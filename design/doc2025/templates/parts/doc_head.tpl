{* The head of a Classic page: the title and meta tags of the static site.
   The front page has its own title and description (exp_doc.ini [ClassicSettings]); every other page
   is titled with its path from the page up to the root, joined with " / ", followed by " - Doc", as the static
   site was ("Installation / FAQ / Documentation - Doc"). The icons, Open Graph and Twitter tags are the brand images
   of the official logo (design:exp_doc/head_brand.tpl), a decided exception, outside the page area the check compares. *}
{if $is_front}
    <title>{ezini( 'ClassicSettings', 'FrontTitle', 'exp_doc.ini' )|wash}</title>
    <meta name="description" content="{ezini( 'ClassicSettings', 'FrontDescription', 'exp_doc.ini' )|wash}" />
    <meta property="og:type" content="website" />
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
{include uri='design:exp_doc/head_feed.tpl' only_own=true()}
{* the icons, theme colors, Open Graph and Twitter tags: the official logo's brand images (a decided exception) *}
{def $doc_manual = false()
     $doc_page = cond( and( is_set( $module_result.node_id ), $module_result.node_id ), fetch( 'content', 'node', hash( 'node_id', $module_result.node_id ) ), false() )}
{if $doc_page}{foreach $doc_page.path as $doc_up}{if eq( $doc_up.class_identifier, 'exp_doc_manual' )}{set $doc_manual = $doc_up}{/if}{/foreach}{/if}
{include uri='design:exp_doc/head_brand.tpl' manual=$doc_manual
         title=cond( $is_front, ezini( 'ClassicSettings', 'FrontTitle', 'exp_doc.ini' ), $path|reverse|extract_left( 1 )[0].text )
         description=ezini( 'ClassicSettings', 'FrontDescription', 'exp_doc.ini' )
         url=cond( $doc_page, $doc_page.url_alias|ezurl( 'no', 'full' ), '/'|ezurl( 'no', 'full' ) )}
{undef $doc_manual $doc_page}
