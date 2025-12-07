import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/outbreak_group.dart';
import '../models/pathogen_detail.dart';

class OutbreakGroupRepository {
  static const String _indexPath = 'assets/data/outbreak_groups/index.v1.json';
  static const String _groupBasePath = 'assets/data/outbreak_groups/';

  // Load main index
  Future<OutbreakGroupsIndex> loadIndex() async {
    try {
      final String jsonString = await rootBundle.loadString(_indexPath);
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return OutbreakGroupsIndex.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load outbreak groups index: $e');
    }
  }

  // Load group data by file path
  Future<GroupData> loadGroupData(String dataFile) async {
    try {
      final String fullPath = '$_groupBasePath$dataFile';
      final String jsonString = await rootBundle.loadString(fullPath);
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return GroupData.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load group data from $dataFile: $e');
    }
  }

  // Search pathogens across all groups
  Future<List<PathogenSearchResult>> searchPathogens(String query) async {
    if (query.isEmpty) return [];

    try {
      final index = await loadIndex();
      final List<PathogenSearchResult> results = [];
      final lowerQuery = query.toLowerCase();

      for (final type in index.types) {
        for (final group in type.groups) {
          try {
            final groupData = await loadGroupData(group.dataFile);
            for (final pathogen in groupData.pathogens) {
              // Search in name, scientific name, and definition
              if (pathogen.name.toLowerCase().contains(lowerQuery) ||
                  pathogen.scientificName.toLowerCase().contains(lowerQuery) ||
                  pathogen.definition.toLowerCase().contains(lowerQuery)) {
                results.add(PathogenSearchResult(
                  pathogen: pathogen,
                  groupName: group.name,
                  typeName: type.name,
                  typeColor: type.color,
                ));
              }
            }
          } catch (e) {
            // Skip groups that fail to load
            continue;
          }
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search pathogens: $e');
    }
  }

  // Get pathogen by ID from a specific group
  Future<PathogenDetail?> getPathogenById(String groupDataFile, String pathogenId) async {
    try {
      final groupData = await loadGroupData(groupDataFile);
      return groupData.pathogens.firstWhere(
        (p) => p.id == pathogenId,
        orElse: () => throw Exception('Pathogen not found'),
      );
    } catch (e) {
      return null;
    }
  }
}

// Search result model
class PathogenSearchResult {
  final PathogenDetail pathogen;
  final String groupName;
  final String typeName;
  final String typeColor;

  PathogenSearchResult({
    required this.pathogen,
    required this.groupName,
    required this.typeName,
    required this.typeColor,
  });
}

