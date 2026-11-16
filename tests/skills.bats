#!/usr/bin/env bats
# Repository-wide rules for the skills under skills/: the frontmatter an
# installer and a model read, and the links a reader follows.

bats_require_minimum_version 1.5.0
bats_load_library bats-support
bats_load_library bats-assert

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

# Print the value of one key from a SKILL.md's leading `---` frontmatter.
frontmatter_value() {
  awk -v key="$2" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    index($0, key ": ") == 1 { print substr($0, length(key) + 3); exit }
  ' "$1"
}

# Print each heading's GitHub anchor: lower-cased, punctuation dropped,
# spaces turned into dashes.
heading_anchors() {
  awk '/^```/ { fence = !fence } !fence && /^#+ / { sub(/^#+ +/, ""); print }' "$1" |
    tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9 _-]//g' -e 's/ /-/g'
}

@test "every skill's SKILL.md frontmatter name matches its directory" {
  local skill_md count=0
  for skill_md in "$REPO_ROOT"/skills/*/SKILL.md; do
    assert_equal "$(frontmatter_value "$skill_md" name)" "$(basename "$(dirname "$skill_md")")"
    count=$((count + 1))
  done
  ((count > 0))
}

@test "every skill's SKILL.md has a description in its frontmatter" {
  local skill_md
  for skill_md in "$REPO_ROOT"/skills/*/SKILL.md; do
    run frontmatter_value "$skill_md" description
    assert_output --regexp '.{40,}'
  done
}

@test "every relative link in a tracked Markdown file reaches a file or heading" {
  local md target path anchor
  for md in "$REPO_ROOT"/*.md "$REPO_ROOT"/skills/*/*.md; do
    while IFS= read -r target; do
      case "$target" in http://* | https://* | mailto:*) continue ;; esac
      path="${target%%#*}"
      anchor=""
      [[ "$target" == *"#"* ]] && anchor="${target#*#}"
      if [[ -n "$path" ]]; then
        [[ -e "$(dirname "$md")/$path" ]] || fail "$md links to missing $path"
      fi
      if [[ -n "$anchor" ]]; then
        local file="$md"
        [[ -n "$path" ]] && file="$(dirname "$md")/$path"
        heading_anchors "$file" | grep -qxF -- "$anchor" ||
          fail "$md links to missing heading #$anchor in $file"
      fi
    done < <(grep -o '\]([^)]*)' "$md" | sed -e 's/^](//' -e 's/)$//')
  done
}
