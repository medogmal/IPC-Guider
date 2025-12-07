// Renal Function Models
// Models for renal function calculation and categorization

/// Renal function category based on CrCl/eGFR
enum RenalCategory {
  normal('Normal', '≥90 mL/min', 0),
  mild('Mild Impairment', '60-89 mL/min', 1),
  moderate('Moderate Impairment', '30-59 mL/min', 2),
  severe('Severe Impairment', '15-29 mL/min', 3),
  esrd('ESRD', '<15 mL/min', 4);

  final String label;
  final String range;
  final int severity;

  const RenalCategory(this.label, this.range, this.severity);

  static RenalCategory fromCrCl(double crCl) {
    if (crCl >= 90) return RenalCategory.normal;
    if (crCl >= 60) return RenalCategory.mild;
    if (crCl >= 30) return RenalCategory.moderate;
    if (crCl >= 15) return RenalCategory.severe;
    return RenalCategory.esrd;
  }
}

/// Patient information for renal function calculation
class PatientInfo {
  final double age; // years
  final double weight; // kg
  final double serumCreatinine; // mg/dL
  final bool isMale;
  final bool isBlack; // For MDRD/CKD-EPI

  const PatientInfo({
    required this.age,
    required this.weight,
    required this.serumCreatinine,
    required this.isMale,
    this.isBlack = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'weight': weight,
      'serumCreatinine': serumCreatinine,
      'isMale': isMale,
      'isBlack': isBlack,
    };
  }

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      age: (json['age'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      serumCreatinine: (json['serumCreatinine'] as num).toDouble(),
      isMale: json['isMale'] as bool,
      isBlack: json['isBlack'] as bool? ?? false,
    );
  }
}

/// Renal function calculation result
class RenalFunctionResult {
  final double crClCockcroftGault; // mL/min
  final double eGfrMdrd; // mL/min/1.73m²
  final double eGfrCkdEpi; // mL/min/1.73m²
  final RenalCategory category;
  final String calculationMethod;

  const RenalFunctionResult({
    required this.crClCockcroftGault,
    required this.eGfrMdrd,
    required this.eGfrCkdEpi,
    required this.category,
    required this.calculationMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'crClCockcroftGault': crClCockcroftGault,
      'eGfrMdrd': eGfrMdrd,
      'eGfrCkdEpi': eGfrCkdEpi,
      'category': category.name,
      'calculationMethod': calculationMethod,
    };
  }

  factory RenalFunctionResult.fromJson(Map<String, dynamic> json) {
    return RenalFunctionResult(
      crClCockcroftGault: (json['crClCockcroftGault'] as num).toDouble(),
      eGfrMdrd: (json['eGfrMdrd'] as num).toDouble(),
      eGfrCkdEpi: (json['eGfrCkdEpi'] as num).toDouble(),
      category: RenalCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => RenalCategory.normal,
      ),
      calculationMethod: json['calculationMethod'] as String,
    );
  }
}

/// Dose adjustment recommendation
class DoseAdjustment {
  final String antibioticId;
  final String antibioticName;
  final RenalCategory renalCategory;
  final String normalDose;
  final String adjustedDose;
  final String interval;
  final String? loadingDose;
  final String rationale;
  final List<String> warnings;
  final List<String> monitoring;
  final String? hemodialysisNote;
  final String? crrtNote;

  const DoseAdjustment({
    required this.antibioticId,
    required this.antibioticName,
    required this.renalCategory,
    required this.normalDose,
    required this.adjustedDose,
    required this.interval,
    this.loadingDose,
    required this.rationale,
    required this.warnings,
    required this.monitoring,
    this.hemodialysisNote,
    this.crrtNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'antibioticId': antibioticId,
      'antibioticName': antibioticName,
      'renalCategory': renalCategory.name,
      'normalDose': normalDose,
      'adjustedDose': adjustedDose,
      'interval': interval,
      'loadingDose': loadingDose,
      'rationale': rationale,
      'warnings': warnings,
      'monitoring': monitoring,
      'hemodialysisNote': hemodialysisNote,
      'crrtNote': crrtNote,
    };
  }

  factory DoseAdjustment.fromJson(Map<String, dynamic> json) {
    return DoseAdjustment(
      antibioticId: json['antibioticId'] as String,
      antibioticName: json['antibioticName'] as String,
      renalCategory: RenalCategory.values.firstWhere(
        (e) => e.name == json['renalCategory'],
      ),
      normalDose: json['normalDose'] as String,
      adjustedDose: json['adjustedDose'] as String,
      interval: json['interval'] as String,
      loadingDose: json['loadingDose'] as String?,
      rationale: json['rationale'] as String,
      warnings: List<String>.from(json['warnings'] as List),
      monitoring: List<String>.from(json['monitoring'] as List),
      hemodialysisNote: json['hemodialysisNote'] as String?,
      crrtNote: json['crrtNote'] as String?,
    );
  }
}

