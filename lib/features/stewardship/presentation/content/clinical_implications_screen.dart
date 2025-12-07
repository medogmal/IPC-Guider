import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ClinicalImplicationsScreen extends StatelessWidget {
  const ClinicalImplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Implications & Prevention'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.medical_information,
            iconColor: AppColors.success,
            title: 'Clinical Implications & Prevention',
            subtitle: 'Antimicrobial Resistance Mechanisms',
            description:
                'Applying resistance knowledge to clinical practice and prevention strategies.',
          ),
          const SizedBox(height: 20),

          // Introduction Card
          IntroductionCard(
            text:
                'Preventing the emergence and spread of antimicrobial resistance requires a comprehensive, multifaceted approach that integrates antimicrobial stewardship, infection prevention and control, diagnostic stewardship, vaccination, and patient education. Clinical decision-making must balance the need for effective therapy with the imperative to preserve antimicrobial effectiveness for future generations.',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // Appropriate Selection Card
          StructuredContentCard(
            heading: 'Appropriate Antibiotic Selection',
            content:
                '''Selecting the right antibiotic requires consideration of multiple factors:

• Infection site and likely pathogens
• Local resistance patterns (antibiogram)
• Patient-specific factors (allergies, renal/hepatic function, pregnancy)
• Severity of illness
• Pharmacokinetic/pharmacodynamic properties

Narrow-spectrum agents should be preferred when appropriate.''',
            icon: Icons.medication,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // Clinical Scenario 1
          _buildClinicalScenarioCard(
            number: '1',
            title: 'Urinary Tract Infection',
            scenario:
                'A 65-year-old woman presents to the ED with fever, dysuria, and flank pain. Urinalysis shows pyuria and bacteriuria. No recent healthcare exposure or antibiotic use. Local antibiogram: E. coli resistance rates - ampicillin 40%, TMP-SMX 25%, fluoroquinolones 15%, ceftriaxone 5%.',
            decision:
                'Start ceftriaxone 1g IV daily (narrow-spectrum, high susceptibility). Avoid fluoroquinolones (collateral damage) and carbapenems (reserve for ESBL).',
            deEscalation:
                'After 48 hours, urine culture grows E. coli susceptible to all agents. Switch to oral cephalexin 500mg QID to complete 7 days total.',
            outcome:
                'Patient improves, avoids unnecessary broad-spectrum therapy, reduces selection pressure for resistance.',
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // PK/PD Principles Card
          _buildPKPDCard(),
          const SizedBox(height: 16),

          // Clinical Scenario 2
          _buildClinicalScenarioCard(
            number: '2',
            title: 'Hospital-Acquired Pneumonia',
            scenario:
                '70-year-old man develops fever, productive cough, new infiltrate on CXR on hospital day 5. ICU post-cardiac surgery with mechanical ventilation. Prior antibiotics: cefazolin for surgical prophylaxis. Local ICU antibiogram: MRSA 30%, Pseudomonas 20% (85% susceptible to cefepime), ESBL 10%.',
            decision:
                'Start vancomycin 15 mg/kg IV q12h (target trough 15-20 mcg/mL) + cefepime 2g IV q8h.',
            deEscalation:
                'After 48 hours, respiratory culture grows MSSA and P. aeruginosa susceptible to cefepime. Discontinue vancomycin, switch to cefazolin 2g IV q8h (narrower for MSSA) + continue cefepime. Plan 7-8 days total.',
            outcome:
                'Appropriate empiric coverage, timely de-escalation, evidence-based duration minimize resistance risk.',
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),

          // Combination Therapy Card
          StructuredContentCard(
            heading: 'Combination Therapy',
            content:
                '''Combination therapy may be indicated to:

• Broaden empiric coverage for critically ill patients
• Prevent resistance emergence (tuberculosis, HIV)
• Achieve synergy (enterococcal endocarditis)
• Treat difficult-to-treat organisms (CRE, MDR Pseudomonas)

However, combination therapy increases costs, adverse effects, and collateral damage. Use judiciously and de-escalate when possible.

EXAMPLE: For suspected septic shock with unknown source, empiric vancomycin + piperacillin-tazobactam provides broad coverage. Once source identified and cultures available, de-escalate to targeted monotherapy.''',
            icon: Icons.merge_type,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // IPC Measures Card
          _buildIPCCard(),
          const SizedBox(height: 16),

          // Clinical Scenario 3
          _buildClinicalScenarioCard(
            number: '3',
            title: 'CRE Outbreak Response',
            scenario:
                'A hospital identifies 3 cases of KPC-producing K. pneumoniae in the ICU within 2 weeks.',
            decision:
                'RESPONSE: (1) Implement contact precautions for all cases; (2) Conduct point-prevalence surveillance (rectal swabs) for all ICU patients; (3) Cohort colonized/infected patients with dedicated staff; (4) Enhance environmental cleaning; (5) Audit hand hygiene compliance; (6) Review antimicrobial use patterns; (7) Notify public health authorities.',
            deEscalation:
                'Surveillance identifies 2 additional colonized patients. Enhanced IPC measures implemented.',
            outcome:
                'Transmission halted. No new cases identified after 3 months.',
            color: AppColors.error,
          ),
          const SizedBox(height: 16),

          // Vaccination Card
          _buildVaccinationCard(),
          const SizedBox(height: 16),

          // Diagnostic Stewardship Card
          StructuredContentCard(
            heading: 'Diagnostic Stewardship',
            content:
                '''Appropriate diagnostic testing guides targeted therapy and avoids unnecessary antimicrobials:

• Obtain cultures before starting antimicrobials when possible
• Avoid culturing asymptomatic patients (e.g., urine cultures in catheterized patients without symptoms lead to unnecessary treatment of asymptomatic bacteriuria)
• Use rapid diagnostics (blood culture ID panels, respiratory pathogen panels, procalcitonin) to guide de-escalation
• Interpret results in clinical context (positive cultures may represent colonization, not infection)

EXAMPLE: A patient with a positive urine culture but no urinary symptoms should not receive antibiotics (asymptomatic bacteriuria), except in pregnancy or before urologic procedures.''',
            icon: Icons.science,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // Patient Education Card
          _buildPatientEducationCard(),
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

  Widget _buildClinicalScenarioCard({
    required String number,
    required String title,
    required String scenario,
    required String decision,
    required String deEscalation,
    required String outcome,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
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
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Clinical Scenario $number: $title',
                  style: const TextStyle(
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
          _buildScenarioSection('SCENARIO', scenario, color),
          const SizedBox(height: 12),
          _buildScenarioSection('DECISION', decision, color),
          const SizedBox(height: 12),
          _buildScenarioSection('DE-ESCALATION', deEscalation, color),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                          text: 'OUTCOME: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: outcome),
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

  Widget _buildPKPDCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
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
                  Icons.timeline,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Adequate Dosing & Duration',
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
            'Suboptimal dosing can lead to treatment failure and resistance emergence. Pharmacokinetic/pharmacodynamic (PK/PD) principles guide dosing:',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          _buildPKPDRow(
            'Time-dependent killing',
            'Beta-lactams: Maximize time above MIC through frequent dosing or continuous infusions',
            AppColors.success,
          ),
          const SizedBox(height: 10),
          _buildPKPDRow(
            'Concentration-dependent killing',
            'Aminoglycosides, fluoroquinolones: Maximize peak concentration through once-daily dosing',
            AppColors.success,
          ),
          const SizedBox(height: 10),
          _buildPKPDRow(
            'AUC/MIC ratio',
            'Vancomycin: Target AUC24/MIC >400 for serious infections',
            AppColors.success,
          ),
          const SizedBox(height: 12),
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
                  Icons.access_time,
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
                          text: 'Duration: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'Should be evidence-based. Shorter courses (3-5 days) for uncomplicated infections reduce resistance without compromising outcomes.',
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

  Widget _buildPKPDRow(String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIPCCard() {
    return StructuredContentCard(
      heading: 'Infection Prevention & Control Measures',
      content:
          '''Preventing infections reduces the need for antimicrobials and limits resistance transmission. Core IPC strategies:

• Hand hygiene: Single most effective intervention, reduces HAI by 30-50%
• Contact precautions: For MDRO-colonized or infected patients (gown, gloves, dedicated equipment)
• Environmental cleaning: Daily and terminal cleaning with EPA-registered disinfectants
• Device stewardship: Minimize use of catheters, ventilators, and other devices
• Surveillance: Active surveillance cultures for high-risk patients (ICU, transplant) to identify colonization early''',
      icon: Icons.shield_outlined,
      color: AppColors.info,
    );
  }

  Widget _buildVaccinationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
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
                  Icons.vaccines,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Vaccination',
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
            'Vaccines prevent infections, reducing antimicrobial use and resistance. Key vaccines include:',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            'Pneumococcal vaccines (PCV13, PPSV23): Reduce invasive pneumococcal disease and antibiotic-resistant S. pneumoniae',
            AppColors.info,
          ),
          _buildBulletPoint(
            'Influenza vaccine: Prevent influenza and secondary bacterial pneumonia',
            AppColors.info,
          ),
          _buildBulletPoint(
            'Haemophilus influenzae type b (Hib) vaccine: Virtually eliminated invasive Hib disease',
            AppColors.info,
          ),
          _buildBulletPoint(
            'Meningococcal vaccines: Prevent meningococcal meningitis',
            AppColors.info,
          ),
          _buildBulletPoint(
            'COVID-19 vaccines: Reduce severe disease and secondary bacterial infections',
            AppColors.info,
          ),
          const SizedBox(height: 16),
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
                  Icons.trending_down,
                  color: AppColors.info,
                  size: 22,
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
                          text: 'Impact: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'Introduction of PCV7 in 2000 reduced invasive pneumococcal disease by 75% and decreased antibiotic-resistant pneumococcal infections by 50%.',
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

  Widget _buildPatientEducationCard() {
    return StructuredContentCard(
      heading: 'Patient Education',
      content:
          '''Educating patients about appropriate antibiotic use empowers them to be partners in stewardship. Key messages:

• Antibiotics do not treat viral infections (colds, flu, most sore throats)
• Complete the prescribed course even if feeling better (though shorter courses are increasingly recommended)
• Do not share antibiotics or use leftover antibiotics
• Prevent infections through hand hygiene, vaccination, and safe food handling

EXAMPLE: A patient with acute bronchitis (viral) should be educated that antibiotics are not indicated, symptoms typically resolve in 2-3 weeks, and symptomatic treatment (cough suppressants, hydration) is appropriate.''',
      icon: Icons.school,
      color: AppColors.warning,
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
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
      'Appropriate selection: narrow-spectrum preferred, guided by antibiogram and patient factors',
      'Adequate dosing: PK/PD principles (time-dependent vs. concentration-dependent killing)',
      'Evidence-based duration: shorter courses (3-5 days) for uncomplicated infections',
      'Combination therapy: use judiciously for critically ill or difficult-to-treat infections',
      'IPC measures: hand hygiene, contact precautions, environmental cleaning, device stewardship',
      'Vaccination: prevents infections and reduces antimicrobial use (pneumococcal, influenza)',
      'Diagnostic stewardship: obtain cultures, avoid testing asymptomatic patients, use rapid diagnostics',
      'Patient education: antibiotics don\'t treat viruses, complete prescribed course, prevent infections',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
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
                      borderRadius: BorderRadius.circular(6),
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
    final references = [
      {
        'label': 'IDSA Guidelines: Implementing an Antibiotic Stewardship Program (2016)',
        'url': 'https://academic.oup.com/cid/article/62/10/e51/2462846'
      },
      {
        'label': 'CDC: Core Elements of Hospital Antibiotic Stewardship Programs (2019)',
        'url': 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html'
      },
      {
        'label': 'WHO: Global Action Plan on Antimicrobial Resistance (2015)',
        'url': 'https://www.who.int/publications/i/item/9789241509763'
      },
      {
        'label': 'CDC: Infection Control Basics',
        'url': 'https://www.cdc.gov/infection-control/index.html'
      },
      {
        'label': 'Sanford Guide to Antimicrobial Therapy (2024)',
        'url': 'https://www.sanfordguide.com/'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
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
                  Icons.menu_book,
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
          ...references.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () async {
                  final url = Uri.parse(entry.value['url']!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
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
                          entry.value['label']!,
                          style: const TextStyle(
                            color: AppColors.info,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.info,
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

