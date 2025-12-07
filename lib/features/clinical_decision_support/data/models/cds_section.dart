import 'cds_reference.dart';

/// Section model for Clinical Decision Support condition
class CDSSection {
  final String id;
  final String title;
  final Map<String, dynamic> content;
  final List<CDSReference> references;

  const CDSSection({
    required this.id,
    required this.title,
    required this.content,
    this.references = const [],
  });

  factory CDSSection.fromJson(Map<String, dynamic> json) {
    return CDSSection(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as Map<String, dynamic>,
      references: (json['references'] as List<dynamic>?)
              ?.map((ref) => CDSReference.fromJson(ref as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'references': references.map((ref) => ref.toJson()).toList(),
    };
  }
}

