import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';

class SampleSizeCalculator extends ConsumerStatefulWidget {
  const SampleSizeCalculator({super.key});

  @override
  ConsumerState<SampleSizeCalculator> createState() => _SampleSizeCalculatorState();
}

class _SampleSizeCalculatorState extends ConsumerState<SampleSizeCalculator> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final _formKey = GlobalKey<FormState>();

  // Study type selection
  String _studyType = 'proportion';
  final List<String> _studyTypes = [
    'proportion',
    'mean',
    'cohort',
    'case-control',
  ];

  // Input controllers
  final _confidenceController = TextEditingController(text: '0.95');
  final _powerController = TextEditingController(text: '0.80');
  final _proportionController = TextEditingController(text: '0.5');
  final _baselineController = TextEditingController(text: '0.3');
  final _effectSizeController = TextEditingController(text: '0.2');
  final _stdDevController = TextEditingController(text: '1.0');
  final _ratioController = TextEditingController(text: '1.0');
  final _eventsController = TextEditingController(text: '10');
  
  // Results
  double? _sampleSize;
  double? _controlSize;
  double? _totalSize;
  String? _interpretation;
  bool _isLoading = false;
  String? _errorMessage;

  // Power curve data
  final List<PowerPoint> _powerCurve = [];

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Determines the minimum number of subjects needed to detect a specified effect.',
    formula: 'n = (Zα/2 + Zβ)² × 2p(1-p) / d²',
    example: 'n = 384 for 5% precision, 95% confidence, 50% proportion.',
    interpretation: 'Larger samples provide more precise estimates and higher power.',
    whenUsed: 'Step 1-2 (study design, outbreak investigation planning).',
    inputDataType: 'Confidence level, power, expected effect size, baseline values.',
    references: [
      Reference(
        title: 'CDC Sample Size Calculator',
        url: 'https://www.cdc.gov/epiinfo/user-guide/sample-size.html',
      ),
      Reference(
        title: 'WHO Sample Size Guidelines',
        url: 'https://www.who.int/publications/i/item/9789241500208',
      ),
      Reference(
        title: 'APIC Outbreak Investigation Guide',
        url: 'https://apic.org/Resource_/TinyMceFileManager/Advocacy-PDFs/APIC_Outbreak_Investigation_Guide.pdf',
      ),
    ],
  );

  @override
  void dispose() {
    _confidenceController.dispose();
    _powerController.dispose();
    _proportionController.dispose();
    _baselineController.dispose();
    _effectSizeController.dispose();
    _stdDevController.dispose();
    _ratioController.dispose();
    _eventsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Sample Size & Power Calculator',
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

              // Study Type Selection
              _buildStudyTypeCard(),
              const SizedBox(height: 24),

              // Input Parameters
              _buildInputCard(),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 24),

              // Results Section
              if (_sampleSize != null) ...[
                _buildResultsCard(),
                const SizedBox(height: 24),

                // Power Analysis Chart
                _buildPowerAnalysisChart(),
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
              Icons.group_add_outlined,
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
                  'Sample Size & Power Calculator',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Optimize study design with power analysis and sample size determination',
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

  Widget _buildStudyTypeCard() {
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
            'Study Type',
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
            children: _studyTypes.map((studyType) {
              final isSelected = _studyType == studyType;
              return ChoiceChip(
                label: Text(studyType.split('-').map((word) => 
                  word[0].toUpperCase() + word.substring(1)).join('-')),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _studyType = studyType;
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

          // Study type descriptions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStudyTypeDescription(),
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
            'Study Parameters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Common parameters
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _confidenceController,
                  decoration: InputDecoration(
                    labelText: 'Confidence Level',
                    hintText: '0.95',
                    suffixText: '(95%)',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent_outlined, color: AppColors.primary),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^0?\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final conf = double.tryParse(value);
                    if (conf == null || conf <= 0 || conf >= 1) {
                      return 'Between 0 and 1';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _powerController,
                  decoration: InputDecoration(
                    labelText: 'Power',
                    hintText: '0.80',
                    suffixText: '(80%)',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bolt_outlined, color: AppColors.primary),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^0?\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final power = double.tryParse(value);
                    if (power == null || power <= 0 || power >= 1) {
                      return 'Between 0 and 1';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Study-specific parameters
          switch (_studyType) {
            'proportion' => _buildProportionInputs(),
            'mean' => _buildMeanInputs(),
            'cohort' => _buildCohortInputs(),
            'case-control' => _buildCaseControlInputs(),
            String() => Container(),
          },
        ],
      ),
    );
  }

  Widget _buildProportionInputs() {
    return Column(
      children: [
        TextFormField(
          controller: _proportionController,
          decoration: InputDecoration(
            labelText: 'Expected Proportion',
            hintText: '0.5',
            suffixText: '(50%)',
            border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.donut_large_outlined, color: AppColors.primary),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^0?\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final prop = double.tryParse(value);
            if (prop == null || prop < 0 || prop > 1) {
              return 'Between 0 and 1';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _effectSizeController,
          decoration: InputDecoration(
            labelText: 'Precision (Margin of Error)',
            hintText: '0.05',
            suffixText: '(±5%)',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.gps_fixed_outlined, color: AppColors.primary),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^0?\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final effect = double.tryParse(value);
            if (effect == null || effect <= 0 || effect >= 1) {
              return 'Between 0 and 1';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMeanInputs() {
    return Column(
      children: [
        TextFormField(
          controller: _stdDevController,
          decoration: InputDecoration(
            labelText: 'Standard Deviation',
            hintText: '1.0',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.show_chart, color: AppColors.primary),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final sd = double.tryParse(value);
            if (sd == null || sd <= 0) {
              return 'Must be > 0';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _effectSizeController,
          decoration: InputDecoration(
            labelText: 'Effect Size',
            hintText: '0.5',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.compare_arrows, color: AppColors.primary),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final effect = double.tryParse(value);
            if (effect == null || effect <= 0) {
              return 'Must be > 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCohortInputs() {
    return Column(
      children: [
        TextFormField(
          controller: _baselineController,
          decoration: InputDecoration(
            labelText: 'Baseline Risk',
            hintText: '0.3',
            suffixText: '(30%)',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.trending_down, color: AppColors.primary),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^0?\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final baseline = double.tryParse(value);
            if (baseline == null || baseline < 0 || baseline > 1) {
              return 'Between 0 and 1';
            }
            return null;
          },
        ),
        const SizedBox(width: 16),
        const SizedBox(height: 16),
        TextFormField(
          controller: _effectSizeController,
          decoration: InputDecoration(
            labelText: 'Relative Risk to Detect',
            hintText: '2.0',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.trending_up, color: AppColors.primary),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final rr = double.tryParse(value);
            if (rr == null || rr <= 1) {
              return 'Must be > 1';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ratioController,
          decoration: InputDecoration(
            labelText: 'Control:Exposure Ratio',
            hintText: '1.0',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.balance, color: AppColors.primary),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final ratio = double.tryParse(value);
            if (ratio == null || ratio <= 0) {
              return 'Must be > 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCaseControlInputs() {
    return Column(
      children: [
        TextFormField(
          controller: _baselineController,
          decoration: InputDecoration(
            labelText: 'Exposure in Controls',
            hintText: '0.3',
            suffixText: '(30%)',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.group, color: AppColors.primary),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^0?\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final exposure = double.tryParse(value);
            if (exposure == null || exposure < 0 || exposure > 1) {
              return 'Between 0 and 1';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _effectSizeController,
          decoration: InputDecoration(
            labelText: 'Odds Ratio to Detect',
            hintText: '2.0',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.compare_arrows, color: AppColors.primary),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final or = double.tryParse(value);
            if (or == null || or <= 1) {
              return 'Must be > 1';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ratioController,
          decoration: InputDecoration(
            labelText: 'Control:Case Ratio',
            hintText: '1.0',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.balance, color: AppColors.primary),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final ratio = double.tryParse(value);
            if (ratio == null || ratio <= 0) {
              return 'Must be > 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _calculateSampleSize,
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
            label: Text(_isLoading ? 'Calculating...' : 'Calculate Sample Size'),
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
                'Sample Size Calculation Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sample Size Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Required Sample Size',
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
                      _sampleSize!.ceil().toString(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'subjects',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
                  'per group',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Group sizes for comparative studies
          if (_studyType == 'cohort' || _studyType == 'case-control')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.groups, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Group Sizes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getGroupSizesText(),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Total sample size
          if (_totalSize != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.summarize, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Total Sample Size: ${_totalSize!.ceil()} subjects',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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

  Widget _buildPowerAnalysisChart() {
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
              Icon(Icons.insights, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Power Analysis',
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
              child: _buildPowerChart(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerChart() {
    if (_powerCurve.isEmpty) {
      return const Center(
        child: Text(
          'Calculate sample size to see power analysis',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 0.2,
          verticalInterval: 50,
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
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 50,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
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
        maxX: _sampleSize! * 2,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          // Power curve
          LineChartBarData(
            spots: _powerCurve.map((point) => FlSpot(point.sampleSize, point.power)).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primary],
            ),
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
          // Target power line
          LineChartBarData(
            spots: [
              FlSpot(0, double.parse(_powerController.text)),
              FlSpot(_sampleSize! * 2, double.parse(_powerController.text)),
            ],
            isCurved: false,
            color: AppColors.success,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
          ),
          // Required sample size marker
          LineChartBarData(
            spots: [FlSpot(_sampleSize!, double.parse(_powerController.text))],
            isCurved: false,
            color: AppColors.success,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: AppColors.success,
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
                  'n: ${spot.x.toInt()}\nPower: ${(spot.y * 100).toInt()}%',
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
              Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Interpretation & Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sample size interpretation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sample Size Interpretation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _interpretation ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Practical considerations
          _buildPracticalConsiderations(),

          const SizedBox(height: 16),

          // Cost implications
          _buildCostImplications(),
        ],
      ),
    );
  }

  Widget _buildPracticalConsiderations() {
    final considerations = _getPracticalConsiderations();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: AppColors.warning, size: 16),
              const SizedBox(width: 4),
              Text(
                'Practical Considerations',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...considerations.map((consideration) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.arrow_right, size: 12, color: AppColors.warning),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    consideration,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCostImplications() {
    final costLevel = _getCostLevel();
    final costColor = _getCostColor();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: costColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: costColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_money, color: costColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cost Implications: $costLevel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: costColor,
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
            'WHO Sample Size Guidelines',
            'https://www.who.int/publications/i/item/9789241500208',
          ),
          const SizedBox(height: 6),
          _buildReferenceButton(
            'CDC Sample Size Calculator',
            'https://www.cdc.gov/epiinfo/user-guide/sample-size.html',
          ),
          const SizedBox(height: 6),
          _buildReferenceButton(
            'OpenEpi Sample Size Calculator',
            'https://www.openepi.com/SampleSize/SSCohort.html',
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
  String _getStudyTypeDescription() {
    switch (_studyType) {
      case 'proportion':
        return 'Calculate sample size for estimating a single proportion with specified precision.';
      case 'mean':
        return 'Calculate sample size for detecting a difference in means between two groups.';
      case 'cohort':
        return 'Calculate sample size for cohort studies to detect relative risk.';
      case 'case-control':
        return 'Calculate sample size for case-control studies to detect odds ratio.';
      default:
        return 'Select a study type to see description.';
    }
  }

  void _calculateSampleSize() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final confidence = double.parse(_confidenceController.text);
        final power = double.parse(_powerController.text);
        
        double sampleSize = 0.0;
        double controlSize = 0.0;
        double totalSize = 0.0;

        switch (_studyType) {
          case 'proportion':
            final proportion = double.parse(_proportionController.text);
            final effectSize = double.parse(_effectSizeController.text);
            sampleSize = _calculateProportionSampleSize(confidence, power, proportion, effectSize);
            break;

          case 'mean':
            final stdDev = double.parse(_stdDevController.text);
            final effectSize = double.parse(_effectSizeController.text);
            sampleSize = _calculateMeanSampleSize(confidence, power, stdDev, effectSize);
            controlSize = sampleSize;
            break;

          case 'cohort':
            final baseline = double.parse(_baselineController.text);
            final relativeRisk = double.parse(_effectSizeController.text);
            final ratio = double.parse(_ratioController.text);
            sampleSize = _calculateCohortSampleSize(confidence, power, baseline, relativeRisk, ratio);
            controlSize = sampleSize * ratio;
            break;

          case 'case-control':
            final exposure = double.parse(_baselineController.text);
            final oddsRatio = double.parse(_effectSizeController.text);
            final ratio = double.parse(_ratioController.text);
            sampleSize = _calculateCaseControlSampleSize(confidence, power, exposure, oddsRatio, ratio);
            controlSize = sampleSize * ratio;
            break;
        }

        totalSize = sampleSize + controlSize;

        // Generate power curve
        _generatePowerCurve(sampleSize, power);

        final interpretation = _generateInterpretation(sampleSize, totalSize);

        setState(() {
          _sampleSize = sampleSize;
          _controlSize = controlSize;
          _totalSize = totalSize;
          _interpretation = interpretation;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error calculating sample size: ${e.toString()}';
          _isLoading = false;
        });
      }
    });
  }

  double _calculateProportionSampleSize(double confidence, double power, double proportion, double effectSize) {
    final zAlpha = _getZScore(confidence);
    final zBeta = _getZScore(power);
    
    return math.pow(zAlpha + zBeta, 2) * proportion * (1 - proportion) / math.pow(effectSize, 2);
  }

  double _calculateMeanSampleSize(double confidence, double power, double stdDev, double effectSize) {
    final zAlpha = _getZScore(confidence);
    final zBeta = _getZScore(power);
    
    return 2 * math.pow(zAlpha + zBeta, 2) * math.pow(stdDev, 2) / math.pow(effectSize, 2);
  }

  double _calculateCohortSampleSize(double confidence, double power, double baseline, double relativeRisk, double ratio) {
    final zAlpha = _getZScore(confidence);
    final zBeta = _getZScore(power);
    
    final p1 = baseline;
    final p2 = baseline * relativeRisk;
    final pBar = (p1 + p2) / 2;
    
    final numerator = math.pow(zAlpha * math.sqrt(2 * pBar * (1 - pBar) * (1 + 1/ratio)) + 
                           zBeta * math.sqrt(p1 * (1 - p1) + p2 * (1 - p2) / ratio), 2);
    final denominator = math.pow(p1 - p2, 2);
    
    return numerator / denominator;
  }

  double _calculateCaseControlSampleSize(double confidence, double power, double exposure, double oddsRatio, double ratio) {
    final zAlpha = _getZScore(confidence);
    final zBeta = _getZScore(power);
    
    final p0 = exposure;
    final p1 = (oddsRatio * p0) / (1 - p0 + oddsRatio * p0);
    final pBar = (p0 + p1) / 2;
    
    final numerator = math.pow(zAlpha * math.sqrt((1 + 1/ratio) * pBar * (1 - pBar)) + 
                           zBeta * math.sqrt(p0 * (1 - p0) + p1 * (1 - p1) / ratio), 2);
    final denominator = math.pow(p1 - p0, 2);
    
    return numerator / denominator;
  }

  double _getZScore(double probability) {
    // Approximate inverse normal distribution
    if (probability <= 0.5) {
      return -_getZScore(1 - probability);
    }
    
    if (probability >= 0.999) return 3.09;
    if (probability >= 0.995) return 2.81;
    if (probability >= 0.99) return 2.58;
    if (probability >= 0.975) return 1.96;
    if (probability >= 0.95) return 1.645;
    if (probability >= 0.90) return 1.28;
    if (probability >= 0.85) return 1.04;
    if (probability >= 0.80) return 0.84;
    
    return 0.674; // For 0.75
  }

  void _generatePowerCurve(double requiredSampleSize, double targetPower) {
    _powerCurve.clear();
    
    for (double n = requiredSampleSize * 0.2; n <= requiredSampleSize * 2; n += requiredSampleSize * 0.1) {
      final power = _calculatePowerForSampleSize(n);
      _powerCurve.add(PowerPoint(n, power));
    }
  }

  double _calculatePowerForSampleSize(double sampleSize) {
    // Simplified power calculation based on sample size
    final requiredSize = _sampleSize ?? sampleSize;
    final targetPower = double.parse(_powerController.text);
    
    // Power increases with sample size following a sigmoid curve
    final ratio = sampleSize / requiredSize;
    return targetPower * (1 - math.exp(-2 * (ratio - 0.5)));
  }

  String _getGroupSizesText() {
    if (_controlSize == null) return '';
    
    final group1 = _sampleSize!.ceil();
    final group2 = _controlSize!.ceil();
    
    switch (_studyType) {
      case 'cohort':
        return 'Exposed: $group1, Unexposed: $group2';
      case 'case-control':
        return 'Cases: $group1, Controls: $group2';
      default:
        return 'Group 1: $group1, Group 2: $group2';
    }
  }

  String _generateInterpretation(double sampleSize, double totalSize) {
    if (totalSize < 100) {
      return 'Small study requiring ${totalSize.ceil()} subjects. Feasible for most settings but may have limited generalizability.';
    } else if (totalSize < 500) {
      return 'Moderate study requiring ${totalSize.ceil()} subjects. Well-suited for single-center investigations.';
    } else if (totalSize < 1000) {
      return 'Large study requiring ${totalSize.ceil()} subjects. Provides good statistical power and generalizability.';
    } else {
      return 'Very large study requiring ${totalSize.ceil()} subjects. Excellent power but may be resource-intensive. Consider multi-center collaboration.';
    }
  }

  List<String> _getPracticalConsiderations() {
    final considerations = <String>[];
    final totalSize = _totalSize ?? 0;
    
    if (totalSize > 1000) {
      considerations.add('Consider multi-center collaboration');
      considerations.add('Plan for extensive data management');
    }
    
    if (_studyType == 'case-control') {
      considerations.add('Ensure adequate case identification');
      considerations.add('Match controls appropriately');
    }
    
    if (_studyType == 'cohort') {
      considerations.add('Plan for long-term follow-up');
      considerations.add('Minimize loss to follow-up');
    }
    
    considerations.add('Account for 10-20% non-response/attrition');
    considerations.add('Ensure adequate data collection resources');
    
    return considerations;
  }

  String _getCostLevel() {
    final totalSize = _totalSize ?? 0;
    
    if (totalSize < 100) return 'Low';
    if (totalSize < 500) return 'Moderate';
    if (totalSize < 1000) return 'High';
    return 'Very High';
  }

  Color _getCostColor() {
    final level = _getCostLevel();
    switch (level) {
      case 'Low':
        return AppColors.success;
      case 'Moderate':
        return AppColors.info;
      case 'High':
        return AppColors.warning;
      case 'Very High':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _reset() {
    _confidenceController.text = '0.95';
    _powerController.text = '0.80';
    _proportionController.text = '0.5';
    _baselineController.text = '0.3';
    _effectSizeController.text = '0.2';
    _stdDevController.text = '1.0';
    _ratioController.text = '1.0';
    _eventsController.text = '10';

    setState(() {
      _sampleSize = null;
      _controlSize = null;
      _totalSize = null;
      _interpretation = null;
      _powerCurve.clear();
      _errorMessage = null;
    });
  }

  void _copyResultWithUnit() {
    if (_sampleSize == null) return;

    final resultText = 'N = ${_sampleSize!.ceil()} subjects per group';
    Clipboard.setData(ClipboardData(text: resultText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $resultText'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearResults() {
    setState(() {
      _sampleSize = null;
      _controlSize = null;
      _totalSize = null;
      _interpretation = null;
      _powerCurve.clear();
      _errorMessage = null;
    });
  }

  Future<void> _saveResult() async {
    if (_sampleSize == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('samplesize_history') ?? [];

      final result = {
        'timestamp': DateTime.now().toIso8601String(),
        'studyType': _studyType,
        'inputs': {
          'confidence': double.parse(_confidenceController.text),
          'power': double.parse(_powerController.text),
          'proportion': _proportionController.text,
          'baseline': _baselineController.text,
          'effectSize': _effectSizeController.text,
          'stdDev': _stdDevController.text,
          'ratio': _ratioController.text,
        },
        'results': {
          'sampleSize': _sampleSize,
          'controlSize': _controlSize,
          'totalSize': _totalSize,
          'interpretation': _interpretation,
        },
      };

      history.add(jsonEncode(result));
      
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }
      
      await prefs.setStringList('samplesize_history', history);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample size calculation saved to history'),
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
    if (_sampleSize == null) return;

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
      // Load example based on selected study type
      switch (_studyType) {
        case 'proportion':
          // Example: Estimating HAI prevalence (expected 15%, precision ±5%)
          _proportionController.text = '0.15';
          _effectSizeController.text = '0.05';
          _confidenceController.text = '0.95';
          _powerController.text = '0.80';
          break;

        case 'mean':
          // Example: Comparing hand hygiene compliance scores (SD=15, detect 10-point difference)
          _stdDevController.text = '15';
          _effectSizeController.text = '10';
          _confidenceController.text = '0.95';
          _powerController.text = '0.80';
          break;

        case 'cohort':
          // Example: Risk of CLABSI (baseline 30%, detect 20% reduction)
          _baselineController.text = '0.30';
          _effectSizeController.text = '0.20';
          _confidenceController.text = '0.95';
          _powerController.text = '0.80';
          _ratioController.text = '1';
          break;

        case 'case-control':
          // Example: Risk factor for MRSA (baseline exposure 40%, OR=2.5)
          _baselineController.text = '0.40';
          _effectSizeController.text = '2.5';
          _confidenceController.text = '0.95';
          _powerController.text = '0.80';
          _ratioController.text = '1';
          break;
      }
    });

    // Show study-specific message
    String exampleDescription;
    switch (_studyType) {
      case 'proportion':
        exampleDescription = 'Estimating HAI prevalence (expected 15%, precision ±5%)';
        break;
      case 'mean':
        exampleDescription = 'Comparing hand hygiene compliance scores (SD=15, detect 10-point difference)';
        break;
      case 'cohort':
        exampleDescription = 'Risk of CLABSI (baseline 30%, detect 20% reduction)';
        break;
      case 'case-control':
        exampleDescription = 'Risk factor for MRSA (baseline exposure 40%, OR=2.5)';
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
    if (_sampleSize == null) return;

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Sample Size Calculator',
      inputs: {
        'Study Type': _studyType.split('-').map((word) => word[0].toUpperCase() + word.substring(1)).join('-'),
        'Confidence Level': '${(double.parse(_confidenceController.text) * 100).toInt()}%',
        'Power': '${(double.parse(_powerController.text) * 100).toInt()}%',
        'Effect Size': _effectSizeController.text,
      },
      results: {
        'Required Sample Size': '${_sampleSize!.ceil()} subjects',
        'Power': '${(double.parse(_powerController.text) * 100).toInt()}%',
      },
      interpretation: _interpretation,
      references: [
        'CDC Sample Size Determination',
        'https://www.cdc.gov/csels/dsepd/ss1978/lesson3/section6.html',
      ],
    );
  }

  Future<void> _exportAsExcel() async {
    if (_sampleSize == null) return;

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Sample Size Calculator',
      inputs: {
        'Study Type': _studyType.split('-').map((word) => word[0].toUpperCase() + word.substring(1)).join('-'),
        'Confidence Level': '${(double.parse(_confidenceController.text) * 100).toInt()}%',
        'Power': '${(double.parse(_powerController.text) * 100).toInt()}%',
        'Effect Size': _effectSizeController.text,
      },
      results: {
        'Required Sample Size': '${_sampleSize!.ceil()} subjects',
        'Power': '${(double.parse(_powerController.text) * 100).toInt()}%',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    if (_sampleSize == null) return;

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Sample Size Calculator',
      inputs: {
        'Study Type': _studyType.split('-').map((word) => word[0].toUpperCase() + word.substring(1)).join('-'),
        'Confidence Level': '${(double.parse(_confidenceController.text) * 100).toInt()}%',
        'Power': '${(double.parse(_powerController.text) * 100).toInt()}%',
        'Effect Size': _effectSizeController.text,
      },
      results: {
        'Required Sample Size': '${_sampleSize!.ceil()} subjects',
        'Power': '${(double.parse(_powerController.text) * 100).toInt()}%',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    if (_sampleSize == null) return;

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Sample Size Calculator',
      inputs: {
        'Study Type': _studyType.split('-').map((word) => word[0].toUpperCase() + word.substring(1)).join('-'),
        'Confidence Level': '${(double.parse(_confidenceController.text) * 100).toInt()}%',
        'Power': '${(double.parse(_powerController.text) * 100).toInt()}%',
        'Effect Size': _effectSizeController.text,
      },
      results: {
        'Required Sample Size': '${_sampleSize!.ceil()} subjects',
        'Power': '${(double.parse(_powerController.text) * 100).toInt()}%',
      },
      interpretation: _interpretation,
      references: [
        'CDC Sample Size Determination',
        'https://www.cdc.gov/eis/field-epi-manual/chapters/Sample-Size.html',
      ],
    );
  }
}

// Data class for power curve points
class PowerPoint {
  final double sampleSize;
  final double power;

  PowerPoint(this.sampleSize, this.power);
}
