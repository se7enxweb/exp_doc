{* The head of a Classic page: the title and meta tags of the static site.
   The front page has its own title, description and Open Graph tags (exp_doc.ini [ClassicSettings]); every other page
   is titled with its path from the page up to the root, joined with " / ", followed by " - Doc", as the static
   site was ("Installation / FAQ / Documentation - Doc"). *}
{if $is_front}
    <title>{ezini( 'ClassicSettings', 'FrontTitle', 'exp_doc.ini' )|wash}</title>

    <meta property="og:title" content="{ezini( 'ClassicSettings', 'FrontTitle', 'exp_doc.ini' )|wash}"/>
    <meta name="twitter:title" content="{ezini( 'ClassicSettings', 'FrontTitle', 'exp_doc.ini' )|wash}"/>
    <meta name="description" content="{ezini( 'ClassicSettings', 'FrontDescription', 'exp_doc.ini' )|wash}" />
    <meta property="og:description" content="{ezini( 'ClassicSettings', 'FrontDescription', 'exp_doc.ini' )|wash}"/>
    <meta name="twitter:description" content="{ezini( 'ClassicSettings', 'FrontDescription', 'exp_doc.ini' )|wash}"/>
    <meta property="og:type" content="website" />
    <meta property="og:url" content={'/'|ezurl( 'double', 'full' )} />
    <meta property="og:image" content={'images/favicon-banner.png'|ezdesign( 'double', 'full' )} />
    <meta property="og:site_name" content="{ezini( 'ClassicSettings', 'SiteName', 'exp_doc.ini' )|wash}" />
    <meta property="twitter:image" content={'images/favicon-banner.png'|ezdesign( 'double', 'full' )} />
{else}
    {def $doc_title_parts = array()}
    {foreach $path|reverse as $item}
        {set $doc_title_parts = $doc_title_parts|append( $item.text )}
    {/foreach}
    <title>{$doc_title_parts|implode( ' / ' )|wash} - {ezini( 'ClassicSettings', 'TitleSuffix', 'exp_doc.ini' )|wash}</title>
    {undef $doc_title_parts}
{/if}

    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="Content-language" content="{$site.http_equiv.Content-language|wash}" />
{foreach ezini( 'ClassicSettings', 'MetaTags', 'exp_doc.ini' ) as $meta_name => $meta_content}
    <meta name="{$meta_name|wash}" content="{$meta_content|wash}" />
{/foreach}
    <meta name="generator" content="Exponential" />
    <link rel="Home" href={'/'|ezurl} title="Doc front page" />
    <link rel="Search" href={'/content/advancedsearch'|ezurl} title="Search Doc" />
    <link rel="Shortcut icon" href={'images/favicon.ico'|ezdesign} type="image/x-icon" />
