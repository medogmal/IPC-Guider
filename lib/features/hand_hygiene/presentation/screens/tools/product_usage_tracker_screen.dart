import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/back_button.dart';
import '../../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../outbreak/data/models/history_entry.dart';
import '../../../../outbreak/data/repositories/history_repository.dart';

class ProductUsageTrackerScreen extends ConsumerStatefulWidget {
  const ProductUsageTrackerScreen({super.key});

  @override
  ConsumerState<ProductUsageTrackerScreen> createState() => _ProductUsageTrackerScreenState();
}

class _ProductUsageTrackerScreenState extends ConsumerState<ProductUsageTrackerScreen> {
  final _abhsVolumeController = TextEditingController();
  final _patientDaysController = TextEditingController();
  final _hcwCountController = TextEditingController();
  final _bedCountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedUnitType = 'ICU';
  int _reportingDays = 30;

  double? _usagePerPatientDay;
  double? _usagePerHcwDay;
  double? _usagePerBedDay;
  int? _estimatedActions;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isLoading = false;

  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'ABHS Product Usage Tracker monitors alcohol-based hand sanitizer consumption as a proxy indicator for hand hygiene activity. WHO recommends tracking product usage alongside direct observation to assess hand hygiene compliance. Higher consumption generally indicates more frequent hand hygiene actions, though it should be interpreted in context with patient acuity, staffing levels, and direct observation data. This metric is easy to collect from supply chain data and provides continuous monitoring without observer presence.',
    formula: 'Usage per Patient-Day (mL) = (ABHS Volume in Liters × 1000) / Patient-Days\n'
        'Usage per HCW per Day (mL) = (ABHS Volume in Liters × 1000) / (HCWs × Days)\n'
        'Estimated Hand Hygiene Actions = (ABHS Volume in Liters × 1000) / 3 mL per action',
    example: 'ICU used 45 liters ABHS in 30 days with 600 patient-days and 50 HCWs:\n'
        '• Usage per Patient-Day = (45 × 1000) / 600 = 75 mL/patient-day\n'
        '• Usage per HCW/Day = (45 × 1000) / (50 × 30) = 30 mL/HCW/day\n'
        '• Estimated Actions = (45 × 1000) / 3 = 15,000 actions',
    interpretation: 'WHO benchmarks for ABHS consumption: ICU 100-150 mL/patient-day, General Ward 20-40 mL/patient-day, HCW 15-30 mL/HCW/day. Higher usage indicates more frequent hand hygiene actions. Low usage suggests poor compliance or inadequate dispenser placement. Very high usage may indicate waste or inappropriate use. Compare with direct observation data to validate compliance. Monitor trends over time to assess improvement initiatives.',
    whenUsed: 'Use this tracker to monitor ABHS consumption patterns and identify units with low or high usage. Essential for hand hygiene program monitoring, resource planning, and identifying areas needing intervention. Calculate monthly or quarterly to track trends. Combine with direct observation data for comprehensive hand hygiene assessment. Useful for benchmarking across units and facilities.',
    inputDataType: 'ABHS volume consumed (liters), patient-days, number of healthcare workers, number of beds, and reporting period (days). Data typically obtained from supply chain or pharmacy records. Ensure accurate patient-day counts from census data. HCW count should include all staff with patient contact (nurses, physicians, therapists, etc.).',
    references: [
      Reference(
        title: 'WHO Guidelines on Hand Hygiene in Health Care - Product Consumption Monitoring',
        url: 'https://www.who.int/publications/i/item/9789241597906',
      ),
      Reference(
        title: 'CDC: Measuring Hand Hygiene Adherence',
        url: 'https://www.cdc.gov/hand-hygiene/hcp/measuring-adherence.html',
      ),
      Reference(
        title: 'SHEA/IDSA: Strategies to Improve Hand Hygiene Compliance',
        url: 'https://www.cambridge.org/core/journals/infection-control-and-hospital-epidemiology',
      ),
    ],
  );

  @override
  void dispose() {
    _abhsVolumeController.dispose();
    _patientDaysController.dispose();
    _hcwCountController.dispose();
    _bedCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'ABHS Product Usage Tracker',
        backgroundColor: AppColors.info,
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
              if (_usagePerPatientDay != null) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
              ],
              if (_interpretation != null) ...[
                const SizedBox(height: 24),
                _buildInterpretationSection(),
              ],
              if (_benchmark != null) ...[
                const SizedBox(height: 16),
                _buildBenchmarkSection(),
              ],
              if (_action != null) ...[
                const SizedBox(height: 16),
                _buildActionSection(),
              ],
              if (_usagePerPatientDay != null) ...[
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
              const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(AppSpacing.extraLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info,
            AppColors.info.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_drink_outlined, color: Colors.white, size: 56),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'ABHS Product Usage Tracker',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Monitor Hand Sanitizer Consumption',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w500,
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
                'Formulas',
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
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    double fontSize = 12.0;
                    if (constraints.maxWidth < 300) {
                      fontSize = 9.0;
                    } else if (constraints.maxWidth < 400) {
                      fontSize = 10.0;
                    }

                    return Column(
                      children: [
                        Math.tex(
                          r'\text{Usage per Patient-Day (mL)} = \frac{\text{ABHS Volume (L)} \times 1000}{\text{Patient-Days}}',
                          textStyle: TextStyle(fontSize: fontSize),
                        ),
                        const SizedBox(height: 12),
                        Math.tex(
                          r'\text{Usage per HCW/Day (mL)} = \frac{\text{ABHS Volume (L)} \times 1000}{\text{HCWs} \times \text{Days}}',
                          textStyle: TextStyle(fontSize: fontSize),
                        ),
                      ],
                    );
                  },
                ),
              ],
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

          // Unit Type Dropdown
          DropdownButtonFormField<String>(
            value: _selectedUnitType,
            decoration: InputDecoration(
              labelText: 'Unit Type',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_hospital, color: AppColors.info),
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

          // Reporting Period Dropdown
          DropdownButtonFormField<int>(
            value: _reportingDays,
            decoration: InputDecoration(
              labelText: 'Reporting Period',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today, color: AppColors.info),
            ),
            items: const [
              DropdownMenuItem(value: 7, child: Text('7 days (1 week)')),
              DropdownMenuItem(value: 14, child: Text('14 days (2 weeks)')),
              DropdownMenuItem(value: 30, child: Text('30 days (1 month)')),
              DropdownMenuItem(value: 90, child: Text('90 days (1 quarter)')),
            ],
            onChanged: (value) {
              setState(() {
                _reportingDays = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // ABHS Volume
          TextFormField(
            controller: _abhsVolumeController,
            decoration: InputDecoration(
              labelText: 'ABHS Volume Used',
              hintText: 'Enter volume in liters',
              suffixText: 'liters',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_drink, color: AppColors.info),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter ABHS volume';
              }
              final num = double.tryParse(value);
              if (num == null || num <= 0) {
                return 'Please enter a valid number (>0)';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Patient-Days
          TextFormField(
            controller: _patientDaysController,
            decoration: InputDecoration(
              labelText: 'Patient-Days',
              hintText: 'Enter total patient-days',
              suffixText: 'patient-days',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.people, color: AppColors.info),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter patient-days';
              }
              final num = int.tryParse(value);
              if (num == null || num <= 0) {
                return 'Please enter a valid number (>0)';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // HCW Count
          TextFormField(
            controller: _hcwCountController,
            decoration: InputDecoration(
              labelText: 'Number of Healthcare Workers',
              hintText: 'Enter HCW count',
              suffixText: 'HCWs',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.medical_services, color: AppColors.info),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter HCW count';
              }
              final num = int.tryParse(value);
              if (num == null || num <= 0) {
                return 'Please enter a valid number (>0)';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Bed Count
          TextFormField(
            controller: _bedCountController,
            decoration: InputDecoration(
              labelText: 'Number of Beds',
              hintText: 'Enter bed count',
              suffixText: 'beds',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.bed, color: AppColors.info),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter bed count';
              }
              final num = int.tryParse(value);
              if (num == null || num <= 0) {
                return 'Please enter a valid number (>0)';
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
          backgroundColor: AppColors.info,
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
      final abhsVolume = double.parse(_abhsVolumeController.text);
      final patientDays = int.parse(_patientDaysController.text);
      final hcwCount = int.parse(_hcwCountController.text);
      final bedCount = int.parse(_bedCountController.text);

      // Calculate usage metrics
      final usagePerPatientDay = (abhsVolume * 1000) / patientDays;
      final usagePerHcwDay = (abhsVolume * 1000) / (hcwCount * _reportingDays);
      final usagePerBedDay = (abhsVolume * 1000) / (bedCount * _reportingDays);
      final estimatedActions = ((abhsVolume * 1000) / 3).round(); // 3 mL per action

      // Get context-specific benchmarks
      double targetMin, targetMax;
      String targetDescription;
      switch (_selectedUnitType) {
        case 'ICU':
          targetMin = 100.0;
          targetMax = 150.0;
          targetDescription = 'WHO benchmark: 100-150 mL/patient-day';
          break;
        case 'General Ward':
          targetMin = 20.0;
          targetMax = 40.0;
          targetDescription = 'WHO benchmark: 20-40 mL/patient-day';
          break;
        case 'Operating Room':
          targetMin = 80.0;
          targetMax = 120.0;
          targetDescription = 'Surgical unit benchmark: 80-120 mL/patient-day';
          break;
        case 'Emergency Department':
          targetMin = 60.0;
          targetMax = 100.0;
          targetDescription = 'Emergency dept benchmark: 60-100 mL/patient-day';
          break;
        case 'Outpatient Clinic':
          targetMin = 10.0;
          targetMax = 25.0;
          targetDescription = 'Outpatient benchmark: 10-25 mL/patient-day';
          break;
        default:
          targetMin = 30.0;
          targetMax = 60.0;
          targetDescription = 'Facility-wide benchmark: 30-60 mL/patient-day';
      }

      // Generate interpretation
      String interpretation;
      if (usagePerPatientDay >= targetMin && usagePerPatientDay <= targetMax * 1.2) {
        interpretation = 'Optimal ABHS Usage: Usage of ${usagePerPatientDay.toStringAsFixed(1)} mL/patient-day is within the expected range for $_selectedUnitType ($targetDescription). This suggests appropriate hand hygiene activity. Continue monitoring trends and correlate with direct observation data to validate compliance. Ensure adequate dispenser placement and product availability to sustain usage.';
      } else if (usagePerPatientDay < targetMin) {
        final deficit = ((targetMin - usagePerPatientDay) / targetMin * 100).toStringAsFixed(0);
        interpretation = 'Low ABHS Usage - Action Required: Usage of ${usagePerPatientDay.toStringAsFixed(1)} mL/patient-day is $deficit% below the minimum benchmark for $_selectedUnitType ($targetDescription). This indicates poor hand hygiene compliance or inadequate dispenser placement. Immediate interventions needed: conduct direct observations to confirm low compliance, assess dispenser accessibility, provide education, implement reminders, and monitor usage trends weekly.';
      } else {
        final excess = ((usagePerPatientDay - targetMax) / targetMax * 100).toStringAsFixed(0);
        interpretation = 'High ABHS Usage: Usage of ${usagePerPatientDay.toStringAsFixed(1)} mL/patient-day is $excess% above the maximum benchmark for $_selectedUnitType ($targetDescription). This may indicate excellent compliance, high patient acuity, or potential waste. Investigate: conduct direct observations to validate compliance, assess for product waste or inappropriate use, review patient acuity and infection rates, and ensure proper dispenser function.';
      }

      // Benchmark information
      final benchmark = 'ABHS Consumption Benchmarks (WHO): $targetDescription. HCW usage: 15-30 mL/HCW/day. Benchmarks vary by unit type based on patient acuity, care intensity, and hand hygiene opportunities. Higher acuity units (ICU, OR) have higher expected consumption. Monitor trends over time and compare with direct observation data for comprehensive assessment.';

      // Action recommendations
      String? action;
      if (usagePerPatientDay < targetMin) {
        action = 'Immediate Actions for Low ABHS Usage:\n'
            '• Conduct direct hand hygiene observations to confirm low compliance\n'
            '• Assess dispenser placement: ensure dispensers at point-of-care (bedside, room entrance)\n'
            '• Check product availability: ensure dispensers are filled and functional\n'
            '• Provide targeted education on WHO 5 Moments and hand hygiene importance\n'
            '• Implement visual reminders and decision support at point of care\n'
            '• Assign unit champions to model and reinforce hand hygiene\n'
            '• Monitor usage weekly and provide feedback to staff\n'
            '• Address workflow barriers that prevent hand hygiene';
      } else if (usagePerPatientDay > targetMax * 1.2) {
        action = 'Recommended Actions for High ABHS Usage:\n'
            '• Conduct direct observations to validate high compliance vs. waste\n'
            '• Assess for product waste: check for leaking dispensers, excessive dispensing\n'
            '• Review patient acuity and infection rates (high acuity may justify high usage)\n'
            '• Educate staff on appropriate ABHS volume (3 mL per application)\n'
            '• Ensure dispensers are functioning properly (not over-dispensing)\n'
            '• If usage is due to excellent compliance, recognize and celebrate success\n'
            '• Share best practices with other units';
      }

      setState(() {
        _usagePerPatientDay = usagePerPatientDay;
        _usagePerHcwDay = usagePerHcwDay;
        _usagePerBedDay = usagePerBedDay;
        _estimatedActions = estimatedActions;
        _interpretation = interpretation;
        _benchmark = benchmark;
        _action = action;
        _isLoading = false;
      });
    });
  }

  void _loadExample() {
    setState(() {
      _selectedUnitType = 'ICU';
      _reportingDays = 30;
      _abhsVolumeController.text = '45';
      _patientDaysController.text = '600';
      _hcwCountController.text = '50';
      _bedCountController.text = '20';
      _usagePerPatientDay = null;
      _usagePerHcwDay = null;
      _usagePerBedDay = null;
      _estimatedActions = null;
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
                    Icon(Icons.menu_book, color: AppColors.info, size: 28),
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
        gradient: LinearGradient(
          colors: [
            AppColors.info,
            AppColors.info.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withValues(alpha: 0.3),
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
              Icon(Icons.assessment, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Results',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Primary Result - Usage per Patient-Day
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Usage per Patient-Day',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_usagePerPatientDay!.toStringAsFixed(1)} mL',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'per patient-day',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Secondary Results Grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Per HCW/Day',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_usagePerHcwDay!.toStringAsFixed(1)} mL',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Per Bed/Day',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_usagePerBedDay!.toStringAsFixed(1)} mL',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Estimated Actions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Hand Hygiene Actions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  '${_estimatedActions!.toString()} actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Context Information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Context',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildContextRow('Unit Type', _selectedUnitType),
                _buildContextRow('Reporting Period', '$_reportingDays days'),
                _buildContextRow('ABHS Volume', '${_abhsVolumeController.text} liters'),
                _buildContextRow('Patient-Days', _patientDaysController.text),
                _buildContextRow('Healthcare Workers', _hcwCountController.text),
                _buildContextRow('Beds', _bedCountController.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Interpretation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    );
  }

  Widget _buildBenchmarkSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_outlined, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'Benchmark',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
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
    );
  }

  Widget _buildActionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
              Icon(Icons.recommend_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recommended Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _saveToHistory,
            icon: Icon(Icons.save_outlined, color: AppColors.success, size: 20),
            label: Text(
              'Save',
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
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showExportOptions,
            icon: const Icon(Icons.file_download_outlined, size: 20),
            label: const Text(
              'Export',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferences() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.library_books, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'References',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._knowledgePanelData.references.map((ref) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () async {
                    final uri = Uri.parse(ref.url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.link, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ref.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
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

  Future<void> _saveToHistory() async {
    try {
      final historyRepo = HistoryRepository();
      final entry = HistoryEntry.fromCalculator(
        calculatorName: 'ABHS Product Usage Tracker',
        inputs: {
          'Unit Type': _selectedUnitType,
          'Reporting Period': '$_reportingDays days',
          'ABHS Volume': '${_abhsVolumeController.text} liters',
          'Patient-Days': _patientDaysController.text,
          'Healthcare Workers': _hcwCountController.text,
          'Beds': _bedCountController.text,
        },
        result: '${_usagePerPatientDay!.toStringAsFixed(1)} mL/patient-day',
        tags: ['Hand Hygiene', 'Product Usage', 'ABHS', _selectedUnitType],
      );

      await historyRepo.addEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to history successfully'),
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

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportModal(
        onExportPDF: _exportAsPDF,
        onExportExcel: _exportAsExcel,
        onExportCSV: _exportAsCSV,
        onExportText: _exportAsText,
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    Navigator.pop(context);
    final success = await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'ABHS Product Usage Tracker',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Unit Type': _selectedUnitType,
        'Reporting Period': '$_reportingDays days',
        'ABHS Volume Used': '${_abhsVolumeController.text} liters',
        'Patient-Days': '${_patientDaysController.text} patient-days',
        'Healthcare Workers': '${_hcwCountController.text} HCWs',
        'Beds': '${_bedCountController.text} beds',
      },
      results: {
        'Usage per Patient-Day': '${_usagePerPatientDay!.toStringAsFixed(1)} mL/patient-day',
        'Usage per HCW/Day': '${_usagePerHcwDay!.toStringAsFixed(1)} mL/HCW/day',
        'Usage per Bed/Day': '${_usagePerBedDay!.toStringAsFixed(1)} mL/bed/day',
        'Estimated Hand Hygiene Actions': '${_estimatedActions!.toString()} actions',
      },
      benchmark: {
        'target': _benchmark ?? 'WHO benchmarks vary by unit type',
        'unit': 'mL/patient-day',
        'source': 'WHO Guidelines on Hand Hygiene in Health Care (2009)',
        'status': 'See interpretation for detailed assessment',
      },
      recommendations: _action,
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => '${r.title}: ${r.url}').toList(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF exported successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);
    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'ABHS Product Usage Tracker',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Unit Type': _selectedUnitType,
        'Reporting Period': '$_reportingDays days',
        'ABHS Volume Used': '${_abhsVolumeController.text} liters',
        'Patient-Days': '${_patientDaysController.text} patient-days',
        'Healthcare Workers': '${_hcwCountController.text} HCWs',
        'Beds': '${_bedCountController.text} beds',
      },
      results: {
        'Usage per Patient-Day': '${_usagePerPatientDay!.toStringAsFixed(1)} mL/patient-day',
        'Usage per HCW/Day': '${_usagePerHcwDay!.toStringAsFixed(1)} mL/HCW/day',
        'Usage per Bed/Day': '${_usagePerBedDay!.toStringAsFixed(1)} mL/bed/day',
        'Estimated Hand Hygiene Actions': '${_estimatedActions!.toString()} actions',
      },
      benchmark: {
        'target': _benchmark ?? 'WHO benchmarks vary by unit type',
        'unit': 'mL/patient-day',
        'source': 'WHO Guidelines on Hand Hygiene in Health Care (2009)',
        'status': 'See interpretation for detailed assessment',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Excel file exported successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);
    final success = await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'ABHS Product Usage Tracker',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Unit Type': _selectedUnitType,
        'Reporting Period': '$_reportingDays days',
        'ABHS Volume Used': '${_abhsVolumeController.text} liters',
        'Patient-Days': '${_patientDaysController.text} patient-days',
        'Healthcare Workers': '${_hcwCountController.text} HCWs',
        'Beds': '${_bedCountController.text} beds',
      },
      results: {
        'Usage per Patient-Day': '${_usagePerPatientDay!.toStringAsFixed(1)} mL/patient-day',
        'Usage per HCW/Day': '${_usagePerHcwDay!.toStringAsFixed(1)} mL/HCW/day',
        'Usage per Bed/Day': '${_usagePerBedDay!.toStringAsFixed(1)} mL/bed/day',
        'Estimated Hand Hygiene Actions': '${_estimatedActions!.toString()} actions',
      },
      benchmark: {
        'target': _benchmark ?? 'WHO benchmarks vary by unit type',
        'unit': 'mL/patient-day',
        'source': 'WHO Guidelines on Hand Hygiene in Health Care (2009)',
        'status': 'See interpretation for detailed assessment',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('CSV file exported successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);
    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'ABHS Product Usage Tracker',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Unit Type': _selectedUnitType,
        'Reporting Period': '$_reportingDays days',
        'ABHS Volume Used': '${_abhsVolumeController.text} liters',
        'Patient-Days': '${_patientDaysController.text} patient-days',
        'Healthcare Workers': '${_hcwCountController.text} HCWs',
        'Beds': '${_bedCountController.text} beds',
      },
      results: {
        'Usage per Patient-Day': '${_usagePerPatientDay!.toStringAsFixed(1)} mL/patient-day',
        'Usage per HCW/Day': '${_usagePerHcwDay!.toStringAsFixed(1)} mL/HCW/day',
        'Usage per Bed/Day': '${_usagePerBedDay!.toStringAsFixed(1)} mL/bed/day',
        'Estimated Hand Hygiene Actions': '${_estimatedActions!.toString()} actions',
      },
      benchmark: {
        'target': _benchmark ?? 'WHO benchmarks vary by unit type',
        'unit': 'mL/patient-day',
        'source': 'WHO Guidelines on Hand Hygiene in Health Care (2009)',
        'status': 'See interpretation for detailed assessment',
      },
      recommendations: _action,
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => '${r.title}: ${r.url}').toList(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Text file exported successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
