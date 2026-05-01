#!/usr/bin/env bash
#
# 🚀 Style Linux Terminal — Setup Script
# https://github.com/giorgitchanturidze/style-linux-terminal
#
# Installs: Zsh, Oh My Zsh, Starship, and Zsh plugins
# Supports: Ubuntu/Debian, Fedora, Arch
#
# Everything is self-contained — no external config files needed.
#

set -e

VERSION="2.0.0"

# ─── Colors ──────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Helpers ─────────────────────────────────────────────────────────────────

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[  OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERR ]${NC} $1"; }

ask() {
    echo ""
    echo -e "${CYAN}${BOLD}$1${NC}"
    read -rp "$(echo -e "${YELLOW}Proceed? [Y/n]:${NC} ")" answer
    [[ -z "$answer" || "$answer" =~ ^[Yy] ]]
}

command_exists() {
    command -v "$1" &>/dev/null
}

# ─── Detect Distro ──────────────────────────────────────────────────────────

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|pop|elementary|zorin)
                DISTRO="debian"
                PKG_INSTALL="sudo apt install -y"
                PKG_UPDATE="sudo apt update"
                ;;
            fedora|rhel|centos|rocky|alma)
                DISTRO="fedora"
                PKG_INSTALL="sudo dnf install -y"
                PKG_UPDATE="sudo dnf check-update || true"
                ;;
            arch|manjaro|endeavouros|garuda)
                DISTRO="arch"
                PKG_INSTALL="sudo pacman -S --noconfirm"
                PKG_UPDATE="sudo pacman -Sy"
                ;;
            *)
                error "Unsupported distro: $ID"
                error "Please follow the manual installation guide in README.md"
                exit 1
                ;;
        esac
        success "Detected distro: $ID ($DISTRO family)"
    else
        error "Cannot detect Linux distribution."
        exit 1
    fi
}

# ─── Backup Existing Configs ────────────────────────────────────────────────

backup_configs() {
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)

    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.backup."$timestamp"
        info "Backed up ~/.zshrc → ~/.zshrc.backup.$timestamp"
    fi
    if [ -f ~/.config/starship.toml ]; then
        cp ~/.config/starship.toml ~/.config/starship.toml.backup."$timestamp"
        info "Backed up starship.toml → starship.toml.backup.$timestamp"
    fi
}

# ─── Install Zsh ────────────────────────────────────────────────────────────

install_zsh() {
    if command_exists zsh; then
        success "Zsh is already installed ($(zsh --version))"
        return 0
    fi

    if ask "📦 Install Zsh?"; then
        $PKG_UPDATE
        $PKG_INSTALL zsh
        success "Zsh installed"
    else
        warn "Skipping Zsh — some features may not work without it"
    fi
}

# ─── Install Oh My Zsh ──────────────────────────────────────────────────────

install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        success "Oh My Zsh is already installed"
        return 0
    fi

    if ask "📦 Install Oh My Zsh?"; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh My Zsh installed"
    else
        warn "Skipping Oh My Zsh"
    fi
}

# ─── Install Starship ───────────────────────────────────────────────────────

install_starship() {
    if command_exists starship; then
        success "Starship is already installed ($(starship --version))"
    else
        if ask "🌟 Install Starship prompt?"; then
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
            success "Starship installed"
        else
            warn "Skipping Starship"
            return 0
        fi
    fi

    # Apply Gruvbox Rainbow preset
    mkdir -p ~/.config
    starship preset gruvbox-rainbow -o ~/.config/starship.toml
    success "Applied Starship Gruvbox Rainbow preset"
}

# ─── Install Zsh Plugins ────────────────────────────────────────────────────

install_plugins() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        warn "Oh My Zsh not found — skipping plugins"
        return 0
    fi

    if ask "🔌 Install Zsh plugins (autosuggestions + syntax highlighting)?"; then
        local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

        if [ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions \
                "$custom_dir/plugins/zsh-autosuggestions"
            success "Installed zsh-autosuggestions"
        else
            success "zsh-autosuggestions already installed"
        fi

        if [ ! -d "$custom_dir/plugins/zsh-syntax-highlighting" ]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting \
                "$custom_dir/plugins/zsh-syntax-highlighting"
            success "Installed zsh-syntax-highlighting"
        else
            success "zsh-syntax-highlighting already installed"
        fi
    else
        warn "Skipping plugins"
    fi
}

# ─── Configure .zshrc ───────────────────────────────────────────────────────

configure_zshrc() {
    local zshrc="$HOME/.zshrc"

    if [ ! -f "$zshrc" ]; then
        warn ".zshrc not found — skipping configuration"
        return 0
    fi

    # Set plugins
    if grep -q 'plugins=(git)' "$zshrc"; then
        sed -i 's/plugins=(git)/plugins=(\n  git\n  zsh-autosuggestions\n  zsh-syntax-highlighting\n)/' "$zshrc"
        success "Updated plugins in .zshrc"
    elif ! grep -q 'zsh-autosuggestions' "$zshrc"; then
        sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' "$zshrc"
        success "Added plugins to .zshrc"
    fi

    # Disable Oh My Zsh theme (Starship handles prompt)
    if grep -q '^ZSH_THEME=' "$zshrc"; then
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME=""/' "$zshrc"
        success "Disabled Oh My Zsh theme (Starship handles prompt)"
    fi

    # Add Starship init (must be last)
    if ! grep -q 'starship init' "$zshrc"; then
        echo '' >> "$zshrc"
        echo '# Initialize Starship prompt (keep this at the end)' >> "$zshrc"
        echo 'eval "$(starship init zsh)"' >> "$zshrc"
        success "Added Starship to .zshrc"
    fi
}

# ─── Set Default Shell ──────────────────────────────────────────────────────

set_default_shell() {
    if command_exists zsh; then
        local current_shell
        current_shell=$(basename "$SHELL")
        if [ "$current_shell" != "zsh" ]; then
            if ask "🐚 Set Zsh as your default shell?"; then
                chsh -s "$(which zsh)"
                success "Default shell changed to Zsh (takes effect on next login)"
            fi
        else
            success "Zsh is already your default shell"
        fi
    fi
}

# ─── Main ────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo -e "${BOLD}${CYAN}"
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║     🚀 Style Linux Terminal Setup     ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "  ${BOLD}Version ${VERSION}${NC}"
    echo ""
    echo -e "  This script will set up a modern terminal with"
    echo -e "  Starship prompt and Zsh plugins."
    echo -e "  ${YELLOW}You'll be asked before each step.${NC}"
    echo ""

    # Preflight
    if ! command_exists git; then
        error "Git is required. Please install git first."
        exit 1
    fi

    if ! command_exists curl; then
        error "curl is required. Please install curl first."
        exit 1
    fi

    detect_distro
    backup_configs
    install_zsh
    install_ohmyzsh
    install_starship
    install_plugins
    configure_zshrc
    set_default_shell

    echo ""
    echo -e "${GREEN}${BOLD}"
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║          ✅ Setup Complete!            ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "  ${BOLD}Next steps:${NC}"
    echo -e "  1. Restart your terminal (or run: ${CYAN}exec zsh${NC})"
    echo -e "  2. Install a Nerd Font: ${CYAN}https://www.nerdfonts.com${NC}"
    echo -e "  3. Set the Nerd Font in your terminal's preferences"
    echo ""
    echo -e "  ${YELLOW}Your old configs were backed up with a timestamp.${NC}"
    echo ""
}

main "$@"
