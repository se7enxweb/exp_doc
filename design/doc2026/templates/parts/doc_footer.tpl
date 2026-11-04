{* The footer of a Modern page: the license of the content (the imported License page), the 7x support offer, the
   community links with the Contributors page, the cookie settings, and the version badge "Runs on Exponential 6.0.15". *}
{def $doc_license = fetch( 'exp_doc', 'node_by_source', hash( 'path', 'License.html' ) )
     $doc_people = fetch( 'content', 'object', hash( 'remote_id', ezini( 'RecentSettings', 'ContributorFolderRemoteID', 'exp_doc.ini' ) ) )}
<footer class="exp-doc-footer">
    <div class="exp-doc-footer-inner">
        <div class="exp-doc-footer-col">
            <p class="exp-doc-footer-brand"><a class="exp-doc-footer-logo" href={'/'|ezurl}>{include uri='design:exp_doc/logo.tpl'}</a> <span>{'Documentation'|i18n( 'design/exp_doc' )}</span></p>
            <p>{'Copyright © 1998 - %year %maker (except where otherwise noted).'|i18n( 'design/exp_doc', '', hash( '%year', currentdate()|datetime( 'custom', '%Y' ), '%maker', '<a href="https://se7enx.com">7x</a>' ) )}</p>
            <p>{'Content license: %license'|i18n( 'design/exp_doc', '', hash( '%license', concat( '<a href=', cond( $doc_license, $doc_license.url_alias, '/' )|ezurl, '>', 'GNU Free Documentation License v1.2+'|i18n( 'design/doc2025' ), '</a>' ) ) )}</p>
        </div>
        <div class="exp-doc-footer-col">
            <p>{'Get the support you need faster! Ask the experts at 7x.'|i18n( 'design/doc2025' )}</p>
            <p><a class="a4-btn is-primary" href="https://se7enx.com/contact">{'Contact 7x'|i18n( 'design/exp_doc' )}</a></p>
        </div>
        <div class="exp-doc-footer-col">
            <ul class="a4-plain exp-doc-footer-links">
                <li><a href="https://exponential.earth">exponential.earth</a></li>
                <li><a href="https://share.exponential.earth">{'Community'|i18n( 'design/doc2025' )}</a></li>
                <li><a href="https://github.com/se7enxweb/exponential">GitHub</a></li>
                {if $doc_people}<li><a href={$doc_people.main_node.url_alias|ezurl}>{'Contributors'|i18n( 'design/exp_doc' )}</a></li>{/if}
                <li><a href={'exphelp/viewer/ext/exp_doc/headless-access.md'|ezurl}>{'REST and GraphQL'|i18n( 'design/exp_doc' )}</a></li>
                <li><a href="#cookie-settings">{'Cookie settings'|i18n( 'design/media/pagelayout' )}</a></li>
            </ul>
        </div>
    </div>
    <p class="exp-doc-runs-on">{'Runs on Exponential %version'|i18n( 'design/doc2025', '', hash( '%version', concat( fetch( 'setup', 'major_version' ), '.', fetch( 'setup', 'minor_version' ), '.', fetch( 'setup', 'release' ) )|wash ) )}</p>
</footer>
{undef $doc_license $doc_people}
