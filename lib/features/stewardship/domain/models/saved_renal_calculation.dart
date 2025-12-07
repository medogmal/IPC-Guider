import 'renal_function.dart';

/// Saved renal dose calculation
class SavedRenalCalculation {
  final String id;
  final DateTime timestamp;
  final String patientInitials;
  
  // Patient info
  final PatientInfo patientInfo;
  
  // Calculation results
  final RenalFunctionResult renalFunctionResult;
  final String calculationMethod;
  
  // Dose adjustment
  final DoseAdjustment? doseAdjustment;
  
  // Notes
  final String? notes;

  const SavedRenalCalculation({
    required this.id,
    required this.timestamp,
    required this.patientInitials,
    required this.patientInfo,
    required this.renalFunctionResult,
    required this.calculationMethod,
    this.doseAdjustment,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'patientInitials': patientInitials,
      'patientInfo': patientInfo.toJson(),
      'renalFunctionResult': renalFunctionResult.toJson(),
      'calculationMethod': calculationMethod,
      'doseAdjustment': doseAdjustment?.toJson(),
      'notes': notes,
    };
  }

  factory SavedRenalCalculation.fromJson(Map<String, dynamic> json) {
    return SavedRenalCalculation(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      patientInitials: json['patientInitials'] as String,
      patientInfo: PatientInfo.fromJson(json['patientInfo'] as Map<String, dynamic>),
      renalFunctionResult: RenalFunctionResult.fromJson(json['renalFunctionResult'] as Map<String, dynamic>),
      calculationMethod: json['calculationMethod'] as String,
      doseAdjustment: json['doseAdjustment'] != null
          ? DoseAdjustment.fromJson(json['doseAdjustment'] as Map<String, dynamic>)
          : null,
      notes: json['notes'] as String?,
    );
  }

  SavedRenalCalculation copyWith({
    String? id,
    DateTime? timestamp,
    String? patientInitials,
    PatientInfo? patientInfo,
    RenalFunctionResult? renalFunctionResult,
    String? calculationMethod,
    DoseAdjustment? doseAdjustment,
    String? notes,
  }) {
    return SavedRenalCalculation(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      patientInitials: patientInitials ?? this.patientInitials,
      patientInfo: patientInfo ?? this.patientInfo,
      renalFunctionResult: renalFunctionResult ?? this.renalFunctionResult,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      doseAdjustment: doseAdjustment ?? this.doseAdjustment,
      notes: notes ?? this.notes,
    );
  }
}

