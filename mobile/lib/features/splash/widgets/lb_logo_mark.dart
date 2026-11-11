import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Gold interlocking LB monogram.
class LbLogoMark extends StatelessWidget {
  const LbLogoMark({super.key, this.size = 72, this.color = AppColors.gold});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'LinksBridge logo',
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size * 0.92,
        child: CustomPaint(painter: _LbLogoPainter(color)),
      ),
    );
  }
}

class _LbLogoPainter extends CustomPainter {
  const _LbLogoPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 92);
    final paint = Paint()..color = color;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 0, 26, 92),
        const Radius.circular(5),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 68, 96, 24),
        const Radius.circular(5),
      ),
      paint,
    );

    final letterB = Path()..fillType = PathFillType.evenOdd;
    letterB.addRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(30, 2, 64, 30),
        topRight: const Radius.circular(15),
        bottomRight: const Radius.circular(15),
      ),
    );
    letterB.addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(46, 9, 32, 16),
        const Radius.circular(8),
      ),
    );
    letterB.addRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(30, 36, 68, 30),
        topRight: const Radius.circular(15),
        bottomRight: const Radius.circular(15),
      ),
    );
    letterB.addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(46, 43, 34, 16),
        const Radius.circular(8),
      ),
    );
    canvas.drawPath(letterB, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LbLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
