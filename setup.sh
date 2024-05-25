#!/bin/bash

RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

command_exists() {
    command -v $1 >/dev/null 2>&1
}

checkEnv() {
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo'
    if ! command_exists ${REQUIREMENTS}; then
        echo -e "${RED}To run me, you need: ${REQUIREMENTS}${RC}"
        exit 1
    fi

    ## Check Package Handeler
    PACKAGEMANAGER='apt nala yum dnf pacman zypper'
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
    DEPENDENCIES='zsh tar tree'
    echo -e "${YELLOW}Installing dependencies...${RC}"
    if [[ $PACKAGER == "pacman" ]]; then
        if ! command_exists yay && ! command_exists paru; then
            echo "Installing yay as AUR helper..."
            sudo ${PACKAGER} --noconfirm -S base-devel
            cd /opt && sudo git clone https://aur.archlinux.org/yay-git.git && sudo chown -R ${USER}:${USER} ./yay-git
            cd yay-git && makepkg --noconfirm -si
        else
            echo "Aur helper already installed"
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

installStarship() {
    if command_exists starship; then
        echo "Starship already installed"
        return
    fi

    if ! curl -sS https://starship.rs/install.sh | sh; then
        echo -e "${RED}Something went wrong during starship install!${RC}"
        exit 1
    fi
    if command_exists fzf; then
        echo "Fzf already installed"
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install
    fi
}

installZoxide() {
    sudo apt update
    sudo apt install zoxide fzf -y
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
   sudo apt update
   sudo apt install -y  joe meld nala xsel xclip tar tree
   sudo pip install git+https://github.com/andreafrancia/trash-cli
   sudo nala fetch
   wget https://github.com/fastfetch-cli/fastfetch/releases/download/2.13.2/fastfetch-linux-amd64.deb
   wget https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb
   wget http://ftp.de.debian.org/debian/pool/main/m/multitail/multitail_7.1.2-1_amd64.deb
   chmod +x *.deb
   sudo apt install ./fastfetch-linux-amd64.deb -y
   sudo apt install ./bat_0.24.0_amd64.deb -y
   sudo apt install ./multitail_7.1.2-1_amd64.deb -y
}

install_fonts() {
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaCode.zip
unzip CascadiaCode.zip
sudo mv *.ttf /usr/local/share/fonts/
echo "Fonts Installed"
}

linkConfig() {
    ## Get the correct user home directory.
    USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
    ## Check if a zshrc file is already there.
    OLD_ZSHRC="${USER_HOME}/.zshrc"
    if [[ -e ${OLD_ZZSHRC} ]]; then
        echo -e "${YELLOW}Moving old zsh config file to ${USER_HOME}/.zshrc.bak${RC}"
        if ! mv ${OLD_ZSHRC} ${USER_HOME}/.zshrc.bak; then
            echo -e "${RED}Can't move the old zsh config file!${RC}"
            exit 1
        fi
    fi

    echo -e "${YELLOW}Linking new zsh config file...${RC}"
    ## Make symbolic link.
    ln -svf ${GITPATH}/.zshrc ${USER_HOME}/.zshrc
    ln -svf ${GITPATH}/starship.toml ${USER_HOME}/.config/starship.toml
}

install_TMUX() {
cd
git clone https://github.com/its-ashu-otf/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
}

change_default_sh() {
echo "Changing Default Login SHELL to ZSH"
chsh -s /usr/bin/zsh
}

checkEnv
installDepend
installStarship
installZoxide
install_additional_dependencies
install_fonts
install_TMUX
change_default_sh

if linkConfig; then
    echo -e "${GREEN}Done!\nrestart your shell to see the changes.${RC}"
else
    echo -e "${RED}Something went wrong!${RC}"
fi
