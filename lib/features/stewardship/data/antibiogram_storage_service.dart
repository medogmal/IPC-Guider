import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/saved_antibiogram.dart';

/// Antibiogram Storage Service
/// Handles saving and loading antibiograms using SharedPreferences
class AntibiogramStorageService {
  static const String _storageKey = 'saved_antibiograms';

  /// Save an antibiogram
  Future<void> saveAntibiogram(SavedAntibiogram antibiogram) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing antibiograms
    final List<SavedAntibiogram> antibiograms = await getAllAntibiograms();
    
    // Check if antibiogram with same ID exists
    final existingIndex = antibiograms.indexWhere((a) => a.id == antibiogram.id);
    
    if (existingIndex != -1) {
      // Update existing
      antibiograms[existingIndex] = antibiogram.copyWith(
        updatedAt: DateTime.now(),
      );
    } else {
      // Add new
      antibiograms.add(antibiogram);
    }
    
    // Save to storage
    final jsonList = antibiograms.map((a) => a.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Get all saved antibiograms
  Future<List<SavedAntibiogram>> getAllAntibiograms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => SavedAntibiogram.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Get antibiogram by ID
  Future<SavedAntibiogram?> getAntibiogramById(String id) async {
    final antibiograms = await getAllAntibiograms();
    try {
      return antibiograms.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Delete an antibiogram
  Future<void> deleteAntibiogram(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final antibiograms = await getAllAntibiograms();
    
    antibiograms.removeWhere((a) => a.id == id);
    
    final jsonList = antibiograms.map((a) => a.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Clear all antibiograms
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Get antibiograms count
  Future<int> getCount() async {
    final antibiograms = await getAllAntibiograms();
    return antibiograms.length;
  }
}

