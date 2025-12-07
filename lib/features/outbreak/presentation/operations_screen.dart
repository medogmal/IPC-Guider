import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/shared_widgets.dart';

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operation & Management'),
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
            'Operation & Management',
            'Classification, reporting, and communication',
            Icons.business_outlined,
            AppColors.warning,
          ),

          const SizedBox(height: 24),

          // NEW: Outbreak Team Structure & Roles
          _buildOperationCard(
            context,
            title: 'Outbreak Team Structure & Roles',
            subtitle: 'IMS-based team organization and responsibilities',
            icon: Icons.groups_outlined,
            onTap: () => context.go('/outbreak/operations/team-structure'),
          ),

          // NEW: Risk Assessment & Prioritization
          _buildOperationCard(
            context,
            title: 'Risk Assessment & Prioritization',
            subtitle: 'Outbreak severity assessment and resource allocation',
            icon: Icons.assessment_outlined,
            onTap: () => context.go('/outbreak/operations/risk-assessment'),
          ),

          // NEW: Outbreak Action Plan Template
          _buildOperationCard(
            context,
            title: 'Outbreak Action Plan Template',
            subtitle: 'Structured planning document for outbreak response',
            icon: Icons.assignment_outlined,
            onTap: () => context.go('/outbreak/operations/action-plan'),
          ),

          // NEW: Meeting Documentation & Minutes
          _buildOperationCard(
            context,
            title: 'Meeting Documentation & Minutes',
            subtitle: 'Standardized templates for outbreak meetings',
            icon: Icons.event_note_outlined,
            onTap: () => context.go('/outbreak/operations/meeting-documentation'),
          ),

          // NEW: Stakeholder Communication Matrix
          _buildOperationCard(
            context,
            title: 'Stakeholder Communication Matrix',
            subtitle: 'Structured communication framework for outbreaks',
            icon: Icons.forum_outlined,
            onTap: () => context.go('/outbreak/operations/stakeholder-communication'),
          ),

          // NEW PAGES (6 remaining from 11-page plan)

          _buildOperationCard(
            context,
            title: 'Outbreak Response Checklist',
            subtitle: 'Comprehensive action items by phase',
            icon: Icons.checklist_rtl_outlined,
            onTap: () => context.go('/outbreak/operations/outbreak-checklist'),
          ),

          _buildOperationCard(
            context,
            title: 'Resource Management & Logistics',
            subtitle: 'Resource allocation and supply chain',
            icon: Icons.inventory_2_outlined,
            onTap: () => context.go('/outbreak/operations/resource-management'),
          ),

          _buildOperationCard(
            context,
            title: 'Quality Assurance & Performance Monitoring',
            subtitle: 'Metrics and KPIs for outbreak response',
            icon: Icons.speed_outlined,
            onTap: () => context.go('/outbreak/operations/quality-monitoring'),
          ),

          _buildOperationCard(
            context,
            title: 'Post-Outbreak Evaluation',
            subtitle: 'Lessons learned and improvement',
            icon: Icons.rate_review_outlined,
            onTap: () => context.go('/outbreak/operations/post-outbreak-evaluation'),
          ),

          _buildOperationCard(
            context,
            title: 'Legal & Regulatory Compliance',
            subtitle: 'Reporting requirements and documentation',
            icon: Icons.gavel_outlined,
            onTap: () => context.go('/outbreak/operations/legal-compliance'),
          ),

          _buildOperationCard(
            context,
            title: 'Training & Competency Verification',
            subtitle: 'Staff preparedness and drills',
            icon: Icons.school_outlined,
            onTap: () => context.go('/outbreak/operations/training-competency'),
          ),

          // EXISTING PAGES START HERE

          // Outbreak Classification Matrix
          _buildOperationCard(
            context,
            title: 'Outbreak Classification Matrix',
            subtitle: 'Category A, B, C classification system',
            icon: Icons.category_outlined,
            onTap: () => context.go('/outbreak/operations/classification'),
          ),

          // Declaring End of Outbreak
          _buildOperationCard(
            context,
            title: 'Declaring End of Outbreak',
            subtitle: 'Criteria and procedures for outbreak closure',
            icon: Icons.check_circle_outline,
            onTap: () => context.go('/outbreak/operations/end-outbreak'),
          ),

          // Reporting
          _buildOperationCard(
            context,
            title: 'Reporting (Preliminary + Final)',
            subtitle: 'Structured outbreak reporting templates',
            icon: Icons.description_outlined,
            onTap: () => context.go('/outbreak/operations/reporting'),
          ),

          // Alerts & Communication
          _buildOperationCard(
            context,
            title: 'Alerts & Communication',
            subtitle: 'System notifications, GDIPC/Weqaya reporting',
            icon: Icons.notifications_active_outlined,
            onTap: () => context.go('/outbreak/operations/alerts'),
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

  Widget _buildOperationCard(
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
