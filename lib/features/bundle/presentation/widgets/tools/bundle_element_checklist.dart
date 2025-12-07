import 'package:flutter/material.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../data/models/bundle_tool_enums.dart';
import '../../../domain/bundle_tool_constants.dart';

/// Dynamic checklist for bundle elements
class BundleElementChecklist extends StatelessWidget {
  final BundleType bundleType;
  final Map<String, ComplianceStatus> elementStatuses;
  final Function(String elementId, ComplianceStatus status) onChanged;

  const BundleElementChecklist({
    super.key,
    required this.bundleType,
    required this.elementStatuses,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final elements = BundleToolConstants.getElementsForBundle(bundleType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Bundle Elements (${elements.length} items)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.small),

        // Elements list
        ...elements.map((element) {
          final status = elementStatuses[element.id] ?? ComplianceStatus.notApplicable;
          return _buildElementItem(element, status);
        }),
      ],
    );
  }

  Widget _buildElementItem(BundleElement element, ComplianceStatus status) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      elevation: 0,
      color: _getStatusColor(status).withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _getStatusColor(status).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.small),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Element name
            Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    element.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Element description
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                element.description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.small),

            // Status buttons
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Row(
                children: [
                  _buildStatusButton(
                    element.id,
                    ComplianceStatus.compliant,
                    status,
                  ),
                  const SizedBox(width: AppSpacing.small),
                  _buildStatusButton(
                    element.id,
                    ComplianceStatus.nonCompliant,
                    status,
                  ),
                  const SizedBox(width: AppSpacing.small),
                  _buildStatusButton(
                    element.id,
                    ComplianceStatus.notApplicable,
                    status,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    String elementId,
    ComplianceStatus buttonStatus,
    ComplianceStatus currentStatus,
  ) {
    final isSelected = buttonStatus == currentStatus;
    final color = _getStatusColor(buttonStatus);

    return Expanded(
      child: OutlinedButton(
        onPressed: () => onChanged(elementId, buttonStatus),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.transparent,
          side: BorderSide(
            color: isSelected ? color : AppColors.neutralLight,
            width: isSelected ? 2 : 1,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonStatus.icon,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                buttonStatus.shortLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return Icons.check_circle;
      case ComplianceStatus.nonCompliant:
        return Icons.cancel;
      case ComplianceStatus.notApplicable:
        return Icons.remove_circle_outline;
    }
  }

  Color _getStatusColor(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return AppColors.success;
      case ComplianceStatus.nonCompliant:
        return AppColors.error;
      case ComplianceStatus.notApplicable:
        return AppColors.warning;
    }
  }
}

