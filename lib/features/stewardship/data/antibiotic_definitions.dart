import '../domain/models/organism_definition.dart';

/// Comprehensive list of antibiotics for antibiogram building
/// Organized by class following CLSI M39-A4 guidelines
class AntibioticDefinitions {
  /// Penicillins
  static const List<AntibioticDefinition> penicillins = [
    AntibioticDefinition(
      id: 'ampicillin',
      name: 'Ampicillin',
      abbreviation: 'AMP',
      class_: 'Penicillins',
    ),
    AntibioticDefinition(
      id: 'ampicillin-sulbactam',
      name: 'Ampicillin-Sulbactam',
      abbreviation: 'SAM',
      class_: 'Penicillins',
    ),
    AntibioticDefinition(
      id: 'piperacillin-tazobactam',
      name: 'Piperacillin-Tazobactam',
      abbreviation: 'TZP',
      class_: 'Penicillins',
    ),
    AntibioticDefinition(
      id: 'penicillin',
      name: 'Penicillin',
      abbreviation: 'PEN',
      class_: 'Penicillins',
    ),
    AntibioticDefinition(
      id: 'amoxicillin',
      name: 'Amoxicillin',
      abbreviation: 'AMX',
      class_: 'Penicillins',
    ),
    AntibioticDefinition(
      id: 'oxacillin',
      name: 'Oxacillin',
      abbreviation: 'OXA',
      class_: 'Penicillins',
    ),
  ];

  /// Cephalosporins
  static const List<AntibioticDefinition> cephalosporins = [
    AntibioticDefinition(
      id: 'cefazolin',
      name: 'Cefazolin',
      abbreviation: 'CFZ',
      class_: 'Cephalosporins (1st Gen)',
    ),
    AntibioticDefinition(
      id: 'ceftriaxone',
      name: 'Ceftriaxone',
      abbreviation: 'CRO',
      class_: 'Cephalosporins (3rd Gen)',
    ),
    AntibioticDefinition(
      id: 'cefotaxime',
      name: 'Cefotaxime',
      abbreviation: 'CTX',
      class_: 'Cephalosporins (3rd Gen)',
    ),
    AntibioticDefinition(
      id: 'ceftazidime',
      name: 'Ceftazidime',
      abbreviation: 'CAZ',
      class_: 'Cephalosporins (3rd Gen)',
    ),
    AntibioticDefinition(
      id: 'cefepime',
      name: 'Cefepime',
      abbreviation: 'FEP',
      class_: 'Cephalosporins (4th Gen)',
    ),
    AntibioticDefinition(
      id: 'ceftaroline',
      name: 'Ceftaroline',
      abbreviation: 'CPT',
      class_: 'Cephalosporins (5th Gen)',
    ),
  ];

  /// Carbapenems
  static const List<AntibioticDefinition> carbapenems = [
    AntibioticDefinition(
      id: 'ertapenem',
      name: 'Ertapenem',
      abbreviation: 'ETP',
      class_: 'Carbapenems',
    ),
    AntibioticDefinition(
      id: 'meropenem',
      name: 'Meropenem',
      abbreviation: 'MEM',
      class_: 'Carbapenems',
    ),
    AntibioticDefinition(
      id: 'imipenem',
      name: 'Imipenem',
      abbreviation: 'IPM',
      class_: 'Carbapenems',
    ),
  ];

  /// Aminoglycosides
  static const List<AntibioticDefinition> aminoglycosides = [
    AntibioticDefinition(
      id: 'gentamicin',
      name: 'Gentamicin',
      abbreviation: 'GEN',
      class_: 'Aminoglycosides',
    ),
    AntibioticDefinition(
      id: 'amikacin',
      name: 'Amikacin',
      abbreviation: 'AMK',
      class_: 'Aminoglycosides',
    ),
    AntibioticDefinition(
      id: 'tobramycin',
      name: 'Tobramycin',
      abbreviation: 'TOB',
      class_: 'Aminoglycosides',
    ),
  ];

  /// Fluoroquinolones
  static const List<AntibioticDefinition> fluoroquinolones = [
    AntibioticDefinition(
      id: 'ciprofloxacin',
      name: 'Ciprofloxacin',
      abbreviation: 'CIP',
      class_: 'Fluoroquinolones',
    ),
    AntibioticDefinition(
      id: 'levofloxacin',
      name: 'Levofloxacin',
      abbreviation: 'LVX',
      class_: 'Fluoroquinolones',
    ),
    AntibioticDefinition(
      id: 'moxifloxacin',
      name: 'Moxifloxacin',
      abbreviation: 'MXF',
      class_: 'Fluoroquinolones',
    ),
  ];

  /// Glycopeptides
  static const List<AntibioticDefinition> glycopeptides = [
    AntibioticDefinition(
      id: 'vancomycin',
      name: 'Vancomycin',
      abbreviation: 'VAN',
      class_: 'Glycopeptides',
    ),
  ];

  /// Oxazolidinones
  static const List<AntibioticDefinition> oxazolidinones = [
    AntibioticDefinition(
      id: 'linezolid',
      name: 'Linezolid',
      abbreviation: 'LZD',
      class_: 'Oxazolidinones',
    ),
  ];

  /// Lipopeptides
  static const List<AntibioticDefinition> lipopeptides = [
    AntibioticDefinition(
      id: 'daptomycin',
      name: 'Daptomycin',
      abbreviation: 'DAP',
      class_: 'Lipopeptides',
    ),
  ];

  /// Macrolides
  static const List<AntibioticDefinition> macrolides = [
    AntibioticDefinition(
      id: 'erythromycin',
      name: 'Erythromycin',
      abbreviation: 'ERY',
      class_: 'Macrolides',
    ),
    AntibioticDefinition(
      id: 'azithromycin',
      name: 'Azithromycin',
      abbreviation: 'AZM',
      class_: 'Macrolides',
    ),
  ];

  /// Lincosamides
  static const List<AntibioticDefinition> lincosamides = [
    AntibioticDefinition(
      id: 'clindamycin',
      name: 'Clindamycin',
      abbreviation: 'CLI',
      class_: 'Lincosamides',
    ),
  ];

  /// Sulfonamides
  static const List<AntibioticDefinition> sulfonamides = [
    AntibioticDefinition(
      id: 'tmp-smx',
      name: 'Trimethoprim-Sulfamethoxazole',
      abbreviation: 'SXT',
      class_: 'Sulfonamides',
    ),
  ];

  /// Nitrofurans
  static const List<AntibioticDefinition> nitrofurans = [
    AntibioticDefinition(
      id: 'nitrofurantoin',
      name: 'Nitrofurantoin',
      abbreviation: 'NIT',
      class_: 'Nitrofurans',
    ),
  ];

  /// Tetracyclines
  static const List<AntibioticDefinition> tetracyclines = [
    AntibioticDefinition(
      id: 'tetracycline',
      name: 'Tetracycline',
      abbreviation: 'TET',
      class_: 'Tetracyclines',
    ),
    AntibioticDefinition(
      id: 'tigecycline',
      name: 'Tigecycline',
      abbreviation: 'TGC',
      class_: 'Tetracyclines',
    ),
  ];

  /// Polymyxins
  static const List<AntibioticDefinition> polymyxins = [
    AntibioticDefinition(
      id: 'colistin',
      name: 'Colistin',
      abbreviation: 'COL',
      class_: 'Polymyxins',
    ),
  ];

  /// Monobactams
  static const List<AntibioticDefinition> monobactams = [
    AntibioticDefinition(
      id: 'aztreonam',
      name: 'Aztreonam',
      abbreviation: 'ATM',
      class_: 'Monobactams',
    ),
  ];

  /// Rifamycins
  static const List<AntibioticDefinition> rifamycins = [
    AntibioticDefinition(
      id: 'rifampin',
      name: 'Rifampin',
      abbreviation: 'RIF',
      class_: 'Rifamycins',
    ),
  ];

  /// Antifungals
  static const List<AntibioticDefinition> antifungals = [
    AntibioticDefinition(
      id: 'fluconazole',
      name: 'Fluconazole',
      abbreviation: 'FLU',
      class_: 'Azoles',
    ),
    AntibioticDefinition(
      id: 'voriconazole',
      name: 'Voriconazole',
      abbreviation: 'VOR',
      class_: 'Azoles',
    ),
    AntibioticDefinition(
      id: 'caspofungin',
      name: 'Caspofungin',
      abbreviation: 'CAS',
      class_: 'Echinocandins',
    ),
    AntibioticDefinition(
      id: 'micafungin',
      name: 'Micafungin',
      abbreviation: 'MIC',
      class_: 'Echinocandins',
    ),
    AntibioticDefinition(
      id: 'amphotericin-b',
      name: 'Amphotericin B',
      abbreviation: 'AMB',
      class_: 'Polyenes',
    ),
  ];

  /// NEW: β-Lactam/β-Lactamase Inhibitor Combinations (CLSI M100-Ed35 2025)
  static const List<AntibioticDefinition> betaLactamBLICombinations = [
    AntibioticDefinition(
      id: 'ceftazidime-avibactam',
      name: 'Ceftazidime-Avibactam',
      abbreviation: 'CZA',
      class_: 'Cephalosporins + BLI',
    ),
    AntibioticDefinition(
      id: 'ceftolozane-tazobactam',
      name: 'Ceftolozane-Tazobactam',
      abbreviation: 'C/T',
      class_: 'Cephalosporins + BLI',
    ),
    AntibioticDefinition(
      id: 'meropenem-vaborbactam',
      name: 'Meropenem-Vaborbactam',
      abbreviation: 'MVB',
      class_: 'Carbapenems + BLI',
    ),
    AntibioticDefinition(
      id: 'imipenem-relebactam',
      name: 'Imipenem-Relebactam',
      abbreviation: 'IMR',
      class_: 'Carbapenems + BLI',
    ),
    AntibioticDefinition(
      id: 'amoxicillin-clavulanate',
      name: 'Amoxicillin-Clavulanate',
      abbreviation: 'AMC',
      class_: 'Penicillins + BLI',
    ),
  ];

  /// NEW: Siderophore Cephalosporins (CLSI M100-Ed35 2025)
  static const List<AntibioticDefinition> siderophoreCephalosporins = [
    AntibioticDefinition(
      id: 'cefiderocol',
      name: 'Cefiderocol',
      abbreviation: 'FDC',
      class_: 'Siderophore Cephalosporins',
    ),
  ];

  /// NEW: Oral Cephalosporins
  static const List<AntibioticDefinition> oralCephalosporins = [
    AntibioticDefinition(
      id: 'cephalexin',
      name: 'Cephalexin',
      abbreviation: 'LEX',
      class_: 'Cephalosporins (1st Gen - Oral)',
    ),
    AntibioticDefinition(
      id: 'cefpodoxime',
      name: 'Cefpodoxime',
      abbreviation: 'CPD',
      class_: 'Cephalosporins (3rd Gen - Oral)',
    ),
    AntibioticDefinition(
      id: 'cefixime',
      name: 'Cefixime',
      abbreviation: 'CFM',
      class_: 'Cephalosporins (3rd Gen - Oral)',
    ),
  ];

  /// NEW: Urine-Specific Agents
  static const List<AntibioticDefinition> urineSpecific = [
    AntibioticDefinition(
      id: 'fosfomycin',
      name: 'Fosfomycin',
      abbreviation: 'FOS',
      class_: 'Fosfomycins',
    ),
  ];

  /// NEW: Additional Penicillins
  static const List<AntibioticDefinition> additionalPenicillins = [
    AntibioticDefinition(
      id: 'dicloxacillin',
      name: 'Dicloxacillin',
      abbreviation: 'DCX',
      class_: 'Penicillins (Penicillinase-Resistant)',
    ),
  ];

  /// Get all antibiotics
  static List<AntibioticDefinition> get all => [
        ...penicillins,
        ...cephalosporins,
        ...carbapenems,
        ...aminoglycosides,
        ...fluoroquinolones,
        ...glycopeptides,
        ...oxazolidinones,
        ...lipopeptides,
        ...macrolides,
        ...lincosamides,
        ...sulfonamides,
        ...nitrofurans,
        ...tetracyclines,
        ...polymyxins,
        ...monobactams,
        ...rifamycins,
        ...antifungals,
        ...betaLactamBLICombinations,
        ...siderophoreCephalosporins,
        ...oralCephalosporins,
        ...urineSpecific,
        ...additionalPenicillins,
      ];

  /// Get antibiotic by ID
  static AntibioticDefinition? getById(String id) {
    try {
      return all.firstWhere((abx) => abx.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get antibiotics by class
  static List<AntibioticDefinition> getByClass(String className) {
    return all.where((abx) => abx.class_ == className).toList();
  }
}

