# software-design-skills

Agent skills for how software is designed, in any language, packaged as a
Nix flake: what an application does for its users, such as how it reads its
configuration. Each skill is a directory under `skills/` with a `SKILL.md`,
its own `flake.nix` and `flake.lock`, built by agent-skill-flake.

## Build and test

Enter the dev shell with `nix develop`; it installs the dev-shell skills
from `skills-devshell/` into `.agents/skills/`, and `menu` lists its
commands.

- `check`: `nix flake check`, the treefmt check and the bats suite.
- `fmt`: nixfmt, prettier, shfmt and shellcheck over the tree.
- `design-skills test`: the bats suite under `tests/` alone; `--help` lists
  its other commands, `list` and `update-locks`.
