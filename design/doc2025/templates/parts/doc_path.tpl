{* The path of a Classic page, as on the static site: "7x / documentation / faq / installation".
   The first item names the site's maker (exp_doc.ini [ClassicSettings] PathHomeName) and links the site's front;
   then every node of the path, in lower case, linked, except the current page, which is plain text. The site's
   root ("documentation") links the page imported from [ClassicSettings] PathRootSource (the static
   documentation.html), as the static site's path did; the front page itself is the static index.html. A name longer
   than 31 characters is cut to 28 and "...", as the static path did ("building mobile browser and..."). *}
{def $doc_root_id = ezini( 'NodeSettings', 'RootNode', 'content.ini' )
     $doc_root_page = fetch( 'exp_doc', 'node_by_source', hash( 'path', ezini( 'ClassicSettings', 'PathRootSource', 'exp_doc.ini' ) ) )}
<!-- Path area: START -->
<div id="path">

<div id="page-width4">
<h2 class="hide">Path</h2>

<!-- Path content: START -->
<p> <a href={'/'|ezurl}>{ezini( 'ClassicSettings', 'PathHomeName', 'exp_doc.ini' )|wash}</a>{foreach $path as $item}
                        /
    {if and( not( $item.url ), is_set( $item.node_id ), eq( $item.node_id, $doc_root_id ) )}
        {* the front page: the static index.html sat below documentation, as "exponential" (the root itself is
           linked while documentation.html is not imported) *}
                        <a href={cond( $doc_root_page, $doc_root_page.url_alias, "/" )|ezurl}>{$item.text|downcase|wash}</a>
        
                        /
                            {ezini( 'ClassicSettings', 'FrontHeading', 'exp_doc.ini' )|downcase|wash}
    {elseif $item.url}
        {if and( is_set( $item.node_id ), eq( $item.node_id, $doc_root_id ), $doc_root_page )}
                        <a href={$doc_root_page.url_alias|ezurl}>{$item.text|downcase|wash}</a>
        {else}
                        <a href={cond( is_set( $item.url_alias ), $item.url_alias, $item.url )|ezurl}>{$item.text|downcase|shorten( 31 )|wash}</a>
        {/if}
    {else}
                            {$item.text|downcase|shorten( 31 )|wash}
    {/if}
{/foreach}
            </p>
<!-- Path content: END -->

</div>

</div>
<!-- Path area: END -->
{undef $doc_root_id $doc_root_page}
