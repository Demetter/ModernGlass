"""Convert ModernZ's icon SVGs (Fluent and Material Symbols) into ASS drawing paths.

Curves stay curves (ASS "b" cubic Béziers); arcs and quadratic curves become cubics.
libass fills drawings with the non-zero winding rule, so icons drawn for SVG's
even-odd rule get their sub-paths re-oriented by nesting depth.

usage: python3 svg2ass.py <ModernZ/icons dir> <names.txt> out.lua [name=extra.svg ...]
  names.txt: one ligature name per line (the names modernz.lua asks for)
"""
import io
import json
import os
import re
import sys

from shapely.geometry import Point, Polygon
from svgelements import SVG, Arc, Close, CubicBezier, Line, Move, Path, QuadraticBezier, Shape


def subpaths(path):
    """Split a path into closed sub-paths of ('L', p0, p1) / ('C', p0, c1, c2, p1) segments."""
    out, cur, start, pos = [], [], None, None
    for seg in path:
        if isinstance(seg, Move):
            if cur:
                out.append(cur)
            cur, start, pos = [], complex(*seg.end), complex(*seg.end)
            continue
        if isinstance(seg, Close):
            if pos is not None and start is not None and abs(pos - start) > 1e-6:
                cur.append(("L", pos, start))
            pos = start
            continue
        s, e = complex(*seg.start), complex(*seg.end)
        if isinstance(seg, Line):
            if abs(e - s) > 1e-9:
                cur.append(("L", s, e))
        elif isinstance(seg, CubicBezier):
            cur.append(("C", s, complex(*seg.control1), complex(*seg.control2), e))
        elif isinstance(seg, QuadraticBezier):
            c = complex(*seg.control)
            cur.append(("C", s, s + 2 / 3 * (c - s), e + 2 / 3 * (c - e), e))
        elif isinstance(seg, Arc):
            for cb in seg.as_cubic_curves():
                cur.append(("C", complex(*cb.start), complex(*cb.control1), complex(*cb.control2), complex(*cb.end)))
        pos = e
    if cur:
        out.append(cur)
    # close every sub-path explicitly
    closed = []
    for sp in out:
        first, last = sp[0][1], sp[-1][-1]
        if abs(first - last) > 1e-6:
            sp.append(("L", last, first))
        closed.append(sp)
    return closed


def flatten(sp, steps=8):
    pts = []
    for seg in sp:
        if seg[0] == "L":
            pts.append(seg[1])
        else:
            p0, c1, c2, p1 = seg[1:]
            for i in range(steps):
                t = i / steps
                mt = 1 - t
                pts.append(mt ** 3 * p0 + 3 * mt * mt * t * c1 + 3 * mt * t * t * c2 + t ** 3 * p1)
    return [(p.real, p.imag) for p in pts]


def signed_area(pts):
    a = 0.0
    for i in range(len(pts)):
        x0, y0 = pts[i]
        x1, y1 = pts[(i + 1) % len(pts)]
        a += x0 * y1 - x1 * y0
    return a / 2


def reverse(sp):
    out = []
    for seg in reversed(sp):
        if seg[0] == "L":
            out.append(("L", seg[2], seg[1]))
        else:
            out.append(("C", seg[4], seg[3], seg[2], seg[1]))
    return out


def evenodd_to_nonzero(sps):
    polys = []
    for sp in sps:
        pts = flatten(sp)
        polys.append((pts, Polygon(pts).buffer(0) if len(pts) >= 3 else None))
    result = []
    for i, sp in enumerate(sps):
        pts = polys[i][0]
        if len(pts) < 3:
            continue
        probe = Point(pts[0])
        depth = sum(1 for j, (_, poly) in enumerate(polys)
                    if j != i and poly is not None and poly.buffer(-1e-4).contains(probe))
        want_positive = depth % 2 == 0
        if (signed_area(pts) > 0) != want_positive:
            sp = reverse(sp)
        result.append(sp)
    return result


def fmt(v):
    s = ("%.2f" % v).rstrip("0").rstrip(".")
    return "0" if s in ("-0", "") else s


def pt(p):
    return "%s %s" % (fmt(p.real), fmt(p.imag))


def to_ass(sps):
    parts = []
    for sp in sps:
        parts.append("m " + pt(sp[0][1]))
        last = None
        for seg in sp:
            if seg[0] == "L":
                parts.append(("" if last == "l" else "l ") + pt(seg[2]))
                last = "l"
            else:
                parts.append(("" if last == "b" else "b ") + " ".join(pt(p) for p in seg[2:]))
                last = "b"
    return " ".join(parts).replace("  ", " ")


def convert(svg_file):
    # draw every icon on a 24x24 canvas, whatever width/height the file asks for
    text = open(svg_file, encoding="utf-8").read()
    root = re.search(r"<svg\b[^>]*>", text).group(0)
    fixed = re.sub(r'\s(width|height)="[^"]*"', "", root).replace("<svg", '<svg width="24" height="24"', 1)
    svg = SVG.parse(io.StringIO(text.replace(root, fixed, 1)), reify=True)
    all_sps = []
    for el in svg.elements():
        if not isinstance(el, Shape):
            continue
        # skip shapes that only define clip paths
        parent = el
        skip = False
        while parent is not None:
            if getattr(parent, "values", {}).get("tag") in ("clipPath", "defs", "mask"):
                skip = True
                break
            parent = getattr(parent, "parent", None)
        if skip:
            continue
        p = Path(el)
        p.reify()
        sps = subpaths(p)
        rule = (el.values.get("fill-rule") or el.values.get("fill_rule") or "nonzero").strip()
        if rule == "evenodd":
            sps = evenodd_to_nonzero(sps)
        all_sps.extend(sps)
    return to_ass(all_sps)


def main():
    icon_dir, names_file, out = sys.argv[1:4]
    ligatures = {}
    for g in json.load(open(os.path.join(icon_dir, "modernz-icons.json")))["glyphs"]:
        for lig in g["extras"].get("ligatures", []):
            ligatures[lig] = g["extras"]["name"]

    # names the font's project file maps to glyphs without their own SVG, or not at all
    file_alias = {"fluent_pip_exit": "fluent_picture_in_picture_exit",
                  "fluent_pip_exit_filled": "fluent_picture_in_picture_exit_filled"}
    ligatures.update({"material_skip_back": "replay", "material_skip_back_filled": "replay",
                      "material_volume_down_filled": "volume_downfilled",
                      "material_fullscreen_filled": "fullscreen"})

    def glyph_file(glyph):
        glyph = file_alias.get(glyph, glyph)
        for sub in ("fluent", "material"):
            f = os.path.join(icon_dir, sub, glyph + ".svg")
            if os.path.exists(f):
                return f
        return None

    wanted = [l.strip() for l in open(names_file) if l.strip()]
    glyph_paths, lig_map, missing = {}, {}, []
    for name in wanted:
        glyph = ligatures.get(name)
        if not glyph:
            missing.append(name)
            continue
        if glyph not in glyph_paths:
            f = glyph_file(glyph)
            if not f:
                missing.append(name + " (no svg for " + glyph + ")")
                continue
            glyph_paths[glyph] = convert(f)
        lig_map[name] = glyph

    # extra icons given as name=file.svg (e.g. the menu checkmark)
    for arg in sys.argv[4:]:
        name, f = arg.split("=", 1)
        glyph_paths[name] = convert(f)
        lig_map[name] = name

    lines = ["-- icon outlines: Fluent UI System Icons (MIT) and Material Symbols (Apache-2.0),",
             "-- converted from ModernZ's icon sources to ASS drawings on a 24x24 grid",
             "local icon_glyphs = {"]
    for g in sorted(glyph_paths):
        lines.append('    ["%s"] = "%s",' % (g, glyph_paths[g]))
    lines.append("}")
    lines.append("local icon_names = {")
    for n in sorted(lig_map):
        lines.append('    ["%s"] = "%s",' % (n, lig_map[n]))
    lines.append("}")
    open(out, "w").write("\n".join(lines) + "\n")
    print("%d names -> %d glyphs, %d bytes" % (len(lig_map), len(glyph_paths), sum(len(v) for v in glyph_paths.values())))
    if missing:
        print("missing:", missing)


if __name__ == "__main__":
    main()
