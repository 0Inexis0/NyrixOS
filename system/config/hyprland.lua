-- NyrixOS foundation with Waybar and the Quickshell control center.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.config({ input = { kb_layout = "de" } })
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")
    hl.exec_cmd("hyprctl setcursor Breeze_Light 24")
    hl.exec_cmd("nyrix-desktop")
    hl.exec_cmd("foot")
end)
-- User overrides are separate from shipped defaults and survive updates.
local shortcut_path = os.getenv("HOME") .. "/.config/nyrix/shortcuts.lua"
local shortcut_file = io.open(shortcut_path, "r")
if shortcut_file then
    shortcut_file:close()
    dofile(shortcut_path)
else
    dofile(os.getenv("HOME") .. "/.config/nyrix/shortcuts-default.lua")
end

-- Foot: rounded corners; background transparency is set by Foot, not text opacity.
hl.window_rule({
    name = "nyrix-terminal-corners",
    match = { class = "^foot$" },
    rounding = 16,
})

-- Settings is a normal movable window, not a layer-shell popup.
hl.window_rule({
    name = "nyrix-settings-window",
    match = { title = "^NyrixOS (Einstellungen|Settings)$" },
    float = true,
    rounding = 18,
})
