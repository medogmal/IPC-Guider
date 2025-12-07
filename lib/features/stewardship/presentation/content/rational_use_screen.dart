import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page 1: Principles of Rational Antimicrobial Use
/// Pattern 1: Conceptual/Educational
/// Special UI: 4 Pillars card, PK/PD comparison card, tissue penetration card
class RationalUseScreen extends StatelessWidget {
  const RationalUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rational Antimicrobial Use'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.rule_outlined,
            iconColor: AppColors.success,  // Green: Rational use best practice
            title: 'Principles of Rational Antimicrobial Use',
            subtitle: 'Right Drug, Right Dose, Right Route, Right Duration',
            description: 'Foundation of effective infection management and antimicrobial stewardship',
          ),
          const SizedBox(height: 16),

          // Introduction Card
          const IntroductionCard(
            text: 'Rational antimicrobial use is the cornerstone of effective infection management and antimicrobial stewardship. It ensures that patients receive the right drug, at the right dose, by the right route, for the right duration—maximizing clinical efficacy while minimizing toxicity, cost, and resistance development.',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // 4 Pillars Card
          _buildFourPillarsCard(),
          const SizedBox(height: 16),

          // Spectrum of Activity Card
          StructuredContentCard(
            heading: 'Spectrum of Activity: Narrow vs. Broad',
            content: '''Narrow-spectrum agents target specific pathogens and preserve normal flora, reducing C. difficile risk and resistance selection pressure; Broad-spectrum agents are reserved for severe infections, polymicrobial infections, or when the pathogen is unknown; De-escalation to narrow-spectrum therapy once culture results are available is essential''',
            icon: Icons.filter_alt_outlined,
            color: AppColors.info,  // Blue: Principles information
          ),
          const SizedBox(height: 16),

          // PK/PD Card
          _buildPKPDCard(),
          const SizedBox(height: 16),

          // Tissue Penetration Card
          _buildTissuePenetrationCard(),
          const SizedBox(height: 16),

          // Clinical Example Card
          _buildClinicalExampleCard(),
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

  Widget _buildFourPillarsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Four pillars best practice
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
                child: const Icon(
                  Icons.account_balance,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'The 4 Pillars of Rational Use',
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
          _buildPillarItem('1', 'Right Drug', 'Select based on likely pathogen(s), local susceptibility patterns (antibiogram), infection site, and patient-specific factors. Narrow-spectrum agents preferred when pathogen known.', AppColors.info),  // Blue: Right Drug
          const SizedBox(height: 12),
          _buildPillarItem('2', 'Right Dose', 'Account for PK/PD principles. Time-dependent antibiotics (beta-lactams) require adequate time above MIC. Concentration-dependent antibiotics (aminoglycosides, fluoroquinolones) require high peak concentrations.', AppColors.info),  // Blue: Right Dose
          const SizedBox(height: 12),
          _buildPillarItem('3', 'Right Route', 'IV therapy for severe infections, hemodynamic instability, or inadequate oral bioavailability. Oral therapy preferred for stable patients with high-bioavailability agents (fluoroquinolones, linezolid, metronidazole).', AppColors.warning),  // Amber: Right Route
          const SizedBox(height: 12),
          _buildPillarItem('4', 'Right Duration', 'Evidence-based duration: short-course (3-5 days) for uncomplicated infections, extended (4-6 weeks) for deep-seated infections. Avoid unnecessarily prolonged courses.', AppColors.error),  // Red: Right Duration critical
        ],
      ),
    );
  }

  Widget _buildPillarItem(String number, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPKPDCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: PK/PD principles
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
                  Icons.science_outlined,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pharmacokinetics (PK) & Pharmacodynamics (PD)',
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
          _buildPKPDRow('Time-Dependent Killing', 'Beta-lactams, macrolides', 'Maximize time above MIC with frequent dosing or continuous infusion', AppColors.info),  // Blue: Time-dependent
          const SizedBox(height: 12),
          _buildPKPDRow('Concentration-Dependent Killing', 'Aminoglycosides, fluoroquinolones', 'Maximize Cmax/MIC ratio or AUC/MIC ratio with high peak concentrations', AppColors.info),  // Blue: Concentration-dependent
        ],
      ),
    );
  }

  Widget _buildPKPDRow(String type, String examples, String strategy, Color color) {
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
          Text(
            type,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Examples: $examples',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Strategy: $strategy',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTissuePenetrationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Tissue penetration caution
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
                  Icons.location_on_outlined,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tissue Penetration & Site-Specific Considerations',
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
          _buildTissueItem('CNS Infections', 'Ceftriaxone, meropenem, vancomycin', 'Good CSF penetration required', Icons.psychology),
          const SizedBox(height: 10),
          _buildTissueItem('Bone & Joint Infections', 'Fluoroquinolones, clindamycin, rifampin', 'Good bone penetration required', Icons.accessibility_new),
          const SizedBox(height: 10),
          _buildTissueItem('Intracellular Pathogens', 'Macrolides, fluoroquinolones', 'Intracellular penetration (Legionella, Chlamydia)', Icons.cell_tower),
        ],
      ),
    );
  }

  Widget _buildTissueItem(String site, String agents, String note, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.warning, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                site,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Agents: $agents',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                note,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClinicalExampleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Clinical example
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
                  color: AppColors.info,  // Blue: Definition information
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.medical_information, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Clinical Example: Community-Acquired Pneumonia',
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
            'A 45-year-old man with CAP is admitted with fever, cough, and infiltrate on chest X-ray.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
          _buildExampleStep('Empiric Therapy', 'Ceftriaxone 1g IV daily + azithromycin 500mg IV daily (covers S. pneumoniae, H. influenzae, atypical pathogens)', AppColors.info),  // Blue: Empiric
          const SizedBox(height: 10),
          _buildExampleStep('De-escalation', 'Blood cultures grow S. pneumoniae susceptible to penicillin → penicillin G 2 million units IV q4h (narrow-spectrum, time-dependent dosing)', AppColors.success),  // Green: De-escalation
          const SizedBox(height: 10),
          _buildExampleStep('IV-to-Oral', 'After 3 days of clinical stability → amoxicillin 1g PO TID (high bioavailability, cost-effective)', AppColors.warning),  // Amber: IV-to-Oral
          const SizedBox(height: 10),
          _buildExampleStep('Duration', 'Total 5 days (evidence-based for CAP)', AppColors.info),  // Blue: Duration
        ],
      ),
    );
  }

  Widget _buildExampleStep(String label, String content, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
              children: [
                TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                TextSpan(text: content),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Right drug, right dose, right route, right duration—the 4 pillars of rational use',
      'Narrow-spectrum agents preferred when pathogen known; broad-spectrum for severe/unknown infections',
      'Time-dependent antibiotics (beta-lactams): maximize time above MIC with frequent dosing or continuous infusion',
      'Concentration-dependent antibiotics (aminoglycosides, fluoroquinolones): maximize Cmax/MIC or AUC/MIC ratio',
      'Tissue penetration matters: CNS (ceftriaxone, meropenem), bone (fluoroquinolones), intracellular (macrolides)',
      'De-escalation to narrow-spectrum therapy once culture results available is essential',
      'Evidence-based duration: short-course (3-5 days) for uncomplicated infections, extended (4-6 weeks) for deep-seated infections',
      'Renal/hepatic dysfunction requires dose adjustments to prevent toxicity',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Key takeaways
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
      'Johns Hopkins ABX Guide: Antimicrobial Therapy': 'https://www.hopkinsguides.com/hopkins/index/Johns_Hopkins_ABX_Guide',
      'Sanford Guide to Antimicrobial Therapy (2024)': 'https://www.sanfordguide.com/',
      'IDSA Guidelines (Syndrome-Specific)': 'https://www.idsociety.org/practice-guideline/',
      'CDC Treatment Guidelines': 'https://www.cdc.gov/antibiotic-use/healthcare/index.html',
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

