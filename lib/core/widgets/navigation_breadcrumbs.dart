import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Standardized navigation breadcrumbs for the IPC Guider app
/// Follows the CodeGear-1 protocol for consistent navigation experience
class NavigationBreadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final double? spacing;
  final Color? textColor;
  final Color? separatorColor;
  final bool showHome;
  final VoidCallback? onHomePressed;

  const NavigationBreadcrumbs({
    super.key,
    required this.items,
    this.spacing,
    this.textColor,
    this.separatorColor,
    this.showHome = true,
    this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    final breadcrumbItems = <BreadcrumbItem>[];

    // Add home button if enabled
    if (showHome) {
      breadcrumbItems.add(
        BreadcrumbItem(
          label: 'Home',
          route: '/',
          icon: 'home',
        ),
      );
    }

    // Add provided items
    breadcrumbItems.addAll(items);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < breadcrumbItems.length; i++) ...[
            if (i > 0) ...[
              SizedBox(width: spacing ?? 4),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: separatorColor ?? Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
              ),
              SizedBox(width: spacing ?? 4),
            ],
            _BreadcrumbItemWidget(
              item: breadcrumbItems[i],
              isLast: i == breadcrumbItems.length - 1,
              textColor: textColor,
              onHomePressed: i == 0 && showHome ? onHomePressed : null,
            ),
          ],
        ],
      ),
    );
  }
}

/// Represents a single breadcrumb item
class BreadcrumbItem {
  final String label;
  final String? route;
  final String? icon;
  final Map<String, String>? parameters;

  const BreadcrumbItem({
    required this.label,
    this.route,
    this.icon,
    this.parameters,
  });
}

/// Widget for rendering a single breadcrumb item
class _BreadcrumbItemWidget extends StatelessWidget {
  final BreadcrumbItem item;
  final bool isLast;
  final Color? textColor;
  final VoidCallback? onHomePressed;

  const _BreadcrumbItemWidget({
    required this.item,
    required this.isLast,
    this.textColor,
    this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLast ? null : (onHomePressed ?? () => context.go(item.route!, extra: item.parameters)),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                _getIconData(item.icon!),
                size: 16,
                color: isLast
                    ? (textColor ?? Theme.of(context).textTheme.titleLarge?.color)
                    : (textColor ?? Theme.of(context).textTheme.bodyMedium?.color)?.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              item.label,
              style: TextStyle(
                color: isLast
                    ? (textColor ?? Theme.of(context).textTheme.titleLarge?.color)
                    : (textColor ?? Theme.of(context).textTheme.bodyMedium?.color)?.withValues(alpha: 0.7),
                fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'home':
        return Icons.home_outlined;
      case 'search':
        return Icons.search;
      case 'calculate':
        return Icons.calculate;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'verified':
        return Icons.verified_user_outlined;
      case 'checklist':
        return Icons.checklist_outlined;
      case 'clean_hands':
        return Icons.clean_hands_outlined;
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      case 'medication':
        return Icons.medication_outlined;
      default:
        return Icons.circle;
    }
  }
}
