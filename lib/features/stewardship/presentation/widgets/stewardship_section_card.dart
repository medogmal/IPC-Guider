import 'package:flutter/material.dart';
import '../../data/models/stewardship_section.dart';
import '../../../../core/design/design_tokens.dart';

/// Card widget for displaying an antimicrobial stewardship section in the list
class StewardshipSectionCard extends StatelessWidget {
  final StewardshipSection section;
  final VoidCallback onTap;

  const StewardshipSectionCard({
    super.key,
    required this.section,
    required this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fundamentals':
        return Icons.school_outlined;
      case 'resistance':
        return Icons.biotech_outlined;
      case 'antibiogram':
        return Icons.analytics_outlined;
      case 'prescribing':
        return Icons.medication_outlined;
      case 'interventions':
        return Icons.build_outlined;
      case 'monitoring':
        return Icons.assessment_outlined;
      default:
        return Icons.medication_liquid;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fundamentals':
        return AppColors.primary;
      case 'resistance':
        return AppColors.error;
      case 'antibiogram':
        return AppColors.info;
      case 'prescribing':
        return AppColors.success;
      case 'interventions':
        return AppColors.warning;
      case 'monitoring':
        return AppColors.primary;
      default:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(section.category);
    final categoryIcon = _getCategoryIcon(section.category);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      section.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Row(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${section.pages.length} ${section.pages.length == 1 ? 'page' : 'pages'}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

