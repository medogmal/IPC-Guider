import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:convert';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';

class SensitivitySpecificityCalculator extends ConsumerStatefulWidget {
  const SensitivitySpecificityCalculator({super.key});

  @override
  ConsumerState<SensitivitySpecificityCalculator> createState() => _SensitivitySpecificityCalculatorState();
}

class _SensitivitySpecificityCalculatorState extends ConsumerState<SensitivitySpecificityCalculator> {
  final ScreenshotController _screenshotController = ScreenshotController();
  
  // Input controllers
  final _truePositivesController = TextEditingController();
  final _falseNegativesController = TextEditingController();
  final _falsePositivesController = TextEditingController();
  final _trueNegativesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Results
  double? _sensitivity;
  double? _specificity;
  double? _positivePredictiveValue;
  double? _negativePredictiveValue;
  double? _accuracy;
  double? _prevalence;
  double? _likelihoodRatioPositive;
  double? _likelihoodRatioNegative;
  double? _diagnosticOddsRatio;
  
  // ROC curve data
  List<ROCPoint> _rocCurve = [];
  double? _auc;
  
  // UI state
  bool _isLoading = false;
  bool _showROCCurve = false;
  String? _errorMessage;

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Measures diagnostic test accuracy with ROC analysis.',
    formula: 'Se = TP/(TP+FN), Sp = TN/(TN+FP)',
    example: 'PCR test: Se=95%, Sp=98%, PPV varies with prevalence.',
    interpretation: 'High Se rules out, High Sp rules in (SnNout, SpPin).',
    whenUsed: 'Step 8-9 (diagnostic test evaluation, analytic phase).',
    inputDataType: 'True positives, false negatives, false positives, true negatives.',
    references: [
      Reference(
        title: 'CDC Diagnostic Test Evaluation',
        url: 'https://www.cdc.gov/eis/field-epi-manual/chapters/Screening.html',
      ),
      Reference(
        title: 'WHO Laboratory Quality Guidelines',
        url: 'https://www.who.int/publications/i/item/9789241548274',
      ),
      Reference(
        title: 'APIC Outbreak Investigation Guide',
        url: 'https://apic.org/Resource_/TinyMceFileManager/Advocacy-PDFs/APIC_Outbreak_Investigation_Guide.pdf',
      ),
    ],
  );

  @override
  void dispose() {
    _truePositivesController.dispose();
    _falseNegativesController.dispose();
    _falsePositivesController.dispose();
    _trueNegativesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Sensitivity/Specificity Calculator',
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
              const SizedBox(height: 24),

              // Formula Display
              _buildFormulaCard(),
              const SizedBox(height: 24),

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
                  icon: Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
                  label: Text(
                    'Load Example',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.warning, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2x2 Contingency Table
              _buildContingencyTable(),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 24),

              // Results Section
              if (_sensitivity != null) ...[
                _buildResultsCard(),
                const SizedBox(height: 24),

                // ROC Curve Section
                _buildROCCurveSection(),
                const SizedBox(height: 24),

                // Clinical Interpretation
                _buildClinicalInterpretationCard(),
                const SizedBox(height: 24),
              ],

              // Error Message
              if (_errorMessage != null) ...[
                _buildErrorMessage(),
                const SizedBox(height: 24),
              ],

              // References
              _buildReferences(),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.analytics_outlined,
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
                  'Sensitivity/Specificity Calculator',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Comprehensive diagnostic test evaluation with ROC analysis',
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
    );
  }

  Widget _buildFormulaCard() {
    return Container(
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
            'Key Formulas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildFormulaItem('Sensitivity', 'TP ÷ (TP + FN)'),
              _buildFormulaItem('Specificity', 'TN ÷ (TN + FP)'),
              _buildFormulaItem('PPV', 'TP ÷ (TP + FP)'),
              _buildFormulaItem('NPV', 'TN ÷ (TN + FN)'),
              _buildFormulaItem('LR+', 'Se ÷ (1 - Sp)'),
              _buildFormulaItem('LR-', '(1 - Se) ÷ Sp'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaItem(String label, String formula) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formula,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContingencyTable() {
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
          Text(
            '2×2 Contingency Table',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

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
              // Test Positive Row
              TableRow(
                children: [
                  _buildTableHeaderCell('Test +'),
                  _buildTableInputCell(_truePositivesController, 'TP'),
                  _buildTableInputCell(_falsePositivesController, 'FP'),
                ],
              ),
              // Test Negative Row
              TableRow(
                children: [
                  _buildTableHeaderCell('Test -'),
                  _buildTableInputCell(_falseNegativesController, 'FN'),
                  _buildTableInputCell(_trueNegativesController, 'TN'),
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
                  'TP = True Positives (Test +, Disease +)\n'
                  'FP = False Positives (Test +, Disease -)\n'
                  'FN = False Negatives (Test -, Disease +)\n'
                  'TN = True Negatives (Test -, Disease -)',
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _calculateMetrics,
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
                'Diagnostic Test Performance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Primary Metrics
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricCard('Sensitivity', '${_sensitivity!.toStringAsFixed(1)}%', AppColors.primary),
              _buildMetricCard('Specificity', '${_specificity!.toStringAsFixed(1)}%', AppColors.success),
              _buildMetricCard('PPV', '${_positivePredictiveValue!.toStringAsFixed(1)}%', AppColors.info),
              _buildMetricCard('NPV', '${_negativePredictiveValue!.toStringAsFixed(1)}%', AppColors.warning),
            ],
          ),

          const SizedBox(height: 16),

          // Secondary Metrics
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricCard('Accuracy', '${_accuracy!.toStringAsFixed(1)}%', AppColors.secondary),
              _buildMetricCard('Prevalence', '${_prevalence!.toStringAsFixed(1)}%', Colors.grey),
              _buildMetricCard('LR+', _likelihoodRatioPositive!.toStringAsFixed(2), Colors.purple),
              _buildMetricCard('LR-', _likelihoodRatioNegative!.toStringAsFixed(2), Colors.deepOrange),
            ],
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

          const SizedBox(height: 12),

          // Copy Results Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _copyAllResults(),
              icon: Icon(Icons.copy, size: 16, color: AppColors.primary),
              label: Text(
                'Copy All Results',
                style: TextStyle(color: AppColors.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildROCCurveSection() {
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
              Icon(Icons.show_chart, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'ROC Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showROCCurve = !_showROCCurve;
                  });
                },
                icon: Icon(_showROCCurve ? Icons.expand_less : Icons.expand_more),
                label: Text(_showROCCurve ? 'Hide' : 'Show'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_showROCCurve) ...[
            // AUC Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Area Under Curve (AUC)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                  Text(
                    _auc != null ? _auc!.toStringAsFixed(3) : 'N/A',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ROC Chart
            Screenshot(
              controller: _screenshotController,
              child: Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.2)),
                ),
                child: _buildROCChart(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildROCChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 0.2,
          verticalInterval: 0.2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textTertiary.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.textTertiary.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 0.2,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    (value * 100).toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 0.2,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    (value * 100).toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.3)),
        ),
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          // Random chance line
          LineChartBarData(
            spots: const [FlSpot(0, 0), FlSpot(1, 1)],
            isCurved: false,
            color: Colors.grey,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
          ),
          // ROC curve points
          if (_rocCurve.isNotEmpty)
            LineChartBarData(
              spots: _rocCurve.map((point) => FlSpot(point.falsePositiveRate, point.truePositiveRate)).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primary],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '1-Sp: ${(spot.x * 100).toInt()}%\nSe: ${(spot.y * 100).toInt()}%',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildClinicalInterpretationCard() {
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
              Icon(Icons.medical_information, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Clinical Interpretation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SnNout/SpPin Rules
          _buildInterpretationRule(
            'SnNout Rule',
            _sensitivity! > 0.95,
            'High sensitivity (>95%) rules out disease',
            'A negative test effectively excludes the condition',
          ),

          const SizedBox(height: 12),

          _buildInterpretationRule(
            'SpPin Rule',
            _specificity! > 0.95,
            'High specificity (>95%) rules in disease',
            'A positive test confirms the condition',
          ),

          const SizedBox(height: 12),

          // Likelihood Ratios Interpretation
          Text(
            'Likelihood Ratios:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          _buildLRInterpretation('LR+', _likelihoodRatioPositive!, {
            '>10': 'Large effect',
            '5-10': 'Moderate effect',
            '2-5': 'Small effect',
            '<2': 'Minimal effect',
          }),

          const SizedBox(height: 8),

          _buildLRInterpretation('LR-', _likelihoodRatioNegative!, {
            '<0.1': 'Large effect',
            '0.1-0.2': 'Moderate effect',
            '0.2-0.5': 'Small effect',
            '>0.5': 'Minimal effect',
          }),

          const SizedBox(height: 12),

          // Overall Test Quality
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getTestQualityColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getTestQualityColor().withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.assessment, color: _getTestQualityColor(), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Overall Test Quality: ${_getTestQuality()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getTestQualityColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationRule(String title, bool condition, String rule, String explanation) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: condition ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: condition ? AppColors.success.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                condition ? Icons.check_circle_outline : Icons.info_outline,
                color: condition ? AppColors.success : AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: condition ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            rule,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            explanation,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLRInterpretation(String label, double value, Map<String, String> interpretations) {
    String interpretation = 'Unknown';
    for (final entry in interpretations.entries) {
      final parts = entry.key.split(':');
      if (parts.length == 2) {
        final range = parts[0].split('-');
        if (range.length == 1) {
          final threshold = double.tryParse(range[0]);
          if (threshold != null) {
            if (label == 'LR+' && value >= threshold) {
              interpretation = entry.value;
              break;
            } else if (label == 'LR-' && value <= threshold) {
              interpretation = entry.value;
              break;
            }
          }
        } else if (range.length == 2) {
          final min = double.tryParse(range[0]);
          final max = double.tryParse(range[1]);
          if (min != null && max != null) {
            if (value >= min && value <= max) {
              interpretation = entry.value;
              break;
            }
          }
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            '$label: ${value.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(
            '($interpretation)',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _getTestQuality() {
    if (_sensitivity! >= 0.9 && _specificity! >= 0.9) {
      return 'Excellent';
    } else if (_sensitivity! >= 0.8 && _specificity! >= 0.8) {
      return 'Good';
    } else if (_sensitivity! >= 0.7 && _specificity! >= 0.7) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }

  Color _getTestQualityColor() {
    final quality = _getTestQuality();
    switch (quality) {
      case 'Excellent':
        return AppColors.success;
      case 'Good':
        return AppColors.info;
      case 'Fair':
        return AppColors.warning;
      case 'Poor':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
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
              Icon(Icons.library_books, color: AppColors.primary, size: 20),
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
            'WHO Laboratory Quality Standards',
            'https://www.who.int/publications/i/item/9789241548274',
          ),
          const SizedBox(height: 6),
          _buildReferenceButton(
            'CDC Diagnostic Test Evaluation',
            'https://www.cdc.gov/labquality/evaluation.html',
          ),
          const SizedBox(height: 6),
          _buildReferenceButton(
            'STARD Guidelines for Diagnostic Studies',
            'https://www.stard-statement.org/',
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

  // Calculation methods
  void _calculateMetrics() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final tp = int.parse(_truePositivesController.text);
        final fn = int.parse(_falseNegativesController.text);
        final fp = int.parse(_falsePositivesController.text);
        final tn = int.parse(_trueNegativesController.text);

        // Check for zero denominators
        if (tp + fn == 0 || fp + tn == 0 || tp + fp == 0 || fn + tn == 0) {
          setState(() {
            _errorMessage = 'Invalid data: Cannot calculate with zero denominators';
            _isLoading = false;
          });
          return;
        }

        // Calculate primary metrics
        final sensitivity = tp / (tp + fn);
        final specificity = tn / (fp + tn);
        final ppv = tp / (tp + fp);
        final npv = tn / (fn + tn);
        final accuracy = (tp + tn) / (tp + fn + fp + tn);
        final prevalence = (tp + fn) / (tp + fn + fp + tn);

        // Calculate likelihood ratios
        final lrPlus = sensitivity / (1 - specificity);
        final lrMinus = (1 - sensitivity) / specificity;
        final dod = (lrPlus) / (lrMinus);

        // Generate ROC curve points (simplified - single point for binary test)
        _rocCurve = [
          ROCPoint(1 - specificity, sensitivity),
        ];

        // Calculate AUC (simplified for single point)
        final auc = (1 + sensitivity) / 2;

        setState(() {
          _sensitivity = sensitivity;
          _specificity = specificity;
          _positivePredictiveValue = ppv;
          _negativePredictiveValue = npv;
          _accuracy = accuracy;
          _prevalence = prevalence;
          _likelihoodRatioPositive = lrPlus;
          _likelihoodRatioNegative = lrMinus;
          _diagnosticOddsRatio = dod;
          _auc = auc;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error calculating metrics: ${e.toString()}';
          _isLoading = false;
        });
      }
    });
  }

  void _reset() {
    _truePositivesController.clear();
    _falseNegativesController.clear();
    _falsePositivesController.clear();
    _trueNegativesController.clear();
    setState(() {
      _sensitivity = null;
      _specificity = null;
      _positivePredictiveValue = null;
      _negativePredictiveValue = null;
      _accuracy = null;
      _prevalence = null;
      _likelihoodRatioPositive = null;
      _likelihoodRatioNegative = null;
      _diagnosticOddsRatio = null;
      _rocCurve.clear();
      _auc = null;
      _showROCCurve = false;
      _errorMessage = null;
    });
  }

  void _copyAllResults() {
    if (_sensitivity == null) return;

    final resultText = '''Sensitivity: ${_sensitivity!.toStringAsFixed(1)}%
Specificity: ${_specificity!.toStringAsFixed(1)}%
PPV: ${_positivePredictiveValue!.toStringAsFixed(1)}%
NPV: ${_negativePredictiveValue!.toStringAsFixed(1)}%
Accuracy: ${_accuracy!.toStringAsFixed(1)}%''';

    Clipboard.setData(ClipboardData(text: resultText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All results copied to clipboard'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveResult() async {
    if (_sensitivity == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('sensitivity_specificity_history') ?? [];

      final result = {
        'timestamp': DateTime.now().toIso8601String(),
        'inputs': {
          'true_positives': int.parse(_truePositivesController.text),
          'false_negatives': int.parse(_falseNegativesController.text),
          'false_positives': int.parse(_falsePositivesController.text),
          'true_negatives': int.parse(_trueNegativesController.text),
        },
        'results': {
          'sensitivity': _sensitivity,
          'specificity': _specificity,
          'ppv': _positivePredictiveValue,
          'npv': _negativePredictiveValue,
          'accuracy': _accuracy,
          'prevalence': _prevalence,
          'lr_plus': _likelihoodRatioPositive,
          'lr_minus': _likelihoodRatioNegative,
          'diagnostic_odds_ratio': _diagnosticOddsRatio,
          'auc': _auc,
          'test_quality': _getTestQuality(),
        },
      };

      history.add(jsonEncode(result));
      
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }
      
      await prefs.setStringList('sensitivity_specificity_history', history);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Results saved to history successfully'),
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
    if (_sensitivity == null) return;

    ExportModal.show(
      context: context,
      onExportPDF: _exportAsPDF,
      onExportCSV: _exportAsCSV,
      onExportExcel: _exportAsExcel,
      onExportText: _exportAsText,
      enablePhoto: false,
    );
  }

  Future<void> _exportAsPDF() async {
    if (_sensitivity == null) return;

    final interpretation = 'Sensitivity: ${_sensitivity!.toStringAsFixed(1)}%, Specificity: ${_specificity!.toStringAsFixed(1)}%. '
        '${_sensitivity! > 0.95 ? 'SnNout Rule met - High sensitivity rules out disease. ' : ''}'
        '${_specificity! > 0.95 ? 'SpPin Rule met - High specificity rules in disease. ' : ''}'
        'Test Quality: ${_getTestQuality()}';

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Enhanced Sensitivity & Specificity Calculator',
      inputs: {
        'True Positives (TP)': _truePositivesController.text,
        'False Negatives (FN)': _falseNegativesController.text,
        'False Positives (FP)': _falsePositivesController.text,
        'True Negatives (TN)': _trueNegativesController.text,
      },
      results: {
        'Sensitivity': '${_sensitivity!.toStringAsFixed(1)}%',
        'Specificity': '${_specificity!.toStringAsFixed(1)}%',
        'PPV': '${_positivePredictiveValue!.toStringAsFixed(1)}%',
        'NPV': '${_negativePredictiveValue!.toStringAsFixed(1)}%',
        'Accuracy': '${_accuracy!.toStringAsFixed(1)}%',
        'LR+': _likelihoodRatioPositive!.toStringAsFixed(2),
        'LR-': _likelihoodRatioNegative!.toStringAsFixed(2),
      },
      interpretation: interpretation,
      references: [
        'CDC Diagnostic Test Evaluation',
        'https://www.cdc.gov/eis/field-epi-manual/chapters/Screening.html',
      ],
    );
  }

  Future<void> _exportAsExcel() async {
    if (_sensitivity == null) return;

    final interpretation = 'Sensitivity: ${_sensitivity!.toStringAsFixed(1)}%, Specificity: ${_specificity!.toStringAsFixed(1)}%. '
        '${_sensitivity! > 0.95 ? 'SnNout Rule met - High sensitivity rules out disease. ' : ''}'
        '${_specificity! > 0.95 ? 'SpPin Rule met - High specificity rules in disease. ' : ''}'
        'Test Quality: ${_getTestQuality()}';

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Enhanced Sensitivity & Specificity Calculator',
      inputs: {
        'True Positives (TP)': _truePositivesController.text,
        'False Negatives (FN)': _falseNegativesController.text,
        'False Positives (FP)': _falsePositivesController.text,
        'True Negatives (TN)': _trueNegativesController.text,
      },
      results: {
        'Sensitivity': '${_sensitivity!.toStringAsFixed(1)}%',
        'Specificity': '${_specificity!.toStringAsFixed(1)}%',
        'PPV': '${_positivePredictiveValue!.toStringAsFixed(1)}%',
        'NPV': '${_negativePredictiveValue!.toStringAsFixed(1)}%',
        'Accuracy': '${_accuracy!.toStringAsFixed(1)}%',
        'LR+': _likelihoodRatioPositive!.toStringAsFixed(2),
        'LR-': _likelihoodRatioNegative!.toStringAsFixed(2),
      },
      interpretation: interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    if (_sensitivity == null) return;

    final interpretation = 'Sensitivity: ${_sensitivity!.toStringAsFixed(1)}%, Specificity: ${_specificity!.toStringAsFixed(1)}%. '
        '${_sensitivity! > 0.95 ? 'SnNout Rule met - High sensitivity rules out disease. ' : ''}'
        '${_specificity! > 0.95 ? 'SpPin Rule met - High specificity rules in disease. ' : ''}'
        'Test Quality: ${_getTestQuality()}';

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Enhanced Sensitivity & Specificity Calculator',
      inputs: {
        'True Positives (TP)': _truePositivesController.text,
        'False Negatives (FN)': _falseNegativesController.text,
        'False Positives (FP)': _falsePositivesController.text,
        'True Negatives (TN)': _trueNegativesController.text,
      },
      results: {
        'Sensitivity': '${_sensitivity!.toStringAsFixed(1)}%',
        'Specificity': '${_specificity!.toStringAsFixed(1)}%',
        'PPV': '${_positivePredictiveValue!.toStringAsFixed(1)}%',
        'NPV': '${_negativePredictiveValue!.toStringAsFixed(1)}%',
        'Accuracy': '${_accuracy!.toStringAsFixed(1)}%',
        'LR+': _likelihoodRatioPositive!.toStringAsFixed(2),
        'LR-': _likelihoodRatioNegative!.toStringAsFixed(2),
      },
      interpretation: interpretation,
    );
  }

  Future<void> _exportAsText() async {
    if (_sensitivity == null) return;

    final interpretation = 'Sensitivity: ${_sensitivity!.toStringAsFixed(1)}%, Specificity: ${_specificity!.toStringAsFixed(1)}%. '
        '${_sensitivity! > 0.95 ? 'SnNout Rule met - High sensitivity rules out disease. ' : ''}'
        '${_specificity! > 0.95 ? 'SpPin Rule met - High specificity rules in disease. ' : ''}'
        'Test Quality: ${_getTestQuality()}';

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Enhanced Sensitivity & Specificity Calculator',
      inputs: {
        'True Positives (TP)': _truePositivesController.text,
        'False Negatives (FN)': _falseNegativesController.text,
        'False Positives (FP)': _falsePositivesController.text,
        'True Negatives (TN)': _trueNegativesController.text,
      },
      results: {
        'Sensitivity': '${_sensitivity!.toStringAsFixed(1)}%',
        'Specificity': '${_specificity!.toStringAsFixed(1)}%',
        'PPV': '${_positivePredictiveValue!.toStringAsFixed(1)}%',
        'NPV': '${_negativePredictiveValue!.toStringAsFixed(1)}%',
        'Accuracy': '${_accuracy!.toStringAsFixed(1)}%',
        'LR+': _likelihoodRatioPositive!.toStringAsFixed(2),
        'LR-': _likelihoodRatioNegative!.toStringAsFixed(2),
      },
      interpretation: interpretation,
      references: [
        'CDC Diagnostic Test Evaluation',
        'https://www.cdc.gov/eis/field-epi-manual/chapters/Screening.html',
      ],
    );
  }

  void _loadExample() {
    setState(() {
      _truePositivesController.text = '95';  // TP
      _falseNegativesController.text = '5';   // FN
      _falsePositivesController.text = '10';  // FP
      _trueNegativesController.text = '90';   // TN
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example data loaded: PCR test evaluation (Se=95%, Sp=90%)'),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// Data class for ROC curve points
class ROCPoint {
  final double falsePositiveRate;
  final double truePositiveRate;

  ROCPoint(this.falsePositiveRate, this.truePositiveRate);
}
