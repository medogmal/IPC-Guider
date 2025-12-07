/// Bundle types supported by the audit tool
enum BundleType {
  clabsi('CLABSI Bundle', 'Central Line-Associated Bloodstream Infection Prevention'),
  cauti('CAUTI Bundle', 'Catheter-Associated Urinary Tract Infection Prevention'),
  vap('VAP Bundle', 'Ventilator-Associated Pneumonia Prevention'),
  ssi('SSI Bundle', 'Surgical Site Infection Prevention'),
  sepsis('Sepsis Bundle', 'Sepsis Management Bundle');

  final String shortName;
  final String fullName;

  const BundleType(this.shortName, this.fullName);

  /// Get bundle type from string (case-insensitive)
  static BundleType? fromString(String value) {
    final normalized = value.toLowerCase().trim();
    for (final type in BundleType.values) {
      if (type.name.toLowerCase() == normalized ||
          type.shortName.toLowerCase() == normalized) {
        return type;
      }
    }
    return null;
  }
}

/// Compliance status for bundle elements
enum ComplianceStatus {
  compliant('Compliant', '✅', 'Yes'),
  nonCompliant('Non-Compliant', '❌', 'No'),
  notApplicable('Not Applicable', '⚠️', 'N/A');

  final String displayName;
  final String icon;
  final String shortLabel;

  const ComplianceStatus(this.displayName, this.icon, this.shortLabel);

  /// Get status from string (case-insensitive)
  static ComplianceStatus? fromString(String value) {
    final normalized = value.toLowerCase().trim();
    for (final status in ComplianceStatus.values) {
      if (status.name.toLowerCase() == normalized ||
          status.displayName.toLowerCase() == normalized ||
          status.shortLabel.toLowerCase() == normalized) {
        return status;
      }
    }
    return null;
  }
}

/// Barriers to bundle compliance
enum BundleBarrier {
  knowledgeGap('Knowledge gap'),
  resourceUnavailability('Resource unavailability'),
  workflowIssue('Workflow issue'),
  timeConstraint('Time constraint'),
  communicationBreakdown('Communication breakdown'),
  leadershipSupport('Leadership support lacking'),
  staffResistance('Staff resistance'),
  documentationIssue('Documentation issue'),
  equipmentMalfunction('Equipment malfunction'),
  other('Other');

  final String displayName;

  const BundleBarrier(this.displayName);

  /// Get barrier from string (case-insensitive)
  static BundleBarrier? fromString(String value) {
    final normalized = value.toLowerCase().trim();
    for (final barrier in BundleBarrier.values) {
      if (barrier.name.toLowerCase() == normalized ||
          barrier.displayName.toLowerCase() == normalized) {
        return barrier;
      }
    }
    return null;
  }
}

/// Risk factor categories
enum RiskFactorCategory {
  patient('Patient Risk Factors'),
  unit('Unit Risk Factors'),
  staffing('Staffing Risk Factors'),
  resource('Resource Risk Factors');

  final String displayName;

  const RiskFactorCategory(this.displayName);

  /// Get category from string (case-insensitive)
  static RiskFactorCategory? fromString(String value) {
    final normalized = value.toLowerCase().trim();
    for (final category in RiskFactorCategory.values) {
      if (category.name.toLowerCase() == normalized ||
          category.displayName.toLowerCase() == normalized) {
        return category;
      }
    }
    return null;
  }
}

/// Risk levels
enum RiskLevel {
  low('Low', 0, 30),
  moderate('Moderate', 30, 60),
  high('High', 60, 80),
  critical('Critical', 80, 100);

  final String displayName;
  final int minScore;
  final int maxScore;

  const RiskLevel(this.displayName, this.minScore, this.maxScore);

  /// Determine risk level from score
  static RiskLevel fromScore(int score) {
    if (score < 30) return RiskLevel.low;
    if (score < 60) return RiskLevel.moderate;
    if (score < 80) return RiskLevel.high;
    return RiskLevel.critical;
  }

  /// Get risk level from string (case-insensitive)
  static RiskLevel? fromString(String value) {
    final normalized = value.toLowerCase().trim();
    for (final level in RiskLevel.values) {
      if (level.name.toLowerCase() == normalized ||
          level.displayName.toLowerCase() == normalized) {
        return level;
      }
    }
    return null;
  }
}

/// Barrier frequency for gap analysis
enum BarrierFrequency {
  low('Low', 'Rarely encountered'),
  medium('Medium', 'Occasionally encountered'),
  high('High', 'Frequently encountered');

  final String displayName;
  final String description;

  const BarrierFrequency(this.displayName, this.description);

  /// Get frequency from string (case-insensitive)
  static BarrierFrequency? fromString(String value) {
    final normalized = value.toLowerCase().trim();
    for (final frequency in BarrierFrequency.values) {
      if (frequency.name.toLowerCase() == normalized ||
          frequency.displayName.toLowerCase() == normalized) {
        return frequency;
      }
    }
    return null;
  }
}

/// Time period for analysis
enum TimePeriod {
  week('Last 7 days', 7),
  twoWeeks('Last 14 days', 14),
  month('Last 30 days', 30),
  quarter('Last 90 days', 90),
  year('Last 365 days', 365),
  custom('Custom period', 0);

  final String displayName;
  final int days;

  const TimePeriod(this.displayName, this.days);

  /// Get time period from string (case-insensitive)
  static TimePeriod? fromString(String value) {
    final normalized = value.toLowerCase().trim();
    for (final period in TimePeriod.values) {
      if (period.name.toLowerCase() == normalized ||
          period.displayName.toLowerCase() == normalized) {
        return period;
      }
    }
    return null;
  }
}

/// Chart type for dashboard
enum ChartType {
  line('Line Chart'),
  bar('Bar Chart'),
  pie('Pie Chart'),
  heatmap('Heatmap');

  final String displayName;

  const ChartType(this.displayName);
}

/// Gap severity for gap analysis
enum GapSeverity {
  low('Low', 'Minor gap - target within reach'),
  moderate('Moderate', 'Moderate gap - focused improvement needed'),
  high('High', 'Significant gap - comprehensive action required'),
  critical('Critical', 'Critical gap - immediate intervention required');

  final String displayName;
  final String description;

  const GapSeverity(this.displayName, this.description);
}

/// Action category for gap closure
enum ActionCategory {
  training('Training & Education'),
  resources('Resources & Supplies'),
  process('Process Improvement'),
  communication('Communication'),
  leadership('Leadership & Accountability'),
  culture('Culture Change'),
  monitoring('Monitoring & Feedback');

  final String displayName;

  const ActionCategory(this.displayName);
}

/// Action priority for gap closure
enum ActionPriority {
  high('High', 'Immediate action required'),
  medium('Medium', 'Action needed within 2-4 weeks'),
  low('Low', 'Action needed within 1-2 months');

  final String displayName;
  final String description;

  const ActionPriority(this.displayName, this.description);
}
