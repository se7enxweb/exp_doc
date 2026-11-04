---
title: Exponential-Dokumentation
order: 0
---

# Exponential-Dokumentation

Die Erweiterung der Dokumentationssite: ihre Klassen, der Import der statischen Dokumentation und die beiden Designs.

- [Die Dokumentation über REST und GraphQL lesen](headless-access.md)

## Der Baum der Dokumentation

| Abschnitt | Adresse | Inhalt |
|---|---|---|
| Exponential | `/exponential` | die Handbücher von 3.x bis 6.x, Erweiterungen, Tutorials, FAQ und der Rest |
| Exponential Platform | `/platform` | die Bereiche des früheren Dokumentationscenters (5.x), darunter Legacy (`/platform/legacy`), Nexus (`/platform/nexus`) und DXP (`/platform/dxp`) |
| Exponential Basic | `/basic` | das kleine CMS der 2.x-Linie |
| Historical | `/historical` | der Seitenverlauf von Confluence: Vergleiche, alte Versionen, Seiteninformationen, Anhänge (nicht in den Menüs) |
| Mitwirkende | `/contributors` | jede Person, die eine Seite geschrieben, bearbeitet, betreut oder kommentiert hat |

Jede Seite hat ihre Rollen (`written_by`, `last_updated_by`, `maintainers`) und die Liste `contributors`; die
Kommentare der Leser sind Objekte der Klasse `comment_historical` unter ihrer Seite, Antworten unter dem Kommentar,
auf den sie antworten.
