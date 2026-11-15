# software-design-skills

Agent skills for how software is designed, in any language, packaged as a
Nix flake.

Each skill names one design rule an application should follow, when it
applies, and how to check that it holds. They cover what the software does
for its users, such as how it reads its configuration, rather than how a
coding agent works, which `coding-agent-skills` covers.

Each skill is a self-contained directory under [`skills/`](skills/) with a
`SKILL.md` that an agent loads on demand. Skills are built by
[`agent-skill-flake`](https://github.com/nhooey/agent-skill-flake).

## Skills

| Skill                                                                                | What it does                                                                                                                                                                           |
| ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`config-hygiene-shipped-defaults`](skills/config-hygiene-shipped-defaults/SKILL.md) | One complete, commented defaults file shipped with the application, and sparse user config merged over it, with layers, merge rules, validation, provenance and per-format trade-offs. |

## Install

```bash
# Preview what installing every skill would change, without writing anything
nix run github:nhooey/software-design-skills#preview

# Install all skills into the agent's skill directory
nix run github:nhooey/software-design-skills#install
```

Package outputs:

- `agent-skills-nhooey-software-design-all` — the aggregate of every skill (also `default`)
- `agent-skill-nhooey-config-hygiene-shipped-defaults`

## Development

```bash
nix develop      # enter the dev shell; run `menu` to list commands
nix fmt          # nixfmt over *.nix, prettier over *.md / *.yaml
nix flake check  # runs the treefmt check (fails on any unformatted file)
```
