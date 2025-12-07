import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../outbreak/data/models/history_entry.dart';
import '../../../outbreak/data/repositories/history_repository.dart';

class ObservationComplianceCalculator extends ConsumerStatefulWidget {
  const ObservationComplianceCalculator({super.key});

  @override
  ConsumerState<ObservationComplianceCalculator> createState() => _ObservationComplianceCalculatorState();
}

class _ObservationComplianceCalculatorState extends ConsumerState<ObservationComplianceCalculator> {
  final _compliantObservationsController = TextEditingController();
  final _totalObservationsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedObservationType = 'Hand Hygiene';
  String _selectedUnitType = 'ICU';
  double? _complianceRate;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isLoading = false;

  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Observation Compliance measures the percentage of observed behaviors that were performed correctly according to established protocols. Unlike audit scores (point-based) or bundle compliance (all-or-nothing), observation compliance focuses on direct observation of individual behaviors in real-time. This metric is essential for hand hygiene monitoring, PPE use, environmental cleaning practices, isolation precautions adherence, and aseptic technique. Higher compliance rates indicate better adherence to evidence-based practices and lower infection risk.',
    formula: 'Observation Compliance % = (Compliant Observations × 100) / Total Observations',
    example: 'Observed 200 hand hygiene opportunities: 165 performed correctly → (165 × 100) / 200 = 82.5% compliance',
    interpretation: 'Higher observation compliance rates indicate better adherence to IPC practices. Target compliance varies by observation type: Hand Hygiene ≥80% (WHO target), PPE Donning/Doffing ≥90% (high-risk procedures), Environmental Cleaning ≥85%, Isolation Precautions ≥90%, Aseptic Technique ≥95%. Low compliance indicates need for education, process improvement, or resource allocation. Compliance should be monitored over time to track improvement and sustain gains.',
    whenUsed: 'Use this calculator to evaluate real-time adherence to IPC practices through direct observation. Essential for hand hygiene monitoring programs, PPE compliance audits, environmental cleaning verification, isolation precautions monitoring, and aseptic technique assessment. Calculate after completing structured observation sessions using standardized checklists. Observations should be conducted by trained observers across different shifts, days, and staff types to ensure representative sampling.',
    inputDataType: 'Number of observations where the behavior was performed correctly (compliant) and total number of observations conducted. Specify observation type and unit type for context. Requires direct observation using validated observation tools. Observations should be unobtrusive when possible to minimize Hawthorne effect (behavior change due to being observed).',
    references: [
      Reference(
        title: 'WHO Hand Hygiene Observation Tool',
        url: 'https://www.who.int/teams/integrated-health-services/infection-prevention-control/hand-hygiene',
      ),
      Reference(
        title: 'CDC Hand Hygiene Guidelines',
        url: 'https://www.cdc.gov/hand-hygiene/index.html',
      ),
      Reference(
        title: 'WHO PPE Guidance',
        url: 'https://www.who.int/publications/i/item/rational-use-of-personal-protective-equipment-for-coronavirus-disease-(covid-19)-and-considerations-during-severe-shortages',
      ),
      Reference(
        title: 'APIC Implementation Guide for Observation Programs',
        url: 'https://apic.org/professional-practice/practice-resources/',
      ),
    ],
  );

  @override
  void dispose() {
    _compliantObservationsController.dispose();
    _totalObservationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'Observation Compliance %',
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
              _buildInputCard(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_complianceRate != null) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
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
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Observation Compliance %',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-Time Behavior Adherence',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ],
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
              Icon(Icons.calculate_outlined, color: AppColors.info, size: 20),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  double fontSize = 14.0;
                  if (constraints.maxWidth < 300) {
                    fontSize = 11.0;
                  } else if (constraints.maxWidth < 400) {
                    fontSize = 12.0;
                  }

                  return Math.tex(
                    r'\text{Observation Compliance \%} = \frac{\text{Compliant Observations} \times 100}{\text{Total Observations}}',
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 20),

          // Observation Type Dropdown
          DropdownButtonFormField<String>(
            value: _selectedObservationType,
            decoration: InputDecoration(
              labelText: 'Observation Type',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.remove_red_eye, color: AppColors.primary),
            ),
            items: const [
              DropdownMenuItem(value: 'Hand Hygiene', child: Text('Hand Hygiene (5 Moments)')),
              DropdownMenuItem(value: 'PPE Donning/Doffing', child: Text('PPE Donning/Doffing')),
              DropdownMenuItem(value: 'Environmental Cleaning', child: Text('Environmental Cleaning')),
              DropdownMenuItem(value: 'Isolation Precautions', child: Text('Isolation Precautions')),
              DropdownMenuItem(value: 'Aseptic Technique', child: Text('Aseptic Technique')),
              DropdownMenuItem(value: 'Sharps Safety', child: Text('Sharps Safety')),
              DropdownMenuItem(value: 'Respiratory Hygiene', child: Text('Respiratory Hygiene/Cough Etiquette')),
              DropdownMenuItem(value: 'Custom Observation', child: Text('Custom Observation')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedObservationType = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Unit Type Dropdown
          DropdownButtonFormField<String>(
            value: _selectedUnitType,
            decoration: InputDecoration(
              labelText: 'Unit Type',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_hospital, color: AppColors.primary),
            ),
            items: const [
              DropdownMenuItem(value: 'ICU', child: Text('ICU (Intensive Care Unit)')),
              DropdownMenuItem(value: 'General Ward', child: Text('General Ward')),
              DropdownMenuItem(value: 'Operating Room', child: Text('Operating Room')),
              DropdownMenuItem(value: 'Emergency Department', child: Text('Emergency Department')),
              DropdownMenuItem(value: 'Outpatient Clinic', child: Text('Outpatient Clinic')),
              DropdownMenuItem(value: 'Facility-wide', child: Text('Facility-wide')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedUnitType = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Compliant Observations
          TextFormField(
            controller: _compliantObservationsController,
            decoration: InputDecoration(
              labelText: 'Compliant Observations',
              hintText: 'Enter number of compliant observations',
              suffixText: 'observations',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.check_circle, color: AppColors.success),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter compliant observations';
              }
              final num = int.tryParse(value);
              if (num == null || num < 0) {
                return 'Please enter a valid number (≥0)';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Total Observations
          TextFormField(
            controller: _totalObservationsController,
            decoration: InputDecoration(
              labelText: 'Total Observations',
              hintText: 'Enter total number of observations',
              suffixText: 'observations',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.format_list_numbered, color: AppColors.primary),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter total observations';
              }
              final num = int.tryParse(value);
              if (num == null || num <= 0) {
                return 'Please enter a valid number (>0)';
              }
              final compliant = int.tryParse(_compliantObservationsController.text) ?? 0;
              if (num < compliant) {
                return 'Total must be ≥ compliant observations';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _calculate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Calculate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      final compliantObs = int.parse(_compliantObservationsController.text);
      final totalObs = int.parse(_totalObservationsController.text);

      // Calculate compliance rate
      final complianceRate = (compliantObs / totalObs) * 100;

      // Get context-specific target based on observation type
      double target;
      String targetDescription;
      switch (_selectedObservationType) {
        case 'Hand Hygiene':
          target = 80.0;
          targetDescription = 'WHO target: ≥80%';
          break;
        case 'PPE Donning/Doffing':
          target = 90.0;
          targetDescription = 'High-risk procedures target: ≥90%';
          break;
        case 'Environmental Cleaning':
          target = 85.0;
          targetDescription = 'Cleaning verification target: ≥85%';
          break;
        case 'Isolation Precautions':
          target = 90.0;
          targetDescription = 'Isolation adherence target: ≥90%';
          break;
        case 'Aseptic Technique':
          target = 95.0;
          targetDescription = 'Sterile procedures target: ≥95%';
          break;
        case 'Sharps Safety':
          target = 95.0;
          targetDescription = 'Sharps safety target: ≥95%';
          break;
        case 'Respiratory Hygiene':
          target = 85.0;
          targetDescription = 'Respiratory hygiene target: ≥85%';
          break;
        default:
          target = 85.0;
          targetDescription = 'General target: ≥85%';
      }

      // Generate interpretation (Higher Compliance = Better)
      String interpretation;
      if (complianceRate >= target) {
        interpretation = 'Excellent Compliance: $_selectedObservationType compliance of ${complianceRate.toStringAsFixed(1)}% meets or exceeds the target of ${target.toStringAsFixed(0)}%. This indicates strong adherence to evidence-based practices and effective implementation of IPC protocols. Continue current practices, recognize high performers, and share success strategies with other units. Monitor compliance over time to sustain gains and identify any emerging trends.';
      } else if (complianceRate >= target - 10) {
        interpretation = 'Good Compliance: $_selectedObservationType compliance of ${complianceRate.toStringAsFixed(1)}% is approaching the target of ${target.toStringAsFixed(0)}%. Most staff are adhering to protocols, but there is room for improvement. Review specific non-compliant observations to identify common barriers or knowledge gaps. Targeted interventions can elevate performance to excellence.';
      } else if (complianceRate >= target - 20) {
        interpretation = 'Moderate Compliance: $_selectedObservationType compliance of ${complianceRate.toStringAsFixed(1)}% is below the target of ${target.toStringAsFixed(0)}%. Significant gaps exist that require focused interventions. Conduct root cause analysis to identify barriers (knowledge, resources, workflow, culture). Implement education, process improvements, and regular monitoring with feedback.';
      } else {
        interpretation = 'Poor Compliance - Action Required: $_selectedObservationType compliance of ${complianceRate.toStringAsFixed(1)}% is significantly below the target of ${target.toStringAsFixed(0)}%. This indicates major gaps in adherence to IPC practices and increased infection risk. Immediate comprehensive intervention is required including intensive education, process redesign, resource allocation, leadership engagement, and real-time monitoring with feedback.';
      }

      // Benchmark information
      final benchmark = 'Observation Compliance Benchmarks: $targetDescription. Benchmarks vary by observation type based on evidence and risk level. Hand Hygiene: ≥80% (WHO), PPE: ≥90%, Environmental Cleaning: ≥85%, Isolation: ≥90%, Aseptic Technique: ≥95%. Compliance should be monitored over time across different shifts, days, and staff types.';

      // Action recommendations if compliance is suboptimal
      String? action;
      if (complianceRate < target - 20) {
        action = 'Immediate Actions for Low Compliance:\n'
            '• Conduct detailed root cause analysis (knowledge, resources, workflow, culture)\n'
            '• Provide intensive education with hands-on training and competency assessment\n'
            '• Ensure adequate supplies and resources are readily available\n'
            '• Simplify processes and remove workflow barriers\n'
            '• Implement real-time monitoring with immediate feedback\n'
            '• Assign unit champions to model and reinforce correct behaviors\n'
            '• Engage leadership to demonstrate commitment and accountability\n'
            '• Consider environmental cues and reminders at point of care';
      } else if (complianceRate < target - 10) {
        action = 'Recommended Actions to Improve Compliance:\n'
            '• Analyze non-compliant observations to identify patterns\n'
            '• Provide targeted education addressing specific gaps\n'
            '• Implement reminders and decision support at point of care\n'
            '• Conduct regular observations with timely feedback\n'
            '• Share best practices from high-performing staff/units\n'
            '• Address resource constraints and workflow barriers\n'
            '• Recognize and celebrate improvements';
      } else if (complianceRate < target) {
        action = 'Recommended Actions to Achieve Excellence:\n'
            '• Fine-tune processes to eliminate remaining gaps\n'
            '• Provide individualized feedback to staff\n'
            '• Implement peer-to-peer coaching and mentoring\n'
            '• Continue regular monitoring to sustain gains\n'
            '• Celebrate successes and recognize high performers\n'
            '• Share success strategies with other units';
      }

      setState(() {
        _complianceRate = complianceRate;
        _interpretation = interpretation;
        _benchmark = benchmark;
        _action = action;
        _isLoading = false;
      });
    });
  }

  void _loadExample() {
    setState(() {
      _selectedObservationType = 'Hand Hygiene';
      _selectedUnitType = 'ICU';
      _compliantObservationsController.text = '165';
      _totalObservationsController.text = '200';
      _complianceRate = null;
      _interpretation = null;
      _benchmark = null;
      _action = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example data loaded'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
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
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Guide',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
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

  Widget _buildResultsCard() {
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
              Icon(Icons.visibility, color: AppColors.success, size: 28),
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

          // Compliance Rate Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success,
                  AppColors.success.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Observation Compliance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_complianceRate!.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_compliantObservationsController.text} / ${_totalObservationsController.text} observations',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Context Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
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
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Observation Context',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Observation Type', _selectedObservationType),
                const SizedBox(height: 8),
                _buildInfoRow('Unit Type', _selectedUnitType),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Interpretation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
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
                    Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Interpretation',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _interpretation!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Benchmark
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Benchmark',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _benchmark!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),

          if (_action != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Recommended Actions',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _action!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveToHistory,
                  icon: Icon(Icons.save, color: AppColors.primary),
                  label: Text('Save', style: TextStyle(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showExportOptions(context),
                  icon: const Icon(Icons.file_download, color: Colors.white),
                  label: const Text('Export', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
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
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _launchURL(reference.url),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.link, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reference.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Icon(Icons.open_in_new, color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveToHistory() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Observation Compliance Calculator',
        inputs: {
          'Observation Type': _selectedObservationType,
          'Unit Type': _selectedUnitType,
          'Compliant Observations': _compliantObservationsController.text,
          'Total Observations': _totalObservationsController.text,
        },
        result: 'Compliance Rate: ${_complianceRate!.toStringAsFixed(2)}%\n'
            'Interpretation: $_interpretation',
        notes: '',
        tags: ['ipc', 'observation', 'compliance', 'audit'],
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

  void _showExportOptions(BuildContext context) {
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
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Export Options',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: ExportModal(
                    onExportPDF: _exportAsPDF,
                    onExportExcel: _exportAsExcel,
                    onExportCSV: _exportAsCSV,
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

    // Extract benchmark target from _benchmark string (e.g., "≥80%" -> 80)
    final benchmarkValue = double.tryParse(_benchmark?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '90') ?? 90;
    final isAboveTarget = _benchmark?.contains('≥') ?? true;

    final success = await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Observation Compliance % Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Observation Type': _selectedObservationType,
        'Unit Type': _selectedUnitType,
        'Compliant Observations': '${_compliantObservationsController.text} observations',
        'Total Observations': '${_totalObservationsController.text} observations',
      },
      results: {
        'Observation Compliance': '${_complianceRate!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': _benchmark ?? '≥90%',
        'unit': 'compliance',
        'source': 'WHO/CDC Guidelines',
        'status': isAboveTarget
            ? (_complianceRate! >= benchmarkValue ? 'Meets Target' : 'Below Target')
            : (_complianceRate! <= benchmarkValue ? 'Meets Target' : 'Above Target'),
      },
      recommendations: _action,
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => '${r.title}: ${r.url}').toList(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported as PDF'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final benchmarkValue = double.tryParse(_benchmark?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '90') ?? 90;
    final isAboveTarget = _benchmark?.contains('≥') ?? true;

    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Observation Compliance % Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Observation Type': _selectedObservationType,
        'Unit Type': _selectedUnitType,
        'Compliant Observations': '${_compliantObservationsController.text} observations',
        'Total Observations': '${_totalObservationsController.text} observations',
      },
      results: {
        'Observation Compliance': '${_complianceRate!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': _benchmark ?? '≥90%',
        'unit': 'compliance',
        'source': 'WHO/CDC Guidelines',
        'status': isAboveTarget
            ? (_complianceRate! >= benchmarkValue ? 'Meets Target' : 'Below Target')
            : (_complianceRate! <= benchmarkValue ? 'Meets Target' : 'Above Target'),
      },
      recommendations: _action,
      interpretation: _interpretation,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported as Excel'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final benchmarkValue = double.tryParse(_benchmark?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '90') ?? 90;
    final isAboveTarget = _benchmark?.contains('≥') ?? true;

    final success = await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Observation Compliance % Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Observation Type': _selectedObservationType,
        'Unit Type': _selectedUnitType,
        'Compliant Observations': '${_compliantObservationsController.text} observations',
        'Total Observations': '${_totalObservationsController.text} observations',
      },
      results: {
        'Observation Compliance': '${_complianceRate!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': _benchmark ?? '≥90%',
        'unit': 'compliance',
        'source': 'WHO/CDC Guidelines',
        'status': isAboveTarget
            ? (_complianceRate! >= benchmarkValue ? 'Meets Target' : 'Below Target')
            : (_complianceRate! <= benchmarkValue ? 'Meets Target' : 'Above Target'),
      },
      recommendations: _action,
      interpretation: _interpretation,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported as CSV'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final benchmarkValue = double.tryParse(_benchmark?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '90') ?? 90;
    final isAboveTarget = _benchmark?.contains('≥') ?? true;

    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Observation Compliance % Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Observation Type': _selectedObservationType,
        'Unit Type': _selectedUnitType,
        'Compliant Observations': '${_compliantObservationsController.text} observations',
        'Total Observations': '${_totalObservationsController.text} observations',
      },
      results: {
        'Observation Compliance': '${_complianceRate!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': _benchmark ?? '≥90%',
        'unit': 'compliance',
        'source': 'WHO/CDC Guidelines',
        'status': isAboveTarget
            ? (_complianceRate! >= benchmarkValue ? 'Meets Target' : 'Below Target')
            : (_complianceRate! <= benchmarkValue ? 'Meets Target' : 'Above Target'),
      },
      recommendations: _action,
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => '${r.title}: ${r.url}').toList(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported as Text'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

