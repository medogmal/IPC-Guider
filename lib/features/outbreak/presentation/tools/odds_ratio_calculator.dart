import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:convert';
import 'dart:math';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';

class OddsRatioCalculator extends StatefulWidget {
  const OddsRatioCalculator({super.key});

  @override
  State<OddsRatioCalculator> createState() => _OddsRatioCalculatorState();
}

class _OddsRatioCalculatorState extends State<OddsRatioCalculator> {
  final _aController = TextEditingController(); // Cases with exposure
  final _bController = TextEditingController(); // Controls with exposure
  final _cController = TextEditingController(); // Cases without exposure
  final _dController = TextEditingController(); // Controls without exposure
  final _formKey = GlobalKey<FormState>();

  double? _oddsRatio;
  double? _lowerCI;
  double? _upperCI;
  String? _interpretation;
  bool _isLoading = false;

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Strength of association between exposure and outcome.',
    formula: 'OR = (A×D)/(B×C)',
    example: 'Salad exposure OR = 25.',
    interpretation: 'OR > 1 suggests causal link.',
    whenUsed: 'Step 9 (case–control analytic studies).',
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
        title: 'Odds Ratio Calculator',
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
                            Icons.balance_outlined,
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
                                'Odds Ratio Calculator',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Calculate odds ratios from case-control studies with confidence intervals',
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
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
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
                          // Main formula using flutter_math_fork
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
                                  r'\text{OR} = \frac{a \times d}{b \times c}',
                                  textStyle: TextStyle(fontSize: fontSize),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Odds of exposure in cases ÷ Odds of exposure in controls',
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

                    // Table
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
                            _buildTableHeaderCell('Cases'),
                            _buildTableHeaderCell('Controls'),
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
                            'a = Cases with exposure\nb = Controls with exposure\nc = Cases without exposure\nd = Controls without exposure',
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
                      onPressed: _isLoading ? null : _calculateOddsRatio,
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

              if (_oddsRatio != null) ...[
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

  void _calculateOddsRatio() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      final a = int.parse(_aController.text);
      final b = int.parse(_bController.text);
      final c = int.parse(_cController.text);
      final d = int.parse(_dController.text);

      // Check for zero values that would make calculation impossible
      if (b == 0 || c == 0) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cannot calculate: Zero values in denominator'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Calculate odds ratio
      final oddsRatio = (a * d) / (b * c);

      // Calculate 95% confidence interval
      final lnOR = log(oddsRatio);
      final seLnOR = sqrt((1/a) + (1/b) + (1/c) + (1/d));
      final lowerCI = exp(lnOR - 1.96 * seLnOR);
      final upperCI = exp(lnOR + 1.96 * seLnOR);

      // Generate interpretation
      String interpretation;
      if (oddsRatio < 0.8) {
        interpretation = 'Protective association - exposure reduces odds of disease';
      } else if (oddsRatio < 1.2) {
        interpretation = 'No significant association';
      } else if (oddsRatio < 2.0) {
        interpretation = 'Moderate positive association';
      } else if (oddsRatio < 5.0) {
        interpretation = 'Strong positive association';
      } else {
        interpretation = 'Very strong positive association';
      }

      setState(() {
        _oddsRatio = oddsRatio;
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
      _oddsRatio = null;
      _lowerCI = null;
      _upperCI = null;
      _interpretation = null;
    });
  }

  void _copyResultWithUnit() {
    if (_oddsRatio == null) return;

    final resultText = 'OR = ${_oddsRatio!.toStringAsFixed(3)}';
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

          // Odds Ratio
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Odds Ratio',
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
                          _oddsRatio!.toStringAsFixed(3),
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
                          'OR',
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
            'CDC Case-Control Studies',
            'https://www.cdc.gov/eis/field-epi-manual/chapters/Case-Control-Studies.html',
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
    if (_oddsRatio == null) return;

    final prefs = await SharedPreferences.getInstance();
    final result = {
      'type': 'odds_ratio',
      'timestamp': DateTime.now().toIso8601String(),
      'inputs': {
        'a': int.parse(_aController.text),
        'b': int.parse(_bController.text),
        'c': int.parse(_cController.text),
        'd': int.parse(_dController.text),
      },
      'results': {
        'odds_ratio': _oddsRatio,
        'lower_ci': _lowerCI,
        'upper_ci': _upperCI,
        'interpretation': _interpretation,
      },
    };

    final history = prefs.getStringList('analytics_history') ?? [];
    history.insert(0, jsonEncode(result));
    
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    
    await prefs.setStringList('analytics_history', history);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Result saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showExportModal() {
    if (_oddsRatio == null) return;

    ExportModal.show(
      context: context,
      onExportPDF: _exportAsPDF,
      onExportCSV: _exportAsCSV,
      onExportExcel: _exportAsExcel,
      onExportText: _exportAsText,
      enablePhoto: false,
    );
  }

  void _loadExample() {
    setState(() {
      _aController.text = '40';  // Cases with exposure
      _bController.text = '20';  // Controls with exposure
      _cController.text = '20';  // Cases without exposure
      _dController.text = '60';  // Controls without exposure
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded: Case-control study data'),
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

  Future<void> _exportAsPDF() async{
    if (_oddsRatio == null) return;

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Odds Ratio Calculator',
      formula: 'OR = (a × d) / (b × c)',
      inputs: {
        'a (Cases + Exposure)': _aController.text,
        'b (Controls + Exposure)': _bController.text,
        'c (Cases - Exposure)': _cController.text,
        'd (Controls - Exposure)': _dController.text,
      },
      results: {
        'Odds Ratio (OR)': _oddsRatio!.toStringAsFixed(3),
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(3)} - ${_upperCI!.toStringAsFixed(3)}',
      },
      benchmark: {
        'target': 'OR = 1.0 (no association)',
        'unit': 'odds ratio',
        'source': 'Epidemiological Standards',
        'status': _oddsRatio! > 1.0
            ? 'OR > 1: Positive association with exposure'
            : _oddsRatio! < 1.0
                ? 'OR < 1: Negative association with exposure'
                : 'OR = 1: No association',
      },
      interpretation: _interpretation,
      references: [
        'CDC Field Epidemiology Manual',
        'https://www.cdc.gov/eis/field-epi-manual/',
      ],
    );
  }

  Future<void> _exportAsExcel() async {
    if (_oddsRatio == null) return;

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Odds Ratio Calculator',
      formula: 'OR = (a × d) / (b × c)',
      inputs: {
        'a (Cases + Exposure)': _aController.text,
        'b (Controls + Exposure)': _bController.text,
        'c (Cases - Exposure)': _cController.text,
        'd (Controls - Exposure)': _dController.text,
      },
      results: {
        'Odds Ratio (OR)': _oddsRatio!.toStringAsFixed(3),
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(3)} - ${_upperCI!.toStringAsFixed(3)}',
      },
      benchmark: {
        'target': 'OR = 1.0 (no association)',
        'unit': 'odds ratio',
        'source': 'Epidemiological Standards',
        'status': _oddsRatio! > 1.0
            ? 'OR > 1: Positive association with exposure'
            : _oddsRatio! < 1.0
                ? 'OR < 1: Negative association with exposure'
                : 'OR = 1: No association',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    if (_oddsRatio == null) return;

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Odds Ratio Calculator',
      formula: 'OR = (a × d) / (b × c)',
      inputs: {
        'a (Cases + Exposure)': _aController.text,
        'b (Controls + Exposure)': _bController.text,
        'c (Cases - Exposure)': _cController.text,
        'd (Controls - Exposure)': _dController.text,
      },
      results: {
        'Odds Ratio (OR)': _oddsRatio!.toStringAsFixed(3),
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(3)} - ${_upperCI!.toStringAsFixed(3)}',
      },
      benchmark: {
        'target': 'OR = 1.0 (no association)',
        'unit': 'odds ratio',
        'source': 'Epidemiological Standards',
        'status': _oddsRatio! > 1.0
            ? 'OR > 1: Positive association with exposure'
            : _oddsRatio! < 1.0
                ? 'OR < 1: Negative association with exposure'
                : 'OR = 1: No association',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    if (_oddsRatio == null) return;

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Odds Ratio Calculator',
      formula: 'OR = (a × d) / (b × c)',
      inputs: {
        'a (Cases + Exposure)': _aController.text,
        'b (Controls + Exposure)': _bController.text,
        'c (Cases - Exposure)': _cController.text,
        'd (Controls - Exposure)': _dController.text,
      },
      results: {
        'Odds Ratio (OR)': _oddsRatio!.toStringAsFixed(3),
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(3)} - ${_upperCI!.toStringAsFixed(3)}',
      },
      benchmark: {
        'target': 'OR = 1.0 (no association)',
        'unit': 'odds ratio',
        'source': 'Epidemiological Standards',
        'status': _oddsRatio! > 1.0
            ? 'OR > 1: Positive association with exposure'
            : _oddsRatio! < 1.0
                ? 'OR < 1: Negative association with exposure'
                : 'OR = 1: No association',
      },
      interpretation: _interpretation,
      references: [
        'CDC Field Epidemiology Manual',
        'https://www.cdc.gov/eis/field-epi-manual/',
        'WHO Outbreak Investigation',
        'https://www.who.int/emergencies/outbreak-toolkit',
      ],
    );
  }
}
