import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../outbreak/data/models/history_entry.dart';
import '../../../outbreak/data/repositories/history_repository.dart';

class DOTCalculator extends ConsumerStatefulWidget {
  const DOTCalculator({super.key});

  @override
  ConsumerState<DOTCalculator> createState() => _DOTCalculatorState();
}

class _DOTCalculatorState extends ConsumerState<DOTCalculator> {
  final _antibioticDaysController = TextEditingController();
  final _patientDaysController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedAntibioticType = 'All Antibiotics';
  String _selectedUnitType = 'General Ward';
  double? _dotRate;
  double? _lowerCI;
  double? _upperCI;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isLoading = false;

  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Days of Therapy (DOT) is a patient-level antimicrobial use metric that measures the number of days patients receive systemic antimicrobial agents. Each day a patient receives one or more antibiotics counts as one DOT, regardless of the number of agents or doses administered. DOT is the preferred metric by CDC NHSN for tracking antibiotic exposure duration.',
    formula: '(Total Antibiotic Days × 1,000) / Patient Days',
    example: '500 days of antibiotic therapy over 10,000 patient days → (500 × 1,000) / 10,000 = 50 DOT per 1,000 patient days',
    interpretation: 'Lower DOT rates indicate less antibiotic exposure and better antimicrobial stewardship. High DOT rates may suggest overuse, prolonged therapy, or inappropriate prescribing. Rates vary significantly by unit type, with ICUs typically having higher rates than general wards. Trending DOT over time is more valuable than single measurements.',
    whenUsed: 'Use this calculator to monitor antibiotic exposure duration across your facility or specific units. Essential for antimicrobial stewardship program surveillance, benchmarking against national data, and evaluating the impact of stewardship interventions. Calculate monthly or quarterly for CDC NHSN reporting and internal quality improvement.',
    inputDataType: 'Total number of days patients received antibiotics (count each patient-day once regardless of number of agents) and total patient days for the same period. Specify antibiotic type and unit type for accurate benchmarking.',
    references: [
      Reference(
        title: 'CDC NHSN Antimicrobial Use and Resistance Module',
        url: 'https://www.cdc.gov/nhsn/pdfs/pscmanual/11pscaurcurrent.pdf',
      ),
      Reference(
        title: 'CDC Core Elements of Hospital Antibiotic Stewardship',
        url: 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html',
      ),
      Reference(
        title: 'IDSA/SHEA Antimicrobial Stewardship Guidelines',
        url: 'https://www.idsociety.org/practice-guideline/antimicrobial-stewardship/',
      ),
    ],
  );

  @override
  void dispose() {
    _antibioticDaysController.dispose();
    _patientDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'DOT (Days of Therapy)',
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
              if (_dotRate != null) ...[
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
              Icon(Icons.medication, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DOT (Days of Therapy)',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Antibiotic Exposure Duration',
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
                    r'\text{DOT Rate} = \frac{\text{Total Antibiotic Days} \times 1000}{\text{Patient Days}}',
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

          // Total Antibiotic Days
          TextFormField(
            controller: _antibioticDaysController,
            decoration: InputDecoration(
              labelText: 'Total Antibiotic Days',
              hintText: 'Enter total days of antibiotic therapy',
              suffixText: 'days',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter total antibiotic days';
              }
              final num = int.tryParse(value);
              if (num == null || num < 0) {
                return 'Please enter a valid number (≥0)';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Patient Days
          TextFormField(
            controller: _patientDaysController,
            decoration: InputDecoration(
              labelText: 'Patient Days',
              hintText: 'Enter total patient days',
              suffixText: 'days',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.people, color: AppColors.primary),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter patient days';
              }
              final num = int.tryParse(value);
              if (num == null || num < 1) {
                return 'Please enter a valid number (≥1)';
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
      final antibioticDays = int.parse(_antibioticDaysController.text);
      final patientDays = int.parse(_patientDaysController.text);

      // Calculate DOT rate per 1,000 patient days
      final dotRate = (antibioticDays * 1000) / patientDays;

      // Calculate 95% Poisson CI
      final lambda = antibioticDays.toDouble();
      final lowerCI = lambda > 0 ? (lambda - 1.96 * sqrt(lambda)) * 1000 / patientDays : 0.0;
      final upperCI = (lambda + 1.96 * sqrt(lambda)) * 1000 / patientDays;

      // Get unit-specific benchmarks
      Map<String, double> benchmarks = _getUnitBenchmarks(_selectedUnitType);
      final lowThreshold = benchmarks['low']!;
      final moderateThreshold = benchmarks['moderate']!;
      final highThreshold = benchmarks['high']!;

      // Generate interpretation (Lower DOT = Better)
      String interpretation;
      if (dotRate <= lowThreshold) {
        interpretation = 'Excellent Stewardship: DOT rate of ${dotRate.toStringAsFixed(1)} per 1,000 patient days is low for $_selectedUnitType, indicating excellent antimicrobial stewardship. Antibiotic exposure duration is well-controlled. Continue current practices and monitor trends.';
      } else if (dotRate <= moderateThreshold) {
        interpretation = 'Acceptable Use: DOT rate of ${dotRate.toStringAsFixed(1)} per 1,000 patient days is within acceptable range for $_selectedUnitType. Antibiotic use is moderate. Review prescribing patterns to identify opportunities for further optimization.';
      } else if (dotRate <= highThreshold) {
        interpretation = 'Elevated Use: DOT rate of ${dotRate.toStringAsFixed(1)} per 1,000 patient days is elevated for $_selectedUnitType. This suggests potential overuse or prolonged therapy. Stewardship intervention is recommended to reduce unnecessary antibiotic exposure.';
      } else {
        interpretation = 'High Use - Action Required: DOT rate of ${dotRate.toStringAsFixed(1)} per 1,000 patient days is significantly elevated for $_selectedUnitType. This indicates substantial antibiotic overuse. Immediate stewardship intervention is required to reduce exposure and prevent resistance.';
      }

      // Benchmark information
      final benchmark = 'DOT Benchmarks for $_selectedUnitType: ≤${lowThreshold.toStringAsFixed(0)} (excellent), ${lowThreshold.toStringAsFixed(0)}-${moderateThreshold.toStringAsFixed(0)} (acceptable), ${moderateThreshold.toStringAsFixed(0)}-${highThreshold.toStringAsFixed(0)} (elevated), >${highThreshold.toStringAsFixed(0)} (high - action required)';

      // Action recommendations if DOT is elevated
      String? action;
      if (dotRate > highThreshold) {
        action = 'Immediate Actions for High DOT:\n'
            '• Conduct urgent antibiotic utilization review\n'
            '• Implement prospective audit and feedback program\n'
            '• Review duration of therapy for common infections\n'
            '• Establish automatic stop orders for empiric therapy\n'
            '• Provide prescriber education on appropriate durations\n'
            '• Implement IV-to-oral conversion protocols\n'
            '• Review and update antibiotic guidelines\n'
            '• Consider antibiotic time-outs at 48-72 hours';
      } else if (dotRate > moderateThreshold) {
        action = 'Recommended Actions to Reduce DOT:\n'
            '• Review antibiotic durations for common infections\n'
            '• Implement shorter-course therapy where appropriate\n'
            '• Promote IV-to-oral conversion when clinically stable\n'
            '• Educate prescribers on optimal treatment durations\n'
            '• Monitor trends and provide regular feedback\n'
            '• Consider antibiotic time-outs for prolonged courses';
      }

      setState(() {
        _dotRate = dotRate;
        _lowerCI = lowerCI;
        _upperCI = upperCI;
        _interpretation = interpretation;
        _benchmark = benchmark;
        _action = action;
        _isLoading = false;
      });
    });
  }

  Map<String, double> _getUnitBenchmarks(String unitType) {
    switch (unitType) {
      case 'ICU':
        return {'low': 600.0, 'moderate': 800.0, 'high': 1000.0};
      case 'Emergency Department':
        return {'low': 100.0, 'moderate': 200.0, 'high': 300.0};
      case 'Surgical Ward':
        return {'low': 400.0, 'moderate': 600.0, 'high': 800.0};
      case 'General Ward':
      default:
        return {'low': 300.0, 'moderate': 500.0, 'high': 700.0};
    }
  }

  void _loadExample() {
    setState(() {
      _selectedAntibioticType = 'All Antibiotics';
      _selectedUnitType = 'General Ward';
      _antibioticDaysController.text = '500';
      _patientDaysController.text = '10000';
      _dotRate = null;
      _lowerCI = null;
      _upperCI = null;
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
                                _dotRate!.toStringAsFixed(1),
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
                                'per 1,000',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'patient days',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '95% CI: ${_lowerCI!.toStringAsFixed(1)} - ${_upperCI!.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '${_dotRate!.toStringAsFixed(1)} (95% CI: ${_lowerCI!.toStringAsFixed(1)}-${_upperCI!.toStringAsFixed(1)})'));
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
        calculatorName: 'DOT Calculator',
        inputs: {
          'Antibiotic Type': _selectedAntibioticType,
          'Unit Type': _selectedUnitType,
          'Antibiotic Days': _antibioticDaysController.text,
          'Patient Days': _patientDaysController.text,
        },
        result: 'DOT Rate: ${_dotRate!.toStringAsFixed(1)} per $_selectedUnitType\n'
            '95% CI: ${_lowerCI!.toStringAsFixed(1)} - ${_upperCI!.toStringAsFixed(1)}',
        notes: '',
        tags: ['antimicrobial-stewardship', 'dot', 'days-of-therapy', 'surveillance'],
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
      toolName: 'DOT (Days of Therapy) Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'Total Antibiotic Days': _antibioticDaysController.text,
        'Patient Days': _patientDaysController.text,
      },
      results: {
        'DOT Rate': '${_dotRate!.toStringAsFixed(1)} per 1,000 patient days',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(1)} - ${_upperCI!.toStringAsFixed(1)}',
      },
      benchmark: {
        'target': '≤500',
        'unit': 'DOT per 1,000 patient days',
        'source': 'CDC NHSN Antimicrobial Use',
        'status': _dotRate! > 500 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => r.url).toList(),
    );
  }

  Future<void> _exportAsExcel() async {
    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'DOT (Days of Therapy) Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'Total Antibiotic Days': _antibioticDaysController.text,
        'Patient Days': _patientDaysController.text,
      },
      results: {
        'DOT Rate': '${_dotRate!.toStringAsFixed(1)} per 1,000 patient days',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(1)} - ${_upperCI!.toStringAsFixed(1)}',
      },
      benchmark: {
        'target': '≤500',
        'unit': 'DOT per 1,000 patient days',
        'source': 'CDC NHSN Antimicrobial Use',
        'status': _dotRate! > 500 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'DOT (Days of Therapy) Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'Total Antibiotic Days': _antibioticDaysController.text,
        'Patient Days': _patientDaysController.text,
      },
      results: {
        'DOT Rate': '${_dotRate!.toStringAsFixed(1)} per 1,000 patient days',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(1)} - ${_upperCI!.toStringAsFixed(1)}',
      },
      benchmark: {
        'target': '≤500',
        'unit': 'DOT per 1,000 patient days',
        'source': 'CDC NHSN Antimicrobial Use',
        'status': _dotRate! > 500 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'DOT (Days of Therapy) Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Antibiotic Type': _selectedAntibioticType,
        'Unit Type': _selectedUnitType,
        'Total Antibiotic Days': _antibioticDaysController.text,
        'Patient Days': _patientDaysController.text,
      },
      results: {
        'DOT Rate': '${_dotRate!.toStringAsFixed(1)} per 1,000 patient days',
        '95% Confidence Interval': '${_lowerCI!.toStringAsFixed(1)} - ${_upperCI!.toStringAsFixed(1)}',
      },
      benchmark: {
        'target': '≤500',
        'unit': 'DOT per 1,000 patient days',
        'source': 'CDC NHSN Antimicrobial Use',
        'status': _dotRate! > 500 ? 'Above Target' : 'Meets Target',
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

