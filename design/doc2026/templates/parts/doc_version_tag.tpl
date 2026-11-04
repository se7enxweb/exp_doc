{* One version as a tag (the landing's manual cards, the search's quick filters): the version's name, linked; a
   supported version (its status attribute is one of exp_doc.ini [ModernSettings] SupportedStatuses[], current or
   maintained) gets the accent outline and a "Supported" badge; another status (legacy, EOL) its own badge, without
   the outline. Parameters: version (the node), href (default: the version's page), current (marked). *}
{def $doc_status = $version.data_map.status.content|trim
     $doc_supported = ezini( 'ModernSettings', 'SupportedStatuses', 'exp_doc.ini' )|contains( $doc_status|downcase )}
<a class="exp-doc-version-tag{if $doc_supported} is-supported{/if}{if and( is_set( $current ), $current )} is-current{/if}" href={first_set( $href, $version.url_alias )|ezurl}{if and( is_set( $current ), $current )} aria-current="true"{/if}>
    <span class="exp-doc-version-name">{first_set( $label, $version.name )|wash}</span>
{if $doc_supported}
    <span class="exp-doc-version-badge is-supported">{'Supported'|i18n( 'design/exp_doc' )}</span>
{elseif $doc_status}
    <span class="exp-doc-version-badge is-{$doc_status|downcase|wash}">{$doc_status|wash}</span>
{/if}
</a>
{undef $doc_status $doc_supported}
