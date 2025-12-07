import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outbreak Detection & Investigation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
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
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.search_outlined,
                        color: AppColors.error,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Outbreak Detection & Investigation',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Recognition, confirmation, and investigation steps',
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

          // Thresholds & Triggers Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFB85C5C).withValues(alpha: 0.12),
                  const Color(0xFFB85C5C).withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFB85C5C).withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => context.go('/outbreak/detection/thresholds'),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB85C5C).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.crisis_alert_outlined,
                      color: Color(0xFFB85C5C),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thresholds & Triggers for Outbreak Investigation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Criteria for initiating outbreak investigation protocols',
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
                    color: Color(0xFFB85C5C),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Surveillance Type Selector Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5B8A8A).withValues(alpha: 0.12),
                  const Color(0xFF5B8A8A).withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF5B8A8A).withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => context.go('/outbreak/detection/surveillance-type'),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B8A8A).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.radar_outlined,
                      color: Color(0xFF5B8A8A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Surveillance Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Interactive tool to choose the best surveillance approach',
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
                    color: Color(0xFF5B8A8A),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Step 1: Recognize potential outbreak
          _buildStepCard(
            context,
            stepNumber: '1',
            title: 'Recognize a Potential Outbreak',
            subtitle: 'Identification of unusual clustering or rates above baseline',
            icon: Icons.visibility_outlined,
            onTap: () => context.go('/outbreak/detection/recognize'),
          ),

          // Step 2: Verify diagnosis and confirm outbreak
          _buildStepCard(
            context,
            stepNumber: '2',
            title: 'Verify Diagnosis and Confirm the Outbreak',
            subtitle: 'Verify increase is real, ensure cases are correctly identified',
            icon: Icons.verified_outlined,
            onTap: () => context.go('/outbreak/detection/verify'),
          ),

          // Step 3: Alert key individuals
          _buildStepCard(
            context,
            stepNumber: '3',
            title: 'Alert Key Individuals',
            subtitle: 'Notify hospital IPC committee, leadership, GDIPC',
            icon: Icons.notification_important_outlined,
            onTap: () => context.go('/outbreak/detection/alert'),
          ),

          // Step 4: Establish case definition
          _buildStepCard(
            context,
            stepNumber: '4',
            title: 'Establish a Case Definition',
            subtitle: 'Develop clear clinical, laboratory, and epidemiological criteria',
            icon: Icons.rule_outlined,
            onTap: () => context.go('/outbreak/detection/case-definition'),
          ),

          // Step 5: Case finding (Line listing)
          _buildStepCard(
            context,
            stepNumber: '5',
            title: 'Case Finding (Line Listing)',
            subtitle: 'Identify and document all cases using active and passive surveillance',
            icon: Icons.list_alt_outlined,
            onTap: () => context.go('/outbreak/detection/case-finding'),
          ),


          // Step 6: Generate hypotheses
          _buildStepCard(
            context,
            stepNumber: '6',
            title: 'Generate Hypotheses',
            subtitle: 'Propose possible causes and transmission routes',
            icon: Icons.lightbulb_outlined,
            onTap: () => context.go('/outbreak/detection/hypotheses'),
          ),

          // Step 7: Analytical studies
          _buildStepCard(
            context,
            stepNumber: '7',
            title: 'Analytical Studies to Evaluate Hypotheses',
            subtitle: 'Case–control or cohort study to test hypothesis',
            icon: Icons.science_outlined,
            onTap: () => context.go('/outbreak/detection/analytical-studies'),
          ),

          // Step 8: Immediate control measures
          _buildStepCard(
            context,
            stepNumber: '8',
            title: 'Immediate Control Measures',
            subtitle: 'Urgent interventions while investigation continues',
            icon: Icons.security_outlined,
            onTap: () => context.go('/outbreak/detection/control-measures'),
          ),

          // Step 9: Environmental sampling
          _buildStepCard(
            context,
            stepNumber: '9',
            title: 'Environmental Sampling (if indicated)',
            subtitle: 'Test water, air, surfaces, equipment, food',
            icon: Icons.biotech_outlined,
            onTap: () => context.go('/outbreak/detection/environmental'),
          ),

          // Step 10: Communication findings & recommendations
          _buildStepCard(
            context,
            stepNumber: '10',
            title: 'Communication Findings & Recommendations',
            subtitle: 'Share findings, control measures, and recommendations',
            icon: Icons.campaign_outlined,
            onTap: () => context.go('/outbreak/detection/communication'),
          ),

          // Step 11: Maintain surveillance and evaluate response
          _buildStepCard(
            context,
            stepNumber: '11',
            title: 'Maintain Surveillance and Evaluate Response',
            subtitle: 'Continue monitoring for new cases and evaluate control measures',
            icon: Icons.monitor_outlined,
            onTap: () => context.go('/outbreak/detection/surveillance'),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        color: AppColors.surface,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Step Number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      stepNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
