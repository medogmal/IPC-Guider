import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/saved_renal_calculation.dart';

/// Service for saving and loading renal dose calculations
class RenalCalculationStorageService {
  static const String _storageKey = 'renal_calculations';

  /// Save a calculation
  Future<void> saveCalculation(SavedRenalCalculation calculation) async {
    final prefs = await SharedPreferences.getInstance();
    final calculations = await getAllCalculations();
    
    // Remove existing calculation with same ID (update)
    calculations.removeWhere((c) => c.id == calculation.id);
    
    // Add new calculation
    calculations.add(calculation);
    
    // Sort by timestamp (newest first)
    calculations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Save to storage
    final jsonList = calculations.map((c) => c.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Get all saved calculations
  Future<List<SavedRenalCalculation>> getAllCalculations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => SavedRenalCalculation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a specific calculation by ID
  Future<SavedRenalCalculation?> getCalculationById(String id) async {
    final calculations = await getAllCalculations();
    try {
      return calculations.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Delete a calculation
  Future<void> deleteCalculation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final calculations = await getAllCalculations();
    
    calculations.removeWhere((c) => c.id == id);
    
    final jsonList = calculations.map((c) => c.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Clear all calculations
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Get count of saved calculations
  Future<int> getCount() async {
    final calculations = await getAllCalculations();
    return calculations.length;
  }
}

