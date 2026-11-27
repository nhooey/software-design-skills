{
  description = "design-hygiene-refactoring-and-prefactoring: Agent skill — refactor at the points the project has chosen, asked once and saved when it hasn't, never changing behaviour and never in the same commit as the change it prepares";

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
      skillName = "design-hygiene-refactoring-and-prefactoring";
      src = ./.;
    };
}
