{* The footer of a Classic page, as on the static site: the logo with the 7x call to action, then the copyright,
   license and social links. The license link points to the imported License page (found by its static file).
   One addition, the version badge (doc.md: "Runs on Exponential 6.0.15"), closes the copyright block. *}
{def $doc_license = fetch( 'exp_doc', 'node_by_source', hash( 'path', 'License.html' ) )}
        <div id="footer-bg">
        <div id="footer" class="container_12">

            <div class="grid_3">
                <img src={'images/exponential.png'|ezdesign} alt="exponential" />
                <div id="footer-copyright" class="grid_3 alpha omega">
                                    </div>
            </div>

            <div class="grid_6 middle">
                <div class="grid_6 alpha omega">
                    <div class="grid_3 alpha"><div></div></div>
                    <div class="grid_3 omega"><div></div></div>
                </div>
            </div>

            <div class="grid_3 right">
                <div class="contact-ez">
                        {'Get the support you need faster! Ask the experts at 7x.'|i18n( 'design/doc2025' )} <a id="cta-contact" href="https://se7enx.com/contact" title="{'Contact 7x!'|i18n( 'design/doc2025' )}" class="btn-green btn--small">{'Call or Contact 7x Today!'|i18n( 'design/doc2025' )}</a>
                </div>

                <div class="adress"></div>
            </div>

        </div>
    </div>
<div id="footer-connect-bg">
    <div id="footer" class="container_12">
        <div id="footer-connect-copyright" class="grid_8 alpha omega">
            {'Copyright © 1998 - %year %maker (except where otherwise noted). All rights reserved.'|i18n( 'design/doc2025', '', hash( '%year', currentdate()|datetime( 'custom', '%Y' ), '%maker', '<a href="https://se7enx.com">7x</a>' ) )}
            <br/>
            {'License for this Website Content:'|i18n( 'design/doc2025' )} <a href={cond( $doc_license, $doc_license.url_alias, '/' )|ezurl}>{'GNU Free Documentation License v1.2+'|i18n( 'design/doc2025' )}</a>
            <br/><br/>
            {'Powered by %cms and the groundbreaking %exponential %community.'|i18n( 'design/doc2025', '', hash(
                '%cms', concat( '<a href="https://se7enx.com/exponential" title="Exponential CMS">', 'The Exponential CMS'|i18n( 'design/doc2025' ), '</a>' ),
                '%exponential', '<a href="https://exponential.earth">Exponential</a>',
                '%community', concat( '<a href="https://share.exponential.earth">', 'Community'|i18n( 'design/doc2025' ), '</a>' ) ) )}<br />
            <span class="exp-doc-runs-on">{'Runs on Exponential %version'|i18n( 'design/doc2025', '', hash( '%version', concat( fetch( 'setup', 'major_version' ), '.', fetch( 'setup', 'minor_version' ), '.', fetch( 'setup', 'release' ) )|wash ) )}</span>
        </div>

        <div id="footer-connect-social" class="grid_4 right"> <b>{'Find Exponential on Your Favorite Social Network:'|i18n( 'design/doc2025' )}</b>&nbsp;
{foreach ezini( 'ClassicSettings', 'SocialLinks', 'exp_doc.ini' ) as $social_name => $social_url}
            <a href="{$social_url|wash}" class="{$social_name|wash}" target="_blank" rel="noopener">{$social_name|wash}</a>{delimiter},{/delimiter}
{/foreach}
        </div>

    </div>
</div>
{undef $doc_license}
