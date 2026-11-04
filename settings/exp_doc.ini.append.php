<?php /* #?ini charset="utf-8"?

# exp_doc: the documentation site.
[DocSettings]
# The remote id of the Documentation site's root node (the migration creates it)
RootRemoteID=exp_doc_site_root
# The remote id of the media folder
MediaRemoteID=exp-doc-media
# Who gets the feedback of "Was this page helpful?" (empty: site.ini [MailSettings] AdminEmail)
FeedbackRecipient=
# The PDF tools for a manual, tried in this order: ezpdf, chromium, wkhtmltopdf
PdfTools[]
PdfTools[]=ezpdf
PdfTools[]=chromium
PdfTools[]=wkhtmltopdf

*/ ?>
