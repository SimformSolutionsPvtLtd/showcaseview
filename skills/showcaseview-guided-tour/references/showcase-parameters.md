# showcaseview: `Showcase` parameters

Verified against `lib/src/showcase/showcase.dart`. Two constructors:

- `Showcase(key:, child:, title:/description:, ...)`: default tooltip.
- `Showcase.withWidget(key:, child:, container:, ...)`: you draw the tooltip.
  It has no title, description, text style, background, padding, arrow or
  scale animation parameters, and `height`/`width` no longer exist.

`key` is a `GlobalKey` and the only required identifier. A `null` default
below means "use the `ShowcaseView` value, or the built-in behavior".

## Content and tooltip look (default constructor only)

| Parameter | Default | Notes |
|---|---|---|
| `title`, `description` | `null` | At least one is required (assert) |
| `titleTextStyle`, `descTextStyle` | `null` | Fall back to the theme's `titleLarge` / `titleSmall` colored with `textColor` |
| `textColor` | `Colors.black` | Used only when the text styles are not set |
| `tooltipBackgroundColor` | `Colors.white` | Also colors the arrow |
| `titleTextAlign`, `descriptionTextAlign` | `TextAlign.start` | Text alignment (named `titleAlignment` before 4.0.0) |
| `titleAlignment`, `descriptionAlignment` | `Alignment.center` | Widget alignment inside the tooltip |
| `titlePadding`, `descriptionPadding` | `null` (zero) | |
| `titleTextDirection`, `descriptionTextDirection` | `null` | |
| `tooltipPadding` | `EdgeInsets.symmetric(vertical: 8, horizontal: 8)` | |
| `tooltipBorderRadius` | `null` (8) | |
| `showArrow` | `true` | `Showcase.withWidget` never shows one |
| `onToolTipClick` | `null` | Tap on the default tooltip |

## Custom tooltip (`Showcase.withWidget` only)

| Parameter | Notes |
|---|---|
| `container` | Required. Drawn as is: no background, padding or arrow. Give it a decoration and a size |

## Target highlight

| Parameter | Default | Notes |
|---|---|---|
| `targetShapeBorder` | rounded rectangle, radius 8 | Use `CircleBorder()` for round targets |
| `targetBorderRadius` | `null` | When set, it replaces the `targetShapeBorder` shape for the hit area |
| `targetPadding` | `EdgeInsets.zero` | Grows the highlighted area |
| `targetTooltipGap` | `10` | Space between target and tooltip, `>= 0` |
| `onTargetRectUpdate` | `null` | `ValueSetter<Rect>` called whenever the target rect is recalculated |

## Overlay

| Parameter | Default | Notes |
|---|---|---|
| `overlayColor` | `Colors.black45` | `ShowcaseView.overlayColor` wins when set |
| `overlayOpacity` | `0.75` | 0.0 to 1.0 (assert). `ShowcaseView.overlayOpacity` wins when set |
| `blurValue` | `null` (view's, 0) | Ignored on web |
| `scrollLoadingWidget` | progress indicator | Shown while auto scroll runs |

## Position and animation

| Parameter | Default | Notes |
|---|---|---|
| `tooltipPosition` | `null` (adaptive) | `TooltipPosition.top`, `.bottom`, `.left`, `.right` |
| `toolTipMargin` | `14` | Minimum distance from the screen edge |
| `toolTipSlideEndDistance` | `7` | Range of the moving animation |
| `movingAnimationDuration` | 2000 ms | Bounce loop of the tooltip |
| `disableMovingAnimation` | `null` (view's, false) | |
| `disableScaleAnimation` | `null` (view's, false) | Always off for `Showcase.withWidget` |
| `scaleAnimationDuration` | 300 ms | Default constructor only |
| `scaleAnimationCurve` | `Curves.easeIn` | Default constructor only |
| `scaleAnimationAlignment` | `null` (computed) | Default constructor only |
| `autoPlayDelay` | `null` (view's, 2 s) | Per-step visibility time when auto play is on |

## Interaction

| Parameter | Default | Notes |
|---|---|---|
| `onTargetClick` | `null` | Replaces "advance to next step"; needs `disposeOnTap` |
| `disposeOnTap` | `null` | `true` dismisses the tour, then runs `onTargetClick`; needs `onTargetClick` |
| `onTargetDoubleTap`, `onTargetLongPress` | `null` | |
| `disableDefaultTargetGestures` | `false` | `true`: target ignores taps, so the four parameters above do nothing |
| `onBarrierClick` | `null` | Still called when barrier interaction is disabled; can't be combined with `disableBarrierInteraction: true` |
| `disableBarrierInteraction` | `false` | The view's value also applies |

## Scrolling

| Parameter | Default | Notes |
|---|---|---|
| `enableAutoScroll` | `null` (view's, false) | Not used for multi showcase |
| `scrollAlignment` | `0.5` | `Scrollable.ensureVisible` alignment |

## Actions and floating widget

| Parameter | Default | Notes |
|---|---|---|
| `tooltipActions` | `null` | `List<TooltipActionButton>`; replaces `globalTooltipActions` for this step |
| `tooltipActionConfig` | `null` | Replaces `globalTooltipActionConfig` for this step |
| `floatingActionWidget` | `null` | A `FloatingActionWidget` value (not a builder); wins over the global one |

## Scope

| Parameter | Default | Notes |
|---|---|---|
| `scope` | `null` | Name of the `ShowcaseView` to join. `null` joins the active scope at the time the widget is first built |

## Constraints (asserts, debug builds)

- `Showcase`: `title != null || description != null`.
- `targetTooltipGap >= 0`; `overlayOpacity` between 0 and 1.
- `onTargetClick` and `disposeOnTap` both set or both `null`.
- `onBarrierClick == null || disableBarrierInteraction == false`.
- `Showcase.withWidget`: `container` is not `null`.
