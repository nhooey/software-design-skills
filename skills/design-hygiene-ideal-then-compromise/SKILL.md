---
name: design-hygiene-ideal-then-compromise
description: Design the ideal solution first, with no regard for the status quo, then name each compromise that would reach the finish line sooner, put every one to the user as a decision with "do the quick thing now and record the ideal" among its options, and record each compromise taken as a proposed node in the repository's plan graph that names the ideal and what was done instead, with only a pointer to that node in the code. Covers writing the ideal down as a checkable end state, finding where a faster path departs from it, telling an ephemeral compromise from one that spreads, the Decide item to ask with, the node's frontmatter and body, the code pointer, and closing the node when the ideal lands, with a worked example of a missing library. Use when designing a feature, tool, library or migration, when about to work around a missing library, a tool's limits or a legacy interface, when tempted to shape a design around what exists today, and when reviewing a design or diff that carries a shortcut.
---

# Ideal, then compromise

_Design the ideal with no regard for what exists today. Then let the user choose each compromise that gets to the finish line sooner, and record every one taken so it can be made ideal later._

A design that starts from the status quo inherits its limits without
noticing them, and a shortcut taken quietly is never paid back because
nobody knows it was taken. Designing the ideal first makes every gap
between it and what ships visible, and recording each gap makes it work
someone can pick up.

## When to apply

- Designing a feature, tool, library, migration or interface, or choosing between approaches.
- About to work around something: a missing library, a tool's limits, a legacy interface, an unfinished dependency.
- Tempted to fit a design to the code, tools or formats already there.
- Reviewing a design or a diff that carries a shortcut, a stopgap or a "for now".

## 1. Design the ideal

Ask what the design would be if it were built from nothing today, with
what is known now:

- **Ignore the status quo:** the current code and its interfaces, the tools already installed, the libraries the language lacks, the time it would take. They come back in step 2, as compromises, never as constraints here.
- **Ignore what most projects do:** the common way is the status quo at a larger scale, not the ideal. An agent leans towards it because it fills the agent's training data, which says how often something is done, not how good it is.
- **Write it down as an end state:** what is true when it is done, stated so it can be checked, with no steps. In a repository with a plan graph, it is an `end-state` node, as `coding-agent-plans-as-graph` lays out.
- **Keep it whole:** the ideal is one design, not a list of wishes. A compromise is measured against it, so it has to be specific enough to fall short of.

## 2. Find the compromises

Lay the ideal beside the fastest path that would ship, and list each
place they part. For each compromise, name:

- **The ideal** it falls short of, in the ideal's own words.
- **What would be done instead**, concretely: the tool shelled out to, the subset handled, the interface kept.
- **What it saves now:** time, a dependency, a migration.
- **What it costs later:** the work to remove it, what else it limits meanwhile, who it surprises.
- **Whether it stays ephemeral:** a compromise worth taking can be removed later without redoing the work around it, such as a stopgap behind an interface the ideal keeps. One that spreads, such as a data format written to disk, an interface other code builds on or a dependency others start to rely on, gets costlier every day it stays; say so.

## 3. Put each compromise to the user

A compromise is the user's choice, never one the agent settles quietly.
Ask about each one on its own, through the agent's structured-question
tool as `coding-agent-questions-as-first-class-prompts` describes, and
in a final response as a Decide item in the format of
`coding-agent-kanban-turn-responses`: capital-letter options,
recommended first, each with a ➕ and a ➖ line. One option is always the
quick thing now with the ideal recorded:

```text
1. **Read TOML in the release tool with a TOML library, or with a stopgap**
   No TOML library for Babashka is packaged in Nix here; the release tool reads `release.toml`.
   🔘 A. **Stopgap now, ideal recorded**: read `release.toml` through `taplo get -o json`, and add plan node `write-babashka-toml-library`
      ➕ the release tool ships today, and the stopgap sits behind one function the library later replaces.
      ➖ the tool needs `taplo` on its path until the library lands.
   🔘 B. **Ideal now**: write a Babashka TOML library in its own repository, packaged in Nix, then the release tool on it
      ➕ every Babashka program here reads TOML properly, with nothing to remove later.
      ➖ a day or more before the release tool ships.
```

The recommendation is a judgement for the case at hand: the quick option
leads only when the compromise stays ephemeral. Choosing the ideal means
doing it, with no node to record.

## 4. Record every compromise taken

Each compromise the user takes becomes a node in the repository's plan
graph, `agents/plans/`, as `coding-agent-plans-as-graph` lays out,
creating the graph if the repository has none:

- **Id and title name the ideal work,** such as `write-babashka-toml-library`, "Write a Babashka TOML library", so the overview reads as what is left to do.
- **`state: proposed`:** the user approves it later, as for any node.
- **`kind: implementation`,** `part-of` the end-state node of the ideal it falls short of, when the ideal has one.
- **`touches`:** the files the stopgap lives in, where the work to remove it lands.
- **The body** names the ideal and what was done instead, and says how to tell the stopgap is gone.

```markdown
---
title: Write a Babashka TOML library
state: proposed
kind: implementation
part-of: release-tool-reads-its-config
touches: [src/release/config.clj]
---

# Write a Babashka TOML library

## The ideal

Babashka programs read and write TOML with a library in its own
repository, packaged in Nix, and the release tool reads
`release.toml` through it.

## Done instead

`release.config/read-config` runs `taplo get -o json` on `release.toml` and
parses the JSON, so the release tool needs `taplo` on its path.

## Done when

`release.config/read-config` calls the library, `taplo` is gone from the
release tool's runtime inputs, and no comment names this node.
```

## The pointer in the code

At the stopgap, a comment holds only a pointer to the node, by id, which
survives the node's move from `open/` to `closed/`:

```clojure
;; Compromise: plan node write-babashka-toml-library
(defn read-config [path] ...)
```

Everything else, the reason, the ideal, a "temporary until", a date,
lives in the node, as `git-hygiene-no-history-in-tracked-files`
requires of every tracked file. Searching for the id finds every site
the node covers.

## Closing a compromise

When the ideal lands, delete the stopgap and every comment naming the
node in the same change, and close the node as `implemented`, as
`coding-agent-plans-as-graph` describes. A compromise later judged
permanent is closed as `rejected` by the user, and its pointer comments
go with it, since the code then is the design.

## Example: a missing library

The chosen language, picked by `design-hygiene-language-choice`, has no
library for something the program needs, such as reading a file format
or calling an API.

- **The ideal:** write the library, in its own repository or package, and use it like any other dependency. It improves the language for everyone who uses it after.
- **The compromises to offer:** a stopgap that calls a command-line tool, or a narrow hand-written parser for the one subset the program reads, behind the interface the library will later fill. Each taken is recorded as a node named for the library, "Write library X".
- **Not a compromise to offer:** moving the program to another language because that one has the library. That trades a removable stopgap for a permanent change of language.

## Related skills

When one of these applies and it's in your skill listing, load it
without asking. If it isn't in your listing, tell the user which skill is
missing and ask whether to install it from the same collection this skill
came from; don't apply it from memory.

- `coding-agent-kanban-turn-responses`: the Decide item each compromise is put to the user as.
- `coding-agent-plans-as-graph`: the end-state node of the ideal, and the proposed node each compromise taken becomes.
- `coding-agent-questions-as-first-class-prompts`: asking about a compromise through the structured-question tool.
- `design-hygiene-language-choice`: the language the ideal is written in, and why a missing library never changes it.
- `git-hygiene-no-history-in-tracked-files`: why the code holds only a pointer to the node.
