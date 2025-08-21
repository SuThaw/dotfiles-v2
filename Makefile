# Unified Dotfiles Makefile
# Simple command interface for dotfiles management

.PHONY: help install test

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[0;33m
NC := \033[0m

# Default
.DEFAULT_GOAL := help

help: ## Show this help
	@echo "$(BLUE)Unified Dotfiles$(NC)"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

install: ## Run installer
	@echo "$(BLUE)Starting installation...$(NC)"
	@chmod +x install.sh
	@./install.sh

test: ## Test installation in dry-run mode
	@echo "$(YELLOW)Running in test mode...$(NC)"
	@chmod +x install.sh
	@./install.sh --dry-run

clean: ## Clean backup files
	@echo "$(YELLOW)Cleaning backups...$(NC)"
	@rm -rf ~/.dotfiles_backup/*
	@echo "$(GREEN)Cleaned$(NC)"

check: ## Check requirements
	@echo "$(BLUE)Checking requirements...$(NC)"
	@command -v git >/dev/null && echo "$(GREEN)✓$(NC) git" || echo "$(RED)✗$(NC) git"
	@command -v curl >/dev/null && echo "$(GREEN)✓$(NC) curl" || echo "$(RED)✗$(NC) curl"
	@command -v zsh >/dev/null && echo "$(GREEN)✓$(NC) zsh" || echo "$(RED)✗$(NC) zsh"
	@command -v brew >/dev/null && echo "$(GREEN)✓$(NC) brew" || echo "$(RED)✗$(NC) brew (optional)"

uninstall: ## Remove dotfiles symlinks
	@echo "$(RED)Starting uninstallation...$(NC)"
	@chmod +x uninstall.sh
	@./uninstall.sh

backup: ## Create backup of current configs
	@echo "$(BLUE)Creating backup...$(NC)"
	@./uninstall.sh --backup-only
	@echo "$(GREEN)Backup created$(NC)"
