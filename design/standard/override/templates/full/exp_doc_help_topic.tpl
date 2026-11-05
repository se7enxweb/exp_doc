{* A help topic (help_concept, help_task, help_reference, help_troubleshooting: help maintained as content) in both
   designs: the documentation page (parts/doc_full.tpl, each design's own) with the topic's text rendered by the help
   (exp_doc/help_topic_body.tpl) as its body, in place of the fields, which hold Markdown. *}
{def $doc_help = fetch( 'exphelp', 'site_topic', hash( 'object_id', $node.contentobject_id ) )}
{set-block scope=relative variable=doc_help_body}{include uri='design:exp_doc/help_topic_body.tpl' node=$node help=$doc_help}{/set-block}
{include uri='design:parts/doc_full.tpl' node=$node body_html=$doc_help_body}
{undef $doc_help}
