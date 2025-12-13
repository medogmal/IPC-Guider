import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';

class PValueCalculator extends ConsumerStatefulWidget {
  const PValueCalculator({super.key});

  @override
  ConsumerState<PValueCalculator> createState() => _PValueCalculatorState();
}

class _PValueCalculatorState extends ConsumerState<PValueCalculator> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final _formKey = GlobalKey<FormState>();

  // Test type selection
  String _testType = 'z-test';
  final List<String> _testTypes = [
    'z-test',
    't-test',
    'chi-square',
    'f-test',
    'anova',
  ];

  // Input controllers
  final _statisticController = TextEditingController();
  final _sampleSizeController = TextEditingController();
  final _dfController = TextEditingController(); // degrees of freedom
  final _alphaController = TextEditingController(text: '0.05');
  
  // Results
  double? _pValue;
  String? _significance;
  String? _interpretation;
  bool _isLoading = false;
  String? _errorMessage;

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Probability of observing results as extreme as, or more extreme than, observed.',
    formula: 'P = P(|Test Statistic| ≥ observed | H₀ true)',
    example: 'P = 0.03 < 0.05 → Reject null hypothesis.',
    interpretation: 'P < α indicates statistically significant result.',
    whenUsed: 'Step 8-9 (hypothesis testing, analytic phase).',
    inputDataType: 'Test statistic, sample size, degrees of freedom, significance level.',
    references: [
      Reference(
        title: 'CDC Statistical Methods',
        url: 'https://www.cdc.gov/eis/field-epi-manual/chapters/Statistical-Methods.html',
      ),
      Reference(
        title: 'WHO Statistical Guidelines',
        url: 'https://www.who.int/publications/i/item/9789241519221',
      ),
      Reference(
        title: 'APIC Outbreak Investigation Guide',
        url: 'https://apic.org/Resource_/TinyMceFileManager/Advocacy-PDFs/APIC_Outbreak_Investigation_Guide.pdf',
      ),
    ],
  );

  @override
  void dispose() {
    _statisticController.dispose();
    _sampleSizeController.dispose();
    _dfController.dispose();
    _alphaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'P-Value Calculator',
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
                    side: BorderSide(color: AppColors.info, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                    side: BorderSide(color: AppColors.warning, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Test Type Selection
              _buildTestTypeCard(),
              const SizedBox(height: 24),

              // Input Parameters
              _buildInputCard(),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 24),

              // Results Section
              if (_pValue != null) ...[
                _buildResultsCard(),
                const SizedBox(height: 24),

                // P-Value Distribution Chart
                _buildDistributionChart(),
                const SizedBox(height: 24),

                // Interpretation Card
                _buildInterpretationCard(),
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
              Icons.science_outlined,
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
                  'P-Value Calculator',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Statistical significance testing for hypothesis evaluation',
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

  Widget _buildTestTypeCard() {
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
            'Test Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _testTypes.map((testType) {
              final isSelected = _testType == testType;
              return ChoiceChip(
                label: Text(testType.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _testType = testType;
                      _clearResults();
                    });
                  }
                },
                backgroundColor: isSelected ? AppColors.primary : null,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Test type descriptions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getTestTypeDescription(),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.info,
              ),
            ),
          ),
        ],
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
          Text(
            'Input Parameters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Test Statistic
          TextFormField(
            controller: _statisticController,
            decoration: InputDecoration(
              labelText: 'Test Statistic',
              hintText: 'Enter calculated test statistic',
              suffixText: _getTestStatisticSuffix(),
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.functions_outlined, color: AppColors.primary),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter test statistic';
              }
              final statistic = double.tryParse(value);
              if (statistic == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Sample Size (for z-test and t-test)
          if (_testType == 'z-test' || _testType == 't-test')
            TextFormField(
              controller: _sampleSizeController,
              decoration: InputDecoration(
                labelText: 'Sample Size (n)',
                hintText: 'Enter sample size',
                suffixText: 'observations',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.groups_outlined, color: AppColors.primary),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter sample size';
                }
                final n = int.tryParse(value);
                if (n == null || n <= 1) {
                  return 'Sample size must be greater than 1';
                }
                return null;
              },
            ),

          // Degrees of Freedom (for t-test, chi-square, f-test)
          if (_testType == 't-test' || _testType == 'chi-square' || _testType == 'f-test')
            TextFormField(
              controller: _dfController,
              decoration: InputDecoration(
                labelText: 'Degrees of Freedom (df)',
                hintText: 'Enter degrees of freedom',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.tune_outlined, color: AppColors.primary),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter degrees of freedom';
                }
                final df = int.tryParse(value);
                if (df == null || df < 1) {
                  return 'Degrees of freedom must be at least 1';
                }
                return null;
              },
            ),

          const SizedBox(height: 16),

          // Significance Level
          TextFormField(
            controller: _alphaController,
            decoration: InputDecoration(
              labelText: 'Significance Level (α)',
              hintText: 'Enter significance level',
              suffixText: 'default: 0.05',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.balance_outlined, color: AppColors.primary),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^0?\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter significance level';
              }
              final alpha = double.tryParse(value);
              if (alpha == null || alpha <= 0 || alpha >= 1) {
                return 'Significance level must be between 0 and 1';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _calculatePValue,
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
            label: Text(_isLoading ? 'Calculating...' : 'Calculate P-Value'),
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
          color: _getSignificanceColor().withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getSignificanceColor().withValues(alpha: 0.1),
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
                  color: _getSignificanceColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getSignificanceIcon(),
                  color: _getSignificanceColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Statistical Significance Test',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getSignificanceColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // P-Value Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getSignificanceColor().withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'P-Value',
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
                    Text(
                      _pValue!.toStringAsFixed(6),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _getSignificanceColor(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getSignificanceColor(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'p',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Copy button
                OutlinedButton.icon(
                  onPressed: () => _copyResultWithUnit(),
                  icon: Icon(Icons.copy, size: 16, color: _getSignificanceColor()),
                  label: Text(
                    'Copy Result',
                    style: TextStyle(color: _getSignificanceColor()),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _getSignificanceColor()),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'α = ${(double.tryParse(_alphaController.text) ?? 0.05).toStringAsFixed(3)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Significance Result
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getSignificanceColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getSignificanceIcon(),
                  color: _getSignificanceColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _significance!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getSignificanceColor(),
                    ),
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
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
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

  Widget _buildDistributionChart() {
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
                '${_testType.toUpperCase()} Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Screenshot(
            controller: _screenshotController,
            child: Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.2)),
              ),
              child: _buildDistributionChartContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChartContent() {
    final statistic = double.tryParse(_statisticController.text) ?? 0.0;
    final alpha = double.tryParse(_alphaController.text) ?? 0.05;

    // Generate distribution data
    final spots = <FlSpot>[];
    final criticalPoints = <FlSpot>[];

    switch (_testType) {
      case 'z-test':
        // Normal distribution
        for (double x = -4.0; x <= 4.0; x += 0.1) {
          final y = _normalPDF(x);
          spots.add(FlSpot(x, y));
        }
        // Critical values
        criticalPoints.add(FlSpot(-_getZCritical(alpha).toDouble(), 0.0));
        criticalPoints.add(FlSpot(_getZCritical(alpha).toDouble(), 0.0));
        break;

      case 't-test':
        // t-distribution (approximation)
        final df = int.tryParse(_dfController.text) ?? 30;
        for (double x = -4.0; x <= 4.0; x += 0.1) {
          final y = _tPDF(x, df);
          spots.add(FlSpot(x, y));
        }
        criticalPoints.add(FlSpot(-_getTCritical(alpha, df).toDouble(), 0.0));
        criticalPoints.add(FlSpot(_getTCritical(alpha, df).toDouble(), 0.0));
        break;

      case 'chi-square':
        // Chi-square distribution
        final chiDf = int.tryParse(_dfController.text) ?? 5;
        for (double x = 0.0; x <= chiDf * 3.0; x += 0.5) {
          final y = _chiSquarePDF(x, chiDf);
          spots.add(FlSpot(x, y));
        }
        criticalPoints.add(FlSpot(_getChiSquareCritical(alpha, chiDf), 0.0));
        break;

      case 'f-test':
        // F-distribution (approximation)
        final fDf1 = 5; // numerator df
        final fDf2 = int.tryParse(_dfController.text) ?? 10;
        for (double x = 0.1; x <= 5.0; x += 0.1) {
        final y = _fPDF(x, fDf1.toDouble(), fDf2.toDouble());
          spots.add(FlSpot(x, y));
        }
        criticalPoints.add(FlSpot(_getFCritical(alpha, fDf1, fDf2), 0.0));
        break;

      default:
        break;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 0.1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textTertiary.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.textTertiary.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.abs() < 1 ? value.toStringAsFixed(1) : value.toInt().toString(),
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
              interval: 0.1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toStringAsFixed(1),
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
        lineBarsData: [
          // Distribution curve
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Critical value lines
          ...criticalPoints.map((point) => LineChartBarData(
            spots: [point, FlSpot(point.x, 0.4)],
            isCurved: false,
            color: AppColors.error,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: const [5, 5],
          )),
          // Test statistic marker
          LineChartBarData(
            spots: [FlSpot(statistic, 0.4)],
            isCurved: false,
            color: _getSignificanceColor(),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: _getSignificanceColor(),
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
                  'Test Statistic: ${spot.x.toStringAsFixed(3)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInterpretationCard() {
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
              Icon(Icons.psychology, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Statistical Interpretation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // P-Value Interpretation Scale
          _buildInterpretationScale(),

          const SizedBox(height: 16),

          // Decision Rule
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getSignificanceColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getSignificanceColor().withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.gavel, color: _getSignificanceColor(), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Decision Rule: ${_getDecisionRule()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getSignificanceColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Effect Size Interpretation
          _buildEffectSizeInterpretation(),
        ],
      ),
    );
  }

  Widget _buildInterpretationScale() {
    final p = _pValue!;
    final interpretations = [
      {'range': '0.001 - 0.01', 'meaning': 'Highly significant', 'color': AppColors.success},
      {'range': '0.01 - 0.05', 'meaning': 'Significant', 'color': AppColors.info},
      {'range': '0.05 - 0.10', 'meaning': 'Marginally significant', 'color': AppColors.warning},
      {'range': '> 0.10', 'meaning': 'Not significant', 'color': AppColors.error},
    ];

    String currentLevel = 'Not significant';
    Color currentColor = AppColors.error;

    for (final interp in interpretations) {
      final range = interp['range'] as String;
      final parts = range.split(' - ');
      final min = double.parse(parts[0]);
      final max = double.parse(parts[1]);
      if (p >= min && p <= max) {
        currentLevel = interp['meaning'] as String;
        currentColor = interp['color'] as Color;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: currentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: currentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: currentColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Significance Level: $currentLevel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: currentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectSizeInterpretation() {
    final statistic = double.tryParse(_statisticController.text) ?? 0.0;
    String effectSize = 'Small';
    Color effectColor = AppColors.info;

    if (_testType == 'z-test' || _testType == 't-test') {
      final absStat = statistic.abs();
      if (absStat >= 2.58) {
        effectSize = 'Large';
        effectColor = AppColors.success;
      } else if (absStat >= 1.96) {
        effectSize = 'Medium';
        effectColor = AppColors.info;
      } else {
        effectSize = 'Small';
        effectColor = AppColors.warning;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.equalizer, color: effectColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Effect Size: $effectSize (|${statistic.toStringAsFixed(2)}|)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: effectColor,
              ),
            ),
          ),
        ],
      ),
    );
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
            'CDC Statistical Methods Manual',
            'https://www.cdc.gov/eis/field-epi-manual/chapters/Statistical-Methods.html',
          ),
          const SizedBox(height: 6),
          _buildReferenceButton(
            'WHO Statistical Guidelines',
            'https://www.who.int/publications/i/item/9789241519221',
          ),
          const SizedBox(height: 6),
          _buildReferenceButton(
            'NIST/SEMATECH Handbook',
            'https://www.itl.nist.gov/div898/handbook/',
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

  // Helper methods
  String _getTestTypeDescription() {
    switch (_testType) {
      case 'z-test':
        return 'Tests population mean when σ is known or n > 30. Used for large samples.';
      case 't-test':
        return 'Tests population mean when σ is unknown. Used for small samples (n < 30).';
      case 'chi-square':
        return 'Tests goodness of fit or independence in categorical data.';
      case 'f-test':
        return 'Tests equality of variances between two populations.';
      case 'anova':
        return 'Tests equality of means across multiple groups.';
      default:
        return 'Select a test type to see description.';
    }
  }

  String _getTestStatisticSuffix() {
    switch (_testType) {
      case 'z-test':
        return 'z';
      case 't-test':
        return 't';
      case 'chi-square':
        return 'χ²';
      case 'f-test':
        return 'F';
      case 'anova':
        return 'F';
      default:
        return '';
    }
  }

  void _calculatePValue() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final statistic = double.parse(_statisticController.text);
        final alpha = double.parse(_alphaController.text);
        double pValue = 0.0;

        switch (_testType) {
          case 'z-test':
            pValue = _calculateZPValue(statistic);
            break;
          case 't-test':
            final df = int.parse(_dfController.text);
            pValue = _calculateTPValue(statistic, df);
            break;
          case 'chi-square':
            final df = int.parse(_dfController.text);
            pValue = _calculateChiSquarePValue(statistic, df);
            break;
          case 'f-test':
            final df = int.parse(_dfController.text);
            pValue = _calculateFPValue(statistic, 5, df); // Assuming df1=5
            break;
          case 'anova':
            // Simplified F-test for ANOVA
            final df = int.parse(_dfController.text);
            pValue = _calculateFPValue(statistic, 2, df);
            break;
        }

        final isSignificant = pValue < alpha;
        final significance = isSignificant ? 'Statistically Significant' : 'Not Significant';
        final interpretation = _generateInterpretation(pValue, alpha, isSignificant);

        setState(() {
          _pValue = pValue;
          _significance = significance;
          _interpretation = interpretation;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error calculating p-value: ${e.toString()}';
          _isLoading = false;
        });
      }
    });
  }

  double _calculateZPValue(double z) {
    // Two-tailed test
    return 2 * (1 - _normalCDF(z.abs()));
  }

  double _calculateTPValue(double t, int df) {
    // Two-tailed test
    return 2 * (1 - _tCDF(t.abs(), df));
  }

  double _calculateChiSquarePValue(double chiSquare, int df) {
    // Right-tailed test
    return 1 - _chiSquareCDF(chiSquare, df);
  }

  double _calculateFPValue(double f, int df1, int df2) {
    // Right-tailed test
    return 1 - _fCDF(f.toDouble(), df1.toDouble(), df2.toDouble());
  }

  // Distribution functions
  double _normalPDF(double x) {
    return (1 / math.sqrt(2 * math.pi)) * math.exp(-0.5 * x * x);
  }

  double _normalCDF(double x) {
    // Approximation of standard normal CDF
    return 0.5 * (1 + _erf(x / math.sqrt(2)));
  }

  double _erf(double x) {
    // Approximation of error function
    final a1 = 0.254829592;
    final a2 = -0.284496736;
    final a3 = 1.421413741;
    final a4 = -1.453152027;
    final a5 = 1.061405429;
    final p = 0.3275911;

    final sign = x < 0 ? -1 : 1;
    x = x.abs();

    final t = 1 / (1 + p * x);
    final t2 = t * t;
    final t3 = t2 * t;

    return sign * (1 - (((((a5 * t3 + a4 * t2) + a3 * t) + a2) * t + a1) * t3) * math.exp(-x * x));
  }

  double _tPDF(double t, int df) {
    // Approximation of t-distribution PDF
    if (df >= 30) {
      return _normalPDF(t); // Approximate as normal for large df
    }
    
    final gamma = math.sqrt(df * math.pi) * _gamma((df + 1) / 2) / _gamma(df / 2);
    return gamma * math.pow(1 + (t * t) / df, -(df + 1) / 2);
  }

  double _tCDF(double t, int df) {
    // Approximation of t-distribution CDF
    if (df >= 30) {
      return _normalCDF(t); // Approximate as normal for large df
    }
    
    // Simplified approximation
    return _regularizedIncompleteBeta(df / 2.0, 0.5, df / (df + t * t));
  }

  double _chiSquarePDF(double x, int df) {
    if (x <= 0) return 0;
    
    final gamma = math.pow(2, df / 2) / _gamma(df / 2);
    return gamma * math.pow(x, df / 2 - 1) * math.exp(-x / 2);
  }

  double _chiSquareCDF(double x, int df) {
    if (x <= 0) return 0;
    return _regularizedIncompleteGamma(df / 2.0, x / 2.0);
  }

  double _fPDF(double x, double d1, double d2) {
    if (x <= 0) return 0;
    
    final gamma1 = math.pow(d1, d1 / 2) * math.pow(d2, d2 / 2) / _gamma(d1 / 2) / _gamma(d2 / 2);
    final gamma2 = math.pow(d1 * x / d2, (d1 / 2) - 1) / _gamma((d1 + d2) / 2);
    
    return gamma1 * gamma2 * math.pow(1 + (d1 * x) / d2, -(d1 + d2) / 2);
  }

  double _fCDF(double x, double d1, double d2) {
    if (x <= 0) return 0;
    return _regularizedIncompleteBeta(d1 / 2, (d1 * x) / (d1 * x + d2), d1 / 2);
  }

  // Gamma function approximations
  double _gamma(double x) {
    // Stirling's approximation for gamma function
    if (x < 1) return 1;
    
    return math.sqrt(2 * math.pi / x) * math.pow(x / math.e, x) * (1 + 1 / (12 * x));
  }

  double _regularizedIncompleteBeta(double a, double b, double x) {
    // Simplified approximation for regularized incomplete beta
    if (x <= 0) return 0;
    if (x >= 1) return 1;
    
    // Use series expansion approximation
    return math.pow(x, a) * (1 - x) / (a + b) * (1 + (a - 1) * (1 - x) / (a + b + 1));
  }

  double _regularizedIncompleteGamma(double a, double x) {
    // Simplified approximation for regularized incomplete gamma
    if (x <= 0) return 0;
    
    return 1 - math.exp(-x) * math.pow(x, a - 1) / _gamma(a);
  }

  // Critical value functions
  double _getZCritical(double alpha) {
    // Approximate critical values for standard normal distribution
    if (alpha >= 0.10) return 1.645;
    if (alpha >= 0.05) return 1.960;
    if (alpha >= 0.01) return 2.576;
    if (alpha >= 0.001) return 3.291;
    return 1.960; // Default
  }

  double _getTCritical(double alpha, int df) {
    // Approximate critical values for t-distribution
    if (df >= 30) return _getZCritical(alpha); // Approximate as normal
    
    if (alpha >= 0.10) {
      if (df >= 20) return 1.725;
      if (df >= 10) return 1.812;
      return 2.228;
    }
    if (alpha >= 0.05) {
      if (df >= 20) return 2.086;
      if (df >= 10) return 2.228;
      return 2.771;
    }
    if (alpha >= 0.01) {
      if (df >= 20) return 2.845;
      if (df >= 10) return 3.169;
      return 4.143;
    }
    return 2.771; // Default
  }

  double _getChiSquareCritical(double alpha, int df) {
    // Approximate critical values for chi-square distribution
    if (df >= 100) return df + _getZCritical(alpha) * math.sqrt(2 * df);
    
    // Use approximation for smaller df
    final z = _getZCritical(alpha);
    return df * math.pow(1 - 2 / (9 * df) + z * math.sqrt(2 / (9 * df)), 3).toDouble();
  }

  double _getFCritical(double alpha, int df1, int df2) {
    // Approximate critical values for F-distribution
    final z = _getZCritical(alpha);
    return math.pow(df2 / df1, z * math.sqrt(2 * df1 * df2 / (df1 * (df2 - 2)))).toDouble();
  }

  String _generateInterpretation(double p, double alpha, bool isSignificant) {
    if (p < 0.001) {
      return 'Extremely strong evidence against null hypothesis. This result is highly unlikely to occur by chance alone.';
    } else if (p < 0.01) {
      return 'Very strong evidence against null hypothesis. This result provides compelling evidence for the alternative hypothesis.';
    } else if (p < 0.05) {
      return 'Strong evidence against null hypothesis. This result is statistically significant at the conventional 5% level.';
    } else if (p < 0.10) {
      return 'Moderate evidence against null hypothesis. This result is marginally significant and may warrant further investigation.';
    } else {
      return 'Weak or no evidence against null hypothesis. This result is not statistically significant at conventional levels.';
    }
  }

  String _getDecisionRule() {
    if (_pValue! < 0.001) {
      return 'Reject H₀ (p < 0.001) - Extremely significant';
    } else if (_pValue! < 0.01) {
      return 'Reject H₀ (p < 0.01) - Very significant';
    } else if (_pValue! < 0.05) {
      return 'Reject H₀ (p < 0.05) - Significant';
    } else if (_pValue! < 0.10) {
      return 'Fail to reject H₀ (p ≥ 0.05) - Marginally significant';
    } else {
      return 'Fail to reject H₀ (p ≥ 0.05) - Not significant';
    }
  }

  Color _getSignificanceColor() {
    if (_pValue == null) return AppColors.textSecondary;
    if (_pValue! < 0.001) return AppColors.success;
    if (_pValue! < 0.01) return AppColors.info;
    if (_pValue! < 0.05) return AppColors.primary;
    if (_pValue! < 0.10) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getSignificanceIcon() {
    if (_pValue == null) return Icons.help_outline;
    if (_pValue! < 0.05) return Icons.check_circle_outline;
    return Icons.highlight_off;
  }

  void _reset() {
    _statisticController.clear();
    _sampleSizeController.clear();
    _dfController.clear();
    _alphaController.text = '0.05';
    setState(() {
      _pValue = null;
      _significance = null;
      _interpretation = null;
      _errorMessage = null;
    });
  }

  void _copyResultWithUnit() {
    if (_pValue == null) return;

    final resultText = 'p = ${_pValue!.toStringAsFixed(6)}';
    Clipboard.setData(ClipboardData(text: resultText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $resultText'),
        backgroundColor: _getSignificanceColor(),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearResults() {
    setState(() {
      _pValue = null;
      _significance = null;
      _interpretation = null;
      _errorMessage = null;
    });
  }

  Future<void> _saveResult() async {
    if (_pValue == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('pvalue_history') ?? [];

      final result = {
        'timestamp': DateTime.now().toIso8601String(),
        'testType': _testType,
        'inputs': {
          'statistic': double.parse(_statisticController.text),
          'alpha': double.parse(_alphaController.text),
          if (_sampleSizeController.text.isNotEmpty) 'sampleSize': int.parse(_sampleSizeController.text),
          if (_dfController.text.isNotEmpty) 'degreesOfFreedom': int.parse(_dfController.text),
        },
        'results': {
          'pValue': _pValue,
          'significance': _significance,
          'interpretation': _interpretation,
        },
      };

      history.add(jsonEncode(result));
      
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }
      
      await prefs.setStringList('pvalue_history', history);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('P-value calculation saved to history'),
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
    if (_pValue == null) return;

    ExportModal.show(
      context: context,
      onExportPDF: _exportAsPDF,
      onExportCSV: _exportAsCSV,
      onExportExcel: _exportAsExcel,
      onExportText: _exportAsText,
      onExportPhoto: _captureAndShareResults,
      enablePhoto: true,
    );
  }

  Future<void> _captureAndShareResults() async {
    try {
      final image = await _screenshotController.capture();
      
      if (image != null && mounted) {
        final timestamp = DateTime.now();
        final filename = 'ipc_pvalue_${timestamp.millisecondsSinceEpoch}.png';
        
        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : const Rect.fromLTWH(0, 0, 1, 1);
        await Share.shareXFiles(
          [XFile.fromData(image, name: filename, mimeType: 'image/png')],
          text: 'P-Value Analysis\n'
                'Test: ${_testType.toUpperCase()}\n'
                'P-Value: ${_pValue!.toStringAsFixed(6)}\n'
                'Significance: $_significance\n'
                'Generated: ${timestamp.toString().split('.')[0]}',
          sharePositionOrigin: origin,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing results: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _loadExample() {
    setState(() {
      // Clear all fields first
      _statisticController.clear();
      _sampleSizeController.clear();
      _dfController.clear();
      _alphaController.text = '0.05';

      // Load example based on selected test type
      switch (_testType) {
        case 'z-test':
          // Example: Comparing HAI rates (z = 2.5, n = 100)
          _statisticController.text = '2.5';
          _sampleSizeController.text = '100';
          break;

        case 't-test':
          // Example: Small sample comparison (t = 2.8, df = 15)
          _statisticController.text = '2.8';
          _dfController.text = '15';
          _sampleSizeController.text = '16';
          break;

        case 'chi-square':
          // Example: Independence test (χ² = 8.5, df = 3)
          _statisticController.text = '8.5';
          _dfController.text = '3';
          break;

        case 'f-test':
          // Example: Variance comparison (F = 3.2, df = 20)
          _statisticController.text = '3.2';
          _dfController.text = '20';
          break;

        case 'anova':
          // Example: Multi-group comparison (F = 4.5, df = 3)
          _statisticController.text = '4.5';
          _dfController.text = '3';
          break;
      }
    });

    // Show test-specific message
    String exampleDescription;
    switch (_testType) {
      case 'z-test':
        exampleDescription = 'Comparing HAI rates (z = 2.5, n = 100)';
        break;
      case 't-test':
        exampleDescription = 'Small sample comparison (t = 2.8, df = 15)';
        break;
      case 'chi-square':
        exampleDescription = 'Independence test (χ² = 8.5, df = 3)';
        break;
      case 'f-test':
        exampleDescription = 'Variance comparison (F = 3.2, df = 20)';
        break;
      case 'anova':
        exampleDescription = 'Multi-group comparison (F = 4.5, df = 3)';
        break;
      default:
        exampleDescription = 'Example parameters loaded';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded: $exampleDescription'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
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
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _exportAsPDF() async {
    if (_pValue == null) return;

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'P-Value Calculator',
      inputs: {
        'Test Type': _testType.toUpperCase(),
        'Test Statistic': _statisticController.text,
        'Significance Level (α)': _alphaController.text,
        'Degrees of Freedom': _dfController.text.isNotEmpty ? _dfController.text : 'N/A',
      },
      results: {
        'P-Value': _pValue!.toStringAsFixed(6),
        'Significance': _interpretation ?? 'N/A',
      },
      interpretation: _interpretation,
      references: [
        'CDC Statistical Methods',
        'https://www.cdc.gov/csels/dsepd/ss1978/lesson3/section5.html',
      ],
    );
  }

  Future<void> _exportAsExcel() async {
    if (_pValue == null) return;

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'P-Value Calculator',
      inputs: {
        'Test Type': _testType.toUpperCase(),
        'Test Statistic': _statisticController.text,
        'Significance Level (α)': _alphaController.text,
        'Degrees of Freedom': _dfController.text.isNotEmpty ? _dfController.text : 'N/A',
      },
      results: {
        'P-Value': _pValue!.toStringAsFixed(6),
        'Significance': _interpretation ?? 'N/A',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    if (_pValue == null) return;

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'P-Value Calculator',
      inputs: {
        'Test Type': _testType.toUpperCase(),
        'Test Statistic': _statisticController.text,
        'Significance Level (α)': _alphaController.text,
        'Degrees of Freedom': _dfController.text.isNotEmpty ? _dfController.text : 'N/A',
      },
      results: {
        'P-Value': _pValue!.toStringAsFixed(6),
        'Significance': _interpretation ?? 'N/A',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    if (_pValue == null) return;

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'P-Value Calculator',
      inputs: {
        'Test Type': _testType.toUpperCase(),
        'Test Statistic': _statisticController.text,
        'Significance Level (α)': _alphaController.text,
        'Degrees of Freedom': _dfController.text.isNotEmpty ? _dfController.text : 'N/A',
      },
      results: {
        'P-Value': _pValue!.toStringAsFixed(6),
        'Significance': _interpretation ?? 'N/A',
      },
      interpretation: _interpretation,
      references: [
        'CDC Statistical Methods',
        'https://www.cdc.gov/csels/dsepd/ss1978/lesson3/section5.html',
        'WHO Statistical Analysis',
        'https://www.who.int/data/gho/data/themes/topics',
      ],
    );
  }
}

