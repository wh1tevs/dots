local w = require("wezterm")
local c = w.config_builder()

local is_windows = os.getenv("OS") == "Windows_NT"

c.front_end = "WebGpu"

c.show_new_tab_button_in_tab_bar = false
c.color_scheme = "tokyonight"
c.window_padding = { top = 0, right = 0, bottom = 0, left = 0 }
c.font = w.font_with_fallback({ "CaskaydiaMono Nerd Font", "Cascadia Code Mono", "monospace" })
c.freetype_load_target = "Light"
c.use_fancy_tab_bar = false
c.tab_max_width = 255

if is_windows then
	c.default_prog = { "pwsh.exe", "-nologo" }
end

c.unix_domains = {
	{ name = "unix" },
}

c.wsl_domains = w.default_wsl_domains()
c.default_gui_startup_args = { "connect", "unix" }

local function update_right_status(window)
	local mode = window:active_key_table()
	if mode then
		mode = "mode: " .. mode
	end

	window:set_right_status(mode or "")
end

local function update_left_status(window)
	local workspace = window:active_workspace()
	if workspace then
		workspace = workspace .. " "
	end
	window:set_left_status(workspace)
end

w.on("update-status", update_right_status)
w.on("update-status", update_left_status)
c.status_update_interval = 1000

w.on("format-tab-title", function(tab)
	local title = tab.tab_title
	title = (title and #title > 0) and title or tab.active_pane.title

	local domain = tab.active_pane.domain_name

	return (" %d: %s - %s "):format(tab.tab_index + 1, title, domain)
end)

-- keys
local LEADER_KEY = "b"

local reanem_workspace_action = w.action.PromptInputLine({
	description = "Rename workspace",
	action = w.action_callback(function(window, _, line)
		if not line then
			return
		end
		w.mux.rename_workspace(window:active_workspace(), line)
	end),
})

local rename_tab_action = w.action.PromptInputLine({
	description = "Rename tab",
	action = w.action_callback(function(window, _, line)
		if not line then
			return
		end
		window:active_tab():set_title(line)
	end),
})

c.disable_default_key_bindings = true
c.leader = { key = LEADER_KEY, mods = "CTRL" }
c.keys = {
	{ key = LEADER_KEY, mods = "LEADER|CTRL", action = w.action.SendKey(c.leader) },
	{ key = ":", mods = "LEADER|SHIFT", action = w.action.ActivateCommandPalette },
	{ key = "s", mods = "LEADER", action = w.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{ key = "c", mods = "LEADER|SHIFT", action = w.action.ShowLauncherArgs({ flags = "FUZZY|DOMAINS" }) },
	{ key = "$", mods = "LEADER|SHIFT", action = reanem_workspace_action },
	--resize & copy mode
	{ key = "r", mods = "LEADER|SHIFT", action = w.action.ActivateKeyTable({ name = "resize", one_shot = false }) },
	{ key = "[", mods = "LEADER", action = w.action.ActivateCopyMode },
	-- tabs
	{ key = "w", mods = "LEADER", action = w.action.ShowTabNavigator },
	{ key = "c", mods = "LEADER", action = w.action.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = w.action.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = w.action.ActivateTabRelative(-1) },
	{ key = ",", mods = "LEADER", action = rename_tab_action },
	{ key = "&", mods = "LEADER|SHIFT", action = w.action.CloseCurrentTab({ confirm = true }) },
	-- panes
	{ key = "%", mods = "LEADER|SHIFT", action = w.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = '"', mods = "LEADER|SHIFT", action = w.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "!", mods = "LEADER|SHIFT", action = w.action.PaneSelect({ mode = "MoveToNewTab" }) },
	{ key = "z", mods = "LEADER", action = w.action.TogglePaneZoomState },
	{ key = "x", mods = "LEADER", action = w.action.CloseCurrentPane({ confirm = true }) },
}

for i = 1, 9 do
	table.insert(c.keys, { key = tostring(i), mods = "LEADER", action = w.action.ActivateTab(i - 1) })
end

c.key_tables = {
	resize = {
		{ key = "Escape", action = w.action.PopKeyTable },
		{ key = "[", mods = "CTRL", action = w.action.PopKeyTable },
	},
}

for key, dir in pairs({ h = "Left", j = "Down", k = "Up", l = "Right" }) do
	table.insert(c.keys, { key = key, mods = "LEADER", action = w.action.ActivatePaneDirection(dir) })
	table.insert(c.key_tables.resize, { key = key, action = w.action.AdjustPaneSize({ dir, 1 }) })
end

return c
