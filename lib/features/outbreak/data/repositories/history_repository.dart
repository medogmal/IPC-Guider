import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry.dart';

class HistoryRepository {
  static const String _boxName = 'history_entries';
  late Box<HistoryEntry> _box;

  // Singleton pattern
  static final HistoryRepository _instance = HistoryRepository._internal();
  factory HistoryRepository() => _instance;
  HistoryRepository._internal();

  // Initialize the repository
  Future<void> initialize() async {
    // Register adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HistoryEntryAdapter());
    }

    // Open the box
    _box = await Hive.openBox<HistoryEntry>(_boxName);

    // Migrate existing data from SharedPreferences if needed
    await _migrateFromSharedPreferences();
  }

  // Get all entries
  List<HistoryEntry> getAllEntries() {
    return _box.values.toList();
  }

  // Get entry by ID
  HistoryEntry? getEntryById(String id) {
    return _box.values.firstWhere(
      (entry) => entry.id == id,
      orElse: () => throw StateError('Entry not found'),
    );
  }

  // Add new entry
  Future<void> addEntry(HistoryEntry entry) async {
    await _box.put(entry.id, entry);
  }

  // Update existing entry
  Future<void> updateEntry(HistoryEntry entry) async {
    await _box.put(entry.id, entry);
  }

  // Delete entry by ID
  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
  }

  // Clear all entries
  Future<void> clearAllEntries() async {
    await _box.clear();
  }

  // Get entries by tool type
  List<HistoryEntry> getEntriesByToolType(String toolType) {
    return _box.values.where((entry) => entry.toolType == toolType).toList();
  }

  // Search entries
  List<HistoryEntry> searchEntries(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((entry) {
      return entry.title.toLowerCase().contains(lowerQuery) ||
             entry.result.toLowerCase().contains(lowerQuery) ||
             entry.notes.toLowerCase().contains(lowerQuery) ||
             entry.inputs.values.any((value) => 
                 value.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Get entries count by tool type
  Map<String, int> getEntriesCountByToolType() {
    final counts = <String, int>{};
    for (final entry in _box.values) {
      counts[entry.toolType] = (counts[entry.toolType] ?? 0) + 1;
    }
    return counts;
  }

  // Update entry notes
  Future<void> updateEntryNotes(String id, String notes) async {
    final entry = getEntryById(id);
    if (entry != null) {
      final updatedEntry = HistoryEntry(
        id: entry.id,
        timestamp: entry.timestamp,
        toolType: entry.toolType,
        title: entry.title,
        inputs: entry.inputs,
        result: entry.result,
        notes: notes,
        contextTag: entry.contextTag,
        tags: entry.tags,
      );
      await updateEntry(updatedEntry);
    }
  }

  // Migrate data from SharedPreferences to Hive
  Future<void> _migrateFromSharedPreferences() async {
    // Skip if we already have entries in Hive
    if (_box.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final migratedEntries = <HistoryEntry>[];

    // Migration keys for different tools
    final migrationKeys = [
      'analytics_history',
      'control_checklist_entries',
      'case_definition_history',
      'epicurve_history',
      'comparison_history',
      'histogram_history',
      'timeline_history',
    ];

    for (final key in migrationKeys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          final List<dynamic> jsonList = json.decode(jsonString);
          for (final jsonItem in jsonList) {
            final entry = _parseHistoryEntry(jsonItem, key);
            if (entry != null) {
              migratedEntries.add(entry);
            }
          }
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }
    }

    // Save migrated entries to Hive
    for (final entry in migratedEntries) {
      await addEntry(entry);
    }

    // Clean up old SharedPreferences data
    for (final key in migrationKeys) {
      await prefs.remove(key);
    }

    // Log migration result (commented out to avoid print in production)
    // Migrated ${migratedEntries.length} entries from SharedPreferences to Hive
  }

  // Parse history entry from different formats
  HistoryEntry? _parseHistoryEntry(dynamic jsonItem, String sourceKey) {
    try {
      if (jsonItem is! Map<String, dynamic>) return null;

      final Map<String, dynamic> json = jsonItem;
      
      // Generate ID if not present
      final id = json['id'] as String? ?? 
                 DateTime.now().millisecondsSinceEpoch.toString();

      // Parse timestamp
      DateTime timestamp;
      if (json['timestamp'] is String) {
        timestamp = DateTime.parse(json['timestamp']);
      } else if (json['date'] is String) {
        timestamp = DateTime.parse(json['date']);
      } else {
        timestamp = DateTime.now();
      }

      // Determine tool type from source key or data
      String toolType = _getToolTypeFromSourceKey(sourceKey);
      if (json['toolType'] is String) {
        toolType = json['toolType'];
      }

      // Parse title
      String title = json['title'] as String? ?? 
                     json['name'] as String? ?? 
                     'Untitled Entry';

      // Parse inputs
      Map<String, String> inputs = {};
      if (json['inputs'] is Map) {
        final inputsMap = json['inputs'] as Map;
        inputs = inputsMap.map((key, value) => 
            MapEntry(key.toString(), value.toString()));
      } else if (json['parameters'] is Map) {
        final paramsMap = json['parameters'] as Map;
        inputs = paramsMap.map((key, value) => 
            MapEntry(key.toString(), value.toString()));
      }

      // Parse result
      String result = json['result'] as String? ?? 
                      json['value'] as String? ?? 
                      'No result';

      // Parse notes
      String notes = json['notes'] as String? ?? '';

      // Parse context tag
      String? contextTag = json['contextTag'] as String?;

      // Parse tags
      List<String> tags = [];
      if (json['tags'] is List) {
        tags = (json['tags'] as List).cast<String>();
      }

      return HistoryEntry(
        id: id,
        timestamp: timestamp,
        toolType: toolType,
        title: title,
        inputs: inputs,
        result: result,
        notes: notes,
        contextTag: contextTag,
        tags: tags,
      );
    } catch (e) {
      return null;
    }
  }

  // Get tool type from source key
  String _getToolTypeFromSourceKey(String sourceKey) {
    switch (sourceKey) {
      case 'analytics_history':
        return 'Calculator';
      case 'control_checklist_entries':
        return 'Checklist';
      case 'case_definition_history':
        return 'Case Builder';
      case 'epicurve_history':
      case 'comparison_history':
      case 'histogram_history':
      case 'timeline_history':
        return 'Chart';
      default:
        return 'Unknown';
    }
  }

  // Get box for direct access (if needed)
  Box<HistoryEntry> get box => _box;

  // Check if repository is initialized
  bool get isInitialized => _box.isOpen;
}
