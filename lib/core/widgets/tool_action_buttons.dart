import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

/// Reusable action buttons for interactive tools
/// Provides consistent UI patterns across all modules

/// AppBar action button for Save
class SaveAppBarButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final bool enabled;

  const SaveAppBarButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Save',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.save_outlined),
      onPressed: enabled ? onPressed : null,
      tooltip: tooltip,
    );
  }
}

/// AppBar action button for Load/History
class LoadAppBarButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final bool showHistory;

  const LoadAppBarButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Load',
    this.showHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(showHistory ? Icons.history : Icons.folder_open),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}

/// AppBar action button for Export/Share
class ExportAppBarButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final bool enabled;

  const ExportAppBarButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Export',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share_outlined),
      onPressed: enabled ? onPressed : null,
      tooltip: tooltip,
    );
  }
}

/// AppBar action button for Help
class HelpAppBarButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const HelpAppBarButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Help & Guidelines',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}

/// Full-width Save button (for results sections)
class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;
  final bool enabled;

  const SaveButton({
    super.key,
    required this.onPressed,
    this.label = 'Save',
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled && !isLoading ? onPressed : null,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save_outlined),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.success,
        side: BorderSide(
          color: enabled ? AppColors.success : AppColors.textSecondary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Full-width Export button (for results sections)
class ExportButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;
  final bool enabled;

  const ExportButton({
    super.key,
    required this.onPressed,
    this.label = 'Export',
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: enabled && !isLoading ? onPressed : null,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.file_download),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Reusable row of Save + Export buttons
/// Standard pattern used across all tools
class SaveExportButtonRow extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onExport;
  final String saveLabel;
  final String exportLabel;
  final bool saveEnabled;
  final bool exportEnabled;
  final bool saveLoading;
  final bool exportLoading;

  const SaveExportButtonRow({
    super.key,
    required this.onSave,
    required this.onExport,
    this.saveLabel = 'Save',
    this.exportLabel = 'Export',
    this.saveEnabled = true,
    this.exportEnabled = true,
    this.saveLoading = false,
    this.exportLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SaveButton(
            onPressed: onSave,
            label: saveLabel,
            enabled: saveEnabled,
            isLoading: saveLoading,
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: ExportButton(
            onPressed: onExport,
            label: exportLabel,
            enabled: exportEnabled,
            isLoading: exportLoading,
          ),
        ),
      ],
    );
  }
}
