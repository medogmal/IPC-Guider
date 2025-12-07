import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

class PreauthorizationScreen extends StatelessWidget {
  const PreauthorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Preauthorization and Formulary Restriction'),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.verified_user,
            iconColor: AppColors.warning,  // Amber: Preauthorization
            title: 'Preauthorization and Formulary Restriction',
            subtitle: 'Balancing Access and Stewardship',
            description: 'Require approval before prescribing high-risk or broad-spectrum antibiotics to preserve them for resistant infections',
          ),
          const SizedBox(height: 20),
          const IntroductionCard(
            text: 'Preauthorization (prior approval) and formulary restriction are stewardship interventions that require prescribers to obtain approval from a stewardship team or ID specialist before prescribing certain high-risk or broad-spectrum antibiotics. These interventions are effective at reducing inappropriate use, preserving broad-spectrum agents for resistant infections, and controlling costs—but must be balanced with timely access to ensure patient safety.',
          ),
          const SizedBox(height: 20),
          _buildRestrictedAntibioticsCard(),
          const SizedBox(height: 20),
          _buildApprovalProcessCard(),
          const SizedBox(height: 20),
          _buildApprovalCriteriaCard(),
          const SizedBox(height: 20),
          _buildEmergencyOverrideCard(),
          const SizedBox(height: 20),
          _buildImpactCard(),
          const SizedBox(height: 20),
          _buildClinicalExample1(),
          const SizedBox(height: 20),
          _buildClinicalExample2(),
          const SizedBox(height: 20),
          _buildClinicalExample3(),
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

  Widget _buildRestrictedAntibioticsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),  // Red: Restricted antibiotics
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
                child: const Icon(Icons.lock, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Restricted Antibiotics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRestrictedItem('Carbapenems', 'Meropenem, imipenem, ertapenem (broad spectrum, risk of CRE)', AppColors.error),
          const SizedBox(height: 10),
          _buildRestrictedItem('Daptomycin', 'For MRSA bacteremia/endocarditis', AppColors.info),
          const SizedBox(height: 10),
          _buildRestrictedItem('Ceftaroline', 'For MRSA pneumonia', AppColors.info),
          const SizedBox(height: 10),
          _buildRestrictedItem('Linezolid', 'For MRSA infections', AppColors.info),
          const SizedBox(height: 10),
          _buildRestrictedItem('Antifungals', 'Voriconazole, caspofungin, micafungin (invasive fungal infections)', AppColors.warning),
          const SizedBox(height: 10),
          _buildRestrictedItem('Colistin', 'For multidrug-resistant Gram-negatives', AppColors.success),
          const SizedBox(height: 12),
          const Text(
            'Note: Specific list varies by institution based on local resistance patterns and formulary considerations',
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictedItem(String drug, String indication, Color color) {
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
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
              children: [
                TextSpan(text: '$drug: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: indication),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalProcessCard() {
    return StructuredContentCard(
      icon: Icons.approval,
      heading: 'Approval Process',
      color: AppColors.info,
      content: '''• Step 1: Request Submission - Prescriber submits request via EMR or phone call to stewardship team
• Step 2: Stewardship Review - Pharmacist or ID physician reviews indication, culture results, allergy history, and alternative options
• Step 3: Decision - Approval granted if appropriate, or alternative therapy recommended
• Step 4: Documentation - Approval and rationale documented in EMR
• Turnaround Time: <1 hour for urgent requests (septic shock, meningitis), <24 hours for non-urgent requests''',
    );
  }

  Widget _buildApprovalCriteriaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Criteria
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
                child: const Icon(Icons.rule, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Carbapenem Approval Criteria (Example)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('✓ Culture-proven ESBL-producing Enterobacteriaceae', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('✓ Severe sepsis/septic shock with risk factors for ESBL (recent hospitalization, recent antibiotics, healthcare exposure)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('✓ Polymicrobial intra-abdominal infections requiring anaerobic coverage', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('✓ Failure of narrower-spectrum agents', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          const Text(
            'Denials are accompanied by alternative recommendations (e.g., ceftriaxone for ESBL-negative E. coli)',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyOverrideCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Emergency override
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
                child: const Icon(Icons.emergency, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Emergency Override Protocols',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Preauthorization should not delay appropriate therapy for life-threatening infections.',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text('Emergency override allows prescribers to initiate restricted antibiotics immediately in urgent situations:', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 8),
          const Text('• Septic shock', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Meningitis', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Neutropenic fever', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          const Text(
            'Retrospective review by stewardship team within 24-48 hours ensures patient safety while maintaining stewardship oversight.',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Impact
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
                child: const Icon(Icons.trending_down, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Impact on Resistance and Costs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildImpactRow('Carbapenem Use', '↓ 20-40%', AppColors.success),
          const SizedBox(height: 10),
          _buildImpactRow('CRE Incidence', '↓ Decreased', AppColors.success),
          const SizedBox(height: 10),
          _buildImpactRow('Annual Cost Savings', '\$200,000-\$500,000', AppColors.info),
          const SizedBox(height: 12),
          const Text(
            'However, overly restrictive programs may lead to delays in appropriate therapy, increased mortality, and prescriber dissatisfaction. The key is to balance restriction with education and timely access.',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow(String metric, String value, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            metric,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
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
              const Expanded(child: Text('Case 1: Hospital-Acquired Pneumonia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 55-year-old man with hospital-acquired pneumonia is started on meropenem 1g IV q8h empirically. Sputum culture at 48 hours grows Klebsiella pneumoniae susceptible to ceftriaxone.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('STEWARDSHIP REVIEW', 'Meropenem unnecessary; recommend de-escalation to ceftriaxone 2g IV daily', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'Prescriber accepts recommendation; patient completes 7-day course with clinical cure. Carbapenem-sparing strategy preserves meropenem for resistant infections', AppColors.success),
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
              const Expanded(child: Text('Case 2: MRSA Bacteremia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 70-year-old woman with MRSA bacteremia requests daptomycin 6mg/kg IV daily. Vancomycin MIC 2 mcg/mL (high-level resistance).', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('STEWARDSHIP REVIEW', 'Appropriate indication (MRSA bacteremia with high vancomycin MIC)', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'Approval granted for daptomycin. Patient completes 14-day course with clearance of bacteremia', AppColors.success),
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
              const Expanded(child: Text('Case 3: Community-Acquired Pneumonia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 40-year-old man with community-acquired pneumonia requests meropenem 1g IV q8h. No risk factors for ESBL or resistant pathogens.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('STEWARDSHIP REVIEW', 'No indication for carbapenem; recommend ceftriaxone 1g IV daily + azithromycin 500mg IV daily (standard CAP therapy)', AppColors.warning),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'Prescriber accepts recommendation; patient responds to narrow-spectrum therapy. Carbapenem-sparing strategy avoids unnecessary broad-spectrum exposure', AppColors.success),
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

  Widget _buildImplementationCard() {
    return StructuredContentCard(
      icon: Icons.settings,
      heading: 'Implementation Strategies',
      color: AppColors.info,
      content: '''• Institutional Policy: Define restricted antibiotics and approval process in institutional policy
• EMR Integration: Automated approval requests and documentation in EMR
• 24/7 Stewardship Coverage: On-call ID physician or pharmacist for after-hours requests
• Emergency Override Protocols: Allow immediate initiation in urgent situations with retrospective review
• Prescriber Education: Educate on approval criteria and alternative options
• Monitoring Metrics: Track approval rates, turnaround times, and clinical outcomes''',
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Preauthorization: require approval before prescribing high-risk/broad-spectrum antibiotics (carbapenems, daptomycin, ceftaroline, linezolid, antifungals)',
      'Approval process: prescriber submits request → stewardship review → approval or alternative recommendation (turnaround <1 hour for urgent)',
      'Approval criteria: evidence-based indications, culture results, local susceptibility patterns',
      'Emergency override protocols: allow immediate initiation in urgent situations (septic shock, meningitis) with retrospective review',
      'Impact: reduce carbapenem use by 20-40%, decrease CRE incidence, save \$200,000-\$500,000 annually',
      'Balance access and stewardship: avoid delays in appropriate therapy for life-threatening infections',
      'Barriers: delays in approval, prescriber dissatisfaction, lack of 24/7 coverage',
      'Implementation: institutional policy, EMR integration, 24/7 coverage, emergency override, prescriber education',
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

