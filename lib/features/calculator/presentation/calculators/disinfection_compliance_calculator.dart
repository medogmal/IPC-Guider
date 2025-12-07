import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../outbreak/data/models/history_entry.dart';
import '../../../outbreak/data/repositories/history_repository.dart';

class DisinfectionComplianceCalculator extends ConsumerStatefulWidget {
  const DisinfectionComplianceCalculator({super.key});

  @override
  ConsumerState<DisinfectionComplianceCalculator> createState() => _DisinfectionComplianceCalculatorState();
}

class _DisinfectionComplianceCalculatorState extends ConsumerState<DisinfectionComplianceCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _areasPassedController = TextEditingController();
  final _totalAreasController = TextEditingController();

  String _selectedAuditMethod = 'Visual';
  String _selectedAreaType = 'All';
  String _selectedTimePeriod = 'Weekly';
  double? _complianceRate;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isCalculated = false;

  final List<String> _auditMethods = ['Visual', 'ATP', 'Fluorescent Marker', 'Microbial Culture', 'Checklist'];
  final List<String> _areaTypes = ['All', 'OR', 'ICU', 'Patient Room', 'Bathroom'];
  final List<String> _timePeriods = ['Weekly', 'Monthly', 'Quarterly'];

  final KnowledgePanelData _knowledgePanelData = KnowledgePanelData(
    definition: 'Disinfection Compliance measures the percentage of audited areas that pass environmental cleaning and disinfection standards. This indicator monitors adherence to cleaning protocols and effectiveness of environmental hygiene programs, which are critical for preventing transmission of healthcare-associated pathogens.',
    formula: 'Disinfection Compliance (%) = (Areas Passed Audit × 100) / Total Audited Areas',
    example: 'If 142 out of 150 audited patient rooms passed cleaning standards:\nDisinfection Compliance = (142 × 100) / 150 = 94.67%',
    interpretation: 'Higher compliance rates indicate effective cleaning practices, proper staff training, and adequate resources. Lower rates suggest gaps in cleaning protocols, inadequate training, insufficient resources, or poor accountability. Compliance varies by audit method (visual vs. ATP vs. culture), area type (OR vs. general ward), and cleaning frequency.',
    whenUsed: 'Used to monitor environmental cleaning effectiveness, validate staff training and competency, identify gaps in cleaning protocols, support outbreak prevention and control, demonstrate regulatory compliance (Joint Commission, CMS), and reduce environmental transmission of pathogens (MRSA, VRE, C. difficile, Acinetobacter).',
    inputDataType: 'Areas passed audit (number of areas meeting cleaning standards), Total audited areas (all areas inspected), Audit method (visual inspection, ATP bioluminescence, fluorescent marker, microbial culture, checklist), Area type (OR, ICU, patient room, bathroom), Time period (weekly, monthly, quarterly). Audit criteria: high-touch surfaces, proper disinfectant use, contact time, cleaning technique.',
    references: [
      Reference(
        title: 'CDC - Best Practices for Environmental Cleaning',
        url: 'https://www.cdc.gov/healthcare-associated-infections/media/pdfs/environmental-cleaning-rls-508.pdf',
      ),
      Reference(
        title: 'CDC - Environmental Cleaning Procedures',
        url: 'https://www.cdc.gov/healthcare-associated-infections/hcp/cleaning-global/procedures.html',
      ),
      Reference(
        title: 'WHO - Guidelines on Core Components of IPC Programmes',
        url: 'https://www.who.int/publications/i/item/9789241549929',
      ),
      Reference(
        title: 'APIC - Environmental Cleaning and Disinfection',
        url: 'https://apic.org/professional-practice/practice-resources/environmental-infection-control/',
      ),
    ],
  );

  @override
  void dispose() {
    _areasPassedController.dispose();
    _totalAreasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Disinfection Compliance %'),
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
              _buildAuditMethodDropdown(),
              const SizedBox(height: 16),
              _buildAreaTypeDropdown(),
              const SizedBox(height: 16),
              _buildTimePeriodDropdown(),
              const SizedBox(height: 16),
              _buildInputCard(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_isCalculated) ...[
                const SizedBox(height: 24),
                _buildResultsCard(),
                const SizedBox(height: 16),
                _buildCleaningComplianceCard(),
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
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.cleaning_services,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disinfection Compliance %',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Environmental & Equipment Surveillance',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Monitors adherence to environmental cleaning and disinfection standards through systematic audits of healthcare areas.',
              style: TextStyle(
                fontSize: 14,
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
                    r'\text{Disinfection Compliance } \% = \frac{\text{Areas Passed Audit} \times 100}{\text{Total Audited Areas}}',
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

  Widget _buildAuditMethodDropdown() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit Method',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedAuditMethod,
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
              items: _auditMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAuditMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaTypeDropdown() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Area Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedAreaType,
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
              items: _areaTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAreaType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodDropdown() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Period',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTimePeriod,
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
              items: _timePeriods.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimePeriod = value!;
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
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _areasPassedController,
              decoration: InputDecoration(
                labelText: 'Areas Passed Audit',
                hintText: 'Enter number of areas that passed',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.check_circle_outline),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter areas passed';
                }
                final number = int.tryParse(value);
                if (number == null || number < 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalAreasController,
              decoration: InputDecoration(
                labelText: 'Total Audited Areas',
                hintText: 'Enter total number of areas audited',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total areas';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number greater than 0';
                }
                final areasPassed = int.tryParse(_areasPassedController.text) ?? 0;
                if (number < areasPassed) {
                  return 'Total areas must be ≥ areas passed';
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final areasPassed = int.parse(_areasPassedController.text);
      final totalAreas = int.parse(_totalAreasController.text);

      final rate = (areasPassed * 100) / totalAreas;

      setState(() {
        _complianceRate = rate;
        _interpretation = _getInterpretation(rate);
        _benchmark = _getBenchmark(rate);
        _action = _getAction(rate);
        _isCalculated = true;
      });

      _saveToHistory();
    }
  }

  String _getInterpretation(double rate) {
    if (rate >= 95) {
      return 'Excellent environmental cleaning compliance. Gold standard achieved. Current cleaning practices, staff training, and accountability systems are highly effective. Continue monitoring to maintain this level.';
    } else if (rate >= 90) {
      return 'Acceptable environmental cleaning compliance. Meets minimum standards. Minor gaps may exist in cleaning protocols or execution. Continue routine monitoring and address any identified deficiencies.';
    } else if (rate >= 80) {
      return 'Environmental cleaning compliance needs improvement. Significant gaps exist in cleaning practices, staff training, or resources. Requires intervention to prevent potential pathogen transmission.';
    } else {
      return 'Unacceptable environmental cleaning compliance. Critical deficiencies in cleaning program. High risk of environmental pathogen transmission. Urgent comprehensive intervention required.';
    }
  }

  String _getBenchmark(double rate) {
    if (rate >= 95) {
      return 'Excellent (≥95%)';
    } else if (rate >= 90) {
      return 'Acceptable (90-94%)';
    } else if (rate >= 80) {
      return 'Needs Improvement (80-89%)';
    } else {
      return 'Unacceptable (<80%)';
    }
  }

  String _getAction(double rate) {
    if (rate >= 95) {
      return 'Continue current cleaning protocols and monitoring frequency. Recognize and reward cleaning staff performance. Document best practices for replication. Maintain staff training programs. Use as benchmark for other areas.';
    } else if (rate >= 90) {
      return 'Review audit findings to identify specific deficiencies. Provide targeted retraining for cleaning staff. Ensure adequate cleaning supplies and equipment. Increase monitoring frequency for areas with failures. Implement corrective action plans.';
    } else if (rate >= 80) {
      return 'Conduct comprehensive review of cleaning protocols and practices. Assess staff competency and provide intensive retraining. Evaluate adequacy of resources (staff, time, supplies). Implement direct observation and feedback. Increase audit frequency. Consider supervisory changes if needed. Address systemic barriers to compliance.';
    } else {
      return 'URGENT: Initiate immediate intervention. Suspend routine operations if high-risk areas affected. Conduct root cause analysis of cleaning program failures. Implement emergency cleaning protocols. Provide intensive staff retraining with competency verification. Assess and address resource deficiencies. Implement daily audits with immediate feedback. Consider environmental cultures if outbreak suspected. Engage leadership for systemic changes. Develop comprehensive improvement plan with measurable goals.';
    }
  }



  Widget _buildResultsCard() {
    Color resultColor;
    IconData resultIcon;

    if (_complianceRate! >= 95) {
      resultColor = AppColors.success;
      resultIcon = Icons.check_circle;
    } else if (_complianceRate! >= 90) {
      resultColor = AppColors.info;
      resultIcon = Icons.info;
    } else if (_complianceRate! >= 80) {
      resultColor = AppColors.warning;
      resultIcon = Icons.warning;
    } else {
      resultColor = AppColors.error;
      resultIcon = Icons.error;
    }

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _showExportModal,
                  tooltip: 'Export Results',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: resultColor.withValues(alpha: 0.3), width: 2),
              ),
              child: Column(
                children: [
                  Icon(resultIcon, color: resultColor, size: 48),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_complianceRate!.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Disinfection Compliance',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildResultRow('Audit Method', _selectedAuditMethod),
            _buildResultRow('Area Type', _selectedAreaType),
            _buildResultRow('Time Period', _selectedTimePeriod),
            _buildResultRow('Areas Passed', _areasPassedController.text),
            _buildResultRow('Total Areas', _totalAreasController.text),
            _buildResultRow('Benchmark', _benchmark!),
            const SizedBox(height: 16),
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
                      Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Interpretation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _interpretation!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: resultColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.recommend, color: resultColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Recommended Actions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _action!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleaningComplianceCard() {
    Color cardColor;
    if (_complianceRate! >= 95) {
      cardColor = AppColors.success;
    } else if (_complianceRate! >= 90) {
      cardColor = AppColors.info;
    } else {
      cardColor = AppColors.warning;
    }

    return Card(
      color: cardColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, color: cardColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Cleaning Compliance Standards',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildComplianceSection(
              'High-Touch Surfaces Checklist',
              [
                'Bed rails and controls',
                'Call buttons and nurse call systems',
                'Door handles and light switches',
                'Bedside tables and overbed tables',
                'IV poles and medical equipment',
                'Bathroom fixtures (toilets, sinks, faucets)',
                'Keyboards, phones, and monitors',
              ],
            ),
            const SizedBox(height: 12),
            _buildComplianceSection(
              'Proper Disinfectant Selection',
              [
                'EPA-registered hospital-grade disinfectants',
                'Appropriate for target pathogens (MRSA, VRE, C. difficile)',
                'Compatible with surface materials',
                'Follow manufacturer dilution instructions',
                'Check expiration dates',
              ],
            ),
            const SizedBox(height: 12),
            _buildComplianceSection(
              'Contact Time Requirements',
              [
                'Allow adequate wet contact time (typically 1-10 minutes)',
                'Do not wipe dry before contact time complete',
                'Reapply if surface dries before contact time',
                'Follow product-specific instructions',
              ],
            ),
            const SizedBox(height: 12),
            _buildComplianceSection(
              'Cleaning Technique',
              [
                'Clean from clean to dirty areas',
                'Use one-directional wiping motion',
                'Change cleaning cloths frequently',
                'Clean high-touch surfaces first',
                'Ensure complete surface coverage',
              ],
            ),
            if (_complianceRate! < 90) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Corrective Actions Required: Compliance below acceptable threshold. Implement immediate retraining, increase audit frequency, and address identified deficiencies.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildReferences() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books, color: AppColors.primary, size: 20),
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
              child: InkWell(
                onTap: () => _launchURL(reference.url),
                child: Text(
                  reference.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            )),
          ],
        ),
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
      _areasPassedController.text = '142';
      _totalAreasController.text = '150';
      _selectedAuditMethod = 'ATP';
      _selectedAreaType = 'Patient Room';
      _selectedTimePeriod = 'Weekly';
      _isCalculated = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example data loaded'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
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
        calculatorName: 'Disinfection Compliance %',
        inputs: {
          'Areas Passed': _areasPassedController.text,
          'Total Areas': _totalAreasController.text,
          'Audit Method': _selectedAuditMethod,
          'Area Type': _selectedAreaType,
          'Time Period': _selectedTimePeriod,
        },
        result: 'Compliance Rate: ${_complianceRate!.toStringAsFixed(2)}%\n'
            'Benchmark: $_benchmark',
        notes: '',
        tags: ['environmental-health', 'disinfection', 'compliance', 'cssd'],
      );

      await repository.addEntry(historyEntry);
    } catch (e) {
      debugPrint('Error saving to history: $e');
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
      'Audit Method': _selectedAuditMethod,
      'Area Type': _selectedAreaType,
      'Time Period': _selectedTimePeriod,
      'Areas Passed': _areasPassedController.text,
      'Total Areas': _totalAreasController.text,
    };

    final results = {
      'Disinfection Compliance': '${_complianceRate!.toStringAsFixed(2)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Disinfection Compliance %',
      inputs: inputs,
      results: results,
      interpretation: _interpretation!,
    );
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final csvContent = '''Calculator,Audit Method,Area Type,Time Period,Areas Passed,Total Areas,Compliance (%),Benchmark,Interpretation
Disinfection Compliance,$_selectedAuditMethod,$_selectedAreaType,$_selectedTimePeriod,${_areasPassedController.text},${_totalAreasController.text},${_complianceRate!.toStringAsFixed(2)},$_benchmark,"$_interpretation"''';

    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: 'Disinfection_Compliance_${DateTime.now().millisecondsSinceEpoch}',
      csvContent: csvContent,
    );
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Audit Method': _selectedAuditMethod,
      'Area Type': _selectedAreaType,
      'Time Period': _selectedTimePeriod,
      'Areas Passed': _areasPassedController.text,
      'Total Areas': _totalAreasController.text,
    };

    final results = {
      'Disinfection Compliance': '${_complianceRate!.toStringAsFixed(2)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Disinfection Compliance %',
      inputs: inputs,
      results: results,
      interpretation: _interpretation!,
    );
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Audit Method': _selectedAuditMethod,
      'Area Type': _selectedAreaType,
      'Time Period': _selectedTimePeriod,
      'Areas Passed': _areasPassedController.text,
      'Total Areas': _totalAreasController.text,
    };

    final results = {
      'Disinfection Compliance': '${_complianceRate!.toStringAsFixed(2)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Disinfection Compliance %',
      inputs: inputs,
      results: results,
      interpretation: _interpretation!,
    );
  }
}


