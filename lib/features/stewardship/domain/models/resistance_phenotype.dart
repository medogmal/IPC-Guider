/// Resistance Phenotype Classification
/// Based on CDC, WHO, and CLSI definitions for antimicrobial resistance patterns
/// 
/// References:
/// - CDC Antibiotic Resistance Threats Report
/// - WHO Global Antimicrobial Resistance and Use Surveillance System (GLASS)
/// - CLSI M100 Table 3A-3C (Phenotypic Detection Methods)
enum ResistancePhenotype {
  /// Extended-Spectrum β-Lactamase (ESBL)
  /// Resistant to 3rd-gen cephalosporins, susceptible to carbapenems
  esbl,

  /// AmpC β-Lactamase (chromosomal or plasmid-mediated)
  /// Resistant to 3rd-gen cephalosporins and cephamycins
  ampC,

  /// Carbapenem-Resistant Enterobacterales (CRE)
  /// Resistant to carbapenems (ertapenem, meropenem, or imipenem)
  cre,

  /// Carbapenem-Resistant Pseudomonas aeruginosa (CRPA)
  crpa,

  /// Carbapenem-Resistant Acinetobacter baumannii (CRAB)
  crab,

  /// Methicillin-Resistant Staphylococcus aureus (MRSA)
  mrsa,

  /// Vancomycin-Resistant Enterococcus (VRE)
  vre,

  /// Multidrug-Resistant (MDR)
  /// Non-susceptible to ≥1 agent in ≥3 antimicrobial categories
  mdr,

  /// Extensively Drug-Resistant (XDR)
  /// Non-susceptible to ≥1 agent in all but ≤2 antimicrobial categories
  xdr,

  /// Pan-Drug-Resistant (PDR)
  /// Non-susceptible to all agents in all antimicrobial categories
  pdr,
}

/// Extension methods for ResistancePhenotype
extension ResistancePhenotypeExtension on ResistancePhenotype {
  /// Get display name
  String get displayName {
    switch (this) {
      case ResistancePhenotype.esbl:
        return 'ESBL';
      case ResistancePhenotype.ampC:
        return 'AmpC';
      case ResistancePhenotype.cre:
        return 'CRE';
      case ResistancePhenotype.crpa:
        return 'CRPA';
      case ResistancePhenotype.crab:
        return 'CRAB';
      case ResistancePhenotype.mrsa:
        return 'MRSA';
      case ResistancePhenotype.vre:
        return 'VRE';
      case ResistancePhenotype.mdr:
        return 'MDR';
      case ResistancePhenotype.xdr:
        return 'XDR';
      case ResistancePhenotype.pdr:
        return 'PDR';
    }
  }

  /// Get full description
  String get fullName {
    switch (this) {
      case ResistancePhenotype.esbl:
        return 'Extended-Spectrum β-Lactamase';
      case ResistancePhenotype.ampC:
        return 'AmpC β-Lactamase';
      case ResistancePhenotype.cre:
        return 'Carbapenem-Resistant Enterobacterales';
      case ResistancePhenotype.crpa:
        return 'Carbapenem-Resistant Pseudomonas aeruginosa';
      case ResistancePhenotype.crab:
        return 'Carbapenem-Resistant Acinetobacter baumannii';
      case ResistancePhenotype.mrsa:
        return 'Methicillin-Resistant Staphylococcus aureus';
      case ResistancePhenotype.vre:
        return 'Vancomycin-Resistant Enterococcus';
      case ResistancePhenotype.mdr:
        return 'Multidrug-Resistant';
      case ResistancePhenotype.xdr:
        return 'Extensively Drug-Resistant';
      case ResistancePhenotype.pdr:
        return 'Pan-Drug-Resistant';
    }
  }

  /// Get clinical description
  String get clinicalDescription {
    switch (this) {
      case ResistancePhenotype.esbl:
        return 'Resistant to 3rd-gen cephalosporins, susceptible to carbapenems. Requires carbapenem therapy.';
      case ResistancePhenotype.ampC:
        return 'Resistant to 3rd-gen cephalosporins and cephamycins. May require carbapenem therapy.';
      case ResistancePhenotype.cre:
        return 'Carbapenem-resistant. Limited treatment options. Infection control alert required.';
      case ResistancePhenotype.crpa:
        return 'Carbapenem-resistant P. aeruginosa. Limited treatment options (ceftolozane-tazobactam, cefiderocol, colistin).';
      case ResistancePhenotype.crab:
        return 'Carbapenem-resistant A. baumannii. Very limited options (colistin, tigecycline, cefiderocol).';
      case ResistancePhenotype.mrsa:
        return 'Methicillin-resistant. Requires vancomycin, linezolid, or daptomycin. Contact precautions required.';
      case ResistancePhenotype.vre:
        return 'Vancomycin-resistant. Requires linezolid or daptomycin. Contact precautions required.';
      case ResistancePhenotype.mdr:
        return 'Non-susceptible to ≥1 agent in ≥3 antimicrobial categories. Limited treatment options.';
      case ResistancePhenotype.xdr:
        return 'Non-susceptible to ≥1 agent in all but ≤2 categories. Very limited treatment options.';
      case ResistancePhenotype.pdr:
        return 'Non-susceptible to all agents in all categories. Extremely limited or no treatment options.';
    }
  }

  /// Get infection control recommendation
  String get infectionControlRecommendation {
    switch (this) {
      case ResistancePhenotype.esbl:
        return 'Standard precautions. Consider contact precautions in outbreak settings.';
      case ResistancePhenotype.ampC:
        return 'Standard precautions. Monitor for resistance spread.';
      case ResistancePhenotype.cre:
      case ResistancePhenotype.crpa:
      case ResistancePhenotype.crab:
        return 'Contact precautions required. Notify infection control immediately. Single room isolation.';
      case ResistancePhenotype.mrsa:
        return 'Contact precautions required. Decolonization protocol may be indicated.';
      case ResistancePhenotype.vre:
        return 'Contact precautions required. Environmental cleaning with sporicidal agents.';
      case ResistancePhenotype.mdr:
      case ResistancePhenotype.xdr:
      case ResistancePhenotype.pdr:
        return 'Enhanced contact precautions. Dedicated equipment. Cohorting if multiple patients.';
    }
  }

  /// Get severity level (for color coding)
  String get severityLevel {
    switch (this) {
      case ResistancePhenotype.esbl:
      case ResistancePhenotype.ampC:
        return 'moderate'; // Yellow/Orange
      case ResistancePhenotype.cre:
      case ResistancePhenotype.crpa:
      case ResistancePhenotype.crab:
      case ResistancePhenotype.mrsa:
      case ResistancePhenotype.vre:
        return 'high'; // Red
      case ResistancePhenotype.mdr:
        return 'high'; // Red
      case ResistancePhenotype.xdr:
      case ResistancePhenotype.pdr:
        return 'critical'; // Dark Red
    }
  }
}

