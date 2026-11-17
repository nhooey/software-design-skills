---
name: software-design-declarative-reconciliation
description: Model a system as desired state reconciled against observed state, through a semantic diff, a plan of operations with postconditions and an idempotent apply, over state kept in a normal form. Covers keeping declared and observed state apart (Kubernetes' spec and status), idempotency, plans as a dependency graph of operations each with a precondition and a postcondition, observing again and verifying after each operation, canonical serialisation so a textual diff equals the semantic one, total configuration with provenance, and plan previews as a product feature, with a worked example. Use when designing or reviewing a tool that makes something match a declaration (infrastructure, configuration, desktop or session state, package sets, repository settings), or when a system's "sync", "restore" or "apply" mixes what is wanted with what is there.
---

# Declarative reconciliation

_Model a system as desired state reconciled against observed state, through a semantic diff, a plan of operations with postconditions and an idempotent apply, over state kept in a normal form._

A tool that runs steps ("create the bucket, then set its policy") breaks
the second time it runs, and can't say what it will do before it does
it. A tool that declares the end state and reconciles towards it can do
both. When a step-by-step tool already exists, its desired state is
there implicitly; `design-hygiene-find-implicit-models` finds it.

## Desired against observed

- **Two states, kept apart:** the desired state is what the user
  declared; the observed state is what is there, read fresh from the
  system. Neither is written into the other. Kubernetes names the pair
  `spec` and `status`.
- **Reconcile in three phases:**
  1. **Diff:** desired against observed, by stable identity, into
     changes (create, destroy, update, move).
  2. **Plan:** the changes turned into operations.
  3. **Apply:** the operations run.
- **The observed state is never cached as truth:** read it again before
  each plan. A stale observation plans changes already made.

## Idempotency

Applying the same plan twice changes nothing the second time, and a
diff taken right after a successful apply is empty. Each operation
checks its postcondition first and skips itself when it already holds,
so a rerun after a partial failure finishes the job instead of
repeating it.

## Plans

A plan is a dependency graph of operations, not a script:

- **Each operation has a precondition and a postcondition,** stated as
  checkable claims: "needs session `work` to exist", "creates pane P".
- **Edges come from what operations need and create:** an operation
  depends on the one that creates what it needs. Independent branches
  run in parallel.
- **Observe again after each operation and verify its postcondition.**
  Later operations target what the earlier one actually created, and a
  failed postcondition stops its dependants, not the whole plan.
- **Report every skipped and failed operation** at the end, against the
  desired state.

## Normal forms

Serialise state canonically: keys sorted, defaults made explicit or
uniformly omitted, one spelling per value, stable ordering of lists
whose order means nothing. Then a textual diff of two states is the
semantic diff, and a state file under version control changes only when
its meaning does.

## Total configuration with provenance

The desired state is total: every setting has a value, from the shipped
defaults or a layer over them, and each value carries the layer it came
from. A diff can then say why a value is wanted, not only what it is.
`config-hygiene-shipped-defaults` covers the layers and the effective
config.

## Semantic diffs as a product feature

Show the plan before applying it, as a preview a user reads and
accepts: each change as `key: old → new`, grouped by the thing it
touches, with the operations' cost and disruption flagged (a restart, a
data loss). The preview comes from the same plan the apply runs, never
from a separate estimate. `writing-hygiene-declarative-statements`
covers the notation.

## Worked example

browsicle's `docs/plugin-architecture.md` applies this to desktop and
session state across plugins:

- §2, principles 5 and 6: capabilities declared up front, and ambiguity
  reported rather than guessed.
- §6.2: the operations `observe`, `plan`, `apply` and `verify`, with
  `apply` idempotent.
- §9.1: the diff by permanent identity.
- §9.2: the plan as a dependency graph, joined from what each operation
  needs and creates.
- §9.3: applying in dependency order, observing again after each
  operation, failures skipping only their dependants.
- §10.2: inherited preferences shown with their effective value and its
  source, provenance in a user interface.
- §10.3: closing and opening as plans, previewed as a diff.
- §11, Testing: a conformance suite checking that capture, close, apply
  and observe give an equal node, and that `apply` is idempotent.

## Credit

The `spec` and `status` vocabulary is Kubernetes', from its
[API conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#spec-and-status)
(Apache-2.0).

## When to apply

- Designing a tool that makes a system match a declaration.
- Reviewing a "sync", "restore" or "apply" command that runs steps, or
  that can't preview what it will do.
- A state file whose diffs are noisy with changes that mean nothing.

## Related skills

When one of these applies and it's in your skill listing, load it
without asking. If it isn't in your listing, tell the user which skill is
missing and ask whether to install it from the same collection this skill
came from; don't apply it from memory.

- `config-hygiene-shipped-defaults`: the total, layered configuration, with provenance, that the desired state is built from.
- `design-hygiene-find-implicit-models`: finding the state and state machine a step-by-step tool keeps implicitly, before declaring it.
- `writing-hygiene-declarative-statements`: the before → after notation and postconditions a plan preview is written in.
