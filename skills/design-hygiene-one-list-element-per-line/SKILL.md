---
name: design-hygiene-one-list-element-per-line
description: Write a list, array or set literal with more than one element in code or config one element per line, never packed several to a line by line width. Covers which literals it applies to (Nix lists and attribute sets, JSON and TOML arrays, YAML sequences, Python, JavaScript and shell lists), the one exception for a fixed-arity tuple such as a coordinate, and how it works with formatters, where nixfmt enforces it, prettier joins JSON, JavaScript and YAML flow lists that fit the line and so needs block YAML or a prettier-ignore comment, and black and ruff keep a list expanded when it ends in a trailing comma. Use when writing or reviewing a list literal in source code, a config file, a manifest or a code example in docs, and when setting up a formatter that would reflow one.
---

# One list element per line

_A list literal with more than one element puts each element on its own line. Each element is an item, so it gets a line, whatever its length._

## When to apply

- Writing a list, array or set literal with two or more elements: in source code, a config file, a manifest, or a code example in docs or a skill.
- Reviewing a diff that adds or edits one.
- Choosing or configuring a formatter for a project.

## The rule

1. **More than one element: one per line,** with the closing bracket on its own line, even when every element would fit on one.
2. **One element stays on one line:** `[ "a" ]`.
3. **Never pack by width.** Several short elements to a line, broken where the line runs out, put the break at an arbitrary place and hide where one item ends and the next begins.
4. **A fixed-arity tuple is not a list.** A coordinate `[x, y]`, a range's two ends or a version triple has positions with meanings, not items, and stays on one line.

One element per line makes each item visible on its own, keeps a diff to one line per item added or removed, and lets a sort, a merge or a `git blame` work per item.

```nix
{
  inputs = [
    "nixpkgs"
    "flake-parts"
    "systems"
  ];
}
```

## Which literals

| Format         | One element per line                         |
| -------------- | -------------------------------------------- |
| Nix            | lists `[ … ]` and attribute sets `{ … }`     |
| JSON, JSON5    | arrays                                       |
| TOML           | arrays                                       |
| YAML           | block sequences (`- a`), never flow `[a, b]` |
| Python         | lists, sets, tuples of items                 |
| JavaScript, TS | arrays, and objects with more than one key   |
| Shell          | arrays, `( … )` with one word per line       |

A Nix function's argument pattern `{ a, b, ... }:` and an `inherit a b;` are not list literals and stay on one line.

## Working with formatters

A formatter that owns a file has the last word on its layout, since the project's format check fails on anything else. Find out what it does with a list before relying on it:

- **nixfmt enforces the rule.** It puts every list of two or more elements, and every attribute set with a binding, one per line, and keeps a single-element list on one line. In Nix, write the list either way and let nixfmt lay it out.
- **prettier undoes it** for JSON and JavaScript arrays and YAML flow sequences: it joins the elements onto one line whenever the literal fits the print width, and has no option to keep them apart. It does keep a JavaScript or JSON object expanded when there is a newline after its `{`, and keeps a YAML block sequence one item per line. Inside Markdown it formats `json`, `yaml` and `js` fences the same way, and leaves fences in languages it doesn't format, such as `nix`, as written.
- **black and ruff format** keep a collection one element per line when its last element has a trailing comma (the magic trailing comma), and join it otherwise. Write the trailing comma.

Under prettier:

- **YAML:** write block sequences, which prettier keeps.
- **A list where the layout matters,** such as one edited often: put `// prettier-ignore` on the line before the statement in JavaScript, TypeScript, JSONC or JSON5, `# prettier-ignore` before the key in YAML, and `<!-- prettier-ignore -->` before a fence in Markdown.
- **A plain `.json` file,** which can't hold a comment: accept prettier's layout, or leave the file out of prettier's includes in the treefmt config.

A formatter that keeps whatever layout it is given, such as gofmt for composite literals, leaves the rule to the writer.

## Checking it holds

- Run the project's formatter, then look for a literal of two or more elements still on one line in a file the formatter doesn't reflow.
- In review, a packed list in a file no formatter owns is a finding; a packed list a formatter produced points at the formatter setup above.

## Related skills

When one of these applies and it's in your skill listing, load it
without asking. If it isn't in your listing, tell the user which skill is
missing and ask whether to install it from the same collection this skill
came from; don't apply it from memory.

- `nix-flakes`: setting up treefmt and its formatters in a flake.
