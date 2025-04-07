## The Ultimate ZSH Prompt

## Overview

This repository provides a comprehensive `.zshrc` configuration along with supporting scripts and configuration files to enhance your terminal experience in Unix-like operating systems. It configures the shell session by setting up aliases, defining functions, customizing the prompt, and more, significantly improving the terminal's usability and power.

## Table of Contents

- [Installation](#installation)
- [Updating](#updating)
- [Configuration Files](#configuration-files)
  - [.zshrc](#zshrc)
  - [starship.toml](#starshiptoml)
  - [config.jsonc](#configjsonc)
- [Key Features](#key-features)
- [Advanced Functions](#advanced-functions)
- [System-Specific Configurations](#system-specific-configurations)
- [Conclusion](#conclusion)

## Installation 

```zsh
curl -fsSL https://raw.githubusercontent.com/its-ashu-otf/myZSH/main/Install-myZSH.sh | bash
```

The `Install-myZSH.sh` script automates the installation process by:

- Creating necessary directories (`myZSH`)
- Cloning the repository
- Installing dependencies (zsh-completion, starship, fzf, zoxide)
- Installing the FiraCode Nerd Font required for the prompt
- Linking configuration files (`.zshrc` and `starship.toml`) to your home directory
- Setting up additional utilities like `fastfetch`

Ensure you have the required permissions and a supported package manager before running the script.

## Updating

To update the configuration, simply run:

```zsh
update-MyZSH
```

This function ensures that local changes are ignored, and the latest updates from the repository are fetched and applied. It performs the following steps:

- Resets local changes
- Fetches the latest changes from the remote repository
- Updates configuration files and links them to your home directory

## Configuration Files

### `.zshrc`

The `.zshrc` file defines aliases, functions, and environment variables to enhance your shell experience. Key features include:

- **Aliases**: Shortcuts for common commands (e.g., `alias cp='cp -i'`)
- **Functions**: Custom functions for tasks like extracting archives, managing services, and configuring firewalls
- **System Initialization Detection**: Automatically detects and configures commands for `systemd`, `SysVinit`, `OpenRC`, or `runit`
- **SSH Manager**: Simplifies SSH management with options to start, stop, restart, and configure SSH
- **Firewall Manager**: Provides an easy-to-use interface for managing firewalls (`ufw`, `firewalld`, or `iptables`)

### `starship.toml`

The `starship.toml` file configures the [Starship](https://starship.rs/) prompt, providing a highly customizable and informative shell prompt. It includes:

- **Module Configurations**: Customizes modules like `python`, `git`, `docker_context`, and various programming languages
- **Hostname Integration**: Displays the system hostname in the prompt for better context
- **Format Customization**: Structures the layout and truncation of paths for a cleaner look

### `config.jsonc`

The `config.jsonc` file configures [fastfetch](https://github.com/AlexRogalskiy/fastfetch), a system information tool. It includes:

- **Logo and Display Settings**: Customizes the appearance of system logos and separators
- **Modules**: Defines which system information modules to display, such as CPU, GPU, OS, kernel, and uptime
- **Custom Sections**: Adds custom formatted sections for hardware and software information

## Key Features

1. **Aliases and Functions**
   - Shortcuts for common commands
   - Custom functions for complex operations (e.g., extracting archives, copying with progress)

2. **System Management**
   - Detects and manages services based on the system's init system (`systemd`, `SysVinit`, `OpenRC`, or `runit`)
   - Provides a simple interface for starting, stopping, restarting, and checking the status of applications

3. **Firewall Management**
   - Supports `ufw`, `firewalld`, and `iptables`
   - Allows checking status, resetting, reloading, and managing ports

4. **SSH Manager**
   - Simplifies SSH management with options to start, stop, restart, and configure SSH
   - Includes a quick-connect feature for remote SSH sessions

5. **Prompt Customization and History Management**
   - Configures PROMPT_COMMAND for automatic history saving
   - Manages history file size and handles duplicates

6. **Enhancements and Utilities**
   - Improves command output readability with colors
   - Introduces safer file operations (e.g., using `trash` instead of `rm`)
   - Integrates Zoxide for easy directory navigation

7. **AI Integration**
   - Advanced AI Integration in Shell

8. **Configuration Editors**
   - Functions to edit important configuration files directly, e.g., `apacheconfig()` for Apache server configurations

9. **Color and Formatting**
   - Enhancements for command output readability using colors and formatting for tools like `ls`, `grep`, and `man`.

10. **Navigation Shortcuts**
    - Aliases to simplify directory navigation, e.g., `alias ..='cd ..'` to go up one directory.

11. **Safety Features**
    - Aliases for safer file operations, like using trash instead of `rm` for deleting files, to prevent accidental data loss.

12. **Extensive Zoxide Support**
    - Easily navigate with `z`, `zi`, or pressing Ctrl+f to launch `zi` to see frequently used navigation directories.

13. **Terminal Icons**
    - Added Terminal Icons for better visual representation.

14. **New Gen `ls`**
    - Replaces the default `ls` with a modern, colorful alternative.

15. **Multi-Distro Support**
    - Tested on Ubuntu, Kali, and Arch Linux.

## Advanced Functions

- System information display
- Networking utilities (e.g., IP address checks)
- Resource monitoring tools
- Service management for applications like Docker, MySQL, and MongoDB

## System-Specific Configurations

- Editor settings (NeoVim as default)
- Conditional aliases based on system type
- Package manager-specific commands

## Conclusion

This `.zshrc` configuration offers a powerful and customizable terminal environment suitable for various Unix-like systems. It enhances productivity through smart aliases, functions, and integrated tools while maintaining flexibility for system-specific needs. Whether you're a developer, system administrator, or power user, this setup aims to make your terminal experience more efficient and enjoyable.

For any issues, suggestions, or contributions, please open an issue or pull request in this repository. We welcome community involvement to make this configuration even better!
