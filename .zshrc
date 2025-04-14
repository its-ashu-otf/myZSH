# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

# Title: myZSH - Ultimate ZSH Configuration
# Author: Ashutosh Gupta (its-ashu-otf)
# Version: 7.0
# Date: 2025-04-07
# Description: ZSH configuration file with various customizations and functions.

#######################################################
#                   INTERACTIVITY CHECK               #
#######################################################

if [[ $- == *i* ]]; then
    iatest=1
else
    iatest=0
fi

#######################################################
# FASTFETCH
#######################################################

# Run fastfetch on terminal startup
if command -v fastfetch &> /dev/null; then
    fastfetch
else
    echo "fastfetch is not installed. Install it for system info display."
fi

#######################################################
#               ENVIRONMENT VARIABLES                 #
#######################################################
export TERM=xterm-256color
export AI_PROVIDER=duckduckgo
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=20000
export HISTTIMEFORMAT="%F %T"
export TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'
export GROFF_NO_SGR=1
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline
export GROFF_NO_SGR=1                  # Fix for man pages colours


# Global variables
REPO_URL="https://github.com/its-ashu-otf/myZSH.git"
REPO_DIR="$HOME/.zsh/myZSH"

#######################################################
#                       FUNCTIONS                     #  
#######################################################


# Update or clone the zsh configuration repository

# Helper functions
print_colored() {
    printf "${1}%s${RC}\n" "$2"
}

# Define color codes using tput for better compatibility
RC=$(tput sgr0)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)

update-MyZSH() {
    REPO_DIR="$HOME/.zsh/myZSH"
    if [ -d "$REPO_DIR" ]; then
        echo "Repository already exists. Fetching changes from remote..."
        cd "$REPO_DIR"
        git fetch origin
        echo "Resetting local changes and syncing with remote..."
        git reset --hard origin/main
        git pull
        echo "Repository updated successfully."
    else
        echo "Repository does not exist. Cloning..."
        mkdir -p "$HOME/.zsh"
        cd "$HOME/.zsh"
        git clone https://github.com/its-ashu-otf/myZSH.git
    fi

    local OLD_ZSHRC="$HOME/.zshrc"
    if [[ -e ${OLD_ZSHRC} ]]; then
        print_colored "$YELLOW" "Moving old zsh config file to ${HOME}/.zshrc.bak"
        if ! mv "${OLD_ZSHRC}" "${HOME}/.zshrc.bak"; then
            print_colored "$RED" "Can't move the old zsh config file!"
            exit 1
        fi
    fi

    print_colored "$YELLOW" "Linking default starship.toml..."
    mkdir -p "$HOME/.config"
    ln -svf "$REPO_DIR/starship.toml" "$HOME/.config/starship.toml"

    print_colored "$YELLOW" "Linking new zsh config file..."
    ln -svf "$REPO_DIR/.zshrc" "$HOME/.zshrc"
}

#######################################################
# SYSTEM INITIALIZATION, FIREWALL, AND SSH MANAGEMENT #
#######################################################

#sytemd, Sysvinit, Openrc or runit identifier
system_init(){
	if command -v systemctl &>/dev/null; then
		INIT_SYSTEM="systemd"
		INIT_SYSTEM_RESTART="sudo systemctl restart"
		INIT_SYSTEM_STOP="sudo systemctl stop"
		INIT_SYSTEM_START="sudo systemctl start"
		INIT_SYSTEM_STATUS="sudo systemctl status"
	elif [ -d /etc/init.d/ ] && [ "$(ls -A /etc/init.d/)" ]; then
		INIT_SYSTEM="SysVinit"
		INIT_SYSTEM_DEFAULT="sudo service"
	elif command -v rc-service &>/dev/null; then
		INIT_SYSTEM="OpenRC"
		INIT_SYSTEM_DEFAULT="sudo rc-service"
	elif command -v sv &>/dev/null; then
		INIT_SYSTEM="runit"
		INIT_SYSTEM_RESTART="sudo sv restart"
		INIT_SYSTEM_START="sudo sv start"
		INIT_SYSTEM_STOP="sudo sv stop"
		INIT_SYSTEM_STATUS="sudo sv status"
	else
		INIT_SYSTEM="Unknown"
		echo -e "[error] system init not found"
	fi
}

if [ -z "$INIT_SYSTEM" ] || [ "$INIT_SYSTEM" = "Unknown" ]; then
	system_init
fi



# simple manager to start, stop, restart and see the status of aplications
system(){
	echo -e '(1) start\n(2) stop\n(3) restart\n(4) status'
	read option
	case $option in
		1)
			echo -e 'name of the app (ex: docker, ssh, Mysql, MongoDb...):\n'
			read app
			if [ "$INIT_SYSTEM" = "SysVinit" ] || [ "$INIT_SYSTEM" = "OpenRC" ]; then
				$INIT_SYSTEM_DEFAULT $FIREWALL start
				else
				$INIT_SYSTEM_START $app
			fi
		;;

		2)
			echo -e 'name of the app (ex: docker, ssh, Mysql, MongoDb...):\n'
			read app
			if [ "$INIT_SYSTEM" = "SysVinit" ] || [ "$INIT_SYSTEM" = "OpenRC" ]; then
				$INIT_SYSTEM_DEFAULT $FIREWALL stop
				else
				$INIT_SYSTEM_STOP $app
			fi
		;;

		3)
			echo -e 'name of the app (ex: docker, ssh, Mysql, MongoDb..):\n'
			read app
			if [ "$INIT_SYSTEM" = "SysVinit" ] || [ "$INIT_SYSTEM" = "OpenRC" ]; then
				$INIT_SYSTEM_DEFAULT $FIREWALL restart
				else
				$INIT_SYSTEM_RESTART $app
			fi
		;;

		4)
			echo -e 'name of the app (ex: docker, ssh, Mysql, MongoDb..):\n'
			read app
			if [ "$INIT_SYSTEM" = "SysVinit" ] || [ "$INIT_SYSTEM" = "OpenRC" ]; then
				$INIT_SYSTEM_DEFAULT $FIREWALL restart
				else
				$INIT_SYSTEM_STATUS $app
			fi

		;;

	esac
}


#firewall simple configuration
firewall() {
		echo -e '(1) firewall status\n(2) reset firewall\n(3) reload firewall\n(4) list apps\n(5) allow (PORT)\n(6) deny (PORT)'
		read option

		if command -v ufw &>/dev/null; then
			FIREWALL="ufw"
		elif command -v firewall-cmd &>/dev/null; then
			FIREWALL="firewalld"
		elif command -v iptables &>/dev/null; then
			FIREWALL="iptables"
		else
			echo "Fail,  firewall not found."
			return 1
		fi

		case $option in
			1)
			echo -e "Firewall status:\n"
			if [ "$FIREWALL" = "ufw" ]; then
				sudo ufw status
			elif [ "$FIREWALL" = "firewalld" ]; then
				sudo firewall-cmd --state
			else
				sudo iptables -L
			fi
			;;
			2)
			echo -e "Resetting firewall:\n"
			if [ "$FIREWALL" = "ufw" ]; then
				sudo ufw reset
			elif [ "$FIREWALL" = "firewalld" ]; then
				sudo firewall-cmd --complete-reload
			else
				sudo iptables -F
			fi
			;;
			3)
			echo -e "Reloading firewall:\n"
			if [ "$FIREWALL" = "ufw" ]; then
				sudo ufw reload
			elif [ "$FIREWALL" = "firewalld" ]; then
				sudo firewall-cmd --reload
			else
				if [ "$INIT_SYSTEM" = "SysVinit" ] || [ "$INIT_SYSTEM" = "OpenRC" ]; then
					$INIT_SYSTEM_DEFAULT $FIREWALL restart
					else
					$INIT_SYSTEM_RESTART $FIREWALL
				fi
			fi
			;;
			4)
			echo -e "App list:\n"
			if [ "$FIREWALL" = "ufw" ]; then
				sudo ufw app list
			elif [ "$FIREWALL" = "firewalld" ]; then
				sudo firewall-cmd --get-services
			else
				sudo iptables --list
			fi
			;;
			5)
			read -p "Digit a port to allow: " allow_port
			if [ "$FIREWALL" = "ufw" ]; then
				sudo ufw allow "$allow_port"
			elif [ "$FIREWALL" = "firewalld" ]; then
				sudo firewall-cmd --permanent --add-port="$allow_port/tcp"
				sudo firewall-cmd --reload
			else
				sudo iptables -A INPUT -p tcp --dport "$allow_port" -j ACCEPT
			fi
			;;
			6)
			read -p "Digit the port to deny:\n" deny_port
			if [ "$FIREWALL" = "ufw" ]; then
				sudo ufw deny "$deny_port"
			elif [ "$FIREWALL" = "firewalld" ]; then
				sudo firewall-cmd --permanent --remove-port="$deny_port/tcp"
				sudo firewall-cmd --reload
			else
				sudo iptables -A INPUT -p tcp --dport "$deny_port" -j DROP
			fi
			;;
			*)
			echo "Invalid option"
			;;
		esac
	}

# SSH simple manager
configssh() {
	echo -e 'SSH MANAGER:\n(1) start\n(2) stop\n(3) restart\n(4) status\n(5) config SSH\n(6) connect to a SSH\n'
	read option

	echo "System init: $INIT_SYSTEM\n"

	case $option in
		1)
			case $INIT_SYSTEM in
				systemd)
					echo -e "Starting SSH with systemd."
					sudo systemctl start ssh
					;;
				SysVinit)
					echo -e "Starting SSH with SysVinit."
					sudo service sshd start
					sudo service ssh start
					;;
				OpenRC)
					echo -e "Starting SSH with OpenRC."
					sudo rc-service sshd start
					;;
				runit)
					echo -e "Starting SSH with runit."
					sudo sv start sshd
					;;
				*)
					echo "Unknown init system, unable to start SSH."
					;;
			esac
			;;
		2)
			case $INIT_SYSTEM in
				systemd)
					echo -e "Stopping SSH with systemd."
					sudo systemctl stop ssh
					;;
				SysVinit)
					echo -e "Stopping SSH with SysVinit."
					sudo service ssh stop
					sudo service sshd stop
					;;
				OpenRC)
					echo -e "Stopping SSH with OpenRC."
					sudo rc-service sshd stop
					;;
				runit)
					echo -e "Stopping SSH with runit."
					sudo sv stop sshd
					;;
				*)
					echo "Fail, unknown init system, unable to stop SSH."
					;;
			esac
			;;
		3)
			case $INIT_SYSTEM in
				systemd)
					echo -e "Restarting SSH with systemd."
					sudo systemctl restart ssh
					;;
				SysVinit)
					echo -e "Restarting SSH with SysVinit."
					sudo service ssh restart
					;;
				OpenRC)
					echo -e "Restarting SSH with OpenRC."
					sudo rc-service sshd restart
					;;
				runit)
					echo -e "Restarting SSH with runit."
					sudo sv restart sshd
					;;
				*)
					echo "Unknown init system, unable to restart SSH."
					;;
			esac
			;;
		4)
			case $INIT_SYSTEM in
				systemd)
					echo -e "Checking SSH status with systemd."
					sudo systemctl status ssh
					;;
				SysVinit)
					echo -e "Checking SSH status with SysVinit."
					sudo service ssh status
					;;
				OpenRC)
					echo -e "Checking SSH status with OpenRC."
					sudo rc-service sshd status
					;;
				runit)
					echo -e "Checking SSH status with runit."
					sudo sv status sshd
					;;
				*)
					echo "Unknown init system, unable to check SSH status."
					;;
			esac
			;;
		5)
			if [ -f /etc/ssh/sshd_config ]; then
				echo -e "Opening sshd_config in vi."
				sudo vi /etc/ssh/sshd_config
			else
				echo "Failed to find the sshd_config file."
			fi
			;;
		6)
			echo -e "Enter username:"
			read user
			echo -e "Enter IP address:"
			read ip
			echo -e "Enter port:"
			read port
			sudo ssh $user@$ip -p $port
			;;
		*)
			echo "Invalid option"
			;;
	esac
}


#######################################################
#                       ALIASES                       #
#######################################################

alias ls='exa --color=always --group-directories-first --icons'
alias ll='exa --icons --long --group-directories-first --sort=size'
alias la='exa -la --color=always --group-directories-first --icons'
alias cls='clear'
alias vi='nvim'
alias svi='sudo vi'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias cp='cp -i'
alias mv='mv -i'
alias bd='cd "$OLDPWD"'
alias history="history 0"
alias alert='notify-send --urgency=low "$(history | tail -n1)"'
alias sgpt='tgpt --model meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias l='ls -CF'
alias hug="hugo server -F --bind=10.0.0.97 --baseURL=http://10.0.0.97"
alias pbcopy='xsel --input --clipboard'
alias pbpaste='xsel --output --clipboard'
alias ii='ifconfig eth0'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias apt-get='sudo apt-get'
alias multitail='multitail --no-repeat -c'
alias freshclam='sudo freshclam'
alias vi='nvim'
alias svi='sudo vi'
alias vis='nvim "+set si"'
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias bd='cd "$OLDPWD"'
alias rmd='/bin/rm  --recursive --force --verbose '
alias lx='ls -lXBh'               # sort by extension
alias lk='ls -lSrh'               # sort by size
alias lc='ls -lcrh'               # sort by change time
alias lu='ls -lurh'               # sort by access time
alias lr='ls -lRh'                # recursive ls
alias lt='ls -ltrh'               # sort by date
alias lm='ls -alh |more'          # pipe through 'more'
alias lw='ls -xAh'                # wide listing format            
alias labc='ls -lap'              # alphabetical sort
alias lf="ls -l | egrep -v '^d'"  # files only
alias ldir="ls -l | egrep '^d'"   # directories only
alias fs='find * -type f | fzf > selected --preview="bat --color=always {}"'
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'
alias h="history | grep "
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias f="find . | grep "
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
alias checkcommand="type -t"
alias openports='netstat -nape --inet'
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
alias sha1='openssl sha1'
alias clickpaste='sleep 3; xdotool type "$(xclip -o -selection clipboard)"'
alias kssh="kitty +kitten ssh"

#######################################################
#              MACHINE SPECIFIC ALIAS'S              #
#######################################################

# Alias's for SSH
# alias SERVERNAME='ssh YOURWEBSITE.com -l USERNAME -p PORTNUMBERHERE'

# Alias's to change the directory
alias web='cd /var/www/html'

# Alias's to mount ISO files
# mount -o loop /home/NAMEOFISO.iso /home/ISOMOUNTDIR/
# umount /home/NAMEOFISO.iso
# (Both commands done as root only.)

#######################################################
#                   SPECIAL FUNCTIONS                 #
#######################################################

# LinUtil By ChristitusTech 
linutil() {
curl -fsSL https://christitus.com/linux | sh
}

# LinUtil Dev By ChristitusTech
linutildev() {
curl -fsSL https://christitus.com/linuxdev | sh
}

# Extract archives
extract() {
    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case $archive in
                *.tar.bz2) tar xvjf $archive ;;
                *.tar.gz) tar xvzf $archive ;;
                *.bz2) bunzip2 $archive ;;
                *.rar) rar x $archive ;;
                *.gz) gunzip $archive ;;
                *.tar) tar xvf $archive ;;
                *.zip) unzip $archive ;;
                *.7z) 7z x $archive ;;
                *) echo "Cannot extract '$archive'" ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# Searches for text in all files in the current folder
ftext() {
	# -i case-insensitive
	# -I ignore binary files
	# -H causes filename to be printed
	# -r recursive search
	# -n causes line number to be printed
	# optional: -F treat search term as a literal, not a regular expression
	# optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
	grep -iIHrn --color=always "$1" . | less -r
}

# Copy file with a progress bar
cpp() {
	set -e
	strace -q -ewrite cp -- "${1}" "${2}" 2>&1 |
		awk '{
	count += $NF
	if (count % 10 == 0) {
		percent = count / total_size * 100
		printf "%3d%% [", percent
		for (i=0;i<=percent;i++)
			printf "="
			printf ">"
			for (i=percent;i<100;i++)
				printf " "
				printf "]\r"
			}
		}
	END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Copy and go to the directory
cpg() {
	if [ -d "$2" ]; then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
mvg() {
	if [ -d "$2" ]; then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
mkdirg() {
	mkdir -p "$1"
	cd "$1"
}

# Goes up a specified number of directories  (i.e. up 4)
up() {
	local d=""
	limit=$1
	for ((i = 1; i <= limit; i++)); do
		d=$d/..
	done
	d=$(echo $d | sed 's/^\///')
	if [ -z "$d" ]; then
		d=..
	fi
	cd $d
}

# Automatically do an ls after each cd, z, or zoxide
cd ()
{
	if [ -n "$1" ]; then
		builtin cd "$@" && ls
	else
		builtin cd ~ && ls
	fi
}

# Returns the last 2 fields of the working directory
pwdtail() {
	pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# Show the current distribution
distribution ()
{
	local dtype="unknown"  # Default to unknown
	# Use /etc/os-release for modern distro identification
	if [ -r /etc/os-release ]; then
		source /etc/os-release
		case $ID in
			fedora|rhel|centos)
				dtype="redhat"
				;;
			sles|opensuse*)
				dtype="suse"
				;;
			ubuntu|debian)
				dtype="debian"
				;;
			kali)
				dtype="kali"
				;;
			arch)
				dtype="arch"
				;;
			slackware)
				dtype="slackware"
				;;
			*)
				# If ID is not recognized, keep dtype as unknown
				;;
		esac
	fi
	echo $dtype
}

# Show the current version of the operating system
ver() {
	local dtype
	dtype=$(distribution)

	case $dtype in
		"redhat")
			if [ -s /etc/redhat-release ]; then
				cat /etc/redhat-release
			else
				cat /etc/issue
			fi
			uname -a
			;;
		"suse")
			cat /etc/SuSE-release
			;;
		"debian")
			lsb_release -a
			;;
		"gentoo")
			cat /etc/gentoo-release
			;;
		"arch")
			cat /etc/os-release
			;;
		"slackware")
			cat /etc/slackware-version
			;;
		*)
			if [ -s /etc/issue ]; then
				cat /etc/issue
			else
				echo "Error: Unknown distribution"
				exit 1
			fi
			;;
	esac
}

# IP address lookup
alias whatismyip="whatsmyip"
function whatsmyip ()
{
	# Internal IP Lookup.
	
	if [ -e /sbin/ip ]; then
		echo -n "Internal IP: "
		/sbin/ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d'/' -f1
	else
		echo -n "Internal IP: "
		/sbin/ifconfig wlan0 | grep "inet " | awk '{print $2}'
	fi
	# External IP Lookup
	echo -n "External IP: "
	curl -s ifconfig.me
}

# View Apache logs
apachelog() {
	if [ -f /etc/httpd/conf/httpd.conf ]; then
		cd /var/log/httpd && ls -xAh && multitail --no-repeat -c -s 2 /var/log/httpd/*_log
	else
		cd /var/log/apache2 && ls -xAh && multitail --no-repeat -c -s 2 /var/log/apache2/*.log
	fi
}

# Edit the Apache configuration
apacheconfig() {
	if [ -f /etc/httpd/conf/httpd.conf ]; then
		sedit /etc/httpd/conf/httpd.conf
	elif [ -f /etc/apache2/apache2.conf ]; then
		sedit /etc/apache2/apache2.conf
	else
		echo "Error: Apache config file could not be found."
		echo "Searching for possible locations:"
		sudo updatedb && locate httpd.conf && locate apache2.conf
	fi
}

# Edit the PHP configuration file
phpconfig() {
	if [ -f /etc/php.ini ]; then
		sedit /etc/php.ini
	elif [ -f /etc/php/php.ini ]; then
		sedit /etc/php/php.ini
	elif [ -f /etc/php5/php.ini ]; then
		sedit /etc/php5/php.ini
	elif [ -f /usr/bin/php5/bin/php.ini ]; then
		sedit /usr/bin/php5/bin/php.ini
	elif [ -f /etc/php5/apache2/php.ini ]; then
		sedit /etc/php5/apache2/php.ini
	else
		echo "Error: php.ini file could not be found."
		echo "Searching for possible locations:"
		sudo updatedb && locate php.ini
	fi
}

# Edit the MySQL configuration file
mysqlconfig() {
	if [ -f /etc/my.cnf ]; then
		sedit /etc/my.cnf
	elif [ -f /etc/mysql/my.cnf ]; then
		sedit /etc/mysql/my.cnf
	elif [ -f /usr/local/etc/my.cnf ]; then
		sedit /usr/local/etc/my.cnf
	elif [ -f /usr/bin/mysql/my.cnf ]; then
		sedit /usr/bin/mysql/my.cnf
	elif [ -f ~/my.cnf ]; then
		sedit ~/my.cnf
	elif [ -f ~/.my.cnf ]; then
		sedit ~/.my.cnf
	else
		echo "Error: my.cnf file could not be found."
		echo "Searching for possible locations:"
		sudo updatedb && locate my.cnf
	fi
}


# Trim leading and trailing spaces (for scripts)
trim() {
	local var=$*
	var="${var#"${var%%[![:space:]]*}"}" # remove leading whitespace characters
	var="${var%"${var##*[![:space:]]}"}" # remove trailing whitespace characters
	echo -n "$var"
}
# GitHub Additions

gcom() {
	git add .
	git commit -m "$1"
}
lazyg() {
	git add .
	git commit -m "$1"
	git push
}

# HasteBin Addition
function hb {
    if [ $# -eq 0 ]; then
        echo "No file path specified."
        return
    elif [ ! -f "$1" ]; then
        echo "File path does not exist."
        return
    fi

    uri="http://bin.christitus.com/documents"
    response=$(curl -s -X POST -d "$(cat "$1")" "$uri")
    if [ $? -eq 0 ]; then
        hasteKey=$(echo $response | jq -r '.key')
        echo "http://bin.christitus.com/$hasteKey"
    else
        echo "Failed to upload the document."
    fi
}

#######################################################
#                   ZSH OPTIONS                       #   
#######################################################
setopt autocd correct interactivecomments magicequalsubst nonomatch notify numericglobsort promptsubst
setopt appendhistory sharehistory hist_ignore_all_dups hist_save_no_dups hist_find_no_dups hist_expire_dups_first
setopt hist_ignore_dups hist_ignore_space hist_verify
setopt auto_pushd pushd_silent pushd_ignore_dups pushd_to_home

    # enable syntax-highlighting
    if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
        ZSH_HIGHLIGHT_STYLES[default]=none
        ZSH_HIGHLIGHT_STYLES[unknown-token]=underline
        ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[global-alias]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[path]=bold
        ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[command-substitution]=none
        ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[process-substitution]=none
        ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
        ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[assign]=none
        ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
        ZSH_HIGHLIGHT_STYLES[named-fd]=none
        ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
        ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
        ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%n@%m: %~\a'
    ;;
*)
    ;;
esac

#######################################################
# AUTOCOMPLETION CONFIGURATION
#######################################################

# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

########################################################
#                 HISTORY CONFIGURATION                #
########################################################
# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history         # share command history data
setopt inc_append_history    # append history to file immediately, not when shell exits
setopt extended_history      # save timestamp and command in history file
setopt hist_save_no_dups     # don't save duplicate commands in history file
setopt hist_find_no_dups     # don't show duplicate commands in history search

#######################################################
#             Key Bindings and Shortcuts              #
#######################################################

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

# ctrl + f for zi
zoxide_i () {
    eval '"$(zoxide query -i)"'
    local precmd
    for precmd in $precmd_functions; do
      $precmd
    done
    zle reset-prompt
}

zle -N zoxide_i        
bindkey '^f' zoxide_i        


#######################################################
#                 PLUGIN INTEGRATIONS                 #
#######################################################

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
source <(fzf --zsh)

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi


# grc colourize implementation
for cmd in g++ head make ld ping6 tail traceroute6 ant blkid curl df diff dig du env fdisk findmnt free gcc getfacl getsebool id ifconfig ip iptables iwconfig jobs last log lsattr lsblk lsmod lsof lspci mount netstat nmap ntpdate ping pv sensors showmount stat sysctl systemctl tcpdump traceroute tune2fs ulimit uptime vmstat whois ; do
    type "${cmd}" >/dev/null 2>&1 && alias "${cmd}"="$(which grc) --colour=auto ${cmd}"
done

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions
fi

######################################################
#		   FZF Integrations		     #
######################################################

### key-bindings.zsh ###
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.zsh
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS


# Key bindings
# ------------

# The code at the top and the bottom of this file is the same as in completion.zsh.
# Refer to that file for explanation.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  __fzf_key_bindings_options="options=(${(j: :)${(kv)options[@]}})"
else
  () {
    __fzf_key_bindings_options="setopt"
    'local' '__fzf_opt'
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        __fzf_key_bindings_options+=" -o $__fzf_opt"
      else
        __fzf_key_bindings_options+=" +o $__fzf_opt"
      fi
    done
  }
fi

'builtin' 'emulate' 'zsh' && 'builtin' 'setopt' 'no_aliases'

{
if [[ -o interactive ]]; then

__fzf_defaults() {
  # $1: Prepend to FZF_DEFAULT_OPTS_FILE and FZF_DEFAULT_OPTS
  # $2: Append to FZF_DEFAULT_OPTS_FILE and FZF_DEFAULT_OPTS
  echo -E "--height ${FZF_TMUX_HEIGHT:-40%} --min-height 20+ --bind=ctrl-z:ignore $1"
  command cat "${FZF_DEFAULT_OPTS_FILE-}" 2> /dev/null
  echo -E "${FZF_DEFAULT_OPTS-} $2"
}

# CTRL-T - Paste the selected file path(s) into the command line
__fzf_select() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  FZF_DEFAULT_COMMAND=${FZF_CTRL_T_COMMAND:-} \
  FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=file,dir,follow,hidden --scheme=path" "${FZF_CTRL_T_OPTS-} -m") \
  FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) "$@" < /dev/tty | while read -r item; do
    echo -n -E "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ -n "${TMUX_PANE-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fzf_select)"
  local ret=$?
  zle reset-prompt
  return $ret
}
if [[ "${FZF_CTRL_T_COMMAND-x}" != "" ]]; then
  zle     -N            fzf-file-widget
  bindkey -M emacs '^T' fzf-file-widget
  bindkey -M vicmd '^T' fzf-file-widget
  bindkey -M viins '^T' fzf-file-widget
fi

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(
    FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) < /dev/tty)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="builtin cd -- ${(q)dir:a}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
if [[ "${FZF_ALT_C_COMMAND-x}" != "" ]]; then
  zle     -N             fzf-cd-widget
  bindkey -M emacs '\ec' fzf-cd-widget
  bindkey -M vicmd '\ec' fzf-cd-widget
  bindkey -M viins '\ec' fzf-cd-widget
fi

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null
  # Ensure the module is loaded if not already, and the required features, such
  # as the associative 'history' array, which maps event numbers to full history
  # lines, are set. Also, make sure Perl is installed for multi-line output.
  if zmodload -F zsh/parameter p:{commands,history} 2>/dev/null && (( ${+commands[perl]} )); then
    selected="$(printf '%s\t%s\000' "${(kv)history[@]}" |
      perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m --read0") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  else
    selected="$(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  fi
  local ret=$?
  if [ -n "$selected" ]; then
    if [[ $(awk '{print $1; exit}' <<< "$selected") =~ ^[1-9][0-9]* ]]; then
      zle vi-fetch-history -n $MATCH
    else # selected is a custom query, not from history
      LBUFFER="$selected"
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N            fzf-history-widget
bindkey -M emacs '^R' fzf-history-widget
bindkey -M vicmd '^R' fzf-history-widget
bindkey -M viins '^R' fzf-history-widget
fi

} always {
  eval $__fzf_key_bindings_options
  'unset' '__fzf_key_bindings_options'
}
### end: key-bindings.zsh ###
### completion.zsh ###
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ completion.zsh
#
# - $FZF_TMUX                 (default: 0)
# - $FZF_TMUX_OPTS            (default: empty)
# - $FZF_COMPLETION_TRIGGER   (default: '**')
# - $FZF_COMPLETION_OPTS      (default: empty)
# - $FZF_COMPLETION_PATH_OPTS (default: empty)
# - $FZF_COMPLETION_DIR_OPTS  (default: empty)


# Both branches of the following `if` do the same thing -- define
# __fzf_completion_options such that `eval $__fzf_completion_options` sets
# all options to the same values they currently have. We'll do just that at
# the bottom of the file after changing options to what we prefer.
#
# IMPORTANT: Until we get to the `emulate` line, all words that *can* be quoted
# *must* be quoted in order to prevent alias expansion. In addition, code must
# be written in a way works with any set of zsh options. This is very tricky, so
# careful when you change it.
#
# Start by loading the builtin zsh/parameter module. It provides `options`
# associative array that stores current shell options.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  # This is the fast branch and it gets taken on virtually all Zsh installations.
  #
  # ${(kv)options[@]} expands to array of keys (option names) and values ("on"
  # or "off"). The subsequent expansion# with (j: :) flag joins all elements
  # together separated by spaces. __fzf_completion_options ends up with a value
  # like this: "options=(shwordsplit off aliases on ...)".
  __fzf_completion_options="options=(${(j: :)${(kv)options[@]}})"
else
  # This branch is much slower because it forks to get the names of all
  # zsh options. It's possible to eliminate this fork but it's not worth the
  # trouble because this branch gets taken only on very ancient or broken
  # zsh installations.
  () {
    # That `()` above defines an anonymous function. This is essentially a scope
    # for local parameters. We use it to avoid polluting global scope.
    'local' '__fzf_opt'
    __fzf_completion_options="setopt"
    # `set -o` prints one line for every zsh option. Each line contains option
    # name, some spaces, and then either "on" or "off". We just want option names.
    # Expansion with (@f) flag splits a string into lines. The outer expansion
    # removes spaces and everything that follow them on every line. __fzf_opt
    # ends up iterating over option names: shwordsplit, aliases, etc.
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        # Option $__fzf_opt is currently on, so remember to set it back on.
        __fzf_completion_options+=" -o $__fzf_opt"
      else
        # Option $__fzf_opt is currently off, so remember to set it back off.
        __fzf_completion_options+=" +o $__fzf_opt"
      fi
    done
    # The value of __fzf_completion_options here looks like this:
    # "setopt +o shwordsplit -o aliases ..."
  }
fi

# Enable the default zsh options (those marked with <Z> in `man zshoptions`)
# but without `aliases`. Aliases in functions are expanded when functions are
# defined, so if we disable aliases here, we'll be sure to have no pesky
# aliases in any of our functions. This way we won't need prefix every
# command with `command` or to quote every word to defend against global
# aliases. Note that `aliases` is not the only option that's important to
# control. There are several others that could wreck havoc if they are set
# to values we don't expect. With the following `emulate` command we
# sidestep this issue entirely.
'builtin' 'emulate' 'zsh' && 'builtin' 'setopt' 'no_aliases'

# This brace is the start of try-always block. The `always` part is like
# `finally` in lesser languages. We use it to *always* restore user options.
{
# The 'emulate' command should not be placed inside the interactive if check;
# placing it there fails to disable alias expansion. See #3731.
if [[ -o interactive ]]; then

# To use custom commands instead of find, override _fzf_compgen_{path,dir}
#
#   _fzf_compgen_path() {
#     echo "$1"
#     command find -L "$1" \
#       -name .git -prune -o -name .hg -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) \
#       -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
#   }
#
#   _fzf_compgen_dir() {
#     command find -L "$1" \
#       -name .git -prune -o -name .hg -prune -o -name .svn -prune -o -type d \
#       -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
#   }

###########################################################

__fzf_defaults() {
  # $1: Prepend to FZF_DEFAULT_OPTS_FILE and FZF_DEFAULT_OPTS
  # $2: Append to FZF_DEFAULT_OPTS_FILE and FZF_DEFAULT_OPTS
  echo -E "--height ${FZF_TMUX_HEIGHT:-40%} --min-height 20+ --bind=ctrl-z:ignore $1"
  command cat "${FZF_DEFAULT_OPTS_FILE-}" 2> /dev/null
  echo -E "${FZF_DEFAULT_OPTS-} $2"
}

__fzf_comprun() {
  if [[ "$(type _fzf_comprun 2>&1)" =~ function ]]; then
    _fzf_comprun "$@"
  elif [ -n "${TMUX_PANE-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]; }; then
    shift
    if [ -n "${FZF_TMUX_OPTS-}" ]; then
      fzf-tmux ${(Q)${(Z+n+)FZF_TMUX_OPTS}} -- "$@"
    else
      fzf-tmux -d ${FZF_TMUX_HEIGHT:-40%} -- "$@"
    fi
  else
    shift
    fzf "$@"
  fi
}

# Extract the name of the command. e.g. ls; foo=1 ssh **<tab>
__fzf_extract_command() {
  # Control completion with the "compstate" parameter, insert and list nothing
  compstate[insert]=
  compstate[list]=
  cmd_word="${(Q)words[1]}"
}

__fzf_generic_path_completion() {
  local base lbuf compgen fzf_opts suffix tail dir leftover matches
  base=$1
  lbuf=$2
  compgen=$3
  fzf_opts=$4
  suffix=$5
  tail=$6

  setopt localoptions nonomatch
  if [[ $base = *'$('* ]] || [[ $base = *'<('* ]] || [[ $base = *'>('* ]] || [[ $base = *':='* ]] || [[ $base = *'`'* ]]; then
    return
  fi
  eval "base=$base" 2> /dev/null || return
  [[ $base = *"/"* ]] && dir="$base"
  while [ 1 ]; do
    if [[ -z "$dir" || -d ${dir} ]]; then
      leftover=${base/#"$dir"}
      leftover=${leftover/#\/}
      [ -z "$dir" ] && dir='.'
      [ "$dir" != "/" ] && dir="${dir/%\//}"
      matches=$(
        export FZF_DEFAULT_OPTS
        FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --scheme=path" "${FZF_COMPLETION_OPTS-}")
        unset FZF_DEFAULT_COMMAND FZF_DEFAULT_OPTS_FILE
        if declare -f "$compgen" > /dev/null; then
          eval "$compgen $(printf %q "$dir")" | __fzf_comprun "$cmd_word" ${(Q)${(Z+n+)fzf_opts}} -q "$leftover"
        else
          if [[ $compgen =~ dir ]]; then
            walker=dir,follow
            rest=${FZF_COMPLETION_DIR_OPTS-}
          else
            walker=file,dir,follow,hidden
            rest=${FZF_COMPLETION_PATH_OPTS-}
          fi
          __fzf_comprun "$cmd_word" ${(Q)${(Z+n+)fzf_opts}} -q "$leftover" --walker "$walker" --walker-root="$dir" ${(Q)${(Z+n+)rest}} < /dev/tty
        fi | while read -r item; do
          item="${item%$suffix}$suffix"
          echo -n -E "${(q)item} "
        done
      )
      matches=${matches% }
      if [ -n "$matches" ]; then
        LBUFFER="$lbuf$matches$tail"
      fi
      zle reset-prompt
      break
    fi
    dir=$(dirname "$dir")
    dir=${dir%/}/
  done
}

_fzf_path_completion() {
  __fzf_generic_path_completion "$1" "$2" _fzf_compgen_path \
    "-m" "" " "
}

_fzf_dir_completion() {
  __fzf_generic_path_completion "$1" "$2" _fzf_compgen_dir \
    "" "/" ""
}

_fzf_feed_fifo() {
  command rm -f "$1"
  mkfifo "$1"
  cat <&0 > "$1" &|
}

_fzf_complete() {
  setopt localoptions ksh_arrays
  # Split arguments around --
  local args rest str_arg i sep
  args=("$@")
  sep=
  for i in {0..${#args[@]}}; do
    if [[ "${args[$i]-}" = -- ]]; then
      sep=$i
      break
    fi
  done
  if [[ -n "$sep" ]]; then
    str_arg=
    rest=("${args[@]:$((sep + 1)):${#args[@]}}")
    args=("${args[@]:0:$sep}")
  else
    str_arg=$1
    args=()
    shift
    rest=("$@")
  fi

  local fifo lbuf matches post
  fifo="${TMPDIR:-/tmp}/fzf-complete-fifo-$$"
  lbuf=${rest[0]}
  post="${funcstack[1]}_post"
  type $post > /dev/null 2>&1 || post=cat

  _fzf_feed_fifo "$fifo"
  matches=$(
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse" "${FZF_COMPLETION_OPTS-} $str_arg") \
    FZF_DEFAULT_OPTS_FILE='' \
      __fzf_comprun "$cmd_word" "${args[@]}" -q "${(Q)prefix}" < "$fifo" | $post | tr '\n' ' ')
  if [ -n "$matches" ]; then
    LBUFFER="$lbuf$matches"
  fi
  command rm -f "$fifo"
}

# To use custom hostname lists, override __fzf_list_hosts.
# The function is expected to print hostnames, one per line as well as in the
# desired sorting and with any duplicates removed, to standard output.
if ! declare -f __fzf_list_hosts > /dev/null; then
  __fzf_list_hosts() {
    setopt localoptions nonomatch
    command cat <(command tail -n +1 ~/.ssh/config ~/.ssh/config.d/* /etc/ssh/ssh_config 2> /dev/null | command grep -i '^\s*host\(name\)\? ' | awk '{for (i = 2; i <= NF; i++) print $1 " " $i}' | command grep -v '[*?%]') \
      <(command grep -oE '^[[a-z0-9.,:-]+' ~/.ssh/known_hosts 2> /dev/null | tr ',' '\n' | tr -d '[' | awk '{ print $1 " " $1 }') \
      <(command grep -v '^\s*\(#\|$\)' /etc/hosts 2> /dev/null | command grep -Fv '0.0.0.0' | command sed 's/#.*//') |
      awk '{for (i = 2; i <= NF; i++) print $i}' | sort -u
  }
fi

_fzf_complete_telnet() {
  _fzf_complete +m -- "$@" < <(__fzf_list_hosts)
}

# The first and the only argument is the LBUFFER without the current word that contains the trigger.
# The current word without the trigger is in the $prefix variable passed from the caller.
_fzf_complete_ssh() {
  local -a tokens
  tokens=(${(z)1})
  case ${tokens[-1]} in
    -i|-F|-E)
      _fzf_path_completion "$prefix" "$1"
      ;;
    *)
      local user
      [[ $prefix =~ @ ]] && user="${prefix%%@*}@"
      _fzf_complete +m -- "$@" < <(__fzf_list_hosts | awk -v user="$user" '{print user $0}')
      ;;
  esac
}

_fzf_complete_export() {
  _fzf_complete -m -- "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_fzf_complete_unset() {
  _fzf_complete -m -- "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_fzf_complete_unalias() {
  _fzf_complete +m -- "$@" < <(
    alias | sed 's/=.*//'
  )
}

_fzf_complete_kill() {
  local transformer
  transformer='
    if [[ $FZF_KEY =~ ctrl|alt|shift ]] && [[ -n $FZF_NTH ]]; then
      nths=( ${FZF_NTH//,/ } )
      new_nths=()
      found=0
      for nth in ${nths[@]}; do
        if [[ $nth = $FZF_CLICK_HEADER_NTH ]]; then
          found=1
        else
          new_nths+=($nth)
        fi
      done
      [[ $found = 0 ]] && new_nths+=($FZF_CLICK_HEADER_NTH)
      new_nths=${new_nths[*]}
      new_nths=${new_nths// /,}
      echo "change-nth($new_nths)+change-prompt($new_nths> )"
    else
      if [[ $FZF_NTH = $FZF_CLICK_HEADER_NTH ]]; then
        echo "change-nth()+change-prompt(> )"
      else
        echo "change-nth($FZF_CLICK_HEADER_NTH)+change-prompt($FZF_CLICK_HEADER_WORD> )"
      fi
    fi
  '
  _fzf_complete -m --header-lines=1 --no-preview --wrap --color fg:dim,nth:regular \
    --bind "click-header:transform:$transformer" -- "$@" < <(
    command ps -eo user,pid,ppid,start,time,command 2> /dev/null ||
      command ps -eo user,pid,ppid,time,args 2> /dev/null || # For BusyBox
      command ps --everyone --full --windows # For cygwin
  )
}

_fzf_complete_kill_post() {
  awk '{print $2}'
}

fzf-completion() {
  local tokens prefix trigger tail matches lbuf d_cmds cursor_pos cmd_word
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins

  # http://zsh.sourceforge.net/FAQ/zshfaq03.html
  # http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion-Flags
  tokens=(${(z)LBUFFER})
  if [ ${#tokens} -lt 1 ]; then
    zle ${fzf_default_completion:-expand-or-complete}
    return
  fi

  # Explicitly allow for empty trigger.
  trigger=${FZF_COMPLETION_TRIGGER-'**'}
  [[ -z $trigger && ${LBUFFER[-1]} == ' ' ]] && tokens+=("")

  # When the trigger starts with ';', it becomes a separate token
  if [[ ${LBUFFER} = *"${tokens[-2]-}${tokens[-1]}" ]]; then
    tokens[-2]="${tokens[-2]-}${tokens[-1]}"
    tokens=(${tokens[0,-2]})
  fi

  lbuf=$LBUFFER
  tail=${LBUFFER:$(( ${#LBUFFER} - ${#trigger} ))}

  # Trigger sequence given
  if [ ${#tokens} -gt 1 -a "$tail" = "$trigger" ]; then
    d_cmds=(${=FZF_COMPLETION_DIR_COMMANDS-cd pushd rmdir})

    {
      cursor_pos=$CURSOR
      # Move the cursor before the trigger to preserve word array elements when
      # trigger chars like ';' or '`' would otherwise reset the 'words' array.
      CURSOR=$((cursor_pos - ${#trigger} - 1))
      # Check if at least one completion system (old or new) is active.
      # If at least one user-defined completion widget is detected, nothing will
      # be completed if neither the old nor the new completion system is enabled.
      # In such cases, the 'zsh/compctl' module is loaded as a fallback.
      if ! zmodload -F zsh/parameter p:functions 2>/dev/null || ! (( ${+functions[compdef]} )); then
        zmodload -F zsh/compctl 2>/dev/null
      fi
      # Create a completion widget to access the 'words' array (man zshcompwid)
      zle -C __fzf_extract_command .complete-word __fzf_extract_command
      zle __fzf_extract_command
    } always {
      CURSOR=$cursor_pos
      # Delete the completion widget
      zle -D __fzf_extract_command  2>/dev/null
    }

    [ -z "$trigger"      ] && prefix=${tokens[-1]} || prefix=${tokens[-1]:0:-${#trigger}}
    if [[ $prefix = *'$('* ]] || [[ $prefix = *'<('* ]] || [[ $prefix = *'>('* ]] || [[ $prefix = *':='* ]] || [[ $prefix = *'`'* ]]; then
      return
    fi
    [ -n "${tokens[-1]}" ] && lbuf=${lbuf:0:-${#tokens[-1]}}

    if eval "noglob type _fzf_complete_${cmd_word} >/dev/null"; then
      prefix="$prefix" eval _fzf_complete_${cmd_word} ${(q)lbuf}
      zle reset-prompt
    elif [ ${d_cmds[(i)$cmd_word]} -le ${#d_cmds} ]; then
      _fzf_dir_completion "$prefix" "$lbuf"
    else
      _fzf_path_completion "$prefix" "$lbuf"
    fi
  # Fall back to default completion
  else
    zle ${fzf_default_completion:-expand-or-complete}
  fi
}

[ -z "$fzf_default_completion" ] && {
  binding=$(bindkey '^I')
  [[ $binding =~ 'undefined-key' ]] || fzf_default_completion=$binding[(s: :w)2]
  unset binding
}

# Normal widget
zle     -N   fzf-completion
bindkey '^I' fzf-completion
fi

} always {
  # Restore the original options.
  eval $__fzf_completion_options
  'unset' '__fzf_completion_options'
}


#######################################################
#                       CLEANUP                       #
#######################################################
unset iatest
