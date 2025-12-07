import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';

/// A card widget for displaying a single bundle component.
/// 
/// Used in the bundle detail screen to show each component of the bundle
/// with a numbered indicator and checkbox-style visual.
class BundleComponentCard extends StatelessWidget {
  final int number;
  final String component;
  final Color color;

  const BundleComponentCard({
    super.key,
    required this.number,
    required this.component,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Component $number: $component',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.small),
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number indicator with checkbox style
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            
            // Component text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  component,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                        fontSize: 14,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card widget for displaying a key point with an icon.
/// 
/// Used in the bundle detail screen to highlight important implementation points.
class BundleKeyPointCard extends StatelessWidget {
  final String keyPoint;
  final Color color;
  final IconData icon;

  const BundleKeyPointCard({
    super.key,
    required this.keyPoint,
    required this.color,
    this.icon = Icons.lightbulb_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Key point: $keyPoint',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.small),
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(width: AppSpacing.small),
            
            // Key point text
            Expanded(
              child: Text(
                keyPoint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                      fontSize: 14,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A section header widget for bundle detail sections.
/// 
/// Used to separate different sections in the bundle detail screen
/// (Components, Rationale, Implementation, Key Points, References).
class BundleSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const BundleSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.large,
        bottom: AppSpacing.medium,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.25,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

