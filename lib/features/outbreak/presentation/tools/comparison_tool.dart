import 'package:flutter/material.dart';
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

class ComparisonTool extends StatefulWidget {
  const ComparisonTool({super.key});

  @override
  State<ComparisonTool> createState() => _ComparisonToolState();
}

class _ComparisonToolState extends State<ComparisonTool> {
  final ScreenshotController _screenshotController = ScreenshotController();

  // Mode toggle
  bool _isAdvancedMode = false;

  // Configuration
  String _selectedMetric = 'Attack Rate';

  // Comparison groups
  final List<ComparisonGroup> _groups = [];
  String? _errorMessage;

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Compares rates before and after intervention.',
    example: 'Pre 10% → Post 2%.',
    interpretation: 'Quantifies intervention effectiveness.',
    whenUsed: 'Step 10 (post-intervention evaluation).',
    inputDataType: 'Pre/post metrics (case count, rate, date).',
    references: [
      Reference(
        title: 'CDC Outbreak Investigation Guidelines',
        url: 'https://www.cdc.gov/eis/field-epi-manual/chapters/Outbreak-Investigation.html',
      ),
      Reference(
        title: 'WHO Evaluation Framework',
        url: 'https://www.who.int/publications/i/item/9789241519221',
      ),
      Reference(
        title: 'APIC Outbreak Investigation Guide',
        url: 'https://apic.org/Resource_/TinyMceFileManager/Advocacy-PDFs/APIC_Outbreak_Investigation_Guide.pdf',
      ),
    ],
  );

  // Form controllers for manual input
  final _groupNameController = TextEditingController();
  final _numeratorController = TextEditingController();
  final _denominatorController = TextEditingController();

  final List<String> _metrics = ['Case counts', 'Attack Rate', 'Relative Risk', 'Odds Ratio'];

  @override
  void initState() {
    super.initState();
    _loadModePreference();
    // Initialize with empty groups
    _addEmptyGroup();
    _addEmptyGroup();
  }

  Future<void> _loadModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAdvancedMode = prefs.getBool('comparison_advanced_mode') ?? false;
    });
  }

  Future<void> _saveModePreference(bool isAdvanced) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('comparison_advanced_mode', isAdvanced);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _numeratorController.dispose();
    _denominatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparison Tool'),
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
                onPressed: _loadExample,
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

            // Metric Selector (Advanced only)
            if (_isAdvancedMode) ...[
              _buildMetricSelector(),
              const SizedBox(height: 20),
            ],

            // Manual Input Section
            _buildManualInputSection(),
            const SizedBox(height: 20),
            
            // Comparison Table
            if (_groups.where((g) => g.isValid).length >= 2) ...[
              _buildComparisonTable(),
              const SizedBox(height: 20),

              // Chart View
              _buildChartView(),
              const SizedBox(height: 20),

              // Summary Panel
              _buildSummaryPanel(),
              const SizedBox(height: 20),

              // Export Buttons
              _buildExportButtons(),
              const SizedBox(height: 20),
            ],

            // Error Message
            if (_errorMessage != null) ...[
              _buildErrorMessage(),
              const SizedBox(height: 20),
            ],

            // Hint for minimum groups
            if (_groups.where((g) => g.isValid).length < 2) ...[
              _buildMinimumGroupsHint(),
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
                    ? 'Advanced - All metrics & tests'
                    : 'Beginner - Attack rate only',
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
              Icons.compare_arrows,
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
                  'Comparison Tool',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Compare outbreaks, wards, or risk groups',
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



  Widget _buildMetricSelector() {
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
            'Comparison Metric',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _metrics.map((metric) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 80) / 2,
                child: RadioListTile<String>(
                  title: Text(metric, style: const TextStyle(fontSize: 12)),
                  value: metric,
                  selected: _selectedMetric == metric,
                  onChanged: (value) {
                    setState(() {
                      _selectedMetric = value!;
                      _recalculateMetrics();
                    });
                  },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Metric description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMetricDescription(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputSection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add Comparison Group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Input fields
          TextFormField(
            controller: _groupNameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              hintText: 'e.g., Ward A, High Risk',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _numeratorController,
                  decoration: InputDecoration(
                    labelText: _getNumeratorLabel(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              if (_selectedMetric != 'Case counts')
                Expanded(
                  child: TextFormField(
                    controller: _denominatorController,
                    decoration: InputDecoration(
                      labelText: _getDenominatorLabel(),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addGroup,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Group'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    final validGroups = _groups.where((g) => g.isValid).toList();

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
              Icon(Icons.table_chart, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Comparison Table',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Group', style: _tableHeaderStyle())),
                Expanded(child: Text(_getNumeratorLabel(), style: _tableHeaderStyle())),
                if (_selectedMetric != 'Case counts')
                  Expanded(child: Text(_getDenominatorLabel(), style: _tableHeaderStyle())),
                Expanded(child: Text(_selectedMetric, style: _tableHeaderStyle())),
                SizedBox(width: 40, child: Text('', style: _tableHeaderStyle())),
              ],
            ),
          ),

          // Table rows
          ...validGroups.asMap().entries.map((entry) {
            final index = entry.key;
            final group = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Colors.transparent : AppColors.surface.withValues(alpha: 0.5),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.textTertiary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(group.name, style: _tableCellStyle())),
                  Expanded(child: Text(group.numerator.toString(), style: _tableCellStyle())),
                  if (_selectedMetric != 'Case counts')
                    Expanded(child: Text(group.denominator.toString(), style: _tableCellStyle())),
                  Expanded(child: Text(_formatMetricValue(group.calculatedValue), style: _tableCellStyle())),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                      onPressed: () => _removeGroup(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChartView() {
    final validGroups = _groups.where((g) => g.isValid).toList();
    if (validGroups.isEmpty) return const SizedBox.shrink();

    final maxValue = validGroups.map((g) => g.calculatedValue).reduce(math.max);

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
                'Comparison Chart',
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
            child: Column(
              children: [
                // Y-axis label
                Expanded(
                  child: Row(
                    children: [
                      // Y-axis
                      RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          _selectedMetric,
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
                          children: validGroups.map((group) {
                            final height = maxValue > 0 ? (group.calculatedValue / maxValue) * 200 : 0.0;
                            final colorIndex = validGroups.indexOf(group);
                            final colors = [
                              AppColors.primary,
                              AppColors.secondary,
                              AppColors.success,
                              AppColors.warning,
                              AppColors.error,
                            ];

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _showGroupTooltip(group),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: height,
                                        decoration: BoxDecoration(
                                          color: colors[colorIndex % colors.length],
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        group.name.length > 8
                                          ? '${group.name.substring(0, 6)}..'
                                          : group.name,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                        textAlign: TextAlign.center,
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
                  'Groups',
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildSummaryPanel() {
    final validGroups = _groups.where((g) => g.isValid).toList();
    if (validGroups.length < 2) return const SizedBox.shrink();

    // Find highest and lowest values
    final sortedGroups = List<ComparisonGroup>.from(validGroups)
      ..sort((a, b) => b.calculatedValue.compareTo(a.calculatedValue));

    final highest = sortedGroups.first;
    final lowest = sortedGroups.last;

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
              Icon(Icons.insights, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Key Findings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Highest value
          _buildFindingItem(
            'Highest $_selectedMetric',
            '${highest.name}: ${_formatMetricValue(highest.calculatedValue)}',
            AppColors.success,
          ),

          const SizedBox(height: 12),

          // Lowest value
          _buildFindingItem(
            'Lowest $_selectedMetric',
            '${lowest.name}: ${_formatMetricValue(lowest.calculatedValue)}',
            AppColors.info,
          ),

          const SizedBox(height: 12),

          // Relative difference
          if (lowest.calculatedValue > 0) ...[
            _buildFindingItem(
              'Relative Difference',
              '${highest.name} vs ${lowest.name}: ${(highest.calculatedValue / lowest.calculatedValue).toStringAsFixed(2)}x',
              AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFindingItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.arrow_forward, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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

  Widget _buildMinimumGroupsHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add at least 2 datasets to compare. Current: ${_groups.where((g) => g.isValid).length}',
              style: TextStyle(
                color: AppColors.info,
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
                'CDC - Measures of Association',
                'https://www.cdc.gov/csels/dsepd/ss1978/lesson3/section5.html',
              ),
              _buildReferenceButton(
                'WHO - Outbreak Investigation',
                'https://www.who.int/emergencies/outbreak-toolkit/disease-outbreak-toolboxes',
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

  // Utility methods
  TextStyle _tableHeaderStyle() {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    );
  }

  TextStyle _tableCellStyle() {
    return TextStyle(
      fontSize: 12,
      color: AppColors.textPrimary,
    );
  }

  String _getMetricDescription() {
    switch (_selectedMetric) {
      case 'Case counts':
        return 'Raw number of cases in each group';
      case 'Attack Rate':
        return 'Percentage of population affected (Cases ÷ Population × 100)';
      case 'Relative Risk':
        return 'Risk ratio between groups [a/(a+b)] ÷ [c/(c+d)]';
      case 'Odds Ratio':
        return 'Odds comparison between groups (a/b) ÷ (c/d)';
      default:
        return '';
    }
  }

  String _getNumeratorLabel() {
    switch (_selectedMetric) {
      case 'Case counts':
        return 'Cases';
      case 'Attack Rate':
        return 'Cases';
      case 'Relative Risk':
        return 'Exposed Cases';
      case 'Odds Ratio':
        return 'Cases';
      default:
        return 'Numerator';
    }
  }

  String _getDenominatorLabel() {
    switch (_selectedMetric) {
      case 'Attack Rate':
        return 'Population';
      case 'Relative Risk':
        return 'Exposed Total';
      case 'Odds Ratio':
        return 'Controls';
      default:
        return 'Denominator';
    }
  }

  String _formatMetricValue(double value) {
    if (_selectedMetric == 'Case counts') {
      return value.toInt().toString();
    } else if (_selectedMetric == 'Attack Rate') {
      return '${value.toStringAsFixed(1)}%';
    } else {
      return value.toStringAsFixed(3);
    }
  }

  // Data processing methods
  void _addEmptyGroup() {
    setState(() {
      _groups.add(ComparisonGroup(
        name: '',
        numerator: 0,
        denominator: 0,
        calculatedValue: 0.0,
      ));
    });
  }

  void _addGroup() {
    final name = _groupNameController.text.trim();
    final numerator = int.tryParse(_numeratorController.text) ?? 0;
    final denominator = int.tryParse(_denominatorController.text) ?? 0;

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Group name is required';
      });
      return;
    }

    if (numerator < 0) {
      setState(() {
        _errorMessage = 'Numerator must be non-negative';
      });
      return;
    }

    if (_selectedMetric != 'Case counts' && denominator <= 0) {
      setState(() {
        _errorMessage = 'Denominator must be positive for this metric';
      });
      return;
    }

    if (_selectedMetric != 'Case counts' && numerator > denominator) {
      setState(() {
        _errorMessage = 'Numerator cannot exceed denominator';
      });
      return;
    }

    final calculatedValue = _calculateMetric(numerator, denominator);

    setState(() {
      _groups.add(ComparisonGroup(
        name: name,
        numerator: numerator,
        denominator: denominator,
        calculatedValue: calculatedValue,
      ));

      // Clear form
      _groupNameController.clear();
      _numeratorController.clear();
      _denominatorController.clear();
      _errorMessage = null;
    });
  }

  void _removeGroup(int index) {
    setState(() {
      final validGroups = _groups.where((g) => g.isValid).toList();
      if (index < validGroups.length) {
        final groupToRemove = validGroups[index];
        _groups.remove(groupToRemove);
      }
    });
  }

  void _recalculateMetrics() {
    setState(() {
      for (final group in _groups) {
        if (group.isValid) {
          group.calculatedValue = _calculateMetric(group.numerator, group.denominator);
        }
      }
    });
  }

  double _calculateMetric(int numerator, int denominator) {
    switch (_selectedMetric) {
      case 'Case counts':
        return numerator.toDouble();
      case 'Attack Rate':
        return denominator > 0 ? (numerator / denominator) * 100 : 0.0;
      case 'Relative Risk':
        // Simplified RR calculation - in real app would need 2x2 table
        return denominator > 0 ? numerator / denominator : 0.0;
      case 'Odds Ratio':
        // Simplified OR calculation - in real app would need 2x2 table
        final odds = denominator > 0 ? numerator / (denominator - numerator) : 0.0;
        return odds;
      default:
        return 0.0;
    }
  }

  void _showGroupTooltip(ComparisonGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(group.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_getNumeratorLabel()}: ${group.numerator}'),
            if (_selectedMetric != 'Case counts')
              Text('${_getDenominatorLabel()}: ${group.denominator}'),
            const SizedBox(height: 8),
            Text(
              '$_selectedMetric: ${_formatMetricValue(group.calculatedValue)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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



  Widget _buildExportButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveComparison,
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
    );
  }

  void _showExportModal() {
    final validGroups = _groups.where((g) => g.isValid).toList();
    if (validGroups.length < 2) return;

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

  Future<void> _saveComparison() async {
    final validGroups = _groups.where((g) => g.isValid).toList();
    if (validGroups.length < 2) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('comparison_history') ?? [];

      final result = {
        'timestamp': DateTime.now().toIso8601String(),
        'metric': _selectedMetric,
        'groups': validGroups.map((g) => {
          'name': g.name,
          'numerator': g.numerator,
          'denominator': g.denominator,
          'calculatedValue': g.calculatedValue,
        }).toList(),
      };

      history.add(jsonEncode(result));
      await prefs.setStringList('comparison_history', history);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comparison saved to history'),
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

  Future<void> _captureAndShareChart() async{
    try {
      final image = await _screenshotController.capture();

      if (image != null && mounted) {
        final timestamp = DateTime.now();
        final filename = 'ipc_comparison_${timestamp.millisecondsSinceEpoch}.png';
        final validGroups = _groups.where((g) => g.isValid).toList();

        // Add watermark per EXPORT_STANDARDS.md
        final watermarkedImage = await UnifiedExportService.addWatermarkToScreenshot(
          screenshotBytes: image,
        );

        await Share.shareXFiles(
          [XFile.fromData(watermarkedImage, name: filename, mimeType: 'image/png')],
          text: 'Comparison Tool - $_selectedMetric\n'
                'Generated: ${timestamp.toString().split('.')[0]}\n'
                'Groups: ${validGroups.length}',
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
    final validGroups = _groups.where((g) => g.isValid).toList();
    if (validGroups.length < 2) return;

    final timestamp = DateTime.now();
    final filename = 'ipc_comparison_${timestamp.millisecondsSinceEpoch}';

    // Create CSV content
    final csvContent = StringBuffer();

    // Header with metadata
    csvContent.writeln('Date_Generated,Tool,Metric,Group_Name,Numerator,Denominator,Value');

    // Data rows
    for (final group in validGroups) {
      csvContent.writeln('${timestamp.toIso8601String()},Comparison Tool,$_selectedMetric,${group.name},${group.numerator},${group.denominator},${group.calculatedValue}');
    }

    // Export using UnifiedExportService
    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: filename,
      csvContent: csvContent.toString(),
      shareText: 'Comparison Tool - $_selectedMetric\nGroups: ${validGroups.length}',
    );
  }

  Future<void> _exportAsExcel() async {
    final validGroups = _groups.where((g) => g.isValid).toList();
    if (validGroups.length < 2) return;

    // Prepare headers and data
    final headers = ['Group Name', 'Numerator', 'Denominator', 'Value'];
    final data = validGroups.map((group) => [
      group.name,
      group.numerator,
      group.denominator,
      group.calculatedValue.toStringAsFixed(2),
    ]).toList();

    await UnifiedExportService.exportVisualizationAsExcel(
      context: context,
      toolName: 'Comparison Tool',
      headers: headers,
      data: data,
      metadata: {
        'Metric': _selectedMetric,
        'Number of Groups': validGroups.length.toString(),
      },
    );
  }

  Future<void> _exportAsPDF() async {
    final validGroups = _groups.where((g) => g.isValid).toList();
    if (validGroups.length < 2) return;

    final inputs = {
      'Metric': _selectedMetric,
      'Number of Groups': validGroups.length.toString(),
    };

    final results = <String, dynamic>{};
    for (int i = 0; i < validGroups.length; i++) {
      final group = validGroups[i];
      results[group.name] = '${group.calculatedValue.toStringAsFixed(2)} (${group.numerator}/${group.denominator})';
    }

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Comparison Tool',
      inputs: inputs,
      results: results,
      interpretation: 'Comparison of $_selectedMetric across ${validGroups.length} groups',
      references: [
        'CDC Outbreak Investigation Guidelines',
        'https://www.cdc.gov/eis/field-epi-manual/chapters/Outbreak-Investigation.html',
      ],
    );
  }

  Future<void> _exportAsText() async {
    final validGroups = _groups.where((g) => g.isValid).toList();
    if (validGroups.length < 2) return;

    final inputs = {
      'Metric': _selectedMetric,
      'Number of Groups': validGroups.length.toString(),
    };

    final results = <String, dynamic>{};
    for (int i = 0; i < validGroups.length; i++) {
      final group = validGroups[i];
      results[group.name] = '${group.calculatedValue.toStringAsFixed(2)} (${group.numerator}/${group.denominator})';
    }

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Comparison Tool',
      inputs: inputs,
      results: results,
      interpretation: 'Comparison of $_selectedMetric across ${validGroups.length} groups',
      references: [
        'CDC Outbreak Investigation Guidelines',
        'https://www.cdc.gov/eis/field-epi-manual/chapters/Outbreak-Investigation.html',
      ],
    );
  }

  void _loadExample() {
    setState(() {
      _groups.clear();

      // Load example based on selected metric
      switch (_selectedMetric) {
        case 'Case counts':
          // Example: Outbreak case counts across 4 wards
          _groups.addAll([
            ComparisonGroup(name: 'ICU', numerator: 12, denominator: 0, calculatedValue: 12.0),
            ComparisonGroup(name: 'Medical Ward', numerator: 8, denominator: 0, calculatedValue: 8.0),
            ComparisonGroup(name: 'Surgical Ward', numerator: 5, denominator: 0, calculatedValue: 5.0),
            ComparisonGroup(name: 'Emergency Dept', numerator: 15, denominator: 0, calculatedValue: 15.0),
          ]);
          break;

        case 'Attack Rate':
          // Example: HAI attack rates across 3 wards
          _groups.addAll([
            ComparisonGroup(name: 'Ward A', numerator: 15, denominator: 100, calculatedValue: 15.0),
            ComparisonGroup(name: 'Ward B', numerator: 8, denominator: 80, calculatedValue: 10.0),
            ComparisonGroup(name: 'Ward C', numerator: 22, denominator: 120, calculatedValue: 18.3),
          ]);
          break;

        case 'Relative Risk':
          // Example: Risk comparison (Exposed vs Unexposed)
          _groups.addAll([
            ComparisonGroup(name: 'Exposed Group', numerator: 25, denominator: 100, calculatedValue: 0.25),
            ComparisonGroup(name: 'Unexposed Group', numerator: 10, denominator: 150, calculatedValue: 0.067),
          ]);
          break;

        case 'Odds Ratio':
          // Example: Case-control study (Cases vs Controls)
          _groups.addAll([
            ComparisonGroup(name: 'Cases (Exposed)', numerator: 30, denominator: 50, calculatedValue: 0.6),
            ComparisonGroup(name: 'Controls (Exposed)', numerator: 15, denominator: 50, calculatedValue: 0.3),
          ]);
          break;
      }

      // Recalculate metrics with correct formula
      _recalculateMetrics();
    });

    // Show metric-specific message
    String exampleDescription;
    switch (_selectedMetric) {
      case 'Case counts':
        exampleDescription = 'Outbreak case counts across 4 wards (ICU: 12, Medical: 8, Surgical: 5, Emergency: 15)';
        break;
      case 'Attack Rate':
        exampleDescription = 'HAI attack rates across 3 wards (Ward A: 15%, Ward B: 10%, Ward C: 18.3%)';
        break;
      case 'Relative Risk':
        exampleDescription = 'Risk comparison - Exposed (25/100) vs Unexposed (10/150)';
        break;
      case 'Odds Ratio':
        exampleDescription = 'Case-control study - Cases (30/50 exposed) vs Controls (15/50 exposed)';
        break;
      default:
        exampleDescription = 'Example data loaded';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded: $exampleDescription'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
      ),
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
            color: Colors.white,
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

// Data class
class ComparisonGroup {
  String name;
  int numerator;
  int denominator;
  double calculatedValue;

  ComparisonGroup({
    required this.name,
    required this.numerator,
    required this.denominator,
    required this.calculatedValue,
  });

  bool get isValid => name.isNotEmpty && numerator >= 0;
}
