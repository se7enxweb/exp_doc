{* One level of a Modern page's historical comments (parts/doc_historical_comments.tpl): each comment with its author
   (linked to the contributor's page when the import knows them, else the name as written), its date and its text,
   and its replies indented below it, in the order of their priority. Parameters: parent_id, class, depth. *}
{def $doc_items = fetch( 'content', 'list', hash( 'parent_node_id', $parent_id,
                                                   'class_filter_type', 'include', 'class_filter_array', array( $class ),
                                                   'sort_by', array( 'priority', true() ) ) )}
{if $doc_items|count}
<ol class="a4-plain exp-doc-comment-thread{if gt( $depth, 1 )} is-reply{/if}">
{foreach $doc_items as $doc_item}
    {def $doc_m = $doc_item.data_map
         $doc_when = cond( and( is_set( $doc_m.created ), $doc_m.created.has_content ), $doc_m.created.content.timestamp, $doc_item.object.published )
         $doc_who = cond( and( is_set( $doc_m.author ), $doc_m.author.has_content ), $doc_m.author.content, false() )
         $doc_name = cond( is_set( $doc_m.author_name ), $doc_m.author_name.content, '' )}
    <li class="exp-doc-comment" id="historical-comment-{$doc_item.node_id}">
        <article class="a4-card exp-doc-comment-card" aria-labelledby="historical-comment-{$doc_item.node_id}-subject">
            <header class="exp-doc-comment-head">
                <h3 class="exp-doc-comment-subject" id="historical-comment-{$doc_item.node_id}-subject">{$doc_item.name|wash}</h3>
                <p class="a4-meta">{if and( $doc_who, $doc_who.main_node )}<a href={$doc_who.main_node.url_alias|ezurl}>{cond( $doc_name|ne( '' ), $doc_name, $doc_who.name )|wash}</a>{else}{$doc_name|wash}{/if} · <time datetime="{$doc_when|datetime( 'custom', '%Y-%m-%dT%H:%i' )}">{$doc_when|l10n( 'shortdatetime' )}</time></p>
            </header>
            <div class="exp-doc-comment-text">{if is_set( $doc_m.body )}{attribute_view_gui attribute=$doc_m.body}{elseif is_set( $doc_m.text )}{attribute_view_gui attribute=$doc_m.text}{/if}</div>
        </article>
        {if lt( $depth, ezini( 'CommentSettings', 'MaxDepth', 'exp_doc.ini' ) )}
        {include uri='design:parts/doc_historical_comment_thread.tpl' parent_id=$doc_item.node_id class=$class depth=inc( $depth )}
        {/if}
    </li>
    {undef $doc_m $doc_when $doc_who $doc_name}
{/foreach}
</ol>
{/if}
{undef $doc_items}
