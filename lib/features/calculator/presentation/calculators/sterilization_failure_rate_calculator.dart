import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../outbreak/data/models/history_entry.dart';
import '../../../outbreak/data/repositories/history_repository.dart';

class SterilizationFailureRateCalculator extends ConsumerStatefulWidget {
  const SterilizationFailureRateCalculator({super.key});

  @override
  ConsumerState<SterilizationFailureRateCalculator> createState() => _SterilizationFailureRateCalculatorState();
}

class _SterilizationFailureRateCalculatorState extends ConsumerState<SterilizationFailureRateCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _failedLoadsController = TextEditingController();
  final _totalLoadsController = TextEditingController();

  String _selectedSterilizationMethod = 'Steam (Gravity)';
  String _selectedIndicatorType = 'Biological Indicator';
  String _selectedTimePeriod = 'Monthly';
  double? _failureRate;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isCalculated = false;

  final List<String> _sterilizationMethods = [
    'Steam (Gravity)',
    'Steam (Prevacuum)',
    'ETO',
    'Hydrogen Peroxide',
    'Dry Heat'
  ];
  final List<String> _indicatorTypes = ['Biological Indicator', 'Chemical Indicator', 'Both'];
  final List<String> _timePeriods = ['Weekly', 'Monthly', 'Quarterly', 'Annually'];

  final KnowledgePanelData _knowledgePanelData = KnowledgePanelData(
    definition: 'Sterilization Failure Rate measures the percentage of sterilization loads that fail biological indicator testing. This is the most critical quality indicator for Central Sterile Supply Department (CSSD) monitoring, as it directly validates the effectiveness of sterilization processes and protects patients from surgical site infections and device-related infections.',
    formula: 'Sterilization Failure Rate (%) = (Failed Loads × 100) / Total Loads',
    example: 'If 2 out of 250 sterilization loads failed biological indicator testing:\nSterilization Failure Rate = (2 × 100) / 250 = 0.8%',
    interpretation: 'Lower failure rates indicate effective sterilization processes, proper equipment maintenance, and competent staff. Higher rates suggest equipment malfunction, improper loading, inadequate cleaning, or operator error. ANY positive biological indicator requires immediate action regardless of rate. Failure rates vary by sterilization method (steam ~1%, ETO slightly higher, dry heat ~1.3%).',
    whenUsed: 'Used to validate sterilization effectiveness, monitor CSSD quality, ensure patient safety (especially for implantable devices), detect equipment malfunction early, demonstrate regulatory compliance (Joint Commission, CMS, FDA), provide legal protection through documentation, and guide preventive maintenance schedules.',
    inputDataType: 'Failed loads (number of loads with positive biological indicators), Total loads (all sterilization cycles monitored), Sterilization method (steam gravity, steam prevacuum, ETO, hydrogen peroxide, dry heat), Indicator type (biological, chemical, both), Time period (weekly, monthly, quarterly, annually). CDC recommends at least weekly BI testing, daily if frequent use, and every load containing implantable items.',
    references: [
      Reference(
        title: 'CDC - Guideline for Disinfection and Sterilization',
        url: 'https://www.cdc.gov/infection-control/media/pdfs/guideline-disinfection-h.pdf',
      ),
      Reference(
        title: 'CDC - Sterilizing Practices',
        url: 'https://www.cdc.gov/infection-control/hcp/disinfection-sterilization/sterilizing-practices.html',
      ),
      Reference(
        title: 'AAMI - Comprehensive Guide to Steam Sterilization',
        url: 'https://www.aami.org/sterilization',
      ),
      Reference(
        title: 'APIC - Central Sterile Supply Department Standards',
        url: 'https://apic.org/professional-practice/practice-resources/cssd/',
      ),
    ],
  );

  @override
  void dispose() {
    _failedLoadsController.dispose();
    _totalLoadsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'Sterilization Failure Rate',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
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
              _buildSterilizationMethodDropdown(),
              const SizedBox(height: 16),
              _buildIndicatorTypeDropdown(),
              const SizedBox(height: 16),
              _buildTimePeriodDropdown(),
              const SizedBox(height: 16),
              _buildInputCard(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_isCalculated) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
                const SizedBox(height: 16),
                _buildSterilizationFailureProtocolCard(),
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
              Icons.medical_services_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sterilization Failure Rate',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CSSD Quality Assurance & Monitoring',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    fontSize = 11.0;
                  } else if (constraints.maxWidth < 400) {
                    fontSize = 13.0;
                  }

                  return Math.tex(
                    r'\text{Sterilization Failure Rate } \% = \frac{\text{Failed Loads} \times 100}{\text{Total Loads}}',
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
        onPressed: _showQuickGuide,
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

  Widget _buildSterilizationMethodDropdown() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sterilization Method',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSterilizationMethod,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _sterilizationMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSterilizationMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorTypeDropdown() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Indicator Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedIndicatorType,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _indicatorTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIndicatorType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodDropdown() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Period',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTimePeriod,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
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

  Widget _buildInputCard() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _failedLoadsController,
              decoration: InputDecoration(
                labelText: 'Failed Loads',
                hintText: 'Enter number of failed loads',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.error_outline),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter failed loads';
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
              controller: _totalLoadsController,
              decoration: InputDecoration(
                labelText: 'Total Loads',
                hintText: 'Enter total number of loads',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total loads';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number greater than 0';
                }
                final failedLoads = int.tryParse(_failedLoadsController.text) ?? 0;
                if (number < failedLoads) {
                  return 'Total loads must be ≥ failed loads';
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final failedLoads = int.parse(_failedLoadsController.text);
      final totalLoads = int.parse(_totalLoadsController.text);

      final rate = (failedLoads * 100) / totalLoads;

      setState(() {
        _failureRate = rate;
        _interpretation = _getInterpretation(rate);
        _benchmark = _getBenchmark(rate);
        _action = _getAction(rate);
        _isCalculated = true;
      });

      _saveToHistory();
    }
  }

  String _getInterpretation(double rate) {
    if (rate < 0.5) {
      return 'Excellent sterilization performance. Exceptional CSSD quality. Failure rate well below CDC baseline expectation. Current sterilization processes, equipment maintenance, and staff competency are highly effective. Continue monitoring to maintain this level.';
    } else if (rate <= 1.0) {
      return 'Acceptable sterilization performance. Meets CDC baseline expectation (~1% for steam). Sterilization processes are effective. Continue routine monitoring and address any identified failures promptly. Maintain preventive maintenance schedules.';
    } else if (rate <= 2.0) {
      return 'High sterilization failure rate. Exceeds acceptable threshold. Requires investigation and corrective action. Potential issues: equipment malfunction, improper loading, inadequate cleaning, operator error, or sterilant quality problems. Immediate intervention needed.';
    } else {
      return 'Unacceptable sterilization failure rate. Critical patient safety concern. Multiple system failures likely. High risk of surgical site infections and device-related infections. Urgent comprehensive investigation and intervention required. Consider suspending operations until resolved.';
    }
  }

  String _getBenchmark(double rate) {
    if (rate < 0.5) {
      return 'Excellent (<0.5%)';
    } else if (rate <= 1.0) {
      return 'Acceptable (0.5-1.0%)';
    } else if (rate <= 2.0) {
      return 'High (1.0-2.0%)';
    } else {
      return 'Unacceptable (>2.0%)';
    }
  }

  String _getAction(double rate) {
    if (rate < 0.5) {
      return 'Continue current sterilization protocols and monitoring frequency. Maintain preventive maintenance schedules. Document best practices. Recognize and reward CSSD staff performance. Use as benchmark for quality improvement. Continue at least weekly biological indicator testing (daily if frequent use).';
    } else if (rate <= 1.0) {
      return 'Continue routine monitoring with at least weekly biological indicator testing. Review each failure for root cause (equipment, loading, cleaning, operator). Ensure preventive maintenance is current. Verify staff competency. Document all failures and corrective actions. Monitor trends for any increase.';
    } else if (rate <= 2.0) {
      return 'IMMEDIATE ACTIONS: Stop using affected sterilizer(s). Quarantine all items from suspect loads. Conduct comprehensive investigation: check mechanical/chemical indicators, review load configurations, inspect sterilizer function, assess staff competency, verify sterilant quality. Implement corrective actions. Increase monitoring frequency. Recall items from loads between last negative and next negative BI. Reprocess all items from failed loads. Consider equipment service or replacement if malfunction confirmed.';
    } else {
      return 'URGENT CRITICAL ACTIONS: Immediately stop all affected sterilizers. Quarantine all processed items. Initiate emergency investigation with multidisciplinary team (CSSD, infection control, biomedical engineering, administration). Assess patient exposure risk - identify all patients who received items from failed loads. Implement emergency sterilization protocols (send items to external facility if needed). Conduct comprehensive root cause analysis: equipment function, maintenance history, staff competency, cleaning processes, loading practices, sterilant quality, environmental factors. Implement daily biological indicator testing. Verify three consecutive negative BIs before resuming operations. Notify regulatory authorities if required. Document all actions thoroughly for legal protection.';
    }
  }

  Widget _buildResultsCard() {
    Color cardColor;
    if (_failureRate! < 0.5) {
      cardColor = AppColors.success;
    } else if (_failureRate! <= 1.0) {
      cardColor = AppColors.info;
    } else if (_failureRate! <= 2.0) {
      cardColor = AppColors.warning;
    } else {
      cardColor = AppColors.error;
    }

    return Card(
      color: cardColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assessment,
                    color: cardColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save_outlined),
                      onPressed: _saveToHistory,
                      tooltip: 'Save to History',
                      color: AppColors.primary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: _showExportModal,
                      tooltip: 'Export',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cardColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  _buildResultRow('Sterilization Failure Rate', '${_failureRate!.toStringAsFixed(2)}%', cardColor),
                  const Divider(height: 24),
                  _buildResultRow('Benchmark', _benchmark!, cardColor),
                  const Divider(height: 24),
                  _buildResultRow('Sterilization Method', _selectedSterilizationMethod, cardColor),
                  const Divider(height: 24),
                  _buildResultRow('Indicator Type', _selectedIndicatorType, cardColor),
                  const Divider(height: 24),
                  _buildResultRow('Time Period', _selectedTimePeriod, cardColor),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'Interpretation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _interpretation!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cardColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.recommend_outlined, size: 20, color: cardColor),
                      const SizedBox(width: 8),
                      Text(
                        'Recommended Actions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _action!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }



  Widget _buildSterilizationFailureProtocolCard() {
    return Card(
      color: AppColors.error.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.error, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sterilization Failure Protocol',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProtocolSection(
              'Immediate Actions (Within 1 Hour)',
              [
                'Stop using the affected sterilizer immediately',
                'Quarantine all items from the failed load',
                'Quarantine items from loads since last negative BI',
                'Tag sterilizer "OUT OF SERVICE" until investigation complete',
                'Notify CSSD supervisor and infection control',
                'Document failure details (date, time, load number, operator)',
                'Preserve failed BI for laboratory confirmation',
              ],
            ),
            const SizedBox(height: 12),
            _buildProtocolSection(
              'Investigation Steps (Within 24 Hours)',
              [
                'Review mechanical indicators (time, temperature, pressure)',
                'Review chemical indicators from the load',
                'Inspect load configuration and packaging',
                'Check sterilizer maintenance records',
                'Verify sterilant quality (steam quality, ETO concentration)',
                'Interview operator about loading and cycle selection',
                'Run empty chamber test with new BI',
                'Contact biomedical engineering for equipment evaluation',
              ],
            ),
            const SizedBox(height: 12),
            _buildProtocolSection(
              'Recall Procedures',
              [
                'Identify all items from loads between last negative and next negative BI',
                'Trace distributed items to patient care areas',
                'Retrieve items if not yet used',
                'For used items: assess patient exposure risk',
                'Document all recalled items and their disposition',
                'Notify risk management if patient exposure occurred',
              ],
            ),
            const SizedBox(height: 12),
            _buildProtocolSection(
              'Patient Risk Assessment',
              [
                'Identify patients who received items from failed loads',
                'Assess infection risk based on item type (critical vs semi-critical)',
                'Consult infectious disease for high-risk exposures',
                'Consider prophylactic treatment if indicated',
                'Implement enhanced surveillance for exposed patients',
                'Document all patient notifications and interventions',
              ],
            ),
            const SizedBox(height: 12),
            _buildProtocolSection(
              'Reprocessing Requirements',
              [
                'Reprocess all items from failed load',
                'Reprocess items from loads since last negative BI',
                'Use alternative sterilizer or send to external facility',
                'Verify three consecutive negative BIs before resuming operations',
                'Implement daily BI testing until stability confirmed',
                'Document all reprocessing activities',
              ],
            ),
            const SizedBox(height: 12),
            _buildProtocolSection(
              'Documentation Requirements',
              [
                'Complete incident report with root cause analysis',
                'Document all investigation findings',
                'Record corrective actions taken',
                'Document patient notifications and risk assessments',
                'Maintain records for legal protection (minimum 7 years)',
                'Report to regulatory authorities if required',
                'Update policies/procedures if system issues identified',
              ],
            ),
            if (_failureRate! > 1.0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'URGENT: Failure rate exceeds acceptable threshold. Immediate comprehensive investigation and intervention required.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildReferences() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.library_books_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'References',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._knowledgePanelData.references.map((reference) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _launchURL(reference.url),
              child: Text(
                '• ${reference.title}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  height: 1.5,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }


  void _showQuickGuide() {
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
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
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
      _failedLoadsController.text = '2';
      _totalLoadsController.text = '250';
      _selectedSterilizationMethod = 'Steam (Prevacuum)';
      _selectedIndicatorType = 'Biological Indicator';
      _selectedTimePeriod = 'Monthly';
      _isCalculated = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example data loaded'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveToHistory() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Sterilization Failure Rate',
        inputs: {
          'Failed Loads': _failedLoadsController.text,
          'Total Loads': _totalLoadsController.text,
          'Sterilization Method': _selectedSterilizationMethod,
          'Indicator Type': _selectedIndicatorType,
          'Time Period': _selectedTimePeriod,
        },
        result: 'Failure Rate: ${_failureRate!.toStringAsFixed(2)}%\n'
            'Benchmark: $_benchmark',
        notes: '',
        tags: ['environmental-health', 'sterilization', 'failure-rate', 'cssd'],
      );

      await repository.addEntry(historyEntry);
    } catch (e) {
      debugPrint('Error saving to history: $e');
    }
  }

  void _showExportModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: ExportModal(
                    onExportPDF: _exportAsPDF,
                    onExportCSV: _exportAsCSV,
                    onExportExcel: _exportAsExcel,
                    onExportText: _exportAsText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    Navigator.pop(context);

    final benchmarkValue = double.tryParse(_benchmark?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0.1') ?? 0.1;

    final inputs = {
      'Sterilization Method': _selectedSterilizationMethod,
      'Indicator Type': _selectedIndicatorType,
      'Time Period': _selectedTimePeriod,
      'Failed Loads': _failedLoadsController.text,
      'Total Loads': _totalLoadsController.text,
    };

    final results = {
      'Sterilization Failure Rate': '${_failureRate!.toStringAsFixed(2)}%',
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Sterilization Failure Rate',
      formula: '(Failed Loads × 100) / Total Loads',
      inputs: inputs,
      results: results,
      benchmark: {
        'target': _benchmark ?? '<0.1%',
        'unit': 'failure rate',
        'source': 'AAMI/CDC CSSD Guidelines',
        'status': _failureRate! < benchmarkValue ? 'Meets Target' : 'Above Target',
      },
      recommendations: _action,
      interpretation: _interpretation!,
    );
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final benchmarkValue = double.tryParse(_benchmark?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0.1') ?? 0.1;

    final inputs = {
      'Sterilization Method': _selectedSterilizationMethod,
      'Indicator Type': _selectedIndicatorType,
      'Time Period': _selectedTimePeriod,
      'Failed Loads': _failedLoadsController.text,
      'Total Loads': _totalLoadsController.text,
    };

    final results = {
      'Sterilization Failure Rate': '${_failureRate!.toStringAsFixed(2)}%',
    };

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Sterilization Failure Rate',
      formula: '(Failed Loads × 100) / Total Loads',
      inputs: inputs,
      results: results,
      benchmark: {
        'target': _benchmark ?? '<0.1%',
        'unit': 'failure rate',
        'source': 'AAMI/CDC CSSD Guidelines',
        'status': _failureRate! < benchmarkValue ? 'Meets Target' : 'Above Target',
      },
      recommendations: _action,
      interpretation: _interpretation!,
    );
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final benchmarkValue = double.tryParse(_benchmark?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0.1') ?? 0.1;

    final inputs = {
      'Sterilization Method': _selectedSterilizationMethod,
      'Indicator Type': _selectedIndicatorType,
      'Time Period': _selectedTimePeriod,
      'Failed Loads': _failedLoadsController.text,
      'Total Loads': _totalLoadsController.text,
    };

    final results = {
      'Sterilization Failure Rate': '${_failureRate!.toStringAsFixed(2)}%',
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Sterilization Failure Rate',
      formula: '(Failed Loads × 100) / Total Loads',
      inputs: inputs,
      results: results,
      benchmark: {
        'target': _benchmark ?? '<0.1%',
        'unit': 'failure rate',
        'source': 'AAMI/CDC CSSD Guidelines',
        'status': _failureRate! < benchmarkValue ? 'Meets Target' : 'Above Target',
      },
      recommendations: _action,
      interpretation: _interpretation!,
    );
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final benchmarkValue = double.tryParse(_benchmark?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0.1') ?? 0.1;

    final inputs = {
      'Sterilization Method': _selectedSterilizationMethod,
      'Indicator Type': _selectedIndicatorType,
      'Time Period': _selectedTimePeriod,
      'Failed Loads': _failedLoadsController.text,
      'Total Loads': _totalLoadsController.text,
    };

    final results = {
      'Sterilization Failure Rate': '${_failureRate!.toStringAsFixed(2)}%',
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Sterilization Failure Rate',
      formula: '(Failed Loads × 100) / Total Loads',
      inputs: inputs,
      results: results,
      benchmark: {
        'target': _benchmark ?? '<0.1%',
        'unit': 'failure rate',
        'source': 'AAMI/CDC CSSD Guidelines',
        'status': _failureRate! < benchmarkValue ? 'Meets Target' : 'Above Target',
      },
      recommendations: _action,
      interpretation: _interpretation!,
    );
  }
}

