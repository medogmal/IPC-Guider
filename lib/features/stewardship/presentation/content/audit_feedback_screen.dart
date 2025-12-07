import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

class AuditFeedbackScreen extends StatelessWidget {
  const AuditFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Prospective Audit and Feedback'),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.rate_review,
            iconColor: AppColors.warning,
            title: 'Prospective Audit and Feedback',
            subtitle: 'The Cornerstone of Antimicrobial Stewardship',
            description: 'Review antimicrobial prescriptions 24-48 hours after initiation and provide real-time recommendations to optimize therapy',
          ),
          const SizedBox(height: 20),
          const IntroductionCard(
            text: 'Prospective audit and feedback (PAF) is the cornerstone of antimicrobial stewardship programs. It involves reviewing antimicrobial prescriptions 24-48 hours after initiation and providing real-time recommendations to prescribers to optimize therapy. PAF is associated with high acceptance rates (>80%), improved clinical outcomes, and reduced antimicrobial consumption.',
          ),
          const SizedBox(height: 20),
          _buildPAFProcessCard(),
          const SizedBox(height: 20),
          _buildTimingCard(),
          const SizedBox(height: 20),
          _buildDocumentationCard(),
          const SizedBox(height: 20),
          _buildAcceptanceFactorsCard(),
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

  Widget _buildPAFProcessCard() {
    return StructuredContentCard(
      icon: Icons.checklist,
      heading: 'PAF Process: 6 Key Focus Areas',
      color: AppColors.info,
      content: '''• Appropriateness of Agent Selection: Review culture results and local susceptibility patterns to ensure optimal agent selection
• Dose Optimization: Verify loading doses, renal adjustments, and therapeutic drug monitoring (TDM)
• De-escalation: Narrow from broad-spectrum to narrow-spectrum therapy based on culture results
• IV-to-Oral Conversion: Convert stable patients to oral therapy to reduce catheter complications and hospital stay
• Duration of Therapy: Ensure evidence-based durations (e.g., 5 days for CAP, 7 days for pyelonephritis)
• Discontinuation: Stop unnecessary antibiotics when infection is ruled out or resolved''',
    );
  }

  Widget _buildTimingCard() {
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
                child: const Icon(Icons.schedule, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Timing is Critical',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimingRow('24-48 hours', 'Most effective timing for recommendations', AppColors.success),
          const SizedBox(height: 12),
          _buildTimingRow('>72 hours', 'Less effective; may be perceived as intrusive', AppColors.error),
          const SizedBox(height: 12),
          const Text(
            'Early course correction prevents clinical deterioration and resistance development',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingRow(String timeframe, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            timeframe,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentationCard() {
    return StructuredContentCard(
      icon: Icons.description,
      heading: 'Documentation & Communication Strategies',
      color: AppColors.info,
      content: '''Documentation in EMR:
• Clear rationale with supporting evidence (culture results, guidelines)
• Alternative options if primary recommendation declined
• Contact information for follow-up questions

Communication Approach:
• Respectful, collaborative, and educational tone
• Avoid punitive language
• Phone calls or in-person discussions for urgent recommendations (e.g., inappropriate therapy for life-threatening infections)''',
    );
  }

  Widget _buildAcceptanceFactorsCard() {
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
                child: const Icon(Icons.thumb_up, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Acceptance Rates >80%',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Factors Associated with Higher Acceptance:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.success),
          ),
          const SizedBox(height: 8),
          const Text('✓ Timely delivery (24-48 hours)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('✓ Clear documentation with supporting evidence', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('✓ Collaborative tone', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('✓ Prescriber education', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('✓ Institutional support and leadership endorsement', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          const Text(
            'Barriers to Acceptance:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.error),
          ),
          const SizedBox(height: 8),
          const Text('✗ Lack of awareness of stewardship recommendations', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('✗ Fear of treatment failure', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('✗ Disagreement with recommendations', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('✗ Lack of time to review feedback', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
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
              const Expanded(child: Text('Case 1: Hospital-Acquired Pneumonia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 60-year-old man with hospital-acquired pneumonia is started on vancomycin 15mg/kg IV q12h + piperacillin-tazobactam 4.5g IV q6h. Sputum culture at 48 hours grows Pseudomonas aeruginosa susceptible to cefepime.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('RECOMMENDATION', 'De-escalate to cefepime 2g IV q8h (narrow-spectrum, once-daily dosing, cost-effective)', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('RATIONALE', 'Vancomycin unnecessary (no MRSA), piperacillin-tazobactam broader than needed', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'Prescriber accepts recommendation; patient completes 7-day course with clinical cure', AppColors.success),
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
              const Expanded(child: Text('Case 2: Pyelonephritis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 70-year-old woman with pyelonephritis is started on ciprofloxacin 400mg IV q12h. Blood culture at 48 hours grows E. coli susceptible to ceftriaxone.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('RECOMMENDATION', 'De-escalate to ceftriaxone 1g IV daily (narrow-spectrum, once-daily dosing)', AppColors.warning),
          const SizedBox(height: 8),
          _buildExampleSection('RATIONALE', 'Fluoroquinolone-sparing strategy to preserve this class for resistant infections', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'Prescriber accepts recommendation; patient switched to ceftriaxone with clinical improvement', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildClinicalExample3() {
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 3: Cellulitis with IV-to-Oral Conversion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 50-year-old man with cellulitis is started on vancomycin 15mg/kg IV q12h. After 5 days, erythema is improving, he is afebrile, and tolerating oral intake.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('RECOMMENDATION', 'Convert to linezolid 600mg PO BID (100% bioavailability, MRSA coverage, cost savings \$200/day)', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('RATIONALE', 'IV-to-oral conversion reduces catheter complications and hospital stay', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'Prescriber accepts recommendation; patient discharged home on oral therapy', AppColors.info),
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
      content: '''• Dedicated Stewardship Team: Pharmacist + ID physician with protected time for daily antimicrobial review
• Daily Review Process: Use EMR reports to identify patients on antimicrobials; prioritize high-risk patients (ICU, immunocompromised, broad-spectrum)
• Standardized Documentation: Templates in EMR for consistent documentation of recommendations and rationale
• Prescriber Education: Feedback loops, academic detailing, and ongoing education on stewardship principles
• Leadership Support: Institutional policies endorsing stewardship recommendations and protected time for team
• Monitoring Metrics: Track acceptance rates, clinical outcomes, antibiotic consumption, and cost savings''',
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'PAF is the cornerstone of stewardship: review prescriptions 24-48 hours post-initiation',
      'Focus areas: appropriateness, dose optimization, de-escalation, IV-to-oral, duration, discontinuation',
      'Timing is critical: recommendations within 24-48 hours are most effective',
      'Documentation: clear rationale, supporting evidence, alternative options in EMR',
      'Communication: respectful, collaborative, educational (avoid punitive language)',
      'Acceptance rates >80% when delivered by trained teams with timely, evidence-based recommendations',
      'Barriers: lack of awareness, fear of failure, disagreement, lack of time',
      'Implementation: dedicated team, daily review, standardized templates, prescriber education, leadership support',
    ];

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

