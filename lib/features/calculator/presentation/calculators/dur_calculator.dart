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

class DURCalculator extends ConsumerStatefulWidget {
  const DURCalculator({super.key});

  @override
  ConsumerState<DURCalculator> createState() => _DURCalculatorState();
}

class _DURCalculatorState extends ConsumerState<DURCalculator> {
  final _deviceDaysController = TextEditingController();
  final _patientDaysController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedDeviceType = 'Central Line';
  double? _ratio;
  double? _percentage;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isLoading = false;

  final List<String> _deviceTypes = [
    'Central Line',
    'Urinary Catheter',
    'Ventilator',
  ];

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'The Device Utilization Ratio (DUR) measures the proportion of patients with invasive devices (central lines, urinary catheters, or ventilators) relative to total patient days. It is a key denominator metric used to calculate Standardized Infection Ratios (SIR) and monitor device usage patterns.',
    formula: 'Device Days ÷ Patient Days',
    example: 'ICU with 180 central line days and 400 patient days → DUR = 0.45 (45%)',
    interpretation: 'Lower DUR generally indicates less device exposure and potentially lower infection risk. However, DUR should be interpreted in clinical context - some units (e.g., ICUs) naturally have higher DUR. Compare to NHSN benchmarks for your unit type.',
    whenUsed: 'Used for continuous surveillance in all inpatient units. Required for NHSN reporting and SIR calculation. Calculate monthly or quarterly. Essential for monitoring device overuse and appropriateness of device placement.',
    inputDataType: 'Total device days (central line, urinary catheter, or ventilator) and total patient days for the surveillance period',
    references: [
      Reference(
        title: 'CDC NHSN Patient Safety Component Manual',
        url: 'https://www.cdc.gov/nhsn/pdfs/pscmanual/pcsmanual_current.pdf',
      ),
      Reference(
        title: 'NHSN Device-Associated Module',
        url: 'https://www.cdc.gov/nhsn/acute-care-hospital/index.html',
      ),
      Reference(
        title: 'APIC HAI Surveillance Guide',
        url: 'https://apic.org/Resource_/TinyMceFileManager/2015/APIC_HAI_Surveillance_Guide.pdf',
      ),
      Reference(
        title: 'GDIPC/Weqaya HAI Surveillance Standards',
        url: 'https://www.moh.gov.sa/en/Ministry/MediaCenter/Publications/Pages/Publications-2020-10-29-001.aspx',
      ),
    ],
  );

  @override
  void dispose() {
    _deviceDaysController.dispose();
    _patientDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Device Utilization Ratio',
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
                            Icons.device_hub_outlined,
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
                                'Device Utilization Ratio',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Device exposure monitoring for HAI prevention',
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
                        Icon(Icons.calculate_outlined, color: AppColors.info, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Formula',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
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
                              r'\text{DUR} = \frac{\text{Device Days}}{\text{Patient Days}}',
                              textStyle: TextStyle(fontSize: fontSize, color: AppColors.textPrimary),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Result expressed as ratio (e.g., 0.45) or percentage (e.g., 45%)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
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
                  onPressed: _showQuickGuide,
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

              const SizedBox(height: 20),

              // Device Type Dropdown
              _buildDeviceTypeDropdown(),

              const SizedBox(height: 20),

              // Input Fields Card
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
                      'Input Data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 20),

                    // Device Days Input
                    TextFormField(
                      controller: _deviceDaysController,
                      decoration: InputDecoration(
                        labelText: 'Device Days',
                        hintText: 'Enter total device days',
                        suffixText: 'days',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter device days';
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
              ),

              const SizedBox(height: 20),

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
                          'Calculate DUR',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              // Results Card
              if (_ratio != null) ...[
                const SizedBox(height: 20),
                _buildResultsCard(),
              ],

              // References Card
              const SizedBox(height: 20),
              _buildReferences(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceTypeDropdown() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDeviceType,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _deviceTypes.map((type) {
                IconData icon;
                if (type == 'Central Line') {
                  icon = Icons.bloodtype_outlined;
                } else if (type == 'Urinary Catheter') {
                  icon = Icons.water_drop_outlined;
                } else {
                  icon = Icons.air_outlined;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(type),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDeviceType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate calculation delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      final deviceDays = int.parse(_deviceDaysController.text);
      final patientDays = int.parse(_patientDaysController.text);

      // Calculate DUR
      final ratio = deviceDays / patientDays;
      final percentage = ratio * 100;

      // Generate interpretation based on device type and ratio
      String interpretation;
      String benchmark;
      String? action;

      if (_selectedDeviceType == 'Central Line') {
        if (ratio <= 0.40) {
          interpretation = 'DUR is below typical ICU range (40-60%). This may indicate appropriate device use or potential underutilization in high-acuity patients.';
          benchmark = 'NHSN Typical Range: Medical ICU = 0.40-0.60 (40-60%), Surgical ICU = 0.45-0.65 (45-65%)';
        } else if (ratio <= 0.60) {
          interpretation = 'DUR is within typical ICU range. This suggests appropriate central line utilization for the unit type.';
          benchmark = 'NHSN Typical Range: Medical ICU = 0.40-0.60 (40-60%), Surgical ICU = 0.45-0.65 (45-65%)';
        } else {
          interpretation = 'DUR is above typical ICU range. Consider reviewing central line necessity and appropriateness of placement.';
          benchmark = 'NHSN Typical Range: Medical ICU = 0.40-0.60 (40-60%), Surgical ICU = 0.45-0.65 (45-65%)';
          action = 'Recommended Actions:\n'
              '• Review daily central line necessity during rounds\n'
              '• Implement central line removal checklist\n'
              '• Consider alternative vascular access (PICC, midline)\n'
              '• Audit indications for central line placement\n'
              '• Educate staff on appropriate central line use';
        }
      } else if (_selectedDeviceType == 'Urinary Catheter') {
        if (ratio <= 0.20) {
          interpretation = 'DUR is below typical ICU range (20-40%). This indicates excellent catheter avoidance practices.';
          benchmark = 'NHSN Typical Range: Medical ICU = 0.20-0.40 (20-40%), Surgical ICU = 0.25-0.45 (25-45%)';
        } else if (ratio <= 0.40) {
          interpretation = 'DUR is within typical ICU range. Continue monitoring catheter appropriateness.';
          benchmark = 'NHSN Typical Range: Medical ICU = 0.20-0.40 (20-40%), Surgical ICU = 0.25-0.45 (25-45%)';
        } else {
          interpretation = 'DUR is above typical ICU range. Review catheter necessity and consider alternatives.';
          benchmark = 'NHSN Typical Range: Medical ICU = 0.20-0.40 (20-40%), Surgical ICU = 0.25-0.45 (25-45%)';
          action = 'Recommended Actions:\n'
              '• Implement nurse-driven catheter removal protocol\n'
              '• Review daily catheter necessity during rounds\n'
              '• Consider alternatives (external catheters, bladder scanner)\n'
              '• Audit indications for catheter placement\n'
              '• Educate staff on appropriate catheter use\n'
              '• Implement CAUTI prevention bundle';
        }
      } else { // Ventilator
        if (ratio <= 0.30) {
          interpretation = 'DUR is below typical ICU range (30-50%). This may indicate effective weaning protocols or lower-acuity patient population.';
          benchmark = 'NHSN Typical Range: Medical ICU = 0.30-0.50 (30-50%), Surgical ICU = 0.25-0.45 (25-45%)';
        } else if (ratio <= 0.50) {
          interpretation = 'DUR is within typical ICU range. Continue monitoring ventilator weaning protocols.';
          benchmark = 'NHSN Typical Range: Medical ICU = 0.30-0.50 (30-50%), Surgical ICU = 0.25-0.45 (25-45%)';
        } else {
          interpretation = 'DUR is above typical ICU range. Review ventilator weaning protocols and readiness assessments.';
          benchmark = 'NHSN Typical Range: Medical ICU = 0.30-0.50 (30-50%), Surgical ICU = 0.25-0.45 (25-45%)';
          action = 'Recommended Actions:\n'
              '• Implement daily spontaneous breathing trials (SBT)\n'
              '• Review sedation protocols (minimize sedation)\n'
              '• Assess readiness for extubation daily\n'
              '• Implement early mobility protocols\n'
              '• Audit ventilator weaning compliance\n'
              '• Consider non-invasive ventilation alternatives';
        }
      }

      setState(() {
        _ratio = ratio;
        _percentage = percentage;
        _interpretation = interpretation;
        _benchmark = benchmark;
        _action = action;
        _isLoading = false;
      });
    });
  }

  Widget _buildResultsCard() {
    Color cardColor;
    if (_selectedDeviceType == 'Central Line') {
      if (_ratio! <= 0.60) {
        cardColor = AppColors.success;
      } else {
        cardColor = AppColors.warning;
      }
    } else if (_selectedDeviceType == 'Urinary Catheter') {
      if (_ratio! <= 0.40) {
        cardColor = AppColors.success;
      } else {
        cardColor = AppColors.warning;
      }
    } else { // Ventilator
      if (_ratio! <= 0.50) {
        cardColor = AppColors.success;
      } else {
        cardColor = AppColors.warning;
      }
    }

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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.assessment, color: cardColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.save_outlined),
                  onPressed: _saveToHistory,
                  tooltip: 'Save to History',
                  color: AppColors.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: _showExportModal,
                  tooltip: 'Export',
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

          // Results Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DUR Values
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cardColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Device Utilization Ratio',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _ratio!.toStringAsFixed(3),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: cardColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Percentage',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${_percentage!.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: cardColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Device Type',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _selectedDeviceType,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Benchmark
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bar_chart, size: 20, color: AppColors.info),
                          const SizedBox(width: 8),
                          Text(
                            'Benchmark',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _benchmark!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Interpretation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cardColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: cardColor),
                          const SizedBox(width: 8),
                          Text(
                            'Interpretation',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _interpretation!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Recommended Actions (if applicable)
                if (_action != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.recommend_outlined, size: 20, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Text(
                              'Recommended Actions',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _action!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              Icon(Icons.library_books_outlined, size: 20, color: AppColors.primary),
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

  void _showQuickGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: KnowledgePanelWidget(data: _knowledgePanelData),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadExample() {
    setState(() {
      _deviceDaysController.text = '180';
      _patientDaysController.text = '400';
      _selectedDeviceType = 'Central Line';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example loaded: 180 central line days in 400 patient days'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveToHistory() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Device Utilization Ratio (DUR)',
        inputs: {
          'Device Type': _selectedDeviceType,
          'Device Days': _deviceDaysController.text,
          'Patient Days': _patientDaysController.text,
        },
        result: 'DUR: ${_ratio!.toStringAsFixed(3)}\n'
            'Percentage: ${_percentage!.toStringAsFixed(1)}%\n'
            'Benchmark: $_benchmark',
        notes: '',
        tags: ['antimicrobial-stewardship', 'dur', 'device-utilization', 'surveillance'],
      );

      await repository.addEntry(historyEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Result saved to history'),
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

  void _showExportModal() {
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
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: ExportModal(
                    onExportPDF: _exportAsPDF,
                    onExportCSV: _exportAsCSV,
                    onExportExcel: _exportAsExcel,
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

    final inputs = {
      'Device Type': _selectedDeviceType,
      'Device Days': _deviceDaysController.text,
      'Patient Days': _patientDaysController.text,
    };

    final results = {
      'Device Utilization Ratio': _ratio!.toStringAsFixed(3),
      'Percentage': '${_percentage!.toStringAsFixed(1)}%',
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Device Utilization Ratio',
      formula: _knowledgePanelData.formula,
      inputs: inputs,
      results: results,
      benchmark: {
        'target': '≤0.50',
        'unit': '(50%)',
        'source': 'NHSN 2023 Baseline',
        'status': _ratio! > 0.50 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation!,
      references: _knowledgePanelData.references.map((r) => r.url).toList(),
    );
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final inputs = {
      'Device Type': _selectedDeviceType,
      'Device Days': _deviceDaysController.text,
      'Patient Days': _patientDaysController.text,
    };

    final results = {
      'Device Utilization Ratio': _ratio!.toStringAsFixed(3),
      'Percentage': '${_percentage!.toStringAsFixed(1)}%',
    };

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Device Utilization Ratio',
      formula: _knowledgePanelData.formula,
      inputs: inputs,
      results: results,
      benchmark: {
        'target': '≤0.50',
        'unit': '(50%)',
        'source': 'NHSN 2023 Baseline',
        'status': _ratio! > 0.50 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation!,
    );
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Device Type': _selectedDeviceType,
      'Device Days': _deviceDaysController.text,
      'Patient Days': _patientDaysController.text,
    };

    final results = {
      'Device Utilization Ratio': _ratio!.toStringAsFixed(3),
      'Percentage': '${_percentage!.toStringAsFixed(1)}%',
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Device Utilization Ratio',
      formula: _knowledgePanelData.formula,
      inputs: inputs,
      results: results,
      benchmark: {
        'target': '≤0.50',
        'unit': '(50%)',
        'source': 'NHSN 2023 Baseline',
        'status': _ratio! > 0.50 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation!,
    );
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Device Type': _selectedDeviceType,
      'Device Days': _deviceDaysController.text,
      'Patient Days': _patientDaysController.text,
    };

    final results = {
      'Device Utilization Ratio': _ratio!.toStringAsFixed(3),
      'Percentage': '${_percentage!.toStringAsFixed(1)}%',
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Device Utilization Ratio',
      formula: _knowledgePanelData.formula,
      inputs: inputs,
      results: results,
      benchmark: {
        'target': '≤0.50',
        'unit': '(50%)',
        'source': 'NHSN 2023 Baseline',
        'status': _ratio! > 0.50 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation!,
      references: _knowledgePanelData.references.map((r) => r.url).toList(),
    );
  }
}
