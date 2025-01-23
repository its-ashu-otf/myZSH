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

    
     if ! command_exists multitail; then
        # Check if the OS is Debian-based (including Kali, Parrot, etc.)
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            # Check if the system is Debian or Debian-like (Kali, Parrot, etc.)
            if [[ "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
                echo "Installing multitail for Debian-based OS (including Kali, Parrot, etc.)..."
                wget -q --show-progress http://ftp.de.debian.org/debian/pool/main/m/multitail/multitail_7.1.2-1_amd64.deb
                chmod +x multitail_7.1.2-1_amd64.deb
                sudo dpkg -i ./multitail_7.1.2-1_amd64.deb
            else
                echo "Skipping multitail installation. Not a Debian-based OS."
            fi
        fi
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

install_fonts() {
    FONT_DIR="/usr/local/share/fonts"
    FONT_NAME="FiraCodeNerdFont-Regular.ttf"
    FIRA_ZIP="FiraCode.zip"
    HACK_ZIP="Hack.zip"
    TEMP_DIR="$(mktemp -d)" # Use a temporary directory for downloads

    # Check if the font is already installed
    if [ ! -f "$FONT_DIR/$FONT_NAME" ]; then
        echo "Downloading fonts..."
        
        # Get the latest release download links
        DOWNLOAD_URLS=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | \
            grep -E 'browser_download_url.*(FiraCode.zip|Hack.zip)' | \
            cut -d '"' -f 4)

        # Ensure there are URLs to download
        if [ -z "$DOWNLOAD_URLS" ]; then
            echo "Failed to fetch download URLs for fonts."
            exit 1
        fi

        # Download FiraCode and Hack font zips
        for url in $DOWNLOAD_URLS; do
            wget -q -P "$TEMP_DIR" "$url" || {
                echo "Failed to download font from $url"
                exit 1
            }
        done

        echo "Unzipping fonts..."
        
        # Unzip both fonts
        unzip -o "$TEMP_DIR/$FIRA_ZIP" -d "$TEMP_DIR/extracted_fonts" || {
            echo "Failed to unzip $FIRA_ZIP"
            exit 1
        }
        unzip -o "$TEMP_DIR/$HACK_ZIP" -d "$TEMP_DIR/extracted_fonts" || {
            echo "Failed to unzip $HACK_ZIP"
            exit 1
        }

        # Check if the font directory exists, and create it if not
        if [ ! -d "$FONT_DIR" ]; then
            echo "Creating font directory: $FONT_DIR"
            sudo mkdir -p "$FONT_DIR"
        fi

        echo "Installing fonts..."

        # Move the fonts to the system font directory
        sudo mv "$TEMP_DIR/extracted_fonts"/*.ttf "$FONT_DIR/" || {
            echo "Failed to move fonts to $FONT_DIR"
            exit 1
        }

        # Update the font cache
        if command -v fc-cache > /dev/null 2>&1; then
            echo "Updating font cache..."
            sudo fc-cache -fv
        else
            echo "Font cache utility not found. Please update manually using 'fc-cache'."
        fi

        echo "Fonts installed successfully."

        # Cleanup
        rm -r "$TEMP_DIR"
    else
        echo "Font already installed."
    fi
}

linkConfig() {
    ## Get the correct user home directory.
    USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
    
    ## Check if a zshrc file is already there.
    OLD_ZSHRC="${USER_HOME}/.zshrc"
    if [[ -e ${OLD_ZSHRC} ]]; then
        echo -e "${YELLOW}Moving old zsh config file to ${USER_HOME}/.zshrc.bak${RC}"
        if ! mv ${OLD_ZSHRC} ${USER_HOME}/.zshrc.bak; then
            echo -e "${RED}Can't move the old zsh config file!${RC}"
            exit 1
        fi
    fi

        # Change Default Shell to ZSH
        echo -e "${YELLOW}Ensuring the default shell is set to ZSH...${RC}"
        
        # Check if /usr/bin/zsh exists
        if [ -x "/usr/bin/zsh" ]; then
            TARGET_SHELL="/usr/bin/zsh"
        elif [ -x "/bin/zsh" ]; then
            TARGET_SHELL="/bin/zsh"
        else
            echo -e "${RED}ZSH is not installed or cannot be found. Please install it first.${RC}"
            exit 1
        fi
        
        # Set the default shell
        if [ "$SHELL" != "$TARGET_SHELL" ]; then
            if sudo chsh -s "$TARGET_SHELL" "${USER}"; then
                echo -e "${GREEN}Default shell successfully changed to ZSH.${RC}"
            else
                echo -e "${RED}Failed to change the default shell. Please check your permissions.${RC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}The default shell is already set to ZSH.${RC}"
        fi

    # Determine which starship configuration to link based on OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        # Check if the OS is Kali or Debian-based
        if [[ "$ID" == "kali" || "$ID_LIKE" == *"debian"* ]]; then
            echo -e "${YELLOW}Kali or Debian-based system detected, linking starship_kali.toml...${RC}"
            ln -svf ${GITPATH}/starship_kali.toml ${USER_HOME}/.config/starship.toml
        else
            echo -e "${YELLOW}Non-Kali system detected, linking default starship.toml...${RC}"
            ln -svf ${GITPATH}/starship.toml ${USER_HOME}/.config/starship.toml
        fi
    fi
    
    echo -e "${YELLOW}Linking new zsh config file...${RC}"
    ## Make symbolic link for .zshrc.
    ln -svf ${GITPATH}/.zshrc ${USER_HOME}/.zshrc
}

# Main script execution
main() {
    echo -e "${YELLOW}Starting installation...${RC}"

    install_dependencies
    install_starship
    install_zoxide
    install_fastfetch
    install_tgpt
    install_fonts
    linkConfig
    
    echo -e "${GREEN}All installations completed successfully! Restart your shell to see changes.${RC}"
}

main
