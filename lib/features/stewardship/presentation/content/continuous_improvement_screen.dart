import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

class ContinuousImprovementScreen extends StatelessWidget {
  const ContinuousImprovementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Continuous Quality Improvement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.assessment_outlined,
            iconColor: AppColors.primary,
            title: 'Continuous Quality Improvement',
            subtitle: 'Sustaining Stewardship Programs',
            description: 'PDSA cycles, root cause analysis, feedback loops, celebrating successes, and long-term sustainability strategies',
          ),
          const SizedBox(height: 20),
          const IntroductionCard(
            text: 'Continuous quality improvement (CQI) is essential for sustaining antimicrobial stewardship programs and adapting to changing resistance patterns, new evidence, and institutional priorities. CQI uses iterative cycles (Plan-Do-Study-Act), root cause analysis, feedback loops, and celebration of successes to drive ongoing improvement. Long-term sustainability requires leadership support, dedicated resources, and a culture of learning and collaboration.',
          ),
          const SizedBox(height: 20),
          _buildPDSACycleCard(),
          const SizedBox(height: 20),
          _buildPDSAExample(),
          const SizedBox(height: 20),
          _buildRootCauseAnalysisCard(),
          const SizedBox(height: 20),
          _buildFeedbackLoopsCard(),
          const SizedBox(height: 20),
          _buildCelebratingSuccessesCard(),
          const SizedBox(height: 20),
          _buildSustainabilityCard(),
          const SizedBox(height: 20),
          _buildLongTermExample(),
          const SizedBox(height: 20),
          _buildKeyTakeawaysCard(),
          const SizedBox(height: 20),
          _buildReferencesCard(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPDSACycleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: PDSA cycle
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
                child: const Icon(Icons.refresh, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'PDSA (Plan-Do-Study-Act) Cycles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'The PDSA cycle is a structured framework for testing and implementing changes.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
          _buildPDSAStep('Plan', 'Identify a problem (e.g., high carbapenem use in ICU) and develop an intervention (e.g., preauthorization)', AppColors.info),  // Blue: Plan
          const SizedBox(height: 10),
          _buildPDSAStep('Do', 'Implement the intervention on a small scale (e.g., pilot in one ICU for 3 months)', AppColors.info),  // Blue: Do
          const SizedBox(height: 10),
          _buildPDSAStep('Study', 'Analyze data (e.g., carbapenem DOT, CRE incidence, acceptance rates)', AppColors.warning),  // Amber: Study
          const SizedBox(height: 10),
          _buildPDSAStep('Act', 'If successful, scale up to all ICUs; if unsuccessful, refine and repeat', AppColors.success),  // Green: Act
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'PDSA cycles allow rapid testing and adaptation without large-scale disruption.',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDSAStep(String step, String description, Color color) {
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
            step,
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

  Widget _buildPDSAExample() {
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
                child: const Center(child: Icon(Icons.lightbulb, color: Colors.white, size: 24)),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case Example: PDSA Cycle for Carbapenem Reduction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          _buildPDSAExampleStep('Plan', 'ICU carbapenem DOT = 120 per 1,000 patient-days (75th percentile). Goal: Reduce to 80 (50th percentile) through preauthorization.', AppColors.info),
          const SizedBox(height: 10),
          _buildPDSAExampleStep('Do', 'Implement preauthorization in ICU for 3 months.', AppColors.info),
          const SizedBox(height: 10),
          _buildPDSAExampleStep('Study', 'Carbapenem DOT decreases to 85 (↓29%), CRE incidence decreases from 1.2 to 0.8 per 1,000 patient-days (↓33%), acceptance rate = 85%, no increase in mortality.', AppColors.warning),
          const SizedBox(height: 10),
          _buildPDSAExampleStep('Act', 'Scale up preauthorization to all ICUs and med-surg units.', AppColors.success),
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
                    'Result: Hospital-wide carbapenem DOT decreases to 70 (25th percentile) after 12 months.',
                    style: TextStyle(fontSize: 14, color: AppColors.success, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDSAExampleStep(String step, String description, Color color) {
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
            step,
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

  Widget _buildRootCauseAnalysisCard() {
    return StructuredContentCard(
      icon: Icons.search,
      heading: 'Root Cause Analysis (RCA) for Stewardship Failures',
      color: AppColors.info,  // Blue: RCA information
      content: '''When to Conduct RCA:
When stewardship interventions fail or adverse events occur (e.g., treatment failure, delayed therapy, medication error)

RCA Steps:
• Define the problem (e.g., patient with sepsis received inappropriate antibiotic, leading to treatment failure)
• Gather data (review medical records, interview staff)
• Identify root causes (e.g., lack of allergy verification, delayed culture review, prescriber knowledge gap)
• Develop action plan (e.g., implement allergy verification protocol, EMR alerts, prescriber education)
• Monitor outcomes

Example:
A 70-year-old man with sepsis is started on ceftriaxone. Blood cultures at 48 hours grow ESBL-producing E. coli resistant to ceftriaxone. Patient deteriorates and requires ICU transfer.

RCA Findings:
• Prescriber did not review patient's recent hospitalization and prior ESBL infection
• EMR did not flag prior MDRO
• Stewardship team did not review case within 24 hours

Action Plan:
• Implement EMR alert for prior MDRO
• Prioritize stewardship review for sepsis patients within 24 hours
• Educate prescribers on risk factors for ESBL

Outcome: No similar cases in the following 6 months''',
    );
  }

  Widget _buildFeedbackLoopsCard() {
    return StructuredContentCard(
      icon: Icons.loop,
      heading: 'Feedback Loops and Iterative Improvement',
      color: AppColors.warning,  // Amber: Feedback loops caution
      content: '''Establish Regular Feedback Loops:
• Monthly stewardship committee meetings to review metrics, discuss challenges, and plan interventions
• Quarterly reports to leadership with key metrics and action items
• Real-time feedback to prescribers through audit and feedback, EMR alerts, and academic detailing
• Annual surveys to assess prescriber knowledge, attitudes, and satisfaction with stewardship program

Use Feedback to Refine Interventions:
• Identify barriers and address them (e.g., lack of EMR integration, prescriber resistance)
• Adapt interventions based on changing resistance patterns and new evidence
• Celebrate successes and share best practices''',
    );
  }

  Widget _buildCelebratingSuccessesCard() {
    return StructuredContentCard(
      icon: Icons.celebration,
      heading: 'Celebrating Successes and Sharing Best Practices',
      color: AppColors.success,  // Green: Celebrating successes
      content: '''Recognize and Celebrate Achievements:
• Announce milestones in newsletters (e.g., "We reached the 50th percentile for carbapenem use!")
• Recognize top-performing units or prescribers with awards or certificates
• Share success stories in grand rounds, conferences, or publications
• Host annual stewardship symposium to showcase achievements and share best practices

Benefits:
• Sustains momentum and motivates staff
• Fosters a culture of stewardship and continuous improvement
• Builds relationships with prescribers through positive reinforcement''',
    );
  }

  Widget _buildSustainabilityCard() {
    return StructuredContentCard(
      icon: Icons.eco,
      heading: 'Long-Term Sustainability Strategies',
      color: AppColors.error,  // Red: Critical sustainability requirements
      content: '''Sustaining Stewardship Programs:
• Secure dedicated FTE for stewardship team (pharmacist, ID physician, data analyst)
• Integrate stewardship metrics into hospital quality dashboards and executive scorecards
• Align stewardship goals with institutional priorities (e.g., cost savings, patient safety, regulatory compliance)
• Build relationships with prescribers through education, collaboration, and respect
• Adapt to changing resistance patterns, new evidence, and emerging threats (e.g., COVID-19, monkeypox)
• Advocate for stewardship at the state and national level (e.g., mandatory reporting, reimbursement incentives)

Barriers to Sustainability:
• Turnover of stewardship team members or leadership
• Competing priorities (e.g., budget cuts, staffing shortages)
• Prescriber resistance or fatigue
• Lack of EMR integration or data infrastructure
• Regulatory changes or reimbursement pressures

Strategies to Overcome Barriers:
• Cross-train multiple team members to ensure continuity
• Demonstrate value through outcome data (e.g., cost savings, reduced CDI)
• Engage prescribers as stewardship champions
• Invest in EMR optimization and data analytics
• Stay informed of regulatory changes and adapt accordingly''',
    );
  }

  Widget _buildLongTermExample() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Case example
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
                child: const Center(child: Icon(Icons.timeline, color: Colors.white, size: 24)),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case Example: Long-Term Sustainability', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'A 300-bed community hospital launches a stewardship program in 2018 with 0.5 FTE pharmacist and 0.2 FTE ID physician.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'Initial interventions: Prospective audit and feedback, carbapenem preauthorization, order sets for CAP and UTI.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'Results after 2 years: Carbapenem DOT ↓40%, CDI rate ↓30%, cost savings \$300,000/year.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          const Text(
            'Leadership approves 1.0 FTE pharmacist and 0.5 FTE ID physician. Program expands to include academic detailing, peer comparison, and NHSN benchmarking.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'By 2024, the hospital consistently ranks <25th percentile for antibiotic use and receives state recognition for stewardship excellence.',
                    style: TextStyle(fontSize: 14, color: AppColors.success, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'PDSA (Plan-Do-Study-Act) cycles: Structured framework for testing and scaling interventions (e.g., carbapenem preauthorization pilot → scale-up)',
      'Root cause analysis (RCA): Identify underlying causes of stewardship failures (e.g., treatment failure, delayed therapy) and prevent recurrence',
      'Feedback loops: Monthly committee meetings, quarterly leadership reports, real-time prescriber feedback, annual surveys',
      'Celebrating successes: Announce milestones, recognize top performers, share success stories, host annual symposium',
      'Long-term sustainability: Secure dedicated FTE, integrate metrics into dashboards, align with institutional priorities, build prescriber relationships',
      'Barriers to sustainability: Turnover, competing priorities, prescriber resistance, lack of EMR integration, regulatory changes',
      'Case example: Community hospital launches stewardship in 2018 → ↓40% carbapenem DOT, ↓30% CDI, \$300k savings → expands program → <25th percentile by 2024',
      'Implementation: Use PDSA cycles, conduct RCA, establish feedback loops, celebrate successes, secure resources, adapt to changes, advocate for stewardship',
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
      'CDC Core Elements of Hospital Antibiotic Stewardship (2019)': 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html',
      'IDSA/SHEA Guidelines for Antimicrobial Stewardship (2016)': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
      'Institute for Healthcare Improvement (IHI) - PDSA Cycles': 'https://www.ihi.org/resources/Pages/HowtoImprove/default.aspx',
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

