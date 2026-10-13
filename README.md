<p align="center">
  <img src="assets/banner.webp" alt="ModernGlass" width="100%">
</p>

<p align="center">
  Frosted, refractive glass controls for <a href="https://mpv.io">mpv</a>, with menus, thumbnails and motion designed as one system.
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

## Highlights

- **Real glass.** A GPU shader frosts the video behind every surface, bends it at the edges like a thick lens, catches light along the rim and casts a soft shadow. It is a material, not a blurred rectangle.
- **Adapts to the picture.** Over bright scenes the glass deepens and the shadow grows, so white controls stay readable on snow, sky or a white frame.
- **Menus that belong to the interface.** Audio, subtitles, playlist, chapters, speed and audio output open as glass menus that grow out of their button. Submenus slide in place, and hover states settle on a spring.
- **Seekbar thumbnails built in.** thumbz renders previews in a background mpv and fills in a storyboard of the whole file while you watch. It works with software decoding on any GPU and tone-maps HDR.
- **One size on every display.** The controls keep the same size from a 1080p monitor to a 5K ultrawide, and follow your system's display scaling.
- **Accessible.** Reduce transparency, increase contrast and reduce motion are one option each.
- **Light on the GPU.** The blur works on a 270-row copy of the frame at any resolution, and switches off while the controls are hidden.

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
  <br><sub>Seekbar thumbnails with the chapter name</sub>
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

`reduce_motion=yes` keeps the fades and drops the spring and scale animations.

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
vo=gpu-next                   # needed for the frosted glass
video-sync=display-resample   # animations at your display's refresh rate, not the video's
```

That's it. Optionally add `border=no` for a frameless window with glass window controls.

> [!NOTE]
> Without `vo=gpu-next` the glass is drawn as tinted panels without the frosted backdrop.

### Upgrading from ModernZ

ModernGlass keeps ModernZ's file names, options and script bindings, so it replaces `modernz.lua` in place and your `modernz.conf` and `input.conf` keep working. The icons are drawn by the script now, so `modernz-icons.ttf` is no longer needed. thumbz replaces thumbfast; remove `thumbfast.lua` if you have it.

## Configuration

Put `modernz.conf` in `script-opts`. It lists every option with its default, or you can write only the ones you change:

```ini
# glass
glass_opacity=40
panel_max_width=1400

# controls: blue progress instead of white, file name as the title
seekbarfg_color=#0A84FF
title=${filename}
```

The glass options at a glance:

| Option | Default | What it does |
| --- | --- | --- |
| `glass_color` | `#17181C` | tint of the glass |
| `glass_opacity` | `30` | clear (`0`) to solid (`100`) |
| `glass_blur` | `yes` | frost the video behind the glass |
| `glass_refraction` | `yes` | lens edges and rim light |
| `glass_shadow` | `yes` | soft adaptive shadow |
| `panel_radius` | `28` | corner radius of the panel |
| `panel_max_width` | `0` | widest the panel gets (`0` = full width) |
| `vidscale_max` | `1.35` | size of the controls on large displays |

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

ModernGlass is built on [ModernZ](https://github.com/Samillion/ModernZ) by Samillion, which keeps a long line of mpv interfaces alive:

- [Samillion/ModernZ](https://github.com/Samillion/ModernZ)
  - forked from [dexeonify/ModernX](https://github.com/dexeonify/mpv-config/blob/main/scripts/modernx.lua)
    - forked from [cyl0/ModernX](https://github.com/cyl0/ModernX)
      - forked from [maoiscat/mpv-osc-modern](https://github.com/maoiscat/mpv-osc-modern)
- [mpv](https://github.com/mpv-player/mpv) and its [osc.lua](https://github.com/mpv-player/mpv/blob/master/player/lua/osc.lua), which all of these are based on
- [Inter](https://rsms.me/inter/) by Rasmus Andersson, [SIL Open Font License 1.1](fonts/Inter-LICENSE.txt)
- [Fluent System Icons](https://github.com/microsoft/fluentui-system-icons) by Microsoft ([MIT](https://github.com/microsoft/fluentui-system-icons?tab=MIT-1-ov-file#readme)) and [Material Symbols](https://github.com/google/material-design-icons) by Google ([Apache 2.0](https://github.com/google/material-design-icons?tab=Apache-2.0-1-ov-file#readme))

The scenes in the screenshots are generated and free to reuse.

## License

[LGPL-2.1](LICENSE), like mpv's osc.lua that ModernGlass derives from. The Inter font files are under the [SIL Open Font License 1.1](fonts/Inter-LICENSE.txt).
