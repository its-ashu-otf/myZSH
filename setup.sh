#!/bin/bash

# Define color codes for better readability
RC='\e[0m'  # Reset color
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

<<<<<<< Updated upstream
echo -e "${GREEN}"
cat << "EOF"

                            ███████████  █████████  █████   █████
                           ░█░░░░░░███  ███░░░░░███░░███   ░░███ 
 █████████████   █████ ████░     ███░  ░███    ░░░  ░███    ░███ 
░░███░░███░░███ ░░███ ░███      ███    ░░█████████  ░███████████ 
 ░███ ░███ ░███  ░███ ░███     ███      ░░░░░░░░███ ░███░░░░░███ 
 ░███ ░███ ░███  ░███ ░███   ████     █ ███    ░███ ░███    ░███ 
 █████░███ █████ ░░███████  ███████████░░█████████  █████   █████
░░░░░ ░░░ ░░░░░   ░░░░░███ ░░░░░░░░░░░  ░░░░░░░░░  ░░░░░   ░░░░░ 
                  ███ ░███                                       
                 ░░██████                                        
                  ░░░░░░                                         

 __           ___  __            __                 __  ___  ___ 
|__) \ /    |  |  /__`      /\  /__` |__| |  |     /  \  |  |__  
|__)  |     |  |  .__/ ___ /~~\ .__/ |  | \__/ ___ \__/  |  |    
                                                                        
                                                                                                                                                
EOF



=======
# Fetching Repo
mkdir -p ~/.zsh
cd ~/.zsh
git clone https://github.com/its-ashu-otf/myZSH.git
cd myZSH

# Function to check if a command exists
>>>>>>> Stashed changes
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

<<<<<<< Updated upstream
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

=======
mkdir -p ~/.zsh
cd ~/.zsh
git clone https://github.com/its-ashu-otf/myZSH.git
cd myZSH
# Environment checks before installation
>>>>>>> Stashed changes
checkEnv() {
    # List of essential tools required
    REQUIREMENTS='curl groups sudo'
    for req in ${REQUIREMENTS}; do
        if ! command_exists "${req}"; then
            echo -e "${RED}Missing requirement: ${req}. Please install it to continue.${RC}"
            exit 1
        fi
    done

<<<<<<< Updated upstream
    ## Check Package Handeler
    PACKAGEMANAGER='apt yum dnf pacman zypper'
=======
    # Detect package manager
    PACKAGEMANAGER='apt nala yum dnf pacman zypper'
>>>>>>> Stashed changes
    for pgm in ${PACKAGEMANAGER}; do
        if command_exists "${pgm}"; then
            PACKAGER="${pgm}"
            echo -e "${GREEN}Detected package manager: ${pgm}${RC}"
            break
        fi
    done

    if [ -z "${PACKAGER}" ]; then
        echo -e "${RED}No supported package manager found.${RC}"
        exit 1
    fi

    # Check if the script can write to the current directory
    GITPATH="$(dirname "$(realpath "$0")")"
    if [[ ! -w "${GITPATH}" ]]; then
        echo -e "${RED}Cannot write to ${GITPATH}. Please check permissions.${RC}"
        exit 1
    fi

    # Check for superuser group membership
    SUPERUSERGROUP='wheel sudo root'
    for sug in ${SUPERUSERGROUP}; do
        if groups | grep -q "${sug}"; then
            SUGROUP="${sug}"
            echo -e "${GREEN}You are in the superuser group: ${SUGROUP}${RC}"
            break
        fi
    done

    if ! groups | grep -q "${SUGROUP}"; then
        echo -e "${RED}You must be a member of the ${SUGROUP} group to run this script.${RC}"
        exit 1
    fi
}

# Install dependencies
installDepend() {
    DEPENDENCIES='zsh tar tree'
    echo -e "${YELLOW}Installing dependencies...${RC}"
    if [[ "${PACKAGER}" == "pacman" ]]; then
        # Install AUR helper if not present
        if ! command_exists yay && ! command_exists paru; then
            echo "Installing yay as AUR helper..."
            sudo ${PACKAGER} --noconfirm -S base-devel
            cd /opt && sudo git clone https://aur.archlinux.org/yay-git.git && sudo chown -R "${USER}":"${USER}" ./yay-git
            cd yay-git && makepkg --noconfirm -si
        fi
        AUR_HELPER=$(command_exists yay && echo "yay" || command_exists paru && echo "paru")
        if [ -z "${AUR_HELPER}" ]; then
            echo "No AUR helper found. Please install yay or paru manually."
            exit 1
        fi
        ${AUR_HELPER} --noconfirm -S ${DEPENDENCIES}
    else
        sudo ${PACKAGER} install -yq ${DEPENDENCIES}
    fi
}

# Install Starship prompt
installStarship() {
    if command_exists starship; then
        echo "Starship is already installed."
        return
    fi

    if ! curl -sS https://starship.rs/install.sh | sh; then
        echo -e "${RED}Failed to install Starship.${RC}"
        exit 1
    fi

    # Install fzf if not present
    if ! command_exists fzf; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install
    else
        echo "fzf is already installed."
    fi
}

# Install Zoxide
installZoxide() {
<<<<<<< Updated upstream
    sudo apt install fzf -y
    if command_exists zoxide; then
        echo "Zoxide already installed"
        return
    fi

    if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        echo -e "${RED}Something went wrong during zoxide install!${RC}"
        exit 1
=======
    sudo apt update
    sudo apt install fzf -y
    if ! command_exists zoxide; then
        if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
            echo -e "${RED}Failed to install Zoxide.${RC}"
            exit 1
        fi
    else
        echo "Zoxide is already installed."
>>>>>>> Stashed changes
    fi
}

# Additional dependency installations
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

   sudo apt update
<<<<<<< Updated upstream

   if ! command_exists fastfetch; then
       wget -q --show-progress https://github.com/fastfetch-cli/fastfetch/releases/download/2.14.0/fastfetch-linux-amd64.deb
       chmod +x fastfetch-linux-amd64.deb
       sudo apt install ./fastfetch-linux-amd64.deb -y
   fi

   if ! command_exists bat; then
       wget -q --show-progress https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb
       chmod +x bat_0.24.0_amd64.deb
       sudo apt install ./bat_0.24.0_amd64.deb -y
   fi

   if ! command_exists multitail; then
       wget -q --show-progress http://ftp.de.debian.org/debian/pool/main/m/multitail/multitail_7.1.2-1_amd64.deb
       chmod +x multitail_7.1.2-1_amd64.deb
       sudo apt install ./multitail_7.1.2-1_amd64.deb -y
   fi
=======
   sudo apt install -y joe meld nala xsel xclip tar tree
   sudo pip install git+https://github.com/andreafrancia/trash-cli
   sudo nala fetch
   wget https://github.com/fastfetch-cli/fastfetch/releases/download/2.14.0/fastfetch-linux-amd64.deb
   wget https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb
   wget http://ftp.de.debian.org/debian/pool/main/m/multitail/multitail_7.1.2-1_amd64.deb
   chmod +x *.deb
   sudo apt install ./fastfetch-linux-amd64.deb -y
   sudo apt install ./bat_0.24.0_amd64.deb -y
   sudo apt install ./multitail_7.1.2-1_amd64.deb -y
>>>>>>> Stashed changes
}

# Install fonts
install_fonts() {
<<<<<<< Updated upstream
    FONT_DIR="/usr/local/share/fonts"
    FONT_NAME="CaskaydiaCoveNerdFont-Regular.ttf"
    if [ ! -f "$FONT_DIR/$FONT_NAME" ]; then
        echo "Downloading font..."
        wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaCode.zip
        echo "Unzipping font..."
        unzip -o CascadiaCode.zip -d extracted_fonts
        echo "Installing font..."
        sudo mv extracted_fonts/*.ttf "$FONT_DIR/"
        echo "Fonts Installed"
        rm -r extracted_fonts CascadiaCode.zip
    else
        echo "Font already installed."
    fi
=======
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaCode.zip
    unzip CascadiaCode.zip
    sudo mv *.ttf /usr/local/share/fonts/
    echo "Fonts installed."
>>>>>>> Stashed changes
}

# Link configuration files
linkConfig() {
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
    OLD_ZSHRC="${USER_HOME}/.zshrc"
    if [[ -e "${OLD_ZSHRC}" ]]; then
        echo -e "${YELLOW}Backing up old zsh config to ${USER_HOME}/.zshrc.bak${RC}"
        if ! mv "${OLD_ZSHRC}" "${USER_HOME}/.zshrc.bak"; then
            echo -e "${RED}Failed to backup the old zsh config file!${RC}"
            exit 1
        fi
    fi

    echo -e "${YELLOW}Linking new zsh config file...${RC}"
    ln -svf "${GITPATH}/.zshrc" "${USER_HOME}/.zshrc"
    ln -svf "${GITPATH}/starship.toml" "${USER_HOME}/.config/starship.toml"
}

# Install TMUX configuration
install_TMUX() {
<<<<<<< Updated upstream
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
=======
    echo -n "Do you want to install TMUX configuration? (y/n): "
    read answer
    if [[ "$answer" = "y" ]]; then
        if [ ! -d "$HOME/.tmux" ]; then
            cd
            git clone https://github.com/its-ashu-otf/.tmux.git
            ln -s -f .tmux/.tmux.conf
            cp .tmux/.tmux.conf.local .
            echo "TMUX configuration installed."
        else
            echo "TMUX configuration already exists."
        fi
    else
        echo "TMUX installation skipped."
    fi
}

# Execute functions
>>>>>>> Stashed changes
checkEnv
installDepend
installStarship
installZoxide
install_additional_dependencies
install_fonts
install_TMUX
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes

# Final configuration link and completion message
if linkConfig; then
    echo -e "${GREEN}Setup complete! Please restart your shell to see the changes.${RC}"
else
    echo -e "${RED}An error occurred during setup.${RC}"
fi
