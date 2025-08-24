#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
#  Modern Dotfiles Uninstallation Script v2.0
#  Clean removal with backup and restore options
# ═══════════════════════════════════════════════════════════════════════════

set -e

# ╭──────────────────────────────────────────────────────────╮
# │                      Configuration                       │
# ╰──────────────────────────────────────────────────────────╯

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# Component flags
REMOVE_ALL=false
REMOVE_SYMLINKS=false
REMOVE_PACKAGES=false
REMOVE_ZSH=false
REMOVE_TMUX=false
REMOVE_NEOVIM=false
REMOVE_STARSHIP=false
REMOVE_GIT=false
REMOVE_TERMINALS=false
REMOVE_VSCODE=false
REMOVE_HOMEBREW=false
REMOVE_DOTFILES_DIR=false
BACKUP_ONLY=false
FORCE_MODE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# ╭──────────────────────────────────────────────────────────╮
# │                    Helper Functions                      │
# ╰──────────────────────────────────────────────────────────╯

print_step() {
  echo -e "\n${BLUE}==>${NC} $1"
}

print_success() {
  echo -e "${GREEN}  ✓${NC} $1"
}

print_error() {
  echo -e "${RED}  ✗${NC} $1" >&2
}

print_warning() {
  echo -e "${YELLOW}  ⚠${NC} $1"
}

print_info() {
  echo -e "${PURPLE}  ℹ${NC} $1"
}

confirm() {
  if [ "$FORCE_MODE" = true ]; then
    return 0
  fi
  read -p "$(echo -e ${YELLOW}"$1 (y/n): "${NC})" -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]]
}

print_banner() {
  clear
  echo -e "${RED}"
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║                                                           ║"
  echo "║           🗑️  DOTFILES UNINSTALLATION WIZARD 🗑️          ║"
  echo "║                                                           ║"
  echo "║                    Version 2.0                           ║"
  echo "║                                                           ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo ""
}

show_help() {
  echo "Dotfiles Uninstallation Script v2.0"
  echo ""
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --all               Remove everything (configs, packages, tools)"
  echo "  --symlinks          Remove all symlinks only"
  echo "  --packages          Remove Homebrew packages from Brewfile"
  echo "  --zsh               Remove Zsh configuration"
  echo "  --tmux              Remove tmux configuration"
  echo "  --neovim            Remove Neovim configuration"
  echo "  --starship          Remove Starship configuration"
  echo "  --git               Remove Git configuration"
  echo "  --terminals         Remove terminal configurations"
  echo "  --vscode            Remove VS Code configuration"
  echo "  --homebrew          Remove Homebrew completely (DANGEROUS!)"
  echo "  --dotfiles-dir      Remove dotfiles directory"
  echo "  --backup-only       Only create backup, don't remove"
  echo "  --force             Skip all confirmations"
  echo "  --help              Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 --symlinks       # Remove only symlinks"
  echo "  $0 --packages       # Uninstall Brewfile packages"
  echo "  $0 --all           # Remove everything"
  echo "  $0 --backup-only   # Just create a backup"
  exit 0
}

# ╭──────────────────────────────────────────────────────────╮
# │                   Parse Arguments                        │
# ╰──────────────────────────────────────────────────────────╯

while [[ $# -gt 0 ]]; do
  case "$1" in
  --all)
    REMOVE_ALL=true
    shift
    ;;
  --symlinks)
    REMOVE_SYMLINKS=true
    shift
    ;;
  --packages)
    REMOVE_PACKAGES=true
    shift
    ;;
  --zsh)
    REMOVE_ZSH=true
    shift
    ;;
  --tmux)
    REMOVE_TMUX=true
    shift
    ;;
  --neovim)
    REMOVE_NEOVIM=true
    shift
    ;;
  --starship)
    REMOVE_STARSHIP=true
    shift
    ;;
  --git)
    REMOVE_GIT=true
    shift
    ;;
  --terminals)
    REMOVE_TERMINALS=true
    shift
    ;;
  --vscode)
    REMOVE_VSCODE=true
    shift
    ;;
  --homebrew)
    REMOVE_HOMEBREW=true
    shift
    ;;
  --dotfiles-dir)
    REMOVE_DOTFILES_DIR=true
    shift
    ;;
  --backup-only)
    BACKUP_ONLY=true
    shift
    ;;
  --force)
    FORCE_MODE=true
    shift
    ;;
  --help | -h)
    show_help
    ;;
  *)
    print_error "Unknown option: $1"
    show_help
    ;;
  esac
done

# ╭──────────────────────────────────────────────────────────╮
# │                    Backup Functions                      │
# ╰──────────────────────────────────────────────────────────╯

create_backup() {
  local backup_path="$BACKUP_DIR/backup_$TIMESTAMP"

  print_step "Creating backup at: $backup_path"
  mkdir -p "$backup_path"

  # List of files to backup
  local files=(
    "$HOME/.zshrc"
    "$HOME/.zsh"
    "$HOME/.gitconfig"
    "$HOME/.gitignore_global"
    "$HOME/.config/tmux"
    "$HOME/.config/nvim"
    "$HOME/.config/starship.toml"
    "$HOME/.config/wezterm"
    "$HOME/.config/warp"
    "$HOME/.config/ghostty"
  )

  for file in "${files[@]}"; do
    if [ -e "$file" ] && [ ! -L "$file" ]; then
      local rel_path="${file#$HOME/}"
      mkdir -p "$backup_path/$(dirname "$rel_path")"
      cp -R "$file" "$backup_path/$rel_path"
      print_success "Backed up $(basename "$file")"
    fi
  done

  # Backup VS Code settings
  local vscode_dir=""
  if [[ "$(uname -s)" == "Darwin" ]]; then
    vscode_dir="$HOME/Library/Application Support/Code/User"
  else
    vscode_dir="$HOME/.config/Code/User"
  fi

  if [ -d "$vscode_dir" ]; then
    mkdir -p "$backup_path/vscode"
    cp "$vscode_dir/settings.json" "$backup_path/vscode/" 2>/dev/null || true
    print_success "Backed up VS Code settings"
  fi

  print_success "Backup completed: $backup_path"
}

# ╭──────────────────────────────────────────────────────────╮
# │                   Removal Functions                      │
# ╰──────────────────────────────────────────────────────────╯

remove_symlink() {
  local target="$1"

  if [ -L "$target" ]; then
    rm -f "$target"
    print_success "Removed symlink: $(basename "$target")"
  elif [ -e "$target" ]; then
    print_warning "$(basename "$target") is not a symlink, skipping"
  fi
}

remove_all_symlinks() {
  print_step "Removing all dotfile symlinks..."

  # Shell configs
  remove_symlink "$HOME/.zshrc"

  # Zsh components
  if [ -d "$HOME/.zsh" ]; then
    for file in "$HOME/.zsh"/*.zsh; do
      [ -L "$file" ] && remove_symlink "$file"
    done
  fi

  # Git configs
  remove_symlink "$HOME/.gitconfig"
  remove_symlink "$HOME/.gitignore_global"

  # Config directory items
  remove_symlink "$HOME/.config/starship.toml"
  remove_symlink "$HOME/.config/tmux/tmux.conf"
  remove_symlink "$HOME/.config/wezterm/wezterm.lua"
  remove_symlink "$HOME/.config/warp"
  remove_symlink "$HOME/.config/ghostty/config"

  # Neovim configs
  if [ -d "$HOME/.config/nvim/lua" ]; then
    find "$HOME/.config/nvim/lua" -type l -delete 2>/dev/null || true
  fi

  # VS Code
  local vscode_dir=""
  if [[ "$(uname -s)" == "Darwin" ]]; then
    vscode_dir="$HOME/Library/Application Support/Code/User"
  else
    vscode_dir="$HOME/.config/Code/User"
  fi
  [ -L "$vscode_dir/settings.json" ] && remove_symlink "$vscode_dir/settings.json"

  print_success "All symlinks removed"
}

remove_brew_packages() {
  print_step "Removing Homebrew packages from Brewfile..."

  if [ ! -f "$DOTFILES_DIR/packages/Brewfile" ]; then
    print_error "Brewfile not found"
    return
  fi

  if ! command -v brew &>/dev/null; then
    print_warning "Homebrew not installed"
    return
  fi

  print_info "This will uninstall all packages listed in Brewfile"
  if confirm "Continue?"; then
    # Parse Brewfile and uninstall packages
    while IFS= read -r line; do
      # Skip comments and empty lines
      [[ "$line" =~ ^#.*$ ]] && continue
      [[ -z "$line" ]] && continue

      # Extract package names
      if [[ "$line" =~ ^brew[[:space:]]+\"(.+)\" ]]; then
        package="${BASH_REMATCH[1]}"
        brew uninstall --ignore-dependencies "$package" 2>/dev/null &&
          print_success "Removed $package" ||
          print_warning "$package not installed"
      elif [[ "$line" =~ ^cask[[:space:]]+\"(.+)\" ]]; then
        cask="${BASH_REMATCH[1]}"
        brew uninstall --cask "$cask" 2>/dev/null &&
          print_success "Removed $cask" ||
          print_warning "$cask not installed"
      fi
    done <"$DOTFILES_DIR/packages/Brewfile"

    # Clean up
    brew autoremove
    brew cleanup
    print_success "Homebrew packages removed"
  fi
}

remove_zsh_config() {
  print_step "Removing Zsh configuration..."

  remove_symlink "$HOME/.zshrc"

  # Remove Zsh plugins
  [ -d "$HOME/.zsh/zsh-autosuggestions" ] && rm -rf "$HOME/.zsh/zsh-autosuggestions"
  [ -d "$HOME/.zsh/zsh-syntax-highlighting" ] && rm -rf "$HOME/.zsh/zsh-syntax-highlighting"

  # Remove symlinked files
  if [ -d "$HOME/.zsh" ]; then
    find "$HOME/.zsh" -type l -delete 2>/dev/null || true
  fi

  print_success "Zsh configuration removed"
}

remove_tmux_config() {
  print_step "Removing tmux configuration..."

  remove_symlink "$HOME/.config/tmux/tmux.conf"
  remove_symlink "$HOME/.config/tmux/tmux.reset.conf"

  # Remove TPM if installed
  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    if confirm "Remove tmux Plugin Manager?"; then
      rm -rf "$HOME/.tmux/plugins"
      print_success "TPM removed"
    fi
  fi

  print_success "tmux configuration removed"
}

remove_neovim_config() {
  print_step "Removing Neovim configuration..."

  if [ -d "$HOME/.config/nvim" ]; then
    if confirm "Remove entire Neovim configuration?"; then
      rm -rf "$HOME/.config/nvim"
      rm -rf "$HOME/.local/share/nvim"
      rm -rf "$HOME/.local/state/nvim"
      rm -rf "$HOME/.cache/nvim"
      print_success "Neovim configuration removed"
    else
      # Just remove symlinks
      find "$HOME/.config/nvim" -type l -delete 2>/dev/null || true
      print_success "Neovim symlinks removed"
    fi
  fi
}

remove_starship_config() {
  print_step "Removing Starship configuration..."

  remove_symlink "$HOME/.config/starship.toml"

  if confirm "Uninstall Starship?"; then
    brew uninstall starship 2>/dev/null || true
    print_success "Starship uninstalled"
  fi
}

remove_git_config() {
  print_step "Removing Git configuration..."

  remove_symlink "$HOME/.gitconfig"
  remove_symlink "$HOME/.gitignore_global"

  print_success "Git configuration removed"
}

remove_terminal_configs() {
  print_step "Removing terminal configurations..."

  remove_symlink "$HOME/.config/wezterm/wezterm.lua"
  remove_symlink "$HOME/.config/warp"
  remove_symlink "$HOME/.config/ghostty/config"

  print_success "Terminal configurations removed"
}

remove_vscode_config() {
  print_step "Removing VS Code configuration..."

  local vscode_dir=""
  if [[ "$(uname -s)" == "Darwin" ]]; then
    vscode_dir="$HOME/Library/Application Support/Code/User"
  else
    vscode_dir="$HOME/.config/Code/User"
  fi

  if [ -L "$vscode_dir/settings.json" ]; then
    remove_symlink "$vscode_dir/settings.json"
    print_success "VS Code configuration removed"
  fi
}

remove_homebrew() {
  print_step "Removing Homebrew..."

  print_warning "This will completely uninstall Homebrew and ALL packages!"
  if confirm "Are you SURE you want to remove Homebrew?"; then
    if confirm "Are you REALLY sure? This cannot be undone!"; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
      print_success "Homebrew removed"
    fi
  fi
}

remove_dotfiles_directory() {
  print_step "Removing dotfiles directory..."

  if [ "$DOTFILES_DIR" != "$HOME" ] && [ -d "$DOTFILES_DIR" ]; then
    if confirm "Remove dotfiles directory at $DOTFILES_DIR?"; then
      rm -rf "$DOTFILES_DIR"
      print_success "Dotfiles directory removed"
    fi
  fi
}

cleanup_backups() {
  print_step "Cleaning up old backups..."

  if [ -d "$BACKUP_DIR" ]; then
    # Remove backups older than 30 days
    find "$BACKUP_DIR" -maxdepth 1 -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
    print_success "Old backups cleaned"
  fi
}

# ╭──────────────────────────────────────────────────────────╮
# │                      Main Logic                          │
# ╰──────────────────────────────────────────────────────────╯

main() {
  print_banner

  # If backup-only mode
  if [ "$BACKUP_ONLY" = true ]; then
    create_backup
    exit 0
  fi

  # If --all flag is set
  if [ "$REMOVE_ALL" = true ]; then
    REMOVE_SYMLINKS=true
    REMOVE_PACKAGES=true
    REMOVE_ZSH=true
    REMOVE_TMUX=true
    REMOVE_NEOVIM=true
    REMOVE_STARSHIP=true
    REMOVE_GIT=true
    REMOVE_TERMINALS=true
    REMOVE_VSCODE=true
    REMOVE_DOTFILES_DIR=true
    # Note: REMOVE_HOMEBREW is not set even with --all for safety
  fi

  # No options specified
  if [ "$REMOVE_SYMLINKS" = false ] &&
    [ "$REMOVE_PACKAGES" = false ] &&
    [ "$REMOVE_ZSH" = false ] &&
    [ "$REMOVE_TMUX" = false ] &&
    [ "$REMOVE_NEOVIM" = false ] &&
    [ "$REMOVE_STARSHIP" = false ] &&
    [ "$REMOVE_GIT" = false ] &&
    [ "$REMOVE_TERMINALS" = false ] &&
    [ "$REMOVE_VSCODE" = false ] &&
    [ "$REMOVE_HOMEBREW" = false ] &&
    [ "$REMOVE_DOTFILES_DIR" = false ]; then

    echo -e "${YELLOW}What would you like to remove?${NC}"
    echo ""
    echo "  1) Symlinks only"
    echo "  2) Homebrew packages (from Brewfile)"
    echo "  3) Individual components"
    echo "  4) Everything (except Homebrew)"
    echo "  5) Exit"
    echo ""
    read -p "Choice (1-5): " choice

    case $choice in
    1) REMOVE_SYMLINKS=true ;;
    2) REMOVE_PACKAGES=true ;;
    3)
      echo ""
      confirm "Remove Zsh config?" && REMOVE_ZSH=true
      confirm "Remove tmux config?" && REMOVE_TMUX=true
      confirm "Remove Neovim config?" && REMOVE_NEOVIM=true
      confirm "Remove Starship?" && REMOVE_STARSHIP=true
      confirm "Remove Git config?" && REMOVE_GIT=true
      confirm "Remove terminal configs?" && REMOVE_TERMINALS=true
      confirm "Remove VS Code config?" && REMOVE_VSCODE=true
      ;;
    4) REMOVE_ALL=true ;;
    5) exit 0 ;;
    *)
      print_error "Invalid choice"
      exit 1
      ;;
    esac
  fi

  # Create backup first
  if confirm "Create backup before removing?"; then
    create_backup
  fi

  # Execute removals
  [ "$REMOVE_PACKAGES" = true ] && remove_brew_packages
  [ "$REMOVE_SYMLINKS" = true ] && remove_all_symlinks

  # Individual component removal
  [ "$REMOVE_ZSH" = true ] && remove_zsh_config
  [ "$REMOVE_TMUX" = true ] && remove_tmux_config
  [ "$REMOVE_NEOVIM" = true ] && remove_neovim_config
  [ "$REMOVE_STARSHIP" = true ] && remove_starship_config
  [ "$REMOVE_GIT" = true ] && remove_git_config
  [ "$REMOVE_TERMINALS" = true ] && remove_terminal_configs
  [ "$REMOVE_VSCODE" = true ] && remove_vscode_config

  # Dangerous removals
  [ "$REMOVE_HOMEBREW" = true ] && remove_homebrew
  [ "$REMOVE_DOTFILES_DIR" = true ] && remove_dotfiles_directory

  # Cleanup
  cleanup_backups

  echo ""
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                                                           ║${NC}"
  echo -e "${GREEN}║            ✓ UNINSTALLATION COMPLETED                    ║${NC}"
  echo -e "${GREEN}║                                                           ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
  echo ""

  if [ -d "$BACKUP_DIR" ]; then
    print_info "Backups available at: $BACKUP_DIR"
  fi

  if [ "$REMOVE_ZSH" = true ] || [ "$REMOVE_ALL" = true ]; then
    print_warning "You may need to restart your terminal"
    print_warning "Your default shell might have been changed"
  fi
}

# Run main function
main "$@"
