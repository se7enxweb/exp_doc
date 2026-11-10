{* The header switches of the documentation site, in both designs (the owner: "the header should allow one click
   design switch to doc design from classic"):
   - Classic / Modern: the kernel's design switch (fetch uiswitch/front_designs, site.ini [DesignSettings]
     SwitchableDesigns[]): a link to the same page with the view parameter (design)/<name>, which shows that design
     and keeps it in a cookie; nothing is drawn where the switch is off;
   - the content languages: the same page in each translation (language_switcher), the current one marked;
   - and a link to the help center (exphelp/dashboard), which runs on this site for every reader.
   Plain links, no script: each choice is one click, and works without JavaScript. *}
{def $doc_switch = fetch( 'uiswitch', 'front_designs' )
     $doc_here = cond( and( is_set( $module_result.node_id ), $module_result.node_id ),
                       fetch( 'content', 'node', hash( 'node_id', $module_result.node_id ) ).url_alias,
                       $site.uri.original_uri )
     $doc_here_parts = array()
     $doc_skip = false()}
{* a page that is not a node keeps its own address, which may carry (design)/<name> already: drop that pair, or each
   switch would add one more (crawlers followed them into /(design)/doc/(design)/doc2025/... without end) *}
{foreach $doc_here|explode( '/' ) as $doc_part}
    {if $doc_skip}{set $doc_skip = false()}
    {elseif eq( $doc_part, concat( '(', $doc_switch.parameter, ')' ) )}{set $doc_skip = true()}
    {else}{set $doc_here_parts = $doc_here_parts|append( $doc_part )}{/if}
{/foreach}
{set $doc_here = $doc_here_parts|implode( '/' )}
{def $doc_languages = language_switcher( $doc_here )}
<div id="exp-doc-switches" class="exp-doc-switches">
    {* a reader who chose the help's language (/(lang)/<key>) keeps it *}
    <a class="exp-doc-helplink" href={concat( 'exphelp/dashboard', cond( fetch( 'exphelp', 'reading_key' ), concat( '/(lang)/', fetch( 'exphelp', 'reading_key' ) ), '' ) )|ezurl}>{'Help center'|i18n( 'design/exp_doc' )}</a>
{if $doc_switch.designs|count}
    <nav class="exp-doc-switch exp-doc-switch-design" aria-label="{'Design'|i18n( 'design/exp_doc' )}">
        <ul>
{foreach $doc_switch.designs as $doc_design}
            <li><a rel="nofollow" href={concat( $doc_here, '/(', $doc_switch.parameter, ')/', $doc_design.name )|ezurl}{if $doc_design.current} aria-current="true" class="current"{/if}>{$doc_design.label|i18n( 'design/exp_doc' )|wash}</a></li>
{/foreach}
        </ul>
    </nav>
{/if}
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
{undef $doc_switch $doc_here $doc_here_parts $doc_skip $doc_languages}
