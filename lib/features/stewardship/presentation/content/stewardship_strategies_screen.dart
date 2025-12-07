import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

/// Dedicated screen for "Antimicrobial Stewardship Strategies"
class StewardshipStrategiesScreen extends StatelessWidget {
  const StewardshipStrategiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antimicrobial Stewardship Strategies'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.psychology,
            iconColor: AppColors.info,  // Blue: Stewardship strategies information
            title: 'Antimicrobial Stewardship Strategies',
            subtitle: 'Fundamentals of AMS',
            description:
                'Antimicrobial stewardship programs employ a variety of evidence-based strategies to optimize antimicrobial use. The IDSA/SHEA guidelines categorize these interventions into two main approaches: restrictive (requiring approval before use) and persuasive (providing guidance and feedback). Most successful programs use a combination of both approaches tailored to their institutional culture and resources.',
          ),
          const SizedBox(height: 20),

          // Prospective Audit and Feedback Card
          StructuredContentCard(
            heading: 'Prospective Audit and Feedback',
            content:
                'The most widely used and effective stewardship strategy. The stewardship team reviews antimicrobial prescriptions 24-48 hours after initiation and provides recommendations to prescribers. Recommendations may include: de-escalation to narrower-spectrum agents based on culture results, dose optimization, IV-to-oral conversion, discontinuation of unnecessary therapy, or duration guidance. Acceptance rates typically range from 80-95% when delivered by trained stewardship teams.',
            icon: Icons.assessment,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Formulary Restriction Card
          StructuredContentCard(
            heading: 'Formulary Restriction and Preauthorization',
            content:
                'Requires prescribers to obtain approval from the stewardship team before prescribing certain restricted antimicrobials (typically broad-spectrum or expensive agents such as carbapenems, daptomycin, ceftaroline, or echinocandins). Preauthorization ensures appropriate use, prevents unnecessary broad-spectrum therapy, and provides an opportunity for education. However, it requires 24/7 availability of stewardship team members and may delay therapy if not implemented carefully.',
            icon: Icons.lock,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),

          // Clinical Pathways Card
          StructuredContentCard(
            heading: 'Clinical Pathways and Order Sets',
            content:
                'Syndrome-specific clinical pathways embedded in the electronic medical record (EMR) guide prescribers toward appropriate empiric therapy, dosing, and duration. Examples include pathways for community-acquired pneumonia, urinary tract infections, skin and soft tissue infections, and sepsis. Order sets should include: evidence-based first-line regimens, appropriate dosing based on renal function, default durations with automatic stop orders, and allergy verification prompts.',
            icon: Icons.route,
            color: AppColors.info,  // Blue: Clinical pathways guidance
          ),
          const SizedBox(height: 16),

          // Dose Optimization Card
          StructuredContentCard(
            heading: 'Dose Optimization and Therapeutic Drug Monitoring',
            content:
                'Ensuring optimal dosing is critical for treatment success and minimizing resistance. Strategies include: pharmacokinetic/pharmacodynamic (PK/PD) dosing for beta-lactams (extended or continuous infusions), therapeutic drug monitoring (TDM) for vancomycin and aminoglycosides, renal dose adjustments based on creatinine clearance, and obesity dosing protocols. Clinical pharmacists play a central role in dose optimization.',
            icon: Icons.tune,
            color: AppColors.primary,  // Teal: Dose optimization clinical concept
          ),
          const SizedBox(height: 16),

          // IV-to-Oral Conversion Card
          StructuredContentCard(
            heading: 'IV-to-Oral Conversion',
            content:
                'Many antimicrobials have excellent oral bioavailability (fluoroquinolones, linezolid, metronidazole, fluconazole, trimethoprim-sulfamethoxazole) and can be switched from IV to oral once patients are clinically stable, afebrile, hemodynamically stable, and able to tolerate oral intake. IV-to-oral conversion reduces costs, decreases catheter-related complications, and facilitates earlier hospital discharge.',
            icon: Icons.swap_horiz,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),

          // Antimicrobial Time-Outs Card
          StructuredContentCard(
            heading: 'Antimicrobial Time-Outs',
            content:
                'A structured reassessment of antimicrobial therapy at 48-72 hours after initiation, when culture results are typically available. The time-out prompts prescribers to: review culture results and de-escalate therapy, reassess clinical response and continue or discontinue therapy, optimize dose and route, and determine appropriate duration. Time-outs can be facilitated through EMR alerts or stewardship team interventions.',
            icon: Icons.schedule,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),

          // Rapid Diagnostic Testing Card
          StructuredContentCard(
            heading: 'Rapid Diagnostic Testing and Diagnostic Stewardship',
            content:
                'Implementing rapid diagnostic tests (such as blood culture identification panels, respiratory pathogen panels, or procalcitonin) can guide earlier de-escalation, reduce unnecessary antimicrobial use, and improve outcomes. Diagnostic stewardship ensures appropriate test ordering to avoid false positives and unnecessary treatment (e.g., avoiding urine cultures in asymptomatic patients).',
            icon: Icons.science,
            color: AppColors.info,  // Blue: Diagnostic testing information
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
      'Two main approaches: restrictive (preauthorization) and persuasive (audit/feedback)',
      'Prospective audit and feedback: most effective strategy, 80-95% acceptance rate',
      'Formulary restriction: requires approval for broad-spectrum agents',
      'Clinical pathways: syndrome-specific guidance embedded in EMR',
      'Dose optimization: PK/PD dosing, TDM, renal adjustments',
      'IV-to-oral conversion: reduces costs and complications',
      'Antimicrobial time-outs: reassess at 48-72 hours with culture results',
      'Rapid diagnostics: enable earlier de-escalation and improve outcomes',
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
        'label': 'IDSA/SHEA Guidelines for Developing an Institutional Program to Enhance Antimicrobial Stewardship (2016)',
        'url': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
      },
      {
        'label': 'CDC Core Elements of Hospital Antibiotic Stewardship Programs (2019)',
        'url': 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html',
      },
      {
        'label': 'Cochrane Review: Interventions to Improve Antibiotic Prescribing Practices (2017)',
        'url': 'https://www.cochranelibrary.com/cdsr/doi/10.1002/14651858.CD003543.pub4/full',
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

