---
name: design-hygiene-parsers-over-regular-expressions
description: Read, edit and write structured text with the format's own parser and serializer, chosen for the language and framework at hand, never with a regular expression, awk, cut, sed or a string template. Covers YAML and frontmatter, JSON, TOML, Markdown, HTML and XML, shell command lines, Nix and flake.lock, CSV, URLs, dates, git and gh output, file and process listings, and source code (tree-sitter or the language's AST), with a table of parsers per format and language, the order to pick one in, the cases where a regex is fine, the inputs that break a regex, and checks a project can add to enforce the rule. Use before writing a regex, grep, sed, awk or split over a file or command output with a grammar, when parsing frontmatter, a manifest, a lock file, a config file or a command line, when generating YAML, TOML, JSON or HTML from strings, and when reviewing code or a script that does any of these.
---

# Parsers over regular expressions

_A format with a grammar is read with its parser and written with its serializer. A regular expression reads one spelling of the data and breaks on the next._

## When to apply

- About to write `re.`, `grep`, `sed`, `awk`, `cut`, `split(":")` or a string template over text that has a grammar.
- Reading frontmatter, a manifest, a config file, a lock file, a command line or a tool's output in code or a script.
- Generating YAML, TOML, JSON, HTML or a shell command by concatenating strings.
- Reviewing a diff, script or skill that does any of the above.

## The rule

1. **Name the format** before writing the code that reads it. Output meant for people (`git status`, `gh pr list`, `ls -l`) is a format with no stable grammar; ask the tool for a machine format instead.
2. **Parse it with the format's parser** into data, and work on the data.
3. **Write it back with the format's serializer**, never by pasting values into a template. A title holding `"` or a newline is data to a serializer and a syntax error to a template.
4. **Edit it in place with a round-trip parser** where comments and layout must survive: ruamel.yaml, tomlkit, `yq -i`, rewrite-clj, libcst.
5. **A regex may then check a single scalar** the parser returned, such as a `name` value's allowed characters.

## Choosing the parser

Pick the first that fits the context:

1. The parser the codebase or tool already depends on.
2. The language's standard library: Python's `json`, `tomllib`, `csv`, `shlex`, `urllib.parse`, `ast`, `html.parser`.
3. A command-line parser already in the dev shell: `jq`, `yq`, `taplo`, `nix eval`.
4. A new dependency, added the way the project adds dependencies (its Nix package, lock file or `deps.edn`).

A context that forbids dependencies, such as a skill's bundled scripts on the standard library alone, calls a command-line parser as a subprocess for the formats the standard library lacks (YAML through `yq -o=json`), rather than hand-rolling one.

## Parsers by format and language

| Format                    | Command line                                                                            | Python                                                                       | Clojure and JVM                                 | Other                                                        |
| ------------------------- | --------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | ----------------------------------------------- | ------------------------------------------------------------ |
| YAML                      | `yq` (yq-go), `-o=json` to hand on to `jq`                                              | PyYAML `safe_load`; ruamel.yaml to edit                                      | clj-yaml                                        | JS: `yaml`                                                   |
| YAML frontmatter          | `yq --front-matter=extract`                                                             | split on the `---` delimiter lines, then the YAML parser; python-frontmatter | split on the delimiter lines, then clj-yaml     | JS: gray-matter                                              |
| JSON                      | `jq`                                                                                    | `json`                                                                       | cheshire, clojure.data.json                     | JS: `JSON.parse`; Nix: `builtins.fromJSON`                   |
| TOML                      | `taplo get`, `yq -p toml`                                                               | `tomllib` to read; tomlkit to edit, tomli-w to write                         | tomlj                                           | Nix: `builtins.fromTOML`                                     |
| Markdown                  | `pandoc -t json`                                                                        | markdown-it-py, mistune                                                      | nextjournal/markdown, commonmark-java           | JS: markdown-it, remark                                      |
| HTML                      | `htmlq`, `xmllint --html --xpath`                                                       | `html.parser`, BeautifulSoup, lxml                                           | hickory, jsoup                                  | JS: `DOMParser`                                              |
| XML                       | `xmllint --xpath`, `yq -p xml`                                                          | `xml.etree.ElementTree`, with defusedxml for untrusted input                 | clojure.data.xml                                | —                                                            |
| Shell command line        | `shfmt --to-json` for the full syntax tree                                              | `shlex.split`, `shlex.join` to build one                                     | —                                               | tree-sitter-bash; in bash, an array, never a string to split |
| Nix expression            | `nix eval --json`, `nix-instantiate --parse`                                            | `nix eval --json` as a subprocess                                            | —                                               | Nix: `builtins.fromJSON`; Rust: rnix                         |
| `flake.lock`, `flake.nix` | `jq` on `flake.lock`; `nix flake metadata --json`, `nix flake show --json`              | `json` on `flake.lock`                                                       | cheshire on `flake.lock`                        | —                                                            |
| CSV, TSV                  | DuckDB `read_csv`, Miller (`mlr`), `qsv`                                                | `csv`, DuckDB                                                                | clojure.data.csv                                | —                                                            |
| INI, `.gitconfig`         | `git config --file F --get`                                                             | `configparser`                                                               | —                                               | —                                                            |
| URL                       | —                                                                                       | `urllib.parse`                                                               | `java.net.URI`, lambdaisland/uri                | JS: `URL`                                                    |
| Date and time             | GNU `date --date`, with an explicit format                                              | `datetime.fromisoformat`, `zoneinfo`                                         | `java.time`                                     | JS: `Temporal`                                               |
| git output                | `--porcelain=v2 -z`, `--format` with `%x00`, `for-each-ref --format`, `rev-parse`, `-z` | the same flags through `subprocess`                                          | the same flags                                  | —                                                            |
| `gh` output               | `--json FIELDS --jq EXPR`, `gh api --jq`                                                | `--json` into `json`                                                         | `--json` into cheshire                          | —                                                            |
| File and process listings | `find -print0`, `stat`, `pgrep`, never `ls` or `ps` text                                | `pathlib`, `os.scandir`, psutil                                              | `java.nio.file`                                 | —                                                            |
| Source code               | tree-sitter, ast-grep                                                                   | `ast` to read; libcst to edit                                                | rewrite-clj to edit; clj-kondo analysis to read | TypeScript compiler API, Rust `syn`                          |

In bash, `read -r -a words <<< "$line"` splits on `IFS` and ignores quotes, so it isn't a command-line parser. Keep a command as an array from the start, or hand the string to `shlex.split` or `shfmt --to-json`.

## Inputs a regex gets wrong

Test any reader of structured text with these, and each is a reason the parser wins:

- **YAML:** a quoted value (`name: "x"`, `name: 'x'`), an indented or nested key, a trailing `# comment`, a block scalar (`description: >-` over several lines), a flow mapping, an anchor.
- **TOML:** a string holding `"`, `\` or a newline; a dotted key; a table header after the key you wanted.
- **JSON:** reordered keys, escaped quotes, a value spread over lines.
- **Markdown:** a fence inside a longer fence, a `~~~` fence, a fence indented in a list item, a `#` line inside a code block.
- **Shell:** quoted spaces, `$'…'`, escaped quotes, `;` and `&&` inside quotes.
- **CSV:** a comma, quote or newline inside a quoted field.
- **URLs:** userinfo, a port, an encoded `/`, a `#` after `?`.
- **Paths and listings:** names with spaces, newlines or a leading `-`.
- **git and gh:** a branch or title holding spaces, a renamed file, a localised human message.

## When a regex is fine

- **A flat token with a fixed grammar:** a semver, a SHA, a UUID, an issue number, a skill name such as `^[a-z0-9-]+$`, including one scalar a parser has already returned.
- **A quick interactive search** whose hits a person or agent reads, to find where to look. `grep -rn` over a repo is a search, not a parser, as long as nothing consumes its output as data.
- **A lexical lint rule** where the text itself is the subject: trailing whitespace, a banned word, a `TODO` marker, a line length.
- **A line format with no parser that the project owns and specifies,** such as its own log line, matched by one anchored pattern next to the code that writes it.

## Enforce it

Advice drifts; a check doesn't. Propose these to a project as checks in its lint or test suite, and build only the ones it accepts:

- **A Python lint** (ast-grep or Semgrep): a call to `re.*` or `str.split` in a function that also reads a path ending in `.yaml`, `.yml`, `.toml`, `.json`, `.lock` or `.md`, or the output of `subprocess` running `git`, `gh` or `ls`.
- **A shell lint:** `grep`, `sed`, `awk` or `cut` whose file operand is `*.json`, `*.yaml`, `*.toml`, `flake.lock` or `flake.nix`; `git status`, `git branch` or `git log` piped to text tools without `--porcelain`, `--format` or `-z`; `gh` piped to `grep` or `awk` without `--json`; `for f in $(ls …)`.
- **A template lint:** an f-string, heredoc or `printf` whose output is written to a `.yaml`, `.toml`, `.json` or `.html` file.
- **A fixture test** per reader, feeding the inputs above and asserting the same data comes out; for a writer, a round trip (parse, serialize, parse) that holds for every fixture.
- **An agent hook**, advisory and non-blocking, that flags the shell patterns above in a Bash call before it runs.

Each check flags a site for review rather than failing outright where a fixed-grammar token is a legitimate match; an inline allow comment naming the token's grammar silences it.

## Your preferences

!`cat "$(dirname "${CLAUDE_SKILL_DIR}")/design-hygiene-parsers-over-regular-expressions.preferences.md" "${CLAUDE_PROJECT_DIR}/.agents/skills/design-hygiene-parsers-over-regular-expressions.preferences.md" 2>/dev/null || true`

If your agent doesn't run the line above, read these files yourself if they
exist: `design-hygiene-parsers-over-regular-expressions.preferences.md` next to this skill's folder, then
`.agents/skills/design-hygiene-parsers-over-regular-expressions.preferences.md` in the project. A project's
file overrides the user's, and the user's overrides this skill's defaults.

The keys this skill reads, with its own defaults:

```markdown
- Parsers: the table's first fitting choice
- Enforcement: advise
```

- `Parsers` lists a chosen parser per format, such as `YAML: ruamel.yaml`, ahead of the table.
- `Enforcement` is `advise`, naming each regex over structured text in the reply or review, or `propose-checks`, also drafting the checks from "Enforce it" that the project lacks.

## Related skills

When one of these applies and it's in your skill listing, load it
without asking. If it isn't in your listing, tell the user which skill is
missing and ask whether to install it from the same collection this skill
came from; don't apply it from memory.

- `config-hygiene-shipped-defaults`: which config format to choose, and its parsing pitfalls.
- `coding-agent-skill-references`: the preferences files this skill reads.
- `github-hygiene-gh-cli-gotchas`: `gh` flags and their machine-readable output.
- `nix-flakes`: reading a flake's inputs and outputs through `nix` rather than its text.
- `python-hygiene-functional-style`: the standard-library tier a skill's bundled scripts keep to.
- `shell-hygiene-commands-as-cli-tools`: a parse run more than once becomes a tested command.
