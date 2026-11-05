{* The notice of a reader's comment that waits for moderation (expDocComment::notify()), in the kernel's mail design:
   design:mail/layout.tpl (HTML) and design:mail/layout_text.tpl (the plain-text part); this template only passes
   text and links, the layout washes them. The e-mail address the reader gave is not in it.

   Variables: page_name, page_url (absolute), author, subject, message (texts), held_url (absolute: the
   administration's Recent content, filtered on held items). *}
{set-block scope=root variable=content_type}text/html{/set-block}
{def $ch_rows = array( hash( 'label', 'Page'|i18n( 'design/exp_doc' ), 'value', $page_name ),
                       hash( 'label', 'Name'|i18n( 'design/exp_doc' ), 'value', $author ),
                       hash( 'label', 'Subject'|i18n( 'design/exp_doc' ), 'value', $subject ) )
     $ch_buttons = array( hash( 'label', 'Release or delete'|i18n( 'design/exp_doc' ), 'url', $held_url, 'kind', 'primary' ),
                          hash( 'label', 'Open the page'|i18n( 'design/exp_doc' ), 'url', $page_url, 'kind', 'secondary' ) )
     $ch_title = 'Comment waiting'|i18n( 'design/exp_doc' )
     $ch_intro = 'A comment on the documentation waits for moderation.'|i18n( 'design/exp_doc' )
     $ch_notice = 'Release or delete it in the administration: Dashboard > Recent content, filter "Held".'|i18n( 'design/exp_doc' )
     $ch_footer = 'This mail was sent by %siteurl because a reader commented on a page.'|i18n( 'design/exp_doc', '', hash( '%siteurl', ezini( 'SiteSettings', 'SiteURL' ) ) )}
{set-block scope=root variable=body_text}{include uri='design:mail/layout_text.tpl'
    mail_title=$ch_title mail_intro=$ch_intro mail_rows=$ch_rows mail_paragraphs=array( $message )
    mail_notice=$ch_notice mail_buttons=$ch_buttons mail_footer=$ch_footer}{/set-block}
{include uri='design:mail/layout.tpl'
    mail_title=$ch_title mail_intro=$ch_intro mail_rows=$ch_rows mail_paragraphs=array( $message )
    mail_notice=$ch_notice mail_buttons=$ch_buttons mail_footer=$ch_footer}
{undef $ch_rows $ch_buttons $ch_title $ch_intro $ch_notice $ch_footer}
