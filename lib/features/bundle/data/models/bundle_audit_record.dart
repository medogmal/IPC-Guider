import 'package:uuid/uuid.dart';
import 'bundle_element_compliance.dart';
import 'bundle_tool_enums.dart';

/// Represents a complete bundle audit record
class BundleAuditRecord {
  final String id;
  final DateTime auditDate;
  final BundleType bundleType;
  final String unitLocation;
  final String auditorName;
  final String? patientId;
  final List<BundleElementCompliance> elements;
  final List<BundleBarrier> barriers;
  final String? otherBarrier;
  final double complianceScore;
  final String interpretation;
  final List<String> recommendations;
  final DateTime createdAt;

  BundleAuditRecord({
    String? id,
    required this.auditDate,
    required this.bundleType,
    required this.unitLocation,
    required this.auditorName,
    this.patientId,
    required this.elements,
    required this.barriers,
    this.otherBarrier,
    required this.complianceScore,
    required this.interpretation,
    required this.recommendations,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Calculate compliance score and create audit record
  factory BundleAuditRecord.calculate({
    required DateTime auditDate,
    required BundleType bundleType,
    required String unitLocation,
    required String auditorName,
    String? patientId,
    required List<BundleElementCompliance> elements,
    required List<BundleBarrier> barriers,
    String? otherBarrier,
  }) {
    // Calculate compliance score
    final applicableElements = elements
        .where((e) => e.status != ComplianceStatus.notApplicable)
        .length;
    final compliantElements =
        elements.where((e) => e.status == ComplianceStatus.compliant).length;
    final score = applicableElements > 0
        ? (compliantElements / applicableElements) * 100
        : 0.0;

    return BundleAuditRecord(
      auditDate: auditDate,
      bundleType: bundleType,
      unitLocation: unitLocation,
      auditorName: auditorName,
      patientId: patientId,
      elements: elements,
      barriers: barriers,
      otherBarrier: otherBarrier,
      complianceScore: score,
      interpretation: _generateInterpretation(score),
      recommendations:
          _generateRecommendations(score, elements, barriers, otherBarrier),
    );
  }

  /// Generate clinical interpretation based on compliance score
  static String _generateInterpretation(double score) {
    if (score >= 95) {
      return 'Excellent bundle adherence. Continue current practices and monitor for sustainability.';
    } else if (score >= 85) {
      return 'Good adherence with minor gaps. Review non-compliant elements and implement targeted interventions.';
    } else if (score >= 75) {
      return 'Moderate adherence. Significant improvement needed. Conduct gap analysis and develop action plan.';
    } else {
      return 'Poor adherence. Immediate action required. Conduct root cause analysis and implement comprehensive improvement plan.';
    }
  }

  /// Generate recommendations based on audit results
  static List<String> _generateRecommendations(
    double score,
    List<BundleElementCompliance> elements,
    List<BundleBarrier> barriers,
    String? otherBarrier,
  ) {
    final recommendations = <String>[];

    // Add recommendations based on non-compliant elements
    final nonCompliant = elements
        .where((e) => e.status == ComplianceStatus.nonCompliant)
        .toList();
    if (nonCompliant.isNotEmpty) {
      recommendations.add(
          'Focus on improving: ${nonCompliant.map((e) => e.elementName).join(', ')}');
    }

    // Add recommendations based on barriers
    if (barriers.contains(BundleBarrier.knowledgeGap)) {
      recommendations
          .add('Provide targeted education and training on bundle elements');
    }
    if (barriers.contains(BundleBarrier.resourceUnavailability)) {
      recommendations
          .add('Ensure adequate supply of necessary equipment and materials');
    }
    if (barriers.contains(BundleBarrier.workflowIssue)) {
      recommendations.add(
          'Review and optimize workflow processes for bundle implementation');
    }
    if (barriers.contains(BundleBarrier.timeConstraint)) {
      recommendations.add('Assess staffing levels and workload distribution');
    }
    if (barriers.contains(BundleBarrier.communicationBreakdown)) {
      recommendations
          .add('Improve communication channels and handoff processes');
    }
    if (barriers.contains(BundleBarrier.leadershipSupport)) {
      recommendations
          .add('Engage leadership to prioritize bundle compliance initiatives');
    }
    if (barriers.contains(BundleBarrier.staffResistance)) {
      recommendations.add(
          'Address staff concerns and involve frontline staff in improvement efforts');
    }
    if (barriers.contains(BundleBarrier.documentationIssue)) {
      recommendations
          .add('Simplify documentation processes and provide clear guidelines');
    }
    if (barriers.contains(BundleBarrier.equipmentMalfunction)) {
      recommendations
          .add('Ensure regular equipment maintenance and availability of backups');
    }
    if (barriers.contains(BundleBarrier.other) && otherBarrier != null) {
      recommendations.add('Address identified barrier: $otherBarrier');
    }

    // Add general recommendations based on score
    if (score < 95) {
      recommendations.add('Conduct regular audits to monitor improvement');
      recommendations.add('Share audit results with team and celebrate successes');
    }

    return recommendations;
  }

  /// Get count of compliant elements
  int get compliantCount =>
      elements.where((e) => e.status == ComplianceStatus.compliant).length;

  /// Get count of non-compliant elements
  int get nonCompliantCount =>
      elements.where((e) => e.status == ComplianceStatus.nonCompliant).length;

  /// Get count of not applicable elements
  int get notApplicableCount =>
      elements.where((e) => e.status == ComplianceStatus.notApplicable).length;

  /// Get count of applicable elements
  int get applicableCount =>
      elements.where((e) => e.status != ComplianceStatus.notApplicable).length;

  /// Create a copy with updated fields
  BundleAuditRecord copyWith({
    String? id,
    DateTime? auditDate,
    BundleType? bundleType,
    String? unitLocation,
    String? auditorName,
    String? patientId,
    List<BundleElementCompliance>? elements,
    List<BundleBarrier>? barriers,
    String? otherBarrier,
    double? complianceScore,
    String? interpretation,
    List<String>? recommendations,
    DateTime? createdAt,
  }) {
    return BundleAuditRecord(
      id: id ?? this.id,
      auditDate: auditDate ?? this.auditDate,
      bundleType: bundleType ?? this.bundleType,
      unitLocation: unitLocation ?? this.unitLocation,
      auditorName: auditorName ?? this.auditorName,
      patientId: patientId ?? this.patientId,
      elements: elements ?? this.elements,
      barriers: barriers ?? this.barriers,
      otherBarrier: otherBarrier ?? this.otherBarrier,
      complianceScore: complianceScore ?? this.complianceScore,
      interpretation: interpretation ?? this.interpretation,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auditDate': auditDate.toIso8601String(),
      'bundleType': bundleType.name,
      'unitLocation': unitLocation,
      'auditorName': auditorName,
      'patientId': patientId,
      'elements': elements.map((e) => e.toJson()).toList(),
      'barriers': barriers.map((b) => b.name).toList(),
      'otherBarrier': otherBarrier,
      'complianceScore': complianceScore,
      'interpretation': interpretation,
      'recommendations': recommendations,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory BundleAuditRecord.fromJson(Map<String, dynamic> json) {
    return BundleAuditRecord(
      id: json['id'] as String,
      auditDate: DateTime.parse(json['auditDate'] as String),
      bundleType: BundleType.values.byName(json['bundleType'] as String),
      unitLocation: json['unitLocation'] as String,
      auditorName: json['auditorName'] as String,
      patientId: json['patientId'] as String?,
      elements: (json['elements'] as List)
          .map((e) => BundleElementCompliance.fromJson(e as Map<String, dynamic>))
          .toList(),
      barriers: (json['barriers'] as List)
          .map((b) => BundleBarrier.values.byName(b as String))
          .toList(),
      otherBarrier: json['otherBarrier'] as String?,
      complianceScore: (json['complianceScore'] as num).toDouble(),
      interpretation: json['interpretation'] as String,
      recommendations: List<String>.from(json['recommendations'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'BundleAuditRecord(id: $id, bundleType: ${bundleType.shortName}, complianceScore: ${complianceScore.toStringAsFixed(1)}%)';
  }
}

