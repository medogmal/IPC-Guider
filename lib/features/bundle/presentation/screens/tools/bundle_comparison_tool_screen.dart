import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/widgets/back_button.dart';
import '../../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../../features/outbreak/data/repositories/history_repository.dart';
import '../../../../../features/outbreak/data/models/history_entry.dart';
import '../../../data/models/bundle_comparison_data.dart';

class BundleComparisonToolScreen extends StatefulWidget {
  const BundleComparisonToolScreen({super.key});

  @override
  State<BundleComparisonToolScreen> createState() => _BundleComparisonToolScreenState();
}

class _BundleComparisonToolScreenState extends State<BundleComparisonToolScreen> {
  final _formKey = GlobalKey<FormState>();

  // Comparison settings
  String _comparisonType = 'bundles'; // 'bundles', 'units', 'time-periods'
  final List<String> _selectedItems = [];

  // Available options
  final List<String> _availableBundles = [
    'CLABSI',
    'CAUTI',
    'VAP',
    'SSI',
    'Sepsis',
    'Hand Hygiene',
    'Contact Precautions',
    'Droplet Precautions',
    'Airborne Precautions',
    'MDRO',
  ];
  final List<String> _availableUnits = ['ICU', 'Medical Ward', 'Surgical Ward', 'Emergency', 'Pediatrics', 'NICU'];

  // Dynamic year for time periods
  final TextEditingController _yearController = TextEditingController(text: DateTime.now().year.toString());
  List<String> _availablePeriods = [];

  // Input data for each selected item
  final Map<String, TextEditingController> _totalAuditsControllers = {};
  final Map<String, TextEditingController> _compliantAuditsControllers = {};
  final Map<String, String?> _trendSelections = {};

  // Results
  BundleComparisonData? _comparisonResult;

  @override
  void initState() {
    super.initState();
    _generatePeriods();
    _yearController.addListener(_generatePeriods);
  }

  void _generatePeriods() {
    final year = int.tryParse(_yearController.text) ?? DateTime.now().year;
    setState(() {
      _availablePeriods = [
        'Q1 $year',
        'Q2 $year',
        'Q3 $year',
        'Q4 $year',
        'Jan $year',
        'Feb $year',
        'Mar $year',
        'Apr $year',
        'May $year',
        'Jun $year',
        'Jul $year',
        'Aug $year',
        'Sep $year',
        'Oct $year',
        'Nov $year',
        'Dec $year',
      ];
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _yearController.dispose();
    for (var controller in _totalAuditsControllers.values) {
      controller.dispose();
    }
    for (var controller in _compliantAuditsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemSelectionChanged(String item, bool selected) {
    setState(() {
      if (selected) {
        _selectedItems.add(item);
        // Create controllers for this item
        _totalAuditsControllers[item] = TextEditingController();
        _compliantAuditsControllers[item] = TextEditingController();
        _trendSelections[item] = null;
      } else {
        _selectedItems.remove(item);
        // Dispose and remove controllers
        _totalAuditsControllers[item]?.dispose();
        _compliantAuditsControllers[item]?.dispose();
        _totalAuditsControllers.remove(item);
        _compliantAuditsControllers.remove(item);
        _trendSelections.remove(item);
      }
      _comparisonResult = null; // Clear results when selection changes
    });
  }

  void _runComparison() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedItems.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 2 items to compare'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Build datasets from user input
    final datasets = <ComparisonDataset>[];
    for (final item in _selectedItems) {
      final totalAudits = int.tryParse(_totalAuditsControllers[item]?.text ?? '0') ?? 0;
      final compliantAudits = int.tryParse(_compliantAuditsControllers[item]?.text ?? '0') ?? 0;

      final inputData = ComparisonInputData(
        name: item,
        totalAudits: totalAudits,
        compliantAudits: compliantAudits,
        trend: _trendSelections[item],
      );

      datasets.add(inputData.toDataset(_comparisonType));
    }

    setState(() {
      _comparisonResult = BundleComparisonData.fromUserInput(
        comparisonType: _comparisonType,
        datasets: datasets,
      );
    });

    // Scroll to results
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _saveToHistory() async {
    if (_comparisonResult == null) return;

    try {
      final entry = HistoryEntry.fromCalculator(
        calculatorName: 'Bundle Comparison Tool',
        inputs: {
          'Comparison Type': _comparisonType,
          'Datasets': _comparisonResult!.datasets.map((d) => d.name).join(', '),
          'Comparison Date': DateFormat('yyyy-MM-dd').format(_comparisonResult!.comparisonDate),
        },
        result: 'Average: ${_comparisonResult!.summary.averageCompliance.toStringAsFixed(1)}%, '
            'Best: ${_comparisonResult!.summary.bestPerformer} (${_comparisonResult!.summary.bestPerformerScore.toStringAsFixed(1)}%)',
      );

      await HistoryRepository().addEntry(entry);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Saved to history'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving to history: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showExportModal() {
    if (_comparisonResult == null) return;

    ExportModal.show(
      context: context,
      onExportPDF: () => _exportAs('pdf'),
      onExportExcel: () => _exportAs('excel'),
      onExportCSV: () => _exportAs('csv'),
      onExportText: () => _exportAs('text'),
      enablePhoto: false,
    );
  }

  Future<void> _exportAs(String format) async {
    Navigator.pop(context); // Close modal first
    
    if (_comparisonResult == null) return;

    try {
      final inputs = {
        'Comparison Type': _comparisonType,
        'Datasets': _comparisonResult!.datasets.map((d) => d.name).join(', '),
        'Comparison Date': DateFormat('yyyy-MM-dd').format(_comparisonResult!.comparisonDate),
      };

      final results = {
        'Average Compliance': '${_comparisonResult!.summary.averageCompliance.toStringAsFixed(1)}%',
        'Best Performer': '${_comparisonResult!.summary.bestPerformer} (${_comparisonResult!.summary.bestPerformerScore.toStringAsFixed(1)}%)',
        'Needs Improvement': '${_comparisonResult!.summary.worstPerformer} (${_comparisonResult!.summary.worstPerformerScore.toStringAsFixed(1)}%)',
        'Compliance Range': '${_comparisonResult!.summary.complianceRange.toStringAsFixed(1)}%',
        'Total Audits': '${_comparisonResult!.summary.totalAudits}',
      };

      // Convert insights and recommendations to strings
      final insightsText = _comparisonResult!.insights.isNotEmpty
          ? _comparisonResult!.insights.map((i) => '• $i').join('\n')
          : null;
      
      final recommendationsText = _comparisonResult!.recommendations.isNotEmpty
          ? _comparisonResult!.recommendations.map((r) => '• $r').join('\n')
          : null;

      switch (format) {
        case 'pdf':
          await UnifiedExportService.exportCalculatorAsPDF(
            context: context,
            toolName: 'Bundle Comparison Tool',
            inputs: inputs,
            results: results,
            interpretation: insightsText,
            recommendations: recommendationsText,
          );
          break;
        case 'excel':
          await UnifiedExportService.exportCalculatorAsExcel(
            context: context,
            toolName: 'Bundle Comparison Tool',
            inputs: inputs,
            results: results,
            interpretation: insightsText,
            recommendations: recommendationsText,
          );
          break;
        case 'csv':
          await UnifiedExportService.exportCalculatorAsCSV(
            context: context,
            toolName: 'Bundle Comparison Tool',
            inputs: inputs,
            results: results,
            interpretation: insightsText,
            recommendations: recommendationsText,
          );
          break;
        case 'text':
          await UnifiedExportService.exportCalculatorAsText(
            context: context,
            toolName: 'Bundle Comparison Tool',
            inputs: inputs,
            results: results,
            interpretation: insightsText,
            recommendations: recommendationsText,
          );
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Exported as ${format.toUpperCase()}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showQuickGuide() {
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutralLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: const KnowledgePanelWidget(
                    data: KnowledgePanelData(
                      definition: 'Bundle Comparison Tool enables side-by-side benchmarking of bundle compliance across different dimensions: bundle types, hospital units, or time periods. It identifies performance gaps, best practices, and opportunities for improvement through visual analytics and statistical comparison.',
                      example: 'Example: Compare CLABSI, CAUTI, and VAP bundles across ICU, Medical Ward, and Surgical Ward. Results show ICU has highest compliance (92%) while Medical Ward needs improvement (68%). CLABSI bundle performs best (88%) across all units.',
                      interpretation: 'Average compliance ≥85% indicates consistent performance. Compliance range >20% suggests significant variation requiring investigation. Best performers can serve as benchmarks. Declining trends require immediate intervention.',
                      whenUsed: 'Use for multi-unit benchmarking, identifying best practices, quality improvement prioritization, executive reporting, accreditation preparation, and tracking improvement initiatives over time.',
                      inputDataType: 'Comparison type (bundles/units/time periods), selection of 2+ items to compare, audit data from each dataset, compliance percentages, element-level performance, and trend indicators.',
                      references: [],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadExample() {
    // Clear existing selections
    for (var item in _selectedItems.toList()) {
      _onItemSelectionChanged(item, false);
    }

    setState(() {
      _comparisonResult = null;
    });

    // Context-aware example loading based on comparison type
    Map<String, Map<String, String>> exampleData;
    String exampleDescription;

    switch (_comparisonType) {
      case 'bundles':
        // Example: Compare 3 different bundle types
        exampleData = {
          'CLABSI': {'total': '50', 'compliant': '45', 'trend': 'Improving'},
          'CAUTI': {'total': '60', 'compliant': '48', 'trend': 'Stable'},
          'VAP': {'total': '40', 'compliant': '32', 'trend': 'Improving'},
        };
        exampleDescription = 'Per Bundle: CLABSI (90%), CAUTI (80%), VAP (80%)';
        break;

      case 'units':
        // Example: Compare 3 different units
        exampleData = {
          'ICU': {'total': '45', 'compliant': '40', 'trend': 'Improving'},
          'Medical Ward': {'total': '60', 'compliant': '45', 'trend': 'Stable'},
          'Surgical Ward': {'total': '50', 'compliant': '42', 'trend': 'Declining'},
        };
        exampleDescription = 'Per Unit: ICU (89%), Medical Ward (75%), Surgical Ward (84%)';
        break;

      case 'time-periods':
        // Example: Compare 3 quarters
        final currentYear = DateTime.now().year;
        exampleData = {
          'Q1 $currentYear': {'total': '50', 'compliant': '38', 'trend': 'Stable'},
          'Q2 $currentYear': {'total': '55', 'compliant': '44', 'trend': 'Improving'},
          'Q3 $currentYear': {'total': '52', 'compliant': '47', 'trend': 'Improving'},
        };
        exampleDescription = 'Per Time Period: Q1 (76%), Q2 (80%), Q3 (90%)';
        break;

      default:
        exampleData = {};
        exampleDescription = 'Example data loaded';
    }

    // Load example data
    for (var entry in exampleData.entries) {
      _onItemSelectionChanged(entry.key, true);
      _totalAuditsControllers[entry.key]?.text = entry.value['total']!;
      _compliantAuditsControllers[entry.key]?.text = entry.value['compliant']!;
      _trendSelections[entry.key] = entry.value['trend'];
    }

    setState(() {}); // Refresh UI

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded: $exampleDescription'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Bundle Comparison Tool',
        fitTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.large, // Bottom padding for mobile
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.medium),
              
              // Quick Guide button
              _buildQuickGuideButton(),
              const SizedBox(height: AppSpacing.medium),
              
              // Load Example button
              _buildLoadExampleButton(),
              const SizedBox(height: AppSpacing.large),
              
              _buildComparisonTypeSection(),
              const SizedBox(height: AppSpacing.medium),
              _buildSelectionSection(),

              // Input data section (only show if items are selected)
              if (_selectedItems.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.medium),
                _buildInputDataSection(),
              ],

              const SizedBox(height: AppSpacing.medium),
              _buildActionButton(),
              if (_comparisonResult != null) ...[
                const SizedBox(height: AppSpacing.large),
                _buildResultsSection(),
                const SizedBox(height: AppSpacing.large), // Extra bottom padding
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.interactiveBorderLight, AppColors.interactiveBorderDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.compare_arrows, color: AppColors.primary, size: 28),
                  const SizedBox(width: AppSpacing.small),
                  const Expanded(
                    child: Text(
                      'Bundle Comparison',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              const Text(
                'Compare bundle compliance across different bundles, units, or time periods. '
                'Identify best practices and areas for improvement.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickGuideButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showQuickGuide,
        icon: const Icon(Icons.menu_book, color: AppColors.info),
        label: const Text(
          'Quick Guide',
          style: TextStyle(
            color: AppColors.info,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.info, width: 1.5),
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
        icon: const Icon(Icons.lightbulb_outline, color: AppColors.success),
        label: const Text(
          'Load Example Data',
          style: TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.success, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonTypeSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.category, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'Comparison Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'bundles',
                  label: Text('Bundles'),
                  icon: Icon(Icons.medical_services, size: 18),
                ),
                ButtonSegment(
                  value: 'units',
                  label: Text('Units'),
                  icon: Icon(Icons.business, size: 18),
                ),
                ButtonSegment(
                  value: 'time-periods',
                  label: Text('Time'),
                  icon: Icon(Icons.calendar_today, size: 18),
                ),
              ],
              selected: {_comparisonType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _comparisonType = newSelection.first;
                  _comparisonResult = null; // Clear results when type changes
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return Colors.transparent;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return AppColors.textPrimary;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.checklist, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'Select Items to Compare',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'Select at least 2 items',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.medium),
            if (_comparisonType == 'bundles') _buildBundleSelection(),
            if (_comparisonType == 'units') _buildUnitSelection(),
            if (_comparisonType == 'time-periods') _buildPeriodSelection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableBundles.map((bundle) {
        final isSelected = _selectedItems.contains(bundle);
        return FilterChip(
          label: Text(bundle),
          selected: isSelected,
          onSelected: (selected) => _onItemSelectionChanged(bundle, selected),
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.neutralLight,
            width: 1.5,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUnitSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableUnits.map((unit) {
        final isSelected = _selectedItems.contains(unit);
        return FilterChip(
          label: Text(unit),
          selected: isSelected,
          onSelected: (selected) => _onItemSelectionChanged(unit, selected),
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.neutralLight,
            width: 1.5,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPeriodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year input field
        Row(
          children: [
            Text(
              'Year:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'YYYY',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final year = int.tryParse(value);
                  if (year == null) return 'Invalid year';
                  if (year < 2000 || year > 2100) return 'Year must be 2000-2100';
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _generatePeriods,
              tooltip: 'Refresh periods',
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        // Period chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availablePeriods.map((period) {
            final isSelected = _selectedItems.contains(period);
            return FilterChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) => _onItemSelectionChanged(period, selected),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.neutralLight,
                width: 1.5,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInputDataSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.small),
                const Text(
                  'Enter Performance Data',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'Enter audit data for each selected item',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.medium),

            // Input fields for each selected item
            ..._selectedItems.map((item) => _buildItemInputCard(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInputCard(String item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name header
          Row(
            children: [
              Icon(
                _comparisonType == 'bundles' ? Icons.medical_services :
                _comparisonType == 'units' ? Icons.business :
                Icons.calendar_today,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                item,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),

          // Total Audits
          TextFormField(
            controller: _totalAuditsControllers[item],
            decoration: const InputDecoration(
              labelText: 'Total Audits *',
              hintText: 'e.g., 50',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.assignment_outlined),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              final num = int.tryParse(value!);
              if (num == null || num <= 0) return 'Enter valid number > 0';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.small),

          // Compliant Audits
          TextFormField(
            controller: _compliantAuditsControllers[item],
            decoration: const InputDecoration(
              labelText: 'Compliant Audits *',
              hintText: 'e.g., 45',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.check_circle_outline),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              final num = int.tryParse(value!);
              if (num == null || num < 0) return 'Enter valid number ≥ 0';

              // Check if compliant <= total
              final total = int.tryParse(_totalAuditsControllers[item]?.text ?? '0') ?? 0;
              if (num > total) return 'Cannot exceed total audits';

              return null;
            },
          ),
          const SizedBox(height: AppSpacing.small),

          // Trend (Optional)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Trend (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.trending_up),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Not specified')),
              DropdownMenuItem(value: 'Improving', child: Text('Improving')),
              DropdownMenuItem(value: 'Stable', child: Text('Stable')),
              DropdownMenuItem(value: 'Declining', child: Text('Declining')),
            ],
            onChanged: (value) {
              setState(() {
                _trendSelections[item] = value;
              });
            },
          ),

          // Show calculated compliance percentage
          if (_totalAuditsControllers[item]?.text.isNotEmpty == true &&
              _compliantAuditsControllers[item]?.text.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.small),
            Container(
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.calculate, size: 16, color: AppColors.info),
                  const SizedBox(width: AppSpacing.small),
                  Text(
                    'Compliance: ${_calculateCompliancePreview(item)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _calculateCompliancePreview(String item) {
    final total = int.tryParse(_totalAuditsControllers[item]?.text ?? '0') ?? 0;
    final compliant = int.tryParse(_compliantAuditsControllers[item]?.text ?? '0') ?? 0;
    if (total == 0) return '0.0';
    return ((compliant / total) * 100).toStringAsFixed(1);
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: _runComparison,
      icon: const Icon(Icons.compare),
      label: const Text('Run Comparison'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_comparisonResult == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummaryCard(),
        const SizedBox(height: AppSpacing.medium),
        _buildComparisonChart(),
        const SizedBox(height: AppSpacing.medium),
        _buildComparisonTable(),
        const SizedBox(height: AppSpacing.medium),
        _buildInsightsCard(),
        const SizedBox(height: AppSpacing.medium),
        _buildRecommendationsCard(),
        const SizedBox(height: AppSpacing.medium),
        _buildReferencesCard(),
        const SizedBox(height: AppSpacing.medium),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final summary = _comparisonResult!.summary;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.summarize, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'Comparison Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildSummaryRow('Average Compliance', '${summary.averageCompliance.toStringAsFixed(1)}%', AppColors.primary),
            const Divider(height: 24),
            _buildSummaryRow('Best Performer', summary.bestPerformer, AppColors.success),
            _buildSummaryRow('Score', '${summary.bestPerformerScore.toStringAsFixed(1)}%', AppColors.success),
            const Divider(height: 24),
            _buildSummaryRow('Needs Improvement', summary.worstPerformer, AppColors.warning),
            _buildSummaryRow('Score', '${summary.worstPerformerScore.toStringAsFixed(1)}%', AppColors.warning),
            const Divider(height: 24),
            _buildSummaryRow('Compliance Range', '${summary.complianceRange.toStringAsFixed(1)}%', AppColors.info),
            _buildSummaryRow('Total Audits', '${summary.totalAudits}', AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart() {
    final datasets = _comparisonResult!.datasets;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'Compliance Comparison',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppColors.neutralDark,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${datasets[group.x.toInt()].name}\n${rod.toY.toStringAsFixed(1)}%',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= datasets.length) return const Text('');
                          final name = datasets[value.toInt()].name;
                          // Truncate long names for mobile
                          final displayName = name.length > 10 ? '${name.substring(0, 10)}...' : name;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              displayName,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.neutralLight,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: AppColors.neutralLight, width: 1),
                      left: BorderSide(color: AppColors.neutralLight, width: 1),
                    ),
                  ),
                  barGroups: datasets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dataset = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: dataset.compliancePercentage,
                          color: _getComplianceColor(dataset.compliancePercentage),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getComplianceColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 75) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildComparisonTable() {
    final datasets = _comparisonResult!.datasets;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.table_chart, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'Detailed Comparison',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
                columns: const [
                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Compliance', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Audits', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Trend', style: TextStyle(fontWeight: FontWeight.w600))),
                ],
                rows: datasets.map((dataset) {
                  return DataRow(
                    cells: [
                      DataCell(Text(dataset.name)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getComplianceColor(dataset.compliancePercentage).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${dataset.compliancePercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _getComplianceColor(dataset.compliancePercentage),
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text('${dataset.totalAudits}')),
                      DataCell(
                        dataset.trend != null && dataset.trendPercentage != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(dataset.trendIcon, size: 16, color: dataset.trendColor),
                                const SizedBox(width: 4),
                                Text(
                                  '${dataset.trendPercentage! > 0 ? '+' : ''}${dataset.trendPercentage!.toStringAsFixed(1)}%',
                                  style: TextStyle(color: dataset.trendColor, fontSize: 12),
                                ),
                              ],
                            )
                          : const Text('-', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: AppColors.info, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'Key Insights',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ..._comparisonResult!.insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.recommend, color: AppColors.success, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'Recommendations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ..._comparisonResult!.recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      rec,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildReferencesCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.library_books, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'References',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            const Text(
              '• WHO Guidelines on Core Components of Infection Prevention and Control Programmes',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              '• CDC Healthcare Infection Control Practices Advisory Committee (HICPAC)',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              '• APIC Implementation Guide: Bundle Approach to Infection Prevention',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _saveToHistory,
            icon: const Icon(Icons.save, color: AppColors.primary),
            label: const Text(
              'Save',
              style: TextStyle(color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showExportModal,
            icon: const Icon(Icons.file_download),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

