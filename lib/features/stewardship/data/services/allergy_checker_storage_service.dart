import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/allergy_assessment.dart';

/// Storage service for Allergy Cross-Reactivity Checker assessments
/// Uses SharedPreferences for local persistence
class AllergyCheckerStorageService {
  static const String _storageKey = 'allergy_assessments';

  /// Save an assessment
  Future<void> saveAssessment(AllergyAssessment assessment) async {
    final prefs = await SharedPreferences.getInstance();
    final assessments = await getAllAssessments();
    
    // Remove existing assessment with same ID (update)
    assessments.removeWhere((a) => a.id == assessment.id);
    
    // Add new assessment
    assessments.add(assessment);
    
    // Save to SharedPreferences
    final jsonList = assessments.map((a) => a.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  /// Get all assessments
  Future<List<AllergyAssessment>> getAllAssessments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => AllergyAssessment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Get assessment by ID
  Future<AllergyAssessment?> getAssessmentById(String id) async {
    final assessments = await getAllAssessments();
    try {
      return assessments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Delete an assessment
  Future<void> deleteAssessment(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final assessments = await getAllAssessments();
    
    assessments.removeWhere((a) => a.id == id);
    
    final jsonList = assessments.map((a) => a.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  /// Clear all assessments
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Get count of assessments
  Future<int> getCount() async {
    final assessments = await getAllAssessments();
    return assessments.length;
  }

  /// Get recent assessments (last N)
  Future<List<AllergyAssessment>> getRecentAssessments(int count) async {
    final assessments = await getAllAssessments();
    assessments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return assessments.take(count).toList();
  }
}

