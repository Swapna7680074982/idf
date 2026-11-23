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
    final logoImage = Image.asset(
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

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: showBackgroundGlow
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: ClipOval(
        child: logoImage,
      ),
    );
  }
}
