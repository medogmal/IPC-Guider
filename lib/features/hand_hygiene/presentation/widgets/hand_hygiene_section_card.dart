import 'package:flutter/material.dart';
import '../../data/models/hand_hygiene_section.dart';
import '../../../../core/design/design_tokens.dart';

/// Card widget for displaying a hand hygiene section in the list
class HandHygieneSectionCard extends StatelessWidget {
  final HandHygieneSection section;
  final VoidCallback onTap;

  const HandHygieneSectionCard({
    super.key,
    required this.section,
    required this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fundamentals':
        return Icons.school_outlined;
      case 'techniques':
        return Icons.pan_tool_outlined;
      case 'compliance monitoring':
        return Icons.assessment_outlined;
      case 'infrastructure & products':
        return Icons.build_outlined;
      case 'special situations':
        return Icons.warning_amber_outlined;
      default:
        return Icons.clean_hands_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fundamentals':
        return AppColors.primary;
      case 'techniques':
        return AppColors.success;
      case 'compliance monitoring':
        return AppColors.info;
      case 'infrastructure & products':
        return AppColors.warning;
      case 'special situations':
        return AppColors.error;
      default:
        return AppColors.primary;
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

