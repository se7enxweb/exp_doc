{* The feed link of the head: the Atom feed of the recent changes (doc/recent with (feed)/atom); on the recent
   changes' own page, the feed of the list it shows (its filters). Classic passes only_own=true(): the static pages
   had no feed, so the link is there on the recent changes' page only (that page is a listed exception). *}
{def $doc_own = and( is_set( $module_result.content_info.persistent_variable.doc_feed ), $module_result.content_info.persistent_variable.doc_feed )}
{if or( $doc_own, and( is_set( $only_own ), $only_own )|not )}
    <link rel="alternate" type="application/atom+xml" title="{'Recent changes'|i18n( 'design/exp_doc' )}" href={cond( $doc_own, $module_result.content_info.persistent_variable.doc_feed, concat( ezini( 'RecentSettings', 'Path', 'exp_doc.ini' ), '/(feed)/atom' ) )|ezurl( 'double', 'full' )}>
{/if}
{undef $doc_own}
