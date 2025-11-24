import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tooltip Safe Area Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SafeAreaTestPage(),
    );
  }
}

class SafeAreaTestPage extends StatefulWidget {
  const SafeAreaTestPage({super.key});

  @override
  State<SafeAreaTestPage> createState() => _SafeAreaTestPageState();
}

class _SafeAreaTestPageState extends State<SafeAreaTestPage> {
  final GlobalKey _topLeftKey = GlobalKey();
  final GlobalKey _topCenterKey = GlobalKey();
  final GlobalKey _topRightKey = GlobalKey();
  final GlobalKey _centerLeftKey = GlobalKey();
  final GlobalKey _centerKey = GlobalKey();
  final GlobalKey _centerRightKey = GlobalKey();
  final GlobalKey _bottomLeftKey = GlobalKey();
  final GlobalKey _bottomCenterKey = GlobalKey();
  final GlobalKey _bottomRightKey = GlobalKey();
  final GlobalKey _longTextKey = GlobalKey();
  final GlobalKey _shortTextKey = GlobalKey();
  final GlobalKey _mediumTextKey = GlobalKey();
  final GlobalKey _actionsTopKey = GlobalKey();
  final GlobalKey _actionsBottomKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowcaseView.get().startShowCase([
        _shortTextKey,
        _mediumTextKey,
        _longTextKey,
        _actionsTopKey,
        _topLeftKey,
        _topCenterKey,
        _topRightKey,
        _centerLeftKey,
        _centerKey,
        _centerRightKey,
        _actionsBottomKey,
        _bottomLeftKey,
        _bottomCenterKey,
        _bottomRightKey,
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Safe Area Test Cases'),
          backgroundColor: Colors.blue,
        ),
        body: Container(
          color: Colors.grey[200],
          child: Stack(
            children: [
              // Grid to show positioning
              CustomPaint(
                size: Size.infinite,
                painter: GridPainter(),
              ),

              // Text Size Tests - Top Section
              _buildShowcaseTarget(
                key: _shortTextKey,
                position: const Alignment(-0.6, -0.7),
                title: 'Short',
                description: 'Small text',
                color: Colors.cyan,
                size: 50,
                showActions: true,
                tooltipPosition: TooltipPosition.bottom,
              ),
              _buildShowcaseTarget(
                key: _mediumTextKey,
                position: const Alignment(0, -0.7),
                title: 'Medium Length Title',
                description:
                    'This is a medium-length description to test tooltip sizing.',
                color: Colors.lightBlue,
                size: 50,
                showActions: true,
                tooltipPosition: TooltipPosition.bottom,
              ),
              _buildShowcaseTarget(
                key: _longTextKey,
                position: const Alignment(0.6, -0.7),
                title: 'Long Text Example',
                description:
                    'This is a very long description that tests how tooltips handle extensive text content and ensure they stay within safe area bounds even with lots of content. The tooltip should wrap properly and not overflow the screen edges while maintaining readability.',
                color: Colors.blue[700]!,
                size: 50,
                showActions: true,
              ),

              // Actions at Top (critical safe area test)
              _buildShowcaseTarget(
                key: _actionsTopKey,
                position: const Alignment(0, -0.9),
                title: 'Top with Actions',
                description: 'Tooltip with action buttons near top edge.',
                color: Colors.amber,
                size: 60,
                showActions: true,
              ),

              // Corner Cases
              _buildShowcaseTarget(
                key: _topLeftKey,
                position: const Alignment(-0.9, -0.9),
                title: 'Top Left',
                description: 'Corner test with actions',
                color: Colors.red,
                size: 60,
                showActions: true,
                tooltipPosition: TooltipPosition.right,
              ),
              _buildShowcaseTarget(
                key: _topCenterKey,
                position: const Alignment(0, -0.85),
                description: 'Top center - no title test',
                color: Colors.orange,
                size: 50,
                showActions: false,
              ),
              _buildShowcaseTarget(
                key: _topRightKey,
                position: const Alignment(0.9, -0.9),
                title: 'Top Right',
                description: 'Corner test.',
                color: Colors.yellow[700]!,
                size: 60,
                showActions: false,
                tooltipPosition: TooltipPosition.left,
              ),

              // Middle Row - No actions
              _buildShowcaseTarget(
                key: _centerLeftKey,
                position: const Alignment(-0.9, 0),
                title: 'Left Edge',
                description: 'Target at left edge without actions.',
                color: Colors.green,
                size: 55,
                showActions: false,
                tooltipPosition: TooltipPosition.right,
              ),
              _buildShowcaseTarget(
                key: _centerKey,
                position: const Alignment(0, 0),
                title: 'Center Point',
                description:
                    'Screen center with medium text and actions to test all directions.',
                color: Colors.blue,
                size: 70,
                showActions: true,
              ),
              _buildShowcaseTarget(
                key: _centerRightKey,
                position: const Alignment(0.9, 0),
                title: 'Right Edge',
                description: 'Right edge test.',
                color: Colors.indigo,
                size: 55,
                showActions: false,
                tooltipPosition: TooltipPosition.left,
              ),

              // Bottom Row (Critical for Safe Area)
              _buildShowcaseTarget(
                key: _actionsBottomKey,
                position: const Alignment(0, 0.9),
                title: 'Bottom with Actions',
                description:
                    'Critical test: Actions at bottom edge with safe area.',
                color: Colors.deepOrange,
                size: 60,
                showActions: true,
              ),
              _buildShowcaseTarget(
                key: _bottomLeftKey,
                position: const Alignment(-0.9, 0.9),
                title: 'Bottom Left',
                description: 'Bottom corner with safe area.',
                color: Colors.purple,
                size: 60,
                showActions: true,
                tooltipPosition: TooltipPosition.top,
              ),
              _buildShowcaseTarget(
                key: _bottomCenterKey,
                position: const Alignment(0, 0.88),
                description:
                    'Bottom center - testing without title and with actions.',
                color: Colors.pink,
                size: 50,
                showActions: true,
              ),
              _buildShowcaseTarget(
                key: _bottomRightKey,
                position: const Alignment(0.9, 0.9),
                title: 'Bottom Right Corner',
                description:
                    'Final test: bottom-right corner with actions and safe area.',
                color: Colors.red[900]!,
                size: 60,
                showActions: true,
                tooltipPosition: TooltipPosition.top,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowcaseTarget({
    required GlobalKey key,
    required Alignment position,
    String? title,
    required String description,
    required Color color,
    double size = 60,
    bool showActions = false,
    TooltipPosition? tooltipPosition,
  }) {
    return Align(
      alignment: position,
      child: Showcase(
        key: key,
        title: title,
        description: description,
        tooltipPosition: tooltipPosition,
        targetBorderRadius: BorderRadius.circular(8),
        tooltipActions: showActions
            ? [
                TooltipActionButton.custom(
                  button: TextButton(
                    onPressed: () {
                      ShowCaseWidget.of(context).next();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Next'),
                  ),
                ),
                TooltipActionButton.custom(
                  button: TextButton(
                    onPressed: () {
                      ShowCaseWidget.of(context).dismiss();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Quit'),
                  ),
                ),
              ]
            : [],
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              showActions ? Icons.touch_app : Icons.location_on,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Draw vertical lines
    for (int i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 0; i <= 10; i++) {
      final y = size.height * i / 10;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw center lines in red
    final centerPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
