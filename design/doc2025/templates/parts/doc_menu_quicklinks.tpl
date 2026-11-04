{* The quick links of the Classic front and top-level pages, as on the static site. The groups and links are
   settings (exp_doc.ini [ClassicQuicklinks] Groups[], then [Quicklinks_<group>] Heading, HeadingSource and
   Links[]=<static file>;<label>). Each link points to the page imported from that static file (the fetch
   exp_doc/node_by_source), so links follow the pages wherever they move; a label may hold simple markup (<br />,
   &reg;), as on the static site. *}
<div class="attribute-heading">
    <h2 class="bullet">{'Quick links'|i18n( 'design/doc2025' )}</h2>
</div>

<div class="boxcontent">

<div id="quicklinks">
{foreach ezini( 'ClassicQuicklinks', 'Groups', 'exp_doc.ini' ) as $doc_group}
    {def $doc_section = concat( 'Quicklinks_', $doc_group )
         $doc_heading_node = cond( ezini_hasvariable( $doc_section, 'HeadingSource', 'exp_doc.ini' ),
                                   fetch( 'exp_doc', 'node_by_source', hash( 'path', ezini( $doc_section, 'HeadingSource', 'exp_doc.ini' ) ) ),
                                   false() )}
<h4>{if $doc_heading_node}<a href={$doc_heading_node.url_alias|ezurl}>{ezini( $doc_section, 'Heading', 'exp_doc.ini' )|wash}</a>{else}{ezini( $doc_section, 'Heading', 'exp_doc.ini' )|wash}{/if}</h4>
<ul>
    {foreach ezini( $doc_section, 'Links', 'exp_doc.ini' ) as $doc_link}
        {def $doc_parts = $doc_link|explode( ';' )
             $doc_target = fetch( 'exp_doc', 'node_by_source', hash( 'path', $doc_parts[0] ) )}
<li><a href={cond( $doc_target, $doc_target.url_alias, '/' )|ezurl}>{$doc_parts|extract_right( dec( $doc_parts|count ) )|implode( ';' )}</a></li>
        {undef $doc_parts $doc_target}
    {/foreach}
</ul>
    {undef $doc_section $doc_heading_node}
{/foreach}

</div>
</div>
