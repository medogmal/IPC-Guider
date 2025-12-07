/// Data model for organism-antibiotic susceptibility data
class OrganismAntibioticData {
  final String organismId;
  final String organismName;
  final String antibioticId;
  final String antibioticName;
  final int susceptibleCount;
  final int intermediateCount;
  final int resistantCount;
  final int totalIsolates;

  const OrganismAntibioticData({
    required this.organismId,
    required this.organismName,
    required this.antibioticId,
    required this.antibioticName,
    required this.susceptibleCount,
    required this.intermediateCount,
    required this.resistantCount,
    required this.totalIsolates,
  });

  /// Calculate susceptibility percentage
  double get susceptibilityPercentage {
    if (totalIsolates == 0) return 0.0;
    return (susceptibleCount / totalIsolates) * 100;
  }

  /// Calculate intermediate percentage
  double get intermediatePercentage {
    if (totalIsolates == 0) return 0.0;
    return (intermediateCount / totalIsolates) * 100;
  }

  /// Calculate resistance percentage
  double get resistancePercentage {
    if (totalIsolates == 0) return 0.0;
    return (resistantCount / totalIsolates) * 100;
  }

  /// Check if data meets CLSI minimum threshold (≥30 isolates)
  bool get meetsClsiThreshold => totalIsolates >= 30;

  /// Validate that counts sum to total
  bool get isValid =>
      susceptibleCount + intermediateCount + resistantCount == totalIsolates;

  OrganismAntibioticData copyWith({
    String? organismId,
    String? organismName,
    String? antibioticId,
    String? antibioticName,
    int? susceptibleCount,
    int? intermediateCount,
    int? resistantCount,
    int? totalIsolates,
  }) {
    return OrganismAntibioticData(
      organismId: organismId ?? this.organismId,
      organismName: organismName ?? this.organismName,
      antibioticId: antibioticId ?? this.antibioticId,
      antibioticName: antibioticName ?? this.antibioticName,
      susceptibleCount: susceptibleCount ?? this.susceptibleCount,
      intermediateCount: intermediateCount ?? this.intermediateCount,
      resistantCount: resistantCount ?? this.resistantCount,
      totalIsolates: totalIsolates ?? this.totalIsolates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organismId': organismId,
      'organismName': organismName,
      'antibioticId': antibioticId,
      'antibioticName': antibioticName,
      'susceptibleCount': susceptibleCount,
      'intermediateCount': intermediateCount,
      'resistantCount': resistantCount,
      'totalIsolates': totalIsolates,
    };
  }

  factory OrganismAntibioticData.fromJson(Map<String, dynamic> json) {
    return OrganismAntibioticData(
      organismId: json['organismId'] as String,
      organismName: json['organismName'] as String,
      antibioticId: json['antibioticId'] as String,
      antibioticName: json['antibioticName'] as String,
      susceptibleCount: json['susceptibleCount'] as int,
      intermediateCount: json['intermediateCount'] as int,
      resistantCount: json['resistantCount'] as int,
      totalIsolates: json['totalIsolates'] as int,
    );
  }

  @override
  String toString() {
    return 'OrganismAntibioticData(organism: $organismName, antibiotic: $antibioticName, '
        'S: $susceptibleCount, I: $intermediateCount, R: $resistantCount, Total: $totalIsolates)';
  }
}

