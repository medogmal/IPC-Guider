import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../data/models/history_entry.dart';
import '../../data/services/history_export_service.dart';

class HistoryExportDialog extends StatefulWidget {
  final List<HistoryEntry> entries;
  final VoidCallback? onExportComplete;

  const HistoryExportDialog({
    super.key,
    required this.entries,
    this.onExportComplete,
  });

  @override
  State<HistoryExportDialog> createState() => _HistoryExportDialogState();
}

class _HistoryExportDialogState extends State<HistoryExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.excel;
  bool _isExporting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final statistics = HistoryExportService.getExportStatistics(widget.entries);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.file_download,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          const Text('Export History'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Export statistics
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Entries: ${statistics['totalEntries']}'),
                  if (statistics['dateRange'] != null)
                    Text('Date Range: ${statistics['dateRange']}'),
                  Text('Estimated Size: ${statistics['estimatedSize']}'),
                  
                  // Tool type breakdown
                  if (statistics['toolTypes'] is Map && 
                      (statistics['toolTypes'] as Map).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tool Types:',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    ...(statistics['toolTypes'] as Map<String, int>)
                        .entries
                        .map((entry) => Text('  • ${entry.key}: ${entry.value}')),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Format selection
            const Text(
              'Export Format',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Format options
            ...ExportFormat.values.map((format) => RadioListTile<ExportFormat>(
              title: Text(_getFormatTitle(format)),
              subtitle: Text(_getFormatDescription(format)),
              value: format,
              groupValue: _selectedFormat,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              activeColor: AppColors.primary,
            )),

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Export progress
            if (_isExporting) ...[
              const SizedBox(height: 16),
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Preparing export...'),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _handleExport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Export'),
        ),
      ],
    );
  }

  String _getFormatTitle(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'CSV (Comma Separated Values)';
      case ExportFormat.excel:
        return 'Excel Spreadsheet';
      case ExportFormat.pdf:
        return 'PDF Document';
    }
  }

  String _getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'Compatible with Excel, Google Sheets, and other spreadsheet apps';
      case ExportFormat.excel:
        return 'Native Excel format with formatting and styling';
      case ExportFormat.pdf:
        return 'Portable document format for viewing and printing';
    }
  }

  Future<void> _handleExport() async {
    if (widget.entries.isEmpty) {
      setState(() {
        _errorMessage = 'No entries to export';
      });
      return;
    }

    setState(() {
      _isExporting = true;
      _errorMessage = null;
    });

    try {
      await HistoryExportService.shareExport(
        entries: widget.entries,
        format: _selectedFormat,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onExportComplete?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Export completed successfully! ${widget.entries.length} entries exported.',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _errorMessage = e.toString().replaceFirst('ExportException: ', '');
        });
      }
    }
  }
}
