-- ═══════════════════════════════════════════════════════════════════════════
--  WezTerm Configuration
--  Modern, GPU-accelerated terminal with advanced features
-- ═══════════════════════════════════════════════════════════════════════════

local wezterm = require("wezterm")
local config = {}

-- Use config builder for newer versions
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Appearance                          │
-- ╰──────────────────────────────────────────────────────────╯

-- Color scheme (matches your Tokyo Night theme)
config.color_scheme = "Tokyo Night"

-- Font configuration (matches your other configs)
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Hack Nerd Font",
	"Fira Code",
	"SF Mono",
	"Menlo",
})
config.font_size = 14.0
config.line_height = 1.2
config.cell_width = 1.0

-- Font features
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- Cursor
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- ╭──────────────────────────────────────────────────────────╮
-- │                    Window Settings                       │
-- ╰──────────────────────────────────────────────────────────╯

-- Window appearance
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_close_confirmation = "NeverPrompt"

-- Window padding
config.window_padding = {
	left = 20,
	right = 20,
	top = 20,
	bottom = 20,
}

-- Initial window size
config.initial_cols = 120
config.initial_rows = 30

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Tab Bar                             │
-- ╰──────────────────────────────────────────────────────────╯

-- Tab bar configuration
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 25

-- Tab bar colors (Tokyo Night theme)
config.colors = {
	tab_bar = {
		background = "#1a1b26",
		active_tab = {
			bg_color = "#7aa2f7",
			fg_color = "#1a1b26",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#414868",
			fg_color = "#a9b1d6",
		},
		inactive_tab_hover = {
			bg_color = "#565f89",
			fg_color = "#a9b1d6",
		},
		new_tab = {
			bg_color = "#1a1b26",
			fg_color = "#a9b1d6",
		},
		new_tab_hover = {
			bg_color = "#414868",
			fg_color = "#a9b1d6",
		},
	},
}

-- ╭──────────────────────────────────────────────────────────╮
-- │                    Shell & Programs                      │
-- ╰──────────────────────────────────────────────────────────╯

-- Default shell (matches your setup)
config.default_prog = { "/bin/zsh", "-l" }

-- Environment variables
config.set_environment_variables = {
	TERM = "xterm-256color",
}

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Key Bindings                        │
-- ╰──────────────────────────────────────────────────────────╯

local act = wezterm.action

config.keys = {
	-- ═══ Tab Management ═══
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CMD", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "[", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "CMD|SHIFT", action = act.ActivateTabRelative(1) },

	-- Tab numbers (CMD+1 through CMD+9)
	{ key = "1", mods = "CMD", action = act.ActivateTab(0) },
	{ key = "2", mods = "CMD", action = act.ActivateTab(1) },
	{ key = "3", mods = "CMD", action = act.ActivateTab(2) },
	{ key = "4", mods = "CMD", action = act.ActivateTab(3) },
	{ key = "5", mods = "CMD", action = act.ActivateTab(4) },
	{ key = "6", mods = "CMD", action = act.ActivateTab(5) },
	{ key = "7", mods = "CMD", action = act.ActivateTab(6) },
	{ key = "8", mods = "CMD", action = act.ActivateTab(7) },
	{ key = "9", mods = "CMD", action = act.ActivateTab(8) },

	-- ═══ Pane Management ═══
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "w", mods = "CMD|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },

	-- Pane navigation (integrates with tmux/vim navigation)
	{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },

	-- Pane resizing
	{ key = "h", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "j", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "k", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "l", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

	-- ═══ Copy/Paste ═══
	{ key = "c", mods = "CMD", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },

	-- ═══ Search ═══
	{ key = "f", mods = "CMD", action = act.Search("CurrentSelectionOrEmptyString") },

	-- ═══ Font Size ═══
	{ key = "=", mods = "CMD", action = act.IncreaseFontSize },
	{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
	{ key = "0", mods = "CMD", action = act.ResetFontSize },

	-- ═══ Scrollback ═══
	{ key = "k", mods = "CMD|ALT", action = act.ClearScrollback("ScrollbackAndViewport") },
	{ key = "u", mods = "CMD", action = act.ScrollByPage(-0.5) },
	{ key = "d", mods = "CMD|ALT", action = act.ScrollByPage(0.5) },

	-- ═══ Quick Launcher ═══
	{ key = "p", mods = "CMD", action = act.ActivateCommandPalette },

	-- ═══ Window Management ═══
	{ key = "n", mods = "CMD", action = act.SpawnWindow },
	{ key = "m", mods = "CMD", action = act.Hide },
	{ key = "q", mods = "CMD", action = act.QuitApplication },

	-- ═══ Debug ═══
	{ key = "L", mods = "CTRL|SHIFT", action = act.ShowDebugOverlay },
}

-- ╭──────────────────────────────────────────────────────────╮
-- │                    Mouse Bindings                        │
-- ╰──────────────────────────────────────────────────────────╯

config.mouse_bindings = {
	-- Right click opens context menu
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(act.PasteFrom("Clipboard"), pane)
			end
		end),
	},

	-- CMD+click to open links
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = act.OpenLinkAtMouseCursor,
	},
}

-- ╭──────────────────────────────────────────────────────────╮
-- │                    Performance                           │
-- ╰──────────────────────────────────────────────────────────╯

-- Performance tweaks
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.check_for_updates = false
config.enable_kitty_keyboard = false

-- GPU acceleration
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

-- ╭──────────────────────────────────────────────────────────╮
-- │                    SSH & Domains                         │
-- ╰──────────────────────────────────────────────────────────╯

-- SSH domain configuration (uncomment and configure as needed)
-- config.ssh_domains = {
--   {
--     name = 'my-server',
--     remote_address = 'server.example.com',
--     username = 'your-username',
--   },
-- }

-- ╭──────────────────────────────────────────────────────────╮
-- │                    Custom Functions                      │
-- ╰──────────────────────────────────────────────────────────╯

-- Format tab titles
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab.tab_title
	-- If no title is set, use the active pane's title
	if title and #title > 0 then
		title = title
	else
		title = tab.active_pane.title
	end

	-- Get the tab index (1-based)
	local tab_index = tab.tab_index + 1

	-- Truncate title if too long
	if #title > 15 then
		title = string.sub(title, 1, 12) .. "..."
	end

	-- Format: "1: title"
	return string.format(" %d: %s ", tab_index, title)
end)

-- Update right status with current working directory and git branch
wezterm.on("update-status", function(window, pane)
	local cwd = pane:get_current_working_dir()
	local cwd_name = ""
	if cwd then
		cwd_name = string.match(cwd.path, "[^/]+/?$") or cwd.path
	end

	-- Try to get git branch (simple approach)
	local success, git_branch = pcall(function()
		local handle = io.popen('cd "' .. (cwd and cwd.path or "") .. '" && git branch --show-current 2>/dev/null')
		if handle then
			local result = handle:read("*a")
			handle:close()
			return string.gsub(result or "", "\n", "")
		end
		return ""
	end)

	local git_info = ""
	if success and git_branch and #git_branch > 0 then
		git_info = " 🌱 " .. git_branch
	end

	window:set_right_status(cwd_name .. git_info .. " ")
end)

-- ╭──────────────────────────────────────────────────────────╮
-- │                    Platform Specific                     │
-- ╰──────────────────────────────────────────────────────────╯

-- macOS specific settings
if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
	config.send_composed_key_when_left_alt_is_pressed = false
	config.send_composed_key_when_right_alt_is_pressed = false

	-- Use macOS native fullscreen
	config.native_macos_fullscreen_mode = false
end

return config
