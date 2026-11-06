import 'dart:math';

import 'package:flutter/material.dart';

import 'world.dart';

class WorldPainter extends CustomPainter {
  WorldPainter(this.world, Listenable repaint) : super(repaint: repaint);

  final World world;

  Path _star(Offset c, double r, double rot) {
    final Path p = Path();
    for (int i = 0; i < 10; i++) {
      final double a = rot - pi / 2 + i * pi / 5;
      final double rr = i.isEven ? r : r * 0.45;
      final Offset o = Offset(c.dx + cos(a) * rr, c.dy + sin(a) * rr);
      if (i == 0) {
        p.moveTo(o.dx, o.dy);
      } else {
        p.lineTo(o.dx, o.dy);
      }
    }
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF0B1026), Color(0xFF1B2A5C)],
        ).createShader(Offset.zero & size),
    );

    final double r = World.itemR * w;
    for (final Item it in world.items) {
      final Offset c = Offset(it.x * w, it.y * h);
      if (it.bomb) {
        canvas.drawCircle(c, r, Paint()..color = const Color(0xFF212121));
        canvas.drawCircle(
          c.translate(-r * 0.3, -r * 0.3),
          r * 0.28,
          Paint()..color = const Color(0x55FFFFFF),
        );
        canvas.drawLine(
          c.translate(0, -r),
          c.translate(r * 0.35, -r * 1.45),
          Paint()
            ..color = const Color(0xFFFF5722)
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      } else {
        canvas.drawCircle(
          c,
          r * 1.5,
          Paint()
            ..color = const Color(0x33FFC107)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        canvas.drawPath(
          _star(c, r * 1.15, it.spin),
          Paint()..color = const Color(0xFFFFD54F),
        );
      }
    }

    final double bw = World.basketW * w;
    final double bx = world.basketX * w;
    final double by = World.basketY * h;
    final Path basket = Path()
      ..moveTo(bx - bw / 2, by - 14)
      ..lineTo(bx + bw / 2, by - 14)
      ..lineTo(bx + bw / 2 - 12, by + 18)
      ..lineTo(bx - bw / 2 + 12, by + 18)
      ..close();
    canvas.drawPath(basket, Paint()..color = const Color(0xFF26C6DA));
    canvas.drawPath(
      basket,
      Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    if (world.flash > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Color.fromRGBO(255, 0, 0, 0.35 * world.flash),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) => true;
}
