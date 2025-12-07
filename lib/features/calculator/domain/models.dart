class CalculatorData {
  final int version;
  final DateTime updatedAt;
  final List<CalculatorDomain> domains;

  const CalculatorData({
    required this.version,
    required this.updatedAt,
    required this.domains,
  });

  factory CalculatorData.fromJson(Map<String, dynamic> json) {
    return CalculatorData(
      version: json['version'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      domains: (json['domains'] as List)
          .map((d) => CalculatorDomain.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CalculatorDomain {
  final String key;
  final String title;
  final List<CalculatorFormula> formulas;

  const CalculatorDomain({
    required this.key,
    required this.title,
    required this.formulas,
  });

  factory CalculatorDomain.fromJson(Map<String, dynamic> json) {
    return CalculatorDomain(
      key: json['key'] as String,
      title: json['title'] as String,
      formulas: (json['formulas'] as List)
          .map((f) => CalculatorFormula.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CalculatorFormula {
  final String id;
  final String name;
  final String formula;
  final String purpose;
  final List<FormulaInput> inputs;
  final String resultUnit;
  final String overview;
  final FormulaExample example;
  final String benchmark;
  final String interpretation;
  final String action;
  final String? indications;  // New field for IPC calculators
  final List<Reference> references;

  const CalculatorFormula({
    required this.id,
    required this.name,
    required this.formula,
    required this.purpose,
    required this.inputs,
    required this.resultUnit,
    required this.overview,
    required this.example,
    required this.benchmark,
    required this.interpretation,
    required this.action,
    this.indications,  // Optional for backward compatibility
    required this.references,
  });

  factory CalculatorFormula.fromJson(Map<String, dynamic> json) {
    return CalculatorFormula(
      id: json['id'] as String,
      name: json['name'] as String,
      formula: json['formula'] as String,
      purpose: json['purpose'] as String,
      inputs: (json['inputs'] as List)
          .map((i) => FormulaInput.fromJson(i as Map<String, dynamic>))
          .toList(),
      resultUnit: json['resultUnit'] as String,
      overview: json['overview'] as String,
      example: FormulaExample.fromJson(json['example'] as Map<String, dynamic>),
      benchmark: json['benchmark'] as String,
      interpretation: json['interpretation'] as String,
      action: json['action'] as String,
      indications: json['indications'] as String?,  // Optional field
      references: (json['references'] as List)
          .map((r) => Reference.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FormulaInput {
  final String key;
  final String label;
  final String type;
  final String unitHint;
  final String? hint;  // New field for input hints
  final Map<String, dynamic>? validation;  // New field for validation rules

  const FormulaInput({
    required this.key,
    required this.label,
    required this.type,
    required this.unitHint,
    this.hint,
    this.validation,
  });

  factory FormulaInput.fromJson(Map<String, dynamic> json) {
    return FormulaInput(
      key: json['key'] ?? json['id'] as String,  // Support both 'key' and 'id'
      label: json['label'] as String,
      type: json['type'] as String,
      unitHint: json['unitHint'] ?? json['unit'] ?? '',  // Support both 'unitHint' and 'unit'
      hint: json['hint'] as String?,
      validation: json['validation'] as Map<String, dynamic>?,
    );
  }
}

class FormulaExample {
  final Map<String, dynamic> values;
  final String worked;
  final String result;
  final String? scenario;  // New field for hospital scenario
  final String? description;  // New field for scenario description

  const FormulaExample({
    required this.values,
    required this.worked,
    required this.result,
    this.scenario,
    this.description,
  });

  factory FormulaExample.fromJson(Map<String, dynamic> json) {
    return FormulaExample(
      values: json['values'] ?? json['inputs'] as Map<String, dynamic>,  // Support both 'values' and 'inputs'
      worked: json['worked'] ?? json['calculation'] ?? '',  // Support both 'worked' and 'calculation'
      result: json['result'] as String,
      scenario: json['scenario'] as String?,
      description: json['description'] as String?,
    );
  }
}

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
}

// History model for local storage
class CalculationHistory {
  final String id;
  final DateTime timestamp;
  final String domain;
  final String formulaId;
  final String formulaName;
  final Map<String, dynamic> inputs;
  final double result;
  final String unit;

  const CalculationHistory({
    required this.id,
    required this.timestamp,
    required this.domain,
    required this.formulaId,
    required this.formulaName,
    required this.inputs,
    required this.result,
    required this.unit,
  });

  factory CalculationHistory.fromJson(Map<String, dynamic> json) {
    return CalculationHistory(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      domain: json['domain'] as String,
      formulaId: json['formulaId'] as String,
      formulaName: json['formulaName'] as String,
      inputs: json['inputs'] as Map<String, dynamic>,
      result: (json['result'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'domain': domain,
      'formulaId': formulaId,
      'formulaName': formulaName,
      'inputs': inputs,
      'result': result,
      'unit': unit,
    };
  }
}

// Principles model
class CalculatorPrinciples {
  final int version;
  final DateTime updatedAt;
  final String title;
  final List<PrincipleSection> sections;
  final List<Reference> references;

  const CalculatorPrinciples({
    required this.version,
    required this.updatedAt,
    required this.title,
    required this.sections,
    required this.references,
  });

  factory CalculatorPrinciples.fromJson(Map<String, dynamic> json) {
    return CalculatorPrinciples(
      version: json['version'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String,
      sections: (json['sections'] as List)
          .map((s) => PrincipleSection.fromJson(s as Map<String, dynamic>))
          .toList(),
      references: (json['references'] as List)
          .map((r) => Reference.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PrincipleSection {
  final String title;
  final String content;
  final List<String> keyPrinciples;

  const PrincipleSection({
    required this.title,
    required this.content,
    required this.keyPrinciples,
  });

  factory PrincipleSection.fromJson(Map<String, dynamic> json) {
    return PrincipleSection(
      title: json['title'] as String,
      content: json['content'] as String,
      keyPrinciples: (json['keyPrinciples'] as List).cast<String>(),
    );
  }
}

// Quiz models
class CalculatorQuiz {
  final int version;
  final DateTime updatedAt;
  final String title;
  final String description;
  final List<QuizQuestion> questions;

  const CalculatorQuiz({
    required this.version,
    required this.updatedAt,
    required this.title,
    required this.description,
    required this.questions,
  });

  factory CalculatorQuiz.fromJson(Map<String, dynamic> json) {
    return CalculatorQuiz(
      version: json['version'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List).cast<String>(),
      correctAnswer: json['correctAnswer'] as int,
      explanation: json['explanation'] as String,
    );
  }
}
