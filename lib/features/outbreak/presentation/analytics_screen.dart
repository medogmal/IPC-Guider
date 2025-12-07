import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/back_button.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Analytics & Interactive Tools',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
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
            Container(
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.analytics_outlined,
                          color: AppColors.info,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analytics & Interactive Tools Hub',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Comprehensive collection of outbreak analysis calculators and interactive tools',
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
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Calculators Section
            _buildSection(
              context,
              'Epidemiological Calculators',
              Icons.calculate_outlined,
              AppColors.primary,
              [
                _ToolItem(
                  'Attack Rate Calculator',
                  'Calculate attack rates with 95% confidence intervals',
                  Icons.trending_up_outlined,
                  '/outbreak/analytics/attack-rate',
                ),
                _ToolItem(
                  'Secondary Attack Rate Calculator',
                  'Transmission analysis among exposed contacts',
                  Icons.people_outline,
                  '/outbreak/analytics/secondary-attack-rate',
                ),
                _ToolItem(
                  'Relative Risk Calculator',
                  'Calculate relative risk from 2x2 contingency tables',
                  Icons.compare_arrows_outlined,
                  '/outbreak/analytics/relative-risk',
                ),
                _ToolItem(
                  'Odds Ratio Calculator',
                  'Calculate odds ratios with confidence intervals',
                  Icons.balance_outlined,
                  '/outbreak/analytics/odds-ratio',
                ),
                _ToolItem(
                  'Case Fatality Rate Calculator',
                  'Outbreak severity and mortality analysis',
                  Icons.emergency_outlined,
                  '/outbreak/analytics/case-fatality-rate',
                ),
                _ToolItem(
                  'Sensitivity & Specificity Calculator',
                  'Calculate diagnostic test performance metrics',
                  Icons.medical_services_outlined,
                  '/outbreak/analytics/enhanced-sensitivity-specificity',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Advanced Statistics Section
            _buildSection(
              context,
              'Advanced Statistical Analysis',
              Icons.functions_outlined,
              AppColors.primary,
              [
                _ToolItem(
                  'P-Value Calculator',
                  'Calculate statistical significance for hypothesis testing',
                  Icons.analytics_outlined,
                  '/outbreak/analytics/p-value',
                ),
                _ToolItem(
                  'Sample Size Calculator',
                  'Determine required sample size for outbreak studies',
                  Icons.people_outline,
                  '/outbreak/analytics/sample-size',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Visualization Tools Section
            _buildSection(
              context,
              'Visualization & Analysis Tools',
              Icons.bar_chart_outlined,
              AppColors.primary,
              [
                _ToolItem(
                  'Epidemic Curve Generator',
                  'Create epidemic curves with pattern recognition',
                  Icons.timeline_outlined,
                  '/outbreak/analytics/enhanced-epidemic-curve',
                ),
                _ToolItem(
                  'Outbreak Timeline Tool',
                  'Build visual timelines of outbreak events',
                  Icons.schedule_outlined,
                  '/outbreak/analytics/timeline',
                ),
                _ToolItem(
                  'Histogram Tool',
                  'Generate histograms for age, onset, and other variables',
                  Icons.bar_chart,
                  '/outbreak/analytics/histogram',
                ),
                _ToolItem(
                  'Comparison Tool',
                  'Compare metrics across different groups',
                  Icons.compare_outlined,
                  '/outbreak/analytics/comparison',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data Management Tools Section
            _buildSection(
              context,
              'Data & Documentation',
              Icons.data_usage_outlined,
              AppColors.primary,
              [
                _ToolItem(
                  'Case Definition Builder',
                  'Create structured case definitions',
                  Icons.description_outlined,
                  '/outbreak/analytics/case-definition',
                ),
                _ToolItem(
                  'Line List Tool',
                  'Manage case-level data and generate visualizations',
                  Icons.table_chart_outlined,
                  '/outbreak/analytics/line-list',
                ),
                _ToolItem(
                  'Control Checklist',
                  'Interactive outbreak control measures checklist',
                  Icons.checklist_outlined,
                  '/outbreak/analytics/control-checklist',
                ),
                _ToolItem(
                  'Contact Tracing Tool',
                  'Track and monitor exposed contacts during outbreaks',
                  Icons.people_outline,
                  '/outbreak/analytics/contact-tracing',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // History Hub removed - will be unified on home page
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<_ToolItem> tools,
  ) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tools.map((tool) => _buildToolCard(context, tool)),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolItem tool) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => context.go(tool.route),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  tool.icon,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tool.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const _ToolItem(this.title, this.description, this.icon, this.route);
}
