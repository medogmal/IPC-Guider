import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models.dart';

class CalculatorRepository {
  static const String _calculatorAsset = 'assets/data/calculator/hai_surveillance.v1.json';
  static const String _historyBoxName = 'calc_history';

  // Singleton pattern
  static final CalculatorRepository _instance = CalculatorRepository._internal();
  factory CalculatorRepository() => _instance;
  CalculatorRepository._internal();

  Box? _historyBox;

  // Initialize Hive box for history
  Future<void> initialize() async {
    _historyBox = Hive.box(_historyBoxName);
  }

  // Load calculator data
  Future<CalculatorData> loadCalculatorData() async {
    try {
      final String jsonString = await rootBundle.loadString(_calculatorAsset);
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return CalculatorData.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load calculator data: $e');
    }
  }

  // Find formula by ID across all domains
  Future<CalculatorFormula?> findFormulaById(String id) async {
    final data = await loadCalculatorData();
    for (final domain in data.domains) {
      for (final formula in domain.formulas) {
        if (formula.id == id) {
          return formula;
        }
      }
    }
    return null;
  }

  // Find domain by formula ID
  Future<CalculatorDomain?> findDomainByFormulaId(String formulaId) async {
    final data = await loadCalculatorData();
    for (final domain in data.domains) {
      for (final formula in domain.formulas) {
        if (formula.id == formulaId) {
          return domain;
        }
      }
    }
    return null;
  }

  // History operations
  Future<void> saveCalculation(CalculationHistory calculation) async {
    await initialize();
    await _historyBox!.put(calculation.id, calculation.toJson());
  }

  Future<List<CalculationHistory>> getHistory() async {
    await initialize();
    final List<CalculationHistory> history = [];
    
    for (final entry in _historyBox!.values) {
      try {
        if (entry is Map) {
          final calculation = CalculationHistory.fromJson(Map<String, dynamic>.from(entry));
          history.add(calculation);
        }
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }
    
    // Sort by timestamp (newest first)
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return history;
  }

  Future<void> deleteCalculation(String id) async {
    await initialize();
    await _historyBox!.delete(id);
  }

  Future<void> updateCalculation(CalculationHistory calculation) async {
    await initialize();
    await _historyBox!.put(calculation.id, calculation.toJson());
  }

  Future<void> clearHistory() async {
    await initialize();
    await _historyBox!.clear();
  }

  // Search functionality
  Future<List<CalculatorFormula>> searchFormulas(String query) async {
    if (query.trim().isEmpty) return [];
    
    final data = await loadCalculatorData();
    final List<CalculatorFormula> results = [];
    final lowerQuery = query.toLowerCase();
    
    for (final domain in data.domains) {
      // Search in domain title
      if (domain.title.toLowerCase().contains(lowerQuery)) {
        results.addAll(domain.formulas);
        continue;
      }
      
      // Search in formula names and purposes
      for (final formula in domain.formulas) {
        if (formula.name.toLowerCase().contains(lowerQuery) ||
            formula.purpose.toLowerCase().contains(lowerQuery)) {
          results.add(formula);
        }
      }
    }
    
    return results;
  }
}
