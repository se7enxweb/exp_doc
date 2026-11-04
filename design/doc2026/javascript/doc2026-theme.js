/*
 * exp_doc Modern (doc2026): the color mode (light, dark, or the system's), set before the stylesheets are drawn.
 *
 * Loaded in <head> by pagelayout.tpl as a file of its own, not an inline script, so the page runs under a Content
 * Security Policy of script-src 'self'. It sets the attributes the admin4 tokens read (components.css):
 *
 *   html[data-a4-theme]          light|dark          the tokens' mode
 *   html[data-exp-theme-choice]  light|dark|system   what the header's switch shows
 *
 * The choice is kept in this browser (localStorage "exp-doc-theme", or a cookie of that name when the storage is
 * blocked); the server never reads it, so cached pages are the same for everyone. Without a choice the system's mode
 * is followed, also when it changes while the page is open. The switch (#exp-doc-theme in parts/doc_header.tpl) is
 * wired by doc2026.js through window.expDocTheme. Printing uses the light mode.
 */
(() => {
    'use strict';
    const KEY = 'exp-doc-theme';
    const CHOICES = ['light', 'dark', 'system'];
    const root = document.documentElement;
    root.classList.add('exp-doc-js');
    const mq = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;

    const valid = (value) => (CHOICES.includes(value) ? value : '');
    const readCookie = () => {
        const m = document.cookie.match(/(?:^|;\s*)exp_doc_theme=([a-z]+)/);
        return m ? valid(m[1]) : '';
    };
    const stored = () => {
        let value = '';
        try { value = valid(window.localStorage.getItem(KEY) || ''); } catch (e) { /* blocked storage */ }
        return value || readCookie() || 'system';
    };
    const save = (choice) => {
        try { window.localStorage.setItem(KEY, choice); } catch (e) { /* blocked storage: the cookie keeps it */ }
        const secure = window.location.protocol === 'https:' ? '; Secure' : '';
        document.cookie = `exp_doc_theme=${choice}; Max-Age=31536000; Path=/; SameSite=Lax${secure}`;
    };
    const apply = (value) => {
        const choice = valid(value) || 'system';
        const mode = choice === 'system' ? (mq && mq.matches ? 'dark' : 'light') : choice;
        root.setAttribute('data-a4-theme', mode);
        root.setAttribute('data-exp-theme-choice', choice);
        return choice;
    };

    let current = apply(stored());
    if (mq && mq.addEventListener) {
        mq.addEventListener('change', () => { if (current === 'system') { apply('system'); } });
    }
    window.addEventListener('beforeprint', () => root.setAttribute('data-a4-theme', 'light'));
    window.addEventListener('afterprint', () => apply(current));

    window.expDocTheme = {
        choice: () => current,
        set: (choice) => { current = apply(choice); save(current); return current; },
        next: () => {
            const order = ['system', 'light', 'dark'];
            return window.expDocTheme.set(order[(order.indexOf(current) + 1) % order.length]);
        }
    };
})();
