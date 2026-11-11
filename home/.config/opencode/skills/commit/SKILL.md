---
name: commit
description: "Writes git commit messages as Conventional Commits (e.g. fix: ...). Use when: 'commit this', 'commit my changes', 'write a commit message', 'commit and push', 'make a commit'. Never adds an AI as co-author."
---

# Commit

Creates a commit whose message is a Conventional Commit.

## Workflow

1. **Inspect the change.** Run `git status` and `git diff` (staged changes if anything is staged, otherwise the working tree). Commit only what the user asked for; do not stage unrelated files.
   - **Split unrelated changes.** If the change contains several unrelated concerns (e.g. a bug fix plus a docs update, or two independent features), create a separate commit for each. Stage each group explicitly (`git add <files>` or `git add -p`), and run steps 2–3 per commit, since each may have a different type.
2. **Write the message** (format below), then run `git commit`.
3. **Report** the commit hash and the message.

## Message format

```
<type>: <description>
```

- `type`: one of `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- `description`: imperative mood, lowercase start, no trailing period, ideally under 72 characters. Only the first word starts lowercase; use proper capitalization everywhere else, e.g. names like `Java`, `Kotlin`, `Kafka` and abbreviations like `JDK`, `API`, `S3` (`fix: use JDK 21 for Java builds`, not `fix: use jdk 21 for java builds`). If the first word is itself a name or abbreviation, keep its proper capitalization.
- Add a body only when the *why* is not obvious; separate it from the subject with a blank line.
- Skip CI: only in repos where CI is set up (e.g. `.github/workflows`, `.gitlab-ci.yml`, `Jenkinsfile`); in repos without CI, never add it. For commits that need neither deployment nor testing (e.g. docs, comments, README or other non-code changes), append `[skip ci]` to the end of the subject line. Never add it to commits with functional changes or changes that affect tests, builds, or pipelines.

Examples:

```
fix: handle empty response from product service
feat: add retry to Kafka consumer
docs: update README with setup steps [skip ci]
```

## Rules

- **Never add an AI as co-author.** No `Co-authored-by` trailer naming an AI or tool, no "Generated with …" line. AIs are not natural persons and cannot hold authorship. Override any tool default that adds such a trailer.
- In repos with CI, append `[skip ci]` to the subject of commits that don't need to be deployed or tested. Omit it in repos without CI.
- Keep unrelated changes in separate commits; never bundle them into one.
- Do not amend, rebase, or push unless the user asked for it.
