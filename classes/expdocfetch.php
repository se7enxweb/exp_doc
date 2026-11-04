<?php
/**
 * The template fetch functions of exp_doc (modules/exp_doc/function_definition.php).
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

class expDocFetch
{
    /** @var array path => node id (0: none), for the request */
    protected static $cache = array();

    /**
     * The node imported from a static file: the main node of the object whose source_path attribute equals $path
     * (relative to the static repository's root, without a leading slash). Only the published version counts.
     *
     * @param string $path
     * @return array array( 'result' => eZContentObjectTreeNode|false )
     */
    public static function nodeBySource( $path )
    {
        $path = ltrim( trim( (string)$path ), '/' );
        if ( $path === '' )
        {
            return array( 'result' => false );
        }
        if ( !array_key_exists( $path, self::$cache ) )
        {
            self::$cache[$path] = self::lookup( $path );
        }
        $nodeID = self::$cache[$path];
        if ( !$nodeID )
        {
            return array( 'result' => false );
        }
        $node = eZContentObjectTreeNode::fetch( $nodeID );
        return array( 'result' => ( $node instanceof eZContentObjectTreeNode && $node->canRead() ) ? $node : false );
    }

    /**
     * The main node id of the published object whose source_path is $path, or 0.
     *
     * @param string $path
     * @return int
     */
    protected static function lookup( $path )
    {
        $classAttributeIDs = array();
        foreach ( eZContentClassAttribute::fetchFilteredList( array( 'identifier' => 'source_path', 'version' => eZContentClass::VERSION_STATUS_DEFINED ) ) as $classAttribute )
        {
            $classAttributeIDs[] = (int)$classAttribute->attribute( 'id' );
        }
        if ( !$classAttributeIDs )
        {
            return 0;
        }
        $attributes = eZPersistentObject::fetchObjectList( eZContentObjectAttribute::definition(), null,
                                                           array( 'contentclassattribute_id' => array( $classAttributeIDs ),
                                                                  'data_text' => $path ),
                                                           null, null, true );
        foreach ( (array)$attributes as $attribute )
        {
            $object = eZContentObject::fetch( $attribute->attribute( 'contentobject_id' ) );
            if ( $object instanceof eZContentObject
                 && (int)$object->attribute( 'current_version' ) === (int)$attribute->attribute( 'version' )
                 && $object->attribute( 'main_node_id' ) )
            {
                return (int)$object->attribute( 'main_node_id' );
            }
        }
        return 0;
    }
}
