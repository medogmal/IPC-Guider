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

class EnvironmentalPositivityRateCalculator extends ConsumerStatefulWidget {
  const EnvironmentalPositivityRateCalculator({super.key});

  @override
  ConsumerState<EnvironmentalPositivityRateCalculator> createState() => _EnvironmentalPositivityRateCalculatorState();
}

class _EnvironmentalPositivityRateCalculatorState extends ConsumerState<EnvironmentalPositivityRateCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _positiveSamplesController = TextEditingController();
  final _totalSamplesController = TextEditingController();

  String _selectedSampleType = 'All';
  String _selectedLocation = 'All';
  String _selectedTimePeriod = 'Monthly';
  double? _positivityRate;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isCalculated = false;

  final List<String> _sampleTypes = ['All', 'Air', 'Surface', 'Water'];
  final List<String> _locations = ['All', 'OR', 'ICU', 'General Ward', 'Dialysis Unit', 'Construction Area'];
  final List<String> _timePeriods = ['Weekly', 'Monthly', 'Quarterly'];

  final KnowledgePanelData _knowledgePanelData = KnowledgePanelData(
    definition: 'Environmental Positivity Rate measures the percentage of environmental samples (air, surface, water) that test positive for microbial contamination. This indicator monitors the microbial quality of the healthcare environment and identifies potential reservoirs of healthcare-associated pathogens.',
    formula: 'Environmental Positivity Rate (%) = (Positive Environmental Samples × 100) / Total Samples',
    example: 'If 8 out of 150 environmental samples tested positive for contamination:\nEnvironmental Positivity Rate = (8 × 100) / 150 = 5.33%',
    interpretation: 'Lower rates indicate effective environmental controls and cleaning practices. Higher rates suggest environmental contamination requiring investigation and intervention. Interpretation varies by sample type (air vs. surface vs. water), location (OR vs. general ward), and organism type. Results represent single points in time and must be compared to baseline values.',
    whenUsed: 'Used during outbreak investigations when environmental reservoirs are suspected, to validate effectiveness of environmental controls (HVAC, water systems), to monitor construction-related contamination, to assess cleaning/disinfection effectiveness, and to protect immunocompromised patients from environmental pathogens (e.g., Aspergillus surveillance).',
    inputDataType: 'Positive environmental samples (number of samples with microbial growth above threshold), Total samples (all environmental samples collected), Sample type (air, surface, water), Location (OR, ICU, general ward, dialysis unit, construction area), Time period (weekly, monthly, quarterly). Note: Environmental sampling is NOT routine surveillance - only for outbreak investigation, research, hazard monitoring, or quality assurance.',
    references: [
      Reference(
        title: 'CDC - Guidelines for Environmental Infection Control',
        url: 'https://www.cdc.gov/infection-control/hcp/environmental-control/index.html',
      ),
      Reference(
        title: 'CDC - Environmental Sampling',
        url: 'https://www.cdc.gov/infection-control/hcp/environmental-control/environmental-sampling.html',
      ),
      Reference(
        title: 'WHO - Guidelines on Core Components of IPC Programmes',
        url: 'https://www.who.int/publications/i/item/9789241549929',
      ),
      Reference(
        title: 'APIC - Environmental Infection Control',
        url: 'https://apic.org/professional-practice/practice-resources/environmental-infection-control/',
      ),
    ],
  );

  @override
  void dispose() {
    _positiveSamplesController.dispose();
    _totalSamplesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Environmental Positivity Rate'),
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
              _buildSampleTypeDropdown(),
              const SizedBox(height: 16),
              _buildLocationDropdown(),
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
                _buildEnvironmentalMonitoringCard(),
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
                    Icons.science_outlined,
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
                        'Environmental Positivity Rate',
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
              'Monitors microbial contamination in environmental samples (air, surface, water) to identify potential reservoirs of healthcare-associated pathogens.',
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
                    fontSize = 10.0;
                  } else if (constraints.maxWidth < 400) {
                    fontSize = 13.0;
                  }

                  return Math.tex(
                    r'\text{Environmental Positivity Rate } \% = \frac{\text{Positive Environmental Samples} \times 100}{\text{Total Samples}}',
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

  Widget _buildSampleTypeDropdown() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sample Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSampleType,
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
              items: _sampleTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSampleType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
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
              items: _locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value!;
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
              controller: _positiveSamplesController,
              decoration: InputDecoration(
                labelText: 'Positive Environmental Samples',
                hintText: 'Enter number of positive samples',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.add_circle_outline),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter positive samples';
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
              controller: _totalSamplesController,
              decoration: InputDecoration(
                labelText: 'Total Samples',
                hintText: 'Enter total number of samples',
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
                  return 'Please enter total samples';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number greater than 0';
                }
                final positiveSamples = int.tryParse(_positiveSamplesController.text) ?? 0;
                if (number < positiveSamples) {
                  return 'Total samples must be ≥ positive samples';
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
      final positiveSamples = int.parse(_positiveSamplesController.text);
      final totalSamples = int.parse(_totalSamplesController.text);

      final rate = (positiveSamples * 100) / totalSamples;

      setState(() {
        _positivityRate = rate;
        _interpretation = _getInterpretation(rate);
        _benchmark = _getBenchmark(rate);
        _action = _getAction(rate);
        _isCalculated = true;
      });

      _saveToHistory();
    }
  }

  String _getInterpretation(double rate) {
    if (rate < 5) {
      return 'Excellent environmental quality. Minimal microbial contamination detected. Current environmental controls and cleaning practices are highly effective.';
    } else if (rate < 10) {
      return 'Acceptable environmental quality. Expected baseline contamination levels. Continue current monitoring and cleaning protocols.';
    } else if (rate < 20) {
      return 'High environmental contamination. Requires investigation and intervention. Review cleaning protocols, environmental controls, and potential sources of contamination.';
    } else {
      return 'Very high environmental contamination. Urgent action required. Potential outbreak or environmental reservoir. Immediate investigation, enhanced cleaning, and infection control measures needed.';
    }
  }

  String _getBenchmark(double rate) {
    if (rate < 5) {
      return 'Excellent (<5%)';
    } else if (rate < 10) {
      return 'Acceptable (5-10%)';
    } else if (rate < 20) {
      return 'High (10-20%)';
    } else {
      return 'Very High (>20%)';
    }
  }

  String _getAction(double rate) {
    if (rate < 5) {
      return 'Continue current environmental monitoring and cleaning protocols. Maintain baseline surveillance. Document results for trend analysis.';
    } else if (rate < 10) {
      return 'Continue routine monitoring. Review cleaning protocols for consistency. Compare results with baseline values and previous periods. Investigate any upward trends.';
    } else if (rate < 20) {
      return 'Investigate sources of contamination. Review and enhance cleaning protocols. Increase monitoring frequency. Assess environmental controls (HVAC, water systems). Consider molecular typing if outbreak suspected. Implement corrective actions and re-sample.';
    } else {
      return 'URGENT: Initiate outbreak investigation. Implement enhanced environmental cleaning and disinfection. Increase monitoring frequency. Assess patient exposure risk. Review environmental controls and maintenance. Consider temporary area closure if high-risk patients affected. Molecular epidemiology to link environmental and clinical isolates. Consult infection control team immediately.';
    }
  }

  Widget _buildResultsCard() {
    Color resultColor;
    IconData resultIcon;

    if (_positivityRate! < 5) {
      resultColor = AppColors.success;
      resultIcon = Icons.check_circle;
    } else if (_positivityRate! < 10) {
      resultColor = AppColors.info;
      resultIcon = Icons.info;
    } else if (_positivityRate! < 20) {
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
                      '${_positivityRate!.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Environmental Positivity Rate',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildResultRow('Sample Type', _selectedSampleType),
            _buildResultRow('Location', _selectedLocation),
            _buildResultRow('Time Period', _selectedTimePeriod),
            _buildResultRow('Positive Samples', _positiveSamplesController.text),
            _buildResultRow('Total Samples', _totalSamplesController.text),
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

  Widget _buildEnvironmentalMonitoringCard() {
    return Card(
      color: AppColors.info.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.info.withValues(alpha: 0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Environmental Monitoring Guidelines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGuidelineSection(
              'When to Perform Environmental Sampling',
              [
                'Outbreak investigation when environmental reservoirs are suspected',
                'Research purposes (well-designed studies)',
                'Monitoring potentially hazardous conditions (construction, water systems)',
                'Quality assurance to evaluate infection control practice changes',
              ],
            ),
            const SizedBox(height: 12),
            _buildGuidelineSection(
              'Sample Types & Methods',
              [
                'Air: Impingement, impaction, sedimentation (settle plates) - CFU/m³',
                'Surface: Swabs, sponges, wipes, RODAC plates - CFU/area',
                'Water: Cold samples (4°C), tested within 24 hours - CFU/mL',
              ],
            ),
            const SizedBox(height: 12),
            _buildGuidelineSection(
              'Important Considerations',
              [
                'NOT routine surveillance - only for specific indications',
                'Results represent single points in time',
                'Compare with baseline values and control samples',
                'Link environmental isolates to clinical isolates via molecular typing',
                'Must have defined protocol and action plan before sampling',
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Note: Environmental sampling is expensive and time-consuming. Ensure clear objectives and interpretation criteria before initiating surveillance.',
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
        ),
      ),
    );
  }

  Widget _buildGuidelineSection(String title, List<String> items) {
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
      _positiveSamplesController.text = '8';
      _totalSamplesController.text = '150';
      _selectedSampleType = 'Surface';
      _selectedLocation = 'ICU';
      _selectedTimePeriod = 'Monthly';
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
        calculatorName: 'Environmental Positivity Rate',
        inputs: {
          'Positive Samples': _positiveSamplesController.text,
          'Total Samples': _totalSamplesController.text,
          'Sample Type': _selectedSampleType,
          'Location': _selectedLocation,
          'Time Period': _selectedTimePeriod,
        },
        result: 'Positivity Rate: ${_positivityRate!.toStringAsFixed(2)}%\n'
            'Benchmark: $_benchmark',
        notes: '',
        tags: ['environmental-health', 'positivity-rate', 'surveillance', 'cssd'],
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
      'Sample Type': _selectedSampleType,
      'Location': _selectedLocation,
      'Time Period': _selectedTimePeriod,
      'Positive Samples': _positiveSamplesController.text,
      'Total Samples': _totalSamplesController.text,
    };

    final results = {
      'Environmental Positivity Rate': '${_positivityRate!.toStringAsFixed(2)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Environmental Positivity Rate',
      inputs: inputs,
      results: results,
      interpretation: _interpretation!,
    );
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final csvContent = '''Calculator,Sample Type,Location,Time Period,Positive Samples,Total Samples,Positivity Rate (%),Benchmark,Interpretation
Environmental Positivity Rate,$_selectedSampleType,$_selectedLocation,$_selectedTimePeriod,${_positiveSamplesController.text},${_totalSamplesController.text},${_positivityRate!.toStringAsFixed(2)},$_benchmark,"$_interpretation"''';

    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: 'Environmental_Positivity_Rate_${DateTime.now().millisecondsSinceEpoch}',
      csvContent: csvContent,
    );
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Sample Type': _selectedSampleType,
      'Location': _selectedLocation,
      'Time Period': _selectedTimePeriod,
      'Positive Samples': _positiveSamplesController.text,
      'Total Samples': _totalSamplesController.text,
    };

    final results = {
      'Environmental Positivity Rate': '${_positivityRate!.toStringAsFixed(2)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Environmental Positivity Rate',
      inputs: inputs,
      results: results,
      interpretation: _interpretation!,
    );
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Sample Type': _selectedSampleType,
      'Location': _selectedLocation,
      'Time Period': _selectedTimePeriod,
      'Positive Samples': _positiveSamplesController.text,
      'Total Samples': _totalSamplesController.text,
    };

    final results = {
      'Environmental Positivity Rate': '${_positivityRate!.toStringAsFixed(2)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Environmental Positivity Rate',
      inputs: inputs,
      results: results,
      interpretation: _interpretation!,
    );
  }
}

