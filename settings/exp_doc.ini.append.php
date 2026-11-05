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
# The views without the caution box (the start of the address below the site's root), as on the static site
DisclaimerHideViews[]
DisclaimerHideViews[]=content/advancedsearch
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
# The pages that draw the static site's empty comments block ("Comments", "There are no comments.", "New comment")
# when they have no comments (parts/doc_comments.tpl): the classes, and the starts of their static source paths (the
# manuals' pages had it, the version landings, FAQ, tutorials, extensions and Confluence pages did not)
EmptyCommentsClasses[]
EmptyCommentsClasses[]=exp_doc_page
EmptyCommentsClasses[]=exp_doc_section
EmptyCommentsPrefixes[]
EmptyCommentsPrefixes[]=Exponential/
EmptyCommentsPrefixes[]=doc_hidden/Exponential/
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
# Pages never listed in the menus, by name (exactly, or with the suffix the import adds to a taken name: "Comments
# (11403666)"): the old site's view of one comment was a page of its own, headed "Comments"; the import made 88 of
# them, which the old site's menus never listed (the comment itself is below its page as comment_historical)
MenuHideNames[]
MenuHideNames[]=Comments
# The social links of the footer: SocialLinks[<label>]=<address>
SocialLinks[]
SocialLinks[YouTube]=https://www.youtube.com/@ExponentialCMSInsights
SocialLinks[Linkedin]=http://www.Linkedin.com/groups?gid=2759&trk=myg_ugrp_ovr
SocialLinks[Instagram]=https://www.Instagram.com/se7enxweb
SocialLinks[Facebook]=http://facebook.exponential.earth
SocialLinks[BlueSky]=https://bsky.app/profile/exponentialcms.bsky.social
SocialLinks[X]=https://twitter.com/se7enxweb
# The class of a social link where the static footer's was not the label (class="youtube" on the YouTube link):
# SocialClasses[<label>]=<class>
SocialClasses[]
SocialClasses[YouTube]=youtube

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
Links[]=Exponential/Technical-manual/6.x/Reference.html;TM : Reference (v6.x)
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
# The page of every product (below the site's root; [PageDisplaySettings] draws the list on it): the front page links
# to it when it shows fewer products than ProductList[]
ProductsPath=products
# The products the front page (Modern) shows, their ProductList paths, in ProductList order; the others are on the
# page of every product (ProductsPath), which the front page links to. Empty: every product.
FrontProductList[]
FrontProductList[]=exponential
FrontProductList[]=platform/dxp
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
# "Was this page helpful?" under every page (parts/doc_feedback.tpl): enabled or disabled
Feedback=enabled
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

# The Confluence pages in the Classic design (fetch exp_doc/confluence_context, parts/confluence_*.tpl): the pages below
# the Confluence container and the pages imported from a [ClassicSettings] ConfluencePrefixes[] path show in the static
# site's Atlassian frame (its header, the space's sidebar with the page tree, the breadcrumbs, the byline, the labels,
# the comments and the Confluence footer), filled from the content tree.
[ConfluenceFrame]
# The classes of a page's attachments (its related objects of these classes, listed in the page's "..." menu)
AttachmentClasses[]
AttachmentClasses[]=exp_doc_image
AttachmentClasses[]=exp_doc_file
# The heading of the sidebar's first block of links, on spaces with links ([ConfluenceSpace_<key>] Links[])
LinksHeading=General

# A space's sidebar as the static space had it ([ConfluenceSpace_<space key>], the key is the space's short title):
# Heading: the heading above "Back to the top" (default: the space's name); SearchName: the name in the search box's
# placeholder "search <name> docs" (default: the space's name); Links[]=<address or static file>;<label>: the links of
# the first block (a static file names the page imported from it)
[ConfluenceSpace_DEVELOPER]
Heading=Developer documentation
Links[]
Links[]=http://ez.no/;eZ Systems Website
Links[]=display/USER.html;Editor documentation

[ConfluenceSpace_USER]
Heading=Editor documentation
SearchName=Editor
Links[]
Links[]=http://ez.no/;eZ Systems Website
Links[]=display/DEVELOPER/Documentation.html;Developer documentation

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
ShowBody=enabled

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

# "Choosing a product" on the front page (exp_doc/landing_choose.tpl): right before the products in Modern, and in
# Classic, which has no products list, at the same place (before "Start where you are"). The products come in the
# order of [ModernSettings] ProductList[], with its names and paths; a product shows when it has a [ChooseProduct_<its
# path, "_" for "/">] group. The texts are English settings that editors can correct without a code change; the
# template runs every one of them through the translation (context design/exp_doc), so a changed text shows in English
# until its catalogue entry is changed too. Every fact was read from the product's own repository (composer.json,
# README) and the help center's "Distributions of Exponential" (DISTRIBUTIONS.md) on 2026-11-05; never add a feature
# that those do not state.
[ChooseSettings]
# enabled or disabled
Enabled=enabled
# The recommended product (its ProductList path): its card is marked, and the recommendation's buttons go to the
# install link of its [ProductLanding_<path>] Links[] and to its landing page
Recommended=exponential
# "How to choose": <ProductList path of the product>;<the need it answers>, in this order
Needs[]
Needs[]=exponential;You want the most complete CMS with the best editor experience: many sites and languages, a shop, workflows, Exponential Layouts and a built-in help center
Needs[]=platform/legacy;You build on Symfony and need the Exponential 6 kernel and its administration inside
Needs[]=platform/nexus;You want a finished Symfony website with Exponential Layouts and demo content
Needs[]=platform/dxp;You want a Symfony-only stack, without the Exponential 6 kernel
Needs[]=basic;You want a very small site for learning or personal use
# The page of every choice (below the site's root; [PageDisplaySettings] draws the whole box on it): the front page
# links to it when it shows fewer products than there are
ChoosePath=choose
# The products "Choosing a product" shows on the front page (both designs; their ProductList paths, in ProductList
# order) with their lines of "How to choose"; the others are on the page of every choice (ChoosePath), which the box
# links to. Empty: every product.
FrontProducts[]
FrontProducts[]=exponential
FrontProducts[]=platform/dxp

# The pages that draw one of the front page's lists in full, by the remote id of their object:
# Display[<remote id>]=<list>. products: every product of [ModernSettings] ProductList[] (exp_doc/landing_products.tpl);
# choose: "Choosing a product" with every product (exp_doc/landing_choose.tpl). Both designs draw the page's own title
# and text first, then the list. The pages are content of their own (not imported), so editors change their texts.
[PageDisplaySettings]
Display[]
Display[exp-doc-page-products]=products
Display[exp-doc-page-choose]=choose

# One group per product, every key one short text: What (what it is), BestFor, Stack (kernel and framework), Admin
# (editing and administration), Features (the key features), PHP (the PHP versions it supports), Learning (what there
# is to learn)
[ChooseProduct_exponential]
What=The complete content management system and application framework, maintained by 7x, and the line this help center documents
BestFor=Structured content, several sites or several languages from one installation; agencies, hosting providers and developers who build without Symfony
Stack=The Exponential 6 kernel in plain PHP, no Symfony; SQLite, MySQL, MariaDB, PostgreSQL, MongoDB or Oracle
Admin=The admin4 administration and the editor siteaccess, in more than 150 languages, with the help center built in
Features=Customizable content model, versions and translations, roles and policies, multisite, a shop, workflows, REST and GraphQL, Exponential Layouts, Exponential Velocity
PHP=8.0 to 8.5 (7.4 usable without support)
Learning=One stack: PHP and Exponential's templates; installs with two commands on SQLite

[ChooseProduct_platform]
What=The Symfony based family of Exponential: Legacy, Nexus and DXP, the free continuation of eZ Platform and Ibexa Open Source
BestFor=Teams that build on Symfony
Stack=Symfony 3.4, 5.4 or 7.4 by distribution and line; the Exponential 6 kernel in Legacy and the older Nexus lines
Admin=The platform's Symfony administration; Legacy and the older Nexus lines add the Exponential administration
Features=By distribution: Exponential Layouts in Nexus and in Legacy 4.6 and 5.0, none in DXP
PHP=By distribution and line (see each one)
Learning=Symfony, plus Exponential 6 where it is included

[ChooseProduct_platform_legacy]
What=A Symfony platform with a full Exponential 6 inside: two kernels share one database
BestFor=Existing Exponential sites that want Symfony next to them, and teams that need both stacks at once
Stack=Symfony 3.4, 5.4 or 7.4 by line, with the Exponential 6 kernel through the legacy bridge
Admin=The Exponential administration next to the platform's Symfony administration
Features=The Exponential 6 kernel next to the Symfony platform; Exponential Layouts on the 4.6 and 5.0 lines
PHP=By line, 7.4 to 8.5
Learning=Two stacks: Symfony and Exponential 6

[ChooseProduct_platform_nexus]
What=A finished website project: the Symfony platform with the media site, its designs and demo content
BestFor=Agencies and teams that want a complete website with demo content and a page builder in minutes
Stack=Symfony 3.4, 5.4 or 7.4 by line; the Exponential 6 kernel up to the 1.2.0.x line
Admin=The platform's Symfony administration and the Exponential Layouts page builder
Features=Exponential Layouts, Tags, the site API and the media site's demo content
PHP=By line, 8.0 to 8.5 (8.4 or later on 1.3.0.x)
Learning=Symfony, plus Exponential 6 on the older lines; always install with a version

[ChooseProduct_platform_dxp]
What=A Symfony-only digital experience platform, the free continuation of eZ Platform and Ibexa Open Source
BestFor=New Symfony projects, and teams leaving eZ Platform or Ibexa Open Source for current PHP
Stack=Symfony 7.4 LTS (Platform v5), without the Exponential 6 kernel
Admin=The platform's admin UI; no layouts editor, approval workflow or scheduler
Features=REST, GraphQL, the HTTP cache, Solr and core search
PHP=8.3 or later (the 4.6 branch: 7.4 to 8.5)
Learning=Symfony only

[ChooseProduct_basic]
What=The small CMS of the 2.x line, a code base of its own and not a version of Exponential 6
BestFor=Education, personal use and very small sites
Stack=Exponential Basic in PHP, no Symfony; MySQL, PostgreSQL, SQLite or Informix
Admin=A user website and an admin website of its own
Features=A simple personal home page CMS, extendable through settings
PHP=8.2 or later
Learning=Small and easy to understand

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
