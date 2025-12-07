import 'bundle_tool_enums.dart';

/// Represents compliance status for a single bundle element
class BundleElementCompliance {
  final String elementId;
  final String elementName;
  final String elementDescription;
  final ComplianceStatus status;
  final String? notes;

  const BundleElementCompliance({
    required this.elementId,
    required this.elementName,
    required this.elementDescription,
    required this.status,
    this.notes,
  });

  /// Create a copy with updated fields
  BundleElementCompliance copyWith({
    String? elementId,
    String? elementName,
    String? elementDescription,
    ComplianceStatus? status,
    String? notes,
  }) {
    return BundleElementCompliance(
      elementId: elementId ?? this.elementId,
      elementName: elementName ?? this.elementName,
      elementDescription: elementDescription ?? this.elementDescription,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'elementId': elementId,
      'elementName': elementName,
      'elementDescription': elementDescription,
      'status': status.name,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory BundleElementCompliance.fromJson(Map<String, dynamic> json) {
    return BundleElementCompliance(
      elementId: json['elementId'] as String,
      elementName: json['elementName'] as String,
      elementDescription: json['elementDescription'] as String,
      status: ComplianceStatus.values.byName(json['status'] as String),
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BundleElementCompliance &&
          runtimeType == other.runtimeType &&
          elementId == other.elementId &&
          elementName == other.elementName &&
          elementDescription == other.elementDescription &&
          status == other.status &&
          notes == other.notes;

  @override
  int get hashCode =>
      elementId.hashCode ^
      elementName.hashCode ^
      elementDescription.hashCode ^
      status.hashCode ^
      notes.hashCode;

  @override
  String toString() {
    return 'BundleElementCompliance(elementId: $elementId, elementName: $elementName, status: ${status.displayName})';
  }
}

