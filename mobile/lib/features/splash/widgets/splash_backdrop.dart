import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';

/// Night skyline with a dark overlay and a handshake silhouette along the bottom.
class SplashBackdrop extends StatelessWidget {
  const SplashBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.splashBase),
        const CustomPaint(painter: _SkylinePainter()),
        const Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Color(0xFF1C2A44),
              BlendMode.multiply,
            ),
            child: _CoverPhoto(url: AppAssets.cityNight),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xE6070B12),
                Color(0xA6070B12),
                Color(0x59070B12),
                Color(0x8C070B12),
              ],
              stops: [0, 0.22, 0.58, 1],
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.40,
            widthFactor: 1,
            child: _HandshakeLayer(),
          ),
        ),
      ],
    );
  }
}

class _CoverPhoto extends StatelessWidget {
  const _CoverPhoto({required this.url, this.alignment = Alignment.center});

  final String url;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      alignment: alignment,
      fadeInDuration: const Duration(milliseconds: 350),
      placeholder: (_, _) => const SizedBox.shrink(),
      errorWidget: (_, _, _) => const SizedBox.shrink(),
    );
  }
}

class _HandshakeLayer extends StatelessWidget {
  const _HandshakeLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: _HandshakePainter()),
        ShaderMask(
          shaderCallback: (rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black],
              stops: [0.05, 0.42],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: const ColorFiltered(
            colorFilter: ColorFilter.matrix(<double>[
              0.08,
              0.08,
              0.08,
              0,
              0,
              0.08,
              0.08,
              0.08,
              0,
              0,
              0.08,
              0.08,
              0.08,
              0,
              0,
              0,
              0,
              0,
              0.95,
              0,
            ]),
            child: _CoverPhoto(
              url: AppAssets.handshake,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _SkylinePainter extends CustomPainter {
  const _SkylinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF122033), Color(0xFF070B12)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final building = Paint()..color = const Color(0xFF101826);
    final window = Paint()..color = const Color(0x33D4A537);
    final heights = [
      0.46,
      0.62,
      0.38,
      0.72,
      0.5,
      0.8,
      0.44,
      0.66,
      0.36,
      0.58,
      0.48,
    ];
    final count = heights.length;
    final width = size.width / count;

    for (var i = 0; i < count; i++) {
      final h = size.height * heights[i];
      final rect = Rect.fromLTWH(i * width, size.height - h, width + 1, h);
      canvas.drawRect(rect, building);
      for (var y = rect.top + 14; y < size.height - 18; y += 16) {
        for (var x = rect.left + 6; x < rect.right - 6; x += 10) {
          canvas.drawRect(Rect.fromLTWH(x, y, 3, 5), window);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HandshakePainter extends CustomPainter {
  const _HandshakePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xF2060A10);
    final w = size.width;
    final h = size.height;

    canvas.drawCircle(Offset(w * 0.26, h * 0.22), h * 0.11, paint);
    canvas.drawCircle(Offset(w * 0.74, h * 0.22), h * 0.11, paint);

    final leftBody = Path()
      ..moveTo(w * 0.12, h)
      ..lineTo(w * 0.15, h * 0.40)
      ..quadraticBezierTo(w * 0.22, h * 0.32, w * 0.32, h * 0.36)
      ..lineTo(w * 0.40, h)
      ..close();
    final rightBody = Path()
      ..moveTo(w * 0.88, h)
      ..lineTo(w * 0.85, h * 0.40)
      ..quadraticBezierTo(w * 0.78, h * 0.32, w * 0.68, h * 0.36)
      ..lineTo(w * 0.60, h)
      ..close();
    final leftArm = Path()
      ..moveTo(w * 0.30, h * 0.42)
      ..lineTo(w * 0.48, h * 0.56)
      ..lineTo(w * 0.56, h * 0.64)
      ..lineTo(w * 0.48, h * 0.72)
      ..lineTo(w * 0.34, h * 0.58)
      ..close();
    final rightArm = Path()
      ..moveTo(w * 0.70, h * 0.42)
      ..lineTo(w * 0.52, h * 0.56)
      ..lineTo(w * 0.44, h * 0.64)
      ..lineTo(w * 0.52, h * 0.72)
      ..lineTo(w * 0.66, h * 0.58)
      ..close();

    canvas.drawPath(leftBody, paint);
    canvas.drawPath(rightBody, paint);
    canvas.drawPath(leftArm, paint);
    canvas.drawPath(rightArm, paint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.62),
        width: w * 0.12,
        height: h * 0.12,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
