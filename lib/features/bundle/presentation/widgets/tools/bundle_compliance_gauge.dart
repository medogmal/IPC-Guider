import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../../core/design/design_tokens.dart';

/// Circular gauge widget for displaying compliance score
class BundleComplianceGauge extends StatelessWidget {
  final double score;
  final double size;
  final bool showLabel;
  final String? label;

  const BundleComplianceGauge({
    super.key,
    required this.score,
    this.size = 120,
    this.showLabel = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getComplianceColor(score);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              score: score,
              color: color,
            ),
          ),

          // Score text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${score.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (showLabel)
                Text(
                  label ?? _getComplianceLabel(score),
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getComplianceColor(double score) {
    if (score >= 95) return AppColors.success;
    if (score >= 85) return AppColors.warning;
    if (score >= 75) return AppColors.info;
    return AppColors.error;
  }

  String _getComplianceLabel(double score) {
    if (score >= 95) return 'Excellent';
    if (score >= 85) return 'Good';
    if (score >= 75) return 'Moderate';
    return 'Poor';
  }
}

class _GaugePainter extends CustomPainter {
  final double score;
  final Color color;

  _GaugePainter({
    required this.score,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.12;

    // Background arc
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2, // Start at top
      2 * math.pi, // Full circle
      false,
      backgroundPaint,
    );

    // Foreground arc (progress)
    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2, // Start at top
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}

