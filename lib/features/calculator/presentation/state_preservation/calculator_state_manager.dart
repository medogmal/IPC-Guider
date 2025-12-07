import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing calculator state preservation
class CalculatorStateNotifier extends StateNotifier<Map<String, dynamic>> {
  CalculatorStateNotifier() : super({});

  /// Save state for a specific calculator
  void saveState(String calculatorId, Map<String, dynamic> state) {
    state = {
      ...state,
      calculatorId: Map<String, dynamic>.from(state),
    };
  }

  /// Get state for a specific calculator
  Map<String, dynamic>? getState(String calculatorId) {
    return state[calculatorId] as Map<String, dynamic>?;
  }

  /// Clear state for a specific calculator
  void clearState(String calculatorId) {
    final newState = Map<String, dynamic>.from(state);
    newState.remove(calculatorId);
    state = newState;
  }

  /// Clear all saved states
  void clearAllStates() {
    state = {};
  }
}

/// Provider for accessing the calculator state notifier
final calculatorStateProvider = StateNotifierProvider<CalculatorStateNotifier, Map<String, dynamic>>(
  (ref) => CalculatorStateNotifier(),
);

/// Extension for easier access to calculator state
extension CalculatorStateExtension on WidgetRef {
  Map<String, dynamic>? getCalculatorState(String calculatorId) {
    return read(calculatorStateProvider.notifier).getState(calculatorId);
  }

  void saveCalculatorState(String calculatorId, Map<String, dynamic> state) {
    read(calculatorStateProvider.notifier).saveState(calculatorId, state);
  }

  void clearCalculatorState(String calculatorId) {
    read(calculatorStateProvider.notifier).clearState(calculatorId);
  }
}
