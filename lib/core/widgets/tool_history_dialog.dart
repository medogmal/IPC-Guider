import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

/// Generic history dialog for interactive tools
/// Displays a list of saved items with load and delete actions
/// Mobile-responsive with proper text overflow handling
/// 
/// Usage:
/// ```dart
/// ToolHistoryDialog.show<SavedAntibiogram>(
///   context: context,
///   title: 'Saved Antibiograms',
///   items: antibiograms,
///   onLoad: (item) => _loadAntibiogram(item),
///   onDelete: (item) => _deleteAntibiogram(item.id),
///   itemBuilder: (item) => HistoryItemData(
///     title: item.facilityName,
///     subtitle: '${item.unit} • ${formatDate(item.startDate)}',
///     trailing: '${item.antibiogramData.length} entries',
///   ),
/// );
/// ```
class ToolHistoryDialog<T> {
  /// Show the history dialog
  static Future<void> show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required void Function(T) onLoad,
    required Future<void> Function(T) onDelete,
    required HistoryItemData Function(T) itemBuilder,
    String emptyMessage = 'No saved items yet.',
  }) async {
    if (items.isEmpty) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(emptyMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    return showDialog(
      context: context,
      builder: (context) => _HistoryDialogContent<T>(
        title: title,
        items: items,
        onLoad: onLoad,
        onDelete: onDelete,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

/// Data class for history item display
class HistoryItemData {
  final String title;
  final String subtitle;
  final String? trailing;
  final IconData icon;

  const HistoryItemData({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.icon = Icons.description,
  });
}

/// Internal widget for history dialog content
class _HistoryDialogContent<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final void Function(T) onLoad;
  final Future<void> Function(T) onDelete;
  final HistoryItemData Function(T) itemBuilder;

  const _HistoryDialogContent({
    required this.title,
    required this.items,
    required this.onLoad,
    required this.onDelete,
    required this.itemBuilder,
  });

  @override
  State<_HistoryDialogContent<T>> createState() => _HistoryDialogContentState<T>();
}

class _HistoryDialogContentState<T> extends State<_HistoryDialogContent<T>> {
  late List<T> _items;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxDialogHeight = screenHeight * 0.7;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${_items.length} saved',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
          maxWidth: 500,
        ),
        child: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final itemData = widget.itemBuilder(item);

              return _buildHistoryItem(item, itemData);
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(T item, HistoryItemData itemData) {
    return ListTile(
      leading: Icon(itemData.icon, color: AppColors.primary),
      title: Text(
        itemData.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        itemData.subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (itemData.trailing != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                itemData.trailing!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            onPressed: _isDeleting ? null : () => _handleDelete(item),
            tooltip: 'Delete',
          ),
        ],
      ),
      onTap: _isDeleting
          ? null
          : () {
              Navigator.of(context).pop();
              widget.onLoad(item);
            },
    );
  }

  Future<void> _handleDelete(T item) async {
    setState(() => _isDeleting = true);

    try {
      await widget.onDelete(item);
      
      if (!mounted) return;
      
      setState(() {
        _items.remove(item);
        _isDeleting = false;
      });

      // Close dialog if no items left
      if (_items.isEmpty && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isDeleting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting item: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

