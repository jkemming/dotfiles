---
name: documentation
description: "Writes and maintains documentation in Markdown. Use when: adding or changing code, features, configuration or architecture, or when asked to 'document this', 'write docs', 'update the docs', 'add a README'. Keeps docs in code where possible and otherwise in the repository's root `docs` directory."
---

# Documentation

Documents code and projects. Document whenever it is reasonable to do so, without restating what the code already makes obvious.

## Workflow

1. **Decide whether it needs documenting.** Document the *why*, intent, constraints, trade-offs, non-obvious behavior, public interfaces, setup and usage, and how parts fit together. Skip anything covered by the "What not to document" rules below.
2. **Choose the location** (see below), preferring documentation in the code itself.
3. **Write it in Markdown**, then check that existing docs affected by the change are updated or removed if now wrong.

## Where to put it

1. **In the relevant code, when possible.** Use the language's doc-comment or inline-comment conventions (e.g. KDoc/Javadoc, docstrings, JSDoc/TSDoc, `//` comments, YAML/shell comments). Write the comment text in Markdown wherever the format supports it.
2. **Otherwise in the `docs` directory at the repository root** (`<repo-root>/docs/`). Use this for material that doesn't belong to a single piece of code: architecture overviews, guides, decisions, runbooks. Create the directory if it doesn't exist. Use descriptive, lowercase, hyphenated file names (e.g. `docs/deployment.md`).
3. **Never create separate docs files next to the code.** No `NOTES.md`, `design.md` or per-directory docs beside source files. Such content goes into the code as comments or into the root `docs` directory.

A top-level `README.md` is fine for a short project introduction and for pointing to `docs/`. Don't duplicate `docs/` content in it.

## Format

- Use Markdown for all documentation files.
- Use headings, lists and fenced code blocks (with a language tag) to structure content. Keep it concise.
- Link to other docs or to code by relative path rather than copying content.

## What not to document

Don't document things that are easily apparent from the code and likely to change quickly, because they go stale and mislead. For example:

- The exact value of a constant or default setting.
- What a well-named function, variable or parameter does.
- Step-by-step restatements of the code.
- Lists that mirror something the code enumerates (all endpoints, all fields, all files).

Describe the concept and point to the code instead (e.g. "The timeout is configured in `Config`" rather than "The timeout is 30 seconds").

## Rules

- Prefer documentation in the code; use the root `docs` directory only when it doesn't fit there.
- Never place standalone docs files next to code.
- Keep docs accurate: when changing behavior, update or delete the docs it affects.
- Explain *why* more than *what*.
