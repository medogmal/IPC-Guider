/// Bundle model for IPC care bundles
/// Represents evidence-based practices grouped together to improve patient outcomes
class Bundle {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<String> components;
  final String rationale;
  final String implementation;
  final List<String> keyPoints;
  final List<BundleReference> references;

  const Bundle({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.components,
    required this.rationale,
    required this.implementation,
    required this.keyPoints,
    required this.references,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) {
    return Bundle(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      components: (json['components'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rationale: json['rationale'] as String? ?? '',
      implementation: json['implementation'] as String? ?? '',
      keyPoints: (json['keyPoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      references: (json['references'] as List<dynamic>?)
              ?.map((e) => BundleReference.fromJson(e as Map<String, dynamic>))
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
      'components': components,
      'rationale': rationale,
      'implementation': implementation,
      'keyPoints': keyPoints,
      'references': references.map((e) => e.toJson()).toList(),
    };
  }
}

/// Reference model for bundle citations
class BundleReference {
  final String label;
  final String url;

  const BundleReference({
    required this.label,
    required this.url,
  });

  factory BundleReference.fromJson(Map<String, dynamic> json) {
    return BundleReference(
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

/// Bundle data container with version info
class BundleData {
  final int version;
  final String updatedAt;
  final List<Bundle> bundles;

  const BundleData({
    required this.version,
    required this.updatedAt,
    required this.bundles,
  });

  factory BundleData.fromJson(Map<String, dynamic> json) {
    return BundleData(
      version: json['version'] as int? ?? 1,
      updatedAt: json['updatedAt'] as String? ?? '',
      bundles: (json['bundles'] as List<dynamic>?)
              ?.map((e) => Bundle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'updatedAt': updatedAt,
      'bundles': bundles.map((e) => e.toJson()).toList(),
    };
  }
}

