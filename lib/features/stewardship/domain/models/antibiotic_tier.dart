/// Antibiotic Tier Classification
/// Based on CLSI M100-Ed35 (2025) Performance Standards for Antimicrobial Susceptibility Testing
///
/// CLSI M100-2025 defines antibiotic classes for selective reporting and antibiogram construction:
/// - Class A: Primary agents (1st line therapy)
/// - Class B: Alternative agents (2nd line therapy)
/// - Class C: Supplementary agents (additional options)
/// - Class U: Urine-only agents (urinary tract infections only)
/// - Class O: Other agents (colistin, tigecycline, novel agents - NOT oral)
enum AntibioticTier {
  /// Class A: Primary agents (1st line)
  /// - First-line empiric therapy options
  /// - Narrow-spectrum when possible
  /// - High efficacy for common pathogens
  /// - Minimal collateral damage to microbiome
  classA,

  /// Class B: Alternative agents (2nd line)
  /// - Used when Class A agents fail or contraindicated
  /// - Beta-lactam allergy alternatives
  /// - Resistance-driven selection
  classB,

  /// Class C: Supplementary agents
  /// - Additional therapeutic options
  /// - Specific clinical scenarios
  /// - May have broader spectrum or different mechanisms
  classC,

  /// Class U: Urine-only agents
  /// - Urine-specific agents (nitrofurantoin, fosfomycin)
  /// - High urinary concentrations
  /// - Not appropriate for systemic infections
  classU,

  /// Class O: Other agents (NOT oral)
  /// - Last-resort agents (colistin, polymyxin B)
  /// - Novel agents (tigecycline, ceftazidime-avibactam, ceftolozane-tazobactam)
  /// - Reserved for MDR/XDR organisms
  /// - Requires stewardship approval in many institutions
  classO,
}

/// Extension methods for AntibioticTier
extension AntibioticTierExtension on AntibioticTier {
  /// Get display name for the tier
  String get displayName {
    switch (this) {
      case AntibioticTier.classA:
        return 'Class A';
      case AntibioticTier.classB:
        return 'Class B';
      case AntibioticTier.classC:
        return 'Class C';
      case AntibioticTier.classU:
        return 'Class U';
      case AntibioticTier.classO:
        return 'Class O';
    }
  }

  /// Get description for the tier
  String get description {
    switch (this) {
      case AntibioticTier.classA:
        return 'Primary agents (1st line)';
      case AntibioticTier.classB:
        return 'Alternative agents (2nd line)';
      case AntibioticTier.classC:
        return 'Supplementary agents';
      case AntibioticTier.classU:
        return 'Urine-only agents';
      case AntibioticTier.classO:
        return 'Other agents (last-resort)';
    }
  }

  /// Get color for the tier (for UI badges)
  String get colorHex {
    switch (this) {
      case AntibioticTier.classA:
        return '#10B981'; // Green (success) - Primary agents
      case AntibioticTier.classB:
        return '#3B82F6'; // Blue (info) - Alternative agents
      case AntibioticTier.classC:
        return '#8B5CF6'; // Purple (primary) - Supplementary agents
      case AntibioticTier.classU:
        return '#06B6D4'; // Cyan (info) - Urine-only agents
      case AntibioticTier.classO:
        return '#F59E0B'; // Orange (warning) - Other/last-resort agents
    }
  }

  /// Get short label for the tier (for compact UI)
  String get shortLabel {
    switch (this) {
      case AntibioticTier.classA:
        return 'A';
      case AntibioticTier.classB:
        return 'B';
      case AntibioticTier.classC:
        return 'C';
      case AntibioticTier.classU:
        return 'U';
      case AntibioticTier.classO:
        return 'O';
    }
  }
}

/// Tiered Antibiotic Panel
/// Defines which antibiotics belong to which tier for a specific organism and specimen source
class TieredAntibioticPanel {
  final String organismId;
  final String specimenSource; // 'all', 'blood', 'urine', 'respiratory', 'wound'
  final Map<AntibioticTier, List<String>> antibioticsByTier;

  const TieredAntibioticPanel({
    required this.organismId,
    required this.specimenSource,
    required this.antibioticsByTier,
  });

  /// Get all antibiotics for a specific tier
  List<String> getAntibioticsForTier(AntibioticTier tier) {
    return antibioticsByTier[tier] ?? [];
  }

  /// Get all antibiotics across all tiers
  List<String> getAllAntibiotics() {
    return antibioticsByTier.values.expand((list) => list).toList();
  }

  /// Get tier for a specific antibiotic
  AntibioticTier? getTierForAntibiotic(String antibioticId) {
    for (final entry in antibioticsByTier.entries) {
      if (entry.value.contains(antibioticId)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Check if an antibiotic is included in this panel
  bool includesAntibiotic(String antibioticId) {
    return getAllAntibiotics().contains(antibioticId);
  }

  /// Get antibiotics for selected tiers
  List<String> getAntibioticsForTiers(Set<AntibioticTier> selectedTiers) {
    return selectedTiers
        .expand((tier) => getAntibioticsForTier(tier))
        .toSet()
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'organismId': organismId,
      'specimenSource': specimenSource,
      'antibioticsByTier': antibioticsByTier.map(
        (tier, antibiotics) => MapEntry(tier.name, antibiotics),
      ),
    };
  }

  factory TieredAntibioticPanel.fromJson(Map<String, dynamic> json) {
    return TieredAntibioticPanel(
      organismId: json['organismId'] as String,
      specimenSource: json['specimenSource'] as String,
      antibioticsByTier: (json['antibioticsByTier'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          AntibioticTier.values.firstWhere((tier) => tier.name == key),
          (value as List<dynamic>).map((e) => e as String).toList(),
        ),
      ),
    );
  }
}

