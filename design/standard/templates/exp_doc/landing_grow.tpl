{* exp_doc/landing_grow: the help center's "Grow from user to developer" band (exphelp/parts/dashboard_grow.tpl, its texts
   and translations in kernel/exphelp) on the front page, right after "Start where you are", in its own help frame.
   The fifth step links the help page on contributing extensions back, which the documentation's help has.
   Styles: exphelp.css (.a4-help-grow*) and the design's .exp-doc-landing-grow; no inline CSS or script.

   Variables: frame_class (optional, more classes of the frame: a4-page in Classic, whose body is not one). *}
<div class="{if and( is_set( $frame_class ), $frame_class )}{$frame_class|wash} {/if}a4-help-frame exp-doc-landing-grow">
    {include uri='design:exphelp/parts/dashboard_grow.tpl' help_grow_extensions_page='help/contribute-extensions-back.md'}
</div>
