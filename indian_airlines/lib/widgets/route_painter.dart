import 'package:flutter/material.dart';
import '../core/constants.dart';

class RouteNode {
  final String code;
  final String city;
  final double xRatio; // 0.0 to 1.0 within map canvas
  final double yRatio;
  final bool isHub;

  const RouteNode({
    required this.code,
    required this.city,
    required this.xRatio,
    required this.yRatio,
    this.isHub = false,
  });
}

/// CustomPainter drawing a stylized route network with curved bezier arcs and glowing hubs
class RouteNetworkPainter extends CustomPainter {
  final double animationValue; // For moving flight dots
  final String? selectedNode;

  static const List<RouteNode> nodes = [
    RouteNode(code: 'DEL', city: 'Delhi', xRatio: 0.44, yRatio: 0.32, isHub: true),
    RouteNode(code: 'BOM', city: 'Mumbai', xRatio: 0.36, yRatio: 0.54, isHub: true),
    RouteNode(code: 'BLR', city: 'Bengaluru', xRatio: 0.42, yRatio: 0.74, isHub: true),
    RouteNode(code: 'HYD', city: 'Hyderabad', xRatio: 0.46, yRatio: 0.60, isHub: true),
    RouteNode(code: 'CCU', city: 'Kolkata', xRatio: 0.62, yRatio: 0.46, isHub: true),
    RouteNode(code: 'MAA', city: 'Chennai', xRatio: 0.48, yRatio: 0.76, isHub: false),
    RouteNode(code: 'GOI', city: 'Goa', xRatio: 0.36, yRatio: 0.68, isHub: false),
    RouteNode(code: 'JAI', city: 'Jaipur', xRatio: 0.40, yRatio: 0.36, isHub: false),
    RouteNode(code: 'COK', city: 'Kochi', xRatio: 0.40, yRatio: 0.84, isHub: false),
    RouteNode(code: 'GAU', city: 'Guwahati', xRatio: 0.72, yRatio: 0.38, isHub: false),
    RouteNode(code: 'DXB', city: 'Dubai', xRatio: 0.16, yRatio: 0.40, isHub: true),
    RouteNode(code: 'LHR', city: 'London', xRatio: 0.10, yRatio: 0.18, isHub: true),
    RouteNode(code: 'SIN', city: 'Singapore', xRatio: 0.82, yRatio: 0.82, isHub: true),
    RouteNode(code: 'HND', city: 'Tokyo', xRatio: 0.92, yRatio: 0.28, isHub: false),
  ];

  static const List<List<String>> routes = [
    ['DEL', 'BOM'],
    ['DEL', 'BLR'],
    ['DEL', 'HYD'],
    ['DEL', 'CCU'],
    ['DEL', 'DXB'],
    ['DEL', 'LHR'],
    ['DEL', 'HND'],
    ['BOM', 'BLR'],
    ['BOM', 'GOI'],
    ['BOM', 'DXB'],
    ['BOM', 'LHR'],
    ['BLR', 'HYD'],
    ['BLR', 'MAA'],
    ['BLR', 'COK'],
    ['BLR', 'SIN'],
    ['CCU', 'GAU'],
    ['CCU', 'DEL'],
    ['DEL', 'JAI'],
  ];

  RouteNetworkPainter({
    this.animationValue = 0.0,
    this.selectedNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Background soft map grid lines
    final gridPaint = Paint()
      ..color = AppConstants.borderLight.withValues(alpha: 0.5)
      ..strokeWidth = 0.8;
    for (double x = 40; x < w; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 40; y < h; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Map code to pixel coordinates
    final Map<String, Offset> positions = {};
    for (final node in nodes) {
      positions[node.code] = Offset(node.xRatio * w, node.yRatio * h);
    }

    // Draw curved flight routes (quadratic bezier arcs)
    final arcPaint = Paint()
      ..color = AppConstants.primaryNavy.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final activeArcPaint = Paint()
      ..color = AppConstants.saffron
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    for (final route in routes) {
      final p1 = positions[route[0]];
      final p2 = positions[route[1]];
      if (p1 == null || p2 == null) continue;

      final bool isHighlight = selectedNode != null &&
          (route[0] == selectedNode || route[1] == selectedNode);

      final double midX = (p1.dx + p2.dx) / 2;
      final double midY = (p1.dy + p2.dy) / 2;
      // Arc curvature offset
      final double dx = p2.dx - p1.dx;
      final double dy = p2.dy - p1.dy;
      final double normalX = -dy * 0.18;
      final double normalY = dx * 0.18;
      final Offset control = Offset(midX + normalX, midY + normalY);

      final path = Path();
      path.moveTo(p1.dx, p1.dy);
      path.quadraticBezierTo(control.dx, control.dy, p2.dx, p2.dy);

      canvas.drawPath(path, isHighlight ? activeArcPaint : arcPaint);

      // Moving animated plane dot
      final double t = (animationValue + (route[0].hashCode % 10) / 10.0) % 1.0;
      final double bx = (1 - t) * (1 - t) * p1.dx + 2 * (1 - t) * t * control.dx + t * t * p2.dx;
      final double by = (1 - t) * (1 - t) * p1.dy + 2 * (1 - t) * t * control.dy + t * t * p2.dy;

      final dotPaint = Paint()
        ..color = AppConstants.saffron
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(bx, by), 2.5, dotPaint);
    }

    // Draw Nodes (Airports & Hubs)
    for (final node in nodes) {
      final pos = positions[node.code]!;
      final bool isSelected = node.code == selectedNode;

      // Glow halo for major hubs
      if (node.isHub) {
        final glowPaint = Paint()
          ..color = AppConstants.saffron.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 14, glowPaint);
      }

      // Outer ring
      final outerPaint = Paint()
        ..color = isSelected ? AppConstants.saffron : AppConstants.primaryNavy
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, node.isHub ? 7 : 5, outerPaint);

      // White center
      final innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, node.isHub ? 3.5 : 2.5, innerPaint);

      // Text Label
      final textSpan = TextSpan(
        text: node.code,
        style: TextStyle(
          color: isSelected ? AppConstants.saffron : AppConstants.primaryNavy,
          fontSize: node.isHub ? 11 : 9,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx + 8, pos.dy - 6));
    }
  }

  @override
  bool shouldRepaint(covariant RouteNetworkPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.selectedNode != selectedNode;
}
