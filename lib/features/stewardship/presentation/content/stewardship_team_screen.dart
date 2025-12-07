import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

/// Dedicated screen for "The Stewardship Team"
class StewardshipTeamScreen extends StatelessWidget {
  const StewardshipTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Stewardship Team'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.groups,
            iconColor: AppColors.info,  // Blue: Team structure information
            title: 'The Stewardship Team',
            subtitle: 'Fundamentals of AMS',
            description:
                'An effective antimicrobial stewardship program requires a dedicated multidisciplinary team with clearly defined roles and responsibilities. The CDC Core Elements emphasize that successful programs appoint a single leader responsible for program outcomes and identify a physician leader and pharmacy leader who are accountable for stewardship activities.',
          ),
          const SizedBox(height: 20),

          // Core Team Members Card
          StructuredContentCard(
            heading: 'Core Team Members',
            content:
                '(1) Infectious Disease Physician or Physician Champion - provides clinical expertise, leads prospective audit and feedback, develops treatment guidelines, and serves as a consultant for complex cases; (2) Clinical Pharmacist with infectious diseases training - conducts medication reviews, performs prospective audit and feedback, monitors antimicrobial use metrics, and provides dosing optimization; (3) Infection Preventionist - tracks healthcare-associated infections, monitors resistance patterns, coordinates with microbiology, and links stewardship with infection prevention efforts.',
            icon: Icons.medical_services,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Extended Team Members Card
          StructuredContentCard(
            heading: 'Extended Team Members',
            content:
                'Microbiologist - provides susceptibility data, interprets culture results, develops antibiograms, and advises on diagnostic stewardship; Information Technology Specialist - develops clinical decision support tools, generates reports and dashboards, maintains antimicrobial use databases; Hospital Epidemiologist - oversees surveillance, analyzes trends, and guides evidence-based interventions; Quality Improvement Specialist - facilitates PDSA cycles, measures outcomes, and supports continuous improvement.',
            icon: Icons.people_outline,
            color: AppColors.info,  // Blue: Extended team information
          ),
          const SizedBox(height: 16),

          // Physician Leader Responsibilities Card
          StructuredContentCard(
            heading: 'Physician Leader Responsibilities',
            content:
                'Provides clinical expertise for antimicrobial selection; Leads prospective audit and feedback activities; Develops and updates facility-specific treatment guidelines; Serves as a consultant for complex infectious disease cases; Educates prescribers on appropriate antimicrobial use; Represents the stewardship program in medical staff committees.',
            icon: Icons.person_outline,
            color: AppColors.primary,  // Teal: Physician role
          ),
          const SizedBox(height: 16),

          // Pharmacy Leader Responsibilities Card
          StructuredContentCard(
            heading: 'Pharmacy Leader Responsibilities',
            content:
                'Conducts daily antimicrobial reviews; Performs dose optimization and therapeutic drug monitoring; Manages formulary restrictions and preauthorization processes; Tracks antimicrobial consumption metrics (DOT, DDD); Generates reports for prescribers and leadership; Coordinates with nursing staff on antimicrobial administration.',
            icon: Icons.medication,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),

          // Frontline Engagement Card
          StructuredContentCard(
            heading: 'Frontline Engagement',
            content:
                'Recruiting physician champions in each clinical department; Involving bedside nurses in hand hygiene and infection prevention; Engaging surgeons in surgical prophylaxis optimization; Partnering with hospitalists and intensivists for guideline implementation.',
            icon: Icons.handshake,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),

          // Leadership Support Card
          StructuredContentCard(
            heading: 'Leadership Support Requirements',
            content:
                'Allocating dedicated time and resources for stewardship team members (minimum 1.0 FTE pharmacist and 0.5 FTE physician for a 200-bed hospital); Providing financial support for education and technology; Including stewardship metrics in quality dashboards; Holding prescribers accountable for adherence to guidelines.',
            icon: Icons.business_center,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),

          // Team Collaboration Card
          StructuredContentCard(
            heading: 'Team Collaboration',
            content:
                'Meet regularly (weekly or biweekly) to review cases, discuss resistance trends, plan interventions, and address barriers; Establish communication channels for urgent consultations; Maintain visibility through rounds, educational sessions, and newsletters.',
            icon: Icons.forum,
            color: AppColors.success,  // Green: Collaboration best practice
          ),
          const SizedBox(height: 20),

          // Key Takeaways Section
          _buildKeyTakeawaysCard(),
          const SizedBox(height: 20),

          // References Section
          _buildReferencesCard(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Core team: ID physician, clinical pharmacist, infection preventionist',
      'Extended team: microbiologist, IT specialist, epidemiologist, QI specialist',
      'Physician leader provides clinical expertise and leads audit/feedback',
      'Pharmacy leader conducts reviews, tracks metrics, manages formulary',
      'Frontline engagement through physician champions is critical',
      'Leadership must allocate dedicated time and resources (1.0 FTE pharmacist, 0.5 FTE physician minimum)',
      'Regular team meetings and communication channels are essential',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Key Takeaways',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...keyPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          height: 1.5,
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

  Widget _buildReferencesCard(BuildContext context) {
    final references = [
      {
        'label': 'CDC Core Elements of Hospital Antibiotic Stewardship Programs (2019)',
        'url': 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html',
      },
      {
        'label': 'IDSA/SHEA Guidelines for Developing an Institutional Program to Enhance Antimicrobial Stewardship (2016)',
        'url': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
      },
      {
        'label': 'ASHP Statement on the Pharmacist\'s Role in Antimicrobial Stewardship (2010)',
        'url': 'https://www.ashp.org/-/media/assets/policy-guidelines/docs/statements/pharmacists-role-antimicrobial-stewardship.ashx',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.library_books_outlined,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
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
          ...references.map((ref) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _launchUrl(ref['url']!),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.open_in_new,
                          color: AppColors.info,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ref['label']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.info,
                              decoration: TextDecoration.underline,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

