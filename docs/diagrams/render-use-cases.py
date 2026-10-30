"""Render this project's actor-grouped PlantUML sources to straight-line SVGs.

Run: python docs/diagrams/render-use-cases.py
Only the actor / usecase / association subset used in these sources is supported.
"""

from pathlib import Path
import math
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
    width, height = columns * 1200, ((len(groups) + columns - 1) // columns) * 900
    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
           f'viewBox="0 0 {width} {height}" role="img" aria-labelledby="title desc">',
           f'<title id="title">{escape(title)}</title>',
           '<desc id="desc">Actor đứng ngoài bên trái khung hệ thống IOTAgri, '
           'tên dưới hình người que. Các use case bố trí so le trong khung, nối trực tiếp bằng đoạn thẳng.</desc>',
           '<rect width="100%" height="100%" fill="white"/>',
           '<g font-family="Arial, sans-serif" fill="#17212b">']
    for index, group in enumerate(groups):
        n = len(group["cases"])
        cy = 450
        svg.append(f'<g data-actor="{group["actor"]}" '
                   f'transform="translate({index % columns * 1200} {index // columns * 900})">')
        svg.append(text(600, 45, f'IOTAgri — {group["name"]}', 24, "bold"))
        svg.append('<rect data-system="IOTAgri" x="240" y="80" width="930" height="770" '
                   'rx="8" fill="#f1eef5" stroke="#51485c" stroke-width="1.8"/>')
        svg.append('<rect x="240" y="59" width="150" height="30" rx="5" fill="#7138a0"/>')
        svg.append('<g fill="white">' + text(315, 80, 'IOTAgri', 17, 'bold') + '</g>')
        # Stagger the use cases within the boundary. For dense diagrams, the
        # near cases occupy the outer fan angles, keeping distant rays clear.
        layouts = {
            1: [(720, 450)],
            2: [(470, 300), (940, 600)],
            3: [(470, 230), (940, 450), (470, 670)],
            4: [(470, 230), (940, 350), (470, 670), (940, 550)],
            5: [(470, 200), (940, 300), (470, 450), (940, 600), (470, 700)],
            7: [(470, 180), (940, 280), (470, 270), (940, 410),
                (940, 540), (470, 740), (940, 670)],
            12: [(470, 130), (940, 150), (470, 220), (940, 240),
                 (940, 330), (940, 420), (940, 510), (940, 600),
                 (470, 700), (940, 690), (470, 790), (940, 780)],
        }
        if n not in layouts:
            raise ValueError(f'Add a compact fan layout for {n} use cases')
        positions = layouts[n]
        # Render all associations behind the use cases. Each edge is exactly
        # one segment, intersected with the ellipse boundary mathematically.
        for (alias, _, _), (x, y) in zip(group["cases"], positions):
            dx, dy = 155 - x, cy - 12 - y
            t = 1 / math.sqrt((dx / 210) ** 2 + (dy / 40) ** 2)
            edge_x, edge_y = x + t * dx, y + t * dy
            if x == 470:
                # Reach near-column ellipses at their leftmost points so
                # steep rays cannot pass behind another near-column case.
                edge_x, edge_y = x - 210, y
            # Select a visible boundary point if the default ray would pass
            # through a neighbouring oval. Keep every association straight.
            candidates = [(edge_x, edge_y)] + [
                (x + 210 * math.cos(math.radians(a)),
                 y + 40 * math.sin(math.radians(a))) for a in range(90, 271)
            ]
            clear = []
            for ex, ey in candidates:
                # Only points facing the actor can be first intersections.
                if ((155 - ex) * (ex - x) / 210**2
                        + (cy - 12 - ey) * (ey - y) / 40**2) < -0.001:
                    continue
                for ox, oy in positions:
                    if (ox, oy) == (x, y):
                        continue
                    ax, ay = (155 - ox) / 210, (cy - 12 - oy) / 40
                    vx, vy = (ex - 155) / 210, (ey - (cy - 12)) / 40
                    t = max(0, min(1, -(ax * vx + ay * vy) / (vx * vx + vy * vy)))
                    if (ax + t * vx)**2 + (ay + t * vy)**2 < 1.03:
                        break
                else:
                    clear.append((ex, ey))
            if not clear:
                raise ValueError(f'No unobstructed straight association for {alias}')
            edge_x, edge_y = min(clear, key=lambda p: (p[0]-edge_x)**2 + (p[1]-edge_y)**2)
            svg.append(f'<line data-usecase="{alias}" x1="155" y1="{cy - 12}" '
                       f'x2="{edge_x:.2f}" y2="{edge_y:.2f}" stroke="#7138a0" stroke-width="1.6"/>')
        for (alias, label, color), (x, y) in zip(group["cases"], positions):
            svg.append(f'<ellipse data-usecase="{alias}" cx="{x}" cy="{y}" '
                       f'rx="210" ry="40" fill="{color}" stroke="#7138a0" '
                       'stroke-width="1.6" stroke-dasharray="8 5"/>')
            lines = [part for chunk in label.split(r"\n")
                     for part in textwrap.wrap(chunk, 36)]
            if len(lines) > 3:
                raise ValueError(f"Label too long for ellipse: {alias}")
            for j, part in enumerate(lines):
                svg.append(text(x, y + 6 + (j - (len(lines) - 1) / 2) * 19, part, 16))
        svg.append(f'<g fill="none" stroke="#17212b" stroke-width="2.5">'
                   f'<circle cx="120" cy="{cy - 52}" r="15"/>'
                   f'<path d="M120 {cy - 37} V{cy + 12} '
                   f'M85 {cy - 12} L120 {cy - 27} L155 {cy - 12} '
                   f'M120 {cy + 12} L96 {cy + 47} '
                   f'M120 {cy + 12} L144 {cy + 47}"/></g>')
        for i, part in enumerate(textwrap.wrap(group["name"], 16)):
            svg.append(text(120, cy + 72 + i * 21, part, 16))
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
