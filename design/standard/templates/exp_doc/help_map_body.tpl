{* The body of a help manual (help_manual) or chapter (help_section) in both designs, inside the page's own frame
   (parts/doc_full.tpl): its subtitle, short description and edition, and its contents two levels deep in the manual's
   order, each entry a link to the page of the topic or chapter (fetch exphelp/site_map: only what the reader may see).
   Nothing when the reader may not see the manual.

   Variables: node, help (the fetch's result, or false). *}
{if $help}
{if $help.subtitle|ne( '' )}<p class="exp-doc-help-subtitle"><em>{$help.subtitle|wash}</em></p>{/if}
{if $help.shortdesc|ne( '' )}<p class="exp-doc-help-shortdesc"><strong>{$help.shortdesc|wash}</strong></p>{/if}
{if $help.edition|ne( '' )}<p class="exp-doc-help-edition">{'Edition %edition'|i18n( 'kernel/exphelp',, hash( '%edition', $help.edition ) )|wash}</p>{/if}
{if $help.preview}<p class="exp-doc-help-preview" role="note"><span class="a4-tag is-warn">{'Preview'|i18n( 'kernel/exphelp' )}</span> {'This topic is not Released; readers do not see it.'|i18n( 'kernel/exphelp' )}</p>{/if}
{if $help.toc|count}
<nav class="exp-doc-help-toc" aria-labelledby="exp-doc-help-toc-{$node.node_id}">
    <h2 id="exp-doc-help-toc-{$node.node_id}">{'Contents'|i18n( 'kernel/exphelp' )}</h2>
    <ol>
    {foreach $help.toc as $doc_help_e}
        <li><a href="{$doc_help_e.url|wash}">{$doc_help_e.title|wash}</a>{if $doc_help_e.shortdesc|ne( '' )}: {$doc_help_e.shortdesc|wash}{/if}
        {if $doc_help_e.children|count}
            <ol>
            {foreach $doc_help_e.children as $doc_help_c}
                <li><a href="{$doc_help_c.url|wash}">{$doc_help_c.title|wash}</a>{if $doc_help_c.shortdesc|ne( '' )}: {$doc_help_c.shortdesc|wash}{/if}</li>
            {/foreach}
            </ol>
        {/if}
        </li>
    {/foreach}
    </ol>
</nav>
{/if}
{/if}
