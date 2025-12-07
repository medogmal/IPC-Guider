import 'dart:convert';
import 'package:flutter/services.dart';

/// Repository for loading allergy cross-reactivity rules
class AllergyCrossReactivityRepository {
  static final AllergyCrossReactivityRepository _instance =
      AllergyCrossReactivityRepository._internal();

  factory AllergyCrossReactivityRepository() => _instance;

  AllergyCrossReactivityRepository._internal();

  Map<String, dynamic>? _cachedData;

  /// Load cross-reactivity rules from JSON
  Future<Map<String, dynamic>> loadRules() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/stewardship/allergy_cross_reactivity_rules.json',
      );
      _cachedData = json.decode(jsonString) as Map<String, dynamic>;
      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load allergy cross-reactivity rules: $e');
    }
  }

  /// Get all drug classes
  Future<List<Map<String, dynamic>>> getAllDrugClasses() async {
    final data = await loadRules();
    return (data['drugClasses'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  /// Get drug class by ID
  Future<Map<String, dynamic>?> getDrugClassById(String id) async {
    final classes = await getAllDrugClasses();
    try {
      return classes.firstWhere((c) => c['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all drugs (flattened list)
  Future<List<String>> getAllDrugs() async {
    final classes = await getAllDrugClasses();
    final List<String> allDrugs = [];
    for (final drugClass in classes) {
      final drugs = (drugClass['drugs'] as List<dynamic>).cast<String>();
      allDrugs.addAll(drugs);
    }
    return allDrugs..sort();
  }

  /// Find drug class for a specific drug
  Future<Map<String, dynamic>?> findDrugClass(String drugName) async {
    final classes = await getAllDrugClasses();
    for (final drugClass in classes) {
      final drugs = (drugClass['drugs'] as List<dynamic>).cast<String>();
      if (drugs.any((d) => d.toLowerCase() == drugName.toLowerCase())) {
        return drugClass;
      }
    }
    return null;
  }

  /// Get cross-reactivity data for a drug class
  Future<Map<String, dynamic>?> getCrossReactivity(String drugClassId) async {
    final drugClass = await getDrugClassById(drugClassId);
    if (drugClass == null) return null;
    return drugClass['crossReactivity'] as Map<String, dynamic>?;
  }

  /// Get safe alternatives for a drug class
  Future<List<Map<String, dynamic>>> getSafeAlternatives(
      String drugClassId) async {
    final drugClass = await getDrugClassById(drugClassId);
    if (drugClass == null) return [];
    return (drugClass['safeAlternatives'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  /// Get references
  Future<List<Map<String, dynamic>>> getReferences() async {
    final data = await loadRules();
    return (data['references'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// Clear cache
  void clearCache() {
    _cachedData = null;
  }
}

