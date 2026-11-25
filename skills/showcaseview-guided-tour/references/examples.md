# showcaseview guided tour: more examples

Every example uses `package:flutter/material.dart` and
`package:showcaseview/showcaseview.dart`. Keys are `State` fields and each
`register` has a matching `unregister` in `dispose`, as in **Basic** in
`SKILL.md`.

## Register once for the whole app

Use this when every tour shares one configuration. No `unregister` is needed
because the registration lives as long as the app.

```dart
void main() {
  ShowcaseView.register(
    autoPlayDelay: const Duration(seconds: 3),
    enableAutoScroll: true,
    semanticEnable: true,
  );
  runApp(const MyApp());
}
```

Screens then only wrap targets and call `ShowcaseView.get().startShowCase`.
Don't also register inside a screen, which would replace this registration.

## Show the tour only once

The package keeps no "seen" flag. Store it in both `onFinish` and
`onDismiss`, and check it before starting (here with `shared_preferences`).

```dart
import 'package:shared_preferences/shared_preferences.dart';

const _tourSeenKey = 'home_tour_seen';

Future<bool> isHomeTourSeen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_tourSeenKey) ?? false;
}

ShowcaseView registerHomeTour() {
  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourSeenKey, true);
  }

  return ShowcaseView.register(
    onFinish: markSeen,
    onDismiss: (_) => markSeen(),
  );
}
```

In the screen's `State`, register in `initState` and start from a method that
checks `mounted` after the `await`: the screen may be gone (and the view
unregistered) by then, and `startShowCase` asserts on an unregistered view.

```dart
Future<void> _startTourOnce() async {
  if (await isHomeTourSeen() || !mounted) return;
  _showcaseView.startShowCase([_menuKey, _addKey]);
}
```

Call `_startTourOnce()` from a post-frame callback in `initState`.

## A "Help" button that replays the tour

```dart
IconButton(
  icon: const Icon(Icons.help_outline),
  onPressed: () => _showcaseView.startShowCase([_menuKey, _addKey]),
)
```

Ignore the "seen" flag here; the user asked for it.

## Tour that spans a pushed screen (named scope)

The second screen is alive while the first still is, so it registers its own
scope and passes that name to its `Showcase` widgets.

```dart
class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  static const _scope = 'detail';
  final GlobalKey _shareKey = GlobalKey();
  late final ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(scope: _scope);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showcaseView.startShowCase(
        [_shareKey],
        delay: const Duration(milliseconds: 300), // route transition
      ),
    );
  }

  @override
  void dispose() {
    _showcaseView.unregister(); // get() returns the previous scope again
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Showcase(
            key: _shareKey,
            scope: _scope,
            title: 'Share',
            description: 'Send this item to a friend',
            child: IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: const SizedBox.expand(),
    );
  }
}
```

If the first screen's tour must continue after the detail screen closes,
start it again in the `then` of the `Navigator.push` with the remaining keys,
after the detail view is unregistered.

## Leave the screen from a step

A target that navigates must dismiss the tour first; `disposeOnTap: true`
does that and then runs `onTargetClick`.

```dart
Showcase(
  key: _profileKey,
  title: 'Profile',
  description: 'Tap to open your profile',
  disposeOnTap: true,
  onTargetClick: () => Navigator.of(context).pushNamed('/profile'),
  child: const CircleAvatar(child: Icon(Icons.person)),
)
```

## Steps in tabs or conditional UI

Start with every key, and let the view skip the ones that are not mounted.

```dart
_showcaseView = ShowcaseView.register(skipIfTargetNotPresent: true);
// ...
_showcaseView.startShowCase([_tabOneKey, _tabTwoKey, _bannerKey]);
```

Or decide up front:

```dart
final steps = [
  _tabOneKey,
  if (_showcaseView.isTargetRendered(_bannerKey)) _bannerKey,
];
_showcaseView.startShowCase(steps);
```

## Long lists: scroll to a target that is not built yet

A target in a `ListView.builder` that is off screen has no mounted
`Showcase`, and a forward step to it ends the tour (or skips it with
`skipIfTargetNotPresent`) **before** `onStart` runs, so `onStart` and
`enableAutoScroll` can't bring it into view. Scroll first, wait one frame so
the item is built, then start or advance. Dispose the `ScrollController` in
`dispose`.

```dart
final ScrollController _scrollController = ScrollController();

// In build:
ListView.builder(
  controller: _scrollController,
  itemCount: 100,
  itemBuilder: (context, i) => i == 99
      ? Showcase(
          key: _lastItemKey,
          title: 'Last item',
          description: 'You reached the end',
          child: ListTile(title: Text('Item $i')),
        )
      : ListTile(title: Text('Item $i')),
)
```

The tour starts at the unbuilt item: scroll, wait a frame, then start.

```dart
Future<void> _startAtLastItem() async {
  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  await WidgetsBinding.instance.endOfFrame;
  if (!mounted) return;
  _showcaseView.startShowCase([_lastItemKey]);
}
```

The unbuilt item comes later in the tour: give the step before it a custom
Next action that scrolls, waits a frame and then advances. Tapping the barrier
or the target would advance without scrolling, so turn both off for that step.

```dart
Showcase(
  key: _firstItemKey,
  title: 'First item',
  description: 'Next jumps to the end of the list',
  disableBarrierInteraction: true,
  disableDefaultTargetGestures: true,
  tooltipActions: [
    TooltipActionButton(
      type: TooltipDefaultActionType.next,
      textStyle: const TextStyle(color: Colors.white),
      onTap: () async {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        _showcaseView.next(force: true);
      },
    ),
  ],
  child: ListTile(title: const Text('Item 0')),
)
```

## Per-step actions, including a custom button

Local actions replace the global ones for that step.

```dart
Showcase(
  key: _addKey,
  title: 'Add',
  description: 'Create a new item',
  tooltipActionConfig: const TooltipActionConfig(
    position: TooltipActionPosition.outside,
    alignment: MainAxisAlignment.end,
  ),
  tooltipActions: [
    TooltipActionButton(
      type: TooltipDefaultActionType.skip,
      name: 'Not now',
      backgroundColor: Colors.grey,
      textStyle: const TextStyle(color: Colors.white),
    ),
    TooltipActionButton(
      type: TooltipDefaultActionType.next,
      name: 'Got it',
      backgroundColor: Colors.green,
      textStyle: const TextStyle(color: Colors.white),
      tailIcon: const ActionButtonIcon(
        icon: Icon(Icons.arrow_forward, size: 16, color: Colors.white),
      ),
      onTap: () {
        // Runs instead of the default "next" behavior.
        _showcaseView.next(force: true);
      },
    ),
    TooltipActionButton.custom(
      button: TextButton(
        onPressed: () => _showcaseView.dismiss(),
        child: const Text('Close'),
      ),
    ),
  ],
  child: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.add),
  ),
)
```

## Auto play

```dart
_showcaseView = ShowcaseView.register(
  autoPlay: true,
  autoPlayDelay: const Duration(seconds: 3),
  enableAutoPlayLock: true, // next() is ignored unless force: true
);
```

A step's `autoPlayDelay` overrides the view's for that step.

## Highlight two widgets at once (multi showcase)

```dart
Showcase(
  key: _pairKey,
  title: 'Search',
  description: 'Find anything',
  child: const Icon(Icons.search),
),
Showcase(
  key: _pairKey,
  title: 'Filter',
  description: 'Narrow the results',
  child: const Icon(Icons.filter_list),
),
// startShowCase([_pairKey]) shows both together.
```

## Dark theme

The defaults are light. Set colors explicitly:

```dart
Showcase(
  key: _menuKey,
  title: 'Menu',
  description: 'Open the menu',
  tooltipBackgroundColor: Theme.of(context).colorScheme.surface,
  textColor: Theme.of(context).colorScheme.onSurface,
  child: const Icon(Icons.menu),
)
```

Set `overlayColor` and `overlayOpacity` on `ShowcaseView.register` to change
the dimming for every step.
