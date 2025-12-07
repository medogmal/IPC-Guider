import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

/// Dedicated screen for "What is Antimicrobial Stewardship?"
/// Uses consistent card-based design pattern from Outbreak module
class WhatIsAmsScreen extends StatelessWidget {
  const WhatIsAmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('What is Antimicrobial Stewardship?'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.medication_liquid,
            iconColor: AppColors.primary,  // Teal: Module primary color
            title: 'What is Antimicrobial Stewardship?',
            subtitle: 'Fundamentals of AMS',
            description:
                'Antimicrobial stewardship (AMS) is a coordinated program that promotes the appropriate use of antimicrobials (including antibiotics, antivirals, antifungals, and antiparasitics), improves patient outcomes, reduces microbial resistance, and decreases the spread of infections caused by multidrug-resistant organisms.',
          ),
          const SizedBox(height: 20),

          // Primary Goals Card
          StructuredContentCard(
            heading: 'Primary Goals of Antimicrobial Stewardship',
            content:
                'Optimize clinical outcomes while minimizing unintended consequences of antimicrobial use (including toxicity, selection of pathogenic organisms, and emergence of resistance); Ensure cost-effective therapy; Reduce healthcare-associated infections including Clostridioides difficile infection.',
            icon: Icons.flag_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Global Threat Card
          StructuredContentCard(
            heading: 'Antimicrobial Resistance: A Global Threat',
            content:
                'The CDC estimates that more than 2.8 million antibiotic-resistant infections occur in the United States each year, resulting in more than 35,000 deaths. Globally, antimicrobial resistance causes at least 700,000 deaths annually, with projections reaching 10 million deaths per year by 2050 if current trends continue.',
            icon: Icons.warning_amber_rounded,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),

          // Inappropriate Use Card
          StructuredContentCard(
            heading: 'The Problem of Inappropriate Use',
            content:
                'Studies show that 30-50% of antibiotics prescribed in hospitals are unnecessary or inappropriate. Common issues include: wrong choice, dose, or duration; failure to de-escalate therapy based on culture results; continuation of empiric broad-spectrum therapy without reassessment.',
            icon: Icons.error_outline,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),

          // WHO AWaRe Classification Card
          StructuredContentCard(
            heading: 'WHO AWaRe Classification System',
            content:
                'ACCESS antibiotics - first-line or second-line treatments with lower resistance potential; WATCH antibiotics - higher resistance potential, prioritized as key targets for stewardship; RESERVE antibiotics - last-resort options for multidrug-resistant infections only.',
            icon: Icons.category_outlined,
            color: AppColors.info,  // Blue: Informational classification system
          ),
          const SizedBox(height: 16),

          // Impact of AMS Programs Card
          StructuredContentCard(
            heading: 'Proven Impact of AMS Programs',
            content:
                'Reduce inappropriate antimicrobial use by 20-30%; Decrease antimicrobial resistance rates; Reduce Clostridioides difficile infections by 30-50%; Improve patient outcomes; Generate significant cost savings (estimated \$200,000-\$900,000 annually per hospital).',
            icon: Icons.trending_up,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),

          // CDC Core Elements Card
          StructuredContentCard(
            heading: 'CDC Core Elements Framework',
            content:
                'Leadership Commitment - dedicated resources and accountability; Accountability - single leader responsible for program outcomes; Drug Expertise - pharmacy leadership with infectious diseases training; Action - implementing evidence-based interventions; Tracking - monitoring antibiotic use and resistance patterns; Reporting - regular feedback to prescribers and leadership; Education - training healthcare staff on optimal prescribing.',
            icon: Icons.account_tree_outlined,
            color: AppColors.primary,  // Teal: General framework concept
          ),
          const SizedBox(height: 16),

          // Multidisciplinary Approach Card
          StructuredContentCard(
            heading: 'Multidisciplinary Team Approach',
            content:
                'Infectious disease physicians - clinical expertise and leadership; Clinical pharmacists - medication reviews and optimization; Infection preventionists - HAI tracking and surveillance; Microbiologists - susceptibility data and diagnostics; IT specialists - clinical decision support tools; Hospital administrators - resource allocation and support; Frontline clinicians - implementation and adherence.',
            icon: Icons.groups_outlined,
            color: AppColors.info,  // Blue: Informational team structure
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
      'AMS promotes appropriate antimicrobial use and reduces resistance',
      '30-50% of hospital antibiotics are unnecessary or inappropriate',
      'Antimicrobial resistance causes 35,000+ deaths annually in the US',
      'WHO AWaRe classification: Access, Watch, Reserve antibiotics',
      'CDC Core Elements: Leadership, Accountability, Expertise, Action, Tracking, Reporting, Education',
      'AMS programs reduce inappropriate use by 20-30% and C. diff by 30-50%',
      'Multidisciplinary approach is essential for success',
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
        'label': 'WHO AWaRe Classification of Antibiotics (2023)',
        'url': 'https://www.who.int/publications/i/item/2021-aware-classification',
      },
      {
        'label': 'IDSA/SHEA Guidelines for Developing an Institutional Program to Enhance Antimicrobial Stewardship (2016)',
        'url': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
      },
      {
        'label': 'CDC Antibiotic Resistance Threats Report (2019)',
        'url': 'https://www.cdc.gov/drugresistance/biggest-threats.html',
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

