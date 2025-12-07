import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

/// Dedicated screen for "Measuring Stewardship Success"
class MeasuringSuccessScreen extends StatelessWidget {
  const MeasuringSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measuring Stewardship Success'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.analytics,
            iconColor: AppColors.success,  // Green: Success measurement
            title: 'Measuring Stewardship Success',
            subtitle: 'Fundamentals of AMS',
            description:
                'Measuring the impact of antimicrobial stewardship programs is essential for demonstrating value, identifying areas for improvement, and ensuring sustainability. The CDC Core Elements emphasize the importance of tracking antimicrobial use and resistance patterns, and reporting outcomes to prescribers and leadership. Stewardship metrics are typically categorized into process measures, outcome measures, and balancing measures.',
          ),
          const SizedBox(height: 20),

          // Process Measures Card
          StructuredContentCard(
            heading: 'Process Measures',
            content:
                'Days of Therapy (DOT) per 1,000 patient-days - the most commonly used metric, counts each day a patient receives an antimicrobial regardless of dose; Defined Daily Dose (DDD) per 1,000 patient-days - standardized metric based on WHO-defined average daily doses, useful for international comparisons; Antimicrobial spectrum coverage days - measures the breadth of antimicrobial coverage; Compliance with treatment guidelines - percentage of patients receiving guideline-concordant therapy.',
            icon: Icons.checklist,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Outcome Measures Card
          StructuredContentCard(
            heading: 'Outcome Measures',
            content:
                'Clostridioides difficile infection (CDI) rates - CDI incidence per 10,000 patient-days, a sensitive indicator of antimicrobial overuse; Antimicrobial resistance rates - percentage of isolates resistant to key antimicrobials, tracked through antibiograms; Multidrug-resistant organism (MDRO) incidence - rates of MRSA, VRE, ESBL, CRE infections; Length of stay and mortality - for specific infection syndromes; Cost savings - reduction in antimicrobial expenditures and avoidance of complications.',
            icon: Icons.show_chart,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),

          // Balancing Measures Card
          StructuredContentCard(
            heading: 'Balancing Measures',
            content:
                'All-cause mortality - to ensure stewardship does not delay appropriate therapy; Hospital readmission rates - to detect premature discontinuation of therapy; Treatment failure rates - to identify inadequate therapy; Adverse drug events - to monitor for toxicity from dose optimization; Time to appropriate therapy - to ensure preauthorization does not delay treatment.',
            icon: Icons.balance,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),

          // Benchmarking Card
          StructuredContentCard(
            heading: 'Benchmarking',
            content:
                'Comparing stewardship metrics to internal historical data and external benchmarks helps contextualize performance. The CDC National Healthcare Safety Network (NHSN) Antimicrobial Use (AU) Module provides standardized definitions and benchmarking data for hospitals. Facilities can compare their antimicrobial use to similar hospitals by bed size, teaching status, and patient population. Internal benchmarking (unit-to-unit or year-over-year) is also valuable for tracking progress.',
            icon: Icons.compare_arrows,
            color: AppColors.info,  // Blue: Benchmarking information
          ),
          const SizedBox(height: 16),

          // Reporting and Feedback Card
          StructuredContentCard(
            heading: 'Reporting and Feedback',
            content:
                'Monthly or quarterly stewardship dashboards for leadership; Unit-specific antimicrobial use reports for medical directors; Individual prescriber feedback (peer comparison); Annual stewardship program reports highlighting successes and areas for improvement. Feedback should be timely, actionable, and non-punitive to encourage engagement.',
            icon: Icons.feedback,
            color: AppColors.info,  // Blue: Reporting information
          ),
          const SizedBox(height: 16),

          // Data Sources Card
          StructuredContentCard(
            heading: 'Data Sources',
            content:
                'Pharmacy dispensing data for antimicrobial consumption metrics; Microbiology data for resistance rates and culture-guided therapy metrics; Electronic medical records for clinical outcomes and guideline compliance; Administrative data for length of stay and costs; Infection prevention surveillance data for HAI rates. Integration of these data sources through dashboards or data warehouses facilitates comprehensive program evaluation.',
            icon: Icons.storage,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),

          // Continuous Quality Improvement Card
          StructuredContentCard(
            heading: 'Continuous Quality Improvement',
            content:
                'Stewardship programs should use Plan-Do-Study-Act (PDSA) cycles to test interventions, measure impact, and refine strategies. Regular review of metrics helps identify opportunities for improvement, such as high-use antimicrobials, units with low guideline compliance, or emerging resistance patterns. Celebrating successes and sharing best practices across the organization sustains momentum and engagement.',
            icon: Icons.autorenew,
            color: AppColors.success,  // Green: Continuous improvement best practice
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
      'Three metric categories: process, outcome, and balancing measures',
      'Process measures: DOT, DDD, spectrum days, guideline compliance',
      'Outcome measures: CDI rates, resistance rates, MDRO incidence, cost savings',
      'Balancing measures: mortality, readmissions, treatment failures, adverse events',
      'CDC NHSN AU Module provides standardized benchmarking',
      'Regular reporting to prescribers and leadership is essential',
      'Use PDSA cycles for continuous quality improvement',
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
        'label': 'CDC National Healthcare Safety Network (NHSN) Antimicrobial Use Module (2024)',
        'url': 'https://www.cdc.gov/nhsn/acute-care-hospital/au/index.html',
      },
      {
        'label': 'CDC Core Elements of Hospital Antibiotic Stewardship Programs (2019)',
        'url': 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html',
      },
      {
        'label': 'IDSA/SHEA Guidelines for Developing an Institutional Program to Enhance Antimicrobial Stewardship (2016)',
        'url': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
      },
      {
        'label': 'WHO Methodology for Point Prevalence Survey on Antibiotic Use (2018)',
        'url': 'https://www.who.int/publications/i/item/WHO-EMP-IAU-2018.01',
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

