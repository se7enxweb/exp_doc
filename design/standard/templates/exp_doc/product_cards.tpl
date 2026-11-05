{* exp_doc/product_cards: the cards of a product's landing page, its sections or its related sections (fetch
   exp_doc/product_landing, .sections and .related): the help center's faded boxes (.a4-help-about and .a4-help-grow in
   turn, with their tile), each with its name linked, the Supported badge of a product, the product's short text or a
   manual's summary, and a manual's versions or the number of pages below it. Styles: exphelp.css and the design's
   .exp-doc-manual* rules.

   Variables: sections, list_class (the list's grid: exp-doc-manuals in Modern, a4-grid in Classic), badge_class (the
   Supported badge's classes), version_tags (optional, true: the versions as Modern's parts/doc_version_tag.tpl; else
   plain .a4-tag links). *}
<ul class="a4-plain {$list_class|wash}">
{foreach $sections as $doc_index => $doc_section}
    <li class="{cond( $doc_index|mod( 2 ), 'a4-help-grow', 'a4-help-about' )} exp-doc-manual{if $doc_section.supported} is-supported{/if}">
        <span class="a4-help-tile" aria-hidden="true"><span class="a4-icon a4-bi-{$doc_section.icon|wash}"></span></span>
        <div class="exp-doc-manual-body">
            <h3 class="exp-doc-manual-name"><a href={$doc_section.node.url_alias|ezurl}>{$doc_section.name|wash}</a>{if $doc_section.supported} <span class="{$badge_class|wash}">{'Supported'|i18n( 'design/exp_doc' )}</span>{/if}</h3>
        {if $doc_section.text}
            <p class="exp-doc-manual-summary">{$doc_section.text|wash}</p>
        {elseif and( $doc_section.manual, is_set( $doc_section.node.data_map.summary ) )}
            {if $doc_section.node.data_map.summary.has_content}<div class="exp-doc-manual-summary">{attribute_view_gui attribute=$doc_section.node.data_map.summary}</div>{/if}
        {/if}
        {if $doc_section.versions|count}
            <ul class="a4-plain exp-doc-manual-versions" aria-label="{'Versions'|i18n( 'design/exp_doc' )}">
            {foreach $doc_section.versions as $doc_version}
                <li>{if and( is_set( $version_tags ), $version_tags )}{include uri='design:parts/doc_version_tag.tpl' version=$doc_version.node label=$doc_version.label}{else}<a class="a4-tag" href={$doc_version.node.url_alias|ezurl}>{$doc_version.label|wash}</a>{/if}</li>
            {/foreach}
            </ul>
        {elseif $doc_section.count|gt( 0 )}
            <p class="a4-meta">{'%count pages'|i18n( 'design/exp_doc', '', hash( '%count', $doc_section.count ) )}</p>
        {/if}
        </div>
    </li>
{/foreach}
</ul>
