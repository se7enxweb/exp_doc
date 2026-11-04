{* One level of a Classic comment thread (parts/doc_comments.tpl): each comment in its row, its replies nested
   inside the row, as on the static site. The author as the source wrote it (author_name), the date (created), the
   text (body); the old class exp_doc_comment kept them in author and text. *}
<ul>{foreach $comments as $doc_index => $comment}    <li class="{cond( $doc_index|mod( 2 )|eq( 0 ), 'comment-bglight', 'comment-bgdark' )}"><div class="padding">
    <div class="content-view-line">
<div class="class-comment">

<form method="post" action={'content/action'|ezurl}>

<div id="comment{$comment.node_id}" class="attribute-heading">
<h2>{$comment.name|wash}</h2>
</div>

<div class="attribute-byline float-break">
 <p class="date">{cond( and( is_set( $comment.data_map.created ), $comment.data_map.created.has_content ), $comment.data_map.created.content.timestamp, $comment.object.published )|datetime( 'custom', '%l %d %F %Y %g:%i:%s %a' )}</p>
 <p class="author">{if is_set( $comment.data_map.author_name )}{$comment.data_map.author_name.content|wash}{else}{$comment.data_map.author.content|wash}{/if}</p>
</div>

<div class="attribute-short">
{if is_set( $comment.data_map.body )}{$comment.data_map.body.content.output.output_text}{else}{$comment.data_map.text.content.output.output_text}{/if}
</div>

<input class="button" type="submit" name="NewButton" value="{'Reply'|i18n( 'design/doc2025' )}" />
<input type="hidden" name="NodeID" value="{$comment.node_id}" />
<input type="hidden" name="ClassIdentifier" value="{$class|wash}" />

<input type="hidden" name="RedirectURIAfterPublish" value="{$page.url_alias|wash}" />

</form>

{def $doc_replies = fetch( 'content', 'list', hash( 'parent_node_id', $comment.node_id,
                                                     'class_filter_type', 'include',
                                                     'class_filter_array', array( $class ),
                                                     'sort_by', array( 'priority', true() ) ) )}
{if $doc_replies|count}
{include uri='design:parts/doc_comment_list.tpl' comments=$doc_replies class=$class page=$page}
{/if}
{undef $doc_replies}
</div>
</div>    </div></li>{/foreach}</ul>
