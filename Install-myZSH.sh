#!/bin/bash

RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

# Function to center text
center_text() {
    local text="$1"
    local line_length="$2"
    local text_length=${#text}
    local padding_before=$(( (line_length - text_length) / 2 ))
    local padding_after=$(( line_length - text_length - padding_before ))
    
    printf "%s%-${padding_before}s%s%-*s%s\n" "║" " " "$text" "$padding_after" " " "║"
}

# ASCII Art
echo -e "\033[96m\033[1m  
        ███╗   ███╗██╗   ██╗███████╗███████╗██╗  ██╗
        ████╗ ████║╚██╗ ██╔╝╚══███╔╝██╔════╝██║  ██║
        ██╔████╔██║ ╚████╔╝   ███╔╝ ███████╗███████║
        ██║╚██╔╝██║  ╚██╔╝   ███╔╝  ╚════██║██╔══██║
        ██║ ╚═╝ ██║   ██║   ███████╗███████║██║  ██║
        ╚═╝     ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝                                                  
\033[0m"
echo
echo -e "\033[92m╓────────────────────────────────────────────────────────────╖"
center_text "Welcome to the myZSH setup!" "$line_length"
center_text "Script Name: Install-myZSH.sh " "$line_length"
center_text "Author: its-ashu-otf " "$line_length"
center_text "Installer Version: 5.0.0 " "$line_length"
echo -e "╙────────────────────────────────────────────────────────────╜\033[0m"
echo

command_exists() {
    command -v $1 >/dev/null 2>&1
}

fetch() {
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
        echo "Repository does not exist. Cloning..."
        mkdir -p "$HOME/.zsh"
        cd "$HOME/.zsh"
        git clone https://github.com/its-ashu-otf/myZSH.git
        cd myZSH
    fi
}

checkEnv() {
    REQUIREMENTS='curl groups sudo'
    if ! command_exists ${REQUIREMENTS}; then
        echo -e "${RED}To run me, you need: ${REQUIREMENTS}${RC}"
        exit 1
    fi

    PACKAGEMANAGER='apt yum dnf pacman zypper emerge xbps-install nix-env'
    for pgm in ${PACKAGEMANAGER}; do
        if command_exists ${pgm}; then
            PACKAGER=${pgm}
            echo -e "Using ${pgm}"
        fi
    done

    if [ -z "${PACKAGER}" ]; then
        echo -e "${RED}Can't find a supported package manager"
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
    
    GITPATH="$(dirname "$(realpath "$0")")"
    if [[ ! -w ${GITPATH} ]]; then
        echo -e "${RED}Can't write to ${GITPATH}${RC}"
        exit 1
    fi

    SUPERUSERGROUP='wheel sudo root'
    for sug in ${SUPERUSERGROUP}; do
        if groups | grep ${sug}; then
            SUGROUP=${sug}
            echo -e "Super user group ${SUGROUP}"
        fi
    done

    if ! groups | grep ${SUGROUP} >/dev/null; then
        echo -e "${RED}You need to be a member of the sudo group to run me!"
        exit 1
    fi
}

installDepend() {
    DEPENDENCIES='zsh tar bat tree trash-cli fzf zoxide fastfetch meld trash-cli zsh-autosuggestions zsh-syntax-highlighting grc colorize eza tgpt'
    echo -e "${YELLOW}Installing dependencies...${RC}"
    if [[ $PACKAGER == "pacman" ]]; then
        if ! command_exists yay && ! command_exists paru; then
            echo "Installing yay as AUR helper..."
            sudo ${PACKAGER} --noconfirm -S base-devel
            cd /opt && sudo git clone https://aur.archlinux.org/yay-git.git && sudo chown -R ${USER}:${USER} ./yay-git
            cd yay-git && makepkg --noconfirm -si
        else
            echo "AUR helper already installed"
        fi
        if command_exists yay; then
            AUR_HELPER="yay"
        elif command_exists paru; then
            AUR_HELPER="paru"
        else
            echo "No AUR helper found. Please install yay or paru."
            exit 1
        fi
        ${AUR_HELPER} --noconfirm -S ${DEPENDENCIES}
    else
        sudo ${PACKAGER} install -yq ${DEPENDENCIES}
    fi
}

install_fonts() {
    FONT_DIR="/usr/local/share/fonts"
    FONT_NAME="FiraCodeNerdFont-Regular.ttf"
    if [ ! -f "$FONT_DIR/$FONT_NAME" ]; then
        echo "Downloading font..."
        wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
        echo "Unzipping font..."
        unzip -o FiraCode.zip -d extracted_fonts
        echo "Installing font..."
        sudo mv extracted_fonts/*.ttf "$FONT_DIR/"
        echo "Fonts Installed"
        rm -r extracted_fonts FiraCode.zip
    else
        echo "Font already installed."
    fi
}

linkConfig() {
    USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
    OLD_ZSHRC="${USER_HOME}/.zshrc"
    if [[ -e ${OLD_ZSHRC} ]]; then
        echo -e "${YELLOW}Moving old zsh config file to ${USER_HOME}/.zshrc.bak${RC}"
        if ! mv ${OLD_ZSHRC} ${USER_HOME}/.zshrc.bak; then
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
            ln -svf ${GITPATH}/starship_kali.toml ${USER_HOME}/.config/starship.toml
        else
            echo -e "${YELLOW}Non-Kali system detected, linking default starship.toml...${RC}"
            ln -svf ${GITPATH}/starship.toml ${USER_HOME}/.config/starship.toml
        fi
    fi
    
    echo -e "${YELLOW}Linking new zsh config file...${RC}"
    ln -svf ${GITPATH}/.zshrc ${USER_HOME}/.zshrc
}


install_TMUX() {
    read -p "Would you like to install or update the TMUX configuration? [y/N] " install_tmux
    if [[ "$install_tmux" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        if [ ! -d "$HOME/.tmux" ]; then
            cd
            git clone https://github.com/its-ashu-otf/.tmux.git
        else
            read -p "TMUX configuration already exists. Would you like to update it? [y/N] " update_tmux
            if [[ "$update_tmux" =~ ^([yY][eE][sS]|[yY])$ ]]
            then
                cd $HOME/.tmux
                git pull
            fi
        fi

        ln -s -f $HOME/.tmux/.tmux.conf $HOME/.tmux.conf
        if [ ! -f "$HOME/.tmux.conf.local" ]; then
            cp $HOME/.tmux/.tmux.conf.local $HOME
        else
            read -p ".tmux.conf.local already exists. Would you like to replace it? [y/N] " replace_tmux_local
            if [[ "$replace_tmux_local" =~ ^([yY][eE][sS]|[yY])$ ]]
            then
                cp $HOME/.tmux/.tmux.conf.local $HOME
            fi
        fi
    fi
}

# Function Calls

fetch
checkEnv
installDepend
installStarship
installZoxide
installtgpt
setupFastfetchConfig
linkConfig
install_additional_dependencies
install_fonts
install_TMUX

echo -e "${GREEN}Done! restart your shell to see the changes.${RC}"
