---
name: design-hygiene-language-choice
description: Choose the language and style of any program, library, service, tool or script by its role and the considerations that shift the pick, never by popularity or habit; agent skills are one case among them. Suggests functional languages first for each role, from configuration and packaging (Nix), scripts and glue (Babashka), applications, libraries, services and data processing (Clojure, OCaml, Haskell, Gleam, Elixir), systems code (Rust) and Apple platforms (Swift) to hot paths such as git hooks (POSIX sh), the portable port for programs other people install without Nix, such as skills and plugins (stdlib Python 3.9), and forced platforms (TypeScript, F#, Scala), with start-up time, static types against a REPL, concurrency, the library ecosystem, native binaries and running without Nix shifting the pick within a role. Covers when a real program plus a port pays, writing a program to be ported piece by piece against shared tests, why an agent's pull towards popular languages is a bias to correct, loading or writing a skill instead of falling back to what the agent knows, using the language's libraries rather than shelling out, writing a missing library rather than switching languages, and how code is written in any language (a pure functional core in a thin effectful shell, immutable data, errors as values, typed interfaces, checkable rules as programs, everything pinned), with a preference key that overrides the suggestions per role. Use when starting a program, script, hook, tool, library or service, choosing a language, runtime or dependency, about to write Python, JavaScript or bash out of habit, when a needed library is missing, and when reviewing a design or diff that picks any of these.
---

# Language choice

_Pick the language of every program, library, service, tool and script by its role and the considerations that shift the pick, never by its popularity or the agent's familiarity with it, and write it as a pure functional core in a thin effectful shell._

This skill covers all the software you write, not only agent skills. Agent skills and plugins are one case among programs, libraries, services, tools and scripts, and come up only where they are shared with people who install them without Nix: the portable port in "Roles and languages" and "Programs that get ported".

## When to apply

- Starting a program, script, hook, tool, library or service, or porting one.
- Choosing a language, runtime, library, database or tool for any of them.
- About to write Python, JavaScript or bash because it came to mind first.
- A library the program needs is missing in the chosen language.
- Deciding whether a program other people install without Nix needs a portable port, or writing one meant to be ported.
- Reviewing a design or diff that adds a language, a runtime dependency or a shell-out.

## Why

- **Popularity measures avoided learning, not quality.** An agent defaults to the most popular languages and tools because they fill its training data. They are popular mostly because people avoid the cost of learning something better, the same reason Nix stays rare while Windows dominates.
- **That cost has collapsed.** An agent learns and rewrites cheaply, and where it knows a less common language, library or database poorly, a skill fills the gap, as the `xtdb-skills` collection does for the XTDB database.
- **Nix makes any toolchain free to reach.** A dev shell brings in any language, compiler or library, pinned, with barely any friction, and the agent handles Nix's hard parts.

So:

- **Never pick a language, library or tool for its popularity** or the agent's own familiarity with it.
- **When the right choice is unfamiliar, get a skill for it:** load one if it's in the skill listing, ask the user for one if not, or propose writing one. Falling back to the popular option is not one of the choices.
- **On noticing a default to Python, JavaScript or bash out of habit,** stop and check "Roles and languages" first.

## Roles and languages

Find the program's role, take its suggested languages, then let the considerations shift the pick among them. Functional languages come first. The user's `Languages by role` preference overrides a role's suggestions.

### Considerations

- **Start-up time:** a command run often, or from a hook, can't wait for a JVM to warm up.
- **Static types or REPL-driven development:** types for hard logic and large programs, a REPL for exploring data and growing a program live.
- **Concurrency:** many connections or jobs at once favour a runtime built for it.
- **The library ecosystem the job needs:** a language with the library beats one without, as "A missing library" weighs.
- **Native binary or a runtime:** a single binary ships and starts simply; a runtime brings its libraries and live tooling.
- **Whether other people must run it without Nix:** only the portable port serves them.

### Suggestions by role

| Role                                 | Suggested                         | Shifted by a consideration                                                                 |
| ------------------------------------ | --------------------------------- | ------------------------------------------------------------------------------------------ |
| Configuration and packaging          | Nix                               | Code only where a declaration can't say it                                                 |
| Scripts and glue                     | Babashka                          | Static types: OCaml<br/>JVM libraries: Clojure                                             |
| Applications and CLI tools           | Clojure, OCaml, Haskell           | Start-up: Clojure native, OCaml, Rust<br/>Static types: OCaml, Haskell                     |
| Libraries                            | The language of the code using it | Used from many languages: Rust                                                             |
| Long-running services                | Clojure, Elixir, Gleam            | Concurrency: Elixir, Gleam<br/>Static types: Gleam, Haskell, OCaml<br/>Native binary: Rust |
| Data processing                      | Clojure, Babashka                 | Static types: OCaml, Haskell<br/>Speed: Rust                                               |
| Systems and speed-critical code      | Rust                              | —                                                                                          |
| Apple platforms                      | Swift                             | Logic shared with other platforms: Rust                                                    |
| Hot paths such as git hooks          | POSIX sh, handing off at once     | Real logic: a native binary in Rust, OCaml or Clojure native                               |
| Portable port for people without Nix | Stdlib Python 3.9                 | Only for programs other people install without Nix, such as skills and plugins             |
| Forced platforms                     | What the platform requires        | Claude Code mods: TypeScript<br/>.NET: F#<br/>JVM frameworks such as Spark: Scala          |

"Clojure native" is Clojure built to a native binary through GraalVM and clj-nix.

- **Hot paths:** POSIX `sh` only where an interpreter's start-up costs too much, such as git hooks and hook shims. Bash beyond small glue becomes a named tool, as `shell-hygiene-commands-as-cli-tools` describes.
- **The portable port:** stdlib-only Python in functional style, as `python-hygiene-functional-style` describes, ported from the real program where that is in another language, or the only version of a small one, as "Programs that get ported" says. It may call the shell tools nearly everyone has (`jq`, `git`, `curl`, POSIX `sed`, `awk`, `grep`, `find`, `sort`), never ones most people must install (`cmark-gfm`, `shfmt`). It is tolerated for its reach, not chosen for its quality, and is not a general role: software that stays with you or ships through Nix takes the other roles.
- **Babashka's dependencies are pinned through Nix** and never downloaded at run time, so a `bb.edn` holds no `:deps`.

Never chosen by default: Python or JavaScript outside the roles above.

### Why each language

| Language                                                                       | Why it's suggested                                                              |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| [Nix](https://nixos.org/)                                                      | Declarative and reproducible; pins every toolchain and dependency               |
| [Babashka](https://babashka.org/)                                              | Clojure with near-instant start-up; data-oriented and REPL-driven               |
| [Clojure](https://clojure.org/)                                                | Immutable data, a live REPL and the JVM's libraries; native through GraalVM     |
| [OCaml](https://ocaml.org/)                                                    | Static types with inference, fast compiles, small fast native binaries          |
| [Haskell](https://www.haskell.org/)                                            | Purity and the strongest types, for logic where correctness matters most        |
| [Gleam](https://gleam.run/)                                                    | Static types on the BEAM, with its concurrency and fault tolerance              |
| [Elixir](https://elixir-lang.org/)                                             | BEAM processes and supervision for concurrent, long-running services            |
| [F#](https://fsharp.org/)                                                      | Functional on .NET, where the platform forces .NET                              |
| [Scala](https://www.scala-lang.org/)                                           | Functional on the JVM, where a framework such as Spark forces it                |
| [Rust](https://www.rust-lang.org/)                                             | Native speed and memory safety with no runtime; immutable by default            |
| [Swift](https://www.swift.org/)                                                | Apple platforms' own language and frameworks                                    |
| [POSIX sh](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/sh.html) | Starts instantly and is everywhere; for hand-offs, not logic                    |
| [Python 3.9](https://www.python.org/)                                          | On nearly every machine with nothing to install; 3.9 reaches the oldest of them |
| [TypeScript](https://www.typescriptlang.org/)                                  | Only where the platform runs nothing else                                       |

## Programs that get ported

This section applies only to programs other people install without Nix, such as skills and plugins. Everything else is written once, in the language its role suggests.

- **Write a small or simple program once,** in functional-style stdlib Python, and skip the port. A real program plus a port pays only where the real program's language brings a real gain: speed, correctness on hard logic, or a better library.
- **Write a program meant for porting so it ports piece by piece:** per function, or at whatever level suits each part, without bending the design to make that possible.
- **A port is only as equivalent as its tests.** Write the shared test cases, and the prompts that drive the port, to cover the program's behaviour, edge cases and errors included, not only the paths that are easy to check.

## Libraries, not tools

- **In a program of your own, use the chosen language's libraries** for Markdown, JSON, TOML, shell syntax and the like, rather than shelling out to a tool.
- **Parse with parsers, not regular expressions,** wherever reasonable, as `design-hygiene-parsers-over-regular-expressions` lays out.
- **Calling tools is fine** in shell glue, dev shell commands and Nix, where running tools is the job.

## A missing library

Never switch languages because a library is missing. Either:

- **Write the library,** in its own repository or package, used like any other dependency, or
- **Take a compromise** such as a stopgap that calls a tool, put to the user and recorded as `design-hygiene-ideal-then-compromise` describes.

## How code is written

In any language:

- **A pure functional core, with effects in a thin shell** at the edges.
- **Immutable data,** nothing changed in place.
- **Expressions over statements.**
- **Errors as values in the core,** raised or printed only in the shell.
- **Imperative code only in a tight inner loop** measured to matter, kept local behind a pure interface.
- **Typed data and declared interfaces,** such as schemas and command specs, over ad hoc string handling.
- **Checkable rules become programs, hooks or tests,** not advice.
- **Everything pinned and reproducible:** toolchains, dependencies and tools through Nix, as `nix-flakes` describes.

## Your preferences

!`cat "${CLAUDE_SKILL_DIR}/../design-hygiene-language-choice.preferences.md" "${CLAUDE_PROJECT_DIR}/.agents/skills/design-hygiene-language-choice.preferences.md" 2>/dev/null || true`

If your agent doesn't run the line above, read these files yourself if they
exist: `design-hygiene-language-choice.preferences.md` next to this skill's folder, then
`.agents/skills/design-hygiene-language-choice.preferences.md` in the project. A project's
file overrides the user's, and the user's overrides this skill's defaults.

The keys this skill reads, with its own defaults:

```markdown
- Languages by role: none
```

`Languages by role` names roles from "Suggestions by role", each with
its languages first to last, such as `Scripts and glue: Babashka, OCaml;
Long-running services: Elixir`. Each named role's languages replace the
skill's suggestions for it; roles it doesn't name keep them. A project's
entry for a role replaces the user's for that role.

## Related skills

When one of these applies and it's in your skill listing, load it
without asking. If it isn't in your listing, tell the user which skill is
missing and ask whether to install it from the same collection this skill
came from; don't apply it from memory.

- `design-hygiene-ideal-then-compromise`: the recorded compromise taken in place of writing a missing library.
- `design-hygiene-parsers-over-regular-expressions`: the parser to read each format with, per language.
- `nix-flakes`: pinning toolchains and dependencies in a flake.
- `python-hygiene-functional-style`: the style and standard-library tier of the portable Python layer.
- `shell-hygiene-commands-as-cli-tools`: turning bash beyond small glue into a named, tested tool.
