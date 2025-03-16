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

echo -e "${YELLOW}Starting installation...${RC}"

# Helper function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

fetch() {
    local REPO_DIR="$HOME/.zsh/myZSH"
    if [ -d "$REPO_DIR" ]; then
        echo "Repository already exists. Checking for updates..."
        cd "$REPO_DIR"
        git fetch origin
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u})
        if [ "$LOCAL" = "$REMOTE" ]; then
            echo "Repository is up to date."
        else
            echo "Updating repository..."
            git pull
        fi
    else
        echo "Repository does not exist. Cloning..."
        mkdir -p "$HOME/.zsh"
        cd "$HOME/.zsh"
        git clone https://github.com/its-ashu-otf/myZSH.git
        cd myZSH
    fi
}

checkEnv() {
    local REQUIREMENTS=('curl' 'groups' 'sudo')
    for req in "${REQUIREMENTS[@]}"; do
        if ! command_exists "$req"; then
            echo -e "${RED}To run me, you need: ${REQUIREMENTS[*]}${RC}"
            exit 1
        fi
    done

    local PACKAGEMANAGER=('apt' 'yum' 'dnf' 'pacman' 'zypper' 'emerge' 'xbps-install' 'nix-env')
    for pgm in "${PACKAGEMANAGER[@]}"; do
        if command_exists "$pgm"; then
            PACKAGER="$pgm"
            echo -e "Using ${pgm}"
            break
        fi
    done

    if [ -z "${PACKAGER}" ]; then
        echo -e "${RED}Can't find a supported package manager${RC}"
        exit 1
    fi

    if command_exists sudo; then
        SUDO_CMD="sudo"
    elif command_exists doas && [ -f "/etc/doas.conf" ]; then
        SUDO_CMD="doas"
    else
        SUDO_CMD="su -c"
    fi

    echo "Using ${SUDO_CMD} as privilege escalation software"
    
    local GITPATH
    GITPATH="$(dirname "$(realpath "$0")")"
    if [[ ! -w ${GITPATH} ]]; then
        echo -e "${RED}Can't write to ${GITPATH}${RC}"
        exit 1
    fi

    local SUPERUSERGROUP=('wheel' 'sudo' 'root')
    for sug in "${SUPERUSERGROUP[@]}"; do
        if groups | grep -q "${sug}"; then
            SUGROUP="${sug}"
            echo -e "Super user group ${SUGROUP}"
            break
        fi
    done

    if ! groups | grep -q "${SUGROUP}"; then
        echo -e "${RED}You need to be a member of the sudo group to run me!${RC}"
        exit 1
    fi
}

install_dependencies() {
    local DEPENDENCIES=(
        "zsh" "curl" "git" "tar" "tree" "fzf" "zoxide" "fastfetch"
        "meld" "multitail" "trash-cli" "zsh-autosuggestions"
        "zsh-syntax-highlighting" "grc" "colorize" "eza" "fd-find"
    )
    local PACKAGE_MANAGER=""
    local MANAGERS=("apt" "yum" "dnf" "pacman" "zypper" "emerge" "xbps-install" "nix-env")

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
        if [ -f /etc/os-release ]; then
            . /etc/os-release
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

install_starship() {
    echo "Installing Starship..."
    if ! command_exists starship; then
        curl -fsSL https://starship.rs/install.sh | sh
    else
        echo "Starship is already installed."
    fi
}

install_zoxide() {
    echo "Installing Zoxide..."
    if ! command_exists zoxide; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    else
        echo "Zoxide is already installed."
    fi
}

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
    local FONT_DIR="/usr/local/share/fonts"
    local FONT_NAME="FiraCodeNerdFont-Regular.ttf"
    local FIRA_ZIP="FiraCode.zip"
    local HACK_ZIP="Hack.zip"
    local TEMP_DIR
    TEMP_DIR="$(mktemp -d)"

    if [ ! -f "$FONT_DIR/$FONT_NAME" ]; then
        echo "Downloading fonts..."
        
        local DOWNLOAD_URLS
        DOWNLOAD_URLS=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | \
            grep -E 'browser_download_url.*(FiraCode.zip|Hack.zip)' | \
            cut -d '"' -f 4)

        if [ -z "$DOWNLOAD_URLS" ]; then
            echo "Failed to fetch download URLs for fonts."
            exit 1
        fi

        for url in $DOWNLOAD_URLS; do
            wget -q -P "$TEMP_DIR" "$url" || {
                echo "Failed to download font from $url"
                exit 1
            }
        done

        echo "Unzipping fonts..."
        
        unzip -o "$TEMP_DIR/$FIRA_ZIP" -d "$TEMP_DIR/extracted_fonts" || {
            echo "Failed to unzip $FIRA_ZIP"
            exit 1
        }
        unzip -o "$TEMP_DIR/$HACK_ZIP" -d "$TEMP_DIR/extracted_fonts" || {
            echo "Failed to unzip $HACK_ZIP"
            exit 1
        }

        if [ ! -d "$FONT_DIR" ]; then
            echo "Creating font directory: $FONT_DIR"
            sudo mkdir -p "$FONT_DIR"
        fi

        echo "Installing fonts..."

        sudo mv "$TEMP_DIR/extracted_fonts"/*.ttf "$FONT_DIR/" || {
            echo "Failed to move fonts to $FONT_DIR"
            exit 1
        }

        if command_exists fc-cache; then
            echo "Updating font cache..."
            sudo fc-cache -fv
        else
            echo "Font cache utility not found. Please update manually using 'fc-cache'."
        fi

        echo "Fonts installed successfully."

        rm -r "$TEMP_DIR"
    else
        echo "Font already installed."
    fi
}

setupFastfetchConfig() {
    printf "%b\n" "${YELLOW}Copying Fastfetch config files...${RC}"
    if [ -d "${HOME}/.config/fastfetch" ] && [ ! -d "${HOME}/.config/fastfetch-bak" ]; then
        cp -r "${HOME}/.config/fastfetch" "${HOME}/.config/fastfetch-bak"
    fi
    mkdir -p "${HOME}/.config/fastfetch/"
    curl -sSLo "${HOME}/.config/fastfetch/config.jsonc" https://raw.githubusercontent.com/ChrisTitusTech/mybash/main/config.jsonc
}

linkConfig() {
    local USER_HOME
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    
    local OLD_ZSHRC="${USER_HOME}/.zshrc"
    if [[ -e ${OLD_ZSHRC} ]]; then
        echo -e "${YELLOW}Moving old zsh config file to ${USER_HOME}/.zshrc.bak${RC}"
        if ! mv "${OLD_ZSHRC}" "${USER_HOME}/.zshrc.bak"; then
            echo -e "${RED}Can't move the old zsh config file!${RC}"
            exit 1
        fi
    fi

    echo -e "${YELLOW}Making Sure Default Shell is set to ZSH...${RC}"
    sudo chsh -s /usr/bin/zsh

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "kali" || "$ID_LIKE" == *"debian"* ]]; then
            echo -e "${YELLOW}Kali or Debian-based system detected, linking starship_kali.toml...${RC}"
            ln -svf "${GITPATH}/starship_kali.toml" "${USER_HOME}/.config/starship.toml"
        else
            echo -e "${YELLOW}Non-Kali system detected, linking default starship.toml...${RC}"
            ln -svf "${GITPATH}/starship.toml" "${USER_HOME}/.config/starship.toml"
        fi
    fi
    
    echo -e "${YELLOW}Linking new zsh config file...${RC}"
    ln -svf "${GITPATH}/.zshrc" "${USER_HOME}/.zshrc"
}

install_TMUX() {
    read -p "Would you like to install or update the TMUX configuration? [y/N] " install_tmux
    if [[ "$install_tmux" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if [ ! -d "$HOME/.tmux" ]; then
            cd
            git clone https://github.com/its-ashu-otf/.tmux.git
        else
            read -p "TMUX configuration already exists. Would you like to update it? [y/N] " update_tmux
            if [[ "$update_tmux" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                cd "$HOME/.tmux"
                git pull
            fi
        fi

        ln -s -f "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
        if [ ! -f "$HOME/.tmux.conf.local" ]; then
            cp "$HOME/.tmux/.tmux.conf.local" "$HOME"
        else
            read -p ".tmux.conf.local already exists. Would you like to replace it? [y/N] " replace_tmux_local
            if [[ "$replace_tmux_local" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                cp "$HOME/.tmux/.tmux.conf.local" "$HOME"
            fi
        fi
    fi
}

if linkConfig; then
    echo -e "${GREEN}Done!\nRestart your shell to see the changes.${RC}"
else
    echo -e "${RED}Something went wrong!${RC}"
fi

# Function Calls
fetch
checkEnv
install_dependencies
install_starship
install_zoxide
install_fastfetch
install_tgpt
install_fonts
setupFastfetchConfig
linkConfig
install_TMUX
