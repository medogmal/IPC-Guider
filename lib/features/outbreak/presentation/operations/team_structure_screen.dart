import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';

class TeamStructureScreen extends StatelessWidget {
  const TeamStructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outbreak Team Structure & Roles'),
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
          // Header Card
          _buildHeaderCard(),
          
          const SizedBox(height: 24),
          
          // Overview Section
          _buildOverviewCard(),
          
          const SizedBox(height: 24),
          
          // IMS Structure Diagram
          _buildIMSStructureCard(),
          
          const SizedBox(height: 24),
          
          // Core Roles Section
          _buildSectionTitle('Core Team Roles'),
          const SizedBox(height: 16),
          
          _buildRoleCard(
            title: 'Incident Commander',
            icon: Icons.person_outline,
            color: AppColors.error,
            responsibilities: [
              'Overall authority and responsibility for outbreak response',
              'Approve objectives and strategies in Outbreak Action Plan',
              'Authorize resource allocation and expenditures',
              'Ensure safety of response team members',
              'Liaison with hospital leadership and external agencies',
            ],
            qualifications: 'Senior IPC professional, Hospital Epidemiologist, or designated administrator',
            reportsTo: 'Hospital CEO/CMO',
          ),
          
          const SizedBox(height: 16),
          
          _buildRoleCard(
            title: 'Operations Chief',
            icon: Icons.medical_services_outlined,
            color: AppColors.primary,
            responsibilities: [
              'Implement control measures and clinical interventions',
              'Coordinate patient cohorting and isolation',
              'Manage environmental cleaning and disinfection',
              'Supervise PPE distribution and training',
              'Monitor compliance with infection control protocols',
            ],
            qualifications: 'Infection Preventionist or Clinical Manager',
            reportsTo: 'Incident Commander',
          ),
          
          const SizedBox(height: 16),
          
          _buildRoleCard(
            title: 'Planning Chief',
            icon: Icons.analytics_outlined,
            color: AppColors.info,
            responsibilities: [
              'Collect, analyze, and display outbreak data',
              'Maintain line list and epidemic curve',
              'Prepare situation reports and briefings',
              'Develop and update Outbreak Action Plan',
              'Document all decisions and actions',
            ],
            qualifications: 'Epidemiologist, Data Analyst, or IPC Coordinator',
            reportsTo: 'Incident Commander',
          ),
          
          const SizedBox(height: 16),
          
          _buildRoleCard(
            title: 'Logistics Chief',
            icon: Icons.inventory_outlined,
            color: AppColors.warning,
            responsibilities: [
              'Procure and distribute supplies (PPE, testing, cleaning)',
              'Manage staff deployment and scheduling',
              'Coordinate with vendors and suppliers',
              'Track resource utilization and costs',
              'Arrange training and equipment',
            ],
            qualifications: 'Supply Chain Manager or Administrative Coordinator',
            reportsTo: 'Incident Commander',
          ),
          
          const SizedBox(height: 24),
          
          // Activation Criteria
          _buildActivationCriteriaCard(),
          
          const SizedBox(height: 24),
          
          // RACI Matrix
          _buildRACIMatrixCard(),
          
          const SizedBox(height: 24),
          
          // References
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
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.groups_outlined,
              color: AppColors.warning,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Outbreak Team Structure & Roles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'IMS-based team organization and responsibilities',
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
            'The Incident Management System (IMS) provides a standardized, scalable framework for organizing outbreak response teams. Based on WHO and CDC guidelines, IMS ensures clear roles, efficient communication, and coordinated action during healthcare-associated outbreaks.',
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
                    'Key Principle: Scalability - Start small with core roles, expand as outbreak severity increases.',
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

  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> responsibilities,
    required String qualifications,
    required String reportsTo,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Role Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Responsibilities
          Text(
            'Key Responsibilities:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...responsibilities.map((resp) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    resp,
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

          const SizedBox(height: 12),

          // Qualifications
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school_outlined, color: color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Qualifications:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  qualifications,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Reports To
          Row(
            children: [
              Icon(Icons.arrow_upward, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 6),
              Text(
                'Reports to: ',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                reportsTo,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIMSStructureCard() {
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
          Text(
            'IMS Organizational Structure',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildHierarchyLevel('Incident Commander', 0, AppColors.error),
          _buildHierarchyLevel('├─ Operations Chief', 1, AppColors.primary),
          _buildHierarchyLevel('├─ Planning Chief', 1, AppColors.info),
          _buildHierarchyLevel('├─ Logistics Chief', 1, AppColors.warning),
          _buildHierarchyLevel('└─ Finance/Admin Chief (if needed)', 1, AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildHierarchyLevel(String title, int level, Color color) {
    return Padding(
      padding: EdgeInsets.only(left: level * 20.0, bottom: 8),
      child: Row(
        children: [
          Icon(
            level == 0 ? Icons.account_circle : Icons.person_outline,
            color: color,
            size: level == 0 ? 20 : 16,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: level == 0 ? 15 : 14,
              fontWeight: level == 0 ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivationCriteriaCard() {
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
              Icon(Icons.power_settings_new, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Team Activation Criteria',
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
            'Activate the full outbreak team when ANY of the following occur:',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            '≥3 confirmed cases within 7 days (or above facility baseline)',
            'High-consequence pathogen (e.g., Ebola, MERS, novel pathogen)',
            'Multi-facility or community-wide outbreak',
            'Significant media attention or public concern',
            'Request from health authorities or hospital leadership',
            'Outbreak affecting vulnerable populations (NICU, ICU, transplant)',
          ].map((criteria) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    criteria,
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

  Widget _buildRACIMatrixCard() {
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
          Text(
            'RACI Matrix (Responsibility Assignment)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRACILegend('R', 'Responsible', 'Does the work', AppColors.primary),
                _buildRACILegend('A', 'Accountable', 'Final authority', AppColors.error),
                _buildRACILegend('C', 'Consulted', 'Provides input', AppColors.info),
                _buildRACILegend('I', 'Informed', 'Kept updated', AppColors.warning),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Example: Case Investigation',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildRACIExample('Incident Commander', 'A'),
          _buildRACIExample('Operations Chief', 'R'),
          _buildRACIExample('Planning Chief', 'C'),
          _buildRACIExample('Hospital Leadership', 'I'),
        ],
      ),
    );
  }

  Widget _buildRACILegend(String letter, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRACIExample(String role, String raciCode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              role,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getRACIColor(raciCode).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              raciCode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getRACIColor(raciCode),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRACIColor(String code) {
    switch (code) {
      case 'R': return AppColors.primary;
      case 'A': return AppColors.error;
      case 'C': return AppColors.info;
      case 'I': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
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
            'WHO Incident Management System',
            'https://www.who.int/emergencies/operations',
          ),
          _buildReferenceItem(
            'CDC Emergency Operations Centers and IMS',
            'https://www.cdc.gov/field-epi-manual/php/chapters/eoc-incident-management.html',
          ),
          _buildReferenceItem(
            'APIC Outbreak Investigation Competencies',
            'https://apic.org/professional-practice/infection-preventionist-ip-competency-model/',
          ),
          _buildReferenceItem(
            'CDC Field Epidemiology Manual',
            'https://www.cdc.gov/field-epi-manual/',
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
