<?php
/**
 * doc/comment: a reader's comment on a documentation page, or a reply to a comment (expDocComment). POST only; the
 * form token is checked by ezformtoken before the view runs.
 *
 *   - the honeypot (CommentWebsite) filled in: answered as if the comment was taken, nothing stored;
 *   - over the rate limit, or a field not valid: this view's own page (design:doc/comment.tpl) with the message and
 *     the form filled in again;
 *   - stored: back to the page with (comment)/held (it waits for a moderator: the review hold's auto-hold) or
 *     (comment)/published, at the comments.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

$Module = $Params['Module'];

if ( !$Module->isCurrentAction( 'Comment' ) )
{
    return $Module->redirectTo( '/' );
}

$input = array();
foreach ( array( 'ParentNodeID' => 'parent', 'Name' => 'name', 'Email' => 'email', 'Subject' => 'subject', 'Message' => 'message', 'Website' => 'website' ) as $name => $key )
{
    $input[$key] = $Module->hasActionParameter( $name ) ? (string)$Module->actionParameter( $name ) : '';
}
$parent = ctype_digit( $input['parent'] ) ? eZContentObjectTreeNode::fetch( (int)$input['parent'] ) : null;
if ( !$parent instanceof eZContentObjectTreeNode || !$parent->canRead() || !expDocComment::takesComments( $parent ) )
{
    return $Module->handleError( eZError::KERNEL_NOT_AVAILABLE, 'kernel' );
}
$page = expDocComment::page( $parent );
$back = function ( $state ) use ( $Module, $page )
{
    return $Module->redirectTo( '/' . $page->attribute( 'url_alias' ) . '/(comment)/' . $state . '#exp-doc-comments' );
};

// a robot fills in every field; a person never sees this one
if ( trim( $input['website'] ) !== '' )
{
    return $back( expDocComment::HELD );
}

$errors = expDocComment::overLimit()
        ? array( 'form' => ezpI18n::tr( 'design/exp_doc', 'You have sent several comments in a short time. Please wait a few minutes and send it again.' ) )
        : expDocComment::errors( $input );
if ( !$errors )
{
    $result = expDocComment::submit( $parent, $input );
    if ( in_array( $result['status'], array( expDocComment::HELD, expDocComment::PUBLISHED ), true ) )
    {
        return $back( $result['status'] );
    }
    $errors = array( 'form' => $result['status'] === expDocComment::REFUSED
                               ? ezpI18n::tr( 'design/exp_doc', 'Comments cannot be added here.' )
                               : ezpI18n::tr( 'design/exp_doc', 'The comment could not be saved. Please try again later.' ) );
}

$tpl = eZTemplate::factory();
$tpl->setVariable( 'parent', $parent );
$tpl->setVariable( 'page', $page );
$tpl->setVariable( 'input', $input );
$tpl->setVariable( 'errors', $errors );
$Result = array();
$Result['content'] = $tpl->fetch( 'design:doc/comment.tpl' );
$Result['path'] = array( array( 'text' => $page->attribute( 'name' ), 'url' => $page->attribute( 'url_alias' ) ),
                         array( 'text' => ezpI18n::tr( 'design/exp_doc', 'Add a comment' ), 'url' => false ) );
