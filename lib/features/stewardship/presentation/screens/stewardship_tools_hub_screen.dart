import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';

/// Tools Hub Screen for Antimicrobial Stewardship module
/// Displays all interactive tools organized by priority
class StewardshipToolsHubScreen extends StatelessWidget {
  const StewardshipToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Tools'),
        elevation: 0,
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

            // Priority 1: Essential Tools
            _buildSectionHeader('Essential Tools', Icons.star, AppColors.primary),
            const SizedBox(height: AppSpacing.medium),
            _buildToolsGrid(context, _essentialTools),
            const SizedBox(height: AppSpacing.large),

            // Priority 2: Important Tools
            _buildSectionHeader('Important Tools', Icons.trending_up, AppColors.info),
            const SizedBox(height: AppSpacing.medium),
            _buildToolsGrid(context, _importantTools),
            const SizedBox(height: AppSpacing.large),

            // Priority 3: Educational Tools
            _buildSectionHeader('Educational Tools', Icons.school_outlined, AppColors.secondary),
            const SizedBox(height: AppSpacing.medium),
            _buildToolsGrid(context, _educationalTools),
            const SizedBox(height: AppSpacing.large),

            // AMS Calculators (Cross-links to IPC Calculator module)
            _buildSectionHeader('AMS Calculators', Icons.calculate_outlined, AppColors.success),
            const SizedBox(height: AppSpacing.medium),
            _buildToolsGrid(context, _amsCalculators),
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
                Icons.auto_fix_high,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(
                  'Interactive AMS Tools',
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
            'Comprehensive tools for antibiogram building, dose adjustment, spectrum visualization, and stewardship monitoring.',
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

  Widget _buildToolsGrid(BuildContext context, List<_ToolItem> tools) {
    return Column(
      children: tools.map((tool) => _buildToolCard(context, tool)).toList(),
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolItem tool) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
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
                        color: tool.isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tool.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status indicator
              if (!tool.isEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Soon',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Priority 1: Essential Tools
  static final List<_ToolItem> _essentialTools = [
    _ToolItem(
      title: 'Antibiogram Builder',
      description: 'Build facility-specific antibiograms with CLSI M39 compliance',
      icon: Icons.grid_on_outlined,
      color: AppColors.primary,
      route: '/stewardship/tools/antibiogram-builder',
      isEnabled: true,
    ),
    _ToolItem(
      title: 'Renal Dose Adjustment Calculator',
      description: 'Calculate antibiotic doses for renal impairment',
      icon: Icons.medication_outlined,
      color: AppColors.primary,
      route: '/stewardship/tools/renal-dose',
      isEnabled: true,
    ),
    _ToolItem(
      title: 'Antibiotic Spectrum Visualizer',
      description: 'Visual comparison of antibiotic coverage spectra',
      icon: Icons.radar_outlined,
      color: AppColors.primary,
      route: '/stewardship/tools/spectrum-visualizer',
      isEnabled: true,
    ),
    _ToolItem(
      title: 'Surgical Prophylaxis Advisor',
      description: 'Procedure-specific antibiotic recommendations',
      icon: Icons.local_hospital_outlined,
      color: AppColors.primary,
      route: '/stewardship/tools/surgical-prophylaxis',
      isEnabled: true,
    ),
  ];

  // Priority 2: Important Tools
  static final List<_ToolItem> _importantTools = [
    _ToolItem(
      title: 'AMS Dashboard',
      description: 'Comprehensive metrics tracking and benchmarking',
      icon: Icons.dashboard_outlined,
      color: AppColors.info,
      route: '/stewardship/tools/dashboard',
      isEnabled: false,
    ),
  ];

  // Priority 3: Educational Tools
  static final List<_ToolItem> _educationalTools = [
    _ToolItem(
      title: 'Allergy Cross-Reactivity Checker',
      description: 'Assess cross-reactivity risk and safe alternatives',
      icon: Icons.warning_amber_outlined,
      color: AppColors.secondary,
      route: '/stewardship/tools/allergy-checker',
      isEnabled: true,
    ),
    _ToolItem(
      title: 'MDRO Risk Calculator',
      description: 'Predict patient-specific multidrug-resistant organism risk',
      icon: Icons.biotech_outlined,
      color: AppColors.secondary,
      route: '/stewardship/tools/mdro-risk',
      isEnabled: true,
    ),
  ];

  // AMS Calculators (Cross-links to IPC Calculator module)
  static final List<_ToolItem> _amsCalculators = [
    _ToolItem(
      title: 'DOT (Days of Therapy) Calculator',
      description: 'Calculate antimicrobial consumption using DOT metric',
      icon: Icons.calculate_outlined,
      color: AppColors.success,
      route: '/calculator/dot',
      isEnabled: true,
    ),
    _ToolItem(
      title: 'DDD (Defined Daily Dose) Calculator',
      description: 'Calculate antimicrobial consumption using DDD metric',
      icon: Icons.calculate_outlined,
      color: AppColors.success,
      route: '/calculator/ddd',
      isEnabled: true,
    ),
    _ToolItem(
      title: 'Antibiotic Utilization % Calculator',
      description: 'Calculate percentage of patients receiving antibiotics',
      icon: Icons.calculate_outlined,
      color: AppColors.success,
      route: '/calculator/antibiotic-utilization',
      isEnabled: true,
    ),
    _ToolItem(
      title: 'De-escalation Rate Calculator',
      description: 'Calculate antibiotic de-escalation compliance rate',
      icon: Icons.calculate_outlined,
      color: AppColors.success,
      route: '/calculator/deescalation-rate',
      isEnabled: true,
    ),
    _ToolItem(
      title: 'Culture-Guided Therapy % Calculator',
      description: 'Calculate percentage of culture-guided antibiotic therapy',
      icon: Icons.calculate_outlined,
      color: AppColors.success,
      route: '/calculator/culture-guided-therapy',
      isEnabled: true,
    ),
  ];
}

/// Internal model for tool items
class _ToolItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final bool isEnabled;

  const _ToolItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    this.isEnabled = false,
  });
}

