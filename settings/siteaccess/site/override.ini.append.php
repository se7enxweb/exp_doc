<?php /* #?ini charset="utf-8"?

# The views of the documentation classes on the front siteaccess site only (the admin keeps its own templates; a rule
# here in the global settings sent the admin to templates that only the doc designs have). Every design of the site
# has the same files (doc2025 Classic, doc2026 Modern), so the rules hold whichever design is chosen.

[full_exp_doc_page]
Source=node/view/full.tpl
MatchFile=full/exp_doc_page.tpl
Subdir=templates
Match[class_identifier]=exp_doc_page

[full_exp_doc_section]
Source=node/view/full.tpl
MatchFile=full/exp_doc_page.tpl
Subdir=templates
Match[class_identifier]=exp_doc_section

[full_exp_doc_manual]
Source=node/view/full.tpl
MatchFile=full/exp_doc_page.tpl
Subdir=templates
Match[class_identifier]=exp_doc_manual

[full_exp_doc_version]
Source=node/view/full.tpl
MatchFile=full/exp_doc_page.tpl
Subdir=templates
Match[class_identifier]=exp_doc_version

[full_exp_doc_faq]
Source=node/view/full.tpl
MatchFile=full/exp_doc_faq.tpl
Subdir=templates
Match[class_identifier]=exp_doc_faq

[full_exp_doc_tutorial]
Source=node/view/full.tpl
MatchFile=full/exp_doc_tutorial.tpl
Subdir=templates
Match[class_identifier]=exp_doc_tutorial

[full_exp_doc_extension]
Source=node/view/full.tpl
MatchFile=full/exp_doc_extension.tpl
Subdir=templates
Match[class_identifier]=exp_doc_extension

[full_exp_doc_contributor]
Source=node/view/full.tpl
MatchFile=full/exp_doc_contributor.tpl
Subdir=templates
Match[class_identifier]=exp_doc_contributor

[line_exp_doc_contributor]
Source=node/view/line.tpl
MatchFile=line/exp_doc_contributor.tpl
Subdir=templates
Match[class_identifier]=exp_doc_contributor

[embed_exp_doc_image]
Source=content/view/embed.tpl
MatchFile=embed/exp_doc_image.tpl
Subdir=templates
Match[class_identifier]=exp_doc_image

# The site's root and other folders: the documentation's own full and line views (Modern draws the landing on the
# front page), not the standard design's folder templates
[full_folder_doc]
Source=node/view/full.tpl
MatchFile=full/exp_doc_page.tpl
Subdir=templates
Match[class_identifier]=folder

[line_folder_doc]
Source=node/view/line.tpl
MatchFile=line/exp_doc_page.tpl
Subdir=templates
Match[class_identifier]=folder

# Help maintained as content (the help_* classes below /media/help): the page of the design with the text as the
# help renders it (fetch exphelp/site_topic and exphelp/site_map), never the Markdown of the fields. The templates are
# in design/standard and serve both designs.
[full_help_concept_doc]
Source=node/view/full.tpl
MatchFile=full/exp_doc_help_topic.tpl
Subdir=templates
Match[class_identifier]=help_concept

[full_help_task_doc]
Source=node/view/full.tpl
MatchFile=full/exp_doc_help_topic.tpl
Subdir=templates
Match[class_identifier]=help_task

[full_help_reference_doc]
Source=node/view/full.tpl
MatchFile=full/exp_doc_help_topic.tpl
Subdir=templates
Match[class_identifier]=help_reference

[full_help_troubleshooting_doc]
Source=node/view/full.tpl
MatchFile=full/exp_doc_help_topic.tpl
Subdir=templates
Match[class_identifier]=help_troubleshooting

[full_help_manual_doc]
Source=node/view/full.tpl
MatchFile=full/exp_doc_help_map.tpl
Subdir=templates
Match[class_identifier]=help_manual

[full_help_section_doc]
Source=node/view/full.tpl
MatchFile=full/exp_doc_help_map.tpl
Subdir=templates
Match[class_identifier]=help_section

*/ ?>
