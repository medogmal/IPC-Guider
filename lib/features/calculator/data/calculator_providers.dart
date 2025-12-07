import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models.dart';
import 'calculator_repository.dart';

// Repository provider
final calculatorRepositoryProvider = Provider<CalculatorRepository>((ref) {
  return CalculatorRepository();
});

// Calculator data provider
final calculatorDataProvider = FutureProvider<CalculatorData>((ref) async {
  final repository = ref.read(calculatorRepositoryProvider);
  return repository.loadCalculatorData();
});

// Formula by ID provider
final formulaByIdProvider = FutureProvider.family<CalculatorFormula?, String>((ref, id) async {
  final repository = ref.read(calculatorRepositoryProvider);
  return repository.findFormulaById(id);
});

// Domain by formula ID provider
final domainByFormulaIdProvider = FutureProvider.family<CalculatorDomain?, String>((ref, formulaId) async {
  final repository = ref.read(calculatorRepositoryProvider);
  return repository.findDomainByFormulaId(formulaId);
});

// History provider
final historyProvider = FutureProvider<List<CalculationHistory>>((ref) async {
  final repository = ref.read(calculatorRepositoryProvider);
  return repository.getHistory();
});

// Search provider
final searchProvider = FutureProvider.family<List<CalculatorFormula>, String>((ref, query) async {
  final repository = ref.read(calculatorRepositoryProvider);
  return repository.searchFormulas(query);
});

// Search query state provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected history items provider (for multi-select)
final selectedHistoryProvider = StateProvider<Set<String>>((ref) => {});

// History operations provider
final historyOperationsProvider = Provider<HistoryOperations>((ref) {
  final repository = ref.read(calculatorRepositoryProvider);
  return HistoryOperations(repository, ref);
});

class HistoryOperations {
  final CalculatorRepository _repository;
  final Ref _ref;

  HistoryOperations(this._repository, this._ref);

  Future<void> saveCalculation(CalculationHistory calculation) async {
    await _repository.saveCalculation(calculation);
    _ref.invalidate(historyProvider);
  }

  Future<void> deleteCalculation(String id) async {
    await _repository.deleteCalculation(id);
    _ref.invalidate(historyProvider);
  }

  Future<void> updateCalculation(CalculationHistory calculation) async {
    await _repository.updateCalculation(calculation);
    _ref.invalidate(historyProvider);
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    _ref.invalidate(historyProvider);
  }

  Future<void> deleteSelected(Set<String> selectedIds) async {
    for (final id in selectedIds) {
      await _repository.deleteCalculation(id);
    }
    _ref.invalidate(historyProvider);
    _ref.read(selectedHistoryProvider.notifier).state = {};
  }
}
