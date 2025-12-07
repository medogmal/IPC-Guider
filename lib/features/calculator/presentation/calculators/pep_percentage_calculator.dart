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

class PEPPercentageCalculator extends ConsumerStatefulWidget {
  const PEPPercentageCalculator({super.key});

  @override
  ConsumerState<PEPPercentageCalculator> createState() => _PEPPercentageCalculatorState();
}

class _PEPPercentageCalculatorState extends ConsumerState<PEPPercentageCalculator> {
  final _pepReceivedController = TextEditingController();
  final _exposedStaffController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedExposureType = 'Bloodborne';
  double? _pepPercentage;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isCalculated = false;

  final List<String> _exposureTypes = [
    'Bloodborne',
    'TB',
    'Measles',
    'Varicella',
    'Rabies',
    'Meningococcal',
    'Other',
  ];

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'The Post-Exposure Prophylaxis (PEP) Percentage measures the proportion of exposed healthcare workers who received appropriate prophylaxis following occupational exposures. This critical metric ensures timely intervention to prevent infection transmission.',
    formula: '(PEP Received × 100) / Exposed Staff',
    example: '18 staff received PEP out of 20 exposed → 90%',
    interpretation: 'Higher percentages indicate effective post-exposure management systems. Rates below 95% suggest barriers to PEP access, delays in reporting, or gaps in exposure management protocols. Target is 100% for all eligible exposures.',
    whenUsed: 'Use this calculator to monitor post-exposure prophylaxis compliance in your facility. Essential for tracking occupational health response effectiveness, identifying barriers to PEP access, and ensuring timely intervention. Calculate monthly or per incident for occupational health surveillance and quality improvement.',
    inputDataType: 'Number of exposed staff who received PEP and total number of exposed staff for the surveillance period. Specify exposure type (bloodborne, TB, measles, etc.) for context-specific PEP timeline evaluation.',
    references: [
      Reference(
        title: 'CDC PEP Guidelines',
        url: 'https://www.cdc.gov/hiv/risk/pep/index.html',
      ),
      Reference(
        title: 'WHO Post-Exposure Prophylaxis',
        url: 'https://www.who.int/teams/integrated-health-services/infection-prevention-control/occupational-health',
      ),
      Reference(
        title: 'OSHA Bloodborne Pathogens Standard',
        url: 'https://www.osha.gov/bloodborne-pathogens',
      ),
      Reference(
        title: 'CDC TB Exposure Guidelines',
        url: 'https://www.cdc.gov/tb/topic/basics/tbinfectioncontrol.htm',
      ),
    ],
  );

  @override
  void dispose() {
    _pepReceivedController.dispose();
    _exposedStaffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('PEP %'),
        elevation: 0,
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
              _buildExposureTypeDropdown(),
              const SizedBox(height: 16),
              _buildInputCard(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_isCalculated) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
                const SizedBox(height: 16),
                _buildPEPProtocolCard(),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emergency, color: AppColors.error, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Post-Exposure Prophylaxis %',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Track PEP compliance for occupational exposures',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
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
                    r'\text{PEP \%} = \frac{\text{PEP Received} \times 100}{\text{Exposed Staff}}',
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

  Widget _buildExposureTypeDropdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exposure Type',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedExposureType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _exposureTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExposureType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input Values',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pepReceivedController,
              decoration: InputDecoration(
                labelText: 'PEP Received',
                hintText: 'Enter number of staff who received PEP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.medication),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of staff who received PEP';
                }
                final number = int.tryParse(value);
                if (number == null || number < 0) {
                  return 'Please enter a valid number';
                }
                final exposed = int.tryParse(_exposedStaffController.text);
                if (exposed != null && number > exposed) {
                  return 'Cannot exceed total exposed staff';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _exposedStaffController,
              decoration: InputDecoration(
                labelText: 'Total Exposed Staff',
                hintText: 'Enter total number of exposed staff',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total exposed staff';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number greater than 0';
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
        onPressed: _calculate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Calculate',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final pepReceived = int.parse(_pepReceivedController.text);
      final exposedStaff = int.parse(_exposedStaffController.text);

      // Calculate percentage
      final percentage = (pepReceived * 100) / exposedStaff;

      setState(() {
        _pepPercentage = percentage;
        _interpretation = _getInterpretation(percentage);
        _benchmark = _getBenchmark(percentage);
        _action = _getAction(percentage);
        _isCalculated = true;
      });

      _saveToHistory();
    }
  }

  String _getInterpretation(double percentage) {
    if (percentage == 100) {
      return 'Excellent PEP compliance. All exposed staff received appropriate prophylaxis, indicating effective post-exposure management system, timely reporting, and accessible PEP services.';
    } else if (percentage >= 95) {
      return 'Good PEP compliance. Most exposed staff received prophylaxis (≥95%), but minor gaps exist. Review cases where PEP was not provided to identify any barriers or contraindications.';
    } else if (percentage >= 80) {
      return 'Moderate PEP compliance. Significant proportion of exposed staff did not receive prophylaxis (80-94%). Investigate barriers to PEP access, delays in reporting, or gaps in exposure management protocols.';
    } else {
      return 'Poor PEP compliance. Majority of exposed staff did not receive appropriate prophylaxis (<80%). Urgent review of post-exposure management system, reporting mechanisms, PEP availability, and staff awareness is essential.';
    }
  }

  String _getBenchmark(double percentage) {
    if (percentage == 100) {
      return '100% (Target Achieved)';
    } else if (percentage >= 95) {
      return '≥95% (Acceptable)';
    } else if (percentage >= 80) {
      return '80-94% (Needs Improvement)';
    } else {
      return '<80% (Urgent Action Required)';
    }
  }

  String _getAction(double percentage) {
    if (percentage == 100) {
      return 'Maintain current post-exposure management practices. Continue staff education on exposure reporting, ensure PEP accessibility 24/7, and regularly review protocols. Recognize and reinforce prompt reporting behaviors.';
    } else if (percentage >= 95) {
      return 'Review cases where PEP was not provided. Assess for valid contraindications, patient refusal, or system barriers. Ensure all staff know how to access PEP services and reinforce importance of timely reporting.';
    } else if (percentage >= 80) {
      return 'Conduct comprehensive review of post-exposure management system. Identify barriers to PEP access (availability, cost, awareness), evaluate reporting mechanisms, enhance staff training, and ensure 24/7 PEP availability.';
    } else {
      return 'Initiate urgent post-exposure management program review. Form multidisciplinary team to investigate root causes, implement immediate corrective actions, enhance reporting systems, ensure PEP stock availability, and conduct intensive staff education campaign.';
    }
  }

  void _loadExample() {
    setState(() {
      _selectedExposureType = 'Bloodborne';
      _pepReceivedController.text = '18';
      _exposedStaffController.text = '20';
    });
  }

  Widget _buildResultsCard() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        _saveResult();
                      },
                      tooltip: 'Save Result',
                      color: AppColors.primary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _showExportModal,
                      tooltip: 'Export',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildResultRow('PEP Percentage', '${_pepPercentage!.toStringAsFixed(1)}%', Icons.percent),
            const SizedBox(height: 12),
            _buildResultRow('Exposure Type', _selectedExposureType, Icons.emergency),
            const SizedBox(height: 12),
            _buildResultRow('PEP Received', _pepReceivedController.text, Icons.medication),
            const SizedBox(height: 12),
            _buildResultRow('Total Exposed', _exposedStaffController.text, Icons.people),
            const SizedBox(height: 12),
            _buildResultRow('Benchmark', _benchmark!, Icons.flag),
            const Divider(height: 32),
            Text(
              'Interpretation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _interpretation!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
            const Divider(height: 32),
            Text(
              'Recommended Action',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _action!,
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

  Widget _buildResultRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPEPProtocolCard() {
    final protocolInfo = _getPEPProtocolInfo(_selectedExposureType);

    return Card(
      color: AppColors.error.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emergency, color: AppColors.error, size: 24),
                const SizedBox(width: 12),
                Text(
                  'PEP Protocol - $_selectedExposureType',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProtocolSection('Timeline', protocolInfo['timeline']!),
            const SizedBox(height: 12),
            _buildProtocolSection('Immediate Actions', protocolInfo['actions']!),
            const SizedBox(height: 12),
            _buildProtocolSection('PEP Regimen', protocolInfo['regimen']!),
            const SizedBox(height: 12),
            _buildProtocolSection('Follow-up', protocolInfo['followup']!),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolSection(String title, String content) {
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
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Map<String, String> _getPEPProtocolInfo(String exposureType) {
    switch (exposureType) {
      case 'Bloodborne':
        return {
          'timeline': '⚠️ URGENT: HIV PEP within 2 hours (ideally), up to 72 hours\n⚠️ HBV PEP within 24 hours\n⚠️ HCV: No PEP available, monitor only',
          'actions': '• Wash wound immediately with soap and water\n• Report to supervisor and occupational health\n• Source patient testing (HIV, HBV, HCV)\n• Baseline testing of exposed worker',
          'regimen': '• HIV: 3-drug regimen for 28 days (e.g., TDF/FTC + RAL)\n• HBV: HBIG + vaccine (if non-immune)\n• HCV: No PEP, monitor ALT and HCV RNA',
          'followup': '• HIV testing at baseline, 6 weeks, 3 months, 6 months\n• HBV: Anti-HBs at 1-2 months post-vaccine\n• HCV: ALT and HCV RNA at 4-6 weeks, 4-6 months',
        };
      case 'TB':
        return {
          'timeline': '⚠️ Initiate within 72 hours of exposure identification\n⚠️ Continue for 3-9 months depending on regimen',
          'actions': '• Document exposure details and duration\n• Baseline TST or IGRA\n• Chest X-ray if symptomatic\n• Assess for active TB disease',
          'regimen': '• Isoniazid (INH) 300mg daily for 9 months, OR\n• Rifampin 600mg daily for 4 months, OR\n• INH + Rifapentine weekly for 3 months',
          'followup': '• Repeat TST/IGRA at 8-10 weeks post-exposure\n• Monitor for TB symptoms monthly\n• Liver function tests if on INH\n• Chest X-ray if symptoms develop',
        };
      case 'Measles':
        return {
          'timeline': '⚠️ MMR vaccine within 72 hours of exposure\n⚠️ Immunoglobulin (IG) within 6 days if contraindicated',
          'actions': '• Verify immunity status (2 MMR doses or positive serology)\n• Administer MMR if non-immune\n• IG 0.5 mL/kg IM if immunocompromised\n• Exclude from work days 5-21 post-exposure if non-immune',
          'regimen': '• MMR vaccine (0.5 mL SC) if non-immune\n• Immunoglobulin (0.5 mL/kg IM, max 15 mL) if contraindicated\n• No PEP if documented immunity',
          'followup': '• Monitor for symptoms days 7-21 post-exposure\n• Serology 4-6 weeks post-vaccine\n• Exclude from patient contact if symptomatic\n• Second MMR dose if only 1 prior dose',
        };
      case 'Varicella':
        return {
          'timeline': '⚠️ Varicella vaccine within 3-5 days of exposure\n⚠️ VZIG within 96 hours (4 days) if high-risk',
          'actions': '• Verify immunity (2 varicella doses, history of disease, or positive serology)\n• Administer vaccine if non-immune\n• VZIG for immunocompromised\n• Exclude from work days 8-21 post-exposure if non-immune',
          'regimen': '• Varicella vaccine (0.5 mL SC) if non-immune\n• VZIG 125 units/10 kg IM (max 625 units) if high-risk\n• No PEP if documented immunity',
          'followup': '• Monitor for symptoms days 10-21 post-exposure\n• Serology 4-6 weeks post-vaccine\n• Exclude from patient contact if symptomatic\n• Second dose 4-8 weeks later if only 1 prior dose',
        };
      case 'Rabies':
        return {
          'timeline': '⚠️ IMMEDIATE: Begin PEP as soon as possible\n⚠️ Do not delay for test results',
          'actions': '• Wash wound thoroughly with soap and water for 15 minutes\n• Report to occupational health immediately\n• Assess animal exposure risk\n• Initiate PEP without delay',
          'regimen': '• Rabies immunoglobulin (RIG) 20 IU/kg infiltrated around wound\n• Rabies vaccine (IM) on days 0, 3, 7, 14\n• If previously vaccinated: vaccine only on days 0, 3',
          'followup': '• Complete full vaccine series\n• No serologic testing needed for PEP\n• Monitor wound healing\n• Report any neurologic symptoms immediately',
        };
      case 'Meningococcal':
        return {
          'timeline': '⚠️ Initiate within 24 hours of exposure\n⚠️ Effective up to 14 days post-exposure',
          'actions': '• Identify close contacts (within 3 feet for >8 hours)\n• Assess exposure risk\n• Initiate chemoprophylaxis promptly\n• Monitor for symptoms for 14 days',
          'regimen': '• Ciprofloxacin 500mg PO single dose, OR\n• Ceftriaxone 250mg IM single dose, OR\n• Azithromycin 500mg PO single dose',
          'followup': '• Monitor for fever, headache, rash for 14 days\n• Seek immediate care if symptoms develop\n• Consider meningococcal vaccine\n• No routine follow-up testing needed',
        };
      default:
        return {
          'timeline': '⚠️ Consult occupational health immediately\n⚠️ Timeline varies by exposure type',
          'actions': '• Document exposure details\n• Report to supervisor and occupational health\n• Assess exposure risk\n• Follow facility-specific protocols',
          'regimen': '• Varies by exposure type\n• Consult infectious disease specialist\n• Follow CDC/WHO guidelines\n• Consider source patient testing',
          'followup': '• Varies by exposure type\n• Follow occupational health recommendations\n• Monitor for symptoms\n• Complete all required testing',
        };
    }
  }

  Widget _buildReferences() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'References',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            ..._knowledgePanelData.references.map((reference) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _launchURL(reference.url),
                    child: Row(
                      children: [
                        Icon(Icons.link, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
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

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'PEP Percentage Calculator',
        inputs: {
          'Exposure Type': _selectedExposureType,
          'PEP Received': _pepReceivedController.text,
          'Total Exposed Staff': _exposedStaffController.text,
        },
        result: 'PEP Percentage: ${_pepPercentage!.toStringAsFixed(1)}%\n'
            'Benchmark: $_benchmark',
        notes: '',
        tags: ['occupational-health', 'pep', 'post-exposure', 'prophylaxis'],
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

  void _saveResult() {
    _saveToHistory();
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

    final inputs = {
      'Exposure Type': _selectedExposureType,
      'PEP Received': _pepReceivedController.text,
      'Total Exposed Staff': _exposedStaffController.text,
    };

    final results = {
      'PEP Percentage': '${_pepPercentage!.toStringAsFixed(1)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'PEP %',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final csvContent = '''Calculator,Exposure Type,PEP Received,Total Exposed,PEP Percentage,Benchmark,Interpretation
PEP %,$_selectedExposureType,${_pepReceivedController.text},${_exposedStaffController.text},${_pepPercentage!.toStringAsFixed(1)}%,${_benchmark!},"${_interpretation!.replaceAll('"', '""')}"''';

    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: 'PEP_Percentage_${DateTime.now().millisecondsSinceEpoch}',
      csvContent: csvContent,
    );
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Exposure Type': _selectedExposureType,
      'PEP Received': _pepReceivedController.text,
      'Total Exposed Staff': _exposedStaffController.text,
    };

    final results = {
      'PEP Percentage': '${_pepPercentage!.toStringAsFixed(1)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'PEP %',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Exposure Type': _selectedExposureType,
      'PEP Received': _pepReceivedController.text,
      'Total Exposed Staff': _exposedStaffController.text,
    };

    final results = {
      'PEP Percentage': '${_pepPercentage!.toStringAsFixed(1)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'PEP %',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }
}


