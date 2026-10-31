"""Render system-context.mmd with five entities evenly spaced around IOTAgri.

Run from the repository root: python docs/diagrams/render-context.py
The source retains Mermaid compatibility; this renderer fixes the radial layout.
"""

import math
from pathlib import Path
import re
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parent
CX, CY, RADIUS, ORBIT = 700, 600, 120, 420
ORDER = ['Guest', 'Admin', 'ESP', 'SMTP', 'User']


def text(x, y, lines, size=18, color='#17212b', bold=False):
    return ''.join(
        f'<text x="{x:.2f}" y="{y + (i-(len(lines)-1)/2)*25:.2f}" '
        f'text-anchor="middle" font-size="{size}" fill="{color}" '
        f'font-weight="{"bold" if bold else "normal"}">{escape(line)}</text>'
        for i, line in enumerate(lines)
    )


def render():
    source = (ROOT / 'system-context.mmd').read_text(encoding='utf-8')
    entities = dict(re.findall(r'^\s+(\w+)\["(.+)"\]', source, re.M))
    flows = re.findall(r'^\s+(\w+) -->\|"(.+)"\| (\w+)', source, re.M)
    if set(entities) != set(ORDER) or len(flows) != 9:
        raise ValueError('Expected five external entities and nine flows')
    svg = [
        '<svg xmlns="http://www.w3.org/2000/svg" width="1400" height="1200" '
        'viewBox="0 0 1400 1200" role="img" aria-labelledby="title desc">',
        '<title id="title">Context Diagram — IOTAgri</title>',
        '<desc id="desc">Năm thực thể bên ngoài cách đều nhau 72 độ quanh '
        'vòng tròn IOTAgri. Chín mũi tên biểu diễn hướng luồng dữ liệu.</desc>',
        '<defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" '
        'markerWidth="8" markerHeight="8" orient="auto-start-reverse">'
        '<path d="M0 0 L10 5 L0 10 Z" fill="#7138a0"/></marker></defs>',
        '<rect width="1400" height="1200" fill="white"/>',
        '<g font-family="Arial, sans-serif">',
        text(700, 65, ['Context Diagram'], 28, bold=True),
    ]
    positions = {}
    labels = []
    for i, alias in enumerate(ORDER):
        angle = math.radians(-126 + i * 72)
        ux, uy = math.cos(angle), math.sin(angle)
        nx, ny = -uy, ux
        x, y = CX + ORBIT * ux, CY + ORBIT * uy
        positions[alias] = (x, y)
        related = [(a, label, b) for a, label, b in flows if alias in (a, b)]
        for a, label, b in related:
            inbound = b == 'System'
            lane = (18 if inbound else -18) if len(related) > 1 else 0
            offset_x, offset_y = lane * nx, lane * ny
            inner = math.sqrt(RADIUS**2 - lane**2)
            # Enter the entity rectangle along the radial line, accounting for
            # the lateral separation between inbound and outbound arrows.
            limits = []
            if abs(ux) > 1e-6:
                limits.append((110 + (offset_x if ux > 0 else -offset_x)) / abs(ux))
            if abs(uy) > 1e-6:
                limits.append((35 + (offset_y if uy > 0 else -offset_y)) / abs(uy))
            outer = ORBIT - min(limits)
            start = (CX + inner * ux + offset_x, CY + inner * uy + offset_y)
            end = (CX + outer * ux + offset_x, CY + outer * uy + offset_y)
            if inbound:
                start, end = end, start
            svg.append(f'<line data-source="{a}" data-target="{b}" '
                       f'x1="{start[0]:.2f}" y1="{start[1]:.2f}" '
                       f'x2="{end[0]:.2f}" y2="{end[1]:.2f}" '
                       'stroke="#7138a0" stroke-width="2" marker-end="url(#arrow)"/>')
            side = (1 if inbound else -1) if len(related) > 1 else 1
            # Wide labels sit beside the spokes, rather than on the lines.
            lx = CX + 270 * ux + side * 100 * nx
            ly = CY + 270 * uy + side * 100 * ny
            lines = label.split('<br/>')
            labels.append(f'<g data-flow="{a}-{b}">' + text(lx, ly, lines) + '</g>')
    svg += labels
    svg.append(f'<circle data-system="IOTAgri" cx="{CX}" cy="{CY}" r="{RADIUS}" '
               'fill="#e7f2ff" stroke="#245b99" stroke-width="3"/>')
    svg.append(text(CX, CY-25, ['0'], 20, '#245b99'))
    svg.append(text(CX, CY+20, ['IOTAgri'], 29, '#163754', True))
    for alias, (x, y) in positions.items():
        name = entities[alias]
        lines = [name]
        svg.append(f'<g data-entity="{alias}"><rect x="{x-110:.2f}" y="{y-35:.2f}" '
                   'width="220" height="70" rx="8" fill="#f3eef8" '
                   'stroke="#7138a0" stroke-width="2"/>' + text(x, y+6, lines, 21, bold=True) + '</g>')
    svg += ['</g>', '</svg>', '']
    for filename in ['context-diagram-radial.svg', 'system-context.svg']:
        (ROOT / 'rendered' / filename).write_text('\n'.join(svg), encoding='utf-8')
    print('Rendered: five entities at 72-degree intervals, nine directed flows')


if __name__ == '__main__':
    render()
