{* The mail of collected information (the "Was this page helpful?" form and any other information collector) in the
   kernel's mail design: an HTML part and a plain-text part, through content/collectedinfomail_body.tpl and
   design:mail/layout.tpl. Here because an active extension (enhancedezbinaryfile) carries a plain-text
   design/standard copy of this template that would otherwise win over the kernel's. *}
{set-block scope=root variable=subject}{"Collected information from %1"|i18n("design/standard/content/edit",,array($collection.object.name))}{/set-block}
{include uri='design:content/collectedinfomail_body.tpl' collection=$collection ci_gui=true()
         ci_title="Collected information from %1"|i18n("design/standard/content/edit",,array($collection.object.name))
         ci_intro="The following information was collected"|i18n("design/standard/content/edit")}
