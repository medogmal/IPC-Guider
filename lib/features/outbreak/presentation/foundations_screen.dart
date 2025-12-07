import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/shared_widgets.dart';

class FoundationsScreen extends StatelessWidget {
  const FoundationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foundations of Epidemiology'),
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
          Container(
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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Foundations of Epidemiology',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Basic concepts and principles',
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

          // Subsection: Infection vs Colonization
          _buildSubsectionCard(
            context,
            title: 'Infection vs Colonization',
            subtitle: 'Distinguishing between infection and colonization',
            icon: Icons.coronavirus_outlined,
            onTap: () => context.go('/outbreak/foundations/infection-colonization'),
          ),

          // Subsection: Case vs Carrier
          _buildSubsectionCard(
            context,
            title: 'Case vs Carrier',
            subtitle: 'Understanding cases and carrier states',
            icon: Icons.person_outline,
            onTap: () => context.go('/outbreak/foundations/case-carrier'),
          ),

          // Subsection: Levels of Disease
          _buildSubsectionCard(
            context,
            title: 'Levels of Disease',
            subtitle: 'Sporadic, Endemic, Epidemic, Pandemic',
            icon: Icons.trending_up_outlined,
            onTap: () => context.go('/outbreak/foundations/disease-levels'),
          ),

          // Subsection: Chain of Infection
          _buildSubsectionCard(
            context,
            title: 'Chain of Infection',
            subtitle: 'Six links in the chain of infection',
            icon: Icons.link_outlined,
            onTap: () => context.go('/outbreak/foundations/chain-infection'),
          ),

          // Subsection: Susceptibility & Risk Factors
          _buildSubsectionCard(
            context,
            title: 'Susceptibility & Risk Factors',
            subtitle: 'Host factors and risk assessment',
            icon: Icons.health_and_safety_outlined,
            onTap: () => context.go('/outbreak/foundations/susceptibility'),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubsectionCard(
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
