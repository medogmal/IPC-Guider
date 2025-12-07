import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';

class ImmediateMeasuresScreen extends StatelessWidget {
  const ImmediateMeasuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Immediate Control Measures'),
        elevation: 0,
      ),
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
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
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
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.emergency,
                        color: AppColors.error,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Immediate Control Measures',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'First Response Actions',
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
                  'When an outbreak is suspected or confirmed, immediate action is critical to prevent further transmission. This guide provides a systematic approach to implementing control measures in the first 24-72 hours.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Timeline Card
          _buildTimelineCard(),
          const SizedBox(height: 20),

          // Patient Measures
          _buildMeasureCard(
            title: 'Patient Measures',
            icon: Icons.person,
            color: AppColors.primary,
            measures: [
              'Isolate suspected/confirmed cases immediately',
              'Implement appropriate transmission-based precautions',
              'Cohort patients with same pathogen if single rooms unavailable',
              'Restrict patient movement outside room to essential only',
              'Place signage on door indicating precautions required',
              'Ensure dedicated patient care equipment when possible',
              'Review and optimize antimicrobial therapy',
              'Obtain specimens for laboratory confirmation',
            ],
            examples: [
              'Contact precautions for MRSA/VRE',
              'Airborne precautions for TB/measles',
              'Droplet precautions for influenza/pertussis',
              'Enhanced contact precautions for C. diff/norovirus',
            ],
          ),
          const SizedBox(height: 16),

          // Environmental Measures
          _buildMeasureCard(
            title: 'Environmental Measures',
            icon: Icons.cleaning_services,
            color: AppColors.success,
            measures: [
              'Increase cleaning frequency of high-touch surfaces',
              'Use appropriate disinfectant for identified pathogen',
              'Ensure adequate contact time for disinfectants',
              'Clean and disinfect shared equipment between patients',
              'Remove unnecessary items from patient rooms',
              'Ensure proper waste segregation and disposal',
              'Verify environmental cleaning with ATP or fluorescent markers',
              'Consider terminal cleaning for discharged patient rooms',
            ],
            examples: [
              'Bleach (1:10 dilution) for C. diff spores',
              'EPA-registered disinfectant for MRSA/VRE',
              'Bleach (1000-5000 ppm) for norovirus',
              'Sporicidal disinfectant for Candida auris',
            ],
          ),
          const SizedBox(height: 16),

          // Staff Measures
          _buildMeasureCard(
            title: 'Staff Measures',
            icon: Icons.medical_services,
            color: AppColors.warning,
            measures: [
              'Dedicate staff to affected patients when possible (cohorting)',
              'Ensure all staff trained on appropriate PPE use',
              'Conduct direct observation of hand hygiene and PPE compliance',
              'Screen staff for symptoms and restrict work if symptomatic',
              'Provide post-exposure prophylaxis if indicated',
              'Limit use of float/agency staff in affected areas',
              'Ensure adequate staffing levels to maintain IPC practices',
              'Provide daily updates and education to all staff',
            ],
            examples: [
              'Cohort nursing staff for norovirus outbreak',
              'Restrict symptomatic staff from patient care',
              'Post-exposure prophylaxis for pertussis contacts',
              'N95 fit testing for airborne pathogen outbreaks',
            ],
          ),
          const SizedBox(height: 16),

          // Communication Measures
          _buildMeasureCard(
            title: 'Communication & Coordination',
            icon: Icons.campaign,
            color: AppColors.info,
            measures: [
              'Notify infection prevention and control team immediately',
              'Alert hospital administration and department leadership',
              'Inform public health authorities as required',
              'Communicate with laboratory for expedited testing',
              'Notify receiving facilities for patient transfers',
              'Provide daily situation reports to stakeholders',
              'Educate patients and families about precautions',
              'Document all actions taken in outbreak log',
            ],
            examples: [
              'Notify CDC for reportable diseases',
              'Alert Ministry of Health for notifiable conditions',
              'Daily outbreak team meetings',
              'Family education handouts in multiple languages',
            ],
          ),
          const SizedBox(height: 20),

          // Key Principles Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
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
                    Icon(Icons.priority_high, color: AppColors.error, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Critical Success Factors',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPrincipleItem(
                  'Speed',
                  'Implement measures immediately - every hour counts',
                  Icons.speed,
                ),
                _buildPrincipleItem(
                  'Consistency',
                  'Ensure all staff follow same protocols without exception',
                  Icons.check_circle,
                ),
                _buildPrincipleItem(
                  'Monitoring',
                  'Audit compliance daily and provide real-time feedback',
                  Icons.visibility,
                ),
                _buildPrincipleItem(
                  'Communication',
                  'Keep all stakeholders informed with regular updates',
                  Icons.forum,
                ),
                _buildPrincipleItem(
                  'Documentation',
                  'Record all actions, decisions, and outcomes',
                  Icons.description,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

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
                Row(
                  children: [
                    Icon(Icons.library_books, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Official References',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildReferenceItem(
                  'CDC – Outbreak Response Guidelines',
                  'https://www.cdc.gov/infectioncontrol/guidelines/index.html',
                ),
                _buildReferenceItem(
                  'WHO – Outbreak Investigation and Response',
                  'https://www.who.int/emergencies/outbreak-toolkit',
                ),
                _buildReferenceItem(
                  'APIC – Outbreak Management Resources',
                  'https://apic.org/professional-practice/practice-resources/',
                ),
                _buildReferenceItem(
                  'GDIPC/Weqaya – National Outbreak Response (Saudi Arabia)',
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


  Widget _buildTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
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
              Icon(Icons.timeline, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Action Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            'First 24 Hours',
            [
              'Isolate affected patients',
              'Implement transmission-based precautions',
              'Notify IPC team and administration',
              'Begin active case finding',
              'Obtain laboratory specimens',
              'Initiate outbreak log',
            ],
            AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildTimelineItem(
            '24-48 Hours',
            [
              'Review laboratory results',
              'Expand surveillance if needed',
              'Audit hand hygiene and PPE compliance',
              'Enhance environmental cleaning',
              'Provide staff education',
              'Daily outbreak team meeting',
            ],
            AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildTimelineItem(
            '48-72 Hours',
            [
              'Assess effectiveness of control measures',
              'Adjust interventions based on new cases',
              'Continue active surveillance',
              'Prepare situation report',
              'Plan for long-term control if needed',
              'Document lessons learned',
            ],
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String period, List<String> actions, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  period,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...actions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle, color: color, size: 14),
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
          )),
        ],
      ),
    );
  }

  Widget _buildMeasureCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> measures,
    required List<String> examples,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
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
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...measures.map((measure) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle_outline, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    measure,
                    style: TextStyle(
                      fontSize: 14,
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

  Widget _buildPrincipleItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
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

