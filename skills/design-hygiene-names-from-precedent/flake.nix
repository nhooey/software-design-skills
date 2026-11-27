{
  description = "design-hygiene-names-from-precedent: Agent skill — before coining a name for a tool, option, file, package or concept, check what the wider ecosystem and the immediate stack already call it, and use that name with its meaning";

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
      skillName = "design-hygiene-names-from-precedent";
      src = ./.;
    };
}
