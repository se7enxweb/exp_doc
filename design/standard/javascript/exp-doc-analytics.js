/*
 * The website statistics tag (Google Analytics through Google Tag Manager), loaded only with the reader's consent.
 *
 * exp_doc/analytics.tpl prints the tag's settings (bcwebsitestatistics.ini) as the JSON element
 * #exp-doc-analytics-config: { id, src, setup, udn }. This script is the "analytics" category of the cookie banner
 * (exp-cookie-consent.js, row data-exp-cc-category="analytics" in exp_doc/cookie_consent.tpl):
 *
 * - nothing from Google is requested before the reader accepts the category ("Accept all", or the switch under
 *   Settings), nor after "Reject all" or a withdrawal;
 * - accepted: Google Consent Mode gets its defaults (statistics storage granted, everything for advertising
 *   denied, as only statistics was asked for), then the tag (src) and the extension's gtag configuration (setup,
 *   with data-bc-ga-id and data-bc-ga-udn as the template operator bc_ga_urchin() printed them) are added;
 * - on every later page the stored choice (cookie ng-cc-consent) loads it again, once the banner has read it;
 * - withdrawn (the footer's "Cookie settings"): Consent Mode is set to denied and Google's opt-out switch is set
 *   for the container and its measurement ids at once, so the tag already in the page sends nothing more, Google's
 *   cookies (_ga, _ga_<id>, _gid, _gat*) are deleted, and the next page loads nothing from Google.
 */
(function () {
    'use strict';

    var NAME = 'analytics';
    var GOOGLE_COOKIE = /^(_ga|_ga_[A-Za-z0-9_-]+|_gid|_gat[A-Za-z0-9_-]*)$/;
    var node = document.getElementById('exp-doc-analytics-config');
    var config = null;
    try {
        config = node ? JSON.parse(node.textContent) : null;
    } catch (e) {
        config = null;
    }
    if (!config || typeof config.id !== 'string' || !config.id || typeof config.src !== 'string' || !/^https:\/\//.test(config.src)) {
        return;
    }

    var loaded = false;
    var granted = false;
    var disabled = [];

    function gtag() {
        window.dataLayer.push(arguments);
    }

    function addScript(src, attributes) {
        var script = document.createElement('script');
        script.async = true;
        script.src = src;
        Object.keys(attributes).forEach(function (name) {
            script.setAttribute(name, attributes[name]);
        });
        document.body.appendChild(script);
    }

    function load() {
        granted = true;
        disabled.splice(0).forEach(function (id) {
            window['ga-disable-' + id] = false;
        });
        if (loaded) {
            gtag('consent', 'update', { analytics_storage: 'granted' });
            return;
        }
        loaded = true;
        window.dataLayer = window.dataLayer || [];
        gtag('consent', 'default', {
            analytics_storage: 'granted',
            ad_storage: 'denied',
            ad_user_data: 'denied',
            ad_personalization: 'denied'
        });
        addScript(config.src, {});
        if (typeof config.setup === 'string' && config.setup) {
            var data = { 'data-bc-ga-id': config.id };
            if (typeof config.udn === 'string' && config.udn) {
                data['data-bc-ga-udn'] = config.udn;
            }
            addScript(config.setup, data);
        }
    }

    /* Each cookie is expired on this host and on every parent domain, where gtag puts it (cookie_domain auto). */
    function dropGoogleCookies() {
        var names = (document.cookie || '').split(';').map(function (part) {
            return part.replace(/^\s+/, '').split('=')[0];
        }).filter(function (name) {
            return GOOGLE_COOKIE.test(name);
        });
        var labels = window.location.hostname.split('.');
        var domains = [''];
        for (var i = 0; i < labels.length - 1; i++) {
            domains.push('; Domain=.' + labels.slice(i).join('.'));
        }
        names.forEach(function (name) {
            domains.forEach(function (domain) {
                document.cookie = name + '=; Path=/; Max-Age=0; Expires=Thu, 01 Jan 1970 00:00:00 GMT' + domain;
            });
        });
    }

    /* The container's Google Analytics measurement ids, read off its cookies (_ga_<X> belongs to G-<X>): Google's
       own opt-out switch (window['ga-disable-<id>']) stops every further hit of the page, also the cookieless
       pings Consent Mode would still send when the page is left. */
    function measurementIds() {
        return (document.cookie || '').split(';').map(function (part) {
            return part.replace(/^\s+/, '').split('=')[0];
        }).filter(function (name) {
            return /^_ga_[A-Za-z0-9]+$/.test(name);
        }).map(function (name) {
            return 'G-' + name.substring(4);
        });
    }

    function withdraw() {
        granted = false;
        if (loaded) {
            gtag('consent', 'update', { analytics_storage: 'denied' });
            [config.id].concat(measurementIds()).forEach(function (id) {
                window['ga-disable-' + id] = true;
                disabled.push(id);
            });
        }
        dropGoogleCookies();
    }

    /* Until start() has run, the stored choice stands for the state: the banner compares the two on
       DOMContentLoaded (before start), and must not read a stored yes as drift. */
    var started = false;

    var handler = {
        isGranted: function () {
            if (!started) {
                return !!(window.ExpCookieConsent && window.ExpCookieConsent.has(NAME));
            }
            return granted;
        },
        apply: function (on) {
            if (on) {
                load();
            } else {
                withdraw();
            }
        }
    };

    if (window.ExpCookieConsent && typeof window.ExpCookieConsent.register === 'function') {
        window.ExpCookieConsent.register(NAME, handler);
    } else {
        window.expCookieConsentHandlers = window.expCookieConsentHandlers || {};
        window.expCookieConsentHandlers[NAME] = handler;
    }

    /* The banner reads its policy version on DOMContentLoaded; asking after it has done so compares the stored
       choice with the right version. Google's cookies are removed only on a withdrawal: they may belong to
       another site of the same parent domain. */
    function start() {
        started = true;
        if (window.ExpCookieConsent && window.ExpCookieConsent.has(NAME)) {
            load();
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', start);
    } else {
        start();
    }
}());
