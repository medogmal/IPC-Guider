import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_entry.dart';
import '../repositories/history_repository.dart';

// History repository provider
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

// History filter model
class HistoryFilter {
  final String searchQuery;
  final Set<String> toolTypes;
  final Set<String> tags;
  final String sortBy; // 'timestamp', 'title', 'toolType'
  final bool sortDescending;

  const HistoryFilter({
    this.searchQuery = '',
    this.toolTypes = const {},
    this.tags = const {},
    this.sortBy = 'timestamp',
    this.sortDescending = true,
  });

  HistoryFilter copyWith({
    String? searchQuery,
    Set<String>? toolTypes,
    Set<String>? tags,
    String? sortBy,
    bool? sortDescending,
  }) {
    return HistoryFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      toolTypes: toolTypes ?? this.toolTypes,
      tags: tags ?? this.tags,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }

  bool get hasActiveFilters {
    return searchQuery.isNotEmpty || toolTypes.isNotEmpty || tags.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryFilter &&
        other.searchQuery == searchQuery &&
        other.toolTypes == toolTypes &&
        other.tags == tags &&
        other.sortBy == sortBy &&
        other.sortDescending == sortDescending;
  }

  @override
  int get hashCode {
    return Object.hash(searchQuery, toolTypes, tags, sortBy, sortDescending);
  }
}

// History filter notifier
class HistoryFilterNotifier extends StateNotifier<HistoryFilter> {
  HistoryFilterNotifier() : super(const HistoryFilter());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleToolType(String toolType) {
    final newToolTypes = Set<String>.from(state.toolTypes);
    if (newToolTypes.contains(toolType)) {
      newToolTypes.remove(toolType);
    } else {
      newToolTypes.add(toolType);
    }
    state = state.copyWith(toolTypes: newToolTypes);
  }

  void toggleTag(String tag) {
    final newTags = Set<String>.from(state.tags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    state = state.copyWith(tags: newTags);
  }

  void setSortBy(String sortBy, {bool descending = true}) {
    state = state.copyWith(sortBy: sortBy, sortDescending: descending);
  }

  void clearFilters() {
    state = const HistoryFilter();
  }
}

// History filter provider
final historyFilterProvider = StateNotifierProvider<HistoryFilterNotifier, HistoryFilter>((ref) {
  return HistoryFilterNotifier();
});

// All history entries provider
final allHistoryEntriesProvider = FutureProvider<List<HistoryEntry>>((ref) async {
  final repository = ref.watch(historyRepositoryProvider);
  // Ensure repository is initialized
  if (!repository.isInitialized) {
    await repository.initialize();
  }
  return repository.getAllEntries();
});

// Filtered history entries provider
final filteredHistoryEntriesProvider = FutureProvider<List<HistoryEntry>>((ref) async {
  final allEntries = await ref.watch(allHistoryEntriesProvider.future);
  final filter = ref.watch(historyFilterProvider);

  var filteredEntries = allEntries.where((entry) {
    // Search filter
    if (filter.searchQuery.isNotEmpty) {
      if (!entry.matchesSearch(filter.searchQuery)) {
        return false;
      }
    }

    // Tool type filter
    if (filter.toolTypes.isNotEmpty) {
      if (!filter.toolTypes.contains(entry.toolType)) {
        return false;
      }
    }

    // Tags filter
    if (filter.tags.isNotEmpty) {
      if (!filter.tags.any((tag) => entry.hasTag(tag))) {
        return false;
      }
    }

    return true;
  }).toList();

  // Sort entries
  filteredEntries.sort((a, b) {
    int comparison;
    switch (filter.sortBy) {
      case 'title':
        comparison = a.title.compareTo(b.title);
        break;
      case 'toolType':
        comparison = a.toolType.compareTo(b.toolType);
        break;
      case 'timestamp':
      default:
        comparison = a.timestamp.compareTo(b.timestamp);
        break;
    }

    return filter.sortDescending ? -comparison : comparison;
  });

  return filteredEntries;
});

// History statistics provider
final historyStatisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(historyRepositoryProvider);
  // Ensure repository is initialized
  if (!repository.isInitialized) {
    await repository.initialize();
  }
  return repository.getEntriesCountByToolType();
});

// History service for business logic
class HistoryService {
  final HistoryRepository _repository;
  final Ref _ref;

  HistoryService(this._repository, this._ref);

  Future<void> addEntry(HistoryEntry entry) async {
    await _repository.addEntry(entry);
    _invalidateProviders();
  }

  Future<void> updateEntry(HistoryEntry entry) async {
    await _repository.updateEntry(entry);
    _invalidateProviders();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    _invalidateProviders();
  }

  Future<void> clearAllEntries() async {
    await _repository.clearAllEntries();
    _invalidateProviders();
  }

  Future<void> updateEntryNotes(String id, String notes) async {
    await _repository.updateEntryNotes(id, notes);
    _invalidateProviders();
  }

  List<HistoryEntry> searchEntries(String query) {
    return _repository.searchEntries(query);
  }

  List<HistoryEntry> getEntriesByToolType(String toolType) {
    return _repository.getEntriesByToolType(toolType);
  }

  HistoryEntry? getEntryById(String id) {
    try {
      return _repository.getEntryById(id);
    } catch (e) {
      return null;
    }
  }

  void _invalidateProviders() {
    _ref.invalidate(allHistoryEntriesProvider);
    _ref.invalidate(historyStatisticsProvider);
  }
}

// History service provider
final historyServiceProvider = Provider<HistoryService>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return HistoryService(repository, ref);
});

// Entry selection state for multi-select mode
class EntrySelectionState {
  final Set<String> selectedIds;
  final bool isMultiSelectMode;

  const EntrySelectionState({
    this.selectedIds = const {},
    this.isMultiSelectMode = false,
  });

  EntrySelectionState copyWith({
    Set<String>? selectedIds,
    bool? isMultiSelectMode,
  }) {
    return EntrySelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntrySelectionState &&
        other.selectedIds == selectedIds &&
        other.isMultiSelectMode == isMultiSelectMode;
  }

  @override
  int get hashCode => Object.hash(selectedIds, isMultiSelectMode);
}

// Entry selection notifier
class EntrySelectionNotifier extends StateNotifier<EntrySelectionState> {
  EntrySelectionNotifier() : super(const EntrySelectionState());

  void toggleSelection(String entryId) {
    final newSelectedIds = Set<String>.from(state.selectedIds);
    if (newSelectedIds.contains(entryId)) {
      newSelectedIds.remove(entryId);
    } else {
      newSelectedIds.add(entryId);
    }

    state = state.copyWith(
      selectedIds: newSelectedIds,
      isMultiSelectMode: newSelectedIds.isNotEmpty,
    );
  }

  void selectAll(List<String> entryIds) {
    state = state.copyWith(
      selectedIds: Set<String>.from(entryIds),
      isMultiSelectMode: true,
    );
  }

  void clearSelection() {
    state = const EntrySelectionState();
  }

  void enterMultiSelectMode(String firstSelectedId) {
    state = state.copyWith(
      selectedIds: {firstSelectedId},
      isMultiSelectMode: true,
    );
  }
}

// Entry selection provider
final entrySelectionProvider = StateNotifierProvider<EntrySelectionNotifier, EntrySelectionState>((ref) {
  return EntrySelectionNotifier();
});
