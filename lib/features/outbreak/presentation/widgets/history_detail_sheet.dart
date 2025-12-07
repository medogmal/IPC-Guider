import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/design_tokens.dart';
import '../../data/models/history_entry.dart';
import '../../data/providers/history_providers.dart';
import '../../data/services/history_export_service.dart';
import 'history_export_dialog.dart';

class HistoryDetailSheet extends ConsumerStatefulWidget {
  final HistoryEntry entry;

  const HistoryDetailSheet({
    super.key,
    required this.entry,
  });

  @override
  ConsumerState<HistoryDetailSheet> createState() => _HistoryDetailSheetState();
}

class _HistoryDetailSheetState extends ConsumerState<HistoryDetailSheet> {
  late TextEditingController _notesController;
  bool _isEditingNotes = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.entry.notes);
    _notesController.addListener(_onNotesChanged);
  }

  @override
  void dispose() {
    _notesController.removeListener(_onNotesChanged);
    _notesController.dispose();
    super.dispose();
  }

  void _onNotesChanged() {
    final hasChanges = _notesController.text != widget.entry.notes;
    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutralLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.neutralLight,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Tool type icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getToolTypeColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getToolTypeIcon(),
                        color: _getToolTypeColor(),
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Title and metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.entry.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
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
                                  ),
                                ),
                                child: Text(
                                  widget.entry.toolType,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _getToolTypeColor(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTimestamp(widget.entry.timestamp),
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

                    // Actions menu
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'export',
                          child: Row(
                            children: [
                              Icon(Icons.file_download),
                              SizedBox(width: 8),
                              Text('Export'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share),
                              SizedBox(width: 8),
                              Text('Share'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Result
                    _buildSection(
                      title: 'Result',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          widget.entry.result,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Inputs
                    if (widget.entry.inputs.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Inputs',
                        child: Column(
                          children: widget.entry.inputs.entries.map((entry) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: Text(entry.value),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    // Notes
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Notes',
                      trailing: _isEditingNotes
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_hasUnsavedChanges)
                                  TextButton(
                                    onPressed: _saveNotes,
                                    child: const Text('Save'),
                                  ),
                                TextButton(
                                  onPressed: _cancelEditNotes,
                                  child: const Text('Cancel'),
                                ),
                              ],
                            )
                          : TextButton(
                              onPressed: () => setState(() => _isEditingNotes = true),
                              child: const Text('Edit'),
                            ),
                      child: _isEditingNotes
                          ? TextField(
                              controller: _notesController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Add notes about this entry...',
                                border: OutlineInputBorder(),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.entry.notes.isEmpty
                                    ? 'No notes added'
                                    : widget.entry.notes,
                                style: TextStyle(
                                  color: widget.entry.notes.isEmpty
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                  fontStyle: widget.entry.notes.isEmpty
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                            ),
                    ),

                    // Context and Tags
                    if (widget.entry.contextTag != null || widget.entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Additional Information',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.entry.contextTag != null) ...[
                              Row(
                                children: [
                                  const Text(
                                    'Context: ',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(widget.entry.contextTag!),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (widget.entry.tags.isNotEmpty) ...[
                              const Text(
                                'Tags:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.entry.tags.map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.info.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.info.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.info,
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Metadata
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Metadata',
                      child: Column(
                        children: [
                          _buildMetadataRow('Created', _formatFullTimestamp(widget.entry.timestamp)),
                          if (widget.entry.id.isNotEmpty)
                            _buildMetadataRow('ID', widget.entry.id),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Color _getToolTypeColor() {
    switch (widget.entry.toolType) {
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
    switch (widget.entry.toolType) {
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

  String _formatFullTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _showExportDialog();
        break;
      case 'share':
        _shareEntry();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => HistoryExportDialog(
        entries: [widget.entry],
        onExportComplete: () {
          // Optional: Close the detail sheet after export
        },
      ),
    );
  }

  Future<void> _shareEntry() async {
    try {
      await HistoryExportService.shareExport(
        entries: [widget.entry],
        format: ExportFormat.csv,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share entry: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close detail sheet
              ref.read(historyServiceProvider).deleteEntry(widget.entry.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNotes() async {
    try {
      await ref.read(historyServiceProvider).updateEntryNotes(
        widget.entry.id,
        _notesController.text,
      );
      
      setState(() {
        _isEditingNotes = false;
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notes saved successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save notes: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _cancelEditNotes() {
    _notesController.text = widget.entry.notes;
    setState(() {
      _isEditingNotes = false;
      _hasUnsavedChanges = false;
    });
  }
}
