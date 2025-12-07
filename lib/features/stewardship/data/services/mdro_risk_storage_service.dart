import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mdro_assessment.dart';

class MdroRiskStorageService {
  static const String _storageKey = 'mdro_assessments';

  Future<void> saveAssessment(MdroAssessment assessment) async {
    final prefs = await SharedPreferences.getInstance();
    final assessments = await getAllAssessments();
    assessments.add(assessment);

    final jsonList = assessments.map((a) => a.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  Future<List<MdroAssessment>> getAllAssessments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      return [];
    }

    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((json) => MdroAssessment.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<MdroAssessment?> getAssessmentById(String id) async {
    final assessments = await getAllAssessments();
    try {
      return assessments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteAssessment(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final assessments = await getAllAssessments();
    assessments.removeWhere((a) => a.id == id);

    final jsonList = assessments.map((a) => a.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<int> getCount() async {
    final assessments = await getAllAssessments();
    return assessments.length;
  }

  Future<List<MdroAssessment>> getRecentAssessments(int count) async {
    final assessments = await getAllAssessments();
    assessments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return assessments.take(count).toList();
  }
}

