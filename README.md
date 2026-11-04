# Exponential Documentation (exp_doc)

The Exponential documentation site as an Exponential site: the static documentation export
(https://exponential.doc.exponential.earth) imported into content classes made for documentation, shown in two
designs.

- **Content classes** in the class group Documentation, each with a Bootstrap icon:
  - pages, sections, manuals and versions;
  - tutorials and their steps;
  - FAQ groups and their questions;
  - extension reference pages;
  - images and files.

  Every class has a metadata attribute in the Meta category.
- **The import.** `extension/exp_doc/bin/php/doc-import-pages.php` (or `./console exp:doc:import`) runs the static
  import of [exp_static_html_imports](https://github.com/se7enxweb/exp_static_html_imports) with the documentation's
  type, `--doc-html`, and its rules (`settings/statichtmlimport.ini.append.php`).
  - It can run again: changed pages are updated, and edits made in the CMS are kept.
  - Old paths redirect to the new pages.
- **Two designs.**
  - **Classic** (`design/doc2025`): the static site, exactly.
  - **Modern** (`design/doc2026`, linked as `design/doc`).

  The header switches between them with one click.

Install: see [INSTALL.md](INSTALL.md). Credits for the original design and content: [CREDITS.md](CREDITS.md).

License: GNU General Public License v2.0 (or any later version). Copyright (C) 1998 - 2026 Exponential Foundation
and 7x.
