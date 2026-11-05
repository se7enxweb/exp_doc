{* A documentation page as a card in the Modern design (child lists, search results, the landing): the name, its rating
   as small stars once it has one, and a short summary (the metadata description, else the first words of the body). *}
{def $doc_map = $node.data_map
     $doc_summary = ''}
{if and( is_set( $doc_map.metadata ), is_set( $doc_map.metadata.content.description ) )}{set $doc_summary = $doc_map.metadata.content.description}{/if}
{* a help topic or manual: its short description (its body is Markdown, see full/exp_doc_help_topic.tpl) *}
{if and( eq( $doc_summary, '' ), is_set( $doc_map.shortdesc ) )}{set $doc_summary = $doc_map.shortdesc.content}{/if}
{if and( eq( $doc_summary, '' ), is_set( $doc_map.body ), is_set( $doc_map.shortdesc )|not )}{set $doc_summary = $doc_map.body.content.output.output_text|striptags|shorten( 160 )}{/if}
<a class="a4-card exp-doc-card" href={$node.url_alias|ezurl}>
    <span class="exp-doc-card-name">{$node.name|wash}</span>
    {if and( is_set( $doc_map.rating ), $doc_map.rating.content.rating_count )}<span class="exp-doc-card-rating">{include uri='design:exp_doc/rating_stars.tpl' rating=$doc_map.rating.content}</span>{/if}
    {if $doc_summary}<span class="exp-doc-card-text">{$doc_summary|wash}</span>{/if}
</a>
{undef $doc_map $doc_summary}
