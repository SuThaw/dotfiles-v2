-- ═══════════════════════════════════════════════════════════════════════════
--  Neovim Configuration with LazyVim and tmux Integration
-- ═══════════════════════════════════════════════════════════════════════════

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- Import LazyVim plugins and configs
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },

		-- Import any of the extras modules
		{ import = "lazyvim.plugins.extras.lang.typescript" },
		{ import = "lazyvim.plugins.extras.lang.json" },
		{ import = "lazyvim.plugins.extras.linting.eslint" },
		{ import = "lazyvim.plugins.extras.formatting.prettier" },

		-- Import your custom plugins
		{ import = "plugins" },
	},
	defaults = {
		lazy = false,
		version = false,
	},
	install = { colorscheme = { "tokyonight", "habamax" } },
	checker = { enabled = true },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
