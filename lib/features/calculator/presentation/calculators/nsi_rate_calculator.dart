import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../outbreak/data/models/history_entry.dart';
import '../../../outbreak/data/repositories/history_repository.dart';

class NSIRateCalculator extends ConsumerStatefulWidget {
  const NSIRateCalculator({super.key});

  @override
  ConsumerState<NSIRateCalculator> createState() => _NSIRateCalculatorState();
}

class _NSIRateCalculatorState extends ConsumerState<NSIRateCalculator> {
  final _nsiCasesController = TextEditingController();
  final _hcwsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedTimePeriod = 'Annually';
  String _selectedDepartment = 'All';
  double? _rate;
  double? _lowerCI;
  double? _upperCI;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isCalculated = false;

  final List<String> _timePeriods = ['Monthly', 'Quarterly', 'Annually'];
  final List<String> _departments = ['All', 'ICU', 'OR', 'ER', 'Lab', 'General Ward'];

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'The Needlestick Injury (NSI) Rate measures the occurrence of needlestick and sharps injuries among healthcare workers per 1,000 HCWs. This critical occupational health metric tracks workplace safety and bloodborne pathogen exposure risk.',
    formula: '(Number of NSI × 1,000) / Total Healthcare Workers',
    example: '8 needlestick injuries among 400 HCWs → 20 per 1,000 HCWs',
    interpretation: 'Lower rates indicate effective sharps safety programs and proper disposal practices. Rates above benchmarks require investigation of injury circumstances, safety device usage, training gaps, and reporting barriers.',
    whenUsed: 'Use this calculator to monitor occupational sharps injuries in your facility. Essential for tracking workplace safety, evaluating safety device effectiveness, comparing performance against benchmarks, and meeting regulatory reporting requirements. Calculate monthly, quarterly, or annually for occupational health surveillance.',
    inputDataType: 'Number of needlestick/sharps injuries and total number of healthcare workers for the surveillance period. Specify time period (monthly, quarterly, annually) and department for targeted analysis.',
    references: [
      Reference(
        title: 'CDC Sharps Safety Workbook',
        url: 'https://www.cdc.gov/sharpssafety/resources.html',
      ),
      Reference(
        title: 'OSHA Bloodborne Pathogens Standard',
        url: 'https://www.osha.gov/bloodborne-pathogens',
      ),
      Reference(
        title: 'WHO Guidelines on Injection Safety',
        url: 'https://www.who.int/teams/integrated-health-services/infection-prevention-control/injection-safety',
      ),
      Reference(
        title: 'NIOSH Preventing Needlestick Injuries',
        url: 'https://www.cdc.gov/niosh/topics/bbp/emergnedl.html',
      ),
    ],
  );

  @override
  void dispose() {
    _nsiCasesController.dispose();
    _hcwsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('NSI Rate'),
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildFormulaCard(),
              const SizedBox(height: 16),
              _buildQuickGuideButton(),
              const SizedBox(height: 16),
              _buildLoadExampleButton(),
              const SizedBox(height: 16),
              _buildTimePeriodDropdown(),
              const SizedBox(height: 16),
              _buildDepartmentDropdown(),
              const SizedBox(height: 16),
              _buildInputCard(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_isCalculated) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
                const SizedBox(height: 16),
                _buildNSIPreventionCard(),
              ],

              const SizedBox(height: 24),

              // References Section - Always visible
              _buildReferences(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: AppColors.error, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Needlestick Injury Rate',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Track occupational sharps injuries per 1,000 healthcare workers',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
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
              Icon(
                Icons.calculate_outlined,
                color: AppColors.info,
                size: 20,
              ),
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
                    r'\frac{\text{Number of NSI} \times 1{,}000}{\text{Total Healthcare Workers}}',
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

  Widget _buildTimePeriodDropdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Period',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTimePeriod,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _timePeriods.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimePeriod = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _departments.map((dept) {
                return DropdownMenuItem(
                  value: dept,
                  child: Text(dept),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input Values',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nsiCasesController,
              decoration: InputDecoration(
                labelText: 'Number of NSI',
                hintText: 'Enter number of needlestick injuries',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.medical_services),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of NSI';
                }
                final number = int.tryParse(value);
                if (number == null || number < 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hcwsController,
              decoration: InputDecoration(
                labelText: 'Total Healthcare Workers',
                hintText: 'Enter total number of HCWs',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total HCWs';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number greater than 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _calculate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Calculate',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final nsiCases = int.parse(_nsiCasesController.text);
      final totalHCWs = int.parse(_hcwsController.text);

      // Calculate rate per 1,000 HCWs
      final rate = (nsiCases * 1000) / totalHCWs;

      // Calculate 95% Poisson confidence interval
      final lowerCI = _calculatePoissonLowerCI(nsiCases) * 1000 / totalHCWs;
      final upperCI = _calculatePoissonUpperCI(nsiCases) * 1000 / totalHCWs;

      setState(() {
        _rate = rate;
        _lowerCI = lowerCI;
        _upperCI = upperCI;
        _interpretation = _getInterpretation(rate);
        _benchmark = _getBenchmark(rate);
        _action = _getAction(rate);
        _isCalculated = true;
      });

      _saveToHistory();
    }
  }

  double _calculatePoissonLowerCI(int cases) {
    if (cases == 0) return 0.0;
    return (cases * pow(1 - 1 / (9 * cases) - 1.96 / (3 * sqrt(cases)), 3)).toDouble();
  }

  double _calculatePoissonUpperCI(int cases) {
    return ((cases + 1) * pow(1 - 1 / (9 * (cases + 1)) + 1.96 / (3 * sqrt(cases + 1)), 3)).toDouble();
  }

  String _getInterpretation(double rate) {
    if (rate < 5) {
      return 'Excellent sharps safety performance. NSI rate is below 5 per 1,000 HCWs, indicating effective safety device usage, proper disposal practices, and strong safety culture.';
    } else if (rate < 10) {
      return 'Acceptable sharps safety performance. NSI rate is within acceptable range (5-10 per 1,000 HCWs), but continued vigilance and improvement efforts are recommended.';
    } else if (rate < 20) {
      return 'High NSI rate. Rate exceeds acceptable benchmarks (10-20 per 1,000 HCWs). Immediate investigation of injury circumstances, safety device effectiveness, and training gaps is required.';
    } else {
      return 'Very high NSI rate. Rate significantly exceeds benchmarks (>20 per 1,000 HCWs). Urgent comprehensive review of sharps safety program, device selection, disposal practices, and staff training is essential.';
    }
  }

  String _getBenchmark(double rate) {
    if (rate < 5) {
      return '<5 per 1,000 HCWs (Excellent)';
    } else if (rate < 10) {
      return '5-10 per 1,000 HCWs (Acceptable)';
    } else if (rate < 20) {
      return '10-20 per 1,000 HCWs (High - Action Required)';
    } else {
      return '>20 per 1,000 HCWs (Very High - Urgent Action)';
    }
  }

  String _getAction(double rate) {
    if (rate < 5) {
      return 'Maintain current sharps safety practices. Continue staff education, monitor compliance with safety device usage, and ensure proper sharps disposal. Recognize and reinforce positive safety behaviors.';
    } else if (rate < 10) {
      return 'Review sharps safety protocols and staff training. Assess safety device effectiveness, evaluate disposal container placement, and reinforce proper handling techniques. Consider targeted interventions in high-risk areas.';
    } else if (rate < 20) {
      return 'Conduct comprehensive sharps safety assessment. Investigate injury circumstances, evaluate safety device selection and usage, review disposal practices, and implement immediate corrective actions. Enhance staff training and supervision.';
    } else {
      return 'Initiate urgent sharps safety program review. Form multidisciplinary team to investigate root causes, evaluate all safety devices, assess training effectiveness, and implement comprehensive corrective action plan. Consider engaging external sharps safety experts.';
    }
  }

  void _loadExample() {
    setState(() {
      _selectedTimePeriod = 'Annually';
      _selectedDepartment = 'All';
      _nsiCasesController.text = '8';
      _hcwsController.text = '400';
    });
  }

  Widget _buildResultsCard() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        _saveResult();
                      },
                      tooltip: 'Save Result',
                      color: AppColors.primary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _showExportModal,
                      tooltip: 'Export',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildResultRow('NSI Rate', '${_rate!.toStringAsFixed(2)} per 1,000 HCWs', Icons.medical_services),
            const SizedBox(height: 12),
            _buildResultRow('95% CI', '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}', Icons.show_chart),
            const SizedBox(height: 12),
            _buildResultRow('Time Period', _selectedTimePeriod, Icons.calendar_today),
            const SizedBox(height: 12),
            _buildResultRow('Department', _selectedDepartment, Icons.business),
            const SizedBox(height: 12),
            _buildResultRow('Benchmark', _benchmark!, Icons.flag),
            const Divider(height: 32),
            Text(
              'Interpretation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _interpretation!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
            const Divider(height: 32),
            Text(
              'Recommended Action',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _action!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNSIPreventionCard() {
    return Card(
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.warning, size: 24),
                const SizedBox(width: 12),
                Text(
                  'NSI Prevention Guidelines',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPreventionSection(
              'Engineering Controls',
              '• Use safety-engineered sharps devices\n• Ensure sharps containers at point of use\n• Never recap needles\n• Use needleless systems when possible',
            ),
            const SizedBox(height: 12),
            _buildPreventionSection(
              'Work Practice Controls',
              '• Activate safety features immediately\n• Dispose of sharps directly into containers\n• Do not pass sharps hand-to-hand\n• Use neutral zone for passing sharps in OR',
            ),
            const SizedBox(height: 12),
            _buildPreventionSection(
              'Administrative Controls',
              '• Provide comprehensive sharps safety training\n• Implement sharps injury reporting system\n• Conduct regular safety audits\n• Involve frontline staff in device selection',
            ),
            const SizedBox(height: 12),
            _buildPreventionSection(
              'Post-Exposure Management',
              '• Wash wound immediately with soap and water\n• Report injury to supervisor immediately\n• Seek medical evaluation within 2 hours\n• Complete incident report and follow PEP protocol',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreventionSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Widget _buildReferences() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'References',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            ..._knowledgePanelData.references.map((reference) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _launchURL(reference.url),
                    child: Row(
                      children: [
                        Icon(Icons.link, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reference.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
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

  void _showQuickGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
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
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Guide',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 24),
                      _buildGuideSection(
                        'Definition',
                        _knowledgePanelData.definition,
                        Icons.info,
                        AppColors.info,
                      ),
                      const SizedBox(height: 20),
                      _buildGuideSection(
                        'Formula',
                        _knowledgePanelData.formula,
                        Icons.calculate,
                        AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      _buildGuideSection(
                        'Example',
                        _knowledgePanelData.example,
                        Icons.lightbulb,
                        AppColors.warning,
                      ),
                      const SizedBox(height: 20),
                      _buildGuideSection(
                        'Interpretation',
                        _knowledgePanelData.interpretation,
                        Icons.insights,
                        AppColors.success,
                      ),
                      const SizedBox(height: 20),
                      _buildGuideSection(
                        'Indications/Use',
                        _knowledgePanelData.whenUsed,
                        Icons.medical_services,
                        AppColors.error,
                      ),
                      const SizedBox(height: 20),
                      _buildGuideSection(
                        'Input Data Type',
                        _knowledgePanelData.inputDataType,
                        Icons.input,
                        AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideSection(String title, String? content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Future<void> _saveToHistory() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'NSI Rate Calculator',
        inputs: {
          'Time Period': _selectedTimePeriod,
          'Department': _selectedDepartment,
          'NSI Cases': _nsiCasesController.text,
          'Total HCWs': _hcwsController.text,
        },
        result: 'NSI Rate: ${_rate!.toStringAsFixed(2)} per 1,000 HCWs\n'
            '95% CI: ${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}\n'
            'Benchmark: $_benchmark',
        notes: '',
        tags: ['occupational-health', 'nsi', 'sharps-safety', 'injury-prevention'],
      );

      await repository.addEntry(historyEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Result saved to history'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _saveResult() {
    _saveToHistory();
  }

  void _showExportModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportModal(
        onExportPDF: () => _exportAsPDF(),
        onExportCSV: () => _exportAsCSV(),
        onExportExcel: () => _exportAsExcel(),
        onExportText: () => _exportAsText(),
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    Navigator.pop(context);

    final inputs = {
      'Time Period': _selectedTimePeriod,
      'Department': _selectedDepartment,
      'Number of NSI': _nsiCasesController.text,
      'Total HCWs': _hcwsController.text,
    };

    final results = {
      'NSI Rate': '${_rate!.toStringAsFixed(2)} per 1,000 HCWs',
      '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'NSI Rate',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final csvContent = '''Calculator,Time Period,Department,NSI Cases,Total HCWs,NSI Rate,95% CI Lower,95% CI Upper,Benchmark,Interpretation
NSI Rate,$_selectedTimePeriod,$_selectedDepartment,${_nsiCasesController.text},${_hcwsController.text},${_rate!.toStringAsFixed(2)},${_lowerCI!.toStringAsFixed(2)},${_upperCI!.toStringAsFixed(2)},${_benchmark!},"${_interpretation!.replaceAll('"', '""')}"''';

    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: 'NSI_Rate_${DateTime.now().millisecondsSinceEpoch}',
      csvContent: csvContent,
    );
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Time Period': _selectedTimePeriod,
      'Department': _selectedDepartment,
      'Number of NSI': _nsiCasesController.text,
      'Total HCWs': _hcwsController.text,
    };

    final results = {
      'NSI Rate': '${_rate!.toStringAsFixed(2)} per 1,000 HCWs',
      '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'NSI Rate',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Time Period': _selectedTimePeriod,
      'Department': _selectedDepartment,
      'Number of NSI': _nsiCasesController.text,
      'Total HCWs': _hcwsController.text,
    };

    final results = {
      'NSI Rate': '${_rate!.toStringAsFixed(2)} per 1,000 HCWs',
      '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'NSI Rate',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }
}


