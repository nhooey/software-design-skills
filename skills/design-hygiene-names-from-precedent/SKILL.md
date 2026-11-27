---
name: design-hygiene-names-from-precedent
description: Before coining a name for a tool, command, option, config key, file, package, function, type or concept, check what the wider ecosystem and the immediate stack already call the same thing, and use that name with its meaning. Covers the two layers of precedent (peer projects in the problem space, and the language, framework or tool's own idioms), where to look for each kind of name, how long the check takes, what to do when precedents conflict or none fits, never reusing a known name for a different meaning, and showing the precedent beside every proposed name. Use before naming anything a reader or user will see, when offering name candidates for someone to pick, and when reviewing a diff, design or plan that introduces a name.
---

# Names from precedent

_Before coining a name, find what the ecosystem already calls the thing and use that. A reader who knows the field should recognise the name without learning it._

## When to apply

- Naming a tool, command, subcommand, flag, config key, environment variable, file, directory, package, attribute, function, type, or a concept in docs.
- Offering name candidates for someone to choose from.
- Reviewing a diff, design or plan that introduces a name.

Branch names follow `git-hygiene-branch-naming` instead; they name a change, not a thing.

## The rule

1. **Describe the thing's shape in plain words** first: what it takes, what it gives back, what it is for. "Combines several packages into one file tree" is a shape; "skillpack" is a name.
2. **Check two layers of precedent** for that shape:
   - **The wider ecosystem:** what peer projects in the same problem space call it. A collection of agent skills is "skills" across peer collections, so a new word for it is noise.
   - **The immediate stack:** what the language, framework, tool or project already calls the same operation. Nix combines packages into one tree with `pkgs.buildEnv` and `pkgs.symlinkJoin` and names constructors `mk…`, so a helper of that shape is `mkSkillsEnv`, not `assembleSkillpack`.
3. **Use the precedent's name, and its meaning with it.** A name borrowed from precedent promises the precedent's behaviour; a helper named after `buildEnv` takes and returns what `buildEnv` does.
4. **Coin a new word only when no precedent fits,** and then make it a plain description of the shape, not jargon.
5. **Never reuse a known name for a different meaning.** A `--force` that skips a prompt in one tool and deletes data in another misleads everyone who knows the first.

Every new word costs each reader, user and downstream consumer the time to learn it, and splits the vocabulary of the field. A name from precedent costs nothing to learn.

## Where precedent lives

| Kind of name             | Look at                                                                                                                                                   |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Command-line flag        | The GNU and POSIX conventions (`--verbose`, `--quiet`, `--dry-run`, `--force`, `--output`, `--help`, `--version`) and the flags of the closest peer tools |
| Subcommand               | Peer tools of the same kind: `init`, `add`, `list`, `show`, `remove`, `update`, `check`, `fmt`                                                            |
| Config key               | The keys peer applications use for the same setting, and the format's own conventions for case and nesting                                                |
| Environment variable     | The tool's own prefix, and standard ones it should honour rather than shadow: `XDG_CONFIG_HOME`, `NO_COLOR`, `EDITOR`, `PAGER`                            |
| File or directory        | Well-known names: `README.md`, `CHANGELOG.md`, `LICENSE`, `.editorconfig`, `flake.nix`, the XDG base directories                                          |
| Package or attribute     | The package set's naming rules, such as nixpkgs' `pname`, `version` and `mk…` builders, and how peer packages of the same kind are named                  |
| Function, type or module | The language's standard library and the framework's API for the same shape of operation                                                                   |
| Concept in docs or a UI  | The term the field's standard, specification or most-read documentation uses                                                                              |

## How to check

A minute is usually enough:

- Search peer repositories for the shape and the candidate name, such as `gh search code` or a web search.
- Skim the stack's standard library or package set (nixpkgs, the language's docs) for the analogous operation.
- Search the project itself, so a new name matches its existing vocabulary.

## Proposing a name

- **A clear winner:** lead with the precedent's name and say which precedent it follows.
- **Precedents conflict,** such as the wider ecosystem and the stack using different words: list both, with where each is used, and ask.
- **No precedent:** say that the check found none and what it searched, then propose a plain descriptive name.
- **Several candidates:** give each one's precedent, or say that it has none, so the choice weighs the divergence on purpose.

Never propose a name without having done the check.

## Checking it holds

In a review, for each name the change introduces:

- Is there a precedent for the shape, and does the name match it?
- If the name matches a known one, does the behaviour match too?
- Does a new word have a reason written down, in the PR or design, for why no precedent fits?

## Related skills

When one of these applies and it's in your skill listing, load it
without asking. If it isn't in your listing, tell the user which skill is
missing and ask whether to install it from the same collection this skill
came from; don't apply it from memory.

- `git-hygiene-branch-naming`: how to name a branch, which names a change rather than a thing.
