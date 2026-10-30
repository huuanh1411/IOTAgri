"""Render this project's actor-grouped PlantUML sources to straight-line SVGs.

Run: python docs/diagrams/render-use-cases.py
Only the actor / usecase / association subset used in these sources is supported.
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
        if line.startswith('@startuml'):
            current = {"cases": []}
            groups.append(current)
        elif match := re.fullmatch(r'actor "(.+)" as (\w+)', line):
            actors[match[2]] = match[1].replace(r"\n", " ")
        elif match := re.fullmatch(r'usecase "(.+)" as (\w+)(?: (#[A-Fa-f0-9]{6}))?', line):
            if current is None:
                raise ValueError("Use case must be inside a diagram")
            current["cases"].append((match[2], match[1], match[3] or "#FFFFFF"))
        elif line == "@enduml":
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
            raise ValueError("Each diagram must have exactly one actor")
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
    columns = 2 if len(groups) > 1 else 1
    width, height = columns * 1200, ((len(groups) + columns - 1) // columns) * 780
    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
           f'viewBox="0 0 {width} {height}" role="img" aria-labelledby="title desc">',
           f'<title id="title">{escape(title)}</title>',
           '<desc id="desc">Actor ở trung tâm, tên bên dưới hình người que. '
           'Các use case bố trí so le hai bên, nối trực tiếp bằng đoạn thẳng; không có khung bao.</desc>',
           '<rect width="100%" height="100%" fill="white"/>',
           '<g font-family="Arial, sans-serif" fill="#17212b">']
    for index, group in enumerate(groups):
        n = len(group["cases"])
        cy = 390
        svg.append(f'<g data-actor="{group["actor"]}" '
                   f'transform="translate({index % columns * 1200} {index // columns * 780})">')
        svg.append(text(600, 45, f'IOTAgri — {group["name"]}', 24, "bold"))
        # Alternate sides, leaving the central corridor clear of use cases.
        positions = []
        for i in range(n):
            side = i % 2
            count = (n + 1 - side) // 2
            row = i // 2
            span = min(520, (count - 1) * 160)
            y = cy if count == 1 else cy - span / 2 + row * span / (count - 1)
            x = 260 if side == 0 else 940
            positions.append((x, y))
        for (alias, label, color), (x, y) in zip(group["cases"], positions):
            hand = 565 if x < 600 else 635
            edge = x + 220 if x < 600 else x - 220
            svg.append(f'<line data-usecase="{alias}" x1="{hand}" y1="{cy - 12}" '
                       f'x2="{edge}" y2="{y}" stroke="#334155" stroke-width="1.5"/>')
            svg.append(f'<ellipse data-usecase="{alias}" cx="{x}" cy="{y}" '
                       f'rx="220" ry="43" fill="{color}" stroke="#334155" stroke-width="1.4"/>')
            lines = [part for chunk in label.split(r"\n")
                     for part in textwrap.wrap(chunk, 39)]
            if len(lines) > 3:
                raise ValueError(f"Label too long for ellipse: {alias}")
            for j, part in enumerate(lines):
                svg.append(text(x, y + 6 + (j - (len(lines) - 1) / 2) * 20, part, 17))
        svg.append(f'<g fill="none" stroke="#17212b" stroke-width="2.5">'
                   f'<circle cx="600" cy="{cy - 52}" r="15"/>'
                   f'<path d="M600 {cy - 37} V{cy + 12} '
                   f'M565 {cy - 12} L600 {cy - 27} L635 {cy - 12} '
                   f'M600 {cy + 12} L576 {cy + 47} '
                   f'M600 {cy + 12} L624 {cy + 47}"/></g>')
        for i, part in enumerate(textwrap.wrap(group["name"], 12)):
            svg.append(text(600, cy + 72 + i * 21, part, 16))
        svg.append('</g>')
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
        for group in groups:
            name = f"{stem}-{group['actor'].lower()}.svg"
            (out / name).write_text(render([group], f"IOTAgri — {group['name']}"), encoding="utf-8")
