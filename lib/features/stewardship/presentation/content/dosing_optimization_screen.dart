import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page 3: Antibiotic Dosing Optimization
/// Pattern 3: Reference/Technical
/// Special UI: Loading/maintenance doses card, renal adjustment table, TDM targets card
class DosingOptimizationScreen extends StatelessWidget {
  const DosingOptimizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosing Optimization'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.medication_liquid_outlined,
            iconColor: AppColors.success,  // Green: Dosing optimization
            title: 'Antibiotic Dosing Optimization',
            subtitle: 'PK/PD Principles, Renal/Hepatic Adjustments, TDM',
            description: 'Ensuring therapeutic concentrations while minimizing toxicity through optimized dosing strategies',
          ),
          const SizedBox(height: 16),

          // Introduction Card
          const IntroductionCard(
            text: 'Dosing optimization ensures that antimicrobial concentrations at the infection site are sufficient to kill pathogens while minimizing toxicity. This requires understanding of pharmacokinetics (PK), pharmacodynamics (PD), patient-specific factors (renal/hepatic function, obesity), and therapeutic drug monitoring (TDM).',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // Loading & Maintenance Doses Card
          _buildLoadingMaintenanceCard(),
          const SizedBox(height: 16),

          // Renal Dose Adjustments Card
          _buildRenalAdjustmentCard(),
          const SizedBox(height: 16),

          // Hepatic Dose Adjustments Card
          StructuredContentCard(
            heading: 'Hepatic Dose Adjustments',
            content: '''Drugs metabolized by the liver (metronidazole, clindamycin, macrolides) may require dose adjustments in severe hepatic impairment (Child-Pugh Class C); Specific dosing recommendations are limited; Therapeutic drug monitoring (TDM) may be helpful when available''',
            icon: Icons.local_hospital_outlined,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // Obesity Dosing Card
          _buildObesityDosingCard(),
          const SizedBox(height: 16),

          // TDM Card
          _buildTDMCard(),
          const SizedBox(height: 16),

          // Extended/Continuous Infusions Card
          StructuredContentCard(
            heading: 'Extended or Continuous Infusions',
            content: '''For time-dependent antibiotics (beta-lactams), extended infusions (over 3-4 hours) or continuous infusions maximize time above MIC, improving outcomes in severe infections caused by pathogens with elevated MICs; Example: piperacillin-tazobactam 3.375g IV over 4 hours q8h (extended infusion) or 12g IV continuous infusion over 24 hours''',
            icon: Icons.water_drop_outlined,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // Clinical Example 1: Vancomycin in Obesity
          _buildClinicalExample1(),
          const SizedBox(height: 16),

          // Clinical Example 2: Renal Adjustment
          _buildClinicalExample2(),
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

  Widget _buildLoadingMaintenanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Loading vs maintenance
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
                child: const Icon(Icons.speed, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Loading & Maintenance Doses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDoseTypeRow('Loading Dose', 'Achieve therapeutic concentrations rapidly in severe infections', 'Based on actual body weight (not adjusted for renal function)', 'Vancomycin: 25-30mg/kg IV (max 3g)', AppColors.info),
          const SizedBox(height: 12),
          _buildDoseTypeRow('Maintenance Dose', 'Maintain therapeutic concentrations after loading dose', 'Adjusted based on renal function (renally cleared) or hepatic function', 'Dosing intervals determined by drug half-life and PK/PD target', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildDoseTypeRow(String type, String purpose, String note1, String note2, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text(purpose, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
          const SizedBox(height: 4),
          Text('• $note1', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          Text('• $note2', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildRenalAdjustmentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Renal adjustment
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
                child: const Icon(Icons.water_damage_outlined, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Renal Dose Adjustments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Most beta-lactams, vancomycin, and aminoglycosides are renally cleared and require dose adjustments in renal impairment. Creatinine clearance (CrCl) is estimated using the Cockcroft-Gault equation.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 14),
          _buildRenalExampleRow('Ceftriaxone', 'No renal adjustment (biliary excretion)', AppColors.success),
          const SizedBox(height: 8),
          _buildRenalExampleRow('Cefepime', 'Requires dose reduction when CrCl <60 mL/min', AppColors.error),
          const SizedBox(height: 8),
          _buildRenalExampleRow('Vancomycin', 'Dose and interval adjusted based on CrCl and TDM', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildRenalExampleRow(String drug, String adjustment, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(color == AppColors.success ? Icons.check_circle : Icons.warning, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
              children: [
                TextSpan(text: '$drug: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: adjustment),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObesityDosingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Obesity dosing
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
                child: const Icon(Icons.monitor_weight_outlined, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Obesity Dosing Considerations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildObesityRow('Hydrophilic Drugs', 'Beta-lactams, aminoglycosides', 'Limited distribution into adipose tissue', 'Dose based on ABW or IBW', AppColors.info),
          const SizedBox(height: 12),
          _buildObesityRow('Lipophilic Drugs', 'Fluoroquinolones, linezolid', 'Distribute into adipose tissue', 'May require TBW dosing', AppColors.warning),
          const SizedBox(height: 12),
          _buildObesityRow('Vancomycin', 'Loading: TBW; Maintenance: ABW or TDM-guided', 'Complex dosing in obesity', 'TDM essential', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildObesityRow(String drugType, String examples, String distribution, String dosing, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(drugType, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text('Examples: $examples', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          Text('Distribution: $distribution', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text('Dosing: $dosing', style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTDMCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: TDM
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_outlined, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Therapeutic Drug Monitoring (TDM)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'TDM is recommended for drugs with narrow therapeutic windows to optimize efficacy and minimize toxicity.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 14),
          _buildTDMRow('Vancomycin', 'AUC/MIC ratio 400-600 for serious MRSA infections (using Bayesian dosing software)', AppColors.success),
          const SizedBox(height: 10),
          _buildTDMRow('Aminoglycosides', 'Peak: gentamicin 8-10 mcg/mL for Gram-negative infections; Trough: <1 mcg/mL to minimize nephrotoxicity', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildTDMRow(String drug, String target, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(drug, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text('Target: $target', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildClinicalExample1() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Example 1
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
                child: const Center(child: Text('1', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 1: Vancomycin Dosing in Obesity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 35-year-old man with MRSA bacteremia weighs 150 kg (height 180 cm, BMI 46). IBW = 75 kg, ABW = 105 kg.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('LOADING DOSE', 'Vancomycin 25 mg/kg × 150 kg = 3,750 mg (use 3g max for safety)', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('MAINTENANCE DOSE', '15 mg/kg × 105 kg (ABW) = 1,575 mg IV q12h (round to 1,500 mg)', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('TDM', 'Performed at steady state (after 4th dose) to target AUC/MIC 400-600', AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildClinicalExample2() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Example 2
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 2: Renal Dose Adjustment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 70-year-old woman with hospital-acquired pneumonia has CrCl 25 mL/min.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('STANDARD DOSE', 'Cefepime 2g IV q8h', AppColors.warning),
          const SizedBox(height: 8),
          _buildExampleSection('ADJUSTED DOSE', 'For CrCl 11-29 mL/min: 2g IV q24h (per package insert)', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('MONITORING', 'Monitor for neurotoxicity (confusion, seizures) in severe renal impairment', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildExampleSection(String label, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
      ],
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Loading doses: achieve rapid therapeutic concentrations in severe infections (vancomycin 25-30mg/kg)',
      'Maintenance doses: adjusted for renal function (beta-lactams, vancomycin, aminoglycosides) or hepatic function',
      'Renal dose adjustments: use Cockcroft-Gault CrCl; reduce dose, extend interval, or both',
      'Obesity dosing: hydrophilic drugs (ABW/IBW), lipophilic drugs (TBW), vancomycin (TBW loading, ABW maintenance)',
      'TDM for narrow therapeutic window drugs: vancomycin (AUC/MIC 400-600), aminoglycosides (peak 8-10 mcg/mL, trough <1)',
      'Extended/continuous infusions for beta-lactams: maximize time above MIC for severe infections',
      'Ceftriaxone: no renal adjustment (biliary excretion); cefepime: requires renal adjustment',
      'Consult pharmacist or ID specialist for complex dosing scenarios',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Key takeaways
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(8)),
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
                    decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(12)),
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
      'Vancomycin TDM Guidelines (ASHP/IDSA/SIDP 2020)': 'https://academic.oup.com/ajhp/article/77/11/835/5810200',
      'Aminoglycoside Dosing Guidelines': 'https://www.hopkinsguides.com/hopkins/index/Johns_Hopkins_ABX_Guide',
      'Sanford Guide to Antimicrobial Therapy (2024)': 'https://www.sanfordguide.com/',
      'CDC Treatment Guidelines: Dosing Considerations': 'https://www.cdc.gov/antibiotic-use/healthcare/index.html',
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
                decoration: BoxDecoration(color: AppColors.info, borderRadius: BorderRadius.circular(8)),
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

