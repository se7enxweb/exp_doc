{* The frame of a Confluence page in the Classic design (the pages of the former documentation center's Confluence
   spaces, fetch exp_doc/confluence_context, the pagelayout's choice): the static site's Atlassian page frame, element
   for element where it shows, filled from the content tree:
   - the header bar: the links menu, the logo, "Spaces" (the Confluence container), "Browse" (the space's page list),
     the sidebar button, the quick search (this site's search), help (the help center) and "Log in";
   - the space's sidebar: its links and heading as the static space had them (exp_doc.ini [ConfluenceSpace_<key>]),
     "Back to the top" (the space's home page), the space search and the page tree (the space's pages, the branch
     down to this page opened; the static page's tree never loaded, it showed "Loading...");
   - the page panel (the page's full view, parts/confluence_page.tpl), the space footer and the Confluence footer.
   The Classic additions stay where every Classic page has them: the header switches right after the header bar, the
   cookie banner and the toolbar after the frame (the pagelayout). No script: the frame's menus are links and
   <details>, the sidebar and the page scroll on their own as in the static frame (stylesheets/doc2025-confluence.css).
   Parameters: context (the fetch's result), node_id. *}
{def $cf = $context
     $cf_space = $cf.space
     $cf_key = $cf.key
     $cf_section = concat( 'ConfluenceSpace_', $cf_key )
     $cf_has_section = and( $cf_key, ezini_hasvariable( $cf_section, 'Heading', 'exp_doc.ini' ) )
     $cf_home = $cf.home
     $cf_container = fetch( 'content', 'object', hash( 'remote_id', ezini( 'PlatformSettings', 'RemoteID', 'exp_doc.ini' ) ) )
     $cf_links = cond( and( $cf_key, ezini_hasvariable( $cf_section, 'Links', 'exp_doc.ini' ) ), ezini( $cf_section, 'Links', 'exp_doc.ini' ), array() )
     $cf_heading = cond( $cf_has_section, ezini( $cf_section, 'Heading', 'exp_doc.ini' ), $cf.name )
     $cf_search_name = cond( and( $cf_key, ezini_hasvariable( $cf_section, 'SearchName', 'exp_doc.ini' ) ), ezini( $cf_section, 'SearchName', 'exp_doc.ini' ), $cf.name )}
<div id="full-height-container">
<header id="header" role="banner">
    <nav class="aui-header" role="navigation" aria-label="{'Documentation'|i18n( 'design/doc2025' )}"><div class="aui-header-inner">
        <div class="aui-header-before"><a class="app-switcher-trigger" href={'/'|ezurl} title="{'Documentation front page'|i18n( 'design/doc2025' )}"><span class="aui-icon aui-icon-small aui-iconfont-appswitcher">{'Linked Applications'|i18n( 'design/doc2025' )}</span></a></div>
        <div class="aui-header-primary">
            <h1 id="logo" class="aui-header-logo aui-header-logo-custom"><a href={'/'|ezurl}><img src={'images/confluence/site-logo.png'|ezdesign} alt="eZ Documentation" width="24" height="24" /></a></h1>
            <ul class="aui-nav">
                <li><a id="space-directory-link" href={cond( $cf_container, $cf_container.main_node.url_alias, '/' )|ezurl} class="aui-nav-imagelink" title="{'Spaces'|i18n( 'design/doc2025' )}"><span>{'Spaces'|i18n( 'design/doc2025' )}</span></a></li>
                <li id="browseMenu"><a id="browse-menu-link" class="aui-nav-link" href={concat( 'content/view/sitemap/', cond( $cf_space, $cf_space.node_id, $node_id ) )|ezurl} title="{'Browse'|i18n( 'design/doc2025' )}"><span class="browse">{'Browse'|i18n( 'design/doc2025' )}</span></a></li>
            </ul>
        </div>
        <div class="aui-header-secondary">
            <ul class="aui-nav">
                <li><a id="doctheme-anchor" href="#splitter-sidebar" class="aui-nav-imagelink" title="{'Page tree'|i18n( 'design/doc2025' )}"><span id="splitter-button"></span></a></li>
                <li><form id="quick-search" class="aui-quicksearch header-quicksearch" method="get" action={'content/search'|ezurl} role="search">
                    <fieldset>
                        <label for="quick-search-query" class="assistive">{'Quick Search'|i18n( 'design/doc2025' )}</label>
                        <input id="quick-search-query" class="text app-search search quick-search-query" type="text" accesskey="q" autocomplete="off" name="SearchText" />
                        <input id="quick-search-submit" class="quick-search-submit" type="submit" value="{'Search'|i18n( 'design/doc2025' )}" />
                    </fieldset>
                </form></li>
                <li><a id="help-menu-link" class="aui-nav-link" href={'exphelp/dashboard'|ezurl} title="{'Help'|i18n( 'design/doc2025' )}"><span class="aui-icon aui-icon-small aui-iconfont-help">{'Help'|i18n( 'design/doc2025' )}</span></a></li>
                <li><a id="login-link" class="user-item login-link" href={'user/login'|ezurl}>{'Log in'|i18n( 'design/doc2025' )}</a></li>
            </ul>
        </div>
    </div></nav>
</header>
{include uri='design:exp_doc/switches.tpl'}
<div id="splitter">
    <div id="splitter-sidebar">
        <p>&nbsp;</p>
{if $cf_links|count}
        <h4>&nbsp; {ezini( 'ConfluenceFrame', 'LinksHeading', 'exp_doc.ini' )|wash}</h4>
        <p>{foreach $cf_links as $cf_link}{def $cf_parts = $cf_link|explode( ';' )
                 $cf_target = cond( $cf_parts[0]|begins_with( 'http' ), false(), fetch( 'exp_doc', 'node_by_source', hash( 'path', $cf_parts[0] ) ) )}<span class="exp-doc-cf-bullet" aria-hidden="true">&bull;</span>&nbsp;&nbsp;{if $cf_parts[0]|begins_with( 'http' )}<a href="{$cf_parts[0]|wash}" class="external-link" rel="nofollow">{else}<a href={cond( $cf_target, $cf_target.url_alias, '/' )|ezurl}>{/if}{$cf_parts|extract_right( dec( $cf_parts|count ) )|implode( ';' )|wash}</a><br />{undef $cf_parts $cf_target}{/foreach}</p>
        <hr />
{/if}
        <h4>&nbsp; {$cf_heading|wash}</h4>
        <p>&nbsp;&nbsp;<sup><a href={cond( $cf_home, $cf_home.url_alias, cond( $cf_space, $cf_space.url_alias, '/' ) )|ezurl}>{'Back to the top'|i18n( 'design/doc2025' )}</a></sup><br /></p>
        <div class="search-macro search-macro-medium">
            <form class="aui" method="get" action={'content/search'|ezurl} role="search">
                <fieldset class="search-macro-fields">
                    <div class="search-macro-query">
                        <input class="text" type="text" name="SearchText" autocomplete="off" placeholder="{'search %name docs'|i18n( 'design/doc2025', '', hash( '%name', $cf_search_name ) )|wash}" aria-label="{'search %name docs'|i18n( 'design/doc2025', '', hash( '%name', $cf_search_name ) )|wash}" />
                    </div>
                    <button type="submit" class="search-macro-button aui-button"><span class="aui-icon aui-icon-small aui-iconfont-search">{'Search'|i18n( 'design/doc2025' )}</span></button>
{if $cf_space}
                    <input type="hidden" name="SubTreeArray[]" value="{$cf_space.node_id}" />
{/if}
                </fieldset>
            </form>
        </div>
        <p></p>
        <nav class="plugin_pagetree" aria-label="{'Page tree'|i18n( 'design/doc2025' )}">
{if $cf.tree|count}
            <ul class="plugin_pagetree_children_list plugin_pagetree_children_list_noleftspace">
{include uri='design:parts/confluence_tree.tpl' items=$cf.tree}
            </ul>
{/if}
        </nav>
    </div>
    <div class="vsplitbar" aria-hidden="true"></div>
    <div id="splitter-content">
{$module_result.content}
        <div id="theme-footer">
            <p>&copy; 1999-2016 <a href="http://ez.no/" class="external-link" rel="nofollow">eZ Systems AS</a> {'and others'|i18n( 'design/doc2025' )}</p>
        </div>
    </div>
</div>
</div>
<div id="footer" role="contentinfo">
    <section class="footer-body">
        <p class="license license-opensource">
            Powered by a free <b>Atlassian Confluence Open Source Project License</b> granted to Exponential. <a href="http://www.atlassian.com/c/conf/11461">Evaluate Confluence today</a>.<br />
        </p>
        <ul id="poweredby">
            <li class="noprint">Powered by <a href="http://www.atlassian.com/software/confluence" class="hover-footer-link">Atlassian Confluence</a> <span id="footer-build-information">5.8.5</span>, <a href="http://www.atlassian.com/software/confluence" class="hover-footer-link">Team Collaboration Software</a></li>
            <li class="noprint"><a href="https://jira.atlassian.com/browse/CONF" class="hover-footer-link">Report a bug</a></li>
            <li class="noprint"><a href="http://www.atlassian.com/about/connected.jsp?s_kwcid=Confluence-stayintouch" class="hover-footer-link">Atlassian News</a></li>
        </ul>
    </section>
</div>
{undef $cf $cf_space $cf_key $cf_section $cf_has_section $cf_home $cf_container $cf_links $cf_heading $cf_search_name}
