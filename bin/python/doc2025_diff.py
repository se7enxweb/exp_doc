#!/usr/bin/env python3
"""The Classic design's exactness check: every imported page against the static file it came from.

usage: doc2025_diff.py --site <doc site URL> --static-base <static site URL> --map <source map TSV>
                       [--catalog <catalog.json>] [--out <dir>] [--sample N] [--only <path prefix>]
                       [--screenshots] [--width 1440] [--threshold 0.005]

The source map is the TSV that bin/php/doc-source-map.php writes: <static path> TAB <page URL on the doc site>,
one line per imported page (a static path that was merged into another page maps to that page).

For each page:
- markup: the page area (div#page) of both documents is normalized and compared:
  * scripts, comments and the allowed modern exceptions are left out (the header switches #exp-doc-switches,
    the cookie banner #exp-cc, the front-end editing toolbar, the version badge .exp-doc-runs-on);
  * inline styles and the exp-doc-* classes that replace them are ignored, and so is rel="noopener" (kept on the
    links that open a new window for security, a decided modern difference), and so are inline event handlers
    (onload=..., no inline scripts);
  * links are compared by target: a static link is resolved to the static file it names, a dynamic link to the
    static file its page came from (through the map); images by file name;
  * text is compared with its whitespace collapsed; attributes in any order;
  * the decided modern exceptions of the rebranding rule: the copyright's end year (any "1998 - <year>"), and the
    head's meta author and copyright (7x, Exponential Foundation and 7x), which lie outside the compared page area;
    the holder "Exponential Foundation and" before 7x in the footer's copyright (owner 2026-11-04);
  * the brand: the official Exponential logo (svg.exp-logo) in place of the static logo image in the header;
- screenshot (--screenshots): both pages at the given width, the exceptions hidden, compared pixel by pixel;
  a page passes when at most --threshold of its pixels differ (0.005 = 0.5 %, doc.md wave 5 answer 23).
Writes <out>/report.json (every page), <out>/report.md (per layout family: pages, markup equal, screenshot equal,
the first differences) and prints PASS or FAIL with the totals.
"""
import argparse
import collections
import io
import json
import os
import posixpath
import re
import sys
import urllib.parse
import urllib.request

from lxml import html as lhtml

EXCEPTION_IDS = {'exp-doc-switches', 'exp-cc', 'expwt', 'exp-wt', 'ezwt', 'exp-cc-config'}
# the decided additions left out of the comparison: the version badge, and the page's Contributors list (a
# list the static site did not have, owner 2026-11-04)
# the page's rating (owner 2026-11-04), and the help center's bottom blocks at the end of the front page
# (exp_doc/landing_org.tpl, owner 2026-11-04), with its "Start where you are" card, which the front page draws
# below the static page's current lists (exp_doc/landing_start.tpl, owner 2026-11-04), and "Who makes Exponential"
# at the top of the front page, before the static page's content (.exp-doc-landing-about, as in Modern, owner 2026-11-04);
# and a product's box after the heading of its container (.exp-doc-product, the products' landing pages, owner 2026-11-04)
EXCEPTION_CLASSES = {'exp-doc-runs-on', 'exp-doc-contributors', 'exp-doc-rating', 'exp-doc-landing-org', 'exp-doc-landing-about',
                     'exp-doc-landing-start', 'exp-doc-product'}
# wrappers that are an exception while what they hold is static markup: compared as if they were not there
UNWRAP_TAGS = {'details'}
UNWRAP_CLASSES = {'exp-doc-comments-toggle'}
# Decided modern exceptions in text (doc.md, the rebranding rule): the copyright runs to the current year, so any
# end year of "1998 - <year>" counts as equal
YEAR_RANGE = re.compile(r'(\b1998\s*-\s*)\d{4}\b')
# ... and the holder named before 7x (owner 2026-11-04: "Exponential Foundation and 7x"), so the dynamic
# "1998 - <year> Exponential Foundation and <a>7x</a>" equals the static "1998 - <year> <a>7x</a>"
HOLDER = re.compile(r'(\b1998 - YEAR) Exponential Foundation and$')


def norm_text(text):
    """A text or tail as compared: whitespace collapsed, the copyright's end year and holder normalized."""
    return HOLDER.sub(r'\1', YEAR_RANGE.sub(r'\g<1>YEAR', re.sub(r'\s+', ' ', text).strip()))


DROP_TAGS = {'script', 'noscript', 'style', 'exp-wt'}
# hidden form fields carry internal ids (node and class ids of the old site and of this one)
HIDDEN_INPUT = 'hidden'


def fetch(url, timeout=60):
    req = urllib.request.Request(url, headers={'User-Agent': 'exp-doc-diff/1'})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read().decode('utf-8', 'replace')


class Normalizer:
    def __init__(self, url_to_static, static_base, site):
        self.url_to_static = url_to_static
        self.static_base = static_base.rstrip('/')
        self.site = site.rstrip('/')

    def static_target(self, href, page_path):
        """A link of a static page, resolved to the static file it names."""
        if not href or href.startswith(('#', 'mailto:', 'javascript:')):
            return href
        parsed = urllib.parse.urlparse(href)
        if parsed.scheme in ('http', 'https'):
            if href.startswith(self.static_base):
                path = parsed.path.lstrip('/')
            else:
                return href
        elif href.startswith('/'):
            path = parsed.path.lstrip('/')
        else:
            path = posixpath.normpath(posixpath.join(posixpath.dirname(page_path), parsed.path))
            while path.startswith("../"):
                path = path[3:]  # above the site root: a browser stays at the root
        if path.endswith('/') or path == '':
            path = path + 'index.html'
        return 'page:' + urllib.parse.unquote(path)

    def dynamic_target(self, href):
        """A link of a dynamic page, mapped back to the static file its page was imported from."""
        if not href or href.startswith(('#', 'mailto:', 'javascript:')):
            return href
        parsed = urllib.parse.urlparse(href)
        if parsed.scheme in ('http', 'https') and not href.startswith(self.site):
            return href
        path = parsed.path
        site_path = urllib.parse.urlparse(self.site).path.rstrip('/')
        if site_path and path.startswith(site_path):
            path = path[len(site_path):]
        path = re.sub(r'/\(design\)/[a-z0-9_]+$', '', path)
        path = urllib.parse.unquote(path.rstrip('/') or '/')
        if path == '/':
            return 'page:index.html'  # the site's root is the static start page (owner, 2026-11-04)
        if path in self.url_to_static:
            return 'page:' + self.url_to_static[path]
        return 'url:' + path

    def tree(self, doc_html, side, page_path):
        root = lhtml.fromstring(doc_html)
        page = root.find('.//div[@id="page"]')
        if page is None:
            page = root.find('.//body')
        if page is None:
            return []
        out = []
        self._walk(page, side, page_path, out, 0)
        return out

    def _skip(self, el):
        if not isinstance(el.tag, str) or el.tag in DROP_TAGS:
            return True
        # the brand: the official logo (an inline svg.exp-logo) replaced the static logo image in the header
        if el.tag == 'a' and el.getparent() is not None and 'grid_3' in (el.getparent().get('class') or '') \
                and any(a.get('id') == 'logo' for a in el.iterancestors()):
            return True  # the logo's link: the brand exception, with the logo it carries
        if 'exp-logo' in (el.get('class') or '').split() or (el.tag == 'img' and (el.get('src') or '').endswith('exponential.png')
                                                              and any(a.get('id') == 'logo' for a in el.iterancestors())):
            return True
        if el.tag == 'input' and (el.get('type') or '').lower() == HIDDEN_INPUT:
            return True
        if el.get('id') in EXCEPTION_IDS:
            return True
        classes = set((el.get('class') or '').split())
        return bool(classes & EXCEPTION_CLASSES)

    def _walk(self, el, side, page_path, out, depth):
        if self._skip(el):
            return
        if el.tag in UNWRAP_TAGS and set((el.get('class') or '').split()) & UNWRAP_CLASSES:
            # a listed exception that only wraps static markup (the collapsed historical comments): its children
            # count as if the wrapper were not there, its summary not at all
            for child in el:
                if child.tag != 'summary':
                    self._walk(child, side, page_path, out, depth)
                    tail = norm_text(child.tail or "")
                    if tail:
                        out.append(('text', depth, tail))
            return
        attrs = []
        for name, value in el.attrib.items():
            if name == 'style':
                continue
            if name.startswith('on'):
                # inline event handlers (the static pages' onload="placeFocus()" on body): no inline scripts, a decided
                # modern exception
                continue
            if name == 'class':
                value = ' '.join(sorted(c for c in value.split() if not c.startswith('exp-doc-')))
                if not value:
                    continue
            if name == 'rel':
                # a decided modern difference (security): links that open a new window (the footer's social links,
                # target="_blank") carry rel="noopener", which the static pages did not have; other rel values count
                value = ' '.join(sorted(r for r in value.split() if r != 'noopener'))
                if not value:
                    continue
            if name in ('href', 'action'):
                value = self.static_target(value, page_path) if side == 'static' else self.dynamic_target(value)
            if name == 'src':
                value = posixpath.basename(urllib.parse.urlparse(value).path)
            attrs.append('%s=%s' % (name, value))
        out.append(('open', depth, el.tag, tuple(sorted(attrs))))
        text = norm_text(el.text or "")
        if text:
            out.append(('text', depth, text))
        for child in el:
            self._walk(child, side, page_path, out, depth + 1)
            tail = norm_text(child.tail or "")
            if tail:
                out.append(("text", depth, tail))
        out.append(('close', depth, el.tag))


def first_difference(a, b):
    for i, (x, y) in enumerate(zip(a, b)):
        if x != y:
            return i, x, y
    if len(a) != len(b):
        i = min(len(a), len(b))
        return i, a[i] if i < len(a) else None, b[i] if i < len(b) else None
    return None


def screenshot_ratio(browser, static_url, dynamic_url, width):
    from PIL import Image, ImageChops
    shots = []
    for url, hide in ((static_url, False), (dynamic_url, True)):
        page = browser.new_page(viewport={'width': width, 'height': 900})
        page.goto(url, wait_until='networkidle', timeout=60000)
        if hide:
            page.add_style_tag(content='#exp-doc-switches,#exp-cc,.exp-doc-runs-on,exp-wt,#expwt,#ezwt{display:none!important}')
        shots.append(Image.open(io.BytesIO(page.screenshot(full_page=True))).convert('RGB'))
        page.close()
    a, b = shots
    w, h = max(a.width, b.width), max(a.height, b.height)
    canvas_a, canvas_b = Image.new('RGB', (w, h), 'white'), Image.new('RGB', (w, h), 'white')
    canvas_a.paste(a, (0, 0))
    canvas_b.paste(b, (0, 0))
    diff = ImageChops.difference(canvas_a, canvas_b).convert('L').point(lambda v: 255 if v > 16 else 0)
    changed = diff.histogram()[255]
    return changed / float(w * h)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--site', required=True)
    ap.add_argument('--static-base', required=True)
    ap.add_argument('--map', required=True)
    ap.add_argument('--catalog')
    ap.add_argument('--out', default='doc2025-diff')
    ap.add_argument('--sample', type=int, default=0)
    ap.add_argument('--only', default='')
    ap.add_argument('--screenshots', action='store_true')
    ap.add_argument('--width', type=int, default=1440)
    ap.add_argument('--threshold', type=float, default=0.005)
    ap.add_argument('--design', default='', help='a design for the kernel design switch, e.g. doc2025 (adds /(design)/<name>)')
    ap.add_argument('--dump', action='store_true', help='also write both normalized token lists of every page to <out>/tokens/, one per line, for diff -u')
    args = ap.parse_args()

    pairs = []
    url_to_static = {}
    with open(args.map) as fh:
        for line in fh:
            parts = line.rstrip('\n').split('\t')
            if len(parts) != 2:
                continue
            static_path, url = parts
            if '#' in static_path:
                continue  # a comment or another part of a page: drawn by its page, not a page of its own
            pairs.append((static_path, url))
            path = urllib.parse.urlparse(url).path
            site_path = urllib.parse.urlparse(args.site).path.rstrip('/')
            if site_path and path.startswith(site_path):
                path = path[len(site_path):]
            url_to_static.setdefault(path.rstrip('/') or '/', static_path)
    catalog = json.load(open(args.catalog)) if args.catalog else {}

    if args.only:
        pairs = [p for p in pairs if p[0].startswith(args.only)]
    if args.sample:
        per_family = collections.defaultdict(list)
        for p in pairs:
            per_family[tuple(catalog.get(p[0], ['?', '?'])[:2])].append(p)
        pairs = [p for group in per_family.values() for p in group[:args.sample]]

    norm = Normalizer(url_to_static, args.static_base, args.site)
    os.makedirs(args.out, exist_ok=True)
    browser = None
    if args.screenshots:
        from playwright.sync_api import sync_playwright
        pw = sync_playwright().start()
        browser = pw.chromium.launch()

    results = []
    for static_path, url in pairs:
        family = '/'.join(catalog.get(static_path, ['?', '?'])[:2])
        static_url = args.static_base.rstrip('/') + '/' + static_path
        if args.design:
            url = url.rstrip('/') + '/(design)/' + args.design
        row = {'static': static_path, 'url': url, 'family': family}
        try:
            a = norm.tree(fetch(static_url), 'static', static_path)
            b = norm.tree(fetch(url), 'dynamic', static_path)
            if args.dump:
                os.makedirs(os.path.join(args.out, 'tokens'), exist_ok=True)
                stem = os.path.join(args.out, 'tokens', re.sub(r'[^A-Za-z0-9._-]+', '_', static_path))
                for side, tokens in (('static', a), ('dynamic', b)):
                    with open('%s.%s.txt' % (stem, side), 'w') as fh:
                        fh.write('\n'.join(repr(t) for t in tokens) + '\n')
            diff = first_difference(a, b)
            row['markup_equal'] = diff is None
            if diff:
                row['difference'] = {'at': diff[0], 'static': repr(diff[1])[:300], 'dynamic': repr(diff[2])[:300]}
            if browser:
                row['pixel_ratio'] = round(screenshot_ratio(browser, static_url, url, args.width), 5)
                row['screenshot_equal'] = row['pixel_ratio'] <= args.threshold
        except Exception as e:  # a page that cannot be fetched is a failure of that page, not of the run
            row['markup_equal'] = False
            row['error'] = str(e)[:300]
        results.append(row)

    if browser:
        browser.close()

    with open(os.path.join(args.out, 'report.json'), 'w') as fh:
        json.dump(results, fh, indent=1)
    by = collections.defaultdict(list)
    for r in results:
        by[r['family']].append(r)
    lines = ['# Classic (doc2025) against the static site', '',
             '| Layout | Pages | Markup equal | Screenshot equal |', '|---|---|---|---|']
    for family, rows in sorted(by.items()):
        shots = [r for r in rows if 'screenshot_equal' in r]
        lines.append('| %s | %d | %d | %s |' % (family, len(rows), sum(1 for r in rows if r.get('markup_equal')),
                                               '%d/%d' % (sum(1 for r in shots if r['screenshot_equal']), len(shots)) if shots else '-'))
    lines += ['', '## First differences', '']
    for r in results:
        if not r.get('markup_equal') or r.get('screenshot_equal') is False:
            lines.append('- `%s` (%s): %s' % (r['static'], r['family'],
                                               r.get('error') or json.dumps(r.get('difference', {}))[:400]
                                               + ('; pixels %.2f %%' % (100 * r['pixel_ratio']) if 'pixel_ratio' in r else '')))
    with open(os.path.join(args.out, 'report.md'), 'w') as fh:
        fh.write('\n'.join(lines) + '\n')

    equal = sum(1 for r in results if r.get('markup_equal') and r.get('screenshot_equal', True))
    print('%s %d of %d pages equal (report: %s)' % ('PASS' if equal == len(results) else 'FAIL', equal, len(results),
                                                    os.path.join(args.out, 'report.md')))
    return 0 if equal == len(results) else 1


if __name__ == '__main__':
    sys.exit(main())
