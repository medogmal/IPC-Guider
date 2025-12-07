import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/back_button.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../../features/outbreak/data/repositories/history_repository.dart';
import '../../../../../features/outbreak/data/models/history_entry.dart';
import '../../../data/models/bundle_tool_enums.dart';
import '../../../data/models/bundle_element_compliance.dart';
import '../../../data/models/bundle_audit_record.dart';
import '../../../domain/bundle_tool_constants.dart';
import '../../widgets/tools/bundle_tool_header.dart';
import '../../widgets/tools/bundle_tool_input_card.dart';
import '../../widgets/tools/bundle_tool_result_card.dart';
import '../../widgets/tools/bundle_element_checklist.dart';
import '../../widgets/tools/bundle_barrier_selector.dart';
import '../../widgets/tools/bundle_compliance_gauge.dart';

/// Unified Bundle Audit Tool - Element-level compliance tracking
class BundleAuditToolScreen extends StatefulWidget {
  const BundleAuditToolScreen({super.key});

  @override
  State<BundleAuditToolScreen> createState() => _BundleAuditToolScreenState();
}

class _BundleAuditToolScreenState extends State<BundleAuditToolScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Input controllers
  final _auditDateController = TextEditingController();
  final _unitController = TextEditingController();
  final _auditorController = TextEditingController();
  final _patientIdController = TextEditingController();
  
  // State variables
  BundleType? _selectedBundleType;
  Map<String, ComplianceStatus> _elementStatuses = {};
  List<BundleBarrier> _selectedBarriers = [];
  String _otherBarrierText = '';
  BundleAuditRecord? _auditResult;
  
  @override
  void initState() {
    super.initState();
    // Set default audit date to today
    _auditDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
  
  @override
  void dispose() {
    _auditDateController.dispose();
    _unitController.dispose();
    _auditorController.dispose();
    _patientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Bundle Audit Tool',
        fitTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.medium,
            AppSpacing.medium,
            AppSpacing.large, // Bottom padding for mobile
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              BundleToolHeader(
                title: 'Bundle Audit Tool',
                description: 'Element-level compliance tracking for all bundle types',
                icon: Icons.checklist_outlined,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.medium),

              // Quick Guide button
              _buildQuickGuideButton(),
              const SizedBox(height: AppSpacing.medium),

              // Load Example button
              _buildLoadExampleButton(),
              const SizedBox(height: AppSpacing.large),
              
              // Bundle Type Selection
              BundleToolInputCard(
                title: 'Bundle Type',
                icon: Icons.category_outlined,
                isRequired: true,
                child: DropdownButtonFormField<BundleType>(
                  decoration: const InputDecoration(
                    hintText: 'Select bundle type',
                    border: OutlineInputBorder(),
                  ),
                  items: BundleType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.shortName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBundleType = value;
                      _elementStatuses.clear();
                      _auditResult = null;
                    });
                  },
                  validator: (value) => value == null ? 'Please select bundle type' : null,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              
              // Audit Details
              if (_selectedBundleType != null) ...[
                BundleToolInputCard(
                  title: 'Audit Details',
                  icon: Icons.info_outlined,
                  isRequired: true,
                  child: Column(
                    children: [
                      // Audit Date
                      TextFormField(
                        controller: _auditDateController,
                        decoration: InputDecoration(
                          labelText: 'Audit Date',
                          hintText: 'Select date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.edit_calendar),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                _auditDateController.text = DateFormat('yyyy-MM-dd').format(date);
                              }
                            },
                          ),
                        ),
                        readOnly: true,
                        validator: (value) => value?.isEmpty ?? true ? 'Please select date' : null,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      
                      // Unit/Location
                      TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit/Location',
                          hintText: 'e.g., ICU, Medical Ward',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 100,
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter unit' : null,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      
                      // Auditor Name
                      TextFormField(
                        controller: _auditorController,
                        decoration: const InputDecoration(
                          labelText: 'Auditor Name',
                          hintText: 'e.g., Dr. Smith',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 100,
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter auditor name' : null,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      
                      // Patient ID (Optional)
                      TextFormField(
                        controller: _patientIdController,
                        decoration: const InputDecoration(
                          labelText: 'Patient ID / Case ID (Optional)',
                          hintText: 'For privacy, use anonymized ID',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 50,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                
                // Bundle Elements Checklist
                BundleToolInputCard(
                  title: 'Bundle Elements',
                  icon: Icons.checklist,
                  isRequired: true,
                  child: BundleElementChecklist(
                    bundleType: _selectedBundleType!,
                    elementStatuses: _elementStatuses,
                    onChanged: (elementId, status) {
                      setState(() {
                        _elementStatuses[elementId] = status;
                        _auditResult = null;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                
                // Barriers to Compliance
                BundleToolInputCard(
                  title: 'Barriers to Compliance',
                  icon: Icons.block_outlined,
                  child: BundleBarrierSelector(
                    selectedBarriers: _selectedBarriers,
                    onChanged: (barriers) {
                      setState(() {
                        _selectedBarriers = barriers;
                        _auditResult = null;
                      });
                    },
                    otherBarrierText: _otherBarrierText,
                    onOtherBarrierChanged: (text) {
                      setState(() {
                        _otherBarrierText = text;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                
                // Calculate Button
                FilledButton.icon(
                  onPressed: _calculateCompliance,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculate Compliance'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
              
              // Results
              if (_auditResult != null) ...[
                const SizedBox(height: AppSpacing.large),
                _buildResultsSection(),
                const SizedBox(height: AppSpacing.large), // Extra bottom padding after results
              ],

              // References (always visible)
              const SizedBox(height: AppSpacing.large),
              _buildReferencesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickGuideButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showQuickGuide,
        icon: Icon(Icons.menu_book, color: AppColors.info),
        label: Text(
          'Quick Guide',
          style: TextStyle(
            color: AppColors.info,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppColors.info, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadExampleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loadExampleData,
        icon: Icon(Icons.lightbulb_outline, color: AppColors.success),
        label: Text(
          'Load Example Data',
          style: TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppColors.success, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_auditResult == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Overall Compliance Score
        BundleToolResultCard(
          title: 'Audit Results',
          icon: Icons.assessment_outlined,
          color: _getComplianceColor(_auditResult!.complianceScore),
          child: Column(
            children: [
              // Gauge
              Center(
                child: BundleComplianceGauge(
                  score: _auditResult!.complianceScore,
                  size: 150,
                ),
              ),
              const SizedBox(height: AppSpacing.large),

              // Element Breakdown
              _buildElementBreakdown(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),

        // Element-Level Details
        _buildElementDetailsCard(),
        const SizedBox(height: AppSpacing.medium),

        // Interpretation
        _buildInterpretationCard(),
        const SizedBox(height: AppSpacing.medium),

        // Benchmark Comparison
        _buildBenchmarkCard(),
        const SizedBox(height: AppSpacing.medium),

        // Recommendations
        _buildRecommendationsCard(),
        const SizedBox(height: AppSpacing.large),

        // Action Buttons (Save & Export)
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveToHistory,
            icon: const Icon(Icons.save, size: 20),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showExportModal,
            icon: Icon(Icons.file_download, size: 20, color: AppColors.primary),
            label: Text('Export', style: TextStyle(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildElementBreakdown() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutralLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Element Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          _buildBreakdownRow(
            'Compliant',
            _auditResult!.compliantCount,
            _auditResult!.elements.length,
            AppColors.success,
          ),
          _buildBreakdownRow(
            'Non-Compliant',
            _auditResult!.nonCompliantCount,
            _auditResult!.elements.length,
            AppColors.error,
          ),
          _buildBreakdownRow(
            'Not Applicable',
            _auditResult!.notApplicableCount,
            _auditResult!.elements.length,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int count, int total, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '$count / $total',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt_outlined, color: AppColors.info),
                const SizedBox(width: AppSpacing.small),
                const Text(
                  'Element-Level Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ..._auditResult!.elements.map((element) {
              final statusColor = element.status == ComplianceStatus.compliant
                  ? AppColors.success
                  : element.status == ComplianceStatus.nonCompliant
                      ? AppColors.error
                      : AppColors.warning;

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.small),
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      element.status == ComplianceStatus.compliant
                          ? Icons.check_circle
                          : element.status == ComplianceStatus.nonCompliant
                              ? Icons.cancel
                              : Icons.help_outline,
                      color: statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            element.elementName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (element.notes != null && element.notes!.isNotEmpty)
                            Text(
                              element.notes!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        element.status.shortLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInterpretationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights_outlined, color: AppColors.info),
                const SizedBox(width: AppSpacing.small),
                const Text(
                  'Interpretation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              _auditResult!.interpretation,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenchmarkCard() {
    final target = BundleToolConstants.complianceTargets[_selectedBundleType!] ?? 95.0;
    final score = _auditResult!.complianceScore;
    final meetsTarget = score >= target;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_outlined, color: AppColors.info),
                const SizedBox(width: AppSpacing.small),
                const Text(
                  'Benchmark Comparison',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Table(
              border: TableBorder.all(
                color: AppColors.neutralLight,
                width: 1,
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: AppColors.neutralLight.withValues(alpha: 0.3),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Metric',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Value',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                _buildTableRow('Your Score', '${score.toStringAsFixed(1)}%'),
                _buildTableRow('Target', '${target.toStringAsFixed(0)}%'),
                _buildTableRow(
                  'Status',
                  meetsTarget ? '✅ Meets Target' : '❌ Below Target',
                ),
                _buildTableRow(
                  'Gap',
                  meetsTarget
                      ? '+${(score - target).toStringAsFixed(1)}%'
                      : '${(score - target).toStringAsFixed(1)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.warning),
                const SizedBox(width: AppSpacing.small),
                const Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            ..._auditResult!.recommendations.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReferencesSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'References',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildReferenceItem(
              'CDC. Central Line-Associated Bloodstream Infection (CLABSI) Prevention',
              'https://www.cdc.gov/hai/bsi/bsi.html',
            ),
            const SizedBox(height: AppSpacing.small),
            _buildReferenceItem(
              'WHO. Guidelines on Core Components of IPC Programmes',
              'https://www.who.int/publications/i/item/9789241549929',
            ),
            const SizedBox(height: AppSpacing.small),
            _buildReferenceItem(
              'APIC. Implementation Guide: Bundle Compliance',
              'https://apic.org/resources/',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceItem(String title, String url) {
    return InkWell(
      onTap: () {
        // Open URL in browser
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  void _calculateCompliance() {
    if (!_formKey.currentState!.validate()) return;
    
    // Check if all elements have been assessed
    final elements = BundleToolConstants.getElementsForBundle(_selectedBundleType!);
    if (_elementStatuses.length < elements.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assess all bundle elements'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    // Create element compliance list
    final elementComplianceList = elements.map((element) {
      return BundleElementCompliance(
        elementId: element.id,
        elementName: element.name,
        elementDescription: element.description,
        status: _elementStatuses[element.id]!,
      );
    }).toList();
    
    // Calculate audit record
    final auditRecord = BundleAuditRecord.calculate(
      auditDate: DateFormat('yyyy-MM-dd').parse(_auditDateController.text),
      bundleType: _selectedBundleType!,
      unitLocation: _unitController.text,
      auditorName: _auditorController.text,
      patientId: _patientIdController.text.isEmpty ? null : _patientIdController.text,
      elements: elementComplianceList,
      barriers: _selectedBarriers,
      otherBarrier: _selectedBarriers.contains(BundleBarrier.other) ? _otherBarrierText : null,
    );
    
    setState(() {
      _auditResult = auditRecord;
    });
    
    // Auto-save to history
    _saveToHistory();
  }

  void _loadExampleData() {
    // Context-aware example loading based on currently selected bundle type
    final bundleType = _selectedBundleType ?? BundleType.clabsi;

    setState(() {
      // Set bundle type if not already selected
      _selectedBundleType = bundleType;

      // Common fields
      _unitController.text = 'ICU';
      _auditorController.text = 'Dr. Sarah Johnson';
      _patientIdController.text = 'PT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Set example compliance statuses based on bundle type
      final elements = BundleToolConstants.getElementsForBundle(bundleType);
      _elementStatuses.clear();

      // Context-specific examples for each bundle type
      switch (bundleType) {
        case BundleType.clabsi:
          // CLABSI: 4/5 compliant (missing chlorhexidine)
          _elementStatuses = {
            elements[0].id: ComplianceStatus.compliant, // Hand Hygiene
            elements[1].id: ComplianceStatus.compliant, // Maximal Barrier
            elements[2].id: ComplianceStatus.nonCompliant, // Chlorhexidine
            elements[3].id: ComplianceStatus.compliant, // Optimal Site
            elements[4].id: ComplianceStatus.compliant, // Daily Review
          };
          _selectedBarriers = [BundleBarrier.resourceUnavailability];
          break;

        case BundleType.cauti:
          // CAUTI: 5/6 compliant (missing daily review)
          _elementStatuses = {
            elements[0].id: ComplianceStatus.compliant, // Appropriate Indication
            elements[1].id: ComplianceStatus.compliant, // Hand Hygiene
            elements[2].id: ComplianceStatus.compliant, // Aseptic Technique
            elements[3].id: ComplianceStatus.compliant, // Secure Catheter
            elements[4].id: ComplianceStatus.compliant, // Closed Drainage
            elements[5].id: ComplianceStatus.nonCompliant, // Daily Review
          };
          _selectedBarriers = [BundleBarrier.workflowIssue];
          break;

        case BundleType.vap:
          // VAP: 5/7 compliant (missing HOB elevation and SBT)
          _elementStatuses = {
            elements[0].id: ComplianceStatus.compliant, // Hand Hygiene
            elements[1].id: ComplianceStatus.nonCompliant, // HOB Elevation
            elements[2].id: ComplianceStatus.compliant, // Oral Care
            elements[3].id: ComplianceStatus.compliant, // Sedation Vacation
            elements[4].id: ComplianceStatus.nonCompliant, // SBT
            elements[5].id: ComplianceStatus.compliant, // DVT Prophylaxis
            elements[6].id: ComplianceStatus.compliant, // PUD Prophylaxis
          };
          _selectedBarriers = [BundleBarrier.knowledgeGap, BundleBarrier.timeConstraint];
          break;

        case BundleType.ssi:
          // SSI: 6/7 compliant (missing antibiotic timing)
          _elementStatuses = {
            elements[0].id: ComplianceStatus.compliant, // Preop Shower
            elements[1].id: ComplianceStatus.compliant, // Hair Removal
            elements[2].id: ComplianceStatus.nonCompliant, // Antibiotic Timing
            elements[3].id: ComplianceStatus.compliant, // Skin Antisepsis
            elements[4].id: ComplianceStatus.compliant, // Normothermia
            elements[5].id: ComplianceStatus.compliant, // Glucose Control
            elements[6].id: ComplianceStatus.compliant, // Wound Protection
          };
          _selectedBarriers = [BundleBarrier.communicationBreakdown];
          break;

        case BundleType.sepsis:
          // Sepsis: 4/5 compliant (missing fluid resuscitation)
          _elementStatuses = {
            elements[0].id: ComplianceStatus.compliant, // Lactate Measurement
            elements[1].id: ComplianceStatus.compliant, // Blood Cultures
            elements[2].id: ComplianceStatus.compliant, // Antibiotics
            elements[3].id: ComplianceStatus.nonCompliant, // Fluid Resuscitation
            elements[4].id: ComplianceStatus.compliant, // Vasopressors
          };
          _selectedBarriers = [BundleBarrier.timeConstraint];
          break;
      }

      _auditResult = null;
    });

    // Show context-specific message
    String exampleDescription;
    switch (bundleType) {
      case BundleType.clabsi:
        exampleDescription = 'CLABSI Bundle: 4/5 compliant (missing chlorhexidine antisepsis)';
        break;
      case BundleType.cauti:
        exampleDescription = 'CAUTI Bundle: 5/6 compliant (missing daily necessity review)';
        break;
      case BundleType.vap:
        exampleDescription = 'VAP Bundle: 5/7 compliant (missing HOB elevation and SBT)';
        break;
      case BundleType.ssi:
        exampleDescription = 'SSI Bundle: 6/7 compliant (missing antibiotic timing)';
        break;
      case BundleType.sepsis:
        exampleDescription = 'Sepsis Bundle: 4/5 compliant (missing fluid resuscitation)';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded: $exampleDescription'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutralLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: const KnowledgePanelWidget(
                    data: KnowledgePanelData(
                      definition: 'Bundle Audit Tool enables systematic assessment of bundle compliance at the element level, helping identify specific gaps and barriers to implementation.',
                      example: 'Example: Audit a CLABSI bundle implementation in ICU, identifying that chlorhexidine skin antisepsis was missed due to supply shortage.',
                      interpretation: 'Compliance ≥95% indicates excellent adherence. Scores <95% require targeted interventions based on identified barriers.',
                      whenUsed: 'Use for routine bundle audits, quality improvement initiatives, and identifying training needs.',
                      inputDataType: 'Bundle type, audit date, unit location, auditor name, element-level compliance status, and barriers encountered.',
                      references: [],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportModal() {
    ExportModal.show(
      context: context,
      onExportPDF: _exportAsPDF,
      onExportExcel: _exportAsExcel,
      onExportCSV: _exportAsExcel, // CSV uses same format as Excel
      onExportText: _exportAsText,
      enablePhoto: false,
    );
  }

  Future<void> _exportAsPDF() async {
    Navigator.pop(context);

    if (_auditResult == null) return;

    // Prepare inputs
    final inputs = {
      'Bundle Type': _selectedBundleType!.shortName,
      'Audit Date': _auditDateController.text,
      'Unit/Location': _unitController.text,
      'Auditor Name': _auditorController.text,
      if (_patientIdController.text.isNotEmpty)
        'Patient ID': _patientIdController.text,
    };

    // Prepare results
    final results = {
      'Compliance Score': '${_auditResult!.complianceScore.toStringAsFixed(1)}%',
      'Compliant Elements': '${_auditResult!.compliantCount} / ${_auditResult!.applicableCount}',
      'Non-Compliant Elements': '${_auditResult!.nonCompliantCount} / ${_auditResult!.applicableCount}',
      'Not Applicable Elements': '${_auditResult!.notApplicableCount} / ${_auditResult!.elements.length}',
    };

    // Prepare benchmark
    final target = BundleToolConstants.complianceTargets[_selectedBundleType!] ?? 95.0;
    final benchmark = {
      'Your Score': '${_auditResult!.complianceScore.toStringAsFixed(1)}%',
      'Target': '${target.toStringAsFixed(0)}%',
      'Status': _auditResult!.complianceScore >= target ? 'Meets Target' : 'Below Target',
      'Gap': _auditResult!.complianceScore >= target
          ? '+${(_auditResult!.complianceScore - target).toStringAsFixed(1)}%'
          : '${(_auditResult!.complianceScore - target).toStringAsFixed(1)}%',
    };

    // Prepare recommendations
    final recommendations = _auditResult!.recommendations.join('\n• ');

    final success = await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Bundle Audit Tool - ${_selectedBundleType!.shortName}',
      inputs: inputs,
      results: results,
      interpretation: _auditResult!.interpretation,
      benchmark: benchmark,
      recommendations: '• $recommendations',
      facilityName: null,
      unitName: _unitController.text,
      generatedBy: _auditorController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported as PDF'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    if (_auditResult == null) return;

    // Prepare inputs
    final inputs = {
      'Bundle Type': _selectedBundleType!.shortName,
      'Audit Date': _auditDateController.text,
      'Unit/Location': _unitController.text,
      'Auditor Name': _auditorController.text,
      if (_patientIdController.text.isNotEmpty)
        'Patient ID': _patientIdController.text,
    };

    // Prepare results
    final results = {
      'Compliance Score': '${_auditResult!.complianceScore.toStringAsFixed(1)}%',
      'Compliant Elements': '${_auditResult!.compliantCount} / ${_auditResult!.applicableCount}',
      'Non-Compliant Elements': '${_auditResult!.nonCompliantCount} / ${_auditResult!.applicableCount}',
      'Not Applicable Elements': '${_auditResult!.notApplicableCount} / ${_auditResult!.elements.length}',
    };

    // Prepare benchmark
    final target = BundleToolConstants.complianceTargets[_selectedBundleType!] ?? 95.0;
    final benchmark = {
      'Your Score': '${_auditResult!.complianceScore.toStringAsFixed(1)}%',
      'Target': '${target.toStringAsFixed(0)}%',
      'Status': _auditResult!.complianceScore >= target ? 'Meets Target' : 'Below Target',
      'Gap': _auditResult!.complianceScore >= target
          ? '+${(_auditResult!.complianceScore - target).toStringAsFixed(1)}%'
          : '${(_auditResult!.complianceScore - target).toStringAsFixed(1)}%',
    };

    // Prepare recommendations
    final recommendations = _auditResult!.recommendations.join('\n');

    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Bundle Audit Tool - ${_selectedBundleType!.shortName}',
      inputs: inputs,
      results: results,
      interpretation: _auditResult!.interpretation,
      benchmark: benchmark,
      recommendations: recommendations,
      facilityName: null,
      unitName: _unitController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported as Excel'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    if (_auditResult == null) return;

    // Prepare inputs
    final inputs = {
      'Bundle Type': _selectedBundleType!.shortName,
      'Audit Date': _auditDateController.text,
      'Unit/Location': _unitController.text,
      'Auditor Name': _auditorController.text,
      if (_patientIdController.text.isNotEmpty)
        'Patient ID': _patientIdController.text,
    };

    // Prepare results
    final results = {
      'Compliance Score': '${_auditResult!.complianceScore.toStringAsFixed(1)}%',
      'Compliant Elements': '${_auditResult!.compliantCount} / ${_auditResult!.applicableCount}',
      'Non-Compliant Elements': '${_auditResult!.nonCompliantCount} / ${_auditResult!.applicableCount}',
      'Not Applicable Elements': '${_auditResult!.notApplicableCount} / ${_auditResult!.elements.length}',
    };

    // Prepare benchmark
    final target = BundleToolConstants.complianceTargets[_selectedBundleType!] ?? 95.0;
    final benchmark = {
      'Your Score': '${_auditResult!.complianceScore.toStringAsFixed(1)}%',
      'Target': '${target.toStringAsFixed(0)}%',
      'Status': _auditResult!.complianceScore >= target ? 'Meets Target' : 'Below Target',
      'Gap': _auditResult!.complianceScore >= target
          ? '+${(_auditResult!.complianceScore - target).toStringAsFixed(1)}%'
          : '${(_auditResult!.complianceScore - target).toStringAsFixed(1)}%',
    };

    // Prepare recommendations
    final recommendations = _auditResult!.recommendations.join('\n');

    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Bundle Audit Tool - ${_selectedBundleType!.shortName}',
      inputs: inputs,
      results: results,
      interpretation: _auditResult!.interpretation,
      benchmark: benchmark,
      recommendations: recommendations,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported as Text'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _saveToHistory() async {
    if (_auditResult == null) return;
    
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }
      
      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Bundle Audit Tool - ${_selectedBundleType!.shortName}',
        inputs: {
          'Bundle Type': _selectedBundleType!.shortName,
          'Audit Date': _auditDateController.text,
          'Unit/Location': _unitController.text,
          'Auditor Name': _auditorController.text,
        },
        result: 'Compliance Score: ${_auditResult!.complianceScore.toStringAsFixed(1)}%\n'
                'Compliant: ${_auditResult!.compliantCount} / ${_auditResult!.elements.length}\n'
                'Non-Compliant: ${_auditResult!.nonCompliantCount} / ${_auditResult!.elements.length}',
        notes: '',
        tags: ['bundle-audit', _selectedBundleType!.name, 'compliance'],
      );
      
      await repository.addEntry(historyEntry);
    } catch (e) {
      debugPrint('Error saving to history: $e');
    }
  }

  Color _getComplianceColor(double score) {
    if (score >= 95) return AppColors.success;
    if (score >= 85) return AppColors.warning;
    if (score >= 75) return AppColors.info;
    return AppColors.error;
  }
}

