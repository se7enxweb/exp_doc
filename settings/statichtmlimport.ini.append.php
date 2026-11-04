<?php /* #?ini charset="utf-8"?

# The documentation site's import (--doc-html), as exp_doc sets it up: the static export of the documentation
# (https://exponential.doc.exponential.earth, se7enxweb/exponential.doc.exponential.earth) into the exp_doc_* classes
# below the "Documentation" site root. The rule keys are described in exp_static_html_imports'
# statichtmlimport.ini.append.php; ./console exp:doc:import runs it with these defaults.

[Type_doc-html]
SourceRepository=https://github.com/se7enxweb/exponential.doc.exponential.earth.git
SourceBranch=master
ParentRemoteID=exp_doc_site_root
MediaParentRemoteID=exp-doc-media
ImportUser=graham
Language=eng-US
BatchSize=50
TagParent=0
SectionMap[]
SectionMap[*]=exp_doc
HiddenSection=exp_doc_hidden
MediaSection=exp_doc_media
CreateRedirects=enabled

Suffixes[]
Suffixes[]=html
IndexFiles[]
IndexFiles[]=index.html

# The machinery of the static export, never pages
ExcludePaths[]
ExcludePaths[]=login*.html
ExcludePaths[]=exportword*
ExcludePaths[]=exportword*/**
ExcludePaths[]=null.html
ExcludePaths[]=redirect.html
ExcludePaths[]=aboutconfluencepage.html
ExcludePaths[]=documentation.html
ExcludePaths[]=plugins/**
ExcludePaths[]=s/**
ExcludePaths[]=x/**
ExcludePaths[]=layout/**
ExcludePaths[]=spaces/**
ExcludePaths[]=spacedirectory/**
ExcludePaths[]=spacedirectory.html
ExcludePaths[]=dashboard/**
ExcludePaths[]=dashboard.html
ExcludePaths[]=labels/**
ExcludePaths[]=label/**
ExcludePaths[]=schemadoc*/**
ExcludePaths[]=var/**
ExcludePaths[]=design/**
ExcludePaths[]=extension/**
ExcludePaths[]=download/**
ExcludePaths[]=content/**
ExcludePaths[]=visual/**
# Confluence's own views of a page (its history, versions, info, attachments, page lists, blog and update lists)
# are no documentation; pages/viewpage<id>.html is a page by its id (a copy, or a page of its own, by its breadcrumb)
ExcludePaths[]=pages/diffpagesbyversion*
ExcludePaths[]=pages/viewpreviousversions*
ExcludePaths[]=pages/viewinfo*
ExcludePaths[]=pages/viewpageattachments*
ExcludePaths[]=pages/listpages-*
ExcludePaths[]=pages/viewrecentblogposts*
ExcludePaths[]=pages/recentlyupdated*

# The export's error pages are no pages; its redirect stubs (a meta refresh) become redirects
NotFoundTitlePatterns[]
NotFoundTitlePatterns[]=/^404\b/
NotFoundTitlePatterns[]=/^Not Found$/i
NotFoundTitlePatterns[]=/^Page Not Found\b/i
# the old site's own error pages ("kernel (1) / Error - Doc" access denied, "kernel (20) / Error - Doc" no module)
NotFoundTitlePatterns[]=/^kernel \(\d+\) \/ Error\b/
ExcludePaths[]=favicon.html

# Files with a page suffix that are no HTML (the export saved fonts and gzip files as .html) are never pages
SkipBinaryPages=enabled
# The viewer pages of one image or file (Technical-manual/<version>/Images/...: one <img>, no text) are that image:
# it becomes an exp_doc_image in the Media folder and the viewer's old path redirects to it
AssetPages=enabled
AssetPageMaxText=0

# Confluence's spaces (display/<SPACE>/<page>.html) are flat folders: a page's parent is the nearest page of its
# breadcrumb (#breadcrumbs: the space, then the ancestors). A space without a page of its own becomes a section
# named by the breadcrumb's first item (the space's name), and all spaces go into one section "Confluence spaces"
BreadcrumbSelector=#breadcrumbs a
BreadcrumbPaths[]
BreadcrumbPaths[]=display/**
BreadcrumbPaths[]=pages/**
GroupFolders[]
GroupFolders[]=display
GroupFolders[]=display/*
GroupTitleSelector=#breadcrumbs li.first a
GroupTitles[]
GroupTitles[display]=Confluence spaces
GroupClass=exp_doc_section

# Copies of pages: view-parameter variants, the Confluence page-id copies and the hidden mirror. Each becomes a
# redirect to the page with the same content; one with content of its own is imported (hidden when below doc_hidden)
DuplicatePatterns[]
DuplicatePatterns[]=#\(language\)#
DuplicatePatterns[]=#^pages/#
DuplicatePatterns[]=#^doc_hidden/#
DuplicatePatterns[]=#^doc_inside_admin/#

HiddenPaths[]
HiddenPaths[]=doc_hidden.html
HiddenPaths[]=doc_hidden/**
HiddenPaths[]=doc_inside_admin.html
HiddenPaths[]=doc_inside_admin/**

# The two page layouts of the export: the documentation site's own (.area-docmain-normal) and Confluence's
# (#main-content); the first selector that matches wins
TitleSelector=#title-text, .attribute-heading h1, h1
BodySelector=#main-content, .area-docmain-normal .content-view-full, #main, body
OriginalSelector=
TitleSuffixPatterns[]
TitleSuffixPatterns[]=/\s*[-|]\s*(Documentation|Exponential.*)$/u
MetaSelectors[]
MetaSelectors[byline]=.page-metadata, .attribute-byline
MetaSelectors[labels]=.label-list .aui-label a, .labels a.label
PageIdPatterns[]
PageIdPatterns[]=/pageId=(\d+)/

RemoveSelectors[]
RemoveSelectors[]=.attribute-byline
RemoveSelectors[]=.pageinfo
RemoveSelectors[]=.page-metadata
RemoveSelectors[]=.copytoclipboard
RemoveSelectors[]=#likes-and-labels-container
RemoveSelectors[]=.search-macro
RemoveSelectors[]=#comments-section
RemoveSelectors[]=.class-comment
RemoveSelectors[]=.pageSectionHeader
UnwrapSelectors[]
UnwrapSelectors[]=.template-object
UnwrapSelectors[]=.template-module
UnwrapSelectors[]=.attribute-long
UnwrapSelectors[]=.attribute-body
PanelSelectors[]
PanelSelectors[info]=.confluence-information-macro-information
PanelSelectors[note]=.confluence-information-macro-note
PanelSelectors[warning]=.confluence-information-macro-warning
PanelSelectors[tip]=.confluence-information-macro-tip
# The documentation's own rendered code (<pre class="wordwrap"> with one <span class="line"> per line) stays a literal
# with its class, so the Classic design draws the same markup; Confluence's code macros become doc_code
LiteralSelectors[]
LiteralSelectors[]=pre.wordwrap
CodeSelectors[]
CodeSelectors[]=.codeContent pre
CodeSelectors[]=pre.syntaxhighlighter-pre
EmbedAlignSelectors[]
EmbedAlignSelectors[center]=.object-center
EmbedAlignSelectors[left]=.object-left
EmbedAlignSelectors[right]=.object-right
CodeLineSelector=span.line
CodeLanguagePatterns[]
CodeLanguagePatterns[]=/brush:\s*([a-z0-9+#]+)/i
CodeLanguagePatterns[]=/language-([a-z0-9+#]+)/i
CodeLanguagePatterns[]=/\b(php|ini|html|xml|bash|sql|css|javascript|js|yaml|twig|tpl)\b/i
ExpandSelectors[]
ExpandSelectors[]=.expand-container
ExpandTitleSelector=.expand-control-text
ChildrenSelectors[]
ChildrenSelectors[]=.content-view-children
ChildrenSelectors[]=.childpages-macro

AssetSuffixes[]
AssetSuffixes[]=png
AssetSuffixes[]=jpg
AssetSuffixes[]=jpeg
AssetSuffixes[]=gif
AssetSuffixes[]=svg
AssetSuffixes[]=pdf
AssetSuffixes[]=zip

# The version pages of the export were renamed (Technical-manual/4.html is the page of the folder 4.7/): such a page is
# the parent of the folder its links point into most, and a "Table of contents" heading becomes the version
FolderPagePatterns[]
FolderPagePatterns[]=Exponential/*/[0-9]*.html
GenericTitles[]
GenericTitles[]=Table of contents

# The byline box of every page ("Written by: A (14/09/2010 10:14 am)", "Last updated by: B (...)", "Maintainers: C, D")
# leaves the body: its people become contributor objects (one per name, in the Contributors folder) and the page
# relates to them (written_by, last_updated_by, maintainers) with the dates in written_at and last_updated_at.
# The dates are read in the source's timezone, assumed to be Europe/Oslo (the documentation site was run from Norway;
# the export carries no timezone of its own).
BylineSelectors[]
BylineSelectors[]=.pageinfo
BylineFields[]
BylineFields[written]=Written by
BylineFields[updated]=Last updated by
BylineFields[maintainers]=Maintainers
BylineListFields[]
BylineListFields[]=maintainers
BylineDateFormats[]
BylineDateFormats[]=d/m/Y g:i a
BylineDateFormats[]=M d, Y H:i
BylineDateFormats[]=M d, Y
BylineTimezone=Europe/Oslo
# Confluence's byline is a sentence (li.page-metadata-modification-info), in four variants. The role mapping:
# "Created by A" is written_by (A), "last modified by B on <date>" is last_updated_by (B) and last_updated_at;
# "last modified on <date>" with no name, and "Created and last modified by A", credit the change to A; "Created by A on
# <date>" (never changed since) is written_at. A date link whose title is a fuller date ("May 27, 2014 07:44") counts
# with that one.
BylineSentenceSelectors[]
BylineSentenceSelectors[]=.page-metadata-modification-info
BylineSentences[]
BylineSentences[]=/^Created and last modified by (?<written>.+?) on (?<updated_at>.+)$/u
BylineSentences[]=/^Created by (?<written>.+?), last modified by (?<updated>.+?) on (?<updated_at>.+)$/u
BylineSentences[]=/^Created by (?<written>.+?), last modified on (?<updated_at>.+)$/u
BylineSentences[]=/^Created by (?<written>.+?) on (?<written_at>.+)$/u
# The authors of the readers' comments (the old manual pages' and Confluence's) are contributors of the page too
BylineCommentAuthorSelectors[]
BylineCommentAuthorSelectors[]=#comments-content p.author
BylineCommentAuthorSelectors[]=.comment-header .author
ContributorClass=exp_doc_contributor
ContributorNameAttribute=name
ContributorParentRemoteID=exp-doc-contributors
ContributorSection=exp_doc

# The front page of the export (index.html) is the content of the Documentation site's root node itself, not a page
# of its own; its old path redirects to the root. Exponential.html stays the "Exponential" section.
RootPage=index.html

# The site-wide default meta description is no description of a page: its first paragraph is
IgnoreDescriptions[]
IgnoreDescriptions[]=Exponential Documentation

# The status of each manual version (exp_doc_version/status, the badge on the start page): the 6 line is current;
# 3.x, 4.x and the 5 era are end of life (none is verified as maintained)
VersionStatus[]
VersionStatus[6*]=current
VersionStatus[5*]=EOL
VersionStatus[4*]=EOL
VersionStatus[3*]=EOL
AttributeMap[exp_doc_version/status]=version_status
AttributeMap[folder/description]=body

# Which class a page becomes; the first match wins
ClassRules[]
ClassRules[]=Exponential/Technical-manual.html;exp_doc_manual
ClassRules[]=Exponential/User-manual.html;exp_doc_manual
ClassRules[]=Exponential/Technical-manual/[0-9]*.html;exp_doc_version
ClassRules[]=Exponential/User-manual/[0-9]*.html;exp_doc_version
ClassRules[]=FAQ.html;exp_doc_faq
ClassRules[]=FAQ/*.html;exp_doc_faq_question
ClassRules[]=Tutorials.html;exp_doc_section
ClassRules[]=Tutorials/*.html;exp_doc_tutorial
ClassRules[]=Tutorials/**;exp_doc_tutorial_step
ClassRules[]=Extensions/*/*.html;exp_doc_extension
ClassRules[]=*.html;exp_doc_section
ClassRules[]=*/*.html;exp_doc_section
DefaultClass=exp_doc_page

# The page fields each attribute takes (an attribute a class does not have is left out)
AttributeMap[]
AttributeMap[*/title]=title
AttributeMap[*/short_title]=short_title
AttributeMap[*/body]=body
AttributeMap[*/original_html]=original_html
AttributeMap[*/source_path]=source_path
AttributeMap[*/source_page_id]=page_id
AttributeMap[*/written_by]=written_by
AttributeMap[*/written_at]=written_at
AttributeMap[*/last_updated_by]=last_updated_by
AttributeMap[*/last_updated_at]=last_updated_at
AttributeMap[*/maintainers]=maintainers
# every person the page names, each once (writer, updater, maintainers, comment authors): the "Contributors" list
AttributeMap[*/contributors]=contributors
AttributeMap[*/labels]=labels_tags
AttributeMap[*/metadata]=metadata_xml
AttributeMap[*/import_hash]=import_hash
AttributeMap[exp_doc_version/version]=version
AttributeMap[exp_doc_faq_question/question]=title
AttributeMap[exp_doc_faq_question/answer]=body
AttributeMap[exp_doc_extension/extension_name]=title

AssetClassRules[]
AssetClassRules[]=*.pdf;exp_doc_file
AssetClassRules[]=*.zip;exp_doc_file
AssetClassRules[]=**;exp_doc_image
AssetAttributeMap[]
AssetAttributeMap[exp_doc_image/name]=title
AssetAttributeMap[exp_doc_image/image]=file
AssetAttributeMap[exp_doc_image/alt]=alt
AssetAttributeMap[exp_doc_image/source_path]=source_path
AssetAttributeMap[exp_doc_file/name]=title
AssetAttributeMap[exp_doc_file/file]=file
AssetAttributeMap[exp_doc_file/source_path]=source_path


# The readers' comments of the old manual pages (#comments-content: one <li> per comment, replies in a nested <ul>)
# become exp_doc_comment objects below their page, replies below the comment they answer
CommentsSelector=#comments-content
CommentClass=exp_doc_comment
AttributeMap[exp_doc_comment/title]=title
AttributeMap[exp_doc_comment/author]=author
AttributeMap[exp_doc_comment/created]=modified
AttributeMap[exp_doc_comment/text]=body
AttributeMap[exp_doc_comment/source_path]=source_path
AttributeMap[exp_doc_comment/import_hash]=import_hash

*/ ?>
