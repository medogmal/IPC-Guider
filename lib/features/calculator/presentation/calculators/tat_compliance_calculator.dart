import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../outbreak/data/models/history_entry.dart';
import '../../../outbreak/data/repositories/history_repository.dart';

class TATComplianceCalculator extends ConsumerStatefulWidget {
  const TATComplianceCalculator({super.key});

  @override
  ConsumerState<TATComplianceCalculator> createState() =>
      _TATComplianceCalculatorState();
}

class _TATComplianceCalculatorState
    extends ConsumerState<TATComplianceCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _reportsWithinTargetController = TextEditingController();
  final _totalReportsController = TextEditingController();
  final _customTATController = TextEditingController();

  String _selectedSpecimenType = 'Blood Culture';
  double? _complianceRate;
  String? _interpretation;
  bool _isCalculated = false;

  final Map<String, int> _tatTargets = {
    'Blood Culture': 120, // 5 days in hours
    'Urine Culture': 48, // 2 days
    'Stool Culture': 72, // 3 days
    'Sputum Culture': 48, // 2 days
    'CSF Culture': 24, // 1 day (critical)
    'Wound/Swab Culture': 48, // 2 days
    'Tissue Culture': 72, // 3 days
    'Sterile Body Fluid Culture': 48, // 2 days
    'Molecular/PCR': 24, // 1 day
    'Custom': 0, // User enters their own
  };

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'TAT (Turnaround Time) Compliance % measures the percentage of laboratory reports delivered within the established target time. This is a critical quality indicator reflecting laboratory efficiency and impact on patient care.',
    formula: '(Reports Within Target TAT ÷ Total Reports) × 100',
    example: '850 reports within target out of 900 total reports → 94.4% TAT compliance',
    interpretation: 'Higher compliance rates indicate efficient laboratory operations and timely reporting. Target: ≥90% for most test types. Low compliance suggests need for workflow optimization, staffing adjustments, or equipment upgrades.',
    whenUsed: 'Use this calculator for continuous monitoring of laboratory performance and quality improvement. Essential for laboratory accreditation, service level agreements, and identifying bottlenecks. Calculate monthly or quarterly for trend analysis and benchmarking.',
    inputDataType: 'Number of reports delivered within target TAT and total reports for the surveillance period. Specify specimen/test type for accurate benchmarking. TAT targets vary by test urgency and complexity.',
    references: [
      Reference(
        title: 'CLSI GP29: Assessment of Laboratory Tests When Proficiency Testing Is Not Available',
        url: 'https://clsi.org/standards/products/quality-management-system/documents/gp29/',
      ),
      Reference(
        title: 'CAP Laboratory Accreditation Program - TAT Standards',
        url: 'https://www.cap.org/laboratory-improvement/accreditation/laboratory-accreditation-program',
      ),
      Reference(
        title: 'WHO Guidelines on Laboratory Quality Management',
        url: 'https://www.who.int/publications/i/item/9789241548274',
      ),
    ],
  );

  @override
  void dispose() {
    _reportsWithinTargetController.dispose();
    _totalReportsController.dispose();
    _customTATController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'TAT Compliance %',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Header Card
              _buildHeaderCard(),
              const SizedBox(height: 16),

              // Formula Card
              _buildFormulaCard(),
              const SizedBox(height: 16),

              // Quick Guide Button
              _buildQuickGuideButton(),
              const SizedBox(height: 12),

              // Load Example Button
              _buildLoadExampleButton(),
              const SizedBox(height: 16),

              // Specimen Type Dropdown
              _buildSpecimenTypeDropdown(),
              const SizedBox(height: 20),

              // Input Card
              _buildInputCard(),
              const SizedBox(height: 20),

              // Calculate Button
              _buildCalculateButton(),

              if (_isCalculated) ...[
                const SizedBox(height: 20),
                _buildResultsCard(),
                const SizedBox(height: 20),
                _buildTATTargetCard(),
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
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
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
      child: Column(
        children: [
          Icon(Icons.timer, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            'TAT Compliance %',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Turnaround Time Performance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
            textAlign: TextAlign.center,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Formula',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
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
                    r'\text{TAT Compliance } \% = \frac{\text{Reports Within Target Time} \times 100}{\text{Total Reports}}',
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

  Widget _buildSpecimenTypeDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Specimen Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecimenType,
              decoration: InputDecoration(
                labelText: 'Select Specimen Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              items: _tatTargets.keys.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpecimenType = value!;
                  _isCalculated = false;
                });
              },
            ),
            if (_selectedSpecimenType != 'Custom') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Target TAT: ${_tatTargets[_selectedSpecimenType]} hours (${(_tatTargets[_selectedSpecimenType]! / 24).toStringAsFixed(1)} days)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.input, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Input Data',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedSpecimenType == 'Custom') ...[
              TextFormField(
                controller: _customTATController,
                decoration: InputDecoration(
                  labelText: 'Custom TAT Target (hours)',
                  hintText: 'Enter TAT target in hours',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.access_time, color: AppColors.warning),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter TAT target';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (int.parse(value) <= 0) {
                    return 'Value must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _reportsWithinTargetController,
              decoration: InputDecoration(
                labelText: 'Reports Within Target Time',
                hintText: 'Enter number of reports within TAT',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.check_circle, color: AppColors.success),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter reports within target';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) < 0) {
                  return 'Value cannot be negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalReportsController,
              decoration: InputDecoration(
                labelText: 'Total Reports',
                hintText: 'Enter total number of reports',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.all_inbox, color: AppColors.info),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total reports';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) <= 0) {
                  return 'Value must be greater than 0';
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
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _calculate();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calculate, size: 24),
          const SizedBox(width: 12),
          Text(
            'Calculate',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  void _calculate() {
    final reportsWithinTarget = int.parse(_reportsWithinTargetController.text);
    final totalReports = int.parse(_totalReportsController.text);

    if (reportsWithinTarget > totalReports) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reports within target cannot exceed total reports'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _complianceRate = (reportsWithinTarget * 100) / totalReports;

      // Interpretation
      if (_complianceRate! >= 95.0) {
        _interpretation =
            'Excellent TAT performance (≥95%). Your turnaround time compliance exceeds the benchmark of 90% for $_selectedSpecimenType. This indicates excellent laboratory efficiency and workflow management. Continue current practices and use as a benchmark for training.';
      } else if (_complianceRate! >= 90.0) {
        _interpretation =
            'Acceptable performance (90-94%). Your TAT compliance meets the benchmark of ≥90% for $_selectedSpecimenType. While acceptable, there is room for improvement. Review workflow bottlenecks and staffing to achieve ≥95%.';
      } else if (_complianceRate! >= 85.0) {
        _interpretation =
            'Needs improvement (85-89%). Your TAT compliance is below the benchmark of 90% for $_selectedSpecimenType. Action required: Process review to identify bottlenecks, staffing assessment, workflow optimization, and implementation of corrective measures. Poor TAT impacts clinical decision-making.';
      } else {
        _interpretation =
            'Critical (<85%). Your TAT compliance is critically low for $_selectedSpecimenType. Immediate intervention required: Comprehensive process audit, staffing evaluation, equipment assessment, workflow redesign, and implementation of quality improvement initiatives. Poor TAT leads to delayed diagnosis, increased length of stay, and compromised patient outcomes.';
      }

      _isCalculated = true;
    });
  }

  Color _getResultColor() {
    if (_complianceRate! >= 95.0) {
      return AppColors.success;
    } else if (_complianceRate! >= 90.0) {
      return AppColors.info;
    } else if (_complianceRate! >= 85.0) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  int _getTATTarget() {
    if (_selectedSpecimenType == 'Custom') {
      return int.parse(_customTATController.text);
    }
    return _tatTargets[_selectedSpecimenType]!;
  }

  Widget _buildResultsCard() {
    final resultColor = _getResultColor();
    final tatTarget = _getTATTarget();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: resultColor, width: 2),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: resultColor, size: 28),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: resultColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'TAT Compliance Rate',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_complianceRate!.toStringAsFixed(2)}%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: resultColor,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Specimen Type: $_selectedSpecimenType',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TAT Target: $tatTarget hours (${(tatTarget / 24).toStringAsFixed(1)} days)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Benchmark: ≥90%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interpretation',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _interpretation!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveToHistory,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showExportModal(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTATTargetCard() {
    final tatTarget = _getTATTarget();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.warning, size: 24),
              const SizedBox(width: 12),
              Text(
                'TAT Target: $_selectedSpecimenType',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, color: AppColors.warning, size: 20),
              const SizedBox(width: 12),
              Text(
                '$tatTarget hours (${(tatTarget / 24).toStringAsFixed(1)} days)',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'TAT is measured from specimen collection to final report availability. Critical specimens (CSF, Molecular/PCR) have shorter TAT targets due to clinical urgency.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
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

  void _loadExample() {
    setState(() {
      if (_selectedSpecimenType == 'Blood Culture') {
        _reportsWithinTargetController.text = '355';
        _totalReportsController.text = '380';
      } else if (_selectedSpecimenType == 'CSF Culture') {
        _reportsWithinTargetController.text = '47';
        _totalReportsController.text = '50';
      } else if (_selectedSpecimenType == 'Custom') {
        _customTATController.text = '48';
        _reportsWithinTargetController.text = '85';
        _totalReportsController.text = '92';
      } else {
        _reportsWithinTargetController.text = '180';
        _totalReportsController.text = '200';
      }
      _isCalculated = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded for $_selectedSpecimenType'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
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
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, color: AppColors.info, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Guide',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.textTertiary.withValues(alpha: 0.2)),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: KnowledgePanelWidget(data: _knowledgePanelData),
                ),
              ),
            ],
          ),
        ),
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
              Icon(Icons.library_books, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Scientific References',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReferenceItem(
            '1. CLSI GP29: Assessment of Laboratory Tests When Proficiency Testing Is Not Available',
            'Clinical and Laboratory Standards Institute guidelines for TAT monitoring',
          ),
          const SizedBox(height: 12),
          _buildReferenceItem(
            '2. CAP Laboratory Accreditation Program - TAT Standards',
            'College of American Pathologists standards for turnaround time compliance',
          ),
          const SizedBox(height: 12),
          _buildReferenceItem(
            '3. WHO Guidelines on Laboratory Quality Management',
            'World Health Organization recommendations for laboratory performance metrics',
          ),
          const SizedBox(height: 12),
          _buildReferenceItem(
            '4. IDSA Guidelines: Diagnostic Microbiology Turnaround Times',
            'Infectious Diseases Society of America guidelines for timely diagnostic reporting',
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToHistory() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'TAT Compliance Calculator',
        inputs: {
          'Specimen Type': _selectedSpecimenType,
          'TAT Target': '${_getTATTarget()} minutes',
          'Reports Within Target': _reportsWithinTargetController.text,
          'Total Reports': _totalReportsController.text,
        },
        result: 'Compliance Rate: ${_complianceRate!.toStringAsFixed(2)}%\n'
            'Interpretation: $_interpretation',
        notes: '',
        tags: ['laboratory', 'tat', 'turnaround-time', 'quality'],
      );

      await repository.addEntry(historyEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to history'),
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

  void _showExportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: SafeArea(
            child: ExportModal(
              onExportPDF: _exportAsPDF,
              onExportExcel: _exportAsExcel,
              onExportCSV: _exportAsCSV,
              onExportText: _exportAsText,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    final tatTarget = _getTATTarget();
    final success = await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'TAT Compliance %',
      formula: '(Reports Within Target × 100) / Total Reports',
      inputs: {
        'Specimen Type': _selectedSpecimenType,
        'TAT Target': '$tatTarget hours (${(tatTarget / 24).toStringAsFixed(1)} days)',
        'Reports Within Target': _reportsWithinTargetController.text,
        'Total Reports': _totalReportsController.text,
      },
      results: {
        'TAT Compliance Rate': '${_complianceRate!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': '≥90%',
        'unit': 'TAT compliance',
        'source': 'CAP Laboratory Standards',
        'status': _complianceRate! >= 90 ? 'Meets Target' : 'Below Target',
      },
      interpretation: _interpretation,
      references: [
        'CLSI GP29: Assessment of Laboratory Tests When Proficiency Testing Is Not Available',
        'CAP Laboratory Accreditation Program - TAT Standards',
        'WHO Guidelines on Laboratory Quality Management',
        'IDSA Guidelines: Diagnostic Microbiology Turnaround Times',
      ],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Exported as PDF' : 'Export failed'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _exportAsExcel() async {
    final tatTarget = _getTATTarget();
    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'TAT Compliance %',
      formula: '(Reports Within Target × 100) / Total Reports',
      inputs: {
        'Specimen Type': _selectedSpecimenType,
        'TAT Target': '$tatTarget hours (${(tatTarget / 24).toStringAsFixed(1)} days)',
        'Reports Within Target': _reportsWithinTargetController.text,
        'Total Reports': _totalReportsController.text,
      },
      results: {
        'TAT Compliance Rate': '${_complianceRate!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': '≥90%',
        'unit': 'TAT compliance',
        'source': 'CAP Laboratory Standards',
        'status': _complianceRate! >= 90 ? 'Meets Target' : 'Below Target',
      },
      interpretation: _interpretation,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Exported as Excel' : 'Export failed'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _exportAsCSV() async {
    final tatTarget = _getTATTarget();
    final success = await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'TAT Compliance %',
      formula: '(Reports Within Target × 100) / Total Reports',
      inputs: {
        'Specimen Type': _selectedSpecimenType,
        'TAT Target': '$tatTarget hours (${(tatTarget / 24).toStringAsFixed(1)} days)',
        'Reports Within Target': _reportsWithinTargetController.text,
        'Total Reports': _totalReportsController.text,
      },
      results: {
        'TAT Compliance Rate': '${_complianceRate!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': '≥90%',
        'unit': 'TAT compliance',
        'source': 'CAP Laboratory Standards',
        'status': _complianceRate! >= 90 ? 'Meets Target' : 'Below Target',
      },
      interpretation: _interpretation,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Exported as CSV' : 'Export failed'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _exportAsText() async {
    final tatTarget = _getTATTarget();
    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'TAT Compliance %',
      formula: '(Reports Within Target × 100) / Total Reports',
      inputs: {
        'Specimen Type': _selectedSpecimenType,
        'TAT Target': '$tatTarget hours (${(tatTarget / 24).toStringAsFixed(1)} days)',
        'Reports Within Target': _reportsWithinTargetController.text,
        'Total Reports': _totalReportsController.text,
      },
      results: {
        'TAT Compliance Rate': '${_complianceRate!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': '≥90%',
        'unit': 'TAT compliance',
        'source': 'CAP Laboratory Standards',
        'status': _complianceRate! >= 90 ? 'Meets Target' : 'Below Target',
      },
      interpretation: _interpretation,
      references: [
        'CLSI GP29: Assessment of Laboratory Tests When Proficiency Testing Is Not Available',
        'CAP Laboratory Accreditation Program - TAT Standards',
        'WHO Guidelines on Laboratory Quality Management',
        'IDSA Guidelines: Diagnostic Microbiology Turnaround Times',
      ],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Exported as Text' : 'Export failed'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}



