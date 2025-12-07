import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

/// Unified export modal for all tools
/// Provides consistent export options: PDF, CSV, Excel, Photo, Text
class ExportModal extends StatelessWidget {
  final VoidCallback onExportPDF;
  final VoidCallback onExportCSV;
  final VoidCallback onExportExcel;
  final VoidCallback? onExportPhoto;
  final VoidCallback onExportText;
  final bool enablePhoto;

  const ExportModal({
    super.key,
    required this.onExportPDF,
    required this.onExportCSV,
    required this.onExportExcel,
    this.onExportPhoto,
    required this.onExportText,
    this.enablePhoto = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.file_download_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Export Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: AppColors.textSecondary,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Choose export format',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Export Options
          _buildExportOption(
            context: context,
            icon: Icons.picture_as_pdf,
            iconColor: AppColors.error,
            title: 'PDF Document',
            description: 'Professional formatted report',
            onTap: () {
              Navigator.pop(context);
              onExportPDF();
            },
          ),

          const SizedBox(height: 12),

          _buildExportOption(
            context: context,
            icon: Icons.table_chart,
            iconColor: AppColors.success,
            title: 'Excel Spreadsheet',
            description: 'Formatted data table (.xlsx)',
            onTap: () {
              Navigator.pop(context);
              onExportExcel();
            },
          ),

          const SizedBox(height: 12),

          _buildExportOption(
            context: context,
            icon: Icons.grid_on,
            iconColor: AppColors.info,
            title: 'CSV File',
            description: 'Comma-separated values',
            onTap: () {
              Navigator.pop(context);
              onExportCSV();
            },
          ),

          if (enablePhoto && onExportPhoto != null) ...[
            const SizedBox(height: 12),
            _buildExportOption(
              context: context,
              icon: Icons.image_outlined,
              iconColor: AppColors.warning,
              title: 'Image (PNG)',
              description: 'Screenshot of results',
              onTap: () {
                Navigator.pop(context);
                onExportPhoto!();
              },
            ),
          ],

          const SizedBox(height: 12),

          _buildExportOption(
            context: context,
            icon: Icons.text_snippet_outlined,
            iconColor: AppColors.textSecondary,
            title: 'Plain Text',
            description: 'Simple text format',
            onTap: () {
              Navigator.pop(context);
              onExportText();
            },
          ),

          const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textTertiary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  /// Show export modal
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onExportPDF,
    required VoidCallback onExportCSV,
    required VoidCallback onExportExcel,
    VoidCallback? onExportPhoto,
    required VoidCallback onExportText,
    bool enablePhoto = false,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ExportModal(
        onExportPDF: onExportPDF,
        onExportCSV: onExportCSV,
        onExportExcel: onExportExcel,
        onExportPhoto: onExportPhoto,
        onExportText: onExportText,
        enablePhoto: enablePhoto,
      ),
    );
  }
}

