{* The body of a help topic (help_concept, help_task, help_reference, help_troubleshooting) in both designs, inside the
   page's own frame (parts/doc_full.tpl): the topic's fields as the help renders them (fetch exphelp/site_topic, the
   kernel's Markdown renderer, safe HTML, not washed), as the help center shows the same topic at exphelp/topic/<id>;
   the short description as the lead, the preview note for who may edit a topic that is not Released, its figures and
   its related topics. Nothing when the reader may not see the topic: the fields are Markdown and never shown raw.
   Styles: exphelp.css (.a4-help-*): Modern loads it on every page, Classic on these (pagelayout.tpl).

   Variables: node, help (the fetch's result, or false). *}
{if $help}
{if $help.shortdesc|ne( '' )}<p class="exp-doc-help-shortdesc"><strong>{$help.shortdesc|wash}</strong></p>{/if}
{if $help.preview}<p class="exp-doc-help-preview" role="note"><span class="a4-tag is-warn">{'Preview'|i18n( 'kernel/exphelp' )}</span> {'This topic is not Released; readers do not see it.'|i18n( 'kernel/exphelp' )}</p>{/if}
{$help.html}
{foreach $help.figures as $doc_help_f}
<figure class="a4-help-figure exp-doc-help-figure">
    <img class="a4-help-img" src={$doc_help_f.image_url|ezroot} alt="{$doc_help_f.alt_text|wash}" loading="lazy" decoding="async" />
    {if $doc_help_f.caption|ne( '' )}<figcaption>{$doc_help_f.caption|wash}</figcaption>{/if}
</figure>
{/foreach}
{if $help.related|count}
<div class="a4-page a4-help-frame exp-doc-help-related">
    <section aria-labelledby="exp-doc-help-related-{$node.node_id}">
        <h2 id="exp-doc-help-related-{$node.node_id}">{'Related topics'|i18n( 'kernel/exphelp' )}</h2>
        <ul class="a4-help-featured">
        {foreach $help.related as $doc_help_r}
            <li class="a4-help-feature"><a href="{$doc_help_r.url|wash}"><span class="a4-help-feature-text"><span class="a4-help-feature-title">{$doc_help_r.title|wash}</span>{if $doc_help_r.shortdesc|ne( '' )}<span class="a4-help-feature-summary">{$doc_help_r.shortdesc|shorten( 140 )|wash}</span>{/if}</span></a></li>
        {/foreach}
        </ul>
    </section>
</div>
{/if}
{/if}
