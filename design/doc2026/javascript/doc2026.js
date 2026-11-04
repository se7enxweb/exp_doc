/*
 * exp_doc Modern (doc2026): the page's behavior. Plain JavaScript, no framework, no inline handlers; loaded at the
 * end of the body by pagelayout.tpl, so the page works under script-src 'self'. Every part is an enhancement: the
 * page is complete without it.
 *
 * - the page tree (parts/doc_tree.tpl): branches off the page's path close, a button opens each; on a phone the
 *   tree is a drawer behind the header's menu button;
 * - the page's contents (the right column): built from the article's h2 and h3, the heading in view marked;
 * - heading links: every h2/h3/h4 of the article gets an id and a "link to this heading" button that copies it;
 * - code blocks: a copy button, and a light highlighting of comments, strings, numbers and keywords (text nodes in
 *   spans with classes; the code itself is never parsed as HTML);
 * - the color mode button (javascript/doc2026-theme.js does the work).
 */
(() => {
    'use strict';
    const doc = document;
    let strings = {};
    try {
        const el = doc.getElementById('exp-doc-strings');
        strings = el ? JSON.parse(el.textContent) : {};
    } catch (e) { strings = {}; }
    const t = (key, fallback) => strings[key] || fallback;

    /* ---- the page tree ---------------------------------------------------------------------------------- */
    const tree = doc.querySelector('[data-exp-doc-tree]');
    if (tree) {
        tree.querySelectorAll('[data-exp-doc-tree-toggle]').forEach((button) => {
            const branch = doc.getElementById(button.getAttribute('aria-controls'));
            if (!branch) { return; }
            button.hidden = false;
            if (branch.hasAttribute('data-exp-doc-tree-closed')) { branch.hidden = true; }
            button.addEventListener('click', () => {
                const open = button.getAttribute('aria-expanded') !== 'true';
                button.setAttribute('aria-expanded', open ? 'true' : 'false');
                branch.hidden = !open;
                button.closest('.exp-doc-tree-item').classList.toggle('is-open', open);
            });
        });
        const current = tree.querySelector('[aria-current="page"]');
        if (current && current.scrollIntoView) { current.scrollIntoView({ block: 'nearest' }); }

        const drawerButton = doc.querySelector('[data-exp-doc-tree-button]');
        if (drawerButton) {
            drawerButton.hidden = false;
            const close = () => {
                drawerButton.setAttribute('aria-expanded', 'false');
                doc.documentElement.classList.remove('exp-doc-tree-open');
            };
            drawerButton.addEventListener('click', () => {
                const open = drawerButton.getAttribute('aria-expanded') !== 'true';
                drawerButton.setAttribute('aria-expanded', open ? 'true' : 'false');
                doc.documentElement.classList.toggle('exp-doc-tree-open', open);
                if (open) { const first = tree.querySelector('a'); if (first) { first.focus(); } }
            });
            doc.addEventListener('keydown', (event) => { if (event.key === 'Escape') { close(); } });
        }
    }

    /* ---- headings: ids, links, the page's contents ------------------------------------------------------- */
    const body = doc.querySelector('[data-exp-doc-body]');
    const slug = (text) => text.toLowerCase().normalize('NFKD').replace(/[\u0300-\u036f]/g, '')
        .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'section';
    const used = new Set(Array.from(doc.querySelectorAll('[id]'), (el) => el.id));
    const headings = body ? Array.from(body.querySelectorAll('h2, h3, h4')) : [];
    headings.forEach((heading) => {
        if (!heading.id) {
            let id = slug(heading.textContent);
            let n = 2;
            while (used.has(id)) { id = `${slug(heading.textContent)}-${n++}`; }
            heading.id = id;
            used.add(id);
        }
        const link = doc.createElement('button');
        link.type = 'button';
        link.className = 'exp-doc-anchor';
        link.setAttribute('aria-label', t('copyLink', 'Copy the link to this heading'));
        link.textContent = '#';
        link.addEventListener('click', () => {
            const url = `${window.location.href.split('#')[0]}#${heading.id}`;
            if (navigator.clipboard) { navigator.clipboard.writeText(url).catch(() => {}); }
            window.history.replaceState(null, '', `#${heading.id}`);
            link.classList.add('is-done');
            window.setTimeout(() => link.classList.remove('is-done'), 1500);
        });
        heading.appendChild(link);
    });

    const onpage = doc.querySelector('[data-exp-doc-onpage]');
    const list = doc.querySelector('[data-exp-doc-onpage-list]');
    const tocHeadings = headings.filter((h) => h.tagName !== 'H4');
    if (onpage && list) {
        if (tocHeadings.length < 2) {
            onpage.hidden = true;
        } else {
            tocHeadings.forEach((heading) => {
                const item = doc.createElement('li');
                item.className = heading.tagName === 'H3' ? 'is-sub' : '';
                const a = doc.createElement('a');
                a.href = `#${heading.id}`;
                a.textContent = heading.firstChild && heading.firstChild.nodeType === 3
                    ? heading.firstChild.textContent.trim() : heading.textContent.replace(/#$/, '').trim();
                item.appendChild(a);
                list.appendChild(item);
            });
            if ('IntersectionObserver' in window) {
                const links = new Map(Array.from(list.querySelectorAll('a'), (a) => [a.hash.slice(1), a]));
                const observer = new IntersectionObserver((entries) => {
                    entries.forEach((entry) => {
                        if (!entry.isIntersecting) { return; }
                        links.forEach((a) => a.removeAttribute('aria-current'));
                        const a = links.get(entry.target.id);
                        if (a) { a.setAttribute('aria-current', 'location'); }
                    });
                }, { rootMargin: '0px 0px -70% 0px' });
                tocHeadings.forEach((h) => observer.observe(h));
            }
        }
    }

    /* ---- code blocks: copy and highlighting --------------------------------------------------------------- */
    const KEYWORDS = new Set(('abstract and array as break case catch class clone const continue declare default do echo '
        + 'else elseif empty enddeclare endfor endforeach endif endswitch endwhile extends final finally fn for foreach '
        + 'function global if implements include include_once instanceof interface isset list match namespace new null '
        + 'or print private protected public readonly require require_once return static switch throw trait true false try '
        + 'unset use var while yield def undef set foreach let async await import export from').split(' '));
    const TOKENS = /(\/\*[\s\S]*?\*\/|\/\/[^\n]*|#[^\n]*|<!--[\s\S]*?-->|\{\*[\s\S]*?\*\})|("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')|(\b\d+(?:\.\d+)?\b)|(\b[A-Za-z_][A-Za-z0-9_]*\b)/g;
    const highlight = (code) => {
        const text = code.textContent;
        if (text.length > 20000) { return; }
        const out = doc.createDocumentFragment();
        let last = 0;
        text.replace(TOKENS, (match, comment, string, number, word, offset) => {
            let cls = '';
            if (comment) { cls = 'tok-comment'; } else if (string) { cls = 'tok-string'; } else if (number) { cls = 'tok-number'; } else if (word && KEYWORDS.has(word)) { cls = 'tok-keyword'; }
            if (!cls) { return match; }
            out.appendChild(doc.createTextNode(text.slice(last, offset)));
            const span = doc.createElement('span');
            span.className = cls;
            span.textContent = match;
            out.appendChild(span);
            last = offset + match.length;
            return match;
        });
        out.appendChild(doc.createTextNode(text.slice(last)));
        code.textContent = '';
        code.appendChild(out);
    };
    (body ? body.querySelectorAll('pre') : []).forEach((pre) => {
        const lines = pre.querySelectorAll(':scope > span.line');
        const source = lines.length ? Array.from(lines, (l) => (l.textContent === '\u00a0' ? '' : l.textContent)).join('\n') : pre.textContent;
        const code = doc.createElement('code');
        code.textContent = source;
        pre.textContent = '';
        pre.appendChild(code);
        highlight(code);
        const wrap = doc.createElement('div');
        wrap.className = 'exp-doc-code';
        pre.parentNode.insertBefore(wrap, pre);
        wrap.appendChild(pre);
        const copy = doc.createElement('button');
        copy.type = 'button';
        copy.className = 'a4-btn exp-doc-copy';
        copy.textContent = t('copy', 'Copy');
        copy.addEventListener('click', () => {
            if (!navigator.clipboard) { return; }
            navigator.clipboard.writeText(source).then(() => {
                copy.textContent = t('copied', 'Copied');
                window.setTimeout(() => { copy.textContent = t('copy', 'Copy'); }, 1500);
            }).catch(() => {});
        });
        wrap.appendChild(copy);
    });

    /* ---- the color mode button ---------------------------------------------------------------------------- */
    const themeButton = doc.querySelector('[data-exp-doc-theme]');
    if (themeButton && window.expDocTheme) {
        const label = themeButton.querySelector('[data-exp-doc-theme-label]');
        const names = { system: t('themeSystem', 'System'), light: t('themeLight', 'Light'), dark: t('themeDark', 'Dark') };
        const show = () => { if (label) { label.textContent = names[window.expDocTheme.choice()]; } };
        themeButton.hidden = false;
        show();
        themeButton.addEventListener('click', () => { window.expDocTheme.next(); show(); });
    }
})();
