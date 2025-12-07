import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/surgical_prophylaxis.dart';

/// Repository for surgical prophylaxis data
class SurgicalProphylaxisRepository {
  static final SurgicalProphylaxisRepository _instance =
      SurgicalProphylaxisRepository._internal();

  factory SurgicalProphylaxisRepository() => _instance;

  SurgicalProphylaxisRepository._internal();

  List<SurgicalProcedure>? _cachedProcedures;

  /// Load all surgical procedures
  Future<List<SurgicalProcedure>> loadProcedures() async {
    if (_cachedProcedures != null) {
      return _cachedProcedures!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/stewardship/surgical_prophylaxis_data.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final proceduresJson = jsonData['procedures'] as List<dynamic>;

      _cachedProcedures = proceduresJson
          .map((e) => SurgicalProcedure.fromJson(e as Map<String, dynamic>))
          .toList();

      return _cachedProcedures!;
    } catch (e) {
      throw Exception('Failed to load surgical prophylaxis data: $e');
    }
  }

  /// Get procedure by ID
  Future<SurgicalProcedure?> getProcedureById(String id) async {
    final procedures = await loadProcedures();
    try {
      return procedures.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get procedures by specialty
  Future<List<SurgicalProcedure>> getProceduresBySpecialty(
    SurgicalSpecialty specialty,
  ) async {
    final procedures = await loadProcedures();
    return procedures.where((p) => p.specialty == specialty).toList();
  }

  /// Search procedures by name
  Future<List<SurgicalProcedure>> searchProcedures(String query) async {
    if (query.isEmpty) {
      return loadProcedures();
    }

    final procedures = await loadProcedures();
    final lowerQuery = query.toLowerCase();

    return procedures.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.description.toLowerCase().contains(lowerQuery) ||
          p.specialty.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get recommendation for procedure and patient profile
  Future<Map<String, dynamic>> getRecommendation({
    required String procedureId,
    required PatientProfile patientProfile,
  }) async {
    final procedure = await getProcedureById(procedureId);
    if (procedure == null) {
      throw Exception('Procedure not found');
    }

    // Determine primary recommendation based on patient profile
    ProphylaxisRecommendation primaryRecommendation;
    final List<ProphylaxisRecommendation> alternatives = [];

    if (patientProfile.hasBetaLactamAllergy) {
      // Use beta-lactam alternative as primary
      if (procedure.betaLactamAllergyAlternative != null) {
        primaryRecommendation = procedure.betaLactamAllergyAlternative!;
      } else {
        // Fallback to primary if no alternative specified
        primaryRecommendation = procedure.primaryProphylaxis;
      }
      // Add MRSA coverage if needed
      if (patientProfile.hasMRSAColonization &&
          procedure.mrsaCoverageAddition != null) {
        alternatives.add(procedure.mrsaCoverageAddition!);
      }
    } else {
      // Use primary prophylaxis
      primaryRecommendation = procedure.primaryProphylaxis;
      
      // Add alternatives
      if (procedure.betaLactamAllergyAlternative != null) {
        alternatives.add(procedure.betaLactamAllergyAlternative!);
      }
      
      // Add MRSA coverage if needed
      if (patientProfile.hasMRSAColonization &&
          procedure.mrsaCoverageAddition != null) {
        primaryRecommendation = procedure.mrsaCoverageAddition!;
      }
    }

    // Adjust dose for weight if applicable
    if (patientProfile.weight != null && patientProfile.weight! >= 120) {
      primaryRecommendation = _adjustDoseForWeight(
        primaryRecommendation,
        patientProfile.weight!,
      );
    }

    return {
      'procedure': procedure,
      'primaryRecommendation': primaryRecommendation,
      'alternatives': alternatives,
      'specialConsiderations': procedure.specialConsiderations,
      'references': procedure.references,
    };
  }

  /// Adjust dose for patient weight
  ProphylaxisRecommendation _adjustDoseForWeight(
    ProphylaxisRecommendation recommendation,
    double weight,
  ) {
    // Simple weight-based adjustment logic
    // In production, this would be more sophisticated
    String adjustedDose = recommendation.dose;
    
    if (weight >= 120 && recommendation.antibioticName.contains('Cefazolin')) {
      adjustedDose = adjustedDose.replaceAll('2 g', '3 g');
    }

    return ProphylaxisRecommendation(
      antibioticName: recommendation.antibioticName,
      dose: adjustedDose,
      route: recommendation.route,
      timing: recommendation.timing,
      duration: recommendation.duration,
      redosingInterval: recommendation.redosingInterval,
      rationale: recommendation.rationale,
      warnings: recommendation.warnings,
      monitoring: recommendation.monitoring,
      isAlternative: recommendation.isAlternative,
    );
  }

  /// Clear cache
  void clearCache() {
    _cachedProcedures = null;
  }
}

