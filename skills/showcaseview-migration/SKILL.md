---
name: showcaseview-migration
description: >-
  Upgrade a Flutter app from any older showcaseview version (1.x, 2.x, 3.x,
  4.x) to the latest release and fix every breaking change in order. Use when
  upgrading or bumping showcaseview, when `flutter analyze` fails after a
  showcaseview upgrade, when moving from the deprecated ShowCaseWidget to
  ShowcaseView.register, or when code uses removed or renamed API such as
  `ShowCaseWidget(`, `ShowCaseWidget.of(context)`, `builder: Builder(`,
  `activeTargetWidget`, `getCurrentActiveShowcaseKey`, `titleAlignment:
  TextAlign`, `descriptionAlignment: TextAlign`, `Showcase.withWidget(` with
  `height:` or `width:`, `key.currentContext` on a showcase key,
  `autoPlayLockEnable`, `disableAnimation`, `shapeBorder:`,
  `showcaseBackgroundColor`, `overlayPadding`, `tipBorderRadius`,
  `contentPadding` or `animationDuration`.
---

# showcaseview: migrate to the latest version

showcaseview had breaking releases at 2.0.0, 3.0.0, 4.0.0 and 5.0.0. The
5.0.0 change is the largest: tours are controlled through
`ShowcaseView.register()` and `ShowcaseView.get()` instead of the
`ShowCaseWidget` widget and `ShowCaseWidget.of(context)`. `ShowCaseWidget`
still works in 5.x but is deprecated and **removed in 6.0.0**. The references
list every change with what to search for, and before and after code.

## Workflow

1. **Detect the current version.** Read the resolved `showcaseview` version
   in `pubspec.lock` (fall back to the constraint in `pubspec.yaml`). In a
   monorepo, do this for every package that depends on showcaseview.
2. **Find usages.** Search the app (`lib/`, `test/`, `integration_test/`) for
   `package:showcaseview` imports and for the identifiers listed in each
   reference you will apply. Report the version, the releases to cross and
   what you found **before editing**.
3. **Upgrade the dependency:** `flutter pub upgrade --major-versions showcaseview`.
   Never hard-code a version. If resolution fails, see "SDK requirements"
   below.
4. **Apply each release's changes in order**, starting with the first release
   after the app's version, using the version index below. Read the whole
   reference for every range you cross; within a reference, skip sections
   whose "From < X" is at or below the app's version.
5. Run `flutter analyze` and fix every remaining error and warning, including
   deprecations from showcaseview (`deprecated_member_use` on `ShowCaseWidget`
   members).
6. Run `dart run skills@ get` so the app's coding agents get the skills of the
   new version. It needs Dart 3.10 or later: if the app's SDK is older, skip
   this step and tell the user to upgrade Flutter and run it later.
7. Report what changed, plus the behavior changes the user should test (see
   "Check after migrating").

For building or changing tours in the new version, use the
`showcaseview-guided-tour` skill.

## Rules

- Import only `package:showcaseview/showcaseview.dart`.
- The "after" snippets are written against the latest version. When a later
  release changes the same code again, writing the latest form directly is
  correct; still read every crossed reference, because each one also has
  changes the others don't.
- Moving from `ShowCaseWidget` to `ShowcaseView` is a **recommended** step,
  not a compile error in 5.x. If the user wants a minimal upgrade, finish the
  compile fixes first and offer the `ShowcaseView` move separately; it is
  mandatory before 6.0.0.
- Don't stop at a clean `flutter analyze`. These changes compile but behave
  differently; check them whenever the range is crossed:
  - < 5.0.0: `key.currentContext` and `key.currentWidget` on a showcase key
    are `null` (the key is no longer attached to the widget).
  - < 5.0.0: with `ShowcaseView`, a screen that is not unregistered leaves its
    scope behind (see `references/4.x-to-5.0.0.md`).
  - < 5.1.0: a forward step with no mounted `Showcase` now ends the tour.
- Keep app behavior: translate each `ShowCaseWidget` argument one to one
  into `ShowcaseView.register`; don't change defaults or add options the app
  didn't use.
- Don't invent replacements for removed parameters that had none; delete them
  and tell the user.

## Version index

| Crossing | Reference | Summary |
|---|---|---|
| 1.x → 2.0.0 | `references/1.x-to-2.0.0.md` | `Showcase` and `ShowCaseWidget` parameters renamed (`shapeBorder` → `targetShapeBorder`, `animationDuration` → `movingAnimationDuration`, `autoPlayLockEnable` → `enableAutoPlayLock`, …), `Showcase.withWidget` lost its title and style parameters |
| 2.x → 4.0.0 | `references/2.x-to-4.0.0.md` | 3.0.0: `ShowCaseWidget.builder` takes a `WidgetBuilder` instead of `Builder`, Dart 2.18. 4.0.0: `titleAlignment` / `descriptionAlignment` (`TextAlign`) → `titleTextAlign` / `descriptionTextAlign` |
| 3.x/4.x → 5.0.0 | `references/4.x-to-5.0.0.md` | `ShowCaseWidget` deprecated in favor of `ShowcaseView.register()` / `get()` / `unregister()`, `Showcase.withWidget` `height` and `width` removed, key no longer attached to the target, Dart 3.0 |
| 5.0.x → latest | `references/5.x-to-latest.md` | 5.0.2 scopes on `Showcase`, new callbacks; 5.1.0 `isTargetRendered`, tour ends when a forward target is missing |

Example: an app on 3.0.0 applies `references/2.x-to-4.0.0.md` from the
"From < 4.0.0" section on, then `references/4.x-to-5.0.0.md`, then
`references/5.x-to-latest.md`.

## SDK requirements

| Since | Requirement | Action |
|---|---|---|
| 1.0.0 | Null safety, Dart ≥ 2.12 | |
| 2.1.0 | Dart upper bound `<4.0.0` | |
| 3.0.0 | Dart ≥ 2.18 | |
| 5.0.0 | Dart ≥ 3.0.0 | raise `environment: sdk:` in the app's `pubspec.yaml` to at least `^3.0.0` and use Flutter 3.10 or later |

## Check after migrating

Tell the user to test these on a device, for the ranges crossed:

- The tour starts, advances, goes back and finishes on every screen that has
  one, and Skip / dismiss leaves no dimmed overlay behind (< 5.0.0).
- Leaving a screen during a tour, then returning to it (registration and
  `unregister` placement, < 5.0.0).
- Two screens with tours open at the same time, for example a pushed route
  (scope names, < 5.0.0).
- Tooltips built with `Showcase.withWidget` look right without `height` and
  `width` (< 5.0.0).
- Steps whose target may be missing (tabs, conditional widgets): the tour
  ends or skips as intended (< 5.1.0).
