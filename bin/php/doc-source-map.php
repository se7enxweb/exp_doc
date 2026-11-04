<?php
/**
 * Writes the source map of the imported documentation: one line per imported page, "<static path> TAB <page URL>",
 * for the Classic design's exactness check (bin/python/doc2025_diff.py).
 *
 * The static path is the page's source_path attribute (the file it was imported from, relative to the static
 * repository); the URL is its main node's address on this site, built with --site-url.
 *
 *   php extension/exp_doc/bin/php/doc-source-map.php --site-url=https://doc.exponential.earth/doc [--output=<file>]
 *
 * @copyright Copyright (C) 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 */

require_once 'autoload.php';

$cli = eZCLI::instance();
$script = eZScript::instance( array( 'description' => 'Writes the static path to page URL map of the imported documentation.',
                                     'use-session' => false, 'use-modules' => false, 'use-extensions' => true ) );
$script->startup();
$options = $script->getOptions( '[site-url:][output:][class:]', '',
                                array( 'site-url' => 'The site address the URLs start with, e.g. https://doc.exponential.earth/doc',
                                       'output' => 'The file to write (default: standard output)',
                                       'class' => 'Comma-separated class identifiers to include (default: every class with a source_path attribute)' ) );
$script->initialize();

$siteUrl = rtrim( (string)$options['site-url'], '/' );
if ( $siteUrl === '' )
{
    $script->shutdown( 1, '--site-url is required' );
}

$classIdentifiers = array();
if ( $options['class'] )
{
    $classIdentifiers = array_filter( array_map( 'trim', explode( ',', $options['class'] ) ) );
}
else
{
    foreach ( eZContentClass::fetchAllClasses( true, false ) as $class )
    {
        foreach ( $class->fetchAttributes() as $attribute )
        {
            if ( $attribute->attribute( 'identifier' ) === 'source_path' )
            {
                $classIdentifiers[] = $class->attribute( 'identifier' );
                break;
            }
        }
    }
}

$handle = $options['output'] ? fopen( $options['output'], 'w' ) : STDOUT;
$count = 0;
$offset = 0;
$limit = 200;
do
{
    $nodes = eZContentObjectTreeNode::subTreeByNodeID( array( 'ClassFilterType' => 'include',
                                                             'ClassFilterArray' => $classIdentifiers,
                                                             'MainNodeOnly' => true,
                                                             'IgnoreVisibility' => true,
                                                             'Limitation' => array(),
                                                             'Offset' => $offset,
                                                             'Limit' => $limit ), 1 );
    $nodes = is_array( $nodes ) ? $nodes : array();
    foreach ( $nodes as $node )
    {
        $dataMap = $node->dataMap();
        if ( !isset( $dataMap['source_path'] ) || !$dataMap['source_path']->hasContent() )
        {
            continue;
        }
        $alias = $node->urlAlias();
        fwrite( $handle, trim( $dataMap['source_path']->toString() ) . "\t" . $siteUrl . '/' . ltrim( $alias, '/' ) . "\n" );
        $count++;
    }
    $offset += $limit;
    eZContentObject::clearCache();
}
while ( count( $nodes ) === $limit );

if ( $options['output'] )
{
    fclose( $handle );
}
fwrite( STDERR, "PASS $count pages mapped\n" );
$script->shutdown( 0 );
