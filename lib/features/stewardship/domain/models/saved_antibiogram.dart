/// Saved Antibiogram Model
/// Represents a saved antibiogram with all configuration and data
class SavedAntibiogram {
  final String id;
  final String facilityName;
  final String unit;
  final DateTime startDate;
  final DateTime endDate;
  final String specimenSource;
  final bool firstIsolateRule;
  final bool excludeDuplicates;
  final bool minimumThreshold;
  final bool clinicallyRelevantOnly;
  final List<String> selectedOrganisms;
  final List<Map<String, dynamic>> antibiogramData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedAntibiogram({
    required this.id,
    required this.facilityName,
    required this.unit,
    required this.startDate,
    required this.endDate,
    required this.specimenSource,
    required this.firstIsolateRule,
    required this.excludeDuplicates,
    required this.minimumThreshold,
    required this.clinicallyRelevantOnly,
    required this.selectedOrganisms,
    required this.antibiogramData,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facilityName': facilityName,
      'unit': unit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'specimenSource': specimenSource,
      'firstIsolateRule': firstIsolateRule,
      'excludeDuplicates': excludeDuplicates,
      'minimumThreshold': minimumThreshold,
      'clinicallyRelevantOnly': clinicallyRelevantOnly,
      'selectedOrganisms': selectedOrganisms,
      'antibiogramData': antibiogramData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SavedAntibiogram.fromJson(Map<String, dynamic> json) {
    return SavedAntibiogram(
      id: json['id'] as String,
      facilityName: json['facilityName'] as String,
      unit: json['unit'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      specimenSource: json['specimenSource'] as String,
      firstIsolateRule: json['firstIsolateRule'] as bool,
      excludeDuplicates: json['excludeDuplicates'] as bool,
      minimumThreshold: json['minimumThreshold'] as bool,
      clinicallyRelevantOnly: json['clinicallyRelevantOnly'] as bool,
      selectedOrganisms: List<String>.from(json['selectedOrganisms'] as List),
      antibiogramData: List<Map<String, dynamic>>.from(
        (json['antibiogramData'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  SavedAntibiogram copyWith({
    String? id,
    String? facilityName,
    String? unit,
    DateTime? startDate,
    DateTime? endDate,
    String? specimenSource,
    bool? firstIsolateRule,
    bool? excludeDuplicates,
    bool? minimumThreshold,
    bool? clinicallyRelevantOnly,
    List<String>? selectedOrganisms,
    List<Map<String, dynamic>>? antibiogramData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedAntibiogram(
      id: id ?? this.id,
      facilityName: facilityName ?? this.facilityName,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      specimenSource: specimenSource ?? this.specimenSource,
      firstIsolateRule: firstIsolateRule ?? this.firstIsolateRule,
      excludeDuplicates: excludeDuplicates ?? this.excludeDuplicates,
      minimumThreshold: minimumThreshold ?? this.minimumThreshold,
      clinicallyRelevantOnly: clinicallyRelevantOnly ?? this.clinicallyRelevantOnly,
      selectedOrganisms: selectedOrganisms ?? this.selectedOrganisms,
      antibiogramData: antibiogramData ?? this.antibiogramData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

