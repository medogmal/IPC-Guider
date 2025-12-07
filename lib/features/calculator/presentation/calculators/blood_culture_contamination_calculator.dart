import 'package:flutter/material.dart';
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

class BloodCultureContaminationCalculator extends ConsumerStatefulWidget {
  const BloodCultureContaminationCalculator({super.key});

  @override
  ConsumerState<BloodCultureContaminationCalculator> createState() =>
      _BloodCultureContaminationCalculatorState();
}

class _BloodCultureContaminationCalculatorState
    extends ConsumerState<BloodCultureContaminationCalculator> {
  final _contaminatedController = TextEditingController();
  final _totalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isCalculated = false;
  double? _contaminationRate;
  String? _interpretation;

  final _knowledgePanelData = const KnowledgePanelData(
    definition:
        'Measures the percentage of blood cultures that grow organisms likely to be contaminants rather than true pathogens. This is a critical lab quality metric that reflects aseptic technique during blood collection.',
    formula: '(Contaminated Blood Cultures × 100) / Total Blood Cultures Collected',
    interpretation: '''
• <2%: Excellent (best practice)
• 2-3%: Acceptable (meets benchmark)
• >3%: Needs improvement (action required)
• >5%: Critical (immediate intervention needed)

High contamination rates lead to:
- Unnecessary antibiotic treatment
- Extended hospital stays
- Increased costs
- Patient harm from unnecessary interventions
- Masks true infection rates''',
    example: '''
Hospital collected 500 blood cultures in January:
• 18 grew contaminants (CoNS in 1 bottle only)
• Contamination rate = (18 × 100) / 500 = 3.6%
• Interpretation: Above benchmark (>3%), indicates need for staff retraining on aseptic technique and review of skin prep protocols.''',
    whenUsed: '''
• Monthly/quarterly lab quality monitoring
• Phlebotomy staff performance evaluation
• Infection control surveillance
• Accreditation/regulatory reporting (CLSI, CAP)
• Quality improvement initiatives
• Pre-analytical process assessment''',
    references: [
      Reference(
        title: 'CLSI M47: Principles and Procedures for Blood Cultures',
        url: 'https://clsi.org/',
      ),
      Reference(
        title: 'CAP Laboratory Accreditation Program - Microbiology Checklist',
        url: 'https://www.cap.org/',
      ),
      Reference(
        title: 'IDSA Guidelines: Blood Culture Contamination',
        url: 'https://www.idsociety.org/',
      ),
      Reference(
        title: 'WHO Guidelines on Drawing Blood: Best Practices',
        url: 'https://www.who.int/publications',
      ),
    ],
  );

  @override
  void dispose() {
    _contaminatedController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'Blood Culture Contamination %',
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
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildFormulaCard(),
              const SizedBox(height: 16),
              _buildQuickGuideButton(),
              const SizedBox(height: 12),
              _buildLoadExampleButton(),
              const SizedBox(height: 16),
              _buildInputCard(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_isCalculated) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
                const SizedBox(height: 16),
                _buildContaminantGuideCard(),
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
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.biotech, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            'Blood Culture Contamination Rate',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Critical Lab Quality Metric',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
            textAlign: TextAlign.center,
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
                    r'\text{Contamination Rate } (\%) = \frac{\text{Contaminated Cultures} \times 100}{\text{Total Blood Cultures}}',
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
          TextFormField(
            controller: _contaminatedController,
            decoration: InputDecoration(
              labelText: 'Contaminated Blood Cultures',
              hintText: 'Enter number of contaminated cultures',
              prefixIcon: Icon(Icons.warning_amber, color: AppColors.error),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: AppColors.background,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contaminated blood cultures';
              }
              final num = int.tryParse(value);
              if (num == null || num < 0) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _totalController,
            decoration: InputDecoration(
              labelText: 'Total Blood Cultures Collected',
              hintText: 'Enter total number of cultures',
              prefixIcon: Icon(Icons.science, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: AppColors.background,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter total blood cultures';
              }
              final num = int.tryParse(value);
              if (num == null || num <= 0) {
                return 'Please enter a valid number greater than 0';
              }
              return null;
            },
          ),
        ],
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
            'Calculate Contamination Rate',
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
    final contaminated = int.parse(_contaminatedController.text);
    final total = int.parse(_totalController.text);

    if (contaminated > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contaminated cultures cannot exceed total cultures'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _contaminationRate = (contaminated * 100) / total;

      // Interpretation
      if (_contaminationRate! < 2.0) {
        _interpretation =
            'Excellent performance (<2%). Your blood culture contamination rate is below 2%, which represents best practice. This indicates excellent aseptic technique during blood collection. Continue current practices and use as a benchmark for training.';
      } else if (_contaminationRate! <= 3.0) {
        _interpretation =
            'Acceptable performance (2-3%). Your contamination rate meets the benchmark of <3%. While acceptable, there is room for improvement. Consider reviewing skin preparation protocols and phlebotomy technique to achieve <2%.';
      } else if (_contaminationRate! <= 5.0) {
        _interpretation =
            'Needs improvement (>3%). Your contamination rate exceeds the benchmark of 3%. This indicates suboptimal aseptic technique. Action required: Staff retraining on proper skin preparation (chlorhexidine or iodine), aseptic technique, and blood culture collection procedures. Review collection practices and implement corrective measures.';
      } else {
        _interpretation =
            'Critical (>5%). Your contamination rate is critically high. Immediate intervention required: Comprehensive staff retraining, audit of all collection practices, review of skin prep protocols, and implementation of quality improvement initiatives. High contamination rates lead to unnecessary antibiotic use, extended hospital stays, and patient harm.';
      }

      _isCalculated = true;
    });
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
              Icon(Icons.assessment, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Results',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getResultColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getResultColor().withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Contamination Rate',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_contaminationRate!.toStringAsFixed(2)}%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getResultColor(),
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getBenchmarkText(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getResultColor(),
                        fontWeight: FontWeight.w600,
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
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _interpretation!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
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
                  icon: Icon(Icons.save, color: AppColors.success),
                  label: Text('Save', style: TextStyle(color: AppColors.success)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.success, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showExportOptions(context),
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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

  Color _getResultColor() {
    if (_contaminationRate! < 2.0) {
      return AppColors.success;
    } else if (_contaminationRate! <= 3.0) {
      return AppColors.info;
    } else if (_contaminationRate! <= 5.0) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _getBenchmarkText() {
    if (_contaminationRate! < 2.0) {
      return 'Excellent (<2%)';
    } else if (_contaminationRate! <= 3.0) {
      return 'Acceptable (≤3%)';
    } else if (_contaminationRate! <= 5.0) {
      return 'Needs Improvement (>3%)';
    } else {
      return 'Critical (>5%)';
    }
  }


  Widget _buildContaminantGuideCard() {
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
              Icon(Icons.info, color: AppColors.warning, size: 24),
              const SizedBox(width: 12),
              Text(
                'Common Blood Culture Contaminants',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContaminantItem(
            'Coagulase-Negative Staphylococci (CoNS)',
            'Most common contaminant. Usually from skin flora. Consider contamination if grows in only 1 bottle or after >24 hours.',
          ),
          const SizedBox(height: 12),
          _buildContaminantItem(
            'Bacillus species (non-anthracis)',
            'Environmental contaminant. Usually from improper skin prep or contaminated collection supplies.',
          ),
          const SizedBox(height: 12),
          _buildContaminantItem(
            'Corynebacterium species (diphtheroids)',
            'Skin flora. Rarely pathogenic except in immunocompromised patients or with prosthetic devices.',
          ),
          const SizedBox(height: 12),
          _buildContaminantItem(
            'Propionibacterium acnes (Cutibacterium acnes)',
            'Skin flora from sebaceous glands. Often delayed growth (>48 hours).',
          ),
          const SizedBox(height: 12),
          _buildContaminantItem(
            'Micrococcus species',
            'Environmental contaminant. Rarely pathogenic.',
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
                    'Key Principle: If the same organism grows in multiple bottles from the same draw, or if the patient has clinical signs of infection, it may be a true pathogen rather than a contaminant. Clinical correlation is essential.',
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

  Widget _buildContaminantItem(String organism, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.warning,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                organism,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
              ),
            ],
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

  void _loadExample() {
    setState(() {
      _contaminatedController.text = '18';
      _totalController.text = '500';
      _isCalculated = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example data loaded'),
        backgroundColor: AppColors.success,
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



  Future<void> _saveToHistory() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Blood Culture Contamination Rate',
        inputs: {
          'Contaminated Cultures': _contaminatedController.text,
          'Total Blood Cultures': _totalController.text,
        },
        result: 'Contamination Rate: ${_contaminationRate!.toStringAsFixed(2)}%\n'
            'Interpretation: $_interpretation',
        notes: '',
        tags: ['laboratory', 'blood-culture', 'contamination', 'quality'],
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
      toolName: 'Blood Culture Contamination %',
      inputs: {
        'Contaminated Blood Cultures': _contaminatedController.text,
        'Total Blood Cultures Collected': _totalController.text,
      },
      results: {
        'Contamination Rate': '${_contaminationRate!.toStringAsFixed(2)}%',
        'Benchmark Status': _getBenchmarkText(),
      },
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

    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Blood Culture Contamination %',
      inputs: {
        'Contaminated Blood Cultures': _contaminatedController.text,
        'Total Blood Cultures Collected': _totalController.text,
      },
      results: {
        'Contamination Rate': '${_contaminationRate!.toStringAsFixed(2)}%',
        'Benchmark Status': _getBenchmarkText(),
      },
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

    final success = await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Blood Culture Contamination %',
      inputs: {
        'Contaminated Blood Cultures': _contaminatedController.text,
        'Total Blood Cultures Collected': _totalController.text,
      },
      results: {
        'Contamination Rate': '${_contaminationRate!.toStringAsFixed(2)}%',
        'Benchmark Status': _getBenchmarkText(),
      },
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

    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Blood Culture Contamination %',
      inputs: {
        'Contaminated Blood Cultures': _contaminatedController.text,
        'Total Blood Cultures Collected': _totalController.text,
      },
      results: {
        'Contamination Rate': '${_contaminationRate!.toStringAsFixed(2)}%',
        'Benchmark Status': _getBenchmarkText(),
      },
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


