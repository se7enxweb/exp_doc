{* The byline under a Modern page's title: who wrote the page and when, who updated it last and when, and its
   maintainers, each name linking the contributor's page (exp_doc_contributor; the facts are the page's attributes
   written_by, written_at, last_updated_by, last_updated_at and maintainers, not its body). Without a last update,
   the object's own modification date is shown. Then the page's labels (eZ Tags) as tags. *}
{def $doc_map = $node.data_map
     $doc_updated = cond( and( is_set( $doc_map.last_updated_at ), $doc_map.last_updated_at.has_content ), $doc_map.last_updated_at.content.timestamp, $node.object.modified )}
<div class="exp-doc-byline a4-meta">
{if and( is_set( $doc_map.written_by ), $doc_map.written_by.has_content )}
    <span>{'Written by %name'|i18n( 'design/exp_doc', '', hash( '%name', concat( '<a href=', $doc_map.written_by.content.main_node.url_alias|ezurl, '>', $doc_map.written_by.content.name|wash, '</a>' ) ) )}{if and( is_set( $doc_map.written_at ), $doc_map.written_at.has_content )}, <time datetime="{$doc_map.written_at.content.timestamp|datetime( 'custom', '%Y-%m-%d' )}">{$doc_map.written_at.content.timestamp|l10n( 'shortdate' )}</time>{/if}</span>
{/if}
    <span>{'Updated %date'|i18n( 'design/exp_doc', '', hash( '%date', concat( '<time datetime="', $doc_updated|datetime( 'custom', '%Y-%m-%d' ), '">', $doc_updated|l10n( 'shortdate' ), '</time>' ) ) )}{if and( is_set( $doc_map.last_updated_by ), $doc_map.last_updated_by.has_content )} {'by %name'|i18n( 'design/exp_doc', '', hash( '%name', concat( '<a href=', $doc_map.last_updated_by.content.main_node.url_alias|ezurl, '>', $doc_map.last_updated_by.content.name|wash, '</a>' ) ) )}{/if}</span>
{if and( is_set( $doc_map.maintainers ), $doc_map.maintainers.has_content )}
    <span>{'Maintainers:'|i18n( 'design/doc2025' )}
    {foreach $doc_map.maintainers.content.relation_list as $doc_rel}{def $doc_obj = fetch( 'content', 'object', hash( 'object_id', $doc_rel.contentobject_id ) )}{if $doc_obj}<a href={$doc_obj.main_node.url_alias|ezurl}>{$doc_obj.name|wash}</a>{/if}{undef $doc_obj}{delimiter}, {/delimiter}{/foreach}</span>
{/if}
</div>
{if and( is_set( $doc_map.labels ), $doc_map.labels.has_content )}
<ul class="a4-plain exp-doc-labels" aria-label="{'Labels'|i18n( 'design/exp_doc' )}">
{foreach $doc_map.labels.content.tags as $doc_tag}
    <li><a class="a4-tag" href={$doc_tag.url|ezurl}>{$doc_tag.keyword|wash}</a></li>
{/foreach}
</ul>
{/if}
{undef $doc_map $doc_updated}
