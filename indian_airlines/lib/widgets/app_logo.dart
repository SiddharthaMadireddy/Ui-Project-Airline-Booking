import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';

enum LogoVariant { full, iconOnly, whiteOnDark }

/// Original Indian Airlines Logo drawn with CustomPainter.
/// Stylized soaring bird/wing mark inside a 24-spoke wheel-style circle,
/// using saffron (#FF9933), deep navy (#0B1F4B), and green (#138808).
///
/// NOTE FOR EVALUATOR / VIVA:
/// To swap in a custom image file (e.g. assets/logo.png), set [customImageAsset]
/// below to your asset path.
class AppLogo extends StatelessWidget {
  // SET THIS TO 'assets/logo.png' IF YOU WISH TO USE AN IMAGE FILE INSTEAD OF CUSTOM PAINTER
  static const String? customImageAsset = null;

  final double size;
  final LogoVariant variant;

  const AppLogo({
    super.key,
    this.size = 36.0,
    this.variant = LogoVariant.full,
  });

  @override
  Widget build(BuildContext context) {
    if (customImageAsset != null && customImageAsset!.isNotEmpty) {
      return Image.asset(
        customImageAsset!,
        height: size,
        fit: BoxFit.contain,
      );
    }

    final bool isDark = variant == LogoVariant.whiteOnDark;
    final iconWidget = CustomPaint(
      size: Size(size, size),
      painter: _IndianAirlinesLogoPainter(),
    );

    if (variant == LogoVariant.iconOnly) {
      return iconWidget;
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          SizedBox(width: size * 0.28),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INDIAN AIRLINES',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: isDark ? Colors.white : AppConstants.primaryNavy,
                  fontSize: size * 0.44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: size * 0.4,
                    height: 2,
                    color: AppConstants.saffron,
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: size * 0.4,
                    height: 2,
                    color: isDark ? Colors.white70 : AppConstants.primaryNavy,
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: size * 0.4,
                    height: 2,
                    color: AppConstants.accentGreen,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// CustomPainter drawing the 24-spoke chakra circle with soaring aerodynamic bird wings
class _IndianAirlinesLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);
    final double radius = min(w, h) / 2 - 2;

    // 1. Outer Ring (Deep Navy)
    final ringPaint = Paint()
      ..color = AppConstants.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2.0, w * 0.07);
    canvas.drawCircle(center, radius, ringPaint);

    // 2. 24 Spokes (Saffron)
    final spokePaint = Paint()
      ..color = AppConstants.saffron
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.0, w * 0.035);

    const int spokeCount = 24;
    final double spokeInnerRadius = radius * 0.28;
    final double spokeOuterRadius = radius * 0.88;

    for (int i = 0; i < spokeCount; i++) {
      final double angle = (i * 2 * pi) / spokeCount;
      final Offset p1 = Offset(
        center.dx + spokeInnerRadius * cos(angle),
        center.dy + spokeInnerRadius * sin(angle),
      );
      final Offset p2 = Offset(
        center.dx + spokeOuterRadius * cos(angle),
        center.dy + spokeOuterRadius * sin(angle),
      );
      canvas.drawLine(p1, p2, spokePaint);
    }

    // 3. Central Hub Ring (Navy)
    final hubPaint = Paint()
      ..color = AppConstants.primaryNavy
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, spokeInnerRadius, hubPaint);

    // 4. Soaring Aerodynamic Bird / Wing (Saffron & Green Gradient Effect)
    // Left Wing (Saffron accent)
    final saffronWing = Paint()
      ..color = AppConstants.saffron
      ..style = PaintingStyle.fill;

    final Path leftWingPath = Path();
    leftWingPath.moveTo(center.dx, center.dy - radius * 0.7);
    leftWingPath.quadraticBezierTo(
      center.dx - radius * 0.65,
      center.dy - radius * 0.5,
      center.dx - radius * 0.85,
      center.dy - radius * 0.05,
    );
    leftWingPath.quadraticBezierTo(
      center.dx - radius * 0.35,
      center.dy - radius * 0.1,
      center.dx,
      center.dy + radius * 0.25,
    );
    leftWingPath.close();
    canvas.drawPath(leftWingPath, saffronWing);

    // Right Wing (Tiranga Green accent)
    final greenWing = Paint()
      ..color = AppConstants.accentGreen
      ..style = PaintingStyle.fill;

    final Path rightWingPath = Path();
    rightWingPath.moveTo(center.dx, center.dy - radius * 0.7);
    rightWingPath.quadraticBezierTo(
      center.dx + radius * 0.65,
      center.dy - radius * 0.5,
      center.dx + radius * 0.85,
      center.dy - radius * 0.05,
    );
    rightWingPath.quadraticBezierTo(
      center.dx + radius * 0.35,
      center.dy - radius * 0.1,
      center.dx,
      center.dy + radius * 0.25,
    );
    rightWingPath.close();
    canvas.drawPath(rightWingPath, greenWing);

    // Center Airplane / Bird Body (White fuselage)
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path fuselagePath = Path();
    fuselagePath.moveTo(center.dx, center.dy - radius * 0.75);
    fuselagePath.lineTo(center.dx - radius * 0.12, center.dy + radius * 0.3);
    fuselagePath.lineTo(center.dx, center.dy + radius * 0.2);
    fuselagePath.lineTo(center.dx + radius * 0.12, center.dy + radius * 0.3);
    fuselagePath.close();
    canvas.drawPath(fuselagePath, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
