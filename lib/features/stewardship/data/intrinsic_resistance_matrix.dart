/// Intrinsic Resistance Matrix
/// Based on CLSI M100-Ed35 (2025) Table 1A-1C
/// 
/// This matrix defines organism-antibiotic combinations that should be EXCLUDED
/// from antibiogram reporting due to intrinsic (chromosomal) resistance mechanisms.
/// 
/// References:
/// - CLSI M100-Ed35 (2025) Performance Standards for Antimicrobial Susceptibility Testing
/// - CLSI M39-A4 Analysis and Presentation of Cumulative Antimicrobial Susceptibility Test Data
class IntrinsicResistanceMatrix {
  /// Get list of antibiotics that are intrinsically resistant for a given organism
  /// Returns empty list if no intrinsic resistance documented
  static List<String> getIntrinsicResistantAntibiotics(String organismId) {
    return _intrinsicResistanceMap[organismId] ?? [];
  }

  /// Check if a specific organism-antibiotic combination is intrinsically resistant
  static bool isIntrinsicallyResistant(String organismId, String antibioticId) {
    final resistantAntibiotics = _intrinsicResistanceMap[organismId] ?? [];
    return resistantAntibiotics.contains(antibioticId);
  }

  /// Get explanation for why an organism is intrinsically resistant to an antibiotic
  static String? getResistanceMechanism(String organismId, String antibioticId) {
    if (!isIntrinsicallyResistant(organismId, antibioticId)) {
      return null;
    }
    return _resistanceMechanisms['$organismId:$antibioticId'];
  }

  /// Intrinsic resistance map: organism_id -> list of intrinsically resistant antibiotic_ids
  static const Map<String, List<String>> _intrinsicResistanceMap = {
    // ========================================
    // GRAM-NEGATIVE BACTERIA
    // ========================================

    // Klebsiella pneumoniae
    'k-pneumoniae': [
      'ampicillin', // Chromosomal SHV β-lactamase
      'amoxicillin', // Chromosomal SHV β-lactamase
    ],

    // Enterobacter species
    'enterobacter-spp': [
      'ampicillin', // AmpC β-lactamase
      'amoxicillin', // AmpC β-lactamase
      'ampicillin-sulbactam', // AmpC β-lactamase
      'cefazolin', // AmpC β-lactamase
      'cefoxitin', // AmpC β-lactamase
    ],

    // Pseudomonas aeruginosa
    'p-aeruginosa': [
      'ampicillin',
      'amoxicillin',
      'ampicillin-sulbactam',
      'cefazolin',
      'ceftriaxone', // No activity (porin impermeability)
      'cefotaxime', // No activity
      'ertapenem', // No activity (porin impermeability)
      'tmp-smx', // Intrinsic resistance
      'tigecycline', // Intrinsic resistance (efflux)
      'tetracycline', // Intrinsic resistance (efflux)
      'doxycycline', // Intrinsic resistance (efflux)
    ],

    // Acinetobacter baumannii
    'a-baumannii': [
      'ampicillin',
      'amoxicillin',
      'ceftriaxone',
      'cefotaxime',
      'ertapenem', // Intrinsic OXA-51-like carbapenemase
    ],

    // Proteus mirabilis
    'proteus-mirabilis': [
      'tigecycline', // Intrinsic resistance
      'tetracycline', // Variable intrinsic resistance
      'nitrofurantoin', // Intrinsic resistance
      'colistin', // Intrinsic resistance (lipid A modification)
    ],

    // Serratia marcescens
    'serratia-marcescens': [
      'ampicillin', // AmpC β-lactamase
      'amoxicillin', // AmpC β-lactamase
      'ampicillin-sulbactam', // AmpC β-lactamase
      'cefazolin', // AmpC β-lactamase
      'cefoxitin', // AmpC β-lactamase
      'colistin', // Intrinsic resistance (lipid A modification)
    ],

    // Salmonella species
    'salmonella-spp': [
      'cefazolin', // Poor activity
      'cephalexin', // Poor activity
    ],

    // Shigella species
    'shigella-spp': [], // No significant intrinsic resistance

    // Proteus vulgaris
    'proteus-vulgaris': [
      'tigecycline', // Intrinsic resistance
      'tetracycline', // Variable intrinsic resistance
      'nitrofurantoin', // Intrinsic resistance
      'colistin', // Intrinsic resistance (lipid A modification)
    ],

    // Morganella morganii
    'morganella-morganii': [
      'ampicillin', // AmpC β-lactamase
      'amoxicillin', // AmpC β-lactamase
      'ampicillin-sulbactam', // AmpC β-lactamase
      'cefazolin', // AmpC β-lactamase
      'cefoxitin', // AmpC β-lactamase
      'colistin', // Intrinsic resistance
      'tigecycline', // Intrinsic resistance
    ],

    // Citrobacter freundii
    'citrobacter-freundii': [
      'ampicillin', // AmpC β-lactamase
      'amoxicillin', // AmpC β-lactamase
      'ampicillin-sulbactam', // AmpC β-lactamase
      'cefazolin', // AmpC β-lactamase
      'cefoxitin', // AmpC β-lactamase
    ],

    // Citrobacter koseri
    'citrobacter-koseri': [
      'ampicillin', // Variable resistance
      'amoxicillin', // Variable resistance
    ],

    // Stenotrophomonas maltophilia
    'stenotrophomonas-maltophilia': [
      'ampicillin',
      'amoxicillin',
      'ampicillin-sulbactam',
      'piperacillin-tazobactam',
      'cefazolin',
      'ceftriaxone',
      'cefotaxime',
      'ceftazidime', // Variable (some strains susceptible)
      'cefepime',
      'ertapenem',
      'meropenem',
      'imipenem',
      'aztreonam',
      'gentamicin',
      'amikacin',
      'tobramycin',
    ],

    // ========================================
    // GRAM-POSITIVE BACTERIA
    // ========================================

    // Enterococcus faecalis
    'enterococcus-faecalis': [
      'cefazolin', // No PBP binding
      'ceftriaxone', // No PBP binding
      'cefotaxime', // No PBP binding
      'ceftazidime', // No PBP binding
      'cefepime', // No PBP binding
      'tmp-smx', // Intrinsic resistance
      'clindamycin', // Intrinsic resistance
    ],

    // Enterococcus faecium
    'enterococcus-faecium': [
      'cefazolin', // No PBP binding
      'ceftriaxone', // No PBP binding
      'cefotaxime', // No PBP binding
      'ceftazidime', // No PBP binding
      'cefepime', // No PBP binding
      'tmp-smx', // Intrinsic resistance
      'clindamycin', // Intrinsic resistance
    ],

    // Staphylococcus aureus (MSSA)
    'mssa': [], // No intrinsic resistance for MSSA

    // MRSA
    'mrsa': [
      'ampicillin', // mecA-mediated resistance
      'amoxicillin', // mecA-mediated resistance
      'ampicillin-sulbactam', // mecA-mediated resistance
      'oxacillin', // mecA-mediated resistance
      'cefazolin', // mecA-mediated resistance
      'ceftriaxone', // mecA-mediated resistance
      'cefepime', // mecA-mediated resistance
      'ertapenem', // mecA-mediated resistance
      'meropenem', // mecA-mediated resistance
      'imipenem', // mecA-mediated resistance
    ],

    // Staphylococcus saprophyticus
    's-saprophyticus': [], // No significant intrinsic resistance

    // Beta-hemolytic Streptococcus (all groups including S. agalactiae)
    'beta-hemolytic-strep': [
      'tmp-smx', // Intrinsic resistance
      'gentamicin', // Intrinsic resistance (monotherapy)
      'aztreonam', // No activity against Gram-positive
    ],

    // ========================================
    // CANDIDA SPECIES
    // ========================================

    // Candida albicans
    'candida-albicans': [], // No intrinsic resistance (baseline susceptibility)

    // Candida glabrata
    'candida-glabrata': [
      'fluconazole', // Intrinsic reduced susceptibility (dose-dependent)
    ],

    // Candida tropicalis
    'candida-tropicalis': [], // No intrinsic resistance

    // Candida parapsilosis
    'candida-parapsilosis': [
      'echinocandins', // Reduced susceptibility (higher MICs)
    ],
  };

  /// Resistance mechanisms for educational purposes
  static const Map<String, String> _resistanceMechanisms = {
    'k-pneumoniae:ampicillin': 'Chromosomal SHV β-lactamase',
    'k-pneumoniae:amoxicillin': 'Chromosomal SHV β-lactamase',
    'enterobacter-spp:cefazolin': 'AmpC β-lactamase (inducible)',
    'p-aeruginosa:ertapenem': 'Porin impermeability (OprD)',
    'p-aeruginosa:tigecycline': 'Efflux pumps (MexAB-OprM)',
    'a-baumannii:ertapenem': 'Intrinsic OXA-51-like carbapenemase',
    'enterococcus-faecalis:ceftriaxone': 'Low-affinity PBPs',
    'mrsa:oxacillin': 'mecA-mediated altered PBP2a',
  };
}

