import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';

class HistogramTool extends StatefulWidget {
  const HistogramTool({super.key});

  @override
  State<HistogramTool> createState() => _HistogramToolState();
}

class _HistogramToolState extends State<HistogramTool> {
  final ScreenshotController _screenshotController = ScreenshotController();

  // Mode toggle
  bool _isAdvancedMode = false;

  // Variable selection
  String _selectedVariable = 'Age (years)';

  // Configuration
  String _binningMode = 'Auto';
  int _binCount = 10;
  double _binWidth = 1.0;
  double? _rangeMin;
  double? _rangeMax;
  String _yAxisMode = 'Counts';

  // Data entry - NEW structured approach
  final _manualDataController = TextEditingController();
  List<double> _validData = [];
  int _ignoredCount = 0;

  // NEW: Structured value entry
  List<ValueEntry> _valueEntries = [];
  final _valueController = TextEditingController();

  // Chart data
  List<HistogramBin> _bins = [];
  HistogramStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Frequency distribution (e.g., incubation period).',
    example: 'Peak 3–5 days → incubation ≈ 4 days.',
    interpretation: 'Helps define exposure window.',
    whenUsed: 'Step 6 (descriptive phase – incubation estimation).',
    inputDataType: 'Onset date – exposure date pairs (per case).',
    references: [
      Reference(
        title: 'CDC Field Epidemiology Manual - Describing Epidemiologic Data',
        url: 'https://www.cdc.gov/eis/field-epi-manual/chapters/Describing-Epi-Data.html',
      ),
      Reference(
        title: 'WHO Outbreak Investigation Toolkit',
        url: 'https://www.who.int/emergencies/outbreak-toolkit/disease-outbreak-toolboxes',
      ),
      Reference(
        title: 'APIC Outbreak Investigation Guide',
        url: 'https://apic.org/Resource_/TinyMceFileManager/Advocacy-PDFs/APIC_Outbreak_Investigation_Guide.pdf',
      ),
    ],
  );

  // Controllers for range override
  final _rangeMinController = TextEditingController();
  final _rangeMaxController = TextEditingController();

  final List<String> _variables = [
    'Age (years)',
    'Onset interval (days)',
    'Length of stay (days)',
    'Custom numeric'
  ];
  final List<String> _binningModes = ['Auto', 'Manual'];
  final List<String> _yAxisModes = ['Counts', 'Percent'];

  @override
  void initState() {
    super.initState();
    _loadModePreference();
  }

  @override
  void dispose() {
    _manualDataController.dispose();
    _valueController.dispose();
    _rangeMinController.dispose();
    _rangeMaxController.dispose();
    super.dispose();
  }

  Future<void> _loadModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAdvancedMode = prefs.getBool('histogram_advanced_mode') ?? false;
    });
  }

  Future<void> _saveModePreference(bool isAdvanced) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('histogram_advanced_mode', isAdvanced);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histogram Tool'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 20),

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
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.info, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Load Sample Data Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadExampleData,
                icon: Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
                label: Text(
                  'Load Sample Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.warning, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Mode Toggle
            _buildModeToggle(),
            const SizedBox(height: 20),

            // Data Source & Variable Selection (Advanced only)
            if (_isAdvancedMode) ...[
              _buildDataSourceSection(),
              const SizedBox(height: 20),
            ],

            // Configuration Section (Advanced only)
            if (_isAdvancedMode) ...[
              _buildConfigurationSection(),
              const SizedBox(height: 20),
            ],

            // Data Entry Section
            _buildDataEntrySection(),
            const SizedBox(height: 20),
            
            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 20),
            
            // Chart Area
            if (_bins.isNotEmpty) ...[
              _buildChartSection(),
              const SizedBox(height: 20),
            ],

            // Summary Panel
             if (_stats != null) ...[
               _buildSummaryPanel(),
               const SizedBox(height: 20),
             ],

             // Export Buttons
             if (_stats != null) ...[
               _buildExportButtons(),
               const SizedBox(height: 20),
             ],



            // Error Message
             if (_errorMessage != null) ...[
               _buildErrorMessage(),
               const SizedBox(height: 20),
             ],

            // References
             _buildReferences(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
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
      child: Row(
        children: [
          Icon(
            _isAdvancedMode ? Icons.settings : Icons.school,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isAdvancedMode
                    ? 'Advanced - Custom bins & overlays'
                    : 'Beginner - Auto bins only',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAdvancedMode,
            onChanged: (value) {
              setState(() {
                _isAdvancedMode = value;
                _saveModePreference(value);
              });
            },
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.bar_chart,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Histogram Tool',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Visualize distribution by configurable bins',
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
    );
  }

  Widget _buildDataSourceSection() {
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
            'Variable Selection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Variable Picker
          Text(
            'Variable',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedVariable,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _variables.map((variable) {
              return DropdownMenuItem(
                value: variable,
                child: Text(variable),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedVariable = value!;
                _clearData();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection() {
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
            'Configuration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Binning Mode
          Text(
            'Binning Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _binningModes.map((mode) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(mode, style: const TextStyle(fontSize: 12)),
                  value: mode,
                  selected: _binningMode == mode,
                  onChanged: (value) {
                    setState(() {
                      _binningMode = value!;
                    });
                  },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
          
          // Manual binning controls
          if (_binningMode == 'Manual') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _binCount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Bin Count (5-20)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      final count = int.tryParse(value);
                      if (count != null && count >= 5 && count <= 20) {
                        setState(() {
                          _binCount = count;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _binWidth.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Bin Width',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      final width = double.tryParse(value);
                      if (width != null && width > 0) {
                        setState(() {
                          _binWidth = width;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Y-axis Mode
          Text(
            'Y-axis Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _yAxisModes.map((mode) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(mode, style: const TextStyle(fontSize: 12)),
                  value: mode,
                  selected: _yAxisMode == mode,
                  onChanged: (value) {
                    setState(() {
                      _yAxisMode = value!;
                      _updateChart();
                    });
                  },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataEntrySection() {
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
            'Data Entry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // NEW: Add Value Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Value Input
              Expanded(
                child: TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: 'Value ($_selectedVariable)',
                    hintText: 'Enter number',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),

              // Add Button
              ElevatedButton.icon(
                onPressed: _addValue,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Values List
          if (_valueEntries.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.list_alt, color: AppColors.info, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Values (${_valueEntries.length} entries)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _valueEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _valueEntries[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                '${entry.value} ${_getUnitLabel()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _removeValue(entry.id),
                                icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _clearAllValues,
              icon: Icon(Icons.clear_all, size: 18, color: AppColors.error),
              label: Text(
                'Clear All',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No values entered yet. Add values or load example.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Summary Stats
          if (_valueEntries.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryStat('Total', _valueEntries.length.toString()),
                  _buildSummaryStat('Min', _validData.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)),
                  _buildSummaryStat('Max', _validData.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)),
                  _buildSummaryStat('Mean', (_validData.reduce((a, b) => a + b) / _validData.length).toStringAsFixed(1)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  String _getUnitLabel() {
    if (_selectedVariable.contains('Age')) return 'years';
    if (_selectedVariable.contains('days')) return 'days';
    return '';
  }

  Widget _buildActionButtons() {
    final canCalculate = _validData.isNotEmpty &&
                       (_binningMode == 'Auto' ||
                        (_binningMode == 'Manual' && _binWidth > 0));

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canCalculate ? _calculateHistogram : null,
            icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.calculate, size: 18),
            label: Text(_isLoading ? 'Calculating...' : 'Calculate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return Screenshot(
      controller: _screenshotController,
      child: Container(
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
              Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Histogram - $_selectedVariable',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart
          SizedBox(
            height: 300,
            child: _buildChart(),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildChart() {
    if (_bins.isEmpty) {
      return Center(
        child: Text(
          'No data to display',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    final maxValue = _bins.map((b) => _yAxisMode == 'Counts' ? b.count.toDouble() : b.percent).reduce(math.max);

    return Column(
      children: [
        // Y-axis label
        Expanded(
          child: Row(
            children: [
              // Y-axis
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  _yAxisMode,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Chart bars
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _bins.map((bin) {
                    final value = _yAxisMode == 'Counts' ? bin.count.toDouble() : bin.percent;
                    final height = maxValue > 0 ? (value / maxValue) * 200 : 0.0;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _showBinTooltip(bin),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: height,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bin.start.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // X-axis label
        Text(
          'Value ($_selectedVariable)',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryPanel() {
    if (_stats == null) return const SizedBox.shrink();

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
              Icon(Icons.analytics, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Summary Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Statistics grid
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildStatItem('N', _stats!.n.toString()),
              _buildStatItem('Min', _stats!.min.toStringAsFixed(1)),
              _buildStatItem('Max', _stats!.max.toStringAsFixed(1)),
              _buildStatItem('Mean', _stats!.mean.toStringAsFixed(2)),
              _buildStatItem('Median', _stats!.median.toStringAsFixed(1)),
              _buildStatItem('SD', _stats!.standardDeviation.toStringAsFixed(2)),
              _buildStatItem('IQR', '${_stats!.q1.toStringAsFixed(1)}-${_stats!.q3.toStringAsFixed(1)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildReferenceButton(
                'WHO - Outbreak Analytics',
                'https://www.who.int/emergencies/outbreak-toolkit/disease-outbreak-toolboxes',
              ),
              _buildReferenceButton(
                'CDC - Data Visualization',
                'https://www.cdc.gov/surveillance/data-visualization/index.html',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceButton(String title, String url) {
    return OutlinedButton.icon(
      onPressed: () => _launchURL(url),
      icon: const Icon(Icons.open_in_new, size: 16),
      label: Text(
        title,
        style: const TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // Data processing methods
  void _calculateHistogram() {
    if (_validData.length < 5) {
      setState(() {
        _errorMessage = 'Not enough data to plot a meaningful histogram (minimum 5 values required).';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Apply range filtering if specified
      List<double> filteredData = _validData;
      if (_rangeMin != null || _rangeMax != null) {
        final min = _rangeMin ?? _validData.reduce(math.min);
        final max = _rangeMax ?? _validData.reduce(math.max);
        filteredData = _validData.where((v) => v >= min && v <= max).toList();
      }

      if (filteredData.isEmpty) {
        setState(() {
          _errorMessage = 'No data points within the specified range.';
          _isLoading = false;
        });
        return;
      }

      // Calculate bins
      _bins = _calculateBins(filteredData);

      // Calculate statistics
      _stats = _calculateStatistics(filteredData);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error calculating histogram: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<HistogramBin> _calculateBins(List<double> data) {
    if (data.isEmpty) return [];

    final min = data.reduce(math.min);
    final max = data.reduce(math.max);

    int binCount;
    if (_binningMode == 'Auto') {
      // Sturges' rule: k = ceil(log2(n) + 1)
      binCount = (math.log(data.length) / math.ln2 + 1).ceil().clamp(5, 20);
    } else {
      binCount = _binCount;
    }

    final binWidth = (max - min) / binCount;
    final bins = <HistogramBin>[];

    for (int i = 0; i < binCount; i++) {
      final start = min + i * binWidth;
      final end = i == binCount - 1 ? max : start + binWidth;

      final count = data.where((v) => v >= start && (i == binCount - 1 ? v <= end : v < end)).length;
      final percent = (count / data.length) * 100;

      bins.add(HistogramBin(
        start: start,
        end: end,
        count: count,
        percent: percent,
      ));
    }

    return bins;
  }

  HistogramStats _calculateStatistics(List<double> data) {
    data.sort();
    final n = data.length;
    final min = data.first;
    final max = data.last;
    final mean = data.reduce((a, b) => a + b) / n;

    final median = n % 2 == 0
      ? (data[n ~/ 2 - 1] + data[n ~/ 2]) / 2
      : data[n ~/ 2];

    final variance = data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / n;
    final standardDeviation = math.sqrt(variance);

    final q1 = data[n ~/ 4];
    final q3 = data[(3 * n) ~/ 4];

    return HistogramStats(
      n: n,
      min: min,
      max: max,
      mean: mean,
      median: median,
      standardDeviation: standardDeviation,
      q1: q1,
      q3: q3,
    );
  }

  void _updateChart() {
    if (_bins.isNotEmpty) {
      setState(() {
        // Recalculate percentages for existing bins
        final total = _bins.map((b) => b.count).reduce((a, b) => a + b);
        for (final bin in _bins) {
          bin.percent = (bin.count / total) * 100;
        }
      });
    }
  }

  void _showBinTooltip(HistogramBin bin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bin Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Range: ${bin.start.toStringAsFixed(1)} - ${bin.end.toStringAsFixed(1)}'),
            const SizedBox(height: 8),
            Text('Count: ${bin.count}'),
            const SizedBox(height: 8),
            Text('Percent: ${bin.percent.toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearData() {
    setState(() {
      _validData.clear();
      _ignoredCount = 0;
      _bins.clear();
      _stats = null;
      _errorMessage = null;
      _manualDataController.clear();
    });
  }

  void _reset() {
    _clearData();
    setState(() {
      _selectedVariable = 'Age (years)';
      _binningMode = 'Auto';
      _binCount = 10;
      _binWidth = 1.0;
      _rangeMin = null;
      _rangeMax = null;
      _yAxisMode = 'Counts';
      _rangeMinController.clear();
      _rangeMaxController.clear();
    });
  }

  Future<void> _saveResult() async {
    if (_stats == null || _bins.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('histogram_history') ?? [];

      final result = {
        'timestamp': DateTime.now().toIso8601String(),
        'variable': _selectedVariable,
        'dataSource': 'Manual Entry',
        'binningMode': _binningMode,
        'binCount': _binCount,
        'binWidth': _binWidth,
        'yAxisMode': _yAxisMode,
        'nValid': _stats!.n,
        'stats': {
          'min': _stats!.min,
          'max': _stats!.max,
          'mean': _stats!.mean,
          'median': _stats!.median,
          'sd': _stats!.standardDeviation,
          'q1': _stats!.q1,
          'q3': _stats!.q3,
        },
      };

      history.add(jsonEncode(result));
      await prefs.setStringList('histogram_history', history);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Histogram saved to history'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildExportButtons() {
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
      child: Row(
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showExportModal,
              icon: const Icon(Icons.file_download_outlined, size: 20),
              label: const Text('Export'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary, width: 2),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportModal() {
    if (_stats == null || _bins.isEmpty) return;

    ExportModal.show(
      context: context,
      onExportPDF: _exportAsPDF,
      onExportCSV: _exportAsCSV,
      onExportExcel: _exportAsExcel,
      onExportText: _exportAsText,
      onExportPhoto: _captureAndShareChart,
      enablePhoto: true,
    );
  }

  Future<void> _captureAndShareChart() async {
    try {
      final image = await _screenshotController.capture();

      if (image != null && mounted) {
        final timestamp = DateTime.now();
        final filename = 'ipc_histogram_${timestamp.millisecondsSinceEpoch}.png';

        // Add watermark per EXPORT_STANDARDS.md
        final watermarkedImage = await UnifiedExportService.addWatermarkToScreenshot(
          screenshotBytes: image,
        );

        await Share.shareXFiles(
          [XFile.fromData(watermarkedImage, name: filename, mimeType: 'image/png')],
          text: 'Histogram - $_selectedVariable\n'
                'Generated: ${timestamp.toString().split('.')[0]}\n'
                'N = ${_stats?.n ?? 0}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing chart: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportAsCSV() async {
    if (_bins.isEmpty || _stats == null) return;

    final timestamp = DateTime.now();
    final filename = 'ipc_histogram_${timestamp.millisecondsSinceEpoch}';

    // Create CSV content
    final csvContent = StringBuffer();

    // Header with metadata
    csvContent.writeln('Date,Title,Variable,Source,N_Valid,N_Excluded,Binning_Mode,Bin_Param,Y_Mode,Range_Min,Range_Max');
    csvContent.writeln('${timestamp.toIso8601String()},Histogram Analysis,$_selectedVariable,Manual Entry,${_stats!.n},$_ignoredCount,$_binningMode,${_binningMode == 'Auto' ? 'Auto' : _binCount},$_yAxisMode,${_rangeMin ?? 'Auto'},${_rangeMax ?? 'Auto'}');
    csvContent.writeln('');

    // Frequency table
    csvContent.writeln('Bin_Start,Bin_End,Count,Percent');
    for (final bin in _bins) {
      csvContent.writeln('${bin.start.toStringAsFixed(2)},${bin.end.toStringAsFixed(2)},${bin.count},${bin.percent.toStringAsFixed(1)}');
    }

    // Export using UnifiedExportService
    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: filename,
      csvContent: csvContent.toString(),
      shareText: 'Histogram Analysis - $_selectedVariable\nN = ${_stats!.n}',
    );
  }

  Future<void> _exportAsExcel() async {
    if (_bins.isEmpty || _stats == null) return;

    // Prepare headers and data
    final headers = ['Bin Start', 'Bin End', 'Count', 'Percent'];
    final data = _bins.map((bin) => [
      bin.start.toStringAsFixed(2),
      bin.end.toStringAsFixed(2),
      bin.count,
      '${bin.percent.toStringAsFixed(1)}%',
    ]).toList();

    await UnifiedExportService.exportVisualizationAsExcel(
      context: context,
      toolName: 'Histogram Analysis',
      headers: headers,
      data: data,
      metadata: {
        'Variable': _selectedVariable,
        'Data Source': 'Manual Entry',
        'N (Valid)': _stats!.n.toString(),
        'N (Excluded)': _ignoredCount.toString(),
        'Mean': _stats!.mean.toStringAsFixed(2),
        'SD': _stats!.standardDeviation.toStringAsFixed(2),
        'Median': _stats!.median.toStringAsFixed(2),
        'Min': _stats!.min.toStringAsFixed(2),
        'Max': _stats!.max.toStringAsFixed(2),
        'Binning Mode': _binningMode,
        'Y-Axis Mode': _yAxisMode,
      },
    );
  }

  Future<void> _exportAsPDF() async {
    if (_bins.isEmpty || _stats == null) return;

    final inputs = {
      'Variable': _selectedVariable,
      'Data Source': 'Manual Entry',
      'N (Valid)': _stats!.n.toString(),
      'N (Excluded)': _ignoredCount.toString(),
      'Binning Mode': _binningMode,
      'Y-Axis Mode': _yAxisMode,
    };

    final results = {
      'Mean': _stats!.mean.toStringAsFixed(2),
      'SD': _stats!.standardDeviation.toStringAsFixed(2),
      'Median': _stats!.median.toStringAsFixed(2),
      'Min': _stats!.min.toStringAsFixed(2),
      'Max': _stats!.max.toStringAsFixed(2),
      'Number of Bins': _bins.length.toString(),
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Histogram Analysis',
      inputs: inputs,
      results: results,
      interpretation: 'Distribution analysis of $_selectedVariable with ${_stats!.n} valid observations. Mean = ${_stats!.mean.toStringAsFixed(2)}, SD = ${_stats!.standardDeviation.toStringAsFixed(2)}',
      references: [
        'CDC Data Visualization Guidelines',
        'https://www.cdc.gov/eis/field-epi-manual/chapters/Data-Visualization.html',
      ],
    );
  }

  Future<void> _exportAsText() async {
    if (_bins.isEmpty || _stats == null) return;

    final inputs = {
      'Variable': _selectedVariable,
      'Data Source': 'Manual Entry',
      'N (Valid)': _stats!.n.toString(),
      'N (Excluded)': _ignoredCount.toString(),
      'Binning Mode': _binningMode,
      'Y-Axis Mode': _yAxisMode,
    };

    final results = {
      'Mean': _stats!.mean.toStringAsFixed(2),
      'SD': _stats!.standardDeviation.toStringAsFixed(2),
      'Median': _stats!.median.toStringAsFixed(2),
      'Min': _stats!.min.toStringAsFixed(2),
      'Max': _stats!.max.toStringAsFixed(2),
      'Number of Bins': _bins.length.toString(),
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Histogram Analysis',
      inputs: inputs,
      results: results,
      interpretation: 'Distribution analysis of $_selectedVariable with ${_stats!.n} valid observations. Mean = ${_stats!.mean.toStringAsFixed(2)}, SD = ${_stats!.standardDeviation.toStringAsFixed(2)}',
      references: [
        'CDC Data Visualization Guidelines',
        'https://www.cdc.gov/eis/field-epi-manual/chapters/Data-Visualization.html',
      ],
    );
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
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.menu_book, color: AppColors.info, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Quick Guide',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.textTertiary.withValues(alpha: 0.2)),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: KnowledgePanelWidget(data: _knowledgePanelData),
                ),
              ),
            ],
          ),
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

  // NEW: Add value entry
  void _addValue() {
    final valueText = _valueController.text.trim();
    if (valueText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a value'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final value = double.tryParse(valueText);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid number'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _valueEntries.add(ValueEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        value: value,
      ));
      _valueEntries.sort((a, b) => a.value.compareTo(b.value));
      _updateValidDataFromEntries();
      _valueController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Value added: $value ${_getUnitLabel()}'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // NEW: Remove value entry
  void _removeValue(String id) {
    setState(() {
      _valueEntries.removeWhere((entry) => entry.id == id);
      _updateValidDataFromEntries();
    });
  }

  // NEW: Clear all values
  void _clearAllValues() {
    setState(() {
      _valueEntries.clear();
      _validData.clear();
      _bins.clear();
      _stats = null;
    });
  }

  // NEW: Update valid data from value entries
  void _updateValidDataFromEntries() {
    _validData = _valueEntries.map((e) => e.value).toList();
    _ignoredCount = 0;
  }

  // NEW: Load example data based on selected variable
  void _loadExampleData() {
    setState(() {
      _valueEntries.clear();

      // Load example based on selected variable type
      switch (_selectedVariable) {
        case 'Age (years)':
          // Example: Patient ages in HAI outbreak (40 patients, 25-85 years)
          _valueEntries = [
            ValueEntry(id: '1', value: 28), ValueEntry(id: '2', value: 32), ValueEntry(id: '3', value: 35),
            ValueEntry(id: '4', value: 38), ValueEntry(id: '5', value: 42), ValueEntry(id: '6', value: 45),
            ValueEntry(id: '7', value: 48), ValueEntry(id: '8', value: 52), ValueEntry(id: '9', value: 55),
            ValueEntry(id: '10', value: 58), ValueEntry(id: '11', value: 62), ValueEntry(id: '12', value: 65),
            ValueEntry(id: '13', value: 65), ValueEntry(id: '14', value: 68), ValueEntry(id: '15', value: 68),
            ValueEntry(id: '16', value: 70), ValueEntry(id: '17', value: 70), ValueEntry(id: '18', value: 72),
            ValueEntry(id: '19', value: 72), ValueEntry(id: '20', value: 72), ValueEntry(id: '21', value: 75),
            ValueEntry(id: '22', value: 75), ValueEntry(id: '23', value: 75), ValueEntry(id: '24', value: 75),
            ValueEntry(id: '25', value: 78), ValueEntry(id: '26', value: 78), ValueEntry(id: '27', value: 78),
            ValueEntry(id: '28', value: 80), ValueEntry(id: '29', value: 80), ValueEntry(id: '30', value: 80),
            ValueEntry(id: '31', value: 82), ValueEntry(id: '32', value: 82), ValueEntry(id: '33', value: 82),
            ValueEntry(id: '34', value: 82), ValueEntry(id: '35', value: 85), ValueEntry(id: '36', value: 85),
            ValueEntry(id: '37', value: 85), ValueEntry(id: '38', value: 85), ValueEntry(id: '39', value: 85),
            ValueEntry(id: '40', value: 85),
          ];
          break;

        case 'Onset interval (days)':
          // Example: HAI incubation period (50 values, 2-18 days, peak 4-6 days)
          _valueEntries = [
            ValueEntry(id: '1', value: 2), ValueEntry(id: '2', value: 2),
            ValueEntry(id: '3', value: 3), ValueEntry(id: '4', value: 3), ValueEntry(id: '5', value: 3), ValueEntry(id: '6', value: 3),
            ValueEntry(id: '7', value: 4), ValueEntry(id: '8', value: 4), ValueEntry(id: '9', value: 4), ValueEntry(id: '10', value: 4),
            ValueEntry(id: '11', value: 4), ValueEntry(id: '12', value: 4), ValueEntry(id: '13', value: 4), ValueEntry(id: '14', value: 4),
            ValueEntry(id: '15', value: 5), ValueEntry(id: '16', value: 5), ValueEntry(id: '17', value: 5), ValueEntry(id: '18', value: 5),
            ValueEntry(id: '19', value: 5), ValueEntry(id: '20', value: 5), ValueEntry(id: '21', value: 5), ValueEntry(id: '22', value: 5),
            ValueEntry(id: '23', value: 5), ValueEntry(id: '24', value: 5),
            ValueEntry(id: '25', value: 6), ValueEntry(id: '26', value: 6), ValueEntry(id: '27', value: 6), ValueEntry(id: '28', value: 6),
            ValueEntry(id: '29', value: 6), ValueEntry(id: '30', value: 6), ValueEntry(id: '31', value: 6), ValueEntry(id: '32', value: 6),
            ValueEntry(id: '33', value: 7), ValueEntry(id: '34', value: 7), ValueEntry(id: '35', value: 7), ValueEntry(id: '36', value: 7),
            ValueEntry(id: '37', value: 7), ValueEntry(id: '38', value: 7),
            ValueEntry(id: '39', value: 8), ValueEntry(id: '40', value: 8), ValueEntry(id: '41', value: 8), ValueEntry(id: '42', value: 8),
            ValueEntry(id: '43', value: 9), ValueEntry(id: '44', value: 9), ValueEntry(id: '45', value: 9),
            ValueEntry(id: '46', value: 10), ValueEntry(id: '47', value: 10),
            ValueEntry(id: '48', value: 12), ValueEntry(id: '49', value: 15), ValueEntry(id: '50', value: 18),
          ];
          break;

        case 'Length of stay (days)':
          // Example: Hospital length of stay (45 patients, 1-30 days, right-skewed)
          _valueEntries = [
            ValueEntry(id: '1', value: 1), ValueEntry(id: '2', value: 2), ValueEntry(id: '3', value: 2),
            ValueEntry(id: '4', value: 3), ValueEntry(id: '5', value: 3), ValueEntry(id: '6', value: 3), ValueEntry(id: '7', value: 3),
            ValueEntry(id: '8', value: 4), ValueEntry(id: '9', value: 4), ValueEntry(id: '10', value: 4), ValueEntry(id: '11', value: 4),
            ValueEntry(id: '12', value: 4), ValueEntry(id: '13', value: 5), ValueEntry(id: '14', value: 5), ValueEntry(id: '15', value: 5),
            ValueEntry(id: '16', value: 5), ValueEntry(id: '17', value: 5), ValueEntry(id: '18', value: 5), ValueEntry(id: '19', value: 6),
            ValueEntry(id: '20', value: 6), ValueEntry(id: '21', value: 6), ValueEntry(id: '22', value: 6), ValueEntry(id: '23', value: 7),
            ValueEntry(id: '24', value: 7), ValueEntry(id: '25', value: 7), ValueEntry(id: '26', value: 8), ValueEntry(id: '27', value: 8),
            ValueEntry(id: '28', value: 8), ValueEntry(id: '29', value: 9), ValueEntry(id: '30', value: 9), ValueEntry(id: '31', value: 10),
            ValueEntry(id: '32', value: 10), ValueEntry(id: '33', value: 11), ValueEntry(id: '34', value: 12), ValueEntry(id: '35', value: 12),
            ValueEntry(id: '36', value: 14), ValueEntry(id: '37', value: 15), ValueEntry(id: '38', value: 16), ValueEntry(id: '39', value: 18),
            ValueEntry(id: '40', value: 20), ValueEntry(id: '41', value: 22), ValueEntry(id: '42', value: 25), ValueEntry(id: '43', value: 28),
            ValueEntry(id: '44', value: 30), ValueEntry(id: '45', value: 30),
          ];
          break;

        case 'Custom numeric':
          // Example: Lab values (WBC count, 30 samples, 4-18 × 10³/μL)
          _valueEntries = [
            ValueEntry(id: '1', value: 4.2), ValueEntry(id: '2', value: 5.1), ValueEntry(id: '3', value: 5.8),
            ValueEntry(id: '4', value: 6.2), ValueEntry(id: '5', value: 6.5), ValueEntry(id: '6', value: 6.8),
            ValueEntry(id: '7', value: 7.2), ValueEntry(id: '8', value: 7.5), ValueEntry(id: '9', value: 7.8),
            ValueEntry(id: '10', value: 8.1), ValueEntry(id: '11', value: 8.5), ValueEntry(id: '12', value: 8.8),
            ValueEntry(id: '13', value: 9.2), ValueEntry(id: '14', value: 9.5), ValueEntry(id: '15', value: 9.8),
            ValueEntry(id: '16', value: 10.2), ValueEntry(id: '17', value: 10.5), ValueEntry(id: '18', value: 10.8),
            ValueEntry(id: '19', value: 11.2), ValueEntry(id: '20', value: 11.5), ValueEntry(id: '21', value: 12.0),
            ValueEntry(id: '22', value: 12.5), ValueEntry(id: '23', value: 13.0), ValueEntry(id: '24', value: 13.5),
            ValueEntry(id: '25', value: 14.0), ValueEntry(id: '26', value: 14.5), ValueEntry(id: '27', value: 15.2),
            ValueEntry(id: '28', value: 16.0), ValueEntry(id: '29', value: 17.5), ValueEntry(id: '30', value: 18.0),
          ];
          break;
      }

      _updateValidDataFromEntries();
    });

    // Show variable-specific message
    String exampleDescription;
    switch (_selectedVariable) {
      case 'Age (years)':
        exampleDescription = 'Patient ages in HAI outbreak (40 patients, 25-85 years, elderly predominance)';
        break;
      case 'Onset interval (days)':
        exampleDescription = 'HAI incubation period (50 values, 2-18 days, peak 4-6 days)';
        break;
      case 'Length of stay (days)':
        exampleDescription = 'Hospital length of stay (45 patients, 1-30 days, right-skewed distribution)';
        break;
      case 'Custom numeric':
        exampleDescription = 'Lab values - WBC count (30 samples, 4-18 × 10³/μL)';
        break;
      default:
        exampleDescription = 'Example data loaded';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded: $exampleDescription'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Data classes
class ValueEntry {
  final String id;
  final double value;

  ValueEntry({
    required this.id,
    required this.value,
  });
}

class HistogramBin {
  final double start;
  final double end;
  final int count;
  double percent;

  HistogramBin({
    required this.start,
    required this.end,
    required this.count,
    required this.percent,
  });
}

class HistogramStats {
  final int n;
  final double min;
  final double max;
  final double mean;
  final double median;
  final double standardDeviation;
  final double q1;
  final double q3;

  HistogramStats({
    required this.n,
    required this.min,
    required this.max,
    required this.mean,
    required this.median,
    required this.standardDeviation,
    required this.q1,
    required this.q3,
  });
}
