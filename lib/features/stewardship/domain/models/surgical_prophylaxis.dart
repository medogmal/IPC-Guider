/// Domain models for Surgical Prophylaxis Advisor
library;

/// Surgical procedure classification
enum ProcedureClassification {
  clean,
  cleanContaminated,
  contaminated,
  dirty;

  String get displayName {
    switch (this) {
      case ProcedureClassification.clean:
        return 'Clean';
      case ProcedureClassification.cleanContaminated:
        return 'Clean-Contaminated';
      case ProcedureClassification.contaminated:
        return 'Contaminated';
      case ProcedureClassification.dirty:
        return 'Dirty/Infected';
    }
  }

  String get description {
    switch (this) {
      case ProcedureClassification.clean:
        return 'No inflammation, no break in technique';
      case ProcedureClassification.cleanContaminated:
        return 'Controlled entry into hollow viscus';
      case ProcedureClassification.contaminated:
        return 'Open, fresh traumatic wounds';
      case ProcedureClassification.dirty:
        return 'Purulent inflammation or perforated viscus';
    }
  }
}

/// Surgical specialty category
enum SurgicalSpecialty {
  orthopedic,
  cardiac,
  gastrointestinal,
  gynecologic,
  neurosurgery,
  urologic,
  vascular,
  general;

  String get displayName {
    switch (this) {
      case SurgicalSpecialty.orthopedic:
        return 'Orthopedic';
      case SurgicalSpecialty.cardiac:
        return 'Cardiac/Cardiothoracic';
      case SurgicalSpecialty.gastrointestinal:
        return 'Gastrointestinal';
      case SurgicalSpecialty.gynecologic:
        return 'Gynecologic/Obstetric';
      case SurgicalSpecialty.neurosurgery:
        return 'Neurosurgery';
      case SurgicalSpecialty.urologic:
        return 'Urologic';
      case SurgicalSpecialty.vascular:
        return 'Vascular';
      case SurgicalSpecialty.general:
        return 'General Surgery';
    }
  }
}

/// Prophylaxis recommendation
class ProphylaxisRecommendation {
  final String antibioticName;
  final String dose;
  final String route;
  final String timing; // e.g., "60 minutes before incision"
  final String duration; // e.g., "Single dose" or "≤24 hours"
  final String? redosingInterval; // e.g., "Every 4 hours if procedure continues"
  final String rationale;
  final List<String> warnings;
  final List<String>? monitoring;
  final bool isAlternative; // true if this is an alternative for allergy

  const ProphylaxisRecommendation({
    required this.antibioticName,
    required this.dose,
    required this.route,
    required this.timing,
    required this.duration,
    this.redosingInterval,
    required this.rationale,
    required this.warnings,
    this.monitoring,
    this.isAlternative = false,
  });

  factory ProphylaxisRecommendation.fromJson(Map<String, dynamic> json) {
    return ProphylaxisRecommendation(
      antibioticName: json['antibioticName'] as String,
      dose: json['dose'] as String,
      route: json['route'] as String,
      timing: json['timing'] as String,
      duration: json['duration'] as String,
      redosingInterval: json['redosingInterval'] as String?,
      rationale: json['rationale'] as String,
      warnings: (json['warnings'] as List<dynamic>).cast<String>(),
      monitoring: json['monitoring'] != null
          ? (json['monitoring'] as List<dynamic>).cast<String>()
          : null,
      isAlternative: json['isAlternative'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'antibioticName': antibioticName,
      'dose': dose,
      'route': route,
      'timing': timing,
      'duration': duration,
      'redosingInterval': redosingInterval,
      'rationale': rationale,
      'warnings': warnings,
      'monitoring': monitoring,
      'isAlternative': isAlternative,
    };
  }
}

/// Reference
class Reference {
  final String label;
  final String url;

  const Reference({
    required this.label,
    required this.url,
  });

  factory Reference.fromJson(Map<String, dynamic> json) {
    return Reference(
      label: json['label'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'url': url,
    };
  }
}

/// Surgical procedure
class SurgicalProcedure {
  final String id;
  final String name;
  final SurgicalSpecialty specialty;
  final ProcedureClassification classification;
  final String description;
  final ProphylaxisRecommendation primaryProphylaxis;
  final ProphylaxisRecommendation? betaLactamAllergyAlternative;
  final ProphylaxisRecommendation? mrsaCoverageAddition;
  final List<String> specialConsiderations;
  final List<Reference> references;

  const SurgicalProcedure({
    required this.id,
    required this.name,
    required this.specialty,
    required this.classification,
    required this.description,
    required this.primaryProphylaxis,
    this.betaLactamAllergyAlternative,
    this.mrsaCoverageAddition,
    required this.specialConsiderations,
    required this.references,
  });

  factory SurgicalProcedure.fromJson(Map<String, dynamic> json) {
    // Parse classification - handle both camelCase and hyphenated formats
    String classificationStr = json['classification'] as String;
    // Convert hyphenated to camelCase: "clean-contaminated" -> "cleanContaminated"
    if (classificationStr.contains('-')) {
      final parts = classificationStr.split('-');
      classificationStr = parts[0] + parts.sublist(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
    }

    return SurgicalProcedure(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: SurgicalSpecialty.values.firstWhere(
        (e) => e.name == json['specialty'],
      ),
      classification: ProcedureClassification.values.firstWhere(
        (e) => e.name == classificationStr,
      ),
      description: json['description'] as String,
      primaryProphylaxis: ProphylaxisRecommendation.fromJson(
        json['primaryProphylaxis'] as Map<String, dynamic>,
      ),
      betaLactamAllergyAlternative: json['betaLactamAllergyAlternative'] != null
          ? ProphylaxisRecommendation.fromJson(
              json['betaLactamAllergyAlternative'] as Map<String, dynamic>,
            )
          : null,
      mrsaCoverageAddition: json['mrsaCoverageAddition'] != null
          ? ProphylaxisRecommendation.fromJson(
              json['mrsaCoverageAddition'] as Map<String, dynamic>,
            )
          : null,
      specialConsiderations:
          (json['specialConsiderations'] as List<dynamic>).cast<String>(),
      references: (json['references'] as List<dynamic>)
          .map((e) => Reference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty.name,
      'classification': classification.name,
      'description': description,
      'primaryProphylaxis': primaryProphylaxis.toJson(),
      'betaLactamAllergyAlternative': betaLactamAllergyAlternative?.toJson(),
      'mrsaCoverageAddition': mrsaCoverageAddition?.toJson(),
      'specialConsiderations': specialConsiderations,
      'references': references.map((e) => e.toJson()).toList(),
    };
  }
}

/// Patient profile for prophylaxis calculation
class PatientProfile {
  final bool hasBetaLactamAllergy;
  final bool hasMRSAColonization;
  final double? weight; // in kg
  final String? renalFunction; // 'normal', 'mild', 'moderate', 'severe'
  final List<String> otherAllergies;

  const PatientProfile({
    required this.hasBetaLactamAllergy,
    required this.hasMRSAColonization,
    this.weight,
    this.renalFunction,
    this.otherAllergies = const [],
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      hasBetaLactamAllergy: json['hasBetaLactamAllergy'] as bool,
      hasMRSAColonization: json['hasMRSAColonization'] as bool,
      weight: json['weight'] as double?,
      renalFunction: json['renalFunction'] as String?,
      otherAllergies: json['otherAllergies'] != null
          ? (json['otherAllergies'] as List<dynamic>).cast<String>()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasBetaLactamAllergy': hasBetaLactamAllergy,
      'hasMRSAColonization': hasMRSAColonization,
      'weight': weight,
      'renalFunction': renalFunction,
      'otherAllergies': otherAllergies,
    };
  }
}

/// Saved prophylaxis recommendation
class SavedProphylaxisRecommendation {
  final String id;
  final DateTime timestamp;
  final String procedureName;
  final String procedureId;
  final PatientProfile patientProfile;
  final ProphylaxisRecommendation recommendation;
  final List<ProphylaxisRecommendation> alternatives;
  final String? notes;

  const SavedProphylaxisRecommendation({
    required this.id,
    required this.timestamp,
    required this.procedureName,
    required this.procedureId,
    required this.patientProfile,
    required this.recommendation,
    this.alternatives = const [],
    this.notes,
  });

  factory SavedProphylaxisRecommendation.fromJson(Map<String, dynamic> json) {
    return SavedProphylaxisRecommendation(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      procedureName: json['procedureName'] as String,
      procedureId: json['procedureId'] as String,
      patientProfile: PatientProfile.fromJson(
        json['patientProfile'] as Map<String, dynamic>,
      ),
      recommendation: ProphylaxisRecommendation.fromJson(
        json['recommendation'] as Map<String, dynamic>,
      ),
      alternatives: json['alternatives'] != null
          ? (json['alternatives'] as List<dynamic>)
              .map((e) =>
                  ProphylaxisRecommendation.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'procedureName': procedureName,
      'procedureId': procedureId,
      'patientProfile': patientProfile.toJson(),
      'recommendation': recommendation.toJson(),
      'alternatives': alternatives.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }
}

