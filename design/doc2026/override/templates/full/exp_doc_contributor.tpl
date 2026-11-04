{* A contributor's page in the Modern design: the name, the picture, short biography and profile link when they are set
   (image, bio, profile_url), then every page
   that names this person (fetch exp_doc/contributor_pages: the pages' relations read in reverse, only visible pages
   the reader may open, no historical copies or comments), newest first, as cards, 24 a page with the kernel's pager
   (view parameter offset). *}
{def $doc_limit = 24
     $doc_offset = first_set( $view_parameters.offset, 0 )
     $doc_list = fetch( 'exp_doc', 'contributor_pages', hash( 'object_id', $node.contentobject_id, 'offset', $doc_offset, 'limit', $doc_limit ) )
     $doc_total = $doc_list.count
     $doc_pages = $doc_list.nodes}
<article class="exp-doc-article exp-doc-contributor">
    <header class="exp-doc-article-head">
        <p class="a4-meta">{'Contributor'|i18n( 'design/exp_doc' )}</p>
        <h1 class="exp-doc-title">{$node.name|wash}</h1>
    </header>
{if and( is_set( $node.data_map.image ), $node.data_map.image.has_content )}
    <img class="exp-doc-contributor-image" src={$node.data_map.image.content.medium.url|ezroot} alt="" width="{$node.data_map.image.content.medium.width}" height="{$node.data_map.image.content.medium.height}">
{/if}
{if and( is_set( $node.data_map.bio ), $node.data_map.bio.has_content )}
    <div class="exp-doc-body" data-exp-doc-body>{attribute_view_gui attribute=$node.data_map.bio}</div>
{/if}
{if and( is_set( $node.data_map.profile_url ), $node.data_map.profile_url.has_content )}
    <p><a href="{$node.data_map.profile_url.content|wash}" rel="noopener">{'Profile'|i18n( 'design/exp_doc' )}</a></p>
{/if}
    <section class="exp-doc-children" aria-labelledby="exp-doc-contrib-pages">
        <h2 id="exp-doc-contrib-pages" class="a4-h2">{'Pages (%count)'|i18n( 'design/exp_doc', '', hash( '%count', $doc_total ) )}</h2>
{if $doc_pages|count}
        <ul class="a4-plain exp-doc-cards">
        {foreach $doc_pages as $doc_page}<li>{node_view_gui view='line' content_node=$doc_page}</li>{/foreach}
        </ul>
        {include uri='design:navigator/google.tpl' page_uri=$node.url_alias item_count=$doc_total view_parameters=$view_parameters item_limit=$doc_limit}
{else}
        <p class="a4-meta">{'No pages name this contributor yet.'|i18n( 'design/exp_doc' )}</p>
{/if}
    </section>
</article>
{undef $doc_limit $doc_offset $doc_list $doc_total $doc_pages}
