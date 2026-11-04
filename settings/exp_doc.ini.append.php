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


# The Classic design (doc2025): the frame of the static documentation site (design/doc2025, templates/parts/doc_*).
[ClassicSettings]
# The front page's title, description and Open Graph site name (parts/doc_head.tpl)
FrontTitle=The Official Documentation For Exponential 6 CMS
# The heading of the front page and its last path item (the static index.html was the page "Exponential")
FrontHeading=Exponential
FrontDescription=Read Exponential Documentation For Free and Join Our Community!
SiteName=Exponential 6.0 CMS Documentation
# Every other page: "<path from the page up> - <TitleSuffix>"
TitleSuffix=Doc
# The first item of the path line, linking the front page
PathHomeName=7x
# The static file whose page the path's "documentation" (the site's root) links
PathRootSource=documentation.html
# The static start page: the root shows its description; while that is empty, the body of the page imported from
# this file (hidden since the root took its place)
RootSource=index.html
# The first folders of the static paths whose pages come from the Confluence space: their byline is drawn in the
# Confluence markup (parts/doc_confluence_meta.tpl), not the ezdoc "Written by" box
ConfluencePrefixes[]
ConfluencePrefixes[]=display
ConfluencePrefixes[]=pages
ConfluencePrefixes[]=label
# The meta tags of every page, as on the static site
MetaTags[]
MetaTags[author]=7x
MetaTags[copyright]=7x
MetaTags[description]=Exponential Documentation
MetaTags[keywords]=Exponential, documentation, manual, reference, 7x
# The caution box above every page (parts/doc_disclaimer.tpl): enabled|disabled
Disclaimer=enabled
# The left menu (parts/doc_menu.tpl): the classes whose node opens a "Table of contents", and those whose node
# opens a flat list; a page under neither shows the quick links
TocRootClasses[]
TocRootClasses[]=exp_doc_version
ListRootClasses[]
ListRootClasses[]=exp_doc_section
ListRootClasses[]=exp_doc_faq
# How deep the open chapter of a table of contents unfolds
TocDepth=2
# The class of the historical comments of the old site under a page (parts/doc_comments.tpl in Classic,
# parts/doc_historical_comments.tpl in Modern; replies are their children, in the order of their priority)
CommentClass=comment_historical
# Classes never listed in the menus
MenuHideClasses[]
MenuHideClasses[]=exp_doc_image
MenuHideClasses[]=exp_doc_file
MenuHideClasses[]=exp_doc_faq_question
MenuHideClasses[]=exp_doc_tutorial_step
MenuHideClasses[]=exp_doc_contributor
MenuHideClasses[]=exp_doc_historical
MenuHideClasses[]=comment_historical
# Nodes never listed in the menus, by remote id: the Contributors folder (its people have their own pages, linked
# from the bylines)
MenuHideNodeRemoteIDs[]
MenuHideNodeRemoteIDs[]=exp-doc-contributors
# The social links of the footer: SocialLinks[<label>]=<address>
SocialLinks[]
SocialLinks[YouTube]=https://www.youtube.com/@ExponentialCMSInsights
SocialLinks[Linkedin]=http://www.Linkedin.com/groups?gid=2759&trk=myg_ugrp_ovr
SocialLinks[Instagram]=https://www.Instagram.com/se7enxweb
SocialLinks[Facebook]=http://facebook.exponential.earth
SocialLinks[BlueSky]=https://bsky.app/profile/exponentialcms.bsky.social
SocialLinks[X]=https://twitter.com/se7enxweb

# The quick links of the Classic front and top-level pages (parts/doc_menu_quicklinks.tpl), as on the static site.
# Links[]=<static file the page was imported from>;<label>
[ClassicQuicklinks]
Groups[]
Groups[]=exponential
Groups[]=platform
Groups[]=extensions

[Quicklinks_exponential]
Heading=Exponential
Links[]
Links[]=Exponential/Technical-manual/4.x/Reference.html;TM : Reference (v6.x)
Links[]=Exponential/Technical-manual/6.html;Technical manual (v6.x)
Links[]=Exponential/User-manual/6.html;User manual (v6.x)
Links[]=Extensions.html;Extensions
Links[]=Tutorials.html;Tutorials
Links[]=FAQ.html;FAQ
Links[]=Exponential/Upgrading.html;Upgrading manual
Links[]=documentation.html;Manual Downloads (PDF / Zip+HTML)
Links[]=display/MAIN/ExponentialPlatformDocumentationCenter.html;Symfony Stack (5.x) Manuals
Links[]=License.html;Documentation License
Links[]=doc_hidden/Standing-on-the-shoulders-of-giants.html;Credits

[Quicklinks_platform]
Heading=Exponential Platform
Links[]
Links[]=display/MAIN/ExponentialPlatformDocumentationCenter.html;Symfony Stack (5.x) Manuals

[Quicklinks_extensions]
Heading=Extensions
HeadingSource=Extensions.html
Links[]
Links[]=Extensions/Exponential-extensions.html;All bundled extensions
Links[]=Extensions/Exponential-extensions/eZ-Find.html;eZ Find
Links[]=Extensions/Exponential-extensions/eZ-Flow.html;eZ Flow
Links[]=Extensions/Exponential-extensions/Website-Interface.html;Website Interface (eZ Webin)
Links[]=Extensions/Exponential-extensions/eZ-JS-Core.html;eZ JS-Core
Links[]=Extensions/Exponential-extensions/Online-Editor/4.html;eZ Online Editor (eZ OE)
Links[]=Extensions/Exponential-extensions/eZ-Image-Editor.html;eZ Image Editor
Links[]=Extensions/Exponential-extensions/eZ-Multiupload.html;eZ Multiupload
Links[]=Extensions/Exponential-extensions/Exponential-Extension-for-Oracle-R-database.html;Exponential Extension for <br />Oracle&reg; database

# The Modern design (doc2026, the "doc" design)
[ModernSettings]
SiteName=Exponential Documentation
SiteDescription=The documentation of Exponential: installation, configuration, development and every extension.
LandingTitle=Exponential Documentation
# The landing heading after the official logo, which stands for the word "Exponential" (named so for screen readers)
LandingHeading=Documentation
LandingText=Install, configure, extend and run Exponential: manuals for every version, tutorials, FAQ and the extensions.
# How many levels the page tree (parts/doc_tree.tpl) draws below the manual version
TreeDepth=3
# How many of the site's top pages the tree of a page outside the manuals lists (then a link to all of them)
SiteTreeLimit=40
# The classes that count as pages (recently changed on the front page)
PageClasses[]
PageClasses[]=exp_doc_page
PageClasses[]=exp_doc_section
PageClasses[]=exp_doc_tutorial
PageClasses[]=exp_doc_faq
PageClasses[]=exp_doc_extension
# The information collector attributes of "Was this page helpful?" (parts/doc_feedback.tpl); a class without them
# shows no form
FeedbackAttributes[]
FeedbackAttributes[]=feedback_helpful
FeedbackAttributes[]=feedback_comment
# The version statuses that count as supported: those versions get the accent outline and a "Supported" badge
# (parts/doc_version_tag.tpl); the other statuses (legacy, EOL) show as their own badge
SupportedStatuses[]
SupportedStatuses[]=current
SupportedStatuses[]=maintained
# The content types offered as quick filters above the search results (content/search.tpl)
SearchQuickClasses[]
SearchQuickClasses[]=exp_doc_tutorial
SearchQuickClasses[]=exp_doc_faq
SearchQuickClasses[]=exp_doc_extension
# The admin siteaccess's address prefix, for "Edit this page"
AdminPrefix=admin
# The image size embedded images are shown at
EmbedImageAlias=large

# The brand images of both designs (bin/python/doc_brand_images.py, from the official logo): the theme color for
# light and dark (the accent and the dark surface tokens), and the manuals that have their own social image
# (images/og-<manual name, lower case, dashes>.png)
[BrandSettings]
ThemeColor=#f26a21
ThemeColorDark=#1a1f29
ManualImages[]
ManualImages[]=technical-manual
ManualImages[]=user-manual

# The recent changes (the view doc/recent, classes/expdocrecent.php) and the front page's link to them
[RecentSettings]
# The view's address: its URL alias (migrations/20261104100800_doc_recent.yml), from the site's root
Path=recent
# The classes the list takes: the pages, and the historical copies (shown as "moved to history")
Classes[]
Classes[]=exp_doc_page
Classes[]=exp_doc_section
Classes[]=exp_doc_tutorial
Classes[]=exp_doc_faq
Classes[]=exp_doc_extension
Classes[]=exp_doc_historical
HistoryClasses[]
HistoryClasses[]=exp_doc_historical
# Entries per page: the choices, and the default
Limits[]
Limits[]=20
Limits[]=50
Limits[]=100
DefaultLimit=20
# The Atom feed's entries
FeedLimit=30
# Characters of the body shown below each entry
ExcerptLength=220
# The contributors of the filter: the Contributors folder's exp_doc_contributor objects, by name, at most this many
ContributorFolderRemoteID=exp-doc-contributors
ContributorLimit=500

# The Platform container (the Confluence spaces, made by the import from display/): Modern draws a landing page for it
[PlatformSettings]
RemoteID=staticimport-doc-html-e4fd3481c5e8112931e161ebbc5af0ff
# How many recently changed pages of the platform the landing lists
RecentLimit=8

# Readers' comments on the pages (Modern: parts/doc_page_comments.tpl; the view doc/comment, classes/expdoccomment.php).
# A new comment is held and hidden by the kernel's review hold (settings/siteaccess/site/content.ini.append.php) until
# a moderator releases it in Dashboard > Recent content.
[CommentSettings]
# The class of the comments, and the page classes that take them
Class=comment
PageClasses[]
PageClasses[]=exp_doc_page
PageClasses[]=exp_doc_section
PageClasses[]=exp_doc_tutorial
PageClasses[]=exp_doc_faq
PageClasses[]=exp_doc_extension
# At most RateLimit comments from one address per RateWindow seconds
RateLimit=5
RateWindow=600
# The longest name, subject and message (characters)
NameLength=100
SubjectLength=150
MessageLength=5000
# The notice of a comment that waits: to Recipient (empty: [DocSettings] FeedbackRecipient, then site.ini
# [MailSettings] AdminEmail), from Sender
Recipient=
Sender=support@se7enx.com
# How deep replies are drawn (deeper ones are listed at the last level)
MaxDepth=6

*/ ?>
