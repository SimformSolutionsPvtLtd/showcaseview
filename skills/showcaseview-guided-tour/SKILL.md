---
name: showcaseview-guided-tour
description: >-
  Build and customize a step-by-step feature tour (app onboarding, coach marks,
  feature highlights) with the showcaseview package: register ShowcaseView,
  wrap widgets with Showcase or Showcase.withWidget, start a tour with
  startShowCase, and control it with next, previous and dismiss. Covers tooltip
  styling and position, tooltip actions (TooltipActionButton,
  TooltipActionConfig), floating action widgets, custom tooltips, auto play,
  auto scroll, multi-showcase, callbacks (onStart, onComplete, onFinish,
  onDismiss), named scopes for several screens, and skipping targets that are
  not on screen. Use when adding, changing or debugging a showcase tour, or
  when code uses ShowcaseView, Showcase, TooltipActionButton or
  FloatingActionWidget.
---

# showcaseview: build a guided tour

showcaseview dims the screen, cuts a hole around a target widget and shows a
tooltip next to it, one step at a time. A tour is a list of `GlobalKey`s: each
key identifies a `Showcase` widget in the tree, and `startShowCase` walks the
list in order. All control goes through `ShowcaseView` (registered once, no
`BuildContext` needed). `ShowCaseWidget` is deprecated: for code that uses it,
use the `showcaseview-migration` skill.

## Workflow

1. **Inspect the project first.** Find the screens the tour covers, how they
   navigate (Navigator, go_router, tabs), where state lives, and whether
   `ShowCaseWidget` or `ShowcaseView` is already used (if `ShowCaseWidget`
   is, migrate first). Check whether the app already remembers that the user
   has seen onboarding (for example shared_preferences): showcaseview keeps
   no such flag.
2. **Add the dependency** if missing: `flutter pub add showcaseview`. Never
   hard-code a version.
3. **Register, wrap, start** as in **Basic**. Pick the tour's steps and give
   each target a `Showcase` with a `GlobalKey` stored in a `State` field.
4. Look up options and defaults in `references/showcase-parameters.md` and
   `references/showcase-view-config.md`; more recipes (tour per screen,
   remembering completion, custom tooltip, scrolling lists) are in
   `references/examples.md`.
5. Run `flutter analyze`, then run the app and walk the whole tour: next,
   back, skip, tapping the dimmed area, tapping the target, and leaving the
   screen mid-tour.

## Rules

Registration and lifecycle:

- Import only `package:showcaseview/showcaseview.dart`.
- Register before any `Showcase` of that scope is built: `Showcase` resolves
  its scope in `initState` and throws "No ShowcaseView is registered"
  otherwise. Register in `main()` for an app-wide setup, or in `initState`
  of the screen that owns the targets. Never register in `build`.
- Keep the instance `register` returns and call its `unregister()` in
  `dispose`. `ShowcaseView.get()` returns the *active* scope, which can be
  another screen's. `unregister()` hides the overlay, cancels auto play and
  clears callbacks added with `addOn...Callback`.
- A scope name maps to one `ShowcaseView`: a second `register` with the same
  scope replaces the first, and unregistering either removes the scope for
  both. Two screens that are alive at the same time (a pushed route over the
  first) must use different scope names (see **Scopes**).
- Create the `GlobalKey`s once, as `State` fields, never inside `build`.
- Start the tour after the first frame so the targets are mounted:
  `WidgetsBinding.instance.addPostFrameCallback((_) => view.startShowCase([...]))`.
  Add `delay:` when the screen is animating in (route transition).
- A step whose key has no mounted `Showcase` **ends the whole tour** at once
  (`onFinish` fires) when moving forward; moving backward to it does not.
  Targets in another tab, behind a
  condition, or in a lazy list item that isn't built are not mounted. Start
  the tour only with keys that are on screen, or register the view with
  `skipIfTargetNotPresent: true` to skip them silently. Check a single key
  with `view.isTargetRendered(key)`.
- The key is only a registry id: don't use the same `GlobalKey` on another
  widget, and don't rely on `key.currentContext` (it is `null`).
- `startShowCase` asserts (debug builds) when `enableShowcase: false`; guard
  the call. Only one tour overlay exists at a time.

Showcase widgets:

- `Showcase` needs `title` or `description` (assert). For a fully custom
  tooltip use `Showcase.withWidget(container: ...)`: it has no title,
  description, text style or background parameters, so give the container
  its own decoration and size, and it draws no arrow.
- Never pass `height`/`width` to `Showcase.withWidget` (removed in 5.0.0).
- The same key on several `Showcase` widgets shows them **together** (multi
  showcase). The first one's barrier and overlay settings apply, and auto
  scroll doesn't work for it.
- `onTargetClick` and `disposeOnTap` must be set together or not at all
  (asserts). By default tapping the highlighted target advances the tour;
  with `onTargetClick` your callback **replaces** the advance, and
  `disposeOnTap: true` additionally dismisses the tour.
- Tapping the dimmed barrier advances too. Disable it per `Showcase` or on
  `ShowcaseView.register(disableBarrierInteraction: true)`.
  `onBarrierClick` can't be combined with `disableBarrierInteraction: true`
  on the same `Showcase`.
- `disableDefaultTargetGestures: true` makes the target ignore taps, so
  `onTargetClick`, `onTargetDoubleTap`, `onTargetLongPress` and
  `disposeOnTap` stop working. Dismiss manually if the user can navigate away.
- The target's own taps are blocked while its step is shown: the overlay sits
  above it. Use `onTargetClick` to run the target's action.

Tooltip actions and floating widgets:

- Action types are `TooltipDefaultActionType.next`, `.previous` and `.skip`
  (the type in some older docs, `TooltipActionButtonType`, does not exist).
  `next` ignores the auto play lock; `skip` calls `dismiss()`.
- `Showcase.tooltipActions` **replaces** `globalTooltipActions` for that
  step: it doesn't merge. `hideActionWidgetForShowcase` only works on global
  actions. The same holds for `tooltipActionConfig` vs
  `globalTooltipActionConfig`.
- A `TooltipActionButton` without `backgroundColor` uses
  `Theme.of(context).primaryColor`, and without `textStyle` the default text
  style: set both so the label is readable.
- `Showcase.floatingActionWidget` takes a `FloatingActionWidget` value;
  `globalFloatingActionWidget` takes a builder `(context) => FloatingActionWidget(...)`.
  `FloatingActionWidget` is a `Positioned` with a `Material`, so use its
  `left/right/top/bottom` (not a `Positioned`). The per-step widget wins over
  the global one; `hideFloatingActionWidgetForShowcase` hides only the
  global one.

Callbacks and control:

- `onStart(index, key)` fires when a step is shown, `onComplete(index, key)`
  when it is left (forward **and** backward), `onFinish()` after the last
  step, `onDismiss(key)` on `dismiss()` or Skip. `dismiss()` does not call
  `onFinish`: record "tour seen" in both.
- Add or remove listeners at runtime with `addOnStartCallback`,
  `addOnCompleteCallback`, `addOnFinishCallback`, `addOnDismissCallback` and
  the matching `remove...` (pass the same function reference to remove).
- `next()` does nothing while `enableAutoPlayLock` is on, unless
  `force: true`. `previous()` does nothing on the first step.
- When the user can leave the screen during a tour, call `dismiss()` first
  (or `disposeOnTap: true` on targets that navigate); `unregister()` also
  hides the overlay.

Appearance:

- `ShowcaseView.overlayColor`/`overlayOpacity`, when set, win over each
  `Showcase`'s values. `blurValue` on a `Showcase` overrides the view's, and
  blur is ignored on web.
- Default tooltip colors are light (white background, black text): set
  `tooltipBackgroundColor`, `textColor` or the text styles for dark themes.
- Auto scroll (`enableAutoScroll`, global or per `Showcase`) uses
  `Scrollable.ensureVisible`, so the target must already be built, and it
  can't help for a lazy list item that isn't: a forward step to it ends the
  tour before `onStart` runs. Scroll first, wait a frame, then start or
  advance (`references/examples.md`).
- Set `semanticEnable: true` on the view to expose tooltips to screen readers.

Scopes:

- A named scope (`register(scope: 'profile')`) becomes the *active* scope:
  `ShowcaseView.get()` returns it, and any `Showcase` built later **without**
  `scope:` joins it. Pass `scope: 'profile'` to its `Showcase` widgets, use
  the returned instance or `ShowcaseView.getNamed('profile')`, and
  `unregister()` it when its screen closes so `get()` returns the previous
  scope again.
- `startShowCase` finds keys that belong to another scope and runs the tour
  in that scope.

## Basic

Register on the screen that owns the targets, start after the first frame,
unregister on dispose.

```dart
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _addKey = GlobalKey();
  late final ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(
      onFinish: () => debugPrint('Tour finished'),
      onDismiss: (key) => debugPrint('Tour dismissed at $key'),
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showcaseView.startShowCase([_menuKey, _addKey]),
    );
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: Showcase(
          key: _menuKey,
          title: 'Menu',
          description: 'Open the menu to see more options',
          child: const Icon(Icons.menu),
        ),
      ),
      floatingActionButton: Showcase(
        key: _addKey,
        title: 'Add',
        description: 'Create a new item',
        child: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
      body: const Center(child: Text('Home')),
    );
  }
}
```

Tour with Previous / Next / Skip buttons on every step. The first step hides
Previous and the last hides Next (`hideActionWidgetForShowcase` works only for
global actions):

```dart
_showcaseView = ShowcaseView.register(
  globalTooltipActionConfig: const TooltipActionConfig(
    position: TooltipActionPosition.inside,
    alignment: MainAxisAlignment.spaceBetween,
  ),
  globalTooltipActions: [
    TooltipActionButton(
      type: TooltipDefaultActionType.previous,
      textStyle: const TextStyle(color: Colors.white),
      hideActionWidgetForShowcase: [_menuKey],
    ),
    TooltipActionButton(
      type: TooltipDefaultActionType.next,
      textStyle: const TextStyle(color: Colors.white),
      hideActionWidgetForShowcase: [_addKey],
    ),
  ],
  globalFloatingActionWidget: (context) => FloatingActionWidget(
    right: 16,
    top: 48,
    child: ElevatedButton(
      onPressed: () => _showcaseView.dismiss(),
      child: const Text('Skip'),
    ),
  ),
);
```

Custom tooltip: `Showcase.withWidget` draws only what `container` returns.

```dart
Showcase.withWidget(
  key: _addKey,
  targetShapeBorder: const CircleBorder(),
  container: Container(
    width: 220,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      'Tap here to create something new',
      style: TextStyle(color: Colors.white),
    ),
  ),
  child: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.add),
  ),
)
```

## Check before finishing

- `flutter analyze` is clean and no code uses `ShowCaseWidget`,
  `ShowCaseWidget.of(context)` or `TooltipActionButtonType`.
- Every `register` has a matching `unregister` in `dispose` (or lives for the
  whole app, registered once in `main`).
- Every key passed to `startShowCase` belongs to a `Showcase` that is mounted
  when the tour starts.
- The tour was run end to end on a device or emulator, including skip and
  back, and leaving the screen mid-tour leaves no overlay behind.
