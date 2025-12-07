import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';

class LineListTool extends StatefulWidget {
  const LineListTool({super.key});

  @override
  State<LineListTool> createState() => _LineListToolState();
}

class _LineListToolState extends State<LineListTool> {
  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'A line list is a systematic table that records key information about each case during an outbreak investigation. It serves as the foundation for descriptive epidemiology, enabling analysis of person, place, and time characteristics.',
    example: 'COVID-19 outbreak line list: Case ID, Name, Age, Sex, Onset Date, Location, Symptoms, Lab Result, Exposure History, Outcome. Used to identify clusters, calculate attack rates, and generate epidemic curves.',
    interpretation: 'Line lists enable rapid identification of outbreak patterns, common exposures, and high-risk groups. Complete and accurate line lists are essential for hypothesis generation and targeted control measures.',
    whenUsed: 'Step 5-6 of outbreak investigation (case finding and descriptive epidemiology). Maintained throughout the outbreak and updated as new cases are identified or additional information becomes available.',
    inputDataType: 'Case demographics (ID, name, age, sex), clinical data (onset date, symptoms, outcome), epidemiological data (location, exposure history, risk factors), and laboratory results.',
    references: [
      Reference(
        title: 'CDC Field Epidemiology Manual - Line Listing',
        url: 'https://www.cdc.gov/eis/field-epi-manual/chapters/Line-Listing.html',
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

  List<Map<String, dynamic>> _cases = [];

  final List<String> _columns = [
    'Case ID',
    'Name',
    'Age',
    'Sex',
    'Date of Onset',
    'Location',
    'Status',
    'Exposure',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Line List Tool'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        actions: [
          IconButton(
            onPressed: _addNewCase,
            icon: const Icon(Icons.add),
            tooltip: 'Add New Case',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          child: Column(
            children: [
            // Header Card
            Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
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
                        Icons.list_alt_outlined,
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
                            'Line List Tool',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage case-level data for outbreak investigations',
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
                    _buildStatCard('Total Cases', _cases.length.toString(), AppColors.primary),
                    const SizedBox(width: 12),
                    _buildStatCard('Confirmed', _getStatusCount('Confirmed').toString(), AppColors.success),
                    const SizedBox(width: 12),
                    _buildStatCard('Suspected', _getStatusCount('Suspected').toString(), AppColors.warning),
                  ],
                ),
              ],
            ),
          ),

          // Quick Guide Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
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
          ),
          const SizedBox(height: 12),

          // Load Template Button (unified position)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
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
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addNewCase,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Case'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _cases.isNotEmpty ? _showExportModal : null,
                        icon: const Icon(Icons.file_download_outlined, size: 20),
                        label: const Text('Export'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _cases.isNotEmpty ? _exportSummary : null,
                        icon: const Icon(Icons.summarize, size: 18),
                        label: const Text('Summary'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: AppColors.success,
                          side: BorderSide(color: AppColors.success),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cases.isNotEmpty ? _clearAll : null,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear All'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cases List
          _cases.isEmpty ? _buildEmptyState() : _buildCasesList(),

          const SizedBox(height: 16),

          // References Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: _buildReferences(),
          ),
            ],
          ),
        ),
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If height is very small, show minimal content
        if (constraints.maxHeight < 100) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.list_alt_outlined,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'No Cases',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addNewCase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 24),
                    textStyle: const TextStyle(fontSize: 10),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        }

        // Normal layout for adequate height
        return SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.list_alt_outlined,
                  size: 32,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 8),
                Text(
                  'No Cases Added Yet',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add your first case to start',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _addNewCase,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Case'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCasesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Case List (${_cases.length} cases)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Cases
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _cases.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final caseData = _cases[index];
              return _buildCaseCard(caseData, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> caseData, int index) {
    final status = caseData['Status'] ?? 'Unknown';
    Color statusColor = AppColors.textSecondary;
    
    switch (status) {
      case 'Confirmed':
        statusColor = AppColors.success;
        break;
      case 'Suspected':
        statusColor = AppColors.warning;
        break;
      case 'Probable':
        statusColor = AppColors.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Status Indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Case Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      caseData['Case ID'] ?? 'Unknown ID',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${caseData['Name'] ?? 'Unknown'} • ${caseData['Age'] ?? 'Unknown'} • ${caseData['Sex'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (caseData['Date of Onset'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Onset: ${caseData['Date of Onset']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editCase(index),
                icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                tooltip: 'Edit Case',
              ),
              IconButton(
                onPressed: () => _deleteCase(index),
                icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                tooltip: 'Delete Case',
              ),
            ],
          ),
        ],
      ),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.library_books_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'References',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReferenceButton(
            'CDC Line List Guidelines',
            'https://www.cdc.gov/eis/field-epi-manual/chapters/Line-Lists.html',
          ),
          const SizedBox(height: 6),
          _buildReferenceButton(
            'WHO Data Collection Standards',
            'https://www.who.int/teams/control-of-neglected-tropical-diseases',
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceButton(String title, String url) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _launchURL(url),
        icon: Icon(
          Icons.open_in_new,
          size: 14,
          color: AppColors.primary,
        ),
        label: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }

  int _getStatusCount(String status) {
    return _cases.where((c) => c['Status'] == status).length;
  }

  void _addNewCase() {
    _showCaseDialog();
  }

  void _editCase(int index) {
    _showCaseDialog(existingCase: _cases[index], index: index);
  }

  void _showCaseDialog({Map<String, dynamic>? existingCase, int? index}) {
    final controllers = <String, TextEditingController>{};
    
    for (final column in _columns) {
      controllers[column] = TextEditingController(
        text: existingCase?[column]?.toString() ?? '',
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingCase == null ? 'Add New Case' : 'Edit Case'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _columns.map((column) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: controllers[column],
                    decoration: InputDecoration(
                      labelText: column,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              for (final controller in controllers.values) {
                controller.dispose();
              }
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final caseData = <String, dynamic>{};
              for (final entry in controllers.entries) {
                caseData[entry.key] = entry.value.text;
              }
              
              if (index != null) {
                setState(() {
                  _cases[index] = caseData;
                });
              } else {
                setState(() {
                  _cases.add(caseData);
                });
              }
              
              _saveData();
              
              for (final controller in controllers.values) {
                controller.dispose();
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(existingCase == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteCase(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Case'),
        content: const Text('Are you sure you want to delete this case?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cases.removeAt(index);
              });
              _saveData();
              Navigator.pop(context);
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
        title: const Text('Clear All Cases'),
        content: const Text('Are you sure you want to delete all cases? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cases.clear();
              });
              _saveData();
              Navigator.pop(context);
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

  String _generateCSV() {
    if (_cases.isEmpty) return '';

    final buffer = StringBuffer();

    // Header
    buffer.writeln(_columns.join(','));

    // Data rows
    for (final caseData in _cases) {
      final row = _columns.map((column) =>
        '"${caseData[column]?.toString().replaceAll('"', '""') ?? ''}"'
      ).join(',');
      buffer.writeln(row);
    }

    return buffer.toString();
  }

  Future<void> _exportSummary() async {
    if (_cases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No cases to summarize'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final summaryData = _generateSummaryCSV();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'ipc_line_list_summary_$timestamp';

    // Export using UnifiedExportService
    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: filename,
      csvContent: summaryData,
      shareText: 'Line List Summary Export\nTotal Cases: ${_cases.length}',
    );
  }

  String _generateSummaryCSV() {
    if (_cases.isEmpty) return '';

    final buffer = StringBuffer();

    // Title
    buffer.writeln('LINE LIST SUMMARY REPORT');
    buffer.writeln('Generated: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('');

    // Overall Statistics
    buffer.writeln('OVERALL STATISTICS');
    buffer.writeln('Metric,Value');
    buffer.writeln('Total Cases,${_cases.length}');
    buffer.writeln('Confirmed Cases,${_getStatusCount('Confirmed')}');
    buffer.writeln('Suspected Cases,${_getStatusCount('Suspected')}');
    buffer.writeln('Probable Cases,${_getStatusCount('Probable')}');
    buffer.writeln('');

    // Cases by Date (for Epidemic Curve)
    buffer.writeln('CASES BY DATE OF ONSET');
    buffer.writeln('Date,Case Count');
    final casesByDate = <String, int>{};
    for (final caseData in _cases) {
      final date = caseData['Date of Onset']?.toString() ?? 'Unknown';
      casesByDate[date] = (casesByDate[date] ?? 0) + 1;
    }
    final sortedDates = casesByDate.keys.toList()..sort();
    for (final date in sortedDates) {
      buffer.writeln('$date,${casesByDate[date]}');
    }
    buffer.writeln('');

    // Cases by Location (for Comparison Tool)
    buffer.writeln('CASES BY LOCATION');
    buffer.writeln('Location,Case Count');
    final casesByLocation = <String, int>{};
    for (final caseData in _cases) {
      final location = caseData['Location']?.toString() ?? 'Unknown';
      casesByLocation[location] = (casesByLocation[location] ?? 0) + 1;
    }
    final sortedLocations = casesByLocation.keys.toList()..sort();
    for (final location in sortedLocations) {
      buffer.writeln('$location,${casesByLocation[location]}');
    }
    buffer.writeln('');

    // Age Distribution (for Histogram Tool)
    buffer.writeln('AGE DISTRIBUTION');
    buffer.writeln('Age');
    for (final caseData in _cases) {
      final age = caseData['Age']?.toString() ?? '';
      if (age.isNotEmpty) {
        buffer.writeln(age);
      }
    }
    buffer.writeln('');

    // Cases by Sex
    buffer.writeln('CASES BY SEX');
    buffer.writeln('Sex,Case Count');
    final casesBySex = <String, int>{};
    for (final caseData in _cases) {
      final sex = caseData['Sex']?.toString() ?? 'Unknown';
      casesBySex[sex] = (casesBySex[sex] ?? 0) + 1;
    }
    for (final sex in casesBySex.keys) {
      buffer.writeln('$sex,${casesBySex[sex]}');
    }
    buffer.writeln('');

    // Date Range (for Timeline Tool)
    buffer.writeln('DATE RANGE');
    final dates = <DateTime>[];
    for (final caseData in _cases) {
      final dateStr = caseData['Date of Onset']?.toString();
      if (dateStr != null && dateStr.isNotEmpty && dateStr != 'Unknown') {
        try {
          dates.add(DateTime.parse(dateStr));
        } catch (e) {
          // Skip invalid dates
        }
      }
    }
    if (dates.isNotEmpty) {
      dates.sort();
      buffer.writeln('First Case,${dates.first.toString().split(' ')[0]}');
      buffer.writeln('Last Case,${dates.last.toString().split(' ')[0]}');
      buffer.writeln('Duration (days),${dates.last.difference(dates.first).inDays + 1}');
    } else {
      buffer.writeln('First Case,N/A');
      buffer.writeln('Last Case,N/A');
      buffer.writeln('Duration (days),N/A');
    }
    buffer.writeln('');

    // Usage Instructions
    buffer.writeln('USAGE INSTRUCTIONS');
    buffer.writeln('This summary can be used with the following IPC Guider tools:');
    buffer.writeln('- Epidemic Curve Generator: Use "Cases by Date of Onset" section');
    buffer.writeln('- Comparison Tool: Use "Cases by Location" section');
    buffer.writeln('- Histogram Tool: Use "Age Distribution" section');
    buffer.writeln('- Timeline Tool: Use "Date Range" section');

    return buffer.toString();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('line_list_data');
    
    if (savedData != null) {
      final decoded = jsonDecode(savedData) as List;
      setState(() {
        _cases = decoded.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('line_list_data', jsonEncode(_cases));
  }

  void _loadExample() {
    setState(() {
      _cases.clear();
      _cases.addAll([
        {
          'caseId': 'C001',
          'name': 'Patient A',
          'age': '45',
          'gender': 'Male',
          'onsetDate': DateTime.now().subtract(Duration(days: 10)).toIso8601String(),
          'reportDate': DateTime.now().subtract(Duration(days: 8)).toIso8601String(),
          'location': 'Ward 3A',
          'status': 'Confirmed',
          'outcome': 'Recovered',
        },
        {
          'caseId': 'C002',
          'name': 'Patient B',
          'age': '32',
          'gender': 'Female',
          'onsetDate': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
          'reportDate': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
          'location': 'Ward 2B',
          'status': 'Confirmed',
          'outcome': 'Under Treatment',
        },
        {
          'caseId': 'C003',
          'name': 'Patient C',
          'age': '58',
          'gender': 'Male',
          'onsetDate': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
          'reportDate': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
          'location': 'Ward 3A',
          'status': 'Probable',
          'outcome': 'Under Treatment',
        },
      ]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded: 3 outbreak cases'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
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
    if (_cases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No cases to export'),
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
      'Total Cases': _cases.length.toString(),
      'Confirmed Cases': _getStatusCount('Confirmed').toString(),
      'Probable Cases': _getStatusCount('Probable').toString(),
      'Suspected Cases': _getStatusCount('Suspected').toString(),
    };

    final results = {
      'Line List Summary': 'Complete case listing with ${_cases.length} cases',
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Line List Tool',
      inputs: inputs,
      results: results,
      interpretation: 'Line list contains ${_cases.length} cases for outbreak investigation. '
          'Data includes case demographics, clinical information, and epidemiological links.',
    );
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Total Cases': _cases.length.toString(),
      'Confirmed Cases': _getStatusCount('Confirmed').toString(),
      'Probable Cases': _getStatusCount('Probable').toString(),
      'Suspected Cases': _getStatusCount('Suspected').toString(),
    };

    final results = {
      'Line List Summary': 'Complete case listing with ${_cases.length} cases',
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Line List Tool',
      inputs: inputs,
      results: results,
      interpretation: 'Line list contains ${_cases.length} cases for outbreak investigation. '
          'Data includes case demographics, clinical information, and epidemiological links.',
    );
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final csvData = _generateCSV();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'ipc_line_list_$timestamp';

    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: filename,
      csvContent: csvData,
      shareText: 'Line List Export\nTotal Cases: ${_cases.length}',
    );
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Total Cases': _cases.length.toString(),
      'Confirmed Cases': _getStatusCount('Confirmed').toString(),
      'Probable Cases': _getStatusCount('Probable').toString(),
      'Suspected Cases': _getStatusCount('Suspected').toString(),
    };

    final results = {
      'Line List Summary': 'Complete case listing with ${_cases.length} cases',
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Line List Tool',
      inputs: inputs,
      results: results,
      interpretation: 'Line list contains ${_cases.length} cases for outbreak investigation. '
          'Data includes case demographics, clinical information, and epidemiological links.',
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error if needed
    }
  }
}
