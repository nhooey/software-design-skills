{
  description = "design-hygiene-parsers-over-regular-expressions: Agent skill — read and write structured text (YAML, JSON, TOML, Markdown, HTML, shell command lines, Nix, CSV, URLs, dates, git and gh output, source code) with the format's own parser for the language at hand, never a regular expression, awk or string templates";

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
      skillName = "design-hygiene-parsers-over-regular-expressions";
      src = ./.;
    };
}
