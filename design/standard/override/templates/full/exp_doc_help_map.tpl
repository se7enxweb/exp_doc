{* A help manual or chapter (help_manual, help_section: help maintained as content) in both designs: the documentation
   page (parts/doc_full.tpl, each design's own) with the manual's contents in the manual's order
   (exp_doc/help_map_body.tpl) as its body; Modern leaves out its child cards when the contents are there, which list the same pages. *}
{def $doc_help = fetch( 'exphelp', 'site_map', hash( 'object_id', $node.contentobject_id ) )}
{set-block scope=relative variable=doc_help_body}{include uri='design:exp_doc/help_map_body.tpl' node=$node help=$doc_help}{/set-block}
{include uri='design:parts/doc_full.tpl' node=$node body_html=$doc_help_body children=cond( $doc_help, false(), true() )}
{undef $doc_help}
