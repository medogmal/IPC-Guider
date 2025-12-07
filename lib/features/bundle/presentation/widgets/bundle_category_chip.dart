import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../data/models/bundle_category.dart';

/// A filter chip widget for bundle categories.
/// 
/// Used in the bundle list screen to filter bundles by category.
/// Follows Material Design chip patterns with category-specific colors.
class BundleCategoryChip extends StatelessWidget {
  final BundleCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const BundleCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? category.color : AppColors.textSecondary;
    final backgroundColor = isSelected
        ? category.color.withValues(alpha: 0.15)
        : AppColors.neutralLight.withValues(alpha: 0.5);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${category.fullName}${count != null ? '. $count bundles' : ''}',
      hint: isSelected ? 'Currently selected. Tap to deselect' : 'Tap to filter by this category',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? category.color.withValues(alpha: 0.5)
                    : AppColors.neutralLight,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Icon(
                  category.icon,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
                
                // Label
                Text(
                  category.displayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                    letterSpacing: 0.2,
                  ),
                ),
                
                // Count badge (if provided)
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

