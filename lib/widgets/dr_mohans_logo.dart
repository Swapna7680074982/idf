import 'package:flutter/material.dart';

class DrMohansLogo extends StatelessWidget {
  final double size;

  const DrMohansLogo({
    super.key,
    this.size = 84,
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
        );
      },
    );
  }
}
