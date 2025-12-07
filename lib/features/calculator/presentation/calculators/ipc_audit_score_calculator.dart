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

class IPCAuditScoreCalculator extends ConsumerStatefulWidget {
  const IPCAuditScoreCalculator({super.key});

  @override
  ConsumerState<IPCAuditScoreCalculator> createState() => _IPCAuditScoreCalculatorState();
}

class _IPCAuditScoreCalculatorState extends ConsumerState<IPCAuditScoreCalculator> {
  final _achievedPointsController = TextEditingController();
  final _totalPointsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedAuditType = 'Comprehensive IPC Audit';
  String _selectedUnitType = 'Facility-wide';
  double? _auditScore;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isLoading = false;

  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'IPC Audit Score measures overall infection prevention and control program performance using a point-based scoring system. Unlike bundle compliance (all-or-nothing), audit scores allow partial credit for each domain assessed. This comprehensive metric evaluates multiple IPC practices including hand hygiene, PPE use, environmental cleaning, waste management, isolation precautions, equipment reprocessing, surveillance systems, and staff competency. Higher scores indicate stronger IPC programs and better patient safety.',
    formula: 'IPC Audit Score % = (Achieved Points × 100) / Total Possible Points',
    example: 'Facility achieved 450 points out of 500 possible points in quarterly IPC audit → (450 × 100) / 500 = 90% audit score',
    interpretation: 'Higher audit scores indicate better overall IPC program performance. Scores ≥90% demonstrate excellent IPC practices across all domains. Scores 80-90% are good but show room for improvement. Scores 70-80% are acceptable but require focused interventions. Scores <70% indicate significant gaps requiring immediate action. This metric is useful for accreditation preparation, facility benchmarking, and demonstrating program effectiveness to leadership.',
    whenUsed: 'Use this calculator to evaluate overall IPC program performance during quarterly or annual comprehensive audits. Essential for accreditation preparation, facility-wide quality improvement initiatives, benchmarking against national standards, and demonstrating program value to hospital leadership. Calculate after completing structured IPC audits using standardized checklists. Can be used for unit-specific or facility-wide assessments.',
    inputDataType: 'Total points achieved across all audit domains and total possible points from the audit tool. Specify audit type and unit type for context. Requires completed audit using a validated, point-based IPC assessment tool. Points may be weighted based on domain criticality.',
    references: [
      Reference(
        title: 'WHO IPC Assessment Framework (IPCAF)',
        url: 'https://www.who.int/publications/i/item/9789241511612',
      ),
      Reference(
        title: 'CDC IPC Assessment Tool',
        url: 'https://www.cdc.gov/infectioncontrol/guidelines/index.html',
      ),
      Reference(
        title: 'Joint Commission IPC Standards',
        url: 'https://www.jointcommission.org/standards/standard-faqs/hospital-and-hospital-clinics/infection-prevention-and-control-ic/',
      ),
      Reference(
        title: 'APIC Implementation Guide',
        url: 'https://apic.org/professional-practice/practice-resources/',
      ),
    ],
  );

  @override
  void dispose() {
    _achievedPointsController.dispose();
    _totalPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'IPC Audit Score %',
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
              if (_auditScore != null) ...[
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
              Icon(Icons.assessment, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IPC Audit Score %',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Overall IPC Program Performance',
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
                    r'\text{IPC Audit Score \%} = \frac{\text{Achieved Points} \times 100}{\text{Total Possible Points}}',
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

          // Audit Type Dropdown
          DropdownButtonFormField<String>(
            value: _selectedAuditType,
            decoration: InputDecoration(
              labelText: 'Audit Type',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.assignment, color: AppColors.primary),
            ),
            items: const [
              DropdownMenuItem(value: 'Comprehensive IPC Audit', child: Text('Comprehensive IPC Audit')),
              DropdownMenuItem(value: 'Hand Hygiene Audit', child: Text('Hand Hygiene Audit')),
              DropdownMenuItem(value: 'Environmental Cleaning Audit', child: Text('Environmental Cleaning Audit')),
              DropdownMenuItem(value: 'PPE Compliance Audit', child: Text('PPE Compliance Audit')),
              DropdownMenuItem(value: 'Isolation Precautions Audit', child: Text('Isolation Precautions Audit')),
              DropdownMenuItem(value: 'Sterilization & Reprocessing Audit', child: Text('Sterilization & Reprocessing Audit')),
              DropdownMenuItem(value: 'Custom Audit', child: Text('Custom Audit')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedAuditType = value!;
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
              DropdownMenuItem(value: 'Facility-wide', child: Text('Facility-wide')),
              DropdownMenuItem(value: 'ICU', child: Text('ICU (Intensive Care Unit)')),
              DropdownMenuItem(value: 'General Ward', child: Text('General Ward')),
              DropdownMenuItem(value: 'Operating Room', child: Text('Operating Room')),
              DropdownMenuItem(value: 'Emergency Department', child: Text('Emergency Department')),
              DropdownMenuItem(value: 'CSSD', child: Text('CSSD (Central Sterile Supply)')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedUnitType = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Achieved Points
          TextFormField(
            controller: _achievedPointsController,
            decoration: InputDecoration(
              labelText: 'Achieved Points',
              hintText: 'Enter points achieved',
              suffixText: 'points',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.check_circle, color: AppColors.success),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter achieved points';
              }
              final num = double.tryParse(value);
              if (num == null || num < 0) {
                return 'Please enter a valid number (≥0)';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Total Possible Points
          TextFormField(
            controller: _totalPointsController,
            decoration: InputDecoration(
              labelText: 'Total Possible Points',
              hintText: 'Enter total possible points',
              suffixText: 'points',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.format_list_numbered, color: AppColors.primary),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter total possible points';
              }
              final num = double.tryParse(value);
              if (num == null || num <= 0) {
                return 'Please enter a valid number (>0)';
              }
              final achieved = double.tryParse(_achievedPointsController.text) ?? 0;
              if (num < achieved) {
                return 'Total points must be ≥ achieved points';
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
      final achievedPoints = double.parse(_achievedPointsController.text);
      final totalPoints = double.parse(_totalPointsController.text);

      // Calculate audit score percentage
      final auditScore = (achievedPoints / totalPoints) * 100;

      // Generate interpretation (Higher Score = Better)
      String interpretation;
      if (auditScore >= 90) {
        interpretation = 'Excellent IPC Program Performance: Audit score of ${auditScore.toStringAsFixed(1)}% demonstrates outstanding infection prevention and control practices across all assessed domains. This indicates a mature, well-functioning IPC program with strong leadership support, adequate resources, and consistent implementation of evidence-based practices. Continue current practices and share success strategies with other facilities.';
      } else if (auditScore >= 80) {
        interpretation = 'Good IPC Program Performance: Audit score of ${auditScore.toStringAsFixed(1)}% indicates good overall IPC practices with some areas for improvement. Most domains meet acceptable standards, but targeted interventions in lower-scoring areas can elevate performance to excellence. Review specific domain scores to identify improvement opportunities.';
      } else if (auditScore >= 70) {
        interpretation = 'Acceptable IPC Program Performance: Audit score of ${auditScore.toStringAsFixed(1)}% meets minimum acceptable standards but shows significant room for improvement. Several domains likely have gaps requiring focused interventions. Prioritize high-impact areas such as hand hygiene, environmental cleaning, and isolation precautions. Enhanced education, process improvements, and regular monitoring are needed.';
      } else {
        interpretation = 'Poor IPC Program Performance - Action Required: Audit score of ${auditScore.toStringAsFixed(1)}% is significantly below acceptable standards and indicates major gaps in infection prevention practices. Immediate comprehensive intervention is required across multiple domains. This score suggests inadequate resources, insufficient training, weak leadership support, or systemic barriers to IPC implementation. Urgent action plan needed.';
      }

      // Benchmark information
      final benchmark = 'IPC Audit Score Benchmarks: ≥90% (excellent - target level), 80-90% (good - approaching excellence), 70-80% (acceptable - meets minimum standards), <70% (poor - immediate action required). Benchmarks may vary by audit tool and facility type.';

      // Action recommendations if score is suboptimal
      String? action;
      if (auditScore < 70) {
        action = 'Immediate Actions for Low Audit Score:\n'
            '• Conduct detailed root cause analysis for each low-scoring domain\n'
            '• Secure leadership commitment and adequate resources\n'
            '• Develop comprehensive IPC improvement action plan\n'
            '• Provide intensive staff education and competency assessment\n'
            '• Implement real-time monitoring and feedback systems\n'
            '• Assign IPC champions for each unit/domain\n'
            '• Engage external IPC expertise for consultation\n'
            '• Establish regular leadership review of IPC metrics';
      } else if (auditScore < 80) {
        action = 'Recommended Actions to Improve Audit Score:\n'
            '• Identify specific domains with lowest scores\n'
            '• Provide targeted education for low-performing areas\n'
            '• Implement process improvements and decision support tools\n'
            '• Conduct regular audits with timely feedback\n'
            '• Share best practices from high-performing units\n'
            '• Address resource constraints and workflow barriers\n'
            '• Enhance surveillance and reporting systems';
      } else if (auditScore < 90) {
        action = 'Recommended Actions to Achieve Excellence:\n'
            '• Fine-tune processes in lower-scoring domains\n'
            '• Implement advanced IPC practices and innovations\n'
            '• Provide ongoing education and competency maintenance\n'
            '• Strengthen culture of safety and accountability\n'
            '• Continue regular monitoring and continuous improvement\n'
            '• Pursue IPC program accreditation or certification';
      }

      setState(() {
        _auditScore = auditScore;
        _interpretation = interpretation;
        _benchmark = benchmark;
        _action = action;
        _isLoading = false;
      });
    });
  }

  void _loadExample() {
    setState(() {
      _selectedAuditType = 'Comprehensive IPC Audit';
      _selectedUnitType = 'Facility-wide';
      _achievedPointsController.text = '450';
      _totalPointsController.text = '500';
      _auditScore = null;
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
              Icon(Icons.assessment, color: AppColors.success, size: 28),
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

          // Audit Score Display
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
                  'IPC Audit Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_auditScore!.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_achievedPointsController.text} / ${_totalPointsController.text} points',
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
                      'Audit Context',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Audit Type', _selectedAuditType),
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
          width: 100,
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
                'References',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
        calculatorName: 'IPC Audit Score Calculator',
        inputs: {
          'Audit Type': _selectedAuditType,
          'Unit Type': _selectedUnitType,
          'Achieved Points': _achievedPointsController.text,
          'Total Points': _totalPointsController.text,
        },
        result: 'Audit Score: ${_auditScore!.toStringAsFixed(2)}%\n'
            'Interpretation: $_interpretation',
        notes: '',
        tags: ['ipc', 'audit', 'compliance', 'quality'],
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
    final success = await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'IPC Audit Score % Calculator',
      inputs: {
        'Audit Type': _selectedAuditType,
        'Unit Type': _selectedUnitType,
        'Achieved Points': '${_achievedPointsController.text} points',
        'Total Possible Points': '${_totalPointsController.text} points',
      },
      results: {
        'IPC Audit Score': '${_auditScore!.toStringAsFixed(1)}%',
      },
      interpretation: '$_interpretation\n\nBenchmark: $_benchmark${_action != null ? '\n\nRecommended Actions:\n$_action' : ''}',
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
    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'IPC Audit Score % Calculator',
      inputs: {
        'Audit Type': _selectedAuditType,
        'Unit Type': _selectedUnitType,
        'Achieved Points': '${_achievedPointsController.text} points',
        'Total Possible Points': '${_totalPointsController.text} points',
      },
      results: {
        'IPC Audit Score': '${_auditScore!.toStringAsFixed(1)}%',
      },
      interpretation: '$_interpretation\n\nBenchmark: $_benchmark${_action != null ? '\n\nRecommended Actions:\n$_action' : ''}',
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
    final success = await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'IPC Audit Score % Calculator',
      inputs: {
        'Audit Type': _selectedAuditType,
        'Unit Type': _selectedUnitType,
        'Achieved Points': '${_achievedPointsController.text} points',
        'Total Possible Points': '${_totalPointsController.text} points',
      },
      results: {
        'IPC Audit Score': '${_auditScore!.toStringAsFixed(1)}%',
      },
      interpretation: '$_interpretation\n\nBenchmark: $_benchmark${_action != null ? '\n\nRecommended Actions:\n$_action' : ''}',
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
    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'IPC Audit Score % Calculator',
      inputs: {
        'Audit Type': _selectedAuditType,
        'Unit Type': _selectedUnitType,
        'Achieved Points': '${_achievedPointsController.text} points',
        'Total Possible Points': '${_totalPointsController.text} points',
      },
      results: {
        'IPC Audit Score': '${_auditScore!.toStringAsFixed(1)}%',
      },
      interpretation: '$_interpretation\n\nBenchmark: $_benchmark${_action != null ? '\n\nRecommended Actions:\n$_action' : ''}',
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

