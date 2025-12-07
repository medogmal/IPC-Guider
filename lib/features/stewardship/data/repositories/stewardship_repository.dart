import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/stewardship_section.dart';

/// Repository for managing Antimicrobial Stewardship data
/// Follows offline-first approach with JSON asset loading
class StewardshipRepository {
  static const String _asset = 'assets/data/antimicrobial_stewardship.v1.json';

  // Singleton pattern
  static final StewardshipRepository _instance =
      StewardshipRepository._internal();
  factory StewardshipRepository() => _instance;
  StewardshipRepository._internal();

  // In-memory cache
  StewardshipData? _cachedData;

  /// Load all antimicrobial stewardship data from JSON asset
  Future<StewardshipData> loadStewardshipData() async {
    // Return cached data if available
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final String jsonString = await rootBundle.loadString(_asset);
      final Map<String, dynamic> json = jsonDecode(jsonString);
      _cachedData = StewardshipData.fromJson(json);
      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load antimicrobial stewardship data: $e');
    }
  }

  /// Get all sections
  Future<List<StewardshipSection>> getAllSections() async {
    final data = await loadStewardshipData();
    return data.sections;
  }

  /// Get section by ID
  Future<StewardshipSection?> getSectionById(String id) async {
    final sections = await getAllSections();
    try {
      return sections.firstWhere((section) => section.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get page by ID (searches across all sections)
  Future<StewardshipPage?> getPageById(String pageId) async {
    final sections = await getAllSections();
    for (final section in sections) {
      try {
        return section.pages.firstWhere((page) => page.id == pageId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Search sections and pages by query
  Future<List<StewardshipSection>> searchSections(String query) async {
    if (query.trim().isEmpty) {
      return getAllSections();
    }

    final sections = await getAllSections();
    final lowerQuery = query.toLowerCase();

    // Filter sections and pages that match the query
    final filteredSections = <StewardshipSection>[];

    for (final section in sections) {
      // Check if section name or description matches
      final sectionMatches = section.name.toLowerCase().contains(lowerQuery) ||
          section.description.toLowerCase().contains(lowerQuery);

      // Check if any page matches
      final matchingPages = section.pages.where((page) {
        return page.name.toLowerCase().contains(lowerQuery) ||
            page.content.any((c) => c.toLowerCase().contains(lowerQuery)) ||
            page.keyPoints.any((k) => k.toLowerCase().contains(lowerQuery));
      }).toList();

      // Include section if it matches or has matching pages
      if (sectionMatches || matchingPages.isNotEmpty) {
        filteredSections.add(
          StewardshipSection(
            id: section.id,
            name: section.name,
            category: section.category,
            description: section.description,
            pages: matchingPages.isNotEmpty ? matchingPages : section.pages,
          ),
        );
      }
    }

    return filteredSections;
  }

  /// Filter sections by category
  Future<List<StewardshipSection>> getSectionsByCategory(
      String category) async {
    if (category.toLowerCase() == 'all') {
      return getAllSections();
    }

    final sections = await getAllSections();
    return sections
        .where((section) =>
            section.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get all unique categories
  Future<List<String>> getCategories() async {
    final sections = await getAllSections();
    final categories = sections.map((s) => s.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  /// Clear cache (useful for testing or forcing reload)
  void clearCache() {
    _cachedData = null;
  }
}

