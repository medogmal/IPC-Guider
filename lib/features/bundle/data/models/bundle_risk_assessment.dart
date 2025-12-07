import 'package:uuid/uuid.dart';
import 'bundle_tool_enums.dart';

/// Risk assessment record with automatic scoring and mitigation strategies
class BundleRiskAssessment {
  final String id;
  final DateTime assessmentDate;
  final BundleType bundleType;
  final String unitLocation;
  final String assessorName;

  // Risk Factors by Category
  final List<String> patientRiskFactors;
  final String? otherPatientRisk;
  final List<String> unitRiskFactors;
  final String? otherUnitRisk;
  final List<String> staffingRiskFactors;
  final String? otherStaffingRisk;
  final List<String> resourceRiskFactors;
  final String? otherResourceRisk;

  // Calculated Scores
  final int patientRiskScore;
  final int unitRiskScore;
  final int staffingRiskScore;
  final int resourceRiskScore;
  final int totalRiskScore;
  final RiskLevel riskLevel;

  // Generated Outputs
  final String riskSummary;
  final List<MitigationStrategy> mitigationStrategies;
  final List<String> priorityActions;

  BundleRiskAssessment({
    String? id,
    required this.assessmentDate,
    required this.bundleType,
    required this.unitLocation,
    required this.assessorName,
    required this.patientRiskFactors,
    this.otherPatientRisk,
    required this.unitRiskFactors,
    this.otherUnitRisk,
    required this.staffingRiskFactors,
    this.otherStaffingRisk,
    required this.resourceRiskFactors,
    this.otherResourceRisk,
    required this.patientRiskScore,
    required this.unitRiskScore,
    required this.staffingRiskScore,
    required this.resourceRiskScore,
    required this.totalRiskScore,
    required this.riskLevel,
    required this.riskSummary,
    required this.mitigationStrategies,
    required this.priorityActions,
  }) : id = id ?? const Uuid().v4();

  /// Factory constructor with automatic risk calculation
  factory BundleRiskAssessment.calculate({
    required DateTime assessmentDate,
    required BundleType bundleType,
    required String unitLocation,
    required String assessorName,
    required List<String> patientRiskFactors,
    String? otherPatientRisk,
    required List<String> unitRiskFactors,
    String? otherUnitRisk,
    required List<String> staffingRiskFactors,
    String? otherStaffingRisk,
    required List<String> resourceRiskFactors,
    String? otherResourceRisk,
  }) {
    // Calculate scores (each factor = 5 points, max 100 per category)
    final patientScore = _calculateCategoryScore(
      patientRiskFactors.length + (otherPatientRisk?.isNotEmpty == true ? 1 : 0),
    );
    final unitScore = _calculateCategoryScore(
      unitRiskFactors.length + (otherUnitRisk?.isNotEmpty == true ? 1 : 0),
    );
    final staffingScore = _calculateCategoryScore(
      staffingRiskFactors.length + (otherStaffingRisk?.isNotEmpty == true ? 1 : 0),
    );
    final resourceScore = _calculateCategoryScore(
      resourceRiskFactors.length + (otherResourceRisk?.isNotEmpty == true ? 1 : 0),
    );

    // Total score (average of 4 categories)
    final totalScore = ((patientScore + unitScore + staffingScore + resourceScore) / 4).round();
    final riskLevel = RiskLevel.fromScore(totalScore);

    // Generate mitigation strategies
    final strategies = _generateMitigationStrategies(
      bundleType,
      patientRiskFactors,
      unitRiskFactors,
      staffingRiskFactors,
      resourceRiskFactors,
      riskLevel,
    );

    // Generate priority actions
    final actions = _generatePriorityActions(riskLevel, strategies);

    // Generate summary
    final summary = _generateRiskSummary(
      bundleType,
      totalScore,
      riskLevel,
      patientScore,
      unitScore,
      staffingScore,
      resourceScore,
    );

    return BundleRiskAssessment(
      assessmentDate: assessmentDate,
      bundleType: bundleType,
      unitLocation: unitLocation,
      assessorName: assessorName,
      patientRiskFactors: patientRiskFactors,
      otherPatientRisk: otherPatientRisk,
      unitRiskFactors: unitRiskFactors,
      otherUnitRisk: otherUnitRisk,
      staffingRiskFactors: staffingRiskFactors,
      otherStaffingRisk: otherStaffingRisk,
      resourceRiskFactors: resourceRiskFactors,
      otherResourceRisk: otherResourceRisk,
      patientRiskScore: patientScore,
      unitRiskScore: unitScore,
      staffingRiskScore: staffingScore,
      resourceRiskScore: resourceScore,
      totalRiskScore: totalScore,
      riskLevel: riskLevel,
      riskSummary: summary,
      mitigationStrategies: strategies,
      priorityActions: actions,
    );
  }

  /// Calculate score for a category (5 points per factor, max 100)
  static int _calculateCategoryScore(int factorCount) {
    return (factorCount * 5).clamp(0, 100);
  }

  /// Generate mitigation strategies based on identified risks
  static List<MitigationStrategy> _generateMitigationStrategies(
    BundleType bundleType,
    List<String> patientRisks,
    List<String> unitRisks,
    List<String> staffingRisks,
    List<String> resourceRisks,
    RiskLevel riskLevel,
  ) {
    final strategies = <MitigationStrategy>[];

    // Patient-related strategies
    if (patientRisks.isNotEmpty) {
      strategies.add(MitigationStrategy(
        category: RiskFactorCategory.patient,
        strategy: 'Implement enhanced monitoring for high-risk patients',
        timeline: riskLevel == RiskLevel.critical ? 'Immediate' : '1-2 weeks',
        responsible: 'Clinical Team',
        priority: riskLevel == RiskLevel.critical || riskLevel == RiskLevel.high
            ? 'High'
            : 'Medium',
      ));
    }

    // Unit-related strategies
    if (unitRisks.isNotEmpty) {
      strategies.add(MitigationStrategy(
        category: RiskFactorCategory.unit,
        strategy: 'Optimize unit environment and workflow processes',
        timeline: '2-4 weeks',
        responsible: 'Unit Manager',
        priority: unitRisks.length > 3 ? 'High' : 'Medium',
      ));
    }

    // Staffing-related strategies
    if (staffingRisks.isNotEmpty) {
      strategies.add(MitigationStrategy(
        category: RiskFactorCategory.staffing,
        strategy: 'Provide targeted training and increase staffing support',
        timeline: '1-3 weeks',
        responsible: 'Nursing Leadership',
        priority: staffingRisks.length > 3 ? 'High' : 'Medium',
      ));
    }

    // Resource-related strategies
    if (resourceRisks.isNotEmpty) {
      strategies.add(MitigationStrategy(
        category: RiskFactorCategory.resource,
        strategy: 'Ensure adequate supply chain and equipment availability',
        timeline: riskLevel == RiskLevel.critical ? 'Immediate' : '1-2 weeks',
        responsible: 'Supply Chain Manager',
        priority: resourceRisks.length > 3 ? 'High' : 'Medium',
      ));
    }

    return strategies;
  }

  /// Generate priority actions based on risk level
  static List<String> _generatePriorityActions(
    RiskLevel riskLevel,
    List<MitigationStrategy> strategies,
  ) {
    final actions = <String>[];

    switch (riskLevel) {
      case RiskLevel.critical:
        actions.addAll([
          'Immediate leadership notification required',
          'Daily monitoring and reassessment',
          'Consider temporary bundle compliance pause for safety review',
          'Activate rapid response team',
        ]);
        break;
      case RiskLevel.high:
        actions.addAll([
          'Notify unit leadership within 24 hours',
          'Increase audit frequency to daily',
          'Implement enhanced supervision',
          'Review and update protocols',
        ]);
        break;
      case RiskLevel.moderate:
        actions.addAll([
          'Schedule team meeting within 1 week',
          'Increase audit frequency to weekly',
          'Provide refresher training',
          'Monitor trends closely',
        ]);
        break;
      case RiskLevel.low:
        actions.addAll([
          'Continue routine monitoring',
          'Maintain current audit schedule',
          'Reinforce best practices',
          'Document baseline for comparison',
        ]);
        break;
    }

    return actions;
  }

  /// Generate risk summary text
  static String _generateRiskSummary(
    BundleType bundleType,
    int totalScore,
    RiskLevel riskLevel,
    int patientScore,
    int unitScore,
    int staffingScore,
    int resourceScore,
  ) {
    final highestCategory = _getHighestRiskCategory(
      patientScore,
      unitScore,
      staffingScore,
      resourceScore,
    );

    return 'Risk assessment for ${bundleType.shortName} shows ${riskLevel.displayName.toLowerCase()} risk '
        '(score: $totalScore/100). The highest risk area is $highestCategory. '
        'Immediate attention to mitigation strategies is ${riskLevel == RiskLevel.critical || riskLevel == RiskLevel.high ? "required" : "recommended"}.';
  }

  /// Determine highest risk category
  static String _getHighestRiskCategory(
    int patientScore,
    int unitScore,
    int staffingScore,
    int resourceScore,
  ) {
    final scores = {
      'patient factors': patientScore,
      'unit environment': unitScore,
      'staffing': staffingScore,
      'resources': resourceScore,
    };

    final highest = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    return highest.key;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessmentDate': assessmentDate.toIso8601String(),
      'bundleType': bundleType.name,
      'unitLocation': unitLocation,
      'assessorName': assessorName,
      'patientRiskFactors': patientRiskFactors,
      'otherPatientRisk': otherPatientRisk,
      'unitRiskFactors': unitRiskFactors,
      'otherUnitRisk': otherUnitRisk,
      'staffingRiskFactors': staffingRiskFactors,
      'otherStaffingRisk': otherStaffingRisk,
      'resourceRiskFactors': resourceRiskFactors,
      'otherResourceRisk': otherResourceRisk,
      'patientRiskScore': patientRiskScore,
      'unitRiskScore': unitRiskScore,
      'staffingRiskScore': staffingRiskScore,
      'resourceRiskScore': resourceRiskScore,
      'totalRiskScore': totalRiskScore,
      'riskLevel': riskLevel.name,
      'riskSummary': riskSummary,
      'mitigationStrategies': mitigationStrategies.map((s) => s.toJson()).toList(),
      'priorityActions': priorityActions,
    };
  }
}

/// Mitigation strategy for identified risks
class MitigationStrategy {
  final RiskFactorCategory category;
  final String strategy;
  final String timeline;
  final String responsible;
  final String priority;

  MitigationStrategy({
    required this.category,
    required this.strategy,
    required this.timeline,
    required this.responsible,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'strategy': strategy,
      'timeline': timeline,
      'responsible': responsible,
      'priority': priority,
    };
  }
}

