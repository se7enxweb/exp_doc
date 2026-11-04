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
4. **Import:** `./console exp:doc:import` (add `--dry-run` first to see what it would do).
5. **Use the designs:** set the front siteaccess's `SiteDesign=doc` (Modern) or `SiteDesign=doc2025` (Classic).
