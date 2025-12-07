import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import 'contact_tracing_dialog.dart';

class ContactTracingTool extends StatefulWidget {
  const ContactTracingTool({super.key});

  @override
  State<ContactTracingTool> createState() => _ContactTracingToolState();
}

class _ContactTracingToolState extends State<ContactTracingTool> {
  // Index case data
  Map<String, dynamic>? _indexCase;
  final _caseIdController = TextEditingController();
  final _caseNameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  DateTime? _symptomOnsetDate;
  DateTime? _isolationDate;

  // Contact list
  List<Map<String, dynamic>> _contacts = [];
  
  // Filter and sort
  String _filterBy = 'All';
  String _sortBy = 'By Date';

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Systematic identification and monitoring of persons exposed to an infectious case.',
    example: 'Index case: COVID-19 patient in ICU. Contacts: 3 nurses (high risk), 2 visitors (medium risk), 5 patients in same ward (low risk).',
    interpretation: 'High-risk contacts require immediate testing and quarantine. Medium-risk contacts need daily monitoring. Low-risk contacts need passive surveillance.',
    whenUsed: 'Step 5-6 (case finding and descriptive epidemiology) of outbreak investigation.',
    inputDataType: 'Index case details, contact information, exposure characteristics, PPE use, follow-up data.',
    references: [
      Reference(
        title: 'WHO Contact Tracing Guidelines',
        url: 'https://www.who.int/publications/i/item/contact-tracing-in-the-context-of-covid-19',
      ),
      Reference(
        title: 'CDC Contact Tracing',
        url: 'https://www.cdc.gov/coronavirus/2019-ncov/php/contact-tracing/index.html',
      ),
      Reference(
        title: 'GDIPC Outbreak Manual',
        url: 'https://www.gdipc.org',
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _caseIdController.dispose();
    _caseNameController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Tracing Tool'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(),
                  const SizedBox(height: 20),

                  // Quick Guide Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showQuickGuide,
                      icon: Icon(Icons.menu_book, color: AppColors.info, size: 20),
                      label: Text(
                        'Quick Guide',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.info, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Load Template Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loadExample,
                      icon: Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
                      label: Text(
                        'Load Template',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.warning, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Index Case Card
                  _buildIndexCaseCard(),
                  const SizedBox(height: 20),

                  // Add Contact Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddContactDialog(),
                      icon: const Icon(Icons.person_add, size: 20),
                      label: const Text('Add Contact'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Summary Statistics (if contacts exist)
                  if (_contacts.isNotEmpty) ...[
                    _buildSummaryCard(),
                    const SizedBox(height: 20),
                  ],

                  // Filter and Sort
                  if (_contacts.isNotEmpty) ...[
                    _buildFilterAndSort(),
                    const SizedBox(height: 16),
                  ],

                  // Contact List
                  if (_contacts.isEmpty)
                    _buildEmptyState()
                  else
                    _buildContactList(),

                  const SizedBox(height: 20),

                  // Action Buttons
                  if (_contacts.isNotEmpty) _buildActionButtons(),

                  const SizedBox(height: 20),

                  // References Section
                  _buildReferences(),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.people_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Tracing Tool',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track and monitor exposed contacts during outbreak investigations',
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
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('Total', _contacts.length.toString(), AppColors.primary),
              const SizedBox(width: 12),
              _buildStatCard('High Risk', _getHighRiskCount().toString(), AppColors.error),
              const SizedBox(width: 12),
              _buildStatCard('Active', _getActiveCount().toString(), AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndexCaseCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(Icons.coronavirus_outlined, color: AppColors.error),
        title: const Text('Index Case Information'),
        subtitle: Text(
          _indexCase != null
            ? '${_indexCase!['caseName']} - ${_indexCase!['diagnosis']}'
            : 'Tap to add index case details',
          style: TextStyle(
            fontSize: 13,
            color: _indexCase != null ? AppColors.textSecondary : AppColors.warning,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _caseIdController,
                  decoration: InputDecoration(
                    labelText: 'Case ID',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _caseNameController,
                  decoration: InputDecoration(
                    labelText: 'Case Name *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _diagnosisController,
                  decoration: InputDecoration(
                    labelText: 'Diagnosis *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.medical_services_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _symptomOnsetDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _symptomOnsetDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Symptom Onset Date *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _symptomOnsetDate != null
                        ? _formatDate(_symptomOnsetDate!)
                        : 'Select date',
                      style: TextStyle(
                        color: _symptomOnsetDate != null ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _isolationDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setState(() => _isolationDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Isolation Date *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.shield_outlined),
                    ),
                    child: Text(
                      _isolationDate != null
                        ? _formatDate(_isolationDate!)
                        : 'Select date',
                      style: TextStyle(
                        color: _isolationDate != null ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearIndexCase,
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveIndexCase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final highRisk = _getHighRiskCount();
    final mediumRisk = _getMediumRiskCount();
    final lowRisk = _getLowRiskCount();
    final symptomatic = _getSymptomaticCount();
    final tested = _getTestedCount();
    final positive = _getPositiveCount();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withValues(alpha: 0.1),
            AppColors.info.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Contact Tracing Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('High Risk', highRisk.toString(), AppColors.error),
              _buildStatColumn('Medium', mediumRisk.toString(), AppColors.warning),
              _buildStatColumn('Low Risk', lowRisk.toString(), AppColors.success),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Symptomatic', symptomatic.toString(), symptomatic > 0 ? AppColors.error : AppColors.textSecondary),
              _buildStatColumn('Tested', tested.toString(), AppColors.textSecondary),
              _buildStatColumn('Positive', positive.toString(), positive > 0 ? AppColors.error : AppColors.textSecondary),
            ],
          ),
          if (positive > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Secondary Attack Rate: ${(positive / _contacts.length * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterAndSort() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('High'),
                const SizedBox(width: 8),
                _buildFilterChip('Medium'),
                const SizedBox(width: 8),
                _buildFilterChip('Low'),
                const SizedBox(width: 8),
                _buildFilterChip('Active'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          icon: Icon(Icons.sort, color: AppColors.primary),
          onSelected: (value) {
            setState(() {
              _sortBy = value;
              _sortContacts();
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'By Date', child: Text('By Date')),
            const PopupMenuItem(value: 'By Risk', child: Text('By Risk')),
            const PopupMenuItem(value: 'By Name', child: Text('By Name')),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterBy == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterBy = label;
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Contacts Added',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add contacts to start tracking exposures',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactList() {
    final filteredContacts = _getFilteredContacts();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredContacts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
        return _buildContactCard(contact);
      },
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    final riskLevel = contact['riskLevel'] as String;
    final riskColor = _getRiskColor(riskLevel);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: riskColor,
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
        title: Text(
          contact['contactName'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildRiskBadge(riskLevel),
              _buildInfoChip(contact['contactType'] as String, Icons.category_outlined),
              _buildInfoChip(_formatDate(DateTime.parse(contact['exposureDate'] as String)), Icons.calendar_today),
            ],
          ),
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showAddContactDialog(existingContact: contact);
            } else if (value == 'delete') {
              _deleteContact(contact['id'] as String);
            }
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Exposure Location', contact['exposureLocation'] as String),
                _buildDetailRow('Duration', contact['exposureDuration'] as String),
                _buildDetailRow('Distance', contact['distance'] as String),
                _buildDetailRow('PPE Used', (contact['ppeUsed'] as List).join(', ')),
                _buildDetailRow('Monitoring Status', contact['monitoringStatus'] as String),
                if (contact['symptomDeveloped'] as bool)
                  _buildDetailRow('Symptoms', 'Yes', color: AppColors.error),
                if (contact['testResult'] != null && (contact['testResult'] as String).isNotEmpty)
                  _buildDetailRow('Test Result', contact['testResult'] as String),
                if (contact['notes'] != null && (contact['notes'] as String).isNotEmpty)
                  _buildDetailRow('Notes', contact['notes'] as String),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String riskLevel) {
    final color = _getRiskColor(riskLevel);
    IconData icon;

    switch (riskLevel) {
      case 'High':
        icon = Icons.warning;
        break;
      case 'Medium':
        icon = Icons.info_outline;
        break;
      case 'Low':
        icon = Icons.check_circle_outline;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            riskLevel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textTertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: color ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showExportModal,
            icon: const Icon(Icons.file_download_outlined, size: 20),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear_all, size: 20),
            label: const Text('Clear All'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.error, width: 2),
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferences() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.library_books_outlined, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'References',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReferenceButton(
            'WHO Contact Tracing Guidelines',
            'https://www.who.int/publications/i/item/contact-tracing-in-the-context-of-covid-19',
          ),
          const SizedBox(height: 8),
          _buildReferenceButton(
            'CDC Contact Tracing',
            'https://www.cdc.gov/coronavirus/2019-ncov/php/contact-tracing/index.html',
          ),
          const SizedBox(height: 8),
          _buildReferenceButton(
            'GDIPC Outbreak Manual',
            'https://www.gdipc.org',
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceButton(String title, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.open_in_new, size: 16, color: AppColors.info),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  int _getHighRiskCount() {
    return _contacts.where((c) => c['riskLevel'] == 'High').length;
  }

  int _getMediumRiskCount() {
    return _contacts.where((c) => c['riskLevel'] == 'Medium').length;
  }

  int _getLowRiskCount() {
    return _contacts.where((c) => c['riskLevel'] == 'Low').length;
  }

  int _getActiveCount() {
    return _contacts.where((c) => c['monitoringStatus'] == 'Active').length;
  }

  int _getSymptomaticCount() {
    return _contacts.where((c) => c['symptomDeveloped'] == true).length;
  }

  int _getTestedCount() {
    return _contacts.where((c) => c['testResult'] != null && (c['testResult'] as String).isNotEmpty).length;
  }

  int _getPositiveCount() {
    return _contacts.where((c) => c['testResult'] == 'Positive').length;
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
        return AppColors.success;
      default:
        return AppColors.neutral;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _getFilteredContacts() {
    if (_filterBy == 'All') return _contacts;
    if (_filterBy == 'Active') {
      return _contacts.where((c) => c['monitoringStatus'] == 'Active').toList();
    }
    return _contacts.where((c) => c['riskLevel'] == _filterBy).toList();
  }

  void _sortContacts() {
    setState(() {
      if (_sortBy == 'By Date') {
        _contacts.sort((a, b) => DateTime.parse(b['exposureDate'] as String)
            .compareTo(DateTime.parse(a['exposureDate'] as String)));
      } else if (_sortBy == 'By Risk') {
        final riskOrder = {'High': 0, 'Medium': 1, 'Low': 2};
        _contacts.sort((a, b) => riskOrder[a['riskLevel']]!.compareTo(riskOrder[b['riskLevel']]!));
      } else if (_sortBy == 'By Name') {
        _contacts.sort((a, b) => (a['contactName'] as String).compareTo(b['contactName'] as String));
      }
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  void _showQuickGuide() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book, color: AppColors.info, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Quick Guide',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                KnowledgePanelWidget(data: _knowledgePanelData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddContactDialog({Map<String, dynamic>? existingContact}) async {
    final contactData = await ContactTracingDialog.showAddContactDialog(
      context: context,
      existingContact: existingContact,
    );

    if (contactData != null) {
      setState(() {
        if (existingContact != null) {
          // Update existing contact
          final index = _contacts.indexWhere((c) => c['id'] == existingContact['id']);
          if (index != -1) {
            _contacts[index] = contactData;
          }
        } else {
          // Add new contact
          _contacts.add(contactData);
        }
        _sortContacts();
      });

      _saveData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existingContact == null ? 'Contact added' : 'Contact updated'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _saveIndexCase() {
    if (_caseNameController.text.trim().isEmpty ||
        _diagnosisController.text.trim().isEmpty ||
        _symptomOnsetDate == null ||
        _isolationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _indexCase = {
        'caseId': _caseIdController.text.trim(),
        'caseName': _caseNameController.text.trim(),
        'diagnosis': _diagnosisController.text.trim(),
        'symptomOnsetDate': _symptomOnsetDate!.toIso8601String(),
        'isolationDate': _isolationDate!.toIso8601String(),
      };
    });

    _saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Index case saved'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _clearIndexCase() {
    setState(() {
      _indexCase = null;
      _caseIdController.clear();
      _caseNameController.clear();
      _diagnosisController.clear();
      _symptomOnsetDate = null;
      _isolationDate = null;
    });
    _saveData();
  }

  void _deleteContact(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _contacts.removeWhere((c) => c['id'] == id);
              });
              _saveData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact deleted'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to clear all contacts and index case data? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _contacts.clear();
                _clearIndexCase();
              });
              _saveData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load index case
      final indexCaseJson = prefs.getString('contact_tracing_index_case');
      if (indexCaseJson != null) {
        final data = json.decode(indexCaseJson) as Map<String, dynamic>;
        setState(() {
          _indexCase = data;
          _caseIdController.text = data['caseId'] ?? '';
          _caseNameController.text = data['caseName'] ?? '';
          _diagnosisController.text = data['diagnosis'] ?? '';
          _symptomOnsetDate = DateTime.parse(data['symptomOnsetDate'] as String);
          _isolationDate = DateTime.parse(data['isolationDate'] as String);
        });
      }

      // Load contacts
      final contactsJson = prefs.getStringList('contact_tracing_contacts') ?? [];
      setState(() {
        _contacts = contactsJson
            .map((c) => Map<String, dynamic>.from(json.decode(c)))
            .toList();
        _sortContacts();
      });
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save index case
      if (_indexCase != null) {
        await prefs.setString('contact_tracing_index_case', json.encode(_indexCase));
      } else {
        await prefs.remove('contact_tracing_index_case');
      }

      // Save contacts
      final contactsJson = _contacts.map((c) => json.encode(c)).toList();
      await prefs.setStringList('contact_tracing_contacts', contactsJson);
    } catch (e) {
      // Silent error handling
    }
  }

  void _loadExample() {
    setState(() {
      // Index case
      _indexCase = {
        'caseId': 'C001',
        'caseName': 'Patient Zero',
        'diagnosis': 'COVID-19',
        'symptomOnsetDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'isolationDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      };
      _caseIdController.text = 'C001';
      _caseNameController.text = 'Patient Zero';
      _diagnosisController.text = 'COVID-19';
      _symptomOnsetDate = DateTime.now().subtract(const Duration(days: 5));
      _isolationDate = DateTime.now().subtract(const Duration(days: 3));

      // Sample contacts
      _contacts = [
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'contactName': 'Nurse Sarah',
          'contactId': 'N001',
          'contactPhone': '',
          'contactType': 'Healthcare',
          'exposureDate': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          'exposureLocation': 'ICU Room 301',
          'exposureDuration': '1-4 hours',
          'distance': '<1 meter',
          'ppeUsed': ['Mask', 'Gloves'],
          'riskLevel': 'Medium',
          'monitoringStatus': 'Active',
          'symptomDeveloped': false,
          'testDate': null,
          'testResult': 'Negative',
          'notes': 'Provided direct patient care',
        },
        {
          'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          'contactName': 'Family Member John',
          'contactId': 'F001',
          'contactPhone': '',
          'contactType': 'Household',
          'exposureDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'exposureLocation': 'Home',
          'exposureDuration': '>4 hours',
          'distance': '<1 meter',
          'ppeUsed': ['None'],
          'riskLevel': 'High',
          'monitoringStatus': 'Active',
          'symptomDeveloped': true,
          'testDate': null,
          'testResult': 'Pending',
          'notes': 'Lives in same household, developed fever on Day 3',
        },
        {
          'id': (DateTime.now().millisecondsSinceEpoch + 2).toString(),
          'contactName': 'Visitor Mary',
          'contactId': 'V001',
          'contactPhone': '',
          'contactType': 'Close Contact',
          'exposureDate': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          'exposureLocation': 'Hospital Lobby',
          'exposureDuration': '15-60 min',
          'distance': '1-2 meters',
          'ppeUsed': ['Mask'],
          'riskLevel': 'Low',
          'monitoringStatus': 'Active',
          'symptomDeveloped': false,
          'testDate': null,
          'testResult': '',
          'notes': 'Brief conversation in lobby',
        },
      ];
    });

    _saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Example contact tracing data loaded'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // Show export modal
  void _showExportModal() {
    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No contacts to export'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: SafeArea(
            child: ExportModal(
              onExportPDF: () => _exportAsPDF(),
              onExportExcel: () => _exportAsExcel(),
              onExportCSV: () => _exportAsCSV(),
              onExportText: () => _exportAsText(),
            ),
          ),
        ),
      ),
    );
  }

  // Export as PDF
  Future<void> _exportAsPDF() async {
    Navigator.pop(context);

    final inputs = {
      'Index Case ID': _indexCase?['caseId'] ?? 'N/A',
      'Index Case Name': _indexCase?['caseName'] ?? 'N/A',
      'Diagnosis': _indexCase?['diagnosis'] ?? 'N/A',
      'Total Contacts': _contacts.length.toString(),
    };

    final results = {
      'High Risk Contacts': _getHighRiskCount().toString(),
      'Medium Risk Contacts': _getMediumRiskCount().toString(),
      'Low Risk Contacts': _getLowRiskCount().toString(),
      'Symptomatic Contacts': _getSymptomaticCount().toString(),
      'Tested Contacts': _getTestedCount().toString(),
      'Positive Contacts': _getPositiveCount().toString(),
      'Secondary Attack Rate': _getPositiveCount() > 0
          ? '${(_getPositiveCount() / _contacts.length * 100).toStringAsFixed(1)}%'
          : 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Contact Tracing Report',
      inputs: inputs,
      results: results,
      interpretation: 'Contact tracing completed for ${_contacts.length} contacts. '
          'High-risk contacts require immediate testing and quarantine.',
    );
  }

  // Export as Excel
  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Index Case ID': _indexCase?['caseId'] ?? 'N/A',
      'Index Case Name': _indexCase?['caseName'] ?? 'N/A',
      'Diagnosis': _indexCase?['diagnosis'] ?? 'N/A',
      'Total Contacts': _contacts.length.toString(),
    };

    final results = {
      'High Risk Contacts': _getHighRiskCount().toString(),
      'Medium Risk Contacts': _getMediumRiskCount().toString(),
      'Low Risk Contacts': _getLowRiskCount().toString(),
      'Symptomatic Contacts': _getSymptomaticCount().toString(),
      'Tested Contacts': _getTestedCount().toString(),
      'Positive Contacts': _getPositiveCount().toString(),
      'Secondary Attack Rate': _getPositiveCount() > 0
          ? '${(_getPositiveCount() / _contacts.length * 100).toStringAsFixed(1)}%'
          : 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Contact Tracing Report',
      inputs: inputs,
      results: results,
      interpretation: 'Contact tracing completed for ${_contacts.length} contacts. '
          'High-risk contacts require immediate testing and quarantine.',
    );
  }

  // Export as CSV
  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final csvContent = _generateCSVContent();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'contact_tracing_$timestamp';

    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: filename,
      csvContent: csvContent,
      shareText: 'Contact Tracing Export\nTotal Contacts: ${_contacts.length}\nHigh Risk: ${_getHighRiskCount()}',
    );
  }

  // Export as Text
  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Index Case ID': _indexCase?['caseId'] ?? 'N/A',
      'Index Case Name': _indexCase?['caseName'] ?? 'N/A',
      'Diagnosis': _indexCase?['diagnosis'] ?? 'N/A',
      'Total Contacts': _contacts.length.toString(),
    };

    final results = {
      'High Risk Contacts': _getHighRiskCount().toString(),
      'Medium Risk Contacts': _getMediumRiskCount().toString(),
      'Low Risk Contacts': _getLowRiskCount().toString(),
      'Symptomatic Contacts': _getSymptomaticCount().toString(),
      'Tested Contacts': _getTestedCount().toString(),
      'Positive Contacts': _getPositiveCount().toString(),
      'Secondary Attack Rate': _getPositiveCount() > 0
          ? '${(_getPositiveCount() / _contacts.length * 100).toStringAsFixed(1)}%'
          : 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Contact Tracing Report',
      inputs: inputs,
      results: results,
      interpretation: 'Contact tracing completed for ${_contacts.length} contacts. '
          'High-risk contacts require immediate testing and quarantine.',
    );
  }

  String _generateCSVContent() {
    final buffer = StringBuffer();

    // Index case section
    if (_indexCase != null) {
      buffer.writeln('INDEX CASE INFORMATION');
      buffer.writeln('Case ID,Case Name,Diagnosis,Symptom Onset,Isolation Date');
      buffer.writeln('${_indexCase!['caseId']},${_indexCase!['caseName']},${_indexCase!['diagnosis']},${_formatDate(DateTime.parse(_indexCase!['symptomOnsetDate'] as String))},${_formatDate(DateTime.parse(_indexCase!['isolationDate'] as String))}');
      buffer.writeln('');
    }

    // Contacts section
    buffer.writeln('CONTACT LIST');
    buffer.writeln('Contact Name,Contact ID,Contact Type,Exposure Date,Location,Duration,Distance,PPE Used,Risk Level,Monitoring Status,Symptoms,Test Result,Notes');

    for (final contact in _contacts) {
      buffer.writeln(
        '${contact['contactName']},'
        '${contact['contactId']},'
        '${contact['contactType']},'
        '${_formatDate(DateTime.parse(contact['exposureDate'] as String))},'
        '${contact['exposureLocation']},'
        '${contact['exposureDuration']},'
        '${contact['distance']},'
        '"${(contact['ppeUsed'] as List).join('; ')}",'
        '${contact['riskLevel']},'
        '${contact['monitoringStatus']},'
        '${contact['symptomDeveloped'] ? 'Yes' : 'No'},'
        '${contact['testResult'] ?? ''},'
        '"${contact['notes'] ?? ''}"'
      );
    }

    // Summary statistics
    buffer.writeln('');
    buffer.writeln('SUMMARY STATISTICS');
    buffer.writeln('Total Contacts,${_contacts.length}');
    buffer.writeln('High Risk,${_getHighRiskCount()}');
    buffer.writeln('Medium Risk,${_getMediumRiskCount()}');
    buffer.writeln('Low Risk,${_getLowRiskCount()}');
    buffer.writeln('Symptomatic,${_getSymptomaticCount()}');
    buffer.writeln('Tested,${_getTestedCount()}');
    buffer.writeln('Positive,${_getPositiveCount()}');
    if (_getPositiveCount() > 0) {
      buffer.writeln('Secondary Attack Rate,${(_getPositiveCount() / _contacts.length * 100).toStringAsFixed(1)}%');
    }

    return buffer.toString();
  }
}
