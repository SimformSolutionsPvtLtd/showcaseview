/*
 * Copyright (c) 2021 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
part of 'tooltip.dart';

class ShowcaseArrow extends StatelessWidget {
  const ShowcaseArrow({
    super.key,
    required this.strokeColor,
    this.tooltipPosition,
    this.useSvg = false,
    this.svgArrowAsset,
    this.flipSvgArrow = false,
  });

  final Color strokeColor;
  final TooltipPosition? tooltipPosition;

  /// When `true`, renders an SVG from [svgArrowAsset] instead of the default
  /// [CustomPainter]-based arrow.
  final bool useSvg;

  /// Asset path for the SVG arrow image (e.g. `'assets/left_icon.svg'`).
  /// Only used when [useSvg] is `true`.
  final String? svgArrowAsset;

  /// When `true`, flips the SVG arrow vertically so the arrowhead faces the
  /// opposite direction. Useful when the SVG tip needs to point toward the
  /// target widget but the asset is oriented the other way.
  final bool flipSvgArrow;

  @override
  Widget build(BuildContext context) {
    // SVG branch – render a flutter_svg asset when requested and available.
    if (useSvg && svgArrowAsset != null) {
      final svg = SvgPicture.asset(
        svgArrowAsset!,
        colorFilter: ColorFilter.mode(strokeColor, BlendMode.srcIn),
      );
      return flipSvgArrow
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(-1, -1, 1),
              child: svg,
            )
          : svg;
    }

    if (tooltipPosition == TooltipPosition.topLeft) {
      return CustomPaint(painter: _CurvedArrowPainter(color: strokeColor));
    } else if (tooltipPosition == TooltipPosition.topRight) {
      return CustomPaint(painter: _CurvedArrowRightPainter(color: strokeColor));
    }
    return CustomPaint(
      painter: _ArrowPainter(
        strokeColor: strokeColor,
      ),
      size: const Size(Constants.arrowWidth, Constants.arrowHeight),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({
    this.strokeColor = Colors.black,
    this.strokeWidth = Constants.arrowStrokeWidth,
    this.paintingStyle = PaintingStyle.fill,
  })  : _paint = Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth
          ..style = paintingStyle,
        // Cache the triangle path since it never changes
        _path = Path()
          ..moveTo(0, Constants.arrowHeight)
          ..lineTo(Constants.arrowWidth * 0.5, 0)
          ..lineTo(Constants.arrowWidth, Constants.arrowHeight)
          ..lineTo(0, Constants.arrowHeight);

  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final Paint _paint;
  final Path _path;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
        _path,
        _paint,
      );

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Curved arrow painter for [TooltipPosition.topLeft].
///
/// Draws a smooth curve from the **bottom-center-right** (`x≈60%`) of the
/// canvas down and to the left, ending at the **top-left** (`x≈20%`) with
/// the arrowhead pointing up-right toward the tooltip. The tail of the curve
/// sits near the target widget; the head points at the tooltip.
///
/// Use [Showcase.targetTooltipGap] ≥ 80 for best results.
class _CurvedArrowPainter extends CustomPainter {
  _CurvedArrowPainter({this.color = Colors.white, this.strokeWidth = 3});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.6, size.height * 0.95)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.95,
        size.width * 0.05,
        size.height * 0.8,
        size.width * 0.2,
        size.height * 0.1,
      );
    canvas.drawPath(path, paint);

    final arrowHeadPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final arrowTip = Offset(size.width * 0.2, size.height * 0.13);
    final arrowPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy - 10)
      ..lineTo(arrowTip.dx + 12, arrowTip.dy + 4)
      ..moveTo(arrowTip.dx, arrowTip.dy - 10)
      ..lineTo(arrowTip.dx - 12, arrowTip.dy + 2);
    canvas.drawPath(arrowPath, arrowHeadPaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Curved arrow painter for [TooltipPosition.topRight].
///
/// Draws a smooth curve from the bottom-center of the canvas (near the
/// tooltip) up to the upper-right corner (pointing toward the target),
/// suitable for when the tooltip is positioned above and to the left of the
/// target.
class _CurvedArrowRightPainter extends CustomPainter {
  _CurvedArrowRightPainter({this.color = Colors.white, this.strokeWidth = 3});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.95)
      ..cubicTo(
        size.width * 0.7,
        size.height * 0.95,
        size.width * 1.1,
        size.height * 0.8,
        size.width * 0.8,
        size.height * 0.1,
      );
    canvas.drawPath(path, paint);

    final arrowHeadPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final arrowTip = Offset(size.width * 0.8, size.height * 0.1);
    final arrowPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowTip.dx - 8, arrowTip.dy + 10)
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowTip.dx + 12, arrowTip.dy + 10);
    canvas.drawPath(arrowPath, arrowHeadPaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedArrowRightPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
