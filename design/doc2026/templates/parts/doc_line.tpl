{* A documentation page as a card in the Modern design (child lists, search results, the landing):
   the name, and a short summary (the metadata description, else the first words of the body). *}
{def $doc_map = $node.data_map
     $doc_summary = ''}
{if and( is_set( $doc_map.metadata ), is_set( $doc_map.metadata.content.description ) )}{set $doc_summary = $doc_map.metadata.content.description}{/if}
{if and( eq( $doc_summary, '' ), is_set( $doc_map.body ) )}{set $doc_summary = $doc_map.body.content.output.output_text|striptags|shorten( 160 )}{/if}
<a class="a4-card exp-doc-card" href={$node.url_alias|ezurl}>
    <span class="exp-doc-card-name">{$node.name|wash}</span>
    {if $doc_summary}<span class="exp-doc-card-text">{$doc_summary|wash}</span>{/if}
</a>
{undef $doc_map $doc_summary}
