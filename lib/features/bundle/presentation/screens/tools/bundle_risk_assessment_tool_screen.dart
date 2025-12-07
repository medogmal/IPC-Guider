import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/back_button.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../../features/outbreak/data/repositories/history_repository.dart';
import '../../../../../features/outbreak/data/models/history_entry.dart';
import '../../../data/models/bundle_tool_enums.dart';
import '../../../data/models/bundle_risk_assessment.dart';
import '../../../domain/bundle_tool_constants.dart';
import '../../widgets/tools/bundle_tool_header.dart';
import '../../widgets/tools/bundle_tool_input_card.dart';
import '../../widgets/tools/bundle_tool_result_card.dart';

class BundleRiskAssessmentToolScreen extends StatefulWidget {
  const BundleRiskAssessmentToolScreen({super.key});

  @override
  State<BundleRiskAssessmentToolScreen> createState() =>
      _BundleRiskAssessmentToolScreenState();
}

class _BundleRiskAssessmentToolScreenState
    extends State<BundleRiskAssessmentToolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitController = TextEditingController();
  final _assessorController = TextEditingController();
  final _otherPatientRiskController = TextEditingController();
  final _otherUnitRiskController = TextEditingController();
  final _otherStaffingRiskController = TextEditingController();
  final _otherResourceRiskController = TextEditingController();

  BundleType? _selectedBundleType;
  DateTime _assessmentDate = DateTime.now();
  final List<String> _selectedPatientRisks = [];
  final List<String> _selectedUnitRisks = [];
  final List<String> _selectedStaffingRisks = [];
  final List<String> _selectedResourceRisks = [];

  BundleRiskAssessment? _riskResult;

  @override
  void dispose() {
    _unitController.dispose();
    _assessorController.dispose();
    _otherPatientRiskController.dispose();
    _otherUnitRiskController.dispose();
    _otherStaffingRiskController.dispose();
    _otherResourceRiskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Bundle Risk Assessment Tool',
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
                title: 'Bundle Risk Assessment',
                description:
                    'Proactively identify high-risk scenarios and generate mitigation strategies',
                icon: Icons.warning_amber_outlined,
                iconColor: AppColors.warning,
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
                    setState(() => _selectedBundleType = value);
                  },
                  validator: (value) =>
                      value == null ? 'Please select a bundle type' : null,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Assessment Details
              BundleToolInputCard(
                title: 'Assessment Details',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    // Assessment Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Assessment Date'),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(_assessmentDate)),
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

                    // Assessor Name
                    TextFormField(
                      controller: _assessorController,
                      decoration: const InputDecoration(
                        labelText: 'Assessor Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Patient Risk Factors
              _buildRiskFactorSection(
                RiskFactorCategory.patient,
                _selectedPatientRisks,
                _otherPatientRiskController,
              ),
              const SizedBox(height: AppSpacing.medium),

              // Unit Risk Factors
              _buildRiskFactorSection(
                RiskFactorCategory.unit,
                _selectedUnitRisks,
                _otherUnitRiskController,
              ),
              const SizedBox(height: AppSpacing.medium),

              // Staffing Risk Factors
              _buildRiskFactorSection(
                RiskFactorCategory.staffing,
                _selectedStaffingRisks,
                _otherStaffingRiskController,
              ),
              const SizedBox(height: AppSpacing.medium),

              // Resource Risk Factors
              _buildRiskFactorSection(
                RiskFactorCategory.resource,
                _selectedResourceRisks,
                _otherResourceRiskController,
              ),
              const SizedBox(height: AppSpacing.large),

              // Assess Risk Button
              ElevatedButton.icon(
                onPressed: _assessRisk,
                icon: const Icon(Icons.assessment, size: 20),
                label: const Text('Assess Risk'),
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
              if (_riskResult != null) ...[
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

  Widget _buildRiskFactorSection(
    RiskFactorCategory category,
    List<String> selectedRisks,
    TextEditingController otherController,
  ) {
    final factors = BundleToolConstants.riskFactors[category] ?? [];

    return BundleToolInputCard(
      title: category.displayName,
      icon: _getCategoryIcon(category),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select all applicable risk factors:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.small),
          ...factors.map((factor) {
            final isSelected = selectedRisks.contains(factor);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(factor, style: const TextStyle(fontSize: 14)),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedRisks.add(factor);
                  } else {
                    selectedRisks.remove(factor);
                  }
                });
              },
            );
          }),
          const SizedBox(height: AppSpacing.small),
          TextFormField(
            controller: otherController,
            decoration: const InputDecoration(
              labelText: 'Other Risk Factor (Optional)',
              border: OutlineInputBorder(),
              hintText: 'Specify any additional risk factors',
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(RiskFactorCategory category) {
    switch (category) {
      case RiskFactorCategory.patient:
        return Icons.person_outline;
      case RiskFactorCategory.unit:
        return Icons.business_outlined;
      case RiskFactorCategory.staffing:
        return Icons.groups_outlined;
      case RiskFactorCategory.resource:
        return Icons.inventory_2_outlined;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _assessmentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _assessmentDate = picked);
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
                        'Bundle Risk Assessment - Quick Guide',
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
                  'Proactively identify high-risk scenarios for bundle non-compliance and generate targeted mitigation strategies.'),
                const SizedBox(height: 16),
                _buildGuideSection('Steps',
                  '1. Select bundle type (CLABSI, CAUTI, VAP, SSI)\n'
                  '2. Enter assessment details (date, unit, assessor)\n'
                  '3. Select patient risk factors\n'
                  '4. Select unit/environment risk factors\n'
                  '5. Select staffing risk factors\n'
                  '6. Select resource risk factors\n'
                  '7. Tap "Assess Risk" to calculate risk score'),
                const SizedBox(height: 16),
                _buildGuideSection('Risk Categories',
                  '• Patient: Clinical conditions, comorbidities\n'
                  '• Unit: Environment, workflow, facilities\n'
                  '• Staffing: Training, turnover, workload\n'
                  '• Resource: Supplies, equipment, budget'),
                const SizedBox(height: 16),
                _buildGuideSection('Risk Scoring',
                  '• Each factor = 5 points (max 100 per category)\n'
                  '• Total score = average of 4 categories\n'
                  '• Low: 0-29 | Moderate: 30-59 | High: 60-79 | Critical: 80-100'),
                const SizedBox(height: 16),
                _buildGuideSection('Outputs',
                  '• Overall risk level with score\n'
                  '• Category-specific scores\n'
                  '• Mitigation strategies by category\n'
                  '• Priority actions based on risk level'),
                const SizedBox(height: 16),
                _buildGuideSection('Tips',
                  '• Be comprehensive - select all applicable factors\n'
                  '• Reassess regularly (monthly or after changes)\n'
                  '• Share results with leadership\n'
                  '• Track mitigation strategy implementation'),
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

      _assessmentDate = DateTime.now();
      _assessorController.text = 'Dr. Sarah Johnson';

      _selectedPatientRisks.clear();
      _selectedUnitRisks.clear();
      _selectedStaffingRisks.clear();
      _selectedResourceRisks.clear();
      _otherPatientRiskController.clear();
      _otherUnitRiskController.clear();
      _otherStaffingRiskController.clear();
      _otherResourceRiskController.clear();
      _riskResult = null;

      // Context-specific examples for each bundle type
      switch (bundleType) {
        case BundleType.clabsi:
          _unitController.text = 'ICU-A';
          _selectedPatientRisks.addAll([
            'Immunocompromised status',
            'Chronic illness (diabetes, renal failure, etc.)',
            'Prolonged hospitalization',
          ]);
          _selectedUnitRisks.addAll([
            'High patient-to-nurse ratio',
            'High device utilization ratio',
          ]);
          _selectedStaffingRisks.addAll([
            'High staff turnover',
            'Inadequate training',
          ]);
          _selectedResourceRisks.addAll([
            'Limited supply of sterile equipment',
          ]);
          break;

        case BundleType.cauti:
          _unitController.text = 'Medical Ward';
          _selectedPatientRisks.addAll([
            'Prolonged hospitalization',
            'Urinary retention or obstruction',
            'Chronic illness (diabetes, renal failure, etc.)',
          ]);
          _selectedUnitRisks.addAll([
            'High patient-to-nurse ratio',
            'Inadequate hand hygiene compliance',
          ]);
          _selectedStaffingRisks.addAll([
            'Inadequate training',
            'Lack of awareness of guidelines',
          ]);
          _selectedResourceRisks.addAll([
            'Limited supply of sterile equipment',
          ]);
          break;

        case BundleType.vap:
          _unitController.text = 'ICU-B';
          _selectedPatientRisks.addAll([
            'Immunocompromised status',
            'Prolonged hospitalization',
            'Chronic illness (diabetes, renal failure, etc.)',
          ]);
          _selectedUnitRisks.addAll([
            'High device utilization ratio',
            'Inadequate hand hygiene compliance',
          ]);
          _selectedStaffingRisks.addAll([
            'High staff turnover',
            'Inadequate training',
            'Lack of awareness of guidelines',
          ]);
          _selectedResourceRisks.addAll([
            'Limited supply of sterile equipment',
            'Inadequate oral care supplies',
          ]);
          break;

        case BundleType.ssi:
          _unitController.text = 'Surgical Ward';
          _selectedPatientRisks.addAll([
            'Chronic illness (diabetes, renal failure, etc.)',
            'Immunocompromised status',
            'Obesity',
          ]);
          _selectedUnitRisks.addAll([
            'High surgical volume',
            'Inadequate hand hygiene compliance',
          ]);
          _selectedStaffingRisks.addAll([
            'Inadequate training',
            'Lack of awareness of guidelines',
          ]);
          _selectedResourceRisks.addAll([
            'Limited supply of sterile equipment',
            'Inadequate skin antiseptic supplies',
          ]);
          break;

        case BundleType.sepsis:
          _unitController.text = 'Emergency Department';
          _selectedPatientRisks.addAll([
            'Immunocompromised status',
            'Chronic illness (diabetes, renal failure, etc.)',
            'Advanced age (>65 years)',
          ]);
          _selectedUnitRisks.addAll([
            'High patient-to-nurse ratio',
            'Overcrowding',
          ]);
          _selectedStaffingRisks.addAll([
            'High staff turnover',
            'Inadequate training',
          ]);
          _selectedResourceRisks.addAll([
            'Limited supply of sterile equipment',
            'Delayed laboratory results',
          ]);
          break;
      }
    });

    // Show context-specific message
    String exampleDescription;
    switch (bundleType) {
      case BundleType.clabsi:
        exampleDescription = 'CLABSI Bundle: ICU-A with 8 risk factors identified';
        break;
      case BundleType.cauti:
        exampleDescription = 'CAUTI Bundle: Medical Ward with 8 risk factors identified';
        break;
      case BundleType.vap:
        exampleDescription = 'VAP Bundle: ICU-B with 10 risk factors identified';
        break;
      case BundleType.ssi:
        exampleDescription = 'SSI Bundle: Surgical Ward with 9 risk factors identified';
        break;
      case BundleType.sepsis:
        exampleDescription = 'Sepsis Bundle: Emergency Department with 9 risk factors identified';
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

  void _assessRisk() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPatientRisks.isEmpty &&
        _selectedUnitRisks.isEmpty &&
        _selectedStaffingRisks.isEmpty &&
        _selectedResourceRisks.isEmpty &&
        _otherPatientRiskController.text.isEmpty &&
        _otherUnitRiskController.text.isEmpty &&
        _otherStaffingRiskController.text.isEmpty &&
        _otherResourceRiskController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one risk factor'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final result = BundleRiskAssessment.calculate(
      assessmentDate: _assessmentDate,
      bundleType: _selectedBundleType!,
      unitLocation: _unitController.text,
      assessorName: _assessorController.text,
      patientRiskFactors: _selectedPatientRisks,
      otherPatientRisk: _otherPatientRiskController.text.isNotEmpty
          ? _otherPatientRiskController.text
          : null,
      unitRiskFactors: _selectedUnitRisks,
      otherUnitRisk: _otherUnitRiskController.text.isNotEmpty
          ? _otherUnitRiskController.text
          : null,
      staffingRiskFactors: _selectedStaffingRisks,
      otherStaffingRisk: _otherStaffingRiskController.text.isNotEmpty
          ? _otherStaffingRiskController.text
          : null,
      resourceRiskFactors: _selectedResourceRisks,
      otherResourceRisk: _otherResourceRiskController.text.isNotEmpty
          ? _otherResourceRiskController.text
          : null,
    );

    setState(() => _riskResult = result);

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
    if (_riskResult == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Risk Level Badge
        _buildRiskLevelBadge(),
        const SizedBox(height: AppSpacing.medium),

        // Risk Scores Table
        _buildRiskScoresTable(),
        const SizedBox(height: AppSpacing.medium),

        // Risk Summary
        _buildRiskSummaryCard(),
        const SizedBox(height: AppSpacing.medium),

        // Mitigation Strategies
        _buildMitigationStrategiesCard(),
        const SizedBox(height: AppSpacing.medium),

        // Priority Actions
        _buildPriorityActionsCard(),
        const SizedBox(height: AppSpacing.large),

        // Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildRiskLevelBadge() {
    final level = _riskResult!.riskLevel;
    final color = _getRiskLevelColor(level);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(_getRiskLevelIcon(level), color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${level.displayName} Risk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'Risk Score: ${_riskResult!.totalRiskScore}/100',
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskScoresTable() {
    return BundleToolResultCard(
      title: 'Risk Scores by Category',
      icon: Icons.bar_chart,
      color: AppColors.primary,
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              _buildTableCell('Category', isHeader: true),
              _buildTableCell('Score', isHeader: true),
            ],
          ),
          _buildScoreRow('Patient Factors', _riskResult!.patientRiskScore),
          _buildScoreRow('Unit Environment', _riskResult!.unitRiskScore),
          _buildScoreRow('Staffing', _riskResult!.staffingRiskScore),
          _buildScoreRow('Resources', _riskResult!.resourceRiskScore),
          TableRow(
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1)),
            children: [
              _buildTableCell('Total Risk Score', isHeader: true),
              _buildTableCell('${_riskResult!.totalRiskScore}/100', isHeader: true),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildScoreRow(String category, int score) {
    return TableRow(
      children: [
        _buildTableCell(category),
        _buildTableCell('$score/100'),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildRiskSummaryCard() {
    return BundleToolResultCard(
      title: 'Risk Summary',
      icon: Icons.summarize,
      color: AppColors.info,
      child: Text(
        _riskResult!.riskSummary,
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildMitigationStrategiesCard() {
    return BundleToolResultCard(
      title: 'Mitigation Strategies',
      icon: Icons.shield_outlined,
      color: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _riskResult!.mitigationStrategies.asMap().entries.map((entry) {
          final index = entry.key;
          final strategy = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _riskResult!.mitigationStrategies.length - 1
                  ? AppSpacing.medium
                  : 0,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(strategy.category),
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strategy.category.displayName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(strategy.priority),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          strategy.priority,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strategy.strategy,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        strategy.timeline,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        strategy.responsible,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriorityActionsCard() {
    return BundleToolResultCard(
      title: 'Priority Actions',
      icon: Icons.checklist,
      color: AppColors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _riskResult!.priorityActions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _riskResult!.priorityActions.length - 1
                  ? AppSpacing.small
                  : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    action,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
              'CDC. Guidelines for Environmental Infection Control in Health-Care Facilities',
              'https://www.cdc.gov/infectioncontrol/guidelines/environmental/',
            ),
            const SizedBox(height: AppSpacing.small),
            _buildReferenceItem(
              'WHO. Guidelines on Core Components of Infection Prevention and Control Programmes',
              'https://www.who.int/publications/i/item/9789241549929',
            ),
            const SizedBox(height: AppSpacing.small),
            _buildReferenceItem(
              'APIC. Implementation Guide: Risk Assessment',
              'https://apic.org/resources/',
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

  Future<void> _saveToHistory() async {
    if (_riskResult == null) return;

    final entry = HistoryEntry(
      timestamp: DateTime.now(),
      toolType: 'Bundle Tool',
      title: 'Bundle Risk Assessment - ${_selectedBundleType!.shortName}',
      inputs: {
        'Unit': _unitController.text,
        'Assessor': _assessorController.text,
        'Patient Risks': _selectedPatientRisks.length.toString(),
        'Unit Risks': _selectedUnitRisks.length.toString(),
        'Staffing Risks': _selectedStaffingRisks.length.toString(),
        'Resource Risks': _selectedResourceRisks.length.toString(),
      },
      result: '${_riskResult!.riskLevel.displayName} Risk (${_riskResult!.totalRiskScore}/100)',
      notes: _riskResult!.riskSummary,
    );

    await HistoryRepository().addEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Risk assessment saved to history'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showExportModal() {
    if (_riskResult == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ExportModal(
        onExportPDF: () async {
          Navigator.pop(context);
          await _exportAsPDF();
        },
        onExportCSV: () async {
          Navigator.pop(context);
          await _exportAsCSV();
        },
        onExportExcel: () async {
          Navigator.pop(context);
          await _exportAsExcel();
        },
        onExportText: () async {
          Navigator.pop(context);
          await _exportAsText();
        },
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    if (_riskResult == null) return;

    final toolName = 'Bundle Risk Assessment - ${_selectedBundleType!.shortName}';

    final inputs = {
      'Bundle Type': _selectedBundleType!.shortName,
      'Assessment Date': DateFormat('MMM dd, yyyy').format(_assessmentDate),
      'Unit/Location': _unitController.text,
      'Assessor': _assessorController.text,
    };

    final results = {
      'Patient Risk Score': '${_riskResult!.patientRiskScore}/100',
      'Unit Risk Score': '${_riskResult!.unitRiskScore}/100',
      'Staffing Risk Score': '${_riskResult!.staffingRiskScore}/100',
      'Resource Risk Score': '${_riskResult!.resourceRiskScore}/100',
      'Total Risk Score': '${_riskResult!.totalRiskScore}/100',
      'Risk Level': _riskResult!.riskLevel.displayName,
    };

    final interpretation = _riskResult!.riskSummary;

    final recommendations = _riskResult!.priorityActions
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    final success = await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: toolName,
      inputs: inputs,
      results: results,
      interpretation: interpretation,
      recommendations: recommendations,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported to PDF successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsExcel() async {
    if (_riskResult == null) return;

    final toolName = 'Bundle Risk Assessment - ${_selectedBundleType!.shortName}';

    final inputs = {
      'Bundle Type': _selectedBundleType!.shortName,
      'Assessment Date': DateFormat('MMM dd, yyyy').format(_assessmentDate),
      'Unit/Location': _unitController.text,
      'Assessor': _assessorController.text,
    };

    final results = {
      'Patient Risk Score': '${_riskResult!.patientRiskScore}/100',
      'Unit Risk Score': '${_riskResult!.unitRiskScore}/100',
      'Staffing Risk Score': '${_riskResult!.staffingRiskScore}/100',
      'Resource Risk Score': '${_riskResult!.resourceRiskScore}/100',
      'Total Risk Score': '${_riskResult!.totalRiskScore}/100',
      'Risk Level': _riskResult!.riskLevel.displayName,
    };

    final interpretation = _riskResult!.riskSummary;

    final recommendations = _riskResult!.priorityActions
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: toolName,
      inputs: inputs,
      results: results,
      interpretation: interpretation,
      recommendations: recommendations,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported to Excel successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsCSV() async {
    if (_riskResult == null) return;

    final toolName = 'Bundle Risk Assessment - ${_selectedBundleType!.shortName}';

    final inputs = {
      'Bundle Type': _selectedBundleType!.shortName,
      'Assessment Date': DateFormat('MMM dd, yyyy').format(_assessmentDate),
      'Unit/Location': _unitController.text,
      'Assessor': _assessorController.text,
    };

    final results = {
      'Patient Risk Score': '${_riskResult!.patientRiskScore}/100',
      'Unit Risk Score': '${_riskResult!.unitRiskScore}/100',
      'Staffing Risk Score': '${_riskResult!.staffingRiskScore}/100',
      'Resource Risk Score': '${_riskResult!.resourceRiskScore}/100',
      'Total Risk Score': '${_riskResult!.totalRiskScore}/100',
      'Risk Level': _riskResult!.riskLevel.displayName,
    };

    final interpretation = _riskResult!.riskSummary;

    final recommendations = _riskResult!.priorityActions
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    final success = await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: toolName,
      inputs: inputs,
      results: results,
      interpretation: interpretation,
      recommendations: recommendations,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported to CSV successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsText() async {
    if (_riskResult == null) return;

    final toolName = 'Bundle Risk Assessment - ${_selectedBundleType!.shortName}';

    final inputs = {
      'Bundle Type': _selectedBundleType!.shortName,
      'Assessment Date': DateFormat('MMM dd, yyyy').format(_assessmentDate),
      'Unit/Location': _unitController.text,
      'Assessor': _assessorController.text,
    };

    final results = {
      'Patient Risk Score': '${_riskResult!.patientRiskScore}/100',
      'Unit Risk Score': '${_riskResult!.unitRiskScore}/100',
      'Staffing Risk Score': '${_riskResult!.staffingRiskScore}/100',
      'Resource Risk Score': '${_riskResult!.resourceRiskScore}/100',
      'Total Risk Score': '${_riskResult!.totalRiskScore}/100',
      'Risk Level': _riskResult!.riskLevel.displayName,
    };

    final interpretation = _riskResult!.riskSummary;

    final recommendations = _riskResult!.priorityActions
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: toolName,
      inputs: inputs,
      results: results,
      interpretation: interpretation,
      recommendations: recommendations,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported to Text successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Color _getRiskLevelColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppColors.success;
      case RiskLevel.moderate:
        return AppColors.warning;
      case RiskLevel.high:
        return Colors.orange;
      case RiskLevel.critical:
        return AppColors.error;
    }
  }

  IconData _getRiskLevelIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.moderate:
        return Icons.warning_amber;
      case RiskLevel.high:
        return Icons.error_outline;
      case RiskLevel.critical:
        return Icons.dangerous;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }
}
