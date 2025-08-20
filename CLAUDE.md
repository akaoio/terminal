# CLAUDE.md - AI Assistant Documentation

## Repository Overview

This repository (`akaoio/terminal`) provides a fully automated terminal enhancement solution that transforms any standard terminal into a cyberpunk-themed, feature-rich development environment.

## Purpose

The repository aims to provide:
1. **One-command installation** - No user interaction required
2. **Complete terminal transformation** - Visual and functional upgrades  
3. **Enhanced productivity** - Smart completions, shortcuts, and tools
4. **Easy maintenance** - Update and uninstall scripts included

## Key Components

### Core Files

1. **install.sh**
   - Main installation script
   - Fully automated (no prompts)
   - Installs: Zsh, Oh-My-Zsh, Powerlevel10k, plugins, fonts, CLI tools
   - Creates backups before modifications
   - Platform detection (Linux/macOS)
   - Beautiful progress animations

2. **update.sh**
   - Updates all components to latest versions
   - Pulls repository updates
   - Updates Oh-My-Zsh, theme, plugins
   - Refreshes system packages

3. **uninstall.sh**
   - Complete removal script
   - Restores original configurations from backup
   - Removes all installed components
   - Returns shell to bash

4. **README.md**
   - User-facing documentation
   - One-liner installation command
   - Feature list and screenshots
   - Keyboard shortcuts reference
   - Troubleshooting guide

5. **CLAUDE.md** (this file)
   - AI assistant reference
   - Technical implementation details
   - Code structure explanation

### Directory Structure

```
akaoio/terminal/
├── install.sh          # Main installer
├── update.sh           # Update script
├── uninstall.sh        # Uninstaller
├── README.md           # User documentation
├── CLAUDE.md           # AI documentation
├── configs/
│   └── p10k.zsh        # Unified Powerlevel10k config (2-line prompt)
├── themes/
│   └── cyberpunk.zsh-theme   # Custom theme
└── assets/
    └── screenshots/           # Demo images
```

## Technical Implementation

### Installation Flow

1. **Banner Display** - Cyberpunk ASCII art
2. **Backup Creation** - Save existing configs to timestamped folder
3. **Package Installation** - Core tools (zsh, git, curl, fonts)
4. **Oh-My-Zsh Setup** - Framework installation
5. **Powerlevel10k Theme** - Clone and configure
6. **Plugin Installation** - Auto-suggestions, syntax highlighting, etc.
7. **Font Installation** - MesloLGS Nerd Fonts
8. **Configuration** - Create optimized .zshrc and .p10k.zsh
9. **Shell Switch** - Set Zsh as default
10. **Completion** - Success message and instructions

### Key Features Implemented

#### Visual Enhancements
- Neon color scheme (pink #198, blue #51, green #46, purple #141)
- Powerline symbols and arrows
- File/folder icons via Nerd Fonts
- Git status indicators in prompt
- Syntax highlighting for commands

#### Productivity Features
- **Auto-suggestions** from command history
- **FZF integration** for fuzzy finding
- **Smart tab completion** with preview
- **Directory jumper** (z command)
- **50+ aliases** for common tasks
- **Custom functions** (mkcd, extract, backup, etc.)

#### Enhanced CLI Tools
- `exa` - ls replacement with icons
- `bat` - cat with syntax highlighting
- `ripgrep` - fast grep alternative
- `fd` - user-friendly find
- `fzf` - fuzzy finder
- `htop` - process viewer
- `neofetch` - system info display

### Configuration Details

#### .zshrc Structure
- Instant prompt initialization
- Oh-My-Zsh configuration
- Plugin loading
- Environment variables
- Aliases (system, git, docker)
- Custom functions
- FZF settings
- Completion configurations
- Key bindings

#### Powerlevel10k Settings (configs/p10k.zsh)
- 2-line prompt design for better readability
- First line: user@hostname, directory, git status
- Second line: prompt symbol (❯)
- Prompt elements (context, dir, vcs, status)
- Color definitions (cyberpunk theme)
- Symbol customization
- Performance optimizations

## Maintenance Notes

### Updating the Repository

When updating features:
1. Test changes locally first
2. Ensure backward compatibility
3. Update version numbers in README
4. Test on both Linux and macOS
5. Verify uninstall still works

### Adding New Features

To add new features:
1. Update `install.sh` with new component
2. Add to `uninstall.sh` for cleanup
3. Document in README.md
4. Update this CLAUDE.md file

### Common Issues

1. **Permission errors** - Scripts need execution permission
2. **Font rendering** - Terminal needs font change to MesloLGS NF
3. **Slow startup** - Too many plugins, use instant prompt
4. **Color issues** - Terminal needs true color support

## Design Philosophy

1. **Zero Configuration** - Works out of the box
2. **No User Interaction** - Fully automated installation
3. **Beautiful Defaults** - Cyberpunk aesthetic
4. **Performance First** - Fast startup and execution
5. **Easy Rollback** - Complete uninstall option

## Testing Checklist

- [ ] Fresh Ubuntu installation
- [ ] Fresh macOS installation
- [ ] Existing Zsh setup
- [ ] Existing Oh-My-Zsh setup
- [ ] Update from previous version
- [ ] Uninstall and restoration
- [ ] All aliases work
- [ ] All functions work
- [ ] FZF integration works
- [ ] Git integration works

## Future Enhancements

Potential improvements:
- WSL support for Windows
- More theme variations
- Plugin marketplace integration
- Configuration wizard
- Cloud sync for settings
- Performance profiling tools

## Support Information

- **Repository**: https://github.com/akaoio/terminal
- **Issues**: https://github.com/akaoio/terminal/issues
- **License**: MIT

---

## For AI Assistants

When helping users with this repository:

1. **Installation Issues**: Check platform compatibility, permissions, internet connection
2. **Customization**: Direct to `p10k configure` for visual changes, edit `.zshrc` for functionality
3. **Performance**: Reduce plugins, enable instant prompt, check for conflicts
4. **Uninstall**: Always creates backups, safe to run anytime
5. **Updates**: Encourage regular updates for latest features

Key commands for users:
- Install: `curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/install.sh | bash`
- Update: `curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/update.sh | bash`
- Uninstall: `curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/uninstall.sh | bash`
- Customize: `p10k configure`
- Reload: `source ~/.zshrc` or `exec zsh`

Remember: This is designed to be foolproof - no user interaction needed during installation!