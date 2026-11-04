{* The head of a Modern page: the title (the page, then the site), the description from the page's metadata
   attribute (the Meta category), the canonical address, and the brand part shared with Classic
   (design:exp_doc/head_brand.tpl: the icons, the theme colors, Open Graph and Twitter with the manual's image). *}
{def $doc_site = ezini( 'ModernSettings', 'SiteName', 'exp_doc.ini' )
     $doc_title = cond( $is_front, $doc_site, concat( $path|reverse|extract_left( 1 )[0].text, ' – ', $doc_site ) )
     $doc_meta = cond( and( $node, is_set( $node.data_map.metadata ) ), $node.data_map.metadata.content, false() )
     $doc_description = cond( and( $doc_meta, is_set( $doc_meta.description ), $doc_meta.description ), $doc_meta.description,
                              ezini( 'ModernSettings', 'SiteDescription', 'exp_doc.ini' ) )
     $doc_manual = false()}
{if $node}{foreach $node.path as $doc_up}{if eq( $doc_up.class_identifier, 'exp_doc_manual' )}{set $doc_manual = $doc_up}{/if}{/foreach}{/if}
    <title>{$doc_title|wash}</title>
    <meta name="description" content="{$doc_description|wash}">
{if $node}
    <link rel="canonical" href={$node.url_alias|ezurl( 'double', 'full' )}>
{/if}
    <meta property="og:type" content="{cond( $is_front, 'website', 'article' )}">
{include uri='design:exp_doc/head_brand.tpl' title=$doc_title description=$doc_description manual=$doc_manual
         url=cond( $node, $node.url_alias|ezurl( 'no', 'full' ), '/'|ezurl( 'no', 'full' ) )}
    <link rel="search" href={'/content/search'|ezurl} title="{'Search the documentation'|i18n( 'design/exp_doc' )}">
{include uri='design:exp_doc/head_feed.tpl'}
    <meta name="generator" content="Exponential">
{undef $doc_site $doc_title $doc_meta $doc_description $doc_manual}
