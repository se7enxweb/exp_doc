{* The comment form of a Modern page (parts/doc_page_comments.tpl, a reply below a comment, and doc/comment.tpl when
   a field must be corrected). It posts to doc/comment; ezformtoken adds the form token. CommentWebsite is the
   honeypot: hidden from people (and from screen readers), so only robots fill it in. Parameters: parent_id, prefix
   (unique ids on the page), input and errors (doc/comment.tpl), reply (true: a reply's smaller form). *}
{def $doc_in = cond( is_set( $input ), $input, hash( 'name', '', 'email', '', 'subject', '', 'message', '' ) )
     $doc_err = cond( is_set( $errors ), $errors, hash() )}
<form class="exp-doc-comment-form" method="post" action={'doc/comment'|ezurl}>
    <input type="hidden" name="ParentNodeID" value="{$parent_id|wash}">
    {if is_set( $doc_err.form )}<p class="a4-field-error" role="alert">{$doc_err.form|wash}</p>{/if}
    <div class="exp-doc-comment-fields">
        <div class="a4-field">
            <label for="{$prefix}-name">{'Name'|i18n( 'design/exp_doc' )}<span class="a4-required-mark" aria-hidden="true">*</span></label>
            <input type="text" id="{$prefix}-name" name="CommentName" value="{$doc_in.name|wash}" required maxlength="{ezini( 'CommentSettings', 'NameLength', 'exp_doc.ini' )}" autocomplete="name"{if is_set( $doc_err.name )} aria-invalid="true" aria-describedby="{$prefix}-name-error"{/if}>
            {if is_set( $doc_err.name )}<p class="a4-field-error" id="{$prefix}-name-error">{$doc_err.name|wash}</p>{/if}
        </div>
        <div class="a4-field">
            <label for="{$prefix}-email">{'E-mail (optional, never shown)'|i18n( 'design/exp_doc' )}</label>
            <input type="email" id="{$prefix}-email" name="CommentEmail" value="{$doc_in.email|wash}" autocomplete="email"{if is_set( $doc_err.email )} aria-invalid="true" aria-describedby="{$prefix}-email-error"{/if}>
            {if is_set( $doc_err.email )}<p class="a4-field-error" id="{$prefix}-email-error">{$doc_err.email|wash}</p>{/if}
        </div>
    </div>
    <div class="a4-field">
        <label for="{$prefix}-subject">{'Subject'|i18n( 'design/exp_doc' )}</label>
        <input type="text" id="{$prefix}-subject" name="CommentSubject" value="{$doc_in.subject|wash}" maxlength="{ezini( 'CommentSettings', 'SubjectLength', 'exp_doc.ini' )}"{if is_set( $doc_err.subject )} aria-invalid="true" aria-describedby="{$prefix}-subject-error"{/if}>
        {if is_set( $doc_err.subject )}<p class="a4-field-error" id="{$prefix}-subject-error">{$doc_err.subject|wash}</p>{/if}
    </div>
    <div class="a4-field">
        <label for="{$prefix}-message">{'Comment'|i18n( 'design/exp_doc' )}<span class="a4-required-mark" aria-hidden="true">*</span></label>
        <textarea id="{$prefix}-message" name="CommentMessage" rows="{cond( and( is_set( $reply ), $reply ), 4, 6 )}" required maxlength="{ezini( 'CommentSettings', 'MessageLength', 'exp_doc.ini' )}"{if is_set( $doc_err.message )} aria-invalid="true" aria-describedby="{$prefix}-message-error"{/if}>{$doc_in.message|wash}</textarea>
        {if is_set( $doc_err.message )}<p class="a4-field-error" id="{$prefix}-message-error">{$doc_err.message|wash}</p>{/if}
    </div>
    <div class="exp-doc-comment-trap" aria-hidden="true">
        <label for="{$prefix}-website">{'Leave this field empty'|i18n( 'design/exp_doc' )}</label>
        <input type="text" id="{$prefix}-website" name="CommentWebsite" value="" tabindex="-1" autocomplete="off">
    </div>
    <p class="a4-meta">{'Comments are read by a moderator before they appear.'|i18n( 'design/exp_doc' )}</p>
    <button type="submit" class="a4-btn a4-btn-primary" name="CommentButton">{cond( and( is_set( $reply ), $reply ), 'Send the reply'|i18n( 'design/exp_doc' ), 'Send the comment'|i18n( 'design/exp_doc' ) )}</button>
</form>
{undef $doc_in $doc_err}
