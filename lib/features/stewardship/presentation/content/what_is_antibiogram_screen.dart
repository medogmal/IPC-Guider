import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page 1: What is an Antibiogram?
/// Pattern 1: Conceptual/Educational
/// Special UI: Types comparison card, CLSI M39 principles card
class WhatIsAntibiogramScreen extends StatelessWidget {
  const WhatIsAntibiogramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('What is an Antibiogram?'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.analytics_outlined,
            iconColor: AppColors.info,  // Blue: Antibiogram information
            title: 'What is an Antibiogram?',
            subtitle: 'Definition, Purpose & CLSI M39 Guidelines',
            description: 'Understanding antibiograms as essential tools for empiric therapy selection and resistance surveillance',
          ),
          const SizedBox(height: 16),

          // Introduction Card
          const IntroductionCard(
            text: 'An antibiogram is a periodic summary report of antimicrobial susceptibility test results for bacterial isolates from a defined population (e.g., hospital, unit, or patient group). It displays the percentage of isolates susceptible to commonly tested antimicrobial agents, providing essential data for empiric therapy selection and resistance surveillance.',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // Primary Purposes Card
          StructuredContentCard(
            heading: 'Primary Purposes of Antibiograms',
            content: '''Guide empiric antimicrobial therapy selection before culture results are available; Monitor local antimicrobial resistance trends over time; Support antimicrobial stewardship initiatives; Inform formulary decisions and treatment guidelines; Facilitate infection prevention and control efforts''',
            icon: Icons.flag_outlined,
            color: AppColors.info,  // Blue: Definition information
          ),
          const SizedBox(height: 16),

          // CLSI M39 Principles Card
          _buildCLSIM39Card(),
          const SizedBox(height: 16),

          // Three Types Card
          _buildThreeTypesCard(),
          const SizedBox(height: 16),

          // Update Frequency Card
          StructuredContentCard(
            heading: 'Update Frequency & Analysis Period',
            content: '''Antibiograms should be updated at least annually, with more frequent updates (quarterly or semi-annually) recommended for high-volume units or when significant resistance changes are detected. The analysis period typically covers 12 consecutive months to account for seasonal variations in bacterial prevalence and resistance patterns.''',
            icon: Icons.update,
            color: AppColors.info,  // Blue: Purpose information
          ),
          const SizedBox(height: 16),

          // Stewardship Value Card
          StructuredContentCard(
            heading: 'Value for Antimicrobial Stewardship',
            content: '''Antibiograms are essential tools for antimicrobial stewardship programs. They enable data-driven empiric therapy recommendations, help identify emerging resistance threats, support de-escalation strategies, and provide objective evidence for formulary restrictions or preauthorization requirements.''',
            icon: Icons.verified_outlined,
            color: AppColors.success,  // Green: Key components best practice
          ),
          const SizedBox(height: 16),

          // Limitations Card
          _buildLimitationsCard(),
          const SizedBox(height: 16),

          // Effective Use Card
          StructuredContentCard(
            heading: 'Effective Antibiogram Use',
            content: '''Effective antibiogram use requires integration with clinical guidelines, local epidemiology, patient-specific factors (severity of illness, prior cultures, recent antimicrobial exposure), and infection source. Antibiograms should complement, not replace, clinical judgment and should always be updated with definitive culture and susceptibility results when available.''',
            icon: Icons.integration_instructions,
            color: AppColors.warning,  // Amber: Limitations caution
          ),
          const SizedBox(height: 20),

          // Key Takeaways Card
          _buildKeyTakeawaysCard(),
          const SizedBox(height: 20),

          // References Card
          _buildReferencesCard(context),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildCLSIM39Card() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Example table
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
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
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.rule_outlined,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'CLSI M39 Key Principles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'The Clinical and Laboratory Standards Institute (CLSI) M39 guideline (4th edition, 2014, reaffirmed 2022) provides standardized methodology for antibiogram development:',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          _buildPrincipleItem(
            '1',
            'First Isolate Rule',
            'Use first isolate per patient per analysis period (typically one year)',
            AppColors.info,  // Blue: Principle
          ),
          const SizedBox(height: 12),
          _buildPrincipleItem(
            '2',
            'Diagnostic Specimens Only',
            'Include only diagnostic specimens (exclude surveillance cultures)',
            AppColors.info,  // Blue: Principle
          ),
          const SizedBox(height: 12),
          _buildPrincipleItem(
            '3',
            'Minimum Threshold',
            'Require minimum of 30 isolates per organism-drug combination for reporting',
            AppColors.info,  // Blue: Principle
          ),
          const SizedBox(height: 12),
          _buildPrincipleItem(
            '4',
            'Stratification',
            'Stratify data by patient location or infection type when appropriate',
            AppColors.info,  // Blue: Principle
          ),
        ],
      ),
    );
  }

  Widget _buildPrincipleItem(String number, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeTypesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Interpretation examples
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
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
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Three Main Types of Antibiograms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTypeRow(
            '1',
            'Cumulative Antibiograms',
            'Summarize susceptibility data for all isolates from a defined population over a specified time period (typically annual)',
            AppColors.info,  // Blue: Type information
            Icons.summarize,
          ),
          const SizedBox(height: 12),
          _buildTypeRow(
            '2',
            'Unit-Specific Antibiograms',
            'Focus on specific hospital units (e.g., ICU, oncology) where resistance patterns may differ from facility-wide data',
            AppColors.warning,  // Amber: Unit-specific consideration
            Icons.local_hospital,
          ),
          const SizedBox(height: 12),
          _buildTypeRow(
            '3',
            'Syndrome-Specific Antibiograms',
            'Target specific infection types (e.g., urinary tract infections, bloodstream infections) to guide syndrome-specific empiric therapy',
            AppColors.success,  // Green: Best practice
            Icons.medical_services,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeRow(String number, String title, String description, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
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

  Widget _buildLimitationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),  // Red: Critical pitfalls
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
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
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_outlined,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Limitations of Antibiograms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLimitationItem('Represent population-level data and may not reflect individual patient risk factors'),
          _buildLimitationItem('Cannot account for prior antimicrobial exposure or colonization status'),
          _buildLimitationItem('May be influenced by testing practices and specimen types'),
          _buildLimitationItem('Require sufficient isolate numbers for statistical validity (≥30 isolates per organism-drug combination)'),
        ],
      ),
    );
  }

  Widget _buildLimitationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Antibiogram = periodic summary of antimicrobial susceptibility data for a defined population',
      'CLSI M39 guideline provides standardized methodology (first isolate rule, ≥30 isolates threshold)',
      'Three types: cumulative (facility-wide), unit-specific (ICU, oncology), syndrome-specific (UTI, BSI)',
      'Primary purpose: guide empiric therapy selection before culture results available',
      'Update frequency: annual minimum, quarterly for high-volume units',
      'Limitations: population-level data, cannot account for individual patient factors',
      'Must integrate with clinical guidelines, patient factors, and infection source',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Best practices
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
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
          ...keyPoints.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
                        color: AppColors.textPrimary,
                        height: 1.5,
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

  Widget _buildReferencesCard(BuildContext context) {
    final references = {
      'CLSI M39-A4: Analysis and Presentation of Cumulative Antimicrobial Susceptibility Test Data (4th Edition, 2014, Reaffirmed 2022)': 'https://clsi.org/standards/products/microbiology/documents/m39/',
      'CDC Antibiogram Toolkit: Guidance for Developing and Using Antibiograms': 'https://www.cdc.gov/antibiotic-use/healthcare/implementation/antibiograms.html',
      'IDSA/SHEA Guidelines for Developing an Institutional Program to Enhance Antimicrobial Stewardship (2016)': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
      'WHO Methodology for Point Prevalence Survey on Antibiotic Use in Hospitals (2018)': 'https://www.who.int/publications/i/item/WHO-EMP-IAU-2018.01',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: References
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.link,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
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
          ...references.entries.toList().asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () async {
                  final uri = Uri.parse(entry.value.value);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: AppColors.info,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value.key,
                          style: const TextStyle(
                            color: AppColors.info,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.open_in_new,
                        color: AppColors.info,
                        size: 18,
                      ),
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

