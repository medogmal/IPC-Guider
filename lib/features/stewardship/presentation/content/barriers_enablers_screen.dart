import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

/// Dedicated screen for "Barriers and Enablers"
class BarriersEnablersScreen extends StatelessWidget {
  const BarriersEnablersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barriers and Enablers'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.insights,
            iconColor: AppColors.primary,  // Teal: General AMS concept
            title: 'Barriers and Enablers',
            subtitle: 'Fundamentals of AMS',
            description:
                'Implementing and sustaining antimicrobial stewardship programs requires overcoming significant barriers while leveraging key enablers. Understanding these factors is critical for program success and long-term sustainability. Common barriers include prescriber resistance, resource limitations, organizational culture, and competing priorities, while enablers include leadership support, multidisciplinary collaboration, data infrastructure, and regulatory drivers.',
          ),
          const SizedBox(height: 20),

          // Prescriber Resistance Card
          StructuredContentCard(
            heading: 'Prescriber Resistance',
            content:
                'Resistance from prescribers who may perceive stewardship interventions as interference with clinical autonomy, question the evidence base for recommendations, fear medicolegal consequences of withholding broad-spectrum therapy, or lack awareness of antimicrobial resistance and stewardship principles. Strategies to overcome: building trust through respectful, evidence-based communication; providing education on local resistance patterns and stewardship outcomes; involving physician champions from each department; and using persuasive rather than punitive approaches.',
            icon: Icons.block,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),

          // Resource Limitations Card
          StructuredContentCard(
            heading: 'Resource Limitations',
            content:
                'Many facilities struggle with inadequate staffing, lack of infectious disease expertise, limited information technology infrastructure, and competing budget priorities. Strategies to address: starting with low-resource interventions (e.g., automatic stop orders, IV-to-oral protocols); leveraging telehealth or regional collaboratives for infectious disease expertise; using free tools such as CDC\'s AU Module and antibiogram templates; and demonstrating cost savings to justify additional resources.',
            icon: Icons.warning_amber,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),

          // Organizational Culture Card
          StructuredContentCard(
            heading: 'Organizational Culture',
            content:
                'Barriers include: hierarchical structures that discourage pharmacist-physician collaboration, lack of accountability for antimicrobial prescribing, siloed departments with poor communication, and resistance to change. Enablers include: leadership commitment and visible support from hospital administration and medical staff leadership; inclusion of stewardship metrics in quality dashboards and provider scorecards; recognition and rewards for stewardship champions; and integration of stewardship into organizational quality and safety initiatives.',
            icon: Icons.business,
            color: AppColors.primary,  // Teal: Organizational concept
          ),
          const SizedBox(height: 16),

          // Competing Priorities Card
          StructuredContentCard(
            heading: 'Competing Priorities',
            content:
                'Healthcare facilities face numerous competing priorities including patient safety initiatives, regulatory compliance, financial pressures, and other quality improvement programs. Stewardship programs must demonstrate alignment with organizational goals such as: reducing healthcare-associated infections (linking stewardship with infection prevention), improving patient safety (preventing adverse drug events and C. difficile), meeting regulatory requirements (Joint Commission, CMS), and generating cost savings (reducing antimicrobial expenditures and length of stay).',
            icon: Icons.priority_high,
            color: AppColors.warning,  // Amber: Competing priorities require attention
          ),
          const SizedBox(height: 16),

          // Data and Technology Infrastructure Card
          StructuredContentCard(
            heading: 'Data and Technology Infrastructure',
            content:
                'Challenges include: inability to track antimicrobial use at the patient or unit level, lack of integration between pharmacy, microbiology, and EMR systems, absence of clinical decision support tools, and limited capacity for data analysis and reporting. Enablers include: investing in pharmacy information systems that track antimicrobial use; implementing EMR-based clinical decision support (order sets, alerts, time-outs); developing dashboards that integrate antimicrobial use, resistance, and outcome data; and partnering with IT specialists to automate reporting.',
            icon: Icons.storage,
            color: AppColors.info,  // Blue: Technology infrastructure information
          ),
          const SizedBox(height: 16),

          // Regulatory Drivers Card
          StructuredContentCard(
            heading: 'Regulatory and Accreditation Drivers',
            content:
                'External requirements can serve as powerful enablers. Key drivers include: Joint Commission standards requiring antimicrobial stewardship programs (Standard MM.09.01.01); CMS Conditions of Participation mandating stewardship programs for hospitals and long-term care facilities; State-level legislation requiring stewardship programs; and public reporting of antimicrobial use and resistance data. These requirements provide leverage for securing leadership support and resources.',
            icon: Icons.gavel,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Sustainability Strategies Card
          StructuredContentCard(
            heading: 'Sustainability Strategies',
            content:
                'Long-term sustainability requires: maintaining dedicated stewardship team time and resources; continuously demonstrating value through metrics and outcomes; adapting interventions based on data and feedback; celebrating successes and sharing stories; engaging new prescribers through onboarding and education; and fostering a culture of antimicrobial stewardship throughout the organization. Programs that integrate stewardship into routine clinical workflows and organizational culture are most likely to sustain improvements over time.',
            icon: Icons.trending_up,
            color: AppColors.success,
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
      'Common barriers: prescriber resistance, resource limitations, organizational culture, competing priorities',
      'Overcome prescriber resistance through trust, education, and physician champions',
      'Address resource limitations with low-resource interventions and demonstrating ROI',
      'Leadership commitment and accountability are critical enablers',
      'Align stewardship with organizational goals (HAI reduction, patient safety, cost savings)',
      'Invest in data infrastructure and clinical decision support tools',
      'Leverage regulatory drivers (Joint Commission, CMS) for support',
      'Sustainability requires continuous demonstration of value and cultural integration',
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
        'label': 'Joint Commission Standards for Antimicrobial Stewardship (MM.09.01.01)',
        'url': 'https://www.jointcommission.org/standards/standard-faqs/hospital-and-hospital-clinics/medication-management-mm/000001746/',
      },
      {
        'label': 'CMS Conditions of Participation: Antibiotic Stewardship Programs',
        'url': 'https://www.cms.gov/medicare/provider-enrollment-and-certification/surveycertificationgeninfo/policy-and-memos-states-and/downloads/survey-and-cert-letter-17-22.pdf',
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

