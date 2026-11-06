{* The quick links of the Classic front and top-level pages, as on the static site. The groups and links are
   settings (exp_doc.ini [ClassicQuicklinks] Groups[] on the front page, PageGroups[] on every other page, as the
   static front page had the longer list; then [Quicklinks_<group>] Heading, HeadingSource and
   Links[]=<static file>;<label>). Each link points to the page imported from that static file (the fetch
   exp_doc/node_by_source), so links follow the pages wherever they move; a page the site has of its own (not imported)
   is named by its address instead, Links[]=path:<url alias>;<label>. A label may hold simple markup (<br />, &reg;),
   as on the static site. *}
<div class="attribute-heading">
    <h2 class="bullet">{'Quick links'|i18n( 'design/doc2025' )}</h2>
</div>

<div class="boxcontent">

<div id="quicklinks">
{def $doc_front = and( is_set( $module_result.node_id ), eq( $module_result.node_id, ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ) )}
{foreach ezini( 'ClassicQuicklinks', cond( $doc_front, 'Groups', 'PageGroups' ), 'exp_doc.ini' ) as $doc_group}
    {def $doc_section = concat( 'Quicklinks_', $doc_group )
         $doc_heading_node = cond( ezini_hasvariable( $doc_section, 'HeadingSource', 'exp_doc.ini' ),
                                   fetch( 'exp_doc', 'node_by_source', hash( 'path', ezini( $doc_section, 'HeadingSource', 'exp_doc.ini' ) ) ),
                                   false() )}
<h4>{if $doc_heading_node}<a href={$doc_heading_node.url_alias|ezurl}>{ezini( $doc_section, 'Heading', 'exp_doc.ini' )|wash}</a>{else}{ezini( $doc_section, 'Heading', 'exp_doc.ini' )|wash}{/if}</h4>
<ul>
    {foreach ezini( $doc_section, 'Links', 'exp_doc.ini' ) as $doc_link}
        {def $doc_parts = $doc_link|explode( ';' )
             $doc_href = '/'}
        {if $doc_parts[0]|begins_with( 'path:' )}
            {set $doc_href = $doc_parts[0]|extract( 5 )}
        {else}
            {def $doc_target = fetch( 'exp_doc', 'node_by_source', hash( 'path', $doc_parts[0] ) )}
            {if $doc_target}{set $doc_href = $doc_target.url_alias}{/if}
            {undef $doc_target}
        {/if}
<li><a href={$doc_href|ezurl}>{$doc_parts|extract_right( dec( $doc_parts|count ) )|implode( ';' )}</a></li>
        {undef $doc_parts $doc_href}
    {/foreach}
</ul>
    {undef $doc_section $doc_heading_node}
{/foreach}

</div>
</div>
{undef $doc_front}
