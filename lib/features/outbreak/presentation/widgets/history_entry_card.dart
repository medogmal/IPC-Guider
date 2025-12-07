import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../data/models/history_entry.dart';

class HistoryEntryCard extends StatelessWidget {
  final HistoryEntry entry;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool> onSelectionChanged;
  final bool highlightEntry;

  const HistoryEntryCard({
    super.key,
    required this.entry,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.onTap,
    required this.onLongPress,
    required this.onSelectionChanged,
    this.highlightEntry = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(),
                width: highlightEntry ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected || highlightEntry)
                  BoxShadow(
                    color: _getBorderColor().withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Selection checkbox (in multi-select mode)
                if (isMultiSelectMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) => onSelectionChanged(value ?? false),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                ],

                // Tool type icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getToolTypeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getToolTypeIcon(),
                    color: _getToolTypeColor(),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and tool type badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getToolTypeColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getToolTypeColor().withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              entry.toolType,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _getToolTypeColor(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Timestamp
                      Text(
                        _formatTimestamp(entry.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Result preview
                      Text(
                        entry.result,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Inputs preview (if available)
                      if (entry.inputs.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _getInputsPreview(),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Tags (if available)
                      if (entry.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: entry.tags.take(3).map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.info,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing icon
                if (!isMultiSelectMode) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (highlightEntry) {
      return AppColors.primary.withValues(alpha: 0.05);
    }
    if (isSelected) {
      return AppColors.primary.withValues(alpha: 0.08);
    }
    return Colors.white;
  }

  Color _getBorderColor() {
    if (highlightEntry) {
      return AppColors.primary;
    }
    if (isSelected) {
      return AppColors.primary;
    }
    return AppColors.neutralLight;
  }

  Color _getToolTypeColor() {
    switch (entry.toolType) {
      case 'Calculator':
        return AppColors.primary;
      case 'Checklist':
        return AppColors.success;
      case 'Case Builder':
        return AppColors.warning;
      case 'Chart':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getToolTypeIcon() {
    switch (entry.toolType) {
      case 'Calculator':
        return Icons.calculate;
      case 'Checklist':
        return Icons.checklist;
      case 'Case Builder':
        return Icons.person_search;
      case 'Chart':
        return Icons.bar_chart;
      default:
        return Icons.analytics;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String _getInputsPreview() {
    if (entry.inputs.isEmpty) return '';
    
    final firstTwo = entry.inputs.entries.take(2);
    final preview = firstTwo.map((e) => '${e.key}: ${e.value}').join(', ');
    
    if (entry.inputs.length > 2) {
      return '$preview...';
    }
    
    return preview;
  }
}
