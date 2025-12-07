import '../domain/models/antibiotic_tier.dart';

/// Tiered Antibiotic Panels Database
/// Comprehensive antibiotic selection panels organized by:
/// - Organism
/// - Specimen source (blood, urine, respiratory, wound, all)
/// - CLSI M100-2025 Classes (A, B, C, U, O)
///
/// Based on:
/// - CLSI M100-Ed35 (2025) Performance Standards
/// - IDSA Clinical Practice Guidelines
/// - Antimicrobial Stewardship Principles
/// - CLSI M39-A4 Selective Reporting Guidelines
class TieredAntibioticPanels {
  /// Get tiered panel for a specific organism and specimen source
  static TieredAntibioticPanel? getPanel({
    required String organismId,
    required String specimenSource,
  }) {
    final key = '$organismId:$specimenSource';
    return _panels[key] ?? _panels['$organismId:all'];
  }

  /// Get all available specimen sources for an organism
  static List<String> getAvailableSpecimenSources(String organismId) {
    return _panels.keys
        .where((key) => key.startsWith('$organismId:'))
        .map((key) => key.split(':')[1])
        .toList();
  }

  /// Check if organism has specimen-specific panels
  static bool hasSpecimenSpecificPanels(String organismId) {
    return getAvailableSpecimenSources(organismId).length > 1;
  }

  /// Comprehensive panels database
  static final Map<String, TieredAntibioticPanel> _panels = {
    // ========================================
    // ESCHERICHIA COLI
    // ========================================

    'e-coli:urine': TieredAntibioticPanel(
      organismId: 'e-coli',
      specimenSource: 'urine',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'nitrofurantoin', // Class A: Primary for uncomplicated UTI
          'tmp-smx', // Class A: Primary (if local resistance <20%)
          'fosfomycin', // Class A: Primary for uncomplicated UTI
        ],
        AntibioticTier.classB: [
          'ciprofloxacin', // Class B: Alternative (stewardship concerns)
          'levofloxacin', // Class B: Alternative
          'ceftriaxone', // Class B: Alternative (parenteral)
          'cefepime', // Class B: Alternative (parenteral)
          'gentamicin', // Class B: Alternative (parenteral)
          'amikacin', // Class B: Alternative (parenteral)
        ],
        AntibioticTier.classC: [
          'ertapenem', // Class C: Supplementary for ESBL
          'meropenem', // Class C: Supplementary for CRE risk
          'piperacillin-tazobactam', // Class C: Supplementary
        ],
        AntibioticTier.classU: [
          'amoxicillin-clavulanate', // Class U: Urine-only oral option
          'cefpodoxime', // Class U: Urine-only oral 3rd-gen
          'cefixime', // Class U: Urine-only oral 3rd-gen
        ],
      },
    ),

    'e-coli:blood': TieredAntibioticPanel(
      organismId: 'e-coli',
      specimenSource: 'blood',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'ceftriaxone', // 1st choice for bacteremia
          'cefepime', // 1st choice
          'piperacillin-tazobactam', // 1st choice
        ],
        AntibioticTier.classB: [
          'ciprofloxacin', // 2nd choice (if susceptible)
          'levofloxacin', // 2nd choice
          'gentamicin', // 2nd choice (combination therapy)
          'amikacin', // 2nd choice
          'ampicillin-sulbactam', // 2nd choice
        ],
        AntibioticTier.classC: [
          'ertapenem', // Reserve for ESBL
          'meropenem', // Reserve for CRE risk
          'imipenem', // Reserve
        ],
        AntibioticTier.classU: [], // Not applicable for blood
      },
    ),

    'e-coli:respiratory': TieredAntibioticPanel(
      organismId: 'e-coli',
      specimenSource: 'respiratory',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'ceftriaxone',
          'cefepime',
          'piperacillin-tazobactam',
        ],
        AntibioticTier.classB: [
          'ciprofloxacin',
          'levofloxacin',
          'gentamicin',
          'amikacin',
        ],
        AntibioticTier.classC: [
          'ertapenem',
          'meropenem',
          'imipenem',
        ],
        AntibioticTier.classU: [],
      },
    ),

    'e-coli:all': TieredAntibioticPanel(
      organismId: 'e-coli',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'ceftriaxone',
          'cefepime',
          'piperacillin-tazobactam',
          'ampicillin-sulbactam',
        ],
        AntibioticTier.classB: [
          'ciprofloxacin',
          'levofloxacin',
          'gentamicin',
          'amikacin',
          'tmp-smx',
        ],
        AntibioticTier.classC: [
          'ertapenem',
          'meropenem',
          'imipenem',
        ],
        AntibioticTier.classU: [
          'nitrofurantoin',
          'fosfomycin',
          'amoxicillin-clavulanate',
        ],
      },
    ),

    // ========================================
    // KLEBSIELLA PNEUMONIAE
    // ========================================

    'k-pneumoniae:all': TieredAntibioticPanel(
      organismId: 'k-pneumoniae',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'ceftriaxone',
          'cefepime',
          'piperacillin-tazobactam',
        ],
        AntibioticTier.classB: [
          'ciprofloxacin',
          'levofloxacin',
          'gentamicin',
          'amikacin',
          'tmp-smx',
        ],
        AntibioticTier.classC: [
          'ertapenem',
          'meropenem',
          'imipenem',
        ],
        AntibioticTier.classU: [],
      },
    ),

    // ========================================
    // PSEUDOMONAS AERUGINOSA
    // ========================================

    'p-aeruginosa:all': TieredAntibioticPanel(
      organismId: 'p-aeruginosa',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'cefepime', // Anti-pseudomonal cephalosporin
          'piperacillin-tazobactam', // Anti-pseudomonal penicillin
          'ceftazidime', // Anti-pseudomonal cephalosporin
        ],
        AntibioticTier.classB: [
          'ciprofloxacin', // Anti-pseudomonal fluoroquinolone
          'levofloxacin', // Anti-pseudomonal fluoroquinolone
          'gentamicin', // Combination therapy
          'amikacin', // Combination therapy
          'tobramycin', // Combination therapy
          'aztreonam', // Monobactam
        ],
        AntibioticTier.classC: [
          'meropenem', // Anti-pseudomonal carbapenem
          'imipenem', // Anti-pseudomonal carbapenem
          'colistin', // Last resort
        ],
        AntibioticTier.classU: [],
      },
    ),

    // ========================================
    // ACINETOBACTER BAUMANNII
    // ========================================

    'a-baumannii:all': TieredAntibioticPanel(
      organismId: 'a-baumannii',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'meropenem', // If susceptible
          'imipenem', // If susceptible
        ],
        AntibioticTier.classB: [
          'amikacin',
          'gentamicin',
          'ciprofloxacin',
          'levofloxacin',
          'tmp-smx',
        ],
        AntibioticTier.classC: [
          'colistin', // Last resort for CRAB
          'tigecycline', // Last resort
        ],
        AntibioticTier.classU: [],
      },
    ),

    // ========================================
    // MSSA (Methicillin-Susceptible Staphylococcus aureus)
    // ========================================

    'mssa:all': TieredAntibioticPanel(
      organismId: 'mssa',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'oxacillin', // Class A: Primary for MSSA
          'cefazolin', // Class A: Primary (preferred for IV)
          'nafcillin', // Class A: Primary
        ],
        AntibioticTier.classB: [
          'clindamycin', // Class B: Alternative (if beta-lactam allergy)
          'tmp-smx', // Class B: Alternative (oral option)
          'doxycycline', // Class B: Alternative (oral option)
        ],
        AntibioticTier.classC: [
          'vancomycin', // Class C: Supplementary (if severe beta-lactam allergy)
          'linezolid', // Class C: Supplementary
        ],
        AntibioticTier.classU: [
          'cephalexin', // Class U: Urine-only oral 1st-gen cephalosporin
          'dicloxacillin', // Class U: Urine-only oral penicillinase-resistant
        ],
      },
    ),

    // ========================================
    // MRSA
    // ========================================

    'mrsa:all': TieredAntibioticPanel(
      organismId: 'mrsa',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'vancomycin', // 1st choice for MRSA
          'linezolid', // 1st choice (especially for pneumonia)
          'daptomycin', // 1st choice (not for pneumonia)
        ],
        AntibioticTier.classB: [
          'clindamycin', // If susceptible
          'tmp-smx', // If susceptible
          'doxycycline', // If susceptible
          'tigecycline', // Alternative
        ],
        AntibioticTier.classC: [
          'ceftaroline', // 5th-gen cephalosporin with MRSA activity
        ],
        AntibioticTier.classU: [
          'linezolid', // Oral option (excellent bioavailability)
          'tmp-smx', // Oral option
          'doxycycline', // Oral option
        ],
      },
    ),

    // ========================================
    // ENTEROCOCCUS FAECALIS
    // ========================================

    'enterococcus-faecalis:all': TieredAntibioticPanel(
      organismId: 'enterococcus-faecalis',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'ampicillin', // 1st choice for E. faecalis
          'penicillin', // Alternative
        ],
        AntibioticTier.classB: [
          'vancomycin', // If ampicillin-resistant or beta-lactam allergy
        ],
        AntibioticTier.classC: [
          'linezolid', // If VRE
          'daptomycin', // If VRE (not for pneumonia)
        ],
        AntibioticTier.classU: [
          'amoxicillin', // Oral option
          'nitrofurantoin', // Urine only
        ],
      },
    ),

    // ========================================
    // ENTEROCOCCUS FAECIUM
    // ========================================

    'enterococcus-faecium:all': TieredAntibioticPanel(
      organismId: 'enterococcus-faecium',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'vancomycin', // 1st choice (often ampicillin-resistant)
        ],
        AntibioticTier.classB: [
          'linezolid', // If VRE
          'daptomycin', // If VRE
        ],
        AntibioticTier.classC: [],
        AntibioticTier.classU: [
          'linezolid', // Oral option
        ],
      },
    ),

    // ========================================
    // SALMONELLA SPECIES
    // ========================================

    'salmonella-spp:all': TieredAntibioticPanel(
      organismId: 'salmonella-spp',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'ceftriaxone', // Class A: Primary for invasive salmonellosis
          'cefotaxime', // Class A: Primary
          'ciprofloxacin', // Class A: Primary (if susceptible)
        ],
        AntibioticTier.classB: [
          'azithromycin', // Class B: Alternative
          'tmp-smx', // Class B: Alternative (if susceptible)
        ],
        AntibioticTier.classC: [
          'meropenem', // Class C: Supplementary (for resistant strains)
        ],
        AntibioticTier.classU: [],
      },
    ),

    // ========================================
    // SHIGELLA SPECIES
    // ========================================

    'shigella-spp:all': TieredAntibioticPanel(
      organismId: 'shigella-spp',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'ciprofloxacin', // Class A: Primary for shigellosis
          'azithromycin', // Class A: Primary
        ],
        AntibioticTier.classB: [
          'ceftriaxone', // Class B: Alternative
          'cefixime', // Class B: Alternative (oral)
        ],
        AntibioticTier.classC: [],
        AntibioticTier.classU: [],
      },
    ),

    // ========================================
    // PROTEUS VULGARIS
    // ========================================

    'proteus-vulgaris:all': TieredAntibioticPanel(
      organismId: 'proteus-vulgaris',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'ceftriaxone', // Class A: Primary
          'cefepime', // Class A: Primary
          'piperacillin-tazobactam', // Class A: Primary
        ],
        AntibioticTier.classB: [
          'ciprofloxacin', // Class B: Alternative
          'levofloxacin', // Class B: Alternative
          'gentamicin', // Class B: Alternative
          'amikacin', // Class B: Alternative
        ],
        AntibioticTier.classC: [
          'ertapenem', // Class C: Supplementary
          'meropenem', // Class C: Supplementary
        ],
        AntibioticTier.classU: [],
      },
    ),

    // ========================================
    // MORGANELLA MORGANII
    // ========================================

    'morganella-morganii:all': TieredAntibioticPanel(
      organismId: 'morganella-morganii',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'cefepime', // Class A: Primary
          'piperacillin-tazobactam', // Class A: Primary
        ],
        AntibioticTier.classB: [
          'ciprofloxacin', // Class B: Alternative
          'levofloxacin', // Class B: Alternative
          'gentamicin', // Class B: Alternative
          'amikacin', // Class B: Alternative
        ],
        AntibioticTier.classC: [
          'ertapenem', // Class C: Supplementary
          'meropenem', // Class C: Supplementary
        ],
        AntibioticTier.classU: [],
      },
    ),

    // ========================================
    // CITROBACTER FREUNDII
    // ========================================

    'citrobacter-freundii:all': TieredAntibioticPanel(
      organismId: 'citrobacter-freundii',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'cefepime', // Class A: Primary (stable to AmpC)
          'piperacillin-tazobactam', // Class A: Primary
        ],
        AntibioticTier.classB: [
          'ciprofloxacin', // Class B: Alternative
          'levofloxacin', // Class B: Alternative
          'gentamicin', // Class B: Alternative
          'amikacin', // Class B: Alternative
        ],
        AntibioticTier.classC: [
          'ertapenem', // Class C: Supplementary
          'meropenem', // Class C: Supplementary
        ],
        AntibioticTier.classU: [],
      },
    ),

    // ========================================
    // CITROBACTER KOSERI
    // ========================================

    'citrobacter-koseri:all': TieredAntibioticPanel(
      organismId: 'citrobacter-koseri',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'ceftriaxone', // Class A: Primary
          'cefepime', // Class A: Primary
          'piperacillin-tazobactam', // Class A: Primary
        ],
        AntibioticTier.classB: [
          'ciprofloxacin', // Class B: Alternative
          'levofloxacin', // Class B: Alternative
          'gentamicin', // Class B: Alternative
          'amikacin', // Class B: Alternative
        ],
        AntibioticTier.classC: [
          'ertapenem', // Class C: Supplementary
          'meropenem', // Class C: Supplementary
        ],
        AntibioticTier.classU: [],
      },
    ),

    // ========================================
    // STENOTROPHOMONAS MALTOPHILIA
    // ========================================

    'stenotrophomonas-maltophilia:all': TieredAntibioticPanel(
      organismId: 'stenotrophomonas-maltophilia',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'tmp-smx', // Class A: Primary (drug of choice)
        ],
        AntibioticTier.classB: [
          'levofloxacin', // Class B: Alternative
          'minocycline', // Class B: Alternative
        ],
        AntibioticTier.classC: [
          'ceftazidime', // Class C: Supplementary (variable activity)
        ],
        AntibioticTier.classU: [],
      },
    ),

    // ========================================
    // STAPHYLOCOCCUS SAPROPHYTICUS
    // ========================================

    's-saprophyticus:urine': TieredAntibioticPanel(
      organismId: 's-saprophyticus',
      specimenSource: 'urine',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'nitrofurantoin', // Class A: Primary for uncomplicated UTI
          'tmp-smx', // Class A: Primary
        ],
        AntibioticTier.classB: [
          'ciprofloxacin', // Class B: Alternative
          'levofloxacin', // Class B: Alternative
        ],
        AntibioticTier.classC: [],
        AntibioticTier.classU: [
          'cephalexin', // Class U: Urine-only oral option
          'amoxicillin-clavulanate', // Class U: Urine-only oral option
        ],
      },
    ),

    // ========================================
    // BETA-HEMOLYTIC STREPTOCOCCUS
    // ========================================

    'beta-hemolytic-strep:all': TieredAntibioticPanel(
      organismId: 'beta-hemolytic-strep',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'penicillin', // Class A: Primary (drug of choice)
          'ampicillin', // Class A: Primary
        ],
        AntibioticTier.classB: [
          'ceftriaxone', // Class B: Alternative
          'cefazolin', // Class B: Alternative
          'clindamycin', // Class B: Alternative (if penicillin allergy)
        ],
        AntibioticTier.classC: [
          'vancomycin', // Class C: Supplementary (if severe penicillin allergy)
        ],
        AntibioticTier.classU: [
          'amoxicillin', // Class U: Oral option
          'cephalexin', // Class U: Oral option
        ],
      },
    ),

    // ========================================
    // CANDIDA SPECIES
    // ========================================

    'candida-albicans:all': TieredAntibioticPanel(
      organismId: 'candida-albicans',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'fluconazole', // Class A: Primary for candidemia
          'caspofungin', // Class A: Primary (echinocandin)
          'micafungin', // Class A: Primary (echinocandin)
        ],
        AntibioticTier.classB: [
          'voriconazole', // Class B: Alternative
        ],
        AntibioticTier.classC: [
          'amphotericin-b', // Class C: Supplementary (reserve)
        ],
        AntibioticTier.classU: [],
      },
    ),

    'candida-glabrata:all': TieredAntibioticPanel(
      organismId: 'candida-glabrata',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'caspofungin', // Class A: Primary (echinocandin preferred)
          'micafungin', // Class A: Primary (echinocandin)
        ],
        AntibioticTier.classB: [
          'voriconazole', // Class B: Alternative
        ],
        AntibioticTier.classC: [
          'amphotericin-b', // Class C: Supplementary (reserve)
        ],
        AntibioticTier.classU: [],
      },
    ),

    'candida-tropicalis:all': TieredAntibioticPanel(
      organismId: 'candida-tropicalis',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'fluconazole', // Class A: Primary
          'caspofungin', // Class A: Primary (echinocandin)
          'micafungin', // Class A: Primary (echinocandin)
        ],
        AntibioticTier.classB: [
          'voriconazole', // Class B: Alternative
        ],
        AntibioticTier.classC: [
          'amphotericin-b', // Class C: Supplementary (reserve)
        ],
        AntibioticTier.classU: [],
      },
    ),

    'candida-parapsilosis:all': TieredAntibioticPanel(
      organismId: 'candida-parapsilosis',
      specimenSource: 'all',
      antibioticsByTier: {
        AntibioticTier.classA: [
          'fluconazole', // Class A: Primary (preferred over echinocandins)
        ],
        AntibioticTier.classB: [
          'voriconazole', // Class B: Alternative
          'caspofungin', // Class B: Alternative (higher MICs)
          'micafungin', // Class B: Alternative (higher MICs)
        ],
        AntibioticTier.classC: [
          'amphotericin-b', // Class C: Supplementary (reserve)
        ],
        AntibioticTier.classU: [],
      },
    ),
  };
}

