import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

/// Demonstrates SVG-based arrows for four tooltip positions:
/// - [TooltipPosition.topLeft]  → `assets/left_icon.svg`
/// - [TooltipPosition.topRight] → `assets/right_icon.svg`
/// - [TooltipPosition.bottom]   → `assets/bottom_center.svg` (topCenter, dialog below, arrow up)
/// - [TooltipPosition.top]      → `assets/center_icon.svg`   (bottomCenter, dialog above, arrow down)
///
/// Set [Showcase.useSvg] to `true` and provide [Showcase.svgArrowAsset]
/// with the path to the desired SVG. When `useSvg` is `false` the default
/// [CustomPainter] arrow is drawn instead.
class SvgArrowExampleScreen extends StatefulWidget {
  const SvgArrowExampleScreen({Key? key}) : super(key: key);

  @override
  State<SvgArrowExampleScreen> createState() => _SvgArrowExampleScreenState();
}

class _SvgArrowExampleScreenState extends State<SvgArrowExampleScreen> {
  // Keys – one per showcase / tooltip-position variant
  final GlobalKey _keyTopLeft = GlobalKey();
  final GlobalKey _keyTopRight = GlobalKey();
  final GlobalKey _keyTopCenter = GlobalKey();
  final GlobalKey _keyBottomCenter = GlobalKey();

  late final ShowcaseView _showcase;

  static const _dialogBg = Color(0xB2161B26);
  static const _borderColor = Color(0xFF21CBFF);

  @override
  void initState() {
    super.initState();
    _showcase = ShowcaseView.register(scope: '_svgArrowExample');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showcase.startShowCase([
        _keyTopLeft,
        _keyTopRight,
        _keyTopCenter,
        _keyBottomCenter,
      ]);
    });
  }

  @override
  void dispose() {
    _showcase.unregister();
    super.dispose();
  }

  void _replay() {
    _showcase.startShowCase([
      _keyTopLeft,
      _keyTopRight,
      _keyTopCenter,
      _keyBottomCenter,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('SVG Arrow Example'),
        backgroundColor: const Color(0xFF161B26),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                'SVG Arrow Tooltips',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                'Set useSvg: true and provide svgArrowAsset to replace the '
                'CustomPainter arrow with any SVG image.\n'
                'Four positions are demonstrated below.',
                style: TextStyle(fontSize: 13, color: Colors.white54),
              ),
            ),

            // ── Top row: topLeft + topRight ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // topLeft — left_icon.svg
                  Showcase(
                    key: _keyTopLeft,
                    scope: '_svgArrowExample',
                    title: 'Top-Left (SVG)',
                    description:
                        'TooltipPosition.topLeft\nArrow: left_icon.svg',
                    tooltipBackgroundColor: _dialogBg,
                    textColor: Colors.white,
                    tooltipBorderColor: _borderColor,
                    disableMovingAnimation: true,
                    tooltipBorderWidth: 1.5,
                    arrowColor: Colors.white,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.7,
                    tooltipPosition: TooltipPosition.topLeft,
                    // Keep targetTooltipGap == curvedArrowWidth (65) so the
                    // SVG canvas has the same height as the curved-arrow space.
                    targetTooltipGap: 65,
                    targetBorderRadius:
                        const BorderRadius.all(Radius.circular(12)),
                    useSvg: true,
                    svgArrowAsset: 'assets/left_icon.svg',
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
                    child: const _FeatureCard(
                      icon: Icons.arrow_back_rounded,
                      label: 'Feature A',
                      color: _borderColor,
                    ),
                  ),

                  // topRight — right_icon.svg
                  Showcase(
                    key: _keyTopRight,
                    scope: '_svgArrowExample',
                    title: 'Top-Right (SVG)',
                    description:
                        'TooltipPosition.topRight\nArrow: right_icon.svg',
                    tooltipBackgroundColor: _dialogBg,
                    textColor: Colors.white,
                    tooltipBorderColor: _borderColor,
                    tooltipBorderWidth: 1.5,
                    arrowColor: Colors.white,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.7,
                    tooltipPosition: TooltipPosition.topRight,
                    targetTooltipGap: 65,
                    targetBorderRadius:
                        const BorderRadius.all(Radius.circular(12)),
                    useSvg: true,
                    svgArrowAsset: 'assets/right_icon.svg',
                    tooltipActions: const [
                      TooltipActionButton(
                        type: TooltipDefaultActionType.previous,
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.next,
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
                      color: _borderColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // ── Bottom row: top (topCenter) + bottom (bottomCenter) ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // topCenter — center_icon.svg (flipSvgArrow:true)
                  // Dialog BELOW. flip moves arrowhead to TOP (near Feature C).
                  Showcase(
                    key: _keyTopCenter,
                    scope: '_svgArrowExample',
                    title: 'Top-Center (SVG)',
                    description: 'Dialog below \u2022 Arrow: center_icon.svg',
                    tooltipBackgroundColor: _dialogBg,
                    textColor: Colors.white,
                    tooltipBorderColor: _borderColor,
                    tooltipBorderWidth: 1.5,
                    arrowColor: Colors.white,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.7,
                    tooltipPosition: TooltipPosition.bottom,
                    targetBorderRadius:
                        const BorderRadius.all(Radius.circular(12)),
                    useSvg: true,
                    svgArrowAsset: 'assets/center_icon.svg',
                    targetTooltipGap: 65,
                    tooltipActions: const [
                      TooltipActionButton(
                        type: TooltipDefaultActionType.previous,
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.next,
                        textStyle: TextStyle(color: Colors.white),
                      ),
                    ],
                    tooltipActionConfig: const TooltipActionConfig(
                      position: TooltipActionPosition.inside,
                      alignment: MainAxisAlignment.spaceBetween,
                    ),
                    child: const _FeatureCard(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Feature C',
                      color: _borderColor,
                    ),
                  ),

                  // bottomCenter — bottom_center.svg
                  // Dialog ABOVE (TooltipPosition.top), arrow BELOW Feature D
                  // via svgArrowBelowTarget. Natural SVG: diamond tip at y≈0
                  // touches Feature D from below, arrow pointing UP at it. ✔
                  Showcase(
                    key: _keyBottomCenter,
                    scope: '_svgArrowExample',
                    title: 'Bottom-Center (SVG)',
                    description: 'Dialog above \u2022 Arrow: bottom_center.svg',
                    tooltipBackgroundColor: _dialogBg,
                    textColor: Colors.white,
                    tooltipBorderColor: _borderColor,
                    tooltipBorderWidth: 1.5,
                    arrowColor: Colors.white,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.7,
                    tooltipPosition: TooltipPosition.top,
                    targetBorderRadius:
                        const BorderRadius.all(Radius.circular(12)),
                    useSvg: true,
                    svgArrowAsset: 'assets/bottom_center.svg',
                    targetTooltipGap: 65,
                    flipSvgArrow: true,
                    tooltipActions: [
                      const TooltipActionButton(
                        type: TooltipDefaultActionType.previous,
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.skip,
                        name: 'Done',
                        textStyle: const TextStyle(color: Colors.white),
                        onTap: () => _showcase.dismiss(),
                      ),
                    ],
                    tooltipActionConfig: const TooltipActionConfig(
                      position: TooltipActionPosition.inside,
                      alignment: MainAxisAlignment.spaceBetween,
                    ),
                    child: const _FeatureCard(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Feature D',
                      color: _borderColor,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Replay button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton.icon(
                onPressed: _replay,
                icon: const Icon(Icons.replay, color: Colors.white),
                label: const Text(
                  'Replay Showcase',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _borderColor,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared card widget ────────────────────────────────────────────────────────

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
      height: 90,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
