#!/usr/bin/env python3
"""Build Book runtime content PNGs.

Removes designer page digit using SVG path anchor (#4B946A near y≈702–730)
with a TIGHT rect that never intersects page-1 cards (floor y≥698).

All pages → Book1 canvas 1179×2556 + Book1 frame alpha.
Header icons cleared in asset; Flutter draws fixed header + frame + counter + nav.
"""
from __future__ import annotations

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC_SVG = ROOT / 'assets/book/safety'
SRC_PNG = ROOT / 'assets/book/safety/png'
DST = ROOT / 'assets/book/runtime'
CHROME = ROOT / 'assets/book/chrome'
PAGE = '#FEF7E6'
DW, DH, SCALE = 393, 852, 3.0
FX, FY, FW, FH, FR = 11.5, 62.5, 371.0, 688.0, 40.5
W, H = int(DW * SCALE), int(DH * SCALE)


def find_digit_anchor(svg: str) -> tuple[float, float]:
    for m in re.finditer(r'<path\b[^>]*>', svg):
        tag = m.group(0)
        if '#4B946A' not in tag:
            continue
        dm = re.search(r'\bd="([^"]+)"', tag)
        if not dm:
            continue
        mm = re.search(r'[Mm]\s*([-\d.]+)\s+([-\d.]+)', dm.group(1))
        if not mm:
            continue
        x, y = float(mm.group(1)), float(mm.group(2))
        if 150 < x < 250 and 690 < y < 760:
            return x, y
    raise SystemExit('digit path not found')


def build_header() -> None:
    CHROME.mkdir(parents=True, exist_ok=True)
    x0, y0 = int(20 * SCALE), int(70 * SCALE)
    ww, hh = int(353 * SCALE), int(50 * SCALE)
    subprocess.check_call([
        'magick', str(SRC_PNG / 'book_page_01.png'), '-resize', f'{W}x{H}!',
        '-crop', f'{ww}x{hh}+{x0}+{y0}', '+repage', '/tmp/hdr_strip.png',
    ])
    subprocess.check_call([
        'magick', '-size', f'{W}x{H}', 'xc:none',
        '/tmp/hdr_strip.png', '-geometry', f'+{x0}+{y0}', '-compose', 'over', '-composite',
        '-fuzz', '10%', '-transparent', PAGE,
        '-fuzz', '10%', '-transparent', '#FEFCF4',
        str(CHROME / 'book_header.png'),
    ])


def build_page(i: int) -> None:
    svg = (SRC_SVG / f'book_page_0{i}.svg').read_text()
    src = SRC_PNG / f'book_page_0{i}.png'
    ax, ay = find_digit_anchor(svg)
    floor = 698.0 if i == 1 else 670.0
    dx0, dx1 = int((ax - 10) * SCALE), int((ax + 24) * SCALE)
    dy0 = int(max(floor, ay - 36) * SCALE)
    dy1 = int((ay + 5) * SCALE)

    sw, sh = map(int, subprocess.check_output(
        ['magick', str(src), '-format', '%wx%h', 'info:'], text=True).split('x'))
    src_h = int(round(sh * (W / sw)))
    subprocess.check_call(['magick', str(src), '-resize', f'{W}x{src_h}!', f'/tmp/s{i}.png'])
    subprocess.check_call([
        'magick', '-size', f'{W}x{H}', 'xc:none',
        f'/tmp/s{i}.png', '-geometry', '+0+0', '-compose', 'over', '-composite',
        f'/tmp/p{i}.png',
    ])
    subprocess.check_call([
        'magick', f'/tmp/p{i}.png', '-fill', PAGE,
        '-draw', f'rectangle {dx0},{dy0} {dx1},{dy1}', f'/tmp/d{i}.png',
    ])
    hy0, hy1 = int(72 * SCALE), int(116 * SCALE)
    cmd = ['magick', f'/tmp/d{i}.png', '-fill', PAGE]
    for xa, xb in [(24, 78), (150, 270), (318, 368)]:
        cmd += ['-draw', f'rectangle {int(xa * SCALE)},{hy0} {int(xb * SCALE)},{hy1}']
    cmd.append(f'/tmp/h{i}.png')
    subprocess.check_call(cmd)

    fx, fy, fw, fh, fr = FX * SCALE, FY * SCALE, FW * SCALE, FH * SCALE, FR * SCALE
    subprocess.check_call([
        'magick', '-size', f'{W}x{H}', 'xc:black', '-fill', 'white',
        '-draw', f'roundrectangle {fx},{fy} {fx+fw},{fy+fh} {fr},{fr}',
        f'/tmp/m{i}.png',
    ])
    dst = DST / f'book_page_0{i}.png'
    subprocess.check_call([
        'magick', f'/tmp/h{i}.png', f'/tmp/m{i}.png',
        '-alpha', 'off', '-compose', 'CopyOpacity', '-composite', str(dst),
    ])
    print(f'wrote {dst.relative_to(ROOT)} digit_clear=({dx0},{dy0})-({dx1},{dy1})')


def main() -> None:
    DST.mkdir(parents=True, exist_ok=True)
    build_header()
    for i in range(1, 7):
        build_page(i)


if __name__ == '__main__':
    main()
