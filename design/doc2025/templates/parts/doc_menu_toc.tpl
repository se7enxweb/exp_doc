{* "Table of contents" of a manual version, as the static site drew it (map#contentstructure): the version's
   chapters (li.topchapter, li.topchapter-selected for the open one); inside the open chapter its pages and their
   children, [ClassicSettings] TocDepth levels (2, as the static site); li.currentnode for the page shown, li.last for the last item of a list. Hidden nodes and
   the classes in [ClassicSettings] MenuHideClasses[] (images, files) are left out. *}
{def $doc_hide = ezini( 'ClassicSettings', 'MenuHideClasses', 'exp_doc.ini' )
     $doc_chapters = fetch( 'exp_doc', 'menu_children', hash( 'parent_node_id', $root.node_id ) )}
                        <div class="attribute-heading"><h2 class="bullet"><a href={$root.url_alias|ezurl}>{'Table of contents'|i18n( 'design/doc2025' )}</a></h2></div>

<div class="boxcontent">

<map id="contentstructure">

            <ul>
{foreach $doc_chapters as $chapter}
    {def $doc_open = $path_ids|contains( $chapter.node_id )}
	<li class="{cond( $doc_open, 'topchapter-selected ', 'topchapter' )}{if eq( $chapter.node_id, $current_id )} currentnode{/if}">
	    <div>
	    		<a class="nodetext" href={$chapter.url_alias|ezurl} title="">
	    		    <span class="node-name-normal">{$chapter.name|wash}</span>
	    		</a>
	    </div>
    {if $doc_open}
        {include uri='design:parts/doc_menu_toc_level.tpl' parent=$chapter depth=1 path_ids=$path_ids current_id=$current_id hide=$doc_hide}
    {/if}
	</li>
    {undef $doc_open}
{/foreach}
            </ul>

</map>

</div>
{undef $doc_hide $doc_chapters}
