import 'package:uuid/uuid.dart';

/// Sepsis Bundle (Hour-1 Bundle) compliance record with time tracking
class SepsisBundleRecord {
  final String id;
  final DateTime recognitionTime; // Time sepsis was recognized
  final DateTime auditDate;
  final String unitLocation;
  final String auditorName;
  final String? patientId;

  // Hour-1 Bundle Elements with time tracking
  final bool lactateMeasured;
  final DateTime? lactateTime;
  final double? lactateValue; // mmol/L

  final bool bloodCulturesObtained;
  final DateTime? bloodCulturesTime;

  final bool antibioticsAdministered;
  final DateTime? antibioticsTime;

  final bool fluidResuscitationGiven;
  final DateTime? fluidResuscitationTime;
  final double? fluidVolume; // mL

  final bool vasopressorsApplied;
  final DateTime? vasopressorsTime;
  final bool vasopressorsIndicated; // Was patient hypotensive?

  // Calculated fields
  final int compliantElements;
  final int totalElements;
  final double compliancePercentage;
  final bool hour1Compliant; // All elements within 1 hour
  final String complianceLevel;
  final List<String> missedElements;
  final List<TimeViolation> timeViolations;
  final String interpretation;
  final List<String> recommendations;

  SepsisBundleRecord({
    required this.id,
    required this.recognitionTime,
    required this.auditDate,
    required this.unitLocation,
    required this.auditorName,
    this.patientId,
    required this.lactateMeasured,
    this.lactateTime,
    this.lactateValue,
    required this.bloodCulturesObtained,
    this.bloodCulturesTime,
    required this.antibioticsAdministered,
    this.antibioticsTime,
    required this.fluidResuscitationGiven,
    this.fluidResuscitationTime,
    this.fluidVolume,
    required this.vasopressorsApplied,
    this.vasopressorsTime,
    required this.vasopressorsIndicated,
    required this.compliantElements,
    required this.totalElements,
    required this.compliancePercentage,
    required this.hour1Compliant,
    required this.complianceLevel,
    required this.missedElements,
    required this.timeViolations,
    required this.interpretation,
    required this.recommendations,
  });

  /// Factory constructor to calculate compliance
  factory SepsisBundleRecord.calculate({
    required DateTime recognitionTime,
    required DateTime auditDate,
    required String unitLocation,
    required String auditorName,
    String? patientId,
    required bool lactateMeasured,
    DateTime? lactateTime,
    double? lactateValue,
    required bool bloodCulturesObtained,
    DateTime? bloodCulturesTime,
    required bool antibioticsAdministered,
    DateTime? antibioticsTime,
    required bool fluidResuscitationGiven,
    DateTime? fluidResuscitationTime,
    double? fluidVolume,
    required bool vasopressorsApplied,
    DateTime? vasopressorsTime,
    required bool vasopressorsIndicated,
  }) {
    // Calculate compliant elements
    int compliantElements = 0;
    int totalElements = 0;
    final missedElements = <String>[];
    final timeViolations = <TimeViolation>[];

    // Element 1: Lactate measured
    totalElements++;
    if (lactateMeasured) {
      compliantElements++;
      if (lactateTime != null) {
        final timeDiff = lactateTime.difference(recognitionTime).inMinutes;
        if (timeDiff > 60) {
          timeViolations.add(TimeViolation(
            element: 'Lactate Measurement',
            targetMinutes: 60,
            actualMinutes: timeDiff,
          ));
        }
      }
    } else {
      missedElements.add('Lactate measurement');
    }

    // Element 2: Blood cultures obtained
    totalElements++;
    if (bloodCulturesObtained) {
      compliantElements++;
      if (bloodCulturesTime != null) {
        final timeDiff = bloodCulturesTime.difference(recognitionTime).inMinutes;
        if (timeDiff > 60) {
          timeViolations.add(TimeViolation(
            element: 'Blood Cultures',
            targetMinutes: 60,
            actualMinutes: timeDiff,
          ));
        }
      }
    } else {
      missedElements.add('Blood cultures before antibiotics');
    }

    // Element 3: Antibiotics administered
    totalElements++;
    if (antibioticsAdministered) {
      compliantElements++;
      if (antibioticsTime != null) {
        final timeDiff = antibioticsTime.difference(recognitionTime).inMinutes;
        if (timeDiff > 60) {
          timeViolations.add(TimeViolation(
            element: 'Broad-Spectrum Antibiotics',
            targetMinutes: 60,
            actualMinutes: timeDiff,
          ));
        }
      }
    } else {
      missedElements.add('Broad-spectrum antibiotics');
    }

    // Element 4: Fluid resuscitation (if indicated)
    totalElements++;
    if (fluidResuscitationGiven) {
      compliantElements++;
      if (fluidResuscitationTime != null) {
        final timeDiff = fluidResuscitationTime.difference(recognitionTime).inMinutes;
        if (timeDiff > 180) { // 3 hours for fluid resuscitation
          timeViolations.add(TimeViolation(
            element: 'Fluid Resuscitation (30mL/kg)',
            targetMinutes: 180,
            actualMinutes: timeDiff,
          ));
        }
      }
    } else {
      missedElements.add('Fluid resuscitation (30mL/kg crystalloid)');
    }

    // Element 5: Vasopressors (if indicated)
    if (vasopressorsIndicated) {
      totalElements++;
      if (vasopressorsApplied) {
        compliantElements++;
        if (vasopressorsTime != null) {
          final timeDiff = vasopressorsTime.difference(recognitionTime).inMinutes;
          if (timeDiff > 60) {
            timeViolations.add(TimeViolation(
              element: 'Vasopressors (MAP ≥65 mmHg)',
              targetMinutes: 60,
              actualMinutes: timeDiff,
            ));
          }
        }
      } else {
        missedElements.add('Vasopressors for hypotension');
      }
    }

    // Calculate compliance percentage
    final compliancePercentage = totalElements > 0
        ? (compliantElements / totalElements) * 100
        : 0.0;

    // Determine if Hour-1 compliant (all elements within 1 hour, except fluids which have 3 hours)
    final hour1Compliant = timeViolations.isEmpty && compliantElements == totalElements;

    // Determine compliance level
    String complianceLevel;
    if (compliancePercentage == 100 && hour1Compliant) {
      complianceLevel = 'Excellent';
    } else if (compliancePercentage >= 80) {
      complianceLevel = 'Good';
    } else if (compliancePercentage >= 60) {
      complianceLevel = 'Fair';
    } else {
      complianceLevel = 'Poor';
    }

    // Generate interpretation
    final interpretation = _generateInterpretation(
      compliantElements,
      totalElements,
      compliancePercentage,
      hour1Compliant,
      timeViolations,
    );

    // Generate recommendations
    final recommendations = _generateRecommendations(
      missedElements,
      timeViolations,
      lactateValue,
    );

    return SepsisBundleRecord(
      id: const Uuid().v4(),
      recognitionTime: recognitionTime,
      auditDate: auditDate,
      unitLocation: unitLocation,
      auditorName: auditorName,
      patientId: patientId,
      lactateMeasured: lactateMeasured,
      lactateTime: lactateTime,
      lactateValue: lactateValue,
      bloodCulturesObtained: bloodCulturesObtained,
      bloodCulturesTime: bloodCulturesTime,
      antibioticsAdministered: antibioticsAdministered,
      antibioticsTime: antibioticsTime,
      fluidResuscitationGiven: fluidResuscitationGiven,
      fluidResuscitationTime: fluidResuscitationTime,
      fluidVolume: fluidVolume,
      vasopressorsApplied: vasopressorsApplied,
      vasopressorsTime: vasopressorsTime,
      vasopressorsIndicated: vasopressorsIndicated,
      compliantElements: compliantElements,
      totalElements: totalElements,
      compliancePercentage: compliancePercentage,
      hour1Compliant: hour1Compliant,
      complianceLevel: complianceLevel,
      missedElements: missedElements,
      timeViolations: timeViolations,
      interpretation: interpretation,
      recommendations: recommendations,
    );
  }

  static String _generateInterpretation(
    int compliantElements,
    int totalElements,
    double compliancePercentage,
    bool hour1Compliant,
    List<TimeViolation> timeViolations,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('Sepsis Hour-1 Bundle Compliance: ${compliancePercentage.toStringAsFixed(1)}%');
    buffer.writeln('$compliantElements out of $totalElements elements completed.');

    if (hour1Compliant) {
      buffer.writeln('\n✓ Excellent! All elements completed within target timeframes.');
    } else if (timeViolations.isNotEmpty) {
      buffer.writeln('\n⚠ Time violations detected:');
      for (final violation in timeViolations) {
        buffer.writeln('  • ${violation.element}: ${violation.actualMinutes} min (target: ${violation.targetMinutes} min)');
      }
    }

    return buffer.toString();
  }

  static List<String> _generateRecommendations(
    List<String> missedElements,
    List<TimeViolation> timeViolations,
    double? lactateValue,
  ) {
    final recommendations = <String>[];

    if (missedElements.isNotEmpty) {
      recommendations.add('Priority: Complete missed elements immediately');
      for (final element in missedElements) {
        recommendations.add('  • $element');
      }
    }

    if (timeViolations.isNotEmpty) {
      recommendations.add('Improve time-to-treatment for delayed elements');
      recommendations.add('Review workflow barriers causing delays');
    }

    if (lactateValue != null && lactateValue >= 2.0) {
      recommendations.add('Remeasure lactate if initial lactate ≥2 mmol/L');
    }

    if (lactateValue != null && lactateValue >= 4.0) {
      recommendations.add('Urgent: Lactate ≥4 mmol/L indicates severe sepsis - aggressive resuscitation needed');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Excellent compliance - maintain current practices');
    }

    return recommendations;
  }
}

/// Time violation for Hour-1 Bundle element
class TimeViolation {
  final String element;
  final int targetMinutes;
  final int actualMinutes;

  TimeViolation({
    required this.element,
    required this.targetMinutes,
    required this.actualMinutes,
  });

  int get delayMinutes => actualMinutes - targetMinutes;
}

