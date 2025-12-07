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

class DeescalationRateCalculator extends ConsumerStatefulWidget {
  const DeescalationRateCalculator({super.key});

  @override
  ConsumerState<DeescalationRateCalculator> createState() => _DeescalationRateCalculatorState();
}

class _DeescalationRateCalculatorState extends ConsumerState<DeescalationRateCalculator> {
  final _deescalatedController = TextEditingController();
  final _totalCoursesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedAntibioticType = 'All Antibiotics';
  String _selectedUnitType = 'General Ward';
  double? _deescalationRate;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isLoading = false;

  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'De-escalation Rate is a key antimicrobial stewardship performance metric that measures the proportion of antibiotic courses where empiric broad-spectrum therapy is narrowed to targeted therapy based on culture results and clinical response. De-escalation includes switching from broad to narrow-spectrum agents, reducing the number of antibiotics, or stopping unnecessary therapy. This metric reflects the quality of stewardship interventions and appropriate response to diagnostic information.',
    formula: '(De-escalated Courses × 100) / Total Antibiotic Courses',
    example: '45 antibiotic courses were de-escalated out of 100 total courses reviewed → (45 × 100) / 100 = 45% de-escalation rate',
    interpretation: 'Higher de-escalation rates indicate better antimicrobial stewardship and more rational prescribing practices. Rates above 50% demonstrate good stewardship, while rates above 70% indicate excellent performance. Low rates may suggest missed opportunities for optimization, inadequate culture collection, or lack of stewardship review. This metric requires prospective audit and feedback programs to identify de-escalation opportunities.',
    whenUsed: 'Use this calculator to evaluate the effectiveness of antimicrobial stewardship interventions and measure prescriber responsiveness to culture data. Essential for quality improvement initiatives, stewardship program assessment, and demonstrating value to hospital leadership. Calculate monthly or quarterly based on prospective audit data. Only include courses where de-escalation was clinically appropriate (exclude negative cultures or courses requiring continued broad coverage).',
    inputDataType: 'Number of antibiotic courses that were successfully de-escalated (narrowed, reduced, or stopped) and total number of antibiotic courses reviewed where de-escalation was appropriate. Specify antibiotic type and unit type for context. Requires prospective audit and feedback program data.',
    references: [
      Reference(
        title: 'IDSA/SHEA Antimicrobial Stewardship Guidelines',
        url: 'https://www.idsociety.org/practice-guideline/antimicrobial-stewardship/',
      ),
      Reference(
        title: 'CDC Core Elements of Hospital Antibiotic Stewardship',
        url: 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html',
      ),
      Reference(
        title: 'WHO AWaRe Classification of Antibiotics',
        url: 'https://www.who.int/publications/i/item/2021-aware-classification',
      ),
    ],
  );

  @override
  void dispose() {
    _deescalatedController.dispose();
    _totalCoursesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'De-escalation Rate',
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
              const SizedBox(height: 16),
              _buildCalculateButton(),
              if (_deescalationRate != null) ...[
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
              Icon(Icons.arrow_downward_outlined, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'De-escalation Rate',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stewardship Performance Metric',
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
                    fontSize = 12.0;
                  } else if (constraints.maxWidth < 400) {
                    fontSize = 14.0;
                  }

                  return Math.tex(
                    r'\text{De-escalation Rate} = \frac{\text{De-escalated Courses} \times 100}{\text{Total Antibiotic Courses}}',
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

          // Antibiotic Type Dropdown
          DropdownButtonFormField<String>(
            value: _selectedAntibioticType,
            decoration: InputDecoration(
              labelText: 'Antibiotic Type',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.medication_liquid, color: AppColors.primary),
            ),
            items: const [
              DropdownMenuItem(value: 'All Antibiotics', child: Text('All Antibiotics')),
              DropdownMenuItem(value: 'Broad-Spectrum', child: Text('Broad-Spectrum')),
              DropdownMenuItem(value: 'Narrow-Spectrum', child: Text('Narrow-Spectrum')),
              DropdownMenuItem(value: 'Carbapenems', child: Text('Carbapenems')),
              DropdownMenuItem(value: 'Fluoroquinolones', child: Text('Fluoroquinolones')),
              DropdownMenuItem(value: 'Glycopeptides', child: Text('Glycopeptides (Vancomycin)')),
              DropdownMenuItem(value: 'Cephalosporins', child: Text('Cephalosporins (3rd/4th Gen)')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedAntibioticType = value!;
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
              DropdownMenuItem(value: 'General Ward', child: Text('General Ward')),
              DropdownMenuItem(value: 'ICU', child: Text('ICU (Intensive Care Unit)')),
              DropdownMenuItem(value: 'Emergency Department', child: Text('Emergency Department')),
              DropdownMenuItem(value: 'Surgical Ward', child: Text('Surgical Ward')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedUnitType = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // De-escalated Courses
          TextFormField(
            controller: _deescalatedController,
            decoration: InputDecoration(
              labelText: 'De-escalated Courses',
              hintText: 'Enter number of de-escalated courses',
              suffixText: 'courses',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.check_circle_outline, color: AppColors.primary),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter de-escalated courses';
              }
              final num = int.tryParse(value);
              if (num == null || num < 0) {
                return 'Please enter a valid number (≥0)';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Total Antibiotic Courses
          TextFormField(
            controller: _totalCoursesController,
            decoration: InputDecoration(
              labelText: 'Total Antibiotic Courses',
              hintText: 'Enter total courses reviewed',
              suffixText: 'courses',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.format_list_numbered, color: AppColors.primary),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter total courses';
              }
              final num = int.tryParse(value);
              if (num == null || num < 1) {
                return 'Please enter a valid number (≥1)';
              }
              final deescalated = int.tryParse(_deescalatedController.text) ?? 0;
              if (num < deescalated) {
                return 'Total courses must be ≥ de-escalated courses';
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
      final deescalated = int.parse(_deescalatedController.text);
      final totalCourses = int.parse(_totalCoursesController.text);

      // Calculate de-escalation rate
      final deescalationRate = (deescalated / totalCourses) * 100;

      // Generate interpretation (Higher % = Better - opposite of DOT/DDD)
      String interpretation;
      if (deescalationRate >= 70) {
        interpretation = 'Excellent Stewardship: De-escalation rate of ${deescalationRate.toStringAsFixed(1)}% demonstrates outstanding antimicrobial stewardship performance. Prescribers are highly responsive to culture data and clinical response. This level of performance indicates a mature stewardship program with effective audit and feedback processes.';
      } else if (deescalationRate >= 50) {
        interpretation = 'Good Stewardship: De-escalation rate of ${deescalationRate.toStringAsFixed(1)}% indicates good stewardship practices. Prescribers are generally responsive to culture results. Continue current efforts and identify specific barriers to further improve de-escalation opportunities.';
      } else if (deescalationRate >= 30) {
        interpretation = 'Moderate Performance: De-escalation rate of ${deescalationRate.toStringAsFixed(1)}% suggests room for improvement. Many opportunities for de-escalation may be missed. Enhanced stewardship interventions, prescriber education, and more frequent audit and feedback are recommended.';
      } else {
        interpretation = 'Poor Performance - Action Required: De-escalation rate of ${deescalationRate.toStringAsFixed(1)}% is significantly below target. This indicates substantial missed opportunities for antibiotic optimization. Immediate stewardship intervention is required to improve culture utilization, prescriber education, and systematic review processes.';
      }

      // Benchmark information
      final benchmark = 'De-escalation Rate Benchmarks: ≥70% (excellent - target level), 50-70% (good), 30-50% (moderate - needs improvement), <30% (poor - immediate action required)';

      // Action recommendations if de-escalation rate is suboptimal
      String? action;
      if (deescalationRate < 30) {
        action = 'Immediate Actions for Low De-escalation Rate:\n'
            '• Implement mandatory stewardship review at 48-72 hours\n'
            '• Enhance culture collection practices before antibiotics\n'
            '• Provide urgent prescriber education on de-escalation principles\n'
            '• Establish clear de-escalation pathways and protocols\n'
            '• Implement real-time alerts for de-escalation opportunities\n'
            '• Review barriers to de-escalation (formulary, culture turnaround)\n'
            '• Increase frequency of prospective audit and feedback\n'
            '• Engage infectious disease consultation for complex cases';
      } else if (deescalationRate < 50) {
        action = 'Recommended Actions to Improve De-escalation:\n'
            '• Enhance prescriber education on culture interpretation\n'
            '• Implement antibiotic time-outs at 48-72 hours\n'
            '• Provide real-time feedback on de-escalation opportunities\n'
            '• Review and simplify de-escalation pathways\n'
            '• Improve culture collection and reporting processes\n'
            '• Share de-escalation success stories and best practices';
      } else if (deescalationRate < 70) {
        action = 'Recommended Actions to Achieve Excellence:\n'
            '• Identify specific barriers preventing de-escalation\n'
            '• Provide targeted education for low-performing prescribers\n'
            '• Optimize culture turnaround time and reporting\n'
            '• Implement decision support tools for de-escalation\n'
            '• Continue regular audit and feedback';
      }

      setState(() {
        _deescalationRate = deescalationRate;
        _interpretation = interpretation;
        _benchmark = benchmark;
        _action = action;
        _isLoading = false;
      });
    });
  }

  void _loadExample() {
    setState(() {
      _selectedAntibioticType = 'All Antibiotics';
      _selectedUnitType = 'General Ward';
      _deescalatedController.text = '45';
      _totalCoursesController.text = '100';
      _deescalationRate = null;
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
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Result Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_selectedAntibioticType - $_selectedUnitType',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _deescalationRate!.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                      fontSize: 48,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '%',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _deescalationRate!.toStringAsFixed(1)));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Result copied to clipboard'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy Result'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: BorderSide(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Interpretation Box
                Container(
                  width: double.infinity,
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
                            'Interpretation',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.info,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _interpretation!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),

                // Benchmark Box
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
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
                      const SizedBox(height: 8),
                      Text(
                        _benchmark!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),

                // Action Box (Conditional)
                if (_action != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
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
                            Icon(Icons.warning_amber_outlined, color: AppColors.error, size: 20),
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
                        const SizedBox(height: 8),
                        Text(
                          _action!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons (Save & Export)
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showExportModal(context),
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
                ),
              ],
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
              Icon(Icons.library_books, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Official References',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._knowledgePanelData.references.map((reference) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => _launchURL(reference.url),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reference.title,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _saveResult() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'De-escalation Rate Calculator',
        inputs: {
          'Antibiotic Type': _selectedAntibioticType,
          'Unit Type': _selectedUnitType,
          'De-escalated Courses': _deescalatedController.text,
          'Total Courses': _totalCoursesController.text,
        },
        result: 'De-escalation Rate: ${_deescalationRate!.toStringAsFixed(1)}%',
        notes: '',
        tags: ['antimicrobial-stewardship', 'de-escalation', 'therapy', 'surveillance'],
      );

      await repository.addEntry(historyEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Result saved successfully'),
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
    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'De-escalation Rate Calculator',
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'De-escalated Courses': _deescalatedController.text,
        'Total Antibiotic Courses': _totalCoursesController.text,
      },
      results: {
        'De-escalation Rate': '${_deescalationRate!.toStringAsFixed(1)}%',
      },
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => r.url).toList(),
    );
  }

  Future<void> _exportAsExcel() async {
    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'De-escalation Rate Calculator',
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'De-escalated Courses': _deescalatedController.text,
        'Total Antibiotic Courses': _totalCoursesController.text,
      },
      results: {
        'De-escalation Rate': '${_deescalationRate!.toStringAsFixed(1)}%',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'De-escalation Rate Calculator',
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'De-escalated Courses': _deescalatedController.text,
        'Total Antibiotic Courses': _totalCoursesController.text,
      },
      results: {
        'De-escalation Rate': '${_deescalationRate!.toStringAsFixed(1)}%',
      },
    );
  }

  Future<void> _exportAsText() async {
    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'De-escalation Rate Calculator',
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'De-escalated Courses': _deescalatedController.text,
        'Total Antibiotic Courses': _totalCoursesController.text,
      },
      results: {
        'De-escalation Rate': '${_deescalationRate!.toStringAsFixed(1)}%',
      },
      interpretation: _interpretation,
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

