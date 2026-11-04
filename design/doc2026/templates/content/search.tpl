{* The search page of the Modern design: the kernel's filtered search (content/front_search_page.tpl: the search
   as view parameters, the filter bar, the active filters as chips, the results as cards), with a row of quick
   filters above it: every manual version (a subtree), and the documentation's own content types (tutorials,
   FAQ, extensions). Each quick filter is a link to the same search with that view parameter, never a query
   string; the languages are offered by the kernel's filter bar where the search engine can filter by language. *}
{def $doc_text = first_set( $view_parameters.text, '' )
     $doc_base = concat( '/content/search', cond( $doc_text|trim|ne( '' ), concat( '/(text)/', $doc_text|view_parameter ), '' ) )
     $doc_root = fetch( 'content', 'node', hash( 'node_id', ezini( 'NodeSettings', 'RootNode', 'content.ini' ) ) )
     $doc_versions = fetch( 'content', 'tree', hash( 'parent_node_id', $doc_root.node_id,
                                                      'class_filter_type', 'include', 'class_filter_array', array( 'exp_doc_version' ),
                                                      'sort_by', array( 'name', false() ), 'limit', 30 ) )
     $doc_types = ezini( 'ModernSettings', 'SearchQuickClasses', 'exp_doc.ini' )}
<div class="exp-doc-search-page">
<nav class="exp-doc-quickfilters" aria-label="{'Narrow the search'|i18n( 'design/exp_doc' )}">
    <span class="a4-meta">{'Narrow to:'|i18n( 'design/exp_doc' )}</span>
    <ul class="a4-plain">
    {foreach $doc_versions as $doc_v}
        <li><a class="a4-tag{if eq( first_set( $view_parameters.subtree, '' ), $doc_v.node_id )} is-accent{/if}" href={concat( $doc_base, '/(subtree)/', $doc_v.node_id )|ezurl}>{concat( $doc_v.parent.name, ' ', $doc_v.name )|wash}</a></li>
    {/foreach}
    {foreach $doc_types as $doc_identifier}
        {def $doc_class = fetch( 'content', 'class', hash( 'class_id', $doc_identifier ) )}
        {if $doc_class}<li><a class="a4-tag{if eq( first_set( $view_parameters.class, '' ), $doc_class.id )} is-accent{/if}" href={concat( $doc_base, '/(class)/', $doc_class.id )|ezurl}>{$doc_class.name|wash}</a></li>{/if}
        {undef $doc_class}
    {/foreach}
    </ul>
</nav>
{include uri='design:content/front_search_page.tpl' title='Search the documentation'|i18n( 'design/exp_doc' )}
</div>
{undef $doc_text $doc_base $doc_root $doc_versions $doc_types}
