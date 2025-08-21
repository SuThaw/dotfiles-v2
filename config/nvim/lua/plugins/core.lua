-- ═══════════════════════════════════════════════════════════════════════════
--  Core Plugins Configuration
-- ═══════════════════════════════════════════════════════════════════════════

return {
	-- ╭──────────────────────────────────────────────────────────╮
	-- │              CRITICAL: tmux Integration                  │
	-- ╰──────────────────────────────────────────────────────────╯
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Navigate Left" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Navigate Down" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Navigate Up" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Navigate Right" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Navigate Previous" },
		},
	},

	-- ╭──────────────────────────────────────────────────────────╮
	-- │                      Theme                               │
	-- ╰──────────────────────────────────────────────────────────╯
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night",
			transparent = false,
			terminal_colors = true,
		},
	},

	-- Configure LazyVim to use tokyonight
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight",
		},
	},

	-- ╭──────────────────────────────────────────────────────────╮
	-- │                    UI Improvements                       │
	-- ╰──────────────────────────────────────────────────────────╯

	-- Better notifications
	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 3000,
			render = "minimal",
			stages = "fade",
		},
	},

	-- Disable default tab bar (we use tmux)
	{ "akinsho/bufferline.nvim", enabled = false },

	-- ╭──────────────────────────────────────────────────────────╮
	-- │                  Editor Enhancements                     │
	-- ╰──────────────────────────────────────────────────────────╯

	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},

	-- Better surround
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},

	-- Comment
	{
		"numToStr/Comment.nvim",
		opts = {},
		lazy = false,
	},

	-- Todo comments
	{
		"folke/todo-comments.nvim",
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = { "BufReadPost", "BufNewFile" },
		config = true,
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next todo comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous todo comment",
			},
			{ "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
			{ "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
			{ "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
		},
	},

	-- ╭──────────────────────────────────────────────────────────╮
	-- │                     Git Integration                      │
	-- ╰──────────────────────────────────────────────────────────╯

	-- Git signs in the gutter
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
		},
	},
} -- This closing brace closes the return statement
