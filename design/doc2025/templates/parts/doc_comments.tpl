{* The comments of a Classic page, as on the static site: a thread of the page's comment objects (the class in
   exp_doc.ini [ClassicSettings] CommentClass), replies nested under the comment they answer, rows alternating
   comment-bglight / comment-bgdark; each with its heading, date, author, text and a Reply button, and a
   "New comment" button at the end. Shown only when the page has comments, as the static site did. The buttons post
   to content/action like any "new object here" form; whether a visitor may comment is the role's decision. *}
{def $doc_comment_class = ezini( 'ClassicSettings', 'CommentClass', 'exp_doc.ini' )
     $doc_comments = fetch( 'content', 'list', hash( 'parent_node_id', $node.node_id,
                                                      'class_filter_type', 'include',
                                                      'class_filter_array', array( $doc_comment_class ),
                                                      'sort_by', array( 'published', true() ) ) )}
{if $doc_comments|count}
<div id="comments" class="class-comment">
<div class="content-view-children">

<h1>{'Comments'|i18n( 'design/doc2025' )}</h1>
<div id="comments-content">
{include uri='design:parts/doc_comment_list.tpl' comments=$doc_comments class=$doc_comment_class page=$node}
</div>
<div class="toolbar">

<form method="post" action={'content/action'|ezurl}>
<input class="button" type="submit" name="NewButton" value="{'New comment'|i18n( 'design/doc2025' )}" />
<input type="hidden" name="NodeID" value="{$node.node_id}" />
<input type="hidden" name="RedirectURIAfterPublish" value="{$node.url_alias|wash}" />
<input type="hidden" name="ClassIdentifier" value="{$doc_comment_class|wash}" />
</form>
</div>

</div>
</div>
{/if}
{undef $doc_comment_class $doc_comments}
