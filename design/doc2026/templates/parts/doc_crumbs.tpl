{* The breadcrumbs of a Modern page: the help center's .a4-crumbs, the current page last and unlinked. *}
<nav class="exp-doc-crumbs-nav" aria-label="{'You are here'|i18n( 'design/exp_doc' )}">
    <ol class="a4-crumbs">
{foreach $path as $item}
        <li>{if $item.url}<a href={cond( is_set( $item.url_alias ), $item.url_alias, $item.url )|ezurl}>{$item.text|wash}</a>{else}<span aria-current="page">{$item.text|wash}</span>{/if}</li>
{/foreach}
    </ol>
</nav>
