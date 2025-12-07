import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:math';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../data/models/history_entry.dart';
import '../../data/providers/history_providers.dart';

class RelativeRiskCalculator extends ConsumerStatefulWidget {
  const RelativeRiskCalculator({super.key});

  @override
  ConsumerState<RelativeRiskCalculator> createState() => _RelativeRiskCalculatorState();
}

class _RelativeRiskCalculatorState extends ConsumerState<RelativeRiskCalculator> {
  final _aController = TextEditingController(); // Exposed Cases
  final _bController = TextEditingController(); // Exposed Non-cases
  final _cController = TextEditingController(); // Non-exposed Cases
  final _dController = TextEditingController(); // Non-exposed Non-cases
  final _formKey = GlobalKey<FormState>();

  double? _relativeRisk;
  double? _lowerCI;
  double? _upperCI;
  String? _interpretation;
  bool _isLoading = false;

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Compares risk between exposed and unexposed groups.',
    formula: 'RR = [A/(A+B)] ÷ [C/(C+D)]',
    example: '30/50 exposed vs 10/100 unexposed → RR = 6',
    interpretation: 'RR > 1 = exposure increases risk.',
    whenUsed: 'Step 8–9 (analytic phase, hypothesis testing).',
    references: [
      Reference(
        title: 'CDC Outbreak Investigation Guidelines',
        url: 'https://www.cdc.gov/eis/field-epi-manual/chapters/Outbreak-Investigation.html',
      ),
      Reference(
        title: 'WHO Outbreak Investigation Toolkit',
        url: 'https://www.who.int/emergencies/outbreak-toolkit/disease-outbreak-toolboxes',
      ),
      Reference(
        title: 'APIC Outbreak Investigation Guide',
        url: 'https://apic.org/Resource_/TinyMceFileManager/Advocacy-PDFs/APIC_Outbreak_Investigation_Guide.pdf',
      ),
    ],
  );

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    _dController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Relative Risk Calculator',
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
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.compare_arrows_outlined,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Relative Risk Calculator',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Calculate relative risk from 2×2 contingency tables with confidence intervals',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Formula Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                    Text(
                      'Formula',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Mathematical formula using flutter_math_fork
                          Center(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double fontSize = 16.0;
                                if (constraints.maxWidth < 300) {
                                  fontSize = 12.0;
                                } else if (constraints.maxWidth < 400) {
                                  fontSize = 14.0;
                                }

                                return Math.tex(
                                  r'\text{RR} = \frac{a/(a+b)}{c/(c+d)}',
                                  textStyle: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Risk in Exposed ÷ Risk in Non-exposed',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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

              // 2x2 Contingency Table
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
                    Text(
                      '2×2 Contingency Table',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Table Header
                    Table(
                      border: TableBorder.all(
                        color: AppColors.textTertiary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1.5),
                        2: FlexColumnWidth(1.5),
                      },
                      children: [
                        // Header Row
                        TableRow(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                          children: [
                            _buildTableHeaderCell(''),
                            _buildTableHeaderCell('Disease +'),
                            _buildTableHeaderCell('Disease -'),
                          ],
                        ),
                        // Exposed Row
                        TableRow(
                          children: [
                            _buildTableHeaderCell('Exposed'),
                            _buildTableInputCell(_aController, 'a'),
                            _buildTableInputCell(_bController, 'b'),
                          ],
                        ),
                        // Non-exposed Row
                        TableRow(
                          children: [
                            _buildTableHeaderCell('Non-exposed'),
                            _buildTableInputCell(_cController, 'c'),
                            _buildTableInputCell(_dController, 'd'),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Legend
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Legend:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'a = Exposed with disease\nb = Exposed without disease\nc = Non-exposed with disease\nd = Non-exposed without disease',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _calculateRelativeRisk,
                      icon: _isLoading 
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.calculate, size: 18),
                      label: Text(_isLoading ? 'Calculating...' : 'Calculate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              if (_relativeRisk != null) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
              ],

              const SizedBox(height: 24),

              // References
              _buildReferences(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableInputCell(TextEditingController controller, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          final num = int.tryParse(value);
          if (num == null || num < 0) {
            return 'Invalid';
          }
          return null;
        },
      ),
    );
  }

  void _calculateRelativeRisk() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate calculation delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      final a = int.parse(_aController.text);
      final b = int.parse(_bController.text);
      final c = int.parse(_cController.text);
      final d = int.parse(_dController.text);

      // Check for division by zero
      if ((a + b) == 0 || (c + d) == 0) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cannot calculate: Division by zero'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Calculate relative risk
      final riskExposed = a / (a + b);
      final riskNonExposed = c / (c + d);
      
      if (riskNonExposed == 0) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cannot calculate: Risk in non-exposed group is zero'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final relativeRisk = riskExposed / riskNonExposed;

      // Calculate 95% confidence interval
      final lnRR = log(relativeRisk);
      final seLnRR = sqrt((1/a) - (1/(a+b)) + (1/c) - (1/(c+d)));
      final lowerCI = exp(lnRR - 1.96 * seLnRR);
      final upperCI = exp(lnRR + 1.96 * seLnRR);

      // Generate interpretation
      String interpretation;
      if (relativeRisk < 0.8) {
        interpretation = 'Protective effect - exposure reduces risk';
      } else if (relativeRisk < 1.2) {
        interpretation = 'No significant association';
      } else if (relativeRisk < 2.0) {
        interpretation = 'Moderate increased risk';
      } else if (relativeRisk < 5.0) {
        interpretation = 'High increased risk';
      } else {
        interpretation = 'Very high increased risk';
      }

      setState(() {
        _relativeRisk = relativeRisk;
        _lowerCI = lowerCI;
        _upperCI = upperCI;
        _interpretation = interpretation;
        _isLoading = false;
      });
    });
  }

  void _reset() {
    _aController.clear();
    _bController.clear();
    _cController.clear();
    _dController.clear();
    setState(() {
      _relativeRisk = null;
      _lowerCI = null;
      _upperCI = null;
      _interpretation = null;
    });
  }

  void _copyResultWithUnit() {
    if (_relativeRisk == null) return;

    final resultText = 'RR = ${_relativeRisk!.toStringAsFixed(3)}';
    Clipboard.setData(ClipboardData(text: resultText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $resultText'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.1),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Relative Risk
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Relative Risk',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Result with prominent unit badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _relativeRisk!.toStringAsFixed(3),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'RR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Copy button
                OutlinedButton.icon(
                  onPressed: () => _copyResultWithUnit(),
                  icon: Icon(Icons.copy, size: 16, color: AppColors.success),
                  label: Text(
                    'Copy Result',
                    style: TextStyle(color: AppColors.success),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.success),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '95% CI: ${_lowerCI!.toStringAsFixed(3)} - ${_upperCI!.toStringAsFixed(3)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Interpretation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _interpretation!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveResult,
                  icon: const Icon(Icons.save, size: 20),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showExportModal,
                  icon: const Icon(Icons.file_download_outlined, size: 20),
                  label: const Text('Export'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary, width: 2),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferences() {
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
              Icon(
                Icons.library_books_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'References',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReferenceButton(
            'CDC Epidemiology Principles',
            'https://www.cdc.gov/eis/field-epi-manual/chapters/Measures-Association.html',
          ),
          const SizedBox(height: 6),
          _buildReferenceButton(
            'WHO Statistical Methods',
            'https://www.who.int/teams/control-of-neglected-tropical-diseases',
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceButton(String title, String url) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _launchURL(url),
        icon: Icon(
          Icons.open_in_new,
          size: 14,
          color: AppColors.primary,
        ),
        label: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }

  Future<void> _saveResult() async {
    if (_relativeRisk == null) return;

    try {
      // Create unified history entry
      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Relative Risk Calculator',
        inputs: {
          'Exposed + Disease (a)': _aController.text,
          'Exposed - Disease (b)': _bController.text,
          'Non-exposed + Disease (c)': _cController.text,
          'Non-exposed - Disease (d)': _dController.text,
        },
        result: '${_relativeRisk!.toStringAsFixed(3)} (95% CI: ${_lowerCI!.toStringAsFixed(3)} - ${_upperCI!.toStringAsFixed(3)})',
        notes: _interpretation ?? '',
        tags: ['epidemiology', 'relative-risk', '2x2-table'],
      );

      // Save to unified history
      final historyService = ref.read(historyServiceProvider);
      await historyService.addEntry(historyEntry);

      // Also maintain backward compatibility with old system for now
      final prefs = await SharedPreferences.getInstance();
      final result = {
        'type': 'relative_risk',
        'timestamp': DateTime.now().toIso8601String(),
        'inputs': {
          'a': int.parse(_aController.text),
          'b': int.parse(_bController.text),
          'c': int.parse(_cController.text),
          'd': int.parse(_dController.text),
        },
        'results': {
          'relative_risk': _relativeRisk,
          'lower_ci': _lowerCI,
          'upper_ci': _upperCI,
          'interpretation': _interpretation,
        },
      };

      final history = prefs.getStringList('analytics_history') ?? [];
      history.insert(0, jsonEncode(result));

      // Keep only last 50 entries
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      await prefs.setStringList('analytics_history', history);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Result saved to history successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save result: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showExportModal() {
    if (_relativeRisk == null) return;

    ExportModal.show(
      context: context,
      onExportPDF: _exportAsPDF,
      onExportCSV: _exportAsCSV,
      onExportExcel: _exportAsExcel,
      onExportText: _exportAsText,
      enablePhoto: false,
    );
  }

  Future<void> _exportAsCSV() async {
    if (_relativeRisk == null) return;

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Relative Risk Calculator',
      formula: 'RR = [a/(a+b)] / [c/(c+d)]',
      inputs: {
        'a (Exposed + Disease)': _aController.text,
        'b (Exposed - Disease)': _bController.text,
        'c (Non-exposed + Disease)': _cController.text,
        'd (Non-exposed - Disease)': _dController.text,
      },
      results: {
        'Relative Risk (RR)': _relativeRisk!.toStringAsFixed(3),
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(3)} - ${_upperCI!.toStringAsFixed(3)}',
      },
      benchmark: {
        'target': 'RR = 1.0 (no association)',
        'unit': 'relative risk',
        'source': 'Epidemiological Standards',
        'status': _relativeRisk! > 1.0
            ? 'RR > 1: Increased risk with exposure'
            : _relativeRisk! < 1.0
                ? 'RR < 1: Decreased risk with exposure'
                : 'RR = 1: No association',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    if (_relativeRisk == null) return;

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Relative Risk Calculator',
      formula: 'RR = [a/(a+b)] / [c/(c+d)]',
      inputs: {
        'a (Exposed + Disease)': _aController.text,
        'b (Exposed - Disease)': _bController.text,
        'c (Non-exposed + Disease)': _cController.text,
        'd (Non-exposed - Disease)': _dController.text,
      },
      results: {
        'Relative Risk (RR)': _relativeRisk!.toStringAsFixed(3),
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(3)} - ${_upperCI!.toStringAsFixed(3)}',
      },
      benchmark: {
        'target': 'RR = 1.0 (no association)',
        'unit': 'relative risk',
        'source': 'Epidemiological Standards',
        'status': _relativeRisk! > 1.0
            ? 'RR > 1: Increased risk with exposure'
            : _relativeRisk! < 1.0
                ? 'RR < 1: Decreased risk with exposure'
                : 'RR = 1: No association',
      },
      interpretation: _interpretation,
    );
  }

  void _loadExample() {
    setState(() {
      _aController.text = '30';  // Exposed Cases
      _bController.text = '70';  // Exposed Non-cases
      _cController.text = '10';  // Non-exposed Cases
      _dController.text = '90';  // Non-exposed Non-cases
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded: Cohort study data'),
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
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.menu_book, color: AppColors.info, size: 24),
                    ),
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
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.textTertiary.withValues(alpha: 0.2)),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: KnowledgePanelWidget(data: _knowledgePanelData),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error if needed
    }
  }

  Future<void> _exportAsPDF() async {
    if (_relativeRisk == null) return;

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Relative Risk Calculator',
      formula: 'RR = [a/(a+b)] / [c/(c+d)]',
      inputs: {
        'a (Exposed + Disease)': _aController.text,
        'b (Exposed - Disease)': _bController.text,
        'c (Non-exposed + Disease)': _cController.text,
        'd (Non-exposed - Disease)': _dController.text,
      },
      results: {
        'Relative Risk (RR)': _relativeRisk!.toStringAsFixed(3),
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(3)} - ${_upperCI!.toStringAsFixed(3)}',
      },
      benchmark: {
        'target': 'RR = 1.0 (no association)',
        'unit': 'relative risk',
        'source': 'Epidemiological Standards',
        'status': _relativeRisk! > 1.0
            ? 'RR > 1: Increased risk with exposure'
            : _relativeRisk! < 1.0
                ? 'RR < 1: Decreased risk with exposure'
                : 'RR = 1: No association',
      },
      interpretation: _interpretation,
      references: [
        'CDC Field Epidemiology Manual',
        'https://www.cdc.gov/eis/field-epi-manual/',
      ],
    );
  }

  Future<void> _exportAsExcel() async {
    if (_relativeRisk == null) return;

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Relative Risk Calculator',
      formula: 'RR = [a/(a+b)] / [c/(c+d)]',
      inputs: {
        'a (Exposed + Disease)': _aController.text,
        'b (Exposed - Disease)': _bController.text,
        'c (Non-exposed + Disease)': _cController.text,
        'd (Non-exposed - Disease)': _dController.text,
      },
      results: {
        'Relative Risk (RR)': _relativeRisk!.toStringAsFixed(3),
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(3)} - ${_upperCI!.toStringAsFixed(3)}',
      },
      benchmark: {
        'target': 'RR = 1.0 (no association)',
        'unit': 'relative risk',
        'source': 'Epidemiological Standards',
        'status': _relativeRisk! > 1.0
            ? 'RR > 1: Increased risk with exposure'
            : _relativeRisk! < 1.0
                ? 'RR < 1: Decreased risk with exposure'
                : 'RR = 1: No association',
      },
      interpretation: _interpretation,
    );
  }
}
