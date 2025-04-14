#!/bin/bash

# Exit on error and undefined variables
set -euo pipefail

# Define color codes using tput for better compatibility
RC=$(tput sgr0)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)

# Global variables
REPO_URL="https://github.com/its-ashu-otf/myZSH.git"
REPO_DIR="$HOME/.zsh/myZSH"
PACKAGER=""
SUDO_CMD=""

# Helper functions
print_colored() {
    printf "${1}%s${RC}\n" "$2"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Display Banner
print_colored "$GREEN" "
        ███╗   ███╗██╗   ██╗███████╗███████╗██╗  ██╗
        ████╗ ████║╚██╗ ██╔╝╚══███╔╝██╔════╝██║  ██║
        ██╔████╔██║ ╚████╔╝   ███╔╝ ███████╗███████║
        ██║╚██╔╝██║  ╚██╔╝   ███╔╝  ╚════██║██╔══██║
        ██║ ╚═╝ ██║   ██║   ███████╗███████║██║  ██║
        ╚═╝     ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝                
"

print_colored "$YELLOW" "Starting installation..."

# Fetch or update the repository
fetch_repository() {
    if [ -d "$REPO_DIR" ]; then
        print_colored "$YELLOW" "Repository already exists. Checking for updates..."
        cd "$REPO_DIR"
        git fetch origin
        if [ "$(git rev-parse @)" != "$(git rev-parse @{u})" ]; then
            print_colored "$YELLOW" "Updating repository..."
            git pull
        else
            print_colored "$GREEN" "Repository is up to date."
        fi
    else
        print_colored "$YELLOW" "Repository does not exist. Cloning..."
        mkdir -p "$(dirname "$REPO_DIR")"
        git clone "$REPO_URL" "$REPO_DIR"
        print_colored "$GREEN" "Repository cloned successfully."
    fi
}

# Check environment and dependencies
check_environment() {
    local REQUIREMENTS=('curl' 'git' 'sudo')
    for req in "${REQUIREMENTS[@]}"; do
        if ! command_exists "$req"; then
            print_colored "$RED" "Missing required command: $req"
            exit 1
        fi
    done

    local PACKAGERS=('apt' 'yum' 'dnf' 'pacman' 'zypper' 'emerge' 'xbps-install' 'nix-env')
    for pgm in "${PACKAGERS[@]}"; do
        if command_exists "$pgm"; then
            PACKAGER="$pgm"
            print_colored "$GREEN" "Using package manager: $pgm"
            break
        fi
    done

    if [ -z "$PACKAGER" ]; then
        print_colored "$RED" "No supported package manager found."
        exit 1
    fi

    if command_exists sudo; then
        SUDO_CMD=$(command -v sudo)
    else
        print_colored "$RED" "sudo is required but not found."
        exit 1
    fi
}

# Install dependencies
install_dependencies() {
    local DEPENDENCIES=(
        "zsh" "curl" "git" "bat" "tar" "tree" "fzf" "zoxide" "fastfetch"
        "meld" "multitail" "trash-cli" "zsh-autosuggestions"
        "zsh-syntax-highlighting" "grc" "colorize" "eza" "fd-find"
    )

    print_colored "$YELLOW" "Installing dependencies..."
    if [[ "$PACKAGER" == "pacman" ]]; then
        $SUDO_CMD pacman -S --noconfirm "${DEPENDENCIES[@]}"
    else
        $SUDO_CMD "$PACKAGER" install -y "${DEPENDENCIES[@]}"
    fi
    print_colored "$GREEN" "Dependencies installed successfully."
}

# Install Starship prompt
install_starship() {
    print_colored "$YELLOW" "Installing Starship..."
    if ! command_exists starship; then
        curl -fsSL https://starship.rs/install.sh | sh -s -- -y
        print_colored "$GREEN" "Starship installed successfully."
    else
        print_colored "$GREEN" "Starship is already installed."
    fi
}

# Install Zoxide
install_zoxide() {
    print_colored "$YELLOW" "Installing Zoxide..."
    if ! command_exists zoxide; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        print_colored "$GREEN" "Zoxide installed successfully."
    else
        print_colored "$GREEN" "Zoxide is already installed."
    fi
}

# Install Fastfetch
install_fastfetch() {
    print_colored "$YELLOW" "Installing Fastfetch..."
    if ! command_exists fastfetch; then
        git clone https://github.com/ChrisTitusTech/fastfetch.git "$HOME/.fastfetch"
        (cd "$HOME/.fastfetch" && make && $SUDO_CMD make install)
        print_colored "$GREEN" "Fastfetch installed successfully."
    else
        print_colored "$GREEN" "Fastfetch is already installed."
    fi
}

# Create Fastfetch configuration
create_fastfetch_config() {
    local CONFIG_DIR="$HOME/.config/fastfetch"
    local CONFIG_FILE="$CONFIG_DIR/config.jsonc"
    
    mkdir -p "$CONFIG_DIR"
    [ -e "$CONFIG_FILE" ] && rm -f "$CONFIG_FILE"
    
    if ! ln -svf "$REPO_DIR/config.jsonc" "$CONFIG_FILE"; then
        print_colored "$RED" "Failed to create symbolic link for fastfetch config"
        exit 1
    fi
}

# Install tgpt
install_tgpt() {
    print_colored "$YELLOW" "Installing tgpt..."
    if ! command_exists tgpt; then
        curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash -s /usr/local/bin
        print_colored "$GREEN" "tgpt installed successfully."
    else
        print_colored "$GREEN" "tgpt is already installed."
    fi
}

# Install fonts
install_fonts() {
    local FONT_NAME="FiraCode Nerd Font"
    local FONT_DIR="/usr/local/share/fonts"
    local TEMP_DIR=""

    # Ensure required commands are available
    if ! command_exists unzip || ! command_exists fc-list; then
        print_colored "$RED" "Missing required commands: unzip or fc-list. Please install them and try again."
        exit 1
    fi

    # Check if the font is already installed
    if fc-list | grep -i "FiraCode" | grep -qi "Nerd"; then
        print_colored "$GREEN" "Font '$FONT_NAME' is already installed."
        return
    fi

    # Create a temporary directory for font installation
    TEMP_DIR=$(mktemp -d) || { print_colored "$RED" "Failed to create temporary directory."; exit 1; }

    # Ensure cleanup of the temporary directory on exit
    trap 'rm -rf "$TEMP_DIR"' EXIT

    print_colored "$YELLOW" "Installing fonts..."
    curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -o "$TEMP_DIR/FiraCode.zip"
    unzip -o "$TEMP_DIR/FiraCode.zip" -d "$TEMP_DIR/fonts"
    $SUDO_CMD mkdir -p "$FONT_DIR"
    $SUDO_CMD mv "$TEMP_DIR/fonts"/*.ttf "$FONT_DIR/"
    $SUDO_CMD fc-cache -fv
    print_colored "$GREEN" "Fonts installed successfully."
}

# Link configuration files
linkConfig() {
    local OLD_ZSHRC="$HOME/.zshrc"
    if [[ -e ${OLD_ZSHRC} ]]; then
        print_colored "$YELLOW" "Moving old zsh config file to ${HOME}/.zshrc.bak"
        if ! mv "${OLD_ZSHRC}" "${HOME}/.zshrc.bak"; then
            print_colored "$RED" "Can't move the old zsh config file!"
            exit 1
        fi
    fi

    print_colored "$YELLOW" "Making sure the default shell is set to ZSH..."
    $SUDO_CMD chsh -s "$(command -v zsh)"

    print_colored "$YELLOW" "Linking default starship.toml..."
    mkdir -p "$HOME/.config"
    ln -svf "$REPO_DIR/starship.toml" "$HOME/.config/starship.toml"

    print_colored "$YELLOW" "Linking new zsh config file..."
    ln -svf "$REPO_DIR/.zshrc" "$HOME/.zshrc"
}

# Main function
main() {
    fetch_repository
    check_environment
    install_dependencies
    install_starship
    install_zoxide
    install_fastfetch
    create_fastfetch_config
    install_tgpt
    install_fonts
    linkConfig
    print_colored "$GREEN" "Installation complete! Restart your shell to see the changes."
}

main
