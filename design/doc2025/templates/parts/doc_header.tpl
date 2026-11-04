{* The header of a Classic page, as on the static site: the logo row and the (empty) first-level top menu.
   The header switches (Classic / Modern, the content languages) are one of the allowed modern exceptions and sit
   in their own element after the logo row, so the static markup above them is unchanged. *}
    <div class="topmenu-anchor"></div>
    <div id="topmenu-bg">
	    <div id="logo" class="container_12">

    <div class="grid_3">
        <a href={'/'|ezurl} title="Exponential Platform, CXM &amp; CMS">
            <img src={'images/exponential.png'|ezdesign}
                 alt="" height="45"/>
        </a>
    </div>

    <div class="grid_9">
                <div class="topmenu-design">
	<!-- Top menu content: START -->
	<div id="topmenu-firstlevel-position">
	<ul id="topmenu-firstlevel" class="sf-menu sf-js-enabled sf-shadow">
        </ul>
    </div>
        <!-- Top menu content: END -->
</div>        </div>
</div>    </div>
{include uri='design:exp_doc/switches.tpl'}
