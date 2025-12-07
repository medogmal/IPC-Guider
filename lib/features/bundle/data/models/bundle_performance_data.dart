import 'bundle_tool_enums.dart';

/// Performance data for Bundle Performance Dashboard
class BundlePerformanceData {
  final DateTime startDate;
  final DateTime endDate;
  final List<BundleType> selectedBundles;
  final List<String> selectedUnits;

  // Key Performance Indicators
  final double overallCompliance;
  final int totalAudits;
  final int bundlesMeetingTarget;
  final int totalBundles;
  final PerformanceTrend trend;

  // Bundle-specific metrics
  final Map<BundleType, BundleMetrics> bundleMetrics;

  // Time series data for charts
  final List<ComplianceDataPoint> complianceOverTime;

  // Element-level analysis
  final List<ElementPerformance> elementPerformance;

  BundlePerformanceData({
    required this.startDate,
    required this.endDate,
    required this.selectedBundles,
    required this.selectedUnits,
    required this.overallCompliance,
    required this.totalAudits,
    required this.bundlesMeetingTarget,
    required this.totalBundles,
    required this.trend,
    required this.bundleMetrics,
    required this.complianceOverTime,
    required this.elementPerformance,
  });

  /// Factory constructor to generate sample/demo data
  factory BundlePerformanceData.sample({
    required DateTime startDate,
    required DateTime endDate,
    required List<BundleType> selectedBundles,
    required List<String> selectedUnits,
  }) {
    // Generate sample bundle metrics
    final bundleMetrics = <BundleType, BundleMetrics>{};
    for (final bundle in selectedBundles) {
      bundleMetrics[bundle] = BundleMetrics.sample(bundle);
    }

    // Calculate overall compliance
    final overallCompliance = bundleMetrics.values.isEmpty
        ? 0.0
        : bundleMetrics.values.map((m) => m.compliance).reduce((a, b) => a + b) /
            bundleMetrics.length;

    // Count bundles meeting target (≥95%)
    final bundlesMeetingTarget =
        bundleMetrics.values.where((m) => m.compliance >= 95.0).length;

    // Generate time series data (last 30 days)
    final complianceOverTime = _generateTimeSeriesData(startDate, endDate);

    // Generate element performance data
    final elementPerformance = _generateElementPerformance(selectedBundles);

    // Determine trend
    final trend = _calculateTrend(complianceOverTime);

    return BundlePerformanceData(
      startDate: startDate,
      endDate: endDate,
      selectedBundles: selectedBundles,
      selectedUnits: selectedUnits,
      overallCompliance: overallCompliance,
      totalAudits: 45, // Sample value
      bundlesMeetingTarget: bundlesMeetingTarget,
      totalBundles: selectedBundles.length,
      trend: trend,
      bundleMetrics: bundleMetrics,
      complianceOverTime: complianceOverTime,
      elementPerformance: elementPerformance,
    );
  }

  static List<ComplianceDataPoint> _generateTimeSeriesData(
    DateTime startDate,
    DateTime endDate,
  ) {
    final dataPoints = <ComplianceDataPoint>[];
    final days = endDate.difference(startDate).inDays;
    final interval = days > 30 ? 7 : 1; // Weekly if > 30 days, daily otherwise

    for (int i = 0; i <= days; i += interval) {
      final date = startDate.add(Duration(days: i));
      // Generate sample compliance data with slight upward trend
      final baseCompliance = 82.0;
      final trend = (i / days) * 8.0; // +8% over period
      final variance = (i % 3) * 2.0; // Some variance
      final compliance = (baseCompliance + trend + variance).clamp(75.0, 98.0);

      dataPoints.add(ComplianceDataPoint(
        date: date,
        compliance: compliance,
      ));
    }

    return dataPoints;
  }

  static List<ElementPerformance> _generateElementPerformance(
    List<BundleType> bundles,
  ) {
    final elements = <ElementPerformance>[];

    // Sample element performance data
    elements.addAll([
      ElementPerformance(
        elementName: 'Hand Hygiene',
        compliance: 95.5,
        audits: 45,
        trend: PerformanceTrend.improving,
      ),
      ElementPerformance(
        elementName: 'Maximal Barrier Precautions',
        compliance: 88.2,
        audits: 45,
        trend: PerformanceTrend.stable,
      ),
      ElementPerformance(
        elementName: 'Chlorhexidine Skin Prep',
        compliance: 92.1,
        audits: 45,
        trend: PerformanceTrend.improving,
      ),
      ElementPerformance(
        elementName: 'Optimal Catheter Site Selection',
        compliance: 85.7,
        audits: 45,
        trend: PerformanceTrend.declining,
      ),
      ElementPerformance(
        elementName: 'Daily Review of Line Necessity',
        compliance: 78.9,
        audits: 45,
        trend: PerformanceTrend.declining,
      ),
    ]);

    return elements;
  }

  static PerformanceTrend _calculateTrend(List<ComplianceDataPoint> dataPoints) {
    if (dataPoints.length < 2) return PerformanceTrend.stable;

    final firstHalf = dataPoints.take(dataPoints.length ~/ 2).toList();
    final secondHalf = dataPoints.skip(dataPoints.length ~/ 2).toList();

    final firstAvg = firstHalf.map((d) => d.compliance).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((d) => d.compliance).reduce((a, b) => a + b) /
            secondHalf.length;

    final diff = secondAvg - firstAvg;

    if (diff > 2.0) return PerformanceTrend.improving;
    if (diff < -2.0) return PerformanceTrend.declining;
    return PerformanceTrend.stable;
  }
}

/// Bundle-specific metrics
class BundleMetrics {
  final BundleType bundleType;
  final double compliance;
  final int audits;
  final PerformanceTrend trend;

  BundleMetrics({
    required this.bundleType,
    required this.compliance,
    required this.audits,
    required this.trend,
  });

  factory BundleMetrics.sample(BundleType bundleType) {
    // Generate sample data with variation by bundle type
    final baseCompliance = {
      BundleType.clabsi: 92.5,
      BundleType.cauti: 88.3,
      BundleType.vap: 90.1,
      BundleType.ssi: 94.2,
      BundleType.sepsis: 85.7,
    };

    final trends = [
      PerformanceTrend.improving,
      PerformanceTrend.stable,
      PerformanceTrend.declining,
    ];

    return BundleMetrics(
      bundleType: bundleType,
      compliance: baseCompliance[bundleType] ?? 90.0,
      audits: 12,
      trend: trends[bundleType.index % trends.length],
    );
  }
}

/// Data point for compliance over time chart
class ComplianceDataPoint {
  final DateTime date;
  final double compliance;

  ComplianceDataPoint({
    required this.date,
    required this.compliance,
  });
}

/// Element-level performance data
class ElementPerformance {
  final String elementName;
  final double compliance;
  final int audits;
  final PerformanceTrend trend;

  ElementPerformance({
    required this.elementName,
    required this.compliance,
    required this.audits,
    required this.trend,
  });
}

/// Performance trend indicator
enum PerformanceTrend {
  improving('Improving', '↑'),
  stable('Stable', '→'),
  declining('Declining', '↓');

  final String displayName;
  final String symbol;

  const PerformanceTrend(this.displayName, this.symbol);
}

