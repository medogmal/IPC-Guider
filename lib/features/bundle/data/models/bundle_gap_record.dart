import 'package:uuid/uuid.dart';
import 'bundle_tool_enums.dart';

/// Model for Bundle Gap Analysis record
/// Identifies root causes of bundle non-compliance and generates action plans
class BundleGapRecord {
  final String id;
  final DateTime analysisDate;
  final BundleType bundleType;
  final String unitLocation;
  final String analystName;
  final String timePeriod;
  
  // Compliance Data
  final double currentCompliance;
  final double targetCompliance;
  final int numberOfAudits;
  final double complianceGap;
  
  // Barriers with Frequency
  final Map<BundleBarrier, BarrierFrequency> barriers;
  final String? otherBarrier;
  final BarrierFrequency? otherBarrierFrequency;
  
  // Frequently Missed Elements
  final List<String> frequentlyMissedElements;
  
  // Generated Outputs
  final List<String> prioritizedBarriers;
  final List<ActionItem> actionPlan;
  final String gapSummary;
  final GapSeverity severity;
  
  final DateTime createdAt;

  BundleGapRecord({
    String? id,
    required this.analysisDate,
    required this.bundleType,
    required this.unitLocation,
    required this.analystName,
    required this.timePeriod,
    required this.currentCompliance,
    required this.targetCompliance,
    required this.numberOfAudits,
    required this.complianceGap,
    required this.barriers,
    this.otherBarrier,
    this.otherBarrierFrequency,
    required this.frequentlyMissedElements,
    required this.prioritizedBarriers,
    required this.actionPlan,
    required this.gapSummary,
    required this.severity,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Factory constructor with automatic analysis
  factory BundleGapRecord.analyze({
    required DateTime analysisDate,
    required BundleType bundleType,
    required String unitLocation,
    required String analystName,
    required String timePeriod,
    required double currentCompliance,
    required double targetCompliance,
    required int numberOfAudits,
    required Map<BundleBarrier, BarrierFrequency> barriers,
    String? otherBarrier,
    BarrierFrequency? otherBarrierFrequency,
    required List<String> frequentlyMissedElements,
  }) {
    final gap = targetCompliance - currentCompliance;
    final severity = _calculateSeverity(gap, currentCompliance);
    final prioritized = _prioritizeBarriers(barriers, otherBarrier, otherBarrierFrequency);
    final actionPlan = _generateActionPlan(
      bundleType,
      barriers,
      otherBarrier,
      otherBarrierFrequency,
      frequentlyMissedElements,
      gap,
    );
    final summary = _generateSummary(
      bundleType,
      currentCompliance,
      targetCompliance,
      gap,
      numberOfAudits,
      timePeriod,
    );

    return BundleGapRecord(
      analysisDate: analysisDate,
      bundleType: bundleType,
      unitLocation: unitLocation,
      analystName: analystName,
      timePeriod: timePeriod,
      currentCompliance: currentCompliance,
      targetCompliance: targetCompliance,
      numberOfAudits: numberOfAudits,
      complianceGap: gap,
      barriers: barriers,
      otherBarrier: otherBarrier,
      otherBarrierFrequency: otherBarrierFrequency,
      frequentlyMissedElements: frequentlyMissedElements,
      prioritizedBarriers: prioritized,
      actionPlan: actionPlan,
      gapSummary: summary,
      severity: severity,
    );
  }

  // Helper: Calculate gap severity
  static GapSeverity _calculateSeverity(double gap, double currentCompliance) {
    if (gap <= 5 && currentCompliance >= 90) return GapSeverity.low;
    if (gap <= 10 && currentCompliance >= 80) return GapSeverity.moderate;
    if (gap <= 20 && currentCompliance >= 70) return GapSeverity.high;
    return GapSeverity.critical;
  }

  // Helper: Prioritize barriers by frequency
  static List<String> _prioritizeBarriers(
    Map<BundleBarrier, BarrierFrequency> barriers,
    String? otherBarrier,
    BarrierFrequency? otherBarrierFrequency,
  ) {
    final prioritized = <String>[];

    // Sort barriers by frequency (High → Medium → Low)
    final highFreq = barriers.entries
        .where((e) => e.value == BarrierFrequency.high)
        .map((e) => e.key.displayName)
        .toList();
    final mediumFreq = barriers.entries
        .where((e) => e.value == BarrierFrequency.medium)
        .map((e) => e.key.displayName)
        .toList();
    final lowFreq = barriers.entries
        .where((e) => e.value == BarrierFrequency.low)
        .map((e) => e.key.displayName)
        .toList();

    prioritized.addAll(highFreq);
    prioritized.addAll(mediumFreq);
    prioritized.addAll(lowFreq);

    // Add "Other" barrier if specified
    if (otherBarrier != null && otherBarrier.isNotEmpty) {
      if (otherBarrierFrequency == BarrierFrequency.high) {
        prioritized.insert(0, otherBarrier);
      } else if (otherBarrierFrequency == BarrierFrequency.medium) {
        prioritized.insert(highFreq.length, otherBarrier);
      } else {
        prioritized.add(otherBarrier);
      }
    }

    return prioritized;
  }

  // Helper: Generate action plan
  static List<ActionItem> _generateActionPlan(
    BundleType bundleType,
    Map<BundleBarrier, BarrierFrequency> barriers,
    String? otherBarrier,
    BarrierFrequency? otherBarrierFrequency,
    List<String> frequentlyMissedElements,
    double gap,
  ) {
    final actions = <ActionItem>[];

    // Generate actions based on barriers
    barriers.forEach((barrier, frequency) {
      final action = _getActionForBarrier(barrier, frequency, bundleType);
      if (action != null) actions.add(action);
    });

    // Add actions for frequently missed elements
    if (frequentlyMissedElements.isNotEmpty) {
      actions.add(ActionItem(
        category: ActionCategory.training,
        priority: ActionPriority.high,
        action: 'Provide targeted training on frequently missed elements: ${frequentlyMissedElements.join(", ")}',
        timeline: '1-2 weeks',
        responsible: 'IPC Team + Unit Manager',
      ));
    }

    // Add monitoring action
    if (gap > 10) {
      actions.add(ActionItem(
        category: ActionCategory.monitoring,
        priority: ActionPriority.high,
        action: 'Implement daily compliance monitoring with real-time feedback',
        timeline: 'Immediate',
        responsible: 'Unit Manager',
      ));
    }

    return actions;
  }

  // Helper: Get action for specific barrier
  static ActionItem? _getActionForBarrier(
    BundleBarrier barrier,
    BarrierFrequency frequency,
    BundleType bundleType,
  ) {
    if (frequency == BarrierFrequency.low) return null;

    final priority = frequency == BarrierFrequency.high
        ? ActionPriority.high
        : ActionPriority.medium;

    switch (barrier) {
      case BundleBarrier.knowledgeGap:
        return ActionItem(
          category: ActionCategory.training,
          priority: priority,
          action: 'Conduct ${bundleType.shortName} bundle training sessions with competency assessment',
          timeline: '2-4 weeks',
          responsible: 'IPC Team',
        );
      case BundleBarrier.resourceUnavailability:
        return ActionItem(
          category: ActionCategory.resources,
          priority: priority,
          action: 'Audit and restock ${bundleType.shortName} bundle supplies; establish par levels',
          timeline: '1 week',
          responsible: 'Supply Chain + Unit Manager',
        );
      case BundleBarrier.workflowIssue:
        return ActionItem(
          category: ActionCategory.process,
          priority: priority,
          action: 'Conduct workflow analysis and redesign ${bundleType.shortName} bundle process',
          timeline: '2-3 weeks',
          responsible: 'Process Improvement Team',
        );
      case BundleBarrier.timeConstraint:
        return ActionItem(
          category: ActionCategory.process,
          priority: priority,
          action: 'Optimize workflow to reduce time burden; consider additional staffing',
          timeline: '2-4 weeks',
          responsible: 'Unit Manager + HR',
        );
      case BundleBarrier.communicationBreakdown:
        return ActionItem(
          category: ActionCategory.communication,
          priority: priority,
          action: 'Implement structured handoff tool and daily safety huddles',
          timeline: '1-2 weeks',
          responsible: 'Unit Manager',
        );
      case BundleBarrier.leadershipSupport:
        return ActionItem(
          category: ActionCategory.leadership,
          priority: ActionPriority.high,
          action: 'Engage leadership in bundle compliance initiative; establish accountability',
          timeline: 'Immediate',
          responsible: 'IPC Director + CNO',
        );
      case BundleBarrier.staffResistance:
        return ActionItem(
          category: ActionCategory.culture,
          priority: priority,
          action: 'Conduct staff engagement sessions; address concerns; share success stories',
          timeline: '2-3 weeks',
          responsible: 'Unit Manager + IPC Team',
        );
      case BundleBarrier.documentationIssue:
        return ActionItem(
          category: ActionCategory.process,
          priority: priority,
          action: 'Simplify documentation tools; provide EHR training',
          timeline: '1-2 weeks',
          responsible: 'IT + IPC Team',
        );
      case BundleBarrier.equipmentMalfunction:
        return ActionItem(
          category: ActionCategory.resources,
          priority: ActionPriority.high,
          action: 'Audit equipment; establish preventive maintenance schedule',
          timeline: 'Immediate',
          responsible: 'Biomedical Engineering',
        );
      case BundleBarrier.other:
        return null; // Handled separately
    }
  }

  // Helper: Generate summary
  static String _generateSummary(
    BundleType bundleType,
    double currentCompliance,
    double targetCompliance,
    double gap,
    int numberOfAudits,
    String timePeriod,
  ) {
    return 'Gap analysis for ${bundleType.shortName} bundle in $timePeriod: '
        'Current compliance is ${currentCompliance.toStringAsFixed(1)}%, '
        '${gap.toStringAsFixed(1)}% below target of ${targetCompliance.toStringAsFixed(0)}%. '
        'Analysis based on $numberOfAudits audits. '
        '${gap > 15 ? "Immediate action required." : gap > 10 ? "Significant improvement needed." : "Minor adjustments recommended."}';
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'analysisDate': analysisDate.toIso8601String(),
        'bundleType': bundleType.name,
        'unitLocation': unitLocation,
        'analystName': analystName,
        'timePeriod': timePeriod,
        'currentCompliance': currentCompliance,
        'targetCompliance': targetCompliance,
        'numberOfAudits': numberOfAudits,
        'complianceGap': complianceGap,
        'barriers': barriers.map((k, v) => MapEntry(k.name, v.name)),
        'otherBarrier': otherBarrier,
        'otherBarrierFrequency': otherBarrierFrequency?.name,
        'frequentlyMissedElements': frequentlyMissedElements,
        'prioritizedBarriers': prioritizedBarriers,
        'actionPlan': actionPlan.map((a) => a.toJson()).toList(),
        'gapSummary': gapSummary,
        'severity': severity.name,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Action item for gap closure
class ActionItem {
  final ActionCategory category;
  final ActionPriority priority;
  final String action;
  final String timeline;
  final String responsible;

  ActionItem({
    required this.category,
    required this.priority,
    required this.action,
    required this.timeline,
    required this.responsible,
  });

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'priority': priority.name,
        'action': action,
        'timeline': timeline,
        'responsible': responsible,
      };
}

