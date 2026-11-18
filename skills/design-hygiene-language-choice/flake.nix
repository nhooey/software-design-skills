{
  description = "design-hygiene-language-choice: Agent skill — choose the language and style of any program, library, service, tool or script by its role, functional languages first, stdlib Python only as the portable port for people without Nix, never a language picked for its popularity, written as a pure functional core in a thin effectful shell";

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
      skillName = "design-hygiene-language-choice";
      src = ./.;
    };
}
