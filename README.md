<p align="center">
  <img src="assets/banner.webp" alt="ModernGlass" width="100%">
</p>

<p align="center">
  A sleek and modern glassmorphic OSC for <a href="https://mpv.io">mpv</a>. This project is a fork of <a href="https://github.com/Samillion/ModernZ">ModernZ</a> that adds translucent glass panels, track menus and seekbar thumbnails while preserving the core standards of mpv's OSC.
</p>

<p align="center">
  <img alt="mpv 0.39+" src="https://img.shields.io/badge/mpv-0.39%2B-2b2d33?style=flat-square&labelColor=17181c">
  <img alt="Windows, macOS, Linux" src="https://img.shields.io/badge/platform-Windows%20%C2%B7%20macOS%20%C2%B7%20Linux-2b2d33?style=flat-square&labelColor=17181c">
  <img alt="License LGPL-2.1" src="https://img.shields.io/badge/license-LGPL--2.1-2b2d33?style=flat-square&labelColor=17181c">
</p>

<p align="center">
  <a href="#installation"><b>Install</b></a> &nbsp;·&nbsp;
  <a href="#configuration">Configure</a> &nbsp;·&nbsp;
  <a href="#controls">Controls</a> &nbsp;·&nbsp;
  <a href="docs/USER_OPTS.md">All options</a> &nbsp;·&nbsp;
  <a href="#credits">Credits</a>
</p>

<br>

<p align="center">
  <img src="assets/hero.webp" alt="ModernGlass playing a golden-hour mountain scene" width="100%">
</p>

<br>

## Features

- **Glass panel.** The playback controls sit on a floating panel with rounded corners. With `vo=gpu-next`, a shader blurs the video behind the panel, distorts it slightly near the edges, adds a highlight along the top edge and draws a shadow under the panel.
- **Brightness adjustment.** Over bright video the panel is darkened and its shadow is made stronger, so white text and icons stay readable.
- **Menus.** The audio, subtitle, playlist, chapter, speed and audio output lists open as menus above their buttons. The ⋯ button opens a menu with playback speed, chapters, audio output, loop, keep on top, screenshot and statistics.
- **Thumbnails.** thumbz shows a preview frame above the seekbar while you hover it. Frames are decoded by a separate mpv process in the background and cached for the current file. HDR video is tone-mapped.
- **Size.** The controls scale with the window up to a maximum size (`vidscale_max`), which is multiplied by the system's display scaling. On large monitors they stay the size they have on a 1080p screen.
- **Accessibility options.** `glass_reduce_transparency` makes the panels nearly opaque, `glass_increase_contrast` makes them black with a visible border, and `reduce_motion` turns off the spring and scale animations.
- **GPU use.** The blur is computed on a copy of the frame scaled down to 270 rows, and the shader is turned off while the controls are hidden.

## Gallery

<table>
  <tr>
    <td width="50%"><img src="assets/menu-audio.webp" alt="Audio track menu"></td>
    <td width="50%"><img src="assets/menu-subtitles.webp" alt="Subtitle menu"></td>
  </tr>
  <tr>
    <td align="center"><sub>Audio tracks</sub></td>
    <td align="center"><sub>Subtitles</sub></td>
  </tr>
  <tr>
    <td width="50%"><img src="assets/menu-speed.webp" alt="Playback speed submenu"></td>
    <td width="50%"><img src="assets/menu-playlist.webp" alt="Playlist menu over a bright sky"></td>
  </tr>
  <tr>
    <td align="center"><sub>Playback speed, from the ⋯ menu</sub></td>
    <td align="center"><sub>Playlist, over a bright scene</sub></td>
  </tr>
</table>

<p align="center">
  <img src="assets/thumbnails.webp" alt="Seekbar thumbnail preview" width="100%">
  <br><sub>Seekbar thumbnail with the chapter name and time</sub>
</p>

<table>
  <tr>
    <td width="70%"><img src="assets/image-viewer.webp" alt="Image viewer controls"></td>
    <td width="30%" align="center"><img src="assets/window-controls.webp" alt="Window controls"></td>
  </tr>
  <tr>
    <td align="center"><sub>Image viewer with zoom controls</sub></td>
    <td align="center"><sub>Window controls in borderless mode</sub></td>
  </tr>
</table>

### Accessibility

<table>
  <tr><td><img src="assets/panel.webp" alt="Default glass"></td></tr>
  <tr><td align="center"><sub>Default</sub></td></tr>
  <tr><td><img src="assets/a11y-contrast.webp" alt="Increase contrast"></td></tr>
  <tr><td align="center"><sub><code>glass_increase_contrast=yes</code></sub></td></tr>
  <tr><td><img src="assets/a11y-reduce.webp" alt="Reduce transparency"></td></tr>
  <tr><td align="center"><sub><code>glass_reduce_transparency=yes</code></sub></td></tr>
</table>

`reduce_motion=yes` turns off the spring and scale animations. Fades are kept.

## Installation

**1. Copy the files** into your mpv folder:

```
📁 mpv/
├── 📁 fonts/
│   ├── Inter-Medium.ttf
│   └── Inter-SemiBold.ttf
├── 📁 script-opts/
│   ├── modernz.conf        (optional, all options with their defaults)
│   └── thumbz.conf         (optional)
└── 📁 scripts/
    ├── modernz.lua
    └── thumbz.lua
```

| System  | mpv folder                                |
| ------- | ----------------------------------------- |
| Windows | `%APPDATA%\mpv\`                          |
| macOS   | `~/Library/Application Support/mpv/`      |
| Linux   | `~/.config/mpv/`                          |

**2. Add to `mpv.conf`:**

```ini
osc=no                        # turn off mpv's own controls
vo=gpu-next                   # needed for the blur behind the panels
video-sync=display-resample   # redraw the controls at the display's refresh rate
```

`border=no` removes the system title bar. The minimize, maximize and close buttons are then drawn by the script in the top right corner.

> [!NOTE]
> With other video outputs the panels are drawn without the blur, at a higher opacity.

### Upgrading from ModernZ

ModernGlass keeps ModernZ's file names, options and script bindings, so it replaces `modernz.lua` in place and your `modernz.conf` and `input.conf` keep working. The icons are drawn by the script now, so `modernz-icons.ttf` is no longer needed. thumbz replaces thumbfast; remove `thumbfast.lua` if you have it.

## Configuration

Put `modernz.conf` in `script-opts`. It lists every option with its default, or you can write only the ones you change:

```ini
# glass
glass_opacity=40
panel_max_width=1400

# controls: blue progress bar, file name as the title
seekbarfg_color=#0A84FF
title=${filename}
```

Glass options:

| Option | Default | What it does |
| --- | --- | --- |
| `glass_color` | `#17181C` | panel color |
| `glass_opacity` | `30` | panel opacity in percent |
| `glass_blur` | `yes` | blur the video behind the panels |
| `glass_refraction` | `yes` | distortion near the edges and a highlight along the top edge |
| `glass_shadow` | `yes` | shadow under the panels |
| `panel_radius` | `28` | corner radius of the panel |
| `panel_max_width` | `0` | widest the panel gets (`0` = full width) |
| `vidscale_max` | `1.35` | maximum size of the controls, multiplied by the display scaling |

The full list is in the [options guide](docs/USER_OPTS.md). Other layouts from ModernZ (`classic`, `compact`, `mini`, `seekbar`) are still available with `layout=`.

## Controls

Left click does a button's main action, right click its secondary one, and middle click (or <kbd>Shift</kbd>+click) an alternative. Every interaction is listed in the [controls guide](docs/CONTROLS.md).

ModernGlass sets no keyboard shortcuts of its own. These can be added to `input.conf`:

```
v   script-binding modernz/visibility              # cycle visibility modes
w   script-binding modernz/progress-toggle         # toggle persistent progress
x   script-message-to modernz osc-show             # show the controls
y   script-message-to modernz osc-hide             # hide the controls
```

## Translations

Put [`modernz-locale.json`](extras/locale/modernz-locale.json) in `script-opts` and set `language=` in `modernz.conf`, for example `language=zh`. Available languages and how to add one are in the [translations guide](docs/TRANSLATIONS.md).

## Extras

The [extra scripts](extras/) from ModernZ work with ModernGlass too: Open-File, Pause-Indicator-Lite and PiP-Lite.

## Credits

ModernGlass is based on [ModernZ](https://github.com/Samillion/ModernZ) by Samillion. Project history:

- [Samillion/ModernZ](https://github.com/Samillion/ModernZ)
  - forked from [dexeonify/ModernX](https://github.com/dexeonify/mpv-config/blob/main/scripts/modernx.lua)
    - forked from [cyl0/ModernX](https://github.com/cyl0/ModernX)
      - forked from [maoiscat/mpv-osc-modern](https://github.com/maoiscat/mpv-osc-modern)
- [mpv](https://github.com/mpv-player/mpv) and its [osc.lua](https://github.com/mpv-player/mpv/blob/master/player/lua/osc.lua), which all of these are based on
- [Inter](https://rsms.me/inter/) by Rasmus Andersson, [SIL Open Font License 1.1](fonts/Inter-LICENSE.txt)
- [Fluent System Icons](https://github.com/microsoft/fluentui-system-icons) by Microsoft ([MIT](https://github.com/microsoft/fluentui-system-icons?tab=MIT-1-ov-file#readme)) and [Material Symbols](https://github.com/google/material-design-icons) by Google ([Apache 2.0](https://github.com/google/material-design-icons?tab=Apache-2.0-1-ov-file#readme))

The landscapes in the screenshots were generated for this README.

## License

[LGPL-2.1](LICENSE), like mpv's osc.lua that ModernGlass derives from. The Inter font files are under the [SIL Open Font License 1.1](fonts/Inter-LICENSE.txt).
