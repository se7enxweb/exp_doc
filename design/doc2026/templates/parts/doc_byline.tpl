{* The facts under a Modern page's title: written by and last updated by (the imported author and modifier with
   their dates, kept as the owner decided), and the page's labels (eZ Tags) as badges. *}
{def $doc_map = $node.data_map}
<p class="exp-doc-byline a4-meta">
{if and( is_set( $doc_map.author ), $doc_map.author.has_content )}
    <span>{'Written by %name'|i18n( 'design/exp_doc', '', hash( '%name', $doc_map.author.content|wash ) )}{if is_set( $doc_map.source_created )}, <time datetime="{$doc_map.source_created.content.timestamp|datetime( 'custom', '%Y-%m-%d' )}">{$doc_map.source_created.content.timestamp|l10n( 'shortdate' )}</time>{/if}</span>
{/if}
    <span>{'Updated %date'|i18n( 'design/exp_doc', '', hash( '%date', concat( '<time datetime="', cond( is_set( $doc_map.source_modified ), $doc_map.source_modified.content.timestamp, $node.object.modified )|datetime( 'custom', '%Y-%m-%d' ), '">', cond( is_set( $doc_map.source_modified ), $doc_map.source_modified.content.timestamp, $node.object.modified )|l10n( 'shortdate' ), '</time>' ) ) )}{if and( is_set( $doc_map.modifier ), $doc_map.modifier.has_content )} {'by %name'|i18n( 'design/exp_doc', '', hash( '%name', $doc_map.modifier.content|wash ) )}{/if}</span>
</p>
{if and( is_set( $doc_map.labels ), $doc_map.labels.has_content )}
<ul class="a4-plain exp-doc-labels" aria-label="{'Labels'|i18n( 'design/exp_doc' )}">
{foreach $doc_map.labels.content.tags as $doc_tag}
    <li><a class="a4-tag" href={$doc_tag.url|ezurl}>{$doc_tag.keyword|wash}</a></li>
{/foreach}
</ul>
{/if}
{undef $doc_map}
