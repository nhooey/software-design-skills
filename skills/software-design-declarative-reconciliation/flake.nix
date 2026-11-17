{
  description = "software-design-declarative-reconciliation: Agent skill — model a system as desired state reconciled against observed state, through a semantic diff, a plan of operations with postconditions and an idempotent apply";

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
      skillName = "software-design-declarative-reconciliation";
      src = ./.;
    };
}
