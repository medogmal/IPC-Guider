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

class MDROIncidenceCalculator extends ConsumerStatefulWidget {
  const MDROIncidenceCalculator({super.key});

  @override
  ConsumerState<MDROIncidenceCalculator> createState() => _MDROIncidenceCalculatorState();
}

class _MDROIncidenceCalculatorState extends ConsumerState<MDROIncidenceCalculator> {
  final _casesController = TextEditingController();
  final _daysController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedMDROType = 'MRSA';
  double? _rate;
  double? _lowerCI;
  double? _upperCI;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isLoading = false;

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'The MDRO Incidence Rate measures the occurrence of new multidrug-resistant organism infections or colonizations per 1,000 patient days. This metric is essential for monitoring antimicrobial resistance trends and evaluating infection prevention interventions.',
    formula: '(New MDRO Cases ÷ Patient Days) × 1,000',
    example: '5 new MRSA cases in 2,000 patient days → 2.5 per 1,000 patient days',
    interpretation: 'Lower rates indicate effective infection prevention and antimicrobial stewardship. Rates above benchmarks require investigation of transmission routes, hand hygiene compliance, environmental cleaning, and antimicrobial prescribing practices.',
    whenUsed: 'Use this calculator to monitor MDRO acquisition rates in your facility. Essential for tracking infection prevention effectiveness, comparing performance against benchmarks, and identifying trends requiring intervention. Calculate monthly or quarterly for surveillance reporting and quality improvement initiatives.',
    inputDataType: 'Number of new MDRO cases (infections or colonizations) and total patient days for the surveillance period. Specify MDRO type (MRSA, VRE, ESBL, CRE) for appropriate benchmark comparison.',
    references: [
      Reference(
        title: 'CDC MDRO Management Guidelines',
        url: 'https://www.cdc.gov/infectioncontrol/guidelines/mdro/index.html',
      ),
      Reference(
        title: 'WHO Guidelines on Core Components of IPC Programmes',
        url: 'https://www.who.int/publications/i/item/9789241549929',
      ),
      Reference(
        title: 'APIC Guide to Preventing MDRO Transmission',
        url: 'https://apic.org/Resource_/TinyMceFileManager/Practice_Guidance/MDRO-Prevention-Strategies.pdf',
      ),
    ],
  );

  @override
  void dispose() {
    _casesController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'MDRO Incidence Rate',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          child: Form(
            key: _formKey,
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
              if (_rate != null) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
              ],
              const SizedBox(height: 16),
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
              Icons.coronavirus_outlined,
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
                  'MDRO Incidence Rate',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Multidrug-Resistant Organism Surveillance',
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
                    r'\text{MDRO Rate} = \frac{\text{New MDRO Cases}}{\text{Patient Days}} \times 1{,}000',
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

          // MDRO Type Dropdown
          DropdownButtonFormField<String>(
            value: _selectedMDROType,
            decoration: InputDecoration(
              labelText: 'MDRO Type',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.biotech, color: AppColors.primary),
            ),
            items: const [
              DropdownMenuItem(value: 'MRSA', child: Text('MRSA (Methicillin-Resistant Staphylococcus aureus)')),
              DropdownMenuItem(value: 'VRE', child: Text('VRE (Vancomycin-Resistant Enterococci)')),
              DropdownMenuItem(value: 'ESBL', child: Text('ESBL (Extended-Spectrum Beta-Lactamase)')),
              DropdownMenuItem(value: 'CRE', child: Text('CRE (Carbapenem-Resistant Enterobacteriaceae)')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedMDROType = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // New MDRO Cases
          TextFormField(
            controller: _casesController,
            decoration: InputDecoration(
              labelText: 'New MDRO Cases',
              hintText: 'Enter number of new cases',
              suffixText: 'cases',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.add_alert, color: AppColors.primary),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter number of MDRO cases';
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
            controller: _daysController,
            decoration: InputDecoration(
              labelText: 'Patient Days',
              hintText: 'Enter total patient days',
              suffixText: 'days',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
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
          elevation: 2,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      final cases = int.parse(_casesController.text);
      final days = int.parse(_daysController.text);

      // Calculate rate
      final rate = (cases / days) * 1000;

      // Calculate 95% CI using Poisson distribution
      final lowerCI = cases > 0 ? (_poissonLowerCI(cases) / days) * 1000 : 0.0;
      final upperCI = (_poissonUpperCI(cases) / days) * 1000;

      // Get benchmarks based on MDRO type
      final benchmarks = _getBenchmarks(_selectedMDROType);

      // Generate interpretation
      String interpretation;
      if (rate <= benchmarks['excellent']!) {
        interpretation = 'Excellent: The $_selectedMDROType incidence rate is at or below the excellent benchmark. This indicates highly effective infection prevention and control practices. Continue current surveillance and prevention strategies.';
      } else if (rate <= benchmarks['acceptable']!) {
        interpretation = 'Acceptable: The $_selectedMDROType incidence rate is within acceptable range but above the excellent benchmark. Review infection prevention practices and consider targeted interventions to further reduce transmission.';
      } else {
        interpretation = 'Action Required: The $_selectedMDROType incidence rate exceeds acceptable benchmarks. Immediate investigation and intervention are needed. Review hand hygiene compliance, environmental cleaning, isolation practices, and antimicrobial stewardship.';
      }

      // Benchmark information
      final benchmark = '$_selectedMDROType Benchmarks: ≤${benchmarks['excellent']} per 1,000 patient days (excellent), '
          '${benchmarks['excellent']}-${benchmarks['acceptable']} (acceptable), '
          '>${benchmarks['acceptable']} (action required)';

      // Action recommendations if rate is high
      String? action;
      if (rate > benchmarks['acceptable']!) {
        action = 'Recommended Actions:\n'
            '• Conduct root cause analysis to identify transmission sources\n'
            '• Audit hand hygiene compliance and provide targeted education\n'
            '• Review and enhance environmental cleaning protocols\n'
            '• Ensure proper isolation precautions for colonized/infected patients\n'
            '• Implement active surveillance screening in high-risk units\n'
            '• Review antimicrobial prescribing practices with stewardship team\n'
            '• Consider cohorting patients and dedicated staff assignments';
      }

      setState(() {
        _rate = rate;
        _lowerCI = lowerCI;
        _upperCI = upperCI;
        _interpretation = interpretation;
        _benchmark = benchmark;
        _action = action;
        _isLoading = false;
      });
    });
  }

  Map<String, double> _getBenchmarks(String mdroType) {
    switch (mdroType) {
      case 'MRSA':
        return {'excellent': 0.5, 'acceptable': 1.0};
      case 'VRE':
        return {'excellent': 0.3, 'acceptable': 0.8};
      case 'ESBL':
        return {'excellent': 1.0, 'acceptable': 2.0};
      case 'CRE':
        return {'excellent': 0.1, 'acceptable': 0.3};
      default:
        return {'excellent': 1.0, 'acceptable': 2.0};
    }
  }

  // Poisson distribution confidence interval calculations
  double _poissonLowerCI(int cases) {
    if (cases == 0) return 0.0;
    return _chiSquareInverse(0.025, 2 * cases) / 2;
  }

  double _poissonUpperCI(int cases) {
    return _chiSquareInverse(0.975, 2 * (cases + 1)) / 2;
  }

  double _chiSquareInverse(double p, int df) {
    final z = _normalInverse(p);
    final term = z * sqrt(2.0 / df) - (2.0 / (9.0 * df));
    return (df * pow(1 + term, 3)).toDouble();
  }

  double _normalInverse(double p) {
    const a0 = 2.50662823884;
    const a1 = -18.61500062529;
    const a2 = 41.39119773534;
    const a3 = -25.44106049637;
    const b1 = -8.47351093090;
    const b2 = 23.08336743743;
    const b3 = -21.06224101826;
    const b4 = 3.13082909833;
    const c0 = 0.3374754822726147;
    const c1 = 0.9761690190917186;
    const c2 = 0.1607979714918209;
    const c3 = 0.0276438810333863;
    const c4 = 0.0038405729373609;
    const c5 = 0.0003951896511919;
    const c6 = 0.0000321767881768;
    const c7 = 0.0000002888167364;
    const c8 = 0.0000003960315187;

    if (p <= 0.0 || p >= 1.0) return 0.0;

    final y = p - 0.5;
    if (y.abs() < 0.42) {
      final r = y * y;
      return y * (((a3 * r + a2) * r + a1) * r + a0) /
          ((((b4 * r + b3) * r + b2) * r + b1) * r + 1.0);
    }

    var r = p;
    if (y > 0.0) r = 1.0 - p;
    r = log(-log(r));
    final x = c0 +
        r * (c1 +
            r * (c2 +
                r * (c3 +
                    r * (c4 + r * (c5 + r * (c6 + r * (c7 + r * c8)))))));
    if (y < 0.0) return -x;
    return x;
  }

  void _loadExample() {
    setState(() {
      _selectedMDROType = 'MRSA';
      _casesController.text = '5';
      _daysController.text = '2000';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example loaded: 5 MRSA cases in 2,000 patient days'),
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
                        '$_selectedMDROType Incidence Rate',
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
                              _rate!.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                    fontSize: 48,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'per 1,000 days',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          Clipboard.setData(ClipboardData(text: _rate!.toStringAsFixed(2)));
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
                      const SizedBox(height: 12),
                      Text(
                        '95% CI: ${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
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
                            'International Benchmark',
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
                              'Action Required',
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
        calculatorName: 'MDRO Incidence Calculator',
        inputs: {
          'MDRO Type': _selectedMDROType,
          'MDRO Cases': _casesController.text,
          'Patient Days': _daysController.text,
        },
        result: 'Incidence Rate: ${_rate!.toStringAsFixed(2)} per 1,000 patient-days\n'
            '95% CI: ${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
        notes: '',
        tags: ['antimicrobial-stewardship', 'mdro', 'incidence', 'surveillance'],
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
      toolName: 'MDRO Incidence Rate Calculator',
      inputs: {
        'MDRO Type': _selectedMDROType,
        'New MDRO Cases': _casesController.text,
        'Patient Days': _daysController.text,
      },
      results: {
        '$_selectedMDROType Incidence Rate': '${_rate!.toStringAsFixed(2)} per 1,000 patient days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      },
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => r.url).toList(),
    );
  }

  Future<void> _exportAsExcel() async {
    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'MDRO Incidence Rate Calculator',
      inputs: {
        'MDRO Type': _selectedMDROType,
        'New MDRO Cases': _casesController.text,
        'Patient Days': _daysController.text,
      },
      results: {
        '$_selectedMDROType Incidence Rate': '${_rate!.toStringAsFixed(2)} per 1,000 patient days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      },
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'MDRO Incidence Rate Calculator',
      inputs: {
        'MDRO Type': _selectedMDROType,
        'New MDRO Cases': _casesController.text,
        'Patient Days': _daysController.text,
      },
      results: {
        '$_selectedMDROType Incidence Rate': '${_rate!.toStringAsFixed(2)} per 1,000 patient days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      },
    );
  }

  Future<void> _exportAsText() async {
    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'MDRO Incidence Rate Calculator',
      inputs: {
        'MDRO Type': _selectedMDROType,
        'New MDRO Cases': _casesController.text,
        'Patient Days': _daysController.text,
      },
      results: {
        '$_selectedMDROType Incidence Rate': '${_rate!.toStringAsFixed(2)} per 1,000 patient days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
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

