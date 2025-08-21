#!/usr/bin/env bash
# Unified Dotfiles Uninstaller
# Safely remove dotfiles and optionally restore backups

set -e

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup"
BACKUP_ONLY=false
FORCE=false

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
  echo -e "${RED}"
  echo "╔════════════════════════════════════╗"
  echo "║   Dotfiles Uninstaller            ║"
  echo "╚════════════════════════════════════╝"
  echo -e "${NC}"
  echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  --backup-only)
    BACKUP_ONLY=true
    shift
    ;;
  --force)
    FORCE=true
    shift
    ;;
  --help)
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --backup-only   Only create backups, don't uninstall"
    echo "  --force         Skip confirmation prompts"
    echo "  --help          Show this help message"
    exit 0
    ;;
  *)
    error "Unknown option: $1"
    exit 1
    ;;
  esac
done

# Remove a symlink if it points to our dotfiles
remove_symlink() {
  local target="$1"
  local name="$(basename "$target")"

  if [[ -L "$target" ]]; then
    # Check if symlink points to our dotfiles
    local link_target="$(readlink "$target")"
    if [[ "$link_target" == *"$DOTFILES_DIR"* ]] || [[ "$link_target" == *"dotfiles"* ]]; then
      rm -f "$target"
      success "Removed $name"
    else
      warning "$name points elsewhere, skipping"
    fi
  elif [[ -e "$target" ]]; then
    warning "$name is not a symlink, skipping"
  fi
}

# Create backup of current configs
create_backup() {
  local timestamp="$(date +%Y%m%d_%H%M%S)"
  local backup_path="$BACKUP_DIR/manual_backup_$timestamp"

  log "Creating backup at: $backup_path"
  mkdir -p "$backup_path"

  # List of files to backup
  local files=(
    "$HOME/.zshrc"
    "$HOME/.gitconfig"
    "$HOME/.gitignore_global"
    "$HOME/.config/tmux/tmux.conf"
    "$HOME/.config/nvim/init.lua"
    "$HOME/.config/starship.toml"
    "$HOME/.config/wezterm/wezterm.lua"
    "$HOME/.config/ghostty/config"
  )

  for file in "${files[@]}"; do
    if [[ -e "$file" ]] && [[ ! -L "$file" ]]; then
      local rel_path="${file#$HOME/}"
      mkdir -p "$backup_path/$(dirname "$rel_path")"
      cp -r "$file" "$backup_path/$rel_path"
      success "Backed up $(basename "$file")"
    fi
  done

  log "Backup completed: $backup_path"
}

# Restore from most recent backup
restore_backup() {
  if [[ ! -d "$BACKUP_DIR" ]]; then
    error "No backups found"
    return 1
  fi

  # Find most recent backup
  local latest_backup=$(ls -td "$BACKUP_DIR"/* 2>/dev/null | head -n 1)

  if [[ -z "$latest_backup" ]]; then
    error "No backups found"
    return 1
  fi

  log "Restoring from: $latest_backup"

  # Ask for confirmation
  if [[ "$FORCE" != "true" ]]; then
    read -p "$(echo -e "${YELLOW}Restore from this backup? [y/N]: ${NC}")" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      warning "Restore cancelled"
      return 0
    fi
  fi

  # Restore files
  if [[ -f "$latest_backup/.zshrc" ]]; then
    cp "$latest_backup/.zshrc" "$HOME/.zshrc"
    success "Restored .zshrc"
  fi

  if [[ -f "$latest_backup/.gitconfig" ]]; then
    cp "$latest_backup/.gitconfig" "$HOME/.gitconfig"
    success "Restored .gitconfig"
  fi

  # Add more restorations as needed...

  success "Restore completed"
}

# Main uninstall function
uninstall() {
  log "Removing dotfiles symlinks..."

  # Zsh
  remove_symlink "$HOME/.zshrc"
  remove_symlink "$HOME/.zshenv"

  # Git
  remove_symlink "$HOME/.gitconfig"
  remove_symlink "$HOME/.gitignore_global"

  # tmux
  remove_symlink "$HOME/.config/tmux/tmux.conf"

  # Neovim
  remove_symlink "$HOME/.config/nvim/init.lua"
  for file in "$HOME/.config/nvim/lua/config"/*.lua; do
    [[ -L "$file" ]] && remove_symlink "$file"
  done
  for file in "$HOME/.config/nvim/lua/plugins"/*.lua; do
    [[ -L "$file" ]] && remove_symlink "$file"
  done

  # Starship
  remove_symlink "$HOME/.config/starship.toml"

  # Terminal emulators
  remove_symlink "$HOME/.config/wezterm/wezterm.lua"
  remove_symlink "$HOME/.config/ghostty/config"
  remove_symlink "$HOME/.config/warp"

  # VS Code
  if [[ -d "$HOME/Library/Application Support/Code/User" ]]; then
    remove_symlink "$HOME/Library/Application Support/Code/User/settings.json"
    remove_symlink "$HOME/Library/Application Support/Code/User/keybindings.json"
  fi

  success "Uninstallation complete"
}

# List current symlinks
list_symlinks() {
  log "Current dotfiles symlinks:"
  echo ""

  local links=(
    "$HOME/.zshrc"
    "$HOME/.gitconfig"
    "$HOME/.config/tmux/tmux.conf"
    "$HOME/.config/nvim/init.lua"
    "$HOME/.config/starship.toml"
    "$HOME/.config/wezterm/wezterm.lua"
    "$HOME/.config/ghostty/config"
  )

  for link in "${links[@]}"; do
    if [[ -L "$link" ]]; then
      local target="$(readlink "$link")"
      if [[ "$target" == *"dotfiles"* ]]; then
        echo "  $(basename "$link") -> $target"
      fi
    fi
  done
}

# Main
main() {
  if [[ "$BACKUP_ONLY" == "true" ]]; then
    print_banner
    create_backup
    exit 0
  fi

  print_banner

  # Show current state
  list_symlinks
  echo ""

  # Confirmation
  if [[ "$FORCE" != "true" ]]; then
    echo -e "${YELLOW}This will remove all dotfiles symlinks.${NC}"
    read -p "$(echo -e "${YELLOW}Continue? [y/N]: ${NC}")" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      warning "Uninstallation cancelled"
      exit 0
    fi
  fi

  # Uninstall
  uninstall
  echo ""

  # Ask about restore
  if [[ "$FORCE" != "true" ]]; then
    read -p "$(echo -e "${YELLOW}Restore from backup? [y/N]: ${NC}")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      restore_backup
    fi
  fi

  echo ""
  log "Done!"

  # Show backup location
  if [[ -d "$BACKUP_DIR" ]]; then
    log "Backups are stored in: $BACKUP_DIR"
  fi
}

# Run main
main
