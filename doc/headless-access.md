# Reading the documentation through REST and GraphQL

The documentation site is an ordinary Exponential installation, so its pages can be read by programs as well as
by people: through the kernel's REST content API and its GraphQL API. Both read as the anonymous visitor, so they
see exactly what the site shows, and nothing that is hidden or restricted.

## Contents

1. [What is available](#1-what-is-available)
2. [GraphQL](#2-graphql)
3. [REST](#3-rest)
4. [The documentation's content classes](#4-the-documentations-content-classes)
5. [Troubleshooting](#5-troubleshooting)

## 1. What is available

| Interface | Address | Reads |
|---|---|---|
| GraphQL | `<site>/api/graphql` | any field of any documentation page, in one request |
| REST, version 2 | `<site>/api/ezp/v2/content/node/<node id>` and `.../list/offset/<n>/limit/<n>` | a node and its children |
| REST, version 1 | `<site>/api/ezp/v1/...` | the same, in the older format |

`<site>` is the documentation's address, for example `https://doc.exponential.earth/doc`. Both interfaces have to be
switched on in the installation (see [section 5](#5-troubleshooting)); they only read here. Pages are never
changed through them on this site.

## 2. GraphQL

The schema is generated from the content classes: every class is a type, every attribute a field. A query for a
page and its children:

```graphql
query {
  node(id: 2535) {
    name
    url
    children(limit: 20) {
      name
      url
      contentClass
    }
  }
}
```

Send it with any HTTP client:

```bash
curl -s https://doc.exponential.earth/doc/api/graphql \
  -H 'Content-Type: application/json' \
  -d '{"query":"{ node(id: 2535) { name url children(limit: 20) { name url } } }"}'
```

The kernel limits the depth, the complexity and the list sizes of a query; `./console exp:graphql:status` shows
the limits. The full reference is the kernel's help page *The GraphQL API* (`features/6.0/graphql.md`), with a
walkthrough and recipes.

## 3. REST

```bash
curl -s https://doc.exponential.earth/doc/api/ezp/v2/content/node/2535
curl -s https://doc.exponential.earth/doc/api/ezp/v2/content/node/2535/list/offset/0/limit/20
```

Reads answer at version 1 and version 2 and check the reader's policies, as the site does. The guide is the
kernel's help page *REST API v1 and v2* (`guides/rest-api-v1-and-v2.md`).

## 4. The documentation's content classes

| Class | What it is | Fields worth reading |
|---|---|---|
| `exp_doc_page` | a page | `title`, `body`, `labels`, `written_by`, `last_updated_by`, `maintainers`, `contributors`, `history_of` |
| `exp_doc_section` | a section of pages | as a page |
| `exp_doc_manual` | a manual (Technical, User ...) | `summary`, `audience`, `cover` |
| `exp_doc_version` | a version of a manual | `version`, `status`, `released`, `eol`, `release_notes` |
| `exp_doc_tutorial`, `exp_doc_tutorial_step` | a tutorial and its steps | `level`, `duration`, `prerequisites`, `step_number` |
| `exp_doc_faq`, `exp_doc_faq_question` | an FAQ group and one question | `question`, `answer` |
| `exp_doc_extension` | an extension's page | `extension_name`, `repository`, `packagist`, `compatibility`, `license`, `status` |
| `exp_doc_contributor` | a person who wrote, maintains or commented on pages | the pages that name them, through the relations |
| `exp_doc_historical` | a container of the page history | `title`, `history_of` |
| `comment_historical` | a reader's comment | `title`, `body`, `author`, `author_name`, `created`, `source_parent_id` |
| `exp_doc_image`, `exp_doc_file` | an image or a file of the pages | `image` or `file`, `alt`, `caption`, `credit` |

## 5. Troubleshooting

| What you see | What to do |
|---|---|
| `/api/graphql` answers 404, or that GraphQL is off | It is not switched on for the site: `./console exp:graphql:enable --siteaccess=site --apply` on the installation. |
| `/api/ezp/...` answers 404 | The REST extension is not active: `ActiveExtensions[]=ezprestapi`. |
| An empty result for a page you can see | The page is hidden, or not in the language asked for. |
