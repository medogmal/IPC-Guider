import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page 4: IV-to-Oral Conversion
/// Pattern 2: Practical/Action-Oriented
/// Special UI: Criteria card, high-bioavailability table, cost savings card, clinical scenarios
class IvToOralScreen extends StatelessWidget {
  const IvToOralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IV-to-Oral Conversion'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.swap_horiz,
            iconColor: AppColors.success,  // Green: IV to oral conversion best practice
            title: 'IV-to-Oral Conversion',
            subtitle: 'Optimizing Route of Administration',
            description: 'Criteria, high-bioavailability antibiotics, cost savings, and implementation strategies',
          ),
          const SizedBox(height: 16),

          // Introduction Card
          const IntroductionCard(
            text: 'IV-to-oral conversion is a key stewardship strategy that reduces costs, catheter-related complications, nursing time, and hospital length of stay—while maintaining clinical efficacy for stable patients with functioning GI tracts.',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // Criteria for Conversion Card
          _buildCriteriaCard(),
          const SizedBox(height: 16),

          // High-Bioavailability Antibiotics Card
          _buildHighBioavailabilityCard(),
          const SizedBox(height: 16),

          // Cost Savings Card
          _buildCostSavingsCard(),
          const SizedBox(height: 16),

          // Barriers Card
          _buildBarriersCard(),
          const SizedBox(height: 16),

          // Implementation Strategies Card
          _buildImplementationCard(),
          const SizedBox(height: 16),

          // Clinical Example 1: CAP
          _buildClinicalExample1(),
          const SizedBox(height: 16),

          // Clinical Example 2: Intra-abdominal
          _buildClinicalExample2(),
          const SizedBox(height: 16),

          // Clinical Example 3: MRSA
          _buildClinicalExample3(),
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

  Widget _buildCriteriaCard() {
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
                child: const Icon(Icons.checklist, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Criteria for IV-to-Oral Conversion',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCriteriaItem('Clinical Stability', 'Hemodynamically stable, afebrile for 24-48 hours, improving WBC/inflammatory markers', Icons.favorite),
          _buildCriteriaItem('Functioning GI Tract', 'Able to tolerate oral intake, no nausea/vomiting, no malabsorption', Icons.restaurant),
          _buildCriteriaItem('High Bioavailability', 'Oral agent with ≥90% bioavailability available', Icons.medication),
          _buildCriteriaItem('Infection Site', 'Site accessible to oral therapy (not CNS abscess, endocarditis)', Icons.location_on),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighBioavailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Bioavailability
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
                child: const Icon(Icons.science_outlined, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'High-Bioavailability Antibiotics (≥90%)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBioavailabilityRow('Fluoroquinolones', 'Levofloxacin, ciprofloxacin, moxifloxacin', '90-99%', AppColors.info),
          _buildBioavailabilityRow('Linezolid', 'MRSA, VRE coverage', '100%', AppColors.success),
          _buildBioavailabilityRow('Metronidazole', 'Anaerobic coverage', '100%', AppColors.success),
          _buildBioavailabilityRow('TMP-SMX', 'MRSA, Stenotrophomonas', '90%', AppColors.info),
          _buildBioavailabilityRow('Fluconazole', 'Candida infections', '90%', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildBioavailabilityRow(String drug, String coverage, String bioavailability, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(drug, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 2),
                  Text(coverage, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
              child: Text(bioavailability, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSavingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Benefits
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
                child: const Icon(Icons.attach_money, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Cost Savings & Patient Benefits',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBenefitItem('Drug Cost', 'IV antibiotics are 2-10× more expensive than oral equivalents', Icons.monetization_on),
          _buildBenefitItem('Nursing Time', 'Reduced IV administration time and monitoring', Icons.access_time),
          _buildBenefitItem('Catheter Complications', 'Avoids phlebitis, thrombosis, catheter-related bloodstream infections', Icons.warning_amber),
          _buildBenefitItem('Hospital Stay', 'Earlier discharge, reduced length of stay', Icons.home),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarriersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),  // Red: Contraindications
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
                child: const Icon(Icons.block, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Barriers to IV-to-Oral Conversion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('• Lack of awareness of high-bioavailability agents', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Fear of treatment failure', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Lack of stewardship oversight', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Inadequate communication between teams', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildImplementationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Implementation
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
                child: const Icon(Icons.settings, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Implementation Strategies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('• Develop institutional protocols for IV-to-oral conversion', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Educate prescribers on high-bioavailability agents', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Pharmacist-driven conversion programs', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• EHR alerts for eligible patients', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Monitor conversion rates as a stewardship metric', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildClinicalExample1() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: CAP example
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
              const Expanded(child: Text('Case 1: Community-Acquired Pneumonia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 55-year-old man with CAP is treated with levofloxacin 750mg IV daily. After 3 days, he is afebrile, tolerating oral intake, and clinically stable.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('CONVERSION', 'Levofloxacin 750mg IV → 750mg PO daily (1:1 conversion, 90% bioavailability)', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('COST SAVINGS', 'IV: \$150/day; PO: \$10/day → \$140/day savings', AppColors.warning),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'Discharged home on oral therapy, total 5 days', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildClinicalExample2() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Intra-abdominal example
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
              const Expanded(child: Text('Case 2: Intra-abdominal Infection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 40-year-old woman with perforated appendicitis is treated with piperacillin-tazobactam 4.5g IV q6h. After source control (appendectomy) and 4 days of IV therapy, she is afebrile and tolerating oral intake.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('CONVERSION', 'Piperacillin-tazobactam IV → ciprofloxacin 500mg PO BID + metronidazole 500mg PO TID (covers Gram-negatives + anaerobes)', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('DURATION', 'Total 4 days post-op (evidence-based for source-controlled intra-abdominal infections)', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildClinicalExample3() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: MRSA cellulitis example
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
                child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 3: MRSA Cellulitis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 60-year-old man with MRSA cellulitis is treated with vancomycin 15mg/kg IV q12h. After 5 days, erythema is improving, he is afebrile, and tolerating oral intake.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('CONVERSION', 'Vancomycin IV → linezolid 600mg PO BID (100% bioavailability, MRSA coverage)', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('COST SAVINGS', 'IV vancomycin: \$250/day; PO linezolid: \$50/day → \$200/day savings', AppColors.warning),
          const SizedBox(height: 8),
          _buildExampleSection('DURATION', 'Total 7-10 days for uncomplicated cellulitis', AppColors.info),
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
      'IV-to-oral conversion reduces costs, catheter complications, nursing time, and hospital stay',
      'Criteria: clinical stability, functioning GI tract, high bioavailability (≥90%), infection site accessible',
      'High-bioavailability agents: fluoroquinolones (90-99%), linezolid (100%), metronidazole (100%), TMP-SMX (90%)',
      'Cost savings: IV antibiotics are 2-10× more expensive than oral equivalents',
      'Barriers: lack of awareness, fear of failure, lack of stewardship oversight',
      'Implementation: protocols, education, pharmacist-driven programs, EHR alerts, monitor conversion rates',
      'Levofloxacin: 1:1 IV-to-oral conversion (750mg IV = 750mg PO)',
      'Linezolid: 100% bioavailability, excellent for MRSA infections',
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
      'IDSA/SHEA Guidelines for Antimicrobial Stewardship (2016)': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
      'CDC Core Elements of Hospital Antibiotic Stewardship (2019)': 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html',
      'Sanford Guide to Antimicrobial Therapy (2024)': 'https://www.sanfordguide.com/',
      'Johns Hopkins ABX Guide: IV-to-Oral Conversion': 'https://www.hopkinsguides.com/hopkins/index/Johns_Hopkins_ABX_Guide',
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

