import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page 3: Interpreting Antibiogram Data
/// Pattern 2: Practical/Action-Oriented
/// Special UI: Susceptibility threshold card, clinical examples, comparison table
class InterpretingAntibiogramScreen extends StatelessWidget {
  const InterpretingAntibiogramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interpreting Antibiogram Data'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.insights_outlined,
            iconColor: AppColors.info,  // Blue: Interpreting antibiogram
            title: 'Interpreting Antibiogram Data',
            subtitle: 'Reading Susceptibility Data & Identifying Trends',
            description: 'Practical guide to interpreting antibiogram data and applying it to empiric therapy decisions',
          ),
          const SizedBox(height: 16),

          // Introduction Card
          const IntroductionCard(
            text: 'Interpreting antibiogram data requires understanding susceptibility percentages, recognizing resistance trends, and applying this information to empiric therapy decisions. Antibiograms provide population-level guidance but must be integrated with patient-specific factors and clinical context.',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // Susceptibility Threshold Card
          _buildSusceptibilityThresholdCard(),
          const SizedBox(height: 16),

          // Resistance Trends Card
          _buildResistanceTrendsCard(),
          const SizedBox(height: 16),

          // Unit Comparison Card
          _buildUnitComparisonCard(),
          const SizedBox(height: 16),

          // Empiric Therapy Selection Card
          StructuredContentCard(
            heading: 'Using Antibiograms for Empiric Therapy Selection',
            content: '''Choose antimicrobials with ≥90% susceptibility for the most likely pathogen(s) when possible; For polymicrobial infections or when multiple pathogens are possible, select agents with broad coverage; Consider infection severity: for sepsis or life-threatening infections, use broader-spectrum agents even if susceptibility is 80-89%; For uncomplicated infections, narrower-spectrum agents with 80-89% susceptibility may be acceptable''',
            icon: Icons.medication_outlined,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // Clinical Example 1: UTI
          _buildClinicalExample1(),
          const SizedBox(height: 16),

          // Clinical Example 2: HAP
          _buildClinicalExample2(),
          const SizedBox(height: 16),

          // Limitations Card
          _buildLimitationsCard(),
          const SizedBox(height: 16),

          // Best Practices Card
          StructuredContentCard(
            heading: 'Best Practices for Antibiogram Interpretation',
            content: '''Use the most recent antibiogram available; Prefer unit-specific or syndrome-specific antibiograms when available; Consider patient risk factors for resistance (recent antibiotics, hospitalization, healthcare exposure, travel); Always de-escalate to narrower-spectrum agents once culture results are available; Monitor clinical response and adjust therapy if no improvement within 48-72 hours; Consult infectious disease specialists for complex cases or when antibiogram guidance is unclear''',
            icon: Icons.checklist_outlined,
            color: AppColors.success,
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

  Widget _buildSusceptibilityThresholdCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Susceptibility thresholds
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
                  Icons.percent,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Reading Susceptibility Percentages',
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
            'The percentage represents the proportion of isolates susceptible to a given antimicrobial. A general rule of thumb:',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          _buildThresholdRow('≥90%', 'Excellent for empiric therapy', AppColors.success),
          const SizedBox(height: 10),
          _buildThresholdRow('80-89%', 'Acceptable for non-severe infections', AppColors.warning),
          const SizedBox(height: 10),
          _buildThresholdRow('<80%', 'Suboptimal - consider alternatives or combination therapy', AppColors.error),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Example: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'If E. coli shows 85% susceptibility to ciprofloxacin, this means 85 out of 100 E. coli isolates tested were susceptible.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdRow(String threshold, String interpretation, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              threshold,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              interpretation,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResistanceTrendsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Comparing organisms
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
                child: const Icon(
                  Icons.trending_down,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Identifying Resistance Trends',
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
            'Compare current antibiogram to previous years to detect emerging resistance. A ≥10% change in susceptibility over one year or a consistent downward trend over multiple years warrants investigation and may require changes to empiric therapy guidelines.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Example: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'If ciprofloxacin susceptibility for E. coli decreased from 90% (2022) to 85% (2023) to 78% (2024), this signals a concerning trend requiring stewardship intervention.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitComparisonCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Comparing units
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
                  Icons.compare_arrows,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Unit-Specific vs. Facility-Wide Data',
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
            'ICU antibiograms typically show 10-20% lower susceptibility rates compared to general wards due to sicker patients, greater antimicrobial exposure, and higher prevalence of healthcare-associated infections.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Clinicians should use unit-specific antibiograms when available for their practice setting.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Example: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Facility-wide E. coli susceptibility to ceftriaxone may be 92%, but ICU-specific susceptibility may be only 78%.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalExample1() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Example 1
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Clinical Example: Uncomplicated UTI',
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
          _buildExampleSection(
            'ANTIBIOGRAM DATA',
            'Facility antibiogram shows E. coli susceptibility: nitrofurantoin 95%, trimethoprim-sulfamethoxazole 82%, ciprofloxacin 78%, ampicillin 55%.',
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildExampleSection(
            'DECISION',
            'For uncomplicated cystitis in a non-pregnant woman, nitrofurantoin is the optimal empiric choice (95% susceptibility, narrow spectrum). Trimethoprim-sulfamethoxazole is acceptable if nitrofurantoin is contraindicated.',
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildExampleSection(
            'AVOID',
            'Ciprofloxacin should be reserved for complicated infections. Ampicillin should not be used empirically due to high resistance (55%).',
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalExample2() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Example 2
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Clinical Example: Hospital-Acquired Pneumonia',
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
          _buildExampleSection(
            'ANTIBIOGRAM DATA',
            'ICU antibiogram shows Pseudomonas aeruginosa susceptibility: cefepime 88%, piperacillin-tazobactam 85%, meropenem 92%, ciprofloxacin 75%.',
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildExampleSection(
            'DECISION',
            'For severe HAP in an ICU patient, meropenem (92% susceptibility) or cefepime (88%) would be appropriate empiric choices.',
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildExampleSection(
            'AVOID',
            'Ciprofloxacin monotherapy (75%) would be inadequate for severe infection. Consider combination therapy (beta-lactam + aminoglycoside or fluoroquinolone) for critically ill patients.',
            AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildExampleSection(String label, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLimitationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),  // Red: Common pitfalls
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
                  'Limitations & Caveats',
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
          _buildLimitationItem('Antibiograms reflect past susceptibility patterns and may not predict current resistance in individual patients'),
          _buildLimitationItem('Prior antimicrobial exposure increases resistance risk beyond antibiogram predictions'),
          _buildLimitationItem('Antibiograms do not account for patient-specific factors (immunosuppression, recent hospitalization, travel history)'),
          _buildLimitationItem('Low isolate numbers (<30) reduce statistical reliability'),
          _buildLimitationItem('Antibiograms may be influenced by changes in testing methods or patient populations'),
          _buildLimitationItem('Susceptibility does not guarantee clinical efficacy - consider pharmacokinetics, infection site, and host factors'),
        ],
      ),
    );
  }

  Widget _buildLimitationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
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
      'Susceptibility ≥90% = excellent for empiric therapy; 80-89% = acceptable; <80% = suboptimal',
      'Resistance trend: ≥10% change in one year or consistent downward trend warrants intervention',
      'ICU antibiograms typically show 10-20% lower susceptibility than facility-wide data',
      'Choose agents with ≥90% susceptibility for likely pathogen(s) when possible',
      'Infection severity matters: use broader agents for sepsis even if susceptibility 80-89%',
      'Limitations: past data, doesn\'t account for individual patient factors, low isolate numbers',
      'Always de-escalate to narrower-spectrum agents once culture results available',
      'Integrate antibiogram with patient risk factors, clinical context, and guidelines',
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
      'CLSI M39-A4: Analysis and Presentation of Cumulative Antimicrobial Susceptibility Test Data (2022)': 'https://clsi.org/standards/products/microbiology/documents/m39/',
      'IDSA Guidelines for Empiric Therapy Selection': 'https://www.idsociety.org/practice-guideline/',
      'CDC Antibiogram Toolkit: Interpreting and Using Antibiograms': 'https://www.cdc.gov/antibiotic-use/healthcare/implementation/antibiograms.html',
      'Sanford Guide to Antimicrobial Therapy (2024)': 'https://www.sanfordguide.com/',
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

