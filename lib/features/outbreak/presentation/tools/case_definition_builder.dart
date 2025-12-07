import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../../../../core/design/design_tokens.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';

class CaseDefinitionBuilder extends StatefulWidget {
  const CaseDefinitionBuilder({super.key});

  @override
  State<CaseDefinitionBuilder> createState() => _CaseDefinitionBuilderState();
}

class _CaseDefinitionBuilderState extends State<CaseDefinitionBuilder> {
  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'A standardized framework for classifying cases during outbreak investigations. Case definitions establish clear criteria for identifying suspected, probable, and confirmed cases based on clinical, laboratory, and epidemiological characteristics.',
    example: 'COVID-19 outbreak: Suspected = fever + respiratory symptoms + exposure; Probable = suspected + epidemiological link; Confirmed = lab-confirmed SARS-CoV-2.',
    interpretation: 'Clear case definitions ensure consistent case identification, enable accurate outbreak size estimation, and facilitate comparison across settings. Definitions should be sensitive enough to capture all potential cases while specific enough to exclude non-cases.',
    whenUsed: 'Step 2-3 of outbreak investigation (case definition and case finding). Essential for establishing surveillance criteria, guiding laboratory testing, and determining outbreak scope.',
    inputDataType: 'Clinical criteria (symptoms, signs), laboratory criteria (test results), epidemiological criteria (time, place, person), and case classification levels (suspected, probable, confirmed).',
    references: [
      Reference(
        title: 'CDC Outbreak Investigation Guidelines',
        url: 'https://www.cdc.gov/eis/field-epi-manual/chapters/Defining-Outbreak.html',
      ),
      Reference(
        title: 'WHO Outbreak Investigation Toolkit',
        url: 'https://www.who.int/emergencies/outbreak-toolkit/disease-outbreak-toolboxes',
      ),
      Reference(
        title: 'APIC Outbreak Investigation Guide',
        url: 'https://apic.org/Resource_/TinyMceFileManager/Advocacy-PDFs/APIC_Outbreak_Investigation_Guide.pdf',
      ),
    ],
  );

  // Case ID for tracking
  final _caseIdController = TextEditingController();

  // Text controllers for "Other" fields
  final _personOtherController = TextEditingController();
  final _placeOtherController = TextEditingController();
  final _symptomsOtherController = TextEditingController();
  final _labOtherController = TextEditingController();
  final _epiLinkOtherController = TextEditingController();

  // Criteria selections
  final Map<String, bool> _personCriteria = {
    'Age 18-65 years': false,
    'Age >65 years': false,
    'Healthcare worker': false,
    'Immunocompromised': false,
    'Pregnant': false,
    'Other (specify)': false,
  };

  final Map<String, bool> _placeCriteria = {
    'ICU': false,
    'Medical ward': false,
    'Emergency department': false,
    'Outpatient clinic': false,
    'Community': false,
    'Other (specify)': false,
  };

  final Map<String, bool> _timeCriteria = {
    'Onset during outbreak period': false,
    'Onset within 14 days of exposure': false,
    'Symptom onset documented': false,
  };

  final Map<String, bool> _symptomsCriteria = {
    'Fever (≥38°C)': false,
    'Cough': false,
    'Shortness of breath': false,
    'Diarrhea': false,
    'Vomiting': false,
    'Headache': false,
    'Fatigue': false,
    'Loss of taste/smell': false,
    'Other (specify)': false,
  };

  final Map<String, bool> _labCriteria = {
    'PCR positive': false,
    'Culture positive': false,
    'Antigen positive': false,
    'Lab pending': false,
    'Lab negative': false,
    'Other (specify)': false,
  };

  final Map<String, bool> _epiLinkCriteria = {
    'Close contact with confirmed case': false,
    'Exposure to common source': false,
    'Part of outbreak cluster': false,
    'Travel to affected area': false,
    'Other (specify)': false,
  };

  // UI state
  String? _errorMessage;

  bool _personExpanded = true;
  bool _placeExpanded = false;
  bool _timeExpanded = false;
  bool _symptomsExpanded = false;
  bool _labExpanded = false;
  bool _epiLinkExpanded = false;

  @override
  void dispose() {
    _caseIdController.dispose();
    _personOtherController.dispose();
    _placeOtherController.dispose();
    _symptomsOtherController.dispose();
    _labOtherController.dispose();
    _epiLinkOtherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Definition Builder'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // Intro Panel
            _buildIntroPanel(),
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
            const SizedBox(height: 12),

            // Export Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showExportModal,
                icon: const Icon(Icons.file_download_outlined, size: 20),
                label: const Text(
                  'Export Case Definition',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Case ID Input
            _buildCaseIdInput(),
            const SizedBox(height: 20),

            // Criteria Cards
            _buildCriteriaCard(
              'Person',
              Icons.person,
              _personCriteria,
              _personExpanded,
              (expanded) => setState(() => _personExpanded = expanded),
              otherController: _personOtherController,
            ),
            const SizedBox(height: 16),

            _buildCriteriaCard(
              'Place',
              Icons.location_on,
              _placeCriteria,
              _placeExpanded,
              (expanded) => setState(() => _placeExpanded = expanded),
              otherController: _placeOtherController,
            ),
            const SizedBox(height: 16),

            _buildCriteriaCard(
              'Time',
              Icons.schedule,
              _timeCriteria,
              _timeExpanded,
              (expanded) => setState(() => _timeExpanded = expanded),
            ),
            const SizedBox(height: 16),

            _buildCriteriaCard(
              'Symptoms',
              Icons.medical_services,
              _symptomsCriteria,
              _symptomsExpanded,
              (expanded) => setState(() => _symptomsExpanded = expanded),
              otherController: _symptomsOtherController,
            ),
            const SizedBox(height: 16),

            _buildCriteriaCard(
              'Lab Results',
              Icons.science,
              _labCriteria,
              _labExpanded,
              (expanded) => setState(() => _labExpanded = expanded),
              otherController: _labOtherController,
            ),
            const SizedBox(height: 16),

            _buildCriteriaCard(
              'Epidemiological Link',
              Icons.link,
              _epiLinkCriteria,
              _epiLinkExpanded,
              (expanded) => setState(() => _epiLinkExpanded = expanded),
              otherController: _epiLinkOtherController,
            ),
            const SizedBox(height: 20),

            // Classification Panel
            _buildClassificationPanel(),
            const SizedBox(height: 20),

            // Summary Panel
             _buildSummaryPanel(),
             const SizedBox(height: 20),

            // Error Message
             if (_errorMessage != null) ...[
               _buildErrorMessage(),
               const SizedBox(height: 20),
             ],

            // Actions Row
             _buildActionsRow(),
             const SizedBox(height: 20),

            // References
             _buildReferences(),
            ],
          ),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Case Definition Builder',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Define suspected, probable, or confirmed cases step by step',
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

  Widget _buildIntroPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Use standardized epidemiological criteria to classify cases during an outbreak. Select applicable criteria and the tool will automatically determine case status.',
              style: TextStyle(
                color: AppColors.info,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseIdInput() {
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
          Text(
            'Case Identification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _caseIdController,
            decoration: const InputDecoration(
              labelText: 'Case ID (optional)',
              hintText: 'e.g., CASE-001, Patient-123',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaCard(
    String title,
    IconData icon,
    Map<String, bool> criteria,
    bool isExpanded,
    Function(bool) onExpansionChanged, {
    TextEditingController? otherController,
  }) {
    final selectedCount = criteria.values.where((v) => v).length;

    return Container(
      width: double.infinity,
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
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        subtitle: selectedCount > 0
          ? Text(
              '$selectedCount selected',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.success,
              ),
            )
          : null,
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: criteria.entries.map((entry) {
                final isOther = entry.key.startsWith('Other (specify)');

                if (isOther && otherController != null) {
                  // Special handling for "Other (specify)" with text field
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: entry.value,
                        onChanged: (value) {
                          setState(() {
                            criteria[entry.key] = value ?? false;
                            _errorMessage = null;
                            if (!(value ?? false)) {
                              otherController.clear();
                            }
                          });
                        },
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (entry.value) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 48, top: 8, bottom: 8),
                          child: TextField(
                            controller: otherController,
                            decoration: InputDecoration(
                              hintText: 'Specify details...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ],
                  );
                } else {
                  // Regular checkbox
                  return CheckboxListTile(
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 14),
                    ),
                    value: entry.value,
                    onChanged: (value) {
                      setState(() {
                        criteria[entry.key] = value ?? false;
                        _errorMessage = null;
                      });
                    },
                    activeColor: AppColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationPanel() {
    final classification = _determineClassification();
    final rationale = _getClassificationRationale(classification);

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
              Icon(Icons.assignment_turned_in, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Case Classification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Classification Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getClassificationColor(classification).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getClassificationColor(classification),
                width: 2,
              ),
            ),
            child: Text(
              classification,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getClassificationColor(classification),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Rationale
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rationale:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rationale,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel() {
    final selectedCriteria = <String>[];

    _personCriteria.forEach((key, value) {
      if (value) selectedCriteria.add('Person: $key');
    });
    _placeCriteria.forEach((key, value) {
      if (value) selectedCriteria.add('Place: $key');
    });
    _timeCriteria.forEach((key, value) {
      if (value) selectedCriteria.add('Time: $key');
    });
    _symptomsCriteria.forEach((key, value) {
      if (value) selectedCriteria.add('Symptoms: $key');
    });
    _labCriteria.forEach((key, value) {
      if (value) selectedCriteria.add('Lab: $key');
    });
    _epiLinkCriteria.forEach((key, value) {
      if (value) selectedCriteria.add('Epi-link: $key');
    });

    if (selectedCriteria.isEmpty) {
      return const SizedBox.shrink();
    }

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
              Icon(Icons.summarize, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Selected Criteria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedCriteria.map((criteria) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  criteria,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    final hasMinimumCriteria = _hasMinimumCriteria();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: hasMinimumCriteria ? _saveCase : null,
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferences() {
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
              Icon(Icons.library_books, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'References',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildReferenceButton(
                'WHO - Case Definition in Outbreak Investigation',
                'https://www.who.int/emergencies/outbreak-toolkit/disease-outbreak-toolboxes',
              ),
              _buildReferenceButton(
                'CDC - Principles of Outbreak Case Classification',
                'https://www.cdc.gov/csels/dsepd/ss1978/lesson1/section5.html',
              ),
              _buildReferenceButton(
                'GDIPC/Weqaya - National Outbreak Reporting Standards',
                'https://www.gdipc.org',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceButton(String title, String url) {
    return OutlinedButton.icon(
      onPressed: () => _launchURL(url),
      icon: const Icon(Icons.open_in_new, size: 16),
      label: Text(
        title,
        style: const TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // Classification logic
  String _determineClassification() {
    final hasSymptoms = _symptomsCriteria.values.any((v) => v);
    final hasPersonTime = (_personCriteria.values.any((v) => v) ||
                          _placeCriteria.values.any((v) => v)) &&
                         _timeCriteria.values.any((v) => v);
    final hasLabPositive = _labCriteria['PCR positive'] == true ||
                          _labCriteria['Culture positive'] == true ||
                          _labCriteria['Antigen positive'] == true;
    final hasEpiLink = _epiLinkCriteria.values.any((v) => v);

    // Classification logic
    if (hasLabPositive) {
      return 'Confirmed';
    } else if (hasSymptoms && hasPersonTime && hasEpiLink) {
      return 'Probable';
    } else if (hasSymptoms && hasPersonTime) {
      return 'Suspected';
    } else {
      return 'Not Classified';
    }
  }

  String _getClassificationRationale(String classification) {
    switch (classification) {
      case 'Confirmed':
        return 'Laboratory confirmation (PCR/Culture/Antigen positive) regardless of other criteria.';
      case 'Probable':
        return 'Clinical symptoms + person/place/time criteria + epidemiological link, but no lab confirmation.';
      case 'Suspected':
        return 'Clinical symptoms + person/place/time criteria, but no epidemiological link or lab confirmation.';
      default:
        return 'Insufficient criteria selected. Minimum: symptoms + person/place/time criteria required.';
    }
  }

  Color _getClassificationColor(String classification) {
    switch (classification) {
      case 'Confirmed':
        return AppColors.success;
      case 'Probable':
        return AppColors.warning;
      case 'Suspected':
        return const Color(0xFFECC94B); // Yellow
      default:
        return AppColors.textSecondary;
    }
  }

  bool _hasMinimumCriteria() {
    final hasSymptoms = _symptomsCriteria.values.any((v) => v);
    final hasPersonOrPlace = _personCriteria.values.any((v) => v) ||
                            _placeCriteria.values.any((v) => v);
    final hasTime = _timeCriteria.values.any((v) => v);

    return hasSymptoms && hasPersonOrPlace && hasTime;
  }

  // Action methods
  Future<void> _saveCase() async {
    if (!_hasMinimumCriteria()) {
      setState(() {
        _errorMessage = 'Please select minimum criteria: symptoms + person/place/time';
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('case_definition_history') ?? [];

      final caseData = {
        'timestamp': DateTime.now().toIso8601String(),
        'caseId': _caseIdController.text.trim().isEmpty
          ? 'CASE-${DateTime.now().millisecondsSinceEpoch}'
          : _caseIdController.text.trim(),
        'classification': _determineClassification(),
        'personCriteria': _personCriteria,
        'placeCriteria': _placeCriteria,
        'timeCriteria': _timeCriteria,
        'symptomsCriteria': _symptomsCriteria,
        'labCriteria': _labCriteria,
        'epiLinkCriteria': _epiLinkCriteria,
        'personOther': _personOtherController.text.trim(),
        'placeOther': _placeOtherController.text.trim(),
        'symptomsOther': _symptomsOtherController.text.trim(),
        'labOther': _labOtherController.text.trim(),
        'epiLinkOther': _epiLinkOtherController.text.trim(),
      };

      history.add(jsonEncode(caseData));
      await prefs.setStringList('case_definition_history', history);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Case definition saved to history'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  void _clearAll() {
    setState(() {
      _caseIdController.clear();
      _personOtherController.clear();
      _placeOtherController.clear();
      _symptomsOtherController.clear();
      _labOtherController.clear();
      _epiLinkOtherController.clear();
      _personCriteria.updateAll((key, value) => false);
      _placeCriteria.updateAll((key, value) => false);
      _timeCriteria.updateAll((key, value) => false);
      _symptomsCriteria.updateAll((key, value) => false);
      _labCriteria.updateAll((key, value) => false);
      _epiLinkCriteria.updateAll((key, value) => false);
      _errorMessage = null;

      // Reset expansion states
      _personExpanded = true;
      _placeExpanded = false;
      _timeExpanded = false;
      _symptomsExpanded = false;
      _labExpanded = false;
      _epiLinkExpanded = false;
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showQuickGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Guide',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: KnowledgePanelWidget(data: _knowledgePanelData),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportModal() {
    if (_caseIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Case ID before exporting'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: SafeArea(
            child: ExportModal(
              onExportPDF: _exportAsPDF,
              onExportExcel: _exportAsExcel,
              onExportCSV: _exportAsCSV,
              onExportText: _exportAsText,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    Navigator.pop(context);

    final inputs = {
      'Case ID': _caseIdController.text,
      'Person Criteria': _getSelectedCriteria(_personCriteria, _personOtherController),
      'Place Criteria': _getSelectedCriteria(_placeCriteria, _placeOtherController),
      'Time Criteria': _getSelectedCriteria(_timeCriteria, null),
      'Symptoms': _getSelectedCriteria(_symptomsCriteria, _symptomsOtherController),
      'Laboratory Criteria': _getSelectedCriteria(_labCriteria, _labOtherController),
      'Epidemiological Link': _getSelectedCriteria(_epiLinkCriteria, _epiLinkOtherController),
    };

    final results = {
      'Case Classification': _getCaseClassification(),
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Case Definition Builder',
      inputs: inputs,
      results: results,
      interpretation: 'Case definition established based on WHO/CDC outbreak investigation guidelines. '
          'Classification: ${_getCaseClassification()}',
    );
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Case ID': _caseIdController.text,
      'Person Criteria': _getSelectedCriteria(_personCriteria, _personOtherController),
      'Place Criteria': _getSelectedCriteria(_placeCriteria, _placeOtherController),
      'Time Criteria': _getSelectedCriteria(_timeCriteria, null),
      'Symptoms': _getSelectedCriteria(_symptomsCriteria, _symptomsOtherController),
      'Laboratory Criteria': _getSelectedCriteria(_labCriteria, _labOtherController),
      'Epidemiological Link': _getSelectedCriteria(_epiLinkCriteria, _epiLinkOtherController),
    };

    final results = {
      'Case Classification': _getCaseClassification(),
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Case Definition Builder',
      inputs: inputs,
      results: results,
      interpretation: 'Case definition established based on WHO/CDC outbreak investigation guidelines. '
          'Classification: ${_getCaseClassification()}',
    );
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final inputs = {
      'Case ID': _caseIdController.text,
      'Person Criteria': _getSelectedCriteria(_personCriteria, _personOtherController),
      'Place Criteria': _getSelectedCriteria(_placeCriteria, _placeOtherController),
      'Time Criteria': _getSelectedCriteria(_timeCriteria, null),
      'Symptoms': _getSelectedCriteria(_symptomsCriteria, _symptomsOtherController),
      'Laboratory Criteria': _getSelectedCriteria(_labCriteria, _labOtherController),
      'Epidemiological Link': _getSelectedCriteria(_epiLinkCriteria, _epiLinkOtherController),
    };

    final results = {
      'Case Classification': _getCaseClassification(),
    };

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Case Definition Builder',
      inputs: inputs,
      results: results,
      interpretation: 'Case definition established based on WHO/CDC outbreak investigation guidelines. '
          'Classification: ${_getCaseClassification()}',
    );
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Case ID': _caseIdController.text,
      'Person Criteria': _getSelectedCriteria(_personCriteria, _personOtherController),
      'Place Criteria': _getSelectedCriteria(_placeCriteria, _placeOtherController),
      'Time Criteria': _getSelectedCriteria(_timeCriteria, null),
      'Symptoms': _getSelectedCriteria(_symptomsCriteria, _symptomsOtherController),
      'Laboratory Criteria': _getSelectedCriteria(_labCriteria, _labOtherController),
      'Epidemiological Link': _getSelectedCriteria(_epiLinkCriteria, _epiLinkOtherController),
    };

    final results = {
      'Case Classification': _getCaseClassification(),
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Case Definition Builder',
      inputs: inputs,
      results: results,
      interpretation: 'Case definition established based on WHO/CDC outbreak investigation guidelines. '
          'Classification: ${_getCaseClassification()}',
    );
  }

  String _getSelectedCriteria(Map<String, bool> criteria, TextEditingController? otherController) {
    final selected = criteria.entries
        .where((e) => e.value)
        .map((e) {
          if (e.key == 'Other (specify)' && otherController != null && otherController.text.isNotEmpty) {
            return '${e.key}: ${otherController.text}';
          }
          return e.key;
        })
        .toList();
    return selected.isEmpty ? 'None' : selected.join(', ');
  }

  String _getCaseClassification() {
    final hasLab = _labCriteria['PCR positive'] == true ||
        _labCriteria['Culture positive'] == true ||
        _labCriteria['Antigen positive'] == true;

    final hasSymptoms = _symptomsCriteria.values.any((v) => v);
    final hasEpiLink = _epiLinkCriteria.values.any((v) => v);

    if (hasLab) {
      return 'Confirmed Case';
    } else if (hasSymptoms && hasEpiLink) {
      return 'Probable Case';
    } else if (hasSymptoms || hasEpiLink) {
      return 'Suspected Case';
    } else {
      return 'Insufficient Criteria';
    }
  }

  void _loadExample() {
    setState(() {
      _caseIdController.text = 'CASE-2024-001';

      // Example: Confirmed COVID-19 case
      _personCriteria['Age 18-65 years'] = true;
      _personCriteria['Healthcare worker'] = true;

      _placeCriteria['ICU'] = true;

      _timeCriteria['Onset during outbreak period'] = true;
      _timeCriteria['Symptom onset documented'] = true;

      _symptomsCriteria['Fever (≥38°C)'] = true;
      _symptomsCriteria['Cough'] = true;
      _symptomsCriteria['Shortness of breath'] = true;
      _symptomsCriteria['Fatigue'] = true;

      _labCriteria['PCR positive'] = true;

      _epiLinkCriteria['Close contact with confirmed case'] = true;
      _epiLinkCriteria['Part of outbreak cluster'] = true;

      // Expand relevant sections
      _personExpanded = true;
      _placeExpanded = true;
      _timeExpanded = true;
      _symptomsExpanded = true;
      _labExpanded = true;
      _epiLinkExpanded = true;

      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Example case definition loaded successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
