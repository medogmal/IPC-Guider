import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/back_button.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../../features/outbreak/data/repositories/history_repository.dart';
import '../../../../../features/outbreak/data/models/history_entry.dart';
import '../../../data/models/bundle_tool_enums.dart';
import '../../../data/models/bundle_performance_data.dart';
import '../../widgets/tools/bundle_tool_header.dart';
import '../../widgets/tools/bundle_tool_input_card.dart';

class BundlePerformanceDashboardScreen extends StatefulWidget {
  const BundlePerformanceDashboardScreen({super.key});

  @override
  State<BundlePerformanceDashboardScreen> createState() =>
      _BundlePerformanceDashboardScreenState();
}

class _BundlePerformanceDashboardScreenState
    extends State<BundlePerformanceDashboardScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final List<BundleType> _selectedBundles = [];
  final List<String> _selectedUnits = [];

  BundlePerformanceData? _performanceData;

  final List<String> _availableUnits = [
    'All Units',
    'ICU',
    'Medical Ward',
    'Surgical Ward',
    'OR',
    'Emergency Department',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select all bundles by default
    _selectedBundles.addAll(BundleType.values);
    _selectedUnits.add('All Units');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Bundle Performance Dashboard',
        fitTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.large,
            AppSpacing.large,
            AppSpacing.large, // Bottom padding for mobile
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              BundleToolHeader(
                title: 'Bundle Performance Dashboard',
                description:
                    'Executive-level overview of bundle compliance metrics with visual analytics',
                icon: Icons.dashboard_outlined,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.medium),

              // Quick Guide button
              _buildQuickGuideButton(),
              const SizedBox(height: AppSpacing.medium),

              // Load Example button
              _buildLoadExampleButton(),
              const SizedBox(height: AppSpacing.large),

              // Time Period Selection
              BundleToolInputCard(
                title: 'Time Period',
                icon: Icons.date_range,
                child: Column(
                  children: [
                    // Start Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Start Date'),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _selectStartDate(context),
                    ),
                    const Divider(),
                    // End Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('End Date'),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _selectEndDate(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Bundle Selection
              BundleToolInputCard(
                title: 'Bundle Selection',
                icon: Icons.category_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select bundles to include in dashboard:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    ...BundleType.values.map((bundle) {
                      final isSelected = _selectedBundles.contains(bundle);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(bundle.shortName, style: const TextStyle(fontSize: 14)),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedBundles.add(bundle);
                            } else {
                              _selectedBundles.remove(bundle);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Unit Selection
              BundleToolInputCard(
                title: 'Unit Selection',
                icon: Icons.business_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select units to include in dashboard:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    ..._availableUnits.map((unit) {
                      final isSelected = _selectedUnits.contains(unit);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(unit, style: const TextStyle(fontSize: 14)),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedUnits.add(unit);
                            } else {
                              _selectedUnits.remove(unit);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.large),

              // Generate Dashboard Button
              ElevatedButton.icon(
                onPressed: _generateDashboard,
                icon: const Icon(Icons.analytics, size: 20),
                label: const Text('Generate Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // Results
              if (_performanceData != null) ...[
                const SizedBox(height: AppSpacing.large),
                _buildDashboardSection(),
                const SizedBox(height: AppSpacing.large), // Extra bottom padding after results
              ],

              // References (always visible)
              const SizedBox(height: AppSpacing.large),
              _buildReferencesSection(),
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
    );
  }

  Widget _buildLoadExampleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loadExampleData,
        icon: Icon(Icons.lightbulb_outline, color: AppColors.success),
        label: Text(
          'Load Example Data',
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
    );
  }

  Widget _buildDashboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header with Save/Export buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dashboard Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                // Save Button
                ElevatedButton.icon(
                  onPressed: _saveDashboard,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Export Button
                OutlinedButton.icon(
                  onPressed: _showExportModal,
                  icon: Icon(Icons.file_download, size: 18, color: AppColors.primary),
                  label: Text(
                    'Export',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),

        // KPIs
        _buildKPIsCard(),
        const SizedBox(height: AppSpacing.medium),

        // Bundle-Specific Metrics
        _buildBundleMetricsCard(),
        const SizedBox(height: AppSpacing.medium),

        // Compliance Over Time Chart
        _buildComplianceChartCard(),
        const SizedBox(height: AppSpacing.medium),

        // Element Performance
        _buildElementPerformanceCard(),
      ],
    );
  }

  Widget _buildKPIsCard() {
    final data = _performanceData!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Key Performance Indicators',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            // KPI Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: AppSpacing.small,
              crossAxisSpacing: AppSpacing.small,
              children: [
                _buildKPIItem(
                  'Overall Compliance',
                  '${data.overallCompliance.toStringAsFixed(1)}%',
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
                _buildKPIItem(
                  'Total Audits',
                  '${data.totalAudits}',
                  Icons.assignment_outlined,
                  AppColors.info,
                ),
                _buildKPIItem(
                  'Bundles Meeting Target',
                  '${data.bundlesMeetingTarget}/${data.totalBundles}',
                  Icons.flag_outlined,
                  AppColors.warning,
                ),
                _buildKPIItem(
                  'Trend',
                  data.trend.displayName,
                  data.trend == PerformanceTrend.improving
                      ? Icons.trending_up
                      : data.trend == PerformanceTrend.declining
                          ? Icons.trending_down
                          : Icons.trending_flat,
                  data.trend == PerformanceTrend.improving
                      ? AppColors.success
                      : data.trend == PerformanceTrend.declining
                          ? AppColors.error
                          : AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.small),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundleMetricsCard() {
    final data = _performanceData!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Bundle-Specific Metrics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ...data.bundleMetrics.entries.map((entry) {
              final bundle = entry.key;
              final metrics = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        bundle.shortName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${metrics.compliance.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: metrics.compliance >= 95
                              ? AppColors.success
                              : metrics.compliance >= 85
                                  ? AppColors.warning
                                  : AppColors.error,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(
                            metrics.trend == PerformanceTrend.improving
                                ? Icons.trending_up
                                : metrics.trend == PerformanceTrend.declining
                                    ? Icons.trending_down
                                    : Icons.trending_flat,
                            size: 16,
                            color: metrics.trend == PerformanceTrend.improving
                                ? AppColors.success
                                : metrics.trend == PerformanceTrend.declining
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            metrics.trend.symbol,
                            style: TextStyle(
                              fontSize: 14,
                              color: metrics.trend == PerformanceTrend.improving
                                  ? AppColors.success
                                  : metrics.trend == PerformanceTrend.declining
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceChartCard() {
    final data = _performanceData!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Compliance Over Time',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.textSecondary.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (data.complianceOverTime.length / 5).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < data.complianceOverTime.length) {
                            final date = data.complianceOverTime[value.toInt()].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('MM/dd').format(date),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
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
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: (data.complianceOverTime.length - 1).toDouble(),
                  minY: 70,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.complianceOverTime
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                                e.key.toDouble(),
                                e.value.compliance,
                              ))
                          .toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementPerformanceCard() {
    final data = _performanceData!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Element-Level Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ...data.elementPerformance.map((element) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            element.elementName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${element.compliance.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: element.compliance >= 95
                                    ? AppColors.success
                                    : element.compliance >= 85
                                        ? AppColors.warning
                                        : AppColors.error,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              element.trend == PerformanceTrend.improving
                                  ? Icons.trending_up
                                  : element.trend == PerformanceTrend.declining
                                      ? Icons.trending_down
                                      : Icons.trending_flat,
                              size: 16,
                              color: element.trend == PerformanceTrend.improving
                                  ? AppColors.success
                                  : element.trend == PerformanceTrend.declining
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: element.compliance / 100,
                      backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        element.compliance >= 95
                            ? AppColors.success
                            : element.compliance >= 85
                                ? AppColors.warning
                                : AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReferencesSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'References',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildReferenceItem(
              'CDC. National Healthcare Safety Network (NHSN) - Bundle Compliance',
              'https://www.cdc.gov/nhsn/psc/index.html',
            ),
            const SizedBox(height: AppSpacing.small),
            _buildReferenceItem(
              'WHO. Guidelines on Core Components of IPC Programmes',
              'https://www.who.int/publications/i/item/9789241549929',
            ),
            const SizedBox(height: AppSpacing.small),
            _buildReferenceItem(
              'APIC. Implementation Guide: Bundle Performance Monitoring',
              'https://apic.org/resources/',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceItem(String title, String url) {
    return InkWell(
      onTap: () {
        // Open URL in browser
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.link, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Date Selection Methods
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  // Quick Guide
  void _showQuickGuide() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book, color: AppColors.info),
                  const SizedBox(width: 8),
                  const Text(
                    'Quick Guide',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              const Text(
                'Bundle Performance Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              const Text(
                'This tool provides an executive-level overview of bundle compliance metrics with visual analytics.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.medium),
              const Text(
                'How to Use:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              _buildGuideStep('1', 'Select time period (start and end dates)'),
              _buildGuideStep('2', 'Select bundles to include in analysis'),
              _buildGuideStep('3', 'Select units to include in analysis'),
              _buildGuideStep('4', 'Tap "Generate Dashboard" to view results'),
              _buildGuideStep('5', 'Review KPIs, trends, and element performance'),
              _buildGuideStep('6', 'Save or export dashboard for reporting'),
              const SizedBox(height: AppSpacing.medium),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // Load Example Data
  void _loadExampleData() {
    setState(() {
      _startDate = DateTime.now().subtract(const Duration(days: 30));
      _endDate = DateTime.now();
      _selectedBundles.clear();
      _selectedBundles.addAll([
        BundleType.clabsi,
        BundleType.cauti,
        BundleType.vap,
      ]);
      _selectedUnits.clear();
      _selectedUnits.addAll(['ICU', 'Medical Ward']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Example data loaded successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Generate Dashboard
  void _generateDashboard() {
    if (_selectedBundles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one bundle'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedUnits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one unit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _performanceData = BundlePerformanceData.sample(
        startDate: _startDate,
        endDate: _endDate,
        selectedBundles: _selectedBundles,
        selectedUnits: _selectedUnits,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dashboard generated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Save Dashboard
  Future<void> _saveDashboard() async {
    if (_performanceData == null) return;

    final data = _performanceData!;
    final entry = HistoryEntry(
      timestamp: DateTime.now(),
      toolType: 'Bundle Performance Dashboard',
      title: 'Dashboard: ${DateFormat('MMM dd, yyyy').format(data.startDate)} - ${DateFormat('MMM dd, yyyy').format(data.endDate)}',
      inputs: {
        'Start Date': DateFormat('MMM dd, yyyy').format(data.startDate),
        'End Date': DateFormat('MMM dd, yyyy').format(data.endDate),
        'Bundles': data.selectedBundles.map((b) => b.shortName).join(', '),
        'Units': data.selectedUnits.join(', '),
      },
      result: '${data.overallCompliance.toStringAsFixed(1)}% Overall Compliance',
      notes: 'Trend: ${data.trend.displayName} | Audits: ${data.totalAudits} | Bundles Meeting Target: ${data.bundlesMeetingTarget}/${data.totalBundles}',
    );

    await HistoryRepository().addEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard saved to history'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Export Modal
  void _showExportModal() {
    if (_performanceData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: ExportModal(
          onExportPDF: () async {
            Navigator.pop(context);
            await _exportAsPDF();
          },
          onExportCSV: () async {
            Navigator.pop(context);
            await _exportAsCSV();
          },
          onExportExcel: () async {
            Navigator.pop(context);
            await _exportAsExcel();
          },
          onExportText: () async {
            Navigator.pop(context);
            await _exportAsText();
          },
        ),
      ),
    );
  }

  // Export Methods
  Future<void> _exportAsPDF() async {
    if (_performanceData == null) return;

    final data = _performanceData!;
    final inputs = {
      'Time Period': '${DateFormat('MMM dd, yyyy').format(data.startDate)} - ${DateFormat('MMM dd, yyyy').format(data.endDate)}',
      'Bundles': data.selectedBundles.map((b) => b.shortName).join(', '),
      'Units': data.selectedUnits.join(', '),
    };

    final results = {
      'Overall Compliance': '${data.overallCompliance.toStringAsFixed(1)}%',
      'Total Audits': '${data.totalAudits}',
      'Bundles Meeting Target': '${data.bundlesMeetingTarget}/${data.totalBundles}',
      'Trend': '${data.trend.displayName} ${data.trend.symbol}',
    };

    final interpretation = _buildInterpretationText();
    final recommendations = _buildRecommendationsText();

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Bundle Performance Dashboard',
      inputs: inputs,
      results: results,
      interpretation: interpretation,
      recommendations: recommendations,
    );
  }

  Future<void> _exportAsExcel() async {
    if (_performanceData == null) return;

    final data = _performanceData!;
    final inputs = {
      'Time Period': '${DateFormat('MMM dd, yyyy').format(data.startDate)} - ${DateFormat('MMM dd, yyyy').format(data.endDate)}',
      'Bundles': data.selectedBundles.map((b) => b.shortName).join(', '),
      'Units': data.selectedUnits.join(', '),
    };

    final results = {
      'Overall Compliance': '${data.overallCompliance.toStringAsFixed(1)}%',
      'Total Audits': '${data.totalAudits}',
      'Bundles Meeting Target': '${data.bundlesMeetingTarget}/${data.totalBundles}',
      'Trend': '${data.trend.displayName} ${data.trend.symbol}',
    };

    final interpretation = _buildInterpretationText();
    final recommendations = _buildRecommendationsText();

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Bundle Performance Dashboard',
      inputs: inputs,
      results: results,
      interpretation: interpretation,
      recommendations: recommendations,
    );
  }

  Future<void> _exportAsCSV() async {
    if (_performanceData == null) return;

    final data = _performanceData!;
    final inputs = {
      'Time Period': '${DateFormat('MMM dd, yyyy').format(data.startDate)} - ${DateFormat('MMM dd, yyyy').format(data.endDate)}',
      'Bundles': data.selectedBundles.map((b) => b.shortName).join(', '),
      'Units': data.selectedUnits.join(', '),
    };

    final results = {
      'Overall Compliance': '${data.overallCompliance.toStringAsFixed(1)}%',
      'Total Audits': '${data.totalAudits}',
      'Bundles Meeting Target': '${data.bundlesMeetingTarget}/${data.totalBundles}',
      'Trend': '${data.trend.displayName} ${data.trend.symbol}',
    };

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Bundle Performance Dashboard',
      inputs: inputs,
      results: results,
    );
  }

  Future<void> _exportAsText() async {
    if (_performanceData == null) return;

    final data = _performanceData!;
    final inputs = {
      'Time Period': '${DateFormat('MMM dd, yyyy').format(data.startDate)} - ${DateFormat('MMM dd, yyyy').format(data.endDate)}',
      'Bundles': data.selectedBundles.map((b) => b.shortName).join(', '),
      'Units': data.selectedUnits.join(', '),
    };

    final results = {
      'Overall Compliance': '${data.overallCompliance.toStringAsFixed(1)}%',
      'Total Audits': '${data.totalAudits}',
      'Bundles Meeting Target': '${data.bundlesMeetingTarget}/${data.totalBundles}',
      'Trend': '${data.trend.displayName} ${data.trend.symbol}',
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Bundle Performance Dashboard',
      inputs: inputs,
      results: results,
    );
  }

  String _buildInterpretationText() {
    if (_performanceData == null) return '';

    final data = _performanceData!;
    final buffer = StringBuffer();

    buffer.writeln('Dashboard Summary:');
    buffer.writeln('Overall bundle compliance is ${data.overallCompliance.toStringAsFixed(1)}% across ${data.totalAudits} audits.');
    buffer.writeln('${data.bundlesMeetingTarget} out of ${data.totalBundles} bundles are meeting the target of ≥95% compliance.');
    buffer.writeln('Performance trend: ${data.trend.displayName} ${data.trend.symbol}');

    return buffer.toString();
  }

  String _buildRecommendationsText() {
    if (_performanceData == null) return '';

    final data = _performanceData!;
    final buffer = StringBuffer();

    buffer.writeln('Recommendations:');

    if (data.overallCompliance < 95) {
      buffer.writeln('• Focus on improving compliance to reach the 95% target');
    }

    if (data.trend == PerformanceTrend.declining) {
      buffer.writeln('• Investigate causes of declining performance');
      buffer.writeln('• Implement corrective actions immediately');
    }

    // Find lowest performing elements
    final lowElements = data.elementPerformance
        .where((e) => e.compliance < 85)
        .toList()
      ..sort((a, b) => a.compliance.compareTo(b.compliance));

    if (lowElements.isNotEmpty) {
      buffer.writeln('• Priority elements needing improvement:');
      for (final element in lowElements.take(3)) {
        buffer.writeln('  - ${element.elementName}: ${element.compliance.toStringAsFixed(1)}%');
      }
    }

    return buffer.toString();
  }
}
