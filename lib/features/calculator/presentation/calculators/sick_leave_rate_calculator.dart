import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../outbreak/data/models/history_entry.dart';
import '../../../outbreak/data/repositories/history_repository.dart';

class SickLeaveRateCalculator extends ConsumerStatefulWidget {
  const SickLeaveRateCalculator({super.key});

  @override
  ConsumerState<SickLeaveRateCalculator> createState() => _SickLeaveRateCalculatorState();
}

class _SickLeaveRateCalculatorState extends ConsumerState<SickLeaveRateCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _sickDaysController = TextEditingController();
  final _totalWorkingDaysController = TextEditingController();
  
  String _selectedTimePeriod = 'Monthly';
  String _selectedInfectionType = 'All';
  double? _sickLeaveRate;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  bool _isCalculated = false;

  final List<String> _timePeriods = ['Monthly', 'Quarterly', 'Annually'];
  final List<String> _infectionTypes = ['All', 'Respiratory', 'GI', 'COVID-19', 'Influenza'];

  final KnowledgePanelData _knowledgePanelData = KnowledgePanelData(
    definition: 'Sick Leave Rate measures the percentage of working days lost due to infection-related illness among healthcare workers. It reflects the burden of occupational infections, effectiveness of infection prevention measures, and impact on workforce availability.',
    formula: 'Sick Leave Rate (%) = (Sick days due to infection × 100) / Total working days',
    example: 'If 45 sick days due to infection occurred among staff with 2,000 total working days:\nSick Leave Rate = (45 × 100) / 2,000 = 2.25%',
    interpretation: 'Lower rates indicate effective infection prevention, good occupational health practices, and healthy work environment. Higher rates suggest increased infection transmission, inadequate preventive measures, or poor occupational health support. Rates vary by season, outbreak periods, and infection type.',
    whenUsed: 'Used to monitor occupational health burden, evaluate infection prevention effectiveness, identify high-risk periods or departments, justify resource allocation for staff health programs, and assess impact of interventions (e.g., vaccination campaigns, PPE compliance).',
    inputDataType: 'Sick days due to infection (from occupational health records, sick leave documentation), Total working days (sum of all staff working days in the period), Time period (monthly, quarterly, annually), Infection type (respiratory, GI, COVID-19, influenza, all).',
    references: [
      Reference(
        title: 'CDC - Healthcare Personnel Safety',
        url: 'https://www.cdc.gov/healthcare-personnel-safety/',
      ),
      Reference(
        title: 'WHO - Occupational Health for Health Workers',
        url: 'https://www.who.int/occupational_health/topics/hcworkers/en/',
      ),
      Reference(
        title: 'OSHA - Healthcare Worker Safety',
        url: 'https://www.osha.gov/healthcare',
      ),
      Reference(
        title: 'APIC - Occupational Health',
        url: 'https://apic.org/professional-practice/practice-resources/occupational-health/',
      ),
    ],
  );

  @override
  void dispose() {
    _sickDaysController.dispose();
    _totalWorkingDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Sick Leave Rate'),
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
              _buildTimePeriodDropdown(),
              const SizedBox(height: 16),
              _buildInfectionTypeDropdown(),
              const SizedBox(height: 16),
              _buildInputCard(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_isCalculated) ...[
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
    return Card(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.sick, color: AppColors.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sick Leave Rate',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Measures percentage of working days lost due to infection-related illness',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
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
                    fontSize = 11.0;
                  } else if (constraints.maxWidth < 400) {
                    fontSize = 13.0;
                  }

                  return Math.tex(
                    r'\text{Sick Leave Rate (\%)} = \frac{\text{Sick days due to infection} \times 100}{\text{Total working days}}',
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

  Widget _buildTimePeriodDropdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Period',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTimePeriod,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
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

  Widget _buildInfectionTypeDropdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Infection Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedInfectionType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.coronavirus),
              ),
              items: _infectionTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedInfectionType = value!;
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
              controller: _sickDaysController,
              decoration: InputDecoration(
                labelText: 'Sick Days Due to Infection',
                hintText: 'Enter number of sick days',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.sick),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter sick days due to infection';
                }
                final number = int.tryParse(value);
                if (number == null || number < 0) {
                  return 'Please enter a valid number';
                }
                final totalDays = int.tryParse(_totalWorkingDaysController.text);
                if (totalDays != null && number > totalDays) {
                  return 'Cannot exceed total working days';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalWorkingDaysController,
              decoration: InputDecoration(
                labelText: 'Total Working Days',
                hintText: 'Enter total working days',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.work),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total working days';
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
      final sickDays = int.parse(_sickDaysController.text);
      final totalWorkingDays = int.parse(_totalWorkingDaysController.text);

      // Calculate percentage
      final rate = (sickDays * 100) / totalWorkingDays;

      setState(() {
        _sickLeaveRate = rate;
        _interpretation = _getInterpretation(rate);
        _benchmark = _getBenchmark(rate);
        _action = _getAction(rate);
        _isCalculated = true;
      });

      _saveToHistory();
    }
  }

  String _getInterpretation(double rate) {
    if (rate < 2) {
      return 'Excellent sick leave rate (<2%). Indicates effective infection prevention measures, good occupational health practices, healthy work environment, and minimal infection transmission among healthcare workers. This reflects strong preventive programs and staff health support.';
    } else if (rate < 5) {
      return 'Acceptable sick leave rate (2-5%). Within expected range for healthcare settings. Reflects adequate infection prevention practices and occupational health support. Continue monitoring trends and maintain current preventive measures, especially during high-risk seasons.';
    } else if (rate < 10) {
      return 'High sick leave rate (5-10%). Elevated infection-related absenteeism suggests increased transmission, inadequate preventive measures, or seasonal outbreak. Investigate contributing factors, enhance infection control practices, and strengthen occupational health support.';
    } else {
      return 'Very high sick leave rate (>10%). Critical level of infection-related absenteeism indicating significant outbreak, poor infection control, or inadequate occupational health measures. Immediate investigation and intervention required to protect workforce and maintain healthcare services.';
    }
  }

  String _getBenchmark(double rate) {
    if (rate < 2) {
      return '<2% (Excellent)';
    } else if (rate < 5) {
      return '2-5% (Acceptable)';
    } else if (rate < 10) {
      return '5-10% (High)';
    } else {
      return '>10% (Very High)';
    }
  }

  String _getAction(double rate) {
    if (rate < 2) {
      return 'Maintain current infection prevention and occupational health practices. Continue staff vaccination programs, ensure adequate PPE availability, promote hand hygiene, and provide accessible occupational health services. Monitor trends and recognize effective practices.';
    } else if (rate < 5) {
      return 'Continue current practices with enhanced monitoring. Review sick leave patterns by department, infection type, and season. Ensure vaccination coverage is optimal, reinforce infection prevention training, and maintain accessible occupational health services. Prepare for seasonal increases.';
    } else if (rate < 10) {
      return 'Conduct comprehensive review of infection prevention practices. Investigate sick leave patterns, identify high-risk departments or periods, enhance PPE compliance, boost vaccination campaigns, improve ventilation, and strengthen occupational health support. Consider outbreak investigation if sudden increase.';
    } else {
      return 'Initiate urgent outbreak investigation and intervention. Form multidisciplinary team to identify infection sources, implement immediate control measures, enhance surveillance, ensure adequate staffing coverage, provide intensive occupational health support, and communicate transparently with staff. Consider external consultation if needed.';
    }
  }

  void _loadExample() {
    setState(() {
      _selectedTimePeriod = 'Monthly';
      _selectedInfectionType = 'Respiratory';
      _sickDaysController.text = '45';
      _totalWorkingDaysController.text = '2000';
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
            _buildResultRow('Sick Leave Rate', '${_sickLeaveRate!.toStringAsFixed(2)}%', Icons.percent),
            const SizedBox(height: 12),
            _buildResultRow('Time Period', _selectedTimePeriod, Icons.calendar_today),
            const SizedBox(height: 12),
            _buildResultRow('Infection Type', _selectedInfectionType, Icons.coronavirus),
            const SizedBox(height: 12),
            _buildResultRow('Sick Days', _sickDaysController.text, Icons.sick),
            const SizedBox(height: 12),
            _buildResultRow('Total Working Days', _totalWorkingDaysController.text, Icons.work),
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
        calculatorName: 'Sick Leave Rate Calculator',
        inputs: {
          'Time Period': _selectedTimePeriod,
          'Infection Type': _selectedInfectionType,
          'Sick Days': _sickDaysController.text,
          'Total Working Days': _totalWorkingDaysController.text,
        },
        result: 'Sick Leave Rate: ${_sickLeaveRate!.toStringAsFixed(2)}%\n'
            'Benchmark: $_benchmark',
        notes: '',
        tags: ['occupational-health', 'sick-leave', 'workforce', 'infection-control'],
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
      'Time Period': _selectedTimePeriod,
      'Infection Type': _selectedInfectionType,
      'Sick Days': _sickDaysController.text,
      'Total Working Days': _totalWorkingDaysController.text,
    };

    final results = {
      'Sick Leave Rate': '${_sickLeaveRate!.toStringAsFixed(2)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Sick Leave Rate',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final csvContent = '''Calculator,Time Period,Infection Type,Sick Days,Total Working Days,Sick Leave Rate,Benchmark,Interpretation
Sick Leave Rate,$_selectedTimePeriod,$_selectedInfectionType,${_sickDaysController.text},${_totalWorkingDaysController.text},${_sickLeaveRate!.toStringAsFixed(2)}%,${_benchmark!},"${_interpretation!.replaceAll('"', '""')}"''';

    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: 'Sick_Leave_Rate_${DateTime.now().millisecondsSinceEpoch}',
      csvContent: csvContent,
    );
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Time Period': _selectedTimePeriod,
      'Infection Type': _selectedInfectionType,
      'Sick Days': _sickDaysController.text,
      'Total Working Days': _totalWorkingDaysController.text,
    };

    final results = {
      'Sick Leave Rate': '${_sickLeaveRate!.toStringAsFixed(2)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Sick Leave Rate',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Time Period': _selectedTimePeriod,
      'Infection Type': _selectedInfectionType,
      'Sick Days': _sickDaysController.text,
      'Total Working Days': _totalWorkingDaysController.text,
    };

    final results = {
      'Sick Leave Rate': '${_sickLeaveRate!.toStringAsFixed(2)}%',
      'Benchmark': _benchmark!,
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Sick Leave Rate',
      inputs: inputs,
      results: results,
      interpretation: _interpretation,
    );
  }
}


