# myBASH
My Custom Bash profile - Highly customized Starship Theme
![gnu_bash_official_logo_icon_169099](https://github.com/its-ashu-otf/myBASH/assets/85825366/d9ff2eaf-7295-4048-a53d-bedfd2a8d3a2)

The .bashrc file is a script that runs every time a new terminal session is started in Unix-like operating systems. It is used to configure the shell session, set up aliases, define functions, and more, making the terminal easier to use and more powerful. Below is a summary of the key sections and functionalities defined in the provided .bashrc file.

# Installation 

```bash
mkdir -p ~/build
cd ~/build
git clone https://github.com/its-ashu-otf/myBASH
cd mybash
./setup.sh
```

# Features

Enhancements and Utilities
- Color and Formatting: Enhancements for command output readability using colors and formatting for tools like `ls`, `grep`, and `man`.
- Navigation Shortcuts: Aliases to simplify directory navigation, e.g., `alias ..='cd ..'` to go up one directory.
- Safety Features: Aliases for safer file operations, like using trash instead of `rm` for deleting files, to prevent accidental data loss.
- Extensive Zoxide support: Easily navigate with `z`, `zi`, or pressing Ctrl+f to launch zi to see frequently used navigation directories.

# Conclusion
This .bashrc file is a comprehensive setup that not only enhances the shell experience with useful aliases and functions but also provides system-specific configurations and safety features to cater to different user needs and system types. It is designed to make the terminal more user-friendly, efficient, and powerful for an average user.
