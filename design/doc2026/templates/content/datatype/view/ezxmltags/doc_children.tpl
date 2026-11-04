{* The custom tag doc_children (an imported "children" macro): the page's child pages, live from the tree. *}
{def $doc_page = fetch( 'content', 'node', hash( 'node_id', $DesignKeys:used.node ) )}
{if $doc_page}
{def $doc_children = fetch( 'content', 'list', hash( 'parent_node_id', $doc_page.node_id, 'sort_by', $doc_page.sort_array,
                                                      'class_filter_type', 'exclude',
                                                      'class_filter_array', ezini( 'ClassicSettings', 'MenuHideClasses', 'exp_doc.ini' ) ) )}
<ul class="exp-doc-child-list">
{foreach $doc_children as $doc_child}
    <li><a href={$doc_child.url_alias|ezurl}>{$doc_child.name|wash}</a></li>
{/foreach}
</ul>
{undef $doc_children}
{/if}
{undef $doc_page}
