import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Alerts & Communication'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          children: [
          _buildHeaderCard(),
          const SizedBox(height: 24),
          _buildOverviewCard(),
          const SizedBox(height: 24),
          _buildAlertLevelsCard(),
          const SizedBox(height: 24),
          _buildInternalCommunicationCard(),
          const SizedBox(height: 16),
          _buildExternalReportingCard(),
          const SizedBox(height: 24),
          _buildCommunicationChecklistCard(),
          const SizedBox(height: 24),
          _buildReferencesCard(context),
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.3),
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerts & Communication',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Notification protocols and reporting systems',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
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
            'Effective alert systems and communication protocols ensure rapid response and stakeholder awareness. Based on CDC CERC principles, WHO guidelines, and GDIPC/Weqaya notification requirements.',
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
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.info, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Key Principle: Right information, right people, right time, right method.',
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

  Widget _buildAlertLevelsCard() {
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
              Icon(Icons.priority_high_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Alert Levels & Triggers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAlertLevel(
            'RED ALERT',
            AppColors.error,
            'Critical Outbreak',
            [
              'Category A outbreak declared',
              'Immediate threat to patient/staff safety',
              'Multi-unit or facility-wide spread',
              'Notify: All stakeholders within 1 hour',
            ],
          ),
          const SizedBox(height: 16),
          _buildAlertLevel(
            'ORANGE ALERT',
            AppColors.warning,
            'Moderate Outbreak',
            [
              'Category B outbreak declared',
              'Contained but requires enhanced monitoring',
              'Single unit involvement',
              'Notify: Key stakeholders within 4 hours',
            ],
          ),
          const SizedBox(height: 16),
          _buildAlertLevel(
            'YELLOW ALERT',
            const Color(0xFFFDD835),
            'Low-Level Cluster',
            [
              'Category C cluster identified',
              'Routine surveillance and monitoring',
              'Limited scope',
              'Notify: IPC team and unit manager within 24 hours',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertLevel(String level, Color color, String description, List<String> criteria) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  level,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...criteria.map((criterion) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.fiber_manual_record,
                    size: 6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    criterion,
                    style: TextStyle(
                      fontSize: 13,
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

  Widget _buildInternalCommunicationCard() {
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
              Icon(Icons.people_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Internal Communication Tiers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCommunicationTier(
            'Tier 1: Immediate',
            AppColors.error,
            Icons.emergency_outlined,
            [
              'Incident Commander and outbreak response team',
              'Hospital CEO/CMO/CNO',
              'Affected unit managers and staff',
              'Method: Phone call + in-person briefing',
            ],
          ),
          const SizedBox(height: 12),
          _buildCommunicationTier(
            'Tier 2: Rapid (Within 4 hours)',
            AppColors.warning,
            Icons.speed_outlined,
            [
              'Infection Control Committee',
              'Occupational Health',
              'Laboratory and Environmental Services',
              'Method: Email + secure messaging',
            ],
          ),
          const SizedBox(height: 12),
          _buildCommunicationTier(
            'Tier 3: Routine (Within 24 hours)',
            AppColors.info,
            Icons.schedule_outlined,
            [
              'All clinical staff (facility-wide)',
              'Support services (housekeeping, dietary)',
              'Quality and risk management',
              'Method: Email + intranet posting',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationTier(String title, Color color, IconData icon, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.fiber_manual_record,
                    size: 6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
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

  Widget _buildExternalReportingCard() {
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
              Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'External Reporting Requirements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
              width: 1,
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                children: [
                  _buildTableHeader('Authority'),
                  _buildTableHeader('When'),
                  _buildTableHeader('Platform'),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell('GDIPC', null),
                  _buildTableCell('24h', null),
                  _buildTableCell('Weqaya system', null),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell('MOH Regional Office', null),
                  _buildTableCell('24h', null),
                  _buildTableCell('Phone + email', null),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell('Weqaya (Saudi CDC)', null),
                  _buildTableCell('24h', null),
                  _buildTableCell('Online portal', null),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell('Local Health Dept', null),
                  _buildTableCell('24-48h', null),
                  _buildTableCell('Official form', null),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, Color? color) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color ?? AppColors.textPrimary,
          fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCommunicationChecklistCard() {
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
              Icon(Icons.checklist_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Communication Checklist',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCriteriaList([
            'Verify accuracy of information before dissemination',
            'Use clear, non-technical language appropriate for audience',
            'Include specific actions required from recipients',
            'Provide contact information for questions',
            'Document all communications (date, time, recipients, content)',
            'Follow up to confirm receipt and understanding',
            'Update stakeholders regularly (daily during active outbreak)',
            'Coordinate messaging across all channels',
          ]),
        ],
      ),
    );
  }

  Widget _buildCriteriaList(List<String> criteria) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: criteria.map((criterion) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.fiber_manual_record,
                  size: 8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  criterion,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReferencesCard(BuildContext context) {
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
              Icon(Icons.library_books_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'References',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReferenceLink(
            context,
            'GDIPC Healthcare-Associated Outbreak Management Manual 2023',
            'https://www.moh.gov.sa/Ministry/Rules/Documents/Healthcare-Associated-Outbreak-Management-Manual.pdf',
          ),
          _buildReferenceLink(
            context,
            'Weqaya (Saudi CDC) Reporting System',
            'https://covid19.moh.gov.sa/',
          ),
          _buildReferenceLink(
            context,
            'CDC Crisis and Emergency Risk Communication (CERC)',
            'https://emergency.cdc.gov/cerc/index.asp',
          ),
          _buildReferenceLink(
            context,
            'WHO Outbreak Communication Guidelines',
            'https://www.who.int/emergencies/outbreak-toolkit',
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceLink(BuildContext context, String title, String url) {
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
            Icon(Icons.link, size: 16, color: AppColors.primary),
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
