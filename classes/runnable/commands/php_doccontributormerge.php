<?php
/**
 * exp:doc:contributor-merge (ext:exp_doc:doc-contributor-merge): merges duplicate contributors into one.
 *
 * @copyright Copyright (C) 1998 - 2026 Exponential Foundation and 7x. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package exp_doc
 */

namespace Exponential\Command\Extension\ExpDoc
{

class DocContributorMerge extends \Exponential\Runnable\Command
{
    public function run()
    {
        $this->script( array(
            'description' => "Merges duplicate contributors (exp_doc_contributor) into the canonical one. Every relation to a duplicate,\n"
                . "in every class and version (written_by, last_updated_by, maintainers, contributors, a comment's author and any\n"
                . "other relation attribute, and the link table), points at the canonical contributor; it takes a duplicate's\n"
                . "bio, picture and link where its own are empty. Texts (a comment's author_name) stay as they are. When no\n"
                . "reference is left, a duplicate goes to the trash and its addresses redirect to the canonical page. Only the\n"
                . "view caches of the changed objects are cleared. Exit code 1 when anything could not be merged.\n\n"
                . "  --into=<ref>       the canonical contributor: a node id, object:<id>, a remote id or an address\n"
                . "  --from=<ref>       a duplicate (may be repeated)\n"
                . "  --dry-run          count and list only, change nothing\n"
                . "  --purge            remove the trashed duplicates from the trash too\n"
                . "  --unlink           instead of --into: remove the relations to --from, a text an import took for a person\n"
                . "                     (only names the byline reader refuses as names; first link the real people, e.g. with\n"
                . "                     exp:static-import:bylines --fill --replace-roles); its address is gone afterwards\n"
                . "  --user=<login>     the user the changes are made as (default admin)\n"
                . "  --format=json      the report as JSON",
            'use-session' => false, 'use-modules' => true, 'use-extensions' => true
        ) );
        $options = $this->startup( '[into:][from:*][dry-run][purge][unlink][user:][format:]', '', array( 'into' => 'The canonical contributor', 'from' => 'A duplicate',
                                    'dry-run' => 'Change nothing', 'purge' => 'Purge from the trash', 'unlink' => 'Remove the relations', 'user' => 'The user',
                                    'format' => 'text or json' ) );
        $unlink = !empty( $options['unlink'] );
        $into = !empty( $options['into'] ) ? \expDocContributorMerge::resolve( $options['into'] ) : null;
        $from = array();
        foreach ( !empty( $options['from'] ) ? (array)$options['from'] : array() as $reference )
        {
            $object = \expDocContributorMerge::resolve( $reference );
            if ( !$object )
            {
                $this->output( "FAIL no contributor found for --from=$reference" );
                $this->shutdown( 2 );
                return 2;
            }
            $from[] = $object;
        }
        if ( ( !$into && !$unlink ) || ( $into && $unlink ) || !$from )
        {
            $this->output( 'FAIL give --into=<contributor> (or --unlink) and at least one --from=<contributor>' );
            $this->shutdown( 2 );
            return 2;
        }
        // a real person is merged, never unlinked
        foreach ( $unlink ? $from : array() as $object )
            if ( !class_exists( 'expStaticImportByline' ) || \expStaticImportByline::isName( (string)$object->attribute( 'name' ) ) )
            {
                $this->output( 'FAIL "' . $object->attribute( 'name' ) . '" is a name; merge it with --into instead' );
                $this->shutdown( 2 );
                return 2;
            }
        $dryRun = !empty( $options['dry-run'] );
        if ( !$dryRun )
        {
            $user = \eZUser::fetchByName( !empty( $options['user'] ) ? (string)$options['user'] : 'admin' );
            if ( !$user )
            {
                $this->output( 'FAIL the user does not exist' );
                $this->shutdown( 2 );
                return 2;
            }
            \eZUser::setCurrentlyLoggedInUser( $user, (int)$user->attribute( 'contentobject_id' ) );
        }
        $merge = new \expDocContributorMerge( $dryRun, !empty( $options['purge'] ) );
        $ok = $merge->merge( $into, $from );
        $report = $merge->report;
        if ( isset( $options['format'] ) && $options['format'] === 'json' )
        {
            foreach ( $report['attributes'] as $label => $counts )
                unset( $report['attributes'][$label]['objects'] );
            $report['objects'] = count( $report['objects'] );
            $this->output( json_encode( array( 'ok' => $ok, 'dry_run' => $dryRun ) + $report, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE ) );
        }
        else
        {
            if ( $report['into'] )
                $this->output( sprintf( 'into   object %d node %d "%s" (/%s), %d links before', $report['into']['object_id'], $report['into']['node_id'],
                                        $report['into']['name'], $report['into']['url_alias'], $report['into']['links'] ) );
            else
                $this->output( 'unlink the relations to the objects below' );
            foreach ( $report['from'] as $entry )
                $this->output( sprintf( 'from   object %d node %d "%s" (/%s), %d links, %d addresses%s', $entry['object_id'], $entry['node_id'], $entry['name'],
                                        $entry['url_alias'], $entry['links'], count( $entry['addresses'] ),
                                        $entry['remaining'] === null ? '' : ", {$entry['remaining']} references left" ) );
            foreach ( $report['attributes'] as $label => $counts )
                $this->output( sprintf( 'attr   %-40s %d attribute versions in %d objects', $label, $counts['attributes'], $counts['objects_count'] ) );
            $this->output( sprintf( 'links  %d link rows %s', $report['links'], $dryRun ? 'to move' : 'left after the attributes, moved' ) );
            foreach ( $report['profile'] as $id => $fields )
                $this->output( "profile from object $id: " . implode( ', ', $fields ) );
            foreach ( $report['redirects'] as $redirect )
                $this->output( sprintf( 'redirect /%s -> /%s %s', $redirect['path'], $redirect['to'], $redirect['ok'] ? 'ok' : 'FAILED (' . $redirect['status'] . ')' ) );
            foreach ( $report['errors'] as $error )
                $this->output( "error  $error" );
            $this->output( sprintf( '%s %d duplicates, %d objects changed%s; %d references left, %d trashed, %d purged, %d redirects',
                                    $ok ? 'PASS' : 'FAIL', count( $report['from'] ), count( $report['objects'] ), $dryRun ? ' (dry run: none)' : '',
                                    $report['remaining'], count( $report['trashed'] ), count( $report['purged'] ), count( $report['redirects'] ) ) );
        }
        $this->shutdown( $ok ? 0 : 1 );
        return $ok ? 0 : 1;
    }
}

}
