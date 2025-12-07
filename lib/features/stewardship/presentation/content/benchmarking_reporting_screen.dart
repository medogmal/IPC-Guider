import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

class BenchmarkingReportingScreen extends StatelessWidget {
  const BenchmarkingReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Benchmarking and Reporting'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.assessment_outlined,
            iconColor: AppColors.primary,
            title: 'Benchmarking and Reporting',
            subtitle: 'Demonstrating Value and Engaging Stakeholders',
            description: 'Internal and external benchmarking, dashboard design, reporting to leadership and frontline staff, and public transparency',
          ),
          const SizedBox(height: 20),
          const IntroductionCard(
            text: 'Benchmarking and reporting are essential for demonstrating stewardship program value, identifying improvement opportunities, and engaging stakeholders. Internal benchmarking compares performance across units and time periods within the same institution. External benchmarking compares performance against national data (e.g., NHSN AU Module). Effective reporting requires clear visualizations, actionable insights, and regular communication to leadership, committees, and frontline staff.',
          ),
          const SizedBox(height: 20),
          _buildInternalBenchmarkingCard(),
          const SizedBox(height: 20),
          _buildExternalBenchmarkingCard(),
          const SizedBox(height: 20),
          _buildDashboardDesignCard(),
          const SizedBox(height: 20),
          _buildReportingStrategiesCard(),
          const SizedBox(height: 20),
          _buildClinicalExample(),
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

  Widget _buildInternalBenchmarkingCard() {
    return StructuredContentCard(
      icon: Icons.compare,
      heading: 'Internal Benchmarking: Unit-to-Unit and Time Trends',
      color: AppColors.info,  // Blue: Internal benchmarking information
      content: '''Unit-to-Unit Comparisons:
• Compare antimicrobial consumption metrics (DOT, DDD, AU%) across units (ICU, med-surg, ED, oncology)
• Example: ICU DOT = 800 per 1,000 patient-days vs. med-surg DOT = 400 per 1,000 patient-days
• High ICU DOT is expected due to higher acuity, but outlier units may indicate overuse or inappropriate prescribing
• Stewardship interventions: Target high-use units with audit and feedback, education, and order sets

Time Trends:
• Track metrics over time (monthly, quarterly, annually) to identify trends and evaluate intervention impact
• Example: Carbapenem DOT decreases from 80 to 50 per 1,000 patient-days over 6 months after implementing preauthorization
• Use control charts (run charts, statistical process control) to distinguish signal from noise
• Celebrate successes and share best practices when targets are met''',
    );
  }

  Widget _buildExternalBenchmarkingCard() {
    return StructuredContentCard(
      icon: Icons.public,
      heading: 'External Benchmarking: NHSN AU Module and National Data',
      color: AppColors.info,  // Blue: External benchmarking information
      content: '''NHSN AU Module:
• The CDC's National Healthcare Safety Network (NHSN) Antimicrobial Use (AU) Module collects standardized antimicrobial consumption data from U.S. hospitals
• Hospitals submit monthly DOT data by drug category (e.g., carbapenems, vancomycin, fluoroquinolones) and receive percentile rankings (25th, 50th, 75th, 90th)
• Example: If your hospital's carbapenem DOT = 60 and the 50th percentile = 70, you are performing better than average
• Target: Aim for <50th percentile (below median)

State and National Data:
• Some states (e.g., California, New York) have mandatory antibiotic reporting programs
• National data sources include NHSN, IQVIA, and academic publications
• Benchmarking against similar hospitals (e.g., academic medical centers, community hospitals) provides context for performance
• Limitation: Differences in patient populations, acuity, and data collection methods may affect comparisons''',
    );
  }

  Widget _buildDashboardDesignCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Dashboard design
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
                child: const Icon(Icons.dashboard, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Dashboard Design and Visualization',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Effective dashboards present key metrics in a clear, actionable format.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
          _buildDashboardPrinciple('Visual Hierarchy', 'Most important metrics at the top', AppColors.info),  // Blue: Principle
          const SizedBox(height: 10),
          _buildDashboardPrinciple('Color Coding', 'Green = on target, yellow = caution, red = action needed', AppColors.success),  // Green: Best practice
          const SizedBox(height: 10),
          _buildDashboardPrinciple('Trend Lines', 'Arrows, sparklines to show direction', AppColors.info),  // Blue: Principle
          const SizedBox(height: 10),
          _buildDashboardPrinciple('Context', 'Benchmarks, targets, percentiles', AppColors.info),  // Blue: Principle
          const SizedBox(height: 10),
          _buildDashboardPrinciple('Limit Metrics', '5-7 key metrics to avoid information overload', AppColors.error),  // Red: Critical principle
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Example: Dashboard displays DOT, CDI rate, de-escalation rate, guideline compliance, and NHSN percentile with color-coded indicators.',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardPrinciple(String principle, String description, Color color) {
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
                TextSpan(text: '$principle: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportingStrategiesCard() {
    return StructuredContentCard(
      icon: Icons.groups,
      heading: 'Reporting Strategies: Leadership, Staff, and Public',
      color: AppColors.info,  // Blue: Reporting information
      content: '''Reporting to Leadership and Committees:
• Frequency: Quarterly reports to hospital leadership (CEO, CMO, CNO) and relevant committees (P&T, Infection Prevention, Quality)
• Content: Key metrics and trends, intervention highlights (e.g., carbapenem restriction, order sets), impact on outcomes (e.g., ↓CDI, ↓costs), challenges and barriers, action items and resource needs
• Format: Executive summaries (1-2 pages) with visual dashboards for busy leaders

Reporting to Frontline Staff:
• Share stewardship successes and data with prescribers, pharmacists, and nurses through newsletters, emails, and unit-based meetings
• Example: "Great work, ICU team! Your carbapenem DOT decreased by 30% this quarter, and CDI rates are down 40%. Keep up the excellent stewardship!"
• Use positive reinforcement and peer comparison to motivate behavior change
• Avoid punitive language or public shaming

Public Reporting and Transparency:
• Some hospitals publicly report antibiotic use metrics on their websites or in annual reports to demonstrate commitment to stewardship and transparency
• Public reporting may improve accountability and patient trust
• Limitation: Risk of misinterpretation by the public (e.g., high DOT may reflect high acuity, not overuse)
• Provide context and explanations to avoid confusion''',
    );
  }

  Widget _buildClinicalExample() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Clinical example
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
              const Expanded(child: Text('Case Example: NHSN Benchmarking Success', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'A 500-bed hospital submits data to NHSN AU Module and receives the following percentile rankings:',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
          _buildPercentileRow('Carbapenem DOT', '75th percentile (higher than 75% of hospitals)', AppColors.error),  // Red: High percentile
          const SizedBox(height: 8),
          _buildPercentileRow('Vancomycin DOT', '50th percentile (median)', AppColors.warning),  // Amber: Medium percentile
          const SizedBox(height: 8),
          _buildPercentileRow('Fluoroquinolone DOT', '25th percentile (lower than 75% of hospitals)', AppColors.success),  // Green: Low percentile
          const SizedBox(height: 16),
          const Text(
            'Action: The stewardship team prioritizes carbapenem reduction through preauthorization and audit and feedback.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 12),
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
                    'Result: After 6 months, carbapenem DOT decreases to the 50th percentile, and CRE incidence decreases by 40%.',
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

  Widget _buildPercentileRow(String metric, String percentile, Color color) {
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
                TextSpan(text: '$metric: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: percentile),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImplementationCard() {
    return StructuredContentCard(
      icon: Icons.settings,
      heading: 'Implementation Strategies',
      color: AppColors.error,  // Red: Critical implementation requirements
      content: '''• Establish a stewardship dashboard with key metrics and benchmarks
• Submit data to NHSN AU Module for external benchmarking
• Report quarterly to leadership and committees with visual dashboards and executive summaries
• Share successes with frontline staff through newsletters and unit meetings
• Use benchmarking data to prioritize interventions and allocate resources
• Celebrate milestones (e.g., reaching 50th percentile) and share best practices''',
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Internal benchmarking: Compare metrics across units (ICU vs. med-surg) and time periods (monthly, quarterly) to identify trends and outliers',
      'External benchmarking: NHSN AU Module provides percentile rankings (target <50th percentile), compare against similar hospitals',
      'Dashboard design: Visual hierarchy, color coding (green/yellow/red), trend lines, benchmarks, limit to 5-7 key metrics',
      'Reporting to leadership: Quarterly reports with key metrics, intervention highlights, impact on outcomes, challenges, action items',
      'Reporting to frontline staff: Share successes through newsletters, emails, unit meetings; use positive reinforcement and peer comparison',
      'Public reporting: Demonstrate transparency and accountability, but provide context to avoid misinterpretation',
      'Case example: Hospital at 75th percentile for carbapenem DOT → preauthorization → 50th percentile, ↓40% CRE incidence',
      'Implementation: Establish dashboard, submit to NHSN, report quarterly, share successes, prioritize interventions, celebrate milestones',
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
      'CDC NHSN Antimicrobial Use Module (2024)': 'https://www.cdc.gov/nhsn/acute-care-hospital/au/index.html',
      'IDSA/SHEA Guidelines for Antimicrobial Stewardship (2016)': 'https://academic.oup.com/cid/article/62/10/e51/2462846',
      'CDC Core Elements of Hospital Antibiotic Stewardship (2019)': 'https://www.cdc.gov/antibiotic-use/core-elements/hospital.html',
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

