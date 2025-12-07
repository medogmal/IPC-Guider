import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../outbreak/data/models/history_entry.dart';
import '../../../outbreak/data/repositories/history_repository.dart';
import '../../../../core/services/unified_export_service.dart';

class DataPoint {
  final DateTime date;
  final double value;

  DataPoint({required this.date, required this.value});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'value': value,
      };

  factory DataPoint.fromJson(Map<String, dynamic> json) => DataPoint(
        date: DateTime.parse(json['date']),
        value: json['value'],
      );
}

class ComplianceTrendTracker extends ConsumerStatefulWidget {
  const ComplianceTrendTracker({super.key});

  @override
  ConsumerState<ComplianceTrendTracker> createState() => _ComplianceTrendTrackerState();
}

class _ComplianceTrendTrackerState extends ConsumerState<ComplianceTrendTracker> {
  final _metricNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedUnitType = 'ICU';
  List<DataPoint> _dataPoints = [];
  bool _isCalculated = false;

  // Summary statistics
  double? _average;
  double? _highest;
  DateTime? _highestDate;
  double? _lowest;
  DateTime? _lowestDate;
  String? _trendDirection;
  String? _interpretation;

  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Compliance Trend Tracker visualizes compliance metrics over time to identify patterns, trends, and improvement opportunities. Unlike single-point measurements, trend analysis reveals whether compliance is improving, declining, or stable, and helps evaluate the effectiveness of interventions. This tool supports tracking any compliance metric (hand hygiene, bundle compliance, audit scores, observation compliance) across multiple time points with interactive graphing and statistical analysis.',
    formula: 'Trend Analysis = Visual representation of compliance values over time with statistical summary (average, range, direction). Trend direction determined by comparing first half vs second half of data points, or by linear regression for more sophisticated analysis.',
    example: 'Hand Hygiene Compliance tracked monthly: Jan 75%, Feb 78%, Mar 82%, Apr 85%, May 87%, Jun 90% → Average: 82.8%, Trend: Improving ↑ (15% increase over 6 months)',
    interpretation: 'Improving trends (↑) indicate successful interventions and should be sustained. Stable trends (→) may indicate plateau requiring new strategies. Declining trends (↓) require immediate investigation and intervention. Look for patterns: seasonal variations, post-intervention changes, correlation with staffing/workload. Sustained improvement over 3-6 months suggests lasting culture change. Short-term spikes may reflect Hawthorne effect (temporary improvement due to observation).',
    whenUsed: 'Use this tracker to monitor compliance metrics over time (weekly, monthly, quarterly). Essential for evaluating intervention effectiveness, demonstrating program value to leadership, identifying seasonal patterns, setting realistic improvement targets, and maintaining accountability. Requires consistent measurement methodology across all time points. Minimum 3-4 data points recommended for meaningful trend analysis; 6-12 points ideal for identifying patterns.',
    inputDataType: 'Metric name (e.g., "Hand Hygiene Compliance", "CLABSI Bundle Compliance"), unit type, and multiple data points (date + value pairs). Values typically percentages (0-100) or rates. Dates should be evenly spaced when possible (e.g., monthly) for clearer trend visualization. Each data point represents a measurement period (e.g., monthly average, quarterly score).',
    references: [
      Reference(
        title: 'WHO Hand Hygiene Improvement Strategy',
        url: 'https://www.who.int/teams/integrated-health-services/infection-prevention-control/hand-hygiene/improvement-tools',
      ),
      Reference(
        title: 'CDC Quality Improvement Resources',
        url: 'https://www.cdc.gov/infectioncontrol/guidelines/index.html',
      ),
      Reference(
        title: 'IHI Quality Improvement Methods',
        url: 'http://www.ihi.org/resources/Pages/HowtoImprove/default.aspx',
      ),
      Reference(
        title: 'APIC Implementation Guide for Monitoring Programs',
        url: 'https://apic.org/professional-practice/practice-resources/',
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    // Initialize with 3 empty data points
    _dataPoints = [
      DataPoint(date: DateTime.now().subtract(const Duration(days: 60)), value: 0),
      DataPoint(date: DateTime.now().subtract(const Duration(days: 30)), value: 0),
      DataPoint(date: DateTime.now(), value: 0),
    ];
  }

  @override
  void dispose() {
    _metricNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'Compliance Trend Tracker',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
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
              _buildInputCard(),
              const SizedBox(height: 16),
              _buildDataPointsCard(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_isCalculated) ...[
                const SizedBox(height: 24),
                _buildTrendChart(),
                const SizedBox(height: 16),
                _buildSummaryCard(),
                const SizedBox(height: 16),
                _buildDataTable(),
                const SizedBox(height: 16),
                _buildReferences(),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compliance Trend Tracker',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Visualize Compliance Over Time',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                    fontSize = 12.0;
                  } else if (constraints.maxWidth < 400) {
                    fontSize = 14.0;
                  }

                  return Math.tex(
                    r'\text{Compliance Trend} = \text{Track compliance rates over time periods}',
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

  Widget _buildInputCard() {
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
            'Metric Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 20),

          // Metric Name
          TextFormField(
            controller: _metricNameController,
            decoration: InputDecoration(
              labelText: 'Metric Name',
              hintText: 'e.g., Hand Hygiene Compliance',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.label, color: AppColors.primary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter metric name';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Unit Type Dropdown
          DropdownButtonFormField<String>(
            value: _selectedUnitType,
            decoration: InputDecoration(
              labelText: 'Unit Type',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_hospital, color: AppColors.primary),
            ),
            items: const [
              DropdownMenuItem(value: 'ICU', child: Text('ICU (Intensive Care Unit)')),
              DropdownMenuItem(value: 'General Ward', child: Text('General Ward')),
              DropdownMenuItem(value: 'Operating Room', child: Text('Operating Room')),
              DropdownMenuItem(value: 'Emergency Department', child: Text('Emergency Department')),
              DropdownMenuItem(value: 'Facility-wide', child: Text('Facility-wide')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedUnitType = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataPointsCard() {
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
              Text(
                'Data Points',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addDataPoint,
                icon: Icon(Icons.add, color: AppColors.primary),
                label: Text('Add', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._dataPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            return _buildDataPointRow(index, point);
          }),
        ],
      ),
    );
  }

  Widget _buildDataPointRow(int index, DataPoint point) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Date Picker
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _selectDate(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${point.date.day}/${point.date.month}/${point.date.year}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Value Input
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: point.value == 0 ? '' : point.value.toStringAsFixed(1),
              decoration: InputDecoration(
                labelText: 'Value',
                suffixText: '%',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              onChanged: (value) {
                final newValue = double.tryParse(value) ?? 0;
                setState(() {
                  _dataPoints[index] = DataPoint(date: point.date, value: newValue);
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final num = double.tryParse(value);
                if (num == null || num < 0 || num > 100) {
                  return '0-100';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          // Delete Button
          if (_dataPoints.length > 2)
            IconButton(
              onPressed: () => _removeDataPoint(index),
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Remove',
            ),
        ],
      ),
    );
  }

  void _addDataPoint() {
    setState(() {
      final lastDate = _dataPoints.isNotEmpty ? _dataPoints.last.date : DateTime.now();
      _dataPoints.add(DataPoint(
        date: lastDate.add(const Duration(days: 30)),
        value: 0,
      ));
    });
  }

  void _removeDataPoint(int index) {
    if (_dataPoints.length > 2) {
      setState(() {
        _dataPoints.removeAt(index);
      });
    }
  }

  Future<void> _selectDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataPoints[index].date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dataPoints[index] = DataPoint(
          date: picked,
          value: _dataPoints[index].value,
        );
      });
    }
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
          'Analyze Trend',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }



  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate at least 2 data points with non-zero values
    final validPoints = _dataPoints.where((p) => p.value > 0).toList();
    if (validPoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter at least 2 data points with values'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Sort data points by date
    _dataPoints.sort((a, b) => a.date.compareTo(b.date));

    // Calculate statistics
    final values = _dataPoints.map((p) => p.value).toList();
    final sum = values.reduce((a, b) => a + b);
    _average = sum / values.length;

    _highest = values.reduce(max);
    _highestDate = _dataPoints.firstWhere((p) => p.value == _highest).date;

    _lowest = values.reduce(min);
    _lowestDate = _dataPoints.firstWhere((p) => p.value == _lowest).date;

    // Determine trend direction (compare first half vs second half)
    final midPoint = values.length ~/ 2;
    final firstHalf = values.sublist(0, midPoint);
    final secondHalf = values.sublist(midPoint);

    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    final difference = secondAvg - firstAvg;
    final percentChange = (difference / firstAvg) * 100;

    if (percentChange > 5) {
      _trendDirection = 'Improving ↑';
      _interpretation = 'Compliance is improving over time. The average increased by ${percentChange.toStringAsFixed(1)}% from the first half to the second half of the tracking period. This positive trend suggests that interventions are effective and should be sustained.';
    } else if (percentChange < -5) {
      _trendDirection = 'Declining ↓';
      _interpretation = 'Compliance is declining over time. The average decreased by ${percentChange.abs().toStringAsFixed(1)}% from the first half to the second half of the tracking period. This negative trend requires immediate investigation and intervention to reverse the decline.';
    } else {
      _trendDirection = 'Stable →';
      _interpretation = 'Compliance is relatively stable over time with minimal change (${percentChange.toStringAsFixed(1)}%). While stability can indicate consistent performance, consider whether current levels meet targets and if new strategies are needed to achieve further improvement.';
    }

    setState(() {
      _isCalculated = true;
    });
  }

  Widget _buildTrendChart() {
    if (_dataPoints.isEmpty) return const SizedBox.shrink();

    // Prepare data for chart
    final sortedPoints = List<DataPoint>.from(_dataPoints)..sort((a, b) => a.date.compareTo(b.date));
    final spots = sortedPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final maxY = ((sortedPoints.map((p) => p.value).reduce(max) / 10).ceil() * 10.0 + 10).toDouble();
    final minY = max(0.0, (sortedPoints.map((p) => p.value).reduce(min) / 10).floor() * 10.0 - 10);

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
              Icon(Icons.show_chart, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Compliance Trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
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
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedPoints.length) {
                          return const Text('');
                        }
                        final date = sortedPoints[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      reservedSize: 40,
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
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (sortedPoints.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppColors.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        final date = sortedPoints[index].date;
                        return LineTooltipItem(
                          '${date.day}/${date.month}/${date.year}\n${spot.y.toStringAsFixed(1)}%',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSummaryCard() {
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
              Icon(Icons.analytics, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Summary Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Average', '${_average!.toStringAsFixed(1)}%', Icons.show_chart),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Highest',
            '${_highest!.toStringAsFixed(1)}% on ${_highestDate!.day}/${_highestDate!.month}/${_highestDate!.year}',
            Icons.arrow_upward,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Lowest',
            '${_lowest!.toStringAsFixed(1)}% on ${_lowestDate!.day}/${_lowestDate!.month}/${_lowestDate!.year}',
            Icons.arrow_downward,
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Trend Direction', _trendDirection!, Icons.trending_up),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _interpretation!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveToHistory,
                  icon: Icon(Icons.save, color: AppColors.success),
                  label: Text('Save', style: TextStyle(color: AppColors.success)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.success, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showExportOptions(context),
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    final sortedPoints = List<DataPoint>.from(_dataPoints)..sort((a, b) => a.date.compareTo(b.date));

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
              Icon(Icons.table_chart, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Data Points',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppColors.primary.withValues(alpha: 0.1),
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Value',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Change',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Trend',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
              rows: sortedPoints.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                final change = index > 0 ? point.value - sortedPoints[index - 1].value : 0.0;
                final trendIcon = change > 0
                    ? '↑'
                    : change < 0
                        ? '↓'
                        : '→';
                final trendColor = change > 0
                    ? AppColors.success
                    : change < 0
                        ? AppColors.error
                        : AppColors.textSecondary;

                return DataRow(
                  cells: [
                    DataCell(
                      Text('${point.date.day}/${point.date.month}/${point.date.year}'),
                    ),
                    DataCell(
                      Text('${point.value.toStringAsFixed(1)}%'),
                    ),
                    DataCell(
                      Text(
                        index > 0 ? '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%' : '-',
                        style: TextStyle(color: trendColor),
                      ),
                    ),
                    DataCell(
                      Text(
                        index > 0 ? trendIcon : '-',
                        style: TextStyle(color: trendColor, fontSize: 18),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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



  void _loadExample() {
    setState(() {
      _metricNameController.text = 'Hand Hygiene Compliance';
      _selectedUnitType = 'ICU';
      _dataPoints = [
        DataPoint(date: DateTime(2024, 1, 1), value: 75.0),
        DataPoint(date: DateTime(2024, 2, 1), value: 78.0),
        DataPoint(date: DateTime(2024, 3, 1), value: 82.0),
        DataPoint(date: DateTime(2024, 4, 1), value: 85.0),
        DataPoint(date: DateTime(2024, 5, 1), value: 87.0),
        DataPoint(date: DateTime(2024, 6, 1), value: 90.0),
      ];
      _isCalculated = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example data loaded'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showQuickGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
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
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Guide',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: KnowledgePanelWidget(data: _knowledgePanelData),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferences() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.library_books_outlined, color: AppColors.primary, size: 20),
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
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _launchURL(reference.url),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.link, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reference.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Icon(Icons.open_in_new, color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveToHistory() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Compliance Trend Tracker',
        inputs: {
          'Metric Name': _metricNameController.text,
          'Unit Type': _selectedUnitType,
          'Data Points': '${_dataPoints.length} entries',
        },
        result: 'Average: ${_average!.toStringAsFixed(2)}%\n'
            'Highest: ${_highest!.toStringAsFixed(2)}%\n'
            'Lowest: ${_lowest!.toStringAsFixed(2)}%\n'
            'Trend: $_trendDirection\n'
            'Interpretation: $_interpretation',
        notes: '',
        tags: ['ipc', 'compliance', 'trend', 'analytics'],
      );

      await repository.addEntry(historyEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to history'),
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



  void _showExportOptions(BuildContext context) {
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
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Export Options',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: ExportModal(
                    onExportPDF: _exportAsPDF,
                    onExportExcel: _exportAsExcel,
                    onExportCSV: _exportAsCSV,
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

    // Prepare data points for export
    final sortedPoints = List<DataPoint>.from(_dataPoints)..sort((a, b) => a.date.compareTo(b.date));
    final dataPointsText = sortedPoints.map((p) {
      return '${p.date.day}/${p.date.month}/${p.date.year}: ${p.value.toStringAsFixed(1)}%';
    }).join('\n');

    final success = await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Compliance Trend Tracker',
      inputs: {
        'Metric Name': _metricNameController.text,
        'Unit Type': _selectedUnitType,
        'Number of Data Points': '${_dataPoints.length} measurements',
        'Data Points': dataPointsText,
      },
      results: {
        'Average': '${_average!.toStringAsFixed(1)}%',
        'Highest': '${_highest!.toStringAsFixed(1)}% on ${_highestDate!.day}/${_highestDate!.month}/${_highestDate!.year}',
        'Lowest': '${_lowest!.toStringAsFixed(1)}% on ${_lowestDate!.day}/${_lowestDate!.month}/${_lowestDate!.year}',
        'Trend Direction': _trendDirection!,
      },
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => '${r.title}: ${r.url}').toList(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported as PDF'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final sortedPoints = List<DataPoint>.from(_dataPoints)..sort((a, b) => a.date.compareTo(b.date));
    final dataPointsText = sortedPoints.map((p) {
      return '${p.date.day}/${p.date.month}/${p.date.year}: ${p.value.toStringAsFixed(1)}%';
    }).join('\n');

    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Compliance Trend Tracker',
      inputs: {
        'Metric Name': _metricNameController.text,
        'Unit Type': _selectedUnitType,
        'Number of Data Points': '${_dataPoints.length} measurements',
        'Data Points': dataPointsText,
      },
      results: {
        'Average': '${_average!.toStringAsFixed(1)}%',
        'Highest': '${_highest!.toStringAsFixed(1)}% on ${_highestDate!.day}/${_highestDate!.month}/${_highestDate!.year}',
        'Lowest': '${_lowest!.toStringAsFixed(1)}% on ${_lowestDate!.day}/${_lowestDate!.month}/${_lowestDate!.year}',
        'Trend Direction': _trendDirection!,
      },
      interpretation: _interpretation,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported as Excel'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final sortedPoints = List<DataPoint>.from(_dataPoints)..sort((a, b) => a.date.compareTo(b.date));
    final dataPointsText = sortedPoints.map((p) {
      return '${p.date.day}/${p.date.month}/${p.date.year}: ${p.value.toStringAsFixed(1)}%';
    }).join('\n');

    final success = await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Compliance Trend Tracker',
      inputs: {
        'Metric Name': _metricNameController.text,
        'Unit Type': _selectedUnitType,
        'Number of Data Points': '${_dataPoints.length} measurements',
        'Data Points': dataPointsText,
      },
      results: {
        'Average': '${_average!.toStringAsFixed(1)}%',
        'Highest': '${_highest!.toStringAsFixed(1)}% on ${_highestDate!.day}/${_highestDate!.month}/${_highestDate!.year}',
        'Lowest': '${_lowest!.toStringAsFixed(1)}% on ${_lowestDate!.day}/${_lowestDate!.month}/${_lowestDate!.year}',
        'Trend Direction': _trendDirection!,
      },
      interpretation: _interpretation,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported as CSV'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final sortedPoints = List<DataPoint>.from(_dataPoints)..sort((a, b) => a.date.compareTo(b.date));
    final dataPointsText = sortedPoints.map((p) {
      return '${p.date.day}/${p.date.month}/${p.date.year}: ${p.value.toStringAsFixed(1)}%';
    }).join('\n');

    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Compliance Trend Tracker',
      inputs: {
        'Metric Name': _metricNameController.text,
        'Unit Type': _selectedUnitType,
        'Number of Data Points': '${_dataPoints.length} measurements',
        'Data Points': dataPointsText,
      },
      results: {
        'Average': '${_average!.toStringAsFixed(1)}%',
        'Highest': '${_highest!.toStringAsFixed(1)}% on ${_highestDate!.day}/${_highestDate!.month}/${_highestDate!.year}',
        'Lowest': '${_lowest!.toStringAsFixed(1)}% on ${_lowestDate!.day}/${_lowestDate!.month}/${_lowestDate!.year}',
        'Trend Direction': _trendDirection!,
      },
      interpretation: _interpretation,
      references: _knowledgePanelData.references.map((r) => '${r.title}: ${r.url}').toList(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported as Text'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

