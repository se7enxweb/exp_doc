{* The caution box above every Classic page, as on the static site (exp_doc.ini [ClassicSettings] Disclaimer).
   Its two links point to imported pages, found by the static file they were imported from (the fetch
   exp_doc/node_by_source), so they follow the page wherever it is moved. The static site colored "Caution:" with
   an inline style; here a class does it (no inline styles). *}
{if ezini( 'ClassicSettings', 'Disclaimer', 'exp_doc.ini' )|eq( 'enabled' )}
{def $doc_platform = fetch( 'exp_doc', 'node_by_source', hash( 'path', 'display/MAIN/ExponentialPlatformDocumentationCenter.html' ) )
     $doc_architecture = fetch( 'exp_doc', 'node_by_source', hash( 'path', 'pages/viewpage0139.html' ) )}
                                    <div id="ezp5disclaimer">
                <p><strong class="exp-doc-caution">{'Caution:'|i18n( 'design/doc2025' )}</strong> {'This documentation is for <strong>Exponential</strong>, from version 3.x to 6.x.'|i18n( 'design/doc2025' )}<br/>
                {'For 5.x documentation covering <em>Platform</em> see %platform_link, for difference between <em>legacy</em> and <em>Platform</em> see %architecture_link.'|i18n( 'design/doc2025', '', hash(
                    '%platform_link', concat( '<a href=', cond( $doc_platform, $doc_platform.url_alias, '/' )|ezurl, '>', 'Exponential Platform Documentation'|i18n( 'design/doc2025' ), '</a>' ),
                    '%architecture_link', concat( '<a href=', cond( $doc_architecture, $doc_architecture.url_alias, '/' )|ezurl, '>', '5.x Architecture overview'|i18n( 'design/doc2025' ), '</a>' ) ) )}</p>
            </div>
{undef $doc_platform $doc_architecture}
{/if}
