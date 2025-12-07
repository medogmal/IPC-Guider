import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/back_button.dart';
import '../data/calculator_providers.dart';
import '../domain/models.dart';
import '../domain/calculation_engine.dart';
import '../services/export_service.dart';
import '../presentation/state_preservation/calculator_state_manager.dart';

class CalculatorFormulaScreen extends ConsumerStatefulWidget {
  final String formulaId;

  const CalculatorFormulaScreen({
    super.key,
    required this.formulaId,
  });

  @override
  ConsumerState<CalculatorFormulaScreen> createState() => _CalculatorFormulaScreenState();
}

class _CalculatorFormulaScreenState extends ConsumerState<CalculatorFormulaScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _errors = {};
  double? _result;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    // State restoration will happen after the formula is loaded in build()
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _restoreState(CalculatorFormula formula) {
    final savedState = ref.getCalculatorState(widget.formulaId);
    if (savedState != null) {
      // Restore input values
      for (final input in formula.inputs) {
        final controller = _controllers[input.key] ??= TextEditingController();
        if (savedState.containsKey(input.key)) {
          controller.text = savedState[input.key].toString();
        }
      }

      // Restore result if available
      _result = savedState['result'] as double?;
    }
  }

  void _saveState(CalculatorFormula formula) {
    final Map<String, dynamic> state = {
      'result': _result,
    };

    for (final input in formula.inputs) {
      if (_controllers.containsKey(input.key)) {
        state[input.key] = _controllers[input.key]!.text;
      }
    }

    ref.saveCalculatorState(widget.formulaId, state);
  }

  @override
  Widget build(BuildContext context) {
    final formulaAsync = ref.watch(formulaByIdProvider(widget.formulaId));
    final domainAsync = ref.watch(domainByFormulaIdProvider(widget.formulaId));

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Calculator',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go('/calculator/history'),
            tooltip: 'History',
          ),
        ],
      ),
      body: formulaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error, null),
        data: (formula) {
          if (formula == null) {
            return _buildNotFoundState(null);
          }

          // Restore state after formula is loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _restoreState(formula);
          });

          return _buildFormulaContent(formula, domainAsync);
        },
      ),
    );
  }

  Widget _buildErrorState(Object error, CalculatorFormula? formula) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load formula',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (formula != null) {
                _saveState(formula);
              }
              context.pop();
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(CalculatorFormula? formula) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Formula not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (formula != null) {
                _saveState(formula);
              }
              context.pop();
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaContent(CalculatorFormula formula, AsyncValue<CalculatorDomain?> domainAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Name (official, human-readable)
          _buildSection(
            title: formula.name,
            child: const SizedBox.shrink(),
            isTitle: true,
          ),
          
          // 2. Formula notation (rendered)
          _buildSection(
            title: 'Formula',
            child: _buildFormulaNotation(formula),
          ),
          
          // 3. Medical Use / Indication
          _buildSection(
            title: 'Medical Use / Indication',
            child: Text(
              formula.purpose,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          
          // 4. Inputs (dynamic, match the math visually)
          _buildSection(
            title: 'Inputs',
            child: _buildInputsSection(formula),
          ),
          
          // 5. Calculate & Result + 6. Save & Export (same row)
          _buildCalculateSection(formula),
          
          // 7. Overview
          _buildSection(
            title: 'Overview',
            child: Text(
              formula.overview,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          
          // 8. Example
          _buildSection(
            title: 'Example',
            child: _buildExampleSection(formula),
          ),
          
          // 9. Benchmark & Interpretation
          _buildSection(
            title: 'Benchmark & Interpretation',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Benchmark:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(formula.benchmark),
                const SizedBox(height: 12),
                Text(
                  'Interpretation:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(formula.interpretation),
              ],
            ),
          ),
          
          // 10. Action
          _buildSection(
            title: 'Action',
            child: Text(
              formula.action,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          
          // 11. References
          _buildSection(
            title: 'References',
            child: _buildReferencesSection(formula),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    bool isTitle = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: isTitle
                ? Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
          ),
          if (!isTitle) ...[
            const SizedBox(height: 12),
            child,
          ],
        ],
      ),
    );
  }

  Widget _buildFormulaNotation(CalculatorFormula formula) {
    try {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Math.tex(
            formula.formula,
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      );
    } catch (e) {
      // Fallback to formatted text if LaTeX parsing fails
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            formula.formula.replaceAll('\\', '').replaceAll('{', '').replaceAll('}', ''),
            style: const TextStyle(fontSize: 18, fontFamily: 'monospace'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget _buildInputsSection(CalculatorFormula formula) {
    // Initialize controllers if not already done
    for (final input in formula.inputs) {
      _controllers[input.key] ??= TextEditingController();
    }

    // Determine layout based on formula type
    switch (formula.id) {
      case 'odds_ratio':
        return _buildOddsRatioLayout(formula);
      case 'relative_risk':
        return _buildRelativeRiskLayout(formula);
      default:
        if (formula.inputs.length == 4) {
          return _buildFourInputLayout(formula);
        } else {
          return _buildSimpleInputLayout(formula);
        }
    }
  }

  Widget _buildSimpleInputLayout(CalculatorFormula formula) {
    return Column(
      children: formula.inputs.map((input) => _buildInputField(input)).toList(),
    );
  }

  Widget _buildFourInputLayout(CalculatorFormula formula) {
    final inputs = formula.inputs;
    return Column(
      children: [
        // Top row: A × B
        Row(
          children: [
            Expanded(child: _buildInputField(inputs[0])),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text('×', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: _buildInputField(inputs[1])),
          ],
        ),
        
        // Fraction bar
        Container(
          height: 2,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        
        // Bottom row: C × D
        Row(
          children: [
            Expanded(child: _buildInputField(inputs[2])),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text('×', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: _buildInputField(inputs[3])),
          ],
        ),
      ],
    );
  }

  // Odds Ratio layout: (A × D) ÷ (B × C)
  Widget _buildOddsRatioLayout(CalculatorFormula formula) {
    final inputs = formula.inputs;
    return Column(
      children: [
        // Top row: A × D
        Row(
          children: [
            Expanded(child: _buildInputField(inputs[0])), // Exposed Cases (A)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text('×', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: _buildInputField(inputs[3])), // Unexposed Non-cases (D)
          ],
        ),

        // Fraction bar
        Container(
          height: 2,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),

        // Bottom row: B × C
        Row(
          children: [
            Expanded(child: _buildInputField(inputs[1])), // Exposed Non-cases (B)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text('×', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: _buildInputField(inputs[2])), // Unexposed Cases (C)
          ],
        ),
      ],
    );
  }

  // Relative Risk layout with computed totals
  Widget _buildRelativeRiskLayout(CalculatorFormula formula) {
    final inputs = formula.inputs;
    final inputValues = CalculationEngine.parseInputs(_getInputTexts());
    final computedTotals = CalculationEngine.calculateComputedTotals(formula, inputValues);

    return Column(
      children: [
        // Top row (numerator): A ÷ (A + B)
        Row(
          children: [
            Expanded(child: _buildInputField(inputs[0])), // Exposed Cases (A)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text('÷', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: _buildComputedField('Exposed Total (A + B)', computedTotals['exposed_total'])),
          ],
        ),

        // Fraction bar
        Container(
          height: 2,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),

        // Bottom row (denominator): C ÷ (C + D)
        Row(
          children: [
            Expanded(child: _buildInputField(inputs[2])), // Unexposed Cases (C)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text('÷', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: _buildComputedField('Unexposed Total (C + D)', computedTotals['unexposed_total'])),
          ],
        ),

        // Additional inputs for B and D
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildInputField(inputs[1])), // Exposed Non-cases (B)
            const SizedBox(width: 16),
            Expanded(child: _buildInputField(inputs[3])), // Unexposed Non-cases (D)
          ],
        ),
      ],
    );
  }

  Widget _buildComputedField(String label, double? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Component label above field
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),

          // Read-only computed field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Text(
              value != null ? value.toStringAsFixed(0) : '—',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getInputTexts() {
    final Map<String, String> inputTexts = {};
    for (final entry in _controllers.entries) {
      inputTexts[entry.key] = entry.value.text;
    }
    return inputTexts;
  }

  Widget _buildInputField(FormulaInput input) {
    final controller = _controllers[input.key]!;
    final error = _errors[input.key];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Component label above field
          Text(
            input.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),

          // Input field
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter ${input.label.toLowerCase()}',
              suffixText: input.unitHint,
              errorText: error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (_) => _clearErrors(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateSection(CalculatorFormula formula) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calculate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCalculating ? null : () => _calculate(formula),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isCalculating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Calculate', style: TextStyle(fontSize: 16)),
            ),
          ),

          // Result display
          if (_result != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Result:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CalculationEngine.formatResult(_result, formula.resultUnit),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),

            // Save & Export row
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveCalculation(formula),
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showExportOptions(formula),
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExampleSection(CalculatorFormula formula) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sample Calculation:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('Inputs: ${formula.example.values.entries.map((e) => '${e.key} = ${e.value}').join(', ')}'),
          const SizedBox(height: 4),
          Text('Calculation: ${formula.example.worked}'),
          const SizedBox(height: 4),
          Text(
            'Result: ${formula.example.result}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildReferencesSection(CalculatorFormula formula) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: formula.references.map((reference) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _launchUrl(reference.url),
            child: Text(
              reference.label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _clearErrors() {
    if (_errors.isNotEmpty) {
      setState(() {
        _errors.clear();
      });
    }
    // Refresh computed totals when inputs change
    setState(() {});
  }

  Future<void> _calculate(CalculatorFormula formula) async {
    setState(() {
      _isCalculating = true;
      _errors.clear();
    });

    // Get input texts
    final Map<String, String> inputTexts = {};
    for (final input in formula.inputs) {
      inputTexts[input.key] = _controllers[input.key]!.text;
    }

    // Validate inputs
    final errors = CalculationEngine.validateInputs(formula, inputTexts);
    if (errors.isNotEmpty) {
      setState(() {
        _errors.addAll(errors);
        _isCalculating = false;
      });
      return;
    }

    // Parse inputs and calculate
    final inputValues = CalculationEngine.parseInputs(inputTexts);
    final result = CalculationEngine.calculate(formula, inputValues);

    setState(() {
      _result = result;
      _isCalculating = false;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calculation failed. Please check your inputs.')),
      );
    }
  }

  Future<void> _saveCalculation(CalculatorFormula formula) async {
    if (_result == null) return;

    try {
      final domain = await ref.read(domainByFormulaIdProvider(widget.formulaId).future);
      if (domain == null) return;

      final inputValues = <String, dynamic>{};
      for (final input in formula.inputs) {
        final text = _controllers[input.key]!.text;
        final value = double.tryParse(text);
        if (value != null) {
          inputValues[input.label] = value; // Use label for export
        }
      }

      final calculation = CalculationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        domain: domain.title,
        formulaId: formula.id,
        formulaName: formula.name,
        inputs: inputValues,
        result: _result!,
        unit: formula.resultUnit,
      );

      await ref.read(historyOperationsProvider).saveCalculation(calculation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calculation saved to history')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  void _showExportOptions(CalculatorFormula formula) {
    if (_result == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export & Share',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ExportService.sharingCapabilityDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as CSV'),
              subtitle: const Text('Compatible with Excel, Google Sheets'),
              trailing: const Icon(Icons.share, size: 20),
              onTap: () {
                Navigator.pop(context);
                _exportCalculation(formula, 'CSV');
              },
            ),

            ListTile(
              leading: const Icon(Icons.file_present, color: Colors.blue),
              title: const Text('Export as XLSX'),
              subtitle: const Text('Native Excel format'),
              trailing: const Icon(Icons.share, size: 20),
              onTap: () {
                Navigator.pop(context);
                _exportCalculation(formula, 'XLSX');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCalculation(CalculatorFormula formula, String format) async {
    if (_result == null) return;

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text('Exporting $format...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      final domain = await ref.read(domainByFormulaIdProvider(widget.formulaId).future);
      if (domain == null) {
        _showExportError('Unable to determine calculator domain');
        return;
      }

      final inputValues = <String, dynamic>{};
      for (final input in formula.inputs) {
        final text = _controllers[input.key]!.text;
        final value = double.tryParse(text);
        if (value != null) {
          inputValues[input.label] = value; // Use label for export
        }
      }

      final calculation = CalculationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        domain: domain.title,
        formulaId: formula.id,
        formulaName: formula.name,
        inputs: inputValues,
        result: _result!,
        unit: formula.resultUnit,
      );

      final result = await ExportService.exportSingleCalculation(
        calculation: calculation,
        format: format,
        calculatorKey: formula.id,
      );

      if (mounted) {
        if (result.success) {
          String message;
          String? actionLabel;
          VoidCallback? actionCallback;

          if (result.filePath == 'web_share') {
            message = 'Shared successfully via ${result.format}';
          } else if (result.filePath == 'web_download') {
            message = 'Downloaded ${result.fileName} (${result.format})';
          } else {
            message = 'Exported and shared via ${result.format}';
            actionLabel = 'Share Again';
            actionCallback = () async {
              if (result.filePath != null) {
                try {
                  await ExportService.shareExportedFile(result.filePath!);
                } catch (e) {
                  _showExportError('Failed to share file');
                }
              }
            };
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              action: actionLabel != null && actionCallback != null
                  ? SnackBarAction(
                      label: actionLabel,
                      textColor: Colors.white,
                      onPressed: actionCallback,
                    )
                  : null,
            ),
          );
        } else {
          _showExportError(result.errorMessage ?? 'Export failed');
        }
      }
    } catch (e) {
      _showExportError('Export failed: ${e.toString()}');
    }
  }

  void _showExportError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _showExportOptions(
              ref.read(formulaByIdProvider(widget.formulaId)).value!,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
