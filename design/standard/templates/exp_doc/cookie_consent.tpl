{* The cookie banner of the documentation site, in both designs (the owner chose a consent banner). It is the
   media design's component (javascript/exp-cookie-consent.js and stylesheets/exp-cookie-consent.css, copied into
   exp_doc's design/standard), with the one category this site has: strictly necessary cookies, which include the
   design choice (Classic / Modern) and the language. The policy page is [SiteInfo] CookiePolicyID of menu.ini, as
   on the media sites; [SiteInfo] CookieConsentVersion asks every visitor again when raised. *}
{def $cc_node = cond( ezini_hasvariable( 'SiteInfo', 'CookiePolicyID', 'menu.ini' ),
                      fetch( 'content', 'node', hash( 'node_id', ezini( 'SiteInfo', 'CookiePolicyID', 'menu.ini' ) ) ),
                      false() )
     $cc_policy_link = cond( is_object( $cc_node ),
                             concat( '<a href="', $cc_node|site_url|wash, '">', 'Cookie Policy'|i18n( 'design/media/pagelayout' ), '</a>' ),
                             'Cookie Policy'|i18n( 'design/media/pagelayout' ) )
     $cc_version = cond( ezini_hasvariable( 'SiteInfo', 'CookieConsentVersion', 'menu.ini' ),
                         ezini( 'SiteInfo', 'CookieConsentVersion', 'menu.ini' ), '1' )}
{ezcss_load( array( 'exp-cookie-consent.css' ) )}
<script type="application/json" id="exp-cc-config">{json_encode( hash( 'version', $cc_version ) )}</script>
<section id="exp-cc" class="exp-cc" role="dialog" aria-modal="false" tabindex="-1"
         aria-labelledby="exp-cc-title" aria-describedby="exp-cc-text" hidden>
    <div class="exp-cc-inner">
        <div class="exp-cc-head">
            <h2 id="exp-cc-title" class="exp-cc-title">{'Cookies on this website'|i18n( 'design/media/cookieconsent' )}</h2>
            <button type="button" class="exp-cc-close" data-exp-cc-action="close"
                    aria-label="{'Close without changes'|i18n( 'design/media/cookieconsent' )}">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
        <div class="exp-cc-body">
            <p id="exp-cc-text" class="exp-cc-text">{'This documentation stores only what it needs to work: a session cookie when you sign in, the design you chose (Classic or Modern) and your language. Your choice is kept in a cookie for 6 months. Details are in our %cookie_link.'|i18n( 'design/exp_doc', '', hash( '%cookie_link', $cc_policy_link ) )}</p>
            <div class="exp-cc-actions">
                <button type="button" class="btn btn-primary exp-cc-btn" data-exp-cc-action="reject">{'Reject all'|i18n( 'design/media/cookieconsent' )}</button>
                <button type="button" class="btn btn-primary exp-cc-btn" data-exp-cc-action="accept">{'Accept all'|i18n( 'design/media/cookieconsent' )}</button>
                <button type="button" class="btn btn-outline-primary exp-cc-btn exp-cc-btn-settings" data-exp-cc-action="settings"
                        aria-expanded="false" aria-controls="exp-cc-panel">{'Settings'|i18n( 'design/media/cookieconsent' )}</button>
            </div>
        </div>
        <div id="exp-cc-panel" class="exp-cc-panel" hidden>
            <ul class="exp-cc-categories">
                <li class="exp-cc-category">
                    <div class="exp-cc-category-head">
                        <input type="checkbox" id="exp-cc-cat-necessary" checked disabled aria-describedby="exp-cc-cat-necessary-text">
                        <label for="exp-cc-cat-necessary">{'Strictly necessary'|i18n( 'design/media/cookieconsent' )}</label>
                        <span class="exp-cc-always">{'Always on'|i18n( 'design/media/cookieconsent' )}</span>
                    </div>
                    <p id="exp-cc-cat-necessary-text">{'The session cookie for signing in and for forms, the cookies that keep your design and language, and the cookie that keeps this choice. They stay on because the website needs them; you can delete them in your browser settings at any time.'|i18n( 'design/exp_doc' )}</p>
                </li>
            </ul>
            <div class="exp-cc-panel-actions">
                <button type="button" class="btn btn-outline-primary exp-cc-btn" data-exp-cc-action="save" hidden>{'Save my choice'|i18n( 'design/media/cookieconsent' )}</button>
            </div>
        </div>
    </div>
</section>
{ezscript_load( array( 'exp-cookie-consent.js' ) )}
{undef $cc_node $cc_policy_link $cc_version}
