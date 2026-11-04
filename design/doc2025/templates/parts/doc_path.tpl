{* The path of a Classic page, as on the static site: "7x / documentation / faq / installation".
   The first item names the site's maker (exp_doc.ini [ClassicSettings] PathHomeName) and links the site's front;
   then every node of the path, in lower case, linked, except the current page, which is plain text. *}
<!-- Path area: START -->
<div id="path">

<div id="page-width4">
<h2 class="hide">Path</h2>

<!-- Path content: START -->
<p> <a href={'/'|ezurl}>{ezini( 'ClassicSettings', 'PathHomeName', 'exp_doc.ini' )|wash}</a>{foreach $path as $item}
                        /
    {if $item.url}
                        <a href={cond( is_set( $item.url_alias ), $item.url_alias, $item.url )|ezurl}>{$item.text|downcase|wash}</a>
    {else}
                            {$item.text|downcase|wash}
    {/if}
{/foreach}
            </p>
<!-- Path content: END -->

</div>

</div>
<!-- Path area: END -->
