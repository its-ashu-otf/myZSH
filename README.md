## The Ultimate ZSH Prompt


## Overview

This repository provides a comprehensive `.zshrc` configuration along with supporting scripts and configuration files to enhance your terminal experience in Unix-like operating systems. It configures the shell session by setting up aliases, defining functions, customizing the prompt, and more, significantly improving the terminal's usability and power.

## Table of Contents

- [Installation](#installation)
- [Uninstallation](#uninstallation)
- [Configuration Files](#configuration-files)
  - [.bashrc](#bashrc)
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
![render1734625237861](https://github.com/user-attachments/assets/a661b896-7260-44a1-8c37-72f63c57409e)

## For Updating 

Simply run this in terminal 

```zsh
zsh_update
```
The `Install-myZSH.sh` script automates the installation process by:

- Creating necessary directories (`linuxtoolbox/myZSH`)
- Cloning the repository
- Installing dependencies (bash-completion, neovim, starship, fzf, zoxide)
- Installing the MesloLGS Nerd Font required for the prompt
- Linking configuration files (`.zshrc` and `starship.toml`) to your home directory
- Setting up additional utilities like `fastfetch`

Ensure you have the required permissions and a supported package manager before running the script.

## Configuration Files

### `.zshrc`

The `.zshrc` file defines aliases, functions, and environment variables to enhance your shell experience. Key features include:

- **Aliases**: Shortcuts for common commands (e.g., `alias cp='cp -i'`)
- **Functions**: Custom functions for tasks like extracting archives and copying files with progress

### `starship.toml`

The `starship.toml` file configures the [Starship](https://starship.rs/) prompt, providing a highly customizable and informative shell prompt. It includes:

- **Theme Settings**: Defines colors and symbols for different prompt segments
- **Module Configurations**: Customizes modules like `python`, `git`, `docker_context`, and various programming languages
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

2. **Prompt Customization and History Management**
   - Configures PROMPT_COMMAND for automatic history saving
   - Manages history file size and handles duplicates

3. **Enhancements and Utilities**
   - Improves command output readability with colors
   - Introduces safer file operations (e.g., using `trash` instead of `rm`)
   - Integrates Zoxide for easy directory navigation

4. **Installation and Configuration Helpers**
   - Auto-installs necessary utilities based on system type
   - Provides functions to edit important configuration files

5. **AI Integration**
   - Advanced AI Integration in Shell

7. **Configuration Editors**
   - Functions to edit important configuration files directly, e.g., `apacheconfig()` for Apache server configurations

8. **Color and Formatting**
   - Enhancements for command output readability using colors and formatting for tools like `ls`, `grep`, and `man`.

9. **Navigation Shortcuts**
    - Aliases to simplify directory navigation, e.g., `alias ..='cd ..'` to go up one directory.

10. **Safety Features**
    - Aliases for safer file operations, like using trash instead of `rm` for deleting files, to prevent accidental data loss.

11. **Extensive Zoxide support**
    - Easily navigate with `z`, `zi`, or pressing Ctrl+f to launch zi to see frequently used navigation directories.

12. **Terminal C/P**
    - PB Copy and paste using xsel for terminal copy and pasting.

13. **Terminal Icons**
    - Added Terminal Icons

14. **New Gen `ls`**
    - New Generation of ls added

15. **Colourful O/P**
    - Colorized Nmap Output

16. **Multi-Distro Support**
    - Tested on Ubuntu, Kali and Arch.
 
## Advanced Functions

- System information display
- Networking utilities (e.g., IP address checks)
- Resource monitoring tools

## System-Specific Configurations

- Editor settings (NeoVim as default)
- Conditional aliases based on system type
- Package manager-specific commands

## Conclusion

This `.zshrc` configuration offers a powerful and customizable terminal environment suitable for various Unix-like systems. It enhances productivity through smart aliases, functions, and integrated tools while maintaining flexibility for system-specific needs. Whether you're a developer, system administrator, or power user, this setup aims to make your terminal experience more efficient and enjoyable.

For any issues, suggestions, or contributions, please open an issue or pull request in this repository. We welcome community involvement to make this configuration even better!
