{
  description = "design-hygiene-ideal-then-compromise: Agent skill — design the ideal solution with no regard for the status quo, then put each compromise that ships sooner to the user as a decision, and record every one taken as a plan node so it can be made ideal later";

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
      skillName = "design-hygiene-ideal-then-compromise";
      src = ./.;
    };
}
