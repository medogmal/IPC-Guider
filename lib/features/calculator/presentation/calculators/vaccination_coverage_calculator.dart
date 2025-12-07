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

class VaccinationCoverageCalculator extends ConsumerStatefulWidget {
  const VaccinationCoverageCalculator({super.key});

  @override
  ConsumerState<VaccinationCoverageCalculator> createState() => _VaccinationCoverageCalculatorState();
}

class _VaccinationCoverageCalculatorState extends ConsumerState<VaccinationCoverageCalculator> {
  final _vaccinatedStaffController = TextEditingController();
  final _totalStaffController = TextEditingController();
  final _customVaccineController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedVaccineType = 'Influenza';
  double? _coverageRate;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isLoading = false;

  final List<String> _vaccineTypes = [
    'Influenza',
    'Hepatitis B',
    'COVID-19',
    'MMR',
    'Varicella',
    'Custom',
  ];

  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Vaccination Coverage measures the percentage of healthcare workers who have received recommended immunizations. High vaccination coverage protects both staff and patients from vaccine-preventable diseases, prevents healthcare-associated outbreaks, and demonstrates commitment to occupational health. This metric is critical for infection prevention, staff safety, and regulatory compliance.',
    formula: 'Vaccination Coverage (%) = (Vaccinated Staff × 100) / Total Staff at Risk',
    example: 'Hospital has 500 HCWs eligible for influenza vaccine. 450 received the vaccine → Coverage = (450 × 100) / 500 = 90%',
    interpretation: 'Higher coverage rates indicate better immunization compliance and lower outbreak risk. ≥90% is excellent (herd immunity achieved), 80-89% is good (needs improvement), 70-79% is moderate (action required), <70% is poor (urgent intervention needed). Coverage varies by vaccine type and should be monitored annually or seasonally.',
    whenUsed: 'Use this calculator to monitor immunization compliance for all recommended vaccines (Influenza, Hepatitis B, COVID-19, MMR, Varicella, Tdap, etc.). Essential for annual vaccination campaigns, regulatory reporting, outbreak prevention, and occupational health program evaluation. Calculate at end of vaccination season or annually for non-seasonal vaccines.',
    inputDataType: 'Number of HCWs who received the complete vaccine series (vaccinated staff) and total number of HCWs who should receive the vaccine based on exposure risk (total staff at risk). Specify vaccine type for context-specific benchmarks. Requires vaccination records from occupational health database.',
    references: [
      Reference(
        title: 'CDC Healthcare Personnel Vaccination Recommendations',
        url: 'https://www.cdc.gov/vaccines/adults/rec-vac/hcw.html',
      ),
      Reference(
        title: 'WHO Immunization of Health-Care Personnel',
        url: 'https://www.who.int/teams/health-workforce/health-worker-safety',
      ),
      Reference(
        title: 'ACIP Adult Immunization Schedule',
        url: 'https://www.cdc.gov/vaccines/schedules/hcp/imz/adult.html',
      ),
      Reference(
        title: 'OSHA Bloodborne Pathogens Standard',
        url: 'https://www.osha.gov/bloodborne-pathogens',
      ),
    ],
  );

  @override
  void dispose() {
    _vaccinatedStaffController.dispose();
    _totalStaffController.dispose();
    _customVaccineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Vaccination Coverage %'),
        backgroundColor: AppColors.surface,
        elevation: 0,
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
              const SizedBox(height: 16),
              _buildLoadExampleButton(),
              const SizedBox(height: 16),
              _buildVaccineTypeDropdown(),
              const SizedBox(height: 16),
              _buildInputCard(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_coverageRate != null) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
                const SizedBox(height: 16),
                _buildVaccineInformationCard(),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vaccines, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vaccination Coverage %',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Monitor immunization compliance among healthcare workers to protect staff and patients from vaccine-preventable diseases.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
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
                    r'\text{Vaccination Coverage } \% = \frac{\text{Vaccinated Staff} \times 100}{\text{Total Staff at Risk}}',
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

  Widget _buildVaccineTypeDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Vaccine Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedVaccineType,
              decoration: InputDecoration(
                labelText: 'Select Vaccine Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              items: _vaccineTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVaccineType = value!;
                  _coverageRate = null;
                });
              },
            ),
            if (_selectedVaccineType == 'Custom') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customVaccineController,
                decoration: InputDecoration(
                  labelText: 'Custom Vaccine Name',
                  hintText: 'Enter vaccine name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.edit, color: AppColors.primary),
                ),
                validator: (value) {
                  if (_selectedVaccineType == 'Custom' && (value == null || value.isEmpty)) {
                    return 'Please enter vaccine name';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
              controller: _vaccinatedStaffController,
              decoration: InputDecoration(
                labelText: 'Vaccinated Staff',
                hintText: 'Enter number of vaccinated staff',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.check_circle, color: AppColors.success),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vaccinated staff';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) < 0) {
                  return 'Number cannot be negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalStaffController,
              decoration: InputDecoration(
                labelText: 'Total Staff at Risk',
                hintText: 'Enter total staff at risk',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.people, color: AppColors.primary),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total staff';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                final total = int.parse(value);
                if (total <= 0) {
                  return 'Total must be greater than 0';
                }
                final vaccinated = int.tryParse(_vaccinatedStaffController.text);
                if (vaccinated != null && vaccinated > total) {
                  return 'Vaccinated staff cannot exceed total staff';
                }
                return null;
              },
            ),
          ],
        ),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                ),
              )
            : Text(
                'Calculate Coverage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.surface,
                ),
              ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final vaccinatedStaff = int.parse(_vaccinatedStaffController.text);
    final totalStaff = int.parse(_totalStaffController.text);

    final coverageRate = (vaccinatedStaff * 100) / totalStaff;

    setState(() {
      _coverageRate = coverageRate;
      _interpretation = _getInterpretation(coverageRate);
      _benchmark = _getBenchmark();
      _action = _getAction(coverageRate);
      _isLoading = false;
    });

    _saveToHistory();
  }

  String _getInterpretation(double coverage) {
    if (coverage >= 90) {
      return 'Excellent vaccination coverage! Herd immunity achieved. This level of coverage provides strong protection for both staff and patients against vaccine-preventable diseases.';
    } else if (coverage >= 80) {
      return 'Good vaccination coverage, but improvement needed. Close to herd immunity threshold. Continue efforts to reach ≥90% coverage.';
    } else if (coverage >= 70) {
      return 'Moderate vaccination coverage. Action required to improve compliance. Significant gaps in protection remain. Investigate barriers to vaccination.';
    } else {
      return 'Poor vaccination coverage. Urgent intervention needed! Staff and patients are at high risk for outbreaks. Immediate action required to improve coverage.';
    }
  }

  String _getBenchmark() {
    switch (_selectedVaccineType) {
      case 'Influenza':
        return '≥90% (WHO/CDC target)';
      case 'Hepatitis B':
        return '≥95% (high-risk areas)';
      case 'COVID-19':
        return '≥90% (varies by policy)';
      case 'MMR':
        return '≥95% (pre-employment)';
      case 'Varicella':
        return '≥95% (pre-employment)';
      case 'Custom':
        return '≥90% (general target)';
      default:
        return '≥90%';
    }
  }

  String _getAction(double coverage) {
    if (coverage >= 90) {
      return 'Maintain current vaccination strategies. Continue monitoring coverage and address any new barriers. Recognize and reward high-performing units.';
    } else if (coverage >= 80) {
      return 'Implement targeted interventions: mobile vaccination clinics, extended hours, peer champions, address vaccine hesitancy through education.';
    } else if (coverage >= 70) {
      return 'Urgent action required: conduct barrier assessment, implement mandatory vaccination policy (if applicable), increase awareness campaigns, provide incentives.';
    } else {
      return 'Critical intervention needed: leadership engagement, mandatory vaccination policy review, address systemic barriers, consider disciplinary measures for non-compliance (per policy).';
    }
  }

  void _loadExample() {
    setState(() {
      _selectedVaccineType = 'Influenza';
      _vaccinatedStaffController.text = '450';
      _totalStaffController.text = '500';
      _coverageRate = null;
    });
  }

  Widget _buildResultsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: AppColors.primary, size: 28),
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
            const SizedBox(height: 24),
            _buildResultRow(
              'Vaccine Type',
              _selectedVaccineType == 'Custom'
                  ? _customVaccineController.text
                  : _selectedVaccineType,
              Icons.vaccines,
              AppColors.info,
            ),
            const Divider(height: 24),
            _buildResultRow(
              'Vaccination Coverage',
              '${_coverageRate!.toStringAsFixed(1)}%',
              Icons.percent,
              AppColors.primary,
              isHighlight: true,
            ),
            const Divider(height: 24),
            _buildResultRow(
              'Benchmark',
              _benchmark!,
              Icons.flag,
              _coverageRate! >= 90 ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
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
                      Icon(Icons.lightbulb, color: AppColors.info, size: 20),
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
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
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
                      Icon(Icons.recommend, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Recommended Action',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveResult,
                    icon: Icon(Icons.save, color: AppColors.primary),
                    label: Text('Save', style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showExportModal,
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
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
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon, Color color, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isHighlight ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                  fontSize: isHighlight ? 20 : 16,
                ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildVaccineInformationCard() {
    final vaccineInfo = _getVaccineInformation();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 2),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: AppColors.info, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Vaccine Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoSection('Recommended Schedule', vaccineInfo['schedule']!),
            const Divider(height: 24),
            _buildInfoSection('Target Population', vaccineInfo['target']!),
            const Divider(height: 24),
            _buildInfoSection('Booster Requirements', vaccineInfo['booster']!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Map<String, String> _getVaccineInformation() {
    switch (_selectedVaccineType) {
      case 'Influenza':
        return {
          'schedule': 'Annual vaccination before flu season (September-October). Single dose for most adults.',
          'target': 'All healthcare workers with direct patient contact. Priority for high-risk units (ICU, ER, pediatrics).',
          'booster': 'Annual revaccination required due to antigenic drift and waning immunity.',
        };
      case 'Hepatitis B':
        return {
          'schedule': '3-dose series (0, 1, 6 months). Check anti-HBs titer 1-2 months after series completion.',
          'target': 'All HCWs with potential exposure to blood/body fluids. Mandatory for high-risk areas.',
          'booster': 'Not routinely recommended if anti-HBs ≥10 mIU/mL. Booster for non-responders or high-risk exposures.',
        };
      case 'COVID-19':
        return {
          'schedule': 'Primary series (2 doses) + boosters per current guidelines. Timing varies by vaccine type.',
          'target': 'All healthcare workers. Priority for frontline staff and high-risk units.',
          'booster': 'Annual or bivalent boosters recommended. Follow updated CDC/WHO guidance.',
        };
      case 'MMR':
        return {
          'schedule': '2-dose series (0, 4-8 weeks apart) for non-immune HCWs. Check immunity via serology or vaccination records.',
          'target': 'All HCWs born after 1957 without evidence of immunity. Critical for pediatric and maternity units.',
          'booster': 'Not routinely recommended after 2-dose series. Consider during outbreaks.',
        };
      case 'Varicella':
        return {
          'schedule': '2-dose series (0, 4-8 weeks apart) for non-immune HCWs. Check immunity via serology or history of disease.',
          'target': 'All HCWs without evidence of immunity. Priority for pediatric, oncology, and transplant units.',
          'booster': 'Not routinely recommended after 2-dose series. Consider post-exposure prophylaxis.',
        };
      case 'Custom':
        return {
          'schedule': 'Refer to vaccine-specific guidelines and manufacturer recommendations.',
          'target': 'Consult occupational health and infection prevention for target population.',
          'booster': 'Follow vaccine-specific booster schedule per CDC/WHO guidelines.',
        };
      default:
        return {
          'schedule': 'N/A',
          'target': 'N/A',
          'booster': 'N/A',
        };
    }
  }

  Widget _buildReferences() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    child: Row(
                      children: [
                        Icon(Icons.link, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reference.title,
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
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showQuickGuide(BuildContext context) {
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
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Guide',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 24),
                      _buildGuideSection(
                        'Definition',
                        _knowledgePanelData.definition,
                        Icons.info,
                        AppColors.info,
                      ),
                      const SizedBox(height: 20),
                      _buildGuideSection(
                        'Formula',
                        _knowledgePanelData.formula,
                        Icons.calculate,
                        AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      _buildGuideSection(
                        'Example',
                        _knowledgePanelData.example,
                        Icons.lightbulb,
                        AppColors.warning,
                      ),
                      const SizedBox(height: 20),
                      _buildGuideSection(
                        'Interpretation',
                        _knowledgePanelData.interpretation,
                        Icons.insights,
                        AppColors.success,
                      ),
                      const SizedBox(height: 20),
                      _buildGuideSection(
                        'Indications/Use',
                        _knowledgePanelData.whenUsed,
                        Icons.medical_services,
                        AppColors.error,
                      ),
                      const SizedBox(height: 20),
                      _buildGuideSection(
                        'Input Data Type',
                        _knowledgePanelData.inputDataType,
                        Icons.input,
                        AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideSection(String title, String? content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Future<void> _saveToHistory() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final vaccineType = _selectedVaccineType == 'Custom'
          ? _customVaccineController.text
          : _selectedVaccineType;

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Vaccination Coverage Calculator',
        inputs: {
          'Vaccine Type': vaccineType,
          'Vaccinated Staff': _vaccinatedStaffController.text,
          'Total Staff': _totalStaffController.text,
        },
        result: 'Coverage Rate: ${_coverageRate!.toStringAsFixed(1)}%\n'
            'Benchmark: $_benchmark',
        notes: '',
        tags: ['ipc', 'vaccination', 'coverage', 'occupational-health'],
      );

      await repository.addEntry(historyEntry);
    } catch (e) {
      debugPrint('Error saving to history: $e');
    }
  }

  void _saveResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Result saved to history'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showExportModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportModal(
        onExportPDF: () => _exportAsPDF(),
        onExportCSV: () => _exportAsCSV(),
        onExportExcel: () => _exportAsExcel(),
        onExportText: () => _exportAsText(),
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    Navigator.pop(context);
    final vaccineName = _selectedVaccineType == 'Custom'
        ? _customVaccineController.text
        : _selectedVaccineType;

    final inputs = {
      'Vaccine Type': vaccineName,
      'Vaccinated Staff': _vaccinatedStaffController.text,
      'Total Staff at Risk': _totalStaffController.text,
    };

    final results = {
      'Coverage Rate': '${_coverageRate!.toStringAsFixed(1)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Vaccination Coverage %',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);
    final vaccineName = _selectedVaccineType == 'Custom'
        ? _customVaccineController.text
        : _selectedVaccineType;

    final csvContent = '''Calculator,Vaccine Type,Vaccinated Staff,Total Staff at Risk,Coverage Rate,Benchmark,Interpretation
Vaccination Coverage %,$vaccineName,${_vaccinatedStaffController.text},${_totalStaffController.text},${_coverageRate!.toStringAsFixed(1)}%,${_benchmark!},"${_interpretation!.replaceAll('"', '""')}"''';

    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: 'Vaccination_Coverage_${DateTime.now().millisecondsSinceEpoch}',
      csvContent: csvContent,
    );
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);
    final vaccineName = _selectedVaccineType == 'Custom'
        ? _customVaccineController.text
        : _selectedVaccineType;

    final inputs = {
      'Vaccine Type': vaccineName,
      'Vaccinated Staff': _vaccinatedStaffController.text,
      'Total Staff at Risk': _totalStaffController.text,
    };

    final results = {
      'Coverage Rate': '${_coverageRate!.toStringAsFixed(1)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Vaccination Coverage %',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);
    final vaccineName = _selectedVaccineType == 'Custom'
        ? _customVaccineController.text
        : _selectedVaccineType;

    final inputs = {
      'Vaccine Type': vaccineName,
      'Vaccinated Staff': _vaccinatedStaffController.text,
      'Total Staff at Risk': _totalStaffController.text,
    };

    final results = {
      'Coverage Rate': '${_coverageRate!.toStringAsFixed(1)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Vaccination Coverage %',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }
}



