#!/usr/bin/env bats
# Argument parsing and skill discovery of scripts/design-skills.sh, run
# against a throwaway repository root so no command reaches nix or bats.

bats_require_minimum_version 1.5.0
bats_load_library bats-support
bats_load_library bats-assert

TOOL="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/scripts/design-skills.sh"

setup() {
  export PRJ_ROOT="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$PRJ_ROOT/skills/beta-skill" "$PRJ_ROOT/skills/alpha-skill" "$PRJ_ROOT/skills/not-a-skill"
  touch "$PRJ_ROOT/skills/beta-skill/SKILL.md" "$PRJ_ROOT/skills/alpha-skill/SKILL.md"
}

@test "--help lists every command token" {
  run "$BASH" "$TOOL" --help
  assert_success
  assert_output --partial "test [BATS_ARGS...]"
  assert_output --partial "list"
  assert_output --partial "update-locks [-n] [SKILL...]"
}

@test "no command prints usage and exits 2" {
  run --separate-stderr "$BASH" "$TOOL"
  assert_failure 2
  [[ "$stderr" == *"Usage: design-skills"* ]]
}

@test "an unknown command exits 2" {
  run --separate-stderr "$BASH" "$TOOL" frobnicate
  assert_failure 2
  [[ "$stderr" == *"unknown command: frobnicate"* ]]
}

@test "each command has its own --help" {
  local command
  for command in test list update-locks; do
    run "$BASH" "$TOOL" "$command" --help
    assert_success
    assert_output --partial "Usage: design-skills $command"
  done
}

@test "list prints only directories with a SKILL.md, sorted" {
  run "$BASH" "$TOOL" list
  assert_success
  assert_output "$(printf 'alpha-skill\nbeta-skill')"
}

@test "list rejects arguments" {
  run "$BASH" "$TOOL" list extra
  assert_failure 2
}

@test "update-locks --dry-run names every skill when none is given" {
  run "$BASH" "$TOOL" update-locks --dry-run
  assert_success
  assert_output "$(printf 'nix flake update --flake %s\n' "$PRJ_ROOT/skills/alpha-skill" "$PRJ_ROOT/skills/beta-skill")"
}

@test "update-locks -n names only the skills given" {
  run "$BASH" "$TOOL" update-locks -n beta-skill
  assert_success
  assert_output "nix flake update --flake $PRJ_ROOT/skills/beta-skill"
}

@test "update-locks rejects a skill that does not exist" {
  run --separate-stderr "$BASH" "$TOOL" update-locks -n not-a-skill
  assert_failure 2
  [[ "$stderr" == *"no skill named not-a-skill"* ]]
}

@test "update-locks rejects an unknown option" {
  run "$BASH" "$TOOL" update-locks --force
  assert_failure 2
}
