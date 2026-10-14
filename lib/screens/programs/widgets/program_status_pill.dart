import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/program_model.dart';

class ProgramStatusPill extends StatefulWidget {
  final ProgramStatus status;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final bool hasShadow;

  const ProgramStatusPill({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding,
    this.hasShadow = true,
  });

  @override
  State<ProgramStatusPill> createState() => _ProgramStatusPillState();
}

class _ProgramStatusPillState extends State<ProgramStatusPill> with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.status == ProgramStatus.ongoing) {
      _initPulseAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant ProgramStatusPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == ProgramStatus.ongoing && _pulseController == null) {
      _initPulseAnimation();
    } else if (widget.status != ProgramStatus.ongoing && _pulseController != null) {
      _pulseController?.dispose();
      _pulseController = null;
    }
  }

  void _initPulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final String label;

    switch (status) {
      case ProgramStatus.upcoming:
        bgColor = const Color(0xFFE0F2FE);
        borderColor = const Color(0xFFBAE6FD);
        textColor = const Color(0xFF0284C7);
        label = 'Upcoming';
        break;
      case ProgramStatus.ongoing:
        bgColor = const Color(0xFFDCFCE7);
        borderColor = const Color(0xFF86EFAC);
        textColor = const Color(0xFF16A34A);
        label = 'Ongoing';
        break;
      case ProgramStatus.completed:
        bgColor = const Color(0xFFF1F5F9);
        borderColor = const Color(0xFFCBD5E1);
        textColor = const Color(0xFF64748B);
        label = 'Completed';
        break;
      case ProgramStatus.cancelled:
        bgColor = const Color(0xFFFEE2E2);
        borderColor = const Color(0xFFFCA5A5);
        textColor = const Color(0xFFDC2626);
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bgColor.withAlpha(240),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: widget.hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (status == ProgramStatus.ongoing) ...[
            _buildPulsingDot(textColor),
            const SizedBox(width: 5.5),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot(Color color) {
    if (_pulseAnimation == null) {
      return Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 7 * _pulseAnimation!.value,
              height: 7 * _pulseAnimation!.value,
              decoration: BoxDecoration(
                color: color.withAlpha((80 / _pulseAnimation!.value).clamp(20, 100).toInt()),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 6.5,
              height: 6.5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}
