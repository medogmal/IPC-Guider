// Data model for pathogen details
class PathogenDetail {
  final String id;
  final String name;
  final String scientificName;
  final String definition;
  final PathogenReservoir reservoir;
  final PathogenTransmission transmission;
  final PathogenIncubation incubationPeriod;
  final List<String> riskFactors;
  final PathogenClinicalFeatures clinicalFeatures;
  final List<String> diagnosis;
  final String treatment;
  final PathogenInfectionControl infectionControl;
  final List<String> outbreakTriggers;
  final List<String> reportingCommunication;
  final List<String> prevention;
  final List<PathogenReference> references;

  PathogenDetail({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.definition,
    required this.reservoir,
    required this.transmission,
    required this.incubationPeriod,
    required this.riskFactors,
    required this.clinicalFeatures,
    required this.diagnosis,
    required this.treatment,
    required this.infectionControl,
    required this.outbreakTriggers,
    required this.reportingCommunication,
    required this.prevention,
    required this.references,
  });

  factory PathogenDetail.fromJson(Map<String, dynamic> json) {
    return PathogenDetail(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      reservoir: PathogenReservoir.fromJson(json['reservoir'] as Map<String, dynamic>? ?? {}),
      transmission: PathogenTransmission.fromJson(json['transmission'] as Map<String, dynamic>? ?? {}),
      incubationPeriod: PathogenIncubation.fromJson(json['incubationPeriod'] as Map<String, dynamic>? ?? {}),
      riskFactors: (json['riskFactors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      clinicalFeatures: PathogenClinicalFeatures.fromJson(json['clinicalFeatures'] as Map<String, dynamic>? ?? {}),
      diagnosis: (json['diagnosis'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      treatment: json['treatment'] as String? ?? '',
      infectionControl: PathogenInfectionControl.fromJson(json['infectionControl'] as Map<String, dynamic>? ?? {}),
      outbreakTriggers: (json['outbreakTriggers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      reportingCommunication: (json['reportingCommunication'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      prevention: (json['prevention'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      references: (json['references'] as List<dynamic>?)
              ?.map((e) => PathogenReference.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'definition': definition,
      'reservoir': reservoir.toJson(),
      'transmission': transmission.toJson(),
      'incubationPeriod': incubationPeriod.toJson(),
      'riskFactors': riskFactors,
      'clinicalFeatures': clinicalFeatures.toJson(),
      'diagnosis': diagnosis,
      'treatment': treatment,
      'infectionControl': infectionControl.toJson(),
      'outbreakTriggers': outbreakTriggers,
      'reportingCommunication': reportingCommunication,
      'prevention': prevention,
      'references': references.map((e) => e.toJson()).toList(),
    };
  }
}

// Reservoir model
class PathogenReservoir {
  final List<String> primary;
  final List<String> secondary;
  final String notes;

  PathogenReservoir({
    required this.primary,
    required this.secondary,
    required this.notes,
  });

  factory PathogenReservoir.fromJson(Map<String, dynamic> json) {
    return PathogenReservoir(
      primary: (json['primary'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      secondary: (json['secondary'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'notes': notes,
    };
  }
}

// Transmission model
class PathogenTransmission {
  final String mode;
  final List<String> routes;
  final String notes;

  PathogenTransmission({
    required this.mode,
    required this.routes,
    required this.notes,
  });

  factory PathogenTransmission.fromJson(Map<String, dynamic> json) {
    return PathogenTransmission(
      mode: json['mode'] as String? ?? '',
      routes: (json['routes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'routes': routes,
      'notes': notes,
    };
  }
}

// Incubation period model
class PathogenIncubation {
  final String range;
  final String infectiousPeriod;
  final String seasonality;
  final String geographic;

  PathogenIncubation({
    required this.range,
    required this.infectiousPeriod,
    required this.seasonality,
    required this.geographic,
  });

  factory PathogenIncubation.fromJson(Map<String, dynamic> json) {
    return PathogenIncubation(
      range: json['range'] as String? ?? '',
      infectiousPeriod: json['infectiousPeriod'] as String? ?? '',
      seasonality: json['seasonality'] as String? ?? '',
      geographic: json['geographic'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'range': range,
      'infectiousPeriod': infectiousPeriod,
      'seasonality': seasonality,
      'geographic': geographic,
    };
  }
}

// Clinical features model
class PathogenClinicalFeatures {
  final List<String> symptoms;
  final List<String> complications;
  final PathogenCaseDefinition caseDefinition;

  PathogenClinicalFeatures({
    required this.symptoms,
    required this.complications,
    required this.caseDefinition,
  });

  factory PathogenClinicalFeatures.fromJson(Map<String, dynamic> json) {
    return PathogenClinicalFeatures(
      symptoms: (json['symptoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      complications: (json['complications'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      caseDefinition: PathogenCaseDefinition.fromJson(json['caseDefinition'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symptoms': symptoms,
      'complications': complications,
      'caseDefinition': caseDefinition.toJson(),
    };
  }
}

// Case definition model
class PathogenCaseDefinition {
  final String suspected;
  final String confirmed;

  PathogenCaseDefinition({
    required this.suspected,
    required this.confirmed,
  });

  factory PathogenCaseDefinition.fromJson(Map<String, dynamic> json) {
    return PathogenCaseDefinition(
      suspected: json['suspected'] as String? ?? '',
      confirmed: json['confirmed'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suspected': suspected,
      'confirmed': confirmed,
    };
  }
}

// Infection control model
class PathogenInfectionControl {
  final String precautions;
  final String screening;
  final String cohorting;
  final String sourceControl;
  final String environmental;
  final String staffEducation;

  PathogenInfectionControl({
    required this.precautions,
    required this.screening,
    required this.cohorting,
    required this.sourceControl,
    required this.environmental,
    required this.staffEducation,
  });

  factory PathogenInfectionControl.fromJson(Map<String, dynamic> json) {
    return PathogenInfectionControl(
      precautions: json['precautions'] as String? ?? '',
      screening: json['screening'] as String? ?? '',
      cohorting: json['cohorting'] as String? ?? '',
      sourceControl: json['sourceControl'] as String? ?? '',
      environmental: json['environmental'] as String? ?? '',
      staffEducation: json['staffEducation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'precautions': precautions,
      'screening': screening,
      'cohorting': cohorting,
      'sourceControl': sourceControl,
      'environmental': environmental,
      'staffEducation': staffEducation,
    };
  }
}

// Reference model
class PathogenReference {
  final String label;
  final String url;

  PathogenReference({
    required this.label,
    required this.url,
  });

  factory PathogenReference.fromJson(Map<String, dynamic> json) {
    return PathogenReference(
      label: json['label'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'url': url,
    };
  }
}

