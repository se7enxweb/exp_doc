{* The flat menu of a list section (the FAQ), as the static site drew it: the section's name, linked, as the
   heading, then its pages as li.topchapter, the open one li.topchapter-selected currentnode. The pages are listed
   with the classes in [ClassicSettings] ListMenuHideClasses[] left out (the menus' MenuHideClasses[] leaves the
   FAQ's questions themselves out). *}
{def $doc_items = fetch( 'content', 'list', hash( 'parent_node_id', $root.node_id,
                                                  'sort_by', $root.sort_array,
                                                  'class_filter_type', 'exclude',
                                                  'class_filter_array', ezini( 'ClassicSettings', 'ListMenuHideClasses', 'exp_doc.ini' ) ) )}
                        <div class="attribute-heading"><h2 class="bullet"><a href={$root.url_alias|ezurl}>{$root.name|wash}</a></h2></div>

<div class="boxcontent">

<map id="contentstructure">
<ul>{foreach $doc_items as $item}<li class="{cond( eq( $item.node_id, $current_id ), 'topchapter-selected currentnode', 'topchapter' )}"><a href={$item.url_alias|ezurl}>{$item.name|wash}</a></li>{/foreach}</ul>
</map>

</div>
{undef $doc_items}
