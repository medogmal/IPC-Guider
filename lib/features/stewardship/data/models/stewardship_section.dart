/// Antimicrobial Stewardship Section model
/// Represents a major topic area within the Antimicrobial Stewardship module
class StewardshipSection {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<StewardshipPage> pages;

  const StewardshipSection({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.pages,
  });

  factory StewardshipSection.fromJson(Map<String, dynamic> json) {
    return StewardshipSection(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pages: (json['pages'] as List<dynamic>?)
              ?.map((e) => StewardshipPage.fromJson(e as Map<String, dynamic>))
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

/// Antimicrobial Stewardship Page model
/// Represents a specific topic within a section
class StewardshipPage {
  final String id;
  final String name;
  final List<String> content;
  final List<String> keyPoints;
  final List<StewardshipReference> references;

  const StewardshipPage({
    required this.id,
    required this.name,
    required this.content,
    required this.keyPoints,
    required this.references,
  });

  factory StewardshipPage.fromJson(Map<String, dynamic> json) {
    return StewardshipPage(
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
                  StewardshipReference.fromJson(e as Map<String, dynamic>))
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

/// Antimicrobial Stewardship Reference model
/// Represents an official source citation
class StewardshipReference {
  final String label;
  final String url;

  const StewardshipReference({
    required this.label,
    required this.url,
  });

  factory StewardshipReference.fromJson(Map<String, dynamic> json) {
    return StewardshipReference(
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

/// Container for all Antimicrobial Stewardship data
class StewardshipData {
  final int version;
  final String updatedAt;
  final List<StewardshipSection> sections;

  const StewardshipData({
    required this.version,
    required this.updatedAt,
    required this.sections,
  });

  factory StewardshipData.fromJson(Map<String, dynamic> json) {
    return StewardshipData(
      version: json['version'] as int? ?? 1,
      updatedAt: json['updatedAt'] as String? ?? '',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) =>
                  StewardshipSection.fromJson(e as Map<String, dynamic>))
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

