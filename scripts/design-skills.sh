#!/usr/bin/env bash
# design-skills: the commands this repository's skills are developed with.
# Exit statuses: 0 success, 1 a command it ran failed, 2 a usage error.

set -euo pipefail

prog="design-skills"

usage() {
  cat <<EOF
Usage: $prog <command> [options]

Commands:
  test [BATS_ARGS...]          Run the bats suite under tests/
  list                         Print the name of every skill under skills/
  update-locks [-n] [SKILL...] Update each skill's own flake.lock (all if none named)

Options:
  -h, --help                   Show this help, or a command's help after it

The flake-wide commands are separate dev-shell commands: check, fmt,
update-flake and update-skills-devshell.
EOF
}

usage_test() {
  cat <<EOF
Usage: $prog test [BATS_ARGS...]

Run the bats suite under tests/ directly, without building the whole
flake check. Arguments are passed to bats, such as --filter REGEX.
EOF
}

usage_list() {
  cat <<EOF
Usage: $prog list

Print the name of every skill under skills/, one per line, sorted.
EOF
}

usage_update_locks() {
  cat <<EOF
Usage: $prog update-locks [-n|--dry-run] [SKILL...]

Run \`nix flake update\` in each named skill's directory, or in every
skill's directory when none is named. The root flake.lock is update-flake's.

Options:
  -n, --dry-run   Print the commands instead of running them
EOF
}

die_usage() {
  printf '%s: %s\n' "$prog" "$1" >&2
  printf "Run '%s --help' for usage.\n" "$prog" >&2
  exit 2
}

# The repository root: the dev shell's PRJ_ROOT, else git's top level.
repo_root() {
  if [[ -n ${PRJ_ROOT:-} ]]; then
    printf '%s\n' "$PRJ_ROOT"
  else
    git rev-parse --show-toplevel
  fi
}

# Every directory under skills/ holding a SKILL.md, by name, sorted.
skill_names() {
  local root skill_md
  root="$(repo_root)"
  for skill_md in "$root"/skills/*/SKILL.md; do
    [[ -e $skill_md ]] || continue
    basename "$(dirname "$skill_md")"
  done | LC_ALL=C sort
}

cmd_test() {
  case "${1:-}" in -h | --help)
    usage_test
    return 0
    ;;
  esac
  local root
  root="$(repo_root)"
  bats --print-output-on-failure "$@" "$root/tests"
}

cmd_list() {
  case "${1:-}" in
  -h | --help)
    usage_list
    return 0
    ;;
  "") ;;
  *) die_usage "list takes no arguments: $1" ;;
  esac
  skill_names
}

cmd_update_locks() {
  local dry_run=0
  local -a skills=()
  while (($# > 0)); do
    case "$1" in
    -h | --help)
      usage_update_locks
      return 0
      ;;
    -n | --dry-run) dry_run=1 ;;
    --)
      shift
      skills+=("$@")
      break
      ;;
    -*) die_usage "unknown option for update-locks: $1" ;;
    *) skills+=("$1") ;;
    esac
    shift
  done

  local -a known=()
  mapfile -t known < <(skill_names)
  if ((${#skills[@]} == 0)); then
    skills=("${known[@]}")
  fi

  local skill
  for skill in "${skills[@]}"; do
    [[ " ${known[*]} " == *" $skill "* ]] || die_usage "no skill named $skill under skills/"
  done

  local root
  root="$(repo_root)"
  for skill in "${skills[@]}"; do
    if ((dry_run)); then
      printf 'nix flake update --flake %s\n' "$root/skills/$skill"
    else
      nix flake update --flake "$root/skills/$skill"
    fi
  done
}

main() {
  if (($# == 0)); then
    usage >&2
    exit 2
  fi
  local command="$1"
  shift
  case "$command" in
  -h | --help) usage ;;
  test) cmd_test "$@" ;;
  list) cmd_list "$@" ;;
  update-locks) cmd_update_locks "$@" ;;
  *) die_usage "unknown command: $command" ;;
  esac
}

main "$@"
