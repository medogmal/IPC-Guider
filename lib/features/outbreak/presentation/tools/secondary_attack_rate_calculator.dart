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

class SecondaryAttackRateCalculator extends ConsumerStatefulWidget {
  const SecondaryAttackRateCalculator({super.key});

  @override
  ConsumerState<SecondaryAttackRateCalculator> createState() => _SecondaryAttackRateCalculatorState();
}

class _SecondaryAttackRateCalculatorState extends ConsumerState<SecondaryAttackRateCalculator> {
  final _secondaryCasesController = TextEditingController();
  final _exposedContactsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double? _secondaryAttackRate;
  double? _lowerCI;
  double? _upperCI;
  String? _interpretation;
  bool _isLoading = false;

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Proportion of exposed contacts who develop disease after exposure to a primary case.',
    formula: '(Secondary cases ÷ Exposed contacts) × 100',
    example: '8 secondary cases among 40 exposed contacts → 20%',
    interpretation: 'Measures transmission efficiency and infectiousness of the pathogen.',
    whenUsed: 'Contact tracing and transmission analysis during outbreak investigation.',
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
    _secondaryCasesController.dispose();
    _exposedContactsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Secondary Attack Rate',
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
              _buildHeaderCard(),
              const SizedBox(height: 16),

              // Formula Card
              _buildFormulaCard(),
              const SizedBox(height: 16),

              // Quick Guide Button
              _buildQuickGuideButton(),
              const SizedBox(height: 16),

              // Load Example Button
              _buildLoadExampleButton(),
              const SizedBox(height: 16),

              // Input Card
              _buildInputCard(),

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
              if (_secondaryAttackRate != null) ...[
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

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.people_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secondary Attack Rate',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transmission analysis among exposed contacts',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
              Icon(Icons.calculate_outlined, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Formula',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double fontSize = 16.0;
                  if (constraints.maxWidth < 300) {
                    fontSize = 12.0;
                  } else if (constraints.maxWidth < 400) {
                    fontSize = 14.0;
                  }

                  return Math.tex(
                    r'\text{Secondary Attack Rate} = \frac{\text{Secondary Cases}}{\text{Exposed Contacts}} \times 100',
                    textStyle: TextStyle(fontSize: fontSize),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickGuideButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showQuickGuide(context),
        icon: Icon(Icons.menu_book, color: AppColors.info, size: 20),
        label: Text(
          'Quick Guide',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.info,
            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildLoadExampleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loadExample,
        icon: Icon(Icons.lightbulb_outline, color: AppColors.success, size: 20),
        label: Text(
          'Load Example',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.success,
            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildInputCard() {
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
              Icon(Icons.input, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Input Parameters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _secondaryCasesController,
            decoration: InputDecoration(
              labelText: 'Secondary Cases',
              hintText: 'Number of secondary cases',
              prefixIcon: Icon(Icons.person_add_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter number of secondary cases';
              }
              final cases = int.tryParse(value);
              if (cases == null || cases < 0) {
                return 'Please enter a valid number (0 or more)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _exposedContactsController,
            decoration: InputDecoration(
              labelText: 'Exposed Contacts',
              hintText: 'Total number of exposed contacts',
              prefixIcon: Icon(Icons.groups_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter number of exposed contacts';
              }
              final contacts = int.tryParse(value);
              if (contacts == null || contacts < 1) {
                return 'Please enter a valid number (1 or more)';
              }
              // Validate that secondary cases <= exposed contacts
              final secondaryCases = int.tryParse(_secondaryCasesController.text);
              if (secondaryCases != null && contacts < secondaryCases) {
                return 'Exposed contacts must be ≥ secondary cases';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _showQuickGuide(BuildContext context) {
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
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Guide',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: KnowledgePanelWidget(data: _knowledgePanelData),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadExample() {
    setState(() {
      _secondaryCasesController.text = '8';
      _exposedContactsController.text = '50';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example data loaded successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
      final secondaryCases = int.parse(_secondaryCasesController.text);
      final exposedContacts = int.parse(_exposedContactsController.text);

      // Calculate secondary attack rate
      final secondaryAttackRate = (secondaryCases / exposedContacts) * 100;

      // Calculate 95% confidence interval
      final p = secondaryAttackRate / 100;
      final se = sqrt((p * (1 - p)) / exposedContacts);
      final margin = 1.96 * se * 100;

      final lowerCI = max(0.0, secondaryAttackRate - margin);
      final upperCI = min(100.0, secondaryAttackRate + margin);

      // Generate interpretation
      String interpretation;
      if (secondaryAttackRate < 5) {
        interpretation = 'Low transmission efficiency - Limited person-to-person spread';
      } else if (secondaryAttackRate < 15) {
        interpretation = 'Moderate transmission - Enhanced infection control measures recommended';
      } else if (secondaryAttackRate < 30) {
        interpretation = 'High transmission efficiency - Aggressive contact tracing and isolation required';
      } else {
        interpretation = 'Very high transmission - Highly contagious pathogen, immediate outbreak response needed';
      }

      setState(() {
        _secondaryAttackRate = secondaryAttackRate;
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Secondary Attack Rate',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_secondaryAttackRate!.toStringAsFixed(2)}%',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
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
                _buildInputRow('Secondary Cases', _secondaryCasesController.text),
                const SizedBox(height: 8),
                _buildInputRow('Exposed Contacts', _exposedContactsController.text),
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
    if (_secondaryAttackRate == null) return;

    try {
      // Create unified history entry
      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Secondary Attack Rate Calculator',
        inputs: {
          'Secondary Cases': _secondaryCasesController.text,
          'Exposed Contacts': _exposedContactsController.text,
        },
        result: '${_secondaryAttackRate!.toStringAsFixed(2)}% (95% CI: ${_lowerCI!.toStringAsFixed(2)}% - ${_upperCI!.toStringAsFixed(2)}%)',
        notes: _interpretation ?? '',
        tags: ['epidemiology', 'secondary-attack-rate', 'transmission'],
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
    if (_secondaryAttackRate == null) return;

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Secondary Attack Rate Calculator',
      formula: '(Secondary Cases × 100) / Exposed Contacts',
      inputs: {
        'Secondary Cases': _secondaryCasesController.text,
        'Exposed Contacts': _exposedContactsController.text,
      },
      results: {
        'Secondary Attack Rate': '${_secondaryAttackRate!.toStringAsFixed(2)}%',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(2)}% - ${_upperCI!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': 'Pathogen-specific',
        'unit': 'secondary attack rate',
        'source': 'CDC/WHO Outbreak Guidelines',
        'status': 'Interpretation: ${_secondaryAttackRate! < 5 ? "Low" : _secondaryAttackRate! < 20 ? "Moderate" : "High"} transmissibility',
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
    if (_secondaryAttackRate == null) return;

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Secondary Attack Rate Calculator',
      formula: '(Secondary Cases × 100) / Exposed Contacts',
      inputs: {
        'Secondary Cases': _secondaryCasesController.text,
        'Exposed Contacts': _exposedContactsController.text,
      },
      results: {
        'Secondary Attack Rate': '${_secondaryAttackRate!.toStringAsFixed(2)}%',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(2)}% - ${_upperCI!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': 'Pathogen-specific',
        'unit': 'secondary attack rate',
        'source': 'CDC/WHO Outbreak Guidelines',
        'status': 'Interpretation: ${_secondaryAttackRate! < 5 ? "Low" : _secondaryAttackRate! < 20 ? "Moderate" : "High"} transmissibility',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    if (_secondaryAttackRate == null) return;

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Secondary Attack Rate Calculator',
      formula: '(Secondary Cases × 100) / Exposed Contacts',
      inputs: {
        'Secondary Cases': _secondaryCasesController.text,
        'Exposed Contacts': _exposedContactsController.text,
      },
      results: {
        'Secondary Attack Rate': '${_secondaryAttackRate!.toStringAsFixed(2)}%',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(2)}% - ${_upperCI!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': 'Pathogen-specific',
        'unit': 'secondary attack rate',
        'source': 'CDC/WHO Outbreak Guidelines',
        'status': 'Interpretation: ${_secondaryAttackRate! < 5 ? "Low" : _secondaryAttackRate! < 20 ? "Moderate" : "High"} transmissibility',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    if (_secondaryAttackRate == null) return;

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Secondary Attack Rate Calculator',
      formula: '(Secondary Cases × 100) / Exposed Contacts',
      inputs: {
        'Secondary Cases': _secondaryCasesController.text,
        'Exposed Contacts': _exposedContactsController.text,
      },
      results: {
        'Secondary Attack Rate': '${_secondaryAttackRate!.toStringAsFixed(2)}%',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(2)}% - ${_upperCI!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': 'Pathogen-specific',
        'unit': 'secondary attack rate',
        'source': 'CDC/WHO Outbreak Guidelines',
        'status': 'Interpretation: ${_secondaryAttackRate! < 5 ? "Low" : _secondaryAttackRate! < 20 ? "Moderate" : "High"} transmissibility',
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
      _secondaryCasesController.clear();
      _exposedContactsController.clear();
      _secondaryAttackRate = null;
      _lowerCI = null;
      _upperCI = null;
      _interpretation = null;
    });
  }
}
