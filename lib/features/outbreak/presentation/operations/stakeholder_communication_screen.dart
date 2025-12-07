import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';

class StakeholderCommunicationScreen extends StatelessWidget {
  const StakeholderCommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stakeholder Communication Matrix'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          children: [
          _buildHeaderCard(),
          const SizedBox(height: 24),
          _buildOverviewCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Internal Stakeholders'),
          const SizedBox(height: 12),
          _buildStakeholderCard(
            'Hospital Leadership',
            'CEO, CNO, CMO, COO',
            'Daily during active outbreak, weekly during monitoring',
            'Email, phone, in-person briefings',
            ['Situation summary', 'Resource needs', 'Risk assessment', 'Media inquiries'],
            AppColors.error,
            Icons.business_center_outlined,
          ),
          const SizedBox(height: 12),
          _buildStakeholderCard(
            'Affected Unit Staff',
            'Nurses, physicians, unit managers',
            'Daily updates, immediate for critical changes',
            'Unit huddles, email, posters',
            ['Control measures', 'PPE requirements', 'Case updates', 'Q&A'],
            AppColors.primary,
            Icons.local_hospital_outlined,
          ),
          const SizedBox(height: 12),
          _buildStakeholderCard(
            'Occupational Health',
            'Employee health services',
            'Daily during HCW exposure/infection',
            'Phone, email, secure messaging',
            ['HCW exposures', 'Screening protocols', 'Work restrictions', 'Prophylaxis'],
            AppColors.info,
            Icons.health_and_safety_outlined,
          ),
          const SizedBox(height: 12),
          _buildStakeholderCard(
            'Laboratory',
            'Microbiology, molecular diagnostics',
            'Daily during active testing',
            'Phone, email, lab information system',
            ['Testing protocols', 'Specimen requirements', 'Result turnaround', 'Capacity'],
            AppColors.warning,
            Icons.science_outlined,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('External Stakeholders'),
          const SizedBox(height: 12),
          _buildStakeholderCard(
            'Public Health Authorities',
            'Local/state health department, CDC',
            'Within 24h of outbreak declaration, then as required',
            'Phone, secure email, official reporting systems',
            ['Outbreak notification', 'Case reports', 'Control measures', 'Assistance requests'],
            const Color(0xFF1565C0),
            Icons.account_balance_outlined,
          ),
          const SizedBox(height: 12),
          _buildStakeholderCard(
            'Patients & Families',
            'Affected patients and their families',
            'As soon as possible after identification',
            'In-person, phone, written materials',
            ['Diagnosis', 'Treatment plan', 'Precautions', 'Prognosis', 'Support resources'],
            const Color(0xFF6A1B9A),
            Icons.people_outline,
          ),
          const SizedBox(height: 12),
          _buildStakeholderCard(
            'Media & Public',
            'News media, community',
            'Only through designated spokesperson',
            'Press releases, media briefings, website',
            ['Factual information', 'Control measures', 'Public safety', 'Contact information'],
            const Color(0xFFD32F2F),
            Icons.campaign_outlined,
          ),
          const SizedBox(height: 24),
          _buildEscalationPathwayCard(),
          const SizedBox(height: 24),
          _buildCommunicationPrinciplesCard(),
          const SizedBox(height: 24),
          _buildReferencesCard(),
        ],
      ),
    ),
    );
  }


  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.forum_outlined,
              color: AppColors.info,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stakeholder Communication Matrix',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Structured communication framework for outbreaks',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Effective stakeholder communication prevents misinformation, ensures coordinated response, and maintains trust. This matrix defines who needs to know what, when, and how during an outbreak.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Critical: All external communication must go through designated spokesperson.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildStakeholderCard(
    String stakeholder,
    String description,
    String frequency,
    String methods,
    List<String> keyMessages,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stakeholder,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.schedule, 'Frequency', frequency),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.chat_bubble_outline, 'Methods', methods),
          const SizedBox(height: 8),
          Text(
            'Key Messages:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          ...keyMessages.map((message) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.circle,
                    color: color,
                    size: 6,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 14),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEscalationPathwayCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Communication Escalation Pathway',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEscalationLevel('Level 1: Routine', 'IPC team → Unit managers → Affected staff', AppColors.success),
          _buildEscalationLevel('Level 2: Moderate', 'Add: Hospital leadership, Occupational Health', AppColors.warning),
          _buildEscalationLevel('Level 3: Severe', 'Add: Public Health, CEO, Communications team', AppColors.error),
          _buildEscalationLevel('Level 4: Critical', 'Add: Media spokesperson, External partners, Board', const Color(0xFF8B0000)),
        ],
      ),
    );
  }

  Widget _buildEscalationLevel(String level, String stakeholders, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              level,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stakeholders,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationPrinciplesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Communication Principles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'Be timely: Communicate early and often',
            'Be accurate: Verify information before sharing',
            'Be transparent: Acknowledge uncertainties',
            'Be consistent: Use unified messaging across channels',
            'Be empathetic: Acknowledge concerns and emotions',
            'Be accessible: Provide multiple communication channels',
            'Be confidential: Protect patient and staff privacy',
            'Be documented: Record all communications',
          ].map((principle) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    principle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildReferencesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.library_books, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Official References',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReferenceItem(
            'CDC Crisis & Emergency Risk Communication (CERC)',
            'https://emergency.cdc.gov/cerc/',
          ),
          _buildReferenceItem(
            'WHO Outbreak Communication Guidelines',
            'https://www.who.int/emergencies/outbreak-toolkit',
          ),
          _buildReferenceItem(
            'APIC Communication Resources',
            'https://apic.org/professional-practice/',
          ),
        ],
      ),
    );
  }



  Widget _buildReferenceItem(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Row(
          children: [
            Icon(
              Icons.open_in_new,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
