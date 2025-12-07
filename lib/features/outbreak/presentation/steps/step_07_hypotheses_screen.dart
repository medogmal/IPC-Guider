import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../widgets/interactive_tools_card.dart';
import '../../data/step_tools_mapping.dart';

class Step07HypothesesScreen extends StatelessWidget {
  const Step07HypothesesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 7: Generate Hypotheses'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.lightbulb_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Generate Hypotheses',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Propose possible causes and transmission routes',
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

            // Content Sections
            _buildContentSection(
              'Description',
              'Propose possible causes and transmission routes.',
              Icons.description_outlined,
              AppColors.info,
            ),

            const SizedBox(height: 16),

            _buildContentSection(
              'Example',
              'Hypothesis: contaminated IV fluids → CLABSI cluster.',
              Icons.lightbulb_outlined,
              AppColors.warning,
            ),

            const SizedBox(height: 16),

            _buildContentSection(
              'Key Questions',
              '• What is the most likely route/source of exposure?\n• Which risk factors are significant?\n• What is common among cases?',
              Icons.help_outline,
              AppColors.error,
            ),

            const SizedBox(height: 16),

            _buildContentSection(
              'Tools',
              '• Literature review\n• Exposure analysis tools\n• Staff interviews\n• Environmental audits',
              Icons.build_outlined,
              AppColors.success,
            ),

            const SizedBox(height: 24),

            // Interactive Tools Card
            InteractiveToolsCard(
              tools: StepToolsMapping.getToolsForStep('step_07_hypotheses'),
            ),

            const SizedBox(height: 16),

            _buildContentSection(
              'Action Points',
              '• Draft hypothesis with rationale\n• Document exposures',
              Icons.checklist_outlined,
              AppColors.primary,
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildContentSection(String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
