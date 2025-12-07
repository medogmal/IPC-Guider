import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

class EpidemicCurveGenerator extends StatefulWidget {
  const EpidemicCurveGenerator({super.key});

  @override
  State<EpidemicCurveGenerator> createState() => _EpidemicCurveGeneratorState();
}

class _EpidemicCurveGeneratorState extends State<EpidemicCurveGenerator> {
  final ScreenshotController _screenshotController = ScreenshotController();

  // Mode toggle
  bool _isAdvancedMode = false;

  // Configuration
  String _timeInterval = 'Day';
  String _stratification = 'None';
  
  // Date range
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  
  // Data entry - NEW structured approach
  final _manualDataController = TextEditingController();
  List<DateTime> _validDates = [];

  // NEW: Structured case entry
  List<CaseEntry> _caseEntries = [];
  DateTime? _selectedDate;
  final _casesController = TextEditingController();
  
  // Chart data
  List<EpiCurveInterval> _intervals = [];
  EpiCurveStats? _stats;
  OutbreakPattern? _outbreakPattern;
  bool _isLoading = false;
  String? _errorMessage;

  // Chart configuration
  bool _showMovingAverage = false;
  bool _showThresholdLines = true;
  final int _movingAveragePeriod = 3;

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Time distribution of cases with advanced pattern recognition.',
    example: 'Single sharp peak → point-source outbreak; multiple peaks → propagated.',
    interpretation: 'Identifies outbreak pattern, peak, and duration.',
    whenUsed: 'Step 6 (descriptive phase) with advanced analytics.',
    inputDataType: 'Case ID, onset date, unit/location.',
    references: [
      Reference(
        title: 'CDC Epidemic Curve Guidelines',
        url: 'https://www.cdc.gov/eis/field-epi-manual/chapters/Epidemic-Curves.html',
      ),
      Reference(
        title: 'WHO Epidemic Curve Guidelines',
        url: 'https://www.who.int/publications/i/item/WHO-WHE-CPI-2018.40',
      ),
      Reference(
        title: 'APIC Outbreak Investigation Guide',
        url: 'https://apic.org/Resource_/TinyMceFileManager/Advocacy-PDFs/APIC_Outbreak_Investigation_Guide.pdf',
      ),
    ],
  );

  // Controllers for date range override
  final _rangeStartController = TextEditingController();
  final _rangeEndController = TextEditingController();

  final List<String> _timeIntervals = ['Day', 'Week', 'Month'];
  final List<String> _stratificationOptions = [
    'None',
    'Ward',
    'Risk group',
    'Case type',
    'Severity'
  ];

  @override
  void initState() {
    super.initState();
    _loadModePreference();
  }

  @override
  void dispose() {
    _manualDataController.dispose();
    _rangeStartController.dispose();
    _rangeEndController.dispose();
    _casesController.dispose();
    super.dispose();
  }

  Future<void> _loadModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAdvancedMode = prefs.getBool('enhanced_epi_curve_advanced_mode') ?? false;
    });
  }

  Future<void> _saveModePreference(bool isAdvanced) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enhanced_epi_curve_advanced_mode', isAdvanced);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Epidemic Curve Generator'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _captureAndShareChart,
            icon: const Icon(Icons.share),
            tooltip: 'Share Chart Image',
          ),
        ],
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

            // Configuration Panel (Advanced only)
            if (_isAdvancedMode) ...[
              _buildConfigurationPanel(),
              const SizedBox(height: 20),
            ],

            // Data Entry Section
            _buildDataEntrySection(),
            const SizedBox(height: 20),
            
            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 20),
            
            // Chart Area
            if (_intervals.isNotEmpty) ...[
              _buildEnhancedChartSection(),
              const SizedBox(height: 20),
            ],
            
            // Pattern Analysis Panel
            if (_outbreakPattern != null) ...[
              _buildPatternAnalysisPanel(),
              const SizedBox(height: 20),
            ],
            
            // Summary Panel
            if (_stats != null) ...[
               _buildSummaryPanel(),
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
                    ? 'Advanced - All features enabled'
                    : 'Beginner - Simplified interface',
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
              Icons.timeline,
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
                  'Enhanced Epi Curve Generator',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Advanced outbreak visualization with pattern recognition',
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



  Widget _buildConfigurationPanel() {
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
          
          // Time Interval
          Text(
            'Time Interval',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _timeIntervals.map((interval) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(interval, style: const TextStyle(fontSize: 12)),
                  value: interval,
                  selected: _timeInterval == interval,
                  onChanged: (value) {
                    setState(() {
                      _timeInterval = value!;
                      _updateChart();
                    });
                  },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Stratification
          Text(
            'Stratification (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _stratification,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _stratificationOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _stratification = value!;
                _updateChart();
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Chart Options
          Text(
            'Chart Options',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Advanced chart options
          if (_isAdvancedMode) ...[
            CheckboxListTile(
              title: const Text('Show Moving Average'),
              subtitle: Text('$_movingAveragePeriod-period moving average'),
              value: _showMovingAverage,
              onChanged: (value) {
                setState(() {
                  _showMovingAverage = value!;
                  _updateChart();
                });
              },
              activeColor: AppColors.primary,
            ),

            CheckboxListTile(
              title: const Text('Show Threshold Lines'),
              subtitle: const Text('Statistical outbreak detection thresholds'),
              value: _showThresholdLines,
              onChanged: (value) {
                setState(() {
                  _showThresholdLines = value!;
                  _updateChart();
                });
              },
              activeColor: AppColors.primary,
            ),

            const SizedBox(height: 16),
          ],
          
          // Date Range Override
          Text(
            'Date Range (Optional Override)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rangeStartController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final date = DateTime.tryParse(value);
                    setState(() {
                      _rangeStart = date;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _rangeEndController,
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final date = DateTime.tryParse(value);
                    setState(() {
                      _rangeEnd = date;
                    });
                  },
                ),
              ),
            ],
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

          // NEW: Add Case Entry Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedDate != null
                                ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                                : 'Select Date',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Cases Input
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _casesController,
                  decoration: const InputDecoration(
                    labelText: 'Cases',
                    hintText: '1',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),

              // Add Button
              ElevatedButton.icon(
                onPressed: _addCaseEntry,
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

          // Case Entries List
          if (_caseEntries.isNotEmpty) ...[
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
                        'Case Data (${_caseEntries.length} entries, ${_caseEntries.fold<int>(0, (sum, e) => sum + e.cases)} total cases)',
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
                      itemCount: _caseEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _caseEntries[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.person, size: 14, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text(
                                '${entry.cases} case${entry.cases > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _removeCaseEntry(entry.id),
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
              onPressed: _clearAllEntries,
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
                      'No case data entered yet. Select a date, enter case count, and click Add.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
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

  Widget _buildActionButtons() {
    final canGenerate = _validDates.isNotEmpty &&
                       (_rangeStart == null || _rangeEnd == null || _rangeStart!.isBefore(_rangeEnd!));

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canGenerate ? _generateEpiCurve : null,
            icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.timeline, size: 18),
            label: Text(_isLoading ? 'Generating...' : 'Generate Curve'),
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

  Widget _buildEnhancedChartSection() {
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
              Icon(Icons.timeline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Epidemic Curve - $_timeInterval Intervals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Interaction hint
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.touch_app, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Pinch to zoom • Swipe to pan',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Chart with Screenshot wrapper - Made scrollable for mobile
          Screenshot(
            controller: _screenshotController,
            child: Container(
              height: 400,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.2)),
              ),
              child: InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                panEnabled: true,
                scaleEnabled: true,
                child: SizedBox(
                  width: math.max(MediaQuery.of(context).size.width - 80, _intervals.length * 40.0), // Dynamic width based on screen and data
                  height: 376, // 400 - 24 (padding)
                  child: _buildFlChart(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Chart controls
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
        ],
      ),
    );
  }

  Widget _buildFlChart() {
    if (_intervals.isEmpty) {
      return const Center(
        child: Text('No data to display'),
      );
    }

    final maxValue = _intervals.map((i) => i.totalCount).reduce(math.max).toDouble();
    final spots = <FlSpot>[];
    final movingAverageSpots = <FlSpot>[];

    // Calculate data points
    for (int i = 0; i < _intervals.length; i++) {
      spots.add(FlSpot(i.toDouble(), _intervals[i].totalCount.toDouble()));
      
      // Calculate moving average if enabled
      if (_showMovingAverage && i >= _movingAveragePeriod - 1) {
        double sum = 0;
        for (int j = 0; j < _movingAveragePeriod; j++) {
          sum += _intervals[i - j].totalCount;
        }
        movingAverageSpots.add(FlSpot(i.toDouble(), sum / _movingAveragePeriod));
      }
    }

    // Calculate threshold lines if enabled
    double? upperThreshold;
    double? lowerThreshold;
    if (_showThresholdLines && _stats != null) {
      final mean = _stats!.meanCases;
      final stdDev = _stats!.stdDevCases;
      upperThreshold = mean + (2 * stdDev); // 2 standard deviations
      lowerThreshold = math.max(0, mean - (2 * stdDev));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: math.max(1, (maxValue / 5).ceilToDouble()),
          verticalInterval: math.max(1, (_intervals.length / 10).ceilToDouble()),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textTertiary.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.textTertiary.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              // Improved interval calculation to prevent overlapping
              interval: math.max(1, (_intervals.length / 8).ceilToDouble()),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _intervals.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Transform.rotate(
                      angle: -0.5, // Rotate labels to prevent overlap
                      child: Text(
                        _formatIntervalLabel(_intervals[index].label),
                        style: const TextStyle(fontSize: 9),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: math.max(1, (maxValue / 5).ceilToDouble()),
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.3)),
        ),
        minX: 0,
        maxX: (_intervals.length - 1).toDouble(),
        minY: 0,
        maxY: maxValue * 1.1,
        lineBarsData: [
          // Main case line
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: true,
            gradient: LinearGradient(
              colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primary],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Moving average line
          if (_showMovingAverage && movingAverageSpots.isNotEmpty)
            LineChartBarData(
              spots: movingAverageSpots,
              isCurved: true,
              curveSmoothness: 0.4,
              preventCurveOverShooting: true,
              color: AppColors.secondary,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < _intervals.length) {
                  final interval = _intervals[index];
                  return LineTooltipItem(
                    '${interval.label}\nCases: ${interval.totalCount}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        extraLinesData: _showThresholdLines && upperThreshold != null
          ? ExtraLinesData(
              horizontalLines: [
                // Upper threshold line
                HorizontalLine(
                  y: upperThreshold,
                  color: AppColors.error,
                  strokeWidth: 2,
                  dashArray: [10, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                ),
                // Lower threshold line
                if (lowerThreshold != null && lowerThreshold > 0)
                  HorizontalLine(
                    y: lowerThreshold,
                    color: AppColors.warning,
                    strokeWidth: 2,
                    dashArray: [10, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.bottomRight,
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            )
          : const ExtraLinesData(),
      ),
    );
  }

  Widget _buildPatternAnalysisPanel() {
    if (_outbreakPattern == null) return const SizedBox.shrink();

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
                'Pattern Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pattern Type
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getPatternColor(_outbreakPattern!.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getPatternColor(_outbreakPattern!.type).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outbreak Pattern: ${_outbreakPattern!.type}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getPatternColor(_outbreakPattern!.type),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _outbreakPattern!.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confidence: ${(_outbreakPattern!.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Key Metrics
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMetricChip('Peak Day', 'Day ${_outbreakPattern!.peakDay}', AppColors.primary),
              _buildMetricChip('Incubation', '${_outbreakPattern!.estimatedIncubation} days', AppColors.info),
              _buildMetricChip('Duration', '${_outbreakPattern!.estimatedDuration} days', AppColors.success),
              if (_outbreakPattern!.reproductionRate != null)
                _buildMetricChip('R₀', _outbreakPattern!.reproductionRate!.toStringAsFixed(2), AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
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
                'Outbreak Summary',
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
              _buildStatItem('Total Cases', _stats!.totalCases.toString()),
              _buildStatItem('First Case', _formatDate(_stats!.firstCase)),
              _buildStatItem('Last Case', _formatDate(_stats!.lastCase)),
              _buildStatItem('Peak Interval', _stats!.peakInterval),
              _buildStatItem('Duration', '${_stats!.outbreakDuration} days'),
              _buildStatItem('Mean Onset', _formatDate(_stats!.meanOnsetDate)),
              _buildStatItem('Mean Cases', _stats!.meanCases.toStringAsFixed(1)),
              _buildStatItem('Std Dev', _stats!.stdDevCases.toStringAsFixed(1)),
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
                'WHO - Epidemic Curve Plotting',
                'https://www.who.int/emergencies/outbreak-toolkit/disease-outbreak-toolboxes',
              ),
              _buildReferenceButton(
                'CDC - Outbreak Investigation Steps',
                'https://www.cdc.gov/eis/field-epi-manual/chapters/Epidemic-Curves.html',
              ),
              _buildReferenceButton(
                'Statistical Outbreak Detection',
                'https://www.cdc.gov/mmwr/weekly/surveillance.html',
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
  // NEW: Add case entry
  void _addCaseEntry() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a date first'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final casesText = _casesController.text.trim();
    if (casesText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter number of cases'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final cases = int.tryParse(casesText);
    if (cases == null || cases < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid number (1 or more)'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _caseEntries.add(CaseEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate!,
        cases: cases,
      ));

      // Sort by date
      _caseEntries.sort((a, b) => a.date.compareTo(b.date));

      // Update valid dates for chart generation
      _updateValidDatesFromEntries();

      // Clear inputs
      _casesController.clear();
      _selectedDate = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $cases case${cases > 1 ? 's' : ''} on ${_formatDate(_selectedDate!)}'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // NEW: Remove case entry
  void _removeCaseEntry(String id) {
    setState(() {
      _caseEntries.removeWhere((entry) => entry.id == id);
      _updateValidDatesFromEntries();
    });
  }

  // NEW: Clear all entries
  void _clearAllEntries() {
    setState(() {
      _caseEntries.clear();
      _validDates.clear();
      _intervals.clear();
      _stats = null;
      _outbreakPattern = null;
    });
  }

  // NEW: Update valid dates from case entries
  void _updateValidDatesFromEntries() {
    final dates = <DateTime>[];
    for (final entry in _caseEntries) {
      for (int i = 0; i < entry.cases; i++) {
        dates.add(entry.date);
      }
    }
    _validDates = dates;
  }

  // NEW: Load example data based on time interval
  void _loadExampleData() {
    setState(() {
      _caseEntries.clear();

      // Load example based on selected time interval
      switch (_timeInterval) {
        case 'Day':
          // Example: Norovirus outbreak (10 days, point-source pattern)
          _caseEntries = [
            CaseEntry(id: '1', date: DateTime(2025, 10, 1), cases: 2),
            CaseEntry(id: '2', date: DateTime(2025, 10, 2), cases: 3),
            CaseEntry(id: '3', date: DateTime(2025, 10, 3), cases: 5),
            CaseEntry(id: '4', date: DateTime(2025, 10, 4), cases: 8),
            CaseEntry(id: '5', date: DateTime(2025, 10, 5), cases: 12),
            CaseEntry(id: '6', date: DateTime(2025, 10, 6), cases: 10),
            CaseEntry(id: '7', date: DateTime(2025, 10, 7), cases: 7),
            CaseEntry(id: '8', date: DateTime(2025, 10, 8), cases: 4),
            CaseEntry(id: '9', date: DateTime(2025, 10, 9), cases: 2),
            CaseEntry(id: '10', date: DateTime(2025, 10, 10), cases: 1),
          ];
          break;

        case 'Week':
          // Example: Influenza outbreak (8 weeks, propagated pattern)
          _caseEntries = [
            CaseEntry(id: '1', date: DateTime(2025, 8, 4), cases: 3),   // Week 1
            CaseEntry(id: '2', date: DateTime(2025, 8, 11), cases: 7),  // Week 2
            CaseEntry(id: '3', date: DateTime(2025, 8, 18), cases: 15), // Week 3
            CaseEntry(id: '4', date: DateTime(2025, 8, 25), cases: 22), // Week 4
            CaseEntry(id: '5', date: DateTime(2025, 9, 1), cases: 18),  // Week 5
            CaseEntry(id: '6', date: DateTime(2025, 9, 8), cases: 12),  // Week 6
            CaseEntry(id: '7', date: DateTime(2025, 9, 15), cases: 6),  // Week 7
            CaseEntry(id: '8', date: DateTime(2025, 9, 22), cases: 2),  // Week 8
          ];
          break;

        case 'Month':
          // Example: MRSA outbreak (6 months, continuous common source)
          _caseEntries = [
            CaseEntry(id: '1', date: DateTime(2025, 5, 15), cases: 8),  // May
            CaseEntry(id: '2', date: DateTime(2025, 6, 15), cases: 12), // June
            CaseEntry(id: '3', date: DateTime(2025, 7, 15), cases: 15), // July
            CaseEntry(id: '4', date: DateTime(2025, 8, 15), cases: 14), // August
            CaseEntry(id: '5', date: DateTime(2025, 9, 15), cases: 10), // September
            CaseEntry(id: '6', date: DateTime(2025, 10, 15), cases: 5), // October
          ];
          break;
      }

      _updateValidDatesFromEntries();
    });

    // Show interval-specific message
    String exampleDescription;
    switch (_timeInterval) {
      case 'Day':
        exampleDescription = 'Norovirus outbreak (10 days, 54 total cases, point-source pattern)';
        break;
      case 'Week':
        exampleDescription = 'Influenza outbreak (8 weeks, 85 total cases, propagated pattern)';
        break;
      case 'Month':
        exampleDescription = 'MRSA outbreak (6 months, 64 total cases, continuous common source)';
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

  void _generateEpiCurve() {
    if (_validDates.length < 5) {
      setState(() {
        _errorMessage = 'Not enough data to generate meaningful epidemic curve (minimum 5 cases required).';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Apply date range filtering if specified
      List<DateTime> filteredDates = _validDates;
      if (_rangeStart != null || _rangeEnd != null) {
        final start = _rangeStart ?? _validDates.reduce((a, b) => a.isBefore(b) ? a : b);
        final end = _rangeEnd ?? _validDates.reduce((a, b) => a.isAfter(b) ? a : b);

        if (start.isAfter(end)) {
          setState(() {
            _errorMessage = 'Invalid date range: start date must be before end date.';
            _isLoading = false;
          });
          return;
        }

        filteredDates = _validDates.where((date) =>
          !date.isBefore(start) && !date.isAfter(end)
        ).toList();
      }

      if (filteredDates.isEmpty) {
        setState(() {
          _errorMessage = 'No cases within the specified date range.';
          _isLoading = false;
        });
        return;
      }

      // Generate intervals
      _intervals = _generateIntervals(filteredDates);

      // Calculate statistics
      _stats = _calculateStats(filteredDates);

      // Analyze outbreak pattern
      _outbreakPattern = _analyzeOutbreakPattern();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error generating epidemic curve: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<EpiCurveInterval> _generateIntervals(List<DateTime> dates) {
    if (dates.isEmpty) return [];

    final sortedDates = List<DateTime>.from(dates)..sort();
    final firstDate = sortedDates.first;
    final lastDate = sortedDates.last;

    final intervals = <String, EpiCurveInterval>{};

    // Generate all intervals in range (including empty ones)
    DateTime current = _getIntervalStart(firstDate);
    final end = _getIntervalStart(lastDate);

    while (!current.isAfter(end)) {
      final label = _getIntervalLabel(current);
      intervals[label] = EpiCurveInterval(
        label: label,
        startDate: current,
        totalCount: 0,
        stratifiedCounts: {},
      );
      current = _getNextInterval(current);
    }

    // Count cases in each interval
    for (final date in dates) {
      final intervalStart = _getIntervalStart(date);
      final label = _getIntervalLabel(intervalStart);

      if (intervals.containsKey(label)) {
        intervals[label]!.totalCount++;

        // Add stratification if selected
        if (_stratification != 'None') {
          final stratGroup = _getStratificationGroup(date);
          intervals[label]!.stratifiedCounts[stratGroup] =
            (intervals[label]!.stratifiedCounts[stratGroup] ?? 0) + 1;
        }
      }
    }

    return intervals.values.toList()..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  DateTime _getIntervalStart(DateTime date) {
    switch (_timeInterval) {
      case 'Day':
        return DateTime(date.year, date.month, date.day);
      case 'Week':
        // ISO week starts on Monday
        final dayOfWeek = date.weekday;
        return date.subtract(Duration(days: dayOfWeek - 1));
      case 'Month':
        return DateTime(date.year, date.month, 1);
      default:
        return date;
    }
  }

  DateTime _getNextInterval(DateTime current) {
    switch (_timeInterval) {
      case 'Day':
        return current.add(const Duration(days: 1));
      case 'Week':
        return current.add(const Duration(days: 7));
      case 'Month':
        return DateTime(current.year, current.month + 1, 1);
      default:
        return current;
    }
  }

  String _getIntervalLabel(DateTime date) {
    switch (_timeInterval) {
      case 'Day':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'Week':
        final weekNumber = _getWeekNumber(date);
        return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
      case 'Month':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}';
      default:
        return date.toString();
    }
  }

  int _getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  String _getStratificationGroup(DateTime date) {
    // Placeholder implementation - in real app would use actual data
    switch (_stratification) {
      case 'Ward':
        return ['Ward A', 'Ward B', 'Ward C'][date.day % 3];
      case 'Risk group':
        return ['High Risk', 'Medium Risk', 'Low Risk'][date.day % 3];
      case 'Case type':
        return ['Confirmed', 'Probable', 'Suspected'][date.day % 3];
      case 'Severity':
        return ['Mild', 'Moderate', 'Severe'][date.day % 3];
      default:
        return 'Unknown';
    }
  }

  EpiCurveStats _calculateStats(List<DateTime> dates) {
    final sortedDates = List<DateTime>.from(dates)..sort();
    final firstCase = sortedDates.first;
    final lastCase = sortedDates.last;
    final duration = lastCase.difference(firstCase).inDays;

    // Find peak interval
    final peakInterval = _intervals.reduce((a, b) =>
      a.totalCount > b.totalCount ? a : b
    );

    // Calculate mean onset date
    final totalDays = dates.map((d) => d.millisecondsSinceEpoch).reduce((a, b) => a + b);
    final meanMillis = totalDays / dates.length;
    final meanOnsetDate = DateTime.fromMillisecondsSinceEpoch(meanMillis.round());

    // Calculate statistics
    final caseCounts = _intervals.map((i) => i.totalCount.toDouble()).toList();
    final meanCases = caseCounts.reduce((a, b) => a + b) / caseCounts.length;
    final variance = caseCounts.map((x) => math.pow(x - meanCases, 2)).reduce((a, b) => a + b) / caseCounts.length;
    final stdDevCases = math.sqrt(variance);

    return EpiCurveStats(
      totalCases: dates.length,
      firstCase: firstCase,
      lastCase: lastCase,
      peakInterval: peakInterval.label,
      outbreakDuration: duration,
      meanOnsetDate: meanOnsetDate,
      meanCases: meanCases,
      stdDevCases: stdDevCases,
    );
  }

  OutbreakPattern _analyzeOutbreakPattern() {
    if (_intervals.length < 3) {
      return OutbreakPattern(
        type: 'Insufficient Data',
        description: 'Not enough data points for pattern analysis',
        confidence: 0.0,
        peakDay: 0,
        estimatedIncubation: 0,
        estimatedDuration: 0,
      );
    }

    final caseCounts = _intervals.map((i) => i.totalCount).toList();
    final maxCases = caseCounts.reduce(math.max);
    final peakIndex = caseCounts.indexOf(maxCases);
    
    // Analyze pattern characteristics
    final hasSinglePeak = _isSinglePeak(caseCounts);
    final hasGradualIncrease = _hasGradualIncrease(caseCounts);
    final hasMultiplePeaks = _hasMultiplePeaks(caseCounts);
    
    // Determine pattern type
    String patternType;
    String description;
    double confidence;
    
    if (hasSinglePeak && peakIndex < caseCounts.length / 3) {
      patternType = 'Point Source';
      description = 'Common source outbreak with single exposure, rapid rise and fall';
      confidence = 0.85;
    } else if (hasGradualIncrease && !hasMultiplePeaks) {
      patternType = 'Propagated';
      description = 'Person-to-person transmission with gradual spread';
      confidence = 0.75;
    } else if (hasMultiplePeaks) {
      patternType = 'Mixed/Intermittent';
      description = 'Multiple exposure events or sustained transmission';
      confidence = 0.70;
    } else {
      patternType = 'Continuous';
      description = 'Ongoing transmission with relatively stable incidence';
      confidence = 0.60;
    }

    // Estimate incubation period (simplified)
    int estimatedIncubation = 0;
    if (peakIndex > 0) {
      estimatedIncubation = (peakIndex * _getIntervalDays()).round();
    }

    // Estimate reproduction rate (very simplified)
    double? reproductionRate;
    if (peakIndex > 0 && peakIndex < caseCounts.length - 1) {
      final growthRate = (caseCounts[peakIndex] - caseCounts[peakIndex - 1]) / math.max(1, caseCounts[peakIndex - 1]);
      reproductionRate = 1 + (growthRate * _getIntervalDays());
    }

    return OutbreakPattern(
      type: patternType,
      description: description,
      confidence: confidence,
      peakDay: peakIndex + 1,
      estimatedIncubation: estimatedIncubation,
      estimatedDuration: _intervals.length * _getIntervalDays(),
      reproductionRate: reproductionRate,
    );
  }

  bool _isSinglePeak(List<int> caseCounts) {
    final maxIndex = caseCounts.indexOf(caseCounts.reduce(math.max));
    
    // Check if cases decline after peak
    for (int i = maxIndex + 1; i < caseCounts.length; i++) {
      if (caseCounts[i] > caseCounts[i - 1] * 1.5) {
        return false;
      }
    }
    
    return true;
  }

  bool _hasGradualIncrease(List<int> caseCounts) {
    int increases = 0;
    for (int i = 1; i < caseCounts.length; i++) {
      if (caseCounts[i] > caseCounts[i - 1]) {
        increases++;
      }
    }
    
    return increases > caseCounts.length * 0.6;
  }

  bool _hasMultiplePeaks(List<int> caseCounts) {
    final maxCases = caseCounts.reduce(math.max);
    final threshold = maxCases * 0.7;
    
    int peaks = 0;
    for (int i = 1; i < caseCounts.length - 1; i++) {
      if (caseCounts[i] >= threshold && 
          caseCounts[i] > caseCounts[i - 1] && 
          caseCounts[i] > caseCounts[i + 1]) {
        peaks++;
      }
    }
    
    return peaks > 1;
  }

  int _getIntervalDays() {
    switch (_timeInterval) {
      case 'Day':
        return 1;
      case 'Week':
        return 7;
      case 'Month':
        return 30;
      default:
        return 1;
    }
  }

  Color _getPatternColor(String patternType) {
    switch (patternType) {
      case 'Point Source':
        return AppColors.error;
      case 'Propagated':
        return AppColors.warning;
      case 'Mixed/Intermittent':
        return AppColors.info;
      case 'Continuous':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  void _updateChart() {
    if (_intervals.isNotEmpty) {
      _generateEpiCurve();
    }
  }

  void _clearData() {
    setState(() {
      _validDates.clear();
      _intervals.clear();
      _stats = null;
      _outbreakPattern = null;
      _errorMessage = null;
      _manualDataController.clear();
    });
  }

  void _reset() {
    _clearData();
    setState(() {
      _timeInterval = 'Day';
      _stratification = 'None';
      _rangeStart = null;
      _rangeEnd = null;
      _rangeStartController.clear();
      _rangeEndController.clear();
      _showMovingAverage = false;
      _showThresholdLines = true;
    });
  }

  Future<void> _saveResult() async {
    if (_stats == null || _intervals.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('enhanced_epicurve_history') ?? [];

      final result = {
        'timestamp': DateTime.now().toIso8601String(),
        'dataSource': 'Manual Entry',
        'timeInterval': _timeInterval,
        'stratification': _stratification,
        'totalCases': _stats!.totalCases,
        'firstCase': _stats!.firstCase.toIso8601String(),
        'lastCase': _stats!.lastCase.toIso8601String(),
        'peakInterval': _stats!.peakInterval,
        'duration': _stats!.outbreakDuration,
        'meanOnset': _stats!.meanOnsetDate.toIso8601String(),
        'patternType': _outbreakPattern?.type,
        'patternConfidence': _outbreakPattern?.confidence,
        'showMovingAverage': _showMovingAverage,
        'showThresholdLines': _showThresholdLines,
      };

      history.add(jsonEncode(result));
      await prefs.setStringList('enhanced_epicurve_history', history);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enhanced epidemic curve saved to history'),
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

  void _showExportModal() {
    if (_stats == null || _intervals.isEmpty) return;

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
        final filename = 'ipc_epicurve_${timestamp.millisecondsSinceEpoch}.png';

        // Add watermark per EXPORT_STANDARDS.md
        final watermarkedImage = await UnifiedExportService.addWatermarkToScreenshot(
          screenshotBytes: image,
        );

        await Share.shareXFiles(
          [XFile.fromData(watermarkedImage, name: filename, mimeType: 'image/png')],
          text: 'Enhanced Epidemic Curve - ${_outbreakPattern?.type ?? 'Unknown Pattern'}\n'
                'Generated: ${timestamp.toString().split('.')[0]}\n'
                'Total Cases: ${_stats?.totalCases ?? 0}',
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
    if (_intervals.isEmpty || _stats == null) return;

    final timestamp = DateTime.now();
    final filename = 'ipc_enhanced_epicurve_${timestamp.millisecondsSinceEpoch}';

    // Create CSV content
    final csvContent = StringBuffer();

    // Header with metadata
    csvContent.writeln('Date_Generated,Tool,Interval,Stratification,N_Cases,Range_Start,Range_End,Pattern_Type,Pattern_Confidence');
    csvContent.writeln('${timestamp.toIso8601String()},Enhanced Epi Curve Generator,$_timeInterval,$_stratification,${_stats!.totalCases},${_formatDate(_stats!.firstCase)},${_formatDate(_stats!.lastCase)},${_outbreakPattern?.type},${_outbreakPattern?.confidence}');
    csvContent.writeln('');

    // Data rows
    if (_stratification == 'None') {
      csvContent.writeln('Interval_Label,Count,Moving_Average,Is_Outbreak');
      for (int i = 0; i < _intervals.length; i++) {
        final interval = _intervals[i];
        final movingAvg = _calculateMovingAverage(i);
        final isOutbreak = _isOutbreakThreshold(i);

        csvContent.writeln('${interval.label},${interval.totalCount},${movingAvg.toStringAsFixed(2)},${isOutbreak ? 'Yes' : 'No'}');
      }
    } else {
      csvContent.writeln('Interval_Label,Group,Count');
      for (final interval in _intervals) {
        if (interval.stratifiedCounts.isEmpty) {
          csvContent.writeln('${interval.label},None,${interval.totalCount}');
        } else {
          for (final entry in interval.stratifiedCounts.entries) {
            csvContent.writeln('${interval.label},${entry.key},${entry.value}');
          }
        }
      }
    }

    // Export using UnifiedExportService
    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: filename,
      csvContent: csvContent.toString(),
      shareText: 'Enhanced Epidemic Curve\nInterval: $_timeInterval\nCases: ${_stats!.totalCases}\nPattern: ${_outbreakPattern?.type ?? 'Unknown'}',
    );
  }

  Future<void> _exportAsExcel() async {
    if (_intervals.isEmpty || _stats == null) return;

    // Prepare headers and data
    final headers = _stratification == 'None'
        ? ['Interval Label', 'Count', 'Moving Average', 'Is Outbreak']
        : ['Interval Label', 'Group', 'Count'];

    final data = <List<dynamic>>[];
    if (_stratification == 'None') {
      for (int i = 0; i < _intervals.length; i++) {
        final interval = _intervals[i];
        final movingAvg = _calculateMovingAverage(i);
        final isOutbreak = _isOutbreakThreshold(i);
        data.add([
          interval.label,
          interval.totalCount,
          movingAvg.toStringAsFixed(2),
          isOutbreak ? 'Yes' : 'No',
        ]);
      }
    } else {
      for (final interval in _intervals) {
        if (interval.stratifiedCounts.isEmpty) {
          data.add([interval.label, 'None', interval.totalCount]);
        } else {
          for (final entry in interval.stratifiedCounts.entries) {
            data.add([interval.label, entry.key, entry.value]);
          }
        }
      }
    }

    await UnifiedExportService.exportVisualizationAsExcel(
      context: context,
      toolName: 'Enhanced Epidemic Curve',
      headers: headers,
      data: data,
      metadata: {
        'Time Interval': _timeInterval,
        'Total Cases': _stats!.totalCases.toString(),
        'Date Range': '${_formatDate(_stats!.firstCase)} to ${_formatDate(_stats!.lastCase)}',
        'Pattern Type': _outbreakPattern?.type ?? 'Unknown',
        'Pattern Confidence': _outbreakPattern != null ? '${(_outbreakPattern!.confidence * 100).toStringAsFixed(1)}%' : 'N/A',
        'Stratification': _stratification,
      },
    );
  }

  Future<void> _exportAsPDF() async {
    if (_intervals.isEmpty || _stats == null) return;

    final inputs = {
      'Time Interval': _timeInterval,
      'Data Source': 'Manual Entry',
      'Stratification': _stratification,
      'Date Range': '${_formatDate(_stats!.firstCase)} to ${_formatDate(_stats!.lastCase)}',
    };

    final results = {
      'Total Cases': _stats!.totalCases.toString(),
      'Peak Interval': _stats!.peakInterval,
      'Mean Cases': _stats!.meanCases.toStringAsFixed(1),
      'Duration': '${_stats!.outbreakDuration} days',
      'Pattern Type': _outbreakPattern?.type ?? 'Unknown',
      'Pattern Confidence': _outbreakPattern != null ? '${(_outbreakPattern!.confidence * 100).toStringAsFixed(1)}%' : 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Enhanced Epidemic Curve',
      inputs: inputs,
      results: results,
      interpretation: _outbreakPattern?.description ?? 'Epidemic curve generated with ${_stats!.totalCases} cases over ${_intervals.length} time intervals',
      references: [
        'CDC Epidemic Curve Guidelines',
        'https://www.cdc.gov/eis/field-epi-manual/chapters/Epidemic-Curve.html',
      ],
    );
  }

  Future<void> _exportAsText() async {
    if (_intervals.isEmpty || _stats == null) return;

    final inputs = {
      'Time Interval': _timeInterval,
      'Data Source': 'Manual Entry',
      'Stratification': _stratification,
      'Date Range': '${_formatDate(_stats!.firstCase)} to ${_formatDate(_stats!.lastCase)}',
    };

    final results = {
      'Total Cases': _stats!.totalCases.toString(),
      'Peak Interval': _stats!.peakInterval,
      'Mean Cases': _stats!.meanCases.toStringAsFixed(1),
      'Duration': '${_stats!.outbreakDuration} days',
      'Pattern Type': _outbreakPattern?.type ?? 'Unknown',
      'Pattern Confidence': _outbreakPattern != null ? '${(_outbreakPattern!.confidence * 100).toStringAsFixed(1)}%' : 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Enhanced Epidemic Curve',
      inputs: inputs,
      results: results,
      interpretation: _outbreakPattern?.description ?? 'Epidemic curve generated with ${_stats!.totalCases} cases over ${_intervals.length} time intervals',
      references: [
        'CDC Epidemic Curve Guidelines',
        'https://www.cdc.gov/eis/field-epi-manual/chapters/Epidemic-Curve.html',
      ],
    );
  }

  double _calculateMovingAverage(int index) {
    if (!_showMovingAverage || index < _movingAveragePeriod - 1) {
      return 0.0;
    }

    double sum = 0;
    for (int i = 0; i < _movingAveragePeriod; i++) {
      sum += _intervals[index - i].totalCount;
    }
    return sum / _movingAveragePeriod;
  }

  bool _isOutbreakThreshold(int index) {
    if (!_showThresholdLines || _stats == null) return false;
    
    final upperThreshold = _stats!.meanCases + (2 * _stats!.stdDevCases);
    return _intervals[index].totalCount > upperThreshold;
  }

  String _formatIntervalLabel(String label) {
    if (label.length > 8) {
      return label.substring(label.length - 5); // Show last 5 chars
    }
    return label;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
}

// Enhanced data classes
class EpiCurveInterval {
  final String label;
  final DateTime startDate;
  int totalCount;
  final Map<String, int> stratifiedCounts;

  EpiCurveInterval({
    required this.label,
    required this.startDate,
    required this.totalCount,
    required this.stratifiedCounts,
  });
}

class EpiCurveStats {
  final int totalCases;
  final DateTime firstCase;
  final DateTime lastCase;
  final String peakInterval;
  final int outbreakDuration;
  final DateTime meanOnsetDate;
  final double meanCases;
  final double stdDevCases;

  EpiCurveStats({
    required this.totalCases,
    required this.firstCase,
    required this.lastCase,
    required this.peakInterval,
    required this.outbreakDuration,
    required this.meanOnsetDate,
    required this.meanCases,
    required this.stdDevCases,
  });
}

class OutbreakPattern {
  final String type;
  final String description;
  final double confidence;
  final int peakDay;
  final int estimatedIncubation;
  final int estimatedDuration;
  final double? reproductionRate;

  OutbreakPattern({
    required this.type,
    required this.description,
    required this.confidence,
    required this.peakDay,
    required this.estimatedIncubation,
    required this.estimatedDuration,
    this.reproductionRate,
  });
}

// NEW: Case Entry Model
class CaseEntry {
  final String id;
  final DateTime date;
  final int cases;

  CaseEntry({
    required this.id,
    required this.date,
    required this.cases,
  });
}
