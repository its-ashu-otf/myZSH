#!/bin/bash

# Colors for output
RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

# Display Banner
echo -e "${GREEN}"
cat << "EOF"
        ███╗   ███╗██╗   ██╗███████╗███████╗██╗  ██╗
        ████╗ ████║╚██╗ ██╔╝╚══███╔╝██╔════╝██║  ██║
        ██╔████╔██║ ╚████╔╝   ███╔╝ ███████╗███████║
        ██║╚██╔╝██║  ╚██╔╝   ███╔╝  ╚════██║██╔══██║
        ██║ ╚═╝ ██║   ██║   ███████╗███████║██║  ██║
        ╚═╝     ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝                
                      
   __          _ __                  __                 __  ___
  / /  __ __  (_) /___________ ____ / /  __ _________  / /_/ _/
 / _ \/ // / / / __(_-<___/ _ `(_-</ _ \/ // /___/ _ \/ __/ _/ 
/_.__/\_, / /_/\__/___/   \_,_/___/_//_/\_,_/    \___/\__/_/   
     /___/                                                     
EOF

# Helper function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check and install dependencies
install_dependencies() {
    local DEPENDENCIES=(
        "zsh" "curl" "git" "tar" "tree" "fzf" "zoxide" "fastfetch"
        "meld" "multitail" "trash-cli" "zsh-autosuggestions"
        "zsh-syntax-highlighting" "grc" "colorize" "eza" "fd-find"
    )
    local PACKAGE_MANAGER=""
    local MANAGERS=("apt" "yum" "dnf" "pacman" "zypper" "emerge" "xbps-install" "nix-env")

    # Detect package manager
    for manager in "${MANAGERS[@]}"; do
        if command_exists "$manager"; then
            PACKAGE_MANAGER="$manager"
            break
        fi
    done

    if [ -z "$PACKAGE_MANAGER" ]; then
        echo -e "${RED}No supported package manager found!${RC}"
        exit 1
    fi

    echo -e "${YELLOW}Using $PACKAGE_MANAGER to install dependencies...${RC}"

    if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
        # Install AUR helper for Arch-based systems
        if ! command_exists yay && ! command_exists paru; then
            echo "Installing yay as AUR helper..."
            sudo pacman -S --noconfirm base-devel
            git clone https://aur.archlinux.org/yay-git.git /tmp/yay-git
            (cd /tmp/yay-git && makepkg -si --noconfirm)
        fi
        yay -S --noconfirm "${DEPENDENCIES[@]}"
    else
        sudo "$PACKAGE_MANAGER" install -y "${DEPENDENCIES[@]}"
    fi
}

# Install tgpt
install_tgpt() {
    local INSTALL_DIR="/usr/local/bin"

    echo "Starting tgpt installation..."
    if command_exists tgpt; then
        echo "tgpt is already installed. Skipping."
        return
    fi

    if curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash -s "$INSTALL_DIR"; then
        echo "tgpt installed successfully!"
    else
        echo -e "${RED}Failed to install tgpt.${RC}"
        exit 1
    fi

    echo "Set up your OpenAI API key by adding this to your ~/.bashrc or ~/.zshrc:"
    echo 'export OPENAI_API_KEY="your_openai_api_key"'
}

# Install Starship
install_starship() {
    echo "Installing Starship..."
    if ! command_exists starship; then
        curl -fsSL https://starship.rs/install.sh | sh
    else
        echo "Starship is already installed."
    fi
}

# Install Zoxide
install_zoxide() {
    echo "Installing Zoxide..."
    if ! command_exists zoxide; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    else
        echo "Zoxide is already installed."
    fi
}

# Install Fastfetch
install_fastfetch() {
    echo "Installing Fastfetch..."
    if ! command_exists fastfetch; then
        git clone https://github.com/ChrisTitusTech/fastfetch.git "$HOME/.fastfetch"
        (cd "$HOME/.fastfetch" && make && sudo make install)
    else
        echo "Fastfetch is already installed."
    fi
}

# Main script execution
main() {
    echo -e "${YELLOW}Starting installation...${RC}"

    install_dependencies
    install_starship
    install_zoxide
    install_fastfetch
    install_tgpt

    echo -e "${GREEN}All installations completed successfully! Restart your shell to see changes.${RC}"
}

main
