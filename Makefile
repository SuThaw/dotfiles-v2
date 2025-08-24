# ═══════════════════════════════════════════════════════════════════════════
#  Dotfiles Makefile - Command Interface for Dotfiles Management
#  Usage: make [target]
# ═══════════════════════════════════════════════════════════════════════════

# Configuration
SHELL := /bin/bash
DOTFILES_DIR := $(shell pwd)
BACKUP_DIR := ~/.dotfiles_backup
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[0;33m
CYAN := \033[0;36m
PURPLE := \033[0;35m
NC := \033[0m

# Default target
.DEFAULT_GOAL := help

# Phony targets
.PHONY: help install uninstall update backup restore test check doctor brew-backup brew-restore clean

# ╭──────────────────────────────────────────────────────────╮
# │                      Main Targets                        │
# ╰──────────────────────────────────────────────────────────╯

help: ## Show this help message
	@echo -e "$(CYAN)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo -e "$(CYAN)║              Dotfiles Management System                   ║$(NC)"
	@echo -e "$(CYAN)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo -e "$(YELLOW)Usage:$(NC) make [target]"
	@echo ""
	@echo -e "$(YELLOW)Main Commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		grep -v '^#' | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo -e "$(YELLOW)Examples:$(NC)"
	@echo "  make install    # Full installation"
	@echo "  make update     # Update everything"
	@echo "  make doctor     # Check system health"

install: ## Install dotfiles and all packages
	@echo -e "$(BLUE)Starting installation...$(NC)"
	@chmod +x install.sh
	@./install.sh

uninstall: ## Uninstall dotfiles (with confirmation)
	@echo -e "$(RED)Starting uninstallation...$(NC)"
	@chmod +x uninstall.sh
	@./uninstall.sh

update: ## Update all packages and tools
	@echo -e "$(BLUE)Updating Homebrew packages...$(NC)"
	@brew update
	@brew upgrade
	@brew cleanup
	@echo -e "$(BLUE)Updating Homebrew casks...$(NC)"
	@brew upgrade --cask
	@echo -e "$(BLUE)Updating npm packages...$(NC)"
	@npm update -g
	@echo -e "$(BLUE)Updating tmux plugins...$(NC)"
	@~/.tmux/plugins/tpm/bin/update_plugins all
	@echo -e "$(GREEN)✓ All packages updated$(NC)"

backup: ## Create backup of current configs
	@echo -e "$(BLUE)Creating backup...$(NC)"
	@mkdir -p $(BACKUP_DIR)/manual_$(TIMESTAMP)
	@cp -R ~/.zshrc $(BACKUP_DIR)/manual_$(TIMESTAMP)/ 2>/dev/null || true
	@cp -R ~/.config/nvim $(BACKUP_DIR)/manual_$(TIMESTAMP)/ 2>/dev/null || true
	@cp -R ~/.config/tmux $(BACKUP_DIR)/manual_$(TIMESTAMP)/ 2>/dev/null || true
	@cp -R ~/.gitconfig $(BACKUP_DIR)/manual_$(TIMESTAMP)/ 2>/dev/null || true
	@echo -e "$(GREEN)✓ Backup created at $(BACKUP_DIR)/manual_$(TIMESTAMP)$(NC)"

restore: ## Restore from latest backup
	@echo -e "$(YELLOW)Available backups:$(NC)"
	@ls -la $(BACKUP_DIR) | tail -n +2
	@echo ""
	@read -p "Enter backup folder name to restore: " backup_name; \
	if [ -d "$(BACKUP_DIR)/$$backup_name" ]; then \
		cp -R $(BACKUP_DIR)/$$backup_name/* ~/; \
		echo -e "$(GREEN)✓ Restored from $$backup_name$(NC)"; \
	else \
		echo -e "$(RED)✗ Backup not found$(NC)"; \
	fi

# ╭──────────────────────────────────────────────────────────╮
# │                   Diagnostic Targets                     │
# ╰──────────────────────────────────────────────────────────╯

test: ## Test installation in dry-run mode
	@echo -e "$(YELLOW)Running in test mode...$(NC)"
	@chmod +x install.sh
	@./install.sh --dry-run

check: ## Check if all requirements are installed
	@echo -e "$(BLUE)Checking requirements...$(NC)"
	@echo ""
	@echo -e "$(YELLOW)Core Requirements:$(NC)"
	@command -v git >/dev/null && echo -e "  $(GREEN)✓$(NC) git" || echo -e "  $(RED)✗$(NC) git"
	@command -v curl >/dev/null && echo -e "  $(GREEN)✓$(NC) curl" || echo -e "  $(RED)✗$(NC) curl"
	@command -v zsh >/dev/null && echo -e "  $(GREEN)✓$(NC) zsh" || echo -e "  $(RED)✗$(NC) zsh"
	@echo ""
	@echo -e "$(YELLOW)Package Managers:$(NC)"
	@command -v brew >/dev/null && echo -e "  $(GREEN)✓$(NC) homebrew" || echo -e "  $(RED)✗$(NC) homebrew"
	@command -v npm >/dev/null && echo -e "  $(GREEN)✓$(NC) npm" || echo -e "  $(RED)✗$(NC) npm"
	@command -v bun >/dev/null && echo -e "  $(GREEN)✓$(NC) bun" || echo -e "  $(RED)✗$(NC) bun"
	@echo ""
	@echo -e "$(YELLOW)Development Tools:$(NC)"
	@command -v nvim >/dev/null && echo -e "  $(GREEN)✓$(NC) neovim" || echo -e "  $(RED)✗$(NC) neovim"
	@command -v tmux >/dev/null && echo -e "  $(GREEN)✓$(NC) tmux" || echo -e "  $(RED)✗$(NC) tmux"
	@command -v starship >/dev/null && echo -e "  $(GREEN)✓$(NC) starship" || echo -e "  $(RED)✗$(NC) starship"
	@command -v lazygit >/dev/null && echo -e "  $(GREEN)✓$(NC) lazygit" || echo -e "  $(RED)✗$(NC) lazygit"
	@command -v docker >/dev/null && echo -e "  $(GREEN)✓$(NC) docker" || echo -e "  $(RED)✗$(NC) docker"

doctor: ## Run full system diagnostics
	@echo -e "$(CYAN)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo -e "$(CYAN)║                   System Diagnostics                      ║$(NC)"
	@echo -e "$(CYAN)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo -e "$(YELLOW)System Info:$(NC)"
	@echo "  OS: $$(uname -s)"
	@echo "  Architecture: $$(uname -m)"
	@echo "  Shell: $$SHELL"
	@echo "  Dotfiles: $(DOTFILES_DIR)"
	@echo ""
	@$(MAKE) -s check
	@echo ""
	@echo -e "$(YELLOW)Symlink Status:$(NC)"
	@[ -L ~/.zshrc ] && echo -e "  $(GREEN)✓$(NC) .zshrc linked" || echo -e "  $(RED)✗$(NC) .zshrc not linked"
	@[ -L ~/.gitconfig ] && echo -e "  $(GREEN)✓$(NC) .gitconfig linked" || echo -e "  $(RED)✗$(NC) .gitconfig not linked"
	@[ -L ~/.config/nvim/init.lua ] && echo -e "  $(GREEN)✓$(NC) nvim config linked" || echo -e "  $(RED)✗$(NC) nvim config not linked"
	@[ -L ~/.config/tmux/tmux.conf ] && echo -e "  $(GREEN)✓$(NC) tmux config linked" || echo -e "  $(RED)✗$(NC) tmux config not linked"

# ╭──────────────────────────────────────────────────────────╮
# │                    Homebrew Targets                      │
# ╰──────────────────────────────────────────────────────────╯

brew-backup: ## Backup current Homebrew packages to Brewfile
	@echo -e "$(BLUE)Backing up Homebrew packages...$(NC)"
	@brew bundle dump --force --file=packages/Brewfile.backup
	@echo -e "$(GREEN)✓ Brewfile backed up to packages/Brewfile.backup$(NC)"

brew-restore: ## Install packages from Brewfile
	@echo -e "$(BLUE)Installing packages from Brewfile...$(NC)"
	@brew bundle --file=packages/Brewfile
	@echo -e "$(GREEN)✓ All packages installed$(NC)"

brew-clean: ## Clean up Homebrew (remove old versions)
	@echo -e "$(BLUE)Cleaning up Homebrew...$(NC)"
	@brew cleanup -s
	@brew doctor
	@brew missing
	@echo -e "$(GREEN)✓ Homebrew cleaned$(NC)"

# ╭──────────────────────────────────────────────────────────╮
# │                    Utility Targets                       │
# ╰──────────────────────────────────────────────────────────╯

clean: ## Clean backup files and caches
	@echo -e "$(YELLOW)Cleaning backups older than 30 days...$(NC)"
	@find $(BACKUP_DIR) -maxdepth 1 -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
	@echo -e "$(YELLOW)Cleaning Neovim cache...$(NC)"
	@rm -rf ~/.local/share/nvim/swap 2>/dev/null || true
	@rm -rf ~/.cache/nvim 2>/dev/null || true
	@echo -e "$(YELLOW)Cleaning tmux resurrect files...$(NC)"
	@rm -rf ~/.tmux/resurrect/*.txt 2>/dev/null || true
	@echo -e "$(GREEN)✓ Cleanup complete$(NC)"

link: ## Re-create all symlinks
	@echo -e "$(BLUE)Re-creating symlinks...$(NC)"
	@./install.sh --links-only
	@echo -e "$(GREEN)✓ Symlinks created$(NC)"

edit: ## Open dotfiles in VS Code
	@code $(DOTFILES_DIR)

pull: ## Pull latest changes from git
	@echo -e "$(BLUE)Pulling latest changes...$(NC)"
	@git pull origin main
	@echo -e "$(GREEN)✓ Repository updated$(NC)"

push: ## Push local changes to git
	@echo -e "$(BLUE)Pushing changes...$(NC)"
	@git add -A
	@git commit -m "Update dotfiles - $(TIMESTAMP)" || true
	@git push origin main
	@echo -e "$(GREEN)✓ Changes pushed$(NC)"

# ╭──────────────────────────────────────────────────────────╮
# │                    Quick Setup Targets                   │
# ╰──────────────────────────────────────────────────────────╯

minimal: ## Minimal installation (shell + git only)
	@echo -e "$(BLUE)Installing minimal setup...$(NC)"
	@./install.sh --minimal

full: ## Full installation with all optional components
	@echo -e "$(BLUE)Installing full setup...$(NC)"
	@./install.sh --full

# ╭──────────────────────────────────────────────────────────╮
# │                     Hidden Targets                       │
# ╰──────────────────────────────────────────────────────────╯

.SILENT: help check doctor
