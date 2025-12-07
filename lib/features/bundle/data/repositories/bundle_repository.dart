import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bundle.dart';
import '../models/bundle_category.dart';

/// Repository for managing IPC bundle data
/// Follows offline-first approach with JSON asset loading
class BundleRepository {
  static const String _bundleAsset = 'assets/data/bundles.json';

  // Singleton pattern
  static final BundleRepository _instance = BundleRepository._internal();
  factory BundleRepository() => _instance;
  BundleRepository._internal();

  // In-memory cache
  BundleData? _cachedData;

  /// Load all bundles from JSON asset
  Future<BundleData> loadBundleData() async {
    // Return cached data if available
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final String jsonString = await rootBundle.loadString(_bundleAsset);
      final Map<String, dynamic> json = jsonDecode(jsonString);
      _cachedData = BundleData.fromJson(json);
      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load bundle data: $e');
    }
  }

  /// Get all bundles
  Future<List<Bundle>> getAllBundles() async {
    final data = await loadBundleData();
    return data.bundles;
  }

  /// Get bundle by ID
  Future<Bundle?> getBundleById(String id) async {
    final bundles = await getAllBundles();
    try {
      return bundles.firstWhere((bundle) => bundle.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all available categories (excluding 'all')
  List<BundleCategory> getCategories() {
    return [
      BundleCategory.vap,
      BundleCategory.clabsi,
      BundleCategory.cauti,
      BundleCategory.ssi,
      BundleCategory.general,
    ];
  }

  /// Filter bundles by category
  Future<List<Bundle>> getBundlesByCategory(BundleCategory category) async {
    if (category == BundleCategory.all) {
      return getAllBundles();
    }

    final bundles = await getAllBundles();
    final categoryString = category.toJsonString();
    return bundles
        .where((bundle) =>
            bundle.category.toLowerCase() == categoryString.toLowerCase())
        .toList();
  }

  /// Search bundles by query (name, description, components)
  Future<List<Bundle>> searchBundles(String query) async {
    if (query.trim().isEmpty) {
      return getAllBundles();
    }

    final bundles = await getAllBundles();
    final lowerQuery = query.toLowerCase();

    return bundles.where((bundle) {
      // Search in name
      if (bundle.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in description
      if (bundle.description.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in category
      if (bundle.category.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in components
      for (final component in bundle.components) {
        if (component.toLowerCase().contains(lowerQuery)) {
          return true;
        }
      }

      // Search in key points
      for (final keyPoint in bundle.keyPoints) {
        if (keyPoint.toLowerCase().contains(lowerQuery)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  /// Search bundles with category filter
  Future<List<Bundle>> searchBundlesWithFilter({
    required String query,
    required BundleCategory category,
  }) async {
    // Get bundles by category first
    List<Bundle> bundles;
    if (category == BundleCategory.all) {
      bundles = await getAllBundles();
    } else {
      bundles = await getBundlesByCategory(category);
    }

    // If no search query, return filtered bundles
    if (query.trim().isEmpty) {
      return bundles;
    }

    // Apply search filter
    final lowerQuery = query.toLowerCase();
    return bundles.where((bundle) {
      return bundle.name.toLowerCase().contains(lowerQuery) ||
          bundle.description.toLowerCase().contains(lowerQuery) ||
          bundle.category.toLowerCase().contains(lowerQuery) ||
          bundle.components.any(
              (component) => component.toLowerCase().contains(lowerQuery)) ||
          bundle.keyPoints
              .any((keyPoint) => keyPoint.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get bundle count by category
  Future<Map<BundleCategory, int>> getBundleCountByCategory() async {
    final bundles = await getAllBundles();
    final Map<BundleCategory, int> counts = {};

    for (final category in BundleCategory.values) {
      if (category == BundleCategory.all) {
        counts[category] = bundles.length;
      } else {
        final categoryString = category.toJsonString();
        counts[category] = bundles
            .where((bundle) =>
                bundle.category.toLowerCase() == categoryString.toLowerCase())
            .length;
      }
    }

    return counts;
  }

  /// Clear cache (useful for testing or refresh)
  void clearCache() {
    _cachedData = null;
  }

  /// Get data version
  Future<int> getVersion() async {
    final data = await loadBundleData();
    return data.version;
  }

  /// Get last updated date
  Future<String> getLastUpdated() async {
    final data = await loadBundleData();
    return data.updatedAt;
  }
}

