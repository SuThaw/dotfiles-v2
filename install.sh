#!/usr/bin/env bash
# Unified Dotfiles Installer - Simple Version
# Step by step installation

set -e

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Output functions
log() { echo -e "${BLUE}==>${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*" >&2; }
warning() { echo -e "${YELLOW}⚠${NC} $*"; }

# Banner
print_banner() {
  echo -e "${BLUE}"
  echo "╔════════════════════════════════════╗"
  echo "║   Unified Dotfiles Installer      ║"
  echo "╚════════════════════════════════════╝"
  echo -e "${NC}"
  echo "Location: $DOTFILES_DIR"
  echo ""
}

# Check for dry run
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  warning "Running in DRY RUN mode - no changes will be made"
  echo ""
fi

# Helper to create symlink
create_symlink() {
  local source="$1"
  local target="$2"

  # Check if source exists
  if [[ ! -e "$source" ]]; then
    warning "Source not found: $source (skipping)"
    return
  fi

  # In dry run mode, just show what would happen
  if [[ "$DRY_RUN" == "true" ]]; then
    log "[DRY RUN] Would link: $source -> $target"
    return
  fi

  # Create backup if target exists
  if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/$(basename "$target")"
    warning "Backed up existing $(basename "$target")"
  fi

  # Remove if it's a symlink
  [[ -L "$target" ]] && rm -f "$target"

  # Create parent directory
  mkdir -p "$(dirname "$target")"

  # Create the symlink
  ln -sf "$source" "$target"
  success "Linked $(basename "$target")"
}

# Main installation
main() {
  print_banner

  # Ask for confirmation
  if [[ "$DRY_RUN" != "true" ]]; then
    read -p "$(echo -e "${YELLOW}Ready to install dotfiles. Continue? [y/N]: ${NC}")" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      warning "Installation cancelled"
      exit 0
    fi
  fi

  # Create backup directory
  [[ "$DRY_RUN" != "true" ]] && mkdir -p "$BACKUP_DIR"

  # Step 1: Check for config files
  log "Step 1: Checking configuration files..."

  if [[ ! -d "$DOTFILES_DIR/config" ]]; then
    error "Config directory not found!"
    echo "Please create your config files first in: $DOTFILES_DIR/config"
    exit 1
  fi

  # Step 2: Zsh configuration
  if [[ -f "$DOTFILES_DIR/config/zsh/.zshrc" ]]; then
    log "Step 2: Installing Zsh configuration..."
    create_symlink "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"

    # Create .zsh directory for plugins
    [[ "$DRY_RUN" != "true" ]] && mkdir -p "$HOME/.zsh"
  else
    warning "No .zshrc found, skipping..."
  fi

  # Step 3: Git configuration
  if [[ -f "$DOTFILES_DIR/config/git/.gitconfig" ]]; then
    log "Step 3: Installing Git configuration..."
    create_symlink "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
  else
    warning "No .gitconfig found, skipping..."
  fi

  if [[ -f "$DOTFILES_DIR/config/git/.gitignore_global" ]]; then
    create_symlink "$DOTFILES_DIR/config/git/.gitignore_global" "$HOME/.gitignore_global"
  fi

  # Step 4: tmux configuration
  if [[ -f "$DOTFILES_DIR/config/tmux/tmux.conf" ]]; then
    log "Step 4: Installing tmux configuration..."
    create_symlink "$DOTFILES_DIR/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

    # Install TPM if not present
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]] && [[ "$DRY_RUN" != "true" ]]; then
      log "Installing Tmux Plugin Manager (TPM)..."
      git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
      success "TPM installed"
      log "Note: Start tmux and press Ctrl+a then Shift+I to install plugins"
    fi
  else
    warning "No tmux.conf found, skipping..."
  fi

  # Step 5: Neovim configuration
  if [[ -d "$DOTFILES_DIR/config/nvim" ]]; then
    log "Step 5: Installing Neovim configuration..."

    # Check if LazyVim should be installed
    if [[ ! -d "$HOME/.config/nvim" ]] && [[ "$DRY_RUN" != "true" ]]; then
      log "Installing LazyVim starter..."
      git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
      rm -rf "$HOME/.config/nvim/.git"
    fi

    # Link custom configs
    if [[ -f "$DOTFILES_DIR/config/nvim/init.lua" ]]; then
      create_symlink "$DOTFILES_DIR/config/nvim/init.lua" "$HOME/.config/nvim/init.lua"
    fi

    # Link lua configs
    for file in "$DOTFILES_DIR/config/nvim/lua/config"/*.lua; do
      if [[ -f "$file" ]]; then
        create_symlink "$file" "$HOME/.config/nvim/lua/config/$(basename "$file")"
      fi
    done

    for file in "$DOTFILES_DIR/config/nvim/lua/plugins"/*.lua; do
      if [[ -f "$file" ]]; then
        create_symlink "$file" "$HOME/.config/nvim/lua/plugins/$(basename "$file")"
      fi
    done
  else
    warning "No Neovim config found, skipping..."
  fi

  # Step 6: Starship
  if [[ -f "$DOTFILES_DIR/config/starship/starship.toml" ]]; then
    log "Step 6: Installing Starship configuration..."
    create_symlink "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"
  else
    warning "No starship.toml found, skipping..."
  fi

  # Step 7: Terminal emulators
  log "Step 7: Installing terminal configurations..."

  # WezTerm
  if [[ -f "$DOTFILES_DIR/config/terminals/wezterm/wezterm.lua" ]]; then
    create_symlink "$DOTFILES_DIR/config/terminals/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
  fi

  # Ghostty
  if [[ -f "$DOTFILES_DIR/config/terminals/ghostty/config" ]]; then
    create_symlink "$DOTFILES_DIR/config/terminals/ghostty/config" "$HOME/.config/ghostty/config"
  fi

  # Warp
  if [[ -d "$DOTFILES_DIR/config/terminals/warp" ]]; then
    create_symlink "$DOTFILES_DIR/config/terminals/warp" "$HOME/.config/warp"
  fi

  # Step 8: VS Code
  if [[ -f "$DOTFILES_DIR/config/vscode/settings.json" ]]; then
    log "Step 8: Installing VS Code configuration..."

    # Detect VS Code config location
    if [[ -d "$HOME/Library/Application Support/Code/User" ]]; then
      # macOS
      create_symlink "$DOTFILES_DIR/config/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
    elif [[ -d "$HOME/.config/Code/User" ]]; then
      # Linux
      create_symlink "$DOTFILES_DIR/config/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
    fi
  else
    warning "No VS Code config found, skipping..."
  fi

  # Success!
  echo ""
  if [[ "$DRY_RUN" == "true" ]]; then
    success "Dry run complete! No changes were made."
    echo "Run without --dry-run to actually install."
  else
    success "Installation complete!"
    echo ""
    log "Next steps:"
    echo "  1. Restart your terminal"
    echo "  2. Run: make check (to verify installation)"
    echo ""
    if [[ -d "$BACKUP_DIR" ]]; then
      log "Backups saved to: $BACKUP_DIR"
    fi
  fi
}

# Run main
main
