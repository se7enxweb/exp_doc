{* The help center's left menu on the documentation site, in both designs (menu.ini [Leftmenu_help]: Help Start,
   Contents, Search the help, Extensions; the report form is off on this site). A plain list in the column where the
   site's page tree or table of contents usually is; the link the page belongs to is marked: a page of the viewer, a
   topic, a manual and the page tree mark Contents, an extension's page marks Extensions, an audience's page marks
   Help Start. *}
{def $help_menu_uri = first_set( $uri_string, '' )|trim( '/' )
     $help_links = ezini( 'Leftmenu_help', 'Links', 'menu.ini' )
     $help_names = hash( 'dashboard',  'Help Start'|i18n( 'kernel/exphelp' ),
                         'contents',   'Contents'|i18n( 'kernel/exphelp' ),
                         'search',     'Search the help'|i18n( 'kernel/exphelp' ),
                         'extensions', 'Extensions'|i18n( 'kernel/exphelp' ),
                         'report',     'Report an error'|i18n( 'kernel/exphelp' ) )
     $help_current = ''}
{if $help_menu_uri|contains( 'exphelp/viewer/ext/' )}{set $help_current = 'exphelp/extensions'}
{elseif or( $help_menu_uri|contains( 'exphelp/viewer' ), $help_menu_uri|contains( 'exphelp/topic' ), $help_menu_uri|contains( 'exphelp/manual' ), $help_menu_uri|contains( 'exphelp/navigation' ), $help_menu_uri|contains( 'exphelp/contents' ) )}{set $help_current = 'exphelp/contents'}
{elseif $help_menu_uri|contains( 'exphelp/search' )}{set $help_current = 'exphelp/search'}
{elseif $help_menu_uri|contains( 'exphelp/extensions' )}{set $help_current = 'exphelp/extensions'}
{else}{set $help_current = 'exphelp/dashboard'}{/if}
<nav class="exp-doc-helpmenu" aria-labelledby="exp-doc-helpmenu-title">
    <h2 id="exp-doc-helpmenu-title" class="exp-doc-helpmenu-title"><a href={'exphelp/dashboard'|ezurl}>{'Help center'|i18n( 'design/exp_doc' )}</a></h2>
    <ul>
{foreach $help_links as $help_key => $help_url}
    {if and( is_set( $help_names[$help_key] ), fetch( 'user', 'has_access_to', hash( 'module', 'exphelp', 'function', 'read' ) ) )}
        {if or( ne( $help_key, 'report' ), fetch( 'user', 'has_access_to', hash( 'module', 'exphelp', 'function', 'report' ) ) )}
        <li><a href={$help_url|ezurl}{if eq( $help_url, $help_current )} aria-current="page"{/if}>{$help_names[$help_key]|wash}</a></li>
        {/if}
    {/if}
{/foreach}
    </ul>
</nav>
{undef $help_menu_uri $help_links $help_names $help_current}
