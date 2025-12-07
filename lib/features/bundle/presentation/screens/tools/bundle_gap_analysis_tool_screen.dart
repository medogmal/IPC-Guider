import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/back_button.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../../features/outbreak/data/repositories/history_repository.dart';
import '../../../../../features/outbreak/data/models/history_entry.dart';
import '../../../data/models/bundle_tool_enums.dart';
import '../../../data/models/bundle_gap_record.dart';
import '../../../domain/bundle_tool_constants.dart';
import '../../widgets/tools/bundle_tool_header.dart';
import '../../widgets/tools/bundle_tool_input_card.dart';
import '../../widgets/tools/bundle_tool_result_card.dart';

class BundleGapAnalysisToolScreen extends StatefulWidget {
  const BundleGapAnalysisToolScreen({super.key});

  @override
  State<BundleGapAnalysisToolScreen> createState() =>
      _BundleGapAnalysisToolScreenState();
}

class _BundleGapAnalysisToolScreenState
    extends State<BundleGapAnalysisToolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitController = TextEditingController();
  final _analystController = TextEditingController();
  final _timePeriodController = TextEditingController();
  final _currentComplianceController = TextEditingController();
  final _targetComplianceController = TextEditingController(text: '95');
  final _numberOfAuditsController = TextEditingController();
  final _otherBarrierController = TextEditingController();

  BundleType? _selectedBundleType;
  DateTime _analysisDate = DateTime.now();
  final Map<BundleBarrier, BarrierFrequency> _selectedBarriers = {};
  BarrierFrequency? _otherBarrierFrequency;
  final List<String> _frequentlyMissedElements = [];

  BundleGapRecord? _gapResult;

  @override
  void dispose() {
    _unitController.dispose();
    _analystController.dispose();
    _timePeriodController.dispose();
    _currentComplianceController.dispose();
    _targetComplianceController.dispose();
    _numberOfAuditsController.dispose();
    _otherBarrierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Bundle Gap Analysis Tool',
        fitTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.large,
            AppSpacing.large,
            AppSpacing.large, // Bottom padding for mobile
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              BundleToolHeader(
                title: 'Bundle Gap Analysis',
                description:
                    'Identify root causes of bundle non-compliance and generate targeted action plans',
                icon: Icons.analytics_outlined,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.medium),

              // Quick Guide button
              _buildQuickGuideButton(),
              const SizedBox(height: AppSpacing.medium),

              // Load Example button
              _buildLoadExampleButton(),
              const SizedBox(height: AppSpacing.large),

              // Bundle Type Selection
              BundleToolInputCard(
                title: 'Bundle Selection',
                icon: Icons.category_outlined,
                child: DropdownButtonFormField<BundleType>(
                  decoration: const InputDecoration(
                    labelText: 'Bundle Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: BundleType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.shortName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBundleType = value;
                      _frequentlyMissedElements.clear();
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a bundle type' : null,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Analysis Details
              BundleToolInputCard(
                title: 'Analysis Details',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    // Analysis Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Analysis Date'),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(_analysisDate)),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: AppSpacing.small),

                    // Unit Location
                    TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit/Location *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.small),

                    // Analyst Name
                    TextFormField(
                      controller: _analystController,
                      decoration: const InputDecoration(
                        labelText: 'Analyst Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.small),

                    // Time Period
                    TextFormField(
                      controller: _timePeriodController,
                      decoration: const InputDecoration(
                        labelText: 'Time Period *',
                        hintText: 'e.g., January 2025',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Compliance Data
              BundleToolInputCard(
                title: 'Compliance Data',
                icon: Icons.assessment_outlined,
                child: Column(
                  children: [
                    // Current Compliance
                    TextFormField(
                      controller: _currentComplianceController,
                      decoration: const InputDecoration(
                        labelText: 'Current Compliance % *',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final num = double.tryParse(value!);
                        if (num == null || num < 0 || num > 100) {
                          return 'Enter 0-100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.small),

                    // Target Compliance
                    TextFormField(
                      controller: _targetComplianceController,
                      decoration: const InputDecoration(
                        labelText: 'Target Compliance % *',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final num = double.tryParse(value!);
                        if (num == null || num < 0 || num > 100) {
                          return 'Enter 0-100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.small),

                    // Number of Audits
                    TextFormField(
                      controller: _numberOfAuditsController,
                      decoration: const InputDecoration(
                        labelText: 'Number of Audits Conducted *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final num = int.tryParse(value!);
                        if (num == null || num < 1) {
                          return 'Enter at least 1';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Barriers Identified
              BundleToolInputCard(
                title: 'Barriers Identified',
                icon: Icons.block_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select barriers and their frequency:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    ...BundleBarrier.values
                        .where((b) => b != BundleBarrier.other)
                        .map((barrier) => _buildBarrierSelector(barrier)),
                    const SizedBox(height: AppSpacing.small),

                    // Other Barrier
                    TextFormField(
                      controller: _otherBarrierController,
                      decoration: const InputDecoration(
                        labelText: 'Other Barrier (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    if (_otherBarrierController.text.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.small),
                      _buildFrequencySelector(
                        'Other Barrier Frequency',
                        _otherBarrierFrequency,
                        (value) {
                          setState(() => _otherBarrierFrequency = value);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Frequently Missed Elements
              if (_selectedBundleType != null) ...[
                BundleToolInputCard(
                  title: 'Frequently Missed Elements',
                  icon: Icons.warning_amber_outlined,
                  child: _buildElementSelector(),
                ),
                const SizedBox(height: AppSpacing.large),
              ],

              // Analyze Button
              ElevatedButton.icon(
                onPressed: _analyzeGap,
                icon: const Icon(Icons.analytics, size: 20),
                label: const Text('Analyze Gap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // Results
              if (_gapResult != null) ...[
                const SizedBox(height: AppSpacing.large),
                _buildResultsSection(),
                const SizedBox(height: AppSpacing.large), // Extra bottom padding after results
              ],

              // References (always visible)
              const SizedBox(height: AppSpacing.large),
              _buildReferencesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickGuideButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showQuickGuide,
        icon: Icon(Icons.menu_book, color: AppColors.info),
        label: Text(
          'Quick Guide',
          style: TextStyle(
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
        onPressed: _loadExampleData,
        icon: Icon(Icons.lightbulb_outline, color: AppColors.success),
        label: Text(
          'Load Example Data',
          style: TextStyle(
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

  Widget _buildBarrierSelector(BundleBarrier barrier) {
    final isSelected = _selectedBarriers.containsKey(barrier);
    final frequency = _selectedBarriers[barrier];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.05)
          : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.small),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(barrier.displayName),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedBarriers[barrier] = BarrierFrequency.medium;
                  } else {
                    _selectedBarriers.remove(barrier);
                  }
                });
              },
            ),
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.small),
              _buildFrequencySelector(
                'Frequency',
                frequency,
                (value) {
                  setState(() {
                    if (value != null) {
                      _selectedBarriers[barrier] = value;
                    }
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector(
    String label,
    BarrierFrequency? value,
    ValueChanged<BarrierFrequency?> onChanged,
  ) {
    return Wrap(
      spacing: 8,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        ...BarrierFrequency.values.map((freq) {
          final isSelected = value == freq;
          return ChoiceChip(
            label: Text(freq.displayName),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) onChanged(freq);
            },
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildElementSelector() {
    if (_selectedBundleType == null) return const SizedBox.shrink();

    final elements = BundleToolConstants.getElementsForBundle(_selectedBundleType!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select elements that are frequently missed:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.small),
        ...elements.map((element) {
          final isSelected = _frequentlyMissedElements.contains(element.name);
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(element.name, style: const TextStyle(fontSize: 14)),
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _frequentlyMissedElements.add(element.name);
                } else {
                  _frequentlyMissedElements.remove(element.name);
                }
              });
            },
          );
        }),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _analysisDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _analysisDate = picked);
    }
  }

  void _showQuickGuide() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book, color: AppColors.info, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Bundle Gap Analysis - Quick Guide',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildGuideSection('Purpose',
                  'Identify root causes of bundle non-compliance and generate targeted action plans.'),
                const SizedBox(height: 16),
                _buildGuideSection('Steps',
                  '1. Select bundle type (CLABSI, CAUTI, VAP, SSI)\n'
                  '2. Enter analysis details (date, unit, analyst, time period)\n'
                  '3. Enter compliance data (current %, target %, number of audits)\n'
                  '4. Select barriers and their frequency (Low/Medium/High)\n'
                  '5. Select frequently missed elements\n'
                  '6. Tap "Analyze Gap" to generate action plan'),
                const SizedBox(height: 16),
                _buildGuideSection('Barriers',
                  '• Knowledge Gap: Staff lack training/awareness\n'
                  '• Resource Unavailability: Supplies not available\n'
                  '• Workflow Issue: Process inefficiencies\n'
                  '• Time Constraint: Insufficient time\n'
                  '• Communication Breakdown: Poor handoffs\n'
                  '• Leadership Support: Lack of accountability\n'
                  '• Staff Resistance: Change resistance\n'
                  '• Documentation Issue: EHR/charting problems\n'
                  '• Equipment Malfunction: Equipment failures'),
                const SizedBox(height: 16),
                _buildGuideSection('Outputs',
                  '• Gap severity (Low/Moderate/High/Critical)\n'
                  '• Prioritized barriers (High → Medium → Low frequency)\n'
                  '• Targeted action plan with timelines and responsibilities\n'
                  '• Gap summary with recommendations'),
                const SizedBox(height: 16),
                _buildGuideSection('Tips',
                  '• Be honest about barriers - this drives effective solutions\n'
                  '• Select multiple barriers if applicable\n'
                  '• Focus on high-frequency barriers first\n'
                  '• Involve frontline staff in barrier identification'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _loadExampleData() {
    // Context-aware example loading based on currently selected bundle type
    final bundleType = _selectedBundleType ?? BundleType.clabsi;

    setState(() {
      // Set bundle type if not already selected
      _selectedBundleType = bundleType;

      _analysisDate = DateTime.now().subtract(const Duration(days: 7));
      _analystController.text = 'Sarah Johnson, RN';
      _timePeriodController.text = DateFormat('MMMM yyyy').format(DateTime.now());
      _targetComplianceController.text = '95';

      _selectedBarriers.clear();
      _frequentlyMissedElements.clear();
      _otherBarrierController.clear();
      _otherBarrierFrequency = null;

      // Context-specific examples for each bundle type
      switch (bundleType) {
        case BundleType.clabsi:
          _unitController.text = 'ICU-A';
          _currentComplianceController.text = '78';
          _numberOfAuditsController.text = '25';
          _selectedBarriers[BundleBarrier.knowledgeGap] = BarrierFrequency.high;
          _selectedBarriers[BundleBarrier.resourceUnavailability] = BarrierFrequency.medium;
          _selectedBarriers[BundleBarrier.timeConstraint] = BarrierFrequency.medium;
          _frequentlyMissedElements.addAll(['Hand Hygiene', 'Maximal Barrier Precautions']);
          break;

        case BundleType.cauti:
          _unitController.text = 'Medical Ward';
          _currentComplianceController.text = '72';
          _numberOfAuditsController.text = '30';
          _selectedBarriers[BundleBarrier.workflowIssue] = BarrierFrequency.high;
          _selectedBarriers[BundleBarrier.documentationIssue] = BarrierFrequency.medium;
          _frequentlyMissedElements.addAll(['Daily Review of Catheter Necessity', 'Aseptic Technique']);
          break;

        case BundleType.vap:
          _unitController.text = 'ICU-B';
          _currentComplianceController.text = '68';
          _numberOfAuditsController.text = '20';
          _selectedBarriers[BundleBarrier.knowledgeGap] = BarrierFrequency.high;
          _selectedBarriers[BundleBarrier.timeConstraint] = BarrierFrequency.high;
          _selectedBarriers[BundleBarrier.staffResistance] = BarrierFrequency.medium;
          _frequentlyMissedElements.addAll(['HOB Elevation 30-45°', 'Spontaneous Breathing Trial']);
          break;

        case BundleType.ssi:
          _unitController.text = 'Surgical Ward';
          _currentComplianceController.text = '82';
          _numberOfAuditsController.text = '35';
          _selectedBarriers[BundleBarrier.communicationBreakdown] = BarrierFrequency.high;
          _selectedBarriers[BundleBarrier.workflowIssue] = BarrierFrequency.medium;
          _frequentlyMissedElements.addAll(['Antibiotic Timing', 'Normothermia']);
          break;

        case BundleType.sepsis:
          _unitController.text = 'Emergency Department';
          _currentComplianceController.text = '75';
          _numberOfAuditsController.text = '28';
          _selectedBarriers[BundleBarrier.timeConstraint] = BarrierFrequency.high;
          _selectedBarriers[BundleBarrier.resourceUnavailability] = BarrierFrequency.medium;
          _frequentlyMissedElements.addAll(['Fluid Resuscitation', 'Lactate Measurement']);
          break;
      }
    });

    // Show context-specific message
    String exampleDescription;
    switch (bundleType) {
      case BundleType.clabsi:
        exampleDescription = 'CLABSI Bundle: 78% compliance, gap of 17%';
        break;
      case BundleType.cauti:
        exampleDescription = 'CAUTI Bundle: 72% compliance, gap of 23%';
        break;
      case BundleType.vap:
        exampleDescription = 'VAP Bundle: 68% compliance, gap of 27%';
        break;
      case BundleType.ssi:
        exampleDescription = 'SSI Bundle: 82% compliance, gap of 13%';
        break;
      case BundleType.sepsis:
        exampleDescription = 'Sepsis Bundle: 75% compliance, gap of 20%';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded: $exampleDescription'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _analyzeGap() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBarriers.isEmpty &&
        (_otherBarrierController.text.isEmpty || _otherBarrierFrequency == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one barrier'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final currentCompliance = double.parse(_currentComplianceController.text);
    final targetCompliance = double.parse(_targetComplianceController.text);
    final numberOfAudits = int.parse(_numberOfAuditsController.text);

    final result = BundleGapRecord.analyze(
      analysisDate: _analysisDate,
      bundleType: _selectedBundleType!,
      unitLocation: _unitController.text,
      analystName: _analystController.text,
      timePeriod: _timePeriodController.text,
      currentCompliance: currentCompliance,
      targetCompliance: targetCompliance,
      numberOfAudits: numberOfAudits,
      barriers: _selectedBarriers,
      otherBarrier: _otherBarrierController.text.isNotEmpty
          ? _otherBarrierController.text
          : null,
      otherBarrierFrequency: _otherBarrierFrequency,
      frequentlyMissedElements: _frequentlyMissedElements,
    );

    setState(() => _gapResult = result);

    // Scroll to results
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildResultsSection() {
    if (_gapResult == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Gap Summary
        BundleToolResultCard(
          title: 'Gap Analysis Results',
          icon: Icons.analytics_outlined,
          color: _getSeverityColor(_gapResult!.severity),
          child: Column(
            children: [
              // Severity Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getSeverityColor(_gapResult!.severity)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getSeverityIcon(_gapResult!.severity),
                      color: _getSeverityColor(_gapResult!.severity),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_gapResult!.severity.displayName} Severity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getSeverityColor(_gapResult!.severity),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.large),

              // Gap Metrics
              _buildGapMetrics(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),

        // Gap Summary Text
        _buildGapSummaryCard(),
        const SizedBox(height: AppSpacing.medium),

        // Prioritized Barriers
        _buildPrioritizedBarriersCard(),
        const SizedBox(height: AppSpacing.medium),

        // Action Plan
        _buildActionPlanCard(),
        const SizedBox(height: AppSpacing.large),

        // Action Buttons (Save & Export)
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildGapMetrics() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutralLight),
      ),
      child: Column(
        children: [
          _buildMetricRow(
            'Current Compliance',
            '${_gapResult!.currentCompliance.toStringAsFixed(1)}%',
            AppColors.error,
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Target Compliance',
            '${_gapResult!.targetCompliance.toStringAsFixed(0)}%',
            AppColors.success,
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Compliance Gap',
            '${_gapResult!.complianceGap.toStringAsFixed(1)}%',
            _getSeverityColor(_gapResult!.severity),
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Number of Audits',
            '${_gapResult!.numberOfAudits}',
            AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGapSummaryCard() {
    return BundleToolResultCard(
      title: 'Gap Summary',
      icon: Icons.summarize_outlined,
      color: AppColors.info,
      child: Text(
        _gapResult!.gapSummary,
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildPrioritizedBarriersCard() {
    return BundleToolResultCard(
      title: 'Prioritized Barriers',
      icon: Icons.priority_high_outlined,
      color: AppColors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Barriers ranked by frequency (High → Medium → Low):',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          ..._gapResult!.prioritizedBarriers.asMap().entries.map((entry) {
            final index = entry.key;
            final barrier = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      barrier,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionPlanCard() {
    return BundleToolResultCard(
      title: 'Action Plan',
      icon: Icons.assignment_outlined,
      color: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended actions to close the gap:',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          ..._gapResult!.actionPlan.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.small),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.small),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(action.priority)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${index + 1}. ${action.priority.displayName} Priority',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getPriorityColor(action.priority),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            action.category.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.action,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          action.timeline,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            action.responsible,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveToHistory,
            icon: const Icon(Icons.save, size: 20),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showExportModal,
            icon: Icon(Icons.file_download, size: 20, color: AppColors.primary),
            label: Text('Export', style: TextStyle(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferencesSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'References',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildReferenceItem(
              'WHO. Guidelines on Core Components of IPC Programmes',
              'https://www.who.int/publications/i/item/9789241549929',
            ),
            const SizedBox(height: AppSpacing.small),
            _buildReferenceItem(
              'CDC. Identifying Healthcare-associated Infections (HAI) for NHSN Surveillance',
              'https://www.cdc.gov/nhsn/psc/index.html',
            ),
            const SizedBox(height: AppSpacing.small),
            _buildReferenceItem(
              'APIC. Implementation Guide - Preventing CLABSI',
              'https://apic.org/Resource_/TinyMceFileManager/2015/APIC_CLABSI_WEB.pdf',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceItem(String title, String url) {
    return InkWell(
      onTap: () {
        // Open URL in browser
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.link, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(GapSeverity severity) {
    switch (severity) {
      case GapSeverity.low:
        return AppColors.success;
      case GapSeverity.moderate:
        return AppColors.warning;
      case GapSeverity.high:
        return AppColors.error;
      case GapSeverity.critical:
        return AppColors.error;
    }
  }

  IconData _getSeverityIcon(GapSeverity severity) {
    switch (severity) {
      case GapSeverity.low:
        return Icons.check_circle_outline;
      case GapSeverity.moderate:
        return Icons.warning_amber_outlined;
      case GapSeverity.high:
        return Icons.error_outline;
      case GapSeverity.critical:
        return Icons.dangerous_outlined;
    }
  }

  Color _getPriorityColor(ActionPriority priority) {
    switch (priority) {
      case ActionPriority.high:
        return AppColors.error;
      case ActionPriority.medium:
        return AppColors.warning;
      case ActionPriority.low:
        return AppColors.info;
    }
  }

  Future<void> _saveToHistory() async {
    if (_gapResult == null) return;

    final entry = HistoryEntry(
      timestamp: DateTime.now(),
      toolType: 'Bundle Tool',
      title: 'Bundle Gap Analysis - ${_selectedBundleType!.shortName}',
      inputs: {
        'Unit': _unitController.text,
        'Analyst': _analystController.text,
        'Time Period': _timePeriodController.text,
        'Current Compliance': '${_gapResult!.currentCompliance.toStringAsFixed(1)}%',
        'Target Compliance': '${_gapResult!.targetCompliance.toStringAsFixed(0)}%',
      },
      result: '${_gapResult!.severity.displayName} Severity Gap',
      notes: _gapResult!.gapSummary,
    );

    await HistoryRepository().addEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gap analysis saved to history'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showExportModal() {
    ExportModal.show(
      context: context,
      onExportPDF: _exportAsPDF,
      onExportExcel: _exportAsExcel,
      onExportCSV: _exportAsExcel,
      onExportText: _exportAsText,
      enablePhoto: false,
    );
  }

  Future<void> _exportAsPDF() async {
    Navigator.pop(context);
    if (_gapResult == null) return;

    final inputs = {
      'Bundle Type': _selectedBundleType!.shortName,
      'Analysis Date': DateFormat('MMM dd, yyyy').format(_analysisDate),
      'Unit/Location': _unitController.text,
      'Analyst': _analystController.text,
      'Time Period': _timePeriodController.text,
      'Number of Audits': _numberOfAuditsController.text,
    };

    final results = {
      'Gap Severity': _gapResult!.severity.displayName,
      'Current Compliance': '${_gapResult!.currentCompliance.toStringAsFixed(1)}%',
      'Target Compliance': '${_gapResult!.targetCompliance.toStringAsFixed(0)}%',
      'Compliance Gap': '${_gapResult!.complianceGap.toStringAsFixed(1)}%',
    };

    final barriers = _gapResult!.prioritizedBarriers.asMap().entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    final actions = _gapResult!.actionPlan.asMap().entries
        .map((e) => '${e.key + 1}. [${e.value.priority.displayName}] ${e.value.action}\n   Timeline: ${e.value.timeline}\n   Responsible: ${e.value.responsible}')
        .join('\n\n');

    final success = await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Bundle Gap Analysis - ${_selectedBundleType!.shortName}',
      inputs: inputs,
      results: results,
      interpretation: _gapResult!.gapSummary,
      recommendations: 'Prioritized Barriers:\n$barriers\n\nAction Plan:\n$actions',
      unitName: _unitController.text,
      generatedBy: _analystController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported as PDF'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);
    if (_gapResult == null) return;

    final inputs = {
      'Bundle Type': _selectedBundleType!.shortName,
      'Analysis Date': DateFormat('MMM dd, yyyy').format(_analysisDate),
      'Unit/Location': _unitController.text,
      'Analyst': _analystController.text,
      'Time Period': _timePeriodController.text,
      'Number of Audits': _numberOfAuditsController.text,
    };

    final results = {
      'Gap Severity': _gapResult!.severity.displayName,
      'Current Compliance': '${_gapResult!.currentCompliance.toStringAsFixed(1)}%',
      'Target Compliance': '${_gapResult!.targetCompliance.toStringAsFixed(0)}%',
      'Compliance Gap': '${_gapResult!.complianceGap.toStringAsFixed(1)}%',
    };

    final barriers = _gapResult!.prioritizedBarriers.asMap().entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    final actions = _gapResult!.actionPlan.asMap().entries
        .map((e) => '${e.key + 1}. [${e.value.priority.displayName}] ${e.value.action} (Timeline: ${e.value.timeline}, Responsible: ${e.value.responsible})')
        .join('\n');

    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Bundle Gap Analysis - ${_selectedBundleType!.shortName}',
      inputs: inputs,
      results: results,
      interpretation: _gapResult!.gapSummary,
      recommendations: 'Prioritized Barriers:\n$barriers\n\nAction Plan:\n$actions',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported as Excel'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);
    if (_gapResult == null) return;

    final inputs = {
      'Bundle Type': _selectedBundleType!.shortName,
      'Analysis Date': DateFormat('MMM dd, yyyy').format(_analysisDate),
      'Unit/Location': _unitController.text,
      'Analyst': _analystController.text,
      'Time Period': _timePeriodController.text,
      'Number of Audits': _numberOfAuditsController.text,
    };

    final results = {
      'Gap Severity': _gapResult!.severity.displayName,
      'Current Compliance': '${_gapResult!.currentCompliance.toStringAsFixed(1)}%',
      'Target Compliance': '${_gapResult!.targetCompliance.toStringAsFixed(0)}%',
      'Compliance Gap': '${_gapResult!.complianceGap.toStringAsFixed(1)}%',
    };

    final barriers = _gapResult!.prioritizedBarriers.asMap().entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    final actions = _gapResult!.actionPlan.asMap().entries
        .map((e) => '${e.key + 1}. [${e.value.priority.displayName}] ${e.value.action}\n   Timeline: ${e.value.timeline}\n   Responsible: ${e.value.responsible}')
        .join('\n\n');

    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Bundle Gap Analysis - ${_selectedBundleType!.shortName}',
      inputs: inputs,
      results: results,
      interpretation: _gapResult!.gapSummary,
      recommendations: 'Prioritized Barriers:\n$barriers\n\nAction Plan:\n$actions',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported as Text'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
