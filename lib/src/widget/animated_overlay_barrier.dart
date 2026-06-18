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
import 'package:flutter/material.dart';

/// Fades the showcase overlay barrier (background color, opacity and blur) in
/// when the showcase first appears.
///
/// The fade only runs once for the lifetime of this widget's [State]. The
/// overlay rebuilds on every showcase step to reposition the highlight cut-out,
/// so this widget is kept outside the per-step keyed subtree in
/// `OverlayManager` to preserve its animation state across steps and avoid the
/// barrier flickering between showcases.
class AnimatedOverlayBarrier extends StatefulWidget {
  const AnimatedOverlayBarrier({
    required this.duration,
    required this.curve,
    required this.child,
    super.key,
  });

  /// Duration of the fade-in animation.
  final Duration duration;

  /// Curve of the fade-in animation.
  final Curve curve;

  /// The barrier widget (background color/blur) to fade in.
  final Widget child;

  @override
  State<AnimatedOverlayBarrier> createState() => _AnimatedOverlayBarrierState();
}

class _AnimatedOverlayBarrierState extends State<AnimatedOverlayBarrier>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}
