{* "Table of contents" of a tutorial, as the static site drew it: the heading links the page shown, and the
   tutorial's steps are one list inside the outer list of map#contentstructure, li.currentnode for the page shown,
   li.last for the last step. The steps are listed with the classes in [ClassicSettings] ListMenuHideClasses[] left
   out (the menus' MenuHideClasses[] leaves the steps themselves out). *}
{def $doc_steps = fetch( 'content', 'list', hash( 'parent_node_id', $root.node_id,
                                                  'sort_by', $root.sort_array,
                                                  'class_filter_type', 'exclude',
                                                  'class_filter_array', ezini( 'ClassicSettings', 'ListMenuHideClasses', 'exp_doc.ini' ) ) )
     $doc_current = fetch( 'content', 'node', hash( 'node_id', $current_id ) )}
                        <div class="attribute-heading"><h2 class="bullet"><a href={cond( $doc_current, $doc_current.url_alias, $root.url_alias )|ezurl}>{'Table of contents'|i18n( 'design/doc2025' )}</a></h2></div>

<div class="boxcontent">

<map id="contentstructure">

            <ul>
{if $doc_steps|count}
            <ul>
{foreach $doc_steps as $doc_index => $item}
    {def $doc_classes = array()}
    {if eq( $item.node_id, $current_id )}{set $doc_classes = $doc_classes|append( 'currentnode' )}{/if}
    {if eq( $doc_index, dec( $doc_steps|count ) )}{set $doc_classes = $doc_classes|append( 'last' )}{/if}
	<li{if $doc_classes|count} class="{$doc_classes|implode( ' ' )}"{/if}>
	    <div>
	    		<a class="nodetext" href={$item.url_alias|ezurl} title="">
	    		    <span class="node-name-normal">{$item.name|wash}</span>
	    		</a>
	    </div>
	</li>
    {undef $doc_classes}
{/foreach}
            </ul>
{/if}
            </ul>

</map>

</div>
{undef $doc_steps $doc_current}
