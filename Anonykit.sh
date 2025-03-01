#!/bin/bash

# ==============================
# Linux Security & Privacy Tool Installer
# ==============================

LOG_FILE="security_install.log"
VERBOSITY=1  # Default verbosity: 1 (INFO)
MAX_LOG_SIZE=1048576  # 1MB log rotation size

# --- ASCII ART BANNER ---
clear
echo "======================================================="
echo "   Linux Security & Privacy Tool Installer"
echo "======================================================="
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢴⠊⣉⣉⠉⠉⠉⠙⢦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡞⠐⢿⣿⣿⣦⡀⠀⠀⠀⠱⢄⠀⠀⠀⠀⡄⠶⠛⠙⠛⠉⠒⠤⡄⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠃⠀⠀⠀⢀⣈⣅⣤⡤⠶⠒⠛⠛⠳⢯⡷⠶⢶⣾⣷⣆⠀⠀⠀⠈⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡶⠶⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢷⡄⠀⠉⠉⠙⠷⠀⠀⠀⠀⢷⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⠛⠀⠀⠀⠀⠀⠀⠀⡀⠀⠄⠃⠀⠀⠄⠀⠀⠄⠀⠀⠻⢧⡀⠀⠀⠀⠀⠀⠀⢀⣿⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠂⠈⠀⠀⠀⠀⠀⠀⠀⠂⠀⠀⠄⠀⠀⠄⠀⠀⠉⠳⢦⣄⡀⠀⠀⢰⣼⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠃⠀⡐⠀⠀⠁⠀⠄⠀⠀⢀⠈⠀⠀⠄⠀⠀⡀⠀⠀⠂⢀⠀⠀⠉⠉⠛⠳⠛⠻⣄⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⡀⠠⠀⠁⠠⠀⠀⠀⠀⠀⢀⠀⠀⠀⠂⠀⠀⠠⠀⢀⠀⠂⡀⠐⠀⠤⢠⡁⠚⢷⣄⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⢀⠀⠐⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠂⠀⡀⠂⠠⠐⠀⠄⠂⢀⠊⠀⣃⢦⢡⠉⠄⠛⣧⡀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠈⠀⠀⠀⠀⠀⢀⠀⠀⠄⠀⠁⡀⠐⡀⣀⠁⢠⢡⡌⣀⢆⡄⡌⡰⣈⠆⣻⠜⡂⠑⠬⢿⡆⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⡟⢃⣀⠀⠠⠀⠀⠄⠀⡀⠠⣀⢐⡈⣠⣄⢦⡵⢴⠮⠿⢶⠿⣾⣿⣶⣝⣷⣑⢪⡕⣏⡒⠈⢈⣹⣧⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇⠀⢻⣿⣿⣷⣿⡶⠿⠾⠓⠚⠋⠉⠁⠈⣀⠤⣄⣆⢳⡬⡶⢤⢠⢉⠋⠻⣽⢦⣹⣿⢡⠂⠀⢼⣿⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣆⠀⠀⠀⠀⠀⠀⠀⠀⣀⢶⣰⠾⣶⣷⡾⢿⣾⣸⢷⣹⢿⣿⢷⡏⣰⠀⡀⠰⠈⠱⠀⢀⠸⣾⢿⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢶⣦⣜⣦⣻⣞⣷⣯⣶⣷⣿⣷⣿⣾⣟⣾⡝⣧⢟⡾⣿⣿⣿⢧⡝⣦⣒⢤⣀⣦⣠⢾⣿⡟⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣾⣹⢯⣝⣮⢻⡜⣿⣿⣿⣿⣳⣯⣾⣿⣿⢿⣯⣿⠇⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣇⢏⡿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣽⣻⠶⣭⡗⣞⢧⣿⢿⣿⣿⣿⣿⣿⣿⣟⣿⡏⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣎⠜⣧⡻⣽⢿⣿⣿⣿⣿⣽⣿⣎⣿⣦⣽⡞⣮⢼⣛⢾⡹⢯⣿⣿⣳⣿⠇⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣾⣰⢻⣭⣛⢿⣯⢿⣿⣟⣯⣟⣼⡷⣯⣝⢮⣳⠻⣬⣛⣿⣼⣿⣽⣿⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⠎⠠⠙⣯⠓⢮⠛⣾⡹⣷⡻⣯⣟⣾⡷⣟⡷⣯⢯⣷⣻⡷⣿⣾⡿⣟⣿⢸⡀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⣴⡿⠁⠀⠁⠰⣯⠈⠤⡙⢤⠳⣵⣟⡿⣾⣻⣽⣟⣿⣿⣿⣿⣿⣿⣯⣷⣯⡝⢻⡄⢩⢻⣦⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣀⣴⡟⠉⠀⠠⠁⠀⠀⠀⠘⢷⣄⠑⢢⠙⣼⢣⡽⣻⢷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣞⠯⠊⢄⠘⡠⠈⠊⡷"
echo "⠀⠀⠀⣤⠟⡉⠐⡀⢂⡱⢊⣥⣿⢿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠉⠛⠻⠾⢷⣿⣼⣷⣟⣿⣿⣿⡿⠿⠛⠋⠌⠤⣉⠂⠄⠡⢀⠁⠁⠀"
echo "======================================================="
echo ""


# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] This script must be run as root. Use sudo or switch to the root user."
    exit 2
fi

# Ensure sudo is available
if ! command -v sudo &>/dev/null; then
    echo "[ERROR] sudo is required but not installed. Exiting."
    exit 3
fi

# Logging functions
log_info() { echo "[INFO] $1" | tee -a $LOG_FILE; }
log_error() { echo "[ERROR] $1" | tee -a $LOG_FILE; }
log_debug() { if [[ $VERBOSITY -ge 2 ]]; then echo "[DEBUG] $1" | tee -a $LOG_FILE; fi; }

# Rotate log file if it exceeds MAX_LOG_SIZE
if [[ -f $LOG_FILE && $(stat -c%s $LOG_FILE) -gt $MAX_LOG_SIZE ]]; then
    mv $LOG_FILE "$LOG_FILE.old"
    log_info "Rotated log file."
fi

# Detect Linux Distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            debian|ubuntu|kali) PKG_MANAGER="apt" ;;
            arch|manjaro) PKG_MANAGER="pacman" ;;
            fedora|rhel|rocky|alma) PKG_MANAGER="dnf" ;;
            opensuse*) PKG_MANAGER="zypper" ;;
            *) log_error "Unsupported Linux distribution!"; exit 1 ;;
        esac
        log_info "Detected Linux: $ID"
    else
        log_error "Cannot detect Linux distribution. Exiting."
        exit 1
    fi
}

# Estimate Disk Space for Installation
estimate_disk_space() {
    local total_size_mb=5000  # Estimated ~5GB total installation size for extra tools
    local total_size_gb=$((total_size_mb / 1024))
    log_info "Total Estimated Installation Size: ~${total_size_gb}GB"
    echo "Do you want to continue? (y/n)"
    read -r confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log_info "Installation aborted by user."
        exit 0
    fi
}

# System update & upgrade
system_update() {
    log_info "Updating and upgrading system..."
    case "$PKG_MANAGER" in
        apt) sudo apt update && sudo apt full-upgrade -y ;;
        pacman) sudo pacman -Syu --noconfirm ;;
        dnf) sudo dnf upgrade -y ;;
        zypper) sudo zypper refresh && sudo zypper update -y ;;
    esac
    log_info "System update complete."
}

# Install a package (skips if already installed)
install_package() {
    local pkg="$1"
    if command -v "$pkg" &>/dev/null; then
        log_info "$pkg is already installed. Skipping..."
        return 0
    fi
    log_info "Installing $pkg..."
    case "$PKG_MANAGER" in
        apt) sudo apt install -y "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        dnf) sudo dnf install -y "$pkg" ;;
        zypper) sudo zypper install -y "$pkg" ;;
    esac

    # Check for installation errors
    if [[ $? -ne 0 ]]; then
        log_error "Failed to install $pkg. Exiting."
        exit 1
    fi
}

# Install essential security tools
install_security_tools() {
    local tools=(
        keepassxc tor signal-desktop openvpn wireguard tailscale ufw fail2ban apparmor brave-browser
        thunderbird pidgin i2p veracrypt gnupg bleachbit rkhunter chkrootkit firejail onionshare
        mat2 dnscrypt-proxy torsocks sequoia-pgp yubikey-manager metasploit-framework clamav
        openvas
    )
    for tool in "${tools[@]}"; do 
        install_package "$tool"
    done
}

# Install advanced monitoring & network tools
install_monitoring_tools() {
    local tools=(
        htop glances netdata ntopng lynis osquery wireshark tcpdump bandwhich nmap tripwire auditd opensnitch chkservice
    )
    for tool in "${tools[@]}"; do 
        install_package "$tool"
    done
}

# Optional Installation of Privacy/Additional Tools
install_privacy_tools() {
    local tools=(
        protonvpn-cli i2p-stable torbrowser-launcher
    )
    for tool in "${tools[@]}"; do 
        install_package "$tool"
    done
}

# Interactive menu
show_menu() {
    while true; do
        clear
        echo "===== Security & Privacy Tools Installer ====="
        echo "1) Install Security & Privacy Tools"
        echo "2) Install Monitoring & Network Tools"
        echo "3) Install Privacy Tools"
        echo "4) Install All Tools (Security, Monitoring, Privacy)"
        echo "0) Exit"
        echo ""
        read -p "Enter your choice: " choice

        case $choice in
            1) install_security_tools ;;
            2) install_monitoring_tools ;;
            3) install_privacy_tools ;;
            4)
                read -p "Are you sure you want to install all tools? [y/n]: " confirm_all
                if [[ "$confirm_all" == "y" || "$confirm_all" == "Y" ]]; then
                    install_security_tools
                    install_monitoring_tools
                    install_privacy_tools
                else
                    log_info "Installation of all tools aborted."
                fi
                ;;
            0) exit 0 ;;
            *) log_error "Invalid choice. Try again." ;;
        esac
        read -p "Press any key to continue..." -n 1 -s
    done
}

# Start process
detect_distro
estimate_disk_space
system_update
show_menu
