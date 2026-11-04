---
title: Exponential Documentation
order: 0
---

# Exponential Documentation

The documentation site extension: its classes, the import of the static documentation and the two designs.

- [Reading the documentation through REST and GraphQL](headless-access.md)

## The documentation's tree

| Section | Address | Holds |
|---|---|---|
| Exponential | `/exponential` | the manuals from 3.x to 6.x, extensions, tutorials, FAQ and the rest |
| Exponential Platform | `/platform` | the spaces of the former documentation center (5.x), with Legacy (`/platform/legacy`), Nexus (`/platform/nexus`) and DXP (`/platform/dxp`) below it |
| Exponential Basic | `/basic` | the small CMS of the 2.x line |
| Historical | `/historical` | Confluence's page history: comparisons, old versions, page information, attachments (not in the menus) |
| Contributors | `/contributors` | every person who wrote, updated, maintains or commented on a page |

Every page has its roles (`written_by`, `last_updated_by`, `maintainers`) and the list `contributors`; the readers'
comments are objects of the class `comment_historical` below their page, replies below the comment they answer.
