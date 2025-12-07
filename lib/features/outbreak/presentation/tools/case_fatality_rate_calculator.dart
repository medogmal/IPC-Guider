import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../data/models/history_entry.dart';
import '../../data/providers/history_providers.dart';

class CaseFatalityRateCalculator extends ConsumerStatefulWidget {
  const CaseFatalityRateCalculator({super.key});

  @override
  ConsumerState<CaseFatalityRateCalculator> createState() => _CaseFatalityRateCalculatorState();
}

class _CaseFatalityRateCalculatorState extends ConsumerState<CaseFatalityRateCalculator> {
  final _deathsController = TextEditingController();
  final _totalInfectedController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double? _caseFatalityRate;
  double? _lowerCI;
  double? _upperCI;
  String? _interpretation;
  bool _isLoading = false;

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Proportion of infected individuals who die from the disease during an outbreak.',
    formula: '(Deaths among infected ÷ Total infected) × 100',
    example: '5 deaths among 50 infected patients → 10% CFR',
    interpretation: 'Measures outbreak severity and pathogen virulence.',
    whenUsed: 'Outbreak severity assessment and public health response planning.',
    references: [
      Reference(
        title: 'CDC "Principles of Epidemiology"',
        url: 'https://www.cdc.gov/eis/field-epi-manual/chapters/Describing-Epi-Data.html',
      ),
      Reference(
        title: 'WHO Outbreak Investigation',
        url: 'https://www.who.int/emergencies/outbreak-toolkit',
      ),
    ],
  );

  @override
  void dispose() {
    _deathsController.dispose();
    _totalInfectedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Case Fatality Rate',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textSecondary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.emergency_outlined,
                            color: AppColors.error,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Case Fatality Rate',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Outbreak severity and mortality analysis',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Formula Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Math.tex(
                          r'\text{Case Fatality Rate} = \frac{\text{Deaths among Infected}}{\text{Total Infected}} \times 100',
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Guide Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showQuickGuide,
                  icon: Icon(Icons.menu_book, color: AppColors.info, size: 20),
                  label: Text(
                    'Quick Guide',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.info, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Load Example Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loadExample,
                  icon: Icon(Icons.lightbulb_outline, color: AppColors.success, size: 20),
                  label: Text(
                    'Load Example',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.success, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Input Section
              Text(
                'Input Data',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Deaths Input
              TextFormField(
                controller: _deathsController,
                decoration: InputDecoration(
                  labelText: 'Deaths among Infected',
                  hintText: 'Number of deaths',
                  prefixIcon: Icon(Icons.dangerous_outlined, color: AppColors.error),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of deaths';
                  }
                  final deaths = int.tryParse(value);
                  if (deaths == null || deaths < 0) {
                    return 'Please enter a valid number (0 or more)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Total Infected Input
              TextFormField(
                controller: _totalInfectedController,
                decoration: InputDecoration(
                  labelText: 'Total Infected',
                  hintText: 'Total number of infected cases',
                  prefixIcon: Icon(Icons.coronavirus_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total infected cases';
                  }
                  final infected = int.tryParse(value);
                  if (infected == null || infected < 1) {
                    return 'Please enter a valid number (1 or more)';
                  }
                  // Validate that deaths <= total infected
                  final deaths = int.tryParse(_deathsController.text);
                  if (deaths != null && infected < deaths) {
                    return 'Total infected must be ≥ deaths';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Calculate Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Calculate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Results Section
              if (_caseFatalityRate != null) ...[
                _buildResultsCard(),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate calculation delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      final deaths = int.parse(_deathsController.text);
      final totalInfected = int.parse(_totalInfectedController.text);

      // Calculate case fatality rate
      final caseFatalityRate = (deaths / totalInfected) * 100;

      // Calculate 95% confidence interval
      final p = caseFatalityRate / 100;
      final se = sqrt((p * (1 - p)) / totalInfected);
      final margin = 1.96 * se * 100;

      final lowerCI = max(0.0, caseFatalityRate - margin);
      final upperCI = min(100.0, caseFatalityRate + margin);

      // Generate interpretation
      String interpretation;
      if (caseFatalityRate < 1) {
        interpretation = 'Very low severity - Mild disease with excellent prognosis';
      } else if (caseFatalityRate < 5) {
        interpretation = 'Low severity - Most cases recover with appropriate care';
      } else if (caseFatalityRate < 15) {
        interpretation = 'Moderate severity - Significant mortality, enhanced clinical management needed';
      } else if (caseFatalityRate < 30) {
        interpretation = 'High severity - Serious disease with substantial mortality risk';
      } else {
        interpretation = 'Very high severity - Extremely dangerous pathogen, urgent public health response required';
      }

      setState(() {
        _caseFatalityRate = caseFatalityRate;
        _lowerCI = lowerCI;
        _upperCI = upperCI;
        _interpretation = interpretation;
        _isLoading = false;
      });
    });
  }

  Widget _buildResultsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Results',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Result
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _caseFatalityRate! < 5
                  ? AppColors.success.withValues(alpha: 0.1)
                  : _caseFatalityRate! < 15
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _caseFatalityRate! < 5
                    ? AppColors.success.withValues(alpha: 0.3)
                    : _caseFatalityRate! < 15
                        ? AppColors.warning.withValues(alpha: 0.3)
                        : AppColors.error.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Case Fatality Rate',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_caseFatalityRate!.toStringAsFixed(2)}%',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: _caseFatalityRate! < 5
                        ? AppColors.success
                        : _caseFatalityRate! < 15
                            ? AppColors.warning
                            : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Confidence Interval
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '95% Confidence Interval',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_lowerCI!.toStringAsFixed(2)}% - ${_upperCI!.toStringAsFixed(2)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Interpretation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Interpretation',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _interpretation!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Input Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.neutralLighter,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Input Summary',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInputRow('Deaths among Infected', _deathsController.text),
                const SizedBox(height: 8),
                _buildInputRow('Total Infected', _totalInfectedController.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _saveToHistory,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showExportOptions,
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _clearForm,
          icon: const Icon(Icons.refresh),
          label: const Text('Clear'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: BorderSide(color: AppColors.textSecondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Future<void> _saveToHistory() async {
    if (_caseFatalityRate == null) return;

    try {
      // Create unified history entry
      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Case Fatality Rate Calculator',
        inputs: {
          'Deaths among Infected': _deathsController.text,
          'Total Infected': _totalInfectedController.text,
        },
        result: '${_caseFatalityRate!.toStringAsFixed(2)}% (95% CI: ${_lowerCI!.toStringAsFixed(2)}% - ${_upperCI!.toStringAsFixed(2)}%)',
        notes: _interpretation ?? '',
        tags: ['epidemiology', 'case-fatality-rate', 'mortality'],
      );

      // Save to unified history
      await ref.read(historyServiceProvider).addEntry(historyEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Saved to history successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportModal(
        onExportPDF: _exportAsPDF,
        onExportExcel: _exportAsExcel,
        onExportCSV: _exportAsCSV,
        onExportText: _exportAsText,
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    if (_caseFatalityRate == null) return;

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Case Fatality Rate Calculator',
      formula: '(Deaths among Infected × 100) / Total Infected',
      inputs: {
        'Deaths among Infected': _deathsController.text,
        'Total Infected': _totalInfectedController.text,
      },
      results: {
        'Case Fatality Rate': '${_caseFatalityRate!.toStringAsFixed(2)}%',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(2)}% - ${_upperCI!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': 'Disease-specific',
        'unit': 'case fatality rate',
        'source': 'WHO/CDC Disease-Specific Guidelines',
        'status': 'Interpretation: ${_caseFatalityRate! < 1 ? "Low" : _caseFatalityRate! < 10 ? "Moderate" : "High"} severity',
      },
      interpretation: _interpretation,
      references: [
        'CDC "Principles of Epidemiology"',
        'https://www.cdc.gov/eis/field-epi-manual/chapters/Describing-Epi-Data.html',
        'WHO Outbreak Investigation',
        'https://www.who.int/emergencies/outbreak-toolkit',
      ],
    );
  }

  Future<void> _exportAsExcel() async {
    if (_caseFatalityRate == null) return;

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Case Fatality Rate Calculator',
      formula: '(Deaths among Infected × 100) / Total Infected',
      inputs: {
        'Deaths among Infected': _deathsController.text,
        'Total Infected': _totalInfectedController.text,
      },
      results: {
        'Case Fatality Rate': '${_caseFatalityRate!.toStringAsFixed(2)}%',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(2)}% - ${_upperCI!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': 'Disease-specific',
        'unit': 'case fatality rate',
        'source': 'WHO/CDC Disease-Specific Guidelines',
        'status': 'Interpretation: ${_caseFatalityRate! < 1 ? "Low" : _caseFatalityRate! < 10 ? "Moderate" : "High"} severity',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    if (_caseFatalityRate == null) return;

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Case Fatality Rate Calculator',
      formula: '(Deaths among Infected × 100) / Total Infected',
      inputs: {
        'Deaths among Infected': _deathsController.text,
        'Total Infected': _totalInfectedController.text,
      },
      results: {
        'Case Fatality Rate': '${_caseFatalityRate!.toStringAsFixed(2)}%',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(2)}% - ${_upperCI!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': 'Disease-specific',
        'unit': 'case fatality rate',
        'source': 'WHO/CDC Disease-Specific Guidelines',
        'status': 'Interpretation: ${_caseFatalityRate! < 1 ? "Low" : _caseFatalityRate! < 10 ? "Moderate" : "High"} severity',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    if (_caseFatalityRate == null) return;

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Case Fatality Rate Calculator',
      formula: '(Deaths among Infected × 100) / Total Infected',
      inputs: {
        'Deaths among Infected': _deathsController.text,
        'Total Infected': _totalInfectedController.text,
      },
      results: {
        'Case Fatality Rate': '${_caseFatalityRate!.toStringAsFixed(2)}%',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(2)}% - ${_upperCI!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': 'Disease-specific',
        'unit': 'case fatality rate',
        'source': 'WHO/CDC Disease-Specific Guidelines',
        'status': 'Interpretation: ${_caseFatalityRate! < 1 ? "Low" : _caseFatalityRate! < 10 ? "Moderate" : "High"} severity',
      },
      interpretation: _interpretation,
      references: [
        'CDC Outbreak Investigation',
        'https://www.cdc.gov/eis/field-epi-manual/chapters/Outbreak-Investigation.html',
        'WHO Outbreak Toolkit',
        'https://www.who.int/emergencies/outbreak-toolkit',
      ],
    );
  }

  void _clearForm() {
    setState(() {
      _deathsController.clear();
      _totalInfectedController.clear();
      _caseFatalityRate = null;
      _lowerCI = null;
      _upperCI = null;
      _interpretation = null;
    });
  }

  void _loadExample() {
    setState(() {
      _deathsController.text = '12';
      _totalInfectedController.text = '150';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded: 12 deaths among 150 infected cases'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showQuickGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Quick Guide',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: KnowledgePanelWidget(data: _knowledgePanelData),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
