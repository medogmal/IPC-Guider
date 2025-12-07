import 'models.dart';

class CalculationEngine {
  // Calculate result based on formula and inputs
  static double? calculate(CalculatorFormula formula, Map<String, double> inputValues) {
    try {
      switch (formula.id) {
        // HAI Surveillance formulas
        case 'clabsi_rate':
          return _calculateDeviceRate(
            inputValues['clabsi_cases'],
            inputValues['central_line_days'],
            1000,
          );
        
        case 'cauti_rate':
          return _calculateDeviceRate(
            inputValues['cauti_cases'],
            inputValues['urinary_catheter_days'],
            1000,
          );
        
        // Outbreak Management & Epidemiology formulas
        case 'odds_ratio':
          return _calculateOddsRatio(
            inputValues['exposed_cases'],
            inputValues['exposed_noncases'],
            inputValues['unexposed_cases'],
            inputValues['unexposed_noncases'],
          );

        case 'relative_risk':
          return _calculateRelativeRisk(
            inputValues['exposed_cases'],
            inputValues['exposed_noncases'],
            inputValues['unexposed_cases'],
            inputValues['unexposed_noncases'],
          );

        // Diagnostic validity formulas
        case 'sensitivity':
          return _calculateSensitivity(
            inputValues['true_positives'],
            inputValues['false_negatives'],
          );

        case 'specificity':
          return _calculateSpecificity(
            inputValues['true_negatives'],
            inputValues['false_positives'],
          );

        default:
          // Generic calculation for unknown formulas
          return _calculateGeneric(formula, inputValues);
      }
    } catch (e) {
      return null;
    }
  }

  // Device-associated infection rate calculation
  static double? _calculateDeviceRate(double? cases, double? deviceDays, int multiplier) {
    if (cases == null || deviceDays == null || deviceDays == 0) return null;
    return (cases / deviceDays) * multiplier;
  }

  // Odds Ratio calculation: OR = (A × D) ÷ (B × C)
  static double? _calculateOddsRatio(double? a, double? b, double? c, double? d) {
    if (a == null || b == null || c == null || d == null) return null;
    if (b == 0 || c == 0) return null; // Avoid division by zero
    return (a * d) / (b * c);
  }

  // Relative Risk calculation: RR = (A ÷ (A + B)) ÷ (C ÷ (C + D))
  static double? _calculateRelativeRisk(double? a, double? b, double? c, double? d) {
    if (a == null || b == null || c == null || d == null) return null;
    final exposedTotal = a + b;
    final unexposedTotal = c + d;
    if (exposedTotal == 0 || unexposedTotal == 0) return null;
    final exposedRate = a / exposedTotal;
    final unexposedRate = c / unexposedTotal;
    if (unexposedRate == 0) return null; // Avoid division by zero
    return exposedRate / unexposedRate;
  }

  // Sensitivity calculation
  static double? _calculateSensitivity(double? truePositives, double? falseNegatives) {
    if (truePositives == null || falseNegatives == null) return null;
    final total = truePositives + falseNegatives;
    if (total == 0) return null;
    return (truePositives / total) * 100;
  }

  // Specificity calculation
  static double? _calculateSpecificity(double? trueNegatives, double? falsePositives) {
    if (trueNegatives == null || falsePositives == null) return null;
    final total = trueNegatives + falsePositives;
    if (total == 0) return null;
    return (trueNegatives / total) * 100;
  }

  // Generic calculation for unknown formulas
  static double? _calculateGeneric(CalculatorFormula formula, Map<String, double> inputValues) {
    // For unknown formulas, try to infer calculation from inputs
    final values = inputValues.values.toList();
    if (values.isEmpty) return null;
    
    // Simple heuristics based on number of inputs
    if (values.length == 2) {
      // Assume it's a rate calculation
      if (values[1] != 0) {
        return (values[0] / values[1]) * 100;
      }
    }
    
    return null;
  }

  // Format result with appropriate decimal places
  static String formatResult(double? value, String unit) {
    if (value == null) return 'N/A';
    
    // Determine decimal places based on value magnitude
    String formatted;
    if (value >= 100) {
      formatted = value.toStringAsFixed(1);
    } else if (value >= 10) {
      formatted = value.toStringAsFixed(2);
    } else {
      formatted = value.toStringAsFixed(3);
    }
    
    return '$formatted $unit';
  }

  // Validate inputs before calculation
  static Map<String, String> validateInputs(CalculatorFormula formula, Map<String, String> inputTexts) {
    final Map<String, String> errors = {};
    
    for (final input in formula.inputs) {
      final text = inputTexts[input.key]?.trim() ?? '';
      
      if (text.isEmpty) {
        errors[input.key] = 'This field is required';
        continue;
      }
      
      final value = double.tryParse(text);
      if (value == null) {
        errors[input.key] = 'Please enter a valid number';
        continue;
      }
      
      if (value < 0) {
        errors[input.key] = 'Value cannot be negative';
        continue;
      }
      
      // Special validation for denominators (should not be zero)
      if (_isDenominator(input.key) && value == 0) {
        errors[input.key] = 'Value cannot be zero';
        continue;
      }
    }
    
    return errors;
  }

  // Check if input is likely a denominator
  static bool _isDenominator(String inputKey) {
    final denominatorKeywords = [
      'days', 'total', 'population', 'denominator',
      'catheter_days', 'line_days', 'device_days'
    ];
    
    final lowerKey = inputKey.toLowerCase();
    return denominatorKeywords.any((keyword) => lowerKey.contains(keyword));
  }

  // Parse input texts to double values
  static Map<String, double> parseInputs(Map<String, String> inputTexts) {
    final Map<String, double> values = {};

    for (final entry in inputTexts.entries) {
      final value = double.tryParse(entry.value.trim());
      if (value != null) {
        values[entry.key] = value;
      }
    }

    return values;
  }

  // Calculate computed totals for display (e.g., A+B for Relative Risk)
  static Map<String, double> calculateComputedTotals(CalculatorFormula formula, Map<String, double> inputValues) {
    final Map<String, double> totals = {};

    switch (formula.id) {
      case 'relative_risk':
        final a = inputValues['exposed_cases'];
        final b = inputValues['exposed_noncases'];
        final c = inputValues['unexposed_cases'];
        final d = inputValues['unexposed_noncases'];
        if (a != null && b != null) {
          totals['exposed_total'] = a + b;
        }
        if (c != null && d != null) {
          totals['unexposed_total'] = c + d;
        }
        break;
    }

    return totals;
  }
}
