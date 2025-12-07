import 'pathogen_detail.dart';

// Main index model
class OutbreakGroupsIndex {
  final int version;
  final String updatedAt;
  final List<PathogenType> types;

  OutbreakGroupsIndex({
    required this.version,
    required this.updatedAt,
    required this.types,
  });

  factory OutbreakGroupsIndex.fromJson(Map<String, dynamic> json) {
    return OutbreakGroupsIndex(
      version: json['version'] as int? ?? 1,
      updatedAt: json['updatedAt'] as String? ?? '',
      types: (json['types'] as List<dynamic>?)
              ?.map((e) => PathogenType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'updatedAt': updatedAt,
      'types': types.map((e) => e.toJson()).toList(),
    };
  }
}

// Pathogen type (Bacterial, Viral, Fungal)
class PathogenType {
  final String id;
  final String name;
  final String icon;
  final String color;
  final List<PathogenGroup> groups;

  PathogenType({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.groups,
  });

  factory PathogenType.fromJson(Map<String, dynamic> json) {
    return PathogenType(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '',
      groups: (json['groups'] as List<dynamic>?)
              ?.map((e) => PathogenGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'groups': groups.map((e) => e.toJson()).toList(),
    };
  }
}

// Pathogen group (e.g., "Foodborne & Waterborne")
class PathogenGroup {
  final String id;
  final String name;
  final String icon;
  final int pathogenCount;
  final String dataFile;

  PathogenGroup({
    required this.id,
    required this.name,
    required this.icon,
    required this.pathogenCount,
    required this.dataFile,
  });

  factory PathogenGroup.fromJson(Map<String, dynamic> json) {
    return PathogenGroup(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      pathogenCount: json['pathogenCount'] as int? ?? 0,
      dataFile: json['dataFile'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'pathogenCount': pathogenCount,
      'dataFile': dataFile,
    };
  }
}

// Group data (contains list of pathogens)
class GroupData {
  final int version;
  final String groupId;
  final String groupName;
  final String type;
  final String updatedAt;
  final List<PathogenDetail> pathogens;

  GroupData({
    required this.version,
    required this.groupId,
    required this.groupName,
    required this.type,
    required this.updatedAt,
    required this.pathogens,
  });

  factory GroupData.fromJson(Map<String, dynamic> json) {
    return GroupData(
      version: json['version'] as int? ?? 1,
      groupId: json['groupId'] as String? ?? '',
      groupName: json['groupName'] as String? ?? '',
      type: json['type'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      pathogens: (json['pathogens'] as List<dynamic>?)
              ?.map((e) => PathogenDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'groupId': groupId,
      'groupName': groupName,
      'type': type,
      'updatedAt': updatedAt,
      'pathogens': pathogens.map((e) => e.toJson()).toList(),
    };
  }
}

