import 'package:flutter/material.dart';
import '../domain/quiz_models.dart';

class QuizBadgeChip extends StatelessWidget {
  final BadgeSpec spec;
  final String? subtitle; // optional small text
  const QuizBadgeChip({super.key, required this.spec, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: spec.color.withValues(alpha: 0.12),
        shape: StadiumBorder(side: BorderSide(color: spec.color)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(spec.icon, color: spec.color, size: 18),
          const SizedBox(width: 6),
          Text(spec.title, style: TextStyle(color: spec.color, fontWeight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(width: 6),
            Text(subtitle!, style: TextStyle(color: spec.color.withValues(alpha: 0.9))),
          ]
        ],
      ),
    );
  }
}
