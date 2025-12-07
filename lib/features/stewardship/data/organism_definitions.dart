import '../domain/models/organism_definition.dart';

/// Comprehensive list of organisms for antibiogram building
/// Organized by Gram stain category following CLSI M39-A4 guidelines
class OrganismDefinitions {
  /// Gram-Negative Bacteria
  static const List<OrganismDefinition> gramNegative = [
    OrganismDefinition(
      id: 'e-coli',
      name: 'Escherichia coli',
      category: 'gram-negative',
      abbreviation: 'E. coli',
      recommendedAntibiotics: [
        'ampicillin',
        'ampicillin-sulbactam',
        'cefazolin',
        'ceftriaxone',
        'ceftazidime',
        'cefepime',
        'ertapenem',
        'meropenem',
        'gentamicin',
        'amikacin',
        'ciprofloxacin',
        'levofloxacin',
        'tmp-smx',
        'nitrofurantoin',
        'piperacillin-tazobactam',
      ],
    ),
    OrganismDefinition(
      id: 'k-pneumoniae',
      name: 'Klebsiella pneumoniae',
      category: 'gram-negative',
      abbreviation: 'K. pneumoniae',
      recommendedAntibiotics: [
        'ampicillin-sulbactam',
        'cefazolin',
        'ceftriaxone',
        'ceftazidime',
        'cefepime',
        'ertapenem',
        'meropenem',
        'gentamicin',
        'amikacin',
        'ciprofloxacin',
        'levofloxacin',
        'tmp-smx',
        'piperacillin-tazobactam',
      ],
    ),
    OrganismDefinition(
      id: 'p-aeruginosa',
      name: 'Pseudomonas aeruginosa',
      category: 'gram-negative',
      abbreviation: 'P. aeruginosa',
      recommendedAntibiotics: [
        'ceftazidime',
        'cefepime',
        'meropenem',
        'imipenem',
        'gentamicin',
        'amikacin',
        'tobramycin',
        'ciprofloxacin',
        'levofloxacin',
        'piperacillin-tazobactam',
        'aztreonam',
        'colistin',
      ],
    ),
    OrganismDefinition(
      id: 'a-baumannii',
      name: 'Acinetobacter baumannii',
      category: 'gram-negative',
      abbreviation: 'A. baumannii',
      recommendedAntibiotics: [
        'ceftazidime',
        'cefepime',
        'meropenem',
        'imipenem',
        'gentamicin',
        'amikacin',
        'ciprofloxacin',
        'levofloxacin',
        'piperacillin-tazobactam',
        'colistin',
        'tigecycline',
        'tmp-smx',
      ],
    ),
    OrganismDefinition(
      id: 'enterobacter-spp',
      name: 'Enterobacter species',
      category: 'gram-negative',
      abbreviation: 'Enterobacter spp.',
      recommendedAntibiotics: [
        'ceftriaxone',
        'ceftazidime',
        'cefepime',
        'ertapenem',
        'meropenem',
        'gentamicin',
        'amikacin',
        'ciprofloxacin',
        'levofloxacin',
        'tmp-smx',
        'piperacillin-tazobactam',
      ],
    ),
    OrganismDefinition(
      id: 'proteus-mirabilis',
      name: 'Proteus mirabilis',
      category: 'gram-negative',
      abbreviation: 'P. mirabilis',
      recommendedAntibiotics: [
        'ampicillin',
        'cefazolin',
        'ceftriaxone',
        'ceftazidime',
        'cefepime',
        'ertapenem',
        'meropenem',
        'gentamicin',
        'amikacin',
        'ciprofloxacin',
        'levofloxacin',
        'tmp-smx',
      ],
    ),
    OrganismDefinition(
      id: 'serratia-marcescens',
      name: 'Serratia marcescens',
      category: 'gram-negative',
      abbreviation: 'S. marcescens',
      recommendedAntibiotics: [
        'ceftriaxone',
        'ceftazidime',
        'cefepime',
        'ertapenem',
        'meropenem',
        'gentamicin',
        'amikacin',
        'ciprofloxacin',
        'levofloxacin',
        'tmp-smx',
        'piperacillin-tazobactam',
      ],
    ),
    OrganismDefinition(
      id: 'salmonella-spp',
      name: 'Salmonella species',
      category: 'gram-negative',
      abbreviation: 'Salmonella spp.',
      recommendedAntibiotics: [
        'ceftriaxone',
        'cefotaxime',
        'ciprofloxacin',
        'levofloxacin',
        'azithromycin',
        'tmp-smx',
      ],
    ),
    OrganismDefinition(
      id: 'shigella-spp',
      name: 'Shigella species',
      category: 'gram-negative',
      abbreviation: 'Shigella spp.',
      recommendedAntibiotics: [
        'ceftriaxone',
        'cefotaxime',
        'ciprofloxacin',
        'levofloxacin',
        'azithromycin',
        'tmp-smx',
      ],
    ),
    OrganismDefinition(
      id: 'proteus-vulgaris',
      name: 'Proteus vulgaris',
      category: 'gram-negative',
      abbreviation: 'P. vulgaris',
      recommendedAntibiotics: [
        'ceftriaxone',
        'ceftazidime',
        'cefepime',
        'ertapenem',
        'meropenem',
        'gentamicin',
        'amikacin',
        'ciprofloxacin',
        'levofloxacin',
        'tmp-smx',
        'piperacillin-tazobactam',
      ],
    ),
    OrganismDefinition(
      id: 'morganella-morganii',
      name: 'Morganella morganii',
      category: 'gram-negative',
      abbreviation: 'M. morganii',
      recommendedAntibiotics: [
        'ceftriaxone',
        'ceftazidime',
        'cefepime',
        'ertapenem',
        'meropenem',
        'gentamicin',
        'amikacin',
        'ciprofloxacin',
        'levofloxacin',
        'tmp-smx',
        'piperacillin-tazobactam',
      ],
    ),
    OrganismDefinition(
      id: 'citrobacter-freundii',
      name: 'Citrobacter freundii',
      category: 'gram-negative',
      abbreviation: 'C. freundii',
      recommendedAntibiotics: [
        'ceftriaxone',
        'ceftazidime',
        'cefepime',
        'ertapenem',
        'meropenem',
        'gentamicin',
        'amikacin',
        'ciprofloxacin',
        'levofloxacin',
        'tmp-smx',
        'piperacillin-tazobactam',
      ],
    ),
    OrganismDefinition(
      id: 'citrobacter-koseri',
      name: 'Citrobacter koseri',
      category: 'gram-negative',
      abbreviation: 'C. koseri',
      recommendedAntibiotics: [
        'ceftriaxone',
        'ceftazidime',
        'cefepime',
        'ertapenem',
        'meropenem',
        'gentamicin',
        'amikacin',
        'ciprofloxacin',
        'levofloxacin',
        'tmp-smx',
        'piperacillin-tazobactam',
      ],
    ),
    OrganismDefinition(
      id: 'stenotrophomonas-maltophilia',
      name: 'Stenotrophomonas maltophilia',
      category: 'gram-negative',
      abbreviation: 'S. maltophilia',
      recommendedAntibiotics: [
        'tmp-smx',
        'levofloxacin',
        'tigecycline',
        'ceftazidime',
      ],
    ),
  ];

  /// Gram-Positive Bacteria
  static const List<OrganismDefinition> gramPositive = [
    // CLSI M100-2025 recommends splitting S. aureus into MSSA and MRSA
    OrganismDefinition(
      id: 'mssa',
      name: 'Methicillin-Susceptible Staphylococcus aureus',
      category: 'gram-positive',
      abbreviation: 'MSSA',
      recommendedAntibiotics: [
        'oxacillin',
        'cefazolin',
        'vancomycin',
        'linezolid',
        'daptomycin',
        'clindamycin',
        'erythromycin',
        'gentamicin',
        'ciprofloxacin',
        'levofloxacin',
        'tmp-smx',
        'rifampin',
        'tetracycline',
        'tigecycline',
      ],
    ),
    OrganismDefinition(
      id: 'mrsa',
      name: 'Methicillin-Resistant Staphylococcus aureus',
      category: 'gram-positive',
      abbreviation: 'MRSA',
      recommendedAntibiotics: [
        'vancomycin',
        'linezolid',
        'daptomycin',
        'clindamycin',
        'tmp-smx',
        'rifampin',
        'tetracycline',
        'tigecycline',
        'ceftaroline',
      ],
    ),
    OrganismDefinition(
      id: 's-epidermidis',
      name: 'Staphylococcus epidermidis',
      category: 'gram-positive',
      abbreviation: 'S. epidermidis',
      recommendedAntibiotics: [
        'oxacillin',
        'vancomycin',
        'linezolid',
        'daptomycin',
        'rifampin',
        'tmp-smx',
      ],
    ),
    OrganismDefinition(
      id: 's-saprophyticus',
      name: 'Staphylococcus saprophyticus',
      category: 'gram-positive',
      abbreviation: 'S. saprophyticus',
      recommendedAntibiotics: [
        'nitrofurantoin',
        'tmp-smx',
        'ciprofloxacin',
        'levofloxacin',
        'amoxicillin',
      ],
    ),
    OrganismDefinition(
      id: 'enterococcus-faecalis',
      name: 'Enterococcus faecalis',
      category: 'gram-positive',
      abbreviation: 'E. faecalis',
      recommendedAntibiotics: [
        'ampicillin',
        'vancomycin',
        'linezolid',
        'daptomycin',
        'nitrofurantoin',
      ],
    ),
    OrganismDefinition(
      id: 'enterococcus-faecium',
      name: 'Enterococcus faecium',
      category: 'gram-positive',
      abbreviation: 'E. faecium',
      recommendedAntibiotics: [
        'vancomycin',
        'linezolid',
        'daptomycin',
      ],
    ),
    OrganismDefinition(
      id: 's-pneumoniae',
      name: 'Streptococcus pneumoniae',
      category: 'gram-positive',
      abbreviation: 'S. pneumoniae',
      recommendedAntibiotics: [
        'penicillin',
        'amoxicillin',
        'ceftriaxone',
        'cefotaxime',
        'vancomycin',
        'levofloxacin',
        'moxifloxacin',
        'erythromycin',
        'azithromycin',
        'clindamycin',
      ],
    ),
    // Beta-hemolytic Streptococcus (all groups including S. agalactiae/Group B)
    OrganismDefinition(
      id: 'beta-hemolytic-strep',
      name: 'Beta-hemolytic Streptococcus',
      category: 'gram-positive',
      abbreviation: 'β-Hemolytic Strep',
      recommendedAntibiotics: [
        'penicillin',
        'ampicillin',
        'amoxicillin',
        'ceftriaxone',
        'cefotaxime',
        'vancomycin',
        'erythromycin',
        'azithromycin',
        'clindamycin',
      ],
    ),
  ];

  /// Other Organisms (Fungi)
  static const List<OrganismDefinition> other = [
    OrganismDefinition(
      id: 'candida-albicans',
      name: 'Candida albicans',
      category: 'other',
      abbreviation: 'C. albicans',
      recommendedAntibiotics: [
        'fluconazole',
        'voriconazole',
        'caspofungin',
        'micafungin',
        'amphotericin-b',
      ],
    ),
    OrganismDefinition(
      id: 'candida-glabrata',
      name: 'Candida glabrata',
      category: 'other',
      abbreviation: 'C. glabrata',
      recommendedAntibiotics: [
        'caspofungin',
        'micafungin',
        'amphotericin-b',
        'voriconazole',
      ],
    ),
    OrganismDefinition(
      id: 'candida-tropicalis',
      name: 'Candida tropicalis',
      category: 'other',
      abbreviation: 'C. tropicalis',
      recommendedAntibiotics: [
        'fluconazole',
        'voriconazole',
        'caspofungin',
        'micafungin',
        'amphotericin-b',
      ],
    ),
    OrganismDefinition(
      id: 'candida-parapsilosis',
      name: 'Candida parapsilosis',
      category: 'other',
      abbreviation: 'C. parapsilosis',
      recommendedAntibiotics: [
        'fluconazole',
        'voriconazole',
        'amphotericin-b',
        'caspofungin',
        'micafungin',
      ],
    ),
    OrganismDefinition(
      id: 'candida-auris',
      name: 'Candida auris',
      category: 'other',
      abbreviation: 'C. auris',
      recommendedAntibiotics: [
        'caspofungin',
        'micafungin',
        'amphotericin-b',
      ],
    ),
  ];

  /// Get all organisms
  static List<OrganismDefinition> get all => [
        ...gramNegative,
        ...gramPositive,
        ...other,
      ];

  /// Get organisms by category
  static List<OrganismDefinition> getByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'gram-negative':
        return gramNegative;
      case 'gram-positive':
        return gramPositive;
      case 'other':
        return other;
      default:
        return [];
    }
  }

  /// Get organism by ID
  static OrganismDefinition? getById(String id) {
    try {
      return all.firstWhere((org) => org.id == id);
    } catch (e) {
      return null;
    }
  }
}

