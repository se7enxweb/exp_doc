{* doc/comment when the comment cannot be taken as sent (a field to correct, too many in a short time): the message
   and the form filled in again, below the page's name. Variables: parent, page, input, errors. *}
<article class="exp-doc-article">
    <h1 class="exp-doc-title">{'Add a comment'|i18n( 'design/exp_doc' )}</h1>
    <p>{'On the page %page'|i18n( 'design/exp_doc', '', hash( '%page', concat( '<a href=', $page.url_alias|ezurl, '>', $page.name|wash, '</a>' ) ) )}</p>
    {include uri='design:parts/doc_comment_form.tpl' parent_id=$parent.node_id prefix='comment' input=$input errors=$errors}
</article>
