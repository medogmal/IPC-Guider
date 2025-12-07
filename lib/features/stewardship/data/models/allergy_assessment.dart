/// Data models for Allergy Cross-Reactivity Checker
/// Represents allergy assessment results and recommendations

class AllergyAssessment {
  final String id;
  final String allergicDrug;
  final String drugClass;
  final String reactionType;
  final String reactionSeverity;
  final String? timeSinceReaction;
  final List<String> clinicalContext;
  final DateTime timestamp;

  // Results
  final String riskLevel; // High, Moderate, Low, Negligible
  final double riskPercentage;
  final String riskExplanation;
  final List<SafeAlternative> safeAlternatives;
  final List<AvoidDrug> avoidList;
  final String clinicalGuidance;
  final List<String> recommendations;

  AllergyAssessment({
    required this.id,
    required this.allergicDrug,
    required this.drugClass,
    required this.reactionType,
    required this.reactionSeverity,
    this.timeSinceReaction,
    required this.clinicalContext,
    required this.timestamp,
    required this.riskLevel,
    required this.riskPercentage,
    required this.riskExplanation,
    required this.safeAlternatives,
    required this.avoidList,
    required this.clinicalGuidance,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'allergicDrug': allergicDrug,
      'drugClass': drugClass,
      'reactionType': reactionType,
      'reactionSeverity': reactionSeverity,
      'timeSinceReaction': timeSinceReaction,
      'clinicalContext': clinicalContext,
      'timestamp': timestamp.toIso8601String(),
      'riskLevel': riskLevel,
      'riskPercentage': riskPercentage,
      'riskExplanation': riskExplanation,
      'safeAlternatives': safeAlternatives.map((e) => e.toJson()).toList(),
      'avoidList': avoidList.map((e) => e.toJson()).toList(),
      'clinicalGuidance': clinicalGuidance,
      'recommendations': recommendations,
    };
  }

  factory AllergyAssessment.fromJson(Map<String, dynamic> json) {
    return AllergyAssessment(
      id: json['id'] as String,
      allergicDrug: json['allergicDrug'] as String,
      drugClass: json['drugClass'] as String,
      reactionType: json['reactionType'] as String,
      reactionSeverity: json['reactionSeverity'] as String,
      timeSinceReaction: json['timeSinceReaction'] as String?,
      clinicalContext: (json['clinicalContext'] as List<dynamic>).cast<String>(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      riskLevel: json['riskLevel'] as String,
      riskPercentage: (json['riskPercentage'] as num).toDouble(),
      riskExplanation: json['riskExplanation'] as String,
      safeAlternatives: (json['safeAlternatives'] as List<dynamic>)
          .map((e) => SafeAlternative.fromJson(e as Map<String, dynamic>))
          .toList(),
      avoidList: (json['avoidList'] as List<dynamic>)
          .map((e) => AvoidDrug.fromJson(e as Map<String, dynamic>))
          .toList(),
      clinicalGuidance: json['clinicalGuidance'] as String,
      recommendations: (json['recommendations'] as List<dynamic>).cast<String>(),
    );
  }
}

class SafeAlternative {
  final String drugName;
  final String drugClass;
  final double crossReactivityRisk;
  final String clinicalUse;
  final String dosingConsiderations;

  SafeAlternative({
    required this.drugName,
    required this.drugClass,
    required this.crossReactivityRisk,
    required this.clinicalUse,
    required this.dosingConsiderations,
  });

  Map<String, dynamic> toJson() {
    return {
      'drugName': drugName,
      'drugClass': drugClass,
      'crossReactivityRisk': crossReactivityRisk,
      'clinicalUse': clinicalUse,
      'dosingConsiderations': dosingConsiderations,
    };
  }

  factory SafeAlternative.fromJson(Map<String, dynamic> json) {
    return SafeAlternative(
      drugName: json['drugName'] as String,
      drugClass: json['drugClass'] as String,
      crossReactivityRisk: (json['crossReactivityRisk'] as num).toDouble(),
      clinicalUse: json['clinicalUse'] as String,
      dosingConsiderations: json['dosingConsiderations'] as String,
    );
  }
}

class AvoidDrug {
  final String drugName;
  final String drugClass;
  final String reason;
  final double crossReactivityRisk;

  AvoidDrug({
    required this.drugName,
    required this.drugClass,
    required this.reason,
    required this.crossReactivityRisk,
  });

  Map<String, dynamic> toJson() {
    return {
      'drugName': drugName,
      'drugClass': drugClass,
      'reason': reason,
      'crossReactivityRisk': crossReactivityRisk,
    };
  }

  factory AvoidDrug.fromJson(Map<String, dynamic> json) {
    return AvoidDrug(
      drugName: json['drugName'] as String,
      drugClass: json['drugClass'] as String,
      reason: json['reason'] as String,
      crossReactivityRisk: (json['crossReactivityRisk'] as num).toDouble(),
    );
  }
}

