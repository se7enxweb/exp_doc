{* The show/hide control of the help center's menu, in both designs (doc2026 pagelayout.tpl, doc2025 pagelayout.tpl):
   a slim rail in the menu's column with one button. The menu starts hidden; the reader's choice is the preference
   exp_doc_help_sidebar (collapsed|expanded; no value is collapsed), which the page layout reads to draw the state
   from the start (is-side-collapsed on the grid, no jump on load). For an anonymous reader the kernel keeps the
   preference in the session.
   - Without JavaScript the button posts the form to user/preferences, which stores the opposite value and brings
     the reader back to this page.
   - With JavaScript (javascript/exp-doc-resizer.js) the form is sent in the background to
     user/preferences/set_and_exit and the menu opens or closes at once.
   On a phone the rail is hidden; the menu is the drawer there, as before (stylesheets/exp-doc-resizer.css).
   Parameters: side_id (the id of the menu), expanded (the state drawn). *}
{def $doc_side_show = 'Show menu'|i18n( 'design/exp_doc' )
     $doc_side_hide = 'Hide menu'|i18n( 'design/exp_doc' )}
<div class="exp-doc-side-rail" data-exp-side-rail>
    <form class="exp-doc-side-form" method="post" action={'user/preferences'|ezurl} data-exp-side-form>
        <input type="hidden" name="Key" value="exp_doc_help_sidebar">
        <input type="hidden" name="Value" value="{cond( $expanded, 'collapsed', 'expanded' )}" data-exp-side-value>
        <input type="hidden" name="RedirectURIAfterSet" value="{$site.uri.original_uri|wash}">
        <button type="submit" class="exp-doc-side-toggle" aria-controls="{$side_id|wash}" aria-expanded="{cond( $expanded, 'true', 'false' )}" title="{cond( $expanded, $doc_side_hide, $doc_side_show )|wash}" data-label-show="{$doc_side_show|wash}" data-label-hide="{$doc_side_hide|wash}">
            <span class="a4-icon a4-bi-layout-sidebar-inset" aria-hidden="true"></span>
            <span class="a4-icon a4-bi-grip-vertical exp-doc-side-grip" aria-hidden="true"></span>
            <span class="a4-sr-only" data-exp-side-label>{cond( $expanded, $doc_side_hide, $doc_side_show )|wash}</span>
        </button>
    </form>
</div>
{undef $doc_side_show $doc_side_hide}
