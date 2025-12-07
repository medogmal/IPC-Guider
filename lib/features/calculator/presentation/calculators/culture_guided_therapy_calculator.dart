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

class CultureGuidedTherapyCalculator extends ConsumerStatefulWidget {
  const CultureGuidedTherapyCalculator({super.key});

  @override
  ConsumerState<CultureGuidedTherapyCalculator> createState() => _CultureGuidedTherapyCalculatorState();
}

class _CultureGuidedTherapyCalculatorState extends ConsumerState<CultureGuidedTherapyCalculator> {
  final _cultureGuidedController = TextEditingController();
  final _totalTherapiesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedAntibioticType = 'All Antibiotics';
  String _selectedUnitType = 'General Ward';
  double? _cultureGuidedRate;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isLoading = false;

  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Culture-Guided Therapy Percentage is a diagnostic stewardship metric that measures the proportion of antibiotic therapies that are based on microbiological culture results and susceptibility testing. This metric reflects the quality of diagnostic practices, appropriate culture collection, and rational prescribing based on evidence rather than empiric guesswork. High rates indicate strong integration of laboratory diagnostics with clinical decision-making.',
    formula: '(Therapies Based on Culture × 100) / Total Therapies',
    example: '75 antibiotic therapies were guided by culture results out of 100 total therapies → (75 × 100) / 100 = 75% culture-guided therapy',
    interpretation: 'Higher culture-guided therapy rates indicate better diagnostic stewardship and more rational prescribing. Rates above 80% demonstrate excellent integration of microbiology with clinical practice. Rates above 60% are acceptable. Low rates suggest inadequate culture collection, delayed results, or empiric therapy without diagnostic confirmation. This metric requires robust culture collection practices and timely laboratory reporting.',
    whenUsed: 'Use this calculator to evaluate diagnostic stewardship effectiveness and measure the integration of microbiology with antibiotic prescribing. Essential for quality improvement initiatives focused on appropriate culture collection, reducing empiric therapy duration, and promoting evidence-based prescribing. Calculate monthly or quarterly based on chart review or electronic health record data. Only include therapies where culture collection was clinically indicated.',
    inputDataType: 'Number of antibiotic therapies that were initiated or modified based on culture and susceptibility results, and total number of antibiotic therapies reviewed where culture collection was appropriate. Specify antibiotic type and unit type for context. Requires chart review or EHR data extraction.',
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
        title: 'WHO Guidelines on Use of Medically Important Antimicrobials',
        url: 'https://www.who.int/publications/i/item/9789241550130',
      ),
    ],
  );

  @override
  void dispose() {
    _cultureGuidedController.dispose();
    _totalTherapiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'Culture-Guided Therapy %',
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
              if (_cultureGuidedRate != null) ...[
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
              Icon(Icons.biotech, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Culture-Guided Therapy %',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rational Prescribing Metric',
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
                    fontSize = 10.0;
                  } else if (constraints.maxWidth < 400) {
                    fontSize = 12.0;
                  }

                  return Math.tex(
                    r'\text{Culture-Guided \%} = \frac{\text{Therapies Based on Culture} \times 100}{\text{Total Therapies}}',
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

          // Therapies Based on Culture
          TextFormField(
            controller: _cultureGuidedController,
            decoration: InputDecoration(
              labelText: 'Therapies Based on Culture',
              hintText: 'Enter culture-guided therapies',
              suffixText: 'therapies',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.science, color: AppColors.primary),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter culture-guided therapies';
              }
              final num = int.tryParse(value);
              if (num == null || num < 0) {
                return 'Please enter a valid number (≥0)';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Total Therapies
          TextFormField(
            controller: _totalTherapiesController,
            decoration: InputDecoration(
              labelText: 'Total Therapies',
              hintText: 'Enter total therapies reviewed',
              suffixText: 'therapies',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.format_list_numbered, color: AppColors.primary),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter total therapies';
              }
              final num = int.tryParse(value);
              if (num == null || num < 1) {
                return 'Please enter a valid number (≥1)';
              }
              final cultureGuided = int.tryParse(_cultureGuidedController.text) ?? 0;
              if (num < cultureGuided) {
                return 'Total therapies must be ≥ culture-guided therapies';
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
      final cultureGuided = int.parse(_cultureGuidedController.text);
      final totalTherapies = int.parse(_totalTherapiesController.text);

      // Calculate culture-guided therapy rate
      final cultureGuidedRate = (cultureGuided / totalTherapies) * 100;

      // Generate interpretation (Higher % = Better)
      String interpretation;
      if (cultureGuidedRate >= 80) {
        interpretation = 'Excellent Diagnostic Stewardship: Culture-guided therapy rate of ${cultureGuidedRate.toStringAsFixed(1)}% demonstrates outstanding integration of microbiology with clinical practice. Prescribers are consistently using culture results to guide therapy. This indicates robust culture collection practices, timely laboratory reporting, and evidence-based prescribing.';
      } else if (cultureGuidedRate >= 60) {
        interpretation = 'Good Diagnostic Stewardship: Culture-guided therapy rate of ${cultureGuidedRate.toStringAsFixed(1)}% indicates good use of microbiological diagnostics. Most therapies are based on culture results. Continue current practices and identify opportunities to further improve culture collection and utilization.';
      } else if (cultureGuidedRate >= 40) {
        interpretation = 'Moderate Performance: Culture-guided therapy rate of ${cultureGuidedRate.toStringAsFixed(1)}% suggests significant room for improvement. Many therapies remain empiric without culture confirmation. Enhanced diagnostic stewardship interventions are recommended to improve culture collection and reduce empiric therapy duration.';
      } else {
        interpretation = 'Poor Performance - Action Required: Culture-guided therapy rate of ${cultureGuidedRate.toStringAsFixed(1)}% is significantly below target. Most therapies are empiric without diagnostic confirmation. Immediate intervention is required to improve culture collection practices, reduce laboratory turnaround time, and promote evidence-based prescribing.';
      }

      // Benchmark information
      final benchmark = 'Culture-Guided Therapy Benchmarks: ≥80% (excellent - target level), 60-80% (good), 40-60% (moderate - needs improvement), <40% (poor - immediate action required)';

      // Action recommendations if culture-guided rate is suboptimal
      String? action;
      if (cultureGuidedRate < 40) {
        action = 'Immediate Actions for Low Culture-Guided Therapy:\n'
            '• Implement mandatory culture collection before antibiotics\n'
            '• Reduce laboratory turnaround time for cultures\n'
            '• Provide urgent prescriber education on diagnostic stewardship\n'
            '• Establish clear protocols for culture collection and interpretation\n'
            '• Implement real-time alerts for culture results\n'
            '• Review barriers to culture collection (phlebotomy, supplies)\n'
            '• Enhance communication between laboratory and clinical teams\n'
            '• Consider rapid diagnostic testing (PCR, MALDI-TOF)';
      } else if (cultureGuidedRate < 60) {
        action = 'Recommended Actions to Improve Culture Utilization:\n'
            '• Enhance prescriber education on culture interpretation\n'
            '• Implement culture collection reminders in EHR\n'
            '• Provide feedback on culture collection rates\n'
            '• Optimize laboratory reporting and communication\n'
            '• Reduce empiric therapy duration with automatic stop orders\n'
            '• Share success stories of culture-guided therapy';
      } else if (cultureGuidedRate < 80) {
        action = 'Recommended Actions to Achieve Excellence:\n'
            '• Identify specific barriers preventing culture utilization\n'
            '• Provide targeted education for low-performing prescribers\n'
            '• Optimize culture collection techniques and timing\n'
            '• Implement decision support tools for culture interpretation\n'
            '• Continue regular audit and feedback';
      }

      setState(() {
        _cultureGuidedRate = cultureGuidedRate;
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
      _cultureGuidedController.text = '75';
      _totalTherapiesController.text = '100';
      _cultureGuidedRate = null;
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
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _cultureGuidedRate!.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                    fontSize: 48,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
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
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _cultureGuidedRate!.toStringAsFixed(1)));
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
        calculatorName: 'Culture-Guided Therapy Calculator',
        inputs: {
          'Antibiotic Type': _selectedAntibioticType,
          'Unit Type': _selectedUnitType,
          'Culture-Guided Therapies': _cultureGuidedController.text,
          'Total Therapies': _totalTherapiesController.text,
        },
        result: 'Culture-Guided Rate: ${_cultureGuidedRate!.toStringAsFixed(1)}%',
        notes: '',
        tags: ['antimicrobial-stewardship', 'culture-guided', 'therapy', 'surveillance'],
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
      toolName: 'Culture-Guided Therapy % Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'Therapies Based on Culture': _cultureGuidedController.text,
        'Total Therapies': _totalTherapiesController.text,
      },
      results: {
        'Culture-Guided Therapy %': '${_cultureGuidedRate!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': '≥80%',
        'unit': 'culture-guided therapy',
        'source': 'IDSA/SHEA Stewardship Guidelines',
        'status': _cultureGuidedRate! >= 80 ? 'Meets Target' : 'Below Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => r.url).toList(),
    );
  }

  Future<void> _exportAsExcel() async {
    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Culture-Guided Therapy % Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'Therapies Based on Culture': _cultureGuidedController.text,
        'Total Therapies': _totalTherapiesController.text,
      },
      results: {
        'Culture-Guided Therapy %': '${_cultureGuidedRate!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': '≥80%',
        'unit': 'culture-guided therapy',
        'source': 'IDSA/SHEA Stewardship Guidelines',
        'status': _cultureGuidedRate! >= 80 ? 'Meets Target' : 'Below Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Culture-Guided Therapy % Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'Therapies Based on Culture': _cultureGuidedController.text,
        'Total Therapies': _totalTherapiesController.text,
      },
      results: {
        'Culture-Guided Therapy %': '${_cultureGuidedRate!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': '≥80%',
        'unit': 'culture-guided therapy',
        'source': 'IDSA/SHEA Stewardship Guidelines',
        'status': _cultureGuidedRate! >= 80 ? 'Meets Target' : 'Below Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Culture-Guided Therapy % Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'Therapies Based on Culture': _cultureGuidedController.text,
        'Total Therapies': _totalTherapiesController.text,
      },
      results: {
        'Culture-Guided Therapy %': '${_cultureGuidedRate!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': '≥80%',
        'unit': 'culture-guided therapy',
        'source': 'IDSA/SHEA Stewardship Guidelines',
        'status': _cultureGuidedRate! >= 80 ? 'Meets Target' : 'Below Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => r.url).toList(),
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

