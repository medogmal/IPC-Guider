import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

class EducationBehavioralScreen extends StatelessWidget {
  const EducationBehavioralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Education and Behavioral Interventions'),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.school,
            iconColor: AppColors.warning,  // Amber: Education
            title: 'Education and Behavioral Interventions',
            subtitle: 'Changing Prescriber Behavior',
            description: 'Academic detailing, peer comparison, commitment devices, nudges, and gamification to optimize antimicrobial prescribing',
          ),
          const SizedBox(height: 20),
          const IntroductionCard(
            text: 'Education and behavioral interventions are essential components of antimicrobial stewardship programs. They aim to change prescriber behavior through knowledge dissemination, peer comparison, commitment devices, nudges, and gamification. These interventions complement structural interventions (audit and feedback, preauthorization) by addressing the cognitive and social factors that influence prescribing decisions.',
          ),
          const SizedBox(height: 20),
          _buildAcademicDetailingCard(),
          const SizedBox(height: 20),
          _buildPeerComparisonCard(),
          const SizedBox(height: 20),
          _buildCommitmentDevicesCard(),
          const SizedBox(height: 20),
          _buildGamificationCard(),
          const SizedBox(height: 20),
          _buildMeasuringBehaviorCard(),
          const SizedBox(height: 20),
          _buildClinicalExample1(),
          const SizedBox(height: 20),
          _buildClinicalExample2(),
          const SizedBox(height: 20),
          _buildClinicalExample3(),
          const SizedBox(height: 20),
          _buildClinicalExample4(),
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

  Widget _buildAcademicDetailingCard() {
    return StructuredContentCard(
      icon: Icons.person,
      heading: 'Academic Detailing & One-on-One Education',
      color: AppColors.info,
      content: '''What is Academic Detailing?
Personalized, evidence-based education delivered by a stewardship pharmacist or ID physician to individual prescribers or small groups

Why More Effective Than Passive Education?
Tailored to prescriber's practice, addresses specific knowledge gaps, builds relationships

Topics Covered:
• Local antibiogram and resistance trends
• Evidence-based guidelines for common infections
• PK/PD principles and dose optimization
• De-escalation strategies and IV-to-oral conversion
• Duration of therapy and automatic stop orders''',
    );
  }

  Widget _buildPeerComparisonCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Academic detailing
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
                child: const Icon(Icons.people, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Peer Comparison & Audit Feedback',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Leverage social norms to influence prescriber behavior',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text('Prescribers are shown how their antibiotic prescribing compares to their peers:', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '"You prescribed broad-spectrum antibiotics 40% of the time, compared to 20% for your peers"',
              style: TextStyle(fontSize: 14, color: AppColors.info, height: 1.6, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          const Text('This creates social pressure to conform to group norms and reduces inappropriate prescribing.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Studies show that peer comparison reduces antibiotic prescribing by 5-10% without increasing adverse outcomes.',
              style: TextStyle(fontSize: 14, color: AppColors.success, height: 1.6, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Key: Present data in a non-punitive, educational manner and provide actionable recommendations for improvement.',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitmentDevicesCard() {
    return StructuredContentCard(
      icon: Icons.touch_app,
      heading: 'Commitment Devices & Nudges',
      color: AppColors.info,
      content: '''What are Nudges?
Behavioral interventions that make it easier for prescribers to choose the desired behavior

Examples:
• Default order sets with evidence-based durations (e.g., 5 days for CAP) that require active opt-out to extend therapy
• Automatic stop orders that require justification to continue antibiotics beyond default duration
• EMR prompts for IV-to-oral conversion when criteria are met
• Pre-checked boxes for narrow-spectrum agents in order sets
• Public commitment pledges (e.g., "I commit to prescribing antibiotics responsibly")''',
    );
  }

  Widget _buildGamificationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Gamification
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
                child: const Icon(Icons.emoji_events, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Gamification & Incentives',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Use game-like elements to motivate prescribers to improve their antibiotic prescribing',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildGamificationItem('Points', 'Earn points for de-escalating antibiotics, converting IV-to-oral, adhering to evidence-based durations', AppColors.warning),
          const SizedBox(height: 10),
          _buildGamificationItem('Badges', 'Unlock badges for achieving milestones (e.g., "Stewardship Champion")', AppColors.info),
          const SizedBox(height: 10),
          _buildGamificationItem('Leaderboards', 'Display top performers, creating friendly competition', AppColors.info),
          const SizedBox(height: 10),
          _buildGamificationItem('Incentives', 'Recognition (certificates, awards), CME credits, or small financial rewards', AppColors.success),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Studies show that gamification can increase adherence to stewardship interventions by 10-20%.',
              style: TextStyle(fontSize: 14, color: AppColors.success, height: 1.6, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationItem(String element, String description, Color color) {
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
                TextSpan(text: '$element: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeasuringBehaviorCard() {
    return StructuredContentCard(
      icon: Icons.analytics,
      heading: 'Measuring Behavior Change',
      color: AppColors.success,
      content: '''• Antibiotic Prescribing Rates: DOT (Days of Therapy) per 1,000 patient-days
• Guideline Adherence: % of CAP patients receiving ceftriaxone + azithromycin
• De-escalation Rates: % of patients de-escalated from broad-spectrum to narrow-spectrum therapy
• IV-to-Oral Conversion Rates: % of eligible patients converted
• Duration of Therapy: Average days of antibiotics for CAP, UTI, SSTI
• Prescriber Knowledge & Attitudes: Pre/post surveys to assess knowledge and attitudes''',
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
              const Expanded(child: Text('Case 1: Academic Detailing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A stewardship pharmacist conducts academic detailing with a hospitalist group. She presents the local antibiogram showing 85% of E. coli isolates are susceptible to ceftriaxone, and only 10% are ESBL-producing.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('RECOMMENDATION', 'Use ceftriaxone as first-line therapy for pyelonephritis instead of carbapenems', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'Over the next 3 months, carbapenem use decreases by 30% in the hospitalist group, with no increase in treatment failures. Academic detailing changed prescriber behavior and reduced unnecessary carbapenem use', AppColors.success),
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
              const Expanded(child: Text('Case 2: Peer Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A hospital implements peer comparison feedback for antibiotic prescribing. Prescribers receive quarterly reports showing their broad-spectrum antibiotic use compared to their peers.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('FEEDBACK', 'One prescriber learns that he prescribes vancomycin + piperacillin-tazobactam 50% of the time, compared to 25% for his peers', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('OUTCOME', 'He commits to using narrower-spectrum agents when appropriate. Over the next 6 months, his broad-spectrum use decreases to 30%, aligning with peer norms. Peer comparison leveraged social norms to reduce inappropriate prescribing', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildClinicalExample3() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Example 3
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
                child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 3: Default Durations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A hospital implements a default order set for CAP with a 5-day duration and automatic stop order. Prescribers must actively extend therapy beyond 5 days by providing justification.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('OUTCOME', 'Over the next year, the average duration of CAP therapy decreases from 7 days to 5.5 days, with no increase in readmissions or treatment failures. Default durations and automatic stop orders nudged prescribers toward evidence-based durations', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildClinicalExample4() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Example 4
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
                child: const Center(child: Text('4', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 4: Gamification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A hospital implements a gamification program for antibiotic stewardship. Prescribers earn points for de-escalating antibiotics, converting IV-to-oral, and adhering to evidence-based durations. Leaderboards display top performers.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('OUTCOME', 'Over 6 months, adherence to stewardship interventions increases by 15%, and prescribers report increased engagement and motivation. Gamification increased adherence to stewardship interventions through friendly competition', AppColors.success),
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
      color: AppColors.error,
      content: '''• Conduct Needs Assessment: Identify knowledge gaps and prescribing patterns
• Develop Tailored Education: Academic detailing, peer comparison reports, commitment pledges
• Integrate into EMR: Default order sets, automatic stop orders, prompts
• Provide Ongoing Feedback: Regular feedback and reinforcement
• Measure Behavior Change: Use stewardship metrics (DOT, guideline adherence, de-escalation rates)
• Celebrate Successes: Recognize top performers and share success stories''',
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Academic detailing: personalized, evidence-based education delivered one-on-one or in small groups (more effective than passive education)',
      'Peer comparison: show prescribers how their antibiotic use compares to peers (reduces prescribing by 5-10% through social norms)',
      'Commitment devices and nudges: default order sets, automatic stop orders, EMR prompts, pre-checked boxes, public pledges',
      'Gamification: points, badges, leaderboards to motivate prescribers (increases adherence by 10-20%)',
      'Measuring behavior change: antibiotic prescribing rates, guideline adherence, de-escalation rates, IV-to-oral conversion, duration of therapy',
      'Case examples: academic detailing reduced carbapenem use by 30%, peer comparison reduced broad-spectrum use, default durations reduced CAP therapy from 7d to 5.5d',
      'Barriers: limited time/resources, prescriber resistance, EMR limitations, lack of support',
      'Implementation: needs assessment, tailored education, integrate into EMR, ongoing feedback, measure behavior change, celebrate successes',
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
      'Behavioral Economics and Antibiotic Stewardship (JAMA 2016)': 'https://jamanetwork.com/journals/jama/fullarticle/2488307',
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

