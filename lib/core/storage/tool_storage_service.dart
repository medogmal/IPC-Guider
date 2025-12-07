import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Generic storage service for interactive tools
/// Provides type-safe CRUD operations using SharedPreferences
/// 
/// Usage:
/// ```dart
/// final service = ToolStorageService<SavedAntibiogram>(
///   storageKey: 'saved_antibiograms',
///   fromJson: SavedAntibiogram.fromJson,
///   toJson: (item) => item.toJson(),
///   getId: (item) => item.id,
/// );
/// ```
class ToolStorageService<T> {
  final String storageKey;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final String Function(T) getId;

  ToolStorageService({
    required this.storageKey,
    required this.fromJson,
    required this.toJson,
    required this.getId,
  });

  /// Save or update an item
  /// If an item with the same ID exists, it will be replaced
  Future<void> save(T item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await getAll();
      
      // Remove existing item with same ID (update)
      final itemId = getId(item);
      items.removeWhere((existingItem) => getId(existingItem) == itemId);
      
      // Add new item
      items.add(item);
      
      // Sort by timestamp if available (newest first)
      // This assumes items have a 'timestamp' or 'updatedAt' field
      try {
        items.sort((a, b) {
          final aJson = toJson(a);
          final bJson = toJson(b);
          final aTime = aJson['timestamp'] ?? aJson['updatedAt'] ?? aJson['createdAt'];
          final bTime = bJson['timestamp'] ?? bJson['updatedAt'] ?? bJson['createdAt'];
          if (aTime != null && bTime != null) {
            return DateTime.parse(bTime.toString()).compareTo(DateTime.parse(aTime.toString()));
          }
          return 0;
        });
      } catch (e) {
        // If sorting fails, continue without sorting
        debugPrint('ToolStorageService: Could not sort items: $e');
      }
      
      // Save to storage
      final jsonList = items.map((item) => toJson(item)).toList();
      await prefs.setString(storageKey, jsonEncode(jsonList));
      
      debugPrint('ToolStorageService: Saved item with ID $itemId to $storageKey');
    } catch (e) {
      debugPrint('ToolStorageService: Error saving item: $e');
      rethrow;
    }
  }

  /// Get all saved items
  Future<List<T>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(storageKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ToolStorageService: Error loading items from $storageKey: $e');
      return [];
    }
  }

  /// Get a specific item by ID
  Future<T?> getById(String id) async {
    try {
      final items = await getAll();
      return items.firstWhere(
        (item) => getId(item) == id,
        orElse: () => throw StateError('Item not found'),
      );
    } catch (e) {
      debugPrint('ToolStorageService: Item with ID $id not found in $storageKey');
      return null;
    }
  }

  /// Delete an item by ID
  Future<void> delete(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await getAll();
      
      items.removeWhere((item) => getId(item) == id);
      
      final jsonList = items.map((item) => toJson(item)).toList();
      await prefs.setString(storageKey, jsonEncode(jsonList));
      
      debugPrint('ToolStorageService: Deleted item with ID $id from $storageKey');
    } catch (e) {
      debugPrint('ToolStorageService: Error deleting item: $e');
      rethrow;
    }
  }

  /// Clear all items
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
      
      debugPrint('ToolStorageService: Cleared all items from $storageKey');
    } catch (e) {
      debugPrint('ToolStorageService: Error clearing items: $e');
      rethrow;
    }
  }

  /// Get count of saved items
  Future<int> getCount() async {
    final items = await getAll();
    return items.length;
  }

  /// Check if an item with the given ID exists
  Future<bool> exists(String id) async {
    final item = await getById(id);
    return item != null;
  }

  /// Get items filtered by a predicate
  Future<List<T>> getFiltered(bool Function(T) predicate) async {
    final items = await getAll();
    return items.where(predicate).toList();
  }
}

