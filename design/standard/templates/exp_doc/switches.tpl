{* The header switches of the documentation site, in both designs (the owner: "the header should allow one click
   design switch to doc design from classic"):
   - Classic / Modern: links to the same page with the view parameter (design)/<name>; the kernel's design switch
     (site.ini [DesignSettings] SwitchableDesigns[]) shows that design and keeps it in a cookie;
   - the content languages: the same page in each translation (language_switcher), the current one marked.
   Plain links, no script: each choice is one click, and works without JavaScript. *}
{def $doc_designs = ezini( 'DesignSwitchSettings', 'Designs', 'exp_doc.ini' )
     $doc_here = cond( and( is_set( $module_result.node_id ), $module_result.node_id ),
                       fetch( 'content', 'node', hash( 'node_id', $module_result.node_id ) ).url_alias,
                       $site.uri.original_uri )
     $doc_languages = language_switcher( $doc_here )}
<div id="exp-doc-switches" class="exp-doc-switches">
    <nav class="exp-doc-switch exp-doc-switch-design" aria-label="{'Design'|i18n( 'design/exp_doc' )}">
        <ul>
{foreach $doc_designs as $doc_design_name => $doc_design_label}
            <li><a href={concat( $doc_here, '/(design)/', $doc_design_name )|ezurl}{if eq( $doc_design_name, ezini( 'DesignSettings', 'SiteDesign', 'site.ini' ) )} aria-current="true" class="current"{/if}>{$doc_design_label|i18n( 'design/exp_doc' )|wash}</a></li>
{/foreach}
        </ul>
    </nav>
{if $doc_languages|count|gt( 1 )}
    <nav class="exp-doc-switch exp-doc-switch-language" aria-label="{'Language'|i18n( 'design/exp_doc' )}">
        <ul>
    {foreach $doc_languages as $doc_siteaccess => $doc_language}
            <li><a href={$doc_language.url|ezurl}{if eq( $doc_siteaccess, $access_type.name )} aria-current="true" class="current"{/if}>{$doc_language.text|wash}</a></li>
    {/foreach}
        </ul>
    </nav>
{/if}
</div>
{undef $doc_designs $doc_here $doc_languages}
