# myBASH

**My Custom Bash profile - Highly customized Starship Theme**

![gnu_bash_official_logo_icon_169099](https://github.com/its-ashu-otf/myBASH/assets/85825366/d9ff2eaf-7295-4048-a53d-bedfd2a8d3a2)

The .bashrc file is a script that runs every time a new terminal session is started in Unix-like operating systems. It is used to configure the shell session, set up aliases, define functions, and more, making the terminal easier to use and more powerful. Below is a summary of the key sections and functionalities defined in the provided .bashrc file.

# Installation and Configuration Helpers

```bash
mkdir -p ~/build
cd ~/build
git clone https://github.com/its-ashu-otf/myBASH.git
cd myBASH
./setup.sh
```

- **Auto-Install**: A function `install_bashrc_support()` to automatically install necessary utilities based on the system type.
- **Configuration Editors**: Functions to edit important configuration files directly, e.g., `apacheconfig()` for Apache server configurations.

# Features

#### Enhancements and Utilities

- **Color and Formatting**: Enhancements for command output readability using colors and formatting for tools like `ls`, `grep`, and `man`.
- **Navigation Shortcuts**: Aliases to simplify directory navigation, e.g., `alias ..='cd ..'` to go up one directory.
- **Safety Features**: Aliases for safer file operations, like using trash instead of `rm` for deleting files, to prevent accidental data loss.
- **Extensive Zoxide support**: Easily navigate with `z`, `zi`, or pressing Ctrl+f to launch zi to see frequently used navigation directories.
- **Faster APT**: Used NALA instead of APT for Great Experience.
- **Terminal C/P**: PB Copy and paste using xsel for terminal copy and pasting.
- **TMUX**: Integrated my personal tmux config.

#### Aliases and Functions

- **Aliases**: Shortcuts for common commands are set up to enhance productivity. For example, `alias cp='cp -i'` makes the `cp` command interactive, asking for confirmation before overwriting files.
- **Functions**: Custom functions for complex operations like `extract()` for extracting various archive types, and `cpp()` for copying files with a progress bar.

#### Prompt Customization and History Management

- **Prompt Command**: The `PROMPT_COMMAND` variable is set to automatically save the command history after each command.
- **History Control**: Settings to manage the size of the history file and how duplicates are handled.

#### System-Specific Aliases and Settings

- **Editor Settings**: Sets `nano` as the default editor.
- **Conditional Aliases**: Depending on the system type (like Fedora), it sets specific aliases, e.g., replacing `cat` with `bat`.

#### Advanced Functions

- **System Information**: Functions to display system information like distribution() to identify the Linux distribution.
- **Networking Utilities**: Tools to check internal and external IP addresses.
- **Resource Monitoring**: Commands to monitor system resources like disk usage and open ports.
  
# Conclusion

This .bashrc file is a comprehensive setup that not only enhances the shell experience with useful aliases and functions but also provides system-specific configurations and safety features to cater to different user needs and system types. It is designed to make the terminal more user-friendly, efficient, and powerful for an average user.
