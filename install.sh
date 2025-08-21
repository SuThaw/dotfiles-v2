#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
#  Modern Dotfiles Installation Script v2.0
#  Automated setup for development environment
# ═══════════════════════════════════════════════════════════════════════════

set -e

# ╭──────────────────────────────────────────────────────────╮
# │                      Configuration                       │
# ╰──────────────────────────────────────────────────────────╯

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
OS_TYPE="$(uname -s)"

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

command_exists() {
  command -v "$1" &>/dev/null
}

confirm() {
  read -p "$(echo -e ${YELLOW}"$1 (y/n): "${NC})" -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]]
}

backup_file() {
  if [ -e "$1" ] && [ ! -L "$1" ]; then
    local backup_path="$BACKUP_DIR/$(dirname "${1#$HOME/}")"
    mkdir -p "$backup_path"
    mv "$1" "$backup_path/$(basename "$1")"
    print_info "Backed up $(basename "$1")"
  fi
}

create_symlink() {
  local source="$1"
  local target="$2"

  # Create parent directory if needed
  mkdir -p "$(dirname "$target")"

  # Backup existing file
  backup_file "$target"

  # Remove existing symlink
  [ -L "$target" ] && rm -f "$target"

  # Create new symlink
  ln -sf "$source" "$target"
  print_success "Linked $(basename "$source")"
}

print_banner() {
  clear
  echo -e "${CYAN}"
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║                                                           ║"
  echo "║           🚀 DOTFILES INSTALLATION WIZARD 🚀             ║"
  echo "║                                                           ║"
  echo "║            Modern Development Environment                 ║"
  echo "║                    Version 2.0                           ║"
  echo "║                                                           ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo ""
}

# ╭──────────────────────────────────────────────────────────╮
# │                  Installation Steps                      │
# ╰──────────────────────────────────────────────────────────╯

# STEP 1: Install Homebrew
install_homebrew() {
  print_step "Checking Homebrew..."

  if ! command_exists brew; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    if [[ "$OS_TYPE" == "Darwin" ]]; then
      if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
      else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >>"$HOME/.zprofile"
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    fi
    print_success "Homebrew installed"
  else
    print_success "Homebrew already installed"
    brew update
    print_success "Homebrew updated"
  fi
}

# STEP 2: Install packages from Brewfile
install_brew_packages() {
  print_step "Installing packages from Brewfile..."

  if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    # Check if running on macOS for casks
    if [[ "$OS_TYPE" == "Darwin" ]]; then
      brew bundle --file="$DOTFILES_DIR/Brewfile"
    else
      # On Linux, skip casks
      brew bundle --file="$DOTFILES_DIR/Brewfile" --no-cask
    fi
    print_success "All packages installed"
  else
    print_error "Brewfile not found at $DOTFILES_DIR/Brewfile"
    exit 1
  fi
}

# STEP 3: Setup Zsh
setup_zsh() {
  print_step "Setting up Zsh configuration..."

  # Backup and link .zshrc
  if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  fi

  # Link Zsh components
  if [ -d "$DOTFILES_DIR/zsh" ]; then
    for file in "$DOTFILES_DIR/zsh"/*.zsh; do
      if [ -f "$file" ]; then
        filename=$(basename "$file")
        create_symlink "$file" "$HOME/.zsh/$filename"
      fi
    done
  fi

  print_success "Zsh configuration complete"
}

# STEP 4: Setup Starship
setup_starship() {
  print_step "Setting up Starship prompt..."

  if [ -f "$DOTFILES_DIR/.config/starship.toml" ]; then
    create_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
    print_success "Starship configured"
  fi
}

# STEP 5: Setup tmux
setup_tmux() {
  print_step "Setting up tmux..."

  # Install TPM (Tmux Plugin Manager)
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    print_info "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    print_success "TPM installed"
  fi

  # Link tmux config
  if [ -f "$DOTFILES_DIR/.config/tmux/tmux.conf" ]; then
    create_symlink "$DOTFILES_DIR/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
  fi

  print_success "tmux configuration complete"
  print_info "Remember to press Ctrl+a then I in tmux to install plugins"
}

# STEP 6: Setup Neovim
setup_neovim() {
  print_step "Setting up Neovim with LazyVim..."

  # Backup existing config
  if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    print_warning "Backing up existing Neovim configuration..."
    mv "$HOME/.config/nvim" "$BACKUP_DIR/nvim"
  fi

  # Install LazyVim if not present
  if [ ! -d "$HOME/.config/nvim" ]; then
    print_info "Installing LazyVim..."
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
    print_success "LazyVim installed"
  fi

  # Link custom configs
  mkdir -p "$HOME/.config/nvim/lua/config"
  mkdir -p "$HOME/.config/nvim/lua/plugins"

  for config_file in "$DOTFILES_DIR/.config/nvim/lua/config"/*.lua; do
    if [ -f "$config_file" ]; then
      create_symlink "$config_file" "$HOME/.config/nvim/lua/config/$(basename "$config_file")"
    fi
  done

  for plugin_file in "$DOTFILES_DIR/.config/nvim/lua/plugins"/*.lua; do
    if [ -f "$plugin_file" ]; then
      create_symlink "$plugin_file" "$HOME/.config/nvim/lua/plugins/$(basename "$plugin_file")"
    fi
  done

  print_success "Neovim configuration complete"
}

# STEP 7: Setup Git
setup_git() {
  print_step "Setting up Git configuration..."

  if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
    create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
  fi

  if [ -f "$DOTFILES_DIR/.gitignore_global" ]; then
    create_symlink "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
  fi

  print_success "Git configuration complete"
}

# STEP 8: Setup terminal emulators
setup_terminals() {
  print_step "Setting up terminal emulators..."

  # WezTerm
  if [ -f "$DOTFILES_DIR/.config/wezterm/wezterm.lua" ]; then
    create_symlink "$DOTFILES_DIR/.config/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
    print_success "WezTerm configured"
  fi

  # Ghostty
  if [ -f "$DOTFILES_DIR/.config/ghostty/config" ]; then
    create_symlink "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
    print_success "Ghostty configured"
  fi
}

# STEP 9: Setup VS Code
setup_vscode() {
  print_step "Setting up VS Code..."

  local vscode_dir=""

  if [[ "$OS_TYPE" == "Darwin" ]]; then
    vscode_dir="$HOME/Library/Application Support/Code/User"
  elif [[ "$OS_TYPE" == "Linux" ]]; then
    vscode_dir="$HOME/.config/Code/User"
  fi

  if [ -n "$vscode_dir" ] && [ -d "$vscode_dir" ]; then
    if [ -f "$DOTFILES_DIR/vscode/settings.json" ]; then
      create_symlink "$DOTFILES_DIR/vscode/settings.json" "$vscode_dir/settings.json"
    fi

    # Install extensions
    if command_exists code && [ -f "$DOTFILES_DIR/vscode/extensions.txt" ]; then
      print_info "Installing VS Code extensions..."
      while IFS= read -r extension; do
        [ -n "$extension" ] && [[ ! "$extension" =~ ^# ]] &&
          code --install-extension "$extension" --force 2>/dev/null
      done <"$DOTFILES_DIR/vscode/extensions.txt"
      print_success "VS Code extensions installed"
    fi
  fi
}

# STEP 10: Install additional tools not in Homebrew
install_additional_tools() {
  print_step "Installing additional tools..."

  # Install Bun if not present
  if ! command_exists bun; then
    print_info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    print_success "Bun installed"
  fi

  # Setup NVM directory
  if [ ! -d "$HOME/.nvm" ]; then
    mkdir -p "$HOME/.nvm"
    print_success "NVM directory created"
  fi
}

# STEP 11: Create project directories
create_project_structure() {
  print_step "Creating project directory structure..."

  local dirs=(
    "$HOME/dev/projects"
    "$HOME/dev/work"
    "$HOME/dev/personal"
    "$HOME/dev/learning"
    "$HOME/dev/sandbox"
    "$HOME/.local/bin"
    "$HOME/.local/scripts"
  )

  for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
  done

  print_success "Project directories created"
}

# STEP 12: Set Zsh as default shell
set_default_shell() {
  print_step "Setting Zsh as default shell..."

  if [[ "$SHELL" != *"zsh"* ]]; then
    if command_exists zsh; then
      if confirm "Set Zsh as your default shell?"; then
        chsh -s "$(which zsh)"
        print_success "Default shell changed to Zsh"
      fi
    fi
  else
    print_success "Zsh is already the default shell"
  fi
}

# ╭──────────────────────────────────────────────────────────╮
# │                    Main Installation                     │
# ╰──────────────────────────────────────────────────────────╯

main() {
  print_banner

  # Create backup directory
  mkdir -p "$BACKUP_DIR"
  print_info "Backup directory: $BACKUP_DIR"

  # Confirm installation
  if ! confirm "This will install and configure your development environment. Continue?"; then
    print_warning "Installation cancelled"
    exit 0
  fi

  # Run installation steps
  install_homebrew
  install_brew_packages
  setup_zsh
  setup_starship
  setup_tmux
  setup_neovim
  setup_git
  setup_terminals
  setup_vscode
  install_additional_tools
  create_project_structure
  set_default_shell

  # Success message
  echo ""
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                                                           ║${NC}"
  echo -e "${GREEN}║         🎉 INSTALLATION COMPLETED SUCCESSFULLY! 🎉        ║${NC}"
  echo -e "${GREEN}║                                                           ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${CYAN}Next steps:${NC}"
  echo "  1. Restart your terminal or run: source ~/.zshrc"
  echo "  2. In tmux, press Ctrl+a then I to install plugins"
  echo "  3. Open Neovim to auto-install plugins"
  echo ""
  echo -e "${YELLOW}Quick commands:${NC}"
  echo "  make help     - Show all available commands"
  echo "  make test     - Test the installation"
  echo "  make update   - Update all packages"
  echo ""
  print_info "Dotfiles location: $DOTFILES_DIR"
  print_info "Backup location: $BACKUP_DIR"
}

# Run main function
main "$@"
