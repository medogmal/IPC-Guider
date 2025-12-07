import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

class ConsumptionMetricsScreen extends StatelessWidget {
  const ConsumptionMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Antimicrobial Consumption Metrics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.assessment_outlined,
            iconColor: AppColors.primary,
            title: 'Antimicrobial Consumption Metrics',
            subtitle: 'Measuring Antibiotic Use',
            description: 'DOT, DDD, AU%, and DASC metrics for monitoring antimicrobial consumption and evaluating stewardship interventions',
          ),
          const SizedBox(height: 20),
          const IntroductionCard(
            text: 'Antimicrobial consumption metrics are essential for monitoring antibiotic use, identifying trends, and evaluating stewardship interventions. The most commonly used metrics are Days of Therapy (DOT) per 1,000 patient-days and Defined Daily Dose (DDD) per 1,000 patient-days. Each metric has strengths and limitations, and the choice depends on the stewardship program\'s goals and data availability.',
          ),
          const SizedBox(height: 20),
          _buildDOTCard(),
          const SizedBox(height: 20),
          _buildDDDCard(),
          const SizedBox(height: 20),
          _buildDOTvsDDDCard(),
          const SizedBox(height: 20),
          _buildAUPercentageCard(),
          const SizedBox(height: 20),
          _buildDASCCard(),
          const SizedBox(height: 20),
          _buildClinicalExample(),
          const SizedBox(height: 20),
          _buildImplementationCard(),
          const SizedBox(height: 20),
          _buildKeyTakeawaysCard(),
          const SizedBox(height: 20),
          _buildReferencesCard(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDOTCard() {
    return StructuredContentCard(
      icon: Icons.calendar_today,
      heading: 'DOT (Days of Therapy) per 1,000 Patient-Days',
      color: AppColors.info,  // Blue: DOT metric information
      content: '''Gold Standard for Hospital Stewardship
Counts the number of days a patient receives any amount of a specific antimicrobial agent, normalized per 1,000 patient-days

Formula:
DOT per 1,000 patient-days = (Total DOT / Total patient-days) × 1,000

Example:
If 500 patients received ceftriaxone for a total of 1,200 days in a month with 10,000 patient-days:
DOT = (1,200 / 10,000) × 1,000 = 120 DOT per 1,000 patient-days

Advantages:
• Reflects actual prescribing behavior (every day a patient receives an antibiotic counts)
• Not affected by dose variations (e.g., renal adjustments, loading doses)
• Recommended by CDC and NHSN AU Module
• Allows comparison across institutions and time periods

Limitations:
• Does not account for dose intensity (e.g., vancomycin 1g vs. 2g both count as 1 DOT)
• Requires accurate pharmacy dispensing data''',
    );
  }

  Widget _buildDDDCard() {
    return StructuredContentCard(
      icon: Icons.medication,
      heading: 'DDD (Defined Daily Dose) per 1,000 Patient-Days',
      color: AppColors.info,  // Blue: DDD metric information
      content: '''WHO Standard for International Comparisons
Based on the WHO-defined average maintenance dose for an adult

Formula:
DDD per 1,000 patient-days = (Total grams administered / DDD in grams) × 1,000 / Total patient-days

Example:
If 500 patients received 1,200g of ceftriaxone (DDD = 2g) in a month with 10,000 patient-days:
DDD = (1,200 / 2) × 1,000 / 10,000 = 60 DDD per 1,000 patient-days

Advantages:
• Accounts for dose intensity (higher doses = higher DDD)
• Standardized by WHO for international comparisons
• Useful for cost analysis (higher DDD = higher drug costs)

Limitations:
• DDD may not reflect actual prescribing (e.g., ceftriaxone DDD = 2g, but typical dose = 1g)
• Not suitable for pediatrics (DDD based on adult doses)
• Less intuitive than DOT for clinicians''',
    );
  }

  Widget _buildDOTvsDDDCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: DOT vs DDD comparison
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.compare_arrows, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'DOT vs. DDD: When to Use Each?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildComparisonRow('Use DOT for:', 'Hospital stewardship programs (CDC/NHSN standard), tracking prescribing behavior (e.g., de-escalation, duration), comparing across institutions', AppColors.info),  // Blue: DOT guideline
          const SizedBox(height: 12),
          _buildComparisonRow('Use DDD for:', 'International comparisons (WHO standard), cost analysis and budget planning, dose intensity monitoring (e.g., vancomycin dose escalation)', AppColors.info),  // Blue: DDD guideline
          const SizedBox(height: 12),
          const Text(
            'Many programs report both metrics for comprehensive monitoring.',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildAUPercentageCard() {
    return StructuredContentCard(
      icon: Icons.percent,
      heading: 'Antibiotic Utilization Percentage (AU%)',
      color: AppColors.info,  // Blue: AU% metric information
      content: '''Percentage of Patients on Antibiotics
The percentage of patients receiving at least one antibiotic on a given day

Formula:
AU% = (Number of patients on antibiotics / Total patients) × 100

Example:
If 150 out of 500 patients are on antibiotics:
AU% = (150 / 500) × 100 = 30%

Benchmark:
• Typical hospital AU% ranges from 30-50%
• ICU often >50%
• High AU% may indicate overuse or high acuity
• Low AU% may indicate effective stewardship or low infection burden''',
    );
  }

  Widget _buildDASCCard() {
    return StructuredContentCard(
      icon: Icons.layers,
      heading: 'Days of Antibiotic Spectrum Coverage (DASC)',
      color: AppColors.success,  // Green: DASC best practice metric
      content: '''Emerging Metric for Spectrum Breadth
Accounts for the breadth of antibiotic spectrum by assigning weights based on spectrum

Weighting Example:
• Narrow-spectrum (e.g., penicillin) = 1
• Broad-spectrum (e.g., meropenem) = 3

Calculation:
If a patient receives ceftriaxone (weight = 1) for 5 days and meropenem (weight = 3) for 3 days:
DASC = (1 × 5) + (3 × 3) = 14

Benefits:
• Incentivizes narrow-spectrum therapy
• Penalizes broad-spectrum use

Limitation:
• Weighting schemes vary and are not yet standardized''',
    );
  }

  Widget _buildClinicalExample() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Clinical example
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.info, borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Icon(Icons.lightbulb, color: Colors.white, size: 24)),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case Example: DOT vs. DDD Discrepancy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'A 500-bed hospital reports DOT = 600 per 1,000 patient-days and DDD = 450 per 1,000 patient-days.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'Analysis: The discrepancy suggests that many patients receive lower-than-standard doses (e.g., renal adjustments, pediatric dosing).',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'Investigation: The stewardship team investigates and finds that 30% of patients have renal impairment requiring dose reductions.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),  // Green: Key lesson
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lesson: This highlights the importance of using both metrics to understand prescribing patterns.',
                    style: TextStyle(fontSize: 14, color: AppColors.success, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImplementationCard() {
    return StructuredContentCard(
      icon: Icons.settings,
      heading: 'Implementation Strategies',
      color: AppColors.error,  // Red: Critical implementation requirements
      content: '''• Establish baseline metrics before launching stewardship interventions
• Track metrics monthly and report to leadership and committees
• Stratify by unit (ICU, med-surg, ED), drug class (carbapenems, vancomycin), and indication (CAP, UTI, sepsis)
• Use control charts to identify trends and outliers
• Benchmark against NHSN AU Module data (national percentiles)
• Celebrate successes (e.g., 20% reduction in carbapenem DOT) and share best practices''',
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'DOT (Days of Therapy) per 1,000 patient-days: gold standard for hospital stewardship, reflects prescribing behavior, not affected by dose variations',
      'DDD (Defined Daily Dose) per 1,000 patient-days: WHO standard, accounts for dose intensity, useful for international comparisons and cost analysis',
      'DOT vs. DDD: Use DOT for tracking prescribing behavior and institutional comparisons; use DDD for international comparisons and cost analysis',
      'Antibiotic Utilization Percentage (AU%): percentage of patients on antibiotics, typical hospital AU% = 30-50%, ICU often >50%',
      'DASC (Days of Antibiotic Spectrum Coverage): emerging metric that accounts for spectrum breadth, incentivizes narrow-spectrum therapy',
      'Case example: DOT = 600, DDD = 450 suggests lower-than-standard doses (renal adjustments, pediatrics)',
      'Implementation: Establish baseline, track monthly, stratify by unit/drug/indication, use control charts, benchmark against NHSN',
      'Celebrate successes and share best practices to sustain stewardship momentum',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Key Takeaways', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...keyPoints.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReferencesCard(BuildContext context) {
    final references = {
      'CDC NHSN Antimicrobial Use Module (2024)': 'https://www.cdc.gov/nhsn/acute-care-hospital/au/index.html',
      'WHO Collaborating Centre for Drug Statistics Methodology (DDD)': 'https://www.whocc.no/atc_ddd_index/',
      'IDSA/SHEA Guidelines for Antimicrobial Stewardship (2016)': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: References
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.link, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Official References', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...references.entries.toList().asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () async {
                  final url = Uri.parse(entry.value.value);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                        child: Center(child: Text('${entry.key + 1}', style: const TextStyle(color: AppColors.info, fontSize: 13, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(entry.value.key, style: const TextStyle(color: AppColors.info, fontSize: 14, fontWeight: FontWeight.w500, decoration: TextDecoration.underline))),
                      const Icon(Icons.open_in_new, color: AppColors.info, size: 18),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

