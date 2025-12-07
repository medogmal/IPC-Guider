import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'history_entry.g.dart';

@HiveType(typeId: 0)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String toolType;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final Map<String, String> inputs;

  @HiveField(5)
  final String result;

  @HiveField(6)
  final String notes;

  @HiveField(7)
  final String? contextTag;

  @HiveField(8)
  final List<String> tags;

  HistoryEntry({
    String? id,
    required this.timestamp,
    required this.toolType,
    required this.title,
    required this.inputs,
    required this.result,
    this.notes = '',
    this.contextTag,
    this.tags = const [],
  }) : id = id ?? const Uuid().v4();

  // Factory constructor for creating from calculator results
  factory HistoryEntry.fromCalculator({
    required String calculatorName,
    required Map<String, String> inputs,
    required String result,
    String notes = '',
    List<String> tags = const [],
  }) {
    return HistoryEntry(
      timestamp: DateTime.now(),
      toolType: 'Calculator',
      title: calculatorName,
      inputs: inputs,
      result: result,
      notes: notes,
      tags: tags,
    );
  }

  // Factory constructor for creating from checklist results
  factory HistoryEntry.fromChecklist({
    required String checklistName,
    required Map<String, String> responses,
    required String completionStatus,
    String notes = '',
    List<String> tags = const [],
  }) {
    return HistoryEntry(
      timestamp: DateTime.now(),
      toolType: 'Checklist',
      title: checklistName,
      inputs: responses,
      result: completionStatus,
      notes: notes,
      tags: tags,
    );
  }

  // Factory constructor for creating from case builder results
  factory HistoryEntry.fromCaseBuilder({
    required String caseName,
    required Map<String, String> criteria,
    required String classification,
    String notes = '',
    List<String> tags = const [],
  }) {
    return HistoryEntry(
      timestamp: DateTime.now(),
      toolType: 'Case Builder',
      title: caseName,
      inputs: criteria,
      result: classification,
      notes: notes,
      tags: tags,
    );
  }

  // Factory constructor for creating from chart/analytics results
  factory HistoryEntry.fromChart({
    required String chartType,
    required Map<String, String> parameters,
    required String summary,
    String notes = '',
    List<String> tags = const [],
  }) {
    return HistoryEntry(
      timestamp: DateTime.now(),
      toolType: 'Chart',
      title: chartType,
      inputs: parameters,
      result: summary,
      notes: notes,
      tags: tags,
    );
  }

  // Factory constructor for creating from outbreak tool results
  factory HistoryEntry.fromOutbreakTool({
    required String toolName,
    required Map<String, String> inputs,
    required String result,
    String notes = '',
    List<String> tags = const [],
  }) {
    return HistoryEntry(
      timestamp: DateTime.now(),
      toolType: 'Outbreak Tool',
      title: toolName,
      inputs: inputs,
      result: result,
      notes: notes,
      tags: tags,
    );
  }

  // Create a copy with updated fields
  HistoryEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? toolType,
    String? title,
    Map<String, String>? inputs,
    String? result,
    String? notes,
    String? contextTag,
    List<String>? tags,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      toolType: toolType ?? this.toolType,
      title: title ?? this.title,
      inputs: inputs ?? this.inputs,
      result: result ?? this.result,
      notes: notes ?? this.notes,
      contextTag: contextTag ?? this.contextTag,
      tags: tags ?? this.tags,
    );
  }

  // Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'toolType': toolType,
      'title': title,
      'inputs': inputs,
      'result': result,
      'notes': notes,
      'contextTag': contextTag,
      'tags': tags,
    };
  }

  // Create from JSON
  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      toolType: json['toolType'] as String,
      title: json['title'] as String,
      inputs: Map<String, String>.from(json['inputs'] as Map),
      result: json['result'] as String,
      notes: json['notes'] as String? ?? '',
      contextTag: json['contextTag'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }

  // Get formatted timestamp for display
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Get inputs as formatted string
  String get inputsAsString {
    if (inputs.isEmpty) return 'No inputs';
    return inputs.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }

  // Check if entry matches search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
           result.toLowerCase().contains(lowerQuery) ||
           notes.toLowerCase().contains(lowerQuery) ||
           toolType.toLowerCase().contains(lowerQuery) ||
           inputs.values.any((value) => value.toLowerCase().contains(lowerQuery)) ||
           tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  // Check if entry has specific tag
  bool hasTag(String tag) {
    return tags.contains(tag);
  }

  // Get display color for tool type
  String get toolTypeColorHex {
    switch (toolType) {
      case 'Calculator':
        return '#4A90A4'; // Primary blue
      case 'Checklist':
        return '#059669'; // Success green
      case 'Case Builder':
        return '#D97706'; // Warning amber
      case 'Chart':
        return '#2563EB'; // Info blue
      case 'Outbreak Tool':
        return '#D97706'; // Golden amber (interactive tools)
      default:
        return '#64748B'; // Secondary gray
    }
  }

  @override
  String toString() {
    return 'HistoryEntry(id: $id, toolType: $toolType, title: $title, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
