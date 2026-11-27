---
name: design-hygiene-refactoring-and-prefactoring
description: Refactor at the points the project has chosen, from a list of triggers (before every change, before each plan or plan node, only when the change is hard, occasionally in a batch of its own, or never unasked), read from the skill's preferences, and when the project hasn't chosen, ask the user once with a checkbox question and save the answer in the project's tracked preferences file. Each refactoring keeps behaviour unchanged, with the tests passing unchanged before and after, sits in its own commit apart from the change it prepares, says what it makes easy, and is scoped to what the coming change needs. Use before starting a change, a plan or a plan node, when a change would touch scattered code or need copy-paste, and when reviewing a commit that mixes a refactoring with a change.
---

# Refactoring and prefactoring

_Make the change easy, then make the easy change, at the points the project has chosen. A refactoring never changes what the code does, and never shares a commit with the change it prepares._

## When to apply

- Before starting a change, a plan or a plan node.
- When a change would touch code scattered across the codebase, or need a block copied and edited.
- When reviewing a commit or pull request that refactors and changes behaviour at once.

## The names

The practice has two names from precedent:

- **Preparatory refactoring**, Martin Fowler's name for restructuring code so that a coming change fits it.
- **"Make the change easy (warning: this may be hard), then make the easy change"**, Kent Beck's statement of the same practice.

This skill calls a preparatory refactoring a _prefactoring_. Ken Pugh's book "Prefactoring" uses the word for something else: design decisions made up front, before the code exists. This skill means Fowler's sense alone: restructuring existing code just before a change, for that change.

## When to refactor

The project's `Refactor when` preference lists one or more of these triggers; several can apply at once.

| Trigger                   | A refactoring happens                                                                                                                                                     |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `before-every-change`     | At the start of each change, as a commit of its own that makes the change easy, or a pull request of its own below the change's where the project keeps one commit per PR |
| `before-plans`            | Before implementing a plan or plan node, as a prefactoring step or node of its own that the implementation `needs`                                                        |
| `when-the-change-is-hard` | Only when the change would otherwise touch scattered code or need copy-paste                                                                                              |
| `occasionally`            | In a batch of its own, never mixed into feature work, at the cadence `Occasionally means` names                                                                           |
| `never-unasked`           | Only when the user asks for it                                                                                                                                            |

The default is `when-the-change-is-hard`. It spends a refactoring where it pays, on a change it shortens, and leaves the other changes' diffs small. `before-every-change` costs a commit even where the code already fits; `never-unasked` lets the copy-paste build up.

Under `never-unasked`, or `occasionally` when it isn't time yet, a change the code doesn't fit still lands as it can; say in the reply which refactoring would have made it easy.

## Asking once

When neither preferences file sets `Refactor when`, ask the user before the first change that would refactor, once per project:

1. Ask through the structured-question tool, such as `AskUserQuestion` with several answers allowed: "When should refactoring happen in this project? (recommended: when the change is hard)", with one option per trigger above, recommended first.
2. Where the answer includes `occasionally`, ask what it means: after a number of changes, or when asked.
3. Write the answer into the project's tracked `.agents/skills/design-hygiene-refactoring-and-prefactoring.preferences.md`, creating it, and commit that file on its own.
4. From then on, apply it without asking. When the user says to change it, update the file first.

A one-off instruction, such as "skip the refactoring this time", overrides the preference for that change and changes nothing in the file.

## The rules

- **Behaviour never changes.** The tests pass, unchanged, before and after the refactoring. A refactoring that needs a test changed is a change; split it out, or write the test first against the old code.
- **Its own commit.** A refactoring is never mixed with the change it prepares, so each diff reads as one thing: a reviewer checks the refactoring for sameness and the change for correctness.
- **The commit says what it makes easy,** such as "Extract the retry loop so the backoff change touches one place".
- **Scoped to the coming change.** Restructure what the change needs and stop; a wider cleanup is a plan node of its own, or an `occasionally` batch.

## Your preferences

!`cat "$(dirname "${CLAUDE_SKILL_DIR}")/design-hygiene-refactoring-and-prefactoring.preferences.md" "${CLAUDE_PROJECT_DIR}/.agents/skills/design-hygiene-refactoring-and-prefactoring.preferences.md" 2>/dev/null || true`

If your agent doesn't run the line above, read these files yourself if they
exist: `design-hygiene-refactoring-and-prefactoring.preferences.md` next to this skill's folder, then
`.agents/skills/design-hygiene-refactoring-and-prefactoring.preferences.md` in the project. A project's
file overrides the user's, and the user's overrides this skill's defaults.

The keys this skill reads, with its own defaults:

```markdown
- Refactor when: none
- Occasionally means: when asked
```

`Refactor when` lists triggers from "When to refactor", such as `before-plans, when-the-change-is-hard`. `none` means the project hasn't chosen: ask as "Asking once" says, recommending `when-the-change-is-hard`. `Occasionally means` names the cadence of `occasionally`, such as `after 10 changes` or `when asked`.

## Related skills

When one of these applies and it's in your skill listing, load it
without asking. If it isn't in your listing, tell the user which skill is
missing and ask whether to install it from the same collection this skill
came from; don't apply it from memory.

- `coding-agent-plans-as-graph`: the prefactoring node a plan node `needs` under `before-plans`.
- `coding-agent-questions-as-first-class-prompts`: asking which triggers apply through the structured-question tool.
- `design-hygiene-find-implicit-models`: the model a prefactoring often makes explicit so the change touches one place.
- `design-hygiene-ideal-then-compromise`: the ideal a prefactoring moves the code toward, and the compromise of skipping it.
- `github-hygiene-single-commit-pull-requests`: the pull request of its own a refactoring takes, below the change's.
