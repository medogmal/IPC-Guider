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

class VAECalculator extends ConsumerStatefulWidget {
  const VAECalculator({super.key});

  @override
  ConsumerState<VAECalculator> createState() => _VAECalculatorState();
}

class _VAECalculatorState extends ConsumerState<VAECalculator> {
  final _casesController = TextEditingController();
  final _daysController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double? _rate;
  double? _lowerCI;
  double? _upperCI;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isLoading = false;

  // VAE Type (optional stratification for educational context)
  String _selectedVAEType = 'All VAE';
  final List<String> _vaeTypes = [
    'All VAE',
    'VAC (Ventilator-Associated Condition)',
    'IVAC (Infection-related VAC)',
    'Possible VAP',
    'Probable VAP',
  ];

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'The Ventilator-Associated Event (VAE) rate is a standardized surveillance metric used to monitor complications associated with mechanical ventilation, including VAC, IVAC, and VAP.',
    formula: '(VAE Cases ÷ Ventilator Days) × 1,000',
    example: '4 VAE cases in ICU with 280 ventilator days → 14.29 per 1,000',
    interpretation: 'Rates below the NHSN baseline indicate effective ventilator management practices. Rates above baseline require investigation of ventilator bundle compliance and weaning protocols.',
    whenUsed: 'Used for continuous surveillance in ICUs and other units with mechanical ventilation. Required for NHSN reporting. Calculate monthly or quarterly for trend analysis.',
    inputDataType: 'Number of VAE cases and total ventilator days for the surveillance period',
    references: [
      Reference(
        title: 'CDC NHSN CLABSI Protocol',
        url: 'https://www.cdc.gov/nhsn/pdfs/pscmanual/4psc_clabscurrent.pdf',
      ),
      Reference(
        title: 'APIC CLABSI Prevention Guide',
        url: 'https://apic.org/Resource_/TinyMceFileManager/2015/APIC_CLABSI_WEB.pdf',
      ),
      Reference(
        title: 'GDIPC/Weqaya HAI Surveillance Standards',
        url: 'https://www.moh.gov.sa/en/Ministry/MediaCenter/Publications/Pages/Publications-2020-10-29-001.aspx',
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
        title: 'VAE Rate Calculator',
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
              // Header Card
              Container(
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.air_outlined,
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
                                'VAE Rate',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ventilator-Associated Events (VAC, IVAC, VAP)',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Formula Display Card
              Container(
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
                        Icon(
                          Icons.calculate_outlined,
                          color: AppColors.info,
                          size: 20,
                        ),
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
                            double fontSize = 16.0;
                            if (constraints.maxWidth < 300) {
                              fontSize = 12.0;
                            } else if (constraints.maxWidth < 400) {
                              fontSize = 14.0;
                            }

                            return Math.tex(
                              r'\text{VAE Rate} = \frac{\text{VAE Cases}}{\text{Ventilator Days}} \times 1{,}000',
                              textStyle: TextStyle(fontSize: fontSize),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Guide Button
              SizedBox(
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
              ),

              const SizedBox(height: 12),

              // Load Example Button
              SizedBox(
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
              ),

              const SizedBox(height: 24),

              // VAE Type Dropdown (Optional Educational Context)
              Container(
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
                        Icon(Icons.category_outlined, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'VAE Type (Optional)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select VAE type for educational context and NHSN reporting guidance',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildVAETypeDropdown(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Input Parameters Card
              Container(
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

                    // CLABSI Cases Input
                    TextFormField(
                      controller: _casesController,
                      decoration: InputDecoration(
                        labelText: 'Number of CLABSI Cases',
                        hintText: 'Enter number of CLABSI cases',
                        suffixText: 'cases',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medical_information_outlined, color: AppColors.primary),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of VAE cases';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num < 0) {
                          return 'Please enter a valid number (≥0)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Ventilator Days Input
                    TextFormField(
                      controller: _daysController,
                      decoration: InputDecoration(
                        labelText: 'Ventilator Days',
                        hintText: 'Enter total ventilator days',
                        suffixText: 'days',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ventilator days';
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
              ),

              const SizedBox(height: 24),

              // Calculate Button
              SizedBox(
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
              ),

              // Results Card (shown after calculation)
              if (_rate != null) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
              ],

              const SizedBox(height: 24),

              // References Section
              _buildReferences(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVAETypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVAEType,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: _vaeTypes.map((String type) {
            IconData icon;
            if (type.contains('VAC')) {
              icon = Icons.warning_amber_outlined;
            } else if (type.contains('IVAC')) {
              icon = Icons.coronavirus_outlined;
            } else if (type.contains('Possible VAP')) {
              icon = Icons.help_outline;
            } else if (type.contains('Probable VAP')) {
              icon = Icons.local_hospital_outlined;
            } else {
              icon = Icons.air_outlined;
            }

            return DropdownMenuItem<String>(
              value: type,
              child: Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedVAEType = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  // Calculate VAE Rate
  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate calculation delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      final cases = int.parse(_casesController.text);
      final days = int.parse(_daysController.text);

      // Calculate rate per 1,000 ventilator days
      final rate = (cases / days) * 1000;

      // Calculate 95% Confidence Interval using Poisson distribution
      final lowerCI = cases > 0 ? (_poissonLowerCI(cases) / days) * 1000 : 0.0;
      final upperCI = (_poissonUpperCI(cases) / days) * 1000;

      // Get VAE type-specific educational context
      final vaeContext = _getVAETypeContext(_selectedVAEType);

      // Generate interpretation with VAE type context
      String interpretation;
      if (rate <= 3.0) {
        interpretation = 'Rate at or below NHSN national baseline. This indicates effective ventilator management practices are in place.';
      } else if (rate <= 5.0) {
        interpretation = 'Rate slightly above NHSN national baseline. Review ventilator bundle compliance and consider targeted interventions.';
      } else {
        interpretation = 'Rate significantly above NHSN national baseline. Immediate investigation and intervention required.';
      }

      // Add VAE type-specific context if not "All VAE"
      if (_selectedVAEType != 'All VAE') {
        interpretation += '\n\n${vaeContext['context']}';
      }

      // Benchmark information with VAE type context
      String benchmark = 'NHSN National Baseline (2015): Medical ICU = 3.0, Surgical ICU = 4.5, Medical/Surgical ICU = 3.5 per 1,000 ventilator days. Target: ≤3.0 for most ICU types.';

      if (_selectedVAEType != 'All VAE') {
        benchmark += '\n\n${vaeContext['definition']}';
      }

      // Action recommendations (if rate exceeds benchmark)
      String? action;
      if (rate > 3.0) {
        action = 'Recommended Actions:\n'
            '• Review ventilator bundle compliance (HOB elevation, sedation vacation, SBT)\n'
            '• Audit daily readiness for extubation assessments\n'
            '• Reinforce oral care protocols (chlorhexidine)\n'
            '• Evaluate weaning protocols and spontaneous breathing trials\n'
            '• Consider early mobility and physical therapy programs';
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

  // Get VAE type-specific educational context
  Map<String, String> _getVAETypeContext(String vaeType) {
    switch (vaeType) {
      case 'VAC (Ventilator-Associated Condition)':
        return {
          'definition': 'VAC Definition: Baseline period of stability/improvement (≥2 days) followed by sustained worsening of oxygenation (≥2 days). Minimum PEEP increase of 3 cmH₂O or FiO₂ increase of 20 points.',
          'context': 'VAC is the broadest tier of VAE surveillance. It captures any sustained worsening of oxygenation, regardless of cause. VAC serves as the foundation for IVAC and VAP identification.',
        };
      case 'IVAC (Infection-related VAC)':
        return {
          'definition': 'IVAC Definition: VAC + temperature criteria (>38°C or <36°C) or WBC criteria (≥12,000 or ≤4,000 cells/mm³) + new antimicrobial agent started and continued for ≥4 days.',
          'context': 'IVAC represents VAC with objective evidence of infection or inflammation plus antimicrobial treatment. IVAC may be respiratory or non-respiratory in origin.',
        };
      case 'Possible VAP':
        return {
          'definition': 'Possible VAP Definition: IVAC + purulent respiratory secretions (from lung, not upper airway) OR positive culture from minimally contaminated specimen (BAL, protected brush, pleural fluid).',
          'context': 'Possible VAP adds microbiologic or purulent secretion evidence to IVAC. This tier provides stronger evidence of lower respiratory tract infection.',
        };
      case 'Probable VAP':
        return {
          'definition': 'Probable VAP Definition: IVAC + positive culture from minimally contaminated specimen (BAL ≥10⁴ CFU/ml, protected brush ≥10³ CFU/ml, or lung tissue ≥10⁴ CFU/g) meeting quantitative thresholds.',
          'context': 'Probable VAP represents the highest tier of VAE surveillance with quantitative microbiologic confirmation of pneumonia. This provides the strongest evidence of ventilator-associated pneumonia.',
        };
      default: // 'All VAE'
        return {
          'definition': '',
          'context': '',
        };
    }
  }

  // Poisson distribution confidence interval calculations
  double _poissonLowerCI(int cases) {
    if (cases == 0) return 0.0;
    // Chi-square approximation for Poisson lower CI
    return _chiSquareInverse(0.025, 2 * cases) / 2;
  }

  double _poissonUpperCI(int cases) {
    // Chi-square approximation for Poisson upper CI
    return _chiSquareInverse(0.975, 2 * (cases + 1)) / 2;
  }

  // Chi-square inverse approximation
  double _chiSquareInverse(double p, int df) {
    // Wilson-Hilferty approximation
    final z = _normalInverse(p);
    final term = z * sqrt(2.0 / df) - (2.0 / (9.0 * df));
    return (df * pow(1 + term, 3)).toDouble();
  }

  // Standard normal inverse (approximation)
  double _normalInverse(double p) {
    // Beasley-Springer-Moro algorithm approximation
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

  // Load example data
  void _loadExample() {
    setState(() {
      _casesController.text = '4';
      _daysController.text = '280';
      _selectedVAEType = 'IVAC (Infection-related VAC)';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example loaded: 4 VAE cases in 280 ventilator days'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show Quick Guide modal
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
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
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

  // Build Results Card
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
                        'VAE Rate',
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
                                _rate!.toStringAsFixed(2),
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                      fontSize: 48,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'per 1,000 ventilator days',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      if (_selectedVAEType != 'All VAE') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.category_outlined, size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                _selectedVAEType.split(' ')[0],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

                // International Benchmark Box (NEW FOR IPC)
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

                // Action Box (NEW FOR IPC - Conditional)
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

                // Action Buttons
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

  // Build References Section
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

  // Save result to history
  Future<void> _saveResult() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'VAE Rate Calculator',
        inputs: {
          'VAE Cases': _casesController.text,
          'Ventilator Days': _daysController.text,
        },
        result: 'Rate: ${_rate!.toStringAsFixed(2)} per 1,000 ventilator-days\n'
            '95% CI: ${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
        notes: '',
        tags: ['hai', 'vae', 'surveillance', 'infection-rate'],
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
            content: Text('Failed to save result: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Show export modal
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

  // Export functions
  Future<void> _exportAsPDF() async {
    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'VAE Rate Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'VAE Type': _selectedVAEType,
        'VAE Cases': _casesController.text,
        'Ventilator Days': _daysController.text,
      },
      results: {
        'VAE Rate': '${_rate!.toStringAsFixed(2)} per 1,000 ventilator days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      },
      benchmark: {
        'target': '≤2.0',
        'unit': 'per 1,000 ventilator days',
        'source': 'NHSN 2023 Baseline',
        'status': _rate! > 2.0 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => r.url).toList(),
    );
  }

  Future<void> _exportAsExcel() async {
    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'VAE Rate Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'VAE Type': _selectedVAEType,
        'VAE Cases': _casesController.text,
        'Ventilator Days': _daysController.text,
      },
      results: {
        'VAE Rate': '${_rate!.toStringAsFixed(2)} per 1,000 ventilator days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      },
      benchmark: {
        'target': '≤2.0',
        'unit': 'per 1,000 ventilator days',
        'source': 'NHSN 2023 Baseline',
        'status': _rate! > 2.0 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'VAE Rate Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'VAE Type': _selectedVAEType,
        'VAE Cases': _casesController.text,
        'Ventilator Days': _daysController.text,
      },
      results: {
        'VAE Rate': '${_rate!.toStringAsFixed(2)} per 1,000 ventilator days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      },
      benchmark: {
        'target': '≤2.0',
        'unit': 'per 1,000 ventilator days',
        'source': 'NHSN 2023 Baseline',
        'status': _rate! > 2.0 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'VAE Rate Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'VAE Type': _selectedVAEType,
        'VAE Cases': _casesController.text,
        'Ventilator Days': _daysController.text,
      },
      results: {
        'VAE Rate': '${_rate!.toStringAsFixed(2)} per 1,000 ventilator days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      },
      benchmark: {
        'target': '≤2.0',
        'unit': 'per 1,000 ventilator days',
        'source': 'NHSN 2023 Baseline',
        'status': _rate! > 2.0 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => r.url).toList(),
    );
  }

  // Launch URL
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


