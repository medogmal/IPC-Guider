import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';

class OutbreakChecklistScreen extends StatelessWidget {
  const OutbreakChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Outbreak Response Checklist'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          children: [
          _buildHeaderCard(),
          const SizedBox(height: 24),
          _buildOverviewCard(),
          const SizedBox(height: 24),
          _buildPhaseSection(
            'Phase 1: Immediate Response (First 24 Hours)',
            AppColors.error,
            Icons.emergency_outlined,
            [
              'Verify outbreak existence (rule out pseudo-outbreak)',
              'Activate outbreak response team',
              'Notify hospital leadership and infection control committee',
              'Implement immediate control measures (isolation, cohorting)',
              'Establish case definition (preliminary)',
              'Begin active case finding',
              'Notify public health authorities (if required)',
              'Set up communication channels',
              'Document initial cases and timeline',
              'Secure laboratory support',
            ],
          ),
          const SizedBox(height: 16),
          _buildPhaseSection(
            'Phase 2: Investigation & Analysis (Days 2-7)',
            AppColors.warning,
            Icons.search_outlined,
            [
              'Refine case definition based on initial findings',
              'Conduct comprehensive case finding (active surveillance)',
              'Perform descriptive epidemiology (person, place, time)',
              'Create epidemic curve',
              'Calculate attack rates by unit/ward',
              'Develop and test hypotheses',
              'Conduct environmental assessment',
              'Review infection control practices',
              'Collect specimens for laboratory confirmation',
              'Implement enhanced control measures',
              'Conduct staff education sessions',
              'Establish daily briefing schedule',
            ],
          ),
          const SizedBox(height: 16),
          _buildPhaseSection(
            'Phase 3: Control & Monitoring (Ongoing)',
            AppColors.primary,
            Icons.shield_outlined,
            [
              'Monitor effectiveness of control measures',
              'Continue active surveillance',
              'Track new cases daily',
              'Adjust control measures as needed',
              'Maintain communication with stakeholders',
              'Document all interventions and outcomes',
              'Conduct analytical studies (if indicated)',
              'Implement long-term prevention strategies',
              'Monitor staff compliance with protocols',
              'Provide regular updates to leadership',
            ],
          ),
          const SizedBox(height: 16),
          _buildPhaseSection(
            'Phase 4: Closure & Evaluation (Post-Outbreak)',
            AppColors.success,
            Icons.task_alt_outlined,
            [
              'Declare end of outbreak (based on criteria)',
              'Complete final outbreak report',
              'Conduct post-outbreak evaluation meeting',
              'Identify lessons learned',
              'Update policies and procedures',
              'Provide feedback to all stakeholders',
              'Archive outbreak documentation',
              'Implement system improvements',
              'Plan follow-up surveillance',
              'Recognize team contributions',
            ],
          ),
          const SizedBox(height: 24),
          _buildCriticalFactorsCard(),
          const SizedBox(height: 24),
          _buildPitfallsCard(),
          const SizedBox(height: 24),
          _buildReferencesCard(context),
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.checklist_rtl_outlined,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outbreak Response Checklist',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Comprehensive action items for outbreak management',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This checklist provides a systematic approach to outbreak response, organized by phase and priority. Use it to ensure no critical steps are missed during the outbreak investigation and control process.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '💡 Key Principle: Checklists reduce cognitive load and prevent errors during high-stress outbreak situations.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseSection(
    String title,
    Color color,
    IconData icon,
    List<String> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCriticalFactorsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_outline, color: AppColors.success, size: 24),
              const SizedBox(width: 12),
              Text(
                'Critical Success Factors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            'Early detection and rapid response',
            'Clear leadership and defined roles',
            'Effective communication (internal and external)',
            'Evidence-based control measures',
            'Adequate resources and support',
            'Staff engagement and compliance',
            'Systematic documentation',
            'Flexibility to adapt strategies',
          ].map((factor) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        factor,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPitfallsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Common Pitfalls to Avoid',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            'Delayed recognition or response',
            'Inadequate case definition (too broad or too narrow)',
            'Insufficient active case finding',
            'Poor communication with stakeholders',
            'Premature declaration of outbreak end',
            'Failure to document interventions and outcomes',
            'Neglecting staff education and support',
            'Not conducting post-outbreak evaluation',
          ].map((pitfall) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.close, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pitfall,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildReferencesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.library_books_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              const Text(
                'References',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReferenceLink(
            context,
            'CDC Field Epidemiology Manual - Outbreak Response',
            'https://www.cdc.gov/eis/field-epi-manual/index.html',
          ),
          _buildReferenceLink(
            context,
            'WHO Outbreak Toolkit',
            'https://www.who.int/emergencies/outbreak-toolkit',
          ),
          _buildReferenceLink(
            context,
            'APIC Implementation Guide - Outbreak Investigation',
            'https://apic.org/resources/',
          ),
          _buildReferenceLink(
            context,
            'CDC Healthcare Infection Outbreak Response Checklist',
            'https://www.cdc.gov/hai/outbreaks/index.html',
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceLink(BuildContext context, String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Row(
          children: [
            Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            ],
          ),
        ),
    );
  }
}
