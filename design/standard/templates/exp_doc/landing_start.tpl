{* exp_doc/landing_start: the "Start where you are" card of the front page, the short line to the help center's
   audiences. Modern draws it right below the products (parts/doc_landing.tpl); Classic, which has no products list,
   right below the static page's current lists, before its first second-level heading (parts/doc_full.tpl); in both
   the help center's bottom blocks (exp_doc/landing_org.tpl) then leave it out. Styles: exphelp.css (.a4-card,
   .a4-help-section-head) and the design's .exp-doc-landing-start; no inline CSS or script.

   Variables: framed (optional, true: drawn in its own .a4-help-frame, outside the bottom blocks), frame_class
   (optional, more classes of that frame: a4-page in Classic, whose body is not one). *}
{if and( is_set( $framed ), $framed )}<div class="{if and( is_set( $frame_class ), $frame_class )}{$frame_class|wash} {/if}a4-help-frame exp-doc-landing-start">{/if}
    <section class="a4-card exp-doc-landing-org-start" aria-labelledby="exp-doc-org-start">
        <div class="a4-help-section-head">
            <h2 id="exp-doc-org-start"><span class="a4-icon a4-bi-people" aria-hidden="true"></span>{'Start where you are'|i18n( 'kernel/exphelp' )}</h2>
            <p>{'Pick your role to see the pages written for it.'|i18n( 'kernel/exphelp' )}</p>
            <a href={'exphelp/dashboard#help-dash-audiences'|ezurl}>{'Open the help center'|i18n( 'design/exp_doc' )}</a>
        </div>
    </section>
{if and( is_set( $framed ), $framed )}</div>{/if}
