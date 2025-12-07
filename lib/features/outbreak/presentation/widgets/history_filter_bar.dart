import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/design_tokens.dart';
import '../../data/providers/history_providers.dart';

class HistoryFilterBar extends ConsumerStatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const HistoryFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  ConsumerState<HistoryFilterBar> createState() => _HistoryFilterBarState();
}

class _HistoryFilterBarState extends ConsumerState<HistoryFilterBar> {
  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(historyFilterProvider);
    final statisticsAsync = ref.watch(historyStatisticsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.neutralLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchExpanded ? 48 : 0,
            child: _isSearchExpanded
                ? TextField(
                    controller: widget.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search entries...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          widget.searchController.clear();
                          widget.onSearchChanged('');
                          setState(() {
                            _isSearchExpanded = false;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: widget.onSearchChanged,
                    autofocus: true,
                  )
                : const SizedBox.shrink(),
          ),

          if (_isSearchExpanded) const SizedBox(height: 16),

          // Filter chips and controls
          Row(
            children: [
              // Search toggle button
              if (!_isSearchExpanded)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearchExpanded = true;
                    });
                  },
                  tooltip: 'Search',
                ),

              // Filter chips
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      // Tool type filters
                      ...statisticsAsync.when(
                        loading: () => <Widget>[],
                        error: (_, __) => <Widget>[],
                        data: (stats) => stats.entries.map((entry) {
                          final toolType = entry.key;
                          final count = entry.value;
                          final isSelected = filter.toolTypes.contains(toolType);

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('$toolType ($count)'),
                              selected: isSelected,
                              onSelected: (selected) {
                                ref.read(historyFilterProvider.notifier)
                                    .toggleToolType(toolType);
                              },
                              selectedColor: _getToolTypeColor(toolType).withValues(alpha: 0.2),
                              checkmarkColor: _getToolTypeColor(toolType),
                              side: BorderSide(
                                color: isSelected
                                    ? _getToolTypeColor(toolType)
                                    : AppColors.neutralLight,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // Clear filters button
                      if (filter.hasActiveFilters) ...[
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('Clear'),
                          onPressed: () {
                            ref.read(historyFilterProvider.notifier).clearFilters();
                            widget.searchController.clear();
                          },
                          backgroundColor: AppColors.error.withValues(alpha: 0.1),
                          side: BorderSide(color: AppColors.error),
                          labelStyle: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Sort button
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.sort,
                  color: AppColors.textSecondary,
                ),
                tooltip: 'Sort',
                onSelected: (value) => _handleSortSelection(value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'timestamp_desc',
                    child: Row(
                      children: [
                        Icon(
                          filter.sortBy == 'timestamp' && filter.sortDescending
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Newest First'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'timestamp_asc',
                    child: Row(
                      children: [
                        Icon(
                          filter.sortBy == 'timestamp' && !filter.sortDescending
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Oldest First'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'title_asc',
                    child: Row(
                      children: [
                        Icon(
                          filter.sortBy == 'title'
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Title A-Z'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toolType_asc',
                    child: Row(
                      children: [
                        Icon(
                          filter.sortBy == 'toolType'
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Tool Type'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Active filters summary
          if (filter.hasActiveFilters) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: AppColors.info,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getActiveFiltersText(filter),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleSortSelection(String value) {
    final parts = value.split('_');
    final sortBy = parts[0];
    final descending = parts.length > 1 && parts[1] == 'desc';
    
    ref.read(historyFilterProvider.notifier).setSortBy(sortBy, descending: descending);
  }

  Color _getToolTypeColor(String toolType) {
    switch (toolType) {
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

  String _getActiveFiltersText(HistoryFilter filter) {
    final parts = <String>[];
    
    if (filter.searchQuery.isNotEmpty) {
      parts.add('Search: "${filter.searchQuery}"');
    }
    
    if (filter.toolTypes.isNotEmpty) {
      parts.add('Tools: ${filter.toolTypes.join(', ')}');
    }
    
    if (filter.tags.isNotEmpty) {
      parts.add('Tags: ${filter.tags.join(', ')}');
    }
    
    return parts.join(' • ');
  }
}
