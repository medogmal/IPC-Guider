import '../data/models/bundle_tool_enums.dart';

/// Bundle element definition
class BundleElement {
  final String id;
  final String name;
  final String description;

  const BundleElement({
    required this.id,
    required this.name,
    required this.description,
  });
}

/// Bundle elements for each bundle type
class BundleToolConstants {
  BundleToolConstants._();

  /// Get elements for a specific bundle type
  static List<BundleElement> getElementsForBundle(BundleType bundleType) {
    switch (bundleType) {
      case BundleType.clabsi:
        return clabsiElements;
      case BundleType.cauti:
        return cautiElements;
      case BundleType.vap:
        return vapElements;
      case BundleType.ssi:
        return ssiElements;
      case BundleType.sepsis:
        return sepsisElements;
    }
  }

  /// CLABSI Bundle Elements (5 elements)
  static const List<BundleElement> clabsiElements = [
    BundleElement(
      id: 'clabsi_1',
      name: 'Hand Hygiene',
      description: 'Perform hand hygiene before catheter insertion and manipulation',
    ),
    BundleElement(
      id: 'clabsi_2',
      name: 'Maximal Barrier Precautions',
      description: 'Use cap, mask, sterile gown, sterile gloves, and full-body drape',
    ),
    BundleElement(
      id: 'clabsi_3',
      name: 'Chlorhexidine Skin Antisepsis',
      description: 'Use >0.5% chlorhexidine for skin preparation',
    ),
    BundleElement(
      id: 'clabsi_4',
      name: 'Optimal Catheter Site Selection',
      description: 'Avoid femoral vein in adults; prefer subclavian vein',
    ),
    BundleElement(
      id: 'clabsi_5',
      name: 'Daily Review of Line Necessity',
      description: 'Assess daily and remove if no longer essential',
    ),
  ];

  /// CAUTI Bundle Elements (6 elements)
  static const List<BundleElement> cautiElements = [
    BundleElement(
      id: 'cauti_1',
      name: 'Appropriate Indication',
      description: 'Insert catheter only for appropriate indications',
    ),
    BundleElement(
      id: 'cauti_2',
      name: 'Hand Hygiene',
      description: 'Perform hand hygiene before catheter insertion',
    ),
    BundleElement(
      id: 'cauti_3',
      name: 'Aseptic Technique',
      description: 'Use aseptic technique and sterile equipment for insertion',
    ),
    BundleElement(
      id: 'cauti_4',
      name: 'Secure Catheter',
      description: 'Secure catheter properly to prevent movement and urethral traction',
    ),
    BundleElement(
      id: 'cauti_5',
      name: 'Maintain Closed Drainage System',
      description: 'Keep drainage bag below bladder level and off the floor',
    ),
    BundleElement(
      id: 'cauti_6',
      name: 'Daily Review of Catheter Necessity',
      description: 'Assess daily and remove if no longer needed',
    ),
  ];

  /// VAP Bundle Elements (7 elements)
  static const List<BundleElement> vapElements = [
    BundleElement(
      id: 'vap_1',
      name: 'Elevation of Head of Bed',
      description: 'Elevate head of bed 30-45 degrees unless contraindicated',
    ),
    BundleElement(
      id: 'vap_2',
      name: 'Daily Sedation Vacation',
      description: 'Interrupt sedation daily and assess readiness to extubate',
    ),
    BundleElement(
      id: 'vap_3',
      name: 'Oral Care',
      description: 'Perform oral care with toothbrushing and oral moisturizers at least twice daily',
    ),
    BundleElement(
      id: 'vap_4',
      name: 'Spontaneous Breathing Trials',
      description: 'Perform daily spontaneous breathing trials to assess readiness for extubation',
    ),
    BundleElement(
      id: 'vap_5',
      name: 'Subglottic Secretion Drainage',
      description: 'Use ETT with subglottic suction port for patients expected to be intubated >48-72 hours',
    ),
    BundleElement(
      id: 'vap_6',
      name: 'Peptic Ulcer Disease Prophylaxis',
      description: 'Provide stress ulcer prophylaxis when indicated',
    ),
    BundleElement(
      id: 'vap_7',
      name: 'DVT Prophylaxis',
      description: 'Provide deep vein thrombosis prophylaxis when indicated',
    ),
  ];

  /// SSI Bundle Elements (6 elements)
  static const List<BundleElement> ssiElements = [
    BundleElement(
      id: 'ssi_1',
      name: 'Appropriate Antibiotic Prophylaxis',
      description: 'Administer prophylactic antibiotics within 1 hour before incision (within 2 hours for vancomycin and fluoroquinolones)',
    ),
    BundleElement(
      id: 'ssi_2',
      name: 'Appropriate Hair Removal',
      description: 'Use clippers, not razors, for hair removal if necessary',
    ),
    BundleElement(
      id: 'ssi_3',
      name: 'Glucose Control',
      description: 'Maintain perioperative blood glucose <200 mg/dL',
    ),
    BundleElement(
      id: 'ssi_4',
      name: 'Normothermia',
      description: 'Maintain perioperative normothermia (≥36°C, per CDC guideline >35.5°C)',
    ),
    BundleElement(
      id: 'ssi_5',
      name: 'Skin Antisepsis',
      description: 'Use alcohol-based antiseptic for skin preparation',
    ),
    BundleElement(
      id: 'ssi_6',
      name: 'Appropriate Wound Dressing',
      description: 'Apply sterile dressing and maintain for 24-48 hours',
    ),
  ];

  /// Sepsis Bundle Elements (7 elements - Hour-1 Bundle)
  static const List<BundleElement> sepsisElements = [
    BundleElement(
      id: 'sepsis_1',
      name: 'Measure Lactate Level',
      description: 'Obtain lactate level within 1 hour of sepsis recognition',
    ),
    BundleElement(
      id: 'sepsis_2',
      name: 'Obtain Blood Cultures',
      description: 'Obtain blood cultures before antibiotic administration',
    ),
    BundleElement(
      id: 'sepsis_3',
      name: 'Administer Broad-Spectrum Antibiotics',
      description: 'Administer broad-spectrum antibiotics within 1 hour',
    ),
    BundleElement(
      id: 'sepsis_4',
      name: 'Begin Rapid Fluid Resuscitation',
      description: 'Administer 30 mL/kg crystalloid for hypotension or lactate ≥4 mmol/L',
    ),
    BundleElement(
      id: 'sepsis_5',
      name: 'Apply Vasopressors',
      description: 'Apply vasopressors if hypotensive during or after fluid resuscitation',
    ),
    BundleElement(
      id: 'sepsis_6',
      name: 'Reassess Volume Status',
      description: 'Reassess volume status and tissue perfusion',
    ),
    BundleElement(
      id: 'sepsis_7',
      name: 'Document Time Zero',
      description: 'Document time of sepsis recognition (time zero)',
    ),
  ];

  /// Risk factors by category
  static const Map<RiskFactorCategory, List<String>> riskFactors = {
    RiskFactorCategory.patient: [
      'Immunocompromised status',
      'Chronic illness (diabetes, renal failure, etc.)',
      'Advanced age (>65 years)',
      'Malnutrition',
      'Obesity (BMI >30)',
      'Prolonged hospitalization',
      'Recent surgery or invasive procedure',
      'Multiple comorbidities',
    ],
    RiskFactorCategory.unit: [
      'High patient-to-nurse ratio',
      'Inadequate isolation facilities',
      'Poor environmental cleaning',
      'Overcrowding',
      'Inadequate hand hygiene facilities',
      'Limited access to PPE',
      'High device utilization ratio',
      'Frequent patient transfers',
    ],
    RiskFactorCategory.staffing: [
      'Insufficient staffing levels',
      'High staff turnover',
      'Inadequate training',
      'Lack of IPC champions',
      'Poor adherence to protocols',
      'Communication barriers',
      'Fatigue and burnout',
      'Use of temporary staff',
    ],
    RiskFactorCategory.resource: [
      'Limited supply of sterile equipment',
      'Inadequate disinfectants',
      'Lack of single-use devices',
      'Equipment malfunction',
      'Insufficient monitoring tools',
      'Limited access to laboratory services',
      'Inadequate documentation systems',
      'Budget constraints',
    ],
  };

  /// Benchmark targets for bundle compliance
  static const Map<BundleType, double> complianceTargets = {
    BundleType.clabsi: 95.0,
    BundleType.cauti: 95.0,
    BundleType.vap: 95.0,
    BundleType.ssi: 95.0,
    BundleType.sepsis: 90.0, // Hour-1 bundle target is typically 90%
  };

  /// National average compliance rates (example data)
  static const Map<BundleType, double> nationalAverages = {
    BundleType.clabsi: 85.0,
    BundleType.cauti: 82.0,
    BundleType.vap: 88.0,
    BundleType.ssi: 90.0,
    BundleType.sepsis: 75.0,
  };
}

