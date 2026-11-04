{* The custom tag doc_expand (an imported "expand" macro): a disclosure, closed until opened; no script needed. *}
<details class="exp-doc-expand">
    <summary>{cond( and( is_set( $title ), $title ), $title, 'Show more'|i18n( 'design/exp_doc' ) )|wash}</summary>
{$content}
</details>
