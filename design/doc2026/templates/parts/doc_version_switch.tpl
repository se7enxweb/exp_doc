{* The version switch of a Modern page: when the page is inside a manual version (an exp_doc_version node), the
   other versions of the same manual, each linking the same page in that version when it exists (the same address
   below the version), else the version's start. The current version is marked, and its status (current,
   maintained, legacy, EOL; the attribute status) is shown as a badge. *}
{def $doc_version = false()}
{if eq( $node.class_identifier, 'exp_doc_version' )}{set $doc_version = $node}{/if}
{if not( $doc_version )}
    {foreach $node.path|reverse as $doc_up}
        {if eq( $doc_up.class_identifier, 'exp_doc_version' )}{set $doc_version = $doc_up}{break}{/if}
    {/foreach}
{/if}
{if $doc_version}
{def $doc_versions = fetch( 'content', 'list', hash( 'parent_node_id', $doc_version.parent_node_id,
                                                      'class_filter_type', 'include', 'class_filter_array', array( 'exp_doc_version' ),
                                                      'sort_by', $doc_version.parent.sort_array ) )
     $doc_rest = $node.url_alias|extract( $doc_version.url_alias|count_chars )
     $doc_status = $doc_version.data_map.status.content|trim}
<details class="exp-doc-version">
    <summary class="a4-btn exp-doc-version-current">
        {'Version %version'|i18n( 'design/exp_doc', '', hash( '%version', $doc_version.name|wash ) )}
        {if $doc_status}<span class="a4-badge exp-doc-status-{$doc_status|downcase|wash}">{$doc_status|wash}</span>{/if}
    </summary>
    <ul class="exp-doc-version-list">
    {foreach $doc_versions as $doc_other}
        {def $doc_same = cond( $doc_rest, fetch( 'content', 'node', hash( 'node_path', concat( $doc_other.url_alias, $doc_rest ) ) ), $doc_other )}
        <li><a href={cond( $doc_same, $doc_same.url_alias, $doc_other.url_alias )|ezurl}{if eq( $doc_other.node_id, $doc_version.node_id )} aria-current="true"{/if}>{$doc_other.name|wash}{if not( $doc_same )} <span class="a4-meta">{'(start page)'|i18n( 'design/exp_doc' )}</span>{/if}</a></li>
        {undef $doc_same}
    {/foreach}
    </ul>
</details>
{undef $doc_versions $doc_rest $doc_status}
{/if}
{undef $doc_version}
