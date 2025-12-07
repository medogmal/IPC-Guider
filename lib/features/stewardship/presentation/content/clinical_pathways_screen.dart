import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

class ClinicalPathwaysScreen extends StatelessWidget {
  const ClinicalPathwaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clinical Pathways and Order Sets'),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.route,
            iconColor: AppColors.warning,  // Amber: Clinical pathways
            title: 'Clinical Pathways and Order Sets',
            subtitle: 'Standardizing Care with Evidence-Based Tools',
            description: 'Syndrome-specific tools embedded in EMR that guide prescribers toward optimal antimicrobial selection, dosing, and duration',
          ),
          const SizedBox(height: 20),
          const IntroductionCard(
            text: 'Clinical pathways and order sets are evidence-based, syndrome-specific tools embedded in the electronic medical record (EMR) that guide prescribers toward optimal antimicrobial selection, dosing, and duration. They standardize care, reduce variability, improve adherence to guidelines, and facilitate stewardship interventions such as automatic stop orders and allergy verification.',
          ),
          const SizedBox(height: 20),
          _buildSyndromePathwaysCard(),
          const SizedBox(height: 20),
          _buildDecisionSupportCard(),
          const SizedBox(height: 20),
          _buildAutomaticStopOrdersCard(),
          const SizedBox(height: 20),
          _buildAllergyVerificationCard(),
          const SizedBox(height: 20),
          _buildImplementationCard(),
          const SizedBox(height: 20),
          _buildClinicalExample1(),
          const SizedBox(height: 20),
          _buildClinicalExample2(),
          const SizedBox(height: 20),
          _buildClinicalExample3(),
          const SizedBox(height: 20),
          _buildBenefitsCard(),
          const SizedBox(height: 20),
          _buildKeyTakeawaysCard(),
          const SizedBox(height: 20),
          _buildReferencesCard(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSyndromePathwaysCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Common pathways
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
                child: const Icon(Icons.medical_services, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Syndrome-Specific Pathways',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPathwayItem('CAP', 'Ceftriaxone 1g IV daily + azithromycin 500mg IV daily for 5 days', AppColors.info),
          const SizedBox(height: 12),
          _buildPathwayItem('UTI', 'Nitrofurantoin 100mg PO BID for 5 days or TMP-SMX DS PO BID for 3 days', AppColors.info),
          const SizedBox(height: 12),
          _buildPathwayItem('SSTI (non-purulent)', 'Cefazolin 2g IV q8h for 5-7 days', AppColors.info),
          const SizedBox(height: 12),
          _buildPathwayItem('SSTI (purulent/MRSA)', 'Vancomycin 15mg/kg IV q12h for 7-10 days', AppColors.warning),
          const SizedBox(height: 12),
          _buildPathwayItem('Sepsis', 'Vancomycin 15mg/kg IV q12h + piperacillin-tazobactam 4.5g IV q6h (empiric broad-spectrum)', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildPathwayItem(String syndrome, String treatment, Color color) {
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
            syndrome,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            treatment,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionSupportCard() {
    return StructuredContentCard(
      icon: Icons.support_agent,
      heading: 'Embedded Decision Support in EMR',
      color: AppColors.info,
      content: '''• Automatic Dose Calculation: Weight-based doses (e.g., vancomycin 15mg/kg)
• Renal Dose Adjustments: Based on creatinine clearance (CrCl)
• Allergy Alerts: Cross-reactivity warnings (e.g., cephalosporin in penicillin-allergic patients)
• Drug-Drug Interaction Alerts: E.g., fluoroquinolones + QT-prolonging drugs
• Automatic Stop Orders: At evidence-based durations (e.g., 5 days for CAP)
• IV-to-Oral Prompts: When criteria met (afebrile, stable, tolerating PO)''',
    );
  }

  Widget _buildAutomaticStopOrdersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Order set components
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
                child: const Icon(Icons.timer_off, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Default Durations & Automatic Stop Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Critical for preventing unnecessarily prolonged courses',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text('Example: A CAP order set may default to 5 days with an automatic stop order, requiring prescribers to actively extend therapy if clinically indicated.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          const Text('This nudges prescribers toward evidence-based durations and reduces antibiotic exposure.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Studies show that automatic stop orders reduce antibiotic duration by 1-2 days without increasing adverse outcomes.',
              style: TextStyle(fontSize: 14, color: AppColors.success, height: 1.6, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Stewardship interventions
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
                child: const Icon(Icons.warning, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Allergy Verification & Cross-Reactivity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('EMR pathways should prompt prescribers to verify allergy history and assess cross-reactivity risk.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          const Text(
            'Penicillin Allergy Example:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.warning),
          ),
          const SizedBox(height: 8),
          const Text('• Ask about type and severity of reaction (rash vs. anaphylaxis)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Mild rash: Cephalosporins may be safe (cross-reactivity <1% for 3rd/4th generation)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Anaphylaxis: Avoid all beta-lactams; use fluoroquinolones or aztreonam', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildImplementationCard() {
    return StructuredContentCard(
      icon: Icons.settings,
      heading: 'Implementation & Maintenance',
      color: AppColors.info,
      content: '''• Step 1: Convene Stewardship Committee - ID, pharmacy, nursing, IT, quality improvement
• Step 2: Review Guidelines - Evidence-based guidelines (IDSA, CDC) and local susceptibility patterns
• Step 3: Develop Pathways - Syndrome-specific pathways with input from frontline prescribers
• Step 4: Integrate into EMR - With decision support features (dose calculation, alerts, automatic stop orders)
• Step 5: Pilot Test - In select units and gather feedback
• Step 6: Launch Institution-Wide - With prescriber education and training
• Step 7: Monitor & Update - Track adherence, clinical outcomes, antibiotic consumption; update annually based on new evidence and local resistance trends''',
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
              const Expanded(child: Text('Case 1: CAP with Order Set', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 50-year-old man with CAP is admitted to the hospital. The prescriber selects the CAP order set in the EMR, which defaults to ceftriaxone 1g IV daily + azithromycin 500mg IV daily for 5 days with an automatic stop order.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('DAY 3', 'Patient is afebrile and tolerating oral intake. EMR prompts prescriber to convert to amoxicillin 1g PO TID', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'Prescriber accepts recommendation; patient discharged home on oral therapy. Evidence-based duration (5 days), IV-to-oral conversion, reduced hospital stay', AppColors.success),
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
                child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 2: UTI with Allergy Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 30-year-old woman with uncomplicated UTI is seen in the emergency department. The prescriber selects the UTI order set, which defaults to nitrofurantoin 100mg PO BID for 5 days.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('ALLERGY ALERT', 'EMR alerts prescriber that patient has documented sulfa allergy, so TMP-SMX is contraindicated', AppColors.warning),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'Prescriber confirms nitrofurantoin is appropriate; patient discharged with 5-day prescription. Allergy verification prevented inappropriate TMP-SMX use', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildClinicalExample3() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Example 3
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
                child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 3: Sepsis with Automatic Dose Calculation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 60-year-old man with sepsis is admitted to the ICU. The prescriber selects the sepsis order set, which defaults to vancomycin 15mg/kg IV q12h + piperacillin-tazobactam 4.5g IV q6h.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('AUTOMATIC CALCULATION', 'EMR automatically calculates vancomycin dose based on patient weight (80 kg → 1,200 mg IV q12h)', AppColors.warning),
          const SizedBox(height: 8),
          _buildExampleSection('DAY 2', 'Blood cultures grow E. coli susceptible to ceftriaxone. Stewardship team recommends de-escalation to ceftriaxone 2g IV daily', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'Prescriber accepts recommendation; patient completes 7-day course with clinical cure. Automatic dose calculation, de-escalation to narrow-spectrum therapy', AppColors.success),
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

  Widget _buildBenefitsCard() {
    return StructuredContentCard(
      icon: Icons.star,
      heading: 'Benefits of Clinical Pathways',
      color: AppColors.success,
      content: '''• Standardized Care: Reduced variability in antimicrobial prescribing
• Improved Guideline Adherence: Evidence-based recommendations embedded in workflow
• Reduced Antibiotic Duration: Automatic stop orders nudge prescribers toward evidence-based durations
• Facilitated Stewardship: Automatic stop orders, IV-to-oral conversion prompts
• Reduced Prescribing Errors: Dose calculation, allergy verification, drug-drug interaction alerts
• Improved Outcomes & Reduced Costs: Better clinical outcomes, shorter hospital stays, lower drug costs''',
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Clinical pathways: evidence-based, syndrome-specific tools embedded in EMR (CAP, UTI, SSTI, sepsis)',
      'Embedded decision support: automatic dose calculation, renal adjustments, allergy alerts, drug-drug interaction alerts, automatic stop orders, IV-to-oral prompts',
      'Default durations and automatic stop orders: nudge prescribers toward evidence-based durations (e.g., 5 days for CAP)',
      'Allergy verification: prompt prescribers to verify allergy history and assess cross-reactivity risk (penicillin vs. cephalosporin)',
      'Implementation: multidisciplinary committee, review guidelines, develop pathways, integrate into EMR, pilot test, launch, monitor, update annually',
      'Benefits: standardized care, improved guideline adherence, reduced antibiotic duration, facilitated stewardship, reduced errors, improved outcomes',
      'Barriers: EMR limitations, prescriber resistance, lack of support, difficulty maintaining pathways',
      'Automatic stop orders reduce antibiotic duration by 1-2 days without increasing adverse outcomes',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Key takeaways
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(8)),
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
                    decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(12)),
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
      'CDC Core Elements of Hospital Antibiotic Stewardship (2019)': 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html',
      'IDSA/SHEA Guidelines for Antimicrobial Stewardship (2016)': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
      'Cochrane Review: Interventions to Improve Antibiotic Prescribing (2017)': 'https://www.cochranelibrary.com/cdsr/doi/10.1002/14651858.CD003543.pub4/full',
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

