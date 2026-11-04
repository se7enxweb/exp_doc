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
     * The version nodes (exp_doc_version) below a manual, newest first by their version number: the attribute
     * version, else the node's name; "x" (6.x) counts as the highest number of its line, and anything that is not a
     * number sorts last. Only nodes the reader may see.
     *
     * @param int $parentNodeID
     * @return array array( 'result' => eZContentObjectTreeNode[] )
     */
    public static function versions( $parentNodeID )
    {
        $nodes = eZContentObjectTreeNode::subTreeByNodeID( array( 'Depth' => 1, 'DepthOperator' => 'eq',
                                                                 'ClassFilterType' => 'include',
                                                                 'ClassFilterArray' => array( 'exp_doc_version' ) ), (int)$parentNodeID );
        $nodes = is_array( $nodes ) ? $nodes : array();
        $keys = array();
        foreach ( $nodes as $i => $node )
        {
            $keys[$i] = self::versionKey( $node );
        }
        uksort( $nodes, function ( $a, $b ) use ( $keys )
        {
            if ( $keys[$a] === null || $keys[$b] === null )
                return ( $keys[$a] === null ) - ( $keys[$b] === null );
            return version_compare( $keys[$b], $keys[$a] );
        } );
        return array( 'result' => array_values( $nodes ) );
    }

    /**
     * The comparable version of a version node ("6.x" becomes "6.99999"), or null when it has none.
     *
     * @param eZContentObjectTreeNode $node
     * @return string|null
     */
    public static function versionKey( eZContentObjectTreeNode $node )
    {
        $map = $node->dataMap();
        foreach ( array( isset( $map['version'] ) ? $map['version']->toString() : '', (string)$node->attribute( 'name' ) ) as $text )
        {
            $text = trim( strtolower( $text ) );
            if ( preg_match( '/^\d+(\.(\d+|x))*$/', $text ) )
            {
                return str_replace( 'x', '99999', $text );
            }
        }
        return null;
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
