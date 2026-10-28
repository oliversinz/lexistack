import 'package:flutter/material.dart';

import 'theme.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
  });
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: title == 'LexiStack'
          ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PuzzleMark(size: 26),
                SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('LexiStack'),
                  ),
                ),
              ],
            )
          : Text(title),
      actions: actions,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

/// Four printed tokens form an original, deliberately incomplete puzzle square.
class PuzzleMark extends StatelessWidget {
  const PuzzleMark({super.key, this.size = 48});
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MarkPainter(Theme.of(context).colorScheme.primary),
      ),
    ),
  );
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 2.3;
    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.translate((i % 2) * unit * 1.25, (i ~/ 2) * unit * 1.25);
      if (i == 1) {
        canvas.translate(unit * .15, 0);
        canvas.rotate(.12);
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, unit, unit),
          Radius.circular(unit * .16),
        ),
        Paint()..color = i == 1 ? coral : color,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => oldDelegate.color != color;
}

class InsetCard extends StatelessWidget {
  const InsetCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Material(color: Colors.transparent, child: child),
  );
}

class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.stars, this.size = 18});
  final int stars;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: counted(stars, 'star'),
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Icon(
              i < stars ? Icons.star_rounded : Icons.star_border_rounded,
              size: size,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    ),
  );
}
