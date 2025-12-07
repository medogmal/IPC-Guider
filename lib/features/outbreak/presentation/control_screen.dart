import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/shared_widgets.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control & Prevention Tools'),
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
            'Control & Prevention Tools',
            'Breaking transmission and prevention strategies',
            Icons.shield_outlined,
            AppColors.success,
          ),

          const SizedBox(height: 24),

          // Breaking the Chain of Infection
          _buildControlCard(
            context,
            title: 'Breaking the Chain of Infection',
            subtitle: 'Interrupt transmission pathways',
            icon: Icons.link_off_outlined,
            onTap: () => context.go('/outbreak/control/chain-breaking'),
          ),

          // Levels of Prevention
          _buildControlCard(
            context,
            title: 'Levels of Prevention',
            subtitle: 'Primary, Secondary, Tertiary prevention',
            icon: Icons.layers_outlined,
            onTap: () => context.go('/outbreak/control/prevention-levels'),
          ),

          // Immediate Control Measures
          _buildControlCard(
            context,
            title: 'Immediate Control Measures',
            subtitle: 'Isolation, cohorting, cleaning, closure protocols',
            icon: Icons.emergency_outlined,
            onTap: () => context.go('/outbreak/control/immediate-measures'),
          ),

          // Environmental Measures
          _buildControlCard(
            context,
            title: 'Environmental Measures',
            subtitle: 'Air, water, and surface interventions',
            icon: Icons.eco_outlined,
            onTap: () => context.go('/outbreak/control/environmental'),
          ),

          // Risk Assessment Checklists
          _buildControlCard(
            context,
            title: 'Risk Assessment Tool',
            subtitle: 'Evaluate outbreak risk factors',
            icon: Icons.assessment_outlined,
            onTap: () => context.go('/outbreak/control/risk-assessment'),
          ),

          // Disinfectant Selection Tool
          _buildControlCard(
            context,
            title: 'Disinfectant Selection Tool',
            subtitle: 'Choose appropriate disinfectants',
            icon: Icons.science_outlined,
            onTap: () => context.go('/outbreak/control/disinfectant-selection'),
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

  Widget _buildControlCard(
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
