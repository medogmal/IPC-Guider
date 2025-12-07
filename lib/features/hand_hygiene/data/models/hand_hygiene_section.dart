/// Hand Hygiene Section model
/// Represents a major topic area within the Hand Hygiene module
class HandHygieneSection {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<HandHygienePage> pages;

  const HandHygieneSection({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.pages,
  });

  factory HandHygieneSection.fromJson(Map<String, dynamic> json) {
    return HandHygieneSection(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pages: (json['pages'] as List<dynamic>?)
              ?.map((e) => HandHygienePage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'pages': pages.map((e) => e.toJson()).toList(),
    };
  }
}

/// Hand Hygiene Page model
/// Represents a specific topic within a section
class HandHygienePage {
  final String id;
  final String name;
  final List<String> content;
  final List<String> keyPoints;
  final List<HandHygieneReference> references;

  const HandHygienePage({
    required this.id,
    required this.name,
    required this.content,
    required this.keyPoints,
    required this.references,
  });

  factory HandHygienePage.fromJson(Map<String, dynamic> json) {
    return HandHygienePage(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      content: (json['content'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      keyPoints: (json['keyPoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      references: (json['references'] as List<dynamic>?)
              ?.map((e) =>
                  HandHygieneReference.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'keyPoints': keyPoints,
      'references': references.map((e) => e.toJson()).toList(),
    };
  }
}

/// Hand Hygiene Reference model
/// Represents an official source citation
class HandHygieneReference {
  final String label;
  final String url;

  const HandHygieneReference({
    required this.label,
    required this.url,
  });

  factory HandHygieneReference.fromJson(Map<String, dynamic> json) {
    return HandHygieneReference(
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

/// Container for all Hand Hygiene data
class HandHygieneData {
  final int version;
  final String updatedAt;
  final List<HandHygieneSection> sections;

  const HandHygieneData({
    required this.version,
    required this.updatedAt,
    required this.sections,
  });

  factory HandHygieneData.fromJson(Map<String, dynamic> json) {
    return HandHygieneData(
      version: json['version'] as int? ?? 1,
      updatedAt: json['updatedAt'] as String? ?? '',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) =>
                  HandHygieneSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'updatedAt': updatedAt,
      'sections': sections.map((e) => e.toJson()).toList(),
    };
  }
}

