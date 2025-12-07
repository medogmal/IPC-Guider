import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';
import '../../data/models/history_entry.dart';
import '../../data/providers/history_providers.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/history_entry_card.dart';
import '../widgets/history_detail_sheet.dart';
import '../widgets/history_export_dialog.dart';

class HistoryHubScreen extends ConsumerStatefulWidget {
  const HistoryHubScreen({super.key});

  @override
  ConsumerState<HistoryHubScreen> createState() => _HistoryHubScreenState();
}

class _HistoryHubScreenState extends ConsumerState<HistoryHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedEntryIds = <String>{};
  bool _isMultiSelectMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntriesAsync = ref.watch(filteredHistoryEntriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isMultiSelectMode
            ? Text('${_selectedEntryIds.length} selected')
            : const Text('History'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: _isMultiSelectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitMultiSelectMode,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
        actions: [
          if (_isMultiSelectMode) ...[
            if (_selectedEntryIds.isNotEmpty) ...[
              IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: _exportSelectedEntries,
                tooltip: 'Export Selected',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteSelectedEntries,
                tooltip: 'Delete Selected',
              ),
            ],
            PopupMenuButton<String>(
              onSelected: _handleBulkAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'select_all',
                  child: Text('Select All'),
                ),
                const PopupMenuItem(
                  value: 'deselect_all',
                  child: Text('Deselect All'),
                ),
              ],
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () => _showExportDialog(context),
              tooltip: 'Export All',
            ),
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All History', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          HistoryFilterBar(
            searchController: _searchController,
            onSearchChanged: (query) {
              ref.read(historyFilterProvider.notifier).setSearchQuery(query);
            },
          ),

          // Content
          Expanded(
            child: filteredEntriesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => _buildErrorState(error),
              data: (entries) => _buildEntriesList(entries),
            ),
          ),
        ],
      ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showExportDialog(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.file_download),
              label: const Text('Export'),
            ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(filteredHistoryEntriesProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<HistoryEntry> entries) {
    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isSelected = _selectedEntryIds.contains(entry.id);

        return HistoryEntryCard(
          entry: entry,
          isSelected: isSelected,
          isMultiSelectMode: _isMultiSelectMode,
          onTap: () => _handleEntryTap(entry),
          onLongPress: () => _handleEntryLongPress(entry),
          onSelectionChanged: (selected) => _handleSelectionChanged(entry.id, selected),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final filter = ref.watch(historyFilterProvider);
    final hasActiveFilters = filter.hasActiveFilters;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasActiveFilters ? Icons.search_off : Icons.history,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            hasActiveFilters ? 'No matching entries' : 'No history entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasActiveFilters
                ? 'Try adjusting your search or filters'
                : 'Your calculation and tool history will appear here',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(historyFilterProvider.notifier).clearFilters();
                _searchController.clear();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  void _handleEntryTap(HistoryEntry entry) {
    if (_isMultiSelectMode) {
      _handleSelectionChanged(entry.id, !_selectedEntryIds.contains(entry.id));
    } else {
      _showEntryDetail(entry);
    }
  }

  void _handleEntryLongPress(HistoryEntry entry) {
    if (!_isMultiSelectMode) {
      setState(() {
        _isMultiSelectMode = true;
        _selectedEntryIds.add(entry.id);
      });
    }
  }

  void _handleSelectionChanged(String entryId, bool selected) {
    setState(() {
      if (selected) {
        _selectedEntryIds.add(entryId);
      } else {
        _selectedEntryIds.remove(entryId);
      }

      // Exit multi-select mode if no items are selected
      if (_selectedEntryIds.isEmpty) {
        _isMultiSelectMode = false;
      }
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedEntryIds.clear();
    });
  }

  void _showEntryDetail(HistoryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HistoryDetailSheet(entry: entry),
    );
  }

  void _showExportDialog(BuildContext context) {
    final entriesAsync = ref.read(filteredHistoryEntriesProvider);

    entriesAsync.when(
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading entries...'),
          ),
        );
      },
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading entries: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      data: (entries) {
        if (entries.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No entries to export'),
              backgroundColor: AppColors.warning,
            ),
          );
          return;
        }

        showDialog(
          context: context,
          builder: (context) => HistoryExportDialog(
            entries: entries,
            onExportComplete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export completed successfully!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _exportSelectedEntries() {
    final entriesAsync = ref.read(filteredHistoryEntriesProvider);

    entriesAsync.when(
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading entries...')),
        );
      },
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      data: (allEntries) {
        final selectedEntries = allEntries
            .where((entry) => _selectedEntryIds.contains(entry.id))
            .toList();

        if (selectedEntries.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No entries selected'),
              backgroundColor: AppColors.warning,
            ),
          );
          return;
        }

        showDialog(
          context: context,
          builder: (context) => HistoryExportDialog(
            entries: selectedEntries,
            onExportComplete: () {
              _exitMultiSelectMode();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${selectedEntries.length} entries exported successfully!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _deleteSelectedEntries() {
    if (_selectedEntryIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entries'),
        content: Text(
          'Are you sure you want to delete ${_selectedEntryIds.length} selected entries? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performBulkDelete();
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

  void _performBulkDelete() {
    final count = _selectedEntryIds.length;
    final historyService = ref.read(historyServiceProvider);
    
    for (final entryId in _selectedEntryIds) {
      historyService.deleteEntry(entryId);
    }

    _exitMultiSelectMode();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count entries deleted successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleBulkAction(String action) {
    final entriesAsync = ref.read(filteredHistoryEntriesProvider);

    switch (action) {
      case 'select_all':
        entriesAsync.whenData((allEntries) {
          setState(() {
            _selectedEntryIds.addAll(allEntries.map((e) => e.id));
          });
        });
        break;
      case 'deselect_all':
        setState(() {
          _selectedEntryIds.clear();
          _isMultiSelectMode = false;
        });
        break;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_all':
        _showClearAllConfirmation();
        break;
      case 'settings':
        // TODO: Navigate to history settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History settings coming soon'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to delete all history entries? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(historyServiceProvider).clearAllEntries();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All history entries cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
