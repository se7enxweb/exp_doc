{* The brand part of every documentation page's head, in both designs: the icons generated from the official logo
   (bin/python/doc_brand_images.py: favicon.svg with its own dark colors, favicon.ico, the touch icon, the web app
   manifest), the theme color for light and dark (the accent and the dark surface tokens), and the Open Graph and
   Twitter tags. The social image is the manual's own when one was generated for it (exp_doc.ini [BrandSettings]
   ManualImages[]), else the default. Parameters: title, description, url (absolute), manual (the page's manual
   node, or false). *}
{def $doc_image = 'images/og-default.png'}
{if and( $manual, ezini( 'BrandSettings', 'ManualImages', 'exp_doc.ini' )|contains( $manual.name|downcase|explode( ' ' )|implode( '-' ) ) )}
    {set $doc_image = concat( 'images/og-', $manual.name|downcase|explode( ' ' )|implode( '-' ), '.png' )}
{/if}
    <link rel="icon" href={'images/favicon.ico'|ezdesign} sizes="48x48">
    <link rel="icon" href={'images/favicon.svg'|ezdesign} type="image/svg+xml">
    <link rel="apple-touch-icon" href={'images/apple-touch-icon.png'|ezdesign}>
    <link rel="manifest" href={'images/site.webmanifest'|ezdesign}>
    <meta name="theme-color" content="{ezini( 'BrandSettings', 'ThemeColor', 'exp_doc.ini' )|wash}" media="(prefers-color-scheme: light)">
    <meta name="theme-color" content="{ezini( 'BrandSettings', 'ThemeColorDark', 'exp_doc.ini' )|wash}" media="(prefers-color-scheme: dark)">
    <meta property="og:site_name" content="{ezini( 'ModernSettings', 'SiteName', 'exp_doc.ini' )|wash}">
    <meta property="og:title" content="{$title|wash}">
    <meta property="og:description" content="{$description|wash}">
    <meta property="og:url" content="{$url|wash}">
    <meta property="og:image" content={$doc_image|ezdesign( 'double', 'full' )}>
    <meta property="og:image:type" content="image/png">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="630">
    <meta property="og:image:alt" content="{'Exponential Documentation'|i18n( 'design/exp_doc' )}">
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="{$title|wash}">
    <meta name="twitter:description" content="{$description|wash}">
    <meta name="twitter:image" content={$doc_image|ezdesign( 'double', 'full' )}>
{undef $doc_image}
