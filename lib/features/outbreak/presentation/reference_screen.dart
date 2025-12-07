import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/shared_widgets.dart';

class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational / Reference'),
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
            'Educational / Reference',
            'Guidelines, appendices, and quick references',
            Icons.menu_book_outlined,
            AppColors.info,
          ),

          const SizedBox(height: 24),

          // Guidelines Section
          Text(
            'Guidelines & Resources',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // WHO Guidelines
          _buildReferenceCard(
            context,
            title: 'WHO Guidelines',
            subtitle: 'World Health Organization outbreak resources',
            icon: Icons.public_outlined,
            onTap: () => context.go('/outbreak/reference/who'),
          ),

          // CDC Guidelines
          _buildReferenceCard(
            context,
            title: 'CDC Guidelines',
            subtitle: 'Centers for Disease Control outbreak protocols',
            icon: Icons.health_and_safety_outlined,
            onTap: () => context.go('/outbreak/reference/cdc'),
          ),

          // GDIPC Guidelines
          _buildReferenceCard(
            context,
            title: 'GDIPC Guidelines',
            subtitle: 'Gulf Centre for Disease Prevention and Control',
            icon: Icons.location_on_outlined,
            onTap: () => context.go('/outbreak/reference/gdipc'),
          ),

          // Weqaya Guidelines
          _buildReferenceCard(
            context,
            title: 'Weqaya Guidelines',
            subtitle: 'Saudi Center for Disease Prevention and Control',
            icon: Icons.flag_outlined,
            onTap: () => context.go('/outbreak/reference/weqaya'),
          ),

          const SizedBox(height: 24),

          // Appendices Section
          Text(
            'Quick Reference Appendices',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Incubation Periods
          _buildReferenceCard(
            context,
            title: 'Incubation Periods',
            subtitle: 'Common pathogen incubation periods',
            icon: Icons.schedule_outlined,
            onTap: () => context.go('/outbreak/reference/incubation'),
          ),

          // Emerging Infections
          _buildReferenceCard(
            context,
            title: 'Emerging Infections',
            subtitle: 'New and re-emerging infectious diseases',
            icon: Icons.new_releases_outlined,
            onTap: () => context.go('/outbreak/reference/emerging'),
          ),

          // Environmental Sampling Guide
          _buildReferenceCard(
            context,
            title: 'Environmental Sampling Quick Guide',
            subtitle: 'Sample collection and testing protocols',
            icon: Icons.science_outlined,
            onTap: () => context.go('/outbreak/reference/sampling'),
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

  Widget _buildReferenceCard(
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
