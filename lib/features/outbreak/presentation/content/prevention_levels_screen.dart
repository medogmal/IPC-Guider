import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';

class PreventionLevelsScreen extends StatelessWidget {
  const PreventionLevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Levels of Prevention'),
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
          // Header Card
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
                        Icons.layers_outlined,
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
                            'Levels of Prevention',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Primary, Secondary, and Tertiary prevention',
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
                const SizedBox(height: 16),
                Text(
                  'Prevention strategies are organized into three levels based on when they are applied in the disease process. Understanding these levels helps target interventions effectively.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Primary Prevention
          _buildLevelCard(
            level: 'Primary Prevention',
            definition: 'Prevent disease occurrence before it starts',
            goal: 'Reduce incidence of disease',
            timing: 'Before exposure or infection',
            strategies: [
              'Vaccination and immunization programs',
              'Hand hygiene education and compliance',
              'Environmental controls (ventilation, water safety)',
              'Health education and promotion',
              'Safe injection practices',
              'Antimicrobial stewardship',
              'Screening and decolonization of high-risk patients',
            ],
            examples: [
              'COVID-19: Vaccination, masking, physical distancing',
              'MRSA: Screening and decolonization on admission to ICU',
              'Influenza: Annual vaccination for healthcare workers',
              'Legionella: Water system maintenance and monitoring',
              'SSI: Preoperative chlorhexidine bathing',
            ],
            color: AppColors.success,
            icon: Icons.shield_outlined,
          ),

          const SizedBox(height: 16),

          // Secondary Prevention
          _buildLevelCard(
            level: 'Secondary Prevention',
            definition: 'Early detection and treatment to prevent progression',
            goal: 'Reduce prevalence and duration of disease',
            timing: 'During early disease stage (often asymptomatic)',
            strategies: [
              'Surveillance and outbreak detection',
              'Active case finding and contact tracing',
              'Screening programs (e.g., MRSA, VRE, CRE)',
              'Early diagnosis and treatment',
              'Isolation of cases to prevent transmission',
              'Post-exposure prophylaxis',
            ],
            examples: [
              'TB: Contact investigation and latent TB testing/treatment',
              'COVID-19: Testing, isolation, and contact tracing',
              'MRSA: Active surveillance cultures in high-risk units',
              'HIV: Post-exposure prophylaxis after needlestick',
              'Measles: Post-exposure vaccination within 72 hours',
            ],
            color: AppColors.warning,
            icon: Icons.search_outlined,
          ),

          const SizedBox(height: 16),

          // Tertiary Prevention
          _buildLevelCard(
            level: 'Tertiary Prevention',
            definition: 'Reduce complications and disability from established disease',
            goal: 'Improve quality of life and reduce mortality',
            timing: 'After disease is established',
            strategies: [
              'Appropriate antimicrobial therapy',
              'Supportive care and rehabilitation',
              'Prevent secondary infections',
              'Minimize invasive device use',
              'Early removal of catheters and devices',
              'Prevent transmission to others',
            ],
            examples: [
              'C. difficile: Oral vancomycin/fidaxomicin + stop offending antibiotics',
              'Sepsis: Early recognition and treatment bundles',
              'CLABSI: Remove central line when no longer needed',
              'VAP: Daily sedation vacation and spontaneous breathing trials',
              'CAUTI: Remove urinary catheter as soon as possible',
            ],
            color: AppColors.error,
            icon: Icons.medical_services_outlined,
          ),

          const SizedBox(height: 24),

          // Comparison Table
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
                    Icon(Icons.table_chart_outlined, color: AppColors.info, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Comparison',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildComparisonRow('When', 'Before disease', 'Early disease', 'Established disease'),
                _buildComparisonRow('Goal', 'Prevent occurrence', 'Early detection', 'Reduce complications'),
                _buildComparisonRow('Target', 'Healthy population', 'At-risk/exposed', 'Infected patients'),
                _buildComparisonRow('Example', 'Vaccination', 'Screening', 'Treatment'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Outbreak Application Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
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
                    Icon(Icons.lightbulb_outlined, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Applying All Three Levels in Outbreaks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Effective outbreak control requires simultaneous application of all three prevention levels:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildOutbreakExample(
                  title: 'Norovirus Outbreak in Hospital Ward',
                  primary: 'Hand hygiene with soap and water, environmental cleaning with bleach',
                  secondary: 'Active case finding, isolate symptomatic patients, cohort staff',
                  tertiary: 'Supportive care for infected patients, prevent dehydration',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // References Section
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
                Text(
                  'Official References',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildReferenceItem(
                  'CDC – Prevention Strategies',
                  'https://www.cdc.gov/infectioncontrol/guidelines/index.html',
                ),
                _buildReferenceItem(
                  'WHO – Infection Prevention and Control',
                  'https://www.who.int/teams/integrated-health-services/infection-prevention-control',
                ),
                _buildReferenceItem(
                  'APIC – Prevention Levels in Healthcare',
                  'https://apic.org/professional-practice/practice-resources/',
                ),
                _buildReferenceItem(
                  'GDIPC/Weqaya – National Prevention Guidelines (Saudi Arabia)',
                  'https://www.moh.gov.sa/en/Ministry/MediaCenter/Publications/Pages/Publications-2020-10-29-001.aspx',
                ),
                ],
              ),
            ),
            ],
          ),
        ),
    );
  }


  Widget _buildLevelCard({
    required String level,
    required String definition,
    required String goal,
    required String timing,
    required List<String> strategies,
    required List<String> examples,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
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
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Definition', definition, color),
          _buildInfoRow('Goal', goal, color),
          _buildInfoRow('Timing', timing, color),
          const SizedBox(height: 12),
          Text(
            'Strategies:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...strategies.map((strategy) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(Icons.check_circle, color: color, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strategy,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outlined, color: color, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Examples:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...examples.map((example) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $example',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String aspect, String primary, String secondary, String tertiary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            aspect,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    primary,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    secondary,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tertiary,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutbreakExample({
    required String title,
    required String primary,
    required String secondary,
    required String tertiary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        _buildPreventionLevelRow('Primary', primary, AppColors.success),
        _buildPreventionLevelRow('Secondary', secondary, AppColors.warning),
        _buildPreventionLevelRow('Tertiary', tertiary, AppColors.error),
      ],
    );
  }

  Widget _buildPreventionLevelRow(String level, String action, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              level,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              action,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.open_in_new, size: 18, color: AppColors.primary),
              const SizedBox(width: 12),
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
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

