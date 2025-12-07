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

class CLABSICalculator extends ConsumerStatefulWidget {
  const CLABSICalculator({super.key});

  @override
  ConsumerState<CLABSICalculator> createState() => _CLABSICalculatorState();
}

class _CLABSICalculatorState extends ConsumerState<CLABSICalculator> {
  final _casesController = TextEditingController();
  final _daysController = TextEditingController();
  final _customLocationController = TextEditingController();
  final _customLineTypeController = TextEditingController();
  final _customOrganismController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double? _rate;
  double? _lowerCI;
  double? _upperCI;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isLoading = false;

  // Required reporting elements
  String _selectedLocation = 'ICU';
  final List<String> _locations = [
    'ICU',
    'PICU',
    'NICU',
    'Dialysis Unit',
    'Medical Ward',
    'Surgical Ward',
    'Custom',
  ];

  String _selectedTimePeriod = 'Monthly';
  final List<String> _timePeriods = [
    'Monthly',
    'Quarterly',
    'Semi-Annual',
    'Annual',
  ];

  String? _selectedQuarter; // For quarterly reporting
  final List<String> _quarters = ['Q1', 'Q2', 'Q3', 'Q4'];

  // Optional reporting elements
  String _selectedLineType = 'All Line Types';
  final List<String> _lineTypes = [
    'All Line Types',
    'PICC',
    'Non-tunneled CVC',
    'Tunneled CVC',
    'Implanted Port',
    'Dialysis Catheter',
    'Custom',
  ];

  String _selectedOrganism = 'Not Specified';
  final List<String> _organisms = [
    'Not Specified',
    'CoNS',
    'MRSA',
    'Klebsiella spp.',
    'Pseudomonas aeruginosa',
    'Candida spp.',
    'E. coli',
    'Enterococcus spp.',
    'Custom',
  ];

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'The Central Line-Associated Bloodstream Infection (CLABSI) rate is a standardized surveillance metric used to monitor the incidence of bloodstream infections associated with central venous catheters.',
    formula: '(CLABSI Cases ÷ Central Line Days) × 1,000',
    example: '3 CLABSI cases in ICU with 450 central line days → 6.67 per 1,000',
    interpretation: 'Rates below the NHSN baseline indicate effective prevention practices. Rates above baseline require investigation of insertion and maintenance practices.',
    whenUsed: 'Used for continuous surveillance in ICUs and other units with central lines. Required for NHSN reporting. Calculate monthly or quarterly for trend analysis.',
    inputDataType: 'Number of CLABSI cases and total central line days for the surveillance period',
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
    _customLocationController.dispose();
    _customLineTypeController.dispose();
    _customOrganismController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'CLABSI Rate Calculator',
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
                            Icons.bloodtype_outlined,
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
                                'CLABSI Rate',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Central Line-Associated Bloodstream Infections',
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
                              r'\text{CLABSI Rate} = \frac{\text{CLABSI Cases}}{\text{Central Line Days}} \times 1{,}000',
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
                  icon: Icon(Icons.menu_book, color: AppColors.info),
                  label: Text(
                    'Quick Guide',
                    style: TextStyle(
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
                  icon: Icon(Icons.lightbulb_outline, color: AppColors.success),
                  label: Text(
                    'Load Example',
                    style: TextStyle(
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

              // Reporting Elements Card (Required)
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
                        Icon(Icons.assignment_outlined, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Reporting Elements (Required)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Essential elements for NHSN reporting and surveillance',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLocationDropdown(),
                    const SizedBox(height: 16),
                    _buildTimePeriodDropdown(),
                    if (_selectedTimePeriod == 'Quarterly') ...[
                      const SizedBox(height: 16),
                      _buildQuarterDropdown(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Optional Reporting Elements Card
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
                        Icon(Icons.tune_outlined, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Optional Reporting Elements',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Additional stratification for detailed analysis',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLineTypeDropdown(),
                    const SizedBox(height: 16),
                    _buildOrganismDropdown(),
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
                          return 'Please enter number of CLABSI cases';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num < 0) {
                          return 'Please enter a valid number (≥0)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Central Line Days Input
                    TextFormField(
                      controller: _daysController,
                      decoration: InputDecoration(
                        labelText: 'Central Line Days',
                        hintText: 'Enter total central line days',
                        suffixText: 'days',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter central line days';
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

  // Build Location Dropdown
  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLocation,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              items: _locations.map((String location) {
                IconData icon;
                if (location.contains('ICU') && !location.contains('PICU') && !location.contains('NICU')) {
                  icon = Icons.local_hospital_outlined;
                } else if (location.contains('PICU')) {
                  icon = Icons.child_care_outlined;
                } else if (location.contains('NICU')) {
                  icon = Icons.baby_changing_station_outlined;
                } else if (location.contains('Dialysis')) {
                  icon = Icons.water_drop_outlined;
                } else if (location.contains('Medical')) {
                  icon = Icons.medical_services_outlined;
                } else if (location.contains('Surgical')) {
                  icon = Icons.healing_outlined;
                } else {
                  icon = Icons.edit_outlined;
                }

                return DropdownMenuItem<String>(
                  value: location,
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          location,
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
                    _selectedLocation = newValue;
                  });
                }
              },
            ),
          ),
        ),
        if (_selectedLocation == 'Custom') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _customLocationController,
            decoration: InputDecoration(
              labelText: 'Custom Location/Unit',
              hintText: 'Enter location or unit name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.edit, color: AppColors.primary),
            ),
            validator: (value) {
              if (_selectedLocation == 'Custom' && (value == null || value.isEmpty)) {
                return 'Please enter location name';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  // Build Time Period Dropdown
  Widget _buildTimePeriodDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTimePeriod,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: _timePeriods.map((String period) {
            IconData icon;
            if (period.contains('Monthly')) {
              icon = Icons.calendar_month_outlined;
            } else if (period.contains('Quarterly')) {
              icon = Icons.calendar_view_month_outlined;
            } else if (period.contains('Semi')) {
              icon = Icons.date_range_outlined;
            } else {
              icon = Icons.calendar_today_outlined;
            }

            return DropdownMenuItem<String>(
              value: period,
              child: Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      period,
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
                _selectedTimePeriod = newValue;
                if (newValue != 'Quarterly') {
                  _selectedQuarter = null;
                } else {
                  _selectedQuarter ??= 'Q1';
                }
              });
            }
          },
        ),
      ),
    );
  }

  // Build Quarter Dropdown (for Quarterly reporting)
  Widget _buildQuarterDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedQuarter,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: _quarters.map((String quarter) {
            return DropdownMenuItem<String>(
              value: quarter,
              child: Row(
                children: [
                  Icon(Icons.filter_1_outlined, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      quarter,
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
                _selectedQuarter = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  // Build Line Type Dropdown
  Widget _buildLineTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLineType,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              items: _lineTypes.map((String lineType) {
                IconData icon;
                if (lineType.contains('All')) {
                  icon = Icons.bloodtype_outlined;
                } else if (lineType.contains('PICC')) {
                  icon = Icons.cable_outlined;
                } else if (lineType.contains('Non-tunneled')) {
                  icon = Icons.straighten_outlined;
                } else if (lineType.contains('Tunneled')) {
                  icon = Icons.route_outlined;
                } else if (lineType.contains('Port')) {
                  icon = Icons.hub_outlined;
                } else if (lineType.contains('Dialysis')) {
                  icon = Icons.water_drop_outlined;
                } else {
                  icon = Icons.edit_outlined;
                }

                return DropdownMenuItem<String>(
                  value: lineType,
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          lineType,
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
                    _selectedLineType = newValue;
                  });
                }
              },
            ),
          ),
        ),
        if (_selectedLineType == 'Custom') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _customLineTypeController,
            decoration: InputDecoration(
              labelText: 'Custom Line Type',
              hintText: 'Enter line type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.edit, color: AppColors.primary),
            ),
            validator: (value) {
              if (_selectedLineType == 'Custom' && (value == null || value.isEmpty)) {
                return 'Please enter line type';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  // Build Organism Dropdown
  Widget _buildOrganismDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedOrganism,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              items: _organisms.map((String organism) {
                IconData icon;
                if (organism.contains('Not Specified')) {
                  icon = Icons.remove_circle_outline;
                } else if (organism.contains('CoNS')) {
                  icon = Icons.coronavirus_outlined;
                } else if (organism.contains('MRSA')) {
                  icon = Icons.warning_amber_outlined;
                } else if (organism.contains('Klebsiella')) {
                  icon = Icons.bug_report_outlined;
                } else if (organism.contains('Pseudomonas')) {
                  icon = Icons.pest_control_outlined;
                } else if (organism.contains('Candida')) {
                  icon = Icons.grain_outlined;
                } else if (organism.contains('E. coli')) {
                  icon = Icons.biotech_outlined;
                } else if (organism.contains('Enterococcus')) {
                  icon = Icons.circle_outlined;
                } else {
                  icon = Icons.edit_outlined;
                }

                return DropdownMenuItem<String>(
                  value: organism,
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          organism,
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
                    _selectedOrganism = newValue;
                  });
                }
              },
            ),
          ),
        ),
        if (_selectedOrganism == 'Custom') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _customOrganismController,
            decoration: InputDecoration(
              labelText: 'Custom Organism',
              hintText: 'Enter organism name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.edit, color: AppColors.primary),
            ),
            validator: (value) {
              if (_selectedOrganism == 'Custom' && (value == null || value.isEmpty)) {
                return 'Please enter organism name';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  // Calculate CLABSI Rate
  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate calculation delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      final cases = int.parse(_casesController.text);
      final days = int.parse(_daysController.text);

      // Calculate rate per 1,000 central line days
      final rate = (cases / days) * 1000;

      // Calculate 95% Confidence Interval using Poisson distribution
      final lowerCI = cases > 0 ? (_poissonLowerCI(cases) / days) * 1000 : 0.0;
      final upperCI = (_poissonUpperCI(cases) / days) * 1000;

      // Generate interpretation
      String interpretation;
      if (rate <= 1.0) {
        interpretation = 'Rate at or below NHSN national baseline. This indicates effective infection prevention practices are in place.';
      } else if (rate <= 2.0) {
        interpretation = 'Rate slightly above NHSN national baseline. Review prevention practices and consider targeted interventions.';
      } else {
        interpretation = 'Rate significantly above NHSN national baseline. Immediate investigation and intervention required.';
      }

      // Benchmark information
      const benchmark = 'NHSN National Baseline (2015): Medical ICU = 0.8, Surgical ICU = 1.1, Medical/Surgical ICU = 1.0 per 1,000 central line days. Target: ≤1.0 for most ICU types.';

      // Action recommendations (if rate exceeds benchmark)
      String? action;
      if (rate > 1.0) {
        action = 'Recommended Actions:\n'
            '• Review central line insertion checklist compliance\n'
            '• Audit daily necessity assessments\n'
            '• Verify maintenance bundle adherence (hand hygiene, dressing changes, port disinfection)\n'
            '• Conduct root cause analysis for each CLABSI\n'
            '• Provide staff education on prevention strategies';
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
      _casesController.text = '3';
      _daysController.text = '450';
      _selectedLocation = 'ICU';
      _selectedTimePeriod = 'Quarterly';
      _selectedQuarter = 'Q2';
      _selectedLineType = 'PICC';
      _selectedOrganism = 'MRSA';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example loaded: 3 MRSA CLABSI cases (PICC) in ICU, Q2, 450 central line days'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
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

  // Build Reporting Badge
  Widget _buildReportingBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
                        'CLABSI Rate',
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
                                'per 1,000 CL days',
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
                      const SizedBox(height: 16),
                      // Reporting Elements Badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildReportingBadge(
                            Icons.location_on_outlined,
                            _selectedLocation == 'Custom'
                                ? _customLocationController.text
                                : _selectedLocation,
                          ),
                          _buildReportingBadge(
                            Icons.calendar_month_outlined,
                            _selectedTimePeriod == 'Quarterly' && _selectedQuarter != null
                                ? '$_selectedTimePeriod ($_selectedQuarter)'
                                : _selectedTimePeriod,
                          ),
                          if (_selectedLineType != 'All Line Types')
                            _buildReportingBadge(
                              Icons.bloodtype_outlined,
                              _selectedLineType == 'Custom'
                                  ? _customLineTypeController.text
                                  : _selectedLineType,
                            ),
                          if (_selectedOrganism != 'Not Specified')
                            _buildReportingBadge(
                              Icons.coronavirus_outlined,
                              _selectedOrganism == 'Custom'
                                  ? _customOrganismController.text
                                  : _selectedOrganism,
                            ),
                        ],
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

  // Save result to history
  Future<void> _saveResult() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'CLABSI Rate Calculator',
        inputs: {
          'CLABSI Cases': _casesController.text,
          'Central Line Days': _daysController.text,
        },
        result: 'Rate: ${_rate!.toStringAsFixed(2)} per 1,000 line-days\n'
            '95% CI: ${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
        notes: '',
        tags: ['hai', 'clabsi', 'surveillance', 'infection-rate'],
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
    final location = _selectedLocation == 'Custom' ? _customLocationController.text : _selectedLocation;
    final timePeriod = _selectedTimePeriod == 'Quarterly' && _selectedQuarter != null
        ? '$_selectedTimePeriod ($_selectedQuarter)'
        : _selectedTimePeriod;
    final lineType = _selectedLineType == 'Custom' ? _customLineTypeController.text : _selectedLineType;
    final organism = _selectedOrganism == 'Custom' ? _customOrganismController.text : _selectedOrganism;

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'CLABSI Rate Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Location/Unit': location,
        'Time Period': timePeriod,
        'Line Type': lineType,
        'Organism': organism,
        'CLABSI Cases': _casesController.text,
        'Central Line Days': _daysController.text,
      },
      results: {
        'CLABSI Rate': '${_rate!.toStringAsFixed(2)} per 1,000 central line days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      },
      benchmark: {
        'target': '≤1.0',
        'unit': 'per 1,000 central line days',
        'source': 'NHSN 2023 Baseline',
        'status': _rate! > 1.0 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => r.url).toList(),
    );
  }

  Future<void> _exportAsExcel() async {
    final location = _selectedLocation == 'Custom' ? _customLocationController.text : _selectedLocation;
    final timePeriod = _selectedTimePeriod == 'Quarterly' && _selectedQuarter != null
        ? '$_selectedTimePeriod ($_selectedQuarter)'
        : _selectedTimePeriod;
    final lineType = _selectedLineType == 'Custom' ? _customLineTypeController.text : _selectedLineType;
    final organism = _selectedOrganism == 'Custom' ? _customOrganismController.text : _selectedOrganism;

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'CLABSI Rate Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Location/Unit': location,
        'Time Period': timePeriod,
        'Line Type': lineType,
        'Organism': organism,
        'CLABSI Cases': _casesController.text,
        'Central Line Days': _daysController.text,
      },
      results: {
        'CLABSI Rate': '${_rate!.toStringAsFixed(2)} per 1,000 central line days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      },
      benchmark: {
        'target': '≤1.0',
        'unit': 'per 1,000 central line days',
        'source': 'NHSN 2023 Baseline',
        'status': _rate! > 1.0 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    final location = _selectedLocation == 'Custom' ? _customLocationController.text : _selectedLocation;
    final timePeriod = _selectedTimePeriod == 'Quarterly' && _selectedQuarter != null
        ? '$_selectedTimePeriod ($_selectedQuarter)'
        : _selectedTimePeriod;
    final lineType = _selectedLineType == 'Custom' ? _customLineTypeController.text : _selectedLineType;
    final organism = _selectedOrganism == 'Custom' ? _customOrganismController.text : _selectedOrganism;

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'CLABSI Rate Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Location/Unit': location,
        'Time Period': timePeriod,
        'Line Type': lineType,
        'Organism': organism,
        'CLABSI Cases': _casesController.text,
        'Central Line Days': _daysController.text,
      },
      results: {
        'CLABSI Rate': '${_rate!.toStringAsFixed(2)} per 1,000 central line days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      },
      benchmark: {
        'target': '≤1.0',
        'unit': 'per 1,000 central line days',
        'source': 'NHSN 2023 Baseline',
        'status': _rate! > 1.0 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    final location = _selectedLocation == 'Custom' ? _customLocationController.text : _selectedLocation;
    final timePeriod = _selectedTimePeriod == 'Quarterly' && _selectedQuarter != null
        ? '$_selectedTimePeriod ($_selectedQuarter)'
        : _selectedTimePeriod;
    final lineType = _selectedLineType == 'Custom' ? _customLineTypeController.text : _selectedLineType;
    final organism = _selectedOrganism == 'Custom' ? _customOrganismController.text : _selectedOrganism;

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'CLABSI Rate Calculator',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Location/Unit': location,
        'Time Period': timePeriod,
        'Line Type': lineType,
        'Organism': organism,
        'CLABSI Cases': _casesController.text,
        'Central Line Days': _daysController.text,
      },
      results: {
        'CLABSI Rate': '${_rate!.toStringAsFixed(2)} per 1,000 central line days',
        '95% CI': '${_lowerCI!.toStringAsFixed(2)} - ${_upperCI!.toStringAsFixed(2)}',
      },
      benchmark: {
        'target': '≤1.0',
        'unit': 'per 1,000 central line days',
        'source': 'NHSN 2023 Baseline',
        'status': _rate! > 1.0 ? 'Above Target' : 'Meets Target',
      },
      recommendations: _action,
      interpretation: _interpretation,
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


