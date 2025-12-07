import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/back_button.dart';

/// Central hub for all bundle interactive tools
class BundleToolsHubScreen extends StatelessWidget {
  const BundleToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Bundle Tools & Audits',
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

            // Phase 8A: Essential Tools
            _buildSectionHeader('Essential Tools', Icons.star, AppColors.primary),
            const SizedBox(height: AppSpacing.medium),
            _buildToolsGrid(context, _essentialTools),
            const SizedBox(height: AppSpacing.large),

            // Phase 8B: Important Tools
            _buildSectionHeader('Important Tools', Icons.trending_up, AppColors.info),
            const SizedBox(height: AppSpacing.medium),
            _buildToolsGrid(context, _importantTools),
            const SizedBox(height: AppSpacing.large),

            // Bundle Calculators (Cross-links to IPC Calculator module)
            _buildSectionHeader('Bundle Calculators', Icons.calculate_outlined, AppColors.secondary),
            const SizedBox(height: AppSpacing.medium),
            _buildToolsGrid(context, _bundleCalculators),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.info.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.build_outlined,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(
                  'Interactive Bundle Tools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Comprehensive tools for bundle audit, gap analysis, risk assessment, and performance monitoring.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
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
    );
  }

  Widget _buildToolsGrid(BuildContext context, List<_ToolInfo> tools) {
    return Column(
      children: tools.map((tool) => _buildToolCard(context, tool)).toList(),
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolInfo tool) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: tool.isEnabled
            ? () => context.push(tool.route)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tool.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  tool.icon,
                  color: tool.color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // Content
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

              // Status indicator
              if (!tool.isEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Soon',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
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

  // Phase 8A: Essential Tools
  static final List<_ToolInfo> _essentialTools = [
    _ToolInfo(
      title: 'Bundle Audit Tool',
      description: 'Element-level compliance tracking for all bundle types',
      icon: Icons.checklist_outlined,
      color: AppColors.primary,
      route: '/bundles/tools/audit',
      isEnabled: true,
    ),
    _ToolInfo(
      title: 'Gap Analysis Tool',
      description: 'Root cause analysis with barrier identification',
      icon: Icons.analytics_outlined,
      color: AppColors.info,
      route: '/bundles/tools/gap-analysis',
      isEnabled: true,
    ),
    _ToolInfo(
      title: 'Risk Assessment Tool',
      description: 'Proactive risk scoring across 4 categories',
      icon: Icons.warning_amber_outlined,
      color: AppColors.warning,
      route: '/bundles/tools/risk-assessment',
      isEnabled: true,
    ),
    _ToolInfo(
      title: 'Performance Dashboard',
      description: 'Executive-level KPIs with visual analytics',
      icon: Icons.dashboard_outlined,
      color: AppColors.success,
      route: '/bundles/tools/dashboard',
      isEnabled: true,
    ),
  ];

  // Phase 8B: Important Tools
  static final List<_ToolInfo> _importantTools = [
    _ToolInfo(
      title: 'Sepsis Bundle Checker',
      description: 'Hour-1 sepsis bundle compliance tracking',
      icon: Icons.medical_services_outlined,
      color: AppColors.error,
      route: '/bundles/tools/sepsis',
      isEnabled: true, // Phase 8B - COMPLETED
    ),
    _ToolInfo(
      title: 'Bundle Comparison Tool',
      description: 'Compare compliance across multiple bundles',
      icon: Icons.compare_arrows_outlined,
      color: AppColors.secondary,
      route: '/bundles/tools/comparison',
      isEnabled: true, // Phase 8B - COMPLETED
    ),
  ];

  // Bundle Calculators (Cross-links to IPC Calculator module)
  static final List<_ToolInfo> _bundleCalculators = [
    _ToolInfo(
      title: 'CLABSI Rate Calculator',
      description: 'Central Line-Associated Bloodstream Infections per 1,000 line days',
      icon: Icons.bloodtype_outlined,
      color: AppColors.error,
      route: '/calculator/clabsi',
      isEnabled: true,
    ),
    _ToolInfo(
      title: 'CAUTI Rate Calculator',
      description: 'Catheter-Associated Urinary Tract Infections per 1,000 catheter days',
      icon: Icons.water_drop_outlined,
      color: AppColors.info,
      route: '/calculator/cauti',
      isEnabled: true,
    ),
    _ToolInfo(
      title: 'VAE Rate Calculator',
      description: 'Ventilator-Associated Events per 1,000 ventilator days',
      icon: Icons.air_outlined,
      color: AppColors.primary,
      route: '/calculator/vae',
      isEnabled: true,
    ),
    _ToolInfo(
      title: 'SSI Rate Calculator',
      description: 'Surgical Site Infections by classification',
      icon: Icons.healing_outlined,
      color: AppColors.warning,
      route: '/calculator/ssi',
      isEnabled: true,
    ),
    _ToolInfo(
      title: 'Device Utilization Ratio',
      description: 'Device exposure monitoring (CL, UC, Ventilator)',
      icon: Icons.device_hub_outlined,
      color: AppColors.secondary,
      route: '/calculator/dur',
      isEnabled: true,
    ),
    _ToolInfo(
      title: 'Bundle Compliance %',
      description: 'Full & partial compliance tracker',
      icon: Icons.check_circle_outline,
      color: AppColors.success,
      route: '/calculator/bundle-compliance',
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

  const _ToolInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.isEnabled,
  });
}

