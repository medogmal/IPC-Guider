import 'dart:convert';
import 'package:flutter/services.dart';

class MdroRiskRepository {
  static final MdroRiskRepository _instance = MdroRiskRepository._internal();
  factory MdroRiskRepository() => _instance;
  MdroRiskRepository._internal();

  Map<String, dynamic>? _cachedData;

  Future<Map<String, dynamic>> loadScoringRules() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/stewardship/mdro_risk_scoring.json');
      _cachedData = json.decode(jsonString) as Map<String, dynamic>;
      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load MDRO risk scoring rules: $e');
    }
  }

  Future<Map<String, dynamic>> getScoringRules() async {
    final data = await loadScoringRules();
    return data['scoringRules'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getRiskThresholds() async {
    final data = await loadScoringRules();
    return data['riskThresholds'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getOrganismRiskFactors() async {
    final data = await loadScoringRules();
    return data['organismRiskFactors'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getRecommendations() async {
    final data = await loadScoringRules();
    return data['recommendations'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getReferences() async {
    final data = await loadScoringRules();
    final references = data['references'] as List;
    return references.map((ref) => ref as Map<String, dynamic>).toList();
  }

  int calculateRiskScore(Map<String, dynamic> inputs, Map<String, dynamic> scoringRules) {
    int totalScore = 0;

    // Age
    final age = inputs['age'] as String;
    final ageScores = scoringRules['age'] as Map<String, dynamic>;
    totalScore += (ageScores[age] as int?) ?? 0;

    // Hospital Admission
    final hospitalAdmission = inputs['hospitalAdmission'] as String;
    final hospitalScores = scoringRules['hospitalAdmission'] as Map<String, dynamic>;
    totalScore += (hospitalScores[hospitalAdmission] as int?) ?? 0;

    // ICU Stay
    final icuStay = inputs['icuStay'] as String;
    final icuScores = scoringRules['icuStay'] as Map<String, dynamic>;
    totalScore += (icuScores[icuStay] as int?) ?? 0;

    // Nursing Home
    final nursingHome = inputs['nursingHome'] as String;
    final nursingHomeScores = scoringRules['nursingHome'] as Map<String, dynamic>;
    totalScore += (nursingHomeScores[nursingHome] as int?) ?? 0;

    // Hemodialysis
    if (inputs['hemodialysis'] as bool) {
      totalScore += scoringRules['hemodialysis'] as int;
    }

    // Surgery
    if (inputs['surgery'] as bool) {
      totalScore += scoringRules['surgery'] as int;
    }

    // Antibiotic Use
    final antibioticUse = inputs['antibioticUse'] as String;
    final antibioticScores = scoringRules['antibioticUse'] as Map<String, dynamic>;
    totalScore += (antibioticScores[antibioticUse] as int?) ?? 0;

    // Broad-Spectrum Antibiotics
    final broadSpectrumAntibiotics = inputs['broadSpectrumAntibiotics'] as List<String>;
    final broadSpectrumScores = scoringRules['broadSpectrumAntibiotics'] as Map<String, dynamic>;
    for (final antibiotic in broadSpectrumAntibiotics) {
      totalScore += (broadSpectrumScores[antibiotic] as int?) ?? 0;
    }

    // Invasive Devices
    final invasiveDevices = inputs['invasiveDevices'] as List<String>;
    final deviceScores = scoringRules['invasiveDevices'] as Map<String, dynamic>;
    for (final device in invasiveDevices) {
      totalScore += (deviceScores[device] as int?) ?? 0;
    }

    // Immunosuppression
    final immunosuppression = inputs['immunosuppression'] as List<String>;
    final immunoScores = scoringRules['immunosuppression'] as Map<String, dynamic>;
    for (final condition in immunosuppression) {
      totalScore += (immunoScores[condition] as int?) ?? 0;
    }

    // Chronic Conditions
    final chronicConditions = inputs['chronicConditions'] as List<String>;
    final chronicScores = scoringRules['chronicConditions'] as Map<String, dynamic>;
    for (final condition in chronicConditions) {
      totalScore += (chronicScores[condition] as int?) ?? 0;
    }

    // Prior MDRO
    final priorMdro = inputs['priorMdro'] as String;
    final priorMdroScores = scoringRules['priorMdro'] as Map<String, dynamic>;
    totalScore += (priorMdroScores[priorMdro] as int?) ?? 0;

    // International Travel
    if (inputs['internationalTravel'] as bool) {
      totalScore += scoringRules['internationalTravel'] as int;
    }

    // Known MDRO Contact
    if (inputs['knownMdroContact'] as bool) {
      totalScore += scoringRules['knownMdroContact'] as int;
    }

    return totalScore;
  }

  Map<String, dynamic> getRiskCategory(int score, Map<String, dynamic> thresholds) {
    if (score >= (thresholds['veryHigh']['min'] as int)) {
      return thresholds['veryHigh'] as Map<String, dynamic>;
    } else if (score >= (thresholds['high']['min'] as int)) {
      return thresholds['high'] as Map<String, dynamic>;
    } else if (score >= (thresholds['moderate']['min'] as int)) {
      return thresholds['moderate'] as Map<String, dynamic>;
    } else {
      return thresholds['low'] as Map<String, dynamic>;
    }
  }

  Map<String, String> calculateOrganismRisks(
    Map<String, dynamic> inputs,
    Map<String, dynamic> organismRiskFactors,
  ) {
    final Map<String, String> organismRisks = {};

    organismRiskFactors.forEach((organism, factors) {
      final factorData = factors as Map<String, dynamic>;
      final highRiskFactors = factorData['highRiskFactors'] as List;
      final moderateRiskFactors = factorData['moderateRiskFactors'] as List;

      int matchedHighRisk = 0;
      int matchedModerateRisk = 0;

      // Check high risk factors
      for (final factor in highRiskFactors) {
        if (_hasRiskFactor(inputs, factor as String)) {
          matchedHighRisk++;
        }
      }

      // Check moderate risk factors
      for (final factor in moderateRiskFactors) {
        if (_hasRiskFactor(inputs, factor as String)) {
          matchedModerateRisk++;
        }
      }

      // Determine organism-specific risk level
      if (matchedHighRisk >= 2) {
        organismRisks[organism] = 'High';
      } else if (matchedHighRisk >= 1 || matchedModerateRisk >= 2) {
        organismRisks[organism] = 'Moderate';
      } else {
        organismRisks[organism] = 'Low';
      }
    });

    return organismRisks;
  }

  bool _hasRiskFactor(Map<String, dynamic> inputs, String factor) {
    switch (factor) {
      case 'nursingHome':
        return inputs['nursingHome'] != 'No';
      case 'hemodialysis':
        return inputs['hemodialysis'] as bool;
      case 'priorMRSA':
        return (inputs['mdroTypes'] as List<String>).contains('MRSA');
      case 'icuStay':
        return inputs['icuStay'] != 'No';
      case 'broadSpectrumAntibiotics':
        return (inputs['broadSpectrumAntibiotics'] as List<String>).isNotEmpty;
      case 'priorVRE':
        return (inputs['mdroTypes'] as List<String>).contains('VRE');
      case 'hospitalAdmission':
        return inputs['hospitalAdmission'] != 'None';
      case 'immunosuppression':
        return (inputs['immunosuppression'] as List<String>).isNotEmpty;
      case 'internationalTravel':
        return inputs['internationalTravel'] as bool;
      case 'priorESBL':
        return (inputs['mdroTypes'] as List<String>).contains('ESBL');
      case 'urinaryCatheter':
        return (inputs['invasiveDevices'] as List<String>).contains('Urinary catheter');
      case 'carbapenems':
        return (inputs['broadSpectrumAntibiotics'] as List<String>).contains('Carbapenems');
      case 'priorCRE':
        return (inputs['mdroTypes'] as List<String>).contains('CRE');
      case 'invasiveDevices':
        return (inputs['invasiveDevices'] as List<String>).isNotEmpty;
      case 'endotrachealTube':
        return (inputs['invasiveDevices'] as List<String>).contains('Endotracheal tube');
      case 'age≥65':
        return inputs['age'] == '65-79 years' || inputs['age'] == '≥80 years';
      case 'chronicConditions':
        return (inputs['chronicConditions'] as List<String>).isNotEmpty;
      case 'surgery':
        return inputs['surgery'] as bool;
      default:
        return false;
    }
  }
}

