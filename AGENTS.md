# ShowCaseView: maintainer guide for coding agents

These instructions are for working **on** the `showcaseview` package. Guidance
for apps that **use** it ships in the package's `skills/` directory.

## Layout

| Path | Owns |
|---|---|
| `lib/showcaseview.dart` | Public library: the only file that decides what is exported from `src/` |
| `lib/src/showcase/` | `Showcase` widget, `ShowcaseView` (registration, tour control, callbacks), `ShowcaseService` (scopes), `ShowcaseController` (one per mounted `Showcase`) |
| `lib/src/showcase_widget.dart` | `ShowCaseWidget`, deprecated wrapper around `ShowcaseView` (removed in 6.0.0) |
| `lib/src/models/` | `TooltipActionButton`, `TooltipActionConfig`, `ActionButtonIcon`, internal scope and position models |
| `lib/src/utils/` | Enums (`TooltipPosition`, `TooltipActionPosition`, `TooltipDefaultActionType`), `OverlayManager`, constants |
| `lib/src/tooltip/`, `lib/src/widget/` | Tooltip layout and rendering, `FloatingActionWidget`, action buttons |
| `example/` | Example app (also deployed as the web demo) |
| `doc/documentation.md` | Full documentation, published on the documentation site |
| `skills/` | Agent skills shipped to users (see below) |

## Keep these in sync with any change

When a public API, parameter, default or behavior changes, update in the same
PR:

1. `doc/documentation.md` (and `README.md` if it is affected).
2. `CHANGELOG.md` under the top entry (use `## [Unreleased]` until the
   version bump), in the existing `Feature` / `Fixed` / `Breaking` style.
   Breaking changes also need a migration guide entry in
   `doc/documentation.md`.
3. `example/`.
4. **`skills/`** (see below). Skills ship to users with the package, so a stale
   skill makes their coding agents write broken code. A breaking change must
   also be added to the `showcaseview-migration` skill.

## Package skills (`skills/`)

The package publishes agent skills following
[Dart package skills](https://dart.dev/tools/pub/package-skills). Users
install them with `dart run skills@ get`.

| Skill | User task |
|---|---|
| `showcaseview-guided-tour` | Build and customize a step-by-step tour with `ShowcaseView` and `Showcase` |
| `showcaseview-migration` | Upgrade an app from its current `showcaseview` version to the latest |

Rules:

- One skill per user task, not per class. Add a new skill only for a new task,
  otherwise extend the existing one.
- Directory name = frontmatter `name` = `showcaseview-<topic>`. Lowercase,
  digits and single hyphens only; the `skills` CLI silently skips names
  without the `showcaseview-` prefix.
- Frontmatter: `name` and `description` only. The description says what the
  skill does and when to use it (max 1024 characters).
- Keep `SKILL.md` under 500 lines. Move long tables to `references/` and link
  them with a relative path from the skill root (`references/x.md`).
- Write rules an agent can follow, and complete Dart examples that compile.
  State behavior verified in `lib/`, not what the docs claim: the docs have
  had mistakes (for example a `TooltipActionButtonType` that does not exist).
- `showcaseview-migration`: every breaking CHANGELOG entry gets a before/after
  entry in the reference file for its release, verified against the code at
  the release tags. Changes not yet released go under a "From < next release"
  heading of `references/5.x-to-latest.md`; when releasing, rename it to
  `From < X.Y.Z`, and update the versions documented in the skills (for
  example the version index in `SKILL.md`).
- When `ShowCaseWidget` is removed in 6.0.0, drop it from the skills' "before"
  guidance and add a `references/5.x-to-6.0.0.md` that makes the `ShowcaseView`
  move mandatory.
- `skills/` must not be excluded by `.gitignore` or a `.pubignore`.

Validate with [`skills_lint`](https://pub.dev/packages/skills_lint). It needs a
recent Dart SDK, so do **not** add it as a dev dependency; install it globally
instead:

```bash
dart pub global activate skills_lint
```

Run from the repository root:

```bash
dart pub global run skills_lint --ignore-config -d skills --check-relative-paths --check-relative-paths-within-skill=true --published-skill-name --published-skill-name-pubspec_path=pubspec.yaml --pub-archive-includes-skill --check-trailing-whitespace --disallowed-field
```

To test an install, create a throwaway Flutter app, add `showcaseview` with a
`path:` dependency, run `dart run skills@ get --all --agent claude`, and check
`.claude/skills/`. Only **direct** dependencies are scanned. Compile the
skills' Dart examples there with `flutter analyze`.

## Verifying changes

Run what CI runs (`.github/workflows/flutter.yaml`) before opening a PR:

```bash
flutter pub get
dart format --set-exit-if-changed .
dart analyze
flutter pub publish --dry-run
```

For widget changes, also run `example/` and walk the whole tour.

## Pull requests

Branch from `master` and follow `.github/pull_request_template.md`: a
Conventional Commit title (`feat:`, `fix:`, `docs:`; add `!` for breaking
changes), and migration instructions for breaking changes.
