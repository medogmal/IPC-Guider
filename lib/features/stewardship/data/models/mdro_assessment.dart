class MdroAssessment {
  final String id;
  final DateTime timestamp;

  // Inputs - Patient Demographics
  final String age;
  final String? gender;

  // Inputs - Healthcare Exposure (Past 90 Days)
  final String hospitalAdmission;
  final String icuStay;
  final String nursingHome;
  final bool hemodialysis;
  final bool surgery;

  // Inputs - Antibiotic Exposure (Past 90 Days)
  final String antibioticUse;
  final List<String> broadSpectrumAntibiotics;

  // Inputs - Clinical Factors
  final List<String> invasiveDevices;
  final List<String> immunosuppression;
  final List<String> chronicConditions;

  // Inputs - Previous MDRO History
  final String priorMdro;
  final List<String> mdroTypes;

  // Inputs - Geographic/Epidemiologic Factors
  final bool internationalTravel;
  final bool knownMdroContact;

  // Results
  final int riskScore; // 0-100
  final String riskCategory; // Low, Moderate, High, Very High
  final double mdroProbability; // percentage
  final String riskExplanation;
  final Map<String, String> organismRisks; // MRSA: Low, VRE: Moderate, etc.
  final List<String> isolationPrecautions;
  final List<String> screeningRecommendations;
  final String empiricTherapy;
  final List<String> stewardshipRecommendations;

  MdroAssessment({
    required this.id,
    required this.timestamp,
    required this.age,
    this.gender,
    required this.hospitalAdmission,
    required this.icuStay,
    required this.nursingHome,
    required this.hemodialysis,
    required this.surgery,
    required this.antibioticUse,
    required this.broadSpectrumAntibiotics,
    required this.invasiveDevices,
    required this.immunosuppression,
    required this.chronicConditions,
    required this.priorMdro,
    required this.mdroTypes,
    required this.internationalTravel,
    required this.knownMdroContact,
    required this.riskScore,
    required this.riskCategory,
    required this.mdroProbability,
    required this.riskExplanation,
    required this.organismRisks,
    required this.isolationPrecautions,
    required this.screeningRecommendations,
    required this.empiricTherapy,
    required this.stewardshipRecommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'age': age,
      'gender': gender,
      'hospitalAdmission': hospitalAdmission,
      'icuStay': icuStay,
      'nursingHome': nursingHome,
      'hemodialysis': hemodialysis,
      'surgery': surgery,
      'antibioticUse': antibioticUse,
      'broadSpectrumAntibiotics': broadSpectrumAntibiotics,
      'invasiveDevices': invasiveDevices,
      'immunosuppression': immunosuppression,
      'chronicConditions': chronicConditions,
      'priorMdro': priorMdro,
      'mdroTypes': mdroTypes,
      'internationalTravel': internationalTravel,
      'knownMdroContact': knownMdroContact,
      'riskScore': riskScore,
      'riskCategory': riskCategory,
      'mdroProbability': mdroProbability,
      'riskExplanation': riskExplanation,
      'organismRisks': organismRisks,
      'isolationPrecautions': isolationPrecautions,
      'screeningRecommendations': screeningRecommendations,
      'empiricTherapy': empiricTherapy,
      'stewardshipRecommendations': stewardshipRecommendations,
    };
  }

  factory MdroAssessment.fromJson(Map<String, dynamic> json) {
    return MdroAssessment(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      age: json['age'] as String,
      gender: json['gender'] as String?,
      hospitalAdmission: json['hospitalAdmission'] as String,
      icuStay: json['icuStay'] as String,
      nursingHome: json['nursingHome'] as String,
      hemodialysis: json['hemodialysis'] as bool,
      surgery: json['surgery'] as bool,
      antibioticUse: json['antibioticUse'] as String,
      broadSpectrumAntibiotics: List<String>.from(json['broadSpectrumAntibiotics'] as List),
      invasiveDevices: List<String>.from(json['invasiveDevices'] as List),
      immunosuppression: List<String>.from(json['immunosuppression'] as List),
      chronicConditions: List<String>.from(json['chronicConditions'] as List),
      priorMdro: json['priorMdro'] as String,
      mdroTypes: List<String>.from(json['mdroTypes'] as List),
      internationalTravel: json['internationalTravel'] as bool,
      knownMdroContact: json['knownMdroContact'] as bool,
      riskScore: json['riskScore'] as int,
      riskCategory: json['riskCategory'] as String,
      mdroProbability: (json['mdroProbability'] as num).toDouble(),
      riskExplanation: json['riskExplanation'] as String,
      organismRisks: Map<String, String>.from(json['organismRisks'] as Map),
      isolationPrecautions: List<String>.from(json['isolationPrecautions'] as List),
      screeningRecommendations: List<String>.from(json['screeningRecommendations'] as List),
      empiricTherapy: json['empiricTherapy'] as String,
      stewardshipRecommendations: List<String>.from(json['stewardshipRecommendations'] as List),
    );
  }
}

