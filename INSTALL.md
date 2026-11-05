# Installing Exponential Documentation

**Requirements:**
- Exponential 6.0.15 or later;
- the extension exp_static_html_imports;
- eztags, for the labels;
- xrowmetadata, for the metadata attribute;
- ezoe (the online editor).

1. **Get the two extensions.** Put them in `extension/exp_doc` and `extension/exp_static_html_imports`, then activate
   them in `settings/override/site.ini.append.php`, exp_static_html_imports first:

   ```ini
   [ExtensionSettings]
   ActiveExtensions[]=exp_static_html_imports
   ActiveExtensions[]=exp_doc
   ```

2. **Deploy:** `./console exp:velocity deploy --allow-root-user`, or regenerate the autoloads and clear the caches.
3. **Run the migrations:** `./console exp:migration:run --extension=exp_doc`. They create:
   - the class group Documentation and its classes;
   - the sections Doc, Media and Hidden;
   - the role Doc reader, for anonymous read access;
   - the media folder below the Documentation site.

   They expect a folder with the remote id `exp_doc_site_root` as the site's root.

   On SQLite, `20261104235900_doc_sqlite_statistics` gives the query planner its statistics (`ANALYZE`, kept in
   `sqlite_stat1`). Without them SQLite loads the attributes of a list of objects (every content tree fetch with data
   maps) through the index of the language alone and reads most of `ezcontentobject_attribute`: seconds per fetch on a
   large database. After a large import, run the same two statements again (`PRAGMA analysis_limit = 1000; ANALYZE;`);
   they change no data. Other engines skip the step.
4. **Import:** `./console exp:doc:import` (add `--dry-run` first to see what it would do).
5. **Use the designs:** set the front siteaccess's `SiteDesign=doc` (Modern) or `SiteDesign=doc2025` (Classic).
6. **Run the cronjobs:** the frequent part (`runcronjobs.php frequent`, every five minutes) runs exp_doc's
   `exp_doc_feeds.php`, which reads the front page's commit and forum feeds so no page view waits for them, and
   `exp_doc_contributor_counts.php`, which counts the Contributors page's roles again after a publish (the page reads
   them from `var/<site>/cache/exp_doc/contributor-counts.php`). Without the cronjob both still work, slower: a page
   view reads a feed whose cache is older than its cache time, and counts the roles when the file is missing.
