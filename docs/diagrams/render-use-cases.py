"""Render this project's actor-grouped PlantUML sources to straight-line SVGs.

Run: python docs/diagrams/render-use-cases.py
Only the actor / rectangle / usecase / association subset used here is supported.
"""

from pathlib import Path
import re
import textwrap
from xml.sax.saxutils import escape


ROOT = Path(__file__).resolve().parent


def read_source(path):
    actors, groups, associations = {}, [], []
    current = None
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if match := re.fullmatch(r'actor "(.+)" as (\w+)', line):
            actors[match[2]] = match[1].replace(r"\n", " ")
        elif match := re.fullmatch(r'rectangle "(.+)" as (\w+) \{', line):
            current = {"title": match[1], "cases": []}
            groups.append(current)
        elif match := re.fullmatch(r'usecase "(.+)" as (\w+)(?: (#[A-Fa-f0-9]{6}))?', line):
            if current is None:
                raise ValueError("Use case must be inside a rectangle")
            current["cases"].append((match[2], match[1], match[3] or "#FFFFFF"))
        elif line == "}":
            current = None
        elif match := re.fullmatch(r'(\w+) -- (\w+)', line):
            associations.append((match[1], match[2]))
    case_ids = [case[0] for group in groups for case in group["cases"]]
    if len(set(case_ids)) != len(case_ids):
        raise ValueError("Duplicate use case alias")
    for group in groups:
        ids = {case[0] for case in group["cases"]}
        owners = {actor for actor, case in associations if case in ids}
        if len(owners) != 1:
            raise ValueError("Each frame must have exactly one actor")
        group["actor"] = owners.pop()
        group["name"] = actors[group["actor"]]
        expected = {(group["actor"], case) for case in ids}
        actual = {(actor, case) for actor, case in associations if case in ids}
        if expected != actual:
            raise ValueError("Every use case needs a direct actor association")
    if len(associations) != len(case_ids) or {a for a, _ in associations} != set(actors):
        raise ValueError("Unexpected association or actor without use cases")
    return groups


def text(x, y, value, size=17, weight="normal"):
    return (f'<text x="{x}" y="{y}" text-anchor="middle" '
            f'font-size="{size}" font-weight="{weight}">{escape(value)}</text>')


def render(groups, title):
    heights = [max(260, len(g["cases"]) * 90 + 90) for g in groups]
    height = sum(heights) + 100
    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="980" height="{height}" '
           f'viewBox="0 0 980 {height}" role="img" aria-labelledby="title desc">',
           f'<title id="title">{escape(title)}</title>',
           '<desc id="desc">Mỗi actor có một khung hành động riêng. Actor là hình '
           'người que có tên bên dưới, nối bằng đoạn thẳng đến từng use case.</desc>',
           '<rect width="100%" height="100%" fill="white"/>',
           '<g font-family="Arial, sans-serif" fill="#17212b">',
           text(490, 34, title, 23, "bold")]
    top = 65
    for group, h in zip(groups, heights):
        n = len(group["cases"])
        start = top + (h - (n - 1) * 90) / 2
        cy = start + (n - 1) * 45
        svg.append(f'<g data-actor="{group["actor"]}">')
        svg.append(f'<rect x="300" y="{top + 10}" width="650" height="{h - 30}" '
                   'fill="#f8fafc" stroke="#334155" stroke-width="1.5"/>')
        svg.append(text(625, top + 38, group["title"], 18, "bold"))
        # Attach every association to the actor's right hand; keep the actor
        # name narrow enough to leave space for the descending segments.
        svg.append(f'<g fill="none" stroke="#17212b" stroke-width="2.5">'
                   f'<circle cx="100" cy="{cy - 52}" r="15"/>'
                   f'<path d="M100 {cy - 37} V{cy + 12} '
                   f'M69 {cy - 12} L100 {cy - 27} L131 {cy - 12} '
                   f'M100 {cy + 12} L76 {cy + 47} '
                   f'M100 {cy + 12} L124 {cy + 47}"/></g>')
        for i, part in enumerate(textwrap.wrap(group["name"], 16)):
            svg.append(text(100, cy + 72 + i * 22, part, 16))
        for i, (alias, label, color) in enumerate(group["cases"]):
            y = start + i * 90
            # End at the leftmost point of the target ellipse, so the entire
            # segment stays left of all other ellipses in the column.
            svg.append(f'<line data-usecase="{alias}" x1="131" y1="{cy - 12}" '
                       f'x2="340" y2="{y}" '
                       'stroke="#334155" stroke-width="1.4"/>')
            svg.append(f'<ellipse data-usecase="{alias}" cx="625" cy="{y}" '
                       f'rx="285" ry="34" fill="{color}" stroke="#334155"/>')
            lines = [part for chunk in label.split(r"\n")
                     for part in textwrap.wrap(chunk, 57)]
            if len(lines) > 2:
                raise ValueError(f"Label too long for ellipse: {alias}")
            for j, part in enumerate(lines):
                svg.append(text(625, y + 6 + (j - (len(lines) - 1) / 2) * 21, part))
        svg.append('</g>')
        top += h
    svg.extend(['</g>', '</svg>'])
    return "\n".join(svg) + "\n"


if __name__ == "__main__":
    out = ROOT / "rendered"
    out.mkdir(exist_ok=True)
    for stem, title in [("use-case", "IOTAgri — Use Case theo actor"),
                        ("use-case-overview", "IOTAgri — Tổng quan Use Case theo actor")]:
        groups = read_source(ROOT / f"{stem}.puml")
        (out / f"{stem}.svg").write_text(render(groups, title), encoding="utf-8")
        print(f"{stem}: {len(groups)} actors, {sum(len(g['cases']) for g in groups)} associations")
        if stem == "use-case":
            for group in groups:
                name = f"use-case-{group['actor'].lower()}.svg"
                (out / name).write_text(render([group], f"IOTAgri — {group['name']}"), encoding="utf-8")
