# software-design-skills

Agent skills for how software is designed, in any language, packaged as a
Nix flake: what an application does for its users, such as how it reads its
configuration. Each skill is a directory under `skills/` with a `SKILL.md`,
its own `flake.nix` and `flake.lock`, built by agent-skill-flake.

## Build and test

- `nix develop`: enter the dev shell, which installs the dev-shell skills
  from `skills-devshell/` into `.agents/skills/`; `menu` lists its commands.
- `nix fmt`: nixfmt over `*.nix`, prettier over `*.md` and `*.yaml`.
- `nix flake check`: the treefmt check, which fails on any unformatted file.
