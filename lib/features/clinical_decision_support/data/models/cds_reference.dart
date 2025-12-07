/// Reference model for Clinical Decision Support
class CDSReference {
  final String label;
  final String url;

  const CDSReference({
    required this.label,
    required this.url,
  });

  factory CDSReference.fromJson(Map<String, dynamic> json) {
    return CDSReference(
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

