/// Domain models for Antibiotic Spectrum Visualizer
///
/// Represents antibiotic coverage data for spectrum visualization
library;

/// Coverage level for an antibiotic against an organism
enum CoverageLevel {
  excellent, // Highly effective, first-line
  good,      // Effective, reliable coverage
  variable,  // Coverage depends on local resistance patterns
  poor,      // Limited effectiveness
  none;      // No coverage

  String get displayName {
    switch (this) {
      case CoverageLevel.excellent:
        return 'Excellent';
      case CoverageLevel.good:
        return 'Good';
      case CoverageLevel.variable:
        return 'Variable';
      case CoverageLevel.poor:
        return 'Poor';
      case CoverageLevel.none:
        return 'None';
    }
  }

  String get description {
    switch (this) {
      case CoverageLevel.excellent:
        return 'Highly effective, first-line agent';
      case CoverageLevel.good:
        return 'Effective, reliable coverage';
      case CoverageLevel.variable:
        return 'Coverage depends on local resistance patterns';
      case CoverageLevel.poor:
        return 'Limited effectiveness, not recommended';
      case CoverageLevel.none:
        return 'No coverage, ineffective';
    }
  }
}

/// Organism category for grouping
enum OrganismCategory {
  gramPositiveCocci,
  gramNegativeBacilli,
  anaerobes,
  atypical;

  String get displayName {
    switch (this) {
      case OrganismCategory.gramPositiveCocci:
        return 'Gram-Positive Cocci';
      case OrganismCategory.gramNegativeBacilli:
        return 'Gram-Negative Bacilli';
      case OrganismCategory.anaerobes:
        return 'Anaerobes';
      case OrganismCategory.atypical:
        return 'Atypical Organisms';
    }
  }
}

/// Antibiotic spectrum breadth classification
enum SpectrumBreadth {
  narrow,   // Targets specific organism groups
  extended, // Covers multiple groups
  broad;    // Wide coverage across categories

  String get displayName {
    switch (this) {
      case SpectrumBreadth.narrow:
        return 'Narrow Spectrum';
      case SpectrumBreadth.extended:
        return 'Extended Spectrum';
      case SpectrumBreadth.broad:
        return 'Broad Spectrum';
    }
  }
}

/// Organism with coverage information
class Organism {
  final String id;
  final String name;
  final String commonName;
  final OrganismCategory category;
  final String? notes;

  const Organism({
    required this.id,
    required this.name,
    required this.commonName,
    required this.category,
    this.notes,
  });

  factory Organism.fromJson(Map<String, dynamic> json) {
    return Organism(
      id: json['id'] as String,
      name: json['name'] as String,
      commonName: json['commonName'] as String,
      category: OrganismCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'commonName': commonName,
      'category': category.name,
      if (notes != null) 'notes': notes,
    };
  }
}

/// Coverage data for a specific organism
class OrganismCoverage {
  final String organismId;
  final CoverageLevel level;
  final String? notes;

  const OrganismCoverage({
    required this.organismId,
    required this.level,
    this.notes,
  });

  factory OrganismCoverage.fromJson(Map<String, dynamic> json) {
    return OrganismCoverage(
      organismId: json['organismId'] as String,
      level: CoverageLevel.values.firstWhere(
        (e) => e.name == json['level'],
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organismId': organismId,
      'level': level.name,
      if (notes != null) 'notes': notes,
    };
  }
}

/// Antibiotic with spectrum coverage data
class AntibioticSpectrum {
  final String id;
  final String name;
  final String genericName;
  final String antibioticClass;
  final SpectrumBreadth spectrumBreadth;
  final List<OrganismCoverage> coverage;
  final String? clinicalUse;
  final List<String>? keyPoints;
  final List<Reference> references;

  const AntibioticSpectrum({
    required this.id,
    required this.name,
    required this.genericName,
    required this.antibioticClass,
    required this.spectrumBreadth,
    required this.coverage,
    this.clinicalUse,
    this.keyPoints,
    required this.references,
  });

  factory AntibioticSpectrum.fromJson(Map<String, dynamic> json) {
    return AntibioticSpectrum(
      id: json['id'] as String,
      name: json['name'] as String,
      genericName: json['genericName'] as String,
      antibioticClass: json['class'] as String,
      spectrumBreadth: SpectrumBreadth.values.firstWhere(
        (e) => e.name == json['spectrumBreadth'],
      ),
      coverage: (json['coverage'] as List)
          .map((e) => OrganismCoverage.fromJson(e as Map<String, dynamic>))
          .toList(),
      clinicalUse: json['clinicalUse'] as String?,
      keyPoints: (json['keyPoints'] as List?)?.cast<String>(),
      references: (json['references'] as List)
          .map((e) => Reference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'class': antibioticClass,
      'spectrumBreadth': spectrumBreadth.name,
      'coverage': coverage.map((e) => e.toJson()).toList(),
      if (clinicalUse != null) 'clinicalUse': clinicalUse,
      if (keyPoints != null) 'keyPoints': keyPoints,
      'references': references.map((e) => e.toJson()).toList(),
    };
  }

  /// Get coverage level for a specific organism
  CoverageLevel? getCoverageFor(String organismId) {
    try {
      return coverage.firstWhere((c) => c.organismId == organismId).level;
    } catch (e) {
      return null;
    }
  }

  /// Get coverage notes for a specific organism
  String? getCoverageNotesFor(String organismId) {
    try {
      return coverage.firstWhere((c) => c.organismId == organismId).notes;
    } catch (e) {
      return null;
    }
  }
}

/// Reference for scientific sources
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

/// Complete spectrum data with organisms and antibiotics
class SpectrumData {
  final List<Organism> organisms;
  final List<AntibioticSpectrum> antibiotics;
  final String version;
  final DateTime updatedAt;

  const SpectrumData({
    required this.organisms,
    required this.antibiotics,
    required this.version,
    required this.updatedAt,
  });

  factory SpectrumData.fromJson(Map<String, dynamic> json) {
    return SpectrumData(
      organisms: (json['organisms'] as List)
          .map((e) => Organism.fromJson(e as Map<String, dynamic>))
          .toList(),
      antibiotics: (json['antibiotics'] as List)
          .map((e) => AntibioticSpectrum.fromJson(e as Map<String, dynamic>))
          .toList(),
      version: json['version'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organisms': organisms.map((e) => e.toJson()).toList(),
      'antibiotics': antibiotics.map((e) => e.toJson()).toList(),
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Get organisms by category
  List<Organism> getOrganismsByCategory(OrganismCategory category) {
    return organisms.where((o) => o.category == category).toList();
  }

  /// Get antibiotics by spectrum breadth
  List<AntibioticSpectrum> getAntibioticsByBreadth(SpectrumBreadth breadth) {
    return antibiotics.where((a) => a.spectrumBreadth == breadth).toList();
  }

  /// Get antibiotics by class
  List<AntibioticSpectrum> getAntibioticsByClass(String antibioticClass) {
    return antibiotics.where((a) => a.antibioticClass == antibioticClass).toList();
  }
}


