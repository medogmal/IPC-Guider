class QuizReference {
  final String label;
  final String url;
  const QuizReference({required this.label, required this.url});

  factory QuizReference.fromJson(Map<String, dynamic> json) =>
      QuizReference(label: json['label'] ?? '', url: json['url'] ?? '');

  Map<String, dynamic> toJson() => {'label': label, 'url': url};
}

class QuizQuestion {
  final String id;
  final String module; // e.g. "isolation"
  final int stage;     // 1..5
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;
  final List<QuizReference> references;

  const QuizQuestion({
    required this.id,
    required this.module,
    required this.stage,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
    this.references = const [],
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      module: json['module'] ?? '',
      stage: json['stage'] ?? 1,
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answerIndex: json['answerIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
      references: (json['references'] as List<dynamic>?)
              ?.map((e) => QuizReference.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'module': module,
        'stage': stage,
        'question': question,
        'options': options,
        'answerIndex': answerIndex,
        'explanation': explanation,
        'references': references.map((r) => r.toJson()).toList(),
      };
}
