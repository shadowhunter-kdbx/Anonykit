#!/bin/bash
# ==============================
# Linux Security & Privacy Tool Installer (Enhanced)
# ==============================

LOG_FILE="security_install.log"
VERBOSITY=1       # 1=INFO, 2=DEBUG
MAX_LOG_SIZE=1048576  # 1MB for log rotation

# --- ASCII ART BANNER ---
clear
cat << "EOF"
=======================================================
   Linux Security & Privacy Tool Installer
=======================================================
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢴⠊⣉⣉⠉⠉⠉⠙⢦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡞⠐⢿⣿⣿⣦⡀⠀⠀⠀⠱⢄⠀⠀⠀⠀⡄⠶⠛⠙⠛⠉⠒⠤⡄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠃⠀⠀⠀⢀⣈⣅⣤⡤⠶⠒⠛⠛⠳⢯⡷⠶⢶⣾⣷⣆⠀⠀⠀⠈⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡶⠶⠚⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢷⡄⠀⠉⠉⠙⠷⠀⠀⠀⠀⢷⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⠛⠀⠀⠀⠀⠀⠀⠀⡀⠀⠄⠃⠀⠀⠄⠀⠀⠄⠀⠀⠻⢧⡀⠀⠀⠀⠀⠀⠀⢀⣿⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠂⠈⠀⠀⠀⠀⠀⠀⠀⠂⠀⠀⠄⠀⠀⠄⠀⠀⠉⠳⢦⣄⡀⠀⠀⢰⣼⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠃⠀⡐⠀⠀⠁⠀⠄⠀⠀⢀⠈⠀⠀⠄⠀⠀⡀⠀⠀⠂⢀⠀⠀⠉⠉⠛⠳⠛⠻⣄⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⡀⠠⠀⠁⠠⠀⠀⠀⠀⠀⢀⠀⠀⠀⠂⠀⠀⠠⠀⢀⠀⠂⡀⠐⠀⠤⢠⡁⠚⢷⣄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⢀⠀⠐⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠂⠀⡀⠂⠠⠐⠀⠄⠂⢀⠊⠀⣃⢦⢡⠉⠄⠛⣧⡀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠈⠀⠀⠀⠀⠀⢀⠀⠀⠄⠀⠁⡀⠐⡀⣀⠁⢠⢡⡌⣀⢆⡄⡌⡰⣈⠆⣻⠜⡂⠑⠬⢿⡆⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡟⢃⣀⠀⠠⠀⠀⠄⠀⡀⠠⣀⢐⡈⣠⣄⢦⡵⢴⠮⠿⢶⠿⣾⣿⣶⣝⣷⣑⢪⡕⣏⡒⠈⢈⣹⣧⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇⠀⢻⣿⣿⣷⣿⡶⠿⠾⠓⠚⠋⠉⠁⠈⣀⠤⣄⣆⢳⡬⡶⢤⢠⢉⠋⠻⣽⢦⣹⣿⢡⠂⠀⢼⣿⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣆⠀⠀⠀⠀⠀⠀⠀⠀⣀⢶⣰⠾⣶⣷⡾⢿⣾⣸⢷⣹⢿⣿⢷⡏⣰⠀⡀⠰⠈⠱⠀⢀⠸⣾⢿⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢶⣦⣜⣦⣻⣞⣷⣯⣶⣷⣿⣷⣿⣾⣟⣾⡝⣧⢟⡾⣿⣿⣿⢧⡝⣦⣒⢤⣀⣦⣠⢾⣿⡟⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣾⣹⢯⣝⣮⢻⡜⣿⣿⣿⣿⣳⣯⣾⣿⣿⢿⣯⣿⠇⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣇⢏⡿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣽⣻⠶⣭⡗⣞⢧⣿⢿⣿⣿⣿⣿⣿⣿⣟⣿⡏⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣎⠜⣧⡻⣽⢿⣿⣿⣿⣿⣽⣿⣎⣿⣦⣽⡞⣮⢼⣛⢾⡹⢯⣿⣿⣳⣿⠇⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣾⣰⢻⣭⣛⢿⣯⢿⣿⣟⣯⣟⣼⡷⣯⣝⢮⣳⠻⣬⣛⣿⣼⣿⣽⣿⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⠎⠠⠙⣯⠓⢮⠛⣾⡹⣷⡻⣯⣟⣾⡷⣟⡷⣯⢯⣷⣻⡷⣿⣾⡿⣟⣿⢸⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⣴⡿⠁⠀⠁⠰⣯⠈⠤⡙⢤⠳⣵⣟⡿⣾⣻⣽⣟⣿⣿⣿⣿⣿⣿⣯⣷⣯⡝⢻⡄⢩⢻⣦⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣀⣴⡟⠉⠀⠠⠁⠀⠀⠀⠘⢷⣄⠑⢢⠙⣼⢣⡽⣻⢷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣞⠯⠊⢄⠘⡠⠈⠊⡷
⠀⠀⠀⣤⠟⡉⠐⡀⢂⡱⢊⣥⣿⢿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠉⠛⠻⠾⢷⣿⣼⣷⣟⣿⣿⣿⡿⠿⠛⠋⠌⠤⣉⠂⠄⠡⢀⠁⠁⠀
=======================================================
EOF
echo ""

# --- Check for root access ---
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] This script must be run as root. Use sudo or switch to the root user."
    exit 2
fi

# --- Ensure sudo is available ---
if ! command -v sudo &>/dev/null; then
    echo "[ERROR] sudo is required but not installed. Exiting."
    exit 3
fi

# --- Logging Functions ---
log_info() {
    echo "[INFO] $1" | tee -a "$LOG_FILE"
}
log_error() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE"
}
log_debug() {
    if [[ $VERBOSITY -ge 2 ]]; then
        echo "[DEBUG] $1" | tee -a "$LOG_FILE"
    fi
}

# --- Rotate log file if it exceeds MAX_LOG_SIZE ---
if [[ -f $LOG_FILE && $(stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]]; then
    mv "$LOG_FILE" "${LOG_FILE}.old"
    log_info "Rotated log file."
fi

# --- Detect Linux Distribution and Package Manager ---
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            debian|ubuntu|kali)
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
                log_error "Unsupported Linux distribution: $ID"
                exit 1
                ;;
        esac
        log_info "Detected Linux Distribution: $NAME ($ID)"
    else
        log_error "Cannot detect Linux distribution. Exiting."
        exit 1
    fi
}

# --- Estimate Disk Space (confirmation prompt) ---
estimate_disk_space() {
    local total_size_mb=5000  # Estimated ~5GB total installation size for extra tools
    local total_size_gb=$(( total_size_mb / 1024 ))
    log_info "Total Estimated Installation Size: ~${total_size_gb}GB"
    read -rp "Do you want to continue? (y/n): " confirm
    if [[ "$confirm" != [yY] ]]; then
        log_info "Installation aborted by user."
        exit 0
    fi
}

# --- System Update & Upgrade ---
system_update() {
    log_info "Updating and upgrading system..."
    case "$PKG_MANAGER" in
        apt)
            sudo apt update && sudo apt full-upgrade -y
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            ;;
        dnf)
            sudo dnf upgrade -y
            ;;
        zypper)
            sudo zypper refresh && sudo zypper update -y
            ;;
    esac
    if [[ $? -eq 0 ]]; then
        log_info "System update complete."
    else
        log_error "System update failed."
        exit 1
    fi
}

# --- Add Signal Repository for apt-based systems ---
setup_signal_repo() {
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        # Check if signal-desktop repository already exists
        if [[ ! -f /etc/apt/sources.list.d/signal.list ]]; then
            log_info "Adding Signal repository..."
            wget -O- https://updates.signal.org/desktop/apt/keys.asc | sudo gpg --dearmor -o /usr/share/keyrings/signal-desktop-keyring.gpg
            if [[ $? -ne 0 ]]; then
                log_error "Failed to download Signal GPG key."
                exit 1
            fi
            echo "deb [signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal.list > /dev/null
            if [[ $? -eq 0 ]]; then
                log_info "Signal repository added successfully. Updating package list..."
                sudo apt update
            else
                log_error "Failed to add Signal repository."
                exit 1
            fi
        else
            log_debug "Signal repository already present."
        fi
    fi
}

# --- Install a Package (with check) ---
install_package() {
    local pkg="$1"
    # Check if package command exists (special cases for browser or GUI apps might need custom check)
    if command -v "$pkg" &>/dev/null; then
        log_info "$pkg is already installed. Skipping..."
        return 0
    fi

    # Special handling for signal-desktop in apt
    if [[ "$pkg" == "signal-desktop" && "$PKG_MANAGER" == "apt" ]]; then
        setup_signal_repo
    fi

    log_info "Installing $pkg..."
    case "$PKG_MANAGER" in
        apt)
            sudo apt install -y "$pkg"
            ;;
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

    if [[ $? -ne 0 ]]; then
        log_error "Failed to install $pkg. Exiting."
        exit 1
    else
        log_info "$pkg installed successfully."
    fi
}

# --- Install Essential Security Tools ---
install_security_tools() {
    local tools=(
        keepassxc tor signal-desktop openvpn wireguard tailscale ufw fail2ban apparmor
        brave-browser thunderbird pidgin i2p veracrypt gnupg bleachbit rkhunter chkrootkit
        firejail onionshare mat2 dnscrypt-proxy torsocks sequoia-pgp yubikey-manager
        metasploit-framework clamav openvas
    )
    for tool in "${tools[@]}"; do 
        install_package "$tool"
    done
}

# --- Install Advanced Monitoring & Network Tools ---
install_monitoring_tools() {
    local tools=(
        htop glances netdata ntopng lynis osquery wireshark tcpdump bandwhich nmap
        tripwire auditd opensnitch chkservice
    )
    for tool in "${tools[@]}"; do 
        install_package "$tool"
    done
}

# --- Install Optional Privacy/Additional Tools ---
install_privacy_tools() {
    local tools=(
        protonvpn-cli i2p-stable torbrowser-launcher
    )
    for tool in "${tools[@]}"; do 
        install_package "$tool"
    done
}

# --- Interactive Menu ---
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
        read -rp "Enter your choice: " choice

        case $choice in
            1)
                install_security_tools
                ;;
            2)
                install_monitoring_tools
                ;;
            3)
                install_privacy_tools
                ;;
            4)
                read -rp "Are you sure you want to install all tools? [y/n]: " confirm_all
                if [[ "$confirm_all" =~ ^[yY]$ ]]; then
                    install_security_tools
                    install_monitoring_tools
                    install_privacy_tools
                else
                    log_info "Installation of all tools aborted."
                fi
                ;;
            0)
                log_info "Exiting installer."
                exit 0
                ;;
            *)
                log_error "Invalid choice. Try again."
                ;;
        esac
        read -rp "Press any key to continue..." -n 1 -s
    done
}

# --- Main Execution Flow ---
detect_distro
estimate_disk_space
system_update
show_menu
