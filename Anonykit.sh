#!/bin/bash
# ============================================================
# Elite+++ Linux Security & Privacy Installer (Ultimate Edition)
# Advanced · Hardened · Professional · Ultimate
# ============================================================

# --- Color Codes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

LOG_FILE="/var/log/elite_security_install.log"
VERBOSITY=2         # 1=INFO, 2=DEBUG for more elite output
MAX_LOG_SIZE=1048576  # 1MB log rotation threshold
BACKUP_DIR="/var/backups/security-configs"

# --- Official URLs for Manual Install Fallbacks ---
declare -A official_urls=(
  ["signal-desktop"]="https://signal.org/en/download/"
  ["tailscale"]="https://tailscale.com/download"
  ["brave-browser"]="https://brave.com/download/"
  ["veracrypt"]="https://www.veracrypt.fr"
  ["netdata"]="https://www.netdata.cloud/"
  ["ntopng"]="https://www.ntop.org/products/traffic-analysis/ntop/"
  ["bandwhich"]="https://github.com/imsnif/bandwhich"
  ["autopsy"]="https://www.sleuthkit.org/autopsy/"
  ["sleuthkit"]="https://www.sleuthkit.org/sleuthkit/"
  ["volatility"]="https://www.volatilityfoundation.org/"
  ["scalpel"]="https://github.com/sleuthkit/scalpel"
  ["plaso"]="https://plaso.readthedocs.io/"
  ["gnome-encfs-manager"]="https://github.com/hdn/gnome-encfs-manager"
  ["zulucrypt"]="https://github.com/marcus97/zuluCrypt"
  ["chkservice"]="https://github.com/bluedan/Chkservice"
  ["cortex"]="https://www.thehive-project.org/"
  ["peframe"]="https://github.com/imsnif/peframe"
  ["nikto"]="https://cirt.net/Nikto2"
)

# --- Spinner/Progress Bar Function ---
show_progress_bar() {
    local current=$1
    local total=$2
    local pkg="$3"
    local bar_length=30
    local progress=$(( current * bar_length / total ))
    local rest=$(( bar_length - progress ))
    local bar=""
    for i in $(seq 1 $progress); do
        bar="${bar}="
    done
    for i in $(seq 1 $rest); do
        bar="${bar} "
    done
    printf "\rBuilding [%s] %d/%d: %s" "$bar" "$current" "$total" "$pkg"
}

# --- Spinner Function ---
run_with_spinner() {
    "$@" &
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    printf "   "
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf "\b\b\b\b[%c]" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\b\b\b\b    \b\b\b\b"
    wait $pid
    return $?
}

# --- ASCII ART BANNER ---
clear
cat << "EOF"

              .7
            .'/
           / /
          / /
         / /
        / /
       / /
      / /
     / /         
    / /          
  __|/
,-\__\
|f-"Y\|
\()7L/
 cgD                            __ _
 |\(                          .'  Y '>,
  \ \                        / _   _   \
   \\\                       )(_) (_)(|}
    \\\                      {  4A   } /
     \\\                      \uLuJJ/\l
      \\\                     |3    p)/
       \\\___ __________      /nnm_n//
       c7___-__,__-)\,__)(".  \_>-<_/D
                  //V     \_"-._.__G G_c__.-__<"/ ( \
                         <"-._>__-,G_.___)\   \7\
                        ("-.__.| \"<.__.-" )   \ \
                        |"-.__"\  |"-.__.-".\   \ \
                        ("-.__"". \"-.__.-".|    \_\
                        \"-.__""|!|"-.__.-".)     \ \
                         "-.__""\_|"-.__.-"./      \ l
                          ".__""">G>-.__.-">       .--,_
                              ""  G
                              Hack the World !
[+]Telegram channel :>  https://t.me/bigbtother
              by an0n cloner

Elite Linux Security Installer
Advanced · Hardened · Professional · Ultimate
EOF
echo ""

# --- Logging Functions ---
log_info()  { echo -e "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" | tee -a "$LOG_FILE"; }
log_error() { echo -e "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" | tee -a "$LOG_FILE"; }
log_debug() { [[ $VERBOSITY -ge 2 ]] && echo -e "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] $1" | tee -a "$LOG_FILE"; }

# --- Log Rotation ---
[[ -f $LOG_FILE && $(stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]] && {
  mv "$LOG_FILE" "$LOG_FILE.old"
  log_info "Rotated log file (max size exceeded)."
}

# --- Ensure Root Access ---
[[ $EUID -ne 0 ]] && {
  echo -e "${RED}[ERROR] Please run this script as root (using sudo or login as root).${NC}"
  exit 2
}

# --- Advanced Virtualization/Sandbox Detection ---
detect_vm() {
    log_info "Performing virtualization and sandbox detection..."
    virt=$(systemd-detect-virt 2>/dev/null)
    if [[ -n "$virt" && "$virt" != "none" ]]; then
        log_info "Virtualization detected: $virt"
    else
        log_info "No virtualization detected by systemd-detect-virt."
    fi
    if grep -qi hypervisor /proc/cpuinfo; then
        log_info "Hypervisor flag found in /proc/cpuinfo."
    else
        log_debug "No hypervisor flag present in /proc/cpuinfo."
    fi
}

# --- Distro & Package Manager Detection ---
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            debian|ubuntu|kali|pop)
                PKG_MANAGER="apt"
                ;;
            arch|manjaro)
                PKG_MANAGER="pacman"
                ;;
            fedora|rhel|rocky|alma)
                PKG_MANAGER="dnf"
                ;;
            opensuse*)
                PKG_MANAGER="zypper"
                ;;
            *)
                log_error "Unsupported distribution: $ID"
                exit 1
                ;;
        esac
        log_info "Detected OS: $PRETTY_NAME using $PKG_MANAGER."
        CODENAME=$(lsb_release -cs)
    else
        log_error "Cannot detect Linux distribution. Exiting."
        exit 1
    fi
}

# --- Remove Problematic Repository Files (for Kali Rolling) ---
clean_kali_repos() {
    if [[ "$CODENAME" == "kali-rolling" ]]; then
        for repo in tailscale.list ntop.list brave-browser-release.list; do
            if [[ -f "/etc/apt/sources.list.d/${repo}" ]]; then
                log_info "Removing problematic repository file: /etc/apt/sources.list.d/${repo}"
                sudo rm -f "/etc/apt/sources.list.d/${repo}"
            fi
        done
        sudo apt update
    fi
}

# --- Disk Space Estimation ---
estimate_disk_space() {
    local size_mb=6000  # ~6GB estimated.
    log_info "Estimated required disk space: ~$((size_mb / 1024)) GB"
    read -rp "Continue with installation? (y/n): " confirm
    [[ $confirm =~ ^[yY]$ ]] || { log_info "Installation aborted by user."; exit 0; }
}

# --- System Update & Upgrade ---
system_update() {
    clean_kali_repos
    log_info "Updating system..."
    if [ "$PKG_MANAGER" == "apt" ]; then
        run_with_spinner sudo apt update && sudo apt full-upgrade -y
    elif [ "$PKG_MANAGER" == "pacman" ]; then
        run_with_spinner sudo pacman -Syu --noconfirm
    elif [ "$PKG_MANAGER" == "dnf" ]; then
        run_with_spinner sudo dnf upgrade -y
    elif [ "$PKG_MANAGER" == "zypper" ]; then
        run_with_spinner sudo zypper refresh && sudo zypper update -y
    fi
    if [[ $? -eq 0 ]]; then
        log_info "System update completed."
    else
        log_error "System update failed. Exiting."
        exit 1
    fi
}

# --- Backup Critical Configurations ---
backup_configs() {
    mkdir -p "$BACKUP_DIR"
    cp -r /etc/ssh "$BACKUP_DIR/" 2>/dev/null
    cp /etc/sysctl.conf "$BACKUP_DIR/" 2>/dev/null
    log_info "Backed up configuration files to $BACKUP_DIR."
}

# --- Harden SSH Configuration ---
harden_ssh() {
    sed -ri 's/^#?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -ri 's/^#?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    if systemctl reload sshd 2>/dev/null; then
        log_info "sshd service reloaded successfully."
    elif systemctl reload ssh 2>/dev/null; then
        log_info "ssh service reloaded successfully."
    else
        log_error "Failed to reload SSH service. Please reload it manually."
    fi
}

# --- Harden Kernel Parameters ---
harden_sysctl() {
    cat <<EOF >> /etc/sysctl.conf
# Elite+++ Kernel Hardening
kernel.randomize_va_space=2
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv4.tcp_syncookies=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.tcp_congestion_control=cubic
EOF
    sysctl -p && log_info "Kernel sysctl parameters hardened."
}

# --- APT-Specific Special Package Functions ---
install_signal_desktop_apt() {
    if [[ ! -f /etc/apt/sources.list.d/signal.list ]]; then
        log_info "Adding Signal Desktop repository..."
        wget -qO- https://updates.signal.org/desktop/apt/keys.asc | sudo gpg --dearmor -o /usr/share/keyrings/signal-desktop-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal.list > /dev/null
        sudo apt update
    fi
    sudo apt install -y signal-desktop
}

install_tailscale_apt() {
    if [[ "$CODENAME" == "kali-rolling" ]]; then
        log_error "Tailscale repository is not available for kali-rolling."
        log_error "Please visit ${official_urls[tailscale]} to install Tailscale manually."
        return 1
    fi
    log_info "Adding Tailscale repository..."
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/${CODENAME}.noarmor.gpg | sudo apt-key add -
    echo "deb [trusted=yes] https://pkgs.tailscale.com/stable/ubuntu ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/tailscale.list
    sudo apt update
    sudo apt install -y tailscale
}

install_brave_browser_apt() {
    if [[ "$CODENAME" == "kali-rolling" ]]; then
        log_error "Brave Browser repository is not available for kali-rolling."
        log_error "Please visit ${official_urls[brave-browser]} to install Brave Browser manually."
        return 1
    fi
    log_info "Adding Brave Browser repository..."
    sudo apt install -y curl apt-transport-https
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
      https://brave.com/signing-keys/brave-browser-archive-keyring.gpg
    echo "deb [trusted=yes,signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave.com/apt stable main" | \
      sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
    sudo apt update
    sudo apt install -y brave-browser
}

install_veracrypt_apt() {
    log_info "Veracrypt not available in apt repositories. Attempting Snap installation..."
    if command -v snap &>/dev/null; then
        snap install veracrypt
    else
        log_error "Snap is not installed. Please visit ${official_urls[veracrypt]} to install VeraCrypt manually."
    fi
}

install_netdata_apt() {
    log_info "Installing Netdata using the official kickstart script..."
    bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait
}

install_ntopng_apt() {
    if [[ "$CODENAME" == "kali-rolling" ]]; then
        log_error "ntopng repository is not available for kali-rolling."
        log_error "Please visit ${official_urls[ntopng]} to install ntopng manually."
        return 1
    fi
    log_info "Adding ntopng repository..."
    wget -qO - https://packages.ntop.org/apt/ntop.key | sudo apt-key add -
    echo "deb [trusted=yes] https://packages.ntop.org/apt/${CODENAME}/ ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/ntop.list
    sudo apt update
    sudo apt install -y ntopng
}

install_bandwhich_apt() {
    log_info "Installing bandwhich via cargo (Rust tool)..."
    if ! command -v bandwhich &>/dev/null; then
        if ! command -v cargo &>/dev/null; then
            sudo apt install -y cargo
        fi
        cargo install bandwhich
    else
        log_info "bandwhich is already installed."
    fi
}

# --- New Function: Auto Install & Run Nikto Scan ---
run_nikto_scan() {
    # Prompt user for port
    read -rp "Enter target port for Nikto scan on localhost (default 80): " nikto_port
    if [[ -z "$nikto_port" ]]; then
        nikto_port=80
    fi
    if ! command -v nikto &>/dev/null; then
        log_info "Nikto not found. Attempting to install via apt..."
        sudo apt install -y nikto
        if [[ $? -ne 0 ]]; then
            log_error "Nikto installation failed. Please visit ${official_urls[nikto]} for manual installation."
            return 1
        fi
    fi
    log_info "Running Nikto vulnerability scan on localhost:$nikto_port ... Please wait."
    run_with_spinner sudo nikto -h localhost -p "$nikto_port"
    if [[ $? -eq 0 ]]; then
        log_info "Nikto scan completed successfully."
    else
        log_error "Nikto scan encountered errors."
    fi
}

# --- New Function: Run rkhunter Scan ---
run_rkhunter_scan() {
    if ! command -v rkhunter &>/dev/null; then
        log_error "rkhunter is not installed."
        return 1
    fi
    log_info "Running rkhunter scan... Please wait."
    run_with_spinner sudo rkhunter --checkall --skip-keypress
    if [[ $? -eq 0 ]]; then
        log_info "rkhunter scan completed successfully."
    else
        log_error "rkhunter scan encountered errors."
    fi
}

# --- Generic Package Installation Function ---
install_package() {
    local pkg="$1"
    if command -v "$pkg" &>/dev/null; then
        log_debug "$pkg is already installed; skipping."
        return 0
    fi

    log_info "Attempting to install package: $pkg"

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        case "$pkg" in
            signal-desktop)
                install_signal_desktop_apt; return ;;
            tailscale)
                install_tailscale_apt; return ;;
            brave-browser)
                install_brave_browser_apt; return ;;
            veracrypt)
                install_veracrypt_apt; return ;;
            netdata)
                install_netdata_apt; return ;;
            ntopng)
                install_ntopng_apt; return ;;
            bandwhich)
                install_bandwhich_apt; return ;;
            # For packages not available via apt.
            gnome-encfs-manager|zulucrypt|chkservice|cortex|peframe|volatility)
                log_error "Package '$pkg' is not available via apt."
                if [[ -n "${official_urls[$pkg]}" ]]; then
                    log_error "Please visit ${official_urls[$pkg]} to install $pkg manually."
                fi
                return 1
                ;;
            *)
                sudo apt install -y "$pkg"
                ;;
        esac
    else
        case "$PKG_MANAGER" in
            pacman)
                sudo pacman -S --noconfirm "$pkg"
                ;;
            dnf)
                sudo dnf install -y "$pkg"
                ;;
            zypper)
                sudo zypper install -y "$pkg"
                ;;
        esac
    fi

    if [[ $? -eq 0 ]]; then
        log_info "$pkg installed successfully."
    else
        log_error "Installation of $pkg failed."
        if [[ -n "${official_urls[$pkg]}" ]]; then
            log_error "Please visit ${official_urls[$pkg]} to install $pkg manually."
        fi
    fi
}


security_tools=(
    keepassxc tor signal-desktop openvpn wireguard ufw fail2ban apparmor
    gnupg bleachbit rkhunter chkrootkit firejail onionshare mat2 torsocks
    apparmor-profiles gnome-encfs-manager zulucrypt psad ferm iptables-persistent
)
network_tools=(
    brave-browser tailscale torbrowser-launcher proxychains4 i2pd dnscrypt-proxy stubby unbound
)
monitoring_tools=(
    htop glances ntopng lynis wireshark tcpdump bandwhich nmap tripwire auditd opensnitch chkservice
    netdata netdiscover iptraf-ng iftop inxi bpytop bmon
)
recon_tools=(
    cortex theharvester maltego yara peframe mitmproxy
)
forensics_tools=(
    autopsy sleuthkit volatility scalpel plaso
)


install_toolset() {
    local -n toolset=$1
    local total=${#toolset[@]}
    local count=0
    for pkg in "${toolset[@]}"; do
        ((count++))
        show_progress_bar $count $total "$pkg"
        install_package "$pkg"
    done
    echo ""  
}


show_menu() {
    while true; do
        clear
        echo -e "${CYAN}========== Elite+++ Linux Security Installer ==========${NC}"
        echo -e "${RED}1) Install Security & Privacy Tools${NC}"
        echo -e "${GREEN}2) Install Network & DNS Privacy Tools${NC}"
        echo -e "${YELLOW}3) Install Monitoring & System Tools${NC}"
        echo -e "${BLUE}4) Install Intelligence & Recon Tools${NC}"
        echo -e "${PURPLE}5) Install Forensics Tools${NC}"
        echo -e "${CYAN}6) Install All Tools${NC}"
        echo -e "${GREEN}7) Harden System (SSH, sysctl)${NC}"
        echo -e "${YELLOW}8) Run Virtualization/Sandbox Detection${NC}"
        echo -e "${RED}9) Run rkhunter Scan${NC}"
        echo -e "${RED}10) Run Nikto Scan on localhost${NC}"
        echo -e "${RED}0) Exit${NC}"
        echo ""
        read -rp "Enter your choice: " choice
        case $choice in
            1) install_toolset security_tools ;;
            2) install_toolset network_tools ;;
            3) install_toolset monitoring_tools ;;
            4) install_toolset recon_tools ;;
            5) install_toolset forensics_tools ;;
            6)
               install_toolset security_tools
               install_toolset network_tools
               install_toolset monitoring_tools
               install_toolset recon_tools
               install_toolset forensics_tools
               ;;
            7)
               backup_configs
               harden_ssh
               harden_sysctl
               ;;
            8)
               detect_vm
               ;;
            9)
               run_rkhunter_scan
               ;;
            10)
               run_nikto_scan
               ;;
            0) log_info "Exiting Elite+++ Installer."; exit 0 ;;
            *) log_error "Invalid selection. Try again." ;;
        esac
        read -rp "Press any key to continue..." -n1 -s
    done
}

# --- Main Execution Flow ---
detect_distro
estimate_disk_space
system_update
show_menu

