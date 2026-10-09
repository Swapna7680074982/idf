import 'package:flutter/material.dart';

class GlobeLogo extends StatelessWidget {
  final double size;
  final bool showBackgroundGlow;

  const GlobeLogo({
    super.key,
    this.size = 80,
    this.showBackgroundGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/icons/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0x28FFFFFF),
                borderRadius: BorderRadius.circular(size * 0.28),
                border: Border.all(
                  color: const Color(0x30FFFFFF),
                  width: 1.5,
                ),
                boxShadow: showBackgroundGlow
                    ? [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Container(
                  width: size * 0.76,
                  height: size * 0.76,
                  decoration: BoxDecoration(
                    color: const Color(0x20FFFFFF),
                    borderRadius: BorderRadius.circular(size * 0.22),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: Size(size * 0.46, size * 0.46),
                      painter: _GlobeIconPainter(),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _GlobeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer Circle
    canvas.drawCircle(center, radius, paint);

    // Horizontal equator line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Vertical meridian line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Longitude curved ellipse
    final ovalRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.52,
      height: size.height,
    );
    canvas.drawOval(ovalRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
