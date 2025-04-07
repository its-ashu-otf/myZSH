# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

# Title: myZSH - Ultimate ZSH Configuration
# Author: Ashutosh Gupta (its-ashu-otf)
# Version: 7.0
# Date: 2025-04-07
# Description: Zsh configuration file with various customizations and functions.

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
export FZF_DEFAULT_COMMAND="fdfind --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fdfind --type=d --hidden --strip-cwd-prefix"
export FZF_DEFAULT_OPTS="--height 70% --layout=reverse --border --color=hl:#2dd4bf"
export FZF_TMUX_OPTS="-p 100%,100%"
export FZF_CTRL_T_OPTS="--preview 'batcat --color=always -n --line-range :500 {}' --bind 'enter:execute(nano)'"
export FZF_ALT_C_OPTS="--preview 'exa --tree --color=always {} | head -200'"

# Global variables
REPO_URL="https://github.com/its-ashu-otf/myZSH.git"
REPO_DIR="$HOME/.zsh/myZSH"
PACKAGER=""
SUDO_CMD=""


#######################################################
#                       FUNCTIONS                     #  
#######################################################


# Update or clone the zsh configuration repository
update-MyZSH() {
    REPO_DIR="$HOME/.zsh/myZSH"
    if [ -d "$REPO_DIR" ]; then
        echo "Repository already exists. Fetching changes from remote..."
        cd "$REPO_DIR"
        git fetch origin
        echo "Resetting local changes and syncing with remote..."
        git reset --hard origin/main
        git pull
        linkConfig
        echo "Repository updated successfully."
    else
        echo "Repository does not exist. Cloning..."
        mkdir -p "$HOME/.zsh"
        cd "$HOME/.zsh"
        git clone https://github.com/its-ashu-otf/myZSH.git
        cd myZSH
    fi

    local USER_HOME
    USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)

    print_colored "$YELLOW" "Linking configuration files..."
    if [ -f "$USER_HOME/.zshrc" ]; then
        mv "$USER_HOME/.zshrc" "$USER_HOME/.zshrc.bak"
        print_colored "$YELLOW" "Existing .zshrc backed up to .zshrc.bak"
    fi
    ln -svf "$HOME/.zsh/myZSH/.zshrc" "$USER_HOME/.zshrc"
    $SUDO_CMD chsh -s "$(command -v zsh)" "$USER"
    print_colored "$GREEN" "Configuration files linked successfully."

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

bindkey '^R' fzf-history-widget
fzf-history-widget() {
    local selected
    selected=$(fc -l 1 | fzf)
    if [[ -n $selected ]]; then
        BUFFER=$selected
        CURSOR=${#BUFFER}
    fi
    zle accept-line
}
zle -N fzf-history-widget

bindkey '^E' fzf-file-widget
fzf-file-widget() {
    local file
    file=$(find . -type f | fzf)
    if [[ -n $file ]]; then
        BUFFER="vim $file"
        CURSOR=${#BUFFER}
    fi
    zle accept-line
}
zle -N fzf-file-widget

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

# ctrl + r for fuzzy history search 
export FZF_DEFAULT_COMMAND='fc -l 1'
bindkey '^R' fzf-history-widget

fzf-history-widget() {
  local selected
  selected=$(fc -l 1 | fzf)
  if [[ -n $selected ]]; then
    BUFFER=$selected
    CURSOR=${#BUFFER}
  fi
  zle accept-line
}
zle -N fzf-history-widget

# ctrl + e for fzf search 
fzf_i () {
    eval '"$( find . -type f | fzf)"'
    local precmd
    for precmd in $precmd_functions; do
      $precmd
    done
    zle reset-prompt
}
zle -N fzf_i
bindkey '^e' fzf_i

#######################################################
#                 PLUGIN INTEGRATIONS                 #
#######################################################

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
[[ -s "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
[[ -s "$HOME/.fzf.bash" ]] && source "$HOME/.fzf.bash"

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


#######################################################
#                       CLEANUP                       #
#######################################################
unset iatest