{
  description = "design-hygiene-one-list-element-per-line: Agent skill — write a list, array or set literal of more than one element in code or config one element per line, and keep it that way under nixfmt, prettier, black and ruff";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agent-skill-flake.url = "github:nhooey/agent-skill-flake";
    agent-skill-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, agent-skill-flake, ... }:
    agent-skill-flake.lib.mkSkillFlake {
      inherit nixpkgs;
      source = import ../../source.nix;
      skillName = "design-hygiene-one-list-element-per-line";
      src = ./.;
    };
}
