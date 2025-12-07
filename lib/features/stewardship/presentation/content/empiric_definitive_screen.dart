import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page 2: Empiric vs. Definitive Therapy
/// Pattern 2: Practical/Action-Oriented
/// Special UI: Decision factors card, de-escalation timeline, clinical scenarios
class EmpiricDefinitiveScreen extends StatelessWidget {
  const EmpiricDefinitiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empiric vs. Definitive Therapy'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.timeline_outlined,
            iconColor: AppColors.success,  // Green: Empiric vs definitive
            title: 'Empiric vs. Definitive Therapy',
            subtitle: 'From Broad-Spectrum to Targeted Treatment',
            description: 'Principles of empiric therapy selection and de-escalation to definitive therapy based on culture results',
          ),
          const SizedBox(height: 16),

          // Introduction Card
          const IntroductionCard(
            text: 'Empiric therapy is initiated before microbiologic confirmation when infection is suspected and delay would compromise patient outcomes. Definitive (targeted) therapy is based on culture results and susceptibility testing, allowing for spectrum narrowing and optimization.',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // When to Start Empiric Therapy Card
          StructuredContentCard(
            heading: 'When to Start Empiric Therapy',
            content: '''Severe infections (sepsis, meningitis, neutropenic fever); Life-threatening infections where delay compromises outcomes; When diagnostic results will be delayed (48-72 hours); Clinical presentation, infection site, patient risk factors, and local epidemiology guide empiric selection''',
            icon: Icons.play_arrow,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // Factors Influencing Empiric Selection Card
          _buildFactorsCard(),
          const SizedBox(height: 16),

          // De-escalation Principles Card
          _buildDeEscalationCard(),
          const SizedBox(height: 16),

          // De-escalation Timeline Card
          _buildTimelineCard(),
          const SizedBox(height: 16),

          // Duration Considerations Card
          StructuredContentCard(
            heading: 'Duration of Therapy Considerations',
            content: '''Uncomplicated infections (cystitis, cellulitis, CAP): 3-7 days; Complicated infections (pyelonephritis, HAP): 7-14 days; Deep-seated infections (osteomyelitis, endocarditis, prosthetic joint infections): 4-6 weeks or longer; Duration based on infection syndrome, source control, and clinical response''',
            icon: Icons.schedule,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // Clinical Example 1: Sepsis
          _buildClinicalExample1(),
          const SizedBox(height: 16),

          // Clinical Example 2: CAP
          _buildClinicalExample2(),
          const SizedBox(height: 16),

          // Barriers to De-escalation Card
          _buildBarriersCard(),
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

  Widget _buildFactorsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
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
                child: const Icon(Icons.checklist, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Factors Influencing Empiric Selection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFactorItem('Infection Severity', 'Broader coverage for septic shock, ICU patients', Icons.warning_amber),
          _buildFactorItem('Infection Site', 'CNS requires CSF-penetrating agents, intra-abdominal requires anaerobic coverage', Icons.location_on),
          _buildFactorItem('Patient Risk Factors', 'Recent antibiotics, hospitalization, healthcare exposure, immunosuppression, travel', Icons.person),
          _buildFactorItem('Local Antibiogram', 'Use facility-specific or unit-specific susceptibility data', Icons.analytics),
          _buildFactorItem('Allergy History', 'Document type and severity of reactions', Icons.medical_information),
        ],
      ),
    );
  }

  Widget _buildFactorItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.warning, size: 20),
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

  Widget _buildDeEscalationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1.5),
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
                child: Text('De-escalation Principles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'De-escalation is the process of narrowing antimicrobial spectrum once culture results are available. This reduces unnecessary broad-spectrum exposure, decreases C. difficile risk, preserves broader agents for resistant infections, and reduces cost.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 14),
          const Text(
            'De-escalation should occur within 48-72 hours of culture results.',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.success, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 1.5),
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
                child: const Icon(Icons.access_time, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('De-escalation Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineItem('Day 0', 'Start empiric broad-spectrum therapy', AppColors.error),
          _buildTimelineItem('Day 1-2', 'Obtain cultures (blood, urine, sputum, etc.)', AppColors.warning),
          _buildTimelineItem('Day 2-3', 'Review culture results and susceptibility testing', AppColors.info),
          _buildTimelineItem('Day 3', 'De-escalate to narrowest-spectrum agent effective against identified pathogen', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String day, String action, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
            child: Center(child: Text(day, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(action, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5))),
        ],
      ),
    );
  }

  Widget _buildClinicalExample1() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
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
              const Expanded(child: Text('Case 1: Sepsis with Unknown Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          _buildExampleSection('PRESENTATION', 'A 65-year-old woman presents with septic shock (BP 80/50, lactate 5.2 mmol/L).', AppColors.info),
          const SizedBox(height: 10),
          _buildExampleSection('EMPIRIC THERAPY', 'Vancomycin 15mg/kg IV q12h + piperacillin-tazobactam 4.5g IV q6h (covers MRSA, Gram-negatives, anaerobes).', AppColors.info),
          const SizedBox(height: 10),
          _buildExampleSection('DE-ESCALATION', 'Blood cultures at 48 hours grow E. coli susceptible to ceftriaxone → ceftriaxone 2g IV daily (narrow-spectrum, once-daily dosing).', AppColors.success),
          const SizedBox(height: 10),
          _buildExampleSection('OUTCOME', 'Source identified as pyelonephritis. Total duration: 10 days.', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildClinicalExample2() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
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
              const Expanded(child: Text('Case 2: Community-Acquired Pneumonia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          _buildExampleSection('EMPIRIC THERAPY', 'Ceftriaxone 1g IV daily + azithromycin 500mg IV daily.', AppColors.warning),
          const SizedBox(height: 10),
          _buildExampleSection('DE-ESCALATION', 'Sputum culture grows S. pneumoniae susceptible to penicillin → penicillin G 2 million units IV q4h.', AppColors.success),
          const SizedBox(height: 10),
          _buildExampleSection('IV-TO-ORAL', 'After 3 days of clinical stability → amoxicillin 1g PO TID.', AppColors.info),
          const SizedBox(height: 10),
          _buildExampleSection('DURATION', 'Total 5 days (evidence-based for CAP).', AppColors.info),
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

  Widget _buildBarriersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1.5),
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
              const Expanded(child: Text('Barriers to De-escalation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          _buildBarrierItem('Lack of culture data (inadequate specimen collection)'),
          _buildBarrierItem('Fear of treatment failure'),
          _buildBarrierItem('Lack of stewardship oversight'),
          _buildBarrierItem('Inadequate communication between teams'),
          const SizedBox(height: 14),
          const Text(
            'Stewardship programs should implement prospective audit and feedback, clinical pathways, and education to overcome these barriers.',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, fontStyle: FontStyle.italic, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBarrierItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5))),
        ],
      ),
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Empiric therapy: initiated before cultures for severe/life-threatening infections',
      'Factors influencing empiric selection: severity, site, risk factors, local antibiogram, allergies',
      'De-escalation: narrow spectrum once culture results available (48-72 hours)',
      'De-escalation reduces C. difficile risk, preserves broad-spectrum agents, reduces cost',
      'Targeted therapy: narrowest-spectrum agent effective against identified pathogen',
      'Duration based on syndrome: uncomplicated (3-7 days), complicated (7-14 days), deep-seated (4-6 weeks)',
      'Barriers to de-escalation: lack of cultures, fear of failure, lack of stewardship oversight',
      'Consult ID specialists for complex cases or resistant pathogens',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
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
      'Surviving Sepsis Campaign Guidelines (2021)': 'https://www.sccm.org/SurvivingSepsisCampaign/Guidelines',
      'Sanford Guide to Antimicrobial Therapy (2024)': 'https://www.sanfordguide.com/',
      'CDC Core Elements of Hospital Antibiotic Stewardship (2019)': 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
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

