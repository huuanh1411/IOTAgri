"""Render both PlantUML sources with all actors sharing one system boundary.

Run from the repository root: python docs/diagrams/render-use-cases.py
Uses only the Python standard library and the UML subset in these sources.
"""

import math
from pathlib import Path
import re
import textwrap
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parent
RX, RY = 210, 45
ACTORS = {
    'Guest': (120, 230, 'left'),
    'User': (120, 1050, 'left'),
    'Admin': (2280, 700, 'right'),
    'ESP': (2280, 1550, 'right'),
    'SMTP': (2280, 180, 'right'),
}
DETAIL = {
    'GuestUC1': (470, 150), 'GuestUC2': (1000, 300),
    'UserUC1': (470, 550),
    'UserUC2': (470, 730), 'UserUC3': (940, 750),
    'UserUC4': (470, 820), 'UserUC5': (940, 850),
    'UserUC6': (940, 950), 'UserUC7': (940, 1050),
    'UserUC8': (940, 1150), 'UserUC9': (940, 1250),
    'UserUC10': (470, 1300), 'UserUC11': (940, 1350),
    'UserUC12': (470, 1390),
    'AdminUC2': (1940, 550), 'AdminUC3': (1470, 750),
    'AdminUC4': (1470, 950), 'AdminUC5': (1940, 1050),
    'AdminUC6': (1470, 1150), 'AdminUC7': (1940, 1250),
    'ESPUC1': (1940, 1450), 'ESPUC2': (1470, 1550),
    'ESPUC3': (1940, 1650),
}
OVERVIEW = {
    'GuestUC1': (470, 180), 'GuestUC2': (1000, 300),
    'UserUC1': (1200, 500), 'UserUC2': (470, 780),
    'UserUC3': (940, 920), 'UserUC4': (470, 1180),
    'UserUC5': (940, 1250),
    'AdminUC2': (1940, 550), 'AdminUC3': (1470, 800),
    'AdminUC4': (1940, 1050),
    'ESPUC1': (1940, 1400), 'ESPUC2': (1470, 1530),
    'ESPUC3': (1940, 1650),
}


def read_source(path):
    actors, cases, edges = {}, {}, []
    source = path.read_text(encoding='utf-8')
    if source.count('@startuml') != 1 or source.count('rectangle "IOTAgri"') != 1:
        raise ValueError('Each source must contain one diagram and one system boundary')
    for line in source.splitlines():
        line = line.strip()
        if m := re.fullmatch(r'actor "(.+)" as (\w+)', line):
            actors[m[2]] = m[1].replace(r'\n', ' ')
        elif m := re.fullmatch(r'usecase "(.+)" as (\w+)(?: (#[A-Fa-f0-9]{6}))?', line):
            if m[2] in cases:
                raise ValueError(f'Duplicate alias: {m[2]}')
            cases[m[2]] = (m[1], m[3] or '#FFFFFF')
        elif m := re.fullmatch(r'(\w+) -- (\w+)', line):
            edges.append((m[1], m[2]))
    if set(actors) != set(ACTORS):
        raise ValueError('The diagram must contain all five actors')
    for actor, case in edges:
        if actor not in actors or case not in cases:
            raise ValueError(f'Unknown association: {actor} -- {case}')
    if {case for _, case in edges} != set(cases):
        raise ValueError('Every use case must have an association')
    return actors, cases, edges


def text(x, y, value, size=20, weight='normal'):
    return (f'<text x="{x}" y="{y}" text-anchor="middle" '
            f'font-size="{size}" font-weight="{weight}">{escape(value)}</text>')


def intersection_count(start, end, target, positions):
    count = 0
    for alias, (ox, oy) in positions.items():
        if alias == target:
            continue
        ax, ay = (start[0] - ox) / RX, (start[1] - oy) / RY
        vx, vy = (end[0] - start[0]) / RX, (end[1] - start[1]) / RY
        t = max(0, min(1, -(ax * vx + ay * vy) / (vx * vx + vy * vy)))
        if (ax + t * vx)**2 + (ay + t * vy)**2 < 1.02:
            count += 1
    return count


def endpoint(start, target, positions):
    x, y = positions[target]
    dx, dy = start[0] - x, start[1] - y
    t = 1 / math.sqrt((dx / RX)**2 + (dy / RY)**2)
    ideal = (x + t * dx, y + t * dy)
    candidates = [ideal] + [(x + RX * math.cos(math.radians(a)),
                            y + RY * math.sin(math.radians(a))) for a in range(360)]
    visible = [p for p in candidates if
               (start[0]-p[0])*(p[0]-x)/RX**2 + (start[1]-p[1])*(p[1]-y)/RY**2 >= -0.001]
    best = min(visible, key=lambda p: (intersection_count(start, p, target, positions),
                                     (p[0]-ideal[0])**2 + (p[1]-ideal[1])**2))
    if intersection_count(start, best, target, positions):
        raise ValueError(f'Association to {target} is obscured; adjust its layout')
    return best


def render(actors, cases, edges, positions, title):
    if set(cases) != set(positions):
        raise ValueError('Layout does not match source aliases')
    svg = ['<svg xmlns="http://www.w3.org/2000/svg" width="2400" height="1800" '
           'viewBox="0 0 2400 1800" role="img" aria-labelledby="title desc">',
           f'<title id="title">{escape(title)}</title>',
           '<desc id="desc">Năm actor cùng xuất hiện bên ngoài một khung hệ thống IOTAgri. '
           'Use case bố trí so le bên trong; use case chung chỉ vẽ một lần.</desc>',
           '<rect width="100%" height="100%" fill="white"/>',
           '<g font-family="Arial, sans-serif" fill="#17212b">', text(1200, 43, title, 30, 'bold'),
           '<rect data-system="IOTAgri" x="240" y="80" width="1920" height="1660" '
           'rx="8" fill="#f1eef5" stroke="#51485c" stroke-width="2"/>',
           '<rect x="240" y="59" width="170" height="30" rx="5" fill="#7138a0"/>',
           '<g fill="white">' + text(325, 81, 'IOTAgri', 21, 'bold') + '</g>']
    for actor, alias in edges:
        x, y, side = ACTORS[actor]
        start = (x + (35 if side == 'left' else -35), y - 12)
        ex, ey = endpoint(start, alias, positions)
        svg.append(f'<line data-actor="{actor}" data-usecase="{alias}" '
                   f'x1="{start[0]}" y1="{start[1]}" x2="{ex:.2f}" y2="{ey:.2f}" '
                   'stroke="#7138a0" stroke-width="1.8"/>')
    for alias, (label, color) in cases.items():
        x, y = positions[alias]
        svg.append(f'<g data-usecase="{alias}"><ellipse cx="{x}" cy="{y}" rx="{RX}" ry="{RY}" '
                   f'fill="{color}" stroke="#7138a0" stroke-width="1.8" stroke-dasharray="8 5"/>')
        lines = [part for chunk in label.split(r'\n') for part in textwrap.wrap(chunk, 35)]
        if len(lines) > 3:
            raise ValueError(f'Label too long: {alias}')
        for i, part in enumerate(lines):
            svg.append(text(x, y + 6 + (i - (len(lines)-1)/2) * 22, part))
        svg.append('</g>')
    for alias, name in actors.items():
        x, y, _ = ACTORS[alias]
        svg.append(f'<g data-actor="{alias}"><g fill="none" stroke="#17212b" stroke-width="3">'
                   f'<circle cx="{x}" cy="{y-52}" r="17"/>'
                   f'<path d="M{x} {y-35} V{y+12} M{x-35} {y-12} L{x} {y-27} L{x+35} {y-12} '
                   f'M{x} {y+12} L{x-24} {y+47} M{x} {y+12} L{x+24} {y+47}"/></g>')
        for i, part in enumerate(textwrap.wrap(name, 11)):
            svg.append(text(x, y + 77 + i * 25, part, 21))
        svg.append('</g>')
    return '\n'.join(svg + ['</g>', '</svg>', ''])


if __name__ == '__main__':
    for stem, positions, title in [
        ('use-case', DETAIL, 'IOTAgri — Use Case đầy đủ'),
        ('use-case-overview', OVERVIEW, 'IOTAgri — Tổng quan Use Case'),
    ]:
        actors, cases, edges = read_source(ROOT / f'{stem}.puml')
        output = render(actors, cases, edges, positions, title)
        (ROOT / 'rendered' / f'{stem}.svg').write_text(output, encoding='utf-8')
        print(f'{stem}: {len(actors)} actors, 1 system boundary, '
              f'{len(cases)} use cases, {len(edges)} direct associations')
