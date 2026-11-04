{* The version switch of a Modern page: when the page is inside a version (an exp_doc_version node), the other
   versions next to it, each linking the same page in that version when it exists (the same address below the
   version), else the version's start. The outermost version of the page's path counts: in the tree of 2026-11-04 a
   version (/exponential/4.7) holds the manuals of that version, which are versions too. The current version is
   marked, and its status (current, maintained, legacy, EOL; the attribute status) is shown as a badge. *}
{def $doc_version = false()}
{foreach $node.path as $doc_up}
    {if eq( $doc_up.class_identifier, 'exp_doc_version' )}{set $doc_version = $doc_up}{break}{/if}
{/foreach}
{if and( not( $doc_version ), eq( $node.class_identifier, 'exp_doc_version' ) )}{set $doc_version = $node}{/if}
{if $doc_version}
{def $doc_versions = fetch( 'exp_doc', 'versions', hash( 'parent_node_id', $doc_version.parent_node_id ) )
     $doc_rest = $node.url_alias|extract( $doc_version.url_alias|count_chars )
     $doc_status = $doc_version.data_map.status.content|trim}
<details class="exp-doc-version">
    <summary class="a4-btn exp-doc-version-current">
        {'Version %version'|i18n( 'design/exp_doc', '', hash( '%version', $doc_version.name|wash ) )}
        {if ezini( 'ModernSettings', 'SupportedStatuses', 'exp_doc.ini' )|contains( $doc_status|downcase )}<span class="exp-doc-version-badge is-supported">{'Supported'|i18n( 'design/exp_doc' )}</span>{elseif $doc_status}<span class="exp-doc-version-badge is-{$doc_status|downcase|wash}">{$doc_status|wash}</span>{/if}
    </summary>
    <ul class="exp-doc-version-list">
    {foreach $doc_versions as $doc_other}
        {def $doc_same = cond( $doc_rest, fetch( 'content', 'node', hash( 'node_path', concat( $doc_other.url_alias, $doc_rest ) ) ), $doc_other )}
        <li>{include uri='design:parts/doc_version_tag.tpl' version=$doc_other href=cond( $doc_same, $doc_same.url_alias, $doc_other.url_alias ) current=eq( $doc_other.node_id, $doc_version.node_id ) label=cond( $doc_same, $doc_other.name, concat( $doc_other.name, ' ', '(start page)'|i18n( 'design/exp_doc' ) ) )}</li>
        {undef $doc_same}
    {/foreach}
    </ul>
</details>
{undef $doc_versions $doc_rest $doc_status}
{/if}
{undef $doc_version}
