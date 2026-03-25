import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

/// Demonstrates the curved arrow tooltip positions:
/// - [TooltipPosition.topLeft]  → [CurvedArrowPainter]  (bends left)
/// - [TooltipPosition.topRight] → [CurvedArrowRightPainter] (bends right)
///
/// The [Showcase.targetTooltipGap] (set to 44) controls the height of the
/// curved-arrow canvas that sits between the tooltip dialog and the target
/// widget.
class CurvedArrowExampleScreen extends StatefulWidget {
  const CurvedArrowExampleScreen({Key? key}) : super(key: key);

  @override
  State<CurvedArrowExampleScreen> createState() =>
      _CurvedArrowExampleScreenState();
}

class _CurvedArrowExampleScreenState extends State<CurvedArrowExampleScreen> {
  final GlobalKey _keyTopLeft = GlobalKey();
  final GlobalKey _keyTopRight = GlobalKey();

  late final ShowcaseView _showcase;

  @override
  void initState() {
    super.initState();
    _showcase = ShowcaseView.register(scope: '_curvedArrowExample');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showcase.startShowCase([_keyTopLeft, _keyTopRight]);
    });
  }

  @override
  void dispose() {
    _showcase.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Curved Arrow Example'),
        backgroundColor: const Color(0xffEE5366),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Curved Arrow Tooltips',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use TooltipPosition.topLeft or TooltipPosition.topRight '
                'to show a curved arrow between the tooltip and the target '
                'widget. Set targetTooltipGap (41–44) to control the arrow '
                'canvas height.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 48),

              // ── topLeft example (arrow bends to the left) ──────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Showcase(
                    key: _keyTopLeft,
                    scope: '_curvedArrowExample',
                    title: 'Top-Left Arrow',
                    description:
                        'This tooltip uses TooltipPosition.topLeft.\n'
                        'The curved arrow bends to the left.',
                    tooltipBackgroundColor: const Color(0xffEE5366),
                    textColor: Colors.white,
                    tooltipPosition: TooltipPosition.topLeft,
                    // Keep targetTooltipGap == Constants.curvedArrowWidth (65)
                    // to maintain the correct aspect ratio for the curve.
                    targetTooltipGap: 65,
                    targetBorderRadius:
                        const BorderRadius.all(Radius.circular(12)),
                    tooltipActions: const [
                      TooltipActionButton(
                        type: TooltipDefaultActionType.next,
                        textStyle: TextStyle(color: Colors.white),
                      ),
                    ],
                    tooltipActionConfig: const TooltipActionConfig(
                      position: TooltipActionPosition.inside,
                      alignment: MainAxisAlignment.end,
                    ),
                    child: _FeatureCard(
                      icon: Icons.arrow_back_rounded,
                      label: 'Feature A',
                      color: primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // ── topRight example (arrow bends to the right) ────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Showcase(
                    key: _keyTopRight,
                    scope: '_curvedArrowExample',
                    title: 'Top-Right Arrow',
                    description:
                        'This tooltip uses TooltipPosition.topRight.\n'
                        'The curved arrow bends to the right.',
                    tooltipBackgroundColor: const Color(0xff3D5AFE),
                    textColor: Colors.white,
                    tooltipPosition: TooltipPosition.topRight,
                    targetTooltipGap: 65,
                    targetBorderRadius:
                        const BorderRadius.all(Radius.circular(12)),
                    tooltipActions: const [
                      TooltipActionButton(
                        type: TooltipDefaultActionType.previous,
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.skip,
                        name: 'Done',
                        textStyle: TextStyle(color: Colors.white),
                      ),
                    ],
                    tooltipActionConfig: const TooltipActionConfig(
                      position: TooltipActionPosition.inside,
                      alignment: MainAxisAlignment.spaceBetween,
                    ),
                    child: const _FeatureCard(
                      icon: Icons.arrow_forward_rounded,
                      label: 'Feature B',
                      color: Color(0xff3D5AFE),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Replay button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showcase
                        .startShowCase([_keyTopLeft, _keyTopRight]);
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Replay showcase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffEE5366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
