{* The page tree of a Modern page (the left column; a drawer on a phone): the pages of the manual version (or the
   section) the page belongs to, the branch of the page open, the page marked. The root is found as in the Classic
   design (exp_doc.ini [ClassicSettings] TocRootClasses[] and ListRootClasses[]); a page under neither shows the
   site's top pages. Branches off the page's path start closed and open with their button (doc2026.js); without
   JavaScript every branch on the path is open and the others are links. *}
{def $doc_root = false()
     $doc_ids = array()
     $doc_roots = merge( ezini( 'ClassicSettings', 'TocRootClasses', 'exp_doc.ini' ), ezini( 'ClassicSettings', 'ListRootClasses', 'exp_doc.ini' ) )}
{foreach $path as $item}{if is_set( $item.node_id )}{set $doc_ids = $doc_ids|append( $item.node_id )}{/if}{/foreach}
{if $node}{set $doc_ids = $doc_ids|append( $node.node_id )}{/if}
{foreach $doc_ids|reverse as $doc_candidate_id}
    {def $doc_candidate = fetch( 'content', 'node', hash( 'node_id', $doc_candidate_id ) )}
    {if and( $doc_candidate, $doc_roots|contains( $doc_candidate.class_identifier ) )}{set $doc_root = $doc_candidate}{/if}
    {undef $doc_candidate}
    {if $doc_root}{break}{/if}
{/foreach}
{if not( $doc_root )}{set $doc_root = fetch( 'content', 'node', hash( 'node_id', ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ) )}{/if}
<nav id="exp-doc-tree" class="exp-doc-tree" aria-labelledby="exp-doc-tree-title" data-exp-doc-tree>
    <h2 id="exp-doc-tree-title" class="exp-doc-tree-title"><a href={$doc_root.url_alias|ezurl}{if and( $node, eq( $doc_root.node_id, $node.node_id ) )} aria-current="page"{/if}>{$doc_root.name|wash}</a></h2>
    {include uri='design:parts/doc_tree_level.tpl' parent=$doc_root path_ids=$doc_ids current_id=cond( $node, $node.node_id, 0 ) depth=1}
</nav>
{undef $doc_root $doc_ids $doc_roots}
