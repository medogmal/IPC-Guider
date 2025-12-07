import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page 4: Antibiogram-Guided Prescribing
/// Pattern 2: Practical/Action-Oriented
/// Special UI: Clinical scenario cards, special population cards, decision-making flowchart
class AntibiogramGuidedPrescribingScreen extends StatelessWidget {
  const AntibiogramGuidedPrescribingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antibiogram-Guided Prescribing'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.medical_services_outlined,
            iconColor: AppColors.info,  // Blue: Antibiogram-guided prescribing
            title: 'Antibiogram-Guided Prescribing',
            subtitle: 'Empiric Therapy Selection & De-escalation',
            description: 'Integrating local susceptibility data with clinical guidelines and patient-specific factors for optimal antimicrobial selection',
          ),
          const SizedBox(height: 16),

          // Introduction Card
          const IntroductionCard(
            text: 'Antibiogram-guided prescribing integrates local susceptibility data with clinical guidelines, patient-specific factors, and infection characteristics to optimize empiric antimicrobial selection. This approach balances the need for effective initial therapy with antimicrobial stewardship principles of spectrum narrowing and resistance prevention.',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // Empiric Therapy Principles Card
          StructuredContentCard(
            heading: 'Empiric Therapy Selection Principles',
            content: '''Identify the most likely pathogen(s) based on infection site and clinical presentation; Consult antibiogram for local susceptibility patterns; Choose agents with ≥90% susceptibility when possible; Consider infection severity and patient risk factors; Use narrowest-spectrum agent that provides adequate coverage; Plan for de-escalation once culture results available''',
            icon: Icons.rule_outlined,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // De-escalation Card
          _buildDeEscalationCard(),
          const SizedBox(height: 16),

          // Local vs National Guidelines Card
          _buildLocalVsNationalCard(),
          const SizedBox(height: 16),

          // Special Populations: ICU
          _buildICUCard(),
          const SizedBox(height: 16),

          // Special Populations: Oncology
          _buildOncologyCard(),
          const SizedBox(height: 16),

          // Special Populations: Transplant
          StructuredContentCard(
            heading: 'Special Populations: Transplant Recipients',
            content: '''Solid organ and hematopoietic stem cell transplant recipients have complex antimicrobial needs due to immunosuppression, prophylactic antimicrobial exposure, and risk of opportunistic infections. Empiric therapy must cover typical bacterial pathogens plus consider atypical organisms (Nocardia, Legionella, fungi). Use transplant unit-specific antibiograms when available. Consult infectious disease specialists early for guidance on empiric therapy and diagnostic workup.''',
            icon: Icons.favorite_outline,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // Clinical Scenario 1: Community UTI
          _buildClinicalScenario1(),
          const SizedBox(height: 16),

          // Clinical Scenario 2: Hospital-Acquired Pneumonia
          _buildClinicalScenario2(),
          const SizedBox(height: 16),

          // Clinical Scenario 3: ICU Sepsis
          _buildClinicalScenario3(),
          const SizedBox(height: 16),

          // Monitoring Card
          StructuredContentCard(
            heading: 'Monitoring & Reassessment',
            content: '''Empiric therapy should be reassessed at 48-72 hours based on: Clinical response (fever resolution, hemodynamic stability, symptom improvement); Microbiologic data (culture results, susceptibility testing); Adverse effects or drug interactions; Opportunity for de-escalation or IV-to-oral conversion. If no clinical improvement by 48-72 hours, consider: inadequate source control, resistant pathogen, incorrect diagnosis, drug-related issues (inadequate dosing, poor penetration), or non-infectious etiology.''',
            icon: Icons.monitor_heart_outlined,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),

          // Documentation Card
          StructuredContentCard(
            heading: 'Documentation & Communication',
            content: '''Document rationale for empiric antimicrobial selection, including antibiogram data consulted, patient risk factors considered, and plan for reassessment and de-escalation. Communicate with the care team about expected culture turnaround time and criteria for therapy modification. Use structured order sets or clinical pathways to standardize antibiogram-guided prescribing and facilitate stewardship interventions.''',
            icon: Icons.description_outlined,
            color: AppColors.info,
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

  Widget _buildDeEscalationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Community-acquired best practice
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
                  Icons.trending_down,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'De-escalation: Cornerstone of Stewardship',
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
            'De-escalation based on culture results is a cornerstone of antimicrobial stewardship. Once definitive culture and susceptibility results are available (typically 48-72 hours), therapy should be narrowed to the most specific agent effective against the identified pathogen.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'This reduces unnecessary broad-spectrum exposure, decreases C. difficile risk, and preserves broader agents for resistant infections.',
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
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.success,
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
                          text: 'If empiric therapy for sepsis included vancomycin + piperacillin-tazobactam, but cultures grow methicillin-susceptible S. aureus (MSSA), de-escalate to cefazolin or nafcillin monotherapy.',
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

  Widget _buildLocalVsNationalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Hospital-acquired caution
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
                  Icons.public,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Local vs. National Guidelines',
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
            'National guidelines (IDSA, ATS, ESCMID) provide evidence-based frameworks, but local antibiograms may reveal resistance patterns that differ from national data.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'When local susceptibility falls below guideline-recommended thresholds (typically <80-90%), empiric therapy recommendations should be adjusted.',
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
                          text: 'IDSA guidelines recommend fluoroquinolones for community-acquired pneumonia, but if local S. pneumoniae fluoroquinolone resistance exceeds 20%, alternative agents (e.g., beta-lactam + macrolide) should be preferred.',
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

  Widget _buildICUCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),  // Red: Septic shock critical
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
                  Icons.local_hospital,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Special Populations: ICU Patients',
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
            'Critically ill patients require broader empiric coverage due to higher risk of resistant pathogens, greater prior antimicrobial exposure, and higher mortality risk from inadequate initial therapy.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Use ICU-specific antibiograms when available. Consider combination therapy (e.g., beta-lactam + aminoglycoside or fluoroquinolone) for severe sepsis or septic shock.',
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
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.error,
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
                          text: 'For ICU-acquired pneumonia with risk factors for MDR Pseudomonas, use cefepime 2g IV q8h or meropenem 1g IV q8h based on ICU antibiogram susceptibility.',
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

  Widget _buildOncologyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Resistance patterns
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
                  Icons.healing,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Special Populations: Oncology/Neutropenic',
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
            'Febrile neutropenia requires immediate broad-spectrum empiric therapy due to rapid progression and high mortality risk.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Use antipseudomonal beta-lactams (cefepime, piperacillin-tazobactam, meropenem) with ≥90% susceptibility to Pseudomonas and Enterobacterales. Add vancomycin if catheter-related infection, skin/soft tissue infection, or hemodynamic instability present.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Consult oncology-specific antibiograms if available, as these patients often have unique resistance patterns due to frequent antimicrobial exposure and prolonged hospitalizations.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalScenario1() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Uncomplicated cystitis example
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
                  'Case 1: Community-Acquired UTI',
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
          _buildScenarioSection(
            'PRESENTATION',
            'A 35-year-old woman presents to the ED with dysuria, frequency, and urgency. No fever, no flank pain. Urinalysis shows pyuria and bacteriuria.',
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildScenarioSection(
            'ANTIBIOGRAM',
            'Facility antibiogram shows E. coli susceptibility: nitrofurantoin 95%, trimethoprim-sulfamethoxazole 82%, ciprofloxacin 78%.',
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildScenarioSection(
            'DECISION',
            'Prescribe nitrofurantoin 100mg PO BID for 5 days (first-line per guidelines, 95% susceptibility, narrow spectrum). Avoid ciprofloxacin (fluoroquinolone stewardship, only 78% susceptibility).',
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildScenarioSection(
            'OUTCOME',
            'Patient improves within 48 hours. No culture obtained (uncomplicated cystitis, culture not indicated per guidelines).',
            AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalScenario2() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: HAP example
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warning,
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
                  'Case 2: Hospital-Acquired Pneumonia',
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
          _buildScenarioSection(
            'PRESENTATION',
            'A 68-year-old man develops fever, productive cough, and new infiltrate on chest X-ray on hospital day 5 (post-abdominal surgery).',
            AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildScenarioSection(
            'ANTIBIOGRAM',
            'ICU antibiogram shows: E. coli susceptibility to ceftriaxone 88%, piperacillin-tazobactam 92%; Pseudomonas susceptibility to cefepime 88%, piperacillin-tazobactam 85%, meropenem 92%.',
            AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildScenarioSection(
            'DECISION',
            'Start piperacillin-tazobactam 4.5g IV q6h (covers both Enterobacterales and Pseudomonas with good susceptibility). Obtain sputum culture and blood cultures.',
            AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildScenarioSection(
            'DE-ESCALATION',
            'Day 3: Cultures grow E. coli susceptible to ceftriaxone, cefepime, and piperacillin-tazobactam. De-escalate to ceftriaxone 2g IV daily (narrower spectrum, once-daily dosing, cost-effective).',
            AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildScenarioSection(
            'OUTCOME',
            'Patient completes 7-day course with clinical resolution.',
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalScenario3() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),  // Red: Septic shock example
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '3',
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
                  'Case 3: ICU Sepsis with Unknown Source',
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
          _buildScenarioSection(
            'PRESENTATION',
            'A 72-year-old woman with diabetes presents with septic shock (BP 80/50, lactate 4.5 mmol/L, altered mental status). Source unclear (possible pneumonia vs. urinary tract vs. intra-abdominal).',
            AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildScenarioSection(
            'ANTIBIOGRAM',
            'ICU antibiogram shows high rates of ESBL E. coli (25%) and MRSA (30%).',
            AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildScenarioSection(
            'DECISION',
            'Broad empiric therapy with vancomycin 15mg/kg IV q12h + meropenem 1g IV q8h (covers MRSA, ESBL, Pseudomonas, anaerobes). Obtain blood cultures, urine culture, chest X-ray, CT abdomen.',
            AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildScenarioSection(
            'DE-ESCALATION',
            'Day 2: Blood cultures grow E. coli susceptible to ceftriaxone and ertapenem. Source identified as pyelonephritis. De-escalate to ertapenem 1g IV daily, discontinue vancomycin.',
            AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildScenarioSection(
            'OUTCOME',
            'Patient stabilizes and completes 10-day course.',
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioSection(String label, String content, Color color) {
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

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Empiric therapy: identify likely pathogen(s), consult antibiogram, choose ≥90% susceptibility, plan de-escalation',
      'De-escalation at 48-72 hours once cultures available is essential for stewardship',
      'Local antibiograms may differ from national guidelines - adjust recommendations accordingly',
      'ICU patients: use ICU-specific antibiograms, consider combination therapy for severe sepsis',
      'Oncology/neutropenic: antipseudomonal beta-lactam with ≥90% susceptibility, add vancomycin if indicated',
      'Transplant recipients: complex needs, consult ID specialists, use unit-specific antibiograms',
      'Reassess at 48-72 hours: clinical response, culture results, de-escalation opportunity',
      'Document rationale, antibiogram consulted, patient factors, and de-escalation plan',
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
      'IDSA Clinical Practice Guidelines (Syndrome-Specific)': 'https://www.idsociety.org/practice-guideline/',
      'Sanford Guide to Antimicrobial Therapy (2024)': 'https://www.sanfordguide.com/',
      'CDC Core Elements of Hospital Antibiotic Stewardship Programs (2019)': 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html',
      'IDSA/SHEA Guidelines for Developing an Institutional Program to Enhance Antimicrobial Stewardship (2016)': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
      'Johns Hopkins ABX Guide': 'https://www.hopkinsguides.com/hopkins/index/Johns_Hopkins_ABX_Guide',
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

