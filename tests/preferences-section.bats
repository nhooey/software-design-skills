#!/usr/bin/env bats
# The "Your preferences" section of each skill: its `!` command line reads
# the user's preferences file and then the project's from an installed skill.
#
# An installed skill's folder is often a symlink into the Nix store,
# `~/.claude/skills/<skill> -> /nix/store/…/<skill>`, with the user's
# `<skill>.preferences.md` beside the link. Claude Code puts the link's path
# in place of `${CLAUDE_SKILL_DIR}`, so the line must find the user's file
# through that path as written, not through the folder the link points to.

bats_require_minimum_version 1.5.0
bats_load_library bats-support
bats_load_library bats-assert

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

# Print the command of a SKILL.md's `!` line: a line that is an exclamation
# mark and one code span.
command_line() {
  awk '/^!`[^`]*`$/ { print substr($0, 3, length($0) - 3) }' "$1"
}

@test "every preferences line reads the user's file beside a symlinked skill folder, then the project's, and prints nothing without them" {
  local skill_md skill line script store skills project count=0
  for skill_md in "$REPO_ROOT"/skills/*/SKILL.md; do
    grep -qxF '## Your preferences' "$skill_md" || continue
    skill="$(basename "$(dirname "$skill_md")")"
    line="$(command_line "$skill_md")"
    [[ -n "$line" && "$line" != *$'\n'* ]] || fail "$skill_md has no single preferences command line"

    store="$BATS_TEST_TMPDIR/$skill/nix/store/hash-skill/share/claude-skills/$skill"
    skills="$BATS_TEST_TMPDIR/$skill/home dir/.claude/skills"
    project="$BATS_TEST_TMPDIR/$skill/the project"
    mkdir -p "$store" "$skills" "$project/.agents/skills"
    ln -s "$store" "$skills/$skill"
    printf '%s\n' '- Never use: Brave Browser' >"$skills/$skill.preferences.md"
    printf '%s\n' '- Project: yes' >"$project/.agents/skills/$skill.preferences.md"

    # Claude Code's substitution is textual: the link's path as written.
    script="${line//"\${CLAUDE_SKILL_DIR}"/"$skills/$skill"}"
    script="${script//"\${CLAUDE_PROJECT_DIR}"/"$project"}"

    run "$BASH" -c "$script"
    assert_success || fail "$skill_md: the line fails with both files present"
    assert_output "$(printf '%s\n' '- Never use: Brave Browser' '- Project: yes')" ||
      fail "$skill_md: the line doesn't print the user's file, then the project's"

    rm -- "$skills/$skill.preferences.md" "$project/.agents/skills/$skill.preferences.md"
    run "$BASH" -c "$script"
    assert_success || fail "$skill_md: the line fails with neither file present"
    assert_output '' || fail "$skill_md: the line prints something with neither file present"
    count=$((count + 1))
  done
  ((count > 0))
}
