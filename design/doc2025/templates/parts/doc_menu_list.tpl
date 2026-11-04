{* The flat menu of a list section (the FAQ and similar), as the static site drew it: the section's name, linked,
   as the heading, then its pages as li.topchapter, the open one li.topchapter-selected. *}
{def $doc_items = fetch( 'content', 'list', hash( 'parent_node_id', $root.node_id,
                                                   'sort_by', $root.sort_array,
                                                   'class_filter_type', 'exclude',
                                                   'class_filter_array', ezini( 'ClassicSettings', 'MenuHideClasses', 'exp_doc.ini' ) ) )}
                        <div class="attribute-heading"><h2 class="bullet"><a href={$root.url_alias|ezurl}>{$root.name|wash}</a></h2></div>

<div class="boxcontent">

<map id="contentstructure">
<ul>{foreach $doc_items as $item}<li class="{cond( eq( $item.node_id, $current_id ), 'topchapter-selected', 'topchapter' )}"><a href={$item.url_alias|ezurl}>{$item.name|wash}</a></li>{/foreach}</ul>
</map>

</div>
{undef $doc_items}
