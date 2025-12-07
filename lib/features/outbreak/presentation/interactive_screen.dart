import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/shared_widgets.dart';

class InteractiveScreen extends StatelessWidget {
  const InteractiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Features'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          children: [
          // Section Header
          _buildSectionHeader(
            'Interactive Features',
            'Case definition builder, line lists, and tools',
            Icons.build_outlined,
            AppColors.primary,
          ),

          const SizedBox(height: 24),

          // Case Definition Builder
          _buildInteractiveCard(
            context,
            title: 'Case Definition Builder',
            subtitle: 'Create standardized case definitions',
            icon: Icons.rule_outlined,
            onTap: () => context.go('/outbreak/interactive/case-definition'),
          ),

          // Line List Tool
          _buildInteractiveCard(
            context,
            title: 'Line List Tool',
            subtitle: 'ID, age, unit, onset date, outcome tracking',
            icon: Icons.list_alt_outlined,
            onTap: () => context.go('/outbreak/interactive/line-list'),
          ),

          // Epi Curve Generator
          _buildInteractiveCard(
            context,
            title: 'Epi Curve Generator',
            subtitle: 'Auto-generate curves from line list data',
            icon: Icons.show_chart_outlined,
            onTap: () => context.go('/outbreak/interactive/epi-curve'),
          ),

          // Calculator Panel
          _buildInteractiveCard(
            context,
            title: 'Calculator Panel',
            subtitle: 'Attack Rate, RR, OR calculators',
            icon: Icons.calculate_outlined,
            onTap: () => context.go('/outbreak/interactive/calculators'),
          ),

          // Control Checklist
          _buildInteractiveCard(
            context,
            title: 'Control Checklist',
            subtitle: 'Interactive outbreak control measures',
            icon: Icons.checklist_outlined,
            onTap: () => context.go('/outbreak/interactive/checklist'),
          ),

          // Export/Report
          _buildInteractiveCard(
            context,
            title: 'Export/Report',
            subtitle: 'Excel/CSV/PDF export capabilities',
            icon: Icons.file_download_outlined,
            onTap: () => context.go('/outbreak/interactive/export'),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Container(
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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

  Widget _buildInteractiveCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IpcCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        onTap: onTap,
      ),
    );
  }
}
