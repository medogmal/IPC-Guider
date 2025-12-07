import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/widgets/back_button.dart';

class OutbreakHomeScreen extends StatelessWidget {
  const OutbreakHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Outbreak & Epidemiology',
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
          // Module Header
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
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.warning_amber_outlined,
                        color: AppColors.warning,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Outbreak & Epidemiology',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Detection, investigation, and response tools',
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

          const SizedBox(height: 16),

          // Quiz Button (matching isolation & calculator style)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 120,
                height: 32,
                child: FilledButton.icon(
                  onPressed: () => context.go('/quiz/outbreak'),
                  icon: const Icon(Icons.play_arrow, size: 14),
                  label: const Text('Quiz', style: TextStyle(fontSize: 11)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Section 1: Interactive Outbreak Tools (moved to first position)
          _buildInteractiveToolsButton(context),

          const SizedBox(height: 12),

          // Section 2: Foundations of Epidemiology
          _buildSectionCard(
            context,
            title: 'Foundations of Epidemiology',
            subtitle: 'Basic concepts and principles',
            icon: Icons.school_outlined,
            onTap: () => context.go('/outbreak/foundations'),
          ),

          // Section 3: Outbreak Detection & Investigation
          _buildSectionCard(
            context,
            title: 'Outbreak Detection & Investigation',
            subtitle: 'Recognition, confirmation, and investigation steps',
            icon: Icons.search_outlined,
            onTap: () => context.go('/outbreak/detection'),
          ),

          // Section 5: Outbreak-Specific Groups
          _buildSectionCard(
            context,
            title: 'Outbreak-Specific Groups',
            subtitle: 'Organized by pathogen type: bacterial, viral, fungal',
            icon: Icons.biotech_outlined,
            onTap: () => context.go('/outbreak/groups'),
          ),

          // Section 6: Control & Prevention Tools
          _buildSectionCard(
            context,
            title: 'Control & Prevention Tools',
            subtitle: 'Breaking transmission and prevention strategies',
            icon: Icons.shield_outlined,
            onTap: () => context.go('/outbreak/control'),
          ),

          // Section 7: Operation & Management
          _buildSectionCard(
            context,
            title: 'Operation & Management',
            subtitle: 'Classification, reporting, and communication',
            icon: Icons.business_outlined,
            onTap: () => context.go('/outbreak/operations'),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IpcCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor,
        onTap: onTap,
      ),
    );
  }

  Widget _buildInteractiveToolsButton(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.go('/outbreak/analytics'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.info.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_fix_high,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interactive Outbreak Tools',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Calculators, visualizations, case definitions, line lists, and control checklists',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
