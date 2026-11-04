{* The custom tag doc_panel (an imported info, note, warning or tip panel): a box with its kind as a class. *}
{def $doc_kind = cond( and( is_set( $type ), array( 'info', 'note', 'warning', 'tip' )|contains( $type ) ), $type, 'info' )}
<div class="exp-doc-panel is-{$doc_kind}" role="note">
{$content}
</div>
{undef $doc_kind}
