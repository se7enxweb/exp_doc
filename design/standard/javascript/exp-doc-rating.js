/**
 * The page rating of the documentation designs (design:exp_doc/rating_form.tpl): five radio buttons that post the
 * chosen stars to the extension ezstarrating's ezjscore function ezstarrating::rate (the attribute id, its version,
 * the stars), with the form token when the page has one, and show the new average or why it was not taken. An ES
 * module, no inline script, no jQuery or YUI. The extension decides what counts: one rating per visitor and page
 * (site.ini [eZStarRating]); a repeated one comes back as already_rated.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 */

const post = async (url, args) => {
    const tokenNode = document.getElementById('ezxform_token_js');
    const body = new URLSearchParams();
    body.set('ezjscServer_function_arguments', args);
    body.set('ezxform_token', tokenNode ? (tokenNode.getAttribute('title') || '') : '');
    const response = await fetch(url.replace(/\/$/, '') + '/', {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
        body,
    });
    if (!response.ok) {
        throw new Error('HTTP ' + response.status);
    }
    return response.json();
};

const setup = (form) => {
    const choice = form.querySelector('[data-exp-rating-choice]');
    const status = form.querySelector('[data-exp-rating-status]');
    const numbers = form.querySelector('[data-exp-rating-numbers]');
    if (!choice) {
        return;
    }
    choice.hidden = false;
    form.addEventListener('submit', (event) => event.preventDefault());
    // a pointer chooses with a click; the keyboard moves between the stars with the arrow keys (which only select)
    // and chooses with Enter or Space
    const send = async (input) => {
        if (choice.disabled) {
            return;
        }
        choice.disabled = true;
        const args = ['ezstarrating', 'rate', form.dataset.attribute, form.dataset.version, input.value].join('::');
        try {
            const answer = await post(form.dataset.call, args);
            const content = answer && answer.content ? answer.content : {};
            if (content.rated && content.stats) {
                const count = Number(content.stats.rating_count);
                const average = Number(content.stats.rounded_average);
                if (numbers && form.dataset.numbers) {
                    const pattern = count === 1 && form.dataset.numbersOne ? form.dataset.numbersOne : form.dataset.numbers;
                    numbers.textContent = pattern.replace('%average', String(average)).replace('%count', String(count));
                }
                status.textContent = form.dataset.thanks;
            } else if (content.already_rated) {
                status.textContent = form.dataset.again;
            } else {
                status.textContent = form.dataset.failed;
                choice.disabled = false;
            }
        } catch (error) {
            status.textContent = form.dataset.failed;
            choice.disabled = false;
        }
    };
    choice.addEventListener('click', (event) => {
        if (event.target && event.target.name === 'rating' && event.detail > 0) {
            send(event.target);
        }
    });
    choice.addEventListener('keydown', (event) => {
        if ((event.key === 'Enter' || event.key === ' ') && event.target && event.target.name === 'rating') {
            event.preventDefault();
            event.target.checked = true;
            send(event.target);
        }
    });
};

document.querySelectorAll('[data-exp-rating]').forEach(setup);
