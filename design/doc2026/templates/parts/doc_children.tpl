{* The child pages of a Modern page, live from the tree (the owner: "live from tree"), as cards: name and a short
   summary (the metadata description, else the start of the body). Images, files, comments and FAQ questions are
   listed by their own templates, not here. *}
{def $doc_children = fetch( 'content', 'list', hash( 'parent_node_id', $node.node_id,
                                                      'sort_by', $node.sort_array,
                                                      'class_filter_type', 'exclude',
                                                      'class_filter_array', merge( ezini( 'ClassicSettings', 'MenuHideClasses', 'exp_doc.ini' ), array( ezini( 'ClassicSettings', 'CommentClass', 'exp_doc.ini' ) ) ) ) )}
{if $doc_children|count}
<section class="exp-doc-children" aria-labelledby="exp-doc-children-title">
    <h2 id="exp-doc-children-title" class="a4-h2">{'In this section'|i18n( 'design/exp_doc' )}</h2>
    <ul class="a4-plain exp-doc-cards">
    {foreach $doc_children as $doc_child}
        <li>{node_view_gui view='line' content_node=$doc_child}</li>
    {/foreach}
    </ul>
</section>
{/if}
{undef $doc_children}
