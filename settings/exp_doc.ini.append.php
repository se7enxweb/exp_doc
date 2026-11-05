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
MetaTags[copyright]=Exponential Foundation and 7x
MetaTags[description]=Exponential Documentation
MetaTags[keywords]=Exponential, documentation, manual, reference, 7x
# The caution box above every page (parts/doc_disclaimer.tpl): enabled|disabled
Disclaimer=enabled
# The left menu (parts/doc_menu.tpl): the classes whose node opens a "Table of contents" (a manual version, an
# extension with its versions), the sections that open one too (by their static source path: the static Upgrading
# and Tutorials pages had a table of contents, the other sections the quick links), the classes whose node opens
# the flat "Table of contents" of its steps (a tutorial), and those whose node opens a flat list (the FAQ); a page
# under none of them shows the quick links
TocRootClasses[]
TocRootClasses[]=exp_doc_version
TocRootClasses[]=exp_doc_extension
TocRootSources[]
TocRootSources[]=Exponential/Upgrading.html
TocRootSources[]=Tutorials.html
StepsRootClasses[]
StepsRootClasses[]=exp_doc_tutorial
ListRootClasses[]
ListRootClasses[]=exp_doc_faq
# The classes left out of the flat list and the steps menu: as MenuHideClasses, but the FAQ's questions and the
# tutorial's steps are what those two menus list
ListMenuHideClasses[]
ListMenuHideClasses[]=exp_doc_image
ListMenuHideClasses[]=exp_doc_file
ListMenuHideClasses[]=exp_doc_contributor
ListMenuHideClasses[]=exp_doc_historical
ListMenuHideClasses[]=comment_historical
ListMenuHideClasses[]=comment
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
# the readers' new comments (parts/doc_page_comments.tpl lists them)
MenuHideClasses[]=comment
# Nodes never listed in the menus, by remote id: the Contributors folder (its people have their own pages, linked
# from the bylines)
MenuHideNodeRemoteIDs[]
MenuHideNodeRemoteIDs[]=exp-doc-contributors
# the media folder (images and files of the pages, not pages)
MenuHideNodeRemoteIDs[]=exp-doc-media
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
# The groups of the front page
Groups[]
Groups[]=exponential
Groups[]=platform
Groups[]=extensions
# The groups of every other page with the quick links: the static site's shorter "Exponential" group, no
# "Exponential Platform"
PageGroups[]
PageGroups[]=exponential_page
PageGroups[]=extensions

[Quicklinks_exponential_page]
Heading=Exponential
Links[]
Links[]=Exponential/Technical-manual/6.html;Technical manual (v6.x)
Links[]=Exponential/User-manual/6.html;User manual (v6.x)
Links[]=Exponential/Upgrading.html;Upgrading manual
Links[]=documentation.html;Manual Downloads
Links[]=display/MAIN/ExponentialPlatformDocumentationCenter.html;Symfony Stack (5.x) Manuals
Links[]=Tutorials.html;Tutorials
Links[]=FAQ.html;FAQ

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
# The last box of the front page's Manuals (Modern): the upgrade guides, at this path below the site's root; empty: none
UpgradeGuidesPath=exponential/upgrading
# The products of the front page, in this order: "<path below the site's root>;<name>;<one line>[;<status>]".
# The name is always this one (the owner's product names); the short text and status come from the container node at
# that path once it exists (its short_description, summary or intro, else the description of its Metadata attribute,
# which editors change), until then
# these (plain lines on purpose: the containers carry the products' own texts). A status of [ModernSettings]
# SupportedStatuses[] gets the Supported badge. Each container is the product's landing page ([ProductLandingSettings]).
ProductList[]
ProductList[]=exponential;Exponential;Manuals, tutorials, upgrading and the extensions of Exponential.;current
ProductList[]=platform;Exponential Platform;The documentation of Exponential Platform.;current
ProductList[]=platform/legacy;Exponential Platform Legacy;The documentation of Exponential Platform Legacy.;current
ProductList[]=platform/nexus;Exponential Platform Nexus;The documentation of Exponential Platform Nexus.;current
ProductList[]=platform/dxp;Exponential Platform DXP;The documentation of Exponential Platform DXP.;current
ProductList[]=basic;Exponential Basic;The documentation of Exponential Basic.;current
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
# The front page's "Recent forum activity" (Modern): the newest topics and replies of the Exponential Share forums,
# read by the server from this RSS 2.0 feed (https only) with the kernel commit feed's timeout and cache time
# (exphelp.ini [CommitFeedSettings]); empty: no box. Links are always made on this address's host.
ForumFeedURL=https://share.exponential.earth/rss/feed/all_forums
# How many posts the box lists
ForumFeedLimit=8
# The "See all forum activity" link
ForumURL=https://share.exponential.earth/forums
# Titles left out of the box: shell patterns (* and ?), case-insensitive, matched against the whole title without
# "Re: " (escorts leaves out exactly "escorts", *escort* every title containing it). Empty: everything shows.
ForumFeedExcludeTitles[]

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
# The recent comments (the view doc/comments) and their URL alias (migrations/20261104101100_doc_recent_comments_and_new.yml)
CommentsPath=recent/comments
# The pages added, newest first (the view doc/new), and its URL alias (the same migration)
NewPath=recent/new
# The newest ratings (the view doc/ratings), and its URL alias (migrations/20261104101400_doc_recent_ratings.yml)
RatingsPath=recent/ratings
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

# The Confluence container (/platform/confluence, the spaces of the former documentation center, made by the import
# from display/confluence/): Modern draws the spaces' landing page for it (parts/doc_platform_landing.tpl). Until
# 2026-11-04 this was the Platform container, which is a product landing page now ([ProductLandingSettings]).
[PlatformSettings]
RemoteID=staticimport-doc-html-8565d9ad2d987fe3c2406f986f5f4fbc
# How many recently changed pages of the spaces the landing lists
RecentLimit=8

# The products' landing pages: the container at each path of [ModernSettings] ProductList[] (fetch exp_doc/
# product_landing). Modern draws the whole page (parts/doc_product_landing.tpl: the hero with the product's text, its
# Supported badge and its links, its sections as cards, the related sections, the container's own text, the recently
# changed pages and the family); Classic keeps its page and adds the product's box after the heading (the links, the
# sections and the family, exp_doc/product_*.tpl). The texts are content: the product's short text is the description
# of the container's Metadata attribute, the longer one its body.
[ProductLandingSettings]
# How many of a product's sections show as cards; with more, a link to all of them (the node's sitemap view)
MaxSections=8
# How many recently changed pages the landing lists
RecentLimit=8
# The classes of a container's children that are no section cards: the version containers (the manuals' cards carry
# their versions) and the historical copies
HideSectionClasses[]
HideSectionClasses[]=exp_doc_version
HideSectionClasses[]=exp_doc_historical
HideSectionClasses[]=comment
HideSectionClasses[]=comment_historical
# The guide comparing every distribution (the help center's DISTRIBUTIONS.md), linked from the family box
CompareURL=exphelp/viewer/DISTRIBUTIONS.md#1-the-quick-start-which-one-should-i-choose

# One group per product: [ProductLanding_<its ProductList path, "_" for "/">]
# Links[]=<kind>;<address>: the hero's buttons, in this order. Kinds: install, upgrade, compare, source (GitHub),
#   package (Packagist), website. An address with :// is outside this site, any other a path of it (help center pages
#   included). Every fact behind them was read from the product's own repository (composer.json, README) and the help
#   center's "Distributions of Exponential" on 2026-11-04.
# Related[]=<path below the site's root>: sections elsewhere on the site that belong to the product (its spaces of the
#   former documentation center)
# ShowBody=enabled|disabled: whether the Modern landing shows the container's body (disabled where the body is the
#   static page the container came from, which Classic shows)
[ProductLanding_exponential]
Links[]
Links[]=install;exphelp/viewer/INSTALL.md
Links[]=upgrade;exponential/upgrading
Links[]=source;https://github.com/se7enxweb/exponential
Links[]=package;https://packagist.org/packages/se7enxweb/exponential
Links[]=website;https://exponential.earth
Related[]
ShowBody=disabled

[ProductLanding_platform]
Links[]
Links[]=compare;exphelp/viewer/DISTRIBUTIONS.md#2-all-distributions-at-a-glance
Links[]=upgrade;exphelp/viewer/DISTRIBUTIONS.md#10-moving-between-distributions
Links[]=source;https://github.com/se7enxweb
Links[]=website;https://platform.exponential.earth
Related[]
ShowBody=enabled

[ProductLanding_platform_legacy]
Links[]
Links[]=install;exphelp/viewer/DISTRIBUTIONS.md#4-exponential-platform-legacy
Links[]=upgrade;exphelp/viewer/DISTRIBUTIONS.md#10-moving-between-distributions
Links[]=source;https://github.com/se7enxweb/exponential-platform-legacy
Links[]=package;https://packagist.org/packages/se7enxweb/exponential-platform-legacy
Links[]=website;https://platform.exponential.earth
Related[]
Related[]=platform/confluence/ezp
Related[]=platform/confluence/ezp51
ShowBody=enabled

[ProductLanding_platform_nexus]
Links[]
Links[]=install;exphelp/viewer/DISTRIBUTIONS.md#5-exponential-platform-nexus
Links[]=upgrade;exphelp/viewer/DISTRIBUTIONS.md#10-moving-between-distributions
Links[]=source;https://github.com/se7enxweb/exponential-platform-nexus
Links[]=package;https://packagist.org/packages/se7enxweb/exponential-platform-nexus
Links[]=website;https://platform.exponential.earth
Related[]
ShowBody=enabled

[ProductLanding_platform_dxp]
Links[]
Links[]=install;exphelp/viewer/DISTRIBUTIONS.md#6-exponential-platform-dxp
Links[]=upgrade;exphelp/viewer/DISTRIBUTIONS.md#10-moving-between-distributions
Links[]=source;https://github.com/se7enxweb/exponential-platform-dxp-skeleton
Links[]=package;https://packagist.org/packages/se7enxweb/exponential-platform-dxp-skeleton
Links[]=website;https://platform.exponential.earth
Related[]
Related[]=platform/confluence/developer
Related[]=platform/confluence/techdoc
Related[]=platform/confluence/userguide
Related[]=platform/confluence/user
ShowBody=enabled

[ProductLanding_basic]
Links[]
Links[]=install;https://github.com/se7enxweb/exponentialbasic#installation-via-composer--packagist
Links[]=compare;exphelp/viewer/DISTRIBUTIONS.md#exponential-basic
Links[]=source;https://github.com/se7enxweb/exponentialbasic
Links[]=package;https://packagist.org/packages/se7enxweb/exponentialbasic
Links[]=website;https://basic.exponential.earth
Related[]
ShowBody=enabled

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
# The notice's "Release or delete" button: the administration's Recent content, held items only, below this
# installation's address (an absolute https address here replaces it)
HeldPath=admin/moderation/recent/(held)/yes
# How deep the readers' replies are drawn (the historical comments are drawn to any depth)
MaxDepth=6
# From this level on, a phone keeps the indent of the level above and a historical reply says whom it answers
IndentDepth=4

*/ ?>
