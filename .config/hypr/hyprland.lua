-- Midnight-PC Hyprland baseline.
-- KDE remains the default/fallback session; select Hyprland from SDDM to test.
--
-- Migrated from hyprland.conf (hyprlang) to Lua for Hyprland >= 0.55.
-- Behavior is intended to be identical to the .conf it replaces.

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "~/.local/bin/wofi-toggle"
local mainMod     = "SUPER"

--------------------------------------------------------------------------------
-- Monitors
--------------------------------------------------------------------------------

hl.monitor({ output = "DP-3", mode = "3840x2160@165", position = "0x0", scale = 1.5 })

-- Remember the portrait display layout when HDMI-A-1 is connected.
hl.monitor({
    output    = "HDMI-A-1",
    mode      = "1920x1080@60",
    position  = "2560x-780",
    scale     = 1,
    transform = 3,
})

--------------------------------------------------------------------------------
-- Environment
--------------------------------------------------------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_QPA_PLATFORMTHEME", "kde")

--------------------------------------------------------------------------------
-- Look and feel
--------------------------------------------------------------------------------

hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 8,
        border_size      = 2,
        col = {
            active_border   = "rgba(5a5a5fee)",
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding           = 16,
        active_opacity     = 0.78,
        inactive_opacity   = 0.68,
        fullscreen_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled           = true,
            size              = 12,
            passes            = 4,
            ignore_opacity    = true,
            new_optimizations = true,
            xray              = false,
            vibrancy          = 0.4,
            vibrancy_darkness = 0.15,
            contrast          = 0.9,
            brightness        = 0.8,
            noise             = 0.015,
            popups            = true,
            popups_ignorealpha = 0.2,
            special           = true,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        -- QD-OLED FreeSync Premium Pro. 1 = always, 2 = fullscreen only.
        -- 1 caused visible desktop flicker on this panel: idle desktop frame pacing
        -- swings the refresh rate and OLED brightness shifts with it. 2 keeps the
        -- desktop at fixed refresh and gives VRR only to fullscreen games.
        vrr                     = 2,
        force_default_wallpaper = 1,
        disable_hyprland_logo   = true,
    },

    xwayland = {
        -- 3840x2160 at scale 1.5 gives a 2560x1440 logical size, and XWayland hands
        -- the logical size to X11 clients. xrandr reported 2560x1440 as the *maximum*
        -- mode, not just the current one, so Steam and every Proton game were capped
        -- at 1440p and then upscaled by the compositor. This makes XWayland report
        -- native 3840x2160 instead.
        --
        -- Cost: X11 apps are no longer scaled by the compositor, so their UI renders
        -- small. Steam needs -forcedesktopscaling 1.5. Wayland-native apps are
        -- unaffected. Games launched through gamescope bypass this entirely.
        force_zero_scaling = true,
    },

    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0.0,
    },
})

--------------------------------------------------------------------------------
-- Animations
--------------------------------------------------------------------------------

hl.curve("smooth", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "smooth", style = "fade" })

--------------------------------------------------------------------------------
-- Layer rules
-- wofi is a layer-shell surface, not a window. window rules do not apply.
--------------------------------------------------------------------------------

hl.layer_rule({
    name         = "wofi-chrome",
    match        = { namespace = "wofi" },
    blur         = true,
    ignore_alpha = 0.05,
    animation    = "popin",
    dim_around   = true,
})

-- The bar's namespace is dms:bar, not waybar. The old waybar rule carried over
-- from the .conf and matched nothing, so the bar never got its blur.
-- xray = true is what DMS's own generated layout.lua asks for: blur samples the
-- wallpaper only, ignoring windows scrolling underneath. Drop it if you'd rather
-- the bar blur whatever is behind it.
hl.layer_rule({
    name         = "dms-bar-chrome",
    match        = { namespace = "^dms:bar$" },
    blur         = true,
    ignore_alpha = 0.05,
    xray         = true,
})

--------------------------------------------------------------------------------
-- Window rules
--
-- Games. Steam launches most titles borderless, which Hyprland does not count
-- as fullscreen: solitary and direct scanout stay blocked, DMS draws over the
-- game, and linux-wallpaperengine's --fullscreen-pause-only-active never fires.
-- Real fullscreen fixes all four. fullscreen_opacity = 1.0 above then makes the
-- window opaque, which also stops blur running behind it.
--------------------------------------------------------------------------------

-- From DMS's generated windowrules.lua: its own panels/dialogs want to float.
hl.window_rule({
    name  = "dms-floating-windows",
    match = { class = "^com.danklinux.dms$" },
    float = true,
})

hl.window_rule({
    name  = "games-fullscreen",
    -- long-bracket string: keeps the regex's \d literal, Lua does not process escapes here
    match = { class = [[^(steam_app_\d+|gamescope|cs2|hl2_linux|pcsx2-qt|rpcs3|dolphin-emu|retroarch|duckstation-qt|xemu|cemu|Ryujinx|yuzu|suyu)$]] },
    fullscreen = true,
})

--------------------------------------------------------------------------------
-- Binds
--
-- HE68 Mag is 65%: no Print Screen, no F-row, no media keys.
-- Stay in Windows mode (physical Win/Mac switch, or Fn+W). Mac mode makes Super
-- arrive as Alt and every bind below goes dead.
--------------------------------------------------------------------------------

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind("ALT + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- Theming / gaming mode
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/.local/bin/theme-menu"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("~/.local/bin/theme-cycle next"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("~/.local/bin/theme-cycle prev"))
hl.bind(mainMod .. " + apostrophe", hl.dsp.exec_cmd("~/.local/bin/theme-mode auto"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("~/.local/bin/gaming-mode toggle"))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("~/.local/bin/session-switch menu"))

-- Screenshots
-- P = picture. The HE68 has no Print key; keep Print anyway in case Fn is remapped.
local shot_region = [[grim -g "$(slurp)" "$HOME/Pictures/Screenshot_$(date +%Y%m%d_%H%M%S).png"]]
local shot_full   = [[grim "$HOME/Pictures/Screenshot_$(date +%Y%m%d_%H%M%S).png"]]

hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(shot_region))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(shot_full))
hl.bind("Print", hl.dsp.exec_cmd(shot_full))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(shot_region))

-- Audio (bindel -> repeating + locked)
hl.bind(mainMod .. " + equal", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind(mainMod .. " + minus", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })

-- Focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Workspaces 1-9 on their own key, 10 on 0
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Special workspace
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse move/resize (bindm)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------------------------------------------------------
-- Autostart
--------------------------------------------------------------------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("playerctld")
    hl.exec_cmd("dms run")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE GTK_THEME QT_QPA_PLATFORMTHEME")
    hl.exec_cmd("systemctl --user restart gaming-mode-watch.service")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface clock-format 12h")
    hl.exec_cmd("~/.local/bin/hypr-theme-apply")
end)

-- Was `exec =` in the .conf: re-runs on every config reload as well as at start.
hl.on("config.reloaded", function()
    hl.exec_cmd("~/.local/bin/hypr-theme-apply")
end)
