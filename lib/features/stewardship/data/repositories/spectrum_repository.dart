import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/antibiotic_spectrum.dart';

/// Repository for loading and managing antibiotic spectrum data
class SpectrumRepository {
  static final SpectrumRepository _instance = SpectrumRepository._internal();
  factory SpectrumRepository() => _instance;
  SpectrumRepository._internal();

  SpectrumData? _cachedData;
  bool _isLoading = false;

  /// Load spectrum data from JSON file
  Future<SpectrumData> loadSpectrumData() async {
    // Return cached data if available
    if (_cachedData != null) {
      return _cachedData!;
    }

    // Prevent multiple simultaneous loads
    if (_isLoading) {
      // Wait for the current load to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_cachedData != null) {
        return _cachedData!;
      }
    }

    _isLoading = true;

    try {
      // Load JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/stewardship/antibiotic_spectrum_data.json',
      );

      // Parse JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Create SpectrumData object
      _cachedData = SpectrumData.fromJson(jsonData);

      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load spectrum data: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Get all organisms
  Future<List<Organism>> getOrganisms() async {
    final data = await loadSpectrumData();
    return data.organisms;
  }

  /// Get organisms by category
  Future<List<Organism>> getOrganismsByCategory(OrganismCategory category) async {
    final data = await loadSpectrumData();
    return data.getOrganismsByCategory(category);
  }

  /// Get all antibiotics
  Future<List<AntibioticSpectrum>> getAntibiotics() async {
    final data = await loadSpectrumData();
    return data.antibiotics;
  }

  /// Get antibiotics by spectrum breadth
  Future<List<AntibioticSpectrum>> getAntibioticsByBreadth(SpectrumBreadth breadth) async {
    final data = await loadSpectrumData();
    return data.getAntibioticsByBreadth(breadth);
  }

  /// Get antibiotics by class
  Future<List<AntibioticSpectrum>> getAntibioticsByClass(String antibioticClass) async {
    final data = await loadSpectrumData();
    return data.getAntibioticsByClass(antibioticClass);
  }

  /// Get antibiotic by ID
  Future<AntibioticSpectrum?> getAntibioticById(String id) async {
    final data = await loadSpectrumData();
    try {
      return data.antibiotics.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get organism by ID
  Future<Organism?> getOrganismById(String id) async {
    final data = await loadSpectrumData();
    try {
      return data.organisms.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search antibiotics by name
  Future<List<AntibioticSpectrum>> searchAntibiotics(String query) async {
    if (query.isEmpty) {
      return getAntibiotics();
    }

    final data = await loadSpectrumData();
    final lowerQuery = query.toLowerCase();

    return data.antibiotics.where((antibiotic) {
      return antibiotic.name.toLowerCase().contains(lowerQuery) ||
          antibiotic.genericName.toLowerCase().contains(lowerQuery) ||
          antibiotic.antibioticClass.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get all unique antibiotic classes
  Future<List<String>> getAntibioticClasses() async {
    final data = await loadSpectrumData();
    final classes = data.antibiotics.map((a) => a.antibioticClass).toSet().toList();
    classes.sort();
    return classes;
  }

  /// Clear cached data (for testing or refresh)
  void clearCache() {
    _cachedData = null;
  }
}

