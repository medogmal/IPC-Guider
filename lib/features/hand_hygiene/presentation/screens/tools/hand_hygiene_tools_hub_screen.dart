import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/back_button.dart';

/// Central hub for all hand hygiene interactive tools
class HandHygieneToolsHubScreen extends StatelessWidget {
  const HandHygieneToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Hand Hygiene Tools',
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: AppSpacing.large),

            // Essential Tools
            _buildSectionHeader('Essential Tools', Icons.star, AppColors.success),
            const SizedBox(height: AppSpacing.medium),
            _buildToolsGrid(context, _essentialTools),
            const SizedBox(height: AppSpacing.large),

            // Related Calculators (Cross-links to IPC Calculator module)
            _buildSectionHeader('Related Calculators', Icons.calculate_outlined, AppColors.secondary),
            const SizedBox(height: AppSpacing.medium),
            _buildToolsGrid(context, _relatedCalculators),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.extraLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success,
            AppColors.success.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.clean_hands_outlined,
              color: Colors.white,
              size: 56,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Interactive Hand Hygiene Tools',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Comprehensive tools for hand hygiene compliance monitoring, product usage tracking, and performance improvement.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.small),
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
    );
  }

  Widget _buildToolsGrid(BuildContext context, List<_ToolInfo> tools) {
    return Column(
      children: tools.map((tool) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.medium),
          child: _buildToolCard(context, tool),
        );
      }).toList(),
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolInfo tool) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tool.color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: tool.color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: tool.isEnabled
              ? () => context.push(tool.route)
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This tool is coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.small),
                  decoration: BoxDecoration(
                    color: tool.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: tool.color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    tool.icon,
                    color: tool.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        tool.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.extraSmall),

                      // Description
                      Text(
                        tool.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.small),

                // Coming Soon Badge or Arrow
                if (!tool.isEnabled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.small,
                      vertical: AppSpacing.extraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Soon',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: tool.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: tool.color,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Essential Tools (To be implemented in Phase 3)
  static final List<_ToolInfo> _essentialTools = [
    _ToolInfo(
      title: 'WHO Observation Tool',
      description: 'Digital WHO 5 Moments observation tracker',
      icon: Icons.visibility_outlined,
      color: AppColors.success,
      route: '/hand-hygiene/tools/who-observation',
      isEnabled: true,
    ),
    _ToolInfo(
      title: 'Product Usage Tracker',
      description: 'ABHS consumption monitoring per patient-day',
      icon: Icons.local_drink_outlined,
      color: AppColors.info,
      route: '/hand-hygiene/tools/product-usage',
      isEnabled: true,
    ),
    _ToolInfo(
      title: 'Dispenser Placement Tool',
      description: 'Optimal dispenser location calculator',
      icon: Icons.place_outlined,
      color: AppColors.primary,
      route: '/hand-hygiene/tools/dispenser-placement',
      isEnabled: true,
    ),
  ];

  // Related Calculators (Cross-links to IPC Calculator module)
  static final List<_ToolInfo> _relatedCalculators = [
    _ToolInfo(
      title: 'Observation Compliance %',
      description: 'Real-time behavior adherence tracking',
      icon: Icons.visibility,
      color: AppColors.primary,
      route: '/calculator/observation-compliance',
      isEnabled: true,
    ),
    _ToolInfo(
      title: 'Compliance Trend Tracker',
      description: 'Visualize compliance over time',
      icon: Icons.trending_up,
      color: AppColors.info,
      route: '/calculator/compliance-trend',
      isEnabled: true,
    ),
  ];
}

/// Tool information model
class _ToolInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final bool isEnabled;

  _ToolInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.isEnabled,
  });
}

