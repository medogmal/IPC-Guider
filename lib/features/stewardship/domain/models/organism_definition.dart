/// Organism definition model
class OrganismDefinition {
  final String id;
  final String name;
  final String category; // 'gram-negative', 'gram-positive', 'other'
  final String? abbreviation;
  final List<String> recommendedAntibiotics;

  const OrganismDefinition({
    required this.id,
    required this.name,
    required this.category,
    this.abbreviation,
    this.recommendedAntibiotics = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'abbreviation': abbreviation,
      'recommendedAntibiotics': recommendedAntibiotics,
    };
  }

  factory OrganismDefinition.fromJson(Map<String, dynamic> json) {
    return OrganismDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      abbreviation: json['abbreviation'] as String?,
      recommendedAntibiotics: (json['recommendedAntibiotics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

/// Antibiotic definition model
class AntibioticDefinition {
  final String id;
  final String name;
  final String? abbreviation;
  final String class_;
  final List<String> applicableOrganisms;

  const AntibioticDefinition({
    required this.id,
    required this.name,
    this.abbreviation,
    required this.class_,
    this.applicableOrganisms = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'class': class_,
      'applicableOrganisms': applicableOrganisms,
    };
  }

  factory AntibioticDefinition.fromJson(Map<String, dynamic> json) {
    return AntibioticDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String?,
      class_: json['class'] as String,
      applicableOrganisms: (json['applicableOrganisms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

