import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../data/models/bundle.dart';
import '../../data/models/bundle_category.dart';

/// A list item widget for displaying a bundle in the bundle list screen.
/// 
/// Follows the IpcCard pattern used throughout the app for consistency.
/// Displays bundle name, description, category chip, and component count.
class BundleListItem extends StatelessWidget {
  final Bundle bundle;
  final VoidCallback onTap;

  const BundleListItem({
    super.key,
    required this.bundle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = BundleCategory.fromString(bundle.category);
    final componentCount = bundle.components.length;

    return Card(
      elevation: 1,
      shadowColor: AppColors.textSecondary.withValues(alpha: 0.1),
      surfaceTintColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.neutralLight.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Semantics(
          button: true,
          label: '${bundle.name}. ${bundle.description}. $componentCount components. ${category.fullName} category.',
          hint: 'Tap to view bundle details',
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with category color
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 24,
                    semanticLabel: null,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bundle name
                      Text(
                        bundle.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.25,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.extraSmall),
                      
                      // Bundle description
                      Text(
                        bundle.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      
                      // Category chip and component count
                      Row(
                        children: [
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: category.color.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              category.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: category.color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.small),
                          
                          // Component count
                          Icon(
                            Icons.checklist_outlined,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$componentCount component${componentCount == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                
                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

