#!/usr/bin/env python3
"""Builds the documentation site's brand images from the official Exponential logo (the exponential.earth header's
SVG): favicons, touch and app icons, the web app manifest, and the Open Graph / social images, for each design.

usage: doc_brand_images.py <official logo svg> <design images dir> [<design images dir> ...]
       [--manual "Technical manual" --manual "User manual" ...]   (an extra social image per manual)

Writes into every images directory:
  favicon.svg                 the two squares of the logo, with its own dark-mode colors (a style inside the SVG)
  favicon.ico                 16, 32 and 48 pixels
  apple-touch-icon.png        180 pixels, on the light background
  icon-192.png, icon-512.png  app icons; icon-maskable-512.png with the safe zone (the mark at 60 % on the accent)
  site.webmanifest            name, short name, icons, theme color (the accent token) and background (the surface)
  og-default.png / .webp      1200 x 630: the logo and "Documentation" on the brand's dark background
  og-<manual>.png / .webp     the same with the manual's name, for each --manual
Rendering is done by Chromium (Playwright), the ICO and WebP files by Pillow. Prints PASS with the file list.

The colors are the design tokens of components.css: accent #f26a21 (theme color), light surface #ffffff and ink
#1f2430, dark surface #1a1f29 and ink #e8ebf0; the logo's own orange square stays #f05a28.
"""
import io
import json
import os
import re
import sys

from PIL import Image
from playwright.sync_api import sync_playwright

ACCENT, LOGO_ORANGE = '#f26a21', '#f05a28'
LIGHT_SURFACE, LIGHT_INK = '#ffffff', '#1f2430'
DARK_SURFACE, DARK_INK = '#1a1f29', '#e8ebf0'

args = sys.argv[1:]
manuals = []
while '--manual' in args:
    i = args.index('--manual')
    manuals.append(args[i + 1])
    del args[i:i + 2]
source, outdirs = args[0], args[1:]
svg = open(source, encoding='utf-8').read()
paths = re.findall(r'<path[^>]*>\s*</path>', svg)
# the mark is the last four paths: the back square's paper and frame, the front square and its frame
mark_paths = paths[-4:]
word_paths = paths[:-4]


def colored(path, ink, paper, accent=LOGO_ORANGE):
    path = path.replace('style="fill: var(--bs-dark);"', 'fill="%s"' % ink)
    path = path.replace('style="fill: var(--bs-light);"', 'fill="%s"' % paper)
    return path.replace('style="fill: #f05a28;"', 'fill="%s"' % accent)


def mark_svg(ink, paper, size=None):
    body = ''.join(colored(p, ink, paper) for p in mark_paths)
    dims = ' width="%d" height="%d"' % (size, size) if size else ''
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="-1 -1 49 49"%s>%s</svg>' % (dims, body)


def logo_svg(ink, paper):
    body = ''.join(colored(p, ink, paper) for p in paths)
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 388 59">%s</svg>' % body


favicon = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="-1 -1 49 49">'
           '<style>.i{fill:%s}.p{fill:%s}@media (prefers-color-scheme: dark){.i{fill:%s}.p{fill:%s}}</style>%s</svg>'
           % (LIGHT_INK, LIGHT_SURFACE, DARK_INK, DARK_SURFACE,
              ''.join(p.replace('style="fill: var(--bs-dark);"', 'class="i"')
                       .replace('style="fill: var(--bs-light);"', 'class="p"')
                       .replace('style="fill: #f05a28;"', 'fill="%s"' % LOGO_ORANGE) for p in mark_paths)))


def page(html_body, width, height, background):
    return ('<!doctype html><html><head><meta charset="utf-8"><style>html,body{margin:0;width:%dpx;height:%dpx;'
            'background:%s;overflow:hidden;font-family:"Noto Sans","Segoe UI",Arial,sans-serif}</style></head>'
            '<body>%s</body></html>' % (width, height, background, html_body))


def icon_page(size, background, scale, ink, paper):
    inner = int(size * scale)
    return page('<div style="display:flex;align-items:center;justify-content:center;width:%dpx;height:%dpx">%s</div>'
                % (size, size, mark_svg(ink, paper, inner)), size, size, background)


def og_page(title):
    return page('<div style="box-sizing:border-box;width:1200px;height:630px;padding:96px;display:flex;flex-direction:column;'
                'justify-content:center;gap:40px;background:radial-gradient(900px 520px at 85%% -10%%,rgba(242,106,33,.30),transparent 60%%),%s">'
                '<div style="width:760px">%s</div>'
                '<div style="color:%s;font-size:64px;font-weight:700;letter-spacing:-.01em">%s</div>'
                '<div style="height:10px;width:180px;background:%s;border-radius:5px"></div></div>'
                % (DARK_SURFACE, logo_svg(DARK_INK, DARK_SURFACE), DARK_INK, title, ACCENT), 1200, 630, DARK_SURFACE)


def render(browser, html, width, height, transparent=False):
    pg = browser.new_page(viewport={'width': width, 'height': height})
    pg.set_content(html)
    data = pg.screenshot(omit_background=transparent)
    pg.close()
    return Image.open(io.BytesIO(data)).convert('RGBA')


def slug(text):
    return re.sub(r'[^a-z0-9]+', '-', text.lower()).strip('-')


written = []
with sync_playwright() as pw:
    browser = pw.chromium.launch()
    images = {}
    for size in (16, 32, 48):
        images['ico%d' % size] = render(browser, icon_page(size, 'transparent', 1.0, LIGHT_INK, LIGHT_SURFACE), size, size, True)
    images['apple'] = render(browser, icon_page(180, LIGHT_SURFACE, 0.72, LIGHT_INK, LIGHT_SURFACE), 180, 180)
    images['192'] = render(browser, icon_page(192, LIGHT_SURFACE, 0.78, LIGHT_INK, LIGHT_SURFACE), 192, 192)
    images['512'] = render(browser, icon_page(512, LIGHT_SURFACE, 0.78, LIGHT_INK, LIGHT_SURFACE), 512, 512)
    images['maskable'] = render(browser, icon_page(512, ACCENT, 0.6, LIGHT_INK, LIGHT_SURFACE), 512, 512)
    images['og-default'] = render(browser, og_page('Documentation'), 1200, 630)
    for manual in manuals:
        images['og-' + slug(manual)] = render(browser, og_page('Documentation &middot; %s' % manual), 1200, 630)
    browser.close()

for outdir in outdirs:
    os.makedirs(outdir, exist_ok=True)

    def save(name, data, mode='w'):
        path = os.path.join(outdir, name)
        with open(path, mode) as fh:
            fh.write(data)
        written.append(path)

    save('favicon.svg', favicon)
    ico = os.path.join(outdir, 'favicon.ico')
    images['ico48'].save(ico, sizes=[(16, 16), (32, 32), (48, 48)],
                         append_images=[images['ico16'], images['ico32']])
    written.append(ico)
    for key, name in (('apple', 'apple-touch-icon.png'), ('192', 'icon-192.png'), ('512', 'icon-512.png'),
                      ('maskable', 'icon-maskable-512.png')):
        images[key].convert('RGB').save(os.path.join(outdir, name), optimize=True)
        written.append(os.path.join(outdir, name))
    for key in [k for k in images if k.startswith('og-')]:
        rgb = images[key].convert('RGB')
        rgb.save(os.path.join(outdir, key + '.png'), optimize=True)
        rgb.save(os.path.join(outdir, key + '.webp'), quality=88)
        written += [os.path.join(outdir, key + '.png'), os.path.join(outdir, key + '.webp')]
    manifest = {
        'name': 'Exponential Documentation',
        'short_name': 'Exponential Docs',
        'start_url': '../../../../../',
        'display': 'browser',
        'theme_color': ACCENT,
        'background_color': LIGHT_SURFACE,
        'icons': [
            {'src': 'icon-192.png', 'sizes': '192x192', 'type': 'image/png'},
            {'src': 'icon-512.png', 'sizes': '512x512', 'type': 'image/png'},
            {'src': 'icon-maskable-512.png', 'sizes': '512x512', 'type': 'image/png', 'purpose': 'maskable'},
        ],
    }
    save('site.webmanifest', json.dumps(manifest, indent=2) + '\n')

print('PASS %d files:\n%s' % (len(written), '\n'.join(written)))
