# Die Dokumentation über REST und GraphQL lesen

Die Dokumentationssite ist eine gewöhnliche Exponential-Installation, ihre Seiten lassen sich also nicht nur von
Menschen, sondern auch von Programmen lesen: über die REST-Inhalts-API und die GraphQL-API des Kernels. Beide lesen als
anonymer Besucher; sie sehen also genau das, was die Site zeigt, und nichts, was verborgen oder eingeschränkt ist.

## Inhalt

1. [Was verfügbar ist](#1-was-verfügbar-ist)
2. [GraphQL](#2-graphql)
3. [REST](#3-rest)
4. [Die Inhaltsklassen der Dokumentation](#4-die-inhaltsklassen-der-dokumentation)
5. [Fehlerbehebung](#5-fehlerbehebung)

## 1. Was verfügbar ist

| Schnittstelle | Adresse | Liest |
|---|---|---|
| GraphQL | `<site>/api/graphql` | jedes Feld jeder Dokumentationsseite, in einer Anfrage |
| REST, Version 2 | `<site>/api/ezp/v2/content/node/<Knoten-ID>` und `.../list/offset/<n>/limit/<n>` | einen Knoten und seine Kinder |
| REST, Version 1 | `<site>/api/ezp/v1/...` | dasselbe, im älteren Format |

`<site>` ist die Adresse der Dokumentation, zum Beispiel `https://doc.exponential.earth`. Beide Schnittstellen
müssen in der Installation eingeschaltet sein (siehe [Abschnitt 5](#5-fehlerbehebung)); hier lesen sie nur. Seiten
werden auf dieser Site nie über sie geändert.

## 2. GraphQL

Das Schema wird aus den Inhaltsklassen erzeugt: jede Klasse ist ein Typ, jedes Attribut ein Feld. Eine Abfrage einer
Seite und ihrer Kinder:

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

Mit einem beliebigen HTTP-Client senden:

```bash
curl -s https://doc.exponential.earth/api/graphql \
  -H 'Content-Type: application/json' \
  -d '{"query":"{ node(id: 2535) { name url children(limit: 20) { name url } } }"}'
```

Der Kernel begrenzt die Tiefe, die Komplexität und die Listengrößen einer Abfrage; `./console exp:graphql:status`
zeigt die Grenzen. Die vollständige Referenz ist die Hilfeseite des Kernels *Die GraphQL-API*
(`features/6.0/graphql.md`), mit einer Einführung und Rezepten.

## 3. REST

```bash
curl -s https://doc.exponential.earth/api/ezp/v2/content/node/2535
curl -s https://doc.exponential.earth/api/ezp/v2/content/node/2535/list/offset/0/limit/20
```

Lesezugriffe antworten in Version 1 und Version 2 und prüfen die Richtlinien des Lesers, wie die Site es tut. Die
Anleitung ist die Hilfeseite des Kernels *REST API v1 und v2* (`guides/rest-api-v1-and-v2.md`).

## 4. Die Inhaltsklassen der Dokumentation

| Klasse | Was sie ist | Lesenswerte Felder |
|---|---|---|
| `exp_doc_page` | eine Seite | `title`, `body`, `labels`, `written_by`, `last_updated_by`, `maintainers`, `contributors`, `history_of` |
| `exp_doc_section` | ein Abschnitt mit Seiten (auch die Produkte) | wie eine Seite |
| `exp_doc_manual` | ein Handbuch (Technisch, Benutzer ...) | `summary`, `audience`, `cover` |
| `exp_doc_version` | eine Version eines Handbuchs | `version`, `status`, `released`, `eol`, `release_notes` |
| `exp_doc_tutorial`, `exp_doc_tutorial_step` | ein Tutorial und seine Schritte | `level`, `duration`, `prerequisites`, `step_number` |
| `exp_doc_faq`, `exp_doc_faq_question` | eine FAQ-Gruppe und eine Frage | `question`, `answer` |
| `exp_doc_extension` | die Seite einer Erweiterung | `extension_name`, `repository`, `packagist`, `compatibility`, `license`, `status` |
| `exp_doc_contributor` | eine Person, die Seiten geschrieben, betreut oder kommentiert hat | die Seiten, die sie nennen, über die Beziehungen |
| `exp_doc_historical` | ein Container des Seitenverlaufs | `title`, `history_of` |
| `comment_historical` | ein Kommentar eines Lesers | `title`, `body`, `author`, `author_name`, `created`, `source_parent_id` |
| `exp_doc_image`, `exp_doc_file` | ein Bild oder eine Datei der Seiten | `image` oder `file`, `alt`, `caption`, `credit` |

## 5. Fehlerbehebung

| Was Sie sehen | Was zu tun ist |
|---|---|
| `/api/graphql` antwortet mit 404, oder GraphQL sei aus | Es ist für die Site nicht eingeschaltet: `./console exp:graphql:enable --siteaccess=site --apply` in der Installation. |
| `/api/ezp/...` antwortet mit 404 | Die REST-Erweiterung ist nicht aktiv: `ActiveExtensions[]=ezprestapi`. |
| Ein leeres Ergebnis für eine Seite, die Sie sehen | Die Seite ist verborgen, oder nicht in der angefragten Sprache vorhanden. |
