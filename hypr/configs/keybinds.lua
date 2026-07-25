---------------------
---- KEYBINDINGS ----
---------------------

-- Modules have their own scope, so define the programs used by binds here.
local mainMod     = "SUPER" -- "Windows" key as main modifier
local terminal    = "kitty"
local fileManager = "kitty -e yazi"
local menu        = "rofi -show drun"

-- Launching programs
hl.bind(mainMod .. " + slash",     hl.dsp.exec_cmd("~/repos/dotfiles/scripts/keybinds-help"))
hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C",         hl.dsp.window.close())
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Y",         hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + space",     hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("flatpak run app.zen_browser.zen"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("google-chrome"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("~/repos/dotfiles/scripts/cliphist-rofi-img"))
hl.bind(mainMod .. " + period",    hl.dsp.exec_cmd("~/repos/dotfiles/scripts/emoji-picker"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("kitty -e tmux"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("~/repos/dotfiles/scripts/scratchterm"))
hl.bind("ALT + SHIFT + 4",         hl.dsp.exec_cmd("~/.local/bin/hyprshot -m region"))
hl.bind(mainMod .. " + I",         hl.dsp.exec_cmd("/home/bpadair/repos/scripts/inbox.sh"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("/home/bpadair/repos/scripts/new-meeting.sh"))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("/home/bpadair/repos/scripts/wifi.sh"))
hl.bind(mainMod .. " + T",         hl.dsp.exec_cmd("/home/bpadair/repos/scripts/bluetooth.sh"))
hl.bind(mainMod .. " + PRINT",     hl.dsp.exec_cmd("/home/bpadair/.local/bin/hyprshot -m region --clipboard-only"))
hl.bind(mainMod .. " + CTRL + T",  hl.dsp.exec_cmd([[rofi -show theme -modi "theme:~/repos/dotfiles/scripts/theme-selector" -show-icons -theme-str 'window { width: 600px; } listview { lines: 3; columns: 2; } element { orientation: vertical; padding: 12px; } element-icon { size: 200px; horizontal-align: 0.5; } element-text { horizontal-align: 0.5; }' -p "Theme"]]))

-- Window management: move focus (vim keys)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                           { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                           { locked = true, repeating = true })

-- Media control (requires playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
