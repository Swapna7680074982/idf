import 'package:flutter/material.dart';

class DrMohansLogo extends StatelessWidget {
  final double size;
  final bool withWhiteBackground;
  final double borderRadius;

  const DrMohansLogo({
    super.key,
    this.size = 52,
    this.withWhiteBackground = true,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = Image.asset(
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
        );
      },
    );

    if (withWhiteBackground) {
      final cardSize = size * 1.5;
      return Container(
        width: cardSize,
        height: cardSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: SizedBox(
          width: size,
          height: size,
          child: logoWidget,
        ),
      );
    }

    return logoWidget;
  }
}

