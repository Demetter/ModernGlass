-- ModernGlass (https://github.com/Demetter/ModernGlass)
-- A Liquid Glass interface for mpv, built on ModernZ v0.3.3 by Samillion
-- (https://github.com/Samillion/ModernZ)
--
-- This script is a derivative of the original mpv-osc-modern by maoiscat
-- and subsequent forks:
--   * cyl0/ModernX
--   * dexeonify/ModernX
--
-- It is based on the official osc.lua from mpv, licensed under the
-- GNU Lesser General Public License v2.1 (LGPLv2.1).
-- Full license: https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html

local assdraw = require "mp.assdraw"
local msg = require "mp.msg"
local opt = require "mp.options"
local utils = require "mp.utils"
mp.set_property("osc", "no")

-- Parameters
-- default user option values
-- do not touch, change them in modernz.conf
local user_opts = {
    -- Language and display
    language = "default",                  -- set language
    layout = "default",                    -- set layout: default (floating glass panel), classic, compact, mini, seekbar
    icon_theme = "fluent",                 -- set icon theme. accepts "fluent" or "material" (icons are built in, no font needed)
    icon_style = "mixed",                  -- "mixed", "filled", "outline"
    font = "Inter",                        -- UI font (Inter ships in the fonts folder)

    idlescreen = true,                     -- show mpv logo when idle
    window_top_bar = "auto",               -- show OSC window top bar: "auto", "yes", or "no" (borderless/fullscreen)
    showwindowed = true,                   -- show OSC when windowed
    showfullscreen = true,                 -- show OSC when fullscreen
    showonselect = false,                  -- show OSC when a select menu is open
    showonpause = true,                    -- show OSC when paused
    keeponpause = "no",                    -- keep OSC visible while paused: "no", "bottombar", "both"
    greenandgrumpy = false,                -- disable Santa hat in December

    -- OSC behaviour and scaling
    hidetimeout = 1500,                    -- time (in ms) before OSC hides if no mouse movement
    keep_with_cursor = true,               -- keep OSC visible while cursor hovers over bottom or top bar
    fadeduration = 200,                    -- fade-out duration (in ms), set to 0 for no fade
    fadein = true,                         -- whether to enable fade-in effect
    minmousemove = 0,                      -- minimum mouse movement (in pixels) required to show OSC
    deadzonesize = 0.75,                   -- size of the deadzone (0.0 = whole screen, 1.0 = no deadzone)
    deadzone_hide = "instant",             -- hide behavior when cursor enters deadzone or leaves window: "instant" or "timeout"
    osc_on_seek = true,                    -- show OSC when seeking
    osc_on_start = "both",                 -- show OSC on start of every file ("no", "bottom", "top", "both")
    mouse_seek_pause = true,               -- pause video while seeking with mouse move (on button hold)
    force_seek_tooltip = false,            -- force show seekbar tooltip on mouse drag, even if not hovering seekbar

    vidscale = "auto",                     -- scale osc with the video
    scalewindowed = 1.0,                   -- osc scale factor when windowed
    scalefullscreen = 1.0,                 -- osc scale factor when fullscreen
    vidscale_max = 1.35,                   -- size cap when scaling with the window, in screen pixels per unit times the system display scaling, so the controls are the same size on every display; 0 = no limit

    -- Elements display
    show_title = true,                     -- show title in the OSC
    title = "${media-title}",              -- title: "${media-title}" or "${filename}"
    title_font_size = 17,                  -- title font size
    truncate_title = false,                -- truncate title with ellipsis if it overflows
    chapter_title_font_size = 14,          -- chapter title font size

    cache_info = false,                    -- show cached time information
    cache_info_speed = false,              -- show cache speed per second
    cache_info_font_size = 12,             -- font size of the cache information

    show_chapter_title = true,             -- show chapter title
    chapter_above_title = false,           -- show chapter above title
    chapter_fmt = "%s",                    -- format for chapter display on seekbar hover (set to "no" to disable)

    timecurrent = true,                    -- show current time instead of remaining time
    timems = false,                        -- show timecodes with milliseconds
    unicodeminus = false,                  -- use the Unicode minus sign in remaining time
    time_format = "dynamic",               -- "dynamic" or "fixed". dynamic shows MM:SS when possible, fixed always shows HH:MM:SS
    time_font_size = 14,                   -- font size of the time display

    tooltip_font_size = 13,                -- tooltips font size
    speed_font_size = 15,                  -- speed button font size

    -- Title bar settings
    show_window_title = false,             -- show window title in borderless/fullscreen mode
    window_title_font_size = 26,           -- window title font size
    window_controls = true,                -- show window controls (close, minimize, maximize) in borderless/fullscreen
    windowcontrols_independent = true,     -- show window controls (top bar) and bottom bar independently on hover

    -- Subtitle and OSD display settings
    sub_margins = true,                    -- raise subtitles above the OSC when shown
    osd_margins = false,                   -- adjust OSD to not overlap with OSC
    dynamic_margins = true,                -- update margins dynamically with OSC visibility

    -- Buttons display and functionality
    subtitles_button = true,               -- show the subtitles menu button
    audio_tracks_button = true,            -- show the audio tracks menu button
    jump_buttons = true,                   -- show the jump backward and forward buttons
    jump_amount = 10,                      -- change the jump amount in seconds
    jump_more_amount = 60,                 -- change the jump amount in seconds on right click
    jump_icon_number = true,               -- show different icon when jump_amount is set to 5, 10, or 30
    jump_mode = "relative",                -- seek mode for jump buttons: "relative" or "exact"
    jump_softrepeat = true,                -- enable continuous jumping when holding down seek buttons
    chapter_skip_buttons = false,          -- show the chapter skip backward and forward buttons
    track_nextprev_buttons = true,         -- show next/previous playlist track buttons

    volume_control = true,                 -- show mute button and volume slider
    volume_control_type = "linear",        -- volume scale type: "linear" or "logarithmic"
    volumebar_unmute_on_click = false,     -- unmute audio when adjusting volume slider with left click
    playlist_button = true,                -- show playlist button
    hide_empty_playlist_button = false,    -- hide playlist button when no playlist exists
    gray_empty_playlist_button = false,    -- gray out the playlist button when no playlist exists

    fullscreen_button = true,              -- show fullscreen toggle button
    info_button = true,                    -- show info button
    ontop_button = true,                   -- show window on top button
    ontop_in_topbar = false,               -- move ontop button to top bar when ontop is active
    screenshot_button = true,              -- show screenshot button

    download_button = true,                -- show download button on web videos (requires yt-dlp and ffmpeg)
    download_path = "~~desktop/mpv",       -- default download directory for videos (https://mpv.io/manual/master/#paths)

    loop_button = true,                    -- show file loop button
    shuffle_button = false,                -- show shuffle button
    speed_button = true,                   -- show speed control button

    buttons_always_active = "none",        -- force buttons to always be active. can add: playlist_prev, playlist_next

    playpause_size = 28,                   -- icon size for the play/pause button
    midbuttons_size = 24,                  -- icon size for the middle buttons
    sidebuttons_size = 24,                 -- icon size for the side buttons

    zoom_control = true,                   -- show zoom controls in image viewer mode
    zoom_in_max = 4,                       -- maximum zoom in value
    zoom_out_min = -1,                     -- minimum zoom out value

    -- Colors and style
    osc_color = "#000000",                 -- accent color of the OSC and title bar
    window_title_color = "#FFFFFF",        -- color of the title in borderless/fullscreen mode
    window_controls_color = "#FFFFFF",     -- color of the window controls (close, minimize, maximize) in borderless/fullscreen mode
    windowcontrols_close_hover = "#F45C5B", -- color of close window control on hover
    windowcontrols_max_hover = "#F8BC3A",  -- color of maximize window controls on hover
    windowcontrols_min_hover = "#43CB44",  -- color of minimize window controls on hover
    title_color = "#FFFFFF",               -- color of the title
    cache_info_color = "#FFFFFF",          -- color of the cache information
    seekbar_cache_color = "#B1B1B1",       -- color of the cache ranges on the seekbar
    seekbarfg_color = "#FFFFFF",           -- color of the seekbar progress
    seekbarbg_color = "#FFFFFF",           -- color of the remaining seekbar
    seek_handle_color = "#FFFFFF",         -- color of the seekbar handle
    seek_handle_border_color = "disable",  -- inner border color drawn inside the seekbar handle (set to "disable" to disable)
    volumebar_match_seek_color = false,    -- match volume bar color with seekbar color (ignores side_buttons_color)
    time_color = "#FFFFFF",                -- color of the timestamps (below seekbar)
    chapter_title_color = "#FFFFFF",       -- color of the chapter title
    side_buttons_color = "#FFFFFF",        -- color of the side buttons (audio, subtitles, playlist, etc.)
    middle_buttons_color = "#FFFFFF",      -- color of the middle buttons (skip, jump, chapter, etc.)
    playpause_color = "#FFFFFF",           -- color of the play/pause button
    held_element_color = "#999999",        -- color of the element when held down (pressed)
    hover_effect_color = "#FFFFFF",        -- color of a hovered button when hover_effect includes "color" (and of the "box" highlight)
    thumbnail_box_color = "#101114",       -- color of the background for thumbnail box
    thumbnail_box_outline = "#FFFFFF",     -- color of the border outline for thumbnail box
    nibble_color = "#FF8232",              -- color of chapter nibbles on the seekbar
    nibble_current_color = "#FFFFFF",      -- color of the current chapter nibble on the seekbar
    ab_loop_color = "#2596be",             -- color of the A/B loop range on the seekbar

    osc_fade_strength = 100,               -- strength of the OSC background fade (0 to disable)
    fade_blur_strength = 100,              -- blur strength for the OSC alpha fade. caution: high values can take a lot of CPU time to render
    fade_transparency_strength = 0,        -- use with "fade_blur_strength=0" to create a transparency box
    window_fade_strength = 100,            -- strength of the window title bar fade (0 to disable)
    window_fade_blur_strength = 100,       -- blur strength for the window title bar. caution: high values can take a lot of CPU time to render
    window_fade_transparency_strength = 0, -- use with "window_fade_blur_strength=0" to create a transparency box
    thumbnail_box_padding = 2,             -- thumbnail box padding around the image
    thumbnail_box_radius = 6,              -- round corner radius for thumbnail box border (0 to disable)
    thumbnail_box_outline_size = 1,        -- thumbnail box border outline size (thickness)

    -- Button interaction settings
    hover_effect = "box",                  -- active button hover effects: "glow", "size", "color", "box"; can use multiple separated by commas
    button_hover_size = 115,               -- relative size of a hovered button if "size" effect is active
    button_held_size = 100,                -- relative size of a button when held/pressed. below 100 shrinks button when held down
    button_held_box_alpha = 18,            -- alpha of the hover background box when a button is held down
    button_glow_amount = 5,                -- glow intensity when "glow" hover effect is active
    slider_hover_size = 100,               -- relative size of a hovered slider handle
    tooltip_hints = true,                  -- enable tooltips for most buttons. seek and volume tooltips are always enabled

    -- Progress bar settings
    seek_handle_size = 0.8,                -- size ratio of the seek handle (range: 0 ~ 1)
    seek_handle_border_size = 0.42,        -- border thickness as a fraction of the handle radius
    seek_handle_border_hover_size = 0.31,  -- border thickness when handle is hovered (set equal to seek_handle_border_size to disable)
    seekbar_height = "large",              -- seekbar height preset: "small", "medium", "large", "xlarge"
    seekrange = true,                      -- show seek range overlay
    seekrangealpha = 150,                  -- transparency of the seek range
    livemarkers = true,                    -- update chapter markers on the seekbar when duration changes
    seekbarkeyframes = true,               -- use keyframes when dragging the seekbar
    slider_rounded_corners = true,         -- rounded corners seekbar slider

    nibbles_style = "gap",                 -- chapter nibble style: "gap", "triangle", "bar", or "single-bar"
    nibbles_top = true,                    -- top chapter nibbles above seekbar
    nibbles_bottom = true,                 -- bottom chapter nibbles below seekbar

    automatickeyframemode = true,          -- automatically set keyframes for the seekbar based on video length
    automatickeyframelimit = 600,          -- videos longer than this (in seconds) will have keyframes on the seekbar

    persistent_progress = false,           -- always show a small progress line at the bottom of the screen
    persistent_progress_height = 17,       -- height of the persistent progress bar
    persistent_buffer = false,             -- show cached buffer status in the persistent progress line

    -- Miscellaneous settings
    visibility = "auto",                   -- only used at init to set visibility_mode(...)
    visibility_modes = "never_auto_always",-- visibility modes to cycle through
    tick_delay = 1 / 60,                   -- minimum interval between OSC redraws (in seconds)
    tick_delay_follow_display_fps = true, -- use display FPS as the minimum redraw interval

    -- Elements Position
    -- Useful when adjusting font size or type
    title_offset = 20,                     -- title vertical offset relative to seekbar
    title_with_chapter_offset = 5,         -- title vertical offset if a chapter title is below it
    chapter_title_offset = 18,             -- chapter title vertical offset relative to seekbar
    chapter_above_title_offset = 3,        -- chapter offset when shown above title
    time_codes_offset = 0,                 -- time codes vertical offset relative to seekbar
    tooltip_height_offset = 5,             -- tooltip height position offset
    portrait_window_trigger = 950,         -- portrait window width trigger to move some elements
    hide_volume_bar_trigger = 1150,        -- hide volume bar trigger window width
    osc_height = 60,                       -- osc height

    -- glass look (layout=default panel, menus, tooltips, thumbnails, window controls)
    glass_color = "#17181C",               -- tint of glass surfaces
    glass_opacity = 30,                    -- tint strength in percent, from clear (0) to solid (100); at least 62 when the video behind can't be frosted
    glass_border_opacity = 14,             -- opacity of the hairline light edge around glass surfaces in percent
    glass_shadow = true,                   -- soft shadow under glass surfaces
    glass_blur = true,                     -- blur the video behind glass surfaces (needs vo=gpu-next)
    glass_refraction = true,               -- distort the video near the edges of glass surfaces and add a highlight along the top edge (with glass_blur)
    glass_reduce_transparency = false,     -- frosty, nearly opaque glass
    glass_increase_contrast = false,       -- black glass with a visible border
    reduce_motion = false,                 -- no spring and scale animations (fades stay)
    panel_radius = 28,                     -- corner radius of the floating panel
    panel_margin = 20,                     -- distance between the floating panel and the window edges
    panel_max_width = 0,                   -- widest the floating panel gets (0 = always full width)
    muted_text_color = "#AEB7C4",          -- secondary text: duration, chapter title, menu details
    playlist_thumbnails = true,            -- small thumbnails beside the videos in the folder and playlist menus (made by thumbz)
    modern_menus = true,                   -- show track, playlist, chapter and audio output lists as ModernZ menus instead of mpv's select lists
    menu_max_items = 9,                    -- rows a menu shows before it scrolls

    -- Mouse commands
    -- customize the button function based on mouse action

    -- title mouse actions
    title_mbtn_left_command = "script-binding stats/display-page-5",
    title_mbtn_mid_command = "show-text ${path}",
    title_mbtn_right_command = "script-binding select/select-watch-history",

    -- chapter title mouse actions
    chapter_title_mbtn_left_command = "script-binding select/select-chapter",
    chapter_title_mbtn_right_command = "show-text ${chapter-list} 3000",

    -- seekbar wheel actions
    seekbar_wheel_up_command = "seek 10",
    seekbar_wheel_down_command = "seek -10",

    -- playlist button mouse actions
    playlist_mbtn_left_command = "script-binding select/select-playlist",
    playlist_mbtn_right_command = "script-binding select/menu",

    -- volume mouse actions
    vol_ctrl_mbtn_left_command = "no-osd cycle mute",
    vol_ctrl_mbtn_right_command = "script-binding select/select-audio-device",
    vol_ctrl_wheel_down_command = "osd-msg add volume -5",
    vol_ctrl_wheel_up_command = "osd-msg add volume 5",
    volumebar_wheel_down_command = "osd-msg add volume -5",
    volumebar_wheel_up_command = "osd-msg add volume 5",

    -- audio button mouse actions
    audio_track_mbtn_left_command = "script-binding select/select-aid",
    audio_track_mbtn_mid_command = "cycle audio down",
    audio_track_mbtn_right_command = "cycle audio",
    audio_track_wheel_down_command = "cycle audio",
    audio_track_wheel_up_command = "cycle audio down",

    -- subtitle button mouse actions
    sub_track_mbtn_left_command = "script-binding select/select-sid",
    sub_track_mbtn_mid_command = "cycle sub down",
    sub_track_mbtn_right_command = "cycle sub",
    sub_track_wheel_down_command = "cycle sub",
    sub_track_wheel_up_command = "cycle sub down",

    -- play/pause button mouse actions
    play_pause_mbtn_left_command = "cycle pause",
    play_pause_mbtn_mid_command = "cycle-values loop-playlist inf no",
    play_pause_mbtn_right_command = "cycle-values loop-file inf no",

    -- chapter skip buttons mouse actions
    chapter_prev_mbtn_left_command = "add chapter -1",
    chapter_prev_mbtn_mid_command = "show-text ${chapter-list} 3000",
    chapter_prev_mbtn_right_command = "script-binding select/select-chapter",

    chapter_next_mbtn_left_command = "add chapter 1",
    chapter_next_mbtn_mid_command = "show-text ${chapter-list} 3000",
    chapter_next_mbtn_right_command = "script-binding select/select-chapter",

    -- playlist skip buttons mouse actions
    playlist_prev_mbtn_left_command = "playlist-prev",
    playlist_prev_mbtn_mid_command = "show-text ${playlist} 3000",
    playlist_prev_mbtn_right_command = "script-binding select/select-playlist",

    playlist_next_mbtn_left_command = "playlist-next",
    playlist_next_mbtn_mid_command = "show-text ${playlist} 3000",
    playlist_next_mbtn_right_command = "script-binding select/select-playlist",

    -- fullscreen button mouse actions
    fullscreen_mbtn_left_command = "cycle fullscreen",
    fullscreen_mbtn_right_command = "cycle window-maximized",

    -- info button mouse actions
    info_mbtn_left_command = "script-binding stats/display-page-1-toggle",

    -- ontop (pin) button mouse actions
    ontop_mbtn_left_command = "osd-msg cycle ontop",

    -- screenshot button mouse actions
    screenshot_mbtn_left_command = "osd-msg screenshot video",

    -- loop file button mouse actions
    file_loop_mbtn_left_command = "osd-msg cycle-values loop-file inf no",
    file_loop_mbtn_right_command = "osd-msg cycle-values loop-playlist inf no",

    -- speed button mouse actions
    speed_mbtn_left_command = "osd-msg add speed 1",
    speed_mbtn_right_command = "osd-msg set speed 1",
    speed_wheel_down_command = "osd-msg add speed -0.25",
    speed_wheel_up_command = "osd-msg add speed 0.25",
}

local osc_param = {                  -- calculated by osc_init()
    playresy = 0,                    -- canvas size Y
    playresx = 0,                    -- canvas size X
    display_aspect = 1,
    unscaled_y = 0,
    osd_units_y = nil,               -- canvas height in mpv OSD units (for osd-margin-y)
    areas = {},
    video_margins = {
        l = 0, r = 0, t = 0, b = 0,  -- left/right/top/bottom
    },
}

-- icon outlines: Fluent UI System Icons (MIT) and Material Symbols (Apache-2.0),
-- converted from ModernZ's icon sources to ASS drawings on a 24x24 grid
local icon_glyphs = {
    ["download"] = "m 12 16 l 7 11 8.4 9.55 11 12.15 11 4 13 4 13 12.15 15.6 9.55 17 11 12 16 m 6 20 b 5.45 20 4.98 19.8 4.59 19.41 4.2 19.02 4 18.55 4 18 l 4 15 6 15 6 18 18 18 18 15 20 15 20 18 b 20 18.55 19.8 19.02 19.41 19.41 19.02 19.8 18.55 20 18 20 l 6 20",
    ["downloading"] = "m 10.98 21.95 b 9.71 21.82 8.53 21.46 7.44 20.89 6.35 20.31 5.4 19.58 4.6 18.69 3.8 17.8 3.17 16.78 2.71 15.62 2.25 14.47 2.02 13.26 2.02 11.97 2.02 9.39 2.88 7.15 4.59 5.26 6.3 3.37 8.43 2.28 11 2 l 11 4 b 8.98 4.28 7.32 5.18 6 6.69 4.68 8.2 4.03 9.96 4.03 11.97 4.03 13.99 4.68 15.75 6 17.26 7.32 18.77 8.98 19.67 10.98 19.95 l 10.98 21.95 m 11.98 17 l 6.95 11.95 8.38 10.52 10.98 13.12 10.98 7 12.98 7 12.98 13.12 15.55 10.55 16.98 12 11.98 17 m 12.98 21.95 l 12.98 19.95 b 13.69 19.85 14.38 19.66 15.04 19.38 15.7 19.09 16.31 18.73 16.88 18.3 l 18.32 19.75 b 17.54 20.37 16.7 20.86 15.8 21.24 14.9 21.61 13.96 21.85 12.98 21.95 m 16.93 5.65 b 16.34 5.22 15.72 4.86 15.06 4.57 14.4 4.29 13.72 4.1 13 4 l 13 2 b 13.98 2.1 14.93 2.34 15.83 2.71 16.73 3.09 17.56 3.58 18.32 4.2 l 16.93 5.65 m 19.73 18.3 l 18.32 16.88 b 18.76 16.31 19.11 15.7 19.38 15.04 19.64 14.38 19.83 13.69 19.93 12.97 l 21.98 12.97 b 21.84 13.96 21.59 14.9 21.23 15.81 20.86 16.72 20.36 17.55 19.73 18.3 m 19.93 10.97 b 19.83 10.26 19.64 9.57 19.38 8.91 19.11 8.25 18.76 7.64 18.32 7.07 l 19.73 5.65 b 20.36 6.4 20.87 7.23 21.25 8.14 21.63 9.05 21.88 9.99 21.98 10.97 l 19.93 10.97",
    ["fast_forward"] = "m 2.5 16.12 l 2.5 7.88 b 2.5 7.58 2.6 7.33 2.8 7.15 3 6.97 3.23 6.88 3.5 6.88 3.58 6.88 3.68 6.88 3.78 6.9 3.88 6.92 3.97 6.96 4.05 7.02 l 10.25 11.17 b 10.4 11.27 10.51 11.4 10.59 11.54 10.66 11.68 10.7 11.83 10.7 12 10.7 12.17 10.66 12.32 10.59 12.46 10.51 12.6 10.4 12.72 10.25 12.82 l 4.05 16.98 b 3.97 17.04 3.88 17.08 3.78 17.1 3.68 17.12 3.58 17.12 3.5 17.12 3.23 17.12 3 17.03 2.8 16.85 2.6 16.67 2.5 16.43 2.5 16.12 m 12.5 16.12 l 12.5 7.88 b 12.5 7.58 12.6 7.33 12.8 7.15 13 6.97 13.23 6.88 13.5 6.88 13.58 6.88 13.68 6.88 13.78 6.9 13.88 6.92 13.97 6.96 14.05 7.02 l 20.25 11.17 b 20.4 11.27 20.51 11.4 20.59 11.54 20.66 11.68 20.7 11.83 20.7 12 20.7 12.17 20.66 12.32 20.59 12.46 20.51 12.6 20.4 12.72 20.25 12.82 l 14.05 16.98 b 13.97 17.04 13.88 17.08 13.78 17.1 13.68 17.12 13.58 17.12 13.5 17.12 13.23 17.12 13 17.03 12.8 16.85 12.6 16.67 12.5 16.43 12.5 16.12 m 4.5 14.25 l 7.9 12 4.5 9.75 4.5 14.25 m 14.5 14.25 l 17.9 12 14.5 9.75 14.5 14.25",
    ["fast_forward_filled"] = "m 2.5 16.12 l 2.5 7.88 b 2.5 7.58 2.6 7.33 2.8 7.15 3 6.97 3.23 6.88 3.5 6.88 3.58 6.88 3.68 6.88 3.78 6.9 3.88 6.92 3.97 6.96 4.05 7.02 l 10.25 11.17 b 10.4 11.27 10.51 11.4 10.59 11.54 10.66 11.68 10.7 11.83 10.7 12 10.7 12.17 10.66 12.32 10.59 12.46 10.51 12.6 10.4 12.72 10.25 12.82 l 4.05 16.98 b 3.97 17.04 3.88 17.08 3.78 17.1 3.68 17.12 3.58 17.12 3.5 17.12 3.23 17.12 3 17.03 2.8 16.85 2.6 16.67 2.5 16.43 2.5 16.12 m 12.5 16.12 l 12.5 7.88 b 12.5 7.58 12.6 7.33 12.8 7.15 13 6.97 13.23 6.88 13.5 6.88 13.58 6.88 13.68 6.88 13.78 6.9 13.88 6.92 13.97 6.96 14.05 7.02 l 20.25 11.17 b 20.4 11.27 20.51 11.4 20.59 11.54 20.66 11.68 20.7 11.83 20.7 12 20.7 12.17 20.66 12.32 20.59 12.46 20.51 12.6 20.4 12.72 20.25 12.82 l 14.05 16.98 b 13.97 17.04 13.88 17.08 13.78 17.1 13.68 17.12 13.58 17.12 13.5 17.12 13.23 17.12 13 17.03 12.8 16.85 12.6 16.67 12.5 16.43 12.5 16.12",
    ["fast_rewind"] = "m 19.95 16.98 l 13.75 12.82 b 13.6 12.72 13.49 12.6 13.41 12.46 13.34 12.32 13.3 12.17 13.3 12 13.3 11.83 13.34 11.68 13.41 11.54 13.49 11.4 13.6 11.27 13.75 11.17 l 19.95 7.02 b 20.03 6.96 20.13 6.92 20.23 6.9 20.32 6.88 20.42 6.88 20.5 6.88 20.77 6.88 21 6.97 21.2 7.15 21.4 7.33 21.5 7.58 21.5 7.88 l 21.5 16.12 b 21.5 16.43 21.4 16.67 21.2 16.85 21 17.03 20.77 17.12 20.5 17.12 20.42 17.12 20.32 17.12 20.23 17.1 20.13 17.08 20.03 17.04 19.95 16.98 m 9.95 16.98 l 3.75 12.82 b 3.6 12.72 3.49 12.6 3.41 12.46 3.34 12.32 3.3 12.17 3.3 12 3.3 11.83 3.34 11.68 3.41 11.54 3.49 11.4 3.6 11.27 3.75 11.17 l 9.95 7.02 b 10.03 6.96 10.13 6.92 10.23 6.9 10.33 6.88 10.42 6.88 10.5 6.88 10.77 6.88 11 6.97 11.2 7.15 11.4 7.33 11.5 7.58 11.5 7.88 l 11.5 16.12 b 11.5 16.43 11.4 16.67 11.2 16.85 11 17.03 10.77 17.12 10.5 17.12 10.42 17.12 10.33 17.12 10.23 17.1 10.13 17.08 10.03 17.04 9.95 16.98 m 9.5 14.25 l 9.5 9.75 6.1 12 9.5 14.25 m 19.5 14.25 l 19.5 9.75 16.1 12 19.5 14.25",
    ["fast_rewind_filled"] = "m 19.95 16.98 l 13.75 12.82 b 13.6 12.72 13.49 12.6 13.41 12.46 13.34 12.32 13.3 12.17 13.3 12 13.3 11.83 13.34 11.68 13.41 11.54 13.49 11.4 13.6 11.27 13.75 11.17 l 19.95 7.02 b 20.03 6.96 20.13 6.92 20.23 6.9 20.32 6.88 20.42 6.88 20.5 6.88 20.77 6.88 21 6.97 21.2 7.15 21.4 7.33 21.5 7.58 21.5 7.88 l 21.5 16.12 b 21.5 16.43 21.4 16.67 21.2 16.85 21 17.03 20.77 17.12 20.5 17.12 20.42 17.12 20.32 17.12 20.23 17.1 20.13 17.08 20.03 17.04 19.95 16.98 m 9.95 16.98 l 3.75 12.82 b 3.6 12.72 3.49 12.6 3.41 12.46 3.34 12.32 3.3 12.17 3.3 12 3.3 11.83 3.34 11.68 3.41 11.54 3.49 11.4 3.6 11.27 3.75 11.17 l 9.95 7.02 b 10.03 6.96 10.13 6.92 10.23 6.9 10.33 6.88 10.42 6.88 10.5 6.88 10.77 6.88 11 6.97 11.2 7.15 11.4 7.33 11.5 7.58 11.5 7.88 l 11.5 16.12 b 11.5 16.43 11.4 16.67 11.2 16.85 11 17.03 10.77 17.12 10.5 17.12 10.42 17.12 10.33 17.12 10.23 17.1 10.13 17.08 10.03 17.04 9.95 16.98",
    ["fluent_arrow_download"] = "m 18.25 20.5 b 18.66 20.5 19 20.84 19 21.25 19 21.66 18.66 22 18.25 22 l 5.25 22 b 4.84 22 4.5 21.67 4.5 21.25 4.5 20.84 4.84 20.5 5.25 20.5 l 18.25 20.5 m 11.65 2.01 l 11.75 2.01 b 12.13 2.01 12.44 2.29 12.49 2.65 l 12.5 2.76 12.5 16.44 16.22 12.72 b 16.49 12.45 16.9 12.43 17.2 12.65 l 17.28 12.72 b 17.55 12.99 17.57 13.4 17.35 13.7 l 17.28 13.78 12.28 18.78 b 12.02 19.04 11.6 19.07 11.31 18.85 l 11.22 18.78 6.22 13.78 b 5.93 13.49 5.93 13.01 6.22 12.72 6.49 12.45 6.9 12.43 7.2 12.65 l 7.28 12.72 11 16.43 11 2.76 b 11 2.38 11.28 2.06 11.65 2.01 l 11.75 2.01 11.65 2.01",
    ["fluent_arrow_download_filled"] = "m 13 3 b 13 2.45 12.55 2 12 2 11.45 2 11 2.45 11 3 l 11 15.09 7.71 11.79 b 7.32 11.4 6.68 11.4 6.29 11.79 5.9 12.18 5.9 12.82 6.29 13.21 l 11.29 18.21 b 11.68 18.6 12.32 18.6 12.71 18.21 l 17.71 13.21 b 18.1 12.82 18.1 12.18 17.71 11.79 17.32 11.4 16.68 11.4 16.29 11.79 l 13 15.09 13 3 m 5 20 b 4.45 20 4 20.45 4 21 4 21.55 4.45 22 5 22 l 19 22 b 19.55 22 20 21.55 20 21 20 20.45 19.55 20 19 20 l 5 20",
    ["fluent_arrow_maximize"] = "m 19.25 4 b 19.66 4 20 4.34 20 4.75 l 20 12.25 b 20 12.66 19.66 13 19.25 13 18.84 13 18.5 12.66 18.5 12.25 l 18.5 6.56 6.56 18.5 12.25 18.5 b 12.66 18.5 13 18.84 13 19.25 13 19.66 12.66 20 12.25 20 l 4.75 20 b 4.34 20 4 19.66 4 19.25 l 4 11.75 b 4 11.34 4.34 11 4.75 11 5.16 11 5.5 11.34 5.5 11.75 l 5.5 17.44 17.44 5.5 11.75 5.5 b 11.34 5.5 11 5.16 11 4.75 11 4.34 11.34 4 11.75 4 l 19.25 4",
    ["fluent_arrow_maximize_filled"] = "m 19.5 3.5 b 20.05 3.5 20.5 3.95 20.5 4.5 l 20.5 12 b 20.5 12.55 20.05 13 19.5 13 18.95 13 18.5 12.55 18.5 12 l 18.5 6.91 6.91 18.5 12 18.5 b 12.55 18.5 13 18.95 13 19.5 13 20.05 12.55 20.5 12 20.5 l 4.5 20.5 b 3.95 20.5 3.5 20.05 3.5 19.5 l 3.5 12 b 3.5 11.45 3.95 11 4.5 11 5.05 11 5.5 11.45 5.5 12 l 5.5 17.09 17.09 5.5 12 5.5 b 11.45 5.5 11 5.05 11 4.5 11 3.95 11.45 3.5 12 3.5 l 19.5 3.5",
    ["fluent_arrow_minimize"] = "m 10.25 13 b 10.66 13 11 13.34 11 13.75 l 11 21.25 b 11 21.66 10.66 22 10.25 22 9.84 22 9.5 21.66 9.5 21.25 l 9.5 15.56 3.28 21.78 b 2.99 22.07 2.51 22.07 2.22 21.78 1.93 21.49 1.93 21.01 2.22 20.72 l 8.44 14.5 2.75 14.5 b 2.34 14.5 2 14.16 2 13.75 2 13.34 2.34 13 2.75 13 l 10.25 13 m 20.72 2.22 b 21.01 1.93 21.49 1.93 21.78 2.22 22.07 2.51 22.07 2.99 21.78 3.28 l 15.56 9.5 21.25 9.5 b 21.66 9.5 22 9.84 22 10.25 22 10.66 21.66 11 21.25 11 l 13.75 11 b 13.34 11 13 10.66 13 10.25 l 13 2.75 b 13 2.34 13.34 2 13.75 2 14.16 2 14.5 2.34 14.5 2.75 l 14.5 8.44 20.72 2.22",
    ["fluent_arrow_minimize_filled"] = "m 10.5 12.51 b 11.01 12.51 11.43 12.89 11.49 13.39 l 11.5 13.51 11.5 21.01 b 11.5 21.56 11.05 22.01 10.5 22.01 9.98 22.01 9.56 21.62 9.5 21.13 l 9.5 21.01 9.5 15.92 3.71 21.71 b 3.35 22.07 2.78 22.1 2.39 21.79 l 2.29 21.71 b 1.93 21.35 1.9 20.78 2.21 20.39 l 2.29 20.29 8.08 14.51 3 14.51 b 2.44 14.51 2 14.06 2 13.51 2 12.99 2.38 12.57 2.88 12.51 l 3 12.51 10.5 12.51 m 13.5 2 b 14.01 2 14.43 2.39 14.49 2.88 l 14.5 3 14.5 8.09 20.29 2.29 b 20.65 1.93 21.22 1.91 21.61 2.21 l 21.71 2.29 b 22.07 2.65 22.09 3.22 21.79 3.61 l 21.71 3.71 15.91 9.5 21 9.5 b 21.55 9.5 22 9.95 22 10.5 22 11.02 21.61 11.44 21.12 11.5 l 21 11.5 13.5 11.5 b 12.99 11.5 12.56 11.12 12.51 10.62 l 12.5 10.5 12.5 3 b 12.5 2.45 12.95 2 13.5 2",
    ["fluent_arrow_repeat_all"] = "m 14.61 2.47 l 14.53 2.4 b 14.24 2.18 13.82 2.2 13.55 2.47 l 13.48 2.55 b 13.26 2.84 13.28 3.27 13.55 3.53 l 15.52 5.51 8.5 5.51 8.27 5.52 b 4.79 5.64 2 8.51 2 12.04 2 13.73 2.64 15.27 3.69 16.43 l 3.76 16.49 b 3.89 16.61 4.06 16.67 4.25 16.67 4.66 16.67 5 16.34 5 15.92 5 15.75 4.94 15.59 4.84 15.46 l 4.64 15.23 b 3.93 14.36 3.5 13.25 3.5 12.04 3.5 9.26 5.74 7.02 8.5 7.02 l 15.38 7.02 13.55 8.86 13.48 8.93 b 13.26 9.23 13.28 9.65 13.55 9.92 13.84 10.22 14.32 10.22 14.61 9.92 l 17.79 6.73 17.86 6.65 b 18.08 6.36 18.06 5.93 17.79 5.66 l 14.61 2.47 m 20.23 7.57 b 20.1 7.46 19.93 7.4 19.75 7.4 19.34 7.4 19 7.73 19 8.15 19 8.34 19.07 8.51 19.18 8.64 20 9.53 20.5 10.72 20.5 12.04 20.5 14.81 18.26 17.05 15.5 17.05 l 8.56 17.05 10.46 15.14 10.54 15.06 b 10.73 14.79 10.73 14.42 10.53 14.15 l 10.46 14.08 10.38 14 b 10.11 13.81 9.74 13.81 9.48 14.01 l 9.4 14.08 6.22 17.27 6.15 17.36 b 5.95 17.62 5.95 17.99 6.15 18.26 l 6.22 18.34 9.4 21.53 9.49 21.6 b 9.78 21.82 10.2 21.8 10.46 21.53 10.73 21.26 10.75 20.84 10.53 20.54 l 10.46 20.46 8.56 18.56 15.5 18.56 15.73 18.55 b 19.21 18.43 22 15.56 22 12.04 22 10.34 21.36 8.8 20.3 7.64 l 20.23 7.57",
    ["fluent_arrow_repeat_all_filled"] = "m 14.71 2.29 l 14.63 2.21 b 14.23 1.9 13.66 1.93 13.3 2.29 l 13.22 2.38 b 12.91 2.77 12.94 3.34 13.3 3.7 l 14.6 5 9 5 8.76 5 b 5 5.13 2 8.21 2 11.99 2 13.44 2.44 14.78 3.19 15.89 3.37 16.14 3.67 16.31 4 16.31 4.55 16.31 5 15.86 5 15.31 5 15.09 4.93 14.89 4.82 14.73 l 4.68 14.51 b 4.25 13.77 4 12.91 4 11.99 4 9.23 6.24 7 9 7 l 14.6 7 13.3 8.29 13.22 8.38 b 12.91 8.77 12.94 9.35 13.3 9.71 13.69 10.1 14.32 10.1 14.71 9.71 l 17.72 6.71 17.8 6.62 b 18.11 6.23 18.08 5.65 17.72 5.29 l 14.71 2.29 m 20.79 8.06 b 20.6 7.83 20.32 7.68 20 7.68 19.45 7.68 19 8.13 19 8.68 19 8.89 19.06 9.08 19.17 9.24 19.7 10.03 20 10.98 20 11.99 20 14.75 17.76 16.99 15 16.99 l 9.41 16.99 10.71 15.7 10.79 15.6 b 11.07 15.24 11.07 14.73 10.79 14.37 l 10.71 14.28 10.61 14.2 b 10.25 13.92 9.74 13.92 9.38 14.21 l 9.29 14.28 6.29 17.29 6.21 17.38 b 5.92 17.74 5.93 18.25 6.21 18.61 l 6.29 18.7 9.29 21.7 9.39 21.79 b 9.78 22.09 10.35 22.06 10.71 21.7 11.07 21.34 11.1 20.77 10.79 20.38 l 10.71 20.29 9.4 18.99 15 18.99 15.24 18.98 b 19 18.86 22 15.78 22 11.99 22 10.53 21.55 9.18 20.79 8.06 l 20.79 8.06",
    ["fluent_arrow_repeat_all_off"] = "m 3.2 2.15 l 3.28 2.22 21.78 20.72 b 22.07 21.01 22.07 21.49 21.78 21.78 21.51 22.05 21.1 22.07 20.8 21.85 l 20.72 21.78 17.21 18.27 b 16.77 18.39 16.32 18.47 15.85 18.49 l 15.5 18.5 8.56 18.5 10.46 20.4 10.53 20.48 b 10.75 20.77 10.73 21.19 10.46 21.46 10.2 21.73 9.78 21.75 9.49 21.53 l 9.4 21.46 6.22 18.28 6.15 18.2 b 5.95 17.94 5.95 17.57 6.15 17.3 l 6.22 17.22 9.4 14.04 9.48 13.97 b 9.74 13.77 10.11 13.76 10.38 13.96 l 10.46 14.04 10.53 14.11 b 10.73 14.38 10.73 14.74 10.54 15.01 l 10.46 15.1 8.56 17 15.5 17 b 15.64 17 15.78 16.99 15.92 16.98 l 6.4 7.46 b 4.69 8.25 3.5 9.99 3.5 12 3.5 13.3 3.99 14.48 4.8 15.37 4.92 15.5 5 15.68 5 15.87 5 16.29 4.66 16.62 4.25 16.62 4.03 16.62 3.83 16.53 3.69 16.37 2.64 15.22 2 13.68 2 12 2 9.58 3.32 7.47 5.29 6.35 l 2.22 3.28 b 1.93 2.99 1.93 2.51 2.22 2.22 2.49 1.95 2.9 1.93 3.2 2.15 m 19.75 7.38 b 19.97 7.38 20.17 7.47 20.3 7.62 21.36 8.78 22 10.31 22 12 22 14.06 21.04 15.89 19.55 17.08 l 18.49 16.01 b 19.71 15.1 20.5 13.64 20.5 12 20.5 10.69 20 9.5 19.18 8.61 19.07 8.48 19 8.31 19 8.13 19 7.71 19.34 7.38 19.75 7.38 m 14.53 2.4 l 14.61 2.47 17.79 5.65 b 18.06 5.92 18.08 6.34 17.86 6.64 l 17.79 6.71 14.61 9.89 b 14.32 10.19 13.84 10.19 13.55 9.89 13.28 9.63 13.26 9.2 13.48 8.91 l 13.55 8.83 15.38 7 9.47 7 7.99 5.52 b 8.08 5.51 8.18 5.51 8.27 5.5 l 8.5 5.5 15.52 5.5 13.55 3.53 b 13.28 3.26 13.26 2.84 13.48 2.55 l 13.55 2.47 b 13.82 2.2 14.24 2.18 14.53 2.4",
    ["fluent_arrow_repeat_all_off_filled"] = "m 3.61 2.21 l 3.71 2.29 21.71 20.29 b 22.1 20.68 22.1 21.32 21.71 21.71 21.35 22.07 20.78 22.09 20.39 21.79 l 20.29 21.71 17.22 18.64 b 16.63 18.84 15.99 18.96 15.33 18.99 l 15 19 9.4 19 10.71 20.3 10.79 20.39 b 11.1 20.78 11.07 21.35 10.71 21.72 10.35 22.08 9.78 22.11 9.39 21.8 l 9.29 21.72 6.29 18.71 6.21 18.62 b 5.93 18.27 5.92 17.75 6.21 17.39 l 6.29 17.3 9.29 14.29 9.38 14.21 b 9.74 13.93 10.25 13.93 10.61 14.21 l 10.71 14.29 10.79 14.38 b 11.07 14.74 11.07 15.25 10.79 15.61 l 10.71 15.71 9.41 17 15 17 b 15.19 17 15.37 16.99 15.55 16.97 l 6.35 7.76 b 4.94 8.65 4 10.21 4 12 4 12.92 4.25 13.78 4.68 14.52 l 4.82 14.74 b 4.93 14.9 5 15.1 5 15.32 5 15.87 4.55 16.32 4 16.32 3.67 16.32 3.37 16.15 3.19 15.9 2.44 14.79 2 13.45 2 12 2 9.66 3.15 7.59 4.91 6.32 l 2.29 3.71 b 1.9 3.32 1.9 2.68 2.29 2.29 2.65 1.93 3.22 1.9 3.61 2.21 m 20 7.68 b 20.32 7.68 20.6 7.83 20.79 8.06 l 20.84 8.14 20.86 8.17 b 21.58 9.27 22 10.58 22 12 22 13.98 21.18 15.76 19.86 17.04 l 18.45 15.62 b 19.4 14.71 20 13.43 20 12 20 11.07 19.75 10.21 19.31 9.46 l 19.17 9.24 b 19.06 9.08 19 8.89 19 8.68 19 8.13 19.45 7.68 20 7.68 m 14.63 2.21 l 14.71 2.29 17.72 5.29 b 18.08 5.66 18.11 6.23 17.8 6.62 l 17.72 6.71 14.71 9.71 b 14.32 10.1 13.69 10.1 13.3 9.71 12.94 9.35 12.91 8.78 13.22 8.39 l 13.3 8.3 14.6 7 9.83 7 7.91 5.09 b 8.19 5.04 8.47 5.02 8.76 5.01 l 9 5 14.6 5 13.3 3.7 b 12.94 3.34 12.91 2.77 13.22 2.38 l 13.3 2.29 b 13.66 1.93 14.23 1.9 14.63 2.21",
    ["fluent_arrow_shuffle"] = "m 19.28 4.72 b 18.99 4.43 18.51 4.43 18.22 4.72 17.93 5.01 17.93 5.49 18.22 5.78 l 19.44 7 19.25 7 b 15.33 7 12.83 9.3 10.56 11.39 l 10.49 11.45 b 8.15 13.6 6.04 15.5 2.75 15.5 2.34 15.5 2 15.84 2 16.25 2 16.66 2.34 17 2.75 17 6.67 17 9.17 14.7 11.44 12.61 l 11.51 12.55 b 13.85 10.4 15.96 8.5 19.25 8.5 l 19.44 8.5 18.22 9.72 b 17.93 10.01 17.93 10.49 18.22 10.78 18.51 11.07 18.99 11.07 19.28 10.78 l 21.78 8.28 b 21.92 8.14 22 7.95 22 7.75 22 7.55 21.92 7.36 21.78 7.22 l 19.28 4.72 m 2.75 7 b 6 7 8.27 8.58 10.25 10.31 10.15 10.4 10.05 10.5 9.95 10.59 l 9.82 10.71 b 9.58 10.92 9.36 11.13 9.14 11.33 7.28 9.73 5.4 8.5 2.75 8.5 2.34 8.5 2 8.16 2 7.75 2 7.34 2.34 7 2.75 7 m 19.25 17 b 16 17 13.73 15.42 11.75 13.69 11.85 13.6 11.95 13.5 12.05 13.41 l 12.05 13.41 12.18 13.29 b 12.42 13.08 12.64 12.87 12.86 12.67 14.72 14.27 16.6 15.5 19.25 15.5 l 19.44 15.5 18.22 14.28 b 17.93 13.99 17.93 13.51 18.22 13.22 18.51 12.93 18.99 12.93 19.28 13.22 l 21.78 15.72 b 21.92 15.86 22 16.05 22 16.25 22 16.45 21.92 16.64 21.78 16.78 l 19.28 19.28 b 18.99 19.57 18.51 19.57 18.22 19.28 17.93 18.99 17.93 18.51 18.22 18.22 l 19.44 17 19.25 17",
    ["fluent_arrow_shuffle_filled"] = "m 19.21 4.29 b 18.82 3.9 18.18 3.9 17.79 4.29 17.4 4.68 17.4 5.32 17.79 5.71 l 18.59 6.51 b 14.79 6.67 12.43 9.1 10.37 11.22 l 10.28 11.3 b 8.06 13.59 6.15 15.5 3 15.5 2.45 15.5 2 15.95 2 16.5 2 17.05 2.45 17.5 3 17.5 7.05 17.5 9.5 14.98 11.63 12.78 l 11.72 12.7 b 13.84 10.51 15.68 8.68 18.57 8.51 l 17.79 9.29 b 17.4 9.68 17.4 10.32 17.79 10.71 18.18 11.1 18.82 11.1 19.21 10.71 l 21.71 8.21 b 21.89 8.02 22 7.77 22 7.5 22 7.23 21.89 6.98 21.71 6.79 l 19.21 4.29 m 3 6.5 b 6.23 6.5 8.44 8.11 10.29 9.87 10.09 10.07 9.9 10.26 9.71 10.45 l 9.57 10.61 b 9.33 10.85 9.11 11.08 8.89 11.3 7.19 9.68 5.48 8.5 3 8.5 2.45 8.5 2 8.05 2 7.5 2 6.95 2.45 6.5 3 6.5 m 18.59 17.49 b 15.58 17.36 13.48 15.82 11.71 14.13 11.91 13.93 12.1 13.74 12.29 13.55 l 12.43 13.39 b 12.67 13.15 12.89 12.92 13.11 12.7 14.71 14.23 16.32 15.36 18.57 15.49 l 17.79 14.71 b 17.4 14.32 17.4 13.68 17.79 13.29 18.18 12.9 18.82 12.9 19.21 13.29 l 21.71 15.79 b 21.89 15.98 22 16.23 22 16.5 22 16.77 21.89 17.02 21.71 17.21 l 19.21 19.71 b 18.82 20.1 18.18 20.1 17.79 19.71 17.4 19.32 17.4 18.68 17.79 18.29 l 18.59 17.49",
    ["fluent_arrow_shuffle_off"] = "m 3.28 2.22 b 2.99 1.93 2.51 1.93 2.22 2.22 1.93 2.51 1.93 2.99 2.22 3.28 l 6.92 7.98 b 5.71 7.38 4.35 7 2.75 7 2.34 7 2 7.34 2 7.75 2 8.16 2.34 8.5 2.75 8.5 5.4 8.5 7.28 9.73 9.14 11.33 9.33 11.16 9.53 10.98 9.73 10.79 l 10.44 11.5 b 8.12 13.63 6.02 15.5 2.75 15.5 2.34 15.5 2 15.84 2 16.25 2 16.66 2.34 17 2.75 17 6.67 17 9.17 14.7 11.44 12.61 l 11.5 12.56 12.21 13.27 b 12.2 13.27 12.19 13.28 12.18 13.29 l 12.05 13.41 b 11.95 13.5 11.85 13.6 11.75 13.69 12.69 14.51 13.69 15.3 14.84 15.9 l 20.72 21.78 b 21.01 22.07 21.49 22.07 21.78 21.78 22.07 21.49 22.07 21.01 21.78 20.72 l 3.28 2.22 m 18.66 15.48 l 20.87 17.69 21.78 16.78 b 21.92 16.64 22 16.45 22 16.25 22 16.05 21.92 15.86 21.78 15.72 l 19.28 13.22 b 18.99 12.93 18.51 12.93 18.22 13.22 17.93 13.51 17.93 13.99 18.22 14.28 l 19.44 15.5 19.25 15.5 b 19.05 15.5 18.85 15.49 18.66 15.48 m 12.7 9.52 l 13.77 10.59 b 15.35 9.37 17.03 8.5 19.25 8.5 l 19.44 8.5 18.22 9.72 b 17.93 10.01 17.93 10.49 18.22 10.78 18.51 11.07 18.99 11.07 19.28 10.78 l 21.78 8.28 b 21.92 8.14 22 7.95 22 7.75 22 7.55 21.92 7.36 21.78 7.22 l 19.28 4.72 b 18.99 4.43 18.51 4.43 18.22 4.72 17.93 5.01 17.93 5.49 18.22 5.78 l 19.44 7 19.25 7 b 16.51 7 14.46 8.13 12.7 9.52",
    ["fluent_arrow_shuffle_off_filled"] = "m 3.28 2.22 b 2.99 1.93 2.51 1.93 2.22 2.22 1.93 2.51 1.93 2.99 2.22 3.28 l 5.92 6.99 b 5.05 6.68 4.08 6.5 3 6.5 2.45 6.5 2 6.95 2 7.5 2 8.05 2.45 8.5 3 8.5 5.48 8.5 7.19 9.68 8.89 11.3 9.1 11.08 9.33 10.85 9.56 10.62 l 10.26 11.32 b 8.05 13.6 6.14 15.5 3 15.5 2.45 15.5 2 15.95 2 16.5 2 17.05 2.45 17.5 3 17.5 7.05 17.5 9.5 14.98 11.63 12.78 l 11.68 12.74 12.38 13.45 12.29 13.55 b 12.1 13.74 11.91 13.93 11.71 14.13 12.89 15.26 14.23 16.33 15.89 16.95 l 17.57 18.63 b 17.43 18.99 17.5 19.42 17.79 19.71 18.08 20 18.51 20.07 18.87 19.93 l 20.72 21.78 b 21.01 22.07 21.49 22.07 21.78 21.78 22.07 21.49 22.07 21.01 21.78 20.72 l 3.28 2.22 m 17.58 14.4 l 21.05 17.87 21.71 17.21 b 21.89 17.02 22 16.77 22 16.5 22 16.23 21.89 15.98 21.71 15.79 l 19.21 13.29 b 18.82 12.9 18.18 12.9 17.79 13.29 17.49 13.59 17.42 14.04 17.58 14.4 m 12.41 9.23 l 13.83 10.65 b 15.21 9.46 16.66 8.62 18.57 8.51 l 17.79 9.29 b 17.4 9.68 17.4 10.32 17.79 10.71 18.18 11.1 18.82 11.1 19.21 10.71 l 21.71 8.21 b 21.89 8.02 22 7.77 22 7.5 22 7.23 21.89 6.98 21.71 6.79 l 19.21 4.29 b 18.82 3.9 18.18 3.9 17.79 4.29 17.4 4.68 17.4 5.32 17.79 5.71 l 18.59 6.51 b 15.97 6.62 14.03 7.81 12.41 9.23",
    ["fluent_audio"] = "m 2 7.25 b 2 5.46 3.46 4 5.25 4 l 18.75 4 b 20.54 4 22 5.46 22 7.25 l 22 16.75 b 22 18.54 20.54 20 18.75 20 l 5.25 20 b 3.46 20 2 18.54 2 16.75 l 2 7.25 m 5.25 5.5 b 4.28 5.5 3.5 6.28 3.5 7.25 l 3.5 16.75 b 3.5 17.72 4.28 18.5 5.25 18.5 l 18.75 18.5 b 19.72 18.5 20.5 17.72 20.5 16.75 l 20.5 7.25 b 20.5 6.28 19.72 5.5 18.75 5.5 l 5.25 5.5 m 5 13.25 l 5 10.75 b 5 10.34 5.34 10 5.75 10 6.16 10 6.5 10.34 6.5 10.75 l 6.5 13.25 b 6.5 13.66 6.16 14 5.75 14 5.34 14 5 13.66 5 13.25 m 8.12 14.75 l 8.12 9.25 b 8.12 8.84 8.46 8.5 8.88 8.5 9.29 8.5 9.62 8.84 9.62 9.25 l 9.62 14.75 b 9.62 15.16 9.29 15.5 8.88 15.5 8.46 15.5 8.12 15.16 8.12 14.75 m 11.25 16.75 l 11.25 7.25 b 11.25 6.84 11.59 6.5 12 6.5 12.41 6.5 12.75 6.84 12.75 7.25 l 12.75 16.75 b 12.75 17.16 12.41 17.5 12 17.5 11.59 17.5 11.25 17.16 11.25 16.75 m 14.38 14.25 l 14.38 9.75 b 14.38 9.34 14.71 9 15.12 9 15.54 9 15.88 9.34 15.88 9.75 l 15.88 14.25 b 15.88 14.66 15.54 15 15.12 15 14.71 15 14.38 14.66 14.38 14.25 m 17.5 13 l 17.5 11 b 17.5 10.59 17.84 10.25 18.25 10.25 18.66 10.25 19 10.59 19 11 l 19 13 b 19 13.41 18.66 13.75 18.25 13.75 17.84 13.75 17.5 13.41 17.5 13",
    ["fluent_audio_filled"] = "m 2 7.25 b 2 5.46 3.46 4 5.25 4 l 18.75 4 b 20.54 4 22 5.46 22 7.25 l 22 16.75 b 22 18.54 20.54 20 18.75 20 l 5.25 20 b 3.46 20 2 18.54 2 16.75 l 2 7.25 m 5 10.75 l 5 13.25 b 5 13.66 5.34 14 5.75 14 6.16 14 6.5 13.66 6.5 13.25 l 6.5 10.75 b 6.5 10.34 6.16 10 5.75 10 5.34 10 5 10.34 5 10.75 m 8.12 9.25 l 8.12 14.75 b 8.12 15.16 8.46 15.5 8.88 15.5 9.29 15.5 9.62 15.16 9.62 14.75 l 9.62 9.25 b 9.62 8.84 9.29 8.5 8.88 8.5 8.46 8.5 8.12 8.84 8.12 9.25 m 11.25 7.25 l 11.25 16.75 b 11.25 17.16 11.59 17.5 12 17.5 12.41 17.5 12.75 17.16 12.75 16.75 l 12.75 7.25 b 12.75 6.84 12.41 6.5 12 6.5 11.59 6.5 11.25 6.84 11.25 7.25 m 14.38 9.75 l 14.38 14.25 b 14.38 14.66 14.71 15 15.12 15 15.54 15 15.88 14.66 15.88 14.25 l 15.88 9.75 b 15.88 9.34 15.54 9 15.12 9 14.71 9 14.38 9.34 14.38 9.75 m 17.5 11 l 17.5 13 b 17.5 13.41 17.84 13.75 18.25 13.75 18.66 13.75 19 13.41 19 13 l 19 11 b 19 10.59 18.66 10.25 18.25 10.25 17.84 10.25 17.5 10.59 17.5 11",
    ["fluent_camera"] = "m 13.92 2.5 b 14.72 2.5 15.46 2.93 15.86 3.61 l 16.68 5 18.75 5 b 20.54 5 22 6.46 22 8.25 l 22 17.75 b 22 19.55 20.54 21 18.75 21 l 5.25 21 b 3.46 21 2 19.55 2 17.75 l 2 8.25 b 2 6.46 3.46 5 5.25 5 l 7.33 5 8.21 3.58 b 8.61 2.91 9.34 2.5 10.12 2.5 l 13.92 2.5 m 13.92 4 l 10.12 4 b 9.9 4 9.69 4.1 9.55 4.27 l 9.48 4.36 8.39 6.14 b 8.25 6.37 8.01 6.5 7.75 6.5 l 5.25 6.5 b 4.28 6.5 3.5 7.28 3.5 8.25 l 3.5 17.75 b 3.5 18.72 4.28 19.5 5.25 19.5 l 18.75 19.5 b 19.72 19.5 20.5 18.72 20.5 17.75 l 20.5 8.25 b 20.5 7.28 19.72 6.5 18.75 6.5 l 16.25 6.5 b 15.98 6.5 15.74 6.36 15.6 6.13 l 14.57 4.37 b 14.44 4.14 14.19 4 13.92 4 m 12 8 b 14.49 8 16.5 10.02 16.5 12.5 16.5 14.99 14.49 17 12 17 9.51 17 7.5 14.99 7.5 12.5 7.5 10.02 9.51 8 12 8 m 12 9.5 b 10.34 9.5 9 10.84 9 12.5 9 14.16 10.34 15.5 12 15.5 13.66 15.5 15 14.16 15 12.5 15 10.84 13.66 9.5 12 9.5",
    ["fluent_camera_filled"] = "m 13.92 2.5 b 14.72 2.5 15.46 2.93 15.86 3.61 l 16.68 5 18.75 5 b 20.54 5 22 6.46 22 8.25 l 22 17.75 b 22 19.55 20.54 21 18.75 21 l 5.25 21 b 3.46 21 2 19.55 2 17.75 l 2 8.25 b 2 6.46 3.46 5 5.25 5 l 7.33 5 8.21 3.58 b 8.61 2.91 9.34 2.5 10.12 2.5 l 13.92 2.5 m 12 8 b 9.51 8 7.5 10.02 7.5 12.5 7.5 14.99 9.51 17 12 17 14.49 17 16.5 14.99 16.5 12.5 16.5 10.02 14.49 8 12 8 m 12 9.5 b 13.66 9.5 15 10.84 15 12.5 15 14.16 13.66 15.5 12 15.5 10.34 15.5 9 14.16 9 12.5 9 10.84 10.34 9.5 12 9.5",
    ["fluent_clock_arrow_download"] = "m 4.5 11 b 4.5 6.31 8.31 2.5 13 2.5 17.69 2.5 21.5 6.31 21.5 11 21.5 15.69 17.69 19.5 13 19.5 12.9 19.5 12.79 19.5 12.69 19.49 12.52 20.01 12.29 20.5 12.01 20.95 12.33 20.98 12.67 21 13 21 18.52 21 23 16.52 23 11 23 5.48 18.52 1 13 1 7.48 1 3 5.48 3 11 3 11.33 3.02 11.67 3.05 11.99 3.5 11.71 3.99 11.48 4.51 11.31 4.5 11.21 4.5 11.1 4.5 11 m 12.99 5.65 b 12.94 5.28 12.63 5 12.25 5 11.84 5 11.5 5.34 11.5 5.75 l 11.5 11.75 11.51 11.85 b 11.56 12.22 11.87 12.5 12.25 12.5 l 16.25 12.5 16.35 12.49 b 16.72 12.44 17 12.13 17 11.75 17 11.34 16.66 11 16.25 11 l 13 11 13 5.75 12.99 5.65 m 1 17.5 b 1 14.63 3.2 12.28 6 12.02 l 6 17.79 4.35 16.15 b 4.16 15.95 3.84 15.95 3.65 16.15 3.45 16.34 3.45 16.66 3.65 16.85 l 6.15 19.35 b 6.34 19.55 6.66 19.55 6.85 19.35 l 9.35 16.85 b 9.55 16.66 9.55 16.34 9.35 16.15 9.16 15.95 8.84 15.95 8.65 16.15 l 7 17.79 7 12.02 b 9.8 12.28 12 14.63 12 17.5 12 20.54 9.54 23 6.5 23 3.46 23 1 20.54 1 17.5 m 9.5 20.5 b 9.5 20.22 9.28 20 9 20 l 4 20 b 3.72 20 3.5 20.22 3.5 20.5 3.5 20.78 3.72 21 4 21 l 9 21 b 9.28 21 9.5 20.78 9.5 20.5",
    ["fluent_clock_arrow_download_filled"] = "m 16.25 12.5 l 12.25 12.5 b 11.84 12.5 11.5 12.16 11.5 11.75 l 11.5 5.75 b 11.5 5.34 11.84 5 12.25 5 12.66 5 13 5.34 13 5.75 l 13 11 16.25 11 b 16.66 11 17 11.34 17 11.75 17 12.16 16.66 12.5 16.25 12.5 m 13 1 b 7.48 1 3 5.48 3 11 3 11.33 3.02 11.66 3.05 11.99 4.05 11.36 5.23 11 6.5 11 10.09 11 13 13.91 13 17.5 13 18.77 12.64 19.95 12.01 20.95 12.34 20.98 12.67 21 13 21 18.52 21 23 16.52 23 11 23 5.48 18.52 1 13 1 m 1 17.5 b 1 14.63 3.2 12.28 6 12.02 l 6 17.79 4.35 16.15 b 4.16 15.95 3.84 15.95 3.65 16.15 3.45 16.34 3.45 16.66 3.65 16.85 l 6.15 19.35 b 6.34 19.55 6.66 19.55 6.85 19.35 l 9.35 16.85 b 9.55 16.66 9.55 16.34 9.35 16.15 9.16 15.95 8.84 15.95 8.65 16.15 l 7 17.79 7 12.02 b 9.8 12.28 12 14.63 12 17.5 12 20.54 9.54 23 6.5 23 3.46 23 1 20.54 1 17.5 m 3.5 20.5 b 3.5 20.78 3.72 21 4 21 l 9 21 b 9.28 21 9.5 20.78 9.5 20.5 9.5 20.22 9.28 20 9 20 l 4 20 b 3.72 20 3.5 20.22 3.5 20.5",
    ["fluent_fast_forward"] = "m 11.5 5.5 b 11.5 4.22 13 3.53 13.97 4.36 l 21.38 10.67 b 22.2 11.37 22.2 12.63 21.38 13.33 l 13.97 19.64 b 13 20.47 11.5 19.77 11.5 18.5 l 11.5 14.51 5.47 19.64 b 4.5 20.47 3 19.78 3 18.5 l 3 5.5 b 3 4.22 4.5 3.53 5.47 4.36 l 11.5 9.49 11.5 5.5 m 11.5 11.46 l 4.5 5.5 4.5 18.5 11.5 12.54 11.5 11.46 m 20.41 11.81 l 13 5.5 13 18.5 20.41 12.19 b 20.53 12.09 20.53 11.91 20.41 11.81",
    ["fluent_fast_forward_filled"] = "m 13.97 4.36 b 13 3.53 11.5 4.23 11.5 5.5 l 11.5 9.49 5.47 4.36 b 4.5 3.53 3 4.23 3 5.51 l 3 18.5 b 3 19.38 3.71 19.98 4.46 20 l 4.55 20 b 4.87 19.99 5.19 19.88 5.47 19.64 l 11.5 14.51 11.5 18.5 b 11.5 19.78 13 20.47 13.97 19.64 l 21.38 13.33 b 22.2 12.64 22.2 11.37 21.38 10.67 l 13.97 4.36",
    ["fluent_info"] = "m 12 2 b 17.53 2 22 6.48 22 12 22 17.52 17.53 22 12 22 6.48 22 2 17.52 2 12 2 6.48 6.48 2 12 2 m 12 3.5 b 7.31 3.5 3.5 7.31 3.5 12 3.5 16.7 7.31 20.5 12 20.5 16.7 20.5 20.5 16.7 20.5 12 20.5 7.31 16.7 3.5 12 3.5 m 12 10.5 b 12.41 10.5 12.75 10.84 12.75 11.25 l 12.75 16.25 b 12.75 16.66 12.41 17 12 17 11.59 17 11.25 16.66 11.25 16.25 l 11.25 11.25 b 11.25 10.84 11.59 10.5 12 10.5 m 12 9 b 12.55 9 13 8.55 13 8 13 7.45 12.55 7 12 7 11.45 7 11 7.45 11 8 11 8.55 11.45 9 12 9",
    ["fluent_info_filled"] = "m 12 2 b 17.53 2 22 6.48 22 12 22 17.52 17.53 22 12 22 6.48 22 2 17.52 2 12 2 6.48 6.48 2 12 2 m 12 10.5 b 11.59 10.5 11.25 10.84 11.25 11.25 l 11.25 16.25 b 11.25 16.66 11.59 17 12 17 12.41 17 12.75 16.66 12.75 16.25 l 12.75 11.25 b 12.75 10.84 12.41 10.5 12 10.5 m 12 9 b 12.55 9 13 8.55 13 8 13 7.45 12.55 7 12 7 11.45 7 11 7.45 11 8 11 8.55 11.45 9 12 9",
    ["fluent_more_vertical"] = "m 12 7.75 b 11.03 7.75 10.25 6.97 10.25 6 10.25 5.03 11.03 4.25 12 4.25 12.97 4.25 13.75 5.03 13.75 6 13.75 6.97 12.97 7.75 12 7.75 m 12 13.75 b 11.03 13.75 10.25 12.97 10.25 12 10.25 11.03 11.03 10.25 12 10.25 12.97 10.25 13.75 11.03 13.75 12 13.75 12.97 12.97 13.75 12 13.75 m 10.25 18 b 10.25 18.97 11.03 19.75 12 19.75 12.97 19.75 13.75 18.97 13.75 18 13.75 17.03 12.97 16.25 12 16.25 11.03 16.25 10.25 17.03 10.25 18",
    ["fluent_more_vertical_filled"] = "m 12 8 b 10.9 8 10 7.1 10 6 10 4.9 10.9 4 12 4 13.1 4 14 4.9 14 6 14 7.1 13.1 8 12 8 m 12 14 b 10.9 14 10 13.1 10 12 10 10.9 10.9 10 12 10 13.1 10 14 10.9 14 12 14 13.1 13.1 14 12 14 m 10 18 b 10 19.1 10.9 20 12 20 13.1 20 14 19.1 14 18 14 16.9 13.1 16 12 16 10.9 16 10 16.9 10 18",
    ["fluent_next"] = "m 3 4.75 b 3 3.35 4.58 2.51 5.74 3.31 l 16.24 10.5 b 17.25 11.19 17.25 12.68 16.25 13.38 l 5.75 20.68 b 4.59 21.49 3 20.66 3 19.25 l 3 4.75 m 4.89 4.55 b 4.73 4.43 4.5 4.55 4.5 4.75 l 4.5 19.25 b 4.5 19.45 4.73 19.57 4.89 19.45 l 15.39 12.15 b 15.53 12.05 15.53 11.84 15.39 11.74 l 4.89 4.55 m 21 3.75 b 21 3.34 20.66 3 20.25 3 19.84 3 19.5 3.34 19.5 3.75 l 19.5 20.25 b 19.5 20.66 19.84 21 20.25 21 20.66 21 21 20.66 21 20.25 l 21 3.75",
    ["fluent_next_filled"] = "m 3 4.75 b 3 3.35 4.58 2.51 5.74 3.31 l 16.24 10.5 b 17.25 11.19 17.25 12.68 16.25 13.38 l 5.75 20.68 b 4.59 21.49 3 20.66 3 19.25 l 3 4.75 m 21 3.75 b 21 3.34 20.66 3 20.25 3 19.84 3 19.5 3.34 19.5 3.75 l 19.5 20.25 b 19.5 20.66 19.84 21 20.25 21 20.66 21 21 20.66 21 20.25 l 21 3.75",
    ["fluent_pause"] = "m 6.25 3 b 5.01 3 4 4.01 4 5.25 l 4 18.75 b 4 19.99 5.01 21 6.25 21 l 8.75 21 b 9.99 21 11 19.99 11 18.75 l 11 5.25 b 11 4.01 9.99 3 8.75 3 l 6.25 3 m 5.5 5.25 b 5.5 4.84 5.84 4.5 6.25 4.5 l 8.75 4.5 b 9.16 4.5 9.5 4.84 9.5 5.25 l 9.5 18.75 b 9.5 19.16 9.16 19.5 8.75 19.5 l 6.25 19.5 b 5.84 19.5 5.5 19.16 5.5 18.75 l 5.5 5.25 m 15.25 3 b 14.01 3 13 4.01 13 5.25 l 13 18.75 b 13 19.99 14.01 21 15.25 21 l 17.75 21 b 18.99 21 20 19.99 20 18.75 l 20 5.25 b 20 4.01 18.99 3 17.75 3 l 15.25 3 m 14.5 5.25 b 14.5 4.84 14.84 4.5 15.25 4.5 l 17.75 4.5 b 18.16 4.5 18.5 4.84 18.5 5.25 l 18.5 18.75 b 18.5 19.16 18.16 19.5 17.75 19.5 l 15.25 19.5 b 14.84 19.5 14.5 19.16 14.5 18.75 l 14.5 5.25",
    ["fluent_pause_filled"] = "m 5.75 3 b 4.78 3 4 3.78 4 4.75 l 4 19.25 b 4 20.22 4.78 21 5.75 21 l 9.25 21 b 10.21 21 11 20.22 11 19.25 l 11 4.75 b 11 3.78 10.21 3 9.25 3 l 5.75 3 m 14.75 3 b 13.78 3 13 3.78 13 4.75 l 13 19.25 b 13 20.22 13.78 21 14.75 21 l 18.25 21 b 19.21 21 20 20.22 20 19.25 l 20 4.75 b 20 3.78 19.21 3 18.25 3 l 14.75 3",
    ["fluent_picture_in_picture_enter"] = "m 2 6.25 b 2 4.46 3.46 3 5.25 3 l 18.75 3 b 20.54 3 22 4.46 22 6.25 l 22 12 20.5 12 20.5 6.25 b 20.5 5.28 19.72 4.5 18.75 4.5 l 5.25 4.5 b 4.28 4.5 3.5 5.28 3.5 6.25 l 3.5 15.75 b 3.5 16.72 4.28 17.5 5.25 17.5 l 11 17.5 11 19 5.25 19 b 3.46 19 2 17.54 2 15.75 l 2 6.25 m 14 13 b 12.9 13 12 13.9 12 15 l 12 20 b 12 21.1 12.9 22 14 22 l 21 22 b 22.1 22 23 21.1 23 20 l 23 15 b 23 13.9 22.1 13 21 13 l 14 13 m 5.22 6.22 b 5.51 5.93 5.99 5.93 6.28 6.22 l 9.5 9.44 9.5 7.75 b 9.5 7.34 9.84 7 10.25 7 10.66 7 11 7.34 11 7.75 l 11 11.25 b 11 11.66 10.66 12 10.25 12 l 6.75 12 b 6.34 12 6 11.66 6 11.25 6 10.84 6.34 10.5 6.75 10.5 l 8.44 10.5 5.22 7.28 b 4.93 6.99 4.93 6.51 5.22 6.22",
    ["fluent_picture_in_picture_enter_filled"] = "m 5.25 3 b 3.46 3 2 4.46 2 6.25 l 2 15.75 b 2 17.54 3.46 19 5.25 19 l 11 19 11 15 b 11 13.34 12.34 12 14 12 l 21 12 b 21.35 12 21.69 12.06 22 12.17 l 22 6.25 b 22 4.46 20.54 3 18.75 3 l 5.25 3 m 6.28 6.22 l 9.5 9.44 9.5 7.75 b 9.5 7.34 9.84 7 10.25 7 10.66 7 11 7.34 11 7.75 l 11 11.25 b 11 11.66 10.66 12 10.25 12 l 6.75 12 b 6.34 12 6 11.66 6 11.25 6 10.84 6.34 10.5 6.75 10.5 l 8.44 10.5 5.22 7.28 b 4.93 6.99 4.93 6.51 5.22 6.22 5.51 5.93 5.99 5.93 6.28 6.22 m 22 13.27 b 21.71 13.1 21.36 13 21 13 l 14 13 b 12.9 13 12 13.9 12 15 l 12 20 b 12 21.1 12.9 22 14 22 l 21 22 b 22.1 22 23 21.1 23 20 l 23 15 b 23 14.26 22.6 13.61 22 13.27",
    ["fluent_pip_exit"] = "m 10 11 b 10.35 11 10.7 10.91 11 10.73 11.3 10.56 11.56 10.3 11.73 10 11.91 9.7 12 9.35 12 9 l 12 4 b 12 3.65 11.91 3.3 11.73 3 11.56 2.7 11.3 2.44 11 2.27 10.7 2.09 10.35 2 10 2 l 3 2 b 2.65 2 2.3 2.09 2 2.27 1.7 2.44 1.44 2.7 1.27 3 1.09 3.3 1 3.65 1 4 l 1 9 b 1 9.35 1.09 9.7 1.27 10 1.44 10.3 1.7 10.56 2 10.73 2.3 10.91 2.65 11 3 11 l 10 11 m 18.75 6.5 l 13 6.5 13 5 18.75 5 b 19.32 5 19.88 5.15 20.38 5.44 20.87 5.72 21.28 6.13 21.56 6.62 21.85 7.12 22 7.68 22 8.25 l 22 17.75 b 22 18.32 21.85 18.88 21.56 19.38 21.28 19.87 20.87 20.28 20.38 20.56 19.88 20.85 19.32 21 18.75 21 l 5.25 21 b 4.68 21 4.12 20.85 3.63 20.56 3.13 20.28 2.72 19.87 2.44 19.38 2.15 18.88 2 18.32 2 17.75 l 2 11.83 b 2.31 11.94 2.65 12 3 12 l 3.5 12 3.5 17.75 b 3.5 18.72 4.28 19.5 5.25 19.5 l 18.75 19.5 b 19.06 19.5 19.36 19.42 19.62 19.27 19.89 19.11 20.11 18.89 20.27 18.62 20.42 18.36 20.5 18.06 20.5 17.75 l 20.5 8.25 b 20.5 7.94 20.42 7.64 20.27 7.38 20.11 7.11 19.89 6.89 19.62 6.73 19.36 6.58 19.06 6.5 18.75 6.5 m 15.56 12.5 l 17.25 12.5 b 17.38 12.5 17.51 12.47 17.62 12.4 17.74 12.33 17.83 12.24 17.9 12.12 17.97 12.01 18 11.88 18 11.75 18 11.62 17.97 11.49 17.9 11.38 17.83 11.26 17.74 11.17 17.62 11.1 17.51 11.03 17.38 11 17.25 11 l 13.75 11 b 13.62 11 13.49 11.03 13.37 11.1 13.26 11.17 13.17 11.26 13.1 11.38 13.03 11.49 13 11.62 13 11.75 l 13 15.25 b 13 15.38 13.03 15.51 13.1 15.63 13.17 15.74 13.26 15.83 13.38 15.9 13.49 15.97 13.62 16 13.75 16 13.88 16 14.01 15.97 14.12 15.9 14.24 15.83 14.33 15.74 14.4 15.63 14.47 15.51 14.5 15.38 14.5 15.25 l 14.5 13.56 17.22 16.28 b 17.3 16.36 17.4 16.43 17.5 16.47 17.61 16.51 17.73 16.53 17.84 16.52 17.96 16.5 18.07 16.47 18.16 16.41 18.26 16.34 18.34 16.26 18.41 16.16 18.47 16.07 18.5 15.96 18.52 15.84 18.53 15.73 18.51 15.61 18.47 15.5 18.43 15.4 18.36 15.3 18.28 15.22 l 15.56 12.5",
    ["fluent_pip_exit_filled"] = "m 10 11 b 10.35 11 10.7 10.91 11 10.73 11.3 10.56 11.56 10.3 11.73 10 11.91 9.7 12 9.35 12 9 l 12 4 b 12 3.65 11.91 3.3 11.73 3 11.56 2.7 11.3 2.44 11 2.27 10.7 2.09 10.35 2 10 2 l 3 2 b 2.65 2 2.3 2.09 2 2.27 1.7 2.44 1.44 2.7 1.27 3 1.09 3.3 1 3.65 1 4 l 1 9 b 1 9.35 1.09 9.7 1.27 10 1.44 10.3 1.7 10.56 2 10.73 2.3 10.91 2.65 11 3 11 l 10 11 m 10 12 l 3 12 b 2.65 12 2.31 11.94 2 11.83 l 2 17.75 b 2 18.32 2.15 18.88 2.44 19.38 2.72 19.87 3.13 20.28 3.62 20.56 4.12 20.85 4.68 21 5.25 21 l 18.75 21 b 19.32 21 19.88 20.85 20.38 20.56 20.87 20.28 21.28 19.87 21.56 19.38 21.85 18.88 22 18.32 22 17.75 l 22 8.25 b 22 7.68 21.85 7.12 21.56 6.62 21.28 6.13 20.87 5.72 20.38 5.44 19.88 5.15 19.32 5 18.75 5 l 13 5 13 9 b 13 9.53 12.86 10.04 12.6 10.5 12.33 10.96 11.96 11.33 11.5 11.6 11.04 11.86 10.53 12 10 12 m 17.75 14 l 16.06 14 18.78 16.72 b 18.86 16.8 18.93 16.9 18.97 17 19.01 17.11 19.03 17.23 19.02 17.34 19 17.46 18.97 17.57 18.91 17.66 18.84 17.76 18.76 17.84 18.66 17.91 18.57 17.97 18.46 18 18.34 18.02 18.23 18.03 18.11 18.01 18 17.97 17.9 17.93 17.8 17.86 17.72 17.78 l 15 15.06 15 16.75 b 15 16.88 14.97 17.01 14.9 17.12 14.83 17.24 14.74 17.33 14.62 17.4 14.51 17.47 14.38 17.5 14.25 17.5 14.12 17.5 13.99 17.47 13.88 17.4 13.76 17.33 13.67 17.24 13.6 17.12 13.53 17.01 13.5 16.88 13.5 16.75 l 13.5 13.25 b 13.5 12.84 13.84 12.5 14.25 12.5 l 17.75 12.5 b 17.88 12.5 18.01 12.53 18.12 12.6 18.24 12.67 18.33 12.76 18.4 12.88 18.47 12.99 18.5 13.12 18.5 13.25 18.5 13.38 18.47 13.51 18.4 13.62 18.33 13.74 18.24 13.83 18.12 13.9 18.01 13.97 17.88 14 17.75 14",
    ["fluent_play"] = "m 7.61 4.61 b 7.11 4.34 6.5 4.7 6.5 5.27 l 6.5 18.73 b 6.5 19.29 7.11 19.66 7.61 19.38 l 19.97 12.66 b 20.49 12.37 20.49 11.63 19.97 11.34 l 7.61 4.61 m 5 5.27 b 5 3.57 6.83 2.48 8.33 3.3 l 20.69 10.02 b 22.25 10.88 22.25 13.12 20.69 13.98 l 8.33 20.7 b 6.83 21.52 5 20.43 5 18.73 l 5 5.27",
    ["fluent_play_filled"] = "m 5 5.27 b 5 3.57 6.83 2.48 8.33 3.3 l 20.69 10.02 b 22.25 10.88 22.25 13.12 20.69 13.98 l 8.33 20.7 b 6.83 21.52 5 20.43 5 18.73 l 5 5.27",
    ["fluent_playlist"] = "m 4 6.25 b 4 5.84 4.34 5.5 4.75 5.5 l 19.25 5.5 b 19.66 5.5 20 5.84 20 6.25 20 6.66 19.66 7 19.25 7 l 4.75 7 b 4.34 7 4 6.66 4 6.25 m 4 12.25 b 4 11.84 4.34 11.5 4.75 11.5 l 19.25 11.5 b 19.66 11.5 20 11.84 20 12.25 20 12.66 19.66 13 19.25 13 l 4.75 13 b 4.34 13 4 12.66 4 12.25 m 4 18.25 b 4 17.84 4.34 17.5 4.75 17.5 l 11.25 17.5 b 11.66 17.5 12 17.84 12 18.25 12 18.66 11.66 19 11.25 19 l 4.75 19 b 4.34 19 4 18.66 4 18.25 m 16.54 14.36 b 15.75 13.86 14.75 14.43 14.75 15.36 l 14.75 19.64 b 14.75 20.57 15.75 21.14 16.54 20.64 l 19.9 18.5 b 20.64 18.03 20.64 16.97 19.9 16.5 l 16.54 14.36 m 16.25 16.25 l 16.25 18.75 b 16.25 18.98 16.49 19.1 16.68 18.97 l 18.68 17.72 b 18.86 17.61 18.86 17.39 18.68 17.28 l 16.68 16.03 b 16.49 15.9 16.25 16.02 16.25 16.25",
    ["fluent_playlist_filled"] = "m 5 5 l 19 5 b 19.18 5 19.35 5.05 19.5 5.13 19.65 5.22 19.78 5.35 19.87 5.5 19.95 5.65 20 5.82 20 6 20 6.18 19.95 6.35 19.87 6.5 19.78 6.65 19.65 6.78 19.5 6.87 19.35 6.95 19.18 7 19 7 l 5 7 b 4.82 7 4.65 6.95 4.5 6.87 4.35 6.78 4.22 6.65 4.13 6.5 4.05 6.35 4 6.18 4 6 4 5.82 4.05 5.65 4.13 5.5 4.22 5.35 4.35 5.22 4.5 5.13 4.65 5.05 4.82 5 5 5 m 5 11 l 19 11 b 19.18 11 19.35 11.05 19.5 11.13 19.65 11.22 19.78 11.35 19.87 11.5 19.95 11.65 20 11.82 20 12 20 12.18 19.95 12.35 19.87 12.5 19.78 12.65 19.65 12.78 19.5 12.87 19.35 12.95 19.18 13 19 13 l 5 13 b 4.82 13 4.65 12.95 4.5 12.87 4.35 12.78 4.22 12.65 4.13 12.5 4.05 12.35 4 12.18 4 12 4 11.82 4.05 11.65 4.13 11.5 4.22 11.35 4.35 11.22 4.5 11.13 4.65 11.05 4.82 11 5 11 m 5 17 l 11 17 b 11.18 17 11.35 17.05 11.5 17.13 11.65 17.22 11.78 17.35 11.87 17.5 11.95 17.65 12 17.82 12 18 12 18.18 11.95 18.35 11.87 18.5 11.78 18.65 11.65 18.78 11.5 18.87 11.35 18.95 11.18 19 11 19 l 5 19 b 4.82 19 4.65 18.95 4.5 18.87 4.35 18.78 4.22 18.65 4.13 18.5 4.05 18.35 4 18.18 4 18 4 17.82 4.05 17.65 4.13 17.5 4.22 17.35 4.35 17.22 4.5 17.13 4.65 17.05 4.82 17 5 17 m 16.54 14.36 b 15.75 13.86 14.75 14.43 14.75 15.36 l 14.75 19.64 b 14.75 20.57 15.75 21.14 16.54 20.64 l 19.9 18.5 b 20.64 18.03 20.64 16.97 19.9 16.5 l 16.54 14.36",
    ["fluent_previous"] = "m 21 4.75 b 21 3.35 19.42 2.51 18.26 3.31 l 7.76 10.5 b 6.75 11.19 6.75 12.68 7.75 13.38 l 18.25 20.68 b 19.41 21.49 21 20.66 21 19.25 l 21 4.75 m 19.11 4.55 b 19.27 4.43 19.5 4.55 19.5 4.75 l 19.5 19.25 b 19.5 19.45 19.27 19.57 19.11 19.45 l 8.61 12.15 b 8.47 12.05 8.47 11.84 8.61 11.74 l 19.11 4.55 m 3 3.75 b 3 3.34 3.34 3 3.75 3 4.16 3 4.5 3.34 4.5 3.75 l 4.5 20.25 b 4.5 20.66 4.16 21 3.75 21 3.34 21 3 20.66 3 20.25 l 3 3.75",
    ["fluent_previous_filled"] = "m 3 3.75 b 3 3.34 3.34 3 3.75 3 4.16 3 4.5 3.34 4.5 3.75 l 4.5 20.25 b 4.5 20.66 4.16 21 3.75 21 3.34 21 3 20.66 3 20.25 l 3 3.75 m 21 4.75 b 21 3.35 19.42 2.51 18.26 3.31 l 7.76 10.5 b 6.75 11.19 6.75 12.68 7.75 13.38 l 18.25 20.68 b 19.41 21.49 21 20.66 21 19.25 l 21 4.75",
    ["fluent_replay"] = "m 12 3.5 b 9.4 3.5 7.08 4.66 5.52 6.5 l 7.25 6.5 b 7.66 6.5 8 6.84 8 7.25 8 7.66 7.66 8 7.25 8 l 3.75 8 b 3.34 8 3 7.66 3 7.25 l 3 3.75 b 3 3.34 3.34 3 3.75 3 4.16 3 4.5 3.34 4.5 3.75 l 4.5 5.39 b 6.33 3.31 9.01 2 12 2 17.52 2 22 6.48 22 12 22 17.52 17.52 22 12 22 6.48 22 2 17.52 2 12 2 11.52 2.03 11.05 2.1 10.59 2.15 10.25 2.45 10 2.8 10 3.28 10 3.63 10.45 3.57 10.92 3.52 11.27 3.5 11.63 3.5 12 3.5 16.69 7.31 20.5 12 20.5 16.69 20.5 20.5 16.69 20.5 12 20.5 7.31 16.69 3.5 12 3.5 m 11.23 8.19 b 10.23 7.63 9 8.36 9 9.5 l 9 14.5 b 9 15.64 10.23 16.37 11.23 15.81 l 15.73 13.31 b 16.76 12.74 16.76 11.26 15.73 10.69 l 11.23 8.19 m 10.5 9.5 l 15 12 10.5 14.5 10.5 9.5",
    ["fluent_replay_filled"] = "m 4.5 5.39 b 6.33 3.31 9.01 2 12 2 17.52 2 22 6.48 22 12 22 17.52 17.52 22 12 22 6.48 22 2 17.52 2 12 2 11.52 2.03 11.05 2.1 10.59 2.15 10.25 2.45 10 2.8 10 3.28 10 3.63 10.45 3.57 10.92 3.52 11.27 3.5 11.63 3.5 12 3.5 16.69 7.31 20.5 12 20.5 16.69 20.5 20.5 16.69 20.5 12 20.5 7.31 16.69 3.5 12 3.5 9.4 3.5 7.08 4.66 5.52 6.5 l 7.25 6.5 b 7.66 6.5 8 6.84 8 7.25 8 7.66 7.66 8 7.25 8 l 3.75 8 b 3.34 8 3 7.66 3 7.25 l 3 3.75 b 3 3.34 3.34 3 3.75 3 4.16 3 4.5 3.34 4.5 3.75 l 4.5 5.39 m 11.23 8.19 b 10.23 7.63 9 8.36 9 9.5 l 9 14.5 b 9 15.64 10.23 16.37 11.23 15.81 l 15.73 13.31 b 16.76 12.74 16.76 11.26 15.73 10.69 l 11.23 8.19",
    ["fluent_rewind"] = "m 12.5 5.5 b 12.5 4.22 11 3.53 10.03 4.36 l 2.62 10.67 b 1.8 11.37 1.8 12.63 2.62 13.33 l 10.03 19.64 b 11 20.47 12.5 19.77 12.5 18.5 l 12.5 14.51 18.53 19.64 b 19.5 20.47 21 19.78 21 18.5 l 21 5.5 b 21 4.22 19.5 3.53 18.53 4.36 l 12.5 9.49 12.5 5.5 m 12.5 12.54 l 12.5 11.46 19.5 5.5 19.5 18.5 12.5 12.54 m 3.59 11.81 l 11 5.5 11 18.5 3.59 12.19 b 3.47 12.09 3.47 11.91 3.59 11.81",
    ["fluent_rewind_filled"] = "m 10.03 4.36 b 11 3.53 12.5 4.22 12.5 5.5 l 12.5 9.49 18.53 4.36 b 19.5 3.53 21 4.23 21 5.51 l 21 18.5 b 21 19.38 20.29 19.98 19.54 20 l 19.45 20 b 19.13 19.99 18.81 19.88 18.53 19.64 l 12.5 14.51 12.5 18.5 b 12.5 19.78 11 20.47 10.03 19.64 l 2.62 13.33 b 1.8 12.63 1.8 11.37 2.62 10.67 l 10.03 4.36 m 2.62 10.67 l 3.11 11.24 2.62 10.67",
    ["fluent_skip_back_10"] = "m 2.75 2.5 b 2.34 2.5 2 2.84 2 3.25 l 2 8.75 b 2 9.16 2.34 9.5 2.75 9.5 l 8.25 9.5 b 8.66 9.5 9 9.16 9 8.75 9 8.34 8.66 8 8.25 8 l 4.34 8 b 5.4 6.6 6.77 5.46 8.47 4.94 10.54 4.3 12.72 4.35 14.74 5.1 16.77 5.86 18.65 7.39 19.59 9.11 19.79 9.47 20.25 9.61 20.61 9.41 20.97 9.21 21.11 8.75 20.91 8.39 19.77 6.31 17.58 4.56 15.26 3.7 12.93 2.83 10.41 2.77 8.03 3.51 6.15 4.09 4.65 5.26 3.5 6.65 l 3.5 3.25 b 3.5 2.84 3.16 2.5 2.75 2.5 m 8.95 11.03 b 9.28 11.12 9.5 11.41 9.5 11.75 l 9.5 20.25 b 9.5 20.66 9.16 21 8.75 21 8.34 21 8 20.66 8 20.25 l 8 13.83 b 7.62 14.2 7.16 14.58 6.64 14.89 6.28 15.11 5.82 14.99 5.61 14.64 5.39 14.28 5.51 13.82 5.86 13.61 6.54 13.2 7.1 12.64 7.51 12.17 7.71 11.93 7.86 11.73 7.96 11.58 8.01 11.51 8.05 11.45 8.08 11.41 8.09 11.39 8.1 11.38 8.1 11.37 l 8.11 11.36 8.11 11.36 b 8.29 11.07 8.63 10.94 8.95 11.03 m 13.2 12.63 b 13.75 11.64 14.68 11 16 11 17.32 11 18.25 11.64 18.81 12.63 19.33 13.56 19.5 14.78 19.5 16 19.5 17.22 19.33 18.44 18.81 19.37 18.25 20.36 17.32 21 16 21 14.68 21 13.75 20.36 13.2 19.37 12.68 18.44 12.5 17.22 12.5 16 12.5 14.78 12.68 13.56 13.2 12.63 m 14.51 13.36 b 14.17 13.97 14 14.88 14 16 14 17.12 14.17 18.03 14.51 18.64 14.81 19.19 15.26 19.5 16 19.5 16.74 19.5 17.19 19.19 17.5 18.64 17.83 18.03 18 17.12 18 16 18 14.88 17.83 13.97 17.5 13.36 17.19 12.81 16.74 12.5 16 12.5 15.26 12.5 14.81 12.81 14.51 13.36",
    ["fluent_skip_back_10_filled"] = "m 3 2.25 b 2.45 2.25 2 2.7 2 3.25 l 2 9 b 2 9.55 2.45 10 3 10 l 8.25 10 b 8.8 10 9.25 9.55 9.25 9 9.25 8.45 8.8 8 8.25 8 l 4.86 8 b 5.85 6.82 7.07 5.89 8.55 5.43 10.56 4.81 12.69 4.86 14.65 5.59 16.63 6.33 18.46 7.82 19.37 9.48 19.64 9.97 20.25 10.15 20.73 9.88 21.21 9.61 21.39 9.01 21.13 8.52 19.95 6.38 17.71 4.6 15.35 3.72 12.97 2.83 10.38 2.77 7.95 3.52 6.38 4.01 5.07 4.9 4 5.98 l 4 3.25 b 4 2.7 3.55 2.25 3 2.25 m 9.75 12 b 9.75 11.58 9.49 11.21 9.09 11.06 8.7 10.92 8.26 11.03 7.99 11.35 7.91 11.44 7.84 11.53 7.77 11.62 7.25 12.24 6.69 12.92 5.49 13.64 5.01 13.93 4.86 14.54 5.14 15.01 5.43 15.49 6.04 15.64 6.51 15.36 7 15.07 7.4 14.78 7.75 14.49 l 7.75 20 b 7.75 20.55 8.2 21 8.75 21 9.3 21 9.75 20.55 9.75 20 l 9.75 12 m 16.25 11 b 14.86 11 13.85 11.64 13.24 12.66 12.68 13.61 12.5 14.82 12.5 16 12.5 17.18 12.68 18.39 13.24 19.34 13.85 20.36 14.86 21 16.25 21 17.64 21 18.65 20.36 19.26 19.34 19.82 18.39 20 17.18 20 16 20 14.82 19.82 13.61 19.26 12.66 18.65 11.64 17.64 11 16.25 11 m 14.5 16 b 14.5 14.97 14.67 14.18 14.96 13.68 15.21 13.26 15.57 13 16.25 13 16.93 13 17.29 13.26 17.54 13.68 17.83 14.18 18 14.97 18 16 18 17.03 17.83 17.82 17.54 18.32 17.29 18.74 16.93 19 16.25 19 15.57 19 15.21 18.74 14.96 18.32 14.67 17.82 14.5 17.03 14.5 16",
    ["fluent_skip_back_30"] = "m 3.84 2.5 b 3.71 2.5 3.58 2.53 3.47 2.6 3.35 2.67 3.26 2.76 3.19 2.88 3.13 2.99 3.09 3.12 3.09 3.25 l 3.09 8.75 b 3.09 9.16 3.43 9.5 3.84 9.5 l 9.34 9.5 b 9.47 9.5 9.6 9.47 9.72 9.4 9.83 9.33 9.93 9.24 9.99 9.12 10.06 9.01 10.09 8.88 10.09 8.75 10.09 8.62 10.06 8.49 9.99 8.38 9.93 8.26 9.83 8.17 9.72 8.1 9.6 8.03 9.47 8 9.34 8 l 5.43 8 b 6.49 6.6 7.86 5.46 9.56 4.94 10.58 4.62 11.65 4.47 12.71 4.5 13.78 4.53 14.83 4.73 15.83 5.1 17.86 5.86 19.74 7.39 20.68 9.11 20.75 9.22 20.84 9.32 20.95 9.38 21.07 9.45 21.19 9.49 21.32 9.49 21.45 9.49 21.58 9.46 21.7 9.39 21.81 9.33 21.91 9.24 21.97 9.13 22.04 9.02 22.08 8.89 22.08 8.76 22.09 8.63 22.06 8.51 22 8.39 20.86 6.31 18.67 4.56 16.35 3.7 15.2 3.27 13.98 3.03 12.75 3 11.52 2.97 10.3 3.14 9.12 3.51 7.24 4.09 5.75 5.26 4.59 6.65 l 4.59 3.25 b 4.59 3.12 4.56 2.99 4.49 2.88 4.43 2.76 4.33 2.67 4.22 2.6 4.1 2.54 3.97 2.5 3.84 2.5 l 3.84 2.5 m 8.75 15.25 b 9.51 15.25 10 15.03 10.29 14.78 10.57 14.52 10.69 14.21 10.68 13.9 10.66 13.35 10.14 12.5 8.5 12.5 7.78 12.5 7.22 12.72 6.84 12.93 6.69 13.02 6.54 13.12 6.41 13.23 6.36 13.27 6.33 13.29 6.31 13.31 l 6.29 13.33 6.29 13.33 b 6.2 13.42 6.09 13.49 5.96 13.53 5.84 13.56 5.71 13.56 5.58 13.53 5.45 13.5 5.34 13.44 5.24 13.35 5.15 13.26 5.08 13.15 5.04 13.02 5 12.9 5 12.77 5.03 12.64 5.06 12.51 5.12 12.4 5.2 12.3 l 5.21 12.29 5.23 12.27 b 5.3 12.2 5.38 12.13 5.46 12.07 5.66 11.9 5.87 11.76 6.1 11.63 6.83 11.21 7.66 11 8.5 11 10.71 11 12.13 12.27 12.18 13.85 12.19 14.24 12.12 14.62 11.96 14.97 11.81 15.33 11.58 15.64 11.29 15.9 11.24 15.93 11.2 15.97 11.16 16 11.2 16.03 11.25 16.07 11.29 16.1 11.9 16.65 12.21 17.39 12.18 18.15 12.13 19.73 10.71 21 8.5 21 7.66 21 6.83 20.79 6.1 20.37 5.8 20.2 5.53 20.01 5.28 19.78 l 5.23 19.73 5.21 19.71 5.2 19.7 b 5.2 19.7 4.74 19.11 5.24 18.64 5.33 18.55 5.45 18.49 5.58 18.46 5.7 18.43 5.84 18.43 5.96 18.47 6.09 18.5 6.2 18.57 6.29 18.67 l 6.29 18.67 6.31 18.69 b 6.33 18.71 6.36 18.73 6.41 18.77 6.5 18.85 6.65 18.96 6.84 19.07 7.22 19.28 7.78 19.5 8.5 19.5 10.14 19.5 10.66 18.65 10.68 18.1 10.69 17.93 10.65 17.77 10.58 17.62 10.52 17.47 10.42 17.33 10.29 17.22 10 16.97 9.51 16.75 8.75 16.75 8.62 16.75 8.49 16.72 8.38 16.65 8.26 16.58 8.17 16.49 8.1 16.38 8.03 16.26 8 16.13 8 16 8 15.87 8.03 15.74 8.1 15.63 8.17 15.51 8.26 15.42 8.38 15.35 8.49 15.28 8.62 15.25 8.75 15.25 m 14.2 12.63 b 14.75 11.64 15.68 11 17 11 18.32 11 19.25 11.64 19.8 12.63 20.33 13.56 20.5 14.78 20.5 16 20.5 17.22 20.33 18.44 19.8 19.37 19.25 20.36 18.32 21 17 21 15.68 21 14.75 20.36 14.2 19.37 13.68 18.44 13.5 17.22 13.5 16 13.5 14.78 13.68 13.56 14.2 12.63 m 15.51 13.36 b 15.17 13.97 15 14.88 15 16 15 17.12 15.17 18.04 15.51 18.64 15.81 19.19 16.26 19.5 17 19.5 17.75 19.5 18.19 19.19 18.5 18.64 18.83 18.03 19 17.12 19 16 19 14.88 18.83 13.97 18.5 13.36 18.19 12.81 17.74 12.5 17 12.5 16.26 12.5 15.81 12.81 15.51 13.36",
    ["fluent_skip_back_30_filled"] = "m 3.87 2.25 b 3.7 2.25 3.53 2.3 3.37 2.38 3.22 2.47 3.09 2.6 3.01 2.75 2.92 2.9 2.87 3.07 2.87 3.25 l 2.87 9 b 2.87 9.18 2.92 9.35 3.01 9.5 3.09 9.65 3.22 9.78 3.37 9.87 3.53 9.95 3.7 10 3.87 10 l 9.12 10 b 9.3 10 9.47 9.95 9.62 9.87 9.78 9.78 9.9 9.65 9.99 9.5 10.08 9.35 10.12 9.18 10.12 9 10.12 8.82 10.08 8.65 9.99 8.5 9.9 8.35 9.78 8.22 9.62 8.13 9.47 8.05 9.3 8 9.12 8 l 5.74 8 b 6.72 6.82 7.95 5.89 9.42 5.43 10.41 5.12 11.45 4.98 12.49 5 13.52 5.03 14.55 5.23 15.53 5.59 17.51 6.33 19.34 7.82 20.25 9.48 20.32 9.62 20.42 9.73 20.54 9.82 20.66 9.9 20.8 9.96 20.95 9.99 21.1 10.01 21.25 10.01 21.4 9.97 21.54 9.92 21.67 9.85 21.79 9.75 21.9 9.65 21.99 9.53 22.05 9.39 22.1 9.25 22.13 9.1 22.12 8.95 22.11 8.8 22.07 8.65 22 8.52 20.82 6.38 18.59 4.6 16.22 3.72 15.04 3.28 13.8 3.04 12.54 3 11.28 2.97 10.03 3.14 8.83 3.52 7.25 4.01 5.94 4.9 4.87 5.98 l 4.87 3.25 b 4.87 3.07 4.83 2.9 4.74 2.75 4.65 2.6 4.53 2.47 4.37 2.38 4.22 2.3 4.05 2.25 3.87 2.25 m 6.46 13.71 b 6.61 13.55 6.76 13.4 7.03 13.27 7.31 13.14 7.75 13 8.5 13 10.11 13 10.42 13.77 10.43 14.04 10.44 14.28 10.22 15 8.75 15 8.57 15 8.4 15.05 8.25 15.13 8.1 15.22 7.97 15.35 7.88 15.5 7.8 15.65 7.75 15.82 7.75 16 7.75 16.18 7.8 16.35 7.88 16.5 7.97 16.65 8.1 16.78 8.25 16.87 8.4 16.95 8.57 17 8.75 17 10.22 17 10.44 17.72 10.43 17.96 10.42 18.23 10.11 19 8.5 19 7.75 19 7.31 18.86 7.03 18.73 6.82 18.62 6.62 18.47 6.46 18.29 6.33 18.17 6.18 18.08 6.01 18.03 5.84 17.99 5.66 17.99 5.49 18.03 5.32 18.08 5.17 18.17 5.04 18.29 4.92 18.42 4.83 18.57 4.78 18.74 4.74 18.91 4.74 19.09 4.78 19.26 4.83 19.43 4.92 19.58 5.04 19.71 l 5.05 19.72 b 5.24 19.9 5.58 20.25 6.16 20.53 6.74 20.81 7.49 21 8.5 21 10.74 21 12.37 19.77 12.43 18.04 12.45 17.65 12.38 17.28 12.23 16.92 12.09 16.57 11.87 16.26 11.59 16 11.87 15.74 12.09 15.43 12.23 15.07 12.38 14.72 12.45 14.34 12.43 13.96 12.37 12.23 10.74 11 8.5 11 7.49 11 6.74 11.19 6.16 11.47 5.58 11.75 5.24 12.1 5.05 12.28 l 5.04 12.29 b 4.93 12.42 4.85 12.57 4.81 12.74 4.77 12.9 4.77 13.08 4.81 13.24 4.86 13.41 4.95 13.56 5.07 13.68 5.19 13.8 5.34 13.89 5.5 13.93 5.67 13.98 5.84 13.98 6.01 13.95 6.18 13.91 6.33 13.82 6.46 13.71 m 14.24 12.66 b 14.85 11.63 15.86 11 17.25 11 18.64 11 19.65 11.63 20.26 12.66 20.82 13.61 21 14.82 21 16 21 17.18 20.82 18.39 20.26 19.34 19.65 20.36 18.64 21 17.25 21 15.86 21 14.85 20.36 14.24 19.34 13.68 18.39 13.5 17.18 13.5 16 13.5 14.82 13.68 13.61 14.24 12.66 m 15.96 13.68 b 15.67 14.18 15.5 14.97 15.5 16 15.5 17.03 15.67 17.82 15.96 18.32 16.21 18.74 16.57 19 17.25 19 17.93 19 18.29 18.74 18.54 18.32 18.83 17.82 19 17.03 19 16 19 14.97 18.83 14.18 18.54 13.68 18.29 13.26 17.93 13 17.25 13 16.57 13 16.21 13.26 15.96 13.68",
    ["fluent_skip_back_5"] = "m 2 3.25 b 2 3.12 2.03 2.99 2.1 2.88 2.17 2.76 2.26 2.67 2.37 2.6 2.49 2.53 2.62 2.5 2.75 2.5 2.88 2.5 3.01 2.53 3.12 2.6 3.24 2.67 3.33 2.76 3.4 2.88 3.47 2.99 3.5 3.12 3.5 3.25 l 3.5 6.65 b 4.65 5.26 6.15 4.09 8.03 3.5 9.2 3.14 10.43 2.97 11.66 3 12.89 3.03 14.11 3.27 15.26 3.7 17.58 4.56 19.77 6.31 20.91 8.39 20.97 8.5 21 8.63 20.99 8.76 20.99 8.89 20.95 9.02 20.88 9.13 20.81 9.24 20.72 9.33 20.6 9.39 20.49 9.46 20.36 9.49 20.23 9.49 20.1 9.48 19.97 9.45 19.86 9.38 19.75 9.32 19.66 9.22 19.59 9.11 18.65 7.39 16.77 5.86 14.74 5.1 13.74 4.73 12.68 4.53 11.62 4.5 10.55 4.47 9.49 4.62 8.47 4.94 6.77 5.46 5.4 6.6 4.34 8 l 8.25 8 b 8.38 8 8.51 8.03 8.62 8.1 8.74 8.17 8.83 8.26 8.9 8.37 8.96 8.49 9 8.62 9 8.75 9 8.88 8.96 9.01 8.9 9.12 8.83 9.24 8.74 9.33 8.62 9.4 8.51 9.46 8.38 9.5 8.25 9.5 l 2.75 9.5 b 2.62 9.5 2.49 9.46 2.37 9.4 2.26 9.33 2.17 9.24 2.1 9.12 2.03 9.01 2 8.88 2 8.75 l 2 3.25 2 3.25 m 13.6 12.5 b 13.73 12.5 13.86 12.47 13.97 12.4 14.09 12.33 14.18 12.24 14.25 12.12 14.31 12.01 14.35 11.88 14.35 11.75 14.35 11.62 14.31 11.49 14.25 11.38 14.18 11.26 14.09 11.17 13.97 11.1 13.86 11.03 13.73 11 13.6 11 l 10.05 11 b 9.93 11 9.81 11.03 9.71 11.08 9.6 11.14 9.51 11.22 9.44 11.32 9.37 11.42 9.32 11.53 9.31 11.65 l 8.91 14.65 b 8.89 14.76 8.9 14.86 8.93 14.97 8.96 15.07 9.02 15.16 9.09 15.24 9.16 15.32 9.24 15.39 9.34 15.43 9.44 15.48 9.54 15.5 9.65 15.5 l 11.82 15.5 b 11.92 15.5 12.02 15.51 12.13 15.52 12.47 15.57 12.79 15.7 13.06 15.91 13.34 16.12 13.55 16.4 13.69 16.71 13.82 17.03 13.87 17.37 13.84 17.71 13.8 18.05 13.68 18.38 13.48 18.66 13.28 18.94 13.01 19.16 12.7 19.31 12.39 19.46 12.04 19.52 11.7 19.5 11.36 19.47 11.03 19.36 10.74 19.17 10.46 18.98 10.22 18.72 10.07 18.41 10.02 18.31 9.95 18.22 9.86 18.14 9.77 18.07 9.66 18.02 9.55 18 9.44 17.97 9.32 17.97 9.21 18 9.1 18.03 8.99 18.08 8.9 18.16 8.82 18.23 8.75 18.33 8.7 18.43 8.65 18.54 8.63 18.65 8.64 18.77 8.64 18.88 8.68 18.99 8.73 19.1 9 19.62 9.4 20.08 9.9 20.41 10.39 20.74 10.96 20.94 11.55 20.99 12.14 21.04 12.73 20.94 13.28 20.7 13.82 20.46 14.29 20.08 14.65 19.61 15 19.13 15.23 18.58 15.31 17.99 15.39 17.49 15.35 16.98 15.2 16.5 15.06 16.01 14.81 15.57 14.48 15.19 14.14 14.81 13.73 14.51 13.27 14.3 12.81 14.1 12.31 13.99 11.8 14 l 10.51 14 10.71 12.5 13.6 12.5 13.6 12.5",
    ["fluent_skip_back_5_filled"] = "m 2 3.25 b 2 3.07 2.05 2.9 2.13 2.75 2.22 2.6 2.35 2.47 2.5 2.38 2.65 2.3 2.82 2.25 3 2.25 3.18 2.25 3.35 2.3 3.5 2.38 3.65 2.47 3.78 2.6 3.87 2.75 3.95 2.9 4 3.07 4 3.25 l 4 5.98 b 5.07 4.9 6.38 4.01 7.95 3.52 9.15 3.14 10.41 2.97 11.67 3 12.92 3.04 14.17 3.28 15.35 3.72 17.71 4.6 19.95 6.38 21.13 8.52 21.2 8.68 21.24 8.85 21.23 9.02 21.22 9.19 21.17 9.35 21.08 9.5 20.99 9.64 20.86 9.76 20.71 9.85 20.56 9.93 20.39 9.97 20.22 9.97 20.05 9.97 19.88 9.92 19.73 9.84 19.58 9.75 19.46 9.63 19.37 9.48 18.46 7.82 16.63 6.33 14.65 5.59 13.68 5.23 12.65 5.03 11.61 5 10.57 4.97 9.54 5.12 8.54 5.43 7.07 5.89 5.85 6.82 4.86 8 l 8.25 8 b 8.42 8 8.6 8.05 8.75 8.13 8.9 8.22 9.03 8.35 9.12 8.5 9.2 8.65 9.25 8.82 9.25 9 9.25 9.17 9.2 9.35 9.12 9.5 9.03 9.65 8.9 9.78 8.75 9.87 8.6 9.95 8.42 10 8.25 10 l 3 10 b 2.82 10 2.65 9.95 2.5 9.87 2.35 9.78 2.22 9.65 2.13 9.5 2.05 9.35 2 9.17 2 9 l 2 3.25 2 3.25 m 13 13 b 13.18 13 13.35 12.95 13.5 12.87 13.65 12.78 13.78 12.65 13.87 12.5 13.95 12.35 14 12.18 14 12 14 11.82 13.95 11.65 13.87 11.5 13.78 11.35 13.65 11.22 13.5 11.13 13.35 11.05 13.18 11 13 11 l 9.9 11 b 9.74 11 9.58 11.04 9.44 11.11 9.3 11.19 9.17 11.29 9.08 11.43 8.99 11.56 8.93 11.71 8.91 11.87 l 8.51 14.87 b 8.49 15.01 8.5 15.15 8.54 15.29 8.58 15.43 8.65 15.55 8.75 15.66 8.84 15.77 8.96 15.85 9.09 15.91 9.22 15.97 9.36 16 9.5 16 l 11.5 16 b 11.71 16 11.92 16.05 12.12 16.14 12.31 16.23 12.49 16.35 12.63 16.52 12.77 16.68 12.88 16.87 12.94 17.07 13 17.28 13.01 17.5 12.98 17.71 12.95 17.96 12.85 18.2 12.69 18.41 12.54 18.61 12.33 18.77 12.1 18.88 11.86 18.98 11.61 19.02 11.35 18.99 11.1 18.97 10.85 18.88 10.64 18.73 10.43 18.58 10.26 18.39 10.15 18.16 10.08 18.02 9.99 17.9 9.87 17.81 9.75 17.72 9.62 17.65 9.47 17.62 9.32 17.58 9.17 17.58 9.02 17.62 8.88 17.65 8.74 17.72 8.62 17.81 8.51 17.91 8.41 18.03 8.35 18.16 8.28 18.3 8.25 18.45 8.25 18.6 8.25 18.75 8.29 18.9 8.35 19.03 8.59 19.53 8.95 19.96 9.4 20.3 9.84 20.63 10.36 20.85 10.9 20.95 11.45 21.04 12.01 21.01 12.54 20.84 13.07 20.68 13.55 20.39 13.95 20 14.35 19.61 14.64 19.14 14.82 18.61 15 18.08 15.04 17.52 14.96 16.98 14.88 16.43 14.66 15.91 14.34 15.46 14.02 15.01 13.59 14.64 13.1 14.39 12.6 14.13 12.05 14 11.5 14 l 10.64 14 10.78 13 13 13 13 13",
    ["fluent_skip_back_tab"] = "m 2.75 3.25 b 2.75 2.7 3.2 2.25 3.75 2.25 4.3 2.25 4.75 2.7 4.75 3.25 l 4.75 5.98 b 5.82 4.9 7.13 4.01 8.7 3.52 11.13 2.77 13.72 2.83 16.1 3.72 18.46 4.6 20.7 6.38 21.88 8.52 22.14 9.01 21.96 9.61 21.48 9.88 21 10.15 20.39 9.97 20.12 9.48 19.21 7.82 17.38 6.33 15.4 5.59 13.44 4.86 11.31 4.81 9.3 5.43 7.82 5.89 6.6 6.82 5.61 8 l 9 8 b 9.55 8 10 8.45 10 9 10 9.55 9.55 10 9 10 l 3.75 10 b 3.2 10 2.75 9.55 2.75 9 l 2.75 3.25 m 18.75 15 b 18.75 13.9 17.85 13 16.75 13 l 8.75 13 b 7.65 13 6.75 13.9 6.75 15 l 6.75 19 b 6.75 20.1 7.65 21 8.75 21 l 16.75 21 b 17.85 21 18.75 20.1 18.75 19 l 18.75 15 m 16.75 15.5 l 16.75 18.5 b 16.75 18.78 16.53 19 16.25 19 l 9.25 19 b 8.97 19 8.75 18.78 8.75 18.5 l 8.75 15.5 b 8.75 15.22 8.97 15 9.25 15 l 16.25 15 b 16.53 15 16.75 15.22 16.75 15.5",
    ["fluent_skip_back_tab_filled"] = "m 2.75 3.25 b 2.75 2.7 3.2 2.25 3.75 2.25 4.3 2.25 4.75 2.7 4.75 3.25 l 4.75 5.98 b 5.82 4.9 7.13 4.01 8.7 3.52 11.13 2.77 13.72 2.83 16.1 3.72 18.46 4.6 20.7 6.38 21.88 8.52 22.14 9.01 21.96 9.61 21.48 9.88 21 10.15 20.39 9.97 20.12 9.48 19.21 7.82 17.38 6.33 15.4 5.59 13.44 4.86 11.31 4.81 9.3 5.43 7.82 5.89 6.6 6.82 5.61 8 l 9 8 b 9.55 8 10 8.45 10 9 10 9.55 9.55 10 9 10 l 3.75 10 b 3.2 10 2.75 9.55 2.75 9 l 2.75 3.25 m 18.75 15 b 18.75 13.9 17.85 13 16.75 13 l 8.75 13 b 7.65 13 6.75 13.9 6.75 15 l 6.75 19 b 6.75 20.1 7.65 21 8.75 21 l 16.75 21 b 17.85 21 18.75 20.1 18.75 19 l 18.75 15 m 16.75 15.5 l 16.75 18.5 b 16.75 18.78 16.53 19 16.25 19 l 9.25 19 b 8.97 19 8.75 18.78 8.75 18.5 l 8.75 15.5 b 8.75 15.22 8.97 15 9.25 15 l 16.25 15 b 16.53 15 16.75 15.22 16.75 15.5",
    ["fluent_skip_forward_10"] = "m 21.25 2.5 b 21.66 2.5 22 2.84 22 3.25 l 22 8.75 b 22 9.16 21.66 9.5 21.25 9.5 l 15.75 9.5 b 15.34 9.5 15 9.16 15 8.75 15 8.34 15.34 8 15.75 8 l 19.66 8 b 18.6 6.6 17.23 5.46 15.53 4.94 13.46 4.3 11.28 4.35 9.26 5.1 7.23 5.86 5.35 7.39 4.41 9.11 4.21 9.47 3.75 9.61 3.39 9.41 3.03 9.21 2.89 8.75 3.09 8.39 4.23 6.31 6.42 4.56 8.74 3.7 11.07 2.83 13.59 2.77 15.97 3.51 17.85 4.09 19.35 5.26 20.5 6.65 l 20.5 3.25 b 20.5 2.84 20.84 2.5 21.25 2.5 m 16 11 b 14.68 11 13.75 11.64 13.2 12.63 12.68 13.56 12.5 14.78 12.5 16 12.5 17.22 12.68 18.44 13.2 19.37 13.75 20.36 14.68 21 16 21 17.32 21 18.25 20.36 18.8 19.37 19.33 18.44 19.5 17.22 19.5 16 19.5 14.78 19.33 13.56 18.8 12.63 18.25 11.64 17.32 11 16 11 m 14 16 b 14 14.88 14.17 13.97 14.51 13.36 14.81 12.81 15.26 12.5 16 12.5 16.74 12.5 17.19 12.81 17.5 13.36 17.83 13.97 18 14.88 18 16 18 17.12 17.83 18.03 17.5 18.64 17.19 19.19 16.74 19.5 16 19.5 15.26 19.5 14.81 19.19 14.51 18.64 14.17 18.03 14 17.12 14 16 m 9.5 11.75 b 9.5 11.41 9.28 11.12 8.95 11.03 8.63 10.94 8.28 11.07 8.11 11.36 l 8.11 11.36 8.1 11.37 b 8.1 11.38 8.09 11.39 8.08 11.41 8.05 11.45 8.01 11.51 7.96 11.58 7.86 11.73 7.71 11.93 7.51 12.17 7.1 12.64 6.54 13.2 5.86 13.61 5.51 13.82 5.39 14.28 5.61 14.64 5.82 14.99 6.28 15.11 6.64 14.89 7.16 14.58 7.62 14.2 8 13.83 l 8 20.25 b 8 20.66 8.34 21 8.75 21 9.16 21 9.5 20.66 9.5 20.25 l 9.5 11.75",
    ["fluent_skip_forward_10_filled"] = "m 21 2.25 b 21.55 2.25 22 2.7 22 3.25 l 22 9 b 22 9.55 21.55 10 21 10 l 15.75 10 b 15.2 10 14.75 9.55 14.75 9 14.75 8.45 15.2 8 15.75 8 l 19.14 8 b 18.15 6.82 16.93 5.89 15.45 5.43 13.44 4.81 11.31 4.86 9.35 5.59 7.37 6.33 5.54 7.82 4.63 9.48 4.36 9.97 3.75 10.15 3.27 9.88 2.79 9.61 2.61 9.01 2.87 8.52 4.05 6.38 6.29 4.6 8.65 3.72 11.03 2.83 13.62 2.77 16.05 3.52 17.62 4.01 18.93 4.9 20 5.98 l 20 3.25 b 20 2.7 20.45 2.25 21 2.25 m 9.09 11.06 b 9.49 11.21 9.75 11.58 9.75 12 l 9.75 20 b 9.75 20.55 9.3 21 8.75 21 8.2 21 7.75 20.55 7.75 20 l 7.75 14.49 b 7.4 14.78 7 15.07 6.51 15.36 6.04 15.64 5.43 15.49 5.14 15.01 4.86 14.54 5.01 13.93 5.49 13.64 6.69 12.92 7.25 12.24 7.77 11.62 7.84 11.53 7.91 11.44 7.99 11.35 8.26 11.03 8.7 10.92 9.09 11.06 m 13.24 12.66 b 13.85 11.64 14.86 11 16.25 11 17.64 11 18.65 11.64 19.26 12.66 19.82 13.61 20 14.82 20 16 20 17.18 19.82 18.39 19.26 19.34 18.65 20.36 17.64 21 16.25 21 14.86 21 13.85 20.36 13.24 19.34 12.68 18.39 12.5 17.18 12.5 16 12.5 14.82 12.68 13.61 13.24 12.66 m 14.96 13.68 b 14.67 14.18 14.5 14.97 14.5 16 14.5 17.03 14.67 17.82 14.96 18.32 15.21 18.74 15.57 19 16.25 19 16.93 19 17.29 18.74 17.54 18.32 17.83 17.82 18 17.03 18 16 18 14.97 17.83 14.18 17.54 13.68 17.29 13.26 16.93 13 16.25 13 15.57 13 15.21 13.26 14.96 13.68",
    ["fluent_skip_forward_30"] = "m 21.25 2.5 b 21.66 2.5 22 2.84 22 3.25 l 22 8.75 b 22 9.16 21.66 9.5 21.25 9.5 l 15.75 9.5 b 15.34 9.5 15 9.16 15 8.75 15 8.34 15.34 8 15.75 8 l 19.66 8 b 18.6 6.6 17.23 5.46 15.53 4.94 13.46 4.3 11.28 4.35 9.26 5.1 7.23 5.86 5.35 7.39 4.41 9.11 4.21 9.47 3.75 9.61 3.39 9.41 3.03 9.21 2.89 8.75 3.09 8.39 4.23 6.31 6.42 4.56 8.74 3.7 11.07 2.83 13.59 2.77 15.97 3.5 17.85 4.09 19.35 5.26 20.5 6.65 l 20.5 3.25 b 20.5 2.84 20.84 2.5 21.25 2.5 m 8.75 15.25 b 9.51 15.25 10 15.03 10.29 14.78 10.57 14.52 10.69 14.2 10.68 13.9 10.66 13.35 10.14 12.5 8.5 12.5 7.78 12.5 7.22 12.72 6.84 12.93 6.65 13.04 6.5 13.15 6.41 13.23 6.36 13.26 6.33 13.29 6.31 13.31 6.3 13.32 6.3 13.33 6.29 13.33 l 6.29 13.33 b 6.01 13.63 5.54 13.64 5.24 13.36 4.93 13.07 4.92 12.6 5.2 12.3 l 5.2 12.3 5.21 12.3 5.21 12.29 5.21 12.29 5.23 12.27 b 5.24 12.26 5.26 12.24 5.28 12.22 5.32 12.18 5.38 12.13 5.46 12.07 5.61 11.94 5.82 11.79 6.1 11.63 6.65 11.31 7.47 11 8.5 11 10.71 11 12.13 12.27 12.18 13.85 12.21 14.61 11.9 15.35 11.29 15.9 11.24 15.93 11.2 15.97 11.16 16 11.2 16.03 11.24 16.07 11.29 16.1 11.9 16.65 12.21 17.39 12.18 18.15 12.13 19.73 10.71 21 8.5 21 7.47 21 6.65 20.69 6.1 20.37 5.82 20.21 5.61 20.06 5.46 19.93 5.38 19.87 5.32 19.82 5.28 19.78 5.26 19.76 5.24 19.74 5.23 19.73 l 5.21 19.71 5.21 19.71 5.21 19.7 5.2 19.7 5.2 19.7 b 5.2 19.7 4.74 19.11 5.24 18.64 5.54 18.36 6.01 18.37 6.29 18.67 l 6.29 18.67 b 6.3 18.67 6.3 18.68 6.31 18.69 6.33 18.71 6.36 18.74 6.41 18.77 6.5 18.85 6.65 18.96 6.84 19.07 7.22 19.28 7.78 19.5 8.5 19.5 10.14 19.5 10.66 18.65 10.68 18.1 10.69 17.8 10.57 17.48 10.29 17.22 10 16.97 9.51 16.75 8.75 16.75 8.34 16.75 8 16.41 8 16 8 15.59 8.34 15.25 8.75 15.25 m 14.2 12.63 b 14.75 11.64 15.68 11 17 11 18.32 11 19.25 11.64 19.81 12.63 20.33 13.56 20.5 14.78 20.5 16 20.5 17.22 20.33 18.44 19.81 19.37 19.25 20.36 18.32 21 17 21 15.68 21 14.75 20.36 14.2 19.37 13.68 18.44 13.5 17.22 13.5 16 13.5 14.78 13.68 13.56 14.2 12.63 m 15.51 13.36 b 15.17 13.97 15 14.88 15 16 15 17.12 15.17 18.03 15.51 18.64 15.81 19.19 16.26 19.5 17 19.5 17.74 19.5 18.19 19.19 18.5 18.64 18.83 18.03 19 17.12 19 16 19 14.88 18.83 13.97 18.5 13.36 18.19 12.81 17.74 12.5 17 12.5 16.26 12.5 15.81 12.81 15.51 13.36",
    ["fluent_skip_forward_30_filled"] = "m 21 2.25 b 21.55 2.25 22 2.7 22 3.25 l 22 9 b 22 9.55 21.55 10 21 10 l 15.75 10 b 15.2 10 14.75 9.55 14.75 9 14.75 8.45 15.2 8 15.75 8 l 19.14 8 b 18.15 6.82 16.93 5.89 15.45 5.43 13.44 4.81 11.31 4.86 9.35 5.59 7.37 6.33 5.54 7.82 4.63 9.48 4.36 9.97 3.75 10.15 3.27 9.88 2.79 9.61 2.61 9.01 2.87 8.52 4.05 6.38 6.29 4.6 8.65 3.72 11.03 2.83 13.62 2.77 16.05 3.52 17.62 4.01 18.93 4.9 20 5.98 l 20 3.25 b 20 2.7 20.45 2.25 21 2.25 m 6.46 13.71 b 6.61 13.55 6.76 13.4 7.03 13.27 7.31 13.14 7.76 13 8.5 13 10.11 13 10.42 13.77 10.43 14.04 10.44 14.28 10.22 15 8.75 15 8.2 15 7.75 15.45 7.75 16 7.75 16.55 8.2 17 8.75 17 10.22 17 10.44 17.72 10.43 17.96 10.42 18.23 10.11 19 8.5 19 7.76 19 7.31 18.86 7.03 18.73 6.76 18.6 6.61 18.45 6.46 18.29 6.06 17.9 5.43 17.9 5.04 18.29 4.65 18.69 4.65 19.32 5.04 19.71 l 5.05 19.72 b 5.24 19.9 5.58 20.25 6.16 20.53 6.74 20.81 7.49 21 8.5 21 10.74 21 12.37 19.77 12.43 18.04 12.46 17.23 12.15 16.53 11.59 16 12.15 15.47 12.46 14.77 12.43 13.96 12.37 12.23 10.74 11 8.5 11 7.49 11 6.74 11.19 6.16 11.47 5.58 11.75 5.24 12.1 5.05 12.28 l 5.04 12.29 b 4.65 12.68 4.65 13.31 5.04 13.71 5.43 14.1 6.06 14.1 6.46 13.71 m 14.24 12.66 b 14.85 11.64 15.86 11 17.25 11 18.64 11 19.65 11.64 20.26 12.66 20.82 13.61 21 14.82 21 16 21 17.18 20.82 18.39 20.26 19.34 19.65 20.36 18.64 21 17.25 21 15.86 21 14.85 20.36 14.24 19.34 13.68 18.39 13.5 17.18 13.5 16 13.5 14.82 13.68 13.61 14.24 12.66 m 15.96 13.68 b 15.67 14.18 15.5 14.97 15.5 16 15.5 17.03 15.67 17.82 15.96 18.32 16.21 18.74 16.57 19 17.25 19 17.93 19 18.29 18.74 18.54 18.32 18.83 17.82 19 17.03 19 16 19 14.97 18.83 14.18 18.54 13.68 18.29 13.26 17.93 13 17.25 13 16.57 13 16.21 13.26 15.96 13.68",
    ["fluent_skip_forward_5"] = "m 21 3.25 b 21 3.12 20.97 2.99 20.9 2.88 20.83 2.76 20.74 2.67 20.62 2.6 20.51 2.53 20.38 2.5 20.25 2.5 20.12 2.5 19.99 2.53 19.88 2.6 19.76 2.67 19.67 2.76 19.6 2.88 19.53 2.99 19.5 3.12 19.5 3.25 l 19.5 6.65 b 18.35 5.26 16.85 4.09 14.97 3.5 13.8 3.14 12.57 2.97 11.34 3 10.11 3.03 8.89 3.27 7.74 3.7 5.42 4.56 3.24 6.31 2.09 8.39 2.03 8.5 2 8.63 2.01 8.76 2.01 8.89 2.05 9.02 2.12 9.13 2.19 9.24 2.28 9.33 2.4 9.39 2.51 9.46 2.64 9.49 2.77 9.49 2.9 9.48 3.03 9.45 3.14 9.38 3.25 9.32 3.34 9.22 3.41 9.11 4.35 7.39 6.23 5.86 8.26 5.1 9.26 4.73 10.32 4.53 11.38 4.5 12.45 4.47 13.51 4.62 14.53 4.94 16.23 5.46 17.6 6.6 18.66 8 l 14.75 8 b 14.62 8 14.49 8.03 14.38 8.1 14.26 8.17 14.17 8.26 14.1 8.37 14.04 8.49 14 8.62 14 8.75 14 8.88 14.04 9.01 14.1 9.12 14.17 9.24 14.26 9.33 14.38 9.4 14.49 9.46 14.62 9.5 14.75 9.5 l 20.25 9.5 b 20.38 9.5 20.51 9.46 20.63 9.4 20.74 9.33 20.83 9.24 20.9 9.12 20.97 9.01 21 8.88 21 8.75 l 21 3.25 21 3.25 m 13.6 12.5 b 13.73 12.5 13.86 12.47 13.97 12.4 14.09 12.33 14.18 12.24 14.25 12.12 14.31 12.01 14.35 11.88 14.35 11.75 14.35 11.62 14.31 11.49 14.25 11.38 14.18 11.26 14.09 11.17 13.97 11.1 13.86 11.03 13.73 11 13.6 11 l 10.05 11 b 9.93 11 9.81 11.03 9.71 11.08 9.6 11.14 9.51 11.22 9.44 11.32 9.37 11.42 9.32 11.53 9.31 11.65 l 8.91 14.65 b 8.89 14.76 8.9 14.86 8.93 14.97 8.96 15.07 9.02 15.16 9.09 15.24 9.16 15.32 9.24 15.39 9.34 15.43 9.44 15.48 9.54 15.5 9.65 15.5 l 11.82 15.5 b 11.92 15.5 12.02 15.51 12.13 15.52 12.47 15.57 12.79 15.7 13.06 15.91 13.34 16.12 13.55 16.4 13.69 16.71 13.82 17.03 13.87 17.37 13.84 17.71 13.8 18.05 13.68 18.38 13.48 18.66 13.28 18.94 13.01 19.16 12.7 19.31 12.39 19.46 12.04 19.52 11.7 19.5 11.36 19.47 11.03 19.36 10.74 19.17 10.46 18.98 10.22 18.72 10.07 18.41 10.02 18.31 9.95 18.22 9.86 18.14 9.77 18.07 9.66 18.02 9.55 18 9.44 17.97 9.32 17.97 9.21 18 9.1 18.03 8.99 18.08 8.9 18.16 8.82 18.23 8.75 18.33 8.7 18.43 8.65 18.54 8.63 18.65 8.64 18.77 8.64 18.88 8.68 18.99 8.73 19.1 9 19.62 9.4 20.08 9.9 20.41 10.39 20.74 10.96 20.94 11.55 20.99 12.14 21.04 12.73 20.94 13.28 20.7 13.82 20.46 14.29 20.08 14.65 19.61 15 19.13 15.23 18.58 15.31 17.99 15.39 17.49 15.35 16.98 15.2 16.5 15.06 16.01 14.81 15.57 14.48 15.19 14.14 14.81 13.73 14.51 13.27 14.3 12.81 14.1 12.31 13.99 11.8 14 l 10.51 14 10.71 12.5 13.6 12.5 13.6 12.5",
    ["fluent_skip_forward_5_filled"] = "m 21.25 3.25 b 21.25 3.07 21.2 2.9 21.12 2.75 21.03 2.6 20.9 2.47 20.75 2.38 20.6 2.3 20.43 2.25 20.25 2.25 20.07 2.25 19.9 2.3 19.75 2.38 19.6 2.47 19.47 2.6 19.38 2.75 19.3 2.9 19.25 3.07 19.25 3.25 l 19.25 5.98 b 18.18 4.9 16.87 4.01 15.3 3.52 14.1 3.14 12.84 2.97 11.58 3 10.33 3.04 9.08 3.28 7.9 3.72 5.54 4.6 3.3 6.38 2.12 8.52 2.05 8.68 2.01 8.85 2.02 9.02 2.03 9.19 2.08 9.35 2.17 9.5 2.26 9.64 2.39 9.76 2.54 9.85 2.69 9.93 2.86 9.97 3.03 9.97 3.2 9.97 3.37 9.92 3.52 9.84 3.67 9.75 3.79 9.63 3.88 9.48 4.79 7.82 6.62 6.33 8.6 5.59 9.57 5.23 10.6 5.03 11.64 5 12.68 4.97 13.71 5.12 14.71 5.43 16.18 5.89 17.4 6.82 18.39 8 l 15 8 b 14.83 8 14.65 8.05 14.5 8.13 14.35 8.22 14.22 8.35 14.13 8.5 14.05 8.65 14 8.82 14 9 14 9.17 14.05 9.35 14.13 9.5 14.22 9.65 14.35 9.78 14.5 9.87 14.65 9.95 14.83 10 15 10 l 20.25 10 b 20.43 10 20.6 9.95 20.75 9.87 20.9 9.78 21.03 9.65 21.12 9.5 21.2 9.35 21.25 9.17 21.25 9 l 21.25 3.25 21.25 3.25 m 13 13 b 13.18 13 13.35 12.95 13.5 12.87 13.65 12.78 13.78 12.65 13.87 12.5 13.95 12.35 14 12.18 14 12 14 11.82 13.95 11.65 13.87 11.5 13.78 11.35 13.65 11.22 13.5 11.13 13.35 11.05 13.18 11 13 11 l 9.9 11 b 9.74 11 9.58 11.04 9.44 11.11 9.3 11.19 9.17 11.29 9.08 11.43 8.99 11.56 8.93 11.71 8.91 11.87 l 8.51 14.87 b 8.49 15.01 8.5 15.15 8.54 15.29 8.58 15.43 8.65 15.55 8.75 15.66 8.84 15.77 8.96 15.85 9.09 15.91 9.22 15.97 9.36 16 9.5 16 l 11.5 16 b 11.71 16 11.92 16.05 12.12 16.14 12.31 16.23 12.49 16.35 12.63 16.52 12.77 16.68 12.88 16.87 12.94 17.07 13 17.28 13.01 17.5 12.98 17.71 12.95 17.96 12.85 18.2 12.69 18.41 12.54 18.61 12.33 18.77 12.1 18.88 11.86 18.98 11.61 19.02 11.35 18.99 11.1 18.97 10.85 18.88 10.64 18.73 10.43 18.58 10.26 18.39 10.15 18.16 10.08 18.02 9.99 17.9 9.87 17.81 9.75 17.72 9.62 17.65 9.47 17.62 9.32 17.58 9.17 17.58 9.02 17.62 8.88 17.65 8.74 17.72 8.62 17.81 8.51 17.91 8.41 18.03 8.35 18.16 8.28 18.3 8.25 18.45 8.25 18.6 8.25 18.75 8.29 18.9 8.35 19.03 8.59 19.53 8.95 19.96 9.4 20.3 9.84 20.63 10.36 20.85 10.9 20.95 11.45 21.04 12.01 21.01 12.54 20.84 13.07 20.68 13.55 20.39 13.95 20 14.35 19.61 14.64 19.14 14.82 18.61 15 18.08 15.04 17.52 14.96 16.98 14.88 16.43 14.66 15.91 14.34 15.46 14.02 15.01 13.59 14.64 13.1 14.39 12.6 14.13 12.05 14 11.5 14 l 10.64 14 10.78 13 13 13 13 13",
    ["fluent_skip_forward_tab"] = "m 21.5 3.75 b 21.5 3.34 21.16 3 20.75 3 20.34 3 20 3.34 20 3.75 l 20 7.15 b 18.85 5.76 17.35 4.59 15.47 4.01 13.09 3.27 10.57 3.33 8.24 4.2 5.92 5.06 3.73 6.81 2.59 8.89 2.39 9.25 2.53 9.71 2.89 9.91 3.25 10.11 3.71 9.97 3.91 9.61 4.85 7.89 6.73 6.36 8.76 5.6 10.78 4.85 12.96 4.8 15.03 5.44 16.73 5.96 18.1 7.1 19.16 8.5 l 15.25 8.5 b 14.84 8.5 14.5 8.84 14.5 9.25 14.5 9.66 14.84 10 15.25 10 l 20.75 10 b 21.16 10 21.5 9.66 21.5 9.25 l 21.5 3.75 m 8 14 b 7.72 14 7.5 14.22 7.5 14.5 l 7.5 18.5 b 7.5 18.78 7.72 19 8 19 l 16 19 b 16.28 19 16.5 18.78 16.5 18.5 l 16.5 14.5 b 16.5 14.22 16.28 14 16 14 l 8 14 m 6 14.5 b 6 13.4 6.9 12.5 8 12.5 l 16 12.5 b 17.1 12.5 18 13.4 18 14.5 l 18 18.5 b 18 19.6 17.1 20.5 16 20.5 l 8 20.5 b 6.9 20.5 6 19.6 6 18.5 l 6 14.5",
    ["fluent_skip_forward_tab_filled"] = "m 22 3.25 b 22 2.7 21.55 2.25 21 2.25 20.45 2.25 20 2.7 20 3.25 l 20 5.98 b 18.93 4.9 17.62 4.01 16.05 3.52 13.62 2.77 11.03 2.83 8.65 3.72 6.29 4.6 4.05 6.38 2.87 8.52 2.61 9.01 2.79 9.61 3.27 9.88 3.75 10.15 4.36 9.97 4.63 9.48 5.54 7.82 7.37 6.33 9.35 5.59 11.31 4.86 13.44 4.81 15.45 5.43 16.93 5.89 18.15 6.82 19.14 8 l 15.75 8 b 15.2 8 14.75 8.45 14.75 9 14.75 9.55 15.2 10 15.75 10 l 21 10 b 21.55 10 22 9.55 22 9 l 22 3.25 m 6 15 b 6 13.9 6.9 13 8 13 l 16 13 b 17.1 13 18 13.9 18 15 l 18 19 b 18 20.1 17.1 21 16 21 l 8 21 b 6.9 21 6 20.1 6 19 l 6 15 m 8 15.5 l 8 18.5 b 8 18.78 8.22 19 8.5 19 l 15.5 19 b 15.78 19 16 18.78 16 18.5 l 16 15.5 b 16 15.22 15.78 15 15.5 15 l 8.5 15 b 8.22 15 8 15.22 8 15.5",
    ["fluent_speaker_0"] = "m 14.7 3.44 b 14.9 3.67 15 3.95 15 4.25 l 15 19.75 b 15 20.44 14.44 21 13.75 21 13.45 21 13.17 20.89 12.94 20.7 l 7.98 16.5 4.25 16.5 b 3.01 16.5 2 15.49 2 14.25 l 2 9.75 b 2 8.51 3.01 7.5 4.25 7.5 l 7.98 7.5 12.94 3.29 b 13.47 2.85 14.26 2.91 14.7 3.44 m 13.5 4.79 l 8.52 9 4.25 9 b 3.84 9 3.5 9.33 3.5 9.75 l 3.5 14.25 b 3.5 14.66 3.84 15 4.25 15 l 8.52 15 13.5 19.21 13.5 4.79",
    ["fluent_speaker_0_filled"] = "m 14.7 3.44 b 14.9 3.67 15 3.95 15 4.25 l 15 19.75 b 15 20.44 14.44 21 13.75 21 13.45 21 13.17 20.89 12.94 20.7 l 7.98 16.5 4.25 16.5 b 3.01 16.5 2 15.49 2 14.25 l 2 9.75 b 2 8.51 3.01 7.5 4.25 7.5 l 7.98 7.5 12.94 3.29 b 13.47 2.85 14.26 2.91 14.7 3.44",
    ["fluent_speaker_1"] = "m 14.7 3.44 b 14.9 3.67 15 3.95 15 4.25 l 15 19.75 b 15 20.44 14.44 21 13.75 21 13.45 21 13.17 20.9 12.94 20.71 l 7.98 16.5 4.25 16.5 b 3.01 16.5 2 15.49 2 14.25 l 2 9.75 b 2 8.51 3.01 7.5 4.25 7.5 l 7.98 7.5 12.94 3.3 b 13.47 2.85 14.26 2.92 14.7 3.44 m 13.5 4.79 l 8.52 9 4.25 9 b 3.84 9 3.5 9.34 3.5 9.75 l 3.5 14.25 b 3.5 14.66 3.84 15 4.25 15 l 8.52 15 13.5 19.21 13.5 4.79 m 17.1 8.64 b 17.46 8.42 17.92 8.54 18.13 8.89 18.71 9.83 19 10.88 19 12.03 19 13.18 18.71 14.23 18.13 15.17 17.92 15.52 17.46 15.64 17.1 15.42 16.75 15.2 16.64 14.74 16.85 14.39 17.28 13.69 17.5 12.91 17.5 12.03 17.5 11.15 17.28 10.37 16.85 9.67 16.64 9.32 16.75 8.86 17.1 8.64",
    ["fluent_speaker_1_filled"] = "m 14.7 3.44 b 14.9 3.67 15 3.95 15 4.25 l 15 19.75 b 15 20.44 14.44 21 13.75 21 13.45 21 13.17 20.9 12.94 20.71 l 7.98 16.5 4.25 16.5 b 3.01 16.5 2 15.49 2 14.25 l 2 9.75 b 2 8.51 3.01 7.5 4.25 7.5 l 7.98 7.5 12.94 3.3 b 13.47 2.85 14.26 2.92 14.7 3.44 m 17.1 8.64 b 17.46 8.42 17.92 8.54 18.13 8.89 18.71 9.83 19 10.88 19 12.03 19 13.18 18.71 14.23 18.13 15.17 17.92 15.52 17.46 15.64 17.1 15.42 16.75 15.2 16.64 14.74 16.85 14.39 17.28 13.69 17.5 12.91 17.5 12.03 17.5 11.15 17.28 10.37 16.85 9.67 16.64 9.32 16.75 8.86 17.1 8.64",
    ["fluent_speaker_2"] = "m 15 4.25 b 15 3.17 13.73 2.6 12.92 3.32 l 8.43 7.31 b 8.29 7.43 8.11 7.5 7.93 7.5 l 4.25 7.5 b 3.01 7.5 2 8.51 2 9.75 l 2 14.25 b 2 15.49 3.01 16.5 4.25 16.5 l 7.93 16.5 b 8.11 16.5 8.29 16.56 8.43 16.69 l 12.92 20.68 b 13.73 21.4 15 20.82 15 19.75 l 15 4.25 m 9.42 8.43 l 13.5 4.81 13.5 19.19 9.42 15.56 b 9.01 15.2 8.48 15 7.93 15 l 4.25 15 b 3.84 15 3.5 14.66 3.5 14.25 l 3.5 9.75 b 3.5 9.33 3.84 9 4.25 9 l 7.93 9 b 8.48 9 9.01 8.8 9.42 8.43 m 18.99 5.9 b 19.32 5.65 19.79 5.72 20.04 6.05 21.27 7.72 22 9.77 22 12 22 14.23 21.27 16.28 20.04 17.95 19.79 18.28 19.32 18.35 18.99 18.1 18.66 17.86 18.59 17.39 18.84 17.05 19.88 15.64 20.5 13.89 20.5 12 20.5 10.11 19.88 8.36 18.84 6.95 18.59 6.61 18.66 6.14 18.99 5.9 m 17.14 8.37 b 17.51 8.17 17.96 8.31 18.16 8.67 18.7 9.66 19 10.8 19 12 19 13.2 18.7 14.34 18.16 15.33 17.96 15.69 17.51 15.83 17.14 15.63 16.78 15.43 16.64 14.98 16.84 14.61 17.26 13.84 17.5 12.95 17.5 12 17.5 11.05 17.26 10.16 16.84 9.39 16.64 9.02 16.78 8.57 17.14 8.37",
    ["fluent_speaker_2_filled"] = "m 15 4.25 l 15 19.75 b 15 20.82 13.73 21.4 12.92 20.68 l 8.43 16.69 b 8.29 16.56 8.11 16.5 7.93 16.5 l 4.25 16.5 b 3.01 16.5 2 15.49 2 14.25 l 2 9.75 b 2 8.51 3.01 7.5 4.25 7.5 l 7.93 7.5 b 8.11 7.5 8.29 7.43 8.43 7.31 l 12.92 3.32 b 13.73 2.6 15 3.17 15 4.25 m 18.99 5.9 b 19.32 5.65 19.79 5.72 20.04 6.05 21.27 7.72 22 9.77 22 12 22 14.23 21.27 16.28 20.04 17.95 19.79 18.28 19.32 18.35 18.99 18.1 18.66 17.86 18.59 17.39 18.84 17.05 19.88 15.64 20.5 13.89 20.5 12 20.5 10.11 19.88 8.36 18.84 6.95 18.59 6.61 18.66 6.14 18.99 5.9 m 17.14 8.37 b 17.51 8.17 17.96 8.31 18.16 8.67 18.7 9.66 19 10.8 19 12 19 13.2 18.7 14.34 18.16 15.33 17.96 15.69 17.51 15.83 17.14 15.63 16.78 15.43 16.64 14.98 16.84 14.61 17.26 13.84 17.5 12.95 17.5 12 17.5 11.05 17.26 10.16 16.84 9.39 16.64 9.02 16.78 8.57 17.14 8.37",
    ["fluent_speaker_mute"] = "m 12.92 3.32 b 13.73 2.6 15 3.17 15 4.25 l 15 19.75 b 15 20.82 13.73 21.4 12.92 20.68 l 8.43 16.69 b 8.29 16.56 8.11 16.5 7.93 16.5 l 4.25 16.5 b 3.01 16.5 2 15.49 2 14.25 l 2 9.75 b 2 8.51 3.01 7.5 4.25 7.5 l 7.93 7.5 b 8.11 7.5 8.29 7.43 8.43 7.31 l 12.92 3.32 m 13.5 4.81 l 9.42 8.43 b 9.01 8.8 8.48 9 7.93 9 l 4.25 9 b 3.84 9 3.5 9.33 3.5 9.75 l 3.5 14.25 b 3.5 14.66 3.84 15 4.25 15 l 7.93 15 b 8.48 15 9.01 15.2 9.42 15.56 l 13.5 19.19 13.5 4.81 m 16.22 9.22 b 16.51 8.93 16.99 8.93 17.28 9.22 l 19 10.94 20.72 9.22 b 21.01 8.93 21.49 8.93 21.78 9.22 22.07 9.51 22.07 9.99 21.78 10.28 l 20.06 12 21.78 13.72 b 22.07 14.01 22.07 14.49 21.78 14.78 21.49 15.07 21.01 15.07 20.72 14.78 l 19 13.06 17.28 14.78 b 16.99 15.07 16.51 15.07 16.22 14.78 15.93 14.49 15.93 14.01 16.22 13.72 l 17.94 12 16.22 10.28 b 15.93 9.99 15.93 9.51 16.22 9.22",
    ["fluent_speaker_mute_filled"] = "m 15 4.25 b 15 3.17 13.73 2.6 12.92 3.32 l 8.43 7.31 b 8.29 7.43 8.11 7.5 7.93 7.5 l 4.25 7.5 b 3.01 7.5 2 8.51 2 9.75 l 2 14.25 b 2 15.49 3.01 16.5 4.25 16.5 l 7.93 16.5 b 8.11 16.5 8.29 16.56 8.43 16.69 l 12.92 20.68 b 13.73 21.4 15 20.82 15 19.75 l 15 4.25 m 16.22 9.22 b 16.51 8.93 16.99 8.93 17.28 9.22 l 19 10.94 20.72 9.22 b 21.01 8.93 21.49 8.93 21.78 9.22 22.07 9.51 22.07 9.99 21.78 10.28 l 20.06 12 21.78 13.72 b 22.07 14.01 22.07 14.49 21.78 14.78 21.49 15.07 21.01 15.07 20.72 14.78 l 19 13.06 17.28 14.78 b 16.99 15.07 16.51 15.07 16.22 14.78 15.93 14.49 15.93 14.01 16.22 13.72 l 17.94 12 16.22 10.28 b 15.93 9.99 15.93 9.51 16.22 9.22",
    ["fluent_subtitles"] = "m 2 7.25 b 2 5.46 3.46 4 5.25 4 l 18.75 4 b 20.54 4 22 5.46 22 7.25 l 22 16.75 b 22 18.54 20.54 20 18.75 20 l 5.25 20 b 3.46 20 2 18.54 2 16.75 l 2 7.25 m 5.25 5.5 b 4.28 5.5 3.5 6.28 3.5 7.25 l 3.5 16.75 b 3.5 17.72 4.28 18.5 5.25 18.5 l 18.75 18.5 b 19.72 18.5 20.5 17.72 20.5 16.75 l 20.5 7.25 b 20.5 6.28 19.72 5.5 18.75 5.5 l 5.25 5.5 m 5 13.25 b 5 12.84 5.34 12.5 5.75 12.5 l 13.25 12.5 b 13.66 12.5 14 12.84 14 13.25 14 13.66 13.66 14 13.25 14 l 5.75 14 b 5.34 14 5 13.66 5 13.25 m 15.75 12.5 b 15.34 12.5 15 12.84 15 13.25 15 13.66 15.34 14 15.75 14 l 18.25 14 b 18.66 14 19 13.66 19 13.25 19 12.84 18.66 12.5 18.25 12.5 l 15.75 12.5 m 5 16.25 b 5 15.84 5.34 15.5 5.75 15.5 l 9.25 15.5 b 9.66 15.5 10 15.84 10 16.25 10 16.66 9.66 17 9.25 17 l 5.75 17 b 5.34 17 5 16.66 5 16.25 m 11.75 15.5 b 11.34 15.5 11 15.84 11 16.25 11 16.66 11.34 17 11.75 17 l 18.25 17 b 18.66 17 19 16.66 19 16.25 19 15.84 18.66 15.5 18.25 15.5 l 11.75 15.5",
    ["fluent_subtitles_filled"] = "m 2 7.25 b 2 5.46 3.46 4 5.25 4 l 18.75 4 b 20.54 4 22 5.46 22 7.25 l 22 16.75 b 22 18.54 20.54 20 18.75 20 l 5.25 20 b 3.46 20 2 18.54 2 16.75 l 2 7.25 m 5 13.25 b 5 13.66 5.34 14 5.75 14 l 13.25 14 b 13.66 14 14 13.66 14 13.25 14 12.84 13.66 12.5 13.25 12.5 l 5.75 12.5 b 5.34 12.5 5 12.84 5 13.25 m 15.75 12.5 b 15.34 12.5 15 12.84 15 13.25 15 13.66 15.34 14 15.75 14 l 18.25 14 b 18.66 14 19 13.66 19 13.25 19 12.84 18.66 12.5 18.25 12.5 l 15.75 12.5 m 5 16.25 b 5 16.66 5.34 17 5.75 17 l 9.25 17 b 9.66 17 10 16.66 10 16.25 10 15.84 9.66 15.5 9.25 15.5 l 5.75 15.5 b 5.34 15.5 5 15.84 5 16.25 m 11.75 15.5 b 11.34 15.5 11 15.84 11 16.25 11 16.66 11.34 17 11.75 17 l 18.25 17 b 18.66 17 19 16.66 19 16.25 19 15.84 18.66 15.5 18.25 15.5 l 11.75 15.5",
    ["fluent_top_speed"] = "m 6.54 5.48 b 7.84 4.4 9.47 3.69 11.25 3.53 l 11.25 5.25 b 11.25 5.66 11.59 6 12 6 12.41 6 12.75 5.66 12.75 5.25 l 12.75 3.53 b 16.93 3.9 20.24 7.29 20.49 11.5 l 18.75 11.5 b 18.34 11.5 18 11.84 18 12.25 18 12.66 18.34 13 18.75 13 l 20.44 13 b 20.18 15.31 19.02 17.25 17.28 18.67 16.96 18.93 16.91 19.4 17.17 19.72 17.43 20.04 17.9 20.09 18.22 19.83 20.45 18.02 21.89 15.44 21.99 12.35 22 12.32 22 12.28 22 12.25 22 12.23 22 12.21 22 12.19 22 12.13 22 12.06 22 12 22 6.48 17.52 2 12 2 6.48 2 2 6.48 2 12 2 15.25 3.52 17.95 5.77 19.83 6.09 20.09 6.56 20.05 6.83 19.73 7.09 19.41 7.05 18.94 6.73 18.67 5.02 17.25 3.83 15.31 3.56 13 l 5.25 13 b 5.66 13 6 12.66 6 12.25 6 11.84 5.66 11.5 5.25 11.5 l 3.51 11.5 b 3.62 9.62 4.35 7.9 5.48 6.54 l 6.72 7.78 b 7.01 8.07 7.49 8.07 7.78 7.78 8.07 7.49 8.07 7.01 7.78 6.72 l 6.54 5.48 m 16.76 6.63 b 16.52 6.45 16.18 6.46 15.95 6.65 l 15.73 6.83 b 15.6 6.95 15.4 7.11 15.16 7.32 14.68 7.72 14.04 8.26 13.38 8.82 12.73 9.38 12.06 9.96 11.52 10.43 11.25 10.67 11.02 10.88 10.83 11.06 10.66 11.22 10.5 11.37 10.41 11.48 9.76 12.29 9.9 13.46 10.72 14.1 11.55 14.74 12.75 14.6 13.4 13.79 13.49 13.68 13.61 13.5 13.72 13.3 13.85 13.08 14.01 12.81 14.18 12.5 14.53 11.88 14.95 11.11 15.36 10.35 15.76 9.6 16.16 8.86 16.45 8.31 16.59 8.04 16.71 7.81 16.8 7.65 l 16.93 7.41 b 17.07 7.14 17 6.82 16.76 6.63",
    ["fluent_top_speed_filled"] = "m 12 2 b 17.52 2 22 6.48 22 12 22 15.14 20.55 17.95 18.29 19.78 17.86 20.12 17.23 20.06 16.88 19.63 16.53 19.2 16.6 18.57 17.03 18.22 18.6 16.95 19.67 15.1 19.94 13 l 18.41 13 b 17.89 13 17.5 12.52 17.5 12 17.5 11.48 17.89 11 18.41 11 l 19.94 11 b 19.49 7.38 16.62 4.51 13 4.06 l 13 5.59 b 13 6.11 12.52 6.5 12 6.5 11.48 6.5 11 6.11 11 5.59 l 11 4.06 b 9.54 4.25 8.2 4.82 7.1 5.68 l 8.17 6.76 b 8.54 7.13 8.48 7.74 8.11 8.11 7.74 8.48 7.13 8.54 6.76 8.17 l 5.68 7.1 b 4.82 8.2 4.25 9.54 4.06 11 l 5.59 11 b 6.11 11 6.5 11.48 6.5 12 6.5 12.52 6.11 13 5.59 13 l 4.06 13 b 4.31 14.95 5.25 16.68 6.64 17.94 l 6.97 18.22 7.05 18.29 b 7.41 18.65 7.45 19.23 7.12 19.63 6.79 20.03 6.22 20.12 5.8 19.84 l 5.71 19.78 5.3 19.42 b 3.27 17.59 2 14.95 2 12 2 6.48 6.48 2 12 2 m 15.95 6.65 b 16.18 6.46 16.52 6.45 16.76 6.63 17 6.82 17.07 7.14 16.93 7.41 l 16.8 7.66 b 16.71 7.81 16.59 8.04 16.45 8.31 16.16 8.86 15.76 9.6 15.36 10.35 14.95 11.11 14.53 11.88 14.18 12.5 14.01 12.81 13.85 13.08 13.72 13.29 13.61 13.49 13.49 13.68 13.4 13.79 12.75 14.6 11.55 14.74 10.72 14.1 9.9 13.46 9.76 12.29 10.41 11.48 10.5 11.37 10.66 11.22 10.83 11.06 11.02 10.88 11.25 10.67 11.52 10.43 12.06 9.96 12.73 9.38 13.38 8.82 14.04 8.26 14.68 7.72 15.16 7.32 15.4 7.11 15.6 6.95 15.73 6.83 l 15.95 6.65",
    ["fluent_zoom_in"] = "m 10 6.5 b 10.41 6.5 10.75 6.84 10.75 7.25 l 10.75 9.25 12.75 9.25 b 13.16 9.25 13.5 9.59 13.5 10 13.5 10.41 13.16 10.75 12.75 10.75 l 10.75 10.75 10.75 12.75 b 10.75 13.16 10.41 13.5 10 13.5 9.59 13.5 9.25 13.16 9.25 12.75 l 9.25 10.75 7.25 10.75 b 6.84 10.75 6.5 10.41 6.5 10 6.5 9.59 6.84 9.25 7.25 9.25 l 9.25 9.25 9.25 7.25 b 9.25 6.84 9.59 6.5 10 6.5 m 10 2 b 14.42 2 18 5.58 18 10 18 11.94 17.31 13.72 16.16 15.1 l 20.78 19.72 b 21.07 20.01 21.07 20.49 20.78 20.78 20.49 21.07 20.01 21.07 19.72 20.78 l 15.1 16.16 b 13.72 17.31 11.94 18 10 18 5.58 18 2 14.42 2 10 2 5.58 5.58 2 10 2 m 10 3.5 b 6.41 3.5 3.5 6.41 3.5 10 3.5 13.59 6.41 16.5 10 16.5 13.59 16.5 16.5 13.59 16.5 10 16.5 6.41 13.59 3.5 10 3.5",
    ["fluent_zoom_in_filled"] = "m 10 2 b 14.42 2 18 5.58 18 10 18 11.94 17.31 13.72 16.16 15.1 l 20.78 19.72 b 21.07 20.01 21.07 20.49 20.78 20.78 20.49 21.07 20.01 21.07 19.72 20.78 l 15.1 16.16 b 13.72 17.31 11.94 18 10 18 5.58 18 2 14.42 2 10 2 5.58 5.58 2 10 2 m 10 6.5 b 9.59 6.5 9.25 6.84 9.25 7.25 l 9.25 9.25 7.25 9.25 b 6.84 9.25 6.5 9.59 6.5 10 6.5 10.41 6.84 10.75 7.25 10.75 l 9.25 10.75 9.25 12.75 b 9.25 13.16 9.59 13.5 10 13.5 10.41 13.5 10.75 13.16 10.75 12.75 l 10.75 10.75 12.75 10.75 b 13.16 10.75 13.5 10.41 13.5 10 13.5 9.59 13.16 9.25 12.75 9.25 l 10.75 9.25 10.75 7.25 b 10.75 6.84 10.41 6.5 10 6.5",
    ["fluent_zoom_out"] = "m 12.75 9.25 b 13.16 9.25 13.5 9.59 13.5 10 13.5 10.41 13.16 10.75 12.75 10.75 l 7.25 10.75 b 6.84 10.75 6.5 10.41 6.5 10 6.5 9.59 6.84 9.25 7.25 9.25 l 12.75 9.25 m 10 2 b 14.42 2 18 5.58 18 10 18 11.94 17.31 13.72 16.16 15.1 l 20.78 19.72 b 21.07 20.01 21.07 20.49 20.78 20.78 20.49 21.07 20.01 21.07 19.72 20.78 l 15.1 16.16 b 13.72 17.31 11.94 18 10 18 5.58 18 2 14.42 2 10 2 5.58 5.58 2 10 2 m 10 3.5 b 6.41 3.5 3.5 6.41 3.5 10 3.5 13.59 6.41 16.5 10 16.5 13.59 16.5 16.5 13.59 16.5 10 16.5 6.41 13.59 3.5 10 3.5",
    ["fluent_zoom_out_filled"] = "m 10 2 b 14.42 2 18 5.58 18 10 18 11.94 17.31 13.72 16.16 15.1 l 20.78 19.72 b 21.07 20.01 21.07 20.49 20.78 20.78 20.49 21.07 20.01 21.07 19.72 20.78 l 15.1 16.16 b 13.72 17.31 11.94 18 10 18 5.58 18 2 14.42 2 10 2 5.58 5.58 2 10 2 m 7.25 9.25 b 6.84 9.25 6.5 9.59 6.5 10 6.5 10.41 6.84 10.75 7.25 10.75 l 12.75 10.75 b 13.16 10.75 13.5 10.41 13.5 10 13.5 9.59 13.16 9.25 12.75 9.25 l 7.25 9.25",
    ["forward_10"] = "m 8.49 21.29 b 7.4 20.81 6.45 20.17 5.64 19.36 4.83 18.55 4.19 17.6 3.71 16.51 3.24 15.42 3 14.25 3 13 3 11.75 3.24 10.58 3.71 9.49 4.19 8.4 4.83 7.45 5.64 6.64 6.45 5.83 7.4 5.19 8.49 4.71 9.58 4.24 10.75 4 12 4 l 12.15 4 11.3 3.15 b 11.1 2.95 11 2.72 11.01 2.45 11.02 2.18 11.12 1.95 11.3 1.75 11.5 1.55 11.74 1.45 12.01 1.44 12.29 1.43 12.53 1.52 12.73 1.72 l 15.3 4.3 b 15.5 4.5 15.6 4.73 15.6 5 15.6 5.27 15.5 5.5 15.3 5.7 l 12.73 8.27 b 12.53 8.47 12.29 8.57 12.01 8.56 11.74 8.55 11.5 8.45 11.3 8.25 11.12 8.05 11.02 7.82 11.01 7.55 11 7.28 11.1 7.05 11.3 6.85 l 12.15 6 12 6 b 10.05 6 8.4 6.68 7.04 8.04 5.68 9.4 5 11.05 5 13 5 14.95 5.68 16.6 7.04 17.96 8.4 19.32 10.05 20 12 20 13.95 20 15.6 19.32 16.96 17.96 18.32 16.6 19 14.95 19 13 19 12.72 19.1 12.48 19.29 12.29 19.48 12.1 19.72 12 20 12 20.28 12 20.52 12.1 20.71 12.29 20.9 12.48 21 12.72 21 13 21 14.25 20.76 15.42 20.29 16.51 19.81 17.6 19.17 18.55 18.36 19.36 17.55 20.17 16.6 20.81 15.51 21.29 14.42 21.76 13.25 22 12 22 10.75 22 9.58 21.76 8.49 21.29 m 9 11.5 l 8.25 11.5 b 8.03 11.5 7.85 11.43 7.71 11.29 7.57 11.15 7.5 10.97 7.5 10.75 7.5 10.53 7.57 10.35 7.71 10.21 7.85 10.07 8.03 10 8.25 10 l 9.75 10 b 9.97 10 10.15 10.07 10.29 10.21 10.43 10.35 10.5 10.53 10.5 10.75 l 10.5 15.25 b 10.5 15.47 10.43 15.65 10.29 15.79 10.15 15.93 9.97 16 9.75 16 9.53 16 9.35 15.93 9.21 15.79 9.07 15.65 9 15.47 9 15.25 l 9 11.5 m 12.5 16 b 12.22 16 11.98 15.9 11.79 15.71 11.6 15.52 11.5 15.28 11.5 15 l 11.5 11 b 11.5 10.72 11.6 10.48 11.79 10.29 11.98 10.1 12.22 10 12.5 10 l 14.5 10 b 14.78 10 15.02 10.1 15.21 10.29 15.4 10.48 15.5 10.72 15.5 11 l 15.5 15 b 15.5 15.28 15.4 15.52 15.21 15.71 15.02 15.9 14.78 16 14.5 16 l 12.5 16 m 13 14.5 l 14 14.5 14 11.5 13 11.5 13 14.5",
    ["forward_30"] = "m 8.49 21.29 b 7.4 20.81 6.45 20.17 5.64 19.36 4.83 18.55 4.19 17.6 3.71 16.51 3.24 15.42 3 14.25 3 13 3 11.75 3.24 10.58 3.71 9.49 4.19 8.4 4.83 7.45 5.64 6.64 6.45 5.83 7.4 5.19 8.49 4.71 9.58 4.24 10.75 4 12 4 l 12.15 4 11.3 3.15 b 11.1 2.95 11 2.72 11.01 2.45 11.02 2.18 11.12 1.95 11.3 1.75 11.5 1.55 11.74 1.45 12.01 1.44 12.29 1.43 12.53 1.52 12.73 1.72 l 15.3 4.3 b 15.5 4.5 15.6 4.73 15.6 5 15.6 5.27 15.5 5.5 15.3 5.7 l 12.73 8.27 b 12.53 8.47 12.29 8.57 12.01 8.56 11.74 8.55 11.5 8.45 11.3 8.25 11.12 8.05 11.02 7.82 11.01 7.55 11 7.28 11.1 7.05 11.3 6.85 l 12.15 6 12 6 b 10.05 6 8.4 6.68 7.04 8.04 5.68 9.4 5 11.05 5 13 5 14.95 5.68 16.6 7.04 17.96 8.4 19.32 10.05 20 12 20 13.95 20 15.6 19.32 16.96 17.96 18.32 16.6 19 14.95 19 13 19 12.72 19.1 12.48 19.29 12.29 19.48 12.1 19.72 12 20 12 20.28 12 20.52 12.1 20.71 12.29 20.9 12.48 21 12.72 21 13 21 14.25 20.76 15.42 20.29 16.51 19.81 17.6 19.17 18.55 18.36 19.36 17.55 20.17 16.6 20.81 15.51 21.29 14.42 21.76 13.25 22 12 22 10.75 22 9.58 21.76 8.49 21.29 m 10.5 16 l 8.25 16 b 8.03 16 7.85 15.93 7.71 15.79 7.57 15.65 7.5 15.47 7.5 15.25 7.5 15.03 7.57 14.85 7.71 14.71 7.85 14.57 8.03 14.5 8.25 14.5 l 10 14.5 10 13.5 9 13.5 b 8.87 13.5 8.75 13.45 8.65 13.35 8.55 13.25 8.5 13.13 8.5 13 8.5 12.87 8.55 12.75 8.65 12.65 8.75 12.55 8.87 12.5 9 12.5 l 10 12.5 10 11.5 8.25 11.5 b 8.03 11.5 7.85 11.43 7.71 11.29 7.57 11.15 7.5 10.97 7.5 10.75 7.5 10.53 7.57 10.35 7.71 10.21 7.85 10.07 8.03 10 8.25 10 l 10.5 10 b 10.78 10 11.02 10.1 11.21 10.29 11.4 10.48 11.5 10.72 11.5 11 l 11.5 15 b 11.5 15.28 11.4 15.52 11.21 15.71 11.02 15.9 10.78 16 10.5 16 m 13.5 16 b 13.22 16 12.98 15.9 12.79 15.71 12.6 15.52 12.5 15.28 12.5 15 l 12.5 11 b 12.5 10.72 12.6 10.48 12.79 10.29 12.98 10.1 13.22 10 13.5 10 l 15.5 10 b 15.78 10 16.02 10.1 16.21 10.29 16.4 10.48 16.5 10.72 16.5 11 l 16.5 15 b 16.5 15.28 16.4 15.52 16.21 15.71 16.02 15.9 15.78 16 15.5 16 l 13.5 16 m 14 14.5 l 15 14.5 15 11.5 14 11.5 14 14.5",
    ["forward_5"] = "m 8.49 21.29 b 7.4 20.81 6.45 20.17 5.64 19.36 4.83 18.55 4.19 17.6 3.71 16.51 3.24 15.42 3 14.25 3 13 3 11.75 3.24 10.58 3.71 9.49 4.19 8.4 4.83 7.45 5.64 6.64 6.45 5.83 7.4 5.19 8.49 4.71 9.58 4.24 10.75 4 12 4 l 12.15 4 11.3 3.15 b 11.1 2.95 11 2.72 11.01 2.45 11.02 2.18 11.12 1.95 11.3 1.75 11.5 1.55 11.74 1.45 12.01 1.44 12.29 1.43 12.53 1.52 12.73 1.72 l 15.3 4.3 b 15.5 4.5 15.6 4.73 15.6 5 15.6 5.27 15.5 5.5 15.3 5.7 l 12.73 8.27 b 12.53 8.47 12.29 8.57 12.01 8.56 11.74 8.55 11.5 8.45 11.3 8.25 11.12 8.05 11.02 7.82 11.01 7.55 11 7.28 11.1 7.05 11.3 6.85 l 12.15 6 12 6 b 10.05 6 8.4 6.68 7.04 8.04 5.68 9.4 5 11.05 5 13 5 14.95 5.68 16.6 7.04 17.96 8.4 19.32 10.05 20 12 20 13.95 20 15.6 19.32 16.96 17.96 18.32 16.6 19 14.95 19 13 19 12.72 19.1 12.48 19.29 12.29 19.48 12.1 19.72 12 20 12 20.28 12 20.52 12.1 20.71 12.29 20.9 12.48 21 12.72 21 13 21 14.25 20.76 15.42 20.29 16.51 19.81 17.6 19.17 18.55 18.36 19.36 17.55 20.17 16.6 20.81 15.51 21.29 14.42 21.76 13.25 22 12 22 10.75 22 9.58 21.76 8.49 21.29 m 13 16 l 10.25 16 b 10.03 16 9.85 15.93 9.71 15.79 9.57 15.65 9.5 15.47 9.5 15.25 9.5 15.03 9.57 14.85 9.71 14.71 9.85 14.57 10.03 14.5 10.25 14.5 l 12.5 14.5 12.5 13.5 10.25 13.5 b 10.03 13.5 9.85 13.43 9.71 13.29 9.57 13.15 9.5 12.97 9.5 12.75 l 9.5 10.75 b 9.5 10.53 9.57 10.35 9.71 10.21 9.85 10.07 10.03 10 10.25 10 l 13.25 10 b 13.47 10 13.65 10.07 13.79 10.21 13.93 10.35 14 10.53 14 10.75 14 10.97 13.93 11.15 13.79 11.29 13.65 11.43 13.47 11.5 13.25 11.5 l 11 11.5 11 12.5 13.25 12.5 b 13.47 12.5 13.65 12.57 13.79 12.71 13.93 12.85 14 13.03 14 13.25 l 14 15 b 14 15.28 13.9 15.52 13.71 15.71 13.52 15.9 13.28 16 13 16",
    ["forward_media"] = "m 12 22 b 10.75 22 9.58 21.76 8.49 21.29 7.4 20.81 6.45 20.17 5.64 19.36 4.83 18.55 4.19 17.6 3.71 16.51 3.24 15.42 3 14.25 3 13 3 11.75 3.24 10.58 3.71 9.49 4.19 8.4 4.83 7.45 5.64 6.64 6.45 5.83 7.4 5.19 8.49 4.71 9.58 4.24 10.75 4 12 4 l 12.15 4 11.3 3.15 b 11.12 2.97 11.03 2.74 11.03 2.46 11.03 2.19 11.12 1.95 11.3 1.75 11.5 1.55 11.74 1.45 12.01 1.44 12.29 1.43 12.53 1.52 12.73 1.72 l 15.3 4.3 b 15.48 4.48 15.58 4.72 15.58 5 15.58 5.28 15.48 5.52 15.3 5.7 l 12.73 8.27 b 12.53 8.47 12.29 8.57 12.01 8.56 11.74 8.55 11.5 8.45 11.3 8.25 11.12 8.05 11.03 7.81 11.03 7.54 11.03 7.26 11.12 7.03 11.3 6.85 l 12.15 6 12 6 b 10.05 6 8.4 6.68 7.04 8.04 5.68 9.4 5 11.05 5 13 5 14.95 5.68 16.6 7.04 17.96 8.4 19.32 10.05 20 12 20 13.77 20 15.31 19.43 16.62 18.27 17.94 17.12 18.72 15.68 18.95 13.92 18.98 13.66 19.1 13.44 19.3 13.26 19.5 13.09 19.73 13 20 13 20.27 13 20.5 13.08 20.7 13.25 20.9 13.42 20.98 13.62 20.95 13.88 20.72 16.19 19.75 18.12 18.05 19.68 16.35 21.23 14.33 22 12 22",
    ["fullscreen"] = "m 5 19 l 7 19 b 7.28 19 7.52 19.1 7.71 19.29 7.9 19.48 8 19.72 8 20 8 20.28 7.9 20.52 7.71 20.71 7.52 20.9 7.28 21 7 21 l 4 21 b 3.72 21 3.48 20.9 3.29 20.71 3.1 20.52 3 20.28 3 20 l 3 17 b 3 16.72 3.1 16.48 3.29 16.29 3.48 16.1 3.72 16 4 16 4.28 16 4.52 16.1 4.71 16.29 4.9 16.48 5 16.72 5 17 l 5 19 m 19 19 l 19 17 b 19 16.72 19.1 16.48 19.29 16.29 19.48 16.1 19.72 16 20 16 20.28 16 20.52 16.1 20.71 16.29 20.9 16.48 21 16.72 21 17 l 21 20 b 21 20.28 20.9 20.52 20.71 20.71 20.52 20.9 20.28 21 20 21 l 17 21 b 16.72 21 16.48 20.9 16.29 20.71 16.1 20.52 16 20.28 16 20 16 19.72 16.1 19.48 16.29 19.29 16.48 19.1 16.72 19 17 19 l 19 19 m 5 5 l 5 7 b 5 7.28 4.9 7.52 4.71 7.71 4.52 7.9 4.28 8 4 8 3.72 8 3.48 7.9 3.29 7.71 3.1 7.52 3 7.28 3 7 l 3 4 b 3 3.72 3.1 3.48 3.29 3.29 3.48 3.1 3.72 3 4 3 l 7 3 b 7.28 3 7.52 3.1 7.71 3.29 7.9 3.48 8 3.72 8 4 8 4.28 7.9 4.52 7.71 4.71 7.52 4.9 7.28 5 7 5 l 5 5 m 19 5 l 17 5 b 16.72 5 16.48 4.9 16.29 4.71 16.1 4.52 16 4.28 16 4 16 3.72 16.1 3.48 16.29 3.29 16.48 3.1 16.72 3 17 3 l 20 3 b 20.28 3 20.52 3.1 20.71 3.29 20.9 3.48 21 3.72 21 4 l 21 7 b 21 7.28 20.9 7.52 20.71 7.71 20.52 7.9 20.28 8 20 8 19.72 8 19.48 7.9 19.29 7.71 19.1 7.52 19 7.28 19 7 l 19 5",
    ["fullscreen_exit"] = "m 6 18 l 4 18 b 3.72 18 3.48 17.9 3.29 17.71 3.1 17.52 3 17.28 3 17 3 16.72 3.1 16.48 3.29 16.29 3.48 16.1 3.72 16 4 16 l 7 16 b 7.28 16 7.52 16.1 7.71 16.29 7.9 16.48 8 16.72 8 17 l 8 20 b 8 20.28 7.9 20.52 7.71 20.71 7.52 20.9 7.28 21 7 21 6.72 21 6.48 20.9 6.29 20.71 6.1 20.52 6 20.28 6 20 l 6 18 m 18 18 l 18 20 b 18 20.28 17.9 20.52 17.71 20.71 17.52 20.9 17.28 21 17 21 16.72 21 16.48 20.9 16.29 20.71 16.1 20.52 16 20.28 16 20 l 16 17 b 16 16.72 16.1 16.48 16.29 16.29 16.48 16.1 16.72 16 17 16 l 20 16 b 20.28 16 20.52 16.1 20.71 16.29 20.9 16.48 21 16.72 21 17 21 17.28 20.9 17.52 20.71 17.71 20.52 17.9 20.28 18 20 18 l 18 18 m 6 6 l 6 4 b 6 3.72 6.1 3.48 6.29 3.29 6.48 3.1 6.72 3 7 3 7.28 3 7.52 3.1 7.71 3.29 7.9 3.48 8 3.72 8 4 l 8 7 b 8 7.28 7.9 7.52 7.71 7.71 7.52 7.9 7.28 8 7 8 l 4 8 b 3.72 8 3.48 7.9 3.29 7.71 3.1 7.52 3 7.28 3 7 3 6.72 3.1 6.48 3.29 6.29 3.48 6.1 3.72 6 4 6 l 6 6 m 18 6 l 20 6 b 20.28 6 20.52 6.1 20.71 6.29 20.9 6.48 21 6.72 21 7 21 7.28 20.9 7.52 20.71 7.71 20.52 7.9 20.28 8 20 8 l 17 8 b 16.72 8 16.48 7.9 16.29 7.71 16.1 7.52 16 7.28 16 7 l 16 4 b 16 3.72 16.1 3.48 16.29 3.29 16.48 3.1 16.72 3 17 3 17.28 3 17.52 3.1 17.71 3.29 17.9 3.48 18 3.72 18 4 l 18 6",
    ["info"] = "m 12.71 16.71 b 12.9 16.52 13 16.28 13 16 l 13 12 b 13 11.72 12.9 11.48 12.71 11.29 12.52 11.1 12.28 11 12 11 11.72 11 11.48 11.1 11.29 11.29 11.1 11.48 11 11.72 11 12 l 11 16 b 11 16.28 11.1 16.52 11.29 16.71 11.48 16.9 11.72 17 12 17 12.28 17 12.52 16.9 12.71 16.71 m 12.71 8.71 b 12.9 8.52 13 8.28 13 8 13 7.72 12.9 7.48 12.71 7.29 12.52 7.1 12.28 7 12 7 11.72 7 11.48 7.1 11.29 7.29 11.1 7.48 11 7.72 11 8 11 8.28 11.1 8.52 11.29 8.71 11.48 8.9 11.72 9 12 9 12.28 9 12.52 8.9 12.71 8.71 m 12 22 b 10.62 22 9.32 21.74 8.1 21.21 6.88 20.69 5.83 19.98 4.93 19.07 4.03 18.18 3.31 17.12 2.79 15.9 2.26 14.68 2 13.38 2 12 2 10.62 2.26 9.32 2.79 8.1 3.31 6.88 4.03 5.82 4.93 4.93 5.83 4.02 6.88 3.31 8.1 2.79 9.32 2.26 10.62 2 12 2 13.38 2 14.68 2.26 15.9 2.79 17.12 3.31 18.18 4.02 19.07 4.93 19.98 5.82 20.69 6.88 21.21 8.1 21.74 9.32 22 10.62 22 12 22 13.38 21.74 14.68 21.21 15.9 20.69 17.12 19.98 18.18 19.07 19.07 18.18 19.98 17.12 20.69 15.9 21.21 14.68 21.74 13.38 22 12 22 m 12 20 b 14.23 20 16.12 19.23 17.68 17.68 19.23 16.12 20 14.23 20 12 20 9.77 19.23 7.87 17.68 6.32 16.12 4.78 14.23 4 12 4 9.77 4 7.88 4.78 6.33 6.32 4.78 7.87 4 9.77 4 12 4 14.23 4.78 16.12 6.33 17.68 7.88 19.23 9.77 20 12 20",
    ["info_filled"] = "m 11 17 l 13 17 13 11 11 11 11 17 m 12.71 8.71 b 12.9 8.52 13 8.28 13 8 13 7.72 12.9 7.48 12.71 7.29 12.52 7.1 12.28 7 12 7 11.72 7 11.48 7.1 11.29 7.29 11.1 7.48 11 7.72 11 8 11 8.28 11.1 8.52 11.29 8.71 11.48 8.9 11.72 9 12 9 12.28 9 12.52 8.9 12.71 8.71 m 12 22 b 10.62 22 9.32 21.74 8.1 21.21 6.88 20.69 5.83 19.98 4.93 19.07 4.03 18.18 3.31 17.12 2.79 15.9 2.26 14.68 2 13.38 2 12 2 10.62 2.26 9.32 2.79 8.1 3.31 6.88 4.03 5.82 4.93 4.93 5.83 4.02 6.88 3.31 8.1 2.79 9.32 2.26 10.62 2 12 2 13.38 2 14.68 2.26 15.9 2.79 17.12 3.31 18.18 4.02 19.07 4.93 19.98 5.82 20.69 6.88 21.21 8.1 21.74 9.32 22 10.62 22 12 22 13.38 21.74 14.68 21.21 15.9 20.69 17.12 19.98 18.18 19.07 19.07 18.18 19.98 17.12 20.69 15.9 21.21 14.68 21.74 13.38 22 12 22",
    ["menu_back"] = "m 15.53 4.22 b 15.62 4.31 15.69 4.43 15.72 4.56 15.76 4.68 15.76 4.82 15.72 4.94 15.69 5.07 15.62 5.19 15.53 5.28 l 8.81 12 15.53 18.72 b 15.61 18.8 15.68 18.9 15.72 19 15.76 19.11 15.78 19.23 15.77 19.34 15.75 19.46 15.72 19.57 15.66 19.66 15.59 19.76 15.51 19.84 15.41 19.91 15.32 19.97 15.21 20 15.09 20.02 14.98 20.03 14.86 20.01 14.75 19.97 14.65 19.93 14.55 19.86 14.47 19.78 l 7.22 12.53 b 7.13 12.44 7.06 12.32 7.03 12.19 6.99 12.07 6.99 11.93 7.03 11.81 7.06 11.68 7.13 11.56 7.22 11.47 l 14.47 4.22 b 14.56 4.13 14.68 4.06 14.81 4.03 14.93 3.99 15.07 3.99 15.19 4.03 15.32 4.06 15.44 4.13 15.53 4.22",
    ["menu_chapters"] = "m 5.75 6.5 b 5.75 6.72 5.69 6.93 5.58 7.12 5.47 7.32 5.32 7.47 5.12 7.58 4.93 7.69 4.72 7.75 4.5 7.75 4.28 7.75 4.07 7.69 3.88 7.58 3.68 7.47 3.53 7.32 3.42 7.12 3.31 6.93 3.25 6.72 3.25 6.5 3.25 6.28 3.31 6.07 3.42 5.88 3.53 5.68 3.68 5.53 3.87 5.42 4.07 5.31 4.28 5.25 4.5 5.25 4.72 5.25 4.93 5.31 5.12 5.42 5.32 5.53 5.47 5.68 5.58 5.88 5.69 6.07 5.75 6.28 5.75 6.5 m 5.75 12 b 5.75 12.22 5.69 12.43 5.58 12.62 5.47 12.82 5.32 12.97 5.12 13.08 4.93 13.19 4.72 13.25 4.5 13.25 4.28 13.25 4.07 13.19 3.88 13.08 3.68 12.97 3.53 12.82 3.42 12.62 3.31 12.43 3.25 12.22 3.25 12 3.25 11.78 3.31 11.57 3.42 11.38 3.53 11.18 3.68 11.03 3.87 10.92 4.07 10.81 4.28 10.75 4.5 10.75 4.72 10.75 4.93 10.81 5.12 10.92 5.32 11.03 5.47 11.18 5.58 11.38 5.69 11.57 5.75 11.78 5.75 12 m 5.75 17.5 b 5.75 17.72 5.69 17.93 5.58 18.12 5.47 18.32 5.32 18.47 5.12 18.58 4.93 18.69 4.72 18.75 4.5 18.75 4.28 18.75 4.07 18.69 3.88 18.58 3.68 18.47 3.53 18.32 3.42 18.12 3.31 17.93 3.25 17.72 3.25 17.5 3.25 17.28 3.31 17.07 3.42 16.88 3.53 16.68 3.68 16.53 3.87 16.42 4.07 16.31 4.28 16.25 4.5 16.25 4.72 16.25 4.93 16.31 5.12 16.42 5.32 16.53 5.47 16.68 5.58 16.88 5.69 17.07 5.75 17.28 5.75 17.5 m 9 5.75 l 20 5.75 b 20.13 5.75 20.26 5.78 20.38 5.85 20.49 5.92 20.58 6.01 20.65 6.12 20.72 6.24 20.75 6.37 20.75 6.5 20.75 6.63 20.72 6.76 20.65 6.88 20.58 6.99 20.49 7.08 20.38 7.15 20.26 7.22 20.13 7.25 20 7.25 l 9 7.25 b 8.87 7.25 8.74 7.22 8.62 7.15 8.51 7.08 8.42 6.99 8.35 6.88 8.28 6.76 8.25 6.63 8.25 6.5 8.25 6.37 8.28 6.24 8.35 6.12 8.42 6.01 8.51 5.92 8.62 5.85 8.74 5.78 8.87 5.75 9 5.75 m 9 11.25 l 20 11.25 b 20.13 11.25 20.26 11.28 20.38 11.35 20.49 11.42 20.58 11.51 20.65 11.62 20.72 11.74 20.75 11.87 20.75 12 20.75 12.13 20.72 12.26 20.65 12.38 20.58 12.49 20.49 12.58 20.38 12.65 20.26 12.72 20.13 12.75 20 12.75 l 9 12.75 b 8.87 12.75 8.74 12.72 8.62 12.65 8.51 12.58 8.42 12.49 8.35 12.38 8.28 12.26 8.25 12.13 8.25 12 8.25 11.87 8.28 11.74 8.35 11.62 8.42 11.51 8.51 11.42 8.62 11.35 8.74 11.28 8.87 11.25 9 11.25 m 9 16.75 l 20 16.75 b 20.13 16.75 20.26 16.78 20.38 16.85 20.49 16.92 20.58 17.01 20.65 17.12 20.72 17.24 20.75 17.37 20.75 17.5 20.75 17.63 20.72 17.76 20.65 17.88 20.58 17.99 20.49 18.08 20.38 18.15 20.26 18.22 20.13 18.25 20 18.25 l 9 18.25 b 8.87 18.25 8.74 18.22 8.62 18.15 8.51 18.08 8.42 17.99 8.35 17.88 8.28 17.76 8.25 17.63 8.25 17.5 8.25 17.37 8.28 17.24 8.35 17.12 8.42 17.01 8.51 16.92 8.62 16.85 8.74 16.78 8.87 16.75 9 16.75",
    ["menu_check"] = "m 4.53 12.97 b 4.24 12.68 3.76 12.68 3.47 12.97 3.18 13.26 3.18 13.74 3.47 14.03 l 7.97 18.53 b 8.26 18.82 8.74 18.82 9.03 18.53 l 20.03 7.53 b 20.32 7.24 20.32 6.76 20.03 6.47 19.74 6.18 19.26 6.18 18.97 6.47 l 8.5 16.94 4.53 12.97",
    ["menu_chevron"] = "m 8.47 4.22 b 8.38 4.31 8.31 4.43 8.28 4.56 8.24 4.68 8.24 4.82 8.28 4.94 8.31 5.07 8.38 5.19 8.47 5.28 l 15.19 12 8.47 18.72 b 8.39 18.8 8.32 18.9 8.28 19 8.24 19.11 8.22 19.23 8.23 19.34 8.25 19.46 8.28 19.57 8.34 19.66 8.41 19.76 8.49 19.84 8.59 19.91 8.68 19.97 8.79 20 8.91 20.02 9.02 20.03 9.14 20.01 9.25 19.97 9.35 19.93 9.45 19.86 9.53 19.78 l 16.78 12.53 b 16.87 12.44 16.94 12.32 16.97 12.19 17.01 12.07 17.01 11.93 16.97 11.81 16.94 11.68 16.87 11.56 16.78 11.47 l 9.53 4.22 b 9.44 4.13 9.32 4.06 9.19 4.03 9.07 3.99 8.93 3.99 8.81 4.03 8.68 4.06 8.56 4.13 8.47 4.22",
    ["menu_folder"] = "m 3.5 6.25 l 3.5 8 8.13 8 b 8.33 8 8.52 7.92 8.66 7.78 l 10.19 6.25 8.66 4.72 b 8.52 4.58 8.33 4.5 8.13 4.5 l 5.25 4.5 b 4.28 4.5 3.5 5.28 3.5 6.25 m 2 6.25 b 2 4.46 3.46 3 5.25 3 l 8.13 3 b 8.73 3 9.3 3.24 9.72 3.66 l 11.56 5.5 18.75 5.5 b 20.54 5.5 22 6.96 22 8.75 l 22 17.75 b 22 19.54 20.54 21 18.75 21 l 5.25 21 b 3.46 21 2 19.54 2 17.75 l 2 6.25 m 3.5 9.5 l 3.5 17.75 b 3.5 18.72 4.28 19.5 5.25 19.5 l 18.75 19.5 b 19.72 19.5 20.5 18.72 20.5 17.75 l 20.5 8.75 b 20.5 7.78 19.72 7 18.75 7 l 11.56 7 9.72 8.84 b 9.3 9.26 8.73 9.5 8.13 9.5 l 3.5 9.5",
    ["menu_folder_up"] = "m 3.5 6.25 l 3.5 8 8.13 8 b 8.33 8 8.52 7.92 8.66 7.78 l 10.19 6.25 8.66 4.72 b 8.52 4.58 8.33 4.5 8.13 4.5 l 5.25 4.5 b 4.28 4.5 3.5 5.28 3.5 6.25 m 2 6.25 b 2 4.46 3.46 3 5.25 3 l 8.13 3 b 8.73 3 9.3 3.24 9.72 3.66 l 11.56 5.5 18.75 5.5 b 20.54 5.5 22 6.96 22 8.75 l 22 12.81 b 21.56 12.38 21.05 12.02 20.5 11.73 l 20.5 8.75 b 20.5 7.78 19.72 7 18.75 7 l 11.56 7 9.72 8.84 b 9.3 9.26 8.73 9.5 8.13 9.5 l 3.5 9.5 3.5 17.75 b 3.5 18.72 4.28 19.5 5.25 19.5 l 11.31 19.5 b 11.49 20.03 11.73 20.54 12.02 21 l 5.25 21 b 3.46 21 2 19.54 2 17.75 l 2 6.25 m 23 17.5 b 23 20.54 20.54 23 17.5 23 14.46 23 12 20.54 12 17.5 12 14.46 14.46 12 17.5 12 20.54 12 23 14.46 23 17.5 m 17 20.5 b 17 20.78 17.22 21 17.5 21 17.78 21 18 20.78 18 20.5 l 18 15.71 19.65 17.35 b 19.84 17.55 20.16 17.55 20.35 17.35 20.55 17.16 20.55 16.84 20.35 16.65 l 17.85 14.15 b 17.66 13.95 17.34 13.95 17.15 14.15 l 14.65 16.65 b 14.45 16.84 14.45 17.16 14.65 17.35 14.84 17.55 15.16 17.55 15.35 17.35 l 17 15.71 17 20.5",
    ["menu_video"] = "m 2 6.25 b 2 4.46 3.46 3 5.25 3 l 18.75 3 b 20.54 3 22 4.46 22 6.25 l 22 17.75 b 22 19.54 20.54 21 18.75 21 l 5.25 21 b 3.46 21 2 19.54 2 17.75 l 2 6.25 m 5.25 4.5 b 4.28 4.5 3.5 5.28 3.5 6.25 l 3.5 17.75 b 3.5 18.72 4.28 19.5 5.25 19.5 l 18.75 19.5 b 19.72 19.5 20.5 18.72 20.5 17.75 l 20.5 6.25 b 20.5 5.28 19.72 4.5 18.75 4.5 l 5.25 4.5 m 9 9.25 l 9 14.75 b 9 15.51 9.82 15.99 10.48 15.63 l 15.48 12.88 b 16.17 12.5 16.17 11.5 15.48 11.12 l 10.48 8.37 b 9.82 8.01 9 8.49 9 9.25",
    ["menu_more"] = "m 7.5 12 b 7.5 12.31 7.42 12.61 7.27 12.88 7.11 13.14 6.89 13.36 6.62 13.52 6.36 13.67 6.06 13.75 5.75 13.75 5.44 13.75 5.14 13.67 4.88 13.52 4.61 13.36 4.39 13.14 4.23 12.88 4.08 12.61 4 12.31 4 12 4 11.69 4.08 11.39 4.23 11.12 4.39 10.86 4.61 10.64 4.87 10.48 5.14 10.33 5.44 10.25 5.75 10.25 6.06 10.25 6.36 10.33 6.62 10.48 6.89 10.64 7.11 10.86 7.27 11.12 7.42 11.39 7.5 11.69 7.5 12 m 13.75 12 b 13.75 12.31 13.67 12.61 13.52 12.88 13.36 13.14 13.14 13.36 12.88 13.52 12.61 13.67 12.31 13.75 12 13.75 11.69 13.75 11.39 13.67 11.12 13.52 10.86 13.36 10.64 13.14 10.48 12.88 10.33 12.61 10.25 12.31 10.25 12 10.25 11.69 10.33 11.39 10.48 11.12 10.64 10.86 10.86 10.64 11.12 10.48 11.39 10.33 11.69 10.25 12 10.25 12.31 10.25 12.61 10.33 12.88 10.48 13.14 10.64 13.36 10.86 13.52 11.12 13.67 11.39 13.75 11.69 13.75 12 m 20 12 b 20 12.31 19.92 12.61 19.77 12.88 19.61 13.14 19.39 13.36 19.12 13.52 18.86 13.67 18.56 13.75 18.25 13.75 17.94 13.75 17.64 13.67 17.38 13.52 17.11 13.36 16.89 13.14 16.73 12.88 16.58 12.61 16.5 12.31 16.5 12 16.5 11.69 16.58 11.39 16.73 11.12 16.89 10.86 17.11 10.64 17.38 10.48 17.64 10.33 17.94 10.25 18.25 10.25 18.56 10.25 18.86 10.33 19.12 10.48 19.39 10.64 19.61 10.86 19.77 11.12 19.92 11.39 20 11.69 20 12",
    ["more_vert"] = "m 12 20 b 11.45 20 10.98 19.8 10.59 19.41 10.2 19.02 10 18.55 10 18 10 17.45 10.2 16.98 10.59 16.59 10.98 16.2 11.45 16 12 16 12.55 16 13.02 16.2 13.41 16.59 13.8 16.98 14 17.45 14 18 14 18.55 13.8 19.02 13.41 19.41 13.02 19.8 12.55 20 12 20 m 12 14 b 11.45 14 10.98 13.8 10.59 13.41 10.2 13.02 10 12.55 10 12 10 11.45 10.2 10.98 10.59 10.59 10.98 10.2 11.45 10 12 10 12.55 10 13.02 10.2 13.41 10.59 13.8 10.98 14 11.45 14 12 14 12.55 13.8 13.02 13.41 13.41 13.02 13.8 12.55 14 12 14 m 12 8 b 11.45 8 10.98 7.8 10.59 7.41 10.2 7.02 10 6.55 10 6 10 5.45 10.2 4.98 10.59 4.59 10.98 4.2 11.45 4 12 4 12.55 4 13.02 4.2 13.41 4.59 13.8 4.98 14 5.45 14 6 14 6.55 13.8 7.02 13.41 7.41 13.02 7.8 12.55 8 12 8",
    ["no_sound"] = "m 18 13.4 l 16.1 15.3 b 15.92 15.48 15.68 15.57 15.4 15.57 15.12 15.57 14.88 15.48 14.7 15.3 14.52 15.12 14.43 14.88 14.43 14.6 14.43 14.32 14.52 14.08 14.7 13.9 l 16.6 12 14.7 10.1 b 14.52 9.92 14.43 9.68 14.43 9.4 14.43 9.12 14.52 8.88 14.7 8.7 14.88 8.52 15.12 8.42 15.4 8.42 15.68 8.42 15.92 8.52 16.1 8.7 l 18 10.6 19.9 8.7 b 20.08 8.52 20.32 8.42 20.6 8.42 20.88 8.42 21.12 8.52 21.3 8.7 21.48 8.88 21.58 9.12 21.58 9.4 21.58 9.68 21.48 9.92 21.3 10.1 l 19.4 12 21.3 13.9 b 21.48 14.08 21.58 14.32 21.58 14.6 21.58 14.88 21.48 15.12 21.3 15.3 21.12 15.48 20.88 15.57 20.6 15.57 20.32 15.57 20.08 15.48 19.9 15.3 l 18 13.4 m 7 15 l 4 15 b 3.72 15 3.48 14.9 3.29 14.71 3.1 14.52 3 14.28 3 14 l 3 10 b 3 9.72 3.1 9.48 3.29 9.29 3.48 9.1 3.72 9 4 9 l 7 9 10.3 5.7 b 10.62 5.38 10.98 5.31 11.39 5.49 11.8 5.66 12 5.98 12 6.43 l 12 17.57 b 12 18.02 11.8 18.34 11.39 18.51 10.98 18.69 10.62 18.62 10.3 18.3 l 7 15 m 10 8.85 l 7.85 11 5 11 5 13 7.85 13 10 15.15 10 8.85",
    ["no_sound_filled"] = "m 18 13.4 l 16.1 15.3 b 15.92 15.48 15.68 15.57 15.4 15.57 15.12 15.57 14.88 15.48 14.7 15.3 14.52 15.12 14.43 14.88 14.43 14.6 14.43 14.32 14.52 14.08 14.7 13.9 l 16.6 12 14.7 10.1 b 14.52 9.92 14.43 9.68 14.43 9.4 14.43 9.12 14.52 8.88 14.7 8.7 14.88 8.52 15.12 8.42 15.4 8.42 15.68 8.42 15.92 8.52 16.1 8.7 l 18 10.6 19.9 8.7 b 20.08 8.52 20.32 8.42 20.6 8.42 20.88 8.42 21.12 8.52 21.3 8.7 21.48 8.88 21.58 9.12 21.58 9.4 21.58 9.68 21.48 9.92 21.3 10.1 l 19.4 12 21.3 13.9 b 21.48 14.08 21.58 14.32 21.58 14.6 21.58 14.88 21.48 15.12 21.3 15.3 21.12 15.48 20.88 15.57 20.6 15.57 20.32 15.57 20.08 15.48 19.9 15.3 l 18 13.4 m 7 15 l 4 15 b 3.72 15 3.48 14.9 3.29 14.71 3.1 14.52 3 14.28 3 14 l 3 10 b 3 9.72 3.1 9.48 3.29 9.29 3.48 9.1 3.72 9 4 9 l 7 9 10.3 5.7 b 10.62 5.38 10.98 5.31 11.39 5.49 11.8 5.66 12 5.98 12 6.43 l 12 17.57 b 12 18.02 11.8 18.34 11.39 18.51 10.98 18.69 10.62 18.62 10.3 18.3 l 7 15",
    ["pause"] = "m 15 19 b 14.45 19 13.98 18.8 13.59 18.41 13.2 18.02 13 17.55 13 17 l 13 7 b 13 6.45 13.2 5.98 13.59 5.59 13.98 5.2 14.45 5 15 5 l 17 5 b 17.55 5 18.02 5.2 18.41 5.59 18.8 5.98 19 6.45 19 7 l 19 17 b 19 17.55 18.8 18.02 18.41 18.41 18.02 18.8 17.55 19 17 19 l 15 19 m 7 19 b 6.45 19 5.98 18.8 5.59 18.41 5.2 18.02 5 17.55 5 17 l 5 7 b 5 6.45 5.2 5.98 5.59 5.59 5.98 5.2 6.45 5 7 5 l 9 5 b 9.55 5 10.02 5.2 10.41 5.59 10.8 5.98 11 6.45 11 7 l 11 17 b 11 17.55 10.8 18.02 10.41 18.41 10.02 18.8 9.55 19 9 19 l 7 19 m 15 17 l 17 17 17 7 15 7 15 17 m 7 17 l 9 17 9 7 7 7 7 17 m 7 7 l 7 17 7 7 m 15 7 l 15 17 15 7",
    ["pause_filled"] = "m 16 19 b 15.45 19 14.98 18.8 14.59 18.41 14.2 18.02 14 17.55 14 17 l 14 7 b 14 6.45 14.2 5.98 14.59 5.59 14.98 5.2 15.45 5 16 5 16.55 5 17.02 5.2 17.41 5.59 17.8 5.98 18 6.45 18 7 l 18 17 b 18 17.55 17.8 18.02 17.41 18.41 17.02 18.8 16.55 19 16 19 m 8 19 b 7.45 19 6.98 18.8 6.59 18.41 6.2 18.02 6 17.55 6 17 l 6 7 b 6 6.45 6.2 5.98 6.59 5.59 6.98 5.2 7.45 5 8 5 8.55 5 9.02 5.2 9.41 5.59 9.8 5.98 10 6.45 10 7 l 10 17 b 10 17.55 9.8 18.02 9.41 18.41 9.02 18.8 8.55 19 8 19",
    ["photo_camera"] = "m 12 17.5 b 13.25 17.5 14.31 17.06 15.19 16.19 16.06 15.31 16.5 14.25 16.5 13 16.5 11.75 16.06 10.69 15.19 9.81 14.31 8.94 13.25 8.5 12 8.5 10.75 8.5 9.69 8.94 8.81 9.81 7.94 10.69 7.5 11.75 7.5 13 7.5 14.25 7.94 15.31 8.81 16.19 9.69 17.06 10.75 17.5 12 17.5 m 12 15.5 b 11.3 15.5 10.71 15.26 10.23 14.78 9.74 14.29 9.5 13.7 9.5 13 9.5 12.3 9.74 11.71 10.23 11.22 10.71 10.74 11.3 10.5 12 10.5 12.7 10.5 13.29 10.74 13.78 11.22 14.26 11.71 14.5 12.3 14.5 13 14.5 13.7 14.26 14.29 13.78 14.78 13.29 15.26 12.7 15.5 12 15.5 m 4 21 b 3.45 21 2.98 20.8 2.59 20.41 2.2 20.02 2 19.55 2 19 l 2 7 b 2 6.45 2.2 5.98 2.59 5.59 2.98 5.2 3.45 5 4 5 l 7.15 5 8.4 3.65 b 8.58 3.45 8.8 3.29 9.06 3.17 9.32 3.06 9.59 3 9.88 3 l 14.12 3 b 14.41 3 14.68 3.06 14.94 3.17 15.2 3.29 15.42 3.45 15.6 3.65 l 16.85 5 20 5 b 20.55 5 21.02 5.2 21.41 5.59 21.8 5.98 22 6.45 22 7 l 22 19 b 22 19.55 21.8 20.02 21.41 20.41 21.02 20.8 20.55 21 20 21 l 4 21 m 4 19 l 20 19 20 7 15.95 7 14.12 5 9.88 5 8.05 7 4 7 4 19",
    ["photo_camera_filled"] = "m 12 17.5 b 13.25 17.5 14.31 17.06 15.19 16.19 16.06 15.31 16.5 14.25 16.5 13 16.5 11.75 16.06 10.69 15.19 9.81 14.31 8.94 13.25 8.5 12 8.5 10.75 8.5 9.69 8.94 8.81 9.81 7.94 10.69 7.5 11.75 7.5 13 7.5 14.25 7.94 15.31 8.81 16.19 9.69 17.06 10.75 17.5 12 17.5 m 12 15.5 b 11.3 15.5 10.71 15.26 10.23 14.78 9.74 14.29 9.5 13.7 9.5 13 9.5 12.3 9.74 11.71 10.23 11.22 10.71 10.74 11.3 10.5 12 10.5 12.7 10.5 13.29 10.74 13.78 11.22 14.26 11.71 14.5 12.3 14.5 13 14.5 13.7 14.26 14.29 13.78 14.78 13.29 15.26 12.7 15.5 12 15.5 m 4 21 b 3.45 21 2.98 20.8 2.59 20.41 2.2 20.02 2 19.55 2 19 l 2 7 b 2 6.45 2.2 5.98 2.59 5.59 2.98 5.2 3.45 5 4 5 l 7.15 5 9 3 15 3 16.85 5 20 5 b 20.55 5 21.02 5.2 21.41 5.59 21.8 5.98 22 6.45 22 7 l 22 19 b 22 19.55 21.8 20.02 21.41 20.41 21.02 20.8 20.55 21 20 21 l 4 21",
    ["pip"] = "m 3 11 b 2.72 11 2.48 10.9 2.29 10.71 2.1 10.52 2 10.28 2 10 2 9.72 2.1 9.48 2.29 9.29 2.48 9.1 2.72 9 3 9 l 5.6 9 2 5.43 b 1.8 5.23 1.7 4.99 1.7 4.71 1.7 4.44 1.8 4.2 2 4 2.2 3.8 2.44 3.7 2.71 3.7 2.99 3.7 3.23 3.8 3.43 4 l 7 7.6 7 5 b 7 4.72 7.1 4.48 7.29 4.29 7.48 4.1 7.72 4 8 4 8.28 4 8.52 4.1 8.71 4.29 8.9 4.48 9 4.72 9 5 l 9 10 b 9 10.28 8.9 10.52 8.71 10.71 8.52 10.9 8.28 11 8 11 l 3 11 m 4 20 b 3.45 20 2.98 19.8 2.59 19.41 2.2 19.02 2 18.55 2 18 l 2 14 b 2 13.72 2.1 13.48 2.29 13.29 2.48 13.1 2.72 13 3 13 3.28 13 3.52 13.1 3.71 13.29 3.9 13.48 4 13.72 4 14 l 4 18 11 18 b 11.28 18 11.52 18.1 11.71 18.29 11.9 18.48 12 18.72 12 19 12 19.28 11.9 19.52 11.71 19.71 11.52 19.9 11.28 20 11 20 l 4 20 m 20.29 12.71 b 20.1 12.52 20 12.28 20 12 l 20 6 12 6 b 11.72 6 11.48 5.9 11.29 5.71 11.1 5.52 11 5.28 11 5 11 4.72 11.1 4.48 11.29 4.29 11.48 4.1 11.72 4 12 4 l 20 4 b 20.55 4 21.02 4.2 21.41 4.59 21.8 4.98 22 5.45 22 6 l 22 12 b 22 12.28 21.9 12.52 21.71 12.71 21.52 12.9 21.28 13 21 13 20.72 13 20.48 12.9 20.29 12.71 m 15 20 b 14.72 20 14.48 19.9 14.29 19.71 14.1 19.52 14 19.28 14 19 l 14 16 b 14 15.72 14.1 15.48 14.29 15.29 14.48 15.1 14.72 15 15 15 l 21 15 b 21.28 15 21.52 15.1 21.71 15.29 21.9 15.48 22 15.72 22 16 l 22 19 b 22 19.28 21.9 19.52 21.71 19.71 21.52 19.9 21.28 20 21 20 l 15 20",
    ["pip_exit"] = "m 4 20 b 3.45 20 2.98 19.8 2.59 19.41 2.2 19.02 2 18.55 2 18 l 2 12 b 2 11.72 2.1 11.48 2.29 11.29 2.48 11.1 2.72 11 3 11 3.28 11 3.52 11.1 3.71 11.29 3.9 11.48 4 11.72 4 12 l 4 18 20 18 20 6 12 6 b 11.72 6 11.48 5.9 11.29 5.71 11.1 5.52 11 5.28 11 5 11 4.72 11.1 4.48 11.29 4.29 11.48 4.1 11.72 4 12 4 l 20 4 b 20.55 4 21.02 4.2 21.41 4.59 21.8 4.98 22 5.45 22 6 l 22 18 b 22 18.55 21.8 19.02 21.41 19.41 21.02 19.8 20.55 20 20 20 l 4 20 m 14 13.42 l 16.38 15.8 b 16.57 16 16.81 16.1 17.07 16.1 17.34 16.1 17.58 16 17.78 15.8 17.98 15.6 18.07 15.36 18.07 15.09 18.07 14.81 17.98 14.57 17.78 14.38 l 15.4 12 17 12 b 17.28 12 17.52 11.9 17.71 11.71 17.9 11.52 18 11.28 18 11 18 10.72 17.9 10.48 17.71 10.29 17.52 10.1 17.28 10 17 10 l 13 10 b 12.72 10 12.48 10.1 12.29 10.29 12.1 10.48 12 10.72 12 11 l 12 15 b 12 15.28 12.1 15.52 12.29 15.71 12.48 15.9 12.72 16 13 16 13.28 16 13.52 15.9 13.71 15.71 13.9 15.52 14 15.28 14 15 l 14 13.42 m 3 9 b 2.72 9 2.48 8.9 2.29 8.71 2.1 8.52 2 8.28 2 8 l 2 5 b 2 4.72 2.1 4.48 2.29 4.29 2.48 4.1 2.72 4 3 4 l 8 4 b 8.28 4 8.52 4.1 8.71 4.29 8.9 4.48 9 4.72 9 5 l 9 8 b 9 8.28 8.9 8.52 8.71 8.71 8.52 8.9 8.28 9 8 9 l 3 9",
    ["pip_exit_filled"] = "m 4 20 b 3.45 20 2.98 19.8 2.59 19.41 2.2 19.02 2 18.55 2 18 l 2 12 b 2 11.72 2.1 11.48 2.29 11.29 2.48 11.1 2.72 11 3 11 l 9 11 b 9.55 11 10.02 10.8 10.41 10.41 10.8 10.02 11 9.55 11 9 l 11 5 b 11 4.72 11.1 4.48 11.29 4.29 11.48 4.1 11.72 4 12 4 l 20 4 b 20.55 4 21.02 4.2 21.41 4.59 21.8 4.98 22 5.45 22 6 l 22 18 b 22 18.55 21.8 19.02 21.41 19.41 21.02 19.8 20.55 20 20 20 l 4 20 m 13 10 b 12.72 10 12.48 10.1 12.29 10.29 12.1 10.48 12 10.72 12 11 l 12 15 b 12 15.28 12.1 15.52 12.29 15.71 12.48 15.9 12.72 16 13 16 13.28 16 13.52 15.9 13.71 15.71 13.9 15.52 14 15.28 14 15 l 14 13.42 16.38 15.8 b 16.57 16 16.81 16.1 17.07 16.1 17.34 16.1 17.58 16 17.78 15.8 17.98 15.6 18.07 15.36 18.07 15.09 18.07 14.81 17.98 14.57 17.78 14.38 l 15.4 12 17 12 b 17.28 12 17.52 11.9 17.71 11.71 17.9 11.52 18 11.28 18 11 18 10.72 17.9 10.48 17.71 10.29 17.52 10.1 17.28 10 17 10 l 13 10 m 3 9 b 2.72 9 2.48 8.9 2.29 8.71 2.1 8.52 2 8.28 2 8 l 2 5 b 2 4.72 2.1 4.48 2.29 4.29 2.48 4.1 2.72 4 3 4 l 8 4 b 8.28 4 8.52 4.1 8.71 4.29 8.9 4.48 9 4.72 9 5 l 9 8 b 9 8.28 8.9 8.52 8.71 8.71 8.52 8.9 8.28 9 8 9 l 3 9",
    ["play_arrow"] = "m 8 17.18 l 8 6.82 b 8 6.54 8.1 6.3 8.3 6.11 8.5 5.92 8.73 5.82 9 5.82 9.08 5.82 9.17 5.84 9.26 5.86 9.35 5.89 9.44 5.92 9.53 5.97 l 17.68 11.15 b 17.83 11.25 17.94 11.37 18.01 11.52 18.09 11.67 18.12 11.83 18.12 12 18.12 12.17 18.09 12.32 18.01 12.47 17.94 12.62 17.83 12.75 17.68 12.85 l 9.53 18.02 b 9.44 18.07 9.35 18.11 9.26 18.14 9.17 18.16 9.08 18.18 9 18.18 8.73 18.18 8.5 18.08 8.3 17.89 8.1 17.7 8 17.46 8 17.18 m 10 15.35 l 15.25 12 10 8.65 10 15.35",
    ["play_arrow_filled"] = "m 8 17.18 l 8 6.82 b 8 6.54 8.1 6.3 8.3 6.11 8.5 5.92 8.73 5.82 9 5.82 9.08 5.82 9.17 5.84 9.26 5.86 9.35 5.89 9.44 5.92 9.53 5.97 l 17.68 11.15 b 17.83 11.25 17.94 11.37 18.01 11.52 18.09 11.67 18.12 11.83 18.12 12 18.12 12.17 18.09 12.32 18.01 12.47 17.94 12.62 17.83 12.75 17.68 12.85 l 9.53 18.02 b 9.44 18.07 9.35 18.11 9.26 18.14 9.17 18.16 9.08 18.18 9 18.18 8.73 18.18 8.5 18.08 8.3 17.89 8.1 17.7 8 17.46 8 17.18",
    ["playlist_play"] = "m 4 16 b 3.72 16 3.48 15.9 3.29 15.71 3.1 15.52 3 15.28 3 15 3 14.72 3.1 14.48 3.29 14.29 3.48 14.1 3.72 14 4 14 l 10 14 b 10.28 14 10.52 14.1 10.71 14.29 10.9 14.48 11 14.72 11 15 11 15.28 10.9 15.52 10.71 15.71 10.52 15.9 10.28 16 10 16 l 4 16 m 4 12 b 3.72 12 3.48 11.9 3.29 11.71 3.1 11.52 3 11.28 3 11 3 10.72 3.1 10.48 3.29 10.29 3.48 10.1 3.72 10 4 10 l 14 10 b 14.28 10 14.52 10.1 14.71 10.29 14.9 10.48 15 10.72 15 11 15 11.28 14.9 11.52 14.71 11.71 14.52 11.9 14.28 12 14 12 l 4 12 m 4 8 b 3.72 8 3.48 7.9 3.29 7.71 3.1 7.52 3 7.28 3 7 3 6.72 3.1 6.48 3.29 6.29 3.48 6.1 3.72 6 4 6 l 14 6 b 14.28 6 14.52 6.1 14.71 6.29 14.9 6.48 15 6.72 15 7 15 7.28 14.9 7.52 14.71 7.71 14.52 7.9 14.28 8 14 8 l 4 8 m 16.78 20.48 b 16.69 20.53 16.61 20.55 16.53 20.55 16.44 20.55 16.36 20.53 16.28 20.5 16.19 20.47 16.12 20.41 16.07 20.34 16.02 20.26 16 20.18 16 20.07 l 16 13.92 b 16 13.82 16.02 13.74 16.07 13.66 16.12 13.59 16.19 13.53 16.28 13.5 16.36 13.47 16.44 13.45 16.53 13.45 16.61 13.45 16.69 13.47 16.78 13.52 l 21.38 16.57 b 21.46 16.62 21.52 16.69 21.55 16.76 21.58 16.84 21.6 16.92 21.6 17 21.6 17.08 21.58 17.16 21.55 17.24 21.52 17.31 21.46 17.38 21.38 17.43 l 16.78 20.48",
    ["repeat"] = "m 6.85 19 l 7.7 19.85 b 7.9 20.05 8 20.28 7.99 20.55 7.98 20.82 7.88 21.05 7.7 21.25 7.5 21.45 7.26 21.55 6.99 21.56 6.71 21.57 6.48 21.47 6.28 21.27 l 3.7 18.7 b 3.6 18.6 3.53 18.49 3.49 18.38 3.45 18.26 3.43 18.13 3.43 18 3.43 17.87 3.45 17.74 3.49 17.62 3.53 17.51 3.6 17.4 3.7 17.3 l 6.28 14.72 b 6.48 14.52 6.71 14.43 6.99 14.44 7.26 14.45 7.5 14.55 7.7 14.75 7.88 14.95 7.98 15.18 7.99 15.45 8 15.72 7.9 15.95 7.7 16.15 l 6.85 17 17 17 17 14 b 17 13.72 17.1 13.48 17.29 13.29 17.48 13.1 17.72 13 18 13 18.28 13 18.52 13.1 18.71 13.29 18.9 13.48 19 13.72 19 14 l 19 17 b 19 17.55 18.8 18.02 18.41 18.41 18.02 18.8 17.55 19 17 19 l 6.85 19 m 17.15 7 l 7 7 7 10 b 7 10.28 6.9 10.52 6.71 10.71 6.52 10.9 6.28 11 6 11 5.72 11 5.48 10.9 5.29 10.71 5.1 10.52 5 10.28 5 10 l 5 7 b 5 6.45 5.2 5.98 5.59 5.59 5.98 5.2 6.45 5 7 5 l 17.15 5 16.3 4.15 b 16.1 3.95 16 3.72 16.01 3.45 16.02 3.18 16.12 2.95 16.3 2.75 16.5 2.55 16.74 2.45 17.01 2.44 17.29 2.43 17.53 2.52 17.73 2.72 l 20.3 5.3 b 20.4 5.4 20.47 5.51 20.51 5.62 20.55 5.74 20.58 5.87 20.58 6 20.58 6.13 20.55 6.26 20.51 6.38 20.47 6.49 20.4 6.6 20.3 6.7 l 17.73 9.27 b 17.53 9.47 17.29 9.57 17.01 9.56 16.74 9.55 16.5 9.45 16.3 9.25 16.12 9.05 16.02 8.82 16.01 8.55 16 8.28 16.1 8.05 16.3 7.85 l 17.15 7",
    ["repeat_on"] = "m 3 23 b 2.45 23 1.98 22.8 1.59 22.41 1.2 22.02 1 21.55 1 21 l 1 3 b 1 2.45 1.2 1.98 1.59 1.59 1.98 1.2 2.45 1 3 1 l 21 1 b 21.55 1 22.02 1.2 22.41 1.59 22.8 1.98 23 2.45 23 3 l 23 21 b 23 21.55 22.8 22.02 22.41 22.41 22.02 22.8 21.55 23 21 23 l 3 23 m 6.85 19 l 17 19 b 17.55 19 18.02 18.8 18.41 18.41 18.8 18.02 19 17.55 19 17 l 19 14 b 19 13.72 18.9 13.48 18.71 13.29 18.52 13.1 18.28 13 18 13 17.72 13 17.48 13.1 17.29 13.29 17.1 13.48 17 13.72 17 14 l 17 17 6.85 17 7.7 16.15 b 7.9 15.95 8 15.72 7.99 15.45 7.98 15.18 7.88 14.95 7.7 14.75 7.5 14.55 7.26 14.45 6.99 14.44 6.71 14.43 6.48 14.52 6.28 14.72 l 3.7 17.3 b 3.6 17.4 3.53 17.51 3.49 17.62 3.45 17.74 3.43 17.87 3.43 18 3.43 18.13 3.45 18.26 3.49 18.38 3.53 18.49 3.6 18.6 3.7 18.7 l 6.28 21.27 b 6.48 21.47 6.71 21.57 6.99 21.56 7.26 21.55 7.5 21.45 7.7 21.25 7.88 21.05 7.98 20.82 7.99 20.55 8 20.28 7.9 20.05 7.7 19.85 l 6.85 19 m 17.15 7 l 16.3 7.85 b 16.1 8.05 16 8.28 16.01 8.55 16.02 8.82 16.12 9.05 16.3 9.25 16.5 9.45 16.74 9.55 17.01 9.56 17.29 9.57 17.53 9.47 17.73 9.27 l 20.3 6.7 b 20.4 6.6 20.47 6.49 20.51 6.38 20.55 6.26 20.58 6.13 20.58 6 20.58 5.87 20.55 5.74 20.51 5.62 20.47 5.51 20.4 5.4 20.3 5.3 l 17.73 2.72 b 17.53 2.52 17.29 2.43 17.01 2.44 16.74 2.45 16.5 2.55 16.3 2.75 16.12 2.95 16.02 3.18 16.01 3.45 16 3.72 16.1 3.95 16.3 4.15 l 17.15 5 7 5 b 6.45 5 5.98 5.2 5.59 5.59 5.2 5.98 5 6.45 5 7 l 5 10 b 5 10.28 5.1 10.52 5.29 10.71 5.48 10.9 5.72 11 6 11 6.28 11 6.52 10.9 6.71 10.71 6.9 10.52 7 10.28 7 10 l 7 7 17.15 7",
    ["replay"] = "m 8.49 21.29 b 7.4 20.81 6.45 20.17 5.64 19.36 4.83 18.55 4.19 17.6 3.71 16.51 3.24 15.42 3 14.25 3 13 3 12.72 3.1 12.48 3.29 12.29 3.48 12.1 3.72 12 4 12 4.28 12 4.52 12.1 4.71 12.29 4.9 12.48 5 12.72 5 13 5 14.95 5.68 16.6 7.04 17.96 8.4 19.32 10.05 20 12 20 13.95 20 15.6 19.32 16.96 17.96 18.32 16.6 19 14.95 19 13 19 11.05 18.32 9.4 16.96 8.04 15.6 6.68 13.95 6 12 6 l 11.85 6 12.7 6.85 b 12.9 7.05 13 7.28 12.99 7.55 12.98 7.82 12.88 8.05 12.7 8.25 12.5 8.45 12.26 8.55 11.99 8.56 11.71 8.57 11.48 8.47 11.28 8.27 l 8.7 5.7 b 8.5 5.5 8.4 5.27 8.4 5 8.4 4.73 8.5 4.5 8.7 4.3 l 11.28 1.72 b 11.48 1.52 11.71 1.43 11.99 1.44 12.26 1.45 12.5 1.55 12.7 1.75 12.88 1.95 12.98 2.18 12.99 2.45 13 2.72 12.9 2.95 12.7 3.15 l 11.85 4 12 4 b 13.25 4 14.42 4.24 15.51 4.71 16.6 5.19 17.55 5.83 18.36 6.64 19.17 7.45 19.81 8.4 20.29 9.49 20.76 10.58 21 11.75 21 13 21 14.25 20.76 15.42 20.29 16.51 19.81 17.6 19.17 18.55 18.36 19.36 17.55 20.17 16.6 20.81 15.51 21.29 14.42 21.76 13.25 22 12 22 10.75 22 9.58 21.76 8.49 21.29",
    ["replay_10"] = "m 9 11.5 l 8.25 11.5 b 8.03 11.5 7.85 11.43 7.71 11.29 7.57 11.15 7.5 10.97 7.5 10.75 7.5 10.53 7.57 10.35 7.71 10.21 7.85 10.07 8.03 10 8.25 10 l 9.75 10 b 9.97 10 10.15 10.07 10.29 10.21 10.43 10.35 10.5 10.53 10.5 10.75 l 10.5 15.25 b 10.5 15.47 10.43 15.65 10.29 15.79 10.15 15.93 9.97 16 9.75 16 9.53 16 9.35 15.93 9.21 15.79 9.07 15.65 9 15.47 9 15.25 l 9 11.5 m 12.5 16 b 12.22 16 11.98 15.9 11.79 15.71 11.6 15.52 11.5 15.28 11.5 15 l 11.5 11 b 11.5 10.72 11.6 10.48 11.79 10.29 11.98 10.1 12.22 10 12.5 10 l 14.5 10 b 14.78 10 15.02 10.1 15.21 10.29 15.4 10.48 15.5 10.72 15.5 11 l 15.5 15 b 15.5 15.28 15.4 15.52 15.21 15.71 15.02 15.9 14.78 16 14.5 16 l 12.5 16 m 13 14.5 l 14 14.5 14 11.5 13 11.5 13 14.5 m 8.49 21.29 b 7.4 20.81 6.45 20.17 5.64 19.36 4.83 18.55 4.19 17.6 3.71 16.51 3.24 15.42 3 14.25 3 13 3 12.72 3.1 12.48 3.29 12.29 3.48 12.1 3.72 12 4 12 4.28 12 4.52 12.1 4.71 12.29 4.9 12.48 5 12.72 5 13 5 14.95 5.68 16.6 7.04 17.96 8.4 19.32 10.05 20 12 20 13.95 20 15.6 19.32 16.96 17.96 18.32 16.6 19 14.95 19 13 19 11.05 18.32 9.4 16.96 8.04 15.6 6.68 13.95 6 12 6 l 11.85 6 12.7 6.85 b 12.9 7.05 13 7.28 12.99 7.55 12.98 7.82 12.88 8.05 12.7 8.25 12.5 8.45 12.26 8.55 11.99 8.56 11.71 8.57 11.48 8.47 11.28 8.27 l 8.7 5.7 b 8.5 5.5 8.4 5.27 8.4 5 8.4 4.73 8.5 4.5 8.7 4.3 l 11.28 1.72 b 11.48 1.52 11.71 1.43 11.99 1.44 12.26 1.45 12.5 1.55 12.7 1.75 12.88 1.95 12.98 2.18 12.99 2.45 13 2.72 12.9 2.95 12.7 3.15 l 11.85 4 12 4 b 13.25 4 14.42 4.24 15.51 4.71 16.6 5.19 17.55 5.83 18.36 6.64 19.17 7.45 19.81 8.4 20.29 9.49 20.76 10.58 21 11.75 21 13 21 14.25 20.76 15.42 20.29 16.51 19.81 17.6 19.17 18.55 18.36 19.36 17.55 20.17 16.6 20.81 15.51 21.29 14.42 21.76 13.25 22 12 22 10.75 22 9.58 21.76 8.49 21.29",
    ["replay_30"] = "m 10.5 16 l 8.25 16 b 8.03 16 7.85 15.93 7.71 15.79 7.57 15.65 7.5 15.47 7.5 15.25 7.5 15.03 7.57 14.85 7.71 14.71 7.85 14.57 8.03 14.5 8.25 14.5 l 10 14.5 10 13.5 9 13.5 b 8.87 13.5 8.75 13.45 8.65 13.35 8.55 13.25 8.5 13.13 8.5 13 8.5 12.87 8.55 12.75 8.65 12.65 8.75 12.55 8.87 12.5 9 12.5 l 10 12.5 10 11.5 8.25 11.5 b 8.03 11.5 7.85 11.43 7.71 11.29 7.57 11.15 7.5 10.97 7.5 10.75 7.5 10.53 7.57 10.35 7.71 10.21 7.85 10.07 8.03 10 8.25 10 l 10.5 10 b 10.78 10 11.02 10.1 11.21 10.29 11.4 10.48 11.5 10.72 11.5 11 l 11.5 15 b 11.5 15.28 11.4 15.52 11.21 15.71 11.02 15.9 10.78 16 10.5 16 m 13.5 16 b 13.22 16 12.98 15.9 12.79 15.71 12.6 15.52 12.5 15.28 12.5 15 l 12.5 11 b 12.5 10.72 12.6 10.48 12.79 10.29 12.98 10.1 13.22 10 13.5 10 l 15.5 10 b 15.78 10 16.02 10.1 16.21 10.29 16.4 10.48 16.5 10.72 16.5 11 l 16.5 15 b 16.5 15.28 16.4 15.52 16.21 15.71 16.02 15.9 15.78 16 15.5 16 l 13.5 16 m 14 14.5 l 15 14.5 15 11.5 14 11.5 14 14.5 m 8.49 21.29 b 7.4 20.81 6.45 20.17 5.64 19.36 4.83 18.55 4.19 17.6 3.71 16.51 3.24 15.42 3 14.25 3 13 3 12.72 3.1 12.48 3.29 12.29 3.48 12.1 3.72 12 4 12 4.28 12 4.52 12.1 4.71 12.29 4.9 12.48 5 12.72 5 13 5 14.95 5.68 16.6 7.04 17.96 8.4 19.32 10.05 20 12 20 13.95 20 15.6 19.32 16.96 17.96 18.32 16.6 19 14.95 19 13 19 11.05 18.32 9.4 16.96 8.04 15.6 6.68 13.95 6 12 6 l 11.85 6 12.7 6.85 b 12.9 7.05 13 7.28 12.99 7.55 12.98 7.82 12.88 8.05 12.7 8.25 12.5 8.45 12.26 8.55 11.99 8.56 11.71 8.57 11.48 8.47 11.28 8.27 l 8.7 5.7 b 8.5 5.5 8.4 5.27 8.4 5 8.4 4.73 8.5 4.5 8.7 4.3 l 11.28 1.72 b 11.48 1.52 11.71 1.43 11.99 1.44 12.26 1.45 12.5 1.55 12.7 1.75 12.88 1.95 12.98 2.18 12.99 2.45 13 2.72 12.9 2.95 12.7 3.15 l 11.85 4 12 4 b 13.25 4 14.42 4.24 15.51 4.71 16.6 5.19 17.55 5.83 18.36 6.64 19.17 7.45 19.81 8.4 20.29 9.49 20.76 10.58 21 11.75 21 13 21 14.25 20.76 15.42 20.29 16.51 19.81 17.6 19.17 18.55 18.36 19.36 17.55 20.17 16.6 20.81 15.51 21.29 14.42 21.76 13.25 22 12 22 10.75 22 9.58 21.76 8.49 21.29",
    ["replay_5"] = "m 13 16 l 10.25 16 b 10.03 16 9.85 15.93 9.71 15.79 9.57 15.65 9.5 15.47 9.5 15.25 9.5 15.03 9.57 14.85 9.71 14.71 9.85 14.57 10.03 14.5 10.25 14.5 l 12.5 14.5 12.5 13.5 10.25 13.5 b 10.03 13.5 9.85 13.43 9.71 13.29 9.57 13.15 9.5 12.97 9.5 12.75 l 9.5 10.75 b 9.5 10.53 9.57 10.35 9.71 10.21 9.85 10.07 10.03 10 10.25 10 l 13.25 10 b 13.47 10 13.65 10.07 13.79 10.21 13.93 10.35 14 10.53 14 10.75 14 10.97 13.93 11.15 13.79 11.29 13.65 11.43 13.47 11.5 13.25 11.5 l 11 11.5 11 12.5 13.25 12.5 b 13.47 12.5 13.65 12.57 13.79 12.71 13.93 12.85 14 13.03 14 13.25 l 14 15 b 14 15.28 13.9 15.52 13.71 15.71 13.52 15.9 13.28 16 13 16 m 8.49 21.29 b 7.4 20.81 6.45 20.17 5.64 19.36 4.83 18.55 4.19 17.6 3.71 16.51 3.24 15.42 3 14.25 3 13 3 12.72 3.1 12.48 3.29 12.29 3.48 12.1 3.72 12 4 12 4.28 12 4.52 12.1 4.71 12.29 4.9 12.48 5 12.72 5 13 5 14.95 5.68 16.6 7.04 17.96 8.4 19.32 10.05 20 12 20 13.95 20 15.6 19.32 16.96 17.96 18.32 16.6 19 14.95 19 13 19 11.05 18.32 9.4 16.96 8.04 15.6 6.68 13.95 6 12 6 l 11.85 6 12.7 6.85 b 12.9 7.05 13 7.28 12.99 7.55 12.98 7.82 12.88 8.05 12.7 8.25 12.5 8.45 12.26 8.55 11.99 8.56 11.71 8.57 11.48 8.47 11.28 8.27 l 8.7 5.7 b 8.5 5.5 8.4 5.27 8.4 5 8.4 4.73 8.5 4.5 8.7 4.3 l 11.28 1.72 b 11.48 1.52 11.71 1.43 11.99 1.44 12.26 1.45 12.5 1.55 12.7 1.75 12.88 1.95 12.98 2.18 12.99 2.45 13 2.72 12.9 2.95 12.7 3.15 l 11.85 4 12 4 b 13.25 4 14.42 4.24 15.51 4.71 16.6 5.19 17.55 5.83 18.36 6.64 19.17 7.45 19.81 8.4 20.29 9.49 20.76 10.58 21 11.75 21 13 21 14.25 20.76 15.42 20.29 16.51 19.81 17.6 19.17 18.55 18.36 19.36 17.55 20.17 16.6 20.81 15.51 21.29 14.42 21.76 13.25 22 12 22 10.75 22 9.58 21.76 8.49 21.29",
    ["shuffle"] = "m 15 20 b 14.72 20 14.48 19.9 14.29 19.71 14.1 19.52 14 19.28 14 19 14 18.72 14.1 18.48 14.29 18.29 14.48 18.1 14.72 18 15 18 l 16.6 18 14.12 15.53 b 13.93 15.32 13.83 15.09 13.84 14.81 13.85 14.54 13.95 14.3 14.15 14.1 14.35 13.9 14.59 13.8 14.86 13.8 15.14 13.8 15.38 13.9 15.58 14.1 l 18 16.55 18 15 b 18 14.72 18.1 14.48 18.29 14.29 18.48 14.1 18.72 14 19 14 19.28 14 19.52 14.1 19.71 14.29 19.9 14.48 20 14.72 20 15 l 20 19 b 20 19.28 19.9 19.52 19.71 19.71 19.52 19.9 19.28 20 19 20 l 15 20 m 4.3 19.7 b 4.12 19.52 4.03 19.28 4.03 19 4.03 18.72 4.12 18.48 4.3 18.3 l 16.6 6 15 6 b 14.72 6 14.48 5.9 14.29 5.71 14.1 5.52 14 5.28 14 5 14 4.72 14.1 4.48 14.29 4.29 14.48 4.1 14.72 4 15 4 l 19 4 b 19.28 4 19.52 4.1 19.71 4.29 19.9 4.48 20 4.72 20 5 l 20 9 b 20 9.28 19.9 9.52 19.71 9.71 19.52 9.9 19.28 10 19 10 18.72 10 18.48 9.9 18.29 9.71 18.1 9.52 18 9.28 18 9 l 18 7.4 5.7 19.7 b 5.52 19.88 5.28 19.98 5 19.98 4.72 19.98 4.48 19.88 4.3 19.7 m 4.28 5.7 b 4.09 5.52 4 5.28 4 5 4 4.72 4.09 4.48 4.28 4.3 4.46 4.12 4.69 4.02 4.96 4.02 5.24 4.02 5.48 4.12 5.68 4.3 l 9.88 8.47 b 10.06 8.66 10.15 8.89 10.16 9.16 10.17 9.44 10.08 9.67 9.88 9.88 9.69 10.06 9.46 10.15 9.18 10.15 8.89 10.15 8.66 10.06 8.47 9.88 l 4.28 5.7",
    ["shuffle_on"] = "m 3 23 b 2.45 23 1.98 22.8 1.59 22.41 1.2 22.02 1 21.55 1 21 l 1 3 b 1 2.45 1.2 1.98 1.59 1.59 1.98 1.2 2.45 1 3 1 l 21 1 b 21.55 1 22.02 1.2 22.41 1.59 22.8 1.98 23 2.45 23 3 l 23 21 b 23 21.55 22.8 22.02 22.41 22.41 22.02 22.8 21.55 23 21 23 l 3 23 m 15 20 l 19 20 b 19.28 20 19.52 19.9 19.71 19.71 19.9 19.52 20 19.28 20 19 l 20 15 b 20 14.72 19.9 14.48 19.71 14.29 19.52 14.1 19.28 14 19 14 18.72 14 18.48 14.1 18.29 14.29 18.1 14.48 18 14.72 18 15 l 18 16.55 15.58 14.12 b 15.38 13.92 15.14 13.82 14.86 13.82 14.59 13.82 14.35 13.92 14.15 14.12 13.95 14.32 13.85 14.56 13.84 14.82 13.83 15.09 13.93 15.32 14.12 15.53 l 16.6 18 15 18 b 14.72 18 14.48 18.1 14.29 18.29 14.1 18.48 14 18.72 14 19 14 19.28 14.1 19.52 14.29 19.71 14.48 19.9 14.72 20 15 20 m 4.3 19.7 b 4.48 19.88 4.72 19.98 5 19.98 5.28 19.98 5.52 19.88 5.7 19.7 l 18 7.4 18 9 b 18 9.28 18.1 9.52 18.29 9.71 18.48 9.9 18.72 10 19 10 19.28 10 19.52 9.9 19.71 9.71 19.9 9.52 20 9.28 20 9 l 20 5 b 20 4.72 19.9 4.48 19.71 4.29 19.52 4.1 19.28 4 19 4 l 15 4 b 14.72 4 14.48 4.1 14.29 4.29 14.1 4.48 14 4.72 14 5 14 5.28 14.1 5.52 14.29 5.71 14.48 5.9 14.72 6 15 6 l 16.6 6 4.3 18.3 b 4.12 18.48 4.03 18.72 4.03 19 4.03 19.28 4.12 19.52 4.3 19.7 m 4.28 5.7 l 8.47 9.88 b 8.66 10.06 8.89 10.15 9.18 10.15 9.46 10.15 9.69 10.06 9.88 9.88 10.08 9.67 10.17 9.44 10.16 9.16 10.15 8.89 10.06 8.66 9.88 8.47 l 5.68 4.3 b 5.48 4.12 5.24 4.02 4.96 4.02 4.69 4.02 4.46 4.12 4.28 4.3 4.09 4.48 4 4.72 4 5 4 5.28 4.09 5.52 4.28 5.7",
    ["skip_next"] = "m 16.5 17 l 16.5 7 b 16.5 6.72 16.6 6.48 16.79 6.29 16.98 6.1 17.22 6 17.5 6 17.78 6 18.02 6.1 18.21 6.29 18.4 6.48 18.5 6.72 18.5 7 l 18.5 17 b 18.5 17.28 18.4 17.52 18.21 17.71 18.02 17.9 17.78 18 17.5 18 17.22 18 16.98 17.9 16.79 17.71 16.6 17.52 16.5 17.28 16.5 17 m 5.5 16.12 l 5.5 7.88 b 5.5 7.58 5.6 7.33 5.8 7.15 6 6.97 6.23 6.88 6.5 6.88 6.58 6.88 6.67 6.88 6.78 6.9 6.88 6.92 6.97 6.96 7.05 7.02 l 13.25 11.17 b 13.4 11.27 13.51 11.4 13.59 11.54 13.66 11.68 13.7 11.83 13.7 12 13.7 12.17 13.66 12.32 13.59 12.46 13.51 12.6 13.4 12.72 13.25 12.82 l 7.05 16.98 b 6.97 17.04 6.88 17.08 6.78 17.1 6.67 17.12 6.58 17.12 6.5 17.12 6.23 17.12 6 17.03 5.8 16.85 5.6 16.67 5.5 16.43 5.5 16.12 m 7.5 14.25 l 10.9 12 7.5 9.75 7.5 14.25",
    ["skip_next_filled"] = "m 16.5 17 l 16.5 7 b 16.5 6.72 16.6 6.48 16.79 6.29 16.98 6.1 17.22 6 17.5 6 17.78 6 18.02 6.1 18.21 6.29 18.4 6.48 18.5 6.72 18.5 7 l 18.5 17 b 18.5 17.28 18.4 17.52 18.21 17.71 18.02 17.9 17.78 18 17.5 18 17.22 18 16.98 17.9 16.79 17.71 16.6 17.52 16.5 17.28 16.5 17 m 5.5 16.12 l 5.5 7.88 b 5.5 7.58 5.6 7.33 5.8 7.15 6 6.97 6.23 6.88 6.5 6.88 6.58 6.88 6.67 6.88 6.78 6.9 6.88 6.92 6.97 6.96 7.05 7.02 l 13.25 11.17 b 13.4 11.27 13.51 11.4 13.59 11.54 13.66 11.68 13.7 11.83 13.7 12 13.7 12.17 13.66 12.32 13.59 12.46 13.51 12.6 13.4 12.72 13.25 12.82 l 7.05 16.98 b 6.97 17.04 6.88 17.08 6.78 17.1 6.67 17.12 6.58 17.12 6.5 17.12 6.23 17.12 6 17.03 5.8 16.85 5.6 16.67 5.5 16.43 5.5 16.12",
    ["skip_previous"] = "m 5.5 17 l 5.5 7 b 5.5 6.72 5.6 6.48 5.79 6.29 5.98 6.1 6.22 6 6.5 6 6.78 6 7.02 6.1 7.21 6.29 7.4 6.48 7.5 6.72 7.5 7 l 7.5 17 b 7.5 17.28 7.4 17.52 7.21 17.71 7.02 17.9 6.78 18 6.5 18 6.22 18 5.98 17.9 5.79 17.71 5.6 17.52 5.5 17.28 5.5 17 m 16.95 16.98 l 10.75 12.82 b 10.6 12.72 10.49 12.6 10.41 12.46 10.34 12.32 10.3 12.17 10.3 12 10.3 11.83 10.34 11.68 10.41 11.54 10.49 11.4 10.6 11.27 10.75 11.17 l 16.95 7.02 b 17.03 6.96 17.12 6.92 17.23 6.9 17.32 6.88 17.42 6.88 17.5 6.88 17.77 6.88 18 6.97 18.2 7.15 18.4 7.33 18.5 7.58 18.5 7.88 l 18.5 16.12 b 18.5 16.43 18.4 16.67 18.2 16.85 18 17.03 17.77 17.12 17.5 17.12 17.42 17.12 17.32 17.12 17.23 17.1 17.12 17.08 17.03 17.04 16.95 16.98 m 16.5 14.25 l 16.5 9.75 13.1 12 16.5 14.25",
    ["skip_previous_filled"] = "m 5.5 17 l 5.5 7 b 5.5 6.72 5.6 6.48 5.79 6.29 5.98 6.1 6.22 6 6.5 6 6.78 6 7.02 6.1 7.21 6.29 7.4 6.48 7.5 6.72 7.5 7 l 7.5 17 b 7.5 17.28 7.4 17.52 7.21 17.71 7.02 17.9 6.78 18 6.5 18 6.22 18 5.98 17.9 5.79 17.71 5.6 17.52 5.5 17.28 5.5 17 m 16.95 16.98 l 10.75 12.82 b 10.6 12.72 10.49 12.6 10.41 12.46 10.34 12.32 10.3 12.17 10.3 12 10.3 11.83 10.34 11.68 10.41 11.54 10.49 11.4 10.6 11.27 10.75 11.17 l 16.95 7.02 b 17.03 6.96 17.12 6.92 17.23 6.9 17.32 6.88 17.42 6.88 17.5 6.88 17.77 6.88 18 6.97 18.2 7.15 18.4 7.33 18.5 7.58 18.5 7.88 l 18.5 16.12 b 18.5 16.43 18.4 16.67 18.2 16.85 18 17.03 17.77 17.12 17.5 17.12 17.42 17.12 17.32 17.12 17.23 17.1 17.12 17.08 17.03 17.04 16.95 16.98",
    ["speed"] = "m 12 16.09 b 12.63 16.08 13.1 15.85 13.4 15.4 l 17.62 9.07 b 17.78 8.84 17.75 8.63 17.56 8.44 17.37 8.25 17.16 8.22 16.93 8.38 l 10.6 12.6 b 10.15 12.9 9.91 13.36 9.89 13.97 9.86 14.59 10.05 15.1 10.45 15.5 10.85 15.9 11.37 16.1 12 16.09 m 12 4 b 12.6 4 13.19 4.05 13.78 4.15 14.36 4.25 14.93 4.41 15.48 4.62 15.74 4.72 16.02 4.91 16.32 5.19 16.62 5.46 16.71 5.72 16.57 5.97 16.44 6.22 16.14 6.39 15.68 6.47 15.21 6.56 14.83 6.55 14.55 6.45 14.13 6.3 13.71 6.19 13.29 6.11 12.86 6.04 12.43 6 12 6 9.78 6 7.9 6.78 6.34 8.34 4.78 9.9 4 11.78 4 14 4 14.7 4.1 15.39 4.29 16.07 4.48 16.76 4.75 17.4 5.1 18 l 18.9 18 b 19.28 17.37 19.56 16.71 19.74 16.02 19.91 15.34 20 14.63 20 13.9 20 13.47 19.96 13.04 19.89 12.62 19.81 12.21 19.7 11.8 19.55 11.4 19.45 11.12 19.43 10.84 19.5 10.57 19.57 10.31 19.72 10.08 19.95 9.9 20.17 9.73 20.4 9.68 20.66 9.75 20.92 9.82 21.1 9.97 21.2 10.2 21.45 10.78 21.64 11.38 21.78 11.99 21.91 12.6 21.98 13.22 22 13.85 22.02 14.8 21.91 15.71 21.68 16.57 21.44 17.44 21.1 18.27 20.65 19.05 20.47 19.35 20.22 19.58 19.9 19.75 19.58 19.92 19.25 20 18.9 20 l 5.1 20 b 4.75 20 4.42 19.92 4.1 19.75 3.78 19.58 3.53 19.35 3.35 19.05 2.92 18.3 2.58 17.5 2.35 16.66 2.12 15.82 2 14.93 2 14 2 12.62 2.26 11.32 2.79 10.11 3.31 8.9 4.03 7.85 4.94 6.94 5.85 6.03 6.91 5.31 8.12 4.79 9.34 4.26 10.63 4 12 4",
    ["speed_filled"] = "m 10.45 15.5 b 10.87 15.92 11.39 16.11 12.03 16.09 12.66 16.06 13.12 15.83 13.4 15.4 l 19 7 10.6 12.6 b 10.17 12.9 9.93 13.35 9.89 13.96 9.85 14.57 10.03 15.08 10.45 15.5 m 5.1 20 b 4.73 20 4.4 19.92 4.09 19.76 3.78 19.6 3.53 19.37 3.35 19.05 2.92 18.27 2.58 17.45 2.35 16.61 2.12 15.77 2 14.9 2 14 2 12.62 2.26 11.32 2.79 10.1 3.31 8.88 4.03 7.82 4.93 6.93 5.83 6.02 6.88 5.31 8.1 4.79 9.32 4.26 10.62 4 12 4 13.37 4 14.65 4.26 15.85 4.77 17.05 5.29 18.1 6 19 6.89 19.9 7.78 20.62 8.82 21.15 10.01 21.68 11.2 21.96 12.48 21.98 13.85 21.99 14.77 21.89 15.66 21.66 16.54 21.44 17.41 21.09 18.25 20.62 19.05 20.44 19.37 20.2 19.6 19.89 19.76 19.58 19.92 19.24 20 18.88 20 l 5.1 20",
    ["subtitles"] = "m 4 20 b 3.45 20 2.98 19.8 2.59 19.41 2.2 19.02 2 18.55 2 18 l 2 6 b 2 5.45 2.2 4.98 2.59 4.59 2.98 4.2 3.45 4 4 4 l 20 4 b 20.55 4 21.02 4.2 21.41 4.59 21.8 4.98 22 5.45 22 6 l 22 18 b 22 18.55 21.8 19.02 21.41 19.41 21.02 19.8 20.55 20 20 20 l 4 20 m 4 18 l 20 18 20 6 4 6 4 18 m 4 18 l 4 6 4 18 m 7 16 l 13 16 b 13.28 16 13.52 15.9 13.71 15.71 13.9 15.52 14 15.28 14 15 14 14.72 13.9 14.48 13.71 14.29 13.52 14.1 13.28 14 13 14 l 7 14 b 6.72 14 6.48 14.1 6.29 14.29 6.1 14.48 6 14.72 6 15 6 15.28 6.1 15.52 6.29 15.71 6.48 15.9 6.72 16 7 16 m 11 12 l 17 12 b 17.28 12 17.52 11.9 17.71 11.71 17.9 11.52 18 11.28 18 11 18 10.72 17.9 10.48 17.71 10.29 17.52 10.1 17.28 10 17 10 l 11 10 b 10.72 10 10.48 10.1 10.29 10.29 10.1 10.48 10 10.72 10 11 10 11.28 10.1 11.52 10.29 11.71 10.48 11.9 10.72 12 11 12 m 7.71 11.71 b 7.9 11.52 8 11.28 8 11 8 10.72 7.9 10.48 7.71 10.29 7.52 10.1 7.28 10 7 10 6.72 10 6.48 10.1 6.29 10.29 6.1 10.48 6 10.72 6 11 6 11.28 6.1 11.52 6.29 11.71 6.48 11.9 6.72 12 7 12 7.28 12 7.52 11.9 7.71 11.71 m 17.71 15.71 b 17.9 15.52 18 15.28 18 15 18 14.72 17.9 14.48 17.71 14.29 17.52 14.1 17.28 14 17 14 16.72 14 16.48 14.1 16.29 14.29 16.1 14.48 16 14.72 16 15 16 15.28 16.1 15.52 16.29 15.71 16.48 15.9 16.72 16 17 16 17.28 16 17.52 15.9 17.71 15.71",
    ["subtitles_filled"] = "m 4 20 b 3.45 20 2.98 19.8 2.59 19.41 2.2 19.02 2 18.55 2 18 l 2 6 b 2 5.45 2.2 4.98 2.59 4.59 2.98 4.2 3.45 4 4 4 l 20 4 b 20.55 4 21.02 4.2 21.41 4.59 21.8 4.98 22 5.45 22 6 l 22 18 b 22 18.55 21.8 19.02 21.41 19.41 21.02 19.8 20.55 20 20 20 l 4 20 m 7 16 l 13 16 b 13.28 16 13.52 15.9 13.71 15.71 13.9 15.52 14 15.28 14 15 14 14.72 13.9 14.48 13.71 14.29 13.52 14.1 13.28 14 13 14 l 7 14 b 6.72 14 6.48 14.1 6.29 14.29 6.1 14.48 6 14.72 6 15 6 15.28 6.1 15.52 6.29 15.71 6.48 15.9 6.72 16 7 16 m 11 12 l 17 12 b 17.28 12 17.52 11.9 17.71 11.71 17.9 11.52 18 11.28 18 11 18 10.72 17.9 10.48 17.71 10.29 17.52 10.1 17.28 10 17 10 l 11 10 b 10.72 10 10.48 10.1 10.29 10.29 10.1 10.48 10 10.72 10 11 10 11.28 10.1 11.52 10.29 11.71 10.48 11.9 10.72 12 11 12 m 7.71 11.71 b 7.9 11.52 8 11.28 8 11 8 10.72 7.9 10.48 7.71 10.29 7.52 10.1 7.28 10 7 10 6.72 10 6.48 10.1 6.29 10.29 6.1 10.48 6 10.72 6 11 6 11.28 6.1 11.52 6.29 11.71 6.48 11.9 6.72 12 7 12 7.28 12 7.52 11.9 7.71 11.71 m 17.71 15.71 b 17.9 15.52 18 15.28 18 15 18 14.72 17.9 14.48 17.71 14.29 17.52 14.1 17.28 14 17 14 16.72 14 16.48 14.1 16.29 14.29 16.1 14.48 16 14.72 16 15 16 15.28 16.1 15.52 16.29 15.71 16.48 15.9 16.72 16 17 16 17.28 16 17.52 15.9 17.71 15.71",
    ["surround_sound"] = "m 14.12 14.12 b 14.71 13.54 15 12.83 15 12 15 11.17 14.71 10.46 14.12 9.88 13.54 9.29 12.83 9 12 9 11.17 9 10.46 9.29 9.88 9.88 9.29 10.46 9 11.17 9 12 9 12.83 9.29 13.54 9.88 14.12 10.46 14.71 11.17 15 12 15 12.83 15 13.54 14.71 14.12 14.12 m 17 12 b 17 12.5 16.93 12.98 16.8 13.45 16.67 13.92 16.46 14.36 16.18 14.78 16.03 15.01 15.95 15.27 15.96 15.55 15.97 15.83 16.07 16.07 16.25 16.25 16.45 16.45 16.68 16.55 16.95 16.54 17.22 16.53 17.43 16.42 17.6 16.2 18.05 15.6 18.4 14.94 18.64 14.22 18.88 13.51 19 12.77 19 12 19 11.23 18.88 10.49 18.64 9.77 18.4 9.06 18.05 8.4 17.6 7.8 17.43 7.58 17.22 7.47 16.95 7.46 16.68 7.45 16.45 7.55 16.25 7.75 16.07 7.93 15.97 8.17 15.96 8.45 15.95 8.73 16.03 8.99 16.18 9.22 16.46 9.64 16.67 10.08 16.8 10.55 16.93 11.02 17 11.5 17 12 m 7.2 10.55 b 7.33 10.08 7.54 9.64 7.83 9.22 7.98 8.99 8.05 8.73 8.04 8.45 8.03 8.17 7.93 7.93 7.75 7.75 7.55 7.55 7.32 7.45 7.05 7.46 6.78 7.47 6.57 7.58 6.4 7.8 5.95 8.4 5.6 9.06 5.36 9.77 5.12 10.49 5 11.23 5 12 5 12.77 5.12 13.51 5.36 14.22 5.6 14.94 5.95 15.6 6.4 16.2 6.57 16.42 6.78 16.53 7.05 16.54 7.32 16.55 7.55 16.45 7.75 16.25 7.93 16.07 8.03 15.83 8.04 15.55 8.05 15.27 7.98 15.01 7.83 14.78 7.54 14.36 7.33 13.92 7.2 13.45 7.07 12.98 7 12.5 7 12 7 11.5 7.07 11.02 7.2 10.55 m 4 20 b 3.45 20 2.98 19.8 2.59 19.41 2.2 19.02 2 18.55 2 18 l 2 6 b 2 5.45 2.2 4.98 2.59 4.59 2.98 4.2 3.45 4 4 4 l 20 4 b 20.55 4 21.02 4.2 21.41 4.59 21.8 4.98 22 5.45 22 6 l 22 18 b 22 18.55 21.8 19.02 21.41 19.41 21.02 19.8 20.55 20 20 20 l 4 20 m 4 18 l 20 18 20 6 4 6 4 18 m 4 18 l 4 6 4 18",
    ["surround_sound_filled"] = "m 14.12 14.12 b 14.71 13.54 15 12.83 15 12 15 11.17 14.71 10.46 14.12 9.88 13.54 9.29 12.83 9 12 9 11.17 9 10.46 9.29 9.88 9.88 9.29 10.46 9 11.17 9 12 9 12.83 9.29 13.54 9.88 14.12 10.46 14.71 11.17 15 12 15 12.83 15 13.54 14.71 14.12 14.12 m 17 12 b 17 12.5 16.93 12.98 16.8 13.45 16.67 13.92 16.46 14.36 16.18 14.78 16.03 15.01 15.95 15.27 15.96 15.55 15.97 15.83 16.07 16.07 16.25 16.25 16.45 16.45 16.68 16.55 16.95 16.54 17.22 16.53 17.43 16.42 17.6 16.2 18.05 15.6 18.4 14.94 18.64 14.22 18.88 13.51 19 12.77 19 12 19 11.23 18.88 10.49 18.64 9.77 18.4 9.06 18.05 8.4 17.6 7.8 17.43 7.58 17.22 7.47 16.95 7.46 16.68 7.45 16.45 7.55 16.25 7.75 16.07 7.93 15.97 8.17 15.96 8.45 15.95 8.73 16.03 8.99 16.18 9.22 16.46 9.64 16.67 10.08 16.8 10.55 16.93 11.02 17 11.5 17 12 m 7.2 10.55 b 7.33 10.08 7.54 9.64 7.83 9.22 7.98 8.99 8.05 8.73 8.04 8.45 8.03 8.17 7.93 7.93 7.75 7.75 7.55 7.55 7.32 7.45 7.05 7.46 6.78 7.47 6.57 7.58 6.4 7.8 5.95 8.4 5.6 9.06 5.36 9.77 5.12 10.49 5 11.23 5 12 5 12.77 5.12 13.51 5.36 14.22 5.6 14.94 5.95 15.6 6.4 16.2 6.57 16.42 6.78 16.53 7.05 16.54 7.32 16.55 7.55 16.45 7.75 16.25 7.93 16.07 8.03 15.83 8.04 15.55 8.05 15.27 7.98 15.01 7.83 14.78 7.54 14.36 7.33 13.92 7.2 13.45 7.07 12.98 7 12.5 7 12 7 11.5 7.07 11.02 7.2 10.55 m 4 20 b 3.45 20 2.98 19.8 2.59 19.41 2.2 19.02 2 18.55 2 18 l 2 6 b 2 5.45 2.2 4.98 2.59 4.59 2.98 4.2 3.45 4 4 4 l 20 4 b 20.55 4 21.02 4.2 21.41 4.59 21.8 4.98 22 5.45 22 6 l 22 18 b 22 18.55 21.8 19.02 21.41 19.41 21.02 19.8 20.55 20 20 20 l 4 20",
    ["volume_down"] = "m 9 15 l 6 15 b 5.72 15 5.48 14.9 5.29 14.71 5.1 14.52 5 14.28 5 14 l 5 10 b 5 9.72 5.1 9.48 5.29 9.29 5.48 9.1 5.72 9 6 9 l 9 9 12.3 5.7 b 12.62 5.38 12.98 5.31 13.39 5.49 13.8 5.66 14 5.98 14 6.43 l 14 17.57 b 14 18.02 13.8 18.34 13.39 18.51 12.98 18.69 12.62 18.62 12.3 18.3 l 9 15 m 18.5 12 b 18.5 12.7 18.34 13.36 18.03 13.99 17.71 14.61 17.29 15.12 16.78 15.53 16.61 15.62 16.44 15.63 16.26 15.54 16.09 15.45 16 15.3 16 15.1 l 16 8.85 b 16 8.65 16.09 8.5 16.26 8.41 16.44 8.32 16.61 8.32 16.78 8.42 17.29 8.84 17.71 9.37 18.03 10 18.34 10.63 18.5 11.3 18.5 12 m 12 8.85 l 9.85 11 7 11 7 13 9.85 13 12 15.15 12 8.85",
    ["volume_downfilled"] = "m 9 15 l 6 15 b 5.72 15 5.48 14.9 5.29 14.71 5.1 14.52 5 14.28 5 14 l 5 10 b 5 9.72 5.1 9.48 5.29 9.29 5.48 9.1 5.72 9 6 9 l 9 9 12.3 5.7 b 12.62 5.38 12.98 5.31 13.39 5.49 13.8 5.66 14 5.98 14 6.43 l 14 17.57 b 14 18.02 13.8 18.34 13.39 18.51 12.98 18.69 12.62 18.62 12.3 18.3 l 9 15 m 18.5 12 b 18.5 12.7 18.34 13.36 18.03 13.99 17.71 14.61 17.29 15.12 16.78 15.53 16.61 15.62 16.44 15.63 16.26 15.54 16.09 15.45 16 15.3 16 15.1 l 16 8.85 b 16 8.65 16.09 8.5 16.26 8.41 16.44 8.32 16.61 8.32 16.78 8.42 17.29 8.84 17.71 9.37 18.03 10 18.34 10.63 18.5 11.3 18.5 12",
    ["volume_mute"] = "m 11 15 l 8 15 b 7.72 15 7.48 14.9 7.29 14.71 7.1 14.52 7 14.28 7 14 l 7 10 b 7 9.72 7.1 9.48 7.29 9.29 7.48 9.1 7.72 9 8 9 l 11 9 14.3 5.7 b 14.62 5.38 14.98 5.31 15.39 5.49 15.8 5.66 16 5.98 16 6.43 l 16 17.57 b 16 18.02 15.8 18.34 15.39 18.51 14.98 18.69 14.62 18.62 14.3 18.3 l 11 15 m 9 13 l 11.85 13 14 15.15 14 8.85 11.85 11 9 11 9 13",
    ["volume_mute_filled"] = "m 11 15 l 8 15 b 7.72 15 7.48 14.9 7.29 14.71 7.1 14.52 7 14.28 7 14 l 7 10 b 7 9.72 7.1 9.48 7.29 9.29 7.48 9.1 7.72 9 8 9 l 11 9 14.3 5.7 b 14.62 5.38 14.98 5.31 15.39 5.49 15.8 5.66 16 5.98 16 6.43 l 16 17.57 b 16 18.02 15.8 18.34 15.39 18.51 14.98 18.69 14.62 18.62 14.3 18.3 l 11 15",
    ["volume_up"] = "m 19 11.97 b 19 10.59 18.63 9.33 17.9 8.19 17.17 7.05 16.18 6.19 14.95 5.62 14.7 5.51 14.52 5.33 14.4 5.09 14.28 4.85 14.27 4.6 14.35 4.35 14.45 4.08 14.63 3.89 14.89 3.77 15.15 3.66 15.41 3.66 15.68 3.77 17.29 4.49 18.58 5.59 19.55 7.06 20.52 8.54 21 10.17 21 11.97 21 13.77 20.52 15.41 19.55 16.89 18.58 18.36 17.29 19.46 15.68 20.18 15.41 20.29 15.15 20.29 14.89 20.18 14.63 20.06 14.45 19.87 14.35 19.6 14.27 19.35 14.28 19.1 14.4 18.86 14.52 18.62 14.7 18.44 14.95 18.32 16.18 17.76 17.17 16.9 17.9 15.76 18.63 14.62 19 13.36 19 11.97 m 7 15 l 4 15 b 3.72 15 3.48 14.9 3.29 14.71 3.1 14.52 3 14.28 3 14 l 3 10 b 3 9.72 3.1 9.48 3.29 9.29 3.48 9.1 3.72 9 4 9 l 7 9 10.3 5.7 b 10.62 5.38 10.98 5.31 11.39 5.49 11.8 5.66 12 5.98 12 6.43 l 12 17.57 b 12 18.02 11.8 18.34 11.39 18.51 10.98 18.69 10.62 18.62 10.3 18.3 l 7 15 m 16.5 12 b 16.5 12.7 16.34 13.36 16.03 13.99 15.71 14.61 15.29 15.12 14.78 15.53 14.61 15.62 14.44 15.63 14.26 15.54 14.09 15.45 14 15.3 14 15.1 l 14 8.85 b 14 8.65 14.09 8.5 14.26 8.41 14.44 8.32 14.61 8.32 14.78 8.42 15.29 8.84 15.71 9.37 16.03 10 16.34 10.63 16.5 11.3 16.5 12 m 10 8.85 l 7.85 11 5 11 5 13 7.85 13 10 15.15 10 8.85",
    ["volume_up_filled"] = "m 19 11.97 b 19 10.59 18.63 9.33 17.9 8.19 17.17 7.05 16.18 6.19 14.95 5.62 14.7 5.51 14.52 5.33 14.4 5.09 14.28 4.85 14.27 4.6 14.35 4.35 14.45 4.08 14.63 3.89 14.89 3.77 15.15 3.66 15.41 3.66 15.68 3.77 17.29 4.49 18.58 5.59 19.55 7.06 20.52 8.54 21 10.17 21 11.97 21 13.77 20.52 15.41 19.55 16.89 18.58 18.36 17.29 19.46 15.68 20.18 15.41 20.29 15.15 20.29 14.89 20.18 14.63 20.06 14.45 19.87 14.35 19.6 14.27 19.35 14.28 19.1 14.4 18.86 14.52 18.62 14.7 18.44 14.95 18.32 16.18 17.76 17.17 16.9 17.9 15.76 18.63 14.62 19 13.36 19 11.97 m 7 15 l 4 15 b 3.72 15 3.48 14.9 3.29 14.71 3.1 14.52 3 14.28 3 14 l 3 10 b 3 9.72 3.1 9.48 3.29 9.29 3.48 9.1 3.72 9 4 9 l 7 9 10.3 5.7 b 10.62 5.38 10.98 5.31 11.39 5.49 11.8 5.66 12 5.98 12 6.43 l 12 17.57 b 12 18.02 11.8 18.34 11.39 18.51 10.98 18.69 10.62 18.62 10.3 18.3 l 7 15 m 16.5 12 b 16.5 12.7 16.34 13.36 16.03 13.99 15.71 14.61 15.29 15.12 14.78 15.53 14.61 15.62 14.44 15.63 14.26 15.54 14.09 15.45 14 15.3 14 15.1 l 14 8.85 b 14 8.65 14.09 8.5 14.26 8.41 14.44 8.32 14.61 8.32 14.78 8.42 15.29 8.84 15.71 9.37 16.03 10 16.34 10.63 16.5 11.3 16.5 12",
    ["window_close"] = "m 4.4 4.55 l 4.47 4.47 b 4.74 4.2 5.15 4.18 5.45 4.4 l 5.53 4.47 12 10.94 18.47 4.47 b 18.76 4.18 19.24 4.18 19.53 4.47 19.82 4.76 19.82 5.24 19.53 5.53 l 13.06 12 19.53 18.47 b 19.8 18.74 19.82 19.15 19.6 19.45 l 19.53 19.53 b 19.26 19.8 18.85 19.82 18.55 19.6 l 18.47 19.53 12 13.06 5.53 19.53 b 5.24 19.82 4.76 19.82 4.47 19.53 4.18 19.24 4.18 18.76 4.47 18.47 l 10.94 12 4.47 5.53 b 4.2 5.26 4.18 4.85 4.4 4.55 l 4.47 4.47 4.4 4.55",
    ["window_maximize"] = "m 5.72 2.86 l 18.38 2.86 b 18.86 2.86 19.33 2.99 19.74 3.23 20.16 3.47 20.5 3.81 20.74 4.22 20.98 4.64 21.1 5.1 21.1 5.58 l 21.1 18.25 b 21.1 18.73 20.98 19.19 20.74 19.61 20.5 20.02 20.16 20.36 19.74 20.6 19.33 20.84 18.86 20.97 18.38 20.97 l 5.72 20.97 b 5.24 20.97 4.77 20.84 4.36 20.6 3.94 20.36 3.6 20.02 3.36 19.61 3.12 19.19 3 18.73 3 18.25 l 3 5.58 b 3 5.1 3.12 4.64 3.36 4.22 3.6 3.81 3.94 3.47 4.36 3.23 4.77 2.99 5.24 2.86 5.72 2.86 m 5.72 4.66 b 5.55 4.66 5.39 4.71 5.25 4.79 5.11 4.87 5 4.99 4.91 5.13 4.83 5.27 4.79 5.43 4.79 5.59 l 4.79 18.25 b 4.79 18.41 4.83 18.57 4.91 18.71 5 18.85 5.11 18.97 5.25 19.05 5.39 19.13 5.55 19.18 5.72 19.18 l 18.38 19.18 b 18.55 19.18 18.71 19.13 18.85 19.05 18.99 18.97 19.1 18.85 19.19 18.71 19.27 18.57 19.31 18.41 19.31 18.25 l 19.31 5.59 b 19.31 5.43 19.27 5.27 19.19 5.13 19.1 4.99 18.99 4.87 18.85 4.79 18.71 4.71 18.55 4.66 18.38 4.66 l 5.72 4.66",
    ["window_minimize"] = "m 3.75 12.5 l 20.25 12.5 b 20.66 12.5 21 12.16 21 11.75 21 11.34 20.66 11 20.25 11 l 3.75 11 b 3.34 11 3 11.34 3 11.75 3 12.16 3.34 12.5 3.75 12.5",
    ["window_unmaximize"] = "m 6.21 3.86 b 6.43 3.25 6.8 2.77 7.31 2.4 7.56 2.22 7.84 2.08 8.14 1.99 8.44 1.9 8.74 1.85 9.05 1.86 l 16.16 1.86 b 17.79 1.86 19.2 2.45 20.39 3.63 21.57 4.81 22.16 6.22 22.16 7.86 l 22.16 14.96 b 22.16 15.61 21.98 16.19 21.61 16.7 21.43 16.96 21.22 17.18 20.97 17.37 20.73 17.55 20.45 17.7 20.16 17.8 l 20.16 7.86 b 20.16 6.78 19.76 5.85 18.96 5.05 18.17 4.26 17.23 3.86 16.16 3.86 l 6.21 3.86 6.21 3.86 m 5.05 5.86 l 15.12 5.86 b 15.94 5.86 16.65 6.16 17.25 6.76 17.86 7.37 18.16 8.08 18.16 8.89 l 18.16 18.97 b 18.16 19.83 17.86 20.55 17.25 21.13 16.97 21.41 16.64 21.63 16.28 21.78 15.91 21.93 15.52 22 15.12 22 l 5.05 22 b 4.19 22 3.47 21.71 2.89 21.13 2.31 20.55 2.02 19.83 2.02 18.97 l 2.02 8.89 b 2.02 8.08 2.31 7.37 2.89 6.76 3.47 6.16 4.19 5.86 5.05 5.86 m 5.05 7.86 b 4.91 7.86 4.77 7.88 4.65 7.94 4.52 7.99 4.4 8.08 4.31 8.18 4.22 8.28 4.15 8.39 4.1 8.51 4.05 8.63 4.02 8.76 4.02 8.89 l 4.02 18.96 b 4.02 19.26 4.12 19.51 4.31 19.71 4.5 19.9 4.75 20 5.05 20 l 15.12 20 b 15.25 19.99 15.38 19.97 15.51 19.92 15.63 19.87 15.74 19.8 15.83 19.71 15.94 19.61 16.02 19.5 16.08 19.37 16.13 19.24 16.16 19.1 16.16 18.96 l 16.16 8.89 b 16.16 8.63 16.05 8.4 15.83 8.18 15.62 7.97 15.38 7.86 15.12 7.86 l 5.05 7.86",
    ["zoom_in"] = "m 8.5 10.5 l 7.5 10.5 b 7.22 10.5 6.98 10.4 6.79 10.21 6.6 10.02 6.5 9.78 6.5 9.5 6.5 9.22 6.6 8.98 6.79 8.79 6.98 8.6 7.22 8.5 7.5 8.5 l 8.5 8.5 8.5 7.5 b 8.5 7.22 8.6 6.98 8.79 6.79 8.98 6.6 9.22 6.5 9.5 6.5 9.78 6.5 10.02 6.6 10.21 6.79 10.4 6.98 10.5 7.22 10.5 7.5 l 10.5 8.5 11.5 8.5 b 11.78 8.5 12.02 8.6 12.21 8.79 12.4 8.98 12.5 9.22 12.5 9.5 12.5 9.78 12.4 10.02 12.21 10.21 12.02 10.4 11.78 10.5 11.5 10.5 l 10.5 10.5 10.5 11.5 b 10.5 11.78 10.4 12.02 10.21 12.21 10.02 12.4 9.78 12.5 9.5 12.5 9.22 12.5 8.98 12.4 8.79 12.21 8.6 12.02 8.5 11.78 8.5 11.5 l 8.5 10.5 m 9.5 16 b 7.68 16 6.15 15.37 4.89 14.11 3.63 12.85 3 11.32 3 9.5 3 7.68 3.63 6.15 4.89 4.89 6.15 3.63 7.68 3 9.5 3 11.32 3 12.85 3.63 14.11 4.89 15.37 6.15 16 7.68 16 9.5 16 10.23 15.88 10.92 15.65 11.57 15.42 12.22 15.1 12.8 14.7 13.3 l 20.3 18.9 b 20.48 19.08 20.58 19.32 20.58 19.6 20.58 19.88 20.48 20.12 20.3 20.3 20.12 20.48 19.88 20.57 19.6 20.57 19.32 20.57 19.08 20.48 18.9 20.3 l 13.3 14.7 b 12.8 15.1 12.23 15.42 11.58 15.65 10.93 15.88 10.23 16 9.5 16 m 9.5 14 b 10.75 14 11.81 13.56 12.69 12.69 13.56 11.81 14 10.75 14 9.5 14 8.25 13.56 7.19 12.69 6.31 11.81 5.44 10.75 5 9.5 5 8.25 5 7.19 5.44 6.31 6.31 5.44 7.19 5 8.25 5 9.5 5 10.75 5.44 11.81 6.31 12.69 7.19 13.56 8.25 14 9.5 14",
    ["zoom_out"] = "m 8 10.5 b 7.72 10.5 7.48 10.4 7.29 10.21 7.1 10.02 7 9.78 7 9.5 7 9.22 7.1 8.98 7.29 8.79 7.48 8.6 7.72 8.5 8 8.5 l 11 8.5 b 11.28 8.5 11.52 8.6 11.71 8.79 11.9 8.98 12 9.22 12 9.5 12 9.78 11.9 10.02 11.71 10.21 11.52 10.4 11.28 10.5 11 10.5 l 8 10.5 m 9.5 16 b 7.68 16 6.15 15.37 4.89 14.11 3.63 12.85 3 11.32 3 9.5 3 7.68 3.63 6.15 4.89 4.89 6.15 3.63 7.68 3 9.5 3 11.32 3 12.85 3.63 14.11 4.89 15.37 6.15 16 7.68 16 9.5 16 10.23 15.88 10.92 15.65 11.57 15.42 12.22 15.1 12.8 14.7 13.3 l 20.3 18.9 b 20.48 19.08 20.58 19.32 20.58 19.6 20.58 19.88 20.48 20.12 20.3 20.3 20.12 20.48 19.88 20.57 19.6 20.57 19.32 20.57 19.08 20.48 18.9 20.3 l 13.3 14.7 b 12.8 15.1 12.23 15.42 11.58 15.65 10.93 15.88 10.23 16 9.5 16 m 9.5 14 b 10.75 14 11.81 13.56 12.69 12.69 13.56 11.81 14 10.75 14 9.5 14 8.25 13.56 7.19 12.69 6.31 11.81 5.44 10.75 5 9.5 5 8.25 5 7.19 5.44 6.31 6.31 5.44 7.19 5 8.25 5 9.5 5 10.75 5.44 11.81 6.31 12.69 7.19 13.56 8.25 14 9.5 14",
}
local icon_names = {
    ["fluent_download"] = "fluent_arrow_download",
    ["fluent_download_filled"] = "fluent_arrow_download_filled",
    ["fluent_downloading"] = "fluent_clock_arrow_download",
    ["fluent_downloading_filled"] = "fluent_clock_arrow_download_filled",
    ["fluent_fast_forward"] = "fluent_fast_forward",
    ["fluent_fast_forward_filled"] = "fluent_fast_forward_filled",
    ["fluent_fast_rewind"] = "fluent_rewind",
    ["fluent_fast_rewind_filled"] = "fluent_rewind_filled",
    ["fluent_forward_10"] = "fluent_skip_forward_10",
    ["fluent_forward_10_filled"] = "fluent_skip_forward_10_filled",
    ["fluent_forward_30"] = "fluent_skip_forward_30",
    ["fluent_forward_30_filled"] = "fluent_skip_forward_30_filled",
    ["fluent_forward_5"] = "fluent_skip_forward_5",
    ["fluent_forward_5_filled"] = "fluent_skip_forward_5_filled",
    ["fluent_fullscreen"] = "fluent_arrow_maximize",
    ["fluent_fullscreen_exit"] = "fluent_arrow_minimize",
    ["fluent_fullscreen_exit_filled"] = "fluent_arrow_minimize_filled",
    ["fluent_fullscreen_filled"] = "fluent_arrow_maximize_filled",
    ["fluent_info"] = "fluent_info",
    ["fluent_info_filled"] = "fluent_info_filled",
    ["fluent_more_vert"] = "fluent_more_vertical",
    ["fluent_more_vert_filled"] = "fluent_more_vertical_filled",
    ["fluent_no_sound"] = "fluent_speaker_mute",
    ["fluent_no_sound_filled"] = "fluent_speaker_mute_filled",
    ["fluent_pause"] = "fluent_pause",
    ["fluent_pause_filled"] = "fluent_pause_filled",
    ["fluent_photo_camera"] = "fluent_camera",
    ["fluent_photo_camera_filled"] = "fluent_camera_filled",
    ["fluent_pip"] = "fluent_picture_in_picture_enter",
    ["fluent_pip_exit"] = "fluent_pip_exit",
    ["fluent_pip_exit_filled"] = "fluent_pip_exit_filled",
    ["fluent_pip_filled"] = "fluent_picture_in_picture_enter_filled",
    ["fluent_play_arrow"] = "fluent_play",
    ["fluent_play_arrow_filled"] = "fluent_play_filled",
    ["fluent_playlist_play"] = "fluent_playlist",
    ["fluent_playlist_play_filled"] = "fluent_playlist_filled",
    ["fluent_repeat"] = "fluent_arrow_repeat_all_off",
    ["fluent_repeat_filled"] = "fluent_arrow_repeat_all_off_filled",
    ["fluent_repeat_on"] = "fluent_arrow_repeat_all",
    ["fluent_repeat_on_filled"] = "fluent_arrow_repeat_all_filled",
    ["fluent_replay"] = "fluent_replay",
    ["fluent_replay_10"] = "fluent_skip_back_10",
    ["fluent_replay_10_filled"] = "fluent_skip_back_10_filled",
    ["fluent_replay_30"] = "fluent_skip_back_30",
    ["fluent_replay_30_filled"] = "fluent_skip_back_30_filled",
    ["fluent_replay_5"] = "fluent_skip_back_5",
    ["fluent_replay_5_filled"] = "fluent_skip_back_5_filled",
    ["fluent_replay_filled"] = "fluent_replay_filled",
    ["fluent_shuffle"] = "fluent_arrow_shuffle_off",
    ["fluent_shuffle_filled"] = "fluent_arrow_shuffle_off_filled",
    ["fluent_shuffle_on"] = "fluent_arrow_shuffle",
    ["fluent_shuffle_on_filled"] = "fluent_arrow_shuffle_filled",
    ["fluent_skip_back"] = "fluent_skip_back_tab",
    ["fluent_skip_back_filled"] = "fluent_skip_back_tab_filled",
    ["fluent_skip_forward"] = "fluent_skip_forward_tab",
    ["fluent_skip_forward_filled"] = "fluent_skip_forward_tab_filled",
    ["fluent_skip_next"] = "fluent_next",
    ["fluent_skip_next_filled"] = "fluent_next_filled",
    ["fluent_skip_previous"] = "fluent_previous",
    ["fluent_skip_previous_filled"] = "fluent_previous_filled",
    ["fluent_speed"] = "fluent_top_speed",
    ["fluent_speed_filled"] = "fluent_top_speed_filled",
    ["fluent_subtitles"] = "fluent_subtitles",
    ["fluent_subtitles_filled"] = "fluent_subtitles_filled",
    ["fluent_surround_sound"] = "fluent_audio",
    ["fluent_surround_sound_filled"] = "fluent_audio_filled",
    ["fluent_volume_down"] = "fluent_speaker_1",
    ["fluent_volume_down_filled"] = "fluent_speaker_1_filled",
    ["fluent_volume_mute"] = "fluent_speaker_0",
    ["fluent_volume_mute_filled"] = "fluent_speaker_0_filled",
    ["fluent_volume_up"] = "fluent_speaker_2",
    ["fluent_volume_up_filled"] = "fluent_speaker_2_filled",
    ["fluent_zoom_in"] = "fluent_zoom_in",
    ["fluent_zoom_in_filled"] = "fluent_zoom_in_filled",
    ["fluent_zoom_out"] = "fluent_zoom_out",
    ["fluent_zoom_out_filled"] = "fluent_zoom_out_filled",
    ["material_download"] = "download",
    ["material_download_filled"] = "download",
    ["material_downloading"] = "downloading",
    ["material_downloading_filled"] = "downloading",
    ["material_fast_forward"] = "fast_forward",
    ["material_fast_forward_filled"] = "fast_forward_filled",
    ["material_fast_rewind"] = "fast_rewind",
    ["material_fast_rewind_filled"] = "fast_rewind_filled",
    ["material_forward_10"] = "forward_10",
    ["material_forward_10_filled"] = "forward_10",
    ["material_forward_30"] = "forward_30",
    ["material_forward_30_filled"] = "forward_30",
    ["material_forward_5"] = "forward_5",
    ["material_forward_5_filled"] = "forward_5",
    ["material_fullscreen"] = "fullscreen",
    ["material_fullscreen_exit"] = "fullscreen_exit",
    ["material_fullscreen_exit_filled"] = "fullscreen_exit",
    ["material_fullscreen_filled"] = "fullscreen",
    ["material_info"] = "info",
    ["material_info_filled"] = "info_filled",
    ["material_more_vert"] = "more_vert",
    ["material_more_vert_filled"] = "more_vert",
    ["material_no_sound"] = "no_sound",
    ["material_no_sound_filled"] = "no_sound_filled",
    ["material_pause"] = "pause",
    ["material_pause_filled"] = "pause_filled",
    ["material_photo_camera"] = "photo_camera",
    ["material_photo_camera_filled"] = "photo_camera_filled",
    ["material_pip"] = "pip",
    ["material_pip_exit"] = "pip_exit",
    ["material_pip_exit_filled"] = "pip_exit_filled",
    ["material_pip_filled"] = "pip",
    ["material_play_arrow"] = "play_arrow",
    ["material_play_arrow_filled"] = "play_arrow_filled",
    ["material_playlist_play"] = "playlist_play",
    ["material_playlist_play_filled"] = "playlist_play",
    ["material_repeat"] = "repeat",
    ["material_repeat_filled"] = "repeat",
    ["material_repeat_on"] = "repeat_on",
    ["material_repeat_on_filled"] = "repeat_on",
    ["material_replay"] = "replay",
    ["material_replay_10"] = "replay_10",
    ["material_replay_10_filled"] = "replay_10",
    ["material_replay_30"] = "replay_30",
    ["material_replay_30_filled"] = "replay_30",
    ["material_replay_5"] = "replay_5",
    ["material_replay_5_filled"] = "replay_5",
    ["material_replay_filled"] = "replay",
    ["material_shuffle"] = "shuffle",
    ["material_shuffle_filled"] = "shuffle",
    ["material_shuffle_on"] = "shuffle_on",
    ["material_shuffle_on_filled"] = "shuffle_on",
    ["material_skip_back"] = "replay",
    ["material_skip_back_filled"] = "replay",
    ["material_skip_forward"] = "forward_media",
    ["material_skip_forward_filled"] = "forward_media",
    ["material_skip_next"] = "skip_next",
    ["material_skip_next_filled"] = "skip_next_filled",
    ["material_skip_previous"] = "skip_previous",
    ["material_skip_previous_filled"] = "skip_previous_filled",
    ["material_speed"] = "speed",
    ["material_speed_filled"] = "speed_filled",
    ["material_subtitles"] = "subtitles",
    ["material_subtitles_filled"] = "subtitles_filled",
    ["material_surround_sound"] = "surround_sound",
    ["material_surround_sound_filled"] = "surround_sound_filled",
    ["material_volume_down"] = "volume_down",
    ["material_volume_down_filled"] = "volume_downfilled",
    ["material_volume_mute"] = "volume_mute",
    ["material_volume_mute_filled"] = "volume_mute_filled",
    ["material_volume_up"] = "volume_up",
    ["material_volume_up_filled"] = "volume_up_filled",
    ["material_zoom_in"] = "zoom_in",
    ["material_zoom_in_filled"] = "zoom_in",
    ["material_zoom_out"] = "zoom_out",
    ["material_zoom_out_filled"] = "zoom_out",
    ["menu_back"] = "menu_back",
    ["menu_chapters"] = "menu_chapters",
    ["menu_check"] = "menu_check",
    ["menu_chevron"] = "menu_chevron",
    ["menu_folder"] = "menu_folder",
    ["menu_folder_up"] = "menu_folder_up",
    ["menu_video"] = "menu_video",
    ["menu_more"] = "menu_more",
    ["window_close"] = "window_close",
    ["window_maximize"] = "window_maximize",
    ["window_minimize"] = "window_minimize",
    ["window_unmaximize"] = "window_unmaximize",
}

-- Icons are vector drawings, so no icon font has to be installed. A button's content
-- holds a marker (\1name\2) that render_icons() swaps for the drawing at the size
-- given by the button's style (\fs), so hover/press scaling keeps working.
local ICON_FRAME = " m 0 0 l 24 0 24 24 0 24 m 0 0 l 0 24 24 24 24 0" -- invisible 24x24 frame: icons align by their grid
local icon_cache = {}

local function icon_marker(name) return "\1" .. name .. "\2" end

local function icon_path(name)
    local glyph = icon_names[name]
        or icon_names[(name:gsub("_filled$", ""))]
        or icon_names[(name:gsub("^%a+_", ""))]
    return glyph and icon_glyphs[glyph] or nil
end

local function icon_drawing(name, size)
    local key = name .. "@" .. size
    local drawing = icon_cache[key]
    if not drawing then
        local path = icon_path(name)
        if not path then return "" end
        local s = size / 24
        drawing = "{\\p1}" .. (path .. ICON_FRAME):gsub("%-?%d+%.?%d*", function(n)
            return string.format("%.2f", tonumber(n) * s)
        end) .. "{\\p0}"
        icon_cache[key] = drawing
    end
    return drawing
end

-- replace icon markers in a button's text with drawings sized by the style's \fs
local function render_icons(text, style)
    if not text or not text:find("\1", 1, true) then return text end
    local size = tonumber((style or ""):match(".*\\fs([%d%.]+)")) or 24
    return (text:gsub("\1([%w_]+)\2", function(name) return icon_drawing(name, size) end))
end

local icon_themes = {
    fluent   = { prefix = "fluent_"   },
    material = { prefix = "material_" },
}

local function build_icons(theme_name, style)
    local theme = icon_themes[theme_name] or icon_themes["fluent"]
    local p = theme.prefix

    local filled_suffix  = (style ~= "outline") and "_filled" or ""
    local outline_suffix = (style == "filled")  and "_filled" or ""

    local function f(name) return icon_marker(p .. name .. filled_suffix)  end
    local function o(name) return icon_marker(p .. name .. outline_suffix) end

    return {
        check    = icon_marker("menu_check"),
        more     = icon_marker("menu_more"),
        chevron  = icon_marker("menu_chevron"),
        back     = icon_marker("menu_back"),
        chapters = icon_marker("menu_chapters"),
        window = {
            maximize   = icon_marker("window_maximize"),
            unmaximize = icon_marker("window_unmaximize"),
            minimize   = icon_marker("window_minimize"),
            close      = icon_marker("window_close"),
        },

        play     = f("play_arrow"),
        pause    = f("pause"),
        replay   = f("replay"),
        previous = f("skip_previous"),
        next     = f("skip_next"),
        rewind   = f("fast_rewind"),
        forward  = f("fast_forward"),
        jump = {
            [5]     = { f("replay_5"),   f("forward_5")   },
            [10]    = { f("replay_10"),  f("forward_10")  },
            [30]    = { f("replay_30"),  f("forward_30")  },
            default = { f("skip_back"),  f("skip_forward") },
        },

        audio        = o("surround_sound"),
        subtitle     = o("subtitles"),
        playlist     = o("playlist_play"),
        menu         = o("more_vert"),
        volume_mute  = o("no_sound"),
        volume_quiet = o("volume_mute"),
        volume_low   = o("volume_down"),
        volume_high  = o("volume_up"),

        download        = o("download"),
        downloading     = o("downloading"),
        speed           = o("speed"),
        shuffle_on      = o("shuffle_on"),
        shuffle_off     = o("shuffle"),
        loop_on         = o("repeat_on"),
        loop_off        = o("repeat"),
        screenshot      = o("photo_camera"),
        ontop_on        = o("pip"),
        ontop_off       = o("pip_exit"),
        info            = o("info"),
        fullscreen      = o("fullscreen"),
        fullscreen_exit = o("fullscreen_exit"),

        zoom_in         = o("zoom_in"),
        zoom_out        = o("zoom_out"),
    }
end

local function set_icon_theme()
    icons = build_icons(user_opts.icon_theme, user_opts.icon_style)
end

--- localization
local language = {
    ["default"] = {
        idle = "Drop files or URLs here to play",
        na = "Not available",
        unknown = "Unknown",
        video = "Video",
        audio = "Audio",
        subtitle = "Subtitle",
        no_subs = "No subtitles",
        no_audio = "No audio tracks",
        volume = "Volume",
        muted = "Muted",
        playlist = "Playlist",
        no_playlist = "Playlist empty",
        chapter = "Chapter",
        fullscreen = "Fullscreen",
        fullscreen_exit = "Exit fullscreen",
        ontop = "Pin window",
        ontop_disable = "Unpin window",
        file_loop_enable = "Loop file on",
        file_loop_disable = "Loop file off",
        playlist_loop_enable = "Loop playlist on",
        playlist_loop_disable = "Loop playlist off",
        shuffle = "Shuffle playlist on",
        unshuffle = "Shuffle playlist off",
        speed_control = "Playback speed",
        screenshot = "Screenshot",
        stats_info = "Statistics",
        cache = "Cache",
        buffering = "Buffering",
        zoom_in = "Zoom in",
        zoom_out = "Zoom out",
        download = "Download",
        download_in_progress = "Download in progress",
        downloading = "Downloading",
        downloaded = "Already downloaded",
        menu = "Menu",
        more = "More",
        normal = "Normal",
        loop = "Loop",
        shuffle_menu = "Shuffle",
        keep_on_top = "Keep on top",
        subtitles = "Subtitles",
        chapters = "Chapters",
        audio_output = "Audio output",
        off = "Off",
        track = "Track",
        default_track = "Default",
        forced = "Forced",
        external = "External",
        other_folders = "Other folders",
        browse_folders = "Browse folders",
        up_one_level = "Up one level",
        nothing_here = "Nothing to play here",
        playing = "Playing",
    },
}

local bidi = {
    fsi = "\226\129\168",   -- U+2068 first strong isolate
    pdi = "\226\129\169",   -- U+2069 pop directional isolate
}

-- locale JSON file handler
local function get_locale_from_json(path)
    local expand_path = mp.command_native({'expand-path', path})

    local file_info = utils.file_info(expand_path)
    if not file_info or not file_info.is_file then
        return nil
    end

    local json_file = io.open(expand_path, 'r')
    if not json_file then
        return nil
    end

    local json = json_file:read('*all')
    json_file:close()

    local json_table, parse_error = utils.parse_json(json)
    if not json_table then
        mp.msg.error("JSON parse error:" .. parse_error)
    end
    return json_table
end

-- load external locales only when default language is not used
local locale_file_loaded = false
local function load_locale_file()
    if user_opts.language == "default" or locale_file_loaded then return end
    locale_file_loaded = true

    local external = get_locale_from_json("~~/script-opts/modernz-locale.json")
    if external then
        for lang, strings in pairs(external) do
            if lang == "default" then
                -- "default" is reserved
                mp.msg.warn("Locale JSON: 'default' is a reserved language key and cannot be overridden. Skipping.")
            elseif type(strings) == "table" then
                language[lang] = strings

                -- fill in any missing keys with the built-in defaults
                for key, value in pairs(language["default"]) do
                    if strings[key] == nil then
                        strings[key] = value
                    end
                end
            else
                mp.msg.warn("Locale data for language '" .. lang .. "' is not in the correct format.")
            end
        end
    end
end

local locale
local function set_osc_locale()
    locale = language[user_opts.language] or language["default"]
end

local function contains(list, item)
    local t
    if type(list) == "table" then
        t = list
    else
        t = {}
        for str in string.gmatch(list, '([^,]+)') do
            t[#t + 1] = str:match("^%s*(.-)%s*$") -- trim spaces
        end
    end
    for _, v in ipairs(t) do
        if v == item then return true end
    end
    return false
end

-- seekbar thumbnails come from thumbz (scripts/thumbz.lua)
local thumbz = {
    width = 0,
    height = 0,
    disabled = true,
    shown = false,   -- a thumbnail was requested and not hidden since
}

local function thumbz_hover(time, x, y)
    thumbz.shown = true
    mp.commandv("script-message-to", "thumbz", "hover", time, x, y)
end

-- only message thumbz when a thumbnail is actually up, not on every render
local function thumbz_hide()
    if thumbz.shown then
        thumbz.shown = false
        mp.commandv("script-message-to", "thumbz", "hide")
    end
end

local platform = mp.get_property("platform")
local tick_delay = 1 / 60
local window_control_box_width = 150
local is_december = os.date("*t").month == 12
local UNICODE_MINUS = string.char(0xe2, 0x88, 0x92)  -- UTF-8 for U+2212 MINUS SIGN

local function osc_color_convert(color)
    return color:sub(6,7) .. color:sub(4,5) ..  color:sub(2,3)
end

local osc_styles
local seekbar_height_style
local hover_effects = { size = false, color = false, glow = false, box = false }

-- the UI typeface. Inter's weights are separate families to libass: Medium for body
-- text, SemiBold for titles (text on glass reads best a little heavier)
local ui_font = {}
local function resolve_fonts()
    local f = user_opts.font
    if f == "Inter" then
        ui_font = {regular = "Inter Medium", medium = "Inter Medium", semibold = "Inter SemiBold", medium_b = "\\b0", semibold_b = "\\b0"}
    else
        ui_font = {regular = f, medium = f, semibold = f, medium_b = "\\b0", semibold_b = "\\b1"}
    end
end

local function set_osc_styles()
    resolve_fonts()
    local playpause_size = user_opts.playpause_size
    local midbuttons_size = user_opts.midbuttons_size
    local sidebuttons_size = user_opts.sidebuttons_size

    hover_effects.size  = contains(user_opts.hover_effect, "size")
    hover_effects.color = contains(user_opts.hover_effect, "color")
    hover_effects.glow  = contains(user_opts.hover_effect, "glow")
    hover_effects.box   = contains(user_opts.hover_effect, "box")

    local seekbar_presets = {
        small  = { radius = 1, height = 2 },
        medium = { radius = 2, height = 4 },
        large  = { radius = 3, height = 6 },
        xlarge = { radius = 4, height = 8 }
    }
    seekbar_height_style = seekbar_presets[user_opts.seekbar_height] or seekbar_presets.medium

    osc_styles = {
        osc_fade_bg = "{\\blur" .. user_opts.fade_blur_strength .. "\\bord" .. user_opts.osc_fade_strength .. "\\1c&H0&\\3c&H" .. osc_color_convert(user_opts.osc_color) .. "&}",
        window_fade_bg = "{\\blur" .. user_opts.window_fade_blur_strength .. "\\bord" .. user_opts.window_fade_strength .. "\\1c&H0&\\3c&H" .. osc_color_convert(user_opts.osc_color) .. "&}",
        window_control = "{\\1c&H" .. osc_color_convert(user_opts.window_controls_color) .. "&\\fs25}",
        window_title = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.window_title_color) .. "&\\3c&H0&\\fs".. user_opts.window_title_font_size .."\\q2\\fn" .. ui_font.regular .. "}",
        title = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.title_color) .. "&\\3c&H0&\\fs".. user_opts.title_font_size .."\\q2\\fn" .. ui_font.regular .. "}",
        chapter_title = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.chapter_title_color) .. "&\\3c&H0&\\fs" .. user_opts.chapter_title_font_size .. "\\q2\\fn" .. ui_font.regular .. "}",
        seekbar_bg = "{\\1c&H" .. osc_color_convert(user_opts.seekbarbg_color) .. "&}",
        seekbar_fg = "{\\blur1\\bord1\\1c&H" .. osc_color_convert(user_opts.seekbarfg_color) .. "&}",
        thumbnail = "{\\bord" .. user_opts.thumbnail_box_outline_size .. "\\1c&H" .. osc_color_convert(user_opts.thumbnail_box_color) .. "&\\3c&H" .. osc_color_convert(user_opts.thumbnail_box_outline) .. "&}",
        time = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.time_color) .. "&\\3c&H0&\\fs" .. user_opts.time_font_size .. "\\fn" .. ui_font.regular .. "}",
        cache = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.cache_info_color) .. "&\\3c&H0&\\fs" .. user_opts.cache_info_font_size .. "\\fn" .. ui_font.regular .. "}",
        tooltip = "{\\bord1\\1c&HFFFFFF&\\3c&H0&\\fs" .. user_opts.tooltip_font_size .. "\\fn" .. ui_font.medium .. ui_font.medium_b .. "}",
        tooltip_box = "{\\1c&H" .. osc_color_convert(user_opts.osc_color) .. "&}",
        speed = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&\\3c&H0&\\fs" .. user_opts.speed_font_size .. "\\fn" .. ui_font.regular .. "}",
        volumebar_bg = "{\\1c&H999999&}",
        volumebar_fg = "{\\blur1\\bord1\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&}",
        control_1 = "{\\1c&H" .. osc_color_convert(user_opts.playpause_color) .. "&\\fs" .. playpause_size .. "}",
        control_2 = "{\\1c&H" .. osc_color_convert(user_opts.middle_buttons_color) .. "&\\fs" .. midbuttons_size .. "}",
        control_3 = "{\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&\\fs" .. sidebuttons_size .. "}",
        control_mini = "{\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&\\fs16}",
        element_down = "{\\1c&H" .. osc_color_convert(user_opts.held_element_color) .. "&" .. string.format("\\fscx%s\\fscy%s", user_opts.button_held_size, user_opts.button_held_size) .. "}",
        element_hover = "{" .. (hover_effects.color and "\\1c&H" .. osc_color_convert(user_opts.hover_effect_color) .. "&" or "") .. (hover_effects.size and string.format("\\fscx%s\\fscy%s", user_opts.button_hover_size, user_opts.button_hover_size) or "") .. "}",
        hover_bg = "{\\1c&H" .. osc_color_convert(user_opts.hover_effect_color) .. "&}",

        -- text on glass: no outline, the glass gives the contrast
        glass_title = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.title_color) .. "&\\fs" .. user_opts.title_font_size .. "\\q2\\fn" .. ui_font.semibold .. ui_font.semibold_b .. "}",
        glass_chapter = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.muted_text_color) .. "&\\fs" .. user_opts.chapter_title_font_size .. "\\q2\\fn" .. ui_font.regular .. "}",
        glass_time = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.time_color) .. "&\\fs" .. user_opts.time_font_size .. "\\fn" .. ui_font.medium .. ui_font.medium_b .. "}",
        glass_text = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&\\fs" .. user_opts.speed_font_size .. "\\fn" .. ui_font.medium .. ui_font.medium_b .. "}",
        glass_cache = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.cache_info_color) .. "&\\fs" .. user_opts.cache_info_font_size .. "\\fn" .. ui_font.regular .. "}",
        glass_window_control = "{\\1c&H" .. osc_color_convert(user_opts.window_controls_color) .. "&\\fs18}",
        glass_play = "{\\1c&H" .. osc_color_convert(user_opts.playpause_color) .. "&\\fs30}",
        glass_icon = "{\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&\\fs22}",
        glass_transport = "{\\1c&H" .. osc_color_convert(user_opts.middle_buttons_color) .. "&\\fs24}",
        glass_time_muted = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.muted_text_color) .. "&\\fs" .. user_opts.time_font_size .. "\\fn" .. ui_font.medium .. ui_font.medium_b .. "}",
        glass_window_title = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.window_title_color) .. "&\\fs" .. math.min(user_opts.window_title_font_size, 18) .. "\\q2\\fn" .. ui_font.regular .. "}",
    }
end

-- internal states, do not touch
local state = {
    showtime = nil,                         -- time of last invocation (last mouse move)
    wc_showtime = nil,                      -- time of last invocation for window controls
    wc_anistart = nil,                      -- time when the wc animation started
    wc_anitype = nil,                       -- current type of wc animation
    wc_animation = nil,                     -- current wc animation alpha
    touchtime = nil,                        -- time of last invocation (last touch event)
    touchpoints = {},                       -- current touch points
    osc_visible = false,                    -- osc visibility
    wc_visible = false,                     -- window controls visibility
    anistart = nil,                         -- time when the animation started
    anitype = nil,                          -- current type of animation
    animation = nil,                        -- current animation alpha
    mouse_down_counter = 0,                 -- used for softrepeat
    active_element = nil,                   -- nil = none, 0 = background, 1+ = see elements[]
    active_event_source = nil,              -- the "button" that issued the current event
    tc_left_rem = not user_opts.timecurrent,-- if the left timecode should display current or remaining time
    tc_ms = user_opts.timems,               -- Should the timecodes display their time with milliseconds
    screen_sizeX = nil, screen_sizeY = nil, -- last screen-resolution, to detect resolution changes to issue reINITs
    initREQ = false,                        -- is a re-init request pending?
    marginsREQ = false,                     -- is a margins update pending?
    last_mouseX = nil, last_mouseY = nil,   -- last mouse position, to detect significant mouse movement
    last_touchX = -1, last_touchY = -1,     -- last touch position
    mouse_in_window = false,
    fullscreen = false,
    tick_timer = nil,
    tick_last_time = 0,                     -- when the last tick() was run
    hide_timer = nil,
    demuxer_cache_state = nil,
    idle_active = false,
    audio_track_count = 0,
    sub_track_count = 0,
    playlist_count = 0,
    playlist_pos_1 = 0,
    pause = false,
    volume = 0,
    mute = false,
    osd_dimensions = {w = 0, h = 0, aspect = 0},
    osd_scale_by_window = false,
    file_loaded = false,                    -- flag to detect file load
    enabled = true,
    input_enabled = true,
    showhide_enabled = false,
    windowcontrols_buttons = false,
    windowcontrols_title = false,
    windowcontrols_ontop = false,
    dmx_cache = 0,
    border = true,
    window_maximized = false,
    osd = mp.create_osd_overlay("ass-events"),
    logo_osd = mp.create_osd_overlay("ass-events"),
    keeponpause_active = false,             -- keeponpause bottombar active state
    cursor_hide_flag = nil,                 -- "allow-hide-cursor" when keep_with_cursor=no, so the cursor can autohide over the OSC
    duration = nil,                         -- current file duration
    chapter_list = {},                      -- sorted by time
    chapter = -1,                           -- current chapter index
    visibility_modes = {},                  -- visibility_modes to cycle through
    eof_reached = false,
    ontop = false,
    speed = 1,
    file_loop = false,
    shuffled = false,
    sliderpos = 0,
    playing_and_seeking = false,
    playtime_hour_force_init = false,       -- used to force request_init() once
    persistent_seekbar_element = nil,
    seekbar_element = nil,
    persistent_progress_toggle = user_opts.persistent_progress,
    user_subpos = mp.get_property_number("sub-pos") or 100,
    osc_adjusted_subpos = nil,
    is_image = false,
    is_url = false,
    url_path = "",                           -- used for yt-dlp downloading
    downloaded_once = false,
    downloading = false,
    file_size_normalized = nil,
    title_max_w = nil,
    windowtitle_max_w = nil,
    chapter_title_max_w = nil,
}

local logo_lines = {
    -- White border
    "{\\c&HE5E5E5&\\p6}m 895 10 b 401 10 0 410 0 905 0 1399 401 1800 895 1800 1390 1800 1790 1399 1790 905 1790 410 1390 10 895 10 {\\p0}",
    -- Purple fill
    "{\\c&H682167&\\p6}m 925 42 b 463 42 87 418 87 880 87 1343 463 1718 925 1718 1388 1718 1763 1343 1763 880 1763 418 1388 42 925 42{\\p0}",
    -- Darker fill
    "{\\c&H430142&\\p6}m 1605 828 b 1605 1175 1324 1456 977 1456 631 1456 349 1175 349 828 349 482 631 200 977 200 1324 200 1605 482 1605 828{\\p0}",
    -- White fill
    "{\\c&HDDDBDD&\\p6}m 1296 910 b 1296 1131 1117 1310 897 1310 676 1310 497 1131 497 910 497 689 676 511 897 511 1117 511 1296 689 1296 910{\\p0}",
    -- Triangle
    "{\\c&H691F69&\\p6}m 762 1113 l 762 708 b 881 776 1000 843 1119 911 1000 978 881 1046 762 1113{\\p0}",
}

local santa_hat_lines = {
    -- Pompoms
    "{\\c&HC0C0C0&\\p6}m 500 -323 b 491 -322 481 -318 475 -311 465 -312 456 -319 446 -318 434 -314 427 -304 417 -297 410 -290 404 -282 395 -278 390 -274 387 -267 381 -265 377 -261 379 -254 384 -253 397 -244 409 -232 425 -228 437 -228 446 -218 457 -217 462 -216 466 -213 468 -209 471 -205 477 -203 482 -206 491 -211 499 -217 508 -222 532 -235 556 -249 576 -267 584 -272 584 -284 578 -290 569 -305 550 -312 533 -309 523 -310 515 -316 507 -321 505 -323 503 -323 500 -323{\\p0}",
    "{\\c&HE0E0E0&\\p6}m 315 -260 b 286 -258 259 -240 246 -215 235 -210 222 -215 211 -211 204 -188 177 -176 172 -151 170 -139 163 -128 154 -121 143 -103 141 -81 143 -60 139 -46 125 -34 129 -17 132 -1 134 16 142 30 145 56 161 80 181 96 196 114 210 133 231 144 266 153 303 138 328 115 373 79 401 28 423 -24 446 -73 465 -123 483 -174 487 -199 467 -225 442 -227 421 -232 402 -242 384 -254 364 -259 342 -250 322 -260 320 -260 317 -261 315 -260{\\p0}",
    -- Main cap
    "{\\c&H0000F0&\\p6}m 1151 -523 b 1016 -516 891 -458 769 -406 693 -369 624 -319 561 -262 526 -252 465 -235 479 -187 502 -147 551 -135 588 -111 1115 165 1379 232 1909 761 1926 800 1952 834 1987 858 2020 883 2053 912 2065 952 2088 1000 2146 962 2139 919 2162 836 2156 747 2143 662 2131 615 2116 567 2122 517 2120 410 2090 306 2089 199 2092 147 2071 99 2034 64 1987 5 1928 -41 1869 -86 1777 -157 1712 -256 1629 -337 1578 -389 1521 -436 1461 -476 1407 -509 1343 -507 1284 -515 1240 -519 1195 -521 1151 -523{\\p0}",
    -- Cap shadow
    "{\\c&H0000AA&\\p6}m 1657 248 b 1658 254 1659 261 1660 267 1669 276 1680 284 1689 293 1695 302 1700 311 1707 320 1716 325 1726 330 1735 335 1744 347 1752 360 1761 371 1753 352 1754 331 1753 311 1751 237 1751 163 1751 90 1752 64 1752 37 1767 14 1778 -3 1785 -24 1786 -45 1786 -60 1786 -77 1774 -87 1760 -96 1750 -78 1751 -65 1748 -37 1750 -8 1750 20 1734 78 1715 134 1699 192 1694 211 1689 231 1676 246 1671 251 1661 255 1657 248 m 1909 541 b 1914 542 1922 549 1917 539 1919 520 1921 502 1919 483 1918 458 1917 433 1915 407 1930 373 1942 338 1947 301 1952 270 1954 238 1951 207 1946 214 1947 229 1945 239 1939 278 1936 318 1924 356 1923 362 1913 382 1912 364 1906 301 1904 237 1891 175 1887 150 1892 126 1892 101 1892 68 1893 35 1888 2 1884 -9 1871 -20 1859 -14 1851 -6 1854 9 1854 20 1855 58 1864 95 1873 132 1883 179 1894 225 1899 273 1908 362 1910 451 1909 541{\\p0}",
    -- Brim and tip pompom
    "{\\c&HF8F8F8&\\p6}m 626 -191 b 565 -155 486 -196 428 -151 387 -115 327 -101 304 -47 273 2 267 59 249 113 219 157 217 213 215 265 217 309 260 302 285 283 373 264 465 264 555 257 608 252 655 292 709 287 759 294 816 276 863 298 903 340 972 324 1012 367 1061 394 1125 382 1167 424 1213 462 1268 482 1322 506 1385 546 1427 610 1479 662 1510 690 1534 725 1566 752 1611 796 1664 830 1703 880 1740 918 1747 986 1805 1005 1863 991 1897 932 1916 880 1914 823 1945 777 1961 725 1979 673 1957 622 1938 575 1912 534 1862 515 1836 473 1790 417 1755 351 1697 305 1658 266 1633 216 1593 176 1574 138 1539 116 1497 110 1448 101 1402 77 1371 37 1346 -16 1295 15 1254 6 1211 -27 1170 -62 1121 -86 1072 -104 1027 -128 976 -133 914 -130 851 -137 794 -162 740 -181 679 -168 626 -191 m 2051 917 b 1971 932 1929 1017 1919 1091 1912 1149 1923 1214 1970 1254 2000 1279 2027 1314 2066 1325 2139 1338 2212 1295 2254 1238 2281 1203 2287 1158 2282 1116 2292 1061 2273 1006 2229 970 2206 941 2167 938 2138 918{\\p0}",
}

--
-- Helper functions
--

local function kill_animation(anitype_key, anistart_key, animation_key)
    state[anitype_key]   = nil
    state[anistart_key]  = nil
    state[animation_key] = nil
end

-- overlays known to be off; kept outside the overlay tables, whose fields all go to mpv
local wiped_osds = setmetatable({}, {__mode = "k"})
local function set_osd(osd, res_x, res_y, text, z)
    if osd.res_x == res_x and osd.res_y == res_y and osd.data == text then
        return
    end
    osd.res_x = res_x
    osd.res_y = res_y
    osd.data = text
    osd.z = z
    wiped_osds[osd] = nil
    -- osd:update(), without waiting for mpv to take it in (nothing is read back)
    local cmd = {}
    for k, v in pairs(osd) do cmd[k] = v end
    cmd.name = "osd-overlay"
    cmd.res_x = math.floor(cmd.res_x)
    cmd.res_y = math.floor(cmd.res_y)
    mp.command_native_async(cmd, function() end)
end

local function set_time_styles(timecurrent_changed, timems_changed)
    if timecurrent_changed then
        state.tc_left_rem = not user_opts.timecurrent
    end
    if timems_changed then
        state.tc_ms = user_opts.timems
    end
end

local function observe_cached(property, callback)
    local key = property:gsub("-", "_")
    mp.observe_property(property, "native", function (_, value)
        state[key] = value
        callback()
    end)
end

-- scale factor for translating between real and virtual ASS coordinates
local function get_virt_scale_factor()
    if state.osd_dimensions.w == 0 or state.osd_dimensions.h == 0 then
        return 0, 0
    end
    return osc_param.playresx / state.osd_dimensions.w,
           osc_param.playresy / state.osd_dimensions.h
end

local function recently_touched()
    if state.touchtime == nil then
        return false
    end
    return state.touchtime + 1 >= mp.get_time()
end

-- return mouse position in virtual ASS coordinates (playresx/y)
-- While a frame is drawn, the pointer position and the few playback properties the
-- elements show are read from mpv once and reused: every read waits on mpv's main
-- thread, and hit-testing alone asked for the pointer ~50 times per frame.
local frame_cache = nil
local function frame_mouse_pos()
    if not frame_cache then return mp.get_mouse_pos() end
    if not frame_cache.mouse_x then
        frame_cache.mouse_x, frame_cache.mouse_y = mp.get_mouse_pos()
    end
    return frame_cache.mouse_x, frame_cache.mouse_y
end
local function frame_number(name, default)
    local v
    if frame_cache then
        v = frame_cache[name]
        if v == nil then
            v = mp.get_property_number(name)
            frame_cache[name] = v == nil and false or v
        end
        if v == false then v = nil end
    else
        v = mp.get_property_number(name)
    end
    if v == nil then return default end
    return v
end

local function get_virt_mouse_pos()
    if recently_touched() then
        local sx, sy = get_virt_scale_factor()
        return state.last_touchX * sx, state.last_touchY * sy
    elseif state.mouse_in_window then
        local sx, sy = get_virt_scale_factor()
        local x, y = frame_mouse_pos()
        return x * sx, y * sy
    else
        return -1, -1
    end
end

local function set_virt_mouse_area(x0, y0, x1, y1, name)
    local sx, sy = get_virt_scale_factor()
    mp.set_mouse_area(x0 / sx, y0 / sy, x1 / sx, y1 / sy, name)
end

local function scale_value(x0, x1, y0, y1, val)
    local m = (y1 - y0) / (x1 - x0)
    local b = y0 - (m * x0)
    return (m * val) + b
end

-- returns the position of an object on a one-dimensional axis,
-- from 0..1 (object to the "left") to 1..0 (object to the "right"), taking margin into account.
local function get_align(align, frame, obj, margin)
    return (frame / 2) + (((frame / 2) - margin - (obj / 2)) * align)
end

local text_measure_osd = mp.create_osd_overlay and mp.create_osd_overlay("ass-events") or nil
if text_measure_osd then
    text_measure_osd.hidden = true
    text_measure_osd.compute_bounds = true
end

local text_width_cache = {}

local function estimate_text_width(text, style)
    if text == nil then return 0 end
    text = tostring(text)
    if #text == 0 then return 0 end

    -- replace digits with '0' for consistency
    local measure_text = text:gsub("%d", "0")
    local cache_key = measure_text .. (style or "")
    local width = 0

    if text_width_cache[cache_key] then
        return text_width_cache[cache_key]
    end

    if text_measure_osd and text_measure_osd.update then
        text_measure_osd.res_x = osc_param.playresx
        text_measure_osd.res_y = osc_param.playresy
        text_measure_osd.data = (style or "") .. "{\\an7\\pos(0,0)}" .. measure_text

        local bounds = text_measure_osd:update()
        if bounds and bounds.x1 and bounds.x0 then
            -- subtract side-bearing padding that libass adds even at bord0
            local fs = tonumber((style or ""):match("\\fs(%d+%.?%d*)")) or 16
            local bearing_correction = fs * 0.08 * 2
            width = math.max(0, (bounds.x1 - bounds.x0) - bearing_correction)
        end
    end

    text_width_cache[cache_key] = width
    return width
end

-- width of the time codes element
local function get_time_codes_width()
    local dur = state.duration or 0
    local rt_sec = state.tc_left_rem and frame_number("playtime-remaining", 0) or frame_number("playback-time", 0)

    local function time_fmt(s)
        local has_h = (s >= 3600) or user_opts.time_format == "fixed"
        local base = has_h and (s >= 36000 and "88" or "8") .. ":88:88" or (s >= 600 and "88" or "8") .. ":88"
        return base .. (state.tc_ms and ".888" or "")
    end

    local prefix = state.tc_left_rem and (user_opts.unicodeminus and UNICODE_MINUS or "-") or ""
    local w = estimate_text_width(prefix .. time_fmt(rt_sec) .. " / " .. time_fmt(dur), osc_styles.time)
    return w ~= 0 and w or 120 + (state.tc_ms and 40 or 0)
end

-- returns hitbox spanning coordinates (top left, bottom right corner)
-- according to alignment
local function get_hitbox_coords(x, y, an, w, h)
    local alignments = {
      [1] = function () return x, y-h, x+w, y end,
      [2] = function () return x-(w/2), y-h, x+(w/2), y end,
      [3] = function () return x-w, y-h, x, y end,

      [4] = function () return x, y-(h/2), x+w, y+(h/2) end,
      [5] = function () return x-(w/2), y-(h/2), x+(w/2), y+(h/2) end,
      [6] = function () return x-w, y-(h/2), x, y+(h/2) end,

      [7] = function () return x, y, x+w, y+h end,
      [8] = function () return x-(w/2), y, x+(w/2), y+h end,
      [9] = function () return x-w, y, x, y+h end,
    }

    return alignments[an]()
end

local function get_element_hitbox(element)
    return element.hitbox.x1, element.hitbox.y1, element.hitbox.x2, element.hitbox.y2
end

local function mouse_hit_coords(bX1, bY1, bX2, bY2)
    local mX, mY = get_virt_mouse_pos()
    return (mX >= bX1 and mX <= bX2 and mY >= bY1 and mY <= bY2)
end

local function mouse_hit(element)
    return mouse_hit_coords(get_element_hitbox(element))
end

local function mouse_in_area(names)
    if type(names) == "string" then names = {names} end
    for _, name in ipairs(names) do
        for _, cords in ipairs(osc_param.areas[name] or {}) do
            if mouse_hit_coords(cords.x1, cords.y1, cords.x2, cords.y2) then
                return true
            end
        end
    end
    return false
end

local function limit_range(min, max, val)
    return math.max(min, math.min(max, val))
end

-- translate value into element coordinates
local function get_slider_ele_pos_for(element, val)
    local ele_pos = scale_value(
        element.slider.min.value, element.slider.max.value,
        element.slider.min.ele_pos, element.slider.max.ele_pos,
        val)

    return limit_range(element.slider.min.ele_pos, element.slider.max.ele_pos, ele_pos)
end

-- translates global (mouse) coordinates to value
local function get_slider_value_at(element, glob_pos)
    if element then
        local val = scale_value(
            element.slider.min.glob_pos, element.slider.max.glob_pos,
            element.slider.min.value, element.slider.max.value,
            glob_pos)

        return limit_range(element.slider.min.value, element.slider.max.value, val)
    end
    -- fall back incase of loading errors
    return 0
end

-- get value at current mouse position
local function get_slider_value(element)
    return get_slider_value_at(element, get_virt_mouse_pos())
end

-- multiplies two alpha values, formular can probably be improved
local function mult_alpha(alphaA, alphaB)
    return math.floor(255 - (((1-(alphaA/255)) * (1-(alphaB/255))) * 255) + 0.5)
end

-- ease-out (cubic): fast start, gentle settle; p runs 0..1
local function ease_out(p)
    p = math.max(0, math.min(1, p))
    return 1 - (1 - p) ^ 3
end

-- spring motion (stiffness 300, damping 24): 0 -> 1 over about a third of a second,
-- with a small overshoot that settles
local function spring(t)
    if t <= 0 then return 0 end
    if t >= 0.6 then return 1 end
    local w, z = 17.32, 0.693
    local wd = w * math.sqrt(1 - z * z)
    return 1 - math.exp(-z * w * t) * (math.cos(wd * t) + (z * w / wd) * math.sin(wd * t))
end

local function add_area(name, x1, y1, x2, y2)
    -- create area if needed
    if osc_param.areas[name] == nil then
        osc_param.areas[name] = {}
    end
    table.insert(osc_param.areas[name], {x1=x1, y1=y1, x2=x2, y2=y2})
end

local function ass_append_alpha(ass, alpha, modifier, inverse, anim_override)
    local ar = {}

    for ai, av in ipairs(alpha) do
        av = mult_alpha(av, modifier)
        local animpos = anim_override or state.animation
        if animpos then
            if inverse then
                animpos = 255 - animpos
            end
            av = mult_alpha(av, animpos)
        end
        ar[ai] = av
    end

    ass:append(string.format("{\\1a&H%X&\\2a&H%X&\\3a&H%X&\\4a&H%X&}", ar[1], ar[2], ar[3], ar[4]))
end

-- Glass surfaces: a translucent tinted fill, a thin light edge and a soft shadow.
-- (libass can't blur what is behind the OSD, so the frosted look comes from the
-- tint, the edge and the shadow.)
-- the glass material as the options resolve it (accessibility settings included)
local glass_look = {}
local function update_glass_look()
    local contrast = user_opts.glass_increase_contrast
    local solid = contrast or user_opts.glass_reduce_transparency
    local opacity = user_opts.glass_opacity
    if solid then opacity = math.max(opacity, contrast and 92 or 86) end
    glass_look = {
        color = contrast and "#000000" or user_opts.glass_color,
        opacity = opacity,
        edge = contrast and 55 or user_opts.glass_border_opacity,
        refraction = user_opts.glass_refraction and not solid,
        motion = not user_opts.reduce_motion,
        contrast = contrast,
    }
end

local function opacity_alpha(percent)
    return math.floor(255 - math.max(0, math.min(100, percent)) * 2.55 + 0.5)
end

-- width of the light edge: about one physical pixel at any window size
local function glass_edge_width()
    local osd_h = state.osd_dimensions and state.osd_dimensions.h or 0
    local ppu = (osd_h > 0 and osc_param.playresy > 0) and (osd_h / osc_param.playresy) or 1
    return math.max(0.5, 1.25 / ppu)
end

-- An assdraw stand-in that keeps every event in its own short string and joins them
-- once at the end: assdraw re-copies its whole text on every append and coordinate,
-- which gets slow for a big drawing like an open menu. Same output as assdraw.
local batch_mt = {}
batch_mt.__index = batch_mt
local function batch_new() return setmetatable({n = 0, list = {}}, batch_mt) end
function batch_mt.new_event(b)
    local a = assdraw.ass_new()
    b.n = b.n + 1
    b.list[b.n] = a
    b.cur = a
end
for _, name in ipairs({"append", "pos", "an", "draw_start", "draw_stop", "coord", "move_to", "line_to",
                       "bezier_curve", "rect_cw", "rect_ccw", "round_rect_cw", "round_rect_ccw", "merge"}) do
    batch_mt[name] = function(b, ...)
        if not b.cur then batch_mt.new_event(b) end
        return b.cur[name](b.cur, ...)
    end
end
function batch_mt.text_of(b)
    local t = {}
    for i = 1, b.n do t[i] = b.list[i].text end
    return table.concat(t, "\n")
end

-- draw a glass rounded rectangle; opts: fade (extra alpha 0-255), fill_alpha,
-- edge_alpha, shadow (false to skip), shadow_alpha, shadow_blur, shadow_y, color
local function glass_rect(ass, x, y, w, h, r, opts)
    opts = opts or {}
    local fade = opts.fade or 0
    local function event(style)
        ass:new_event()
        ass:append(string.format("{\\rDefault\\an7\\pos(%f,%f)\\bord0\\shad0%s}", x, y, style))
        ass:draw_start()
    end
    if opts.shadow ~= false and user_opts.glass_shadow then
        event(string.format("\\blur%g\\1c&H000000&\\1a&H%X&", opts.shadow_blur or 10, mult_alpha(opts.shadow_alpha or 0xBC, fade)))
        ass:round_rect_cw(0, opts.shadow_y or 3, w, h + (opts.shadow_y or 3), r)
        ass:draw_stop()
    end
    event(string.format("\\blur0\\1c&H%s&\\1a&H%X&", osc_color_convert(opts.color or glass_look.color),
        mult_alpha(opts.fill_alpha or opacity_alpha(glass_look.opacity), fade)))
    ass:round_rect_cw(0, 0, w, h, r)
    ass:draw_stop()
    local edge = opts.edge_alpha or opacity_alpha(glass_look.edge)
    if edge < 255 then
        local e = glass_edge_width()
        event(string.format("\\blur0\\1c&HFFFFFF&\\1a&H%X&", mult_alpha(edge, fade)))
        ass:round_rect_cw(0, 0, w, h, r)
        ass:round_rect_ccw(e, e, w - e, h - e, math.max(0, r - e))
        ass:draw_stop()
        -- the light catching the top of the edge, fading down the corners
        if opts.rim ~= false and not glass_look.contrast then
            local cut = math.min(r, h / 2)
            for _, band in ipairs({{y - 2, y + cut * 0.5, 0x8C}, {y + cut * 0.5, y + cut, 0xC4}}) do
                event(string.format("\\blur0.5\\1c&HFFFFFF&\\1a&H%X&\\clip(%f,%f,%f,%f)", mult_alpha(band[3], fade),
                    x - 2, band[1], x + w + 2, band[2]))
                ass:round_rect_cw(0, 0, w, h, r)
                ass:round_rect_ccw(e, e, w - e, h - e, math.max(0, r - e))
                ass:draw_stop()
            end
        end
    end
end


-- Real glass: with vo=gpu-next a small shader blurs the video behind the glass
-- surfaces. ModernZ hands it up to three rounded rectangles through glsl-shader-opts.
local GLASS_SHADER = [==[
// ModernZ glass for vo=gpu-next: frosts and refracts the video behind ModernZ's glass
// surfaces, adds the light catching their rim and the shadow they cast.
// ModernZ loads this itself and moves the surfaces through glsl-shader-opts.
// Up to four rounded rectangles, in fractions of the video area.

//!PARAM mzg_on
//!TYPE DYNAMIC int
//!MINIMUM 0
//!MAXIMUM 1
0

//!PARAM mzg_strength
//!TYPE DYNAMIC float
//!MINIMUM 0.0
//!MAXIMUM 1.0
1.0

//!PARAM mzg_unit
//!TYPE DYNAMIC float
//!MINIMUM 0.0
//!MAXIMUM 1.0
0.0014

//!PARAM mzg_lens
//!TYPE DYNAMIC float
//!MINIMUM 0.0
//!MAXIMUM 1.0
1.0

//!PARAM mzg_shadow
//!TYPE DYNAMIC float
//!MINIMUM 0.0
//!MAXIMUM 1.0
1.0

//!PARAM mzg_tone
//!TYPE DYNAMIC float
//!MINIMUM 0.0
//!MAXIMUM 1.0
1.0

//!PARAM mzg_0x
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_0y
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_0w
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_0h
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_0r
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_0a
//!TYPE DYNAMIC float
1.0
//!PARAM mzg_1x
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_1y
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_1w
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_1h
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_1r
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_1a
//!TYPE DYNAMIC float
1.0
//!PARAM mzg_2x
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_2y
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_2w
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_2h
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_2r
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_2a
//!TYPE DYNAMIC float
1.0
//!PARAM mzg_3x
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_3y
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_3w
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_3h
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_3r
//!TYPE DYNAMIC float
0.0
//!PARAM mzg_3a
//!TYPE DYNAMIC float
1.0

//!HOOK OUTPUT
//!BIND HOOKED
//!SAVE MZG_A
//!WIDTH HOOKED.w 270 * HOOKED.h /
//!HEIGHT 270
//!WHEN mzg_on
//!DESC [ModernZ] glass: downscale
// a fixed 270 rows, so the frost looks the same at any window size
vec4 hook() {
    // box filter over the source texels under this one, two by two with bilinear taps
    int n = clamp(int(ceil(HOOKED_size.y / 540.0)), 1, 8);
    vec4 sum = vec4(0.0);
    for (int y = 0; y < n; y++) {
        for (int x = 0; x < n; x++) {
            vec2 o = (vec2(float(x), float(y)) - 0.5 * float(n - 1)) * 2.0;
            sum += HOOKED_tex(HOOKED_pos + o * HOOKED_pt);
        }
    }
    return sum / float(n * n);
}

//!HOOK OUTPUT
//!BIND MZG_A
//!SAVE MZG_B
//!WIDTH MZG_A.w
//!HEIGHT MZG_A.h
//!WHEN mzg_on
//!DESC [ModernZ] glass: horizontal blur
vec4 hook() {
    // gaussian, sigma 6 texels (about 24 px at 1080p), as 19 bilinear taps
    const float w[10] = float[](0.06663, 0.12873, 0.11215, 0.08749, 0.06113, 0.03824, 0.02143, 0.01075, 0.00483, 0.00194);
    const float o[10] = float[](0.0, 1.4896, 3.4757, 5.4619, 7.4481, 9.4344, 11.4208, 13.4073, 15.3940, 17.3808);
    vec4 c = MZG_A_tex(MZG_A_pos) * w[0];
    for (int i = 1; i < 10; i++) {
        vec2 d = vec2(o[i] * MZG_A_pt.x, 0.0);
        c += (MZG_A_tex(MZG_A_pos + d) + MZG_A_tex(MZG_A_pos - d)) * w[i];
    }
    return c;
}

//!HOOK OUTPUT
//!BIND MZG_B
//!SAVE MZG_C
//!WIDTH MZG_B.w
//!HEIGHT MZG_B.h
//!WHEN mzg_on
//!DESC [ModernZ] glass: vertical blur
vec4 hook() {
    const float w[10] = float[](0.06663, 0.12873, 0.11215, 0.08749, 0.06113, 0.03824, 0.02143, 0.01075, 0.00483, 0.00194);
    const float o[10] = float[](0.0, 1.4896, 3.4757, 5.4619, 7.4481, 9.4344, 11.4208, 13.4073, 15.3940, 17.3808);
    vec4 c = MZG_B_tex(MZG_B_pos) * w[0];
    for (int i = 1; i < 10; i++) {
        vec2 d = vec2(0.0, o[i] * MZG_B_pt.y);
        c += (MZG_B_tex(MZG_B_pos + d) + MZG_B_tex(MZG_B_pos - d)) * w[i];
    }
    return c;
}

//!HOOK OUTPUT
//!BIND HOOKED
//!BIND MZG_C
//!WHEN mzg_on
//!DESC [ModernZ] glass: composite

// signed distance (in pixels) to a rounded rectangle given in fractions of the video
float mzg_box(vec2 p, float x, float y, float w, float h, float r) {
    vec2 half_size = 0.5 * vec2(w, h) * HOOKED_size;
    float rad = r * HOOKED_size.y;
    vec2 q = abs(p - (vec2(x, y) * HOOKED_size + half_size)) - half_size + rad;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - rad;
}

// distance to the nearest surface; its opacity (it may be fading in or out) goes to a
float mzg_sdf_a(vec2 p, out float a) {
    float d = 1e6, k;
    a = 1.0;
    if (mzg_0w > 0.0) { k = mzg_box(p, mzg_0x, mzg_0y, mzg_0w, mzg_0h, mzg_0r); if (k < d) { d = k; a = mzg_0a; } }
    if (mzg_1w > 0.0) { k = mzg_box(p, mzg_1x, mzg_1y, mzg_1w, mzg_1h, mzg_1r); if (k < d) { d = k; a = mzg_1a; } }
    if (mzg_2w > 0.0) { k = mzg_box(p, mzg_2x, mzg_2y, mzg_2w, mzg_2h, mzg_2r); if (k < d) { d = k; a = mzg_2a; } }
    if (mzg_3w > 0.0) { k = mzg_box(p, mzg_3x, mzg_3y, mzg_3w, mzg_3h, mzg_3r); if (k < d) { d = k; a = mzg_3a; } }
    return d;
}

float mzg_sdf(vec2 p) {
    float a;
    return mzg_sdf_a(p, a);
}

vec4 hook() {
    const vec3 luma = vec3(0.2126, 0.7152, 0.0722);
    vec4 c = HOOKED_tex(HOOKED_pos);
    vec2 p = HOOKED_pos * HOOKED_size;
    float u = max(mzg_unit * HOOKED_size.y, 0.25); // pixels per ModernZ layout unit
    float alpha;
    float d = mzg_sdf_a(p, alpha);
    if (d > 48.0 * u)
        return c;

    if (d > 0.0) {
        // the shadow the glass casts: soft, and deeper over bright pictures
        if (mzg_shadow > 0.0) {
            float sa;
            float ds = max(mzg_sdf_a(p - vec2(0.0, 6.0 * u), sa), 0.0) / (14.0 * u);
            float under = dot(MZG_C_tex(HOOKED_pos).rgb, luma);
            float k = mzg_shadow * sa * mix(0.10, 0.26, smoothstep(0.15, 0.85, under));
            c.rgb *= 1.0 - k * exp(-0.5 * ds * ds);
        }
        if (d >= 0.5)
            return c;
    }

    // outward normal of the nearest edge, and how close to that edge we are
    vec2 nx = vec2(1.0, 0.0);
    vec2 n = vec2(mzg_sdf(p + nx.xy) - mzg_sdf(p - nx.xy), mzg_sdf(p + nx.yx) - mzg_sdf(p - nx.yx));
    n = dot(n, n) > 1e-8 ? normalize(n) : vec2(0.0, -1.0);
    float rim = clamp(1.0 + min(d, 0.0) / (14.0 * u), 0.0, 1.0); // 1 at the edge, 0 inside

    // lensing: the thick edge bends the picture inward; the middle stays undistorted
    float bend = mzg_lens * 7.0 * u * rim * rim;
    vec2 q = clamp((p - n * bend) / HOOKED_size, vec2(0.0), vec2(1.0));
    vec3 frost = MZG_C_tex(q).rgb;
    vec3 g = mix(frost, HOOKED_tex(q).rgb, mzg_lens * 0.55 * rim * rim * rim);

    // vibrancy, like backdrop-filter: saturate(170%)
    float l = dot(g, luma);
    g = clamp(mix(vec3(l), g, 1.7), 0.0, 1.0);

    // adaptive tone: brighter pictures get deeper glass, so white controls stay readable
    float under = dot(frost, luma);
    g *= 1.0 - mzg_tone * 0.5 * smoothstep(0.35, 1.0, under);

    // specular: a light above the viewer catches the top of the rim, a faint bounce the bottom
    float top = max(dot(n, vec2(-0.30, -0.954)), 0.0);
    float bottom = max(dot(n, vec2(0.30, 0.954)), 0.0);
    g += mzg_lens * (0.16 * top * top + 0.05 * bottom * bottom) * pow(rim, 7.0);

    float m = clamp(0.5 - d, 0.0, 1.0) * mzg_strength * alpha;
    return vec4(mix(c.rgb, g, m), c.a);
}
]==]

-- loaded: the shader is in mpv's list right now. It is taken out when glass has been off
-- screen for a while: any hook on the output makes the renderer add a full-size pass.
local glass_blur = {path = nil, sig = nil, suspended = false, failed = false, loaded = false}

local function glass_blur_active()
    if glass_blur.path == nil or glass_blur.failed then return false end
    -- the shader sees the video before mpv rotates or flips it onto the screen, so
    -- rotated video gets the plain tinted glass instead (glass_blur.rotated is observed)
    return not glass_blur.rotated
end

local function glass_blur_install()
    if glass_blur.path or glass_blur.failed then return end
    if not user_opts.glass_blur or mp.get_property("current-vo") ~= "gpu-next" then return end
    local dir = mp.command_native({"expand-path", "~~cache/"})
    if not dir or not utils.file_info(dir) then
        dir = os.getenv("TEMP") or os.getenv("TMPDIR") or "/tmp"
    end
    local path = utils.join_path(dir, "modernz-glass.glsl")
    local f = io.open(path, "wb")
    if not f then glass_blur.failed = true return end
    f:write(GLASS_SHADER)
    f:close()
    -- left over from an earlier start (it is taken out again while glass is hidden)
    for _, p in ipairs(mp.get_property_native("glsl-shaders") or {}) do
        if p == path then glass_blur.loaded = true end
    end
    glass_blur.path = path

    -- mpv's default screenshot keys, taken without the blur in the picture
    -- (keys bound in input.conf still win over these)
    for key, mode in pairs({s = "subtitles", S = "video"}) do
        mp.add_key_binding(key, "glass-screenshot-" .. mode, function()
            glass_blur.screenshot("screenshot " .. mode)
        end)
    end
end

-- rects: {x, y, w, h, r, opacity} in OSC coordinates; an empty list turns the blur off
local function glass_blur_update(rects)
    if glass_blur.path == nil or glass_blur.failed then return end
    if glass_blur.suspended or not glass_blur_active() then rects = {} end
    local d = state.osd_dimensions or {}
    local W, H = d.w or 0, d.h or 0
    local ml, mr, mt, mb = d.ml or 0, d.mr or 0, d.mt or 0, d.mb or 0
    local vw, vh = W - ml - mr, H - mt - mb
    local kv = {mzg_on = "0"}
    if #rects > 0 and vw > 0 and vh > 0 and osc_param.playresx > 0 then
        kv.mzg_on = "1"
        local sx, sy = W / osc_param.playresx, H / osc_param.playresy
        kv.mzg_unit = string.format("%.6f", sy / vh)
        kv.mzg_lens = glass_look.refraction and "1" or "0"
        kv.mzg_shadow = user_opts.glass_shadow and "1" or "0"
        kv.mzg_tone = "1"
        for i = 0, 3 do
            local r = rects[i + 1]
            local p = "mzg_" .. i
            if r then
                kv[p .. "x"] = string.format("%.5f", (r[1] * sx - ml) / vw)
                kv[p .. "y"] = string.format("%.5f", (r[2] * sy - mt) / vh)
                kv[p .. "w"] = string.format("%.5f", r[3] * sx / vw)
                kv[p .. "h"] = string.format("%.5f", r[4] * sy / vh)
                kv[p .. "r"] = string.format("%.5f", r[5] * sy / vh)
                kv[p .. "a"] = string.format("%.2f", r[6] or 1)
            else
                kv[p .. "w"] = "0"
            end
        end
    end
    local keys = {}
    for k in pairs(kv) do keys[#keys + 1] = k end
    table.sort(keys)
    local parts = {}
    for _, k in ipairs(keys) do parts[#parts + 1] = k .. "=" .. kv[k] end
    local sig = table.concat(parts, ",")
    -- unchanged: nothing to do (an update makes the renderer start over)
    if sig == glass_blur.sig then return end
    glass_blur.sig = sig
    msg.debug("glass blur: " .. sig)
    -- Sent without waiting: an option change waits for the renderer to take it, which
    -- can hold the script up to a frame, every frame of an animation. mpv runs them in
    -- the order sent, before the OSD update that follows.
    local function send(...)
        mp.command_native_async({"change-list", ...}, function() end)
    end
    if kv.mzg_on == "0" then
        -- nothing on screen: switch the passes off now, and take the shader out once the
        -- glass has stayed away a while (loaded but idle, it still costs one full-size
        -- pass per frame; taking it out and back in for every brief hide isn't worth it)
        if glass_blur.loaded then
            send("glsl-shader-opts", "append", "mzg_on=0")
            if not glass_blur.unload_timer then
                glass_blur.unload_timer = mp.add_timeout(5, function()
                    glass_blur.unload_timer = nil
                    if glass_blur.loaded and glass_blur.sig and glass_blur.sig:find("mzg_on=0", 1, true) then
                        send("glsl-shaders", "remove", glass_blur.path)
                        glass_blur.loaded = false
                    end
                end)
            end
        end
        return
    end
    if glass_blur.unload_timer then
        glass_blur.unload_timer:kill()
        glass_blur.unload_timer = nil
    end
    -- "add" sets just these keys and keeps any other shader's options
    send("glsl-shader-opts", "add", sig)
    if not glass_blur.loaded then
        send("glsl-shaders", "append", glass_blur.path)
        glass_blur.loaded = true
    end
end


-- the blur would end up in "video" screenshots, so lift it while one is taken
local function screenshot_without_glass(command)
    if not glass_blur_active() or glass_blur.sig == nil or glass_blur.sig:find("mzg_on=0", 1, true) then
        mp.command(command)
        return
    end
    glass_blur.suspended = true
    glass_blur_update({})
    mp.add_timeout(0.15, function()
        mp.command(command)
        mp.add_timeout(0.2, function()
            glass_blur.suspended = false
            glass_blur.sig = nil
            if glass_blur.on_resume then glass_blur.on_resume() end
        end)
    end)
end
glass_blur.screenshot = screenshot_without_glass

-- vector clip in the shape of a rounded rectangle (absolute coordinates)
local function rrect_clip(x, y, w, h, r)
    local a = assdraw.ass_new()
    a:round_rect_cw(x, y, x + w, y + h, r)
    return string.format("\\clip(%d,%s)", a.scale, a.text)
end

-- how opaque glass surfaces are: lighter when the video behind them is blurred
local function glass_fill_alpha(min_opacity)
    local opacity = glass_look.opacity
    if not glass_blur_active() then opacity = math.max(opacity, 62) end
    return opacity_alpha(math.max(opacity, min_opacity or 0))
end

-- draw tooltip background box and label
local function draw_tooltip(ass, tx, ty, width, style, label, alpha)
    local fs = user_opts.tooltip_font_size
    local ph, pv = 8, 4
    local box_h = fs + 2 * pv
    local min_w = box_h + 2 * ph
    local box_w = math.max(width + 2 * ph, min_w)
    -- glass pill
    glass_rect(ass, tx - box_w / 2, ty - fs - pv, box_w, box_h, box_h / 2,
        {fill_alpha = opacity_alpha(math.max(glass_look.opacity, 80)), shadow_blur = 8, shadow_y = 3, shadow_alpha = 0xC4})
    -- label
    ass:new_event()
    ass:append("{\\rDefault}")
    ass:pos(tx, ty)
    ass:an(2)
    ass:append(style)
    ass:append("{\\bord0\\shad0}")
    if alpha then ass_append_alpha(ass, alpha, 0) end
    ass:append(label)
end

local function ass_draw_cir_cw(ass, x, y, r)
    ass:round_rect_cw(x-r, y-r, x+r, y+r, r)
end

local function ass_draw_rr_h_cw(ass, x0, y0, x1, y1, r1, hexagon, r2)
    if hexagon then
        ass:hexagon_cw(x0, y0, x1, y1, r1, r2)
    else
        ass:round_rect_cw(x0, y0, x1, y1, r1, r2)
    end
end

local function get_hidetimeout()
    if user_opts.visibility == "always" then
        return -1 -- disable autohide
    end
    return user_opts.hidetimeout
end

local function get_touchtimeout()
    if state.touchtime == nil then
        return 0
    end
    return state.touchtime + (get_hidetimeout() / 1000) - mp.get_time()
end

local function cache_enabled()
    return state.demuxer_cache_state and #state.demuxer_cache_state["seekable-ranges"] > 0
end

local function set_margin_offset(prop, offset)
    if offset > 0 then
        if not state[prop] then
            state[prop] = mp.get_property_number(prop)
        end
        mp.set_property_number(prop, state[prop] + offset)
    elseif state[prop] then
        mp.set_property_number(prop, state[prop])
        state[prop] = nil
    end
end

local function reset_margins()
    -- restore subtitle position if it was changed
    if state.osc_adjusted_subpos ~= nil then
        mp.set_property_number("sub-pos", state.user_subpos)
        state.osc_adjusted_subpos = nil
    end
    set_margin_offset("osd-margin-y", 0)
end

local function update_margins()
    local use_margins = get_hidetimeout() < 0 or user_opts.dynamic_margins
    local top_vis = state.wc_visible
    local bottom_vis = state.osc_visible
    local margins = {
        l = 0,
        r = 0,
        t = (use_margins and top_vis) and osc_param.video_margins.t or 0,
        b = (use_margins and bottom_vis) and osc_param.video_margins.b or 0,
    }

    -- raise amount is based on OSC height
    if user_opts.sub_margins and mp.get_property_native("sid") then
        if margins.b > 0 then
            local raise_percent = margins.b * 100
            -- only raise if subs are low enough that they would overlap the OSC
            if state.user_subpos >= (100 - raise_percent) then
                local adjusted = math.floor((1 - margins.b) * 100)
                if adjusted < 0 then adjusted = state.user_subpos end
                state.osc_adjusted_subpos = adjusted
                mp.set_property_number("sub-pos", adjusted)
            else
                -- sub pos is high; do nothing
                state.osc_adjusted_subpos = nil
            end
        else
            -- restore original sub position
            if state.osc_adjusted_subpos ~= nil then
                mp.set_property_number("sub-pos", state.user_subpos)
                state.osc_adjusted_subpos = nil
            end
        end
    end

    if user_opts.osd_margins then
        local align = mp.get_property("osd-align-y")
        local osd_margin = 0
        if align == "top" and top_vis then
            osd_margin = margins.t
        elseif align == "bottom" and bottom_vis then
            osd_margin = margins.b
        end
        set_margin_offset("osd-margin-y", osd_margin * (osc_param.osd_units_y or osc_param.playresy))
    end

    mp.set_property_native("user-data/osc/margins", margins)
end

local tick

-- Request that tick() is called (which typically re-renders the OSC).
-- The tick is then either executed immediately, or rate-limited if it was
-- called a small time ago.
local function request_tick()
    if state.tick_timer == nil then
        state.tick_timer = mp.add_timeout(0, tick)
    end

    if not state.tick_timer:is_enabled() then
        local now = mp.get_time()
        local timeout = tick_delay - (now - state.tick_last_time)
        if timeout < 0 then
            timeout = 0
        end
        state.tick_timer.timeout = timeout
        state.tick_timer:resume()
    end
end
glass_blur.on_resume = request_tick

local function request_init()
    state.initREQ = true
    request_tick()
end

-- Like request_init(), but also request an immediate update
local function request_init_resize()
    request_init()
    -- ensure immediate update
    state.tick_timer:kill()
    state.tick_timer.timeout = 0
    state.tick_timer:resume()
end

local function render_wipe(osd)
    msg.trace("render_wipe()")
    -- already off: skip the round trip to mpv (this runs on every redraw)
    if osd.data == "" and wiped_osds[osd] then return end
    osd.data = "" -- allows set_osd to immediately update on enable
    wiped_osds[osd] = true
    osd:remove()
end

-- Turn a running fade around, continuing from its current alpha instead of
-- restarting (fade-in runs alpha 255 -> 0, fade-out 0 -> 255 over fadeduration).
-- anitype_key is "anitype" or "wc_anitype"; the matching start/alpha keys share its prefix.
local function reverse_fade(anitype_key, new_type)
    local prefix = anitype_key:sub(1, #anitype_key - #"anitype")
    local anistart_key, animation_key = prefix .. "anistart", prefix .. "animation"
    local alpha = state[animation_key]
    if alpha == nil then
        -- the fade hasn't drawn a frame yet: reversing a fade-out means it never left
        state[anitype_key] = (new_type == "out") and "out" or nil
        state[anistart_key] = nil
        return
    end
    -- where the new fade's curve has this alpha (see run_fade)
    local progress = (new_type == "out") and math.sqrt(alpha / 255) or (1 - (alpha / 255) ^ (1 / 3))
    state[anitype_key] = new_type
    state[anistart_key] = mp.get_time() - progress * (user_opts.fadeduration / 1000)
end

local function show_bar(label, showtime_key, visible_key, anitype_key, set_visible)
    -- show when disabled can happen (e.g. mouse_move) due to async/delayed unbinding
    if not state.enabled then return end
    msg.trace("show_" .. label)
    state[showtime_key] = mp.get_time()
    if user_opts.fadeduration <= 0 then
        set_visible(true)
    elseif user_opts.fadein then
        if state[anitype_key] == "out" then
            -- the bar is still flagged visible while fading out, so turn the fade
            -- around here, otherwise it completes and hides the bar right after
            -- this show (e.g. pausing mid fade-out with keeponpause)
            reverse_fade(anitype_key, "in")
            request_tick()
        elseif not state[visible_key] then
            state[anitype_key] = "in"
            request_tick()
        end
    else
        set_visible(true)
        state[anitype_key] = nil
    end
end

local function hide_bar(label, visible_key, anitype_key, set_visible)
    msg.trace("hide_" .. label)
    if not state.enabled then
        -- typically hide happens at render() from tick(), but now tick() is
        -- no-op and won't render again to remove the osc, so do that manually.
        state[visible_key] = false
        render_wipe(state.osd)
    elseif user_opts.fadeduration > 0 then
        if state[visible_key] then
            if state[anitype_key] == "in" then
                -- hiding during a fade-in: fade out from the current alpha rather
                -- than reusing the fade-in start time (which cut the fade-out short)
                reverse_fade(anitype_key, "out")
            elseif state[anitype_key] ~= "out" then
                state[anitype_key] = "out"
            end
            request_tick()
        end
    else
        set_visible(false)
    end
end

local function update_tracklist(_, track_list)
    state.audio_track_count = 0
    state.sub_track_count = 0

    for _, track in pairs(track_list) do
        if track.type == "audio" then
            state.audio_track_count = state.audio_track_count + 1
        elseif track.type == "sub" then
            state.sub_track_count = state.sub_track_count + 1
        end
    end

    request_init()
end

-- convert slider_pos to logarithmic depending on volume_control user_opts
local function set_volume(slider_pos)
    local volume = slider_pos
    if user_opts.volume_control_type == "logarithmic" then
        volume = slider_pos^2 / 100
    end
    return math.floor(volume)
end

-- WindowControl helpers
local function window_controls_enabled()
    local val = user_opts.window_top_bar
    if val == "auto" then
        return not state.border or not state.title_bar or (state.fullscreen and platform ~= "darwin")
    else
        return val ~= "no"
    end
end

--
-- Element Management
--
local elements = {}

local function prepare_elements()
    -- remove elements without layout or invisible
    local elements2 = {}
    for _, element in pairs(elements) do
        if element.layout ~= nil and element.visible then
            table.insert(elements2, element)
        end
    end
    elements = elements2

    local function elem_compare (a, b)
        return a.layout.layer < b.layout.layer
    end

    table.sort(elements, elem_compare)

    for _,element in pairs(elements) do

        local elem_geo = element.layout.geometry

        -- Calculate title and chapter hitbox
        local hitbox_w = elem_geo.w

        if (element.name == "title" or element.name == "chapter_title") and type(element.content) == "function" then
            local width = estimate_text_width(element.content(), osc_styles[element.name])
            if width > 0 then hitbox_w = math.min(width, hitbox_w) end
        end

        -- Calculate the hitbox
        local hitbox_h = elem_geo.h + ((element.name == "volumebar" or element.name == "zoom_control") and 14 or 0)
        local bX1, bY1, bX2, bY2 = get_hitbox_coords(elem_geo.x, elem_geo.y, elem_geo.an, hitbox_w, hitbox_h)
        element.hitbox = {x1 = bX1, y1 = bY1, x2 = bX2, y2 = bY2}

        local style_ass = assdraw.ass_new()

        -- prepare static elements
        style_ass:append("{}") -- hack to troll new_event into inserting a \n
        style_ass:new_event()
        style_ass:pos(elem_geo.x, elem_geo.y)
        style_ass:an(elem_geo.an)
        style_ass:append(element.layout.style)

        element.style_ass = style_ass

        local static_ass = assdraw.ass_new()

        if element.type == "box" then
            --draw box
            local box = element.layout.box
            static_ass:draw_start()
            ass_draw_rr_h_cw(static_ass, 0, 0, elem_geo.w, elem_geo.h, box.radius, box.hexagon)
            if box.ring then
                -- only an outline of this width (glass edges)
                static_ass:round_rect_ccw(box.ring, box.ring, elem_geo.w - box.ring, elem_geo.h - box.ring, math.max(0, box.radius - box.ring))
            end
            static_ass:draw_stop()

        elseif element.type == "slider" then
            --draw static slider parts
            local slider_lo = element.layout.slider
            -- calculate positions of min and max points
            element.slider.min.ele_pos = user_opts.seek_handle_size > 0 and (user_opts.seek_handle_size * elem_geo.h / 2) or slider_lo.border
            element.slider.max.ele_pos = elem_geo.w - element.slider.min.ele_pos
            element.slider.min.glob_pos = element.hitbox.x1 + element.slider.min.ele_pos
            element.slider.max.glob_pos = element.hitbox.x1 + element.slider.max.ele_pos

            static_ass:draw_start()
            -- a hack which prepares the whole slider area to allow center placements such like an=5
            static_ass:rect_cw(0, 0, elem_geo.w, elem_geo.h)
            static_ass:rect_ccw(0, 0, elem_geo.w, elem_geo.h)
            -- marker nibbles are drawn dynamically in draw_seekbar_nibbles()
        end

        element.static_ass = static_ass

        -- if the element is supposed to be disabled,
        -- style it accordingly and kill the eventresponders
        if not element.enabled then
            if element.name ~= "seekbar" then
                element.layout.alpha[1] = 215
            end
            -- keep these to display tooltips
            if not (element.name == "sub_track" or element.name == "audio_track" or element.name == "playlist") then
                element.eventresponder = nil
            end
        end

        -- gray out the element if it is toggled off
        if element.off then
            element.layout.alpha[1] = 100
        end
    end
end

--
-- Element Rendering
--

-- returns nil or a chapter element from the native property chapter-list
local function get_chapter(possec)
    local cl = state.chapter_list  -- sorted, get latest before possec, if any

    for n=#cl,1,-1 do
        if possec >= cl[n].time then
            return cl[n]
        end
    end
end

-- Computes handle position and radius without drawing
-- Returns handle position, radius, and whether the handle is active (hovered or dragged)
local function get_seekbar_handle_pos(element)
    local pos = element.slider.posF()
    if not pos then return 0, 0, false end

    local elem_geo = element.layout.geometry
    local handle_radius = user_opts.seek_handle_size * elem_geo.h / 2
    local handle_x = get_slider_ele_pos_for(element, pos)
    local center_y = elem_geo.h / 2

    local mouse_over_handle = mouse_hit_coords(
        element.hitbox.x1 + handle_x - handle_radius,
        element.hitbox.y1 + center_y - handle_radius,
        element.hitbox.x1 + handle_x + handle_radius,
        element.hitbox.y1 + center_y + handle_radius
    ) and element.enabled

    local is_active = mouse_over_handle or element.state.handle_drag

    if handle_radius > 0 then
        if is_active then
            handle_radius = handle_radius * (user_opts.slider_hover_size / 100)
            handle_x = limit_range(handle_radius, elem_geo.w - handle_radius, handle_x)
        end
        return handle_x, handle_radius, is_active
    end

    return handle_x, 0, false
end

-- Prepares elem_ass for a new draw layer with the given color
local function begin_draw_layer(element, elem_ass, color, anim_override)
    elem_ass:draw_stop()
    elem_ass:merge(element.style_ass)
    ass_append_alpha(elem_ass, element.layout.alpha, 0, nil, anim_override)
    elem_ass:append("{\\blur0\\bord0\\1c&H" .. osc_color_convert(color) .. "&}")
    elem_ass:merge(element.static_ass)
end

-- Draws a handle on the seekbar using precomputed position and radius
local function draw_seekbar_handle(element, elem_ass, handle_x, handle_radius, anim_override, is_active)
    if handle_radius <= 0 then return end

    local center_y = element.layout.geometry.h / 2
    local slider_lo = element.layout.slider

    local fill_color = slider_lo.handle_color or user_opts.side_buttons_color
    local border_color = slider_lo.handle_border
    local border_thickness = is_active and user_opts.seek_handle_border_hover_size or user_opts.seek_handle_border_size
    local has_border = border_color and border_color ~= "" and border_thickness > 0

    if has_border then
        -- inner_radius is how far the fill circle extends inward from the outer edge
        local inner_radius = handle_radius * (1 - border_thickness)
        -- full circle in border color, then smaller circle in fill color on top
        begin_draw_layer(element, elem_ass, border_color, anim_override)
        ass_draw_cir_cw(elem_ass, handle_x, center_y, handle_radius)
        begin_draw_layer(element, elem_ass, fill_color, anim_override)
        ass_draw_cir_cw(elem_ass, handle_x, center_y, inner_radius)
    else
        -- no border configured, just draw a single solid circle
        begin_draw_layer(element, elem_ass, fill_color, anim_override)
        ass_draw_cir_cw(elem_ass, handle_x, center_y, handle_radius)
    end
end

-- Whether chapter marker n (in percent) should be drawn on the seekbar.
-- The first chapter normally starts at the beginning of the file, where a marker is
-- meaningless, so it is skipped; a first chapter that starts later still gets one.
local function is_drawn_marker(n, marker)
    if n > 1 then return true end
    local duration = state.duration or 0
    return duration > 0 and (marker / 100 * duration) >= 1
end

-- Collects and sorts pixel-space cut positions for gap-style chapter markers, skipping a first marker at the start
local function collect_gap_cuts(element)
    local cuts = {}
    if element.slider.markerF then
        for n, marker in ipairs(element.slider.markerF()) do
            if is_drawn_marker(n, marker) and marker >= element.slider.min.value and marker <= element.slider.max.value then
                cuts[#cuts + 1] = get_slider_ele_pos_for(element, marker)
            end
        end
        table.sort(cuts)
    end
    return cuts
end

-- Draws bar segments split around chapter gaps, stopping at x_max (bar_w for bg, xp for fg).
local function draw_gap_segments(elem_ass, element, gap_half, x_max, slider_lo, elem_geo, radius)
    gap_half = gap_half or 1.5
    local cuts = collect_gap_cuts(element)
    -- clamp x_max back to the nearest gap boundary if it falls inside a gap
    for _, cut in ipairs(cuts) do
        if x_max > cut - gap_half and x_max < cut + gap_half then
            x_max = cut - gap_half
            break
        end
    end
    local seg_start = 0
    for _, cut in ipairs(cuts) do
        if cut >= x_max then break end
        local seg_end = cut - gap_half
        if seg_end > seg_start then
            elem_ass:round_rect_cw(seg_start, slider_lo.gap, seg_end, elem_geo.h - slider_lo.gap,
                (seg_start == 0) and radius or 0, 0)
        end
        seg_start = cut + gap_half
    end
    if x_max > seg_start then
        elem_ass:round_rect_cw(seg_start, slider_lo.gap, x_max, elem_geo.h - slider_lo.gap,
            (seg_start == 0) and radius or 0, (x_max == elem_geo.w) and radius or 0)
    end
end

-- Draws seekbar ranges according to user_opts
local function draw_seekbar_ranges(element, elem_ass, xp, rh, override_alpha, inverse)
    local handle = xp and rh and rh > 0
    xp = xp or 0
    rh = rh or 0
    local slider_lo = element.layout.slider
    local elem_geo = element.layout.geometry
    local seekRanges = element.slider.seekRangesF()
    if not seekRanges then return end
    elem_ass:draw_stop()
    elem_ass:merge(element.style_ass)
    ass_append_alpha(elem_ass, element.layout.alpha, override_alpha or user_opts.seekrangealpha, inverse)
    elem_ass:append("{\\1c&H" .. osc_color_convert(user_opts.seekbar_cache_color) .. "&}")
    elem_ass:merge(element.static_ass)

    local radius = slider_lo.radius
    local gap_half = 1.5
    local cuts = (slider_lo.nibbles_style == "gap" and element.name == "seekbar") and collect_gap_cuts(element) or {}

    for _, range in pairs(seekRanges) do
        local pstart = math.max(xp, get_slider_ele_pos_for(element, range["start"]) - slider_lo.gap)
        local pend = math.min(elem_geo.w, get_slider_ele_pos_for(element, range["end"]) + slider_lo.gap)

        -- round edge only when cache range reaches start/end
        local r_left = pstart < element.slider.min.ele_pos and radius or 0
        local r_right = pend > element.slider.max.ele_pos and radius or 0

        -- split around chapter gaps then around the handle
        local seg_start = pstart
        for _, cut in ipairs(cuts) do
            local gap_l, gap_r = cut - gap_half, cut + gap_half
            if gap_r > pstart and gap_l < pend then
                local sl, sr = seg_start, math.min(gap_l, pend)
                if handle and (sl < xp + rh and sr > xp - rh) then
                    if sl < xp - rh then elem_ass:round_rect_cw(sl, slider_lo.gap, xp - rh, elem_geo.h - slider_lo.gap, sl == pstart and r_left or 0, 0) end
                    if xp + rh < sr  then elem_ass:round_rect_cw(xp + rh, slider_lo.gap, sr, elem_geo.h - slider_lo.gap, 0, 0) end
                elseif sr > sl then
                    elem_ass:round_rect_cw(sl, slider_lo.gap, sr, elem_geo.h - slider_lo.gap, sl == pstart and r_left or 0, 0)
                end
                seg_start = math.max(gap_r, pstart)
            end
        end
        local sl, sr = seg_start, pend
        local rl = (sl == pstart) and r_left or 0
        if handle and (sl < xp + rh and sr > xp - rh) then
            if sl < xp - rh then elem_ass:round_rect_cw(sl, slider_lo.gap, xp - rh, elem_geo.h - slider_lo.gap, rl, 0) end
            if xp + rh < sr  then elem_ass:round_rect_cw(xp + rh, slider_lo.gap, sr, elem_geo.h - slider_lo.gap, 0, r_right) end
        else
            if sr > sl then elem_ass:round_rect_cw(sl, slider_lo.gap, sr, elem_geo.h - slider_lo.gap, rl, r_right) end
        end
    end
end

-- show visual indicator in seek ranges for ab loop
local function draw_ab_loop_range(element, elem_ass)
    if element.name ~= "seekbar" then return end
    local duration = state.duration
    if not duration or duration <= 0 then return end
    local ab_a = frame_number("ab-loop-a")
    if not ab_a then return end
    local ab_b = frame_number("ab-loop-b")
    -- with only A set, show the pending range up to the end of the file;
    -- if B is placed before A, mpv loops as if the points were given in order
    local loop_start = ab_a
    local loop_end = ab_b or duration
    if loop_start > loop_end then
        loop_start, loop_end = loop_end, loop_start
    end
    loop_start = math.max(0, math.min(duration, loop_start))
    loop_end = math.max(0, math.min(duration, loop_end))
    local slider_lo = element.layout.slider
    local elem_geo = element.layout.geometry
    local ax = get_slider_ele_pos_for(element, loop_start / duration * 100)
    local bx = get_slider_ele_pos_for(element, loop_end / duration * 100)
    if ax >= bx then return end
    begin_draw_layer(element, elem_ass, user_opts.ab_loop_color)
    elem_ass:rect_cw(ax, slider_lo.gap, bx, elem_geo.h - slider_lo.gap)
end

local function draw_seekbar_nibbles(element, elem_ass)
    local slider_lo = element.layout.slider
    local elem_geo = element.layout.geometry

    if element.slider.markerF == nil or slider_lo.gap <= 0 then
        return
    end

    if slider_lo.nibbles_style == "gap" and element.name == "seekbar" then
        local radius = slider_lo.radius
        local bg_alpha = 128
        elem_ass:draw_stop()
        elem_ass:merge(element.style_ass)
        ass_append_alpha(elem_ass, element.layout.alpha, bg_alpha)
        elem_ass:append("{\\blur0\\bord0\\1c&H" .. osc_color_convert(user_opts.seekbarbg_color) .. "&}")
        elem_ass:merge(element.static_ass)
        draw_gap_segments(elem_ass, element, 1.5, elem_geo.w, slider_lo, elem_geo, radius)
        return
    end

    local markers = element.slider.markerF()

    if #markers == 0 then return end
    local current_chapter = state.chapter or -1

    -- draw a single nibble at position s
    local function draw_nibble(ass, s)
        if slider_lo.gap >= 5 then
            local bar_h = 3
            if slider_lo.nibbles_top then
                if slider_lo.nibbles_style == "triangle" then
                    ass:move_to(s - 3, slider_lo.gap - 5)
                    ass:line_to(s + 3, slider_lo.gap - 5)
                    ass:line_to(s, slider_lo.gap - 1)
                elseif slider_lo.nibbles_style == "bar" then
                    ass:rect_cw(s - 1, slider_lo.gap - bar_h, s + 1, slider_lo.gap)
                else
                    ass:rect_cw(s - 1, slider_lo.gap - bar_h, s + 1, elem_geo.h - slider_lo.gap)
                end
            end
            if slider_lo.nibbles_bottom then
                if slider_lo.nibbles_style == "triangle" then
                    ass:move_to(s - 3, elem_geo.h - slider_lo.gap + 5)
                    ass:line_to(s, elem_geo.h - slider_lo.gap + 1)
                    ass:line_to(s + 3, elem_geo.h - slider_lo.gap + 5)
                elseif slider_lo.nibbles_style == "bar" then
                    ass:rect_cw(s - 1, elem_geo.h - slider_lo.gap, s + 1, elem_geo.h - slider_lo.gap + bar_h)
                else
                    ass:rect_cw(s - 1, slider_lo.gap, s + 1, elem_geo.h - slider_lo.gap + bar_h)
                end
            end
        else
            if slider_lo.nibbles_top then
                ass:rect_cw(s - 1, 0, s + 1, slider_lo.gap)
            end
            if slider_lo.nibbles_bottom then
                ass:rect_cw(s - 1, elem_geo.h - slider_lo.gap, s + 1, elem_geo.h)
            end
        end
    end

    -- draw non-current chapter nibbles
    local has_non_current = false
    for n, marker in ipairs(markers) do
        if is_drawn_marker(n, marker) and (n - 1) ~= current_chapter and marker >= element.slider.min.value and marker <= element.slider.max.value then
            if not has_non_current then
                begin_draw_layer(element, elem_ass, user_opts.nibble_color)
                has_non_current = true
            end
            draw_nibble(elem_ass, get_slider_ele_pos_for(element, marker))
        end
    end

    -- draw current chapter nibble on top
    if current_chapter >= 0 and current_chapter < #markers then
        local marker = markers[current_chapter + 1]
        if is_drawn_marker(current_chapter + 1, marker) and marker >= element.slider.min.value and marker <= element.slider.max.value then
            begin_draw_layer(element, elem_ass, user_opts.nibble_current_color)
            draw_nibble(elem_ass, get_slider_ele_pos_for(element, marker))
        end
    end
end

-- Draw seekbar progress more accurately
local function draw_seekbar_progress(element, elem_ass)
    local pos = element.slider.posF()
    if not pos then
        return
    end
    local xp = get_slider_ele_pos_for(element, pos)
    local slider_lo = element.layout.slider
    local elem_geo = element.layout.geometry
    local radius = slider_lo.radius

    if slider_lo.nibbles_style == "gap" and element.name == "seekbar" then
        draw_gap_segments(elem_ass, element, 1.5, xp, slider_lo, elem_geo, radius)
    else
        elem_ass:round_rect_cw(0, slider_lo.gap, xp, elem_geo.h - slider_lo.gap, radius)
    end
end

local function render_elements(master_ass, osc_vis, wc_vis)
    -- each element is drawn on its own and all are joined once at the end: assdraw
    -- copies its whole text on every append, which adds up on a long text
    local parts = {}
    local function render_element(n)
        local element = elements[n]

        -- skip elements whose group is not currently visible
        local is_top = element.layout.group == "top"
        if (is_top and not wc_vis) or (not is_top and not osc_vis) then return end

        -- use wc animation for top group elements
        -- use 0 to block fallback to state.animation when wc has no active animation
        local anim_override = nil
        if is_top then
            anim_override = state.wc_animation or 0
        end

        local style_ass = assdraw.ass_new()
        style_ass:merge(element.style_ass)
        ass_append_alpha(style_ass, element.layout.alpha, 0, nil, anim_override)

        if element.eventresponder and (state.active_element == n) then
            -- run render event functions
            if element.eventresponder.render ~= nil then
                element.eventresponder.render(element)
            end
            if mouse_hit(element) then
                -- mouse down styling
                if element.styledown then
                    local down_style = osc_styles.element_down
                    if element.name == "title" or element.name == "chapter_title" or element.name == "time_codes" or element.name == "speed" or element.name == "cache_info" or element.name == "time_pos" or element.name == "time_end" then
                        down_style = down_style:gsub("\\fscx%d+\\fscy%d+", "")
                    end
                    style_ass:append(down_style)
                end
                if element.softrepeat and state.mouse_down_counter >= 15 and state.mouse_down_counter % 5 == 0 then
                    element.eventresponder[state.active_event_source.."_down"](element)
                end
                state.mouse_down_counter = state.mouse_down_counter + 1
            end
        end

        local elem_ass = assdraw.ass_new()

        -- Hover background box
        if element.type == "button" and hover_effects.box
            and element.name ~= "title"
            and element.name ~= "chapter_title"
            and element.name ~= "time_codes"
            and element.name ~= "time_pos"
            and element.name ~= "time_end"
            and element.name ~= "cache_info" then
            local is_clickable = element.eventresponder and (
                element.eventresponder["mbtn_left_down"] ~= nil or
                element.eventresponder["mbtn_left_up"] ~= nil
            )
            local hb = element.hover_box
            local hovering = (hb and mouse_hit_coords(hb.x1, hb.y1, hb.x2, hb.y2) or mouse_hit(element)) and is_clickable and element.enabled
            -- on glass the highlight springs open from the middle of the button, swells a
            -- touch while held, and fades away when the pointer leaves
            local now = mp.get_time()
            local grow, fade_in = 1, 0
            if state.glass_ui then
                if hovering then
                    element.state.hover_t = element.state.hover_t or now
                    element.state.hover_out = nil
                    local t = now - element.state.hover_t
                    if glass_look.motion then
                        grow = 0.9 + 0.1 * spring(t) + (state.mouse_down_counter > 0 and 0.04 or 0)
                        if t < 0.6 then request_tick() end
                    end
                    fade_in = math.floor(255 * (1 - ease_out(t / 0.1)) + 0.5)
                    if t < 0.1 then request_tick() end
                elseif element.state.hover_t then
                    element.state.hover_t = nil
                    element.state.hover_out = now
                end
                local out = element.state.hover_out
                if out then
                    local p = (now - out) / 0.14
                    if p >= 1 or not is_clickable or not element.enabled then
                        element.state.hover_out = nil
                    else
                        fade_in = math.floor(255 * p * p + 0.5)
                        request_tick()
                    end
                end
            end
            if hovering or element.state.hover_out then
                local hx1, hy1, hx2, hy2
                if hb then hx1, hy1, hx2, hy2 = hb.x1, hb.y1, hb.x2, hb.y2
                else hx1, hy1, hx2, hy2 = get_element_hitbox(element) end
                local pad = element.hover_pad ~= nil and element.hover_pad or 6
                local held = hovering and state.mouse_down_counter > 0
                local hover_base_alpha = held and (255 - math.floor(math.max(0, math.min(100, user_opts.button_held_box_alpha)) * 2.55)) or (element.hover_alpha or 0xE6)
                local hover_radius = element.hover_radius ~= nil and element.hover_radius or 4
                local mx_, my_ = (hx1 + hx2) / 2, (hy1 + hy2) / 2
                local hw, hh = (hx2 - hx1) / 2 + pad, (hy2 - hy1) / 2 + pad
                hw, hh = hw * grow, hh * grow
                elem_ass:append("{}")
                elem_ass:new_event()
                elem_ass:pos(0, 0)
                elem_ass:an(7)
                ass_append_alpha(elem_ass, {[1] = mult_alpha(hover_base_alpha, fade_in), [2] = 255, [3] = 255, [4] = 255}, element.layout.alpha[1], nil, anim_override)
                local hover_style = element.hover_color
                    and "{\\blur0\\bord0\\1c&H" .. osc_color_convert(element.hover_color) .. "&}"
                    or osc_styles.hover_bg
                elem_ass:append(hover_style)
                elem_ass:draw_start()
                elem_ass:round_rect_cw(mx_ - hw, my_ - hh, mx_ + hw, my_ + hh, math.min(hover_radius * grow, hw, hh))
                elem_ass:draw_stop()
            end
        end

        elem_ass:merge(style_ass)

        if element.type ~= "button" then
            elem_ass:merge(element.static_ass)
        end

        if element.type == "slider" then
            if element.name ~= "persistent_seekbar" then
                local slider_lo = element.layout.slider
                local elem_geo = element.layout.geometry
                local s_min = element.slider.min.value
                local s_max = element.slider.max.value

                draw_seekbar_nibbles(element, elem_ass)

                -- reset context so handle/progress render on top of nibbles
                elem_ass:draw_stop()
                elem_ass:merge(element.style_ass)
                ass_append_alpha(elem_ass, element.layout.alpha, 0, nil, anim_override)
                elem_ass:merge(element.static_ass)

                local handle_x, handle_radius, is_active = get_seekbar_handle_pos(element) -- get handle position/radius
                draw_seekbar_progress(element, elem_ass)
                draw_seekbar_ranges(element, elem_ass, handle_x, handle_radius)
                draw_ab_loop_range(element, elem_ass)
                draw_seekbar_handle(element, elem_ass, handle_x, handle_radius, anim_override, is_active) -- draw handle on top of progress

                elem_ass:draw_stop()

                if element.slider and element.slider.tooltipF ~= nil and element.enabled then
                    local force_seek_tooltip = user_opts.force_seek_tooltip
                        and element.name == "seekbar"
                        and element.eventresponder["mbtn_left_down"]
                        and element.state.mbtnleft
                        and state.mouse_down_counter > 0
                        and state.playing_and_seeking

                    if mouse_hit(element) or force_seek_tooltip then
                        local sliderpos = get_slider_value(element)
                        local tooltiplabel = element.slider.tooltipF(sliderpos)
                        local an = slider_lo.tooltip_an
                        local ty
                        if an == 2 then
                            local seekbar = state.seekbar_element
                            local ref_el = (element.name == "volumebar" and seekbar and seekbar.hitbox) and seekbar or element
                            local image_mode_offset = (ref_el == element) and 10 or 0
                            local anchor_offset = (ref_el == element) and (elem_geo.h / 2) or 0
                            ty = ref_el.hitbox.y1 + anchor_offset - user_opts.tooltip_height_offset - image_mode_offset
                        else
                            ty = element.hitbox.y1 + elem_geo.h / 2 - user_opts.tooltip_height_offset
                        end
                        -- floating panel: tooltips and thumbnails sit just above the panel
                        if an == 2 and state.tooltip_y then ty = state.tooltip_y end

                        local tx = get_virt_mouse_pos()
                        local osd_w = frame_number("osd-width")
                        local r_w, r_h = get_virt_scale_factor()

                        local tooltip_width = estimate_text_width(tooltiplabel, slider_lo.tooltip_style)

                        local chapter_text = nil
                        local chapter_width = 0

                        if osd_w and r_w > 0 then
                            -- Only attempt to fetch and measure chapter logic if this is the seekbar
                            if element.name == "seekbar" and user_opts.chapter_fmt ~= "no" then
                                local dur = state.duration or 0
                                if dur > 0 then
                                    local ch = get_chapter(sliderpos * dur / 100)
                                    if ch and ch.title and ch.title ~= "" then
                                        chapter_text = string.format(user_opts.chapter_fmt, ch.title)
                                        chapter_width = estimate_text_width(chapter_text, slider_lo.tooltip_style)
                                    end
                                end
                            end

                            -- Clamping layer ensures horizontal boundaries are strictly respected
                            if slider_lo.adjust_tooltip or (element.thumbnailable and not thumbz.disabled) then
                                local max_text_width = math.max(tooltip_width, chapter_width)
                                local margin = 10 * r_w
                                local half_width = max_text_width / 2
                                local min_x = margin + half_width
                                local max_x = osc_param.playresx - margin - half_width
                                tx = math.min(max_x, math.max(min_x, tx))
                            end
                        end

                        if element.name == "seekbar" then
                            state.sliderpos = sliderpos
                        end

                        local tooltip_fs = user_opts.tooltip_font_size
                        local pad_v = 3
                        local gap = 5

                        -- Anchor above tooltip: ty (baseline) - fs (height) - pad_v (tooltip padding) - gap
                        local current_y = ty - tooltip_fs - pad_v - gap

                        -- Thumbfast logic
                        if element.thumbnailable and not thumbz.disabled and osd_w then
                            local thumb_pad = user_opts.thumbnail_box_padding
                            local thumb_radius = user_opts.thumbnail_box_radius > 0 and user_opts.thumbnail_box_radius or 0

                            local hover_sec = 0
                            if state.duration then hover_sec = state.duration * sliderpos / 100 end

                            local margin_x = 18 / r_w
                            local thumb_x = math.min(osd_w - thumbz.width - margin_x, math.max(margin_x, tx / r_w - thumbz.width / 2))
                            thumb_x = math.floor(thumb_x + 0.5)

                            local thumb_y_px = current_y - (thumb_pad * r_h) - (thumbz.height * r_h)

                            if state.anitype == nil then
                                -- the preview is content, not glass: a plain frame, a hairline and a soft shadow
                                glass_rect(elem_ass, (thumb_x - thumb_pad) * r_w, thumb_y_px - thumb_pad * r_h,
                                    (thumbz.width + 2 * thumb_pad) * r_w, (thumbz.height + 2 * thumb_pad) * r_h, thumb_radius,
                                    {color = user_opts.thumbnail_box_color, fill_alpha = 0,
                                     edge_alpha = opacity_alpha(18), rim = false,
                                     shadow_blur = 16, shadow_y = 6, shadow_alpha = 0xA0})

                                thumbz_hover(hover_sec, thumb_x, math.floor(thumb_y_px / r_h + 0.5))
                            end

                            -- Keep tooltips anchored to the thumbnail center even at window edges
                            tx = (thumb_x + thumbz.width / 2) * r_w
                            an = 2

                            -- Advance anchor above the thumbnail
                            current_y = thumb_y_px - (thumb_pad * r_h) - gap
                        end

                        if chapter_text and r_w > 0 then
                            local chapter_y = current_y - pad_v
                            draw_tooltip(elem_ass, tx, chapter_y, chapter_width, slider_lo.tooltip_style, chapter_text, slider_lo.alpha)
                        end

                        draw_tooltip(elem_ass, tx, ty, tooltip_width, slider_lo.tooltip_style, tooltiplabel, slider_lo.alpha)
                    elseif element.thumbnailable then
                        thumbz_hide()
                    end
                end
            end
        elseif element.type == "button" then
            local buttontext
            if type(element.content) == "function" then
                buttontext = element.content() -- function objects
            elseif element.content ~= nil then
                buttontext = element.content -- text objects
            end
            buttontext = render_icons(buttontext, element.layout.style)
            -- glass: the hovered icon lifts a little toward the pointer
            if state.glass_ui and glass_look.motion and state.mouse_down_counter == 0 then
                local lift = 0
                if element.state.hover_t then
                    lift = 6 * spring(mp.get_time() - element.state.hover_t)
                elseif element.state.hover_out then
                    lift = 6 * (1 - ease_out((mp.get_time() - element.state.hover_out) / 0.14))
                end
                if lift > 0.05 then
                    buttontext = string.format("{\\fscx%.1f\\fscy%.1f}", 100 + lift, 100 + lift) .. buttontext
                end
            end

            -- add hover effects
            local button_lo = element.layout.button
            local is_clickable = element.eventresponder and (element.eventresponder["mbtn_left_down"] ~= nil or element.eventresponder["mbtn_left_up"] ~= nil)
            local hovered = mouse_hit(element) and is_clickable and element.enabled and state.mouse_down_counter == 0
            local hoverstyle = button_lo.hoverstyle
            if hovered and (hover_effects.size or hover_effects.color) then
                -- remove font scale tags for these elements, it looks out of place
                if element.name == "title" or element.name == "time_codes" or element.name == "chapter_title" or element.name == "cache_info" or element.name == "speed" or element.name == "time_pos" or element.name == "time_end" then
                    hoverstyle = hoverstyle:gsub("\\fscx%d+\\fscy%d+", "")
                end
                elem_ass:append(hoverstyle .. buttontext)
            else
                elem_ass:append(buttontext)
            end

            -- apply blur effect if "glow" is in hover effects
            if hovered and hover_effects.glow then
                local shadow_ass = assdraw.ass_new()
                shadow_ass:merge(style_ass)
                shadow_ass:append("{\\blur" .. user_opts.button_glow_amount .. "}" .. hoverstyle .. buttontext)
                elem_ass:merge(shadow_ass)
            end

            -- add tooltip for button elements
            local seeking_with_force_tooltip = user_opts.force_seek_tooltip and state.mouse_down_counter > 0 and state.playing_and_seeking

            if element.tooltipF ~= nil and element.enabled and not seeking_with_force_tooltip and user_opts.tooltip_hints and not state.menu_open then
                local hb = element.hover_box
                if (hb and mouse_hit_coords(hb.x1, hb.y1, hb.x2, hb.y2) or mouse_hit(element)) then
                    local tooltiplabel

                    -- tooltip label
                    if element.enabled then
                        if type(element.tooltipF) == "function" then
                            tooltiplabel = element.tooltipF()
                        else
                            tooltiplabel = element.tooltipF
                        end
                    else
                        tooltiplabel = element.nothingavailable
                    end

                    local tx = hb and (hb.x1 + hb.x2) / 2 or (element.hitbox.x1 + element.hitbox.x2) / 2
                    local seekbar_ref = (state.seekbar_element and state.seekbar_element.hitbox) and state.seekbar_element or element
                    local image_mode_offset = (seekbar_ref == element) and 10 or 0
                    local ty = state.tooltip_y or (seekbar_ref.hitbox.y1 - user_opts.tooltip_height_offset - image_mode_offset)

                    local osd_w = frame_number("osd-width")
                    local r_w = get_virt_scale_factor()
                    local tooltip_width = estimate_text_width(tooltiplabel, element.tooltip_style)
                    if osd_w and r_w > 0 then
                        local margin = 10 * r_w
                        tx = math.min(osc_param.playresx - margin - tooltip_width / 2, math.max(margin + tooltip_width / 2, tx))
                    end

                    if tooltiplabel then
                        draw_tooltip(elem_ass, tx, ty, tooltip_width, element.tooltip_style, bidi.fsi .. tooltiplabel .. bidi.pdi)
                    end
                end
            end
        end

        parts[#parts + 1] = elem_ass.text
    end

    for n = 1, #elements do render_element(n) end
    master_ass.text = master_ass.text .. table.concat(parts)
end

local function render_persistent_progress(master_ass)
    local element = state.persistent_seekbar_element
    if not element or not element.layout then return end
    local style_ass = assdraw.ass_new()
    style_ass:merge(element.style_ass)
    if state.animation or not state.osc_visible then
        ass_append_alpha(style_ass, element.layout.alpha, 0, true)

        local elem_ass = assdraw.ass_new()
        elem_ass:merge(style_ass)
        elem_ass:merge(element.static_ass)

        -- draw pos marker
        local pos = element.slider.posF and element.slider.posF()
        local xp = pos and get_slider_ele_pos_for(element, pos) or 0

        draw_seekbar_progress(element, elem_ass)

        if user_opts.persistent_buffer then
            draw_seekbar_ranges(element, elem_ass, xp, 0, nil, true)
        end

        elem_ass:draw_stop()
        master_ass:merge(elem_ass)
    end
end

--
-- Menus: track, playlist, chapter, speed and audio output lists, and the "more" menu,
-- as glass popups that grow out of their button instead of mpv's select lists
--

local menu = nil          -- the open menu: {kind, title, items, anchor, scroll, hover, pressed, back, t0, geo}
local menu_closing = nil  -- a menu fading away after it was closed
local menu_frame = 0      -- bumped once per render, so a menu's geometry is worked out once per frame
local close_menu, open_menu, render_menu, menu_event, menu_visual_rect, menu_covers_sync, menu_cover_ready
do -- (in a block: the main chunk is close to Lua's limit of 200 locals)

local MENU = {row_h = 32, sep_h = 9, header_h = 32, pad = 6, radius = 16, fs = 14, meta_fs = 12.5, title_fs = 12.5, glyph = 16, icon = 18}

local lang_names = {
    en = "English", eng = "English", ja = "Japanese", jpn = "Japanese", es = "Spanish", spa = "Spanish",
    fr = "French", fre = "French", fra = "French", de = "German", ger = "German", deu = "German",
    it = "Italian", ita = "Italian", pt = "Portuguese", por = "Portuguese", ru = "Russian", rus = "Russian",
    zh = "Chinese", chi = "Chinese", zho = "Chinese", ko = "Korean", kor = "Korean", ar = "Arabic", ara = "Arabic",
    hi = "Hindi", hin = "Hindi", nl = "Dutch", dut = "Dutch", nld = "Dutch", sv = "Swedish", swe = "Swedish",
    no = "Norwegian", nor = "Norwegian", da = "Danish", dan = "Danish", fi = "Finnish", fin = "Finnish",
    pl = "Polish", pol = "Polish", tr = "Turkish", tur = "Turkish", el = "Greek", gre = "Greek", ell = "Greek",
    he = "Hebrew", heb = "Hebrew", th = "Thai", tha = "Thai", vi = "Vietnamese", vie = "Vietnamese",
    id = "Indonesian", ind = "Indonesian", ms = "Malay", may = "Malay", msa = "Malay", uk = "Ukrainian",
    ukr = "Ukrainian", cs = "Czech", cze = "Czech", ces = "Czech", hu = "Hungarian", hun = "Hungarian",
    ro = "Romanian", rum = "Romanian", ron = "Romanian", fa = "Persian", per = "Persian", fas = "Persian",
    bn = "Bengali", ben = "Bengali", ta = "Tamil", tam = "Tamil", te = "Telugu", tel = "Telugu",
    tl = "Tagalog", tgl = "Tagalog", fil = "Filipino", ca = "Catalan", cat = "Catalan",
}

local codec_names = {
    eac3 = "E-AC-3", ac3 = "AC-3", aac = "AAC", opus = "Opus", flac = "FLAC", truehd = "TrueHD", dts = "DTS",
    mp3 = "MP3", vorbis = "Vorbis", alac = "ALAC", mp2 = "MP2", pcm_s16le = "PCM", pcm_s24le = "PCM",
    ass = "ASS", ssa = "SSA", subrip = "SRT", srt = "SRT", hdmv_pgs_subtitle = "PGS", pgssub = "PGS",
    webvtt = "WebVTT", dvd_subtitle = "VobSub", dvdsub = "VobSub", mov_text = "Text", text = "Text",
}

local function lang_name(code)
    if not code or code == "" then return nil end
    return lang_names[code:lower()] or code:upper()
end

local function channel_name(n)
    if not n or n <= 0 then return nil end
    return ({"Mono", "Stereo", "3.0", "4.0", "5.0", "5.1", "6.1", "7.1"})[n] or (n .. " ch")
end

local function plain_time(sec)
    sec = math.max(0, math.floor(sec or 0))
    local h, m, s = math.floor(sec / 3600), math.floor(sec / 60) % 60, sec % 60
    return h > 0 and string.format("%d:%02d:%02d", h, m, s) or string.format("%d:%02d", m, s)
end

local function esc(text)
    return mp.command_native({"escape-ass", tostring(text or "")})
end

local function speed_label(v)
    if math.abs(v - 1) < 0.001 then return locale.normal end
    return (string.format("%.2f", v):gsub("0+$", ""):gsub("%.$", "")) .. "×"
end

-- glyph name inside an icon marker ("\1name\2")
local function glyph_of(marker)
    return marker and marker:sub(2, -2) or nil
end

local SPEEDS = {0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2}

-- Folders: the videos next to the playing file, and a browser for other folders
local function ext_set(list)
    local set = {}
    for ext in list:gmatch("%w+") do set[ext] = true end
    return set
end
local MEDIA_EXTS = {
    video = ext_set("mkv mp4 m4v avi mov webm wmv flv ts m2ts mts mpg mpeg vob ogv 3gp rmvb asf f4v divx y4m"),
    audio = ext_set("mp3 flac m4a aac ogg oga opus wav wv ape aiff aif wma mka dsf dff"),
    image = ext_set("jpg jpeg png webp gif bmp tif tiff avif heic heif jxl"),
}

local function ext_of(name)
    return (name:match("%.([^%.]+)$") or ""):lower()
end

-- "Episode 2" before "Episode 10": runs of digits compare as numbers
local function natural_sort(names)
    local keys = {}
    for _, n in ipairs(names) do
        keys[n] = n:lower():gsub("%d+", function(d) return ("0"):rep(math.max(0, 12 - #d)) .. d end)
    end
    table.sort(names, function(a, b)
        if keys[a] ~= keys[b] then return keys[a] < keys[b] end
        return a < b
    end)
    return names
end

local function same_path(a, b)
    local function norm(p)
        p = p:gsub("\\", "/"):gsub("/+", "/")
        return platform == "windows" and p:lower() or p
    end
    return norm(a) == norm(b)
end

-- the playing file as an absolute local path, with its folder; nil for streams
local function current_file()
    local path = mp.get_property("path")
    if not path or path:find("^%a[%w+.-]*://") then return nil end
    path = utils.join_path(mp.get_property("working-directory", ""), path)
    local dir = utils.split_path(path)
    return path, dir
end

-- folders list files like the playing one: videos, music or pictures
local function media_kind()
    local path = current_file()
    local ext = path and ext_of(path) or ""
    if MEDIA_EXTS.audio[ext] then return "audio" end
    if MEDIA_EXTS.image[ext] then return "image" end
    return "video"
end

local function dir_name(dir)
    local trimmed = dir:gsub("[/\\]+$", "")
    return trimmed:match("[^/\\]+$") or dir
end

local function parent_dir(dir)
    local trimmed = dir:gsub("[/\\]+$", "")
    if trimmed == "" or trimmed:match("^%a:$") then return nil end  -- "/" or a drive
    local parent = utils.split_path(trimmed)
    if parent == "" or parent == "./" or same_path(parent, dir) then return nil end
    return parent
end

local function list_media(dir, kind)
    local exts = MEDIA_EXTS[kind]
    local out = {}
    for _, f in ipairs(utils.readdir(dir, "files") or {}) do
        if f:sub(1, 1) ~= "." and exts[ext_of(f)] then out[#out + 1] = f end
    end
    return natural_sort(out)
end

local function list_folders(dir)
    local out = {}
    for _, d in ipairs(utils.readdir(dir, "dirs") or {}) do
        if not d:find("^[.$]") and d ~= "System Volume Information" then out[#out + 1] = d end
    end
    return natural_sort(out)
end

-- make the folder the playlist, in order, and play one of its files (the playing
-- file keeps playing when it is the one picked)
local function play_folder(dir, files, index)
    local target = utils.join_path(dir, files[index])
    local path = current_file()
    if path and same_path(path, target) then
        mp.commandv("playlist-clear")
    else
        mp.commandv("loadfile", target, "replace")
    end
    for i = 1, index - 1 do
        mp.commandv("loadfile", utils.join_path(dir, files[i]), "insert-at", tostring(i - 1))
    end
    for i = index + 1, #files do
        mp.commandv("loadfile", utils.join_path(dir, files[i]), "append")
    end
end

local function strip_ext(name)
    return (name:gsub("%.[%w]+$", ""))
end

-- Covers: a small still beside each video in the folder and playlist menus. thumbz makes
-- them (once per file, kept on disk); they're shown with overlay-add, since ASS can't
-- draw pictures, while the menu stands still, over a tile that moves with the menu.
local COVER_W, COVER_H, COVER_R = 60, 33.75, 6  -- in layout units (the pictures are 160x90)
local COVER_X, COVER_GAP = 6, 12                -- inset from the row's edge, gap to the name
local COVER_ROW_H = 46
local COVER_SLOT0, COVER_SLOTS = 50, 14         -- overlay ids (thumbz's seekbar one is 42)
local cover_files = {}                          -- path -> picture, or false (none possible)
local cover_asked = {}
local cover_want, cover_shown = {}, {}          -- overlay id -> {file, x, y, w, h}

local function covers_on()
    return user_opts.playlist_thumbnails and thumbz.present and media_kind() ~= "audio"
end

menu_cover_ready = function(path, file)
    cover_files[path] = file ~= "" and file or false
    if menu then request_tick() end
end

menu_covers_sync = function()
    local d = state.osd_dimensions or {}
    local sx, sy = (d.w or 0) / osc_param.playresx, (d.h or 0) / osc_param.playresy
    for id = COVER_SLOT0, COVER_SLOT0 + COVER_SLOTS - 1 do
        local want, shown = cover_want[id], cover_shown[id]
        if want and sx > 0 then
            local x, y = math.floor(want.x * sx + 0.5), math.floor(want.y * sy + 0.5)
            local w, h = math.floor(COVER_W * sx + 0.5), math.floor(COVER_H * sy + 0.5)
            if not shown or shown.file ~= want.file or shown.x ~= x or shown.y ~= y or shown.w ~= w or shown.h ~= h then
                mp.command_native_async({"overlay-add", id, x, y, want.file, 0, "bgra", 160, 90, 640, w, h}, function() end)
                cover_shown[id] = {file = want.file, x = x, y = y, w = w, h = h}
            end
        elseif shown then
            mp.command_native_async({"overlay-remove", id}, function() end)
            cover_shown[id] = nil
        end
    end
    cover_want = {}
end

-- title, items, header; an item: {label, meta, active, action, icon, submenu, arg (for
-- the submenu), sep (line above)}; header: a link on the title row {label, submenu, arg}
local function menu_items(kind, arg)
    local items, title, header = {}, nil, nil
    local path, dir = current_file()
    local with_covers = covers_on()
    if kind == "playlist" and dir and (state.playlist_count or 0) <= 1 then
        kind, arg = "folder", dir  -- a single file: the videos in its folder
    end
    if kind == "audio" or kind == "sub" then
        title = kind == "audio" and locale.audio or locale.subtitles
        if kind == "sub" then
            local sid = mp.get_property("sid")
            items[#items + 1] = {label = locale.off, active = sid == "no" or sid == nil or sid == "",
                                 action = function() mp.commandv("set", "sid", "no") end}
        end
        for _, t in ipairs(mp.get_property_native("track-list") or {}) do
            if t.type == kind then
                local lang = lang_name(t.lang)
                local label = t.title or lang or (locale.track .. " " .. t.id)
                local meta = {}
                if t.title and lang then meta[#meta + 1] = lang end
                if t.codec then meta[#meta + 1] = codec_names[t.codec] or t.codec:upper() end
                if kind == "audio" then meta[#meta + 1] = channel_name(t["demux-channel-count"]) end
                if t.forced then meta[#meta + 1] = locale.forced end
                if t.external then meta[#meta + 1] = locale.external end
                local active = t.selected
                if kind == "sub" and t["main-selection"] ~= nil then active = t.selected and t["main-selection"] == 0 end
                local id = t.id
                items[#items + 1] = {label = label, meta = table.concat(meta, " · "), active = active,
                    sep = kind == "sub" and #items == 1,
                    action = function() mp.commandv("set", kind == "audio" and "aid" or "sid", tostring(id)) end}
            end
        end
    elseif kind == "playlist" then
        title = locale.playlist
        local entries = mp.get_property_native("playlist") or {}
        local one_dir = dir ~= nil
        local cwd = mp.get_property("working-directory", "")
        for i, entry in ipairs(entries) do
            local name = entry.title
            if not name or name == "" then
                name = (entry.filename or ""):gsub("[/\\]+$", ""):match("[^/\\]+$") or entry.filename or ""
                if not name:find("^%a+://") then name = strip_ext(name) end
            end
            -- a playlist of one folder is titled with the folder's name
            if one_dir then
                local f = utils.join_path(cwd, entry.filename or "")
                one_dir = not f:find("^%a[%w+.-]*://") and same_path(utils.split_path(f), dir)
            end
            local file = entry.filename and not entry.filename:find("^%a[%w+.-]*://")
                and utils.join_path(cwd, entry.filename) or nil
            local active = entry.current or entry.playing
            -- beside thumbnails, the playing one says so instead of numbers and a check
            local meta = tostring(i)
            if with_covers and file then meta = active and locale.playing or nil end
            items[#items + 1] = {label = name, active = active, cover = with_covers and file or nil, meta = meta,
                action = function() mp.commandv("playlist-play-index", tostring(i - 1)) end}
        end
        if one_dir then title = dir_name(dir) end
        if dir then header = {label = locale.browse_folders, submenu = "browse", arg = dir} end
    elseif kind == "folder" then
        -- the videos in the playing file's folder, in order
        title = dir_name(arg)
        local files = list_media(arg, media_kind())
        for i, f in ipairs(files) do
            local active = path ~= nil and same_path(path, utils.join_path(arg, f))
            local meta = tostring(i)
            if with_covers then meta = active and locale.playing or nil end
            items[#items + 1] = {label = strip_ext(f), active = active, meta = meta,
                cover = with_covers and utils.join_path(arg, f) or nil,
                action = function() play_folder(arg, files, i) end}
        end
        local up = parent_dir(arg)
        if up then header = {label = locale.other_folders, submenu = "browse", arg = up} end
    elseif kind == "browse" then
        -- a folder: up a level, its folders, then its videos
        title = dir_name(arg)
        local up = parent_dir(arg)
        if up then
            items[#items + 1] = {icon = "menu_folder_up", label = locale.up_one_level, submenu = "browse", arg = up}
        end
        for _, d in ipairs(list_folders(arg)) do
            local sub = utils.join_path(arg, d)
            items[#items + 1] = {icon = "menu_folder", label = d, submenu = "browse", arg = sub,
                meta = dir and same_path(sub, (dir:gsub("[/\\]+$", ""))) and locale.playing or nil}
        end
        local files = list_media(arg, media_kind())
        for i, f in ipairs(files) do
            local active = path ~= nil and same_path(path, utils.join_path(arg, f))
            items[#items + 1] = {icon = not with_covers and "menu_video" or nil, label = strip_ext(f), sep = i == 1 and #items > 0,
                active = active, meta = with_covers and active and locale.playing or nil,
                cover = with_covers and utils.join_path(arg, f) or nil,
                action = function() play_folder(arg, files, i) end}
        end
        if #items == 0 then
            items[1] = {label = locale.nothing_here}
        end
    elseif kind == "chapter" then
        title = locale.chapters
        local current = mp.get_property_number("chapter", -1)
        for i, ch in ipairs(mp.get_property_native("chapter-list") or {}) do
            items[#items + 1] = {label = (ch.title and ch.title ~= "") and ch.title or (locale.chapter .. " " .. i),
                meta = plain_time(ch.time), active = (i - 1) == current,
                action = function() mp.commandv("set", "chapter", tostring(i - 1)) end}
        end
    elseif kind == "audio-device" then
        title = locale.audio_output
        local current = mp.get_property("audio-device")
        for _, dev in ipairs(mp.get_property_native("audio-device-list") or {}) do
            local name = dev.name
            items[#items + 1] = {label = dev.description or name, active = name == current,
                action = function() mp.commandv("set", "audio-device", name) end}
        end
    elseif kind == "speed" then
        title = locale.speed_control
        local current = mp.get_property_number("speed", 1)
        for _, v in ipairs(SPEEDS) do
            items[#items + 1] = {label = speed_label(v), active = math.abs(current - v) < 0.001,
                action = function() mp.commandv("set", "speed", tostring(v)) end}
        end
    elseif kind == "more" then
        local function add(item) items[#items + 1] = item end
        if user_opts.speed_button then
            add({icon = glyph_of(icons.speed), label = locale.speed_control, submenu = "speed",
                 meta = speed_label(mp.get_property_number("speed", 1))})
        end
        local chapters = mp.get_property_native("chapter-list") or {}
        if #chapters > 0 then
            local ch = mp.get_property_number("chapter", -1)
            add({icon = glyph_of(icons.chapters), label = locale.chapters, submenu = "chapter",
                 meta = ch >= 0 and string.format("%d / %d", ch + 1, #chapters) or nil})
        end
        if #(mp.get_property_native("audio-device-list") or {}) > 1 then
            add({icon = glyph_of(icons.volume_high), label = locale.audio_output, submenu = "audio-device"})
        end
        local first = true
        local function toggle(item)
            item.sep = first and #items > 0
            first = false
            add(item)
        end
        if user_opts.loop_button then
            local loop = mp.get_property("loop-file") ~= "no"
            toggle({icon = glyph_of(icons.loop_on), label = locale.loop, active = loop,
                    action = function() mp.command(user_opts.file_loop_mbtn_left_command) end})
        end
        if user_opts.shuffle_button and (state.playlist_count or 0) > 1 then
            toggle({icon = glyph_of(icons.shuffle_on), label = locale.shuffle_menu,
                    action = function() mp.command(user_opts.shuffle_mbtn_left_command) end})
        end
        if user_opts.ontop_button then
            toggle({icon = glyph_of(icons.ontop_on), label = locale.keep_on_top, active = state.ontop,
                    action = function() mp.command(user_opts.ontop_mbtn_left_command) end})
        end
        first = true
        if user_opts.screenshot_button then
            toggle({icon = glyph_of(icons.screenshot), label = locale.screenshot,
                    action = function() glass_blur.screenshot(user_opts.screenshot_mbtn_left_command) end})
        end
        if user_opts.info_button then
            toggle({icon = glyph_of(icons.info), label = locale.stats_info,
                    action = function() mp.command(user_opts.info_mbtn_left_command) end})
        end
    end
    return title, items, header
end


local function menu_activate(index)
    if not menu then return end
    if index == 0 and menu.back then
        -- back to the view this one was opened from, where it was scrolled to
        local stack = {}
        for i = 1, #menu.stack - 1 do stack[i] = menu.stack[i] end
        local prev = menu.stack[#menu.stack]
        open_menu(prev.kind, menu.anchor, {from_back = true, arg = prev.arg, scroll = prev.scroll, stack = stack})
        return
    end
    local item = index == 0 and menu.header or menu.items[index]
    if not item then return end
    if item.submenu then
        local stack = {}
        for i, v in ipairs(menu.stack) do stack[i] = v end
        stack[#stack + 1] = {kind = menu.kind, arg = menu.arg, scroll = menu.scroll}
        open_menu(item.submenu, menu.anchor, {back = true, arg = item.arg, stack = stack})
        return
    end
    close_menu()
    if item.action then item.action() end
end

local function menu_move(step)
    if not menu then return end
    local first = (menu.back or menu.header) and 0 or 1
    local i = (menu.hover or (step > 0 and first - 1 or #menu.items + 1)) + step
    menu.hover = math.max(first, math.min(#menu.items, i))
    menu.keyboard = true
    -- keep the highlighted row in view
    local rows = menu.geo and menu.geo.rows or #menu.items
    if menu.hover > 0 then
        if menu.hover <= menu.scroll then menu.scroll = menu.hover - 1 end
        if menu.hover > menu.scroll + rows then menu.scroll = menu.hover - rows end
    end
    request_tick()
end

local function menu_keys(enable)
    local keys = {
        {"ESC", function() close_menu() end},
        {"UP", function() menu_move(-1) end},
        {"DOWN", function() menu_move(1) end},
        {"LEFT", function() if menu and menu.back then menu_activate(0) end end},
        {"BS", function() if menu and menu.back then menu_activate(0) end end},
        {"RIGHT", function()
            local item = menu and menu.hover and menu.items[menu.hover]
            if item and item.submenu then menu_activate(menu.hover) end
        end},
        {"ENTER", function() if menu and menu.hover then menu_activate(menu.hover) end end},
        {"KP_ENTER", function() if menu and menu.hover then menu_activate(menu.hover) end end},
    }
    for i, k in ipairs(keys) do
        local name = "modernz-menu-" .. i
        if enable then mp.add_forced_key_binding(k[1], name, k[2], {repeatable = true})
        else mp.remove_key_binding(name) end
    end
    -- pointer moves anywhere in the window reach the menu (for hover)
    if enable then
        set_virt_mouse_area(0, 0, osc_param.playresx, osc_param.playresy, "menu-hover")
        mp.enable_key_bindings("menu-hover")
    else
        mp.disable_key_bindings("menu-hover")
        set_virt_mouse_area(0, 0, 0, 0, "menu-hover")
    end
end

close_menu = function()
    if not menu then return end
    cover_want = {}
    menu_covers_sync()
    menu.closing = mp.get_time()
    menu_closing = menu.geo and menu or nil
    menu = nil
    state.menu_open = false
    menu_keys(false)
    request_tick()
end

-- opts: back = kind of the menu this one was opened from (shows a back row)
open_menu = function(kind, anchor_name, opts)
    opts = opts or {}
    -- the same button again closes its menu (and any submenu opened from it)
    if menu and not opts.back and not opts.from_back
        and (menu.kind == kind or (anchor_name and menu.anchor == anchor_name)) then
        close_menu()
        return
    end
    local title, items, header = menu_items(kind, opts.arg)
    if #items == 0 then
        mp.osd_message(kind == "sub" and locale.no_subs or kind == "audio" and locale.no_audio or locale.na)
        return
    end
    -- the views it was opened from (each a kind, arg and scroll), for the back row
    local stack = opts.stack or {}
    local had_menu = menu ~= nil
    local origin = menu and menu.geo
    if menu then menu = nil else menu_keys(true) end
    menu_closing = nil
    local active, icons_mode, covers = 1, false, false
    for i, item in ipairs(items) do
        item.raw = item.label
        item.label = esc(item.label)
        item.meta = (item.meta and item.meta ~= "") and esc(item.meta) or nil
        if item.active and active == 1 then active = i end
        if item.icon or item.cover then icons_mode = true end
        if item.cover then covers = true end
    end
    state.menu_open = true
    if header then header.label = esc(header.label) end
    menu = {kind = kind, arg = opts.arg, stack = stack, title = title and esc(title) or nil, items = items,
            header = #stack == 0 and header or nil,
            covers = covers, row_h = covers and COVER_ROW_H or MENU.row_h,
            anchor = anchor_name, back = #stack > 0, icons = icons_mode, hover = nil, t0 = mp.get_time(),
            -- going into a submenu or back: the card reshapes from the old one in place and
            -- the new rows slide in from the side they come from
            keep_x = had_menu and origin and origin.x or nil,
            from = had_menu and origin and {x = origin.x, y = origin.y, w = origin.w, h = origin.h} or nil,
            dir = opts.back and 1 or -1}
    local rows = math.min(#items, math.max(3, user_opts.menu_max_items))
    menu.scroll = opts.scroll or math.max(0, math.min(#items - rows, active - math.ceil(rows / 2)))
    state.showtime = mp.get_time()
    request_tick()
end

-- a label that fits the row, shortened with an ellipsis when it doesn't
local function fit_label(item, avail, style)
    if item.fit_w == avail then return item.fit end
    item.fit_w = avail
    item.fit = item.label
    if not item.raw or estimate_text_width(item.label, style) <= avail then return item.fit end
    local starts = {}
    for p in item.raw:gmatch("()[^\128-\191]") do starts[#starts + 1] = p end
    local lo, hi = 1, #starts
    item.fit = esc("…")
    while lo <= hi do
        local mid = math.floor((lo + hi) / 2)
        local cut = esc((item.raw:sub(1, starts[mid] - 1):gsub("[%s%.%-_]+$", "")) .. "…")
        if estimate_text_width(cut, style) <= avail then
            item.fit, lo = cut, mid + 1
        else
            hi = mid - 1
        end
    end
    return item.fit
end

local function menu_styles()
    local muted = osc_color_convert(user_opts.muted_text_color)
    return {
        title = string.format("{\\bord0\\shad0%s\\fn%s\\1c&H%s&}", ui_font.semibold_b, ui_font.semibold, muted),
        heading = string.format("{\\bord0\\shad0%s\\fn%s\\1c&HFFFFFF&}", ui_font.semibold_b, ui_font.semibold),
        label = string.format("{\\bord0\\shad0\\b0\\fn%s\\1c&HFFFFFF&}", ui_font.regular),
        meta = string.format("{\\bord0\\shad0\\b0\\fn%s\\1c&H%s&}", ui_font.regular, muted),
    }
end

-- size and place of the open menu: above its button, inside the panel's width
local function menu_geometry(m)
    m = m or menu
    if not m then return nil end
    if m.closing then return m.geo end  -- stays put while it fades away
    if m.geo and m.geo_frame == menu_frame then return m.geo end
    local W, H = osc_param.playresx, osc_param.playresy
    local st = menu_styles()
    local fs_label = "{\\fs" .. MENU.fs .. "}"
    local fs_meta = "{\\fs" .. MENU.meta_fs .. "}"
    local widest = m.title and (estimate_text_width(m.title, st.title .. "{\\fs" .. MENU.title_fs .. "}") + (m.back and 24 or 0)) or 0
    if m.header then
        widest = widest + estimate_text_width(m.header.label, st.meta .. "{\\fs" .. MENU.meta_fs .. "}") + 40
    end
    -- a long list (a big folder) is sized by its longest entries only: measuring text
    -- waits on mpv, and hundreds of measurements would hold up opening the menu
    local sized = m.items
    if #sized > 16 then
        if not m.longest then
            local order = {}
            for i = 1, #sized do order[i] = sized[i] end
            table.sort(order, function(a, b) return #a.label + #(a.meta or "") > #b.label + #(b.meta or "") end)
            m.longest = {}
            for j = 1, math.min(12, #order) do m.longest[j] = order[j] end
        end
        sized = m.longest
    end
    for _, item in ipairs(sized) do
        local w = estimate_text_width(item.label, st.label .. fs_label)
            + (item.meta and (estimate_text_width(item.meta, st.meta .. fs_meta) + 20) or 0)
            + (item.submenu and 18 or 0) + (m.icons and not m.covers and item.active ~= nil and 22 or 0)
        if w > widest then widest = w end
    end
    local lead = m.covers and (COVER_X + COVER_W + COVER_GAP + 2) or m.icons and 40 or 32
    local w = math.floor(math.max(200, math.min(widest + lead + 2 * MENU.pad + 18, math.min(440, W - 24))))

    local ax, ay = W / 2, H - 120
    for _, e in ipairs(elements) do
        if e.name == m.anchor and e.hitbox then
            ax = (e.hitbox.x1 + e.hitbox.x2) / 2
            ay = e.hitbox.y1
        end
    end
    local p = state.panel_rect
    if p then ay = p.y1
    elseif state.seekbar_element and state.seekbar_element.hitbox then ay = math.min(ay, state.seekbar_element.hitbox.y1) end
    local bottom = ay - 10

    local header = m.title and MENU.header_h or MENU.pad
    local avail = bottom - 12 - header - MENU.pad
    local rows = math.min(#m.items, math.max(3, user_opts.menu_max_items), math.max(1, math.floor(avail / m.row_h)))
    local scrolls = #m.items > rows
    m.scroll = math.max(0, math.min(m.scroll, #m.items - rows))
    -- row offsets from the top of the list (separators only when the whole list shows)
    local ys, y = {}, 0
    for r = 1, rows do
        local item = m.items[m.scroll + r]
        if item and item.sep and not scrolls then y = y + MENU.sep_h end
        ys[r] = y
        y = y + m.row_h
    end
    local h = header + y + MENU.pad
    local left, right = 12, W - 12
    if p then left, right = math.max(left, p.x1), math.min(right, p.x2) end
    local x = m.keep_x or (ax - w / 2)
    x = math.max(left, math.min(right - w, x))
    m.geo = {x = x, y = bottom - h, w = w, h = h, rows = rows, ys = ys, top = bottom - h + header,
                scrolls = scrolls, ax = math.max(x + MENU.radius, math.min(x + w - MENU.radius, ax))}
    m.geo_frame = menu_frame
    return m.geo
end

-- the row under the pointer: an item index, 0 for the back row, nil for none
local function menu_row_at(mx, my)
    local g = menu and menu.geo
    if not g or not mx or mx < g.x or mx > g.x + g.w then return nil end
    if (menu.back or menu.header) and my >= g.y and my < g.top then return 0 end
    for r = 1, g.rows do
        local y = g.top + g.ys[r]
        if my >= y and my < y + menu.row_h then
            local i = menu.scroll + r
            return i <= #menu.items and i or nil
        end
    end
    return nil
end

-- where a menu's animation is: k (scale around the anchor), fade (card's extra alpha,
-- 0 = opaque), cfade (the content's), slide (content's sideways offset), x/y/w/h (the
-- card, which reshapes going into a submenu) and done
local function menu_motion(m, g)
    local now = mp.get_time()
    local motion = glass_look.motion
    if m.closing then
        -- closing: a quick fade, settling back a touch toward the button
        local p = math.min(1, (now - m.closing) / 0.12)
        local f = math.floor(255 * p * p + 0.5)
        return {k = motion and (1 - 0.03 * p * p) or 1, fade = f, cfade = f, slide = 0,
                x = g.x, y = g.y, w = g.w, h = g.h, done = p >= 1}
    end
    local t = now - m.t0
    local fade_in = math.floor(255 * (1 - ease_out(t / 0.14)) + 0.5)
    local f = m.from
    if f then
        local e = motion and ease_out(t / 0.24) or 1
        return {k = 1, fade = 0, cfade = fade_in, slide = (1 - e) * 10 * m.dir,
                x = f.x + (g.x - f.x) * e, y = f.y + (g.y - f.y) * e, w = f.w + (g.w - f.w) * e, h = f.h + (g.h - f.h) * e,
                done = t >= (motion and 0.26 or 0.15)}
    end
    -- opening: grows out of its button on a spring and fades up
    return {k = motion and (0.94 + 0.06 * spring(t)) or 1, fade = fade_in, cfade = fade_in, slide = 0,
            x = g.x, y = g.y, w = g.w, h = g.h, done = t >= (motion and 0.6 or 0.15)}
end

-- the menu card as currently drawn (for the backdrop blur)
menu_visual_rect = function(m)
    local g = menu_geometry(m)
    if not g then return nil end
    local mo = menu_motion(m, g)
    local k, ox, oy = mo.k, g.ax, g.y + g.h
    return {ox + (mo.x - ox) * k, oy + (mo.y - oy) * k, mo.w * k, mo.h * k, MENU.radius * k, 1 - mo.fade / 255}
end

render_menu = function(master_ass, m)
    local menu = m  -- the open menu, or one that is fading away
    local g = menu_geometry(m)
    if not g then return end
    -- drawn on its own and joined once at the end (see batch_new)
    local ass = batch_new()
    local st = menu_styles()
    local mo = menu_motion(m, g)
    if not mo.done then request_tick() end
    local k, fade, cfade = mo.k, mo.fade, mo.cfade
    -- grow out of the button: everything scales around the anchor point
    local ox, oy = g.ax, g.y + g.h
    local function X(x) return ox + (x - ox) * k end
    local function Y(y) return oy + (y - oy) * k end
    local function XC(x) return X(x + mo.slide) end  -- content (slides in from a submenu)
    local function A(a) return string.format("\\alpha&H%02X&", mult_alpha(a or 0, cfade)) end
    -- while the card reshapes, the content is cut to it
    local cut = m.from and not mo.done and {X(mo.x), Y(mo.y), X(mo.x + mo.w), Y(mo.y + mo.h)} or nil
    local cut_tag = cut and string.format("\\clip(%f,%f,%f,%f)", cut[1], cut[2], cut[3], cut[4]) or ""
    local function clip_rect(x1, y1, x2, y2)
        if cut then
            x1, y1, x2, y2 = math.max(x1, cut[1]), math.max(y1, cut[2]), math.min(x2, cut[3]), math.min(y2, cut[4])
        end
        return string.format("\\clip(%f,%f,%f,%f)", x1, y1, x2, y2)
    end

    glass_rect(ass, X(mo.x), Y(mo.y), mo.w * k, mo.h * k, MENU.radius * k, {
        fade = fade, fill_alpha = glass_fill_alpha(glass_blur_active() and 48 or 86),
        shadow = not (glass_blur_active() and user_opts.glass_shadow),
        shadow_blur = 22, shadow_y = 10, shadow_alpha = 0xB0})

    local inner_x, inner_w = g.x + MENU.pad, g.w - 2 * MENU.pad - (g.scrolls and 6 or 0)
    local row_r = MENU.radius - MENU.pad
    local function highlight(y, h, strong)
        ass:new_event()
        ass:append(string.format("{\\rDefault\\an7\\bord0\\shad0\\blur0\\1c&HFFFFFF&\\1a&H%02X&%s}",
            mult_alpha(strong and 0xD4 or 0xE6, cfade), cut_tag))
        ass:pos(XC(inner_x), Y(y))
        ass:draw_start()
        ass:round_rect_cw(0, 0, inner_w * k, h * k, row_r * k)
        ass:draw_stop()
    end
    -- text and icons keep their cached outlines and scale with tags (a new size every
    -- frame of the animation would re-make, and keep, a copy of each icon path)
    local scale_tag = k ~= 1 and string.format("\\fscx%.2f\\fscy%.2f", k * 100, k * 100) or ""
    local function text(x, y, an, style, size, str, alpha, clip)
        ass:new_event()
        ass:append(string.format("{\\rDefault\\an%d%s}", an, clip or cut_tag))
        ass:pos(XC(x), Y(y))
        ass:append(style .. string.format("{\\fs%g%s%s}", size, A(alpha), scale_tag) .. str)
    end
    local function glyph(name, x, y, size, alpha, color)
        ass:new_event()
        ass:append(string.format("{\\rDefault\\an5\\bord0\\shad0\\blur0\\1c&H%s&%s%s%s}", color or "FFFFFF", A(alpha), scale_tag, cut_tag))
        ass:pos(XC(x), Y(y))
        ass:append(icon_drawing(name, size))
    end

    -- header: a section title, or a back row for submenus
    if menu.title then
        local cy = g.y + MENU.header_h / 2 + 2
        if menu.back then
            if menu.hover == 0 then highlight(g.y + MENU.pad, MENU.header_h - MENU.pad, menu.pressed == 0) end
            glyph("menu_back", inner_x + 13, cy, 14, 0x30)
            text(inner_x + 26, cy, 4, st.heading, MENU.fs, menu.title, 0)
        else
            if menu.header then
                -- a link on the right of the title row (another folder, ...)
                if menu.hover == 0 then highlight(g.y + MENU.pad, MENU.header_h - MENU.pad, menu.pressed == 0) end
                local muted = osc_color_convert(user_opts.muted_text_color)
                local lx = inner_x + inner_w - 10
                glyph("menu_chevron", lx - 4, cy, 12, menu.hover == 0 and 0 or 0x30, muted)
                text(lx - 16, cy, 6, st.meta, MENU.meta_fs, menu.header.label, menu.hover == 0 and 0 or 0x20)
            end
            text(g.x + 16, cy, 4, st.title, MENU.title_fs, menu.title, 0)
        end
    end

    local right = inner_x + inner_w - 10
    local wanted = {}
    for r = 1, g.rows do
        local i = menu.scroll + r
        local item = menu.items[i]
        if not item then break end
        local ry = g.top + g.ys[r]
        local row_h = menu.row_h
        local cy = ry + row_h / 2
        if item.sep and not g.scrolls then
            ass:new_event()
            ass:append(string.format("{\\rDefault\\an7\\bord0\\shad0\\blur0\\1c&HFFFFFF&\\1a&H%02X&%s}", mult_alpha(0xE2, cfade), cut_tag))
            ass:pos(XC(inner_x + 10), Y(ry - MENU.sep_h / 2 - 0.5))
            ass:draw_start()
            ass:rect_cw(0, 0, (inner_w - 20) * k, math.max(0.5, glass_edge_width()) * k)
            ass:draw_stop()
        end
        if menu.hover == i then highlight(ry + 1, row_h - 2, menu.pressed == i) end

        -- rows next to the edge of a scrolled list fade out
        local edge = 0
        -- (rows with pictures stay solid: the pictures can't fade with them)
        if g.scrolls and not menu.covers then
            if menu.scroll > 0 and r <= 2 then edge = r == 1 and 0x99 or 0x44 end
            if menu.scroll + g.rows < #menu.items and r > g.rows - 2 then edge = math.max(edge, r == g.rows and 0x99 or 0x44) end
        end

        local label_x = inner_x + (menu.covers and (COVER_X + COVER_W + COVER_GAP) or menu.icons and 38 or 30)
        local trail = right
        if item.cover then
            -- the tile moves with the menu; the picture goes on top once it stands still
            -- a tile one unit larger than the picture: a placeholder while it loads, then
            -- the hairline edge around it
            local tx, ty = inner_x + COVER_X, cy - COVER_H / 2
            ass:new_event()
            ass:append(string.format("{\\rDefault\\an7\\bord0\\shad0\\blur0\\1c&HFFFFFF&\\1a&H%02X&%s}",
                mult_alpha(0xE0, cfade), cut_tag))
            ass:pos(XC(tx - 1), Y(ty - 1))
            ass:draw_start()
            ass:round_rect_cw(0, 0, (COVER_W + 2) * k, (COVER_H + 2) * k, (COVER_R + 1) * k)
            ass:draw_stop()
            local file = cover_files[item.cover]
            if file == nil and not cover_asked[item.cover] then
                cover_asked[item.cover] = true
                wanted[#wanted + 1] = item.cover
            end
            local still = not m.closing and mo.slide == 0 and math.abs(k - 1) < 0.003 and cfade < 8
                and (not m.from or mo.done)
            if file and still and edge < 0x80 and r <= COVER_SLOTS then
                cover_want[COVER_SLOT0 + r - 1] = {file = file, x = XC(tx), y = Y(ty)}
            end
        end
        if menu.icons then
            if item.icon then glyph(item.icon, inner_x + (menu.covers and (COVER_X + COVER_W / 2) or 18), cy, MENU.icon, edge) end
            if item.active and not menu.covers then
                glyph("menu_check", right - 6, cy, MENU.glyph, edge)
                trail = right - 22
            end
        elseif item.active then
            glyph("menu_check", inner_x + 15, cy, MENU.glyph, edge)
        end
        if item.submenu then
            glyph("menu_chevron", right - 4, cy, 12, mult_alpha(0x50, edge), osc_color_convert(user_opts.muted_text_color))
            trail = right - 16
        end
        local meta_w = item.meta and estimate_text_width(item.meta, st.meta .. "{\\fs" .. MENU.meta_fs .. "}") or 0
        if item.meta then text(trail, cy, 6, st.meta, MENU.meta_fs, item.meta, edge) end
        local label_right = trail - (item.meta and meta_w + 14 or 0)
        local label = fit_label(item, label_right - label_x, st.label .. "{\\fs" .. MENU.fs .. "}")
        text(label_x, cy, 4, st.label, MENU.fs, label, edge,
             clip_rect(XC(label_x - 2), Y(ry), XC(label_right), Y(ry + row_h)))
    end

    -- covers still to make: the rows on screen first
    if #wanted > 0 then
        mp.commandv("script-message-to", "thumbz", "covers", utils.format_json(wanted))
    end

    -- scroll position
    if g.scrolls then
        local track_y, track_h = g.top + 4, g.ys[g.rows] + menu.row_h - 8
        local thumb_h = math.max(18, track_h * g.rows / #menu.items)
        local thumb_y = track_y + (track_h - thumb_h) * menu.scroll / (#menu.items - g.rows)
        ass:new_event()
        ass:append(string.format("{\\rDefault\\an7\\bord0\\shad0\\blur0\\1c&HFFFFFF&\\1a&H%02X&%s}", mult_alpha(0xA8, cfade), cut_tag))
        ass:pos(X(g.x + g.w - 9), Y(thumb_y))
        ass:draw_start()
        ass:round_rect_cw(0, 0, 3 * k, thumb_h * k, 1.5 * k)
        ass:draw_stop()
    end
    master_ass:new_event()
    master_ass:append(ass:text_of())
end

-- mouse input while a menu is open: returns true when the event belongs to the menu
menu_event = function(source, what)
    if not menu then return false end
    local mx, my = get_virt_mouse_pos()
    if source == "mouse_move" then
        local row = menu_row_at(mx, my)
        if row or not menu.keyboard then menu.hover = row end
        if row then menu.keyboard = false end
        return false
    end
    local g = menu.geo
    local inside = g and mx and mx >= g.x and mx <= g.x + g.w and my >= g.y and my <= g.y + g.h
    if source == "wheel_up" or source == "wheel_down" then
        if what == "press" and inside then
            menu.scroll = math.max(0, math.min(#menu.items - g.rows, menu.scroll + (source == "wheel_up" and -1 or 1)))
            menu.hover = menu_row_at(mx, my)
        end
        return true
    end
    if what == "down" then
        menu.pressed = inside and menu_row_at(mx, my) or nil
        menu.dismiss = not inside
        return true
    elseif what == "up" then
        if menu.dismiss then
            close_menu()
        elseif source == "mbtn_left" then
            local row = menu_row_at(mx, my)
            if row and row == menu.pressed then menu_activate(row) end
        end
        if menu then menu.pressed = nil end
        return true
    end
    return true
end
end

-- the select/* lists ModernZ replaces with its own menus (when modern_menus=yes)
local menu_for_command = {
    ["script-binding select/select-aid"] = "audio",
    ["script-binding select/select-sid"] = "sub",
    ["script-binding select/select-playlist"] = "playlist",
    ["script-binding select/select-chapter"] = "chapter",
    ["script-binding select/select-audio-device"] = "audio-device",
}

--
-- Initialisation and Layout
--
local function is_image()
    local t = mp.get_property_native("current-tracks/video")
    state.is_image = t ~= nil and t.image == true and t.albumart ~= true
end

local function get_ytdl_format()
    local fmt = mp.get_property("file-local-options/ytdl-format") or mp.get_property("ytdl-format") or ""
    return fmt ~= "" and ("-f " .. fmt) or "-f bestvideo+bestaudio/best"
end

local function exec(args, callback)
    for i = #args, 1, -1 do
        if args[i] == nil or args[i] == "" then table.remove(args, i) end
    end
    msg.info("Executing: " .. table.concat(args, " "))
    mp.command_native_async({
        name = "subprocess",
        args = args,
        capture_stdout = true,
        capture_stderr = true
    }, callback)
end

local function check_path_url()
    state.is_url = false
    state.downloading = false

    local path = mp.get_property("path")
    if not path then return end

    -- normalize ytdl:// prefix: ytdl://https://... > https://..., ytdl://... > https://...
    path = path:gsub("^ytdl://https?://", "https://"):gsub("^ytdl://", "https://")

    local scheme = path:match("^([%w][%w+%-%.]*)://")
    local online_schemes = {
        http=true, https=true,
        ftp=true, ftps=true,
        rtmp=true, rtmps=true,
        rtsp=true, rtsps=true,
        mms=true, mmsh=true, mmst=true,
    }

    if scheme and online_schemes[scheme:lower()] then
        state.is_url = true
        state.url_path = path
        msg.info("URL detected.")

        if user_opts.download_button then
            msg.info("Approximating file size...")
            state.file_size_normalized = "Approximating file size..."
            exec({
                "yt-dlp",
                state.is_image and "" or get_ytdl_format(),
                "--no-download",
                "-O", "%(filesize,filesize_approx)s",
                path
            }, function(_, result)
                local bytes = tonumber(result.stdout)
                if bytes then
                    state.file_size_normalized = utils.format_bytes_humanized(bytes)
                    msg.info("Download size: " .. state.file_size_normalized)
                else
                    local fs_prop = mp.get_property_osd("file-size")
                    if fs_prop and fs_prop ~= "" then
                        state.file_size_normalized = fs_prop
                        msg.info("Download size: " .. fs_prop)
                    else
                        state.file_size_normalized = "Unknown"
                        msg.info("Unable to retrieve file size.")
                    end
                end
                request_tick()
            end)
        end
    end
end

local function download_done(success, _, error)
    if success then
        local path = mp.command_native({"expand-path", user_opts.download_path})
        mp.commandv("show-text", "Download saved to " .. path, "-1", "1")
        state.downloaded_once = true
        msg.info("Download completed")
    else
        mp.commandv("show-text", "Download failed - " .. (error or "Unknown error"), "-1", "1")
        msg.info("Download failed")
    end
    state.downloading = false
end

local function new_element(name, type)
    elements[name] = {}
    elements[name].type = type
    elements[name].name = name

    -- add default stuff
    elements[name].eventresponder = {}
    elements[name].visible = true
    elements[name].enabled = true
    elements[name].softrepeat = false
    elements[name].styledown = (type == "button")
    elements[name].state = {}

    if type == "button" then
        elements[name].tooltip_style = osc_styles.tooltip
    elseif type == "slider" then
        elements[name].slider = {min = {value = 0}, max = {value = 100}}
        elements[name].thumbnailable = false
    end

    return elements[name]
end

local function add_layout(name)
    if elements[name] ~= nil then
        -- new layout
        elements[name].layout = {}

        -- set layout defaults
        elements[name].layout.layer = 50
        elements[name].layout.alpha = {[1] = 0, [2] = 255, [3] = 255, [4] = 255}
        elements[name].layout.group = "bottom"

        if elements[name].type == "button" then
            elements[name].layout.button = {
                hoverstyle = osc_styles.element_hover,
            }
        elseif elements[name].type == "slider" then
            -- slider defaults
            elements[name].layout.slider = {
                border = 1,
                gap = 1,
                radius = 0,
                nibbles_top = user_opts.nibbles_top,
                nibbles_bottom = user_opts.nibbles_bottom,
                nibbles_style = user_opts.nibbles_style,
                adjust_tooltip = true,
                tooltip_style = osc_styles.tooltip,
                tooltip_an = 2,
                alpha = {[1] = 0, [2] = 255, [3] = 88, [4] = 255},
                hoverstyle = osc_styles.element_hover:gsub("\\fscx%d+\\fscy%d+", ""), -- font scales messes with handle positions in werid ways
            }
        elseif elements[name].type == "box" then
            elements[name].layout.box = {radius = 0, hexagon = false}
        end

        return elements[name].layout
    else
        msg.error("Can't add_layout to element '"..name.."', doesn't exist.")
    end
end

-- glass surface made of layout boxes, so it fades with the OSC: a soft shadow, the
-- tinted fill, a sheen that fades down from the top, a thin edge that is brighter on top
local function glass_panel(name, x, y, w, h, r, group)
    local lo
    local function part(suffix, layer)
        new_element(name .. suffix, "box")
        lo = add_layout(name .. suffix)
        lo.geometry = {x = x, y = y, an = 7, w = w, h = h}
        lo.layer = layer
        lo.group = group
        lo.box.radius = r
        return lo
    end
    -- the shader casts an adaptive shadow when it runs; otherwise a soft static one
    if user_opts.glass_shadow and not glass_blur_active() then
        lo = part("_shadow", 7)
        lo.geometry.y = y + 6
        lo.style = "{\\blur20\\bord0\\shad0\\1c&H000000&}"
        lo.alpha[1] = 0xB8
    end
    lo = part("_bg", 8)
    lo.style = "{\\blur0\\bord0\\shad0\\1c&H" .. osc_color_convert(glass_look.color) .. "&}"
    lo.alpha[1] = glass_fill_alpha()

    -- hairline edge, and the light catching its top
    local edge = glass_edge_width()
    lo = part("_edge", 9)
    lo.style = "{\\blur0\\bord0\\shad0\\1c&HFFFFFF&}"
    lo.box.ring = edge
    lo.alpha[1] = opacity_alpha(glass_look.edge)
    if not glass_look.contrast then
        local cut = math.min(r, h / 2)
        lo = part("_rim", 9)
        lo.style = string.format("{\\blur0.5\\bord0\\shad0\\1c&HFFFFFF&\\clip(%f,%f,%f,%f)}", x - 2, y - 2, x + w + 2, y + cut * 0.5)
        lo.box.ring = edge
        lo.alpha[1] = 0x8C
        lo = part("_rim2", 9)
        lo.style = string.format("{\\blur0.5\\bord0\\shad0\\1c&HFFFFFF&\\clip(%f,%f,%f,%f)}", x - 2, y + cut * 0.5, x + w + 2, y + cut)
        lo.box.ring = edge
        lo.alpha[1] = 0xC4
    end
end

-- Window controls on glass: a floating pill at the top right (and the title in its own
-- pill at the top left), matching the bottom panel
local function glass_window_controls()
    local W, H = osc_param.playresx, osc_param.playresy
    local m = math.max(8, math.floor(user_opts.panel_margin * 0.75 + 0.5))
    local bw, bh, pad = 40, 32, 4
    local lo
    local ontop_active = user_opts.ontop_button and window_controls_enabled() and user_opts.ontop_in_topbar and state.ontop
    -- one capsule: [pin] minimize maximize close
    local count = (user_opts.window_controls and 3 or 0) + (ontop_active and 1 or 0)
    local box_w = count > 0 and (count * bw + 2 * pad) or 0
    local box_h = bh + 2 * pad
    local r = box_h / 2
    local bx, by = W - m - box_w, m
    local cy = by + box_h / 2

    local size_hover = hover_effects.size and
        string.format("\\fscx%s\\fscy%s", user_opts.button_hover_size, user_opts.button_hover_size) or ""
    local function wc_button(name, x, hoverstyle)
        lo = add_layout(name)
        lo.geometry = {x = x, y = cy, an = 5, w = bw, h = bh}
        lo.style = osc_styles.glass_window_control
        lo.group = "top"
        lo.button.hoverstyle = hoverstyle
        elements[name].hover_radius = bh / 2
        elements[name].hover_pad = 0
    end
    local function tinted(color) return "{\\c&H" .. osc_color_convert(color) .. "&" .. size_hover .. "}" end

    if count > 0 then
        glass_panel("wc_panel", bx, by, box_w, box_h, r, "top")
        state.wc_rect = {x1 = bx, y1 = by, x2 = bx + box_w, y2 = by + box_h, r = r}
        local x = bx + pad + bw / 2
        if ontop_active then
            elements["ontop"].visible = true
            wc_button("ontop", x, osc_styles.element_hover)
            x = x + bw
        end
        if user_opts.window_controls then
            -- plain highlights, and a solid red one for close
            wc_button("minimize", x, tinted(user_opts.windowcontrols_min_hover))
            wc_button("maximize", x + bw, tinted(user_opts.windowcontrols_max_hover))
            wc_button("close", x + 2 * bw, "{}")
            elements["minimize"].hover_color, elements["maximize"].hover_color = nil, nil
            elements["close"].hover_alpha = 0x38
        end
    end

    if user_opts.show_window_title then
        local left_x = m
        local max_w = math.max(0, bx - 12 - left_x)
        local text = mp.get_property("title") or ""
        local text_w = math.min(max_w - 32, estimate_text_width(text, osc_styles.glass_window_title))
        if text ~= "" and text_w > 20 then
            glass_panel("wc_title_panel", left_x, by, text_w + 32, box_h, r, "top")
            state.wt_rect = {x1 = left_x, y1 = by, x2 = left_x + text_w + 32, y2 = by + box_h, r = r}
            lo = add_layout("windowtitle")
            lo.geometry = {x = left_x + 16, y = cy, an = 4, w = text_w, h = box_h}
            lo.group = "top"
            lo.alpha[3] = 0
            lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.glass_window_title, left_x + 16, by, left_x + 16 + text_w, by + box_h)
            state.windowtitle_max_w = text_w
        end
    end

    if user_opts.show_window_title or count > 0 then
        local sh_area_y1 = by + box_h + get_align(1 - (2 * user_opts.deadzonesize), H - (by + box_h), 0, 0)
        add_area("showhide_wc", 0, 0, W, sh_area_y1)
        if count > 0 then add_area("window-controls", bx, by, bx + box_w, by + box_h) end
        -- the strip left of the controls drags the window, like a title bar
        add_area("window-controls-title", 0, 0, bx, by + box_h)
        osc_param.video_margins.t = (by + box_h) / H
    end
end

-- Window Controls
local function window_controls()
    if state.glass_ui then return glass_window_controls() end
    local wc_geo = {
        x = 0,
        y = 50,
        an = 1,
        w = osc_param.playresx,
        h = 50,
    }

    local lo
    local ontop_active = user_opts.ontop_button and window_controls_enabled() and user_opts.ontop_in_topbar and state.ontop
    local controlbox_w = (user_opts.window_controls and window_control_box_width or 0)
    local controlbox_left = wc_geo.w - controlbox_w
    local titlebox_left = ontop_active and 50 or wc_geo.x
    local button_y = wc_geo.y - (wc_geo.h / 2)
    local first_geo  = {x = controlbox_left + 25,  y = button_y, an = 5, w = 50, h = wc_geo.h}
    local second_geo = {x = controlbox_left + 75, y = button_y, an = 5, w = 49, h = wc_geo.h}
    local third_geo  = {x = controlbox_left + 125, y = button_y, an = 5, w = 50, h = wc_geo.h}

    -- Window controls
    if user_opts.window_controls then
        local size_hover = hover_effects.size and
            string.format("\\fscx%s\\fscy%s", user_opts.button_hover_size, user_opts.button_hover_size) or ""
        local function wc_hoverstyle(color)
            return "{\\c&H" .. osc_color_convert(color) .. "&" .. size_hover .. "}"
        end

        local function wc_button(name, geom, hover_color)
            lo = add_layout(name)
            lo.geometry = geom
            lo.style = osc_styles.window_control
            lo.group = "top"
            lo.button.hoverstyle = wc_hoverstyle(hover_color)
        end

        wc_button("close", third_geo, user_opts.windowcontrols_close_hover) -- Close: 🗙
        wc_button("maximize", second_geo, user_opts.windowcontrols_max_hover) -- Maximize: 🗖/🗗
        wc_button("minimize", first_geo, user_opts.windowcontrols_min_hover) -- Minimize: 🗕
    end

    -- ontop button in top bar when ontop is active
    if ontop_active then
        elements["ontop"].visible = osc_param.playresx >= controlbox_w + 35
        elements["ontop"].hover_radius = 0
        elements["ontop"].hover_pad = 0
        lo = add_layout("ontop")
        lo.geometry = {x = 25, y = button_y, an = 5, w = 50, h = wc_geo.h}
        lo.style = osc_styles.window_control
        lo.group = "top"
        lo.button.hoverstyle = osc_styles.element_hover
    end

    -- Window Title
    if user_opts.show_window_title then
        lo = add_layout("windowtitle")
        lo.geometry = {x = math.max(20, titlebox_left + 4), y = button_y + 14, an = 1, w = osc_param.playresx - 50, h = wc_geo.h}
        lo.group = "top"
        lo.alpha[3] = 0
        lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.window_title, titlebox_left, wc_geo.y - wc_geo.h, controlbox_left, wc_geo.y + wc_geo.h)
        state.windowtitle_max_w = controlbox_left - math.max(20, titlebox_left + 4)
    end

    -- only add top areas and margin if one of the elements is enabled
    if (user_opts.show_window_title or user_opts.window_controls or ontop_active) then
        -- deadzone below window controls
        local sh_area_y1 = wc_geo.y + get_align(1 - (2 * user_opts.deadzonesize), osc_param.playresy - wc_geo.y, 0, 0)
        add_area("showhide_wc", wc_geo.x, 0, wc_geo.w, sh_area_y1)
        add_area("window-controls", get_hitbox_coords(controlbox_left, wc_geo.y, wc_geo.an, controlbox_w, wc_geo.h))
        if ontop_active then add_area("window-controls-ontop", 0, 0, 50, wc_geo.h) end
        add_area("window-controls-title", titlebox_left, 0, controlbox_left, wc_geo.h)
        -- top bar margins
        osc_param.video_margins.t = wc_geo.h / osc_param.playresy
    end
end

--
-- ModernZ Layouts
--

local layouts = {}

-- create the OSC fade background box and window bar alpha box
local function setup_bg_elements(posX, posY, osc_w, osc_h, osc_alpha3, wc_alpha3)
    new_element("osc_fade_bg", "box")
    local lo = add_layout("osc_fade_bg")
    lo.geometry = {x = posX, y = posY, an = 7, w = osc_w, h = osc_h}
    lo.style = osc_styles.osc_fade_bg
    lo.layer = 10
    lo.alpha[3] = osc_alpha3

    if window_controls_enabled() and (user_opts.show_window_title or user_opts.window_controls) then
        new_element("window_bar_alpha_bg", "box")
        lo = add_layout("window_bar_alpha_bg")
        lo.geometry = {x = posX, y = -100, an = 7, w = osc_w, h = -1}
        lo.style = osc_styles.window_fade_bg
        lo.layer = 10
        lo.group = "top"
        lo.alpha[3] = wc_alpha3
    end
end

-- Default layout: a floating glass panel with the title, the seekbar and one row of
-- controls (playback on the left, everything else on the right)
layouts["default"] = function ()
    local W, H = osc_param.playresx, osc_param.playresy
    local margin = user_opts.panel_margin
    local panel_w = W - 2 * margin
    if user_opts.panel_max_width > 0 then panel_w = math.min(panel_w, user_opts.panel_max_width) end
    local px = math.floor((W - panel_w) / 2)

    -- controls are 36 wide round targets; the outer ones sit concentric with the panel corners
    local btn = 36
    local radius = math.max(8, user_opts.panel_radius)
    local inset = math.max(6, radius - btn / 2)
    local pad_x = math.max(18, inset + 8)
    local show_title = user_opts.show_title
    local title_fs = user_opts.title_font_size
    local seek_off = show_title and (14 + title_fs + 18) or 24   -- panel top to seekbar centre
    local panel_h = seek_off + 32 + inset + btn / 2
    local py = H - margin - panel_h
    local x0, x1 = px + pad_x, px + panel_w - pad_x
    local inner_w = x1 - x0
    local seek_cy = py + seek_off
    local cy = py + panel_h - inset - btn / 2

    state.glass_ui = true
    state.tooltip_y = py - 9
    state.panel_rect = {x1 = px, y1 = py, x2 = px + panel_w, y2 = py + panel_h, r = radius}

    osc_param.areas = {}
    osc_param.video_margins.b = (panel_h + margin) / H
    add_area("input", px, py, px + panel_w, py + panel_h)
    add_area("showhide", 0, get_align(-1 + (2 * user_opts.deadzonesize), py, 0, 0), W, H)

    glass_panel("panel", px, py, panel_w, panel_h, radius, "bottom")

    local lo, ne

    -- title row: title on the left, current chapter (muted, opens the chapter list) on the right
    local chapter_index = (state.chapter or -1) >= 0
    local show_chapter = user_opts.show_chapter_title and chapter_index and user_opts.chapter_fmt ~= "no"
    local baseline = py + 14 + title_fs
    local chapter_w = show_chapter and math.floor(inner_w * 0.36) or 0
    local title_w = math.max(0, inner_w - (show_chapter and chapter_w + 16 or 0))
    elements["title"].visible = show_title
    if show_title then
        lo = add_layout("title")
        lo.geometry = {x = x0, y = baseline, an = 1, w = title_w, h = title_fs}
        lo.layer = 48
        lo.alpha[3] = 0
        lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.glass_title, x0, py, x0 + title_w, baseline + 6)
        state.title_max_w = title_w
    end
    if user_opts.show_chapter_title then
        elements["chapter_title"].visible = show_title and show_chapter
        if show_title and show_chapter then
            lo = add_layout("chapter_title")
            lo.geometry = {x = x1, y = baseline, an = 3, w = chapter_w, h = user_opts.chapter_title_font_size}
            lo.layer = 48
            lo.alpha[3] = 0
            lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.glass_chapter, x1 - chapter_w, py, x1, baseline + 6)
            state.chapter_title_max_w = chapter_w
        end
    end

    -- seek row: elapsed | seekbar | duration (or remaining)
    local has_time = (state.duration or 0) > 0
    local function time_sample(sec)
        local has_h = sec >= 3600 or user_opts.time_format == "fixed"
        local base = has_h and (sec >= 36000 and "88" or "8") .. ":88:88" or (sec >= 600 and "88" or "8") .. ":88"
        return base .. (state.tc_ms and ".888" or "")
    end
    local tw = 0
    if has_time then
        local sample = time_sample(math.max(state.duration or 0, frame_number("playback-time", 0) or 0))
        tw = math.ceil(estimate_text_width("-" .. sample, osc_styles.glass_time)) + 2
        if tw <= 2 then tw = 44 end
    end
    elements["time_pos"].visible = has_time
    elements["time_end"].visible = has_time
    local sx0, sx1 = x0, x1
    if has_time then
        lo = add_layout("time_pos")
        lo.geometry = {x = x0, y = seek_cy, an = 4, w = tw, h = user_opts.time_font_size}
        lo.layer = 48
        lo.alpha[3] = 0
        lo.style = osc_styles.glass_time
        lo = add_layout("time_end")
        lo.geometry = {x = x1, y = seek_cy, an = 6, w = tw, h = user_opts.time_font_size}
        lo.layer = 48
        lo.alpha[3] = 0
        lo.style = osc_styles.glass_time_muted
        sx0, sx1 = x0 + tw + 12, x1 - tw - 12
    end
    local seek_w = math.max(10, sx1 - sx0)

    ne = new_element("seekbarbg", "box")
    ne.visible = user_opts.nibbles_style ~= "gap"
    lo = add_layout("seekbarbg")
    local seekbar_bg_h = seekbar_height_style.height
    lo.geometry = {x = sx0 + seek_w / 2, y = seek_cy, an = 5, w = seek_w, h = seekbar_bg_h}
    lo.layer = 15
    lo.style = osc_styles.seekbar_bg
    lo.box.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.alpha[1] = 0xB4

    lo = add_layout("seekbar")
    local seekbar_h = 18
    lo.geometry = {x = sx0 + seek_w / 2, y = seek_cy, an = 5, w = seek_w, h = seekbar_h}
    lo.layer = 49
    lo.style = osc_styles.seekbar_fg
    lo.slider.handle_color = user_opts.seek_handle_color
    lo.slider.handle_border = user_opts.seek_handle_border_color
    lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
    lo.slider.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.slider.tooltip_an = 2

    if user_opts.persistent_progress or state.persistent_progress_toggle then
        lo = add_layout("persistent_seekbar")
        lo.geometry = {x = W / 2, y = H, an = 5, w = W, h = user_opts.persistent_progress_height}
        lo.style = osc_styles.seekbar_fg
        lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
        lo.slider.tooltip_an = 0
    end

    -- controls row: volume on the left, transport in the middle, tracks and the rest on the right
    local audio_track = state.audio_track_count > 0
    local subtitle_track = state.sub_track_count > 0
    local have_pl = state.playlist_count > 1
    local chapter_skip = user_opts.chapter_skip_buttons and type(state.chapter_list) == "table" and next(state.chapter_list) ~= nil
    local playlist_button = user_opts.playlist_button and (not user_opts.hide_empty_playlist_button or have_pl)
    local nextprev = user_opts.track_nextprev_buttons
    local icon, transport = osc_styles.glass_icon, osc_styles.glass_transport

    -- name, width, keep priority (higher stays longer), style, wanted, gap after
    local left = {
        {"vol_ctrl", btn, 85, icon, audio_track and user_opts.volume_control, 0},
        {"volumebar", 72, 25, nil, audio_track and user_opts.volume_control, 4},
    }
    local center = {
        {"chapter_prev", btn, 30, transport, chapter_skip},
        {"playlist_prev", btn, 60, transport, nextprev and (have_pl or contains(user_opts.buttons_always_active, "playlist_prev"))},
        {"jump_backward", btn, 70, transport, user_opts.jump_buttons},
        {"play_pause", 44, 100, osc_styles.glass_play, true},
        {"jump_forward", btn, 70, transport, user_opts.jump_buttons},
        {"playlist_next", btn, 60, transport, nextprev and (have_pl or contains(user_opts.buttons_always_active, "playlist_next"))},
        {"chapter_next", btn, 30, transport, chapter_skip},
    }
    local right = {
        {"cache_info", user_opts.cache_info_speed and 70 or 48, 5, osc_styles.glass_cache, user_opts.cache_info},
        {"download", btn, 10, icon, state.is_url and user_opts.download_button},
        {"sub_track", btn, 80, icon, subtitle_track and user_opts.subtitles_button},
        {"audio_track", btn, 75, icon, audio_track and user_opts.audio_tracks_button},
        {"playlist", btn, 65, icon, playlist_button},
        {"more", btn, 90, icon, true},
        {"fullscreen", btn, 98, icon, user_opts.fullscreen_button},
    }
    local groups = {left, center, right}
    local gaps = {4, 10, 4}
    for gi, list in ipairs(groups) do
        for _, it in ipairs(list) do
            it.keep = (it[5] and elements[it[1]] ~= nil) and true or false
            it.gap = it[6] or gaps[gi]
        end
    end
    local function width(list)
        local sum, any = 0, false
        for _, it in ipairs(list) do
            if it.keep then sum = sum + it[2] + (any and it.gap or 0); any = true end
        end
        return sum
    end
    local row_x0, row_x1 = px + inset, px + panel_w - inset
    local row_w = row_x1 - row_x0
    -- transport centred in the panel when there is room for it, else straight after the volume
    local function fits(centred)
        local l, c, r = width(left), width(center), width(right)
        if centred then
            local c0 = px + panel_w / 2 - c / 2
            return row_x0 + l + 16 <= c0 and c0 + c + 16 <= row_x1 - r
        end
        return l + c + r + 32 <= row_w
    end
    local centred = true
    while not fits(centred) do
        if centred and fits(false) then
            centred = false
        else
            local victim
            for _, list in ipairs(groups) do
                for _, it in ipairs(list) do
                    if it.keep and (not victim or it[3] < victim[3]) then victim = it end
                end
            end
            if not victim then break end
            victim.keep = false
        end
    end
    -- the volume slider goes with its button
    if not left[1].keep then left[2].keep = false end

    local function place(it, x)
        local name, w, _, style = it[1], it[2], it[3], it[4]
        if name == "volumebar" then
            ne = new_element("volumebarbg", "box")
            lo = add_layout("volumebarbg")
            lo.geometry = {x = x, y = cy, an = 4, w = w, h = 4}
            lo.layer = 15
            lo.alpha[1] = 0xB4
            lo.style = user_opts.volumebar_match_seek_color and osc_styles.seekbar_bg or "{\\1c&HFFFFFF&}"
            lo.box.radius = 2

            lo = add_layout("volumebar")
            lo.geometry = {x = x, y = cy, an = 4, w = w, h = 12}
            lo.style = user_opts.volumebar_match_seek_color and osc_styles.seekbar_fg or osc_styles.volumebar_fg
            lo.slider.handle_color = user_opts.volumebar_match_seek_color and user_opts.seekbarfg_color or user_opts.side_buttons_color
            lo.slider.gap = 4
            lo.slider.radius = 2
            lo.slider.tooltip_an = 2
            return
        end
        lo = add_layout(name)
        if name == "cache_info" then
            lo.geometry = {x = x + 4, y = cy, an = 4, w = w - 8, h = user_opts.cache_info_font_size}
            lo.layer = 48
            lo.alpha[3] = 0
        else
            lo.geometry = {x = x + w / 2, y = cy, an = 5, w = w, h = btn}
        end
        lo.style = style
        local e = elements[name]
        e.hover_radius, e.hover_pad, e.hover_alpha = btn / 2, 0, 0xE6
        if name == "play_pause" then
            e.hover_radius = 22
            lo.geometry.h = 44
        elseif name == "cache_info" then
            e.hover_radius, e.hover_pad = 10, 4
        end
    end
    local function lay(list, x)
        local any = false
        for _, it in ipairs(list) do
            if elements[it[1]] then elements[it[1]].visible = it.keep end
            if it.keep then
                if any then x = x + it.gap end
                place(it, x)
                x = x + it[2]
                any = true
            end
        end
        return x
    end
    local lx = lay(left, row_x0)
    lay(center, centred and (px + panel_w / 2 - width(center) / 2) or (lx + 16))
    lay(right, row_x1 - width(right))

    -- the volume button's highlight and wheel area cover its slider too
    if left[1].keep and left[2].keep then
        local vc = elements["vol_ctrl"].layout.geometry
        local left_edge = vc.x - btn / 2
        elements["vol_ctrl"].hover_box = {x1 = left_edge, y1 = cy - btn / 2, x2 = left_edge + btn + 4 + 72 + 8, y2 = cy + btn / 2}
        elements["vol_ctrl"].hover_pad = 0
        elements["vol_ctrl"].hover_radius = btn / 2
    end
end

-- Image viewer on glass: one compact floating pill with groups split by thin dividers
layouts["glass-image"] = function ()
    local W, H = osc_param.playresx, osc_param.playresy
    local margin = user_opts.panel_margin
    local btn, gap, pad, bar_h = 36, 4, 10, 56
    local have_pl = state.playlist_count > 1
    local nextprev = user_opts.track_nextprev_buttons and have_pl
    local playlist_button = user_opts.playlist_button and (not user_opts.hide_empty_playlist_button or have_pl)
    local ontop_button = user_opts.ontop_button and not (window_controls_enabled() and user_opts.ontop_in_topbar and state.ontop)
    local zoom = user_opts.zoom_control

    -- name, width, keep priority (higher stays longer), style, wanted
    local groups = {
        {
            {"playlist_prev", btn, 60, osc_styles.glass_icon, nextprev},
            {"playlist", btn, 50, osc_styles.glass_icon, playlist_button},
            {"playlist_next", btn, 60, osc_styles.glass_icon, nextprev},
        },
        {
            {"zoom_out_icon", btn, 45, osc_styles.glass_icon, zoom},
            {"zoom_control", 88, 25, nil, zoom},
            {"zoom_in_icon", btn, 45, osc_styles.glass_icon, zoom},
        },
        {
            {"download", btn, 10, osc_styles.glass_icon, state.is_url and user_opts.download_button},
            {"ontop", btn, 20, osc_styles.glass_icon, ontop_button},
            {"info", btn, 35, osc_styles.glass_icon, user_opts.info_button},
            {"fullscreen", btn, 70, osc_styles.glass_icon, user_opts.fullscreen_button},
        },
    }
    local divider_w = 1 + 2 * 8
    local function width()
        local sum, used = 2 * pad, 0
        for _, g in ipairs(groups) do
            local n = 0
            for _, it in ipairs(g) do
                if it.keep then sum = sum + it[2] + (n > 0 and gap or 0); n = n + 1 end
            end
            if n > 0 then used = used + 1 end
        end
        return sum + math.max(0, used - 1) * divider_w
    end
    for _, g in ipairs(groups) do
        for _, it in ipairs(g) do it.keep = (it[5] and elements[it[1]] ~= nil) and true or false end
    end
    while width() > W - 2 * margin do
        local victim
        for _, g in ipairs(groups) do
            for _, it in ipairs(g) do
                if it.keep and (not victim or it[3] < victim[3]) then victim = it end
            end
        end
        if not victim then break end
        victim.keep = false
    end
    -- the zoom slider only makes sense next to its buttons
    if not (groups[2][1].keep and groups[2][3].keep) then groups[2][2].keep = false end

    local bar_w = width()
    local px, py = math.floor((W - bar_w) / 2), H - margin - bar_h
    local radius = bar_h / 2
    local cy = py + bar_h / 2

    state.glass_ui = true
    state.tooltip_y = py - 9
    state.panel_rect = {x1 = px, y1 = py, x2 = px + bar_w, y2 = py + bar_h, r = radius}

    osc_param.areas = {}
    osc_param.video_margins.b = (bar_h + margin) / H
    add_area("input", px, py, px + bar_w, py + bar_h)
    add_area("showhide", 0, get_align(-1 + (2 * user_opts.deadzonesize), py, 0, 0), W, H)

    glass_panel("panel", px, py, bar_w, bar_h, radius, "bottom")

    local lo, ne
    local x = px + pad
    local dividers = 0
    for gi, g in ipairs(groups) do
        local any = false
        for _, it in ipairs(g) do any = any or it.keep end
        if any and x > px + pad then
            dividers = dividers + 1
            ne = new_element("image_divider" .. dividers, "box")
            lo = add_layout("image_divider" .. dividers)
            lo.geometry = {x = x + divider_w / 2, y = cy, an = 5, w = 1, h = 20}
            lo.layer = 15
            lo.style = "{\\blur0\\bord0\\shad0\\1c&HFFFFFF&}"
            lo.alpha[1] = 0xC8
            x = x + divider_w
        end
        local first = true
        for _, it in ipairs(g) do
            local name, w, _, style = it[1], it[2], it[3], it[4]
            if elements[name] then elements[name].visible = it.keep end
            if it.keep then
                if not first then x = x + gap end
                first = false
                if name == "zoom_control" then
                    ne = new_element("zoom_control_bg", "box")
                    lo = add_layout("zoom_control_bg")
                    lo.geometry = {x = x + 4, y = cy, an = 4, w = w - 8, h = 4}
                    lo.layer = 15
                    lo.alpha[1] = 0xB4
                    lo.style = "{\\1c&HFFFFFF&}"
                    lo.box.radius = 2

                    lo = add_layout("zoom_control")
                    lo.geometry = {x = x + 4, y = cy, an = 4, w = w - 8, h = 12}
                    lo.style = osc_styles.volumebar_fg
                    lo.slider.handle_color = user_opts.side_buttons_color
                    lo.slider.gap = 4
                    lo.slider.radius = 2
                    lo.slider.tooltip_an = 2
                else
                    lo = add_layout(name)
                    lo.geometry = {x = x + w / 2, y = cy, an = 5, w = w, h = btn}
                    lo.style = style
                    local e = elements[name]
                    e.hover_radius, e.hover_pad, e.hover_alpha = btn / 2, 0, 0xE6
                end
                x = x + w
            end
        end
    end
end

-- Classic layout: full-width bar over a gradient (ModernZ before the glass panel)
layouts["classic"] = function ()
    local no_title = not user_opts.show_title
    local no_chapter = not user_opts.show_chapter_title
    local chapter_index = user_opts.show_chapter_title and (state.chapter or -1) >= 0
    local chapter_h = (no_chapter or not chapter_index) and 0 or user_opts.chapter_title_font_size
    local chapter_offset = (no_chapter or not chapter_index) and 0 or user_opts.chapter_title_offset
    chapter_offset = user_opts.chapter_above_title and user_opts.chapter_above_title_offset or chapter_offset
    local title_h = no_title and 0 or user_opts.title_font_size
    local title_offset = (no_chapter or not chapter_index or user_opts.chapter_above_title) and user_opts.title_offset or user_opts.title_with_chapter_offset
    title_offset = no_title and 0 or title_offset
    local title_and_chapter_h_with_offset = chapter_h + chapter_offset + title_h + title_offset

    if title_and_chapter_h_with_offset == 0 then
        -- add some top padding if both title and chapter aren't displayed
        local ch_skip = user_opts.chapter_skip_buttons and type(state.chapter_list) == "table" and next(state.chapter_list)
        local outer = (ch_skip and 0 or 100) + (user_opts.jump_buttons and 0 or 100)
        local timecodes_above = osc_param.playresx < (user_opts.portrait_window_trigger - outer
            - (user_opts.playlist_button and (not user_opts.hide_empty_playlist_button or state.playlist_count > 1) and 0 or 100)
            - (state.sub_track_count > 0 and 0 or 100)
            - (state.audio_track_count > 0 and 0 or 100))
        title_and_chapter_h_with_offset = timecodes_above
            and math.max(user_opts.osc_height * 0.2, user_opts.time_codes_offset + user_opts.title_offset + user_opts.time_font_size)
            or user_opts.osc_height * 0.2
    end

    local osc_geo = {
        w = osc_param.playresx,
        h = user_opts.osc_height + title_and_chapter_h_with_offset
    }

    -- update bottom margin
    osc_param.video_margins.b = osc_geo.h / osc_param.playresy

    -- origin of the controllers, left/bottom corner
    local posX = 0
    local posY = osc_param.playresy

    osc_param.areas = {} -- delete areas

    -- area for active mouse input
    add_area("input", get_hitbox_coords(posX, posY, 1, osc_geo.w, osc_geo.h))

    -- area for show/hide
    local osc_top = posY - osc_geo.h
    add_area("showhide", 0, get_align(-1 + (2 * user_opts.deadzonesize), osc_top, 0, 0), osc_param.playresx, osc_param.playresy)

    -- fetch values
    local osc_w = osc_geo.w
    local lo, geo, ne

    -- osc background
    setup_bg_elements(posX, posY, osc_w, osc_geo.h, user_opts.fade_transparency_strength, user_opts.window_fade_transparency_strength)

    local refX = osc_w / 2
    local refY = posY

    -- seekbar
    ne = new_element("seekbarbg", "box")
    ne.visible = user_opts.nibbles_style ~= "gap"
    lo = add_layout("seekbarbg")
    local seekbar_bg_h = seekbar_height_style.height
    lo.geometry = {x = refX, y = refY - user_opts.osc_height, an = 5, w = osc_geo.w - 30, h = seekbar_bg_h}
    lo.layer = 15
    lo.style = osc_styles.seekbar_bg
    lo.box.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.alpha[1] = 128

    lo = add_layout("seekbar")
    local seekbar_h = 18
    lo.geometry = {x = refX, y = refY - user_opts.osc_height, an = 5, w = osc_geo.w - 30, h = seekbar_h}
    lo.layer = 49
    lo.style = osc_styles.seekbar_fg
    lo.slider.handle_color = user_opts.seek_handle_color
    lo.slider.handle_border = user_opts.seek_handle_border_color
    lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
    lo.slider.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.slider.tooltip_an = 2

    if user_opts.persistent_progress or state.persistent_progress_toggle then
        lo = add_layout("persistent_seekbar")
        lo.geometry = {x = refX, y = refY, an = 5, w = osc_geo.w, h = user_opts.persistent_progress_height}
        lo.style = osc_styles.seekbar_fg
        lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
        lo.slider.tooltip_an = 0
    end

    local audio_track = state.audio_track_count > 0
    local subtitle_track = state.sub_track_count > 0
    local chapter_skip_buttons = user_opts.chapter_skip_buttons and type(state.chapter_list) == "table" and next(state.chapter_list)
    local ontop_button = user_opts.ontop_button and not (window_controls_enabled() and user_opts.ontop_in_topbar and state.ontop)
    local playlist_button = user_opts.playlist_button and (not user_opts.hide_empty_playlist_button or state.playlist_count > 1)

    local offset = user_opts.jump_buttons and 60 or 0
    local outeroffset = (chapter_skip_buttons and 0 or 100) + (user_opts.jump_buttons and 0 or 100)
    local narrow_win = osc_param.playresx < (
        user_opts.portrait_window_trigger
        - outeroffset
        - (playlist_button and 0 or 100)
        - (subtitle_track and 0 or 100)
        - (audio_track and 0 or 100)
    )

    local time_codes_width = get_time_codes_width()
    local chapter_title_y, title_y
    if user_opts.chapter_above_title then
        title_y = user_opts.osc_height + title_offset
        chapter_title_y = title_y + title_h + chapter_offset
    else
        chapter_title_y = user_opts.osc_height + chapter_offset
        title_y = (no_chapter or not chapter_index) and (user_opts.osc_height + title_offset) or (chapter_title_y + chapter_h + user_opts.title_with_chapter_offset)
    end

    -- osc title
    local title_w = (no_chapter or not chapter_index or user_opts.chapter_above_title) and (osc_geo.w - 60 - time_codes_width) or (osc_geo.w - 50)
    state.title_max_w = title_w
    if title_w < 0 then title_w = 0 end
    elements["title"].visible = not no_title
    geo = {x = 25, y = refY - title_y, an = 1, w = title_w, h = user_opts.title_font_size}
    lo = add_layout("title")
    lo.geometry = geo
    lo.layer = 48
    lo.alpha[3] = 0
    lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.title, 0, 0, geo.x + geo.w, geo.y + geo.h)

    -- chapter title
    if user_opts.show_chapter_title then
        elements["chapter_title"].visible = not no_chapter and chapter_index
        local chapter_title_w = narrow_win and (osc_geo.w - time_codes_width - 60) or (osc_geo.w - 60)
        geo = {x = 26, y = refY - chapter_title_y, an = 1, w = chapter_title_w, h = user_opts.chapter_title_font_size}
        lo = add_layout("chapter_title")
        lo.geometry = geo
        lo.layer = 48
        lo.alpha[3] = 0
        lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.chapter_title, 0, 0, geo.x + geo.w, geo.y + geo.h)
        state.chapter_title_max_w = geo.w
    end

    -- left side buttons
    local start_x = 37
    local function left_side_button(name, min_w, w, step)
        local vis = osc_param.playresx >= min_w
        elements[name].visible = vis
        if vis then
            lo = add_layout(name)
            lo.geometry = {x = start_x, y = refY - (user_opts.osc_height / 2), an = 5, w = w or 24, h = 24}
            lo.style = osc_styles.control_3
            start_x = start_x + (step or 45)
        end
    end

    if playlist_button then left_side_button("playlist", 550) end
    if audio_track and user_opts.audio_tracks_button then left_side_button("audio_track", 650) end
    if subtitle_track and user_opts.subtitles_button then left_side_button("sub_track", 750) end

    if audio_track and user_opts.volume_control then
        -- volume button
        left_side_button("vol_ctrl", 850)
        start_x = start_x - 25 -- vol_ctrl uses a narrower step (+20 not +45)

        -- volume bar
        local vol_vis = (osc_param.playresx >= user_opts.hide_volume_bar_trigger - outeroffset)
        ne = new_element("volumebarbg", "box")
        ne.visible = vol_vis
        lo = add_layout("volumebarbg")
        lo.geometry = {x = start_x, y = refY - (user_opts.osc_height / 2), an = 4, w = 55, h = 4}
        lo.layer = 15
        lo.alpha[1] = 128
        lo.style = user_opts.volumebar_match_seek_color and osc_styles.seekbar_bg or osc_styles.volumebar_bg
        lo.box.radius = user_opts.slider_rounded_corners and 2 or 0

        elements["volumebar"].visible = vol_vis
        lo = add_layout("volumebar")
        lo.geometry = {x = start_x, y = refY - (user_opts.osc_height / 2), an = 4, w = 55, h = 10}
        lo.style = user_opts.volumebar_match_seek_color and osc_styles.seekbar_fg or osc_styles.volumebar_fg
        lo.slider.handle_color = user_opts.volumebar_match_seek_color and user_opts.seekbarfg_color or user_opts.side_buttons_color
        lo.slider.gap = 3
        lo.slider.radius = user_opts.slider_rounded_corners and 2 or 0
        lo.slider.tooltip_an = 2
        start_x = start_x + 75
        -- vol_ctrl center = bar_start - 20; bar_start = start_x - 75; left edge = center - 12
        local vc_left = start_x - 107
        local osc_mid = refY - (user_opts.osc_height / 2)
        elements["vol_ctrl"].hover_box = vol_vis and {x1 = vc_left, y1 = osc_mid - 12, x2 = vc_left + 87, y2 = osc_mid + 12} or nil
    end

    -- time codes
    local auto_hide_volbar = (audio_track and user_opts.volume_control) and osc_param.playresx < (user_opts.hide_volume_bar_trigger - outeroffset)
    local time_codes_x = start_x
        - (auto_hide_volbar and 67 or 0) -- window width with audio track and elements
        - (audio_track and not user_opts.volume_control and 12 or 0) -- audio track with no elements
        - (not audio_track and 12 or 0) -- remove excess space
    local time_codes_y = user_opts.time_codes_offset + (user_opts.osc_height / 2)
    if narrow_win then
        -- try to vertically align time codes to the baseline of title/chapter
        if not user_opts.show_title and not user_opts.show_chapter_title then
            time_codes_y = user_opts.time_codes_offset + user_opts.osc_height + user_opts.title_offset
        elseif no_chapter or not chapter_index or user_opts.chapter_above_title then
            time_codes_y = title_y + ((title_h - user_opts.time_font_size) * 0.25)
        else
            time_codes_y = chapter_title_y
            if chapter_h ~= user_opts.time_font_size then
                time_codes_y = time_codes_y - ((user_opts.time_font_size - chapter_h) * 0.25)
            end
        end
    end
    elements["time_codes"].visible = (state.duration or 0) > 0
    lo = add_layout("time_codes")
    lo.geometry = {x = (narrow_win and (osc_geo.w - 25) or time_codes_x), y = refY - time_codes_y, an = (narrow_win and 3 or 4), w = time_codes_width, h = user_opts.time_font_size}
    lo.layer = 48
    lo.alpha[3] = 0
    lo.style = osc_styles.time

    -- center buttons
    if user_opts.track_nextprev_buttons then
        elements["playlist_prev"].visible = (state.playlist_count > 1 or contains(user_opts.buttons_always_active, "playlist_prev")) and (osc_param.playresx >= 500 - outeroffset)
        lo = add_layout("playlist_prev")
        lo.geometry = {x = refX - (60 + (chapter_skip_buttons and 60 or 0)) - offset, y = refY - (user_opts.osc_height / 2), an = 5, w = 30, h = 24}
        lo.style = osc_styles.control_2
    end

    if chapter_skip_buttons then
        elements["chapter_prev"].visible = osc_param.playresx >= 400 - outeroffset
        lo = add_layout("chapter_prev")
        lo.geometry = {x = refX - 60 - offset, y = refY - (user_opts.osc_height / 2), an = 5, w = 30, h = 24}
        lo.style = osc_styles.control_2
    end

    if user_opts.jump_buttons then
        lo = add_layout("jump_backward")
        lo.geometry = {x = refX - 60, y = refY - (user_opts.osc_height / 2), an = 5, w = 30, h = 24}
        lo.style = osc_styles.control_2
    end

    lo = add_layout("play_pause")
    lo.geometry = {x = refX, y = refY - (user_opts.osc_height / 2), an = 5, w = 45, h = 28}
    lo.style = osc_styles.control_1

    if user_opts.jump_buttons then
        lo = add_layout("jump_forward")
        lo.geometry = {x = refX + 60, y = refY - (user_opts.osc_height / 2), an = 5, w = 30, h = 24}
        lo.style = osc_styles.control_2
    end

    if chapter_skip_buttons then
        elements["chapter_next"].visible = osc_param.playresx >= 400 - outeroffset
        lo = add_layout("chapter_next")
        lo.geometry = {x = refX + 60 + offset, y = refY - (user_opts.osc_height / 2), an = 5, w = 30, h = 24}
        lo.style = osc_styles.control_2
    end

    if user_opts.track_nextprev_buttons then
        elements["playlist_next"].visible = (state.playlist_count > 1 or contains(user_opts.buttons_always_active, "playlist_next")) and (osc_param.playresx >= 500 - outeroffset)
        lo = add_layout("playlist_next")
        lo.geometry = {x = refX + (60 + (chapter_skip_buttons and 60 or 0)) + offset, y = refY - (user_opts.osc_height / 2), an = 5, w = 30, h = 24}
        lo.style = osc_styles.control_2
    end

    -- right side buttons
    local end_x = osc_geo.w - 37
    local function right_side_button(name, min_w, vis_extra, style, w)
        local vis = (osc_param.playresx >= min_w - outeroffset) and (vis_extra == nil or vis_extra)
        elements[name].visible = vis
        if vis then
            lo = add_layout(name)
            lo.geometry = {x = end_x, y = refY - (user_opts.osc_height / 2), an = 5, w = (w or 24), h = 24}
            lo.style = style or osc_styles.control_3
            end_x = end_x - 45
        end
    end

    right_side_button("fullscreen", 550, user_opts.fullscreen_button)
    right_side_button("info", 650, user_opts.info_button)
    right_side_button("ontop", 750, user_opts.ontop_button and not (window_controls_enabled() and user_opts.ontop_in_topbar and state.ontop))
    right_side_button("screenshot", 850, user_opts.screenshot_button)
    right_side_button("file_loop", 950, user_opts.loop_button)
    right_side_button("shuffle", 1050, user_opts.shuffle_button)
    right_side_button("speed", 1150, user_opts.speed_button, osc_styles.speed, 42)
    right_side_button("download", 1150, state.is_url and user_opts.download_button)

    if user_opts.cache_info then
        right_side_button("cache_info", 1250, user_opts.cache_info, osc_styles.cache, user_opts.cache_info_speed and 70 or 45)
        lo.geometry.x  = lo.geometry.x + 7
        lo.geometry.an = 6
        lo.alpha[3] = 0
    end
end

layouts["compact"] = function ()
    local chapter_index = (state.chapter or -1) >= 0
    local no_title = not user_opts.show_title
    local no_chapter = not user_opts.show_chapter_title
    local chapter_h = (no_chapter or not chapter_index) and 0 or user_opts.chapter_title_font_size
    local chapter_offset = (no_chapter or not chapter_index) and 0 or user_opts.chapter_title_offset
    chapter_offset = user_opts.chapter_above_title and user_opts.chapter_above_title_offset or chapter_offset
    local title_h = no_title and 0 or user_opts.title_font_size
    local title_offset = (no_chapter or not chapter_index or user_opts.chapter_above_title) and user_opts.title_offset or user_opts.title_with_chapter_offset
    title_offset = no_title and 0 or title_offset
    local title_and_chapter_h_with_offset = chapter_h + chapter_offset + title_h + title_offset

    if title_and_chapter_h_with_offset == 0 then
        -- add some top padding if both title and chapter aren't displayed
        title_and_chapter_h_with_offset = user_opts.osc_height * 0.2
    end

    local osc_geo = {
        w = osc_param.playresx,
        h = user_opts.osc_height + title_and_chapter_h_with_offset
    }

    -- update bottom margin
    osc_param.video_margins.b = osc_geo.h / osc_param.playresy

    -- origin of the controllers, left/bottom corner
    local posX = 0
    local posY = osc_param.playresy

    osc_param.areas = {} -- delete areas

    -- area for active mouse input
    add_area("input", get_hitbox_coords(posX, posY, 1, osc_geo.w, osc_geo.h))

    -- area for show/hide
    local osc_top = posY - osc_geo.h
    add_area("showhide", 0, get_align(-1 + (2 * user_opts.deadzonesize), osc_top, 0, 0), osc_param.playresx, osc_param.playresy)

    -- fetch values
    local osc_w = osc_geo.w
    local lo, geo, ne
    -- osc background
    setup_bg_elements(posX, posY, osc_w, osc_geo.h, user_opts.fade_transparency_strength, user_opts.window_fade_transparency_strength)

    local refX = osc_w / 2
    local refY = posY

    -- seekbar
    ne = new_element("seekbarbg", "box")
    ne.visible = user_opts.nibbles_style ~= "gap"
    lo = add_layout("seekbarbg")
    local seekbar_bg_h = seekbar_height_style.height
    lo.geometry = {x = refX, y = refY - user_opts.osc_height, an = 5, w = osc_geo.w - 30, h = seekbar_bg_h}
    lo.layer = 15
    lo.style = osc_styles.seekbar_bg
    lo.box.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.alpha[1] = 128

    lo = add_layout("seekbar")
    local seekbar_h = 18
    lo.geometry = {x = refX, y = refY - user_opts.osc_height, an = 5, w = osc_geo.w - 30, h = seekbar_h}
    lo.layer = 49
    lo.style = osc_styles.seekbar_fg
    lo.slider.handle_color = user_opts.seek_handle_color
    lo.slider.handle_border = user_opts.seek_handle_border_color
    lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
    lo.slider.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.slider.tooltip_an = 2

    if user_opts.persistent_progress or state.persistent_progress_toggle then
        lo = add_layout("persistent_seekbar")
        lo.geometry = {x = refX, y = refY, an = 5, w = osc_geo.w, h = user_opts.persistent_progress_height}
        lo.style = osc_styles.seekbar_fg
        lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
        lo.slider.tooltip_an = 0
    end

    local time_codes_width = get_time_codes_width()
    local chapter_title_y, title_y
    if user_opts.chapter_above_title then
        title_y = user_opts.osc_height + title_offset
        chapter_title_y = title_y + title_h + chapter_offset
    else
        chapter_title_y = user_opts.osc_height + chapter_offset
        title_y = (no_chapter or not chapter_index) and (user_opts.osc_height + title_offset) or (chapter_title_y + chapter_h + user_opts.title_with_chapter_offset)
    end

    -- osc title
    local title_w = osc_geo.w - 50
    state.title_max_w = title_w
    if title_w < 0 then title_w = 0 end
    elements["title"].visible = not no_title
    geo = {x = 25, y = refY - title_y, an = 1, w = title_w, h = user_opts.title_font_size}
    lo = add_layout("title")
    lo.geometry = geo
    lo.layer = 48
    lo.alpha[3] = 0
    lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.title, 0, 0, geo.x + geo.w, geo.y + geo.h)

    -- chapter title
    if user_opts.show_chapter_title then
        elements["chapter_title"].visible = not no_chapter and chapter_index
        geo = {x = 25, y = refY - chapter_title_y, an = 1, w = osc_geo.w - 60, h = user_opts.chapter_title_font_size}
        lo = add_layout("chapter_title")
        lo.geometry = geo
        lo.layer = 48
        lo.alpha[3] = 0
        lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.chapter_title, 0, 0, geo.x + geo.w, geo.y + geo.h)
        state.chapter_title_max_w = geo.w
    end

    -- left side buttons
    local start_x = 37
    local function left_side_button(name, min_w, w, step)
        local vis = osc_param.playresx >= min_w
        elements[name].visible = vis
        if vis then
            lo = add_layout(name)
            lo.geometry = {x = start_x, y = refY - (user_opts.osc_height / 2), an = 5, w = w or 24, h = 24}
            lo.style = osc_styles.control_2
            start_x = start_x + (step or 45)
        end
    end

    elements["play_pause"].visible = osc_param.playresx >= 200
    lo = add_layout("play_pause")
    lo.geometry = {x = start_x, y = refY - (user_opts.osc_height / 2), an = 5, w = 24, h = 24}
    lo.style = osc_styles.control_2
    start_x = start_x + 45

    local pl_count = state.playlist_count
    local pl_pos = state.playlist_pos_1

    if user_opts.track_nextprev_buttons then
        local prev_vis = pl_pos > 1 and osc_param.playresx >= 550
        elements["playlist_prev"].visible = prev_vis
        if prev_vis then
            lo = add_layout("playlist_prev")
            lo.geometry = {x = start_x, y = refY - (user_opts.osc_height / 2), an = 5, w = 24, h = 24}
            lo.style = osc_styles.control_2
            start_x = start_x + 45
        end

        local next_vis = pl_pos < pl_count and osc_param.playresx >= 550
        elements["playlist_next"].visible = next_vis
        if next_vis then
            lo = add_layout("playlist_next")
            lo.geometry = {x = start_x, y = refY - (user_opts.osc_height / 2), an = 5, w = 24, h = 24}
            lo.style = osc_styles.control_2
            start_x = start_x + 45
        end
    end

    if user_opts.jump_buttons then
        left_side_button("jump_backward", 700, 30)
        left_side_button("jump_forward", 700, 30)
    end

    if state.audio_track_count > 0 and user_opts.volume_control then
        left_side_button("vol_ctrl", 800, nil, 20)

        local vol_vis = osc_param.playresx >= 900
        ne = new_element("volumebarbg", "box")
        ne.visible = vol_vis
        elements["volumebar"].visible = vol_vis
        if vol_vis then
            lo = add_layout("volumebarbg")
            lo.geometry = {x = start_x, y = refY - (user_opts.osc_height / 2), an = 4, w = 55, h = 4}
            lo.layer = 15
            lo.alpha[1] = 128
            lo.style = user_opts.volumebar_match_seek_color and osc_styles.seekbar_bg or osc_styles.volumebar_bg
            lo.box.radius = user_opts.slider_rounded_corners and 2 or 0

            lo = add_layout("volumebar")
            lo.geometry = {x = start_x, y = refY - (user_opts.osc_height / 2), an = 4, w = 55, h = 10}
            lo.style = user_opts.volumebar_match_seek_color and osc_styles.seekbar_fg or osc_styles.volumebar_fg
            lo.slider.handle_color = user_opts.volumebar_match_seek_color and user_opts.seekbarfg_color or user_opts.side_buttons_color
            lo.slider.gap = 3
            lo.slider.radius = user_opts.slider_rounded_corners and 2 or 0
            lo.slider.tooltip_an = 2
            start_x = start_x + 75
            -- vol_ctrl center = bar_start - 20; bar_start = start_x - 75; left edge = center - 12
            local vc_left = start_x - 107
            local osc_mid = refY - (user_opts.osc_height / 2)
            elements["vol_ctrl"].hover_box = {x1 = vc_left, y1 = osc_mid - 12, x2 = vc_left + 87, y2 = osc_mid + 12}
        else
            elements["vol_ctrl"].hover_box = nil
        end
    end

    -- right side buttons
    local end_x = osc_geo.w - 37
    local function right_side_button(name, min_w, vis_extra, style, w)
        local vis = (osc_param.playresx >= min_w) and (vis_extra == nil or vis_extra)
        elements[name].visible = vis
        if vis then
            lo = add_layout(name)
            lo.geometry = {x = end_x, y = refY - (user_opts.osc_height / 2), an = 5, w = (w or 24), h = 24}
            lo.style = style or osc_styles.control_2
            end_x = end_x - 45
        end
    end

    right_side_button("fullscreen", 300, user_opts.fullscreen_button)
    right_side_button("ontop", 400, user_opts.ontop_button and not (window_controls_enabled() and user_opts.ontop_in_topbar and state.ontop))
    right_side_button("sub_track", 500, user_opts.subtitles_button and state.sub_track_count > 0)
    right_side_button("audio_track", 600, user_opts.audio_tracks_button and state.audio_track_count > 0)
    right_side_button("playlist", 300, user_opts.playlist_button)
    right_side_button("download", 800, state.is_url and user_opts.download_button)
    right_side_button("speed", 800, user_opts.speed_button, osc_styles.speed, 42)
    right_side_button("file_loop", 900, user_opts.loop_button)
    right_side_button("shuffle", 1000, user_opts.shuffle_button)

    -- time codes
    local time_codes_width = get_time_codes_width()
    elements["time_codes"].visible = (state.duration or 0) > 0
    lo = add_layout("time_codes")
    lo.geometry = {x = end_x + 20, y = refY - (user_opts.osc_height / 2), an = 6, w = time_codes_width, h = 20}
    lo.layer = 48
    lo.alpha[3] = 0
    lo.style = osc_styles.time
end

layouts["mini"] = function ()
    local osc_height = 30
    local first_row_y = 25
    local second_row_y = 25
    local osc_offset = first_row_y + second_row_y

    local osc_geo = {
        w = osc_param.playresx,
        h = osc_height + osc_offset
    }

    -- update bottom margin
    osc_param.video_margins.b = osc_geo.h / osc_param.playresy

    -- origin of the controllers, left/bottom corner
    local posX = 0
    local posY = osc_param.playresy

    osc_param.areas = {} -- delete areas

    -- area for active mouse input
    add_area("input", get_hitbox_coords(posX, posY, 1, osc_geo.w, osc_geo.h))

    -- area for show/hide
    local osc_top = posY - osc_geo.h
    add_area("showhide", 0, get_align(-1 + (2 * user_opts.deadzonesize), osc_top, 0, 0), osc_param.playresx, osc_param.playresy)

    local lo, ne

    -- osc background
    setup_bg_elements(posX, posY, osc_geo.w, osc_geo.h, user_opts.fade_transparency_strength, user_opts.window_fade_transparency_strength)

    local refX = osc_geo.w / 2
    local refY = posY

    -- seekbar
    ne = new_element("seekbarbg", "box")
    ne.visible = user_opts.nibbles_style ~= "gap"
    lo = add_layout("seekbarbg")
    local seekbar_bg_h = seekbar_height_style.height
    lo.geometry = {x = refX, y = refY - first_row_y - second_row_y, an = 5, w = osc_geo.w - 30, h = seekbar_bg_h}
    lo.layer = 15
    lo.style = osc_styles.seekbar_bg
    lo.box.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.alpha[1] = 128

    lo = add_layout("seekbar")
    local seekbar_h = 18
    lo.geometry = {x = refX, y = refY - first_row_y - second_row_y, an = 5, w = osc_geo.w - 30, h = seekbar_h}
    lo.layer = 49
    lo.style = osc_styles.seekbar_fg
    lo.slider.handle_color = user_opts.seek_handle_color
    lo.slider.handle_border = user_opts.seek_handle_border_color
    lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
    lo.slider.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.slider.tooltip_an = 2

    if user_opts.persistent_progress or state.persistent_progress_toggle then
        lo = add_layout("persistent_seekbar")
        lo.geometry = {x = refX, y = refY, an = 5, w = osc_geo.w, h = user_opts.persistent_progress_height}
        lo.style = osc_styles.seekbar_fg
        lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
        lo.slider.tooltip_an = 0
    end

    -- left side buttons
    local start_x = 37
    local function left_side_button(name, min_w, w, step)
        local vis = osc_param.playresx >= min_w
        elements[name].visible = vis
        if vis then
            lo = add_layout(name)
            lo.geometry = {x = start_x, y = refY - first_row_y, an = 5, w = w or 24, h = 20}
            lo.style = osc_styles.control_mini
            start_x = start_x + (step or 35)
        end
    end

    elements["play_pause"].visible = osc_param.playresx >= 200
    lo = add_layout("play_pause")
    lo.geometry = {x = start_x, y = refY - first_row_y, an = 5, w = 24, h = 20}
    lo.style = osc_styles.control_mini
    start_x = start_x + 35

    local pl_count = state.playlist_count
    local pl_pos = state.playlist_pos_1

    if user_opts.track_nextprev_buttons then
        local prev_vis = pl_pos > 1 and osc_param.playresx >= 350
        elements["playlist_prev"].visible = prev_vis
        if prev_vis then
            lo = add_layout("playlist_prev")
            lo.geometry = {x = start_x, y = refY - first_row_y, an = 5, w = 24, h = 20}
            lo.style = osc_styles.control_mini
            start_x = start_x + 35
        end

        local next_vis = pl_pos < pl_count and osc_param.playresx >= 350
        elements["playlist_next"].visible = next_vis
        if next_vis then
            lo = add_layout("playlist_next")
            lo.geometry = {x = start_x, y = refY - first_row_y, an = 5, w = 24, h = 20}
            lo.style = osc_styles.control_mini
            start_x = start_x + 35
        end
    end

    if user_opts.jump_buttons then
        left_side_button("jump_backward", 450, 30)
        left_side_button("jump_forward", 450, 30)
    end

    if state.audio_track_count > 0 and user_opts.volume_control then
        left_side_button("vol_ctrl", 500, nil, 20)

        local vol_vis = osc_param.playresx >= 650
        ne = new_element("volumebarbg", "box")
        ne.visible = vol_vis
        elements["volumebar"].visible = vol_vis
        if vol_vis then
            lo = add_layout("volumebarbg")
            lo.geometry = {x = start_x, y = refY - first_row_y, an = 4, w = 55, h = 4}
            lo.layer = 15
            lo.alpha[1] = 128
            lo.style = user_opts.volumebar_match_seek_color and osc_styles.seekbar_bg or osc_styles.volumebar_bg
            lo.box.radius = user_opts.slider_rounded_corners and 2 or 0

            lo = add_layout("volumebar")
            lo.geometry = {x = start_x, y = refY - first_row_y, an = 4, w = 55, h = 10}
            lo.style = user_opts.volumebar_match_seek_color and osc_styles.seekbar_fg or osc_styles.volumebar_fg
            lo.slider.handle_color = user_opts.volumebar_match_seek_color and user_opts.seekbarfg_color or user_opts.side_buttons_color
            lo.slider.gap = 3
            lo.slider.radius = user_opts.slider_rounded_corners and 2 or 0
            lo.slider.tooltip_an = 2
            start_x = start_x + 75
            -- vol_ctrl center = bar_start - 20; bar_start = start_x - 75; left edge = center - 10
            local vc_left = start_x - 107
            local osc_mid = refY - first_row_y
            elements["vol_ctrl"].hover_box = {x1 = vc_left, y1 = osc_mid - 10, x2 = vc_left + 87, y2 = osc_mid + 10}
        else
            elements["vol_ctrl"].hover_box = nil
        end
    end

    -- right side buttons
    local end_x = osc_geo.w - 37
    local function right_side_button(name, min_w, vis_extra, style, w)
        local vis = (osc_param.playresx >= min_w) and (vis_extra == nil or vis_extra)
        elements[name].visible = vis
        if vis then
            lo = add_layout(name)
            lo.geometry = {x = end_x, y = refY - first_row_y, an = 5, w = (w or 24), h = 20}
            lo.style = style or osc_styles.control_mini
            end_x = end_x - 35
        end
    end

    right_side_button("fullscreen", 250, user_opts.fullscreen_button)
    right_side_button("ontop", 300, user_opts.ontop_button and not (window_controls_enabled() and user_opts.ontop_in_topbar and state.ontop))
    right_side_button("sub_track", 400, user_opts.subtitles_button and state.sub_track_count > 0)
    right_side_button("audio_track", 500, user_opts.audio_tracks_button and state.audio_track_count > 0)
    right_side_button("playlist", 600, user_opts.playlist_button)
    right_side_button("download", 700, state.is_url and user_opts.download_button)
    right_side_button("speed", 700, user_opts.speed_button, osc_styles.speed, 42)
    right_side_button("file_loop", 750, user_opts.loop_button)
    right_side_button("shuffle", 800, user_opts.shuffle_button)

    -- time codes
    local time_codes_width = get_time_codes_width()
    elements["time_codes"].visible = (state.duration or 0) > 0
    lo = add_layout("time_codes")
    lo.geometry = {x = end_x, y = refY - first_row_y, an = 6, w = time_codes_width, h = 20}
    lo.layer = 48
    lo.alpha[3] = 0
    lo.style = osc_styles.time
end

layouts["seekbar"] = function ()
    local osc_height = 30
    local first_row_y = 25
    local second_row_y = 15
    local osc_offset = first_row_y + second_row_y

    local osc_geo = {
        w = osc_param.playresx,
        h = osc_height + osc_offset
    }

    -- update bottom margin
    osc_param.video_margins.b = osc_geo.h / osc_param.playresy

    -- origin of the controllers, left/bottom corner
    local posX = 0
    local posY = osc_param.playresy

    osc_param.areas = {} -- delete areas

    -- area for active mouse input
    add_area("input", get_hitbox_coords(posX, posY, 1, osc_geo.w, osc_geo.h))

    -- area for show/hide
    local osc_top = posY - osc_geo.h
    add_area("showhide", 0, get_align(-1 + (2 * user_opts.deadzonesize), osc_top, 0, 0), osc_param.playresx, osc_param.playresy)

    local lo, ne

    -- osc background
    setup_bg_elements(posX, posY, osc_geo.w, osc_geo.h, user_opts.fade_transparency_strength, user_opts.window_fade_transparency_strength)

    local refX = osc_geo.w / 2
    local refY = posY

    -- seekbar
    ne = new_element("seekbarbg", "box")
    ne.visible = user_opts.nibbles_style ~= "gap"
    lo = add_layout("seekbarbg")
    local seekbar_bg_h = seekbar_height_style.height
    lo.geometry = {x = refX, y = refY - first_row_y, an = 5, w = osc_geo.w - 30, h = seekbar_bg_h}
    lo.layer = 15
    lo.style = osc_styles.seekbar_bg
    lo.box.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.alpha[1] = 128

    lo = add_layout("seekbar")
    local seekbar_h = 18
    lo.geometry = {x = refX, y = refY - first_row_y, an = 5, w = osc_geo.w - 30, h = seekbar_h}
    lo.layer = 49
    lo.style = osc_styles.seekbar_fg
    lo.slider.handle_color = user_opts.seek_handle_color
    lo.slider.handle_border = user_opts.seek_handle_border_color
    lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
    lo.slider.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.slider.tooltip_an = 2

    if user_opts.persistent_progress or state.persistent_progress_toggle then
        lo = add_layout("persistent_seekbar")
        lo.geometry = {x = refX, y = refY, an = 5, w = osc_geo.w, h = user_opts.persistent_progress_height}
        lo.style = osc_styles.seekbar_fg
        lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
        lo.slider.tooltip_an = 0
    end

    -- time codes
    local time_codes_width = get_time_codes_width()
    elements["time_codes"].visible = (state.duration or 0) > 0
    lo = add_layout("time_codes")
    lo.geometry = {x = osc_geo.w - 25, y = refY - first_row_y - second_row_y, an = 3, w = time_codes_width, h = user_opts.time_font_size}
    lo.layer = 48
    lo.alpha[3] = 0
    lo.style = osc_styles.time
end

layouts["modern-image"] = function ()
    local osc_geo = {
        w = osc_param.playresx,
        h = 50
    }

    -- update bottom margin
    osc_param.video_margins.b = osc_geo.h / osc_param.playresy

    -- origin of the controllers, left/bottom corner
    local posX = 0
    local posY = osc_param.playresy

    osc_param.areas = {} -- delete areas

    -- area for active mouse input
    add_area("input", get_hitbox_coords(posX, posY, 1, osc_geo.w, osc_geo.h))

    -- area for show/hide
    local osc_top = posY - osc_geo.h
    add_area("showhide", 0, get_align(-1 + (2 * user_opts.deadzonesize), osc_top, 0, 0), osc_param.playresx, osc_param.playresy)

    -- fetch values
    local osc_w = osc_geo.w
    local lo, ne
    -- osc background
    setup_bg_elements(posX, posY, osc_w, osc_geo.h, user_opts.fade_transparency_strength, user_opts.window_fade_transparency_strength)

    local refX = osc_w / 2
    local refY = posY

    local track_nextprev_buttons = user_opts.track_nextprev_buttons and state.playlist_count > 1
    local fullscreen_button = user_opts.fullscreen_button
    local info_button = user_opts.info_button
    local ontop_button = user_opts.ontop_button and not (window_controls_enabled() and user_opts.ontop_in_topbar and state.ontop)
    local playlist_button = user_opts.playlist_button and (not user_opts.hide_empty_playlist_button or state.playlist_count > 1)
    local zoom_control = user_opts.zoom_control

    local function left_side_button(name, x, min_w, w, style)
        elements[name].visible = osc_param.playresx >= min_w
        lo = add_layout(name)
        lo.geometry = {x = x, y = refY - (user_opts.osc_height / 2), an = 5, w = w or 24, h = 24}
        lo.style = style or osc_styles.control_2
    end

    local end_x = osc_geo.w - 37
    local function right_side_button(name, min_w, vis_extra)
        elements[name].visible = (osc_param.playresx >= min_w) and (vis_extra == nil or vis_extra)
        lo = add_layout(name)
        lo.geometry = {x = end_x, y = refY - (user_opts.osc_height / 2), an = 5, w = 24, h = 24}
        lo.style = osc_styles.control_3
        end_x = end_x - 45
    end

    -- left side
    if playlist_button then left_side_button("playlist", 25, 250, nil, osc_styles.control_3) end

    if track_nextprev_buttons then
        left_side_button("playlist_prev", 60 - (playlist_button and 0 or 25), 250)
        left_side_button("playlist_next", 90 - (playlist_button and 0 or 25), 250)
    end

    if zoom_control then
        local zoom_vis = osc_param.playresx >= 300
        local zx = 130 - (playlist_button and 0 or 25) - (track_nextprev_buttons and 0 or 70)

        left_side_button("zoom_out_icon", zx, 300, 30)

        ne = new_element("zoom_control_bg", "box")
        ne.visible = zoom_vis
        lo = add_layout("zoom_control_bg")
        lo.geometry = {x = zx + 25, y = refY - (user_opts.osc_height / 2), an = 4, w = 80, h = 4}
        lo.layer = 15
        lo.alpha[1] = 128
        lo.style = osc_styles.volumebar_bg
        lo.box.radius = user_opts.slider_rounded_corners and 2 or 0

        elements["zoom_control"].visible = zoom_vis
        lo = add_layout("zoom_control")
        lo.geometry = {x = zx + 25, y = refY - (user_opts.osc_height / 2), an = 4, w = 80, h = 10}
        lo.style = osc_styles.volumebar_fg
        lo.slider.handle_color = user_opts.side_buttons_color
        lo.slider.radius = user_opts.slider_rounded_corners and 2 or 0
        lo.slider.gap = 3
        lo.slider.tooltip_an = 2

        left_side_button("zoom_in_icon", zx + 130, 300, 30)
    end

    -- right side
    if fullscreen_button then right_side_button("fullscreen", 350) end
    if info_button then right_side_button("info", 400) end
    if ontop_button then right_side_button("ontop", 450) end
    if user_opts.download_button then right_side_button("download", 500, state.is_url) end
end

local function set_bar_visible(visible_key, visible)
    if state[visible_key] ~= visible then
        state[visible_key] = visible
        update_margins()
    end
    request_tick()
end

local function osc_visible(visible)
    set_bar_visible("osc_visible", visible)
end

local function wc_visible(visible)
    set_bar_visible("wc_visible", visible)
end

-- run a button's command; mpv's select lists open as ModernZ menus instead
local function run_command(command, element_name)
    local kind = user_opts.modern_menus and menu_for_command[command:match("^%s*(.-)%s*$")]
    if kind then
        open_menu(kind, element_name)
    elseif command:find("screenshot", 1, true) then
        screenshot_without_glass(command)
    else
        mp.command(command)
    end
end

-- use_down: if true, uses _down instead of _up (for softrepeat buttons)
local function bind_buttons(element_name, use_down)
    local ev = use_down and "_down" or "_up"
    for _, button in ipairs({"mbtn_left", "mbtn_right"}) do
        local command = user_opts[element_name .. "_" .. button .. "_command"]
        if command ~= nil and command ~= "" and command ~= "ignore" then
            elements[element_name].eventresponder[button .. ev] = function() run_command(command, element_name) end
        end
    end
    local command = user_opts[element_name .. "_mbtn_mid_command"]
    if command ~= nil and command ~= "" and command ~= "ignore" then
        elements[element_name].eventresponder["shift+mbtn_left_down"] = function() run_command(command, element_name) end
    end
    for _, button in ipairs({"wheel_up", "wheel_down"}) do
        local command = user_opts[element_name .. "_" .. button .. "_command"]
        if command ~= nil and command ~= "" and command ~= "ignore" then
            elements[element_name].eventresponder[button .. "_press"] = function() run_command(command, element_name) end
        end
    end
end

-- format seconds into a time string
local function format_time(seconds)
    if not seconds then return "--:--" end

    local hours   = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs    = math.floor(seconds % 60)
    local show_hours = hours > 0 or user_opts.time_format == "fixed"

    if state.tc_ms then
        local ms = math.floor((seconds % 1) * 1000)
        if show_hours then
            return string.format("%d:%02d:%02d.%03d", hours, minutes, secs, ms)
        else
            return string.format("%d:%02d.%03d", minutes, secs, ms)
        end
    else
        if show_hours then
            return string.format("%d:%02d:%02d", hours, minutes, secs)
        else
            return string.format("%d:%02d", minutes, secs)
        end
    end
end

local function build_cache_seek_ranges()
    if not user_opts.seekrange or not cache_enabled() then return nil end
    if not state.duration then return nil end
    local nranges = {}
    for _, range in ipairs(state.demuxer_cache_state["seekable-ranges"]) do
        nranges[#nranges + 1] = {
            ["start"] = 100 * range["start"] / state.duration,
            ["end"]   = 100 * range["end"]   / state.duration,
        }
    end
    return nranges
end

local function osc_init()
    msg.debug("osc_init")

    -- set canvas resolution according to display aspect and scaling setting
    local baseResY = 720
    local display_h = state.osd_dimensions.h
    local display_aspect = state.osd_dimensions.aspect
    local scale

    if state.fullscreen then
        scale = user_opts.scalefullscreen
    else
        scale = user_opts.scalewindowed
    end

    local scale_with_video
    if user_opts.vidscale == "auto" then
        scale_with_video = state.osd_scale_by_window
    else
        scale_with_video = user_opts.vidscale == "yes"
    end

    if scale_with_video then
        osc_param.unscaled_y = baseResY
    else
        osc_param.unscaled_y = display_h
    end
    osc_param.playresy = osc_param.unscaled_y / scale
    -- mpv's OSD units (used for osd-margin-y) always follow the window height
    osc_param.osd_units_y = osc_param.playresy
    if display_aspect > 0 then
        osc_param.display_aspect = display_aspect
    end
    -- in portrait windows, base the scaled canvas on the window's short side (its width)
    -- like landscape does with its height; otherwise a 9:16 window is only ~405 units
    -- wide and every width-dependent button gets hidden
    if scale_with_video and osc_param.display_aspect < 1 then
        osc_param.playresy = osc_param.playresy / osc_param.display_aspect
    end
    -- growing with the window stops at a set size (adjusted for the system's display
    -- scaling), so a large or high resolution screen shows the controls at the same size
    -- as a regular one instead of ever bigger
    if scale_with_video and user_opts.vidscale_max > 0 and display_h > 0 then
        local hidpi = mp.get_property_number("display-hidpi-scale", 1) or 1
        local max_px = user_opts.vidscale_max * math.max(hidpi, 0.5) * scale  -- screen pixels per unit
        if display_h / osc_param.playresy > max_px then
            osc_param.playresy = display_h / max_px
        end
    end
    osc_param.playresx = osc_param.playresy * osc_param.display_aspect

    -- stop seeking with the slider to prevent skipping files
    state.active_element = nil
    state.playing_and_seeking = false

    -- reset margins and text width
    text_width_cache = {}
    osc_param.video_margins = {l = 0, r = 0, t = 0, b = 0}

    elements = {}

    -- some often needed stuff
    local pl_count = state.playlist_count
    local have_pl = pl_count > 1
    local pl_pos = state.playlist_pos_1
    local have_ch = #state.chapter_list > 0
    local loop = mp.get_property("loop-playlist", "no")

    -- titles are redrawn every frame but rarely change: expand them at most every
    -- half second and escape each distinct text once (both are round trips to mpv)
    local title_cache = {}
    local function make_escaped_title(source)
        local now = mp.get_time()
        local c = title_cache[source or ""]
        if c and now - c.t < 0.5 then return c.text end
        local title = mp.command_native({"expand-text", source})
        title = title:gsub("\n", " ")
        local text = c and c.raw == title and c.text or (title ~= "" and mp.command_native({"escape-ass", title}) or "mpv")
        title_cache[source or ""] = {t = now, raw = title, text = text}
        return text
    end

    local ne

    -- Window controls
    -- Close: 🗙
    ne = new_element("close", "button")
    ne.hover_color = user_opts.windowcontrols_close_hover
    ne.hover_radius = 0
    ne.hover_pad = 0
    ne.content = icons.window.close
    ne.eventresponder["mbtn_left_up"] = function () mp.commandv("quit") end

    -- Minimize: 🗕
    ne = new_element("minimize", "button")
    ne.hover_color = user_opts.windowcontrols_min_hover
    ne.hover_radius = 0
    ne.hover_pad = 0
    ne.content = icons.window.minimize
    ne.eventresponder["mbtn_left_up"] = function () mp.commandv("cycle", "window-minimized") end

    -- Maximize: 🗖 /🗗
    ne = new_element("maximize", "button")
    ne.hover_color = user_opts.windowcontrols_max_hover
    ne.hover_radius = 0
    ne.hover_pad = 0
    ne.content = (state.window_maximized or state.fullscreen) and icons.window.unmaximize or icons.window.maximize
    ne.eventresponder["mbtn_left_up"] = function () mp.commandv("cycle", (state.fullscreen and "fullscreen" or "window-maximized")) end

    local function truncate_title(title, max_w, style)
        if not max_w or max_w <= 0 or estimate_text_width(title, style) <= max_w then return title end
        local ell_w = estimate_text_width("…", style)
        -- map each UTF-8 character to its last byte offset (avoids slicing mid-char)
        local char_ends, pos = {}, 1
        while pos <= #title do
            local b = title:byte(pos)
            local char_len = b >= 0xF0 and 4 or b >= 0xE0 and 3 or b >= 0xC0 and 2 or 1
            char_ends[#char_ends + 1] = pos + char_len - 1
            pos = pos + char_len
        end
        -- binary search over character count
        local low, high, fit = 1, #char_ends, 0
        while low <= high do
            local mid = math.floor((low + high) / 2)
            if estimate_text_width(title:sub(1, char_ends[mid]), style) <= max_w - ell_w then
                fit = mid; low = mid + 1
            else
                high = mid - 1
            end
        end
        return title:sub(1, fit > 0 and char_ends[fit] or 0) .. "…"
    end

    -- Window Title
    ne = new_element("windowtitle", "button")
    ne.content = function ()
        local t = make_escaped_title(mp.get_property("title"))
        return user_opts.truncate_title and truncate_title(t, state.windowtitle_max_w, osc_styles.window_title) or t
    end

    -- OSC title
    ne = new_element("title", "button")
    ne.content = function ()
        local t = make_escaped_title(user_opts.title)
        return user_opts.truncate_title and truncate_title(t, state.title_max_w, osc_styles.title) or t
    end
    bind_buttons("title")

    -- Chapter title
    ne = new_element("chapter_title", "button")
    ne.content = function()
        local chapter_index = state.chapter or -1
        if user_opts.chapter_fmt == "no" or chapter_index < 0 then return "" end
        local chapter_data = state.chapter_list[chapter_index + 1]
        local raw = chapter_data and chapter_data.title ~= "" and chapter_data.title
            or string.format("%s: %d/%d", locale.chapter, chapter_index + 1, #state.chapter_list)
        if state.chapter_title_raw ~= raw then
            state.chapter_title_raw = raw
            state.chapter_title_esc = mp.command_native({"escape-ass", raw})
        end
        local chapter_title = state.chapter_title_esc
        local t = string.format(user_opts.chapter_fmt, chapter_title)
        return user_opts.truncate_title and truncate_title(t, state.chapter_title_max_w, osc_styles.chapter_title) or t
    end
    bind_buttons("chapter_title")

    -- playlist buttons
    -- prev
    ne = new_element("playlist_prev", "button")
    ne.content = icons.previous
    ne.enabled = (pl_pos > 1) or (loop ~= "no") or contains(user_opts.buttons_always_active, "playlist_prev")
    bind_buttons("playlist_prev")

    --next
    ne = new_element("playlist_next", "button")
    ne.content = icons.next
    ne.enabled = (have_pl and (pl_pos < pl_count)) or (loop ~= "no") or contains(user_opts.buttons_always_active, "playlist_next")
    bind_buttons("playlist_next")

    --play control buttons
    --play_pause
    ne = new_element("play_pause", "button")
    ne.content = function () return state.eof_reached and icons.replay or (state.pause and not state.playing_and_seeking and icons.play) or icons.pause end
    bind_buttons("play_pause")
    ne.eventresponder["mbtn_left_up"] = function ()
        if state.eof_reached then
            mp.commandv("seek", 0, "absolute-percent")
            mp.commandv("set", "pause", "no")
        else
            mp.command(user_opts.play_pause_mbtn_left_command)
        end
    end

    local jump_amount = user_opts.jump_amount
    local jump_more_amount = user_opts.jump_more_amount
    local jump_mode = user_opts.jump_mode
    local jump_icon = user_opts.jump_icon_number and icons.jump[jump_amount] or icons.jump.default

    --jump_backward
    ne = new_element("jump_backward", "button")
    ne.softrepeat = user_opts.jump_softrepeat
    ne.content = jump_icon[1]
    ne.eventresponder["mbtn_left_down"] = function () mp.commandv("seek", -jump_amount, jump_mode) end
    ne.eventresponder["mbtn_right_down"] = function () mp.commandv("seek", -jump_more_amount, jump_mode) end
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.commandv("frame-back-step") end

    --jump_forward
    ne = new_element("jump_forward", "button")
    ne.softrepeat = user_opts.jump_softrepeat
    ne.content = jump_icon[2]
    ne.eventresponder["mbtn_left_down"] = function () mp.commandv("seek", jump_amount, jump_mode) end
    ne.eventresponder["mbtn_right_down"] = function () mp.commandv("seek", jump_more_amount, jump_mode) end
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.commandv("frame-step") end

    --chapter_prev
    ne = new_element("chapter_prev", "button")
    ne.content = icons.rewind
    ne.enabled = have_ch -- disables button when no chapters available.
    bind_buttons("chapter_prev", true)

    --chapter_next
    ne = new_element("chapter_next", "button")
    ne.content = icons.forward
    ne.enabled = have_ch -- disables button when no chapters available.
    bind_buttons("chapter_next", true)

    --playlist
    ne = new_element("playlist", "button")
    ne.enabled = have_pl or not user_opts.hide_empty_playlist_button
    ne.off = not have_pl and user_opts.gray_empty_playlist_button
    ne.content = icons.playlist
    ne.tooltipF = function() return have_pl and locale.playlist .. " [" .. pl_pos .. "/" .. pl_count .. "]" or locale.playlist .. " / " .. locale.menu end
    ne.nothingavailable = locale.no_playlist
    bind_buttons("playlist")

    -- track tooltip helper
    local function track_tooltip(label, track_type, id_prop, count)
        local prop = mp.get_property("current-tracks/" .. track_type .. "/title") or mp.get_property("current-tracks/" .. track_type .. "/lang") or locale.unknown
        return label .. " [" .. mp.get_property_number(id_prop, "-") .. "/" .. count .. "] [" .. prop .. "]"
    end

    --audio_track
    ne = new_element("audio_track", "button")
    ne.enabled = state.audio_track_count > 0
    ne.off = state.audio_track_count == 0 or not mp.get_property_native("aid")
    ne.content = icons.audio
    ne.tooltipF = function () return track_tooltip(locale.audio, "audio", "aid", state.audio_track_count) end
    ne.nothingavailable = locale.no_audio
    bind_buttons("audio_track")

    --sub_track
    ne = new_element("sub_track", "button")
    ne.enabled = state.sub_track_count > 0
    ne.off = state.sub_track_count == 0 or not mp.get_property_native("sid")
    ne.content = icons.subtitle
    ne.tooltipF = function () return track_tooltip(locale.subtitle, "sub", "sid", state.sub_track_count) end
    ne.nothingavailable = locale.no_subs
    bind_buttons("sub_track")

    -- vol_ctrl
    ne = new_element("vol_ctrl", "button")
    ne.enabled = state.audio_track_count > 0
    ne.off = state.audio_track_count == 0
    ne.content = function ()
        local volume = state.volume
        return state.mute and icons.volume_mute or (volume >= 75 and icons.volume_high) or (volume >= 25 and icons.volume_low) or icons.volume_quiet
    end
    ne.tooltipF = function ()
        local volume = state.volume
        -- show only one decimal, if decimals exist
        local volume_str = (volume % 1 == 0) and string.format("%.0f", volume) or string.format("%.1f", volume)
        return locale.volume .. ": " .. volume_str .. (state.mute and " (" .. locale.muted .. ")" or "")
    end
    bind_buttons("vol_ctrl")

    --volumebar
    local volume_max_prop = mp.get_property_number("volume-max") or 0
    local volume_max = volume_max_prop > 0 and volume_max_prop or 100
    ne = new_element("volumebar", "slider")
    ne.enabled = state.audio_track_count > 0
    ne.slider = {min = {value = 0}, max = {value = volume_max}}
    ne.slider.markerF = function () return {} end
    ne.slider.seekRangesF = function() return nil end
    ne.slider.posF = function ()
        if user_opts.volume_control_type ~= "logarithmic" then return state.volume end
        return state.volume and math.sqrt(state.volume * 100) or 0
    end
    ne.eventresponder["mouse_move"] = function (element)
        local pos = get_slider_value(element)
        local setvol = set_volume(pos)
        if element.state.lastseek == nil or element.state.lastseek ~= setvol then
                mp.commandv("set", "volume", setvol)
                element.state.lastseek = setvol
        end
    end
    ne.eventresponder["mbtn_left_down"] = function (element)
        element.state.mbtnleft = true
        local pos = get_slider_value(element)
        if user_opts.volumebar_unmute_on_click then
            mp.set_property_bool("mute", false)
        end
        mp.commandv("set", "volume", set_volume(pos))
    end
    ne.eventresponder["mbtn_left_up"] = function (element)
        element.state.mbtnleft = false
        element.state.handle_drag = false
    end
    ne.eventresponder["reset"] = function (element)
        element.state.lastseek = nil
        element.state.mbtnleft = false
    end
    bind_buttons("volumebar")

    -- zoom in/out helper
    local function zoom_step(delta)
        local z = mp.get_property_number("video-zoom", 0)
        mp.commandv("osd-msg", "set", "video-zoom", math.max(user_opts.zoom_out_min, math.min(user_opts.zoom_in_max, z + delta)))
    end

    -- zoom out icon
    ne = new_element("zoom_out_icon", "button")
    ne.content = icons.zoom_out
    ne.tooltipF = locale.zoom_out
    ne.eventresponder["mbtn_left_up"] = function () zoom_step(-0.05) end
    ne.eventresponder["mbtn_right_up"] = function () mp.commandv("osd-msg", "set", "video-zoom", 0) end
    ne.eventresponder["wheel_up_press"] = function () zoom_step(0.05) end
    ne.eventresponder["wheel_down_press"] = function () zoom_step(-0.05) end

    -- zoom slider
    ne = new_element("zoom_control", "slider")
    ne.slider = {min = {value = user_opts.zoom_out_min}, max = {value = user_opts.zoom_in_max}}
    ne.slider.markerF = function () return {} end
    ne.slider.seekRangesF = function() return nil end
    ne.slider.posF = function () return mp.get_property_number("video-zoom") end
    ne.slider.tooltipF = function (pos) return string.format("%.3f", pos):gsub("%.?0*$", "") end
    ne.eventresponder["mouse_move"] = function (element)
        local pos = get_slider_value(element)
        if element.state.lastseek == nil or element.state.lastseek ~= pos then
                mp.commandv("osd-msg", "set", "video-zoom", pos)
                element.state.lastseek = pos
        end
    end
    ne.eventresponder["mbtn_left_down"] = function (element) mp.commandv("osd-msg", "set", "video-zoom", get_slider_value(element)) end
    ne.eventresponder["reset"] = function (element) element.state.lastseek = nil end
    ne.eventresponder["mbtn_right_up"] = function () mp.commandv("osd-msg", "set", "video-zoom", 0) end
    ne.eventresponder["wheel_up_press"] = function () zoom_step(0.05) end
    ne.eventresponder["wheel_down_press"]= function () zoom_step(-0.05) end

    -- zoom in icon
    ne = new_element("zoom_in_icon", "button")
    ne.content = icons.zoom_in
    ne.tooltipF = locale.zoom_in
    ne.eventresponder["mbtn_left_up"] = function () zoom_step(0.05) end
    ne.eventresponder["mbtn_right_up"] = function () mp.commandv("osd-msg", "set", "video-zoom", 0) end
    ne.eventresponder["wheel_up_press"] = function () zoom_step(0.05) end
    ne.eventresponder["wheel_down_press"]= function () zoom_step(-0.05) end

    --fullscreen
    ne = new_element("fullscreen", "button")
    ne.content = function() return state.fullscreen and icons.fullscreen_exit or icons.fullscreen end
    ne.tooltipF = function() return state.fullscreen and locale.fullscreen_exit or locale.fullscreen end
    bind_buttons("fullscreen")

    --info
    ne = new_element("info", "button")
    ne.content = icons.info
    ne.tooltipF = locale.stats_info
    bind_buttons("info")

    --ontop
    ne = new_element("ontop", "button")
    ne.content = function () return not state.ontop and icons.ontop_on or icons.ontop_off end
    ne.tooltipF = function ()
        if user_opts.ontop_in_topbar and window_controls_enabled() and state.ontop then return nil end
        return state.ontop and locale.ontop_disable or locale.ontop
    end
    bind_buttons("ontop")

    --screenshot
    ne = new_element("screenshot", "button")
    ne.content = icons.screenshot
    ne.tooltipF = locale.screenshot
    bind_buttons("screenshot")

    --file_loop
    ne = new_element("file_loop", "button")
    ne.content = function() return state.file_loop and icons.loop_on or icons.loop_off end
    ne.tooltipF = function() return state.file_loop and locale.file_loop_enable or locale.file_loop_disable end
    bind_buttons("file_loop")

    --shuffle
    ne = new_element("shuffle", "button")
    ne.content = function() return state.shuffled and icons.shuffle_on or icons.shuffle_off end
    ne.tooltipF = function() return state.shuffled and locale.shuffle or locale.unshuffle end
    ne.eventresponder["mbtn_left_up"] = function()
        mp.commandv("show-text", state.shuffled and locale.unshuffle or locale.shuffle, "-1", "1")
        state.shuffled = not state.shuffled
        mp.command("playlist-" .. (state.shuffled and "shuffle" or "unshuffle"))
    end

    --speed
    ne = new_element("speed", "button")
    ne.content = function() return string.format(state.speed % 1 == 0 and "%.1f×" or "%g×", state.speed) end
    ne.tooltipF = locale.speed_control
    bind_buttons("speed")

    --download
    ne = new_element("download", "button")
    ne.content = function () return state.downloading and icons.downloading or icons.download end
    ne.tooltipF = function () return state.downloading and locale.downloading .. "..." or locale.download .. " (" .. state.file_size_normalized .. ")" end
    ne.eventresponder["mbtn_left_up"] = function ()
        local localpath = mp.command_native({"expand-path", user_opts.download_path})

        if state.downloaded_once then
            mp.commandv("show-text", locale.downloaded, "-1", "1")
        elseif state.downloading then
            mp.commandv("show-text", locale.download_in_progress, "-1", "1")
        else
            mp.commandv("show-text", locale.downloading .. "...", "-1", "1")
            state.downloading = true
            local command = {
                "yt-dlp",
                state.is_image and "" or get_ytdl_format(),
                "--add-metadata",
                "--embed-subs",
                "-o", "%(title)s.%(ext)s",
                "-P", localpath,
                state.url_path
            }

            exec(command, download_done)
        end
    end

    -- cache info
    ne = new_element("cache_info", "button")
    ne.content = function ()
        if not cache_enabled() then return "" end
        local dcs = state.demuxer_cache_state
        local dmx_cache = state.dmx_cache
        local cache_state = dcs and dcs["cache-duration"]
        local thresh = math.min(dmx_cache * 0.05, 5)
        if cache_state and math.abs(cache_state - dmx_cache) >= thresh then
            dmx_cache = cache_state
            state.dmx_cache = cache_state
        end
        local min = math.floor(dmx_cache / 60)
        local sec = math.floor(dmx_cache % 60)
        local cache_time = (min > 0) and string.format("%sm%02ds", min, sec) or string.format("%3ds", sec)
        local cache_info = (mp.get_property_bool("paused-for-cache") == true) and (locale.buffering .. ": " .. (mp.get_property("cache-buffering-state") or 0) .. "%") or cache_time
        if not user_opts.cache_info_speed then return cache_info end
        local dmx_speed = (dcs and dcs["raw-input-rate"]) or 0
        local number, unit = utils.format_bytes_humanized(dmx_speed):match("([%d%.]+)%s*(%S+)")
        return cache_info .. "\\N" .. string.format("%8s %4s/s", number or 0, unit or "B")
    end
    ne.tooltipF = function() return cache_enabled() and locale.cache or nil end
    ne.eventresponder["mbtn_left_up"] = function() mp.command("script-binding stats/display-page-3") end

    --seekbar
    ne = new_element("seekbar", "slider")
    ne.enabled = mp.get_property("percent-pos") ~= nil
    ne.thumbnailable = true
    ne.slider.markerF = function ()
        if state.duration then
            local chapters = state.chapter_list
            local markers = {}
            for n = 1, #chapters do
                markers[n] = (chapters[n].time / state.duration * 100)
            end
            return markers
        else
            return {}
        end
    end
    ne.slider.posF = function ()
        if state.eof_reached then return 100 end
        return frame_number("percent-pos")
    end
    ne.slider.tooltipF = function (pos)
        if state.duration ~= nil and pos ~= nil then return format_time(state.duration * (pos / 100)) end
        return ""
    end
    ne.slider.seekRangesF = build_cache_seek_ranges
    ne.eventresponder["mouse_move"] = function (element)
        if not element.state.mbtnleft then return end -- allow drag for mbtnleft only!
        state.playing_and_seeking = true
        if not mp.get_property_bool("pause") and user_opts.mouse_seek_pause then
            mp.commandv("cycle", "pause")
        end
        local seekto = get_slider_value(element)
        if element.state.lastseek == nil or element.state.lastseek ~= seekto then
            local flags = "absolute-percent"
            if not user_opts.seekbarkeyframes then
                flags = flags .. "+exact"
            end
            mp.commandv("seek", seekto, flags)
            element.state.lastseek = seekto
        end
    end
    ne.eventresponder["mbtn_left_down"] = function (element)
        element.state.mbtnleft = true
        element.state.was_paused = mp.get_property_bool("pause")
        state.playing_and_seeking = false
        mp.commandv("seek", get_slider_value(element), "absolute-percent+exact")
    end
    ne.eventresponder["shift+mbtn_left_down"] = function (element)
        element.state.mbtnleft = true
        element.state.was_paused = mp.get_property_bool("pause")
        state.playing_and_seeking = false
        mp.commandv("seek", get_slider_value(element), "absolute-percent")
    end
    ne.eventresponder["mbtn_left_up"] = function (element)
        element.state.mbtnleft = false
        if state.playing_and_seeking then
            -- only unpause if the video was playing before the drag started
            if not element.state.was_paused and not mp.get_property_bool("eof-reached") and user_opts.mouse_seek_pause then
                mp.commandv("cycle", "pause")
            end
            state.playing_and_seeking = false
        end
    end
    ne.eventresponder["mbtn_right_down"] = function (element)
        local chapter
        local pos = get_slider_value(element)
        local diff = math.huge

        for i, marker in ipairs(element.slider.markerF()) do
            if math.abs(pos - marker) < diff then
                diff = math.abs(pos - marker)
                chapter = i
            end
        end

        if chapter then
            mp.set_property("chapter", chapter - 1)
        end
    end
    ne.eventresponder["reset"] = function (element)
        element.state.lastseek = nil
        if element.state.mbtnleft then
            element.state.mbtnleft = false
            if state.playing_and_seeking then
                if not element.state.was_paused and not mp.get_property_bool("eof-reached") and user_opts.mouse_seek_pause then
                    mp.commandv("cycle", "pause")
                end
                state.playing_and_seeking = false
            end
        end
    end
    bind_buttons("seekbar")

    --persistent seekbar
    ne = new_element("persistent_seekbar", "slider")
    ne.enabled = mp.get_property("percent-pos") ~= nil
    ne.slider.markerF = function () return {} end
    ne.slider.posF = function ()
        if state.eof_reached then return 100 end
        return frame_number("percent-pos")
    end
    ne.slider.tooltipF = function() return "" end
    ne.slider.seekRangesF = function()
        if user_opts.persistent_buffer then return build_cache_seek_ranges() end
        return nil
    end

    -- Time codes display
    ne = new_element("time_codes", "button")
    ne.content = function()
        local playback_time = frame_number("playback-time", 0)
        if not state.duration then return "--:--" end

        local playtime_remaining = state.tc_left_rem and frame_number("playtime-remaining", 0) or playback_time
        local prefix = state.tc_left_rem and (user_opts.unicodeminus and UNICODE_MINUS or "-") or ""

        -- call request_init() only when needed to update time code width
        if user_opts.time_format ~= "fixed" and playback_time then
            local hour_or_more = playback_time >= 3600
            if hour_or_more ~= state.playtime_hour_force_init then
                request_init()
                state.playtime_hour_force_init = hour_or_more
            end
        end

        local sep = state.glass_ui and ("{\\1c&H" .. osc_color_convert(user_opts.muted_text_color) .. "&}") or ""
        return prefix .. format_time(playtime_remaining) .. sep .. " / " .. format_time(state.duration)
    end
    ne.eventresponder["mbtn_left_up"] = function()
        state.tc_left_rem = not state.tc_left_rem
        request_init()
    end
    ne.eventresponder["mbtn_right_up"] = function()
        state.tc_ms = not state.tc_ms
        request_init()
    end

    -- the glass panel puts the times at the two ends of the seekbar
    local function hour_check(seconds)
        if user_opts.time_format ~= "fixed" and seconds then
            local hour_or_more = seconds >= 3600
            if hour_or_more ~= state.playtime_hour_force_init then
                request_init()
                state.playtime_hour_force_init = hour_or_more
            end
        end
    end
    ne = new_element("time_pos", "button")
    ne.content = function()
        if not state.duration then return "--:--" end
        local t = frame_number("playback-time", 0)
        hour_check(t)
        return format_time(t)
    end
    ne.eventresponder["mbtn_right_up"] = function()
        state.tc_ms = not state.tc_ms
        request_init()
    end
    ne = new_element("time_end", "button")
    ne.content = function()
        if not state.duration then return "--:--" end
        if state.tc_left_rem then
            return (user_opts.unicodeminus and UNICODE_MINUS or "-") .. format_time(frame_number("playtime-remaining", 0))
        end
        return format_time(state.duration)
    end
    ne.tooltipF = nil
    ne.eventresponder["mbtn_left_up"] = function()
        state.tc_left_rem = not state.tc_left_rem
        request_init()
    end
    ne.eventresponder["mbtn_right_up"] = function()
        state.tc_ms = not state.tc_ms
        request_init()
    end

    -- more: speed, chapters, loop, keep on top, screenshot, statistics
    ne = new_element("more", "button")
    ne.content = icons.more
    ne.tooltipF = locale.more
    ne.eventresponder["mbtn_left_up"] = function() open_menu("more", "more") end

    -- load layout (the glass panel sets these again)
    update_glass_look()
    glass_blur_install()
    state.glass_ui = false
    state.tooltip_y = nil
    state.panel_rect = nil
    state.wc_rect = nil
    state.wt_rect = nil
    if state.is_image then
        local glass = user_opts.layout == "default" or not layouts[user_opts.layout]
        layouts[glass and "glass-image" or "modern-image"]()
    elseif layouts[user_opts.layout] then
        layouts[user_opts.layout]()
    else
        layouts["default"]()
    end

    -- load window controls
    if window_controls_enabled() then
        window_controls()
    end

    -- cache seekbar elements
    state.persistent_seekbar_element = elements["persistent_seekbar"]
    state.seekbar_element = elements["seekbar"]

    prepare_elements()
    update_margins()
end

local function show_wc()
    show_bar("wc", "wc_showtime", "wc_visible", "wc_anitype", wc_visible)
end

local function hide_wc()
    hide_bar("wc", "wc_visible", "wc_anitype", wc_visible)
end

local function show_osc()
    if state.idle_active then return end
    -- the pointer is probably heading for the seekbar: let thumbz get ready
    if not state.osc_visible and not thumbz.disabled then
        mp.commandv("script-message-to", "thumbz", "prepare")
    end
    show_bar("osc", "showtime", "osc_visible", "anitype", osc_visible)
end

local function hide_osc()
    close_menu()
    -- clear any pending thumbnail before hiding
    thumbz_hide()
    -- clear input area immediately so clicks pass through while the bar is
    -- hidden, rather than waiting for the next render tick to do it
    set_virt_mouse_area(0, 0, 0, 0, "input")
    -- reset margins before hide_bar wipes the overlay
    if not state.enabled then
        reset_margins()
    end
    hide_bar("osc", "osc_visible", "anitype", osc_visible)
end

local function mouse_leave()
    -- leaving the bottom bar's area with a menu open is fine, as long as the pointer is in the window
    if menu then
        local mp_pos = mp.get_property_native("mouse-pos")
        if mp_pos and mp_pos.hover then return end
    end
    if get_hidetimeout() >= 0 and get_touchtimeout() <= 0 then
        if user_opts.deadzone_hide == "timeout" then
            local now = mp.get_time()
            if state.osc_visible and not state.keeponpause_active then
                state.showtime = now
            end
            if state.wc_visible then
                state.wc_showtime = now
            end
            request_tick()
        else
            if not state.keeponpause_active then hide_osc() end
            hide_wc()
        end
    end
    -- reset mouse position
    state.last_mouseX, state.last_mouseY = nil, nil
    state.mouse_in_window = false
end

local function handle_touch(_, touchpoints)
    --remember last touch points
    if touchpoints then
        state.touchpoints = touchpoints
        if #touchpoints > 0 then
            --remember last time of invocation (touch event)
            state.touchtime = mp.get_time()
            state.last_touchX = touchpoints[1].x
            state.last_touchY = touchpoints[1].y
        end
    end
end

--
-- Event handling
--
local function reset_timeout()
    local now = mp.get_time()
    if window_controls_enabled() and user_opts.windowcontrols_independent then
        -- only reset the timer for the bar the event belongs to
        if mouse_in_area({"window-controls", "window-controls-title", "window-controls-ontop"}) then
            state.wc_showtime = now
        else
            state.showtime = now
        end
    else
        state.showtime = now
        state.wc_showtime = now
    end
end

local function element_has_action(element, action)
    return element and element.eventresponder and element.eventresponder[action]
end

-- dynamically sets the "input" mouse area to only the hovered element
local click_keys = {
    "mbtn_left_up", "mbtn_left_down", "mbtn_left_press",
    "mbtn_right_up", "mbtn_right_down", "mbtn_right_press",
    "wheel_up_press", "wheel_down_press",
}
local function has_click_action(e)
    if not e.eventresponder then return false end
    for _, k in ipairs(click_keys) do
        if e.eventresponder[k] then return true end
    end
    return false
end

local function refresh_input_area()
    if not state.osc_visible then
        set_virt_mouse_area(0, 0, 0, 0, "input")
        return
    end

    -- with a menu open every click is ours (a click outside the menu closes it)
    if menu then
        set_virt_mouse_area(0, 0, osc_param.playresx, osc_param.playresy, "input")
        set_virt_mouse_area(0, 0, osc_param.playresx, osc_param.playresy, "menu-hover")
        return
    end

    -- during an active drag, keep the input area locked to the held element
    if state.active_element and elements[state.active_element] then
        local e = elements[state.active_element]
        set_virt_mouse_area(e.hitbox.x1, e.hitbox.y1, e.hitbox.x2, e.hitbox.y2, "input")
        return
    end

    -- bail early if the cursor isn't inside the bottom bar zone at all
    if not mouse_in_area("input") then
        set_virt_mouse_area(0, 0, 0, 0, "input")
        return
    end

    -- find the topmost element with direct click handlers under the cursor;
    -- layer order matches process_event's dispatch priority
    local hovered = nil
    for n = 1, #elements do
        local e = elements[n]
        if e.hitbox and has_click_action(e) and mouse_hit(e) then
            hovered = e
        end
    end

    if hovered then
        set_virt_mouse_area(hovered.hitbox.x1, hovered.hitbox.y1, hovered.hitbox.x2, hovered.hitbox.y2, "input")
    else
        set_virt_mouse_area(0, 0, 0, 0, "input")
    end
end

-- re-apply the cursor-hide flag to the OSC input sections that are currently enabled.
-- held = true drops the flag so the cursor stays visible while a button/slider is held.
local function apply_cursor_hide_flag(held)
    local flag = (not held) and state.cursor_hide_flag or nil
    if state.input_enabled then mp.enable_key_bindings("input", flag) end
    if state.windowcontrols_buttons then mp.enable_key_bindings("window-controls", flag) end
    if state.windowcontrols_ontop then mp.enable_key_bindings("window-controls-ontop", flag) end
end

local function process_event(source, what)
    frame_cache = nil  -- input is handled with live values
    local action = string.format("%s%s", source, what and ("_" .. what) or "")

    -- an open menu takes the clicks and the wheel (a click outside closes it)
    if menu_event(source, what) then
        reset_timeout()
        request_tick()
        return
    end

    if what == "down" or what == "press" then
        reset_timeout() -- clicking resets the hideosc timer

        for n = 1, #elements do
            if mouse_hit(elements[n]) and
                elements[n].eventresponder and
                (elements[n].eventresponder[source .. "_up"] or
                    elements[n].eventresponder[action]) then

                if what == "down" then
                    state.active_element = n
                    state.active_event_source = source
                    if state.cursor_hide_flag then apply_cursor_hide_flag(true) end
                end
                -- fire the down or press event if the element has one
                if element_has_action(elements[n], action) then
                    elements[n].eventresponder[action](elements[n])
                end
            end
        end
    elseif what == "up" then
        if elements[state.active_element] then
            local n = state.active_element

            if n == 0 then
                --click on background (does not work)
            elseif element_has_action(elements[n], action) and
                mouse_hit(elements[n]) then

                elements[n].eventresponder[action](elements[n])
            end

            --reset active element
            if element_has_action(elements[n], "reset") then
                elements[n].eventresponder["reset"](elements[n])
            end
        end
        if state.active_element and state.cursor_hide_flag then
            -- button released: let the cursor autohide again
            apply_cursor_hide_flag(false)
        end
        state.active_element = nil
        state.mouse_down_counter = 0
    elseif source == "mouse_move" then
        state.mouse_in_window = true

        local mouseX, mouseY = get_virt_mouse_pos()
        if user_opts.minmousemove == 0 or
            ((state.last_mouseX ~= nil and state.last_mouseY ~= nil) and
                (math.abs(mouseX - state.last_mouseX) >= user_opts.minmousemove or
                 math.abs(mouseY - state.last_mouseY) >= user_opts.minmousemove)) then
            if window_controls_enabled() and user_opts.windowcontrols_independent then
                if mouse_in_area("showhide_wc") then
                    show_wc()
                elseif user_opts.visibility ~= "always" and user_opts.deadzone_hide ~= "timeout" then
                    hide_wc()
                end
                if mouse_in_area("showhide") or menu then
                    show_osc()
                elseif user_opts.visibility ~= "always" and not state.keeponpause_active and user_opts.deadzone_hide ~= "timeout" then
                    hide_osc()
                end
            else
                show_osc()
                if window_controls_enabled() then show_wc() end
            end
        end
        state.last_mouseX, state.last_mouseY = mouseX, mouseY

        local n = state.active_element
        if element_has_action(elements[n], action) then
            elements[n].eventresponder[action](elements[n])
        end

        -- update input area to follow the cursor so only the element
        -- currently under it captures clicks; empty space passes through
        refresh_input_area()
    end

    -- ensure rendering after any (mouse) event - icons could change etc
    request_tick()
end

local function do_enable_keybindings()
    if state.enabled then
        if not state.showhide_enabled then
            mp.enable_key_bindings("showhide", "allow-vo-dragging+allow-hide-cursor")
            mp.enable_key_bindings("showhide_wc", "allow-vo-dragging+allow-hide-cursor")
        end
        state.showhide_enabled = true
    end
end

local function enable_osc(enable)
    state.enabled = enable
    if enable then
        do_enable_keybindings()
    else
        hide_osc() -- acts immediately when state.enabled == false
        hide_wc()
        if state.showhide_enabled then
            mp.disable_key_bindings("showhide")
            mp.disable_key_bindings("showhide_wc")
        end
        state.showhide_enabled = false
    end
end

local function render()
    msg.trace("rendering")
    menu_frame = menu_frame + 1
    frame_cache = {}
    local current_screen_sizeX = state.osd_dimensions.w
    local current_screen_sizeY = state.osd_dimensions.h
    local mouseX, mouseY = get_virt_mouse_pos()
    local now = mp.get_time()

    -- check if display changed, if so request reinit
    if state.screen_sizeX ~= current_screen_sizeX or state.screen_sizeY ~= current_screen_sizeY then
        request_init_resize()

        state.screen_sizeX = current_screen_sizeX
        state.screen_sizeY = current_screen_sizeY
    end

    -- init management
    if state.active_element then
        -- mouse is held down on some element - keep ticking and ignore initReq
        -- till it's released, or else the mouse-up (click) will misbehave or
        -- get ignored. that's because osc_init() recreates the osc elements,
        -- but mouse handling depends on the elements staying unmodified
        -- between mouse-down and mouse-up (using the index active_element).
        request_tick()
    elseif state.initREQ then
        osc_init()
        state.initREQ = false

        -- store initial mouse position
        if (state.last_mouseX == nil or state.last_mouseY == nil) and not (mouseX == nil or mouseY == nil or mouseX == -1 or mouseY == -1) then
            state.last_mouseX, state.last_mouseY = mouseX, mouseY
        end
    end

    -- fade animation
    local function run_fade(anitype_key, anistart_key, animation_key, set_visible)
        local anitype = state[anitype_key]
        if anitype == nil then
            kill_animation(anitype_key, anistart_key, animation_key)
            return
        end
        if state[anistart_key] == nil then state[anistart_key] = now end
        local fadelen = user_opts.fadeduration / 1000
        if now < state[anistart_key] + fadelen then
            -- eased: quick to appear and settling gently, gentle to start leaving
            local p = (now - state[anistart_key]) / fadelen
            if anitype == "in" then
                set_visible(true)
                state[animation_key] = 255 * (1 - p) ^ 3
            elseif anitype == "out" then
                state[animation_key] = 255 * p * p
            end
        else
            if anitype == "out" then set_visible(false) end
            kill_animation(anitype_key, anistart_key, animation_key)
        end
    end
    run_fade("anitype",    "anistart",    "animation",    osc_visible)
    run_fade("wc_anitype", "wc_anistart", "wc_animation", wc_visible)

    --mouse show/hide area
    for _, cords in pairs(osc_param.areas["showhide"]) do
        set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "showhide")
    end
    if osc_param.areas["showhide_wc"] then
        for _, cords in pairs(osc_param.areas["showhide_wc"]) do
            set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "showhide_wc")
        end
    else
        set_virt_mouse_area(0, 0, 0, 0, "showhide_wc")
    end
    do_enable_keybindings()

    --mouse input area
    local function update_input_area(area_name, visible, enabled_key, enable_fn)
        local areas = osc_param.areas[area_name]
        if not areas then return end
        for _, cords in ipairs(areas) do
            if visible then
                set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, area_name)
            end
            if visible ~= state[enabled_key] then
                if visible then enable_fn() else mp.disable_key_bindings(area_name) end
                state[enabled_key] = visible
            end
        end
    end

    -- sync input area to cursor position
    if state.osc_visible ~= state.input_enabled then
        if state.osc_visible then
            mp.enable_key_bindings("input", state.cursor_hide_flag)
        else
            mp.disable_key_bindings("input")
        end
        state.input_enabled = state.osc_visible
    end
    refresh_input_area()

    update_input_area("window-controls", state.wc_visible, "windowcontrols_buttons", function() mp.enable_key_bindings("window-controls", state.cursor_hide_flag) end)
    update_input_area("window-controls-title", state.wc_visible, "windowcontrols_title", function() mp.enable_key_bindings("window-controls-title", state.cursor_hide_flag and "allow-vo-dragging+allow-hide-cursor" or "allow-vo-dragging") end)
    update_input_area("window-controls-ontop", state.wc_visible, "windowcontrols_ontop", function() mp.enable_key_bindings("window-controls-ontop", state.cursor_hide_flag) end)

    -- autohide
    local function run_autohide(showtime_key, hide_fn, input_areas)
        local hide_timeout = get_hidetimeout()
        if state[showtime_key] == nil or hide_timeout < 0 then return end
        local timeout = state[showtime_key] + (hide_timeout / 1000) - now
        if timeout <= 0 and get_touchtimeout() <= 0 then
            -- a hold in the bottom bar should not prevent the top bar from hiding, and vice versa.
            local element_blocks_hide = state.active_element ~= nil and mouse_in_area(input_areas)
            if not element_blocks_hide and (not user_opts.keep_with_cursor or not mouse_in_area(input_areas)) then
                hide_fn()
            end
        else
            if not state.hide_timer then
                state.hide_timer = mp.add_timeout(0, tick)
            end
            if timeout < state.hide_timer.timeout then
                state.hide_timer.timeout = timeout
                state.hide_timer:kill()
                state.hide_timer:resume()
            end
        end
    end

    local osc_areas = {"input"}
    local wc_areas  = {"window-controls", "window-controls-title", "window-controls-ontop"}
    if not user_opts.windowcontrols_independent then
        osc_areas = {"input", "window-controls", "window-controls-title", "window-controls-ontop"}
        wc_areas = osc_areas
    end

    if state.hide_timer then state.hide_timer.timeout = math.huge end
    if menu then state.showtime = now end -- an open menu keeps the controls up
    if not state.keeponpause_active then
        run_autohide("showtime", hide_osc, osc_areas)
    end
    run_autohide("wc_showtime", hide_wc, wc_areas)

    -- a closed menu fades for 0.12 s; one more redraw once it has gone
    if menu_closing and (not state.osc_visible or mp.get_time() - menu_closing.closing >= 0.12) then
        menu_closing = nil
        request_tick()
    end

    -- blur the video behind the visible glass surfaces (vo=gpu-next)
    if glass_blur.path then
        local rects = {}
        if glass_blur_active() and state.glass_ui and not state.idle_active then
            -- the frost fades in and out with its surface
            local p = state.panel_rect
            if p and state.osc_visible then
                rects[#rects + 1] = {p.x1, p.y1, p.x2 - p.x1, p.y2 - p.y1, p.r, 1 - (state.animation or 0) / 255}
            end
            for _, key in ipairs({"wc_rect", "wt_rect"}) do
                local w = state[key]
                if w and state.wc_visible then
                    rects[#rects + 1] = {w.x1, w.y1, w.x2 - w.x1, w.y2 - w.y1, w.r, 1 - (state.wc_animation or 0) / 255}
                end
            end
        end
        local m = menu or menu_closing
        local g = m and state.osc_visible and glass_blur_active() and menu_visual_rect(m)
        if g then rects[#rects + 1] = g end
        glass_blur_update(rects)
    end

    -- actual rendering
    local ass = assdraw.ass_new()

    if state.osc_visible or state.wc_visible then
        render_elements(ass, state.osc_visible, state.wc_visible)
    end

    if menu then
        if state.osc_visible then render_menu(ass, menu) else close_menu() end
    end
    if menu_closing and state.osc_visible then render_menu(ass, menu_closing) end
    menu_covers_sync()

    if user_opts.persistent_progress or state.persistent_progress_toggle then
        render_persistent_progress(ass)
    end

    -- submit
    set_osd(state.osd, osc_param.playresy * osc_param.display_aspect, osc_param.playresy, ass.text, 1000)
    frame_cache = nil
end

-- called by mpv on every frame
tick = function()
    if state.marginsREQ == true then
        update_margins()
        state.marginsREQ = false
    end

    if not state.enabled then return end

    if state.idle_active then
        -- the idle screen doesn't draw menus: close one left open so its keys and covers go
        if menu then close_menu() end
        msg.trace("idle message")
        if user_opts.idlescreen then
            local display_aspect = state.osd_dimensions.aspect
            if display_aspect == 0 then return end
            local display_h = 360
            local display_w = display_h * display_aspect
            -- logo is rendered at 2^(6-1) = 32 times resolution with size 1800x1800
            local icon_x, icon_y = (display_w - 1800 / 32) / 2, 140
            local line_prefix = ("{\\rDefault\\an7\\1a&H00&\\bord0\\shad0\\pos(%f,%f)}"):format(icon_x, icon_y)

            local ass = assdraw.ass_new()
            -- mpv logo
            for _, line in ipairs(logo_lines) do
                ass:new_event()
                ass:append(line_prefix .. line)
            end

            -- Santa hat
            if is_december and not user_opts.greenandgrumpy then
                for _, line in ipairs(santa_hat_lines) do
                    ass:new_event()
                    ass:append(line_prefix .. line)
                end
            end

            ass:new_event()
            ass:pos(display_w / 2, icon_y + 65)
            ass:an(8)
            ass:append("{\\fs24\\1c&HFFFFFF&}" .. locale.idle)
            set_osd(state.logo_osd, display_w, display_h, ass.text, -1000)
        end

        if state.osc_visible then
            osc_visible(false)
        end

        if window_controls_enabled() then
            render()
        else
            render_wipe(state.osd)
            if state.showhide_enabled then
                mp.disable_key_bindings("showhide")
                mp.disable_key_bindings("showhide_wc")
                state.showhide_enabled = false
            end
        end
    elseif (state.fullscreen and user_opts.showfullscreen) or (not state.fullscreen and user_opts.showwindowed) then
        render_wipe(state.logo_osd)
        render()
    else
        -- Flush OSD
        render_wipe(state.osd)
        render_wipe(state.logo_osd)
    end

    state.tick_last_time = mp.get_time()

    local function tick_animation(anitype_key, anistart_key, animation_key, allow_idle)
        if state[anitype_key] ~= nil then
            if (allow_idle or not state.idle_active) and
               (not state[anistart_key] or
                mp.get_time() < 1 + state[anistart_key] + user_opts.fadeduration / 1000)
            then
                request_tick()
            else
                kill_animation(anitype_key, anistart_key, animation_key)
            end
        end
    end
    tick_animation("anitype",    "anistart",    "animation")
    tick_animation("wc_anitype", "wc_anistart", "wc_animation", window_controls_enabled())
end

local function set_tick_delay(_, display_fps)
    -- may be nil if unavailable, and 0 or NaN when mpv can't tell the refresh rate
    if not user_opts.tick_delay_follow_display_fps or type(display_fps) ~= "number"
        or display_fps ~= display_fps or display_fps < 1 or display_fps > 1000 then
        tick_delay = user_opts.tick_delay
        return
    end
    tick_delay = 1 / display_fps
end

mp.register_event("shutdown", function()
    reset_margins()
    mp.del_property("user-data/osc")
end)
mp.register_event("file-loaded", function()
    is_image() -- check if file is an image
    state.file_loaded = true
    check_path_url()
    local oos = user_opts.osc_on_start
    if oos == "bottom" or oos == "both" then show_osc() end
    if oos == "top" or oos == "both" then show_wc() end
end)
mp.register_event("start-file", function()
    -- reset ab loop on new file start
    mp.set_property("ab-loop-a", "no")
    mp.set_property("ab-loop-b", "no")
    request_init()
end)
mp.observe_property("track-list", "native", update_tracklist)
observe_cached("playlist-count", request_init)
observe_cached("playlist-pos-1", request_init)
observe_cached("chapter-list", function ()
    state.chapter_list = state.chapter_list or {}
    table.sort(state.chapter_list, function(a, b) return a.time < b.time end)
    request_init()
end)
observe_cached("duration", function ()
    if user_opts.automatickeyframemode then
        user_opts.seekbarkeyframes = (state.duration or 0) > user_opts.automatickeyframelimit
    end
    if user_opts.livemarkers and state.chapter_list[1] then
        request_init()
    end
end)
mp.register_event("seek", function()
    if state.file_loaded then
        state.file_loaded = false
        return
    end
    if user_opts.osc_on_seek and not (state.file_loop and mp.get_property_number("time-pos", -1) == 0) then
        show_osc()
    end
end)
mp.observe_property("seeking", "native", function(_, seeking)
    if user_opts.osc_on_seek then
        reset_timeout()
    end
end)
observe_cached("fullscreen", function ()
    state.marginsREQ = true
    request_init_resize()
end)
observe_cached("border", request_init_resize)
observe_cached("title-bar", request_init_resize)
observe_cached("window-maximized", request_init_resize)
observe_cached("idle-active", request_tick)
mp.observe_property("user-data/mpv/console/open", "bool", function(_, val)
    if val and user_opts.visibility == "auto" and not user_opts.showonselect and not state.keeponpause_active then
        -- clear pending thumbnail
        thumbz_hide()
        osc_visible(false)
        wc_visible(false)
    end
end)
mp.observe_property("display-fps", "number", set_tick_delay)
mp.observe_property("display-hidpi-scale", "number", function() request_init_resize() end)
observe_cached("demuxer-cache-state", request_tick)
mp.observe_property("vo-configured", "bool", request_tick)
mp.observe_property("playback-time", "number", request_tick)
observe_cached("osd-dimensions", request_init_resize)
mp.observe_property("video-params", "native", function(_, vp)
    if not vp then return end -- briefly unset while the video reconfigures
    local rotated = (vp.rotate or 0) % 360 ~= 0
    if rotated ~= glass_blur.rotated then
        glass_blur.rotated = rotated
        request_init()
    end
end)
observe_cached("osd-scale-by-window", request_init_resize)
mp.observe_property("touch-pos", "native", handle_touch)
observe_cached("volume", request_tick)
observe_cached("mute", request_tick)
observe_cached("eof-reached", request_tick)
observe_cached("ontop", request_init)
observe_cached("speed", request_tick)
-- the layout reserves a chapter title row only while inside a chapter, so rebuild it
-- when playback enters or leaves the chapter range (e.g. starting before the first chapter)
mp.observe_property("chapter", "native", function(_, value)
    local was_in_chapter = (state.chapter or -1) >= 0
    state.chapter = value
    if user_opts.show_chapter_title and was_in_chapter ~= ((value or -1) >= 0) then
        request_init()
    else
        request_tick()
    end
end)
-- redraw the A-B loop range when loop points change, even while paused
mp.observe_property("ab-loop-a", "native", request_tick)
mp.observe_property("ab-loop-b", "native", request_tick)
-- ensure compatibility with auto loop scripts
mp.observe_property("loop-file", "bool", function(_, val)
    state.file_loop = (val ~= false)
end)
mp.observe_property("sub-pos", "native", function(_, value)
    if value == nil then return end
    if state.osc_adjusted_subpos == nil or value ~= state.osc_adjusted_subpos then
        state.user_subpos = value
    end
end)

-- mouse show/hide bindings
mp.set_key_bindings({
    {"mouse_move",              function() process_event("mouse_move", nil) end},
    {"mouse_leave",             mouse_leave},
}, "showhide", "force")
mp.set_key_bindings({
    {"mouse_move",              function() process_event("mouse_move", nil) end},
    {"mouse_leave",             mouse_leave},
}, "showhide_wc", "force")
-- while a menu is open: pointer moves over the whole window
mp.set_key_bindings({
    {"mouse_move",              function() process_event("mouse_move", nil) end},
}, "menu-hover", "force")
do_enable_keybindings()

--mouse input bindings
mp.set_key_bindings({
    {"mbtn_left",           function() process_event("mbtn_left", "up") end,
                            function() process_event("mbtn_left", "down")  end},
    {"shift+mbtn_left",     function() process_event("shift+mbtn_left", "up") end,
                            function() process_event("shift+mbtn_left", "down")  end},
    {"mbtn_right",          function() process_event("mbtn_right", "up") end,
                            function() process_event("mbtn_right", "down")  end},
    {"shift+mbtn_right",    function() process_event("shift+mbtn_right", "up") end,
                            function() process_event("shift+mbtn_right", "down")  end},
    -- alias to shift_mbtn_left for single-handed mouse use
    {"mbtn_mid",            function() process_event("shift+mbtn_left", "up") end,
                            function() process_event("shift+mbtn_left", "down")  end},
    {"wheel_up",            function() process_event("wheel_up", "press") end},
    {"wheel_down",          function() process_event("wheel_down", "press") end},
    {"mbtn_left_dbl",       "ignore"},
    {"shift+mbtn_left_dbl", "ignore"},
    {"mbtn_right_dbl",      "ignore"},
}, "input", "force")
mp.enable_key_bindings("input", state.cursor_hide_flag)

mp.set_key_bindings({
    {"mbtn_left",           function() process_event("mbtn_left", "up") end,
                            function() process_event("mbtn_left", "down")  end},
}, "window-controls", "force")
mp.enable_key_bindings("window-controls", state.cursor_hide_flag)

mp.set_key_bindings({
    {"mbtn_left",           function() process_event("mbtn_left", "up") end,
                            function() process_event("mbtn_left", "down")  end},
}, "window-controls-ontop", "force")
set_virt_mouse_area(0, 0, 0, 0, "window-controls-ontop")

local function always_on(val)
    if state.enabled then
        if val then
            show_osc()
            show_wc()
        else
            hide_osc()
            hide_wc()
        end
    end
end

-- mode can be auto/always/never/cycle
-- the modes only affect internal variables and not stored on its own.
local function visibility_mode(mode, no_osd)
    if mode == "cycle" then
        for i, allowed_mode in ipairs(state.visibility_modes) do
            if i == #state.visibility_modes then
                mode = state.visibility_modes[1]
                break
            elseif user_opts.visibility == allowed_mode then
                mode = state.visibility_modes[i + 1]
                break
            end
        end
    end

    if mode == "auto" then
        always_on(false)
        enable_osc(true)
    elseif mode == "always" then
        enable_osc(true)
        always_on(true)
    elseif mode == "never" then
        enable_osc(false)
    else
        msg.warn("Ignoring unknown visibility mode '" .. mode .. "'")
        return
    end

    user_opts.visibility = mode
    mp.set_property_native("user-data/osc/visibility", mode)

    if not no_osd and tonumber(mp.get_property("osd-level")) >= 1 then
        mp.osd_message("OSC visibility: " .. mode)
    end

    -- Reset the input state on a mode change. The input state will be
    -- recalculated on the next render cycle, except in 'never' mode where it
    -- will just stay disabled.
    mp.disable_key_bindings("input")
    mp.disable_key_bindings("window-controls")
    mp.disable_key_bindings("window-controls-title")
    mp.disable_key_bindings("window-controls-ontop")
    state.input_enabled = false
    state.windowcontrols_buttons = false
    state.windowcontrols_title = false
    state.windowcontrols_ontop = false

    update_margins()
    request_tick()
end

local function idlescreen_visibility(mode, no_osd)
    if mode == "cycle" then
        mode = user_opts.idlescreen and "no" or "yes"
    end

    user_opts.idlescreen = (mode == "yes")

    mp.set_property_native("user-data/osc/idlescreen", user_opts.idlescreen)

    if not no_osd and tonumber(mp.get_property("osd-level")) >= 1 then
        mp.osd_message("OSC logo visibility: " .. tostring(mode))
    end

    request_tick()
end

mp.observe_property("pause", "bool", function(_, enabled)
    state.pause = (enabled == true)
    request_tick()
    if user_opts.showonpause and user_opts.visibility ~= "never" then
        state.enabled = enabled
        if enabled then
            if user_opts.keeponpause == "both" then
                -- save mode and set visibility to "always" temporarily
                if not state.keeponpause_restore and user_opts.visibility ~= "always" then
                    state.keeponpause_restore = user_opts.visibility
                end
                visibility_mode("always", true)
            elseif user_opts.keeponpause == "bottombar" then
                state.keeponpause_active = true
                show_osc()
            else
                show_osc()
            end
        else
            -- clear keeponpause bottombar active state
            state.keeponpause_active = false
            -- restore mode if it was changed by keeponpause=both
            if state.keeponpause_restore then
                visibility_mode(state.keeponpause_restore, true)
                state.keeponpause_restore = nil
            else
                -- respect "always" mode on unpause
                visibility_mode(user_opts.visibility, true)
            end
            -- reset timers so both bars get a fresh hidetimeout on unpause
            local now = mp.get_time()
            if state.osc_visible then state.showtime = now end
            if state.wc_visible then state.wc_showtime = now end
        end
    end
end)

mp.register_script_message("osc-visibility", visibility_mode)
-- for input.conf: script-message-to modernz open-menu <audio|sub|playlist|chapter|audio-device>
mp.register_script_message("open-menu", function(kind)
    -- with no OSC to draw it on, the menu would stay invisible and keep its keys bound
    if not state.enabled or state.idle_active then return end
    show_osc()
    open_menu(kind, nil)
end)
-- for input.conf: script-message-to modernz screenshot [video|subtitles|window]
-- takes the screenshot without the glass blur in it
mp.register_script_message("screenshot", function(mode)
    screenshot_without_glass("osd-msg screenshot " .. (mode or "subtitles"))
end)
mp.register_script_message("osc-show", show_osc)
mp.register_script_message("osc-hide", function()
    if user_opts.visibility == "auto" then
        hide_osc()
        hide_wc()
    end
end)
mp.add_key_binding(nil, "visibility", function() visibility_mode("cycle") end)
mp.add_key_binding(nil, "progress-toggle", function()
    user_opts.persistent_progress = not user_opts.persistent_progress
    state.persistent_progress_toggle = user_opts.persistent_progress
    request_init()
end)
mp.register_script_message("osc-idlescreen", idlescreen_visibility)
mp.register_script_message("thumbz-info", function(json)
    local data = utils.parse_json(json)
    if type(data) ~= "table" or not data.width or not data.height then
        msg.error("thumbz-info: received json didn't produce a table with thumbnail information")
        return
    end
    thumbz.width, thumbz.height, thumbz.disabled = data.width, data.height, data.disabled
    thumbz.present = true
    -- the OSC may already be up (e.g. osc_on_start): let thumbz get ready right away
    if state.osc_visible and not thumbz.disabled then
        mp.commandv("script-message-to", "thumbz", "prepare")
    end
end)

mp.register_script_message("thumbz-cover", function(path, file)
    menu_cover_ready(path, file)
end)

-- validate string type user options
local function validate_user_opts()
    if not language[user_opts.language] then
       msg.warn("language '" .. user_opts.language .. "' not found. Ignoring.")
       user_opts.language = "default"
       if not language["default"] then
          msg.warn("ERROR: can't find the default language or the one set by user_opts.")
       end
    end

    if user_opts.seek_handle_size < 0 then
        msg.warn("seek_handle_size must be 0 or higher. Setting it to 0 (minimum).")
        user_opts.seek_handle_size = 0
    end

    local function validate_string_opt(key, valid, default)
        for _, v in ipairs(valid) do
            if user_opts[key] == v then return end
        end
        msg.warn(key .. " value '" .. tostring(user_opts[key]) .. "' is invalid. Resetting to '" .. default .. "'.")
        user_opts[key] = default
    end
    validate_string_opt("window_top_bar", {"auto", "yes", "no"}, "auto")
    validate_string_opt("volume_control_type", {"linear", "logarithmic"}, "linear")
    validate_string_opt("keeponpause",  {"no", "bottombar", "both"}, "no")
    validate_string_opt("deadzone_hide", {"instant", "timeout"}, "instant")

    local hbc = user_opts.seek_handle_border_color
    if hbc == "disable" then
        hbc = ""
    elseif hbc ~= "" and hbc:find("^#%x%x%x%x%x%x$") == nil then
        msg.warn("'" .. hbc .. "' is not a valid color for seek_handle_border_color, border disabled")
        hbc = ""
    end
    user_opts.seek_handle_border_color = hbc

    local colors = {
        user_opts.osc_color, user_opts.seekbarfg_color, user_opts.seekbarbg_color, user_opts.title_color, user_opts.time_color,
        user_opts.side_buttons_color, user_opts.middle_buttons_color, user_opts.playpause_color, user_opts.window_title_color,
        user_opts.window_controls_color, user_opts.held_element_color, user_opts.thumbnail_box_color, user_opts.chapter_title_color,
        user_opts.seekbar_cache_color, user_opts.hover_effect_color, user_opts.windowcontrols_close_hover, user_opts.windowcontrols_max_hover,
        user_opts.windowcontrols_min_hover, user_opts.cache_info_color, user_opts.thumbnail_box_outline, user_opts.nibble_color,
        user_opts.nibble_current_color, user_opts.seek_handle_color, user_opts.ab_loop_color,
    }

    for _, color in pairs(colors) do
        if color:find("^#%x%x%x%x%x%x$") == nil then
            msg.warn("'" .. color .. "' is not a valid color")
        end
    end

    state.visibility_modes = {}
    for str in string.gmatch(user_opts.visibility_modes, "([^_]+)") do
        if str ~= "auto" and str ~= "always" and str ~= "never" then
            msg.warn("Ignoring unknown visibility mode '" .. str .."' in list")
        else
            table.insert(state.visibility_modes, str)
        end
    end

    if user_opts.keeponpause ~= "no" and not user_opts.showonpause then
        msg.warn("keeponpause requires showonpause. Setting showonpause=yes.")
        user_opts.showonpause = true
    end

    -- with keep_with_cursor=no, let mpv's cursor-autohide work while hovering the OSC
    state.cursor_hide_flag = (not user_opts.keep_with_cursor) and "allow-hide-cursor" or nil

    local watch_later = "," .. ((mp.get_property("options/watch-later-options") or ""):gsub("%s+", "")) .. ","
    if user_opts.sub_margins and watch_later:find(",sub-pos,", 1, true) then
        msg.warn("sub_margins conflict: add watch-later-options-remove=sub-pos to mpv.conf")
    end
    if user_opts.osd_margins and watch_later:find(",osd-margin-y,", 1, true) then
        msg.warn("osd_margins conflict: add watch-later-options-remove=osd-margin-y to mpv.conf")
    end
end

-- read options from config and command-line
opt.read_options(user_opts, "modernz", function(changed)
    if changed.language then load_locale_file() end
    validate_user_opts()
    if changed.keep_with_cursor then apply_cursor_hide_flag(false) end
    if changed.language then set_osc_locale() end
    set_icon_theme()
    set_osc_styles()
    set_time_styles(changed.timecurrent, changed.timems)
    if changed.tick_delay or changed.tick_delay_follow_display_fps then
        set_tick_delay("display_fps", mp.get_property_number("display_fps"))
    end
    request_tick()
    if changed.visibility then
        visibility_mode(user_opts.visibility, true)
    end
    request_init()
end)

load_locale_file()
validate_user_opts()
set_osc_locale()
set_icon_theme()
set_osc_styles()
set_time_styles(true, true)
set_tick_delay()
visibility_mode(user_opts.visibility, true)

set_virt_mouse_area(0, 0, 0, 0, "input")
set_virt_mouse_area(0, 0, 0, 0, "window-controls")
set_virt_mouse_area(0, 0, 0, 0, "window-controls-title")
