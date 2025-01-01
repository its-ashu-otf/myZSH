#!/bin/bash

# Color Definitions
RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'
CYAN='\e[96m'

# Function to center text
center_text() {
    local text="$1"
    local line_length="$2"
    local text_length=${#text}
    local padding_before=$(( (line_length - text_length) / 2 ))
    local padding_after=$(( line_length - text_length - padding_before ))

    printf "%s%-${padding_before}s%s%-*s%s\n" "║" " " "$text" "$padding_after" " " "║"
}

# Displaying welcome ASCII art
display_welcome() {
    echo -e "${CYAN}\033[1m
        ███╗   ███╗██╗   ██╗███████╗███████╗██╗  ██╗
        ████╗ ████║╚██╗ ██╔╝╚══███╔╝██╔════╝██║  ██║
        ██╔████╔██║ ╚████╔╝   ███╔╝ ███████╗███████║
        ██║╚██╔╝██║  ╚██╔╝   ███╔╝  ╚════██║██╔══██║
        ██║ ╚═╝ ██║   ██║   ███████╗███████║██║  ██║
        ╚═╝     ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝
    \033[0m"
}

# Fetch repository or update
fetch_repo() {
    REPO_DIR="$HOME/.zsh/myZSH"
    if [ -d "$REPO_DIR" ]; then
        echo "Repository already exists. Checking for updates..."
        cd "$REPO_DIR"
        git fetch origin
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u})
        if [ $LOCAL = $REMOTE ]; then
            echo "Repository is up to date."
        else
            echo "Updating repository..."
            git pull
        fi
    else
        echo "Cloning repository..."
        mkdir -p "$HOME/.zsh"
        cd "$HOME/.zsh"
        git clone https://github.com/its-ashu-otf/myZSH.git
        cd myZSH
    fi
}

# Check if required commands exist
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check system environment
check_system_env() {
    REQUIRED_COMMANDS="curl groups sudo"
    for cmd in $REQUIRED_COMMANDS; do
        if ! command_exists "$cmd"; then
            echo -e "${RED}Missing required command: $cmd${RC}"
            exit 1
        fi
    done

    # Check for supported package manager
    PACKAGE_MANAGERS="apt yum dnf pacman zypper emerge xbps-install nix-env"
    for pkg_mgr in $PACKAGE_MANAGERS; do
        if command_exists "$pkg_mgr"; then
            PACKAGE_MANAGER="$pkg_mgr"
            echo -e "Using package manager: $pkg_mgr"
            break
        fi
    done

    if [ -z "$PACKAGE_MANAGER" ]; then
        echo -e "${RED}Unsupported package manager. Please install a supported one.${RC}"
        exit 1
    fi

    # Set up privilege escalation command
    if command_exists sudo; then
        SUDO_CMD="sudo"
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
    else
        SUDO_CMD="su -c"
    fi

    echo "Using ${SUDO_CMD} for privilege escalation."
}

# Install required dependencies
install_dependencies() {
    DEPENDENCIES="zsh tar bat tree trash-cli fzf zoxide fastfetch meld zsh-autosuggestions zsh-syntax-highlighting grc colorize eza tgpt"
    echo -e "${YELLOW}Installing dependencies...${RC}"

    if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
        if ! command_exists yay && ! command_exists paru; then
            echo "Installing AUR helper..."
            sudo ${PACKAGE_MANAGER} --noconfirm -S base-devel
            cd /opt && sudo git clone https://aur.archlinux.org/yay-git.git && sudo chown -R ${USER}:${USER} ./yay-git
            cd yay-git && makepkg --noconfirm -si
        fi
        AUR_HELPER=$(command_exists yay && echo "yay" || echo "paru")
        ${AUR_HELPER} --noconfirm -S ${DEPENDENCIES}
    else
        sudo ${PACKAGE_MANAGER} install -y ${DEPENDENCIES}
    fi
}

# Install specific software like tgpt, zoxide, starship
install_software() {
    # Install tgpt
    if ! command_exists tgpt; then
        echo "Installing tgpt..."
        wget -q https://raw.githubusercontent.com/aandrew-me/tgpt/main/install -O install.sh
        sudo bash install.sh
        echo "tgpt installed successfully."
    else
        echo "tgpt already installed."
    fi

    # Install zoxide
    if ! command_exists zoxide; then
        echo "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    else
        echo "zoxide already installed."
    fi

    # Install Starship
    if ! command_exists starship; then
        echo "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh
    else
        echo "Starship already installed."
    fi
}

# Install fonts (e.g., FiraCode Nerd Font)
install_fonts() {
    FONT_DIR="/usr/local/share/fonts"
    FONT_NAME="FiraCodeNerdFont-Regular.ttf"

    if [ ! -f "$FONT_DIR/$FONT_NAME" ]; then
        echo "Downloading and installing font..."
        wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
        unzip -o FiraCode.zip -d extracted_fonts
        sudo mv extracted_fonts/*.ttf "$FONT_DIR/"
        rm -rf extracted_fonts FiraCode.zip
        echo "Font installed."
    else
        echo "Font already installed."
    fi
}

# Set up fastfetch config
setup_fastfetch() {
    echo -e "${YELLOW}Setting up fastfetch config...${RC}"
    mkdir -p "${HOME}/.config/fastfetch"
    curl -sSLo "${HOME}/.config/fastfetch/config.jsonc" https://raw.githubusercontent.com/ChrisTitusTech/mybash/main/config.jsonc
}

# Link the configuration files for ZSH, Starship, and TMUX
link_config() {
    USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
    OLD_ZSHRC="${USER_HOME}/.zshrc"
    
    if [ -e "$OLD_ZSHRC" ]; then
        echo -e "${YELLOW}Moving old .zshrc to .zshrc.bak${RC}"
        mv "$OLD_ZSHRC" "${USER_HOME}/.zshrc.bak"
    fi

    # Set default shell to zsh
    echo -e "${YELLOW}Changing default shell to ZSH...${RC}"
    sudo chsh -s /usr/bin/zsh

    # Link Starship config
    echo -e "${YELLOW}Linking Starship config...${RC}"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "kali" || "$ID_LIKE" == *"debian"* ]]; then
            ln -svf "${GITPATH}/starship_kali.toml" "${USER_HOME}/.config/starship.toml"
        else
            ln -svf "${GITPATH}/starship.toml" "${USER_HOME}/.config/starship.toml"
        fi
    fi

    # Link .zshrc
    ln -svf "${GITPATH}/.zshrc" "${USER_HOME}/.zshrc"
}

# Main Script Execution
display_welcome
fetch_repo
check_system_env
install_dependencies
install_software
setup_fastfetch
install_fonts
link_config

echo -e "${GREEN}Setup completed successfully! Please restart your terminal to apply changes.${RC}"
