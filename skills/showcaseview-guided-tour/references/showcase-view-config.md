# showcaseview: `ShowcaseView` configuration and control

Verified against `lib/src/showcase/showcase_view.dart`, `showcase_service.dart`
and `lib/src/models/`.

## `ShowcaseView.register(...)`

Creates a `ShowcaseView` for a scope and returns it. Every argument is
optional.

| Parameter | Default | Notes |
|---|---|---|
| `scope` | internal default scope | Name of this registration; see scope rules in `SKILL.md` |
| `onStart` | `null` | `(int? index, GlobalKey key)` when a step is shown |
| `onComplete` | `null` | `(int? index, GlobalKey key)` when a step is left, forward or backward |
| `onFinish` | `null` | After the last step, or when a forward step has no mounted target |
| `onDismiss` | `null` | `(GlobalKey? dismissedAt)` on `dismiss()` or the Skip action; `null` key when no step was active |
| `skipIfTargetNotPresent` | `false` | Skip steps whose `Showcase` is not mounted instead of ending the tour |
| `enableShowcase` | `true` | `false` turns tours off; `startShowCase` then asserts in debug |
| `autoPlay` | `false` | Advances after `autoPlayDelay` |
| `autoPlayDelay` | 2000 ms | A step's own `autoPlayDelay` wins |
| `enableAutoPlayLock` | `false` | `next()` (without `force: true`) does nothing; barrier and target taps still advance |
| `enableAutoScroll` | `false` | A step's own value wins |
| `scrollDuration` | 300 ms | |
| `disableBarrierInteraction` | `false` | |
| `disableScaleAnimation` | `false` | |
| `disableMovingAnimation` | `false` | |
| `blurValue` | `0` | A step's own value wins; ignored on web |
| `overlayColor` | `null` | When set, wins over every step's `overlayColor` |
| `overlayOpacity` | `null` | When set, wins over every step's `overlayOpacity` |
| `globalTooltipActions` | `null` | `List<TooltipActionButton>` for every step without its own `tooltipActions` |
| `globalTooltipActionConfig` | `null` | Layout of the actions for steps without their own config |
| `globalFloatingActionWidget` | `null` | `FloatingActionWidget Function(BuildContext)` shown on every step |
| `hideFloatingActionWidgetForShowcase` | `[]` | Keys of steps that hide the global floating widget |
| `semanticEnable` | `false` | Live-region semantics for tooltips and actions |

`autoPlay`, `autoPlayDelay`, `enableAutoPlayLock`, `enableAutoScroll`,
`scrollDuration`, `blurValue`, the three `disable...` flags, `enableShowcase`
and the `global...` fields are mutable on the instance. Change the keys that
hide the floating widget with `hideFloatingActionWidgetForKeys(list)`.

## Getting an instance

| Call | Returns |
|---|---|
| `ShowcaseView.register(...)` | The new instance (keep it) |
| `ShowcaseView.get()` | The active scope's instance; throws if none is registered |
| `ShowcaseView.getNamed('profile')` | The instance of that scope; throws if not registered |

## Methods and getters

| Member | Behavior |
|---|---|
| `startShowCase(keys, {delay})` | Starts at index 0 after `delay`. Runs in the scope that holds the keys |
| `next({force})` | Next step, or finishes after the last. No-op while `enableAutoPlayLock` unless `force: true` |
| `previous()` | Previous step; no-op on the first |
| `completed(key)` | Advances only if `key` is the active step |
| `dismiss()` | Ends the tour, calls `onDismiss` and dismiss listeners (not `onFinish`) |
| `unregister()` | Removes the scope, hides the overlay, cancels auto play, clears listeners |
| `updateOverlay()` | Rebuilds the overlay (after layout changes during a step) |
| `isTargetRendered(key)` | `true` when a `Showcase` with that key is mounted in this scope |
| `isShowcaseRunning` | A step is active |
| `isShowCaseCompleted` | `true` whenever no tour is running, including before the first start |
| `getActiveShowcaseKey` | Key of the active step or `null` |
| `hiddenFloatingActionKeys` | Keys that hide the global floating widget |
| `addOnStartCallback`, `addOnCompleteCallback` | Take `OnShowcaseCallback = void Function(int?, GlobalKey)` |
| `addOnFinishCallback` | Takes `VoidCallback` |
| `addOnDismissCallback` | Takes `OnDismissCallback = void Function(GlobalKey?)` |
| `removeOn...Callback` | Pass the same function reference that was added |

## `TooltipActionButton`

```dart
const TooltipActionButton({
  required TooltipDefaultActionType type, // next, previous, skip
  String? name,                // default: 'Next' / 'Previous' / 'Skip'
  VoidCallback? onTap,         // replaces the type's behavior
  Color? backgroundColor,      // default: Theme.of(context).primaryColor
  TextStyle? textStyle,
  BorderRadius? borderRadius,  // default: circular(50)
  EdgeInsets? padding,         // default: symmetric(horizontal: 15, vertical: 4)
  Border? border,
  ActionButtonIcon? leadIcon,
  ActionButtonIcon? tailIcon,
  List<GlobalKey> hideActionWidgetForShowcase = const [], // global actions only
});

const TooltipActionButton.custom({
  required Widget button,      // you handle taps, e.g. ShowcaseView.get().next()
  List<GlobalKey> hideActionWidgetForShowcase = const [],
});
```

`ActionButtonIcon(icon: Icon(...))` and
`ActionButtonIcon.withImageIcon(icon: ImageIcon(...))`, both with optional
`padding`.

## `TooltipActionConfig`

| Parameter | Default | Notes |
|---|---|---|
| `position` | `TooltipActionPosition.inside` | `outside`, `inside` (below the text), `insideLeft`, `insideRight` (stacked vertically) |
| `alignment` | `MainAxisAlignment.spaceBetween` | |
| `actionGap` | `5` | Between buttons |
| `gapBetweenContentAndAction` | `10` | |
| `crossAxisAlignment` | `CrossAxisAlignment.start` | `stretch` is not allowed (assert) |
| `mainAxisSize` | `MainAxisSize.max` | |
| `textBaseline` | `null` | Required only for baseline alignment |

On `Showcase.withWidget`, actions are always drawn in a separate box next to
the custom tooltip, whatever `position` says.

## `FloatingActionWidget`

`FloatingActionWidget({required child, left, top, right, bottom, width,
height})` is a `Positioned` wrapped around a transparent `Material`.
`FloatingActionWidget.directional(textDirection:, start:, end:, ...)` mirrors
for RTL. Pass at most two of the three horizontal values and two of the three
vertical values.

## Callback order for one step change

`next()` / `previous()` → `onComplete(leaving index)` → `onStart(new index)`;
past the last step → `onComplete(last)` → `onFinish()`. `dismiss()` →
`onDismiss(active key)` only.
