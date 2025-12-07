import '../domain/models/resistance_phenotype.dart';

/// Resistance Phenotype Detector
/// Automated detection of resistance phenotypes based on susceptibility patterns
/// 
/// Based on:
/// - CLSI M100 Table 3A-3C (Phenotypic Detection Methods)
/// - CDC CRE Definition
/// - WHO GLASS Definitions
class ResistancePhenotypeDetector {
  /// Detect all resistance phenotypes for a given organism and susceptibility data
  static List<ResistancePhenotype> detectPhenotypes({
    required String organismId,
    required Map<String, String> susceptibilityResults, // antibiotic_id -> 'S'/'I'/'R'
  }) {
    final List<ResistancePhenotype> detectedPhenotypes = [];

    // Detect ESBL (Enterobacterales only)
    if (_isEnterobacterales(organismId)) {
      if (detectESBL(susceptibilityResults)) {
        detectedPhenotypes.add(ResistancePhenotype.esbl);
      }
    }

    // Detect CRE (Enterobacterales only)
    if (_isEnterobacterales(organismId)) {
      if (detectCRE(susceptibilityResults)) {
        detectedPhenotypes.add(ResistancePhenotype.cre);
      }
    }

    // Detect CRPA (Pseudomonas aeruginosa only)
    if (organismId == 'p-aeruginosa') {
      if (detectCRPA(susceptibilityResults)) {
        detectedPhenotypes.add(ResistancePhenotype.crpa);
      }
    }

    // Detect CRAB (Acinetobacter baumannii only)
    if (organismId == 'a-baumannii') {
      if (detectCRAB(susceptibilityResults)) {
        detectedPhenotypes.add(ResistancePhenotype.crab);
      }
    }

    // Detect MRSA (Staphylococcus aureus only)
    if (organismId == 's-aureus') {
      if (detectMRSA(susceptibilityResults)) {
        detectedPhenotypes.add(ResistancePhenotype.mrsa);
      }
    }

    // Detect VRE (Enterococcus only)
    if (organismId.contains('enterococcus')) {
      if (detectVRE(susceptibilityResults)) {
        detectedPhenotypes.add(ResistancePhenotype.vre);
      }
    }

    return detectedPhenotypes;
  }

  /// Detect ESBL phenotype (CLSI M100 Table 3A)
  /// ESBL: Resistant to 3rd-gen cephalosporins, susceptible to carbapenems
  static bool detectESBL(Map<String, String> results) {
    // Check resistance to 3rd-gen cephalosporins
    final resistant3rdGen = _isResistant(results['ceftriaxone']) ||
        _isResistant(results['cefotaxime']) ||
        _isResistant(results['ceftazidime']);

    // Check susceptibility to carbapenems
    final susceptibleCarbapenem = _isSusceptible(results['ertapenem']) ||
        _isSusceptible(results['meropenem']) ||
        _isSusceptible(results['imipenem']);

    return resistant3rdGen && susceptibleCarbapenem;
  }

  /// Detect CRE phenotype (CDC definition)
  /// CRE: Resistant to any carbapenem
  static bool detectCRE(Map<String, String> results) {
    return _isResistant(results['ertapenem']) ||
        _isResistant(results['meropenem']) ||
        _isResistant(results['imipenem']);
  }

  /// Detect CRPA phenotype
  /// CRPA: P. aeruginosa resistant to carbapenems
  static bool detectCRPA(Map<String, String> results) {
    return _isResistant(results['meropenem']) ||
        _isResistant(results['imipenem']);
  }

  /// Detect CRAB phenotype
  /// CRAB: A. baumannii resistant to carbapenems
  static bool detectCRAB(Map<String, String> results) {
    return _isResistant(results['meropenem']) ||
        _isResistant(results['imipenem']);
  }

  /// Detect MRSA phenotype
  /// MRSA: S. aureus resistant to oxacillin/methicillin
  static bool detectMRSA(Map<String, String> results) {
    return _isResistant(results['oxacillin']) ||
        _isResistant(results['cefoxitin']); // Cefoxitin is surrogate marker
  }

  /// Detect VRE phenotype
  /// VRE: Enterococcus resistant to vancomycin
  static bool detectVRE(Map<String, String> results) {
    return _isResistant(results['vancomycin']);
  }

  /// Helper: Check if organism is Enterobacterales
  static bool _isEnterobacterales(String organismId) {
    const enterobacterales = [
      'e-coli',
      'k-pneumoniae',
      'enterobacter-spp',
      'proteus-mirabilis',
      'serratia-marcescens',
    ];
    return enterobacterales.contains(organismId);
  }

  /// Helper: Check if result is resistant
  static bool _isResistant(String? result) {
    return result == 'R';
  }

  /// Helper: Check if result is susceptible
  static bool _isSusceptible(String? result) {
    return result == 'S';
  }
}

