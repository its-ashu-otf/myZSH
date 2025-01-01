#!/bin/bash

RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

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

command_exists() {
    command -v $1 >/dev/null 2>&1
}

fetch() {
    ## Fetching Repo
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
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo'
    if ! command_exists ${REQUIREMENTS}; then
        echo -e "${RED}To run me, you need: ${REQUIREMENTS}${RC}"
        exit 1
    fi

    ## Check Package Manager
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
    
    ## Check if the current directory is writable.
    GITPATH="$(dirname "$(realpath "$0")")"
    if [[ ! -w ${GITPATH} ]]; then
        echo -e "${RED}Can't write to ${GITPATH}${RC}"
        exit 1
    fi

    ## Check SuperUser Group
    SUPERUSERGROUP='wheel sudo root'
    for sug in ${SUPERUSERGROUP}; do
        if groups | grep ${sug}; then
            SUGROUP=${sug}
            echo -e "Super user group ${SUGROUP}"
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | grep ${SUGROUP} >/dev/null; then
        echo -e "${RED}You need to be a member of the sudo group to run me!"
        exit 1
    fi
}

installDepend() {
    ## Check for dependencies.
    DEPENDENCIES='zsh tar bat tree trash-cli fzf zoxide fastfetch meld trash-cli zsh-autosuggestions zsh-syntax-highlighting grc colorize eza'
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

installFastfetch() {
    ## Install fastfetch
    echo -e "${YELLOW}Installing Fastfetch...${RC}"
    if ! command_exists fastfetch; then
        git clone https://github.com/ChrisTitusTech/fastfetch.git "$HOME/.fastfetch" || {
            echo -e "${RED}Failed to clone Fastfetch repository!${RC}"
            exit 1
        }
        cd "$HOME/.fastfetch" && make && sudo make install
    else
        echo "Fastfetch is already installed."
    fi
}

installStarship() {
    if command_exists starship; then
        echo "Starship already installed"
        return
    fi

    if ! curl -sS https://starship.rs/install.sh | sh; then
        echo -e "${RED}Something went wrong during starship install!${RC}"
        exit 1
    fi
}

installtgpt() {
    # Check if tgpt is not installed
    if ! command -v tgpt &> /dev/null; then
        # Download the install script silently
        wget -q https://raw.githubusercontent.com/aandrew-me/tgpt/main/install -O install.sh
        # Run the install script
        sudo bash install.sh
        # Output success message
        echo "tgpt installed successfully"
    else
        # If tgpt is already installed, inform the user
        echo "tgpt is already installed"
    fi
}

installZoxide() {
    if command_exists zoxide; then
        echo "Zoxide already installed"
        return
    fi

    if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        echo -e "${RED}Something went wrong during zoxide install!${RC}"
        exit 1
    fi
}

install_additional_dependencies() {
    if ! command_exists joe; then
        sudo apt install -y joe
    fi
    if ! command_exists meld; then
        sudo apt install -y meld
    fi
    if ! command_exists xsel; then
        sudo apt install -y xsel
    fi
    if ! command_exists xclip; then
        sudo apt install -y xclip
    fi
    if ! command_exists tar; then
        sudo apt install -y tar
    fi
    if ! command_exists tree; then
        sudo apt install -y tree
    fi
    if ! command_exists trash-put; then
        sudo pip install git+https://github.com/andreafrancia/trash-cli
    fi

    if ! command_exists bat; then
        sudo apt install bat -y
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


setupFastfetchConfig() {
    printf "%b\n" "${YELLOW}Copying Fastfetch config files...${RC}"
    if [ -d "${HOME}/.config/fastfetch" ] && [ ! -d "${HOME}/.config/fastfetch-bak" ]; then
        cp -r "${HOME}/.config/fastfetch" "${HOME}/.config/fastfetch-bak"
    fi
    mkdir -p "${HOME}/.config/fastfetch/"
    curl -sSLo "${HOME}/.config/fastfetch/config.jsonc" https://raw.githubusercontent.com/ChrisTitusTech/mybash/main/config.jsonc
}


install_fonts() {
    FONT_DIR="/usr/local/share/fonts"
    FONT_NAME="FiraCodeNerdFont-Regular.ttf"
    if [ ! -f "$FONT_DIR/$FONT_NAME" ]; then
        echo "Downloading fonts..."
        wget -q $(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep 'browser_download_url.*FiraCode.zip' | cut -d '"' -f 4)
        wget -q $(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep 'browser_download_url.*Hack.zip' | cut -d '"' -f 4)
        echo "Unzipping font..."
        unzip -o FiraCode.zip -d extracted_fonts
        unzip -o Hack.zip -d extracted_fonts
        echo "Installing font..."
        sudo mv extracted_fonts/*.ttf "$FONT_DIR/"
        echo "Fonts Installed"
        rm -r extracted_fonts FiraCode.zip
        rm -r extracted_fonts Hack.zip
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
    echo -e "${YELLOW}Making Sure Default Shell is set to ZSH...${RC}"
    sudo chsh -s /usr/bin/zsh

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
installFastfetch
setupFastfetchConfig
linkConfig
install_additional_dependencies
install_fonts
install_TMUX
installtgpt

if linkConfig; then
    echo -e "${GREEN}Done!\nrestart your shell to see the changes.${RC}"
else
    echo -e "${RED}Something went wrong!${RC}"
fi
