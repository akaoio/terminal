# 🚀 AKAOIO TERMINAL - CYBERPUNK EDITION

<div align="center">

![Terminal Banner](https://img.shields.io/badge/TERMINAL-CYBERPUNK-ff00ff?style=for-the-badge&logo=gnometerminal&logoColor=white)
![Version](https://img.shields.io/badge/VERSION-2.0-00ffff?style=for-the-badge)
![Platform](https://img.shields.io/badge/PLATFORM-LINUX%20%7C%20MACOS-00ff00?style=for-the-badge)
![License](https://img.shields.io/badge/LICENSE-MIT-ffff00?style=for-the-badge)

<h3>Transform your boring terminal into a CYBERPUNK MASTERPIECE! ⚡</h3>

[Installation](#-one-line-installation) • [Features](#-features) • [Screenshots](#-screenshots) • [Keyboard Shortcuts](#️-keyboard-shortcuts) • [Update](#-update) • [Uninstall](#-uninstall)

</div>

---

## 🎯 ONE-LINE INSTALLATION

Copy, paste, enter. That's it! No questions asked!

```bash
curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/install.sh | bash
```

Or if you prefer wget:

```bash
wget -qO- https://raw.githubusercontent.com/akaoio/terminal/main/install.sh | bash
```

---

## ✨ FEATURES 🆕

### 🎨 **Visual Excellence**
- **Powerlevel10k Theme** - Cyberpunk edition with neon colors
- **Nerd Fonts** - Beautiful icons for files, folders, git, and more
- **Syntax Highlighting** - Code lights up as you type
- **Auto-suggestions** - Ghost text predictions from your command history
- **FZF Integration** - Fuzzy finder with preview windows

### ⚡ **Productivity Boosters**
- **DEX Smart Workspace** 🆕 - Adaptive tmux layouts for any screen size
- **LazyVim IDE** 🆕 - Modern Neovim with plugins pre-configured
- **Smart Tab Completion** - Visual menu with descriptions
- **Directory Jumper** - Type `z folder` to jump anywhere
- **History Search** - Ctrl+R with fuzzy matching
- **Git Integration** - Branch, status, and changes in prompt
- **Auto-correction** - Fixes typos automatically

### 🛠️ **Enhanced CLI Tools**
- `tmux` 🆕 - Terminal multiplexer with compact status tabs and mobile-friendly keybindings
- `nvim` 🆕 - Neovim with LazyVim configuration
- `dex` 🆕 - Smart workspace manager (auto-adapts to screen)
- `exa` - Better ls with icons and tree view
- `bat` - Better cat with syntax highlighting
- `ripgrep` - Blazing fast grep alternative
- `fd` - User-friendly find replacement
- `fzf` - Fuzzy finder for everything
- `htop` - Interactive process viewer
- `neofetch` - System info with style

### 🚀 **60+ Aliases & Functions**
- `ll` - Detailed list with icons
- `extract` - Extract any archive format
- `mkcd` - Create and enter directory
- `ports` - Show listening ports
- `weather` - Check weather instantly
- `gs`, `ga`, `gc`, `gp` - Git shortcuts
- `dps`, `dimg`, `dexec` - Docker shortcuts
- And many more...

---

## 📸 SCREENSHOTS

<div align="center">

### Terminal Overview
```
╭─ ⚡ user@machine  ~/projects/awesome-app  main ✓
│
╰─❯❯❯ 
```

### Features in Action
- **Auto-suggestions**: Type command and see predictions in gray
- **Syntax Highlighting**: Valid commands in green, invalid in red
- **Git Status**: Branch name + modified/untracked indicators
- **Icons Everywhere**: Files, folders, git, languages all have icons
- **FZF Tab**: Press Tab for interactive completion menu

</div>

---

## ⌨️ KEYBOARD SHORTCUTS

| Shortcut | Action |
|----------|--------|
| `Tab` | Smart completion with FZF menu |
| `Ctrl + Space` | Accept auto-suggestion |
| `Ctrl + R` | Search command history |
| `Ctrl + T` | Find files interactively |
| `Alt + C` | Navigate directories |
| `Ctrl + L` | Clear screen |
| `Ctrl + A` | Go to line beginning |
| `Ctrl + E` | Go to line end |
| `Ctrl + K` | Delete to end of line |
| `Ctrl + U` | Delete to beginning |
| `Ctrl + W` | Delete word backward |
| `↑` / `↓` | Navigate history |

### 📱 Mobile/Termux Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl + A` | tmux prefix key |
| `Ctrl + A, h` | Split horizontally (mobile-friendly) |
| `Ctrl + A, v` | Split vertically (mobile-friendly) |
| `Ctrl + A, j` | Navigate to pane below |
| `Ctrl + A, k` | Navigate to pane above |
| `Ctrl + A, b` | Navigate to left pane |
| `Ctrl + A, l` | Navigate to right pane |
| `Ctrl + A, +` | Resize pane up |
| `Ctrl + A, =` | Resize pane down |

---

## 🔧 CUSTOMIZATION

### Change Theme Style
```bash
p10k configure
```
Interactive wizard to customize:
- Prompt style (arrows, rounded, powerline)
- Colors and icons
- What information to display
- Multi-line or single-line prompt

### Edit Configuration
```bash
nano ~/.zshrc     # Main config
nano ~/.p10k.zsh  # Theme config
```

### Add Custom Aliases
Add to the end of `~/.zshrc`:
```bash
alias mycommand='your command here'
```

---

## 📦 WHAT GETS INSTALLED

### Core Components
- ✅ Zsh shell
- ✅ Oh My Zsh framework
- ✅ Powerlevel10k theme
- ✅ Nerd Fonts (MesloLGS NF)
- ✅ tmux (terminal multiplexer)
- ✅ Neovim with LazyVim IDE
- ✅ Claude Code AI assistant

### Plugins
- ✅ zsh-autosuggestions
- ✅ zsh-syntax-highlighting
- ✅ zsh-completions
- ✅ fzf-tab
- ✅ LazyVim plugins (auto-installed on first launch)

### CLI Tools
- ✅ fzf (fuzzy finder)
- ✅ bat (better cat)
- ✅ exa (better ls)
- ✅ ripgrep (better grep)
- ✅ fd (better find)
- ✅ htop (process manager)
- ✅ neofetch (system info)
- ✅ dex (smart workspace manager)

### Configurations
- ✅ 70+ useful aliases
- ✅ Smart functions
- ✅ tmux with compact touch-friendly status bar
- ✅ LazyVim modern IDE setup
- ✅ Adaptive screen layouts
- ✅ Session persistence
- ✅ Claude Code integration

---

## 🔄 UPDATE

Keep your terminal bleeding edge:

```bash
curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/update.sh | bash
```

Or if you cloned the repo:
```bash
cd ~/akaoio/terminal && ./update.sh
```

---

## 🗑️ UNINSTALL

Restore your terminal to original state:

```bash
curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/uninstall.sh | bash
```

This will:
- ✅ Restore your original configs from backup
- ✅ Remove Oh My Zsh and plugins
- ✅ Switch back to bash
- ✅ Clean up all traces
- ❌ Keep system packages (zsh, git, etc.)

---

## 🐛 TROUBLESHOOTING

### Icons/Arrows Not Showing?
**Solution**: Set terminal font to "MesloLGS NF" in terminal preferences

### Terminal Slow to Start?
**Solution**: Run `p10k configure` and choose "Instant Prompt"

### Permission Denied?
**Solution**: Run with sudo: `curl ... | sudo bash`

### Wrong Colors?
**Solution**: Enable "True Color" in terminal settings

---

## 🚀 QUICK TIPS

1. **First Time?** Run `p10k configure` to customize appearance
2. **View All Aliases:** Type `alias` to see all shortcuts
3. **Update Regularly:** Run update script monthly for latest features
4. **Learn FZF:** Press Tab everywhere - it's magical!
5. **Use z-jumper:** After visiting folders, type `z foldername` to jump

---

## 💻 SYSTEM REQUIREMENTS

- **OS**: Linux (Ubuntu/Debian/Arch/etc.) or macOS
- **Shell**: Bash or Zsh (will install Zsh)
- **Terminal**: Any modern terminal emulator
- **Internet**: Required for installation
- **Permissions**: Sudo access for package installation

---

## 🤝 CONTRIBUTING

Found a bug? Want a feature? PRs welcome!

```bash
git clone https://github.com/akaoio/terminal.git
cd terminal
# Make your changes
./install.sh  # Test locally
```

---

## 📄 LICENSE

MIT License - Use it, modify it, share it!

---

## 🌟 STAR THIS REPO!

If you love your new terminal, give us a star! ⭐

---

<div align="center">

**Built with 💜 by AKAOIO**

[Report Bug](https://github.com/akaoio/terminal/issues) • [Request Feature](https://github.com/akaoio/terminal/issues)

</div>

---

## 🎮 BONUS: TERMINAL GAMES

After installation, try these commands for fun:
- `matrix` - Matrix rain effect
- `weather` - Check weather
- `moon` - Moon phases
- `crypto` - Cryptocurrency rates
- `neofetch` - Show system info with style

---

<div align="center">
<h3>🚀 Welcome to the future of terminal experience! 🚀</h3>
</div>
