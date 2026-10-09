import 'package:flutter/material.dart';

class EmailIllustration extends StatelessWidget {
  final double size;

  const EmailIllustration({
    super.key,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(size * 0.18),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Envelope background & lines
          CustomPaint(
            size: Size(size * 0.9, size * 0.7),
            painter: _EnvelopePainter(),
          ),
          // Center blue badge with "E" or mail icon
          Container(
            width: size * 0.32,
            height: size * 0.32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF38BDF8),
                  Color(0xFF0284C7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withAlpha(60),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'E',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Top V Flap line
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..lineTo(size.width * 0.9, size.height * 0.2);

    canvas.drawPath(path, paint);

    // Bottom left corner diagonal line
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.85),
      Offset(size.width * 0.38, size.height * 0.52),
      paint,
    );

    // Bottom right corner diagonal line
    canvas.drawLine(
      Offset(size.width * 0.9, size.height * 0.85),
      Offset(size.width * 0.62, size.height * 0.52),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
