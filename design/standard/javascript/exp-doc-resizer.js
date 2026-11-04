/**
 * The resizable side column of the documentation designs (both: Modern's page tree, Classic's menu on the help
 * center's pages), shared by them (stylesheets/exp-doc-resizer.css). An ES module, no inline script.
 *
 * Markup:
 *   <div data-exp-resizable="<key>" data-min="224" data-max="480">        the grid: its first column is the side
 *       <button data-exp-drawer-toggle aria-controls="<side id>" hidden>   the drawer button (small screens)
 *       <nav id="<side id>" data-exp-side> ... <div data-exp-resizer role="separator" tabindex="0"></div></nav>
 *       ...the content
 *   </div>
 *
 * - Drag the handle, or focus it and use the arrow keys (Shift: bigger steps), Home and End. The width is the custom
 *   property --exp-doc-side on the grid (CSSOM, so a strict style-src allows it), kept between min and max and in
 *   localStorage per viewer and key (every access in try/catch: private windows and blocked storage just forget it).
 * - Below the breakpoint of the stylesheet the handle is hidden and the side column is a drawer above the content:
 *   the button opens and closes it. Without this script the side column simply stacks above the content.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 */

const STEP = 16;
const BIG_STEP = 64;
const PREFIX = 'exp-doc-side:';

function read(key) {
    try {
        const value = parseInt(window.localStorage.getItem(PREFIX + key), 10);
        return Number.isFinite(value) ? value : null;
    } catch (e) {
        return null;
    }
}

function write(key, value) {
    try {
        window.localStorage.setItem(PREFIX + key, String(value));
    } catch (e) {
        // storage blocked: the width lasts until the page is left
    }
}

function setup(grid) {
    const key = grid.getAttribute('data-exp-resizable') || 'side';
    const side = grid.querySelector('[data-exp-side]');
    const handle = grid.querySelector('[data-exp-resizer]');
    const toggle = grid.querySelector('[data-exp-drawer-toggle]');
    const min = parseInt(grid.getAttribute('data-min'), 10) || 224;
    const max = parseInt(grid.getAttribute('data-max'), 10) || 480;
    const clamp = (value) => Math.max(min, Math.min(max, Math.round(value)));
    const current = () => (side ? side.getBoundingClientRect().width : min);

    const apply = (value, keep) => {
        const width = clamp(value);
        grid.style.setProperty('--exp-doc-side', width + 'px');
        if (handle) {
            handle.setAttribute('aria-valuenow', String(width));
        }
        if (keep) {
            write(key, width);
        }
    };

    if (handle) {
        handle.setAttribute('aria-valuemin', String(min));
        handle.setAttribute('aria-valuemax', String(max));
        const saved = read(key);
        if (saved !== null) {
            apply(saved, false);
        } else {
            handle.setAttribute('aria-valuenow', String(Math.round(current())));
        }

        handle.addEventListener('pointerdown', (event) => {
            if (event.button !== 0) {
                return;
            }
            event.preventDefault();
            const start = event.clientX;
            const startWidth = current();
            const rtl = getComputedStyle(grid).direction === 'rtl';
            handle.setPointerCapture(event.pointerId);
            grid.classList.add('is-resizing');
            const move = (e) => apply(startWidth + (rtl ? start - e.clientX : e.clientX - start), false);
            const end = (e) => {
                handle.releasePointerCapture(e.pointerId);
                handle.removeEventListener('pointermove', move);
                handle.removeEventListener('pointerup', end);
                handle.removeEventListener('pointercancel', end);
                grid.classList.remove('is-resizing');
                apply(current(), true);
            };
            handle.addEventListener('pointermove', move);
            handle.addEventListener('pointerup', end);
            handle.addEventListener('pointercancel', end);
        });

        handle.addEventListener('keydown', (event) => {
            const step = event.shiftKey ? BIG_STEP : STEP;
            const rtl = getComputedStyle(grid).direction === 'rtl';
            let width = null;
            switch (event.key) {
                case 'ArrowLeft': width = current() + (rtl ? step : -step); break;
                case 'ArrowRight': width = current() + (rtl ? -step : step); break;
                case 'ArrowDown': width = current() - step; break;
                case 'ArrowUp': width = current() + step; break;
                case 'Home': width = min; break;
                case 'End': width = max; break;
                default: return;
            }
            event.preventDefault();
            apply(width, true);
        });
    }

    if (toggle && side) {
        toggle.hidden = false;
        grid.classList.add('has-drawer');
        const set = (open) => {
            toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
            grid.classList.toggle('is-drawer-open', open);
        };
        set(false);
        toggle.addEventListener('click', () => set(toggle.getAttribute('aria-expanded') !== 'true'));
    }
}

document.querySelectorAll('[data-exp-resizable]').forEach(setup);
