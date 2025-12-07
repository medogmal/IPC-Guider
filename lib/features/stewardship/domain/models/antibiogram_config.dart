import 'package:flutter/material.dart';

/// Configuration model for Antibiogram Builder
/// Contains facility information and CLSI M39-A4 compliance settings
class AntibiogramConfig {
  final String facilityName;
  final String unit;
  final DateTimeRange dateRange;
  final String specimenSource;
  final bool applyFirstIsolateRule;
  final bool excludeDuplicates;
  final bool minimumThreshold;
  final bool clinicallyRelevantOnly;

  const AntibiogramConfig({
    required this.facilityName,
    required this.unit,
    required this.dateRange,
    required this.specimenSource,
    this.applyFirstIsolateRule = true,
    this.excludeDuplicates = true,
    this.minimumThreshold = true,
    this.clinicallyRelevantOnly = true,
  });

  AntibiogramConfig copyWith({
    String? facilityName,
    String? unit,
    DateTimeRange? dateRange,
    String? specimenSource,
    bool? applyFirstIsolateRule,
    bool? excludeDuplicates,
    bool? minimumThreshold,
    bool? clinicallyRelevantOnly,
  }) {
    return AntibiogramConfig(
      facilityName: facilityName ?? this.facilityName,
      unit: unit ?? this.unit,
      dateRange: dateRange ?? this.dateRange,
      specimenSource: specimenSource ?? this.specimenSource,
      applyFirstIsolateRule: applyFirstIsolateRule ?? this.applyFirstIsolateRule,
      excludeDuplicates: excludeDuplicates ?? this.excludeDuplicates,
      minimumThreshold: minimumThreshold ?? this.minimumThreshold,
      clinicallyRelevantOnly: clinicallyRelevantOnly ?? this.clinicallyRelevantOnly,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facilityName': facilityName,
      'unit': unit,
      'dateRangeStart': dateRange.start.toIso8601String(),
      'dateRangeEnd': dateRange.end.toIso8601String(),
      'specimenSource': specimenSource,
      'applyFirstIsolateRule': applyFirstIsolateRule,
      'excludeDuplicates': excludeDuplicates,
      'minimumThreshold': minimumThreshold,
      'clinicallyRelevantOnly': clinicallyRelevantOnly,
    };
  }

  factory AntibiogramConfig.fromJson(Map<String, dynamic> json) {
    return AntibiogramConfig(
      facilityName: json['facilityName'] as String,
      unit: json['unit'] as String,
      dateRange: DateTimeRange(
        start: DateTime.parse(json['dateRangeStart'] as String),
        end: DateTime.parse(json['dateRangeEnd'] as String),
      ),
      specimenSource: json['specimenSource'] as String,
      applyFirstIsolateRule: json['applyFirstIsolateRule'] as bool? ?? true,
      excludeDuplicates: json['excludeDuplicates'] as bool? ?? true,
      minimumThreshold: json['minimumThreshold'] as bool? ?? true,
      clinicallyRelevantOnly: json['clinicallyRelevantOnly'] as bool? ?? true,
    );
  }
}

