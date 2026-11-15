---
name: config-hygiene-shipped-defaults
description: Give an application one complete defaults file that ships with it and lists every setting with its default and a comment, and a user config that names only what it changes and is merged over the defaults. Covers where defaults live (never in code), the merge rules (maps merge, lists replace, how to unset), layering (defaults, system, user, project, environment, flags), validation and unknown keys, showing the effective config and where each value came from, testing that the defaults file is complete, and choosing a format, with how TOML, YAML, JSON and others differ for this job. The user's preferences pick the format and the other house rules. Use when adding configuration to an application or tool, adding or renaming a setting, reviewing how a program reads its config, or when defaults are scattered through code or copied into users' files.
---

# Complete shipped defaults, sparse user overrides

_Every setting has its default in one file that ships with the application, with a comment saying what it does. A user's config names only what it changes, and the application merges it over the defaults._

## The rule

- **One defaults file, complete:** it lists every setting the application reads, set to its default, each with a comment saying what it does, its allowed values and its unit. Reading it tells a user everything they can configure.
- **It ships inside the package:** it's installed with the program, next to its code or in its data directory, and read from there on every start. It's never copied into the user's directory, where it would freeze the defaults of the version that copied it.
- **No defaults in code:** the code reads every value from the merged config and has no fallback of its own. A default written in two places drifts, and the file stops being the truth.
- **The user's file is sparse:** it holds only what the user changed. A new version's new settings and changed defaults then reach every user, and the user's file reads as a list of their decisions.
- **Merging is defined, not accidental:** see [Merging](#merging).

## Layers

Later layers override earlier ones:

| Layer       | Where                                              | Who writes it      |
| ----------- | -------------------------------------------------- | ------------------ |
| Defaults    | the shipped defaults file                          | the application    |
| System      | `/etc/<app>/`, or what a system module generates   | the administrator  |
| User        | `$XDG_CONFIG_HOME/<app>/` (`~/.config/<app>/`)     | the user           |
| Project     | a file in the working tree, such as `.<app>.<ext>` | the project        |
| Environment | `<APP>_<SECTION>_<KEY>` variables                  | the session        |
| Flags       | command-line options                               | the one invocation |

Use only the layers the application needs; a tool with no projects has no project layer. Every layer except the defaults is sparse, and every layer has the same shape, so one merge function handles them all.

## Merging

- **Maps merge key by key, recursively:** a user who sets one key in a section keeps the section's other defaults.
- **Lists replace whole:** a list in a later layer replaces the earlier list. Appending looks friendly but leaves no way to remove a default entry, and two layers appending give an order nobody chose.
- **When users need to change one entry, make it a map:** a list of named things, such as servers, profiles or rules, becomes a map keyed by name, so a user can override or disable one entry without restating the rest. Give each entry an `enabled` key rather than relying on deletion.
- **Unsetting needs a spelling:** a user may need to clear a default that has a value. Formats with a null use it to mean "no value"; formats without one, such as TOML, need an explicit value the setting documents, such as an empty string or `"none"`. Never treat a missing key as "unset": missing means "use the default".
- **Scalars replace:** a later string, number or boolean replaces the earlier one, after type checking.

## Validation

- **Validate the merged result** against one schema, so every layer is held to the same types and ranges, and report the file and key of the bad value.
- **Unknown keys are reported:** a misspelt key in a user's file otherwise silently does nothing. Fail on an unknown key or warn about it, as the preferences say, and suggest the closest known key.
- **Deprecated keys keep working for a while:** read the old name, warn with the new one, and map it in the merge, until a stated version.

## Seeing what's in effect

Ship two commands, or the equivalent options:

- **The defaults:** print the shipped defaults file, comments and all, so a user can start from it.
- **The effective config:** print the merged result, with the layer each value came from, such as `ui.theme = "dark"  # user: ~/.config/app/config.toml`. This answers "why is it doing that?" without reading code.

## Testing

- **The defaults file parses and passes the schema.**
- **It's complete:** every key the schema defines is in the defaults file, and every key in the file is in the schema. Where the code reads keys through one accessor, check the keys it reads against the file too.
- **Every key has a comment**, in formats that allow comments.
- **The merge rules hold:** a sparse user file changes only its keys, a list replaces, a map entry overrides by name, and the unset spelling clears a value.
- **An empty user config is valid** and gives exactly the defaults.

## Choosing a format

The preferences name the format. Where they don't, or the application already has one, keep what it has. What matters for this job: comments, so the defaults file documents itself; a null, for unsetting; how deep nesting reads; typing surprises; and tools that keep comments when they rewrite a file.

| Format | Comments | Null   | Deep nesting               | Pitfalls for config                                                                                                                               |
| ------ | -------- | ------ | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| TOML   | ✅       | ❌     | verbose past two levels    | No null, so unsetting needs a documented value. Arrays of tables (`[[x]]`) are easy to misread.                                                   |
| YAML   | ✅       | ✅     | reads well                 | Implicit typing (YAML 1.1 reads `no` as false, `010` as octal, `1.10` as a float). Indentation errors. Anchors hide values. Many parser dialects. |
| JSON   | ❌       | ✅     | reads well, noisy to write | No comments, so a complete defaults file can't document itself. No trailing commas.                                                               |
| JSONC  | ✅       | ✅     | as JSON                    | Not every JSON parser reads it.                                                                                                                   |
| Others | varies   | varies | varies                     | Nix, EDN, HCL, KDL or a language's own config DSL fit when the application already speaks it.                                                     |

- **TOML** suits flat to two-level config that people edit by hand. Its dates and times are native types.
- **YAML** suits deep or list-heavy config. Quote strings that could parse as something else, and parse as YAML 1.2 where the library allows it.
- **JSON** suits config that programs write more than people do. Put the documentation in the schema's `description` fields and print it with the defaults command.
- **Whatever the format,** describe the schema in JSON Schema or the language's own schema library. Editors such as Taplo for TOML and yaml-language-server for YAML use a JSON Schema for completion and checking.
- **Rewriting a user's file:** if the application ever edits the user's config, use a library that keeps comments and order, such as tomlkit for TOML or ruamel.yaml for YAML, and write only the keys it changes.

## Your preferences

!`cat "${CLAUDE_SKILL_DIR}/../config-hygiene-shipped-defaults.preferences.md" "${CLAUDE_PROJECT_DIR}/.agents/skills/config-hygiene-shipped-defaults.preferences.md" 2>/dev/null || true`

If your agent doesn't run the line above, read these files yourself if they
exist: `config-hygiene-shipped-defaults.preferences.md` next to this skill's folder, then
`.agents/skills/config-hygiene-shipped-defaults.preferences.md` in the project. A project's
file overrides the user's, and the user's overrides this skill's defaults.

The keys this skill reads, with its own defaults:

```markdown
- Format: keep the application's current format; TOML for a new one
- Unknown keys: fail
- List merge: replace
- Unset value: null where the format has one; otherwise documented per setting
- Layers: defaults, user, environment, flags
- Environment prefix: the application's name in capitals, then `_`
- Effective-config command: `config show`, with `--defaults` for the shipped file
```

## When to apply

- Adding configuration to an application or tool, or adding, renaming or removing a setting.
- Reviewing how a program reads its config, or finding defaults written in code.
- A user's config that is a full copy of the defaults, or docs that list settings the defaults file doesn't.

## Related skills

When one of these applies and it's in your skill listing, load it
without asking. If it isn't in your listing, tell the user which skill is
missing and ask whether to install it from the same collection this skill
came from; don't apply it from memory.

- `coding-agent-skill-references`: the preferences files this skill reads, and where a user's choice goes rather than in the skill.
- `shell-hygiene-secrets-through-secretspec`: secrets never go in a defaults or user config file; they're read through SecretSpec.
