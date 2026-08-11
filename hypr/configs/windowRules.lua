--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Ignore maximize requests from apps
hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Scratchpad terminal
hl.window_rule({
    name  = "scratchpad-term",
    match = { class = "^kitty-scratchpad$" },
    float = true,
    size  = { "monitor_w * 0.75", "monitor_h * 0.4" },
})

-- File picker (yazi via xdg-desktop-portal-termfilechooser)
hl.window_rule({
    name   = "filepicker",
    match  = { class = "^filepicker$" },
    float  = true,
    size   = { "monitor_w * 0.75", "monitor_h * 0.75" },
    center = true,
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
    },
    no_focus = true,
})
