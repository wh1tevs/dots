local w = require("wezterm")
local c = w.config_builder()

c.show_new_tab_button_in_tab_bar = false
c.color_scheme = "tokyonight"
c.window_padding = { top = 0, right = 0, bottom = 0, left = 0 }
c.font = w.font("CaskaydiaMono Nerd Font")
c.use_fancy_tab_bar = false
c.tab_max_width = 255

if w.target_triple:match("windows") then
	c.default_prog = { "pwsh.exe", "-nologo" }
end

function update_right_status(window, pane)
	local name = window:active_key_table()
	if name then
		name = "mode: " .. name
	end
	window:set_right_status(name or "")
end

function update_left_status(window, pane)
	local workspace = window:active_workspace()
	if workspace then
		workspace = workspace .. " "
	end
	window:set_left_status(workspace)
end

w.on("update-status", update_right_status)
w.on("update-status", update_left_status)

c.leader = { key = "b", mods = "CTRL" }
c.keys = {
	{ key = "b", mods = "LEADER|CTRL", action = w.action.SendKey({ key = "b", mods = "CTRL" }) },
	{ key = "s", mods = "LEADER", action = w.action.ShowLauncherArgs({ flags = "DOMAINS" }) },
	{ key = "w", mods = "LEADER", action = w.action.ShowLauncherArgs({ flags = "TABS" }) },
	{ key = "w", mods = "LEADER|SHIFT", action = w.action.ShowLauncherArgs({ flags = "WORKSPACES" }) },
	{
		key = "r",
		mods = "LEADER|SHIFT",
		action = w.action.ActivateKeyTable({ name = "resize", one_shot = false }),
	},
	{ key = "[", mods = "LEADER", action = w.action.ActivateCopyMode },
	{ key = "c", mods = "LEADER", action = w.action.SpawnTab("DefaultDomain") },
	{ key = "&", mods = "LEADER|SHIFT", action = w.action.CloseCurrentTab({ confirm = true }) },
	{ key = "%", mods = "LEADER|SHIFT", action = w.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = '"', mods = "LEADER|SHIFT", action = w.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "x", mods = "LEADER", action = w.action.CloseCurrentPane({ confirm = true }) },
	{ key = "n", mods = "LEADER", action = w.action.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = w.action.ActivateTabRelative(-1) },
	{ key = "z", mods = "LEADER", action = w.action.TogglePaneZoomState },

	{
		key = "$",
		mods = "LEADER|SHIFT",
		action = w.action.PromptInputLine({
			description = "Rename workspace",
			action = w.action_callback(function(window, pane, line)
				if not line then
					return
				end

				w.mux.rename_workspace(window:active_workspace(), line)
			end),
		}),
	},
	{
		key = ",",
		mods = "LEADER",
		action = w.action.PromptInputLine({
			description = "Rename tab",
			action = w.action_callback(function(window, pane, line)
				if not line then
					return
				end

				window:active_tab():set_title(line)
			end),
		}),
	},
}

for i = 1, 9 do
	table.insert(c.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = w.action.ActivateTab(i - 1),
	})
end

local keys_dir = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

for key, dir in pairs(keys_dir) do
	table.insert(c.keys, {
		key = key,
		mods = "LEADER",
		action = w.action.ActivatePaneDirection(dir),
	})
end

if not c.key_tables then
	c.key_tables = {}
end

c.key_tables.resize = {
	{ key = "Escape", action = "PopKeyTable" },
	{ key = "[", mods = "CTRL", action = "PopKeyTable" },
}

for key, dir in pairs(keys_dir) do
	table.insert(c.key_tables.resize, {
		key = key,
		action = w.action.AdjustPaneSize({ dir, 1 }),
	})
end

return c
