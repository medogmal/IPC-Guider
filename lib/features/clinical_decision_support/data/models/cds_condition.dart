import 'cds_section.dart';

/// Condition model for Clinical Decision Support
class CDSCondition {
  final String id;
  final String name;
  final List<String> synonyms;
  final List<String> icd10;
  final List<String> severity;
  final String shortDescription;
  final Map<String, CDSSection> sections;

  const CDSCondition({
    required this.id,
    required this.name,
    this.synonyms = const [],
    this.icd10 = const [],
    this.severity = const [],
    required this.shortDescription,
    required this.sections,
  });

  factory CDSCondition.fromJson(Map<String, dynamic> json) {
    final sectionsMap = <String, CDSSection>{};
    final sectionsJson = json['sections'] as Map<String, dynamic>?;
    
    if (sectionsJson != null) {
      sectionsJson.forEach((key, value) {
        sectionsMap[key] = CDSSection.fromJson(value as Map<String, dynamic>);
      });
    }

    return CDSCondition(
      id: json['id'] as String,
      name: json['name'] as String,
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      icd10: (json['icd10'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      severity: (json['severity'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      shortDescription: json['shortDescription'] as String? ?? '',
      sections: sectionsMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'synonyms': synonyms,
      'icd10': icd10,
      'severity': severity,
      'shortDescription': shortDescription,
      'sections': sections.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

