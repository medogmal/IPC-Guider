import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

class ProcessOutcomeMeasuresScreen extends StatelessWidget {
  const ProcessOutcomeMeasuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Process and Outcome Measures'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.assessment_outlined,
            iconColor: AppColors.primary,
            title: 'Process and Outcome Measures',
            subtitle: 'Demonstrating Stewardship Impact',
            description: 'Process measures (guideline compliance, de-escalation), outcome measures (CDI, MDRO, mortality), and balancing measures (readmissions, LOS, ADEs)',
          ),
          const SizedBox(height: 20),
          const IntroductionCard(
            text: 'Antimicrobial stewardship programs must measure both process and outcome metrics to demonstrate impact. Process measures assess adherence to stewardship interventions (e.g., compliance with guidelines, time to appropriate therapy). Outcome measures assess clinical and microbiological outcomes (e.g., C. diff rates, MDRO incidence, mortality). Balancing measures ensure that stewardship interventions do not cause unintended harm (e.g., increased readmissions, length of stay, adverse events).',
          ),
          const SizedBox(height: 20),
          _buildProcessMeasuresCard(),
          const SizedBox(height: 20),
          _buildOutcomeMeasuresCard(),
          const SizedBox(height: 20),
          _buildBalancingMeasuresCard(),
          const SizedBox(height: 20),
          _buildCompositeScoringCard(),
          const SizedBox(height: 20),
          _buildClinicalExample(),
          const SizedBox(height: 20),
          _buildKeyTakeawaysCard(),
          const SizedBox(height: 20),
          _buildReferencesCard(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProcessMeasuresCard() {
    return StructuredContentCard(
      icon: Icons.checklist,
      heading: 'Process Measures: Adherence to Stewardship Interventions',
      color: AppColors.info,  // Blue: Process measures information
      content: '''Guideline Compliance:
• Measure: % of patients receiving guideline-concordant therapy for common infections (CAP, UTI, sepsis)
• Example: 80 out of 100 CAP patients receive ceftriaxone + azithromycin (per IDSA guidelines) = 80% compliance
• Benchmark: Target >80% compliance
• Interventions: Academic detailing, order sets, audit and feedback

Time to Appropriate Therapy:
• Measure: Time from infection diagnosis to initiation of appropriate antimicrobial therapy
• Example: For sepsis, measure time from triage to first antibiotic dose
• Benchmark: Target <1 hour for septic shock (Surviving Sepsis Campaign)
• Interventions: Sepsis protocols, rapid diagnostics, pharmacist-driven protocols

De-escalation Rate:
• Measure: % of patients de-escalated from broad-spectrum to narrow-spectrum therapy after culture results
• Example: 60 out of 100 patients on vancomycin + piperacillin-tazobactam are de-escalated to ceftriaxone = 60%
• Benchmark: Target >70% de-escalation
• Interventions: Prospective audit and feedback, automatic alerts

IV-to-Oral Conversion Rate:
• Measure: % of eligible patients converted from IV to oral therapy
• Example: 50 out of 80 eligible patients are converted to oral therapy = 62.5%
• Benchmark: Target >70% conversion
• Interventions: EMR prompts, pharmacist-driven protocols, order sets with oral options''',
    );
  }

  Widget _buildOutcomeMeasuresCard() {
    return StructuredContentCard(
      icon: Icons.trending_down,
      heading: 'Outcome Measures: Clinical and Microbiological Outcomes',
      color: AppColors.info,  // Blue: Outcome measures information
      content: '''C. difficile Infection (CDI) Rates:
• Measure: Hospital-onset CDI per 10,000 patient-days
• Formula: CDI rate = (Number of hospital-onset CDI cases / Total patient-days) × 10,000
• Example: 10 CDI cases in a month with 10,000 patient-days = 10 per 10,000 patient-days
• Benchmark: NHSN SIR (Standardized Infection Ratio) target <1.0
• Associated with: Broad-spectrum antibiotic use (fluoroquinolones, clindamycin, cephalosporins)
• Interventions: Fluoroquinolone restriction, duration optimization

Multidrug-Resistant Organism (MDRO) Incidence:
• Measure: New MDRO infections per 1,000 patient-days (e.g., MRSA, CRE, VRE, ESBL)
• Example: 5 new CRE cases in a month with 10,000 patient-days = 0.5 per 1,000 patient-days
• Benchmark: Varies by organism and institution
• Associated with: Broad-spectrum antibiotic use (carbapenems, 3rd/4th generation cephalosporins)
• Interventions: Carbapenem restriction, de-escalation, infection prevention measures

Mortality:
• Measure: All-cause mortality or infection-related mortality
• Example: 10 out of 100 patients with sepsis die = 10% mortality
• Benchmark: Varies by infection and severity
• Important: Stewardship programs must ensure that interventions (e.g., de-escalation, duration reduction) do not increase mortality
• Balancing measure: Monitor mortality trends before and after stewardship interventions''',
    );
  }

  Widget _buildBalancingMeasuresCard() {
    return StructuredContentCard(
      icon: Icons.balance,
      heading: 'Balancing Measures: Ensuring No Unintended Harm',
      color: AppColors.warning,  // Amber: Balancing measures caution
      content: '''Readmissions:
• Measure: 30-day readmission rates for infection-related diagnoses
• Example: 15 out of 100 CAP patients are readmitted within 30 days = 15%
• Benchmark: Target <15% for CAP
• High readmission rates may indicate: Premature discharge, inadequate oral therapy, or treatment failure
• Interventions: Ensure adequate duration, IV-to-oral conversion criteria, discharge planning

Length of Stay (LOS):
• Measure: Average LOS for infection-related admissions
• Example: 100 CAP patients have a total LOS of 500 days = 5 days average LOS
• Benchmark: Varies by infection and severity
• Stewardship interventions (e.g., IV-to-oral conversion, duration reduction) should reduce LOS without increasing readmissions or mortality

Adverse Drug Events (ADEs):
• Measure: Antibiotic-related ADEs (e.g., acute kidney injury from vancomycin, C. diff from fluoroquinolones)
• Example: 10 out of 100 patients on vancomycin develop AKI = 10% ADE rate
• Benchmark: Varies by drug
• Interventions: TDM for vancomycin, dose optimization, fluoroquinolone restriction''',
    );
  }

  Widget _buildCompositeScoringCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Comparison card
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
                child: const Icon(Icons.calculate, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Composite Stewardship Scores',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Some programs use composite scores that combine process, outcome, and balancing measures into a single metric.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Example Formula:\nStewardship Score = (Guideline Compliance × 0.3) + (De-escalation Rate × 0.3) + (1 - CDI Rate × 0.2) + (1 - Mortality × 0.2)',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Composite scores provide a holistic view of stewardship performance but require careful weighting and validation.',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalExample() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Clinical example
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Icon(Icons.lightbulb, color: Colors.white, size: 24)),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case Example: Carbapenem Restriction Program', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Process Measure', 'Carbapenem DOT decreases from 80 to 50 per 1,000 patient-days (↓37.5%)', AppColors.info),  // Blue: Process measure
          const SizedBox(height: 10),
          _buildMetricRow('Outcome Measure', 'CRE incidence decreases from 1.0 to 0.5 per 1,000 patient-days (↓50%)', AppColors.info),  // Blue: Outcome measure
          const SizedBox(height: 10),
          _buildMetricRow('Balancing Measures', 'Mortality remains stable at 8%, readmission rate remains stable at 12%, LOS decreases from 7 to 6 days (↓14%)', AppColors.warning),  // Amber: Balancing measure
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Conclusion: The intervention is effective and safe.',
                    style: TextStyle(fontSize: 15, color: AppColors.success, fontWeight: FontWeight.bold, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String description, Color color) {
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

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Process measures: Guideline compliance (target >80%), time to appropriate therapy (<1h for septic shock), de-escalation rate (>70%), IV-to-oral conversion (>70%)',
      'Outcome measures: CDI rates (NHSN SIR <1.0), MDRO incidence (varies by organism), mortality (monitor trends)',
      'Balancing measures: Readmissions (<15% for CAP), length of stay (should decrease), adverse drug events (monitor AKI, C. diff)',
      'Composite stewardship scores: Combine process, outcome, and balancing measures into a single metric',
      'Case example: Carbapenem restriction → ↓37.5% DOT, ↓50% CRE incidence, stable mortality/readmissions, ↓14% LOS',
      'Stewardship interventions must demonstrate impact on both process and outcome measures',
      'Balancing measures ensure interventions do not cause unintended harm',
      'Monitor trends over time and benchmark against national data (NHSN)',
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
      'CDC NHSN Antimicrobial Use and Resistance Module (2024)': 'https://www.cdc.gov/nhsn/acute-care-hospital/au/index.html',
      'IDSA/SHEA Guidelines for Antimicrobial Stewardship (2016)': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
      'Surviving Sepsis Campaign Guidelines (2021)': 'https://www.sccm.org/SurvivingSepsisCampaign/Guidelines',
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

