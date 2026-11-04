{* The head of a Modern page: the title (the page, then the site), the description and Open Graph tags from the
   page's metadata attribute (the Meta category), the canonical address, and the icons. *}
{def $doc_site = ezini( 'ModernSettings', 'SiteName', 'exp_doc.ini' )
     $doc_title = cond( $is_front, $doc_site, concat( $path|reverse|extract_left( 1 )[0].text, ' – ', $doc_site ) )
     $doc_meta = cond( and( $node, is_set( $node.data_map.metadata ) ), $node.data_map.metadata.content, false() )
     $doc_description = cond( and( $doc_meta, is_set( $doc_meta.description ), $doc_meta.description ), $doc_meta.description,
                              ezini( 'ModernSettings', 'SiteDescription', 'exp_doc.ini' ) )}
    <title>{$doc_title|wash}</title>
    <meta name="description" content="{$doc_description|wash}">
    <meta property="og:title" content="{$doc_title|wash}">
    <meta property="og:description" content="{$doc_description|wash}">
    <meta property="og:type" content="{cond( $is_front, 'website', 'article' )}">
    <meta property="og:site_name" content="{$doc_site|wash}">
    <meta property="og:image" content={'images/og-banner.png'|ezdesign( 'double', 'full' )}>
{if $node}
    <link rel="canonical" href={$node.url_alias|ezurl( 'double', 'full' )}>
{/if}
    <link rel="icon" href={'images/favicon.svg'|ezdesign} type="image/svg+xml">
    <link rel="search" href={'/content/search'|ezurl} title="{'Search the documentation'|i18n( 'design/exp_doc' )}">
    <meta name="generator" content="Exponential">
{undef $doc_site $doc_title $doc_meta $doc_description}
