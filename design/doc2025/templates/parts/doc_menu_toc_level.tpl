{* One level of the open chapter in the Classic table of contents (parts/doc_menu_toc.tpl): the children of
   $parent; every child that is on the page's path, or is the page, opens its own children, down to
   [ClassicSettings] TocDepth levels. *}
{def $doc_items = fetch( 'content', 'list', hash( 'parent_node_id', $parent.node_id,
                                                   'sort_by', $parent.sort_array,
                                                   'class_filter_type', 'exclude',
                                                   'class_filter_array', $hide ) )
     $doc_max = ezini( 'ClassicSettings', 'TocDepth', 'exp_doc.ini' )}
{if $doc_items|count}
            <ul>
{foreach $doc_items as $doc_index => $item}
    {def $doc_classes = array()}
    {if eq( $item.node_id, $current_id )}{set $doc_classes = $doc_classes|append( 'currentnode' )}{/if}
    {if eq( $doc_index, dec( $doc_items|count ) )}{set $doc_classes = $doc_classes|append( 'last' )}{/if}
	<li{if $doc_classes|count} class="{$doc_classes|implode( ' ' )}"{/if}>
	    <div>
	    		<a class="nodetext" href={$item.url_alias|ezurl} title="">
	    		    <span class="node-name-normal">{$item.name|wash}</span>
	    		</a>
	    </div>
    {if lt( $depth, $doc_max )}
        {include uri='design:parts/doc_menu_toc_level.tpl' parent=$item depth=inc( $depth ) path_ids=$path_ids current_id=$current_id hide=$hide}
    {/if}
	</li>
    {undef $doc_classes}
{/foreach}
            </ul>
{/if}
{undef $doc_items $doc_max}
