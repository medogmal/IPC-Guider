import 'package:flutter/material.dart';

/// Data model for Bundle Comparison Tool
/// Compares bundle compliance across different dimensions (bundles, units, time periods)
class BundleComparisonData {
  final String id;
  final DateTime comparisonDate;
  final String comparisonType; // 'bundles', 'units', 'time-periods'
  final List<ComparisonDataset> datasets;
  final ComparisonSummary summary;
  final List<String> insights;
  final List<String> recommendations;

  BundleComparisonData({
    required this.id,
    required this.comparisonDate,
    required this.comparisonType,
    required this.datasets,
    required this.summary,
    required this.insights,
    required this.recommendations,
  });

  /// Factory constructor to calculate comparison from user input data
  factory BundleComparisonData.fromUserInput({
    required String comparisonType,
    required List<ComparisonDataset> datasets,
  }) {
    final now = DateTime.now();

    // Calculate summary from actual user data
    final avgCompliance = datasets.map((d) => d.compliancePercentage).reduce((a, b) => a + b) / datasets.length;
    final bestPerformer = datasets.reduce((a, b) => a.compliancePercentage > b.compliancePercentage ? a : b);
    final worstPerformer = datasets.reduce((a, b) => a.compliancePercentage < b.compliancePercentage ? a : b);
    final totalAudits = datasets.map((d) => d.totalAudits).reduce((a, b) => a + b);

    final summary = ComparisonSummary(
      averageCompliance: avgCompliance,
      bestPerformer: bestPerformer.name,
      bestPerformerScore: bestPerformer.compliancePercentage,
      worstPerformer: worstPerformer.name,
      worstPerformerScore: worstPerformer.compliancePercentage,
      complianceRange: bestPerformer.compliancePercentage - worstPerformer.compliancePercentage,
      totalAudits: totalAudits,
    );

    // Generate insights based on actual data
    final insights = <String>[
      'Average compliance across all datasets: ${avgCompliance.toStringAsFixed(1)}%',
      'Best performer: ${bestPerformer.name} (${bestPerformer.compliancePercentage.toStringAsFixed(1)}%)',
      'Needs improvement: ${worstPerformer.name} (${worstPerformer.compliancePercentage.toStringAsFixed(1)}%)',
      'Compliance range: ${(bestPerformer.compliancePercentage - worstPerformer.compliancePercentage).toStringAsFixed(1)}% gap',
      if (avgCompliance >= 90) 'Overall performance is excellent across all datasets',
      if (avgCompliance >= 80 && avgCompliance < 90) 'Overall performance is good but has room for improvement',
      if (avgCompliance < 80) 'Overall performance requires immediate attention and intervention',
      if (summary.complianceRange > 20) 'Significant performance variation detected across datasets',
      if (summary.complianceRange <= 10) 'Performance is consistent across all datasets',
    ];

    // Generate recommendations based on actual data
    final recommendations = <String>[
      if (worstPerformer.compliancePercentage < 75) 'Priority: Focus improvement efforts on ${worstPerformer.name}',
      if (summary.complianceRange > 20) 'Investigate root causes of large performance gap (${summary.complianceRange.toStringAsFixed(1)}%)',
      if (bestPerformer.compliancePercentage >= 90) 'Share best practices from ${bestPerformer.name} with other $comparisonType',
      'Conduct targeted training for low-performing areas',
      'Implement regular monitoring and feedback loops',
      if (avgCompliance < 80) 'Consider immediate intervention and resource allocation',
      'Schedule follow-up audits to track improvement',
    ];

    return BundleComparisonData(
      id: 'comparison_${now.millisecondsSinceEpoch}',
      comparisonDate: now,
      comparisonType: comparisonType,
      datasets: datasets,
      summary: summary,
      insights: insights,
      recommendations: recommendations,
    );
  }



  Map<String, dynamic> toJson() => {
        'id': id,
        'comparisonDate': comparisonDate.toIso8601String(),
        'comparisonType': comparisonType,
        'datasets': datasets.map((d) => d.toJson()).toList(),
        'summary': summary.toJson(),
        'insights': insights,
        'recommendations': recommendations,
      };
}

/// Individual dataset in comparison
class ComparisonDataset {
  final String name;
  final String category;
  final double compliancePercentage;
  final int totalAudits;
  final double compliantAudits;
  final Map<String, double>? elementCompliance; // Optional
  final String? trend; // Optional: 'Improving', 'Stable', 'Declining'
  final double? trendPercentage; // Optional

  ComparisonDataset({
    required this.name,
    required this.category,
    required this.compliancePercentage,
    required this.totalAudits,
    required this.compliantAudits,
    this.elementCompliance,
    this.trend,
    this.trendPercentage,
  });

  Color get trendColor {
    if (trend == null) return Colors.grey;
    if (trend == 'Improving') return Colors.green;
    if (trend == 'Declining') return Colors.red;
    return Colors.grey;
  }

  IconData get trendIcon {
    if (trend == null) return Icons.trending_flat;
    if (trend == 'Improving') return Icons.trending_up;
    if (trend == 'Declining') return Icons.trending_down;
    return Icons.trending_flat;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'compliancePercentage': compliancePercentage,
        'totalAudits': totalAudits,
        'compliantAudits': compliantAudits,
        'elementCompliance': elementCompliance,
        'trend': trend,
        'trendPercentage': trendPercentage,
      };
}

/// Summary of comparison results
class ComparisonSummary {
  final double averageCompliance;
  final String bestPerformer;
  final double bestPerformerScore;
  final String worstPerformer;
  final double worstPerformerScore;
  final double complianceRange;
  final int totalAudits;

  ComparisonSummary({
    required this.averageCompliance,
    required this.bestPerformer,
    required this.bestPerformerScore,
    required this.worstPerformer,
    required this.worstPerformerScore,
    required this.complianceRange,
    required this.totalAudits,
  });

  Map<String, dynamic> toJson() => {
        'averageCompliance': averageCompliance,
        'bestPerformer': bestPerformer,
        'bestPerformerScore': bestPerformerScore,
        'worstPerformer': worstPerformer,
        'worstPerformerScore': worstPerformerScore,
        'complianceRange': complianceRange,
        'totalAudits': totalAudits,
      };
}

/// Helper class to collect input data for each dataset before running comparison
class ComparisonInputData {
  final String name;
  final int totalAudits;
  final int compliantAudits;
  final String? trend;

  ComparisonInputData({
    required this.name,
    required this.totalAudits,
    required this.compliantAudits,
    this.trend,
  });

  double get compliancePercentage {
    if (totalAudits == 0) return 0.0;
    return (compliantAudits / totalAudits) * 100;
  }

  ComparisonDataset toDataset(String category) {
    return ComparisonDataset(
      name: name,
      category: category,
      compliancePercentage: compliancePercentage,
      totalAudits: totalAudits,
      compliantAudits: compliantAudits.toDouble(),
      trend: trend,
      trendPercentage: null,
    );
  }
}
