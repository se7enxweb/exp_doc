{* A contributor's page in the Modern design: the name (and the contributor's own text, if any), then every page
   that names this person as writer, last updater or maintainer (the pages' relation attributes, read in reverse),
   newest first, as cards. *}
{def $doc_pages = fetch( 'content', 'reverse_related_objects', hash( 'object_id', $node.contentobject_id,
                                                                    'all_relations', true(),
                                                                    'sort_by', array( 'modified', false() ) ) )}
<article class="exp-doc-article exp-doc-contributor">
    <header class="exp-doc-article-head">
        <p class="a4-meta">{'Contributor'|i18n( 'design/exp_doc' )}</p>
        <h1 class="exp-doc-title">{$node.name|wash}</h1>
    </header>
{if and( is_set( $node.data_map.body ), $node.data_map.body.has_content )}
    <div class="exp-doc-body" data-exp-doc-body>{attribute_view_gui attribute=$node.data_map.body}</div>
{/if}
    <section class="exp-doc-children" aria-labelledby="exp-doc-contrib-pages">
        <h2 id="exp-doc-contrib-pages" class="a4-h2">{'Pages (%count)'|i18n( 'design/exp_doc', '', hash( '%count', $doc_pages|count ) )}</h2>
{if $doc_pages|count}
        <ul class="a4-plain exp-doc-cards">
        {foreach $doc_pages as $doc_object}{if $doc_object.main_node}<li>{node_view_gui view='line' content_node=$doc_object.main_node}</li>{/if}{/foreach}
        </ul>
{else}
        <p class="a4-meta">{'No pages name this contributor yet.'|i18n( 'design/exp_doc' )}</p>
{/if}
    </section>
</article>
{undef $doc_pages}
