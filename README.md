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

| Skill                                                                                                      | What it does                                                                                                                                                                                                                          |
| ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`config-hygiene-shipped-defaults`](skills/config-hygiene-shipped-defaults/SKILL.md)                       | One complete, commented defaults file shipped with the application, and sparse user config merged over it, with layers, merge rules, validation, provenance and per-format trade-offs.                                                |
| [`design-hygiene-find-implicit-models`](skills/design-hygiene-find-implicit-models/SKILL.md)               | Find the lifecycles, sources of truth, message protocols, bounds and supervisors a codebase runs without naming them, write each down with evidence, and make one explicit only where that deletes branches, flags or illegal states. |
| [`software-design-declarative-reconciliation`](skills/software-design-declarative-reconciliation/SKILL.md) | Desired state reconciled against observed state, through a semantic diff, a plan of operations with postconditions and an idempotent apply, over state in a normal form.                                                              |

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
- `agent-skill-nhooey-design-hygiene-find-implicit-models`
- `agent-skill-nhooey-software-design-declarative-reconciliation`

## Development

Enter the dev shell with `nix develop`; `menu` lists its commands, each
with a one-line help:

- `check`: `nix flake check`, the treefmt check and the bats suite.
- `fmt`: nixfmt over `*.nix`, prettier over `*.md` and `*.yaml`, shfmt
  and shellcheck over `*.sh`.
- `design-skills test`: the bats suite under `tests/` alone.
- `design-skills list`: the skills under `skills/`.
- `design-skills update-locks [SKILL...]`: each skill's own `flake.lock`.
- `update-flake`, `update-skills-devshell`: the root and dev-shell skill
  locks.
