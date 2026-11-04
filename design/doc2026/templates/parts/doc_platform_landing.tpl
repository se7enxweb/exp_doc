{* The landing page of the Platform container in the Modern design (the Confluence spaces of the old site, below
   one section made by the import, exp_doc.ini [PlatformSettings] RemoteID): the hero with its own text (the
   container's body), a card per space (its child sections, with their page counts), and the platform's recently
   changed pages with a link to the full list (doc/recent with (manual)/<this node>). Classic shows the container as
   the static page it came from. *}
{def $doc_spaces = fetch( 'exp_doc', 'menu_children', hash( 'parent_node_id', $node.node_id ) )
     $doc_recent = fetch( 'content', 'tree', hash( 'parent_node_id', $node.node_id,
                                                    'class_filter_type', 'include', 'class_filter_array', ezini( 'ModernSettings', 'PageClasses', 'exp_doc.ini' ),
                                                    'sort_by', array( 'modified', false() ),
                                                    'limit', ezini( 'PlatformSettings', 'RecentLimit', 'exp_doc.ini' ) ) )}
<section class="a4-help-hero exp-doc-hero" aria-labelledby="exp-doc-platform-title">
    <h1 id="exp-doc-platform-title" class="exp-doc-hero-title"><span class="exp-doc-hero-logo">{include uri='design:exp_doc/logo.tpl'}</span> {$node.name|wash}</h1>
    <p class="a4-help-hero-sub">{'The documentation of the Symfony stack (5.x): the spaces of the former documentation center, kept as they were.'|i18n( 'design/exp_doc' )}</p>
</section>

{if $doc_spaces|count}
<section class="exp-doc-landing-section" aria-labelledby="exp-doc-spaces-title">
    <h2 id="exp-doc-spaces-title" class="a4-h2">{'Spaces'|i18n( 'design/exp_doc' )}</h2>
    <ul class="a4-plain exp-doc-manuals">
    {foreach $doc_spaces as $doc_space}
        <li class="{cond( $doc_space.number|mod( 2 ), 'a4-help-grow', 'a4-help-about' )} exp-doc-manual">
            <span class="a4-help-tile" aria-hidden="true"><span class="a4-icon a4-bi-journal-text"></span></span>
            <div class="exp-doc-manual-body">
                <h3 class="exp-doc-manual-name"><a href={$doc_space.url_alias|ezurl}>{$doc_space.name|wash}</a></h3>
                <p class="a4-meta">{'%count pages'|i18n( 'design/exp_doc', '', hash( '%count', $doc_space.children_count ) )}</p>
            </div>
        </li>
    {/foreach}
    </ul>
</section>
{/if}

{if and( is_set( $node.data_map.body ), $node.data_map.body.has_content )}
<section class="exp-doc-landing-section exp-doc-body" aria-label="{$node.name|wash}">
{attribute_view_gui attribute=$node.data_map.body}
</section>
{/if}

{if $doc_recent|count}
<section class="a4-help-support exp-doc-landing-section" aria-labelledby="exp-doc-platform-recent-title">
    <h2 id="exp-doc-platform-recent-title" class="a4-h2">{'Recently changed'|i18n( 'design/exp_doc' )}</h2>
    <ol class="a4-plain exp-doc-landing-list">
    {foreach $doc_recent as $doc_item}
        <li><a href={$doc_item.url_alias|ezurl}>{$doc_item.name|wash}</a> <span class="a4-meta">{$doc_item.object.modified|l10n( 'shortdate' )}</span></li>
    {/foreach}
    </ol>
    <p class="exp-doc-landing-more"><a href={concat( ezini( 'RecentSettings', 'Path', 'exp_doc.ini' ), '/(manual)/', $node.node_id )|ezurl}>{'See all changes'|i18n( 'design/exp_doc' )}</a></p>
</section>
{/if}
{undef $doc_spaces $doc_recent}
