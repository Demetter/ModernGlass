# Icons

ModernGlass draws its icons as ASS vector paths inside `modernz.lua`, so no icon font is needed. The paths are converted from the SVGs in this folder:

- `fluent/` – [Fluent System Icons](https://github.com/microsoft/fluentui-system-icons) (MIT)
- `material/` – [Material Symbols](https://github.com/google/material-design-icons) (Apache 2.0)
- `extra/` – menu glyphs (check mark, chevrons, ⋯, chapters)
- `modernz-icons.json` – which SVG each icon name comes from
- `names.txt` – the icon names the script uses

To regenerate the paths after changing an SVG (needs `pip install svgelements shapely`):

```
python3 svg2ass.py . names.txt icon_glyphs.lua \
    menu_check=extra/ic_fluent_checkmark_24_regular.svg \
    menu_back=extra/menu_back.svg menu_chevron=extra/menu_chevron.svg \
    menu_more=extra/menu_more.svg menu_chapters=extra/menu_chapters.svg
```

Then replace the icon table in `modernz.lua` with the contents of `icon_glyphs.lua`.
