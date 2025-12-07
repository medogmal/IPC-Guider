import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../data/models/history_entry.dart';
import '../../data/providers/history_providers.dart';

class ControlChecklist extends ConsumerStatefulWidget {
  const ControlChecklist({super.key});

  @override
  ConsumerState<ControlChecklist> createState() => _ControlChecklistState();
}

class _ControlChecklistState extends ConsumerState<ControlChecklist> {
  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'A systematic checklist of infection prevention and control measures implemented during outbreak response. It ensures comprehensive implementation of patient, environmental, staff, and communication interventions to contain and terminate outbreaks.',
    example: 'MRSA outbreak control checklist: Patient isolation (100% compliance), enhanced environmental cleaning (daily audits), staff screening (all HCWs tested), daily outbreak meetings (documented), GDIPC notification (completed within 24h).',
    interpretation: 'Complete checklists demonstrate systematic outbreak response and identify gaps in control measures. Regular monitoring ensures sustained implementation and enables early detection of compliance issues.',
    whenUsed: 'Step 9-10 of outbreak investigation (implement control measures and evaluate effectiveness). Used throughout the outbreak response period with daily or weekly reviews until outbreak termination.',
    inputDataType: 'Control measure categories (patient, environmental, staff, communication), specific interventions implemented, compliance status, implementation dates, and responsible personnel.',
    references: [
      Reference(
        title: 'CDC Outbreak Response Guidelines',
        url: 'https://www.cdc.gov/hai/outbreaks/index.html',
      ),
      Reference(
        title: 'WHO Outbreak Control Measures',
        url: 'https://www.who.int/emergencies/outbreak-toolkit/disease-outbreak-toolboxes',
      ),
      Reference(
        title: 'APIC Outbreak Investigation Guide',
        url: 'https://apic.org/Resource_/TinyMceFileManager/Advocacy-PDFs/APIC_Outbreak_Investigation_Guide.pdf',
      ),
    ],
  );

  // Outbreak details
  final _outbreakNameController = TextEditingController();
  final _wardUnitController = TextEditingController();
  final _notesController = TextEditingController();

  // Text controllers for "Other" fields
  final _patientOtherController = TextEditingController();
  final _environmentalOtherController = TextEditingController();
  final _staffOtherController = TextEditingController();
  final _communicationOtherController = TextEditingController();

  // Checklist categories and items
  final Map<String, Map<String, bool>> _checklistItems = {
    'Patient Measures': {
      'Isolation of suspected/confirmed cases': false,
      'Cohorting if needed': false,
      'Dedicated staff for outbreak ward': false,
      'Other (specify)': false,
    },
    'Environmental Measures': {
      'Enhanced cleaning & disinfection': false,
      'Equipment disinfection': false,
      'Water/air/environmental checks if indicated': false,
      'Other (specify)': false,
    },
    'Staff Measures': {
      'Staff screening (if outbreak requires)': false,
      'Hand hygiene audit': false,
      'PPE availability & compliance check': false,
      'Other (specify)': false,
    },
    'Communication & Documentation': {
      'Notify hospital leadership': false,
      'Notify GDIPC/Weqaya (as per regulations)': false,
      'Daily outbreak update note': false,
      'Other (specify)': false,
    },
  };

  // Collapsed state for categories
  final Map<String, bool> _categoryCollapsed = {
    'Patient Measures': false,
    'Environmental Measures': false,
    'Staff Measures': false,
    'Communication & Documentation': false,
  };

  bool _isLoading = false;
  List<Map<String, dynamic>> _savedEntries = [];

  @override
  void initState() {
    super.initState();
    _loadSavedEntries();
  }

  @override
  void dispose() {
    _outbreakNameController.dispose();
    _wardUnitController.dispose();
    _notesController.dispose();
    _patientOtherController.dispose();
    _environmentalOtherController.dispose();
    _staffOtherController.dispose();
    _communicationOtherController.dispose();
    super.dispose();
  }

  // Calculate completion percentage
  double get _completionPercentage {
    int totalItems = 0;
    int completedItems = 0;
    
    for (var category in _checklistItems.values) {
      totalItems += category.length;
      completedItems += category.values.where((completed) => completed).length;
    }
    
    return totalItems > 0 ? (completedItems / totalItems) : 0.0;
  }

  // Get progress color based on percentage
  Color get _progressColor {
    final percentage = _completionPercentage;
    if (percentage >= 0.7) return AppColors.success;
    if (percentage >= 0.3) return AppColors.warning;
    return AppColors.error;
  }

  // Load saved entries from SharedPreferences
  Future<void> _loadSavedEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('control_checklist_entries') ?? [];
      setState(() {
        _savedEntries = entriesJson
            .map((entry) => Map<String, dynamic>.from(json.decode(entry)))
            .toList();
        _savedEntries.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
      });
    } catch (e) {
      // Silent error handling for production
    }
  }

  // Save current checklist state
  Future<void> _saveEntry() async {
    if (_outbreakNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter outbreak name', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create unified history entry
      final completedItems = <String>[];
      final allResponses = <String, String>{};

      for (var category in _checklistItems.entries) {
        for (var item in category.value.entries) {
          var itemKey = item.key;

          // Add "Other" details if applicable
          if (itemKey == 'Other (specify)' && item.value) {
            String? otherText;
            if (category.key == 'Patient Measures') {
              otherText = _patientOtherController.text.trim();
            } else if (category.key == 'Environmental Measures') {
              otherText = _environmentalOtherController.text.trim();
            } else if (category.key == 'Staff Measures') {
              otherText = _staffOtherController.text.trim();
            } else if (category.key == 'Communication & Documentation') {
              otherText = _communicationOtherController.text.trim();
            }

            if (otherText != null && otherText.isNotEmpty) {
              itemKey = 'Other: $otherText';
            }
          }

          final key = '${category.key}: $itemKey';
          allResponses[key] = item.value ? 'Completed' : 'Not Completed';
          if (item.value) {
            completedItems.add(key);
          }
        }
      }

      final completionStatus = '${(_completionPercentage * 100).toStringAsFixed(1)}% Complete (${completedItems.length} items)';

      final historyEntry = HistoryEntry.fromChecklist(
        checklistName: 'Control Checklist - ${_outbreakNameController.text.trim()}',
        responses: {
          'Outbreak Name': _outbreakNameController.text.trim(),
          'Ward/Unit': _wardUnitController.text.trim(),
          ...allResponses,
        },
        completionStatus: completionStatus,
        notes: _notesController.text.trim(),
        tags: ['control-measures', 'outbreak-response', 'checklist'],
      );

      // Save to unified history
      final historyService = ref.read(historyServiceProvider);
      await historyService.addEntry(historyEntry);

      // Also maintain backward compatibility with old system for now
      final entry = {
        'timestamp': DateTime.now().toIso8601String(),
        'outbreakName': _outbreakNameController.text.trim(),
        'wardUnit': _wardUnitController.text.trim(),
        'notes': _notesController.text.trim(),
        'completionPercentage': _completionPercentage,
        'checklistItems': Map<String, Map<String, bool>>.from(_checklistItems),
      };

      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('control_checklist_entries') ?? [];
      entriesJson.add(json.encode(entry));
      await prefs.setStringList('control_checklist_entries', entriesJson);

      await _loadSavedEntries();
      _showSnackBar('Checklist saved to history successfully');
    } catch (e) {
      _showSnackBar('Failed to save checklist: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }



  // Generate CSV content
  String _generateCSVContent() {
    final buffer = StringBuffer();
    buffer.writeln('Date,Outbreak Name,Ward/Unit,Completed Items,Completion %,Notes');
    
    for (var entry in _savedEntries) {
      final completedItems = <String>[];
      final checklistItems = Map<String, Map<String, bool>>.from(entry['checklistItems']);
      
      for (var category in checklistItems.entries) {
        for (var item in category.value.entries) {
          if (item.value) {
            completedItems.add('${category.key}: ${item.key}');
          }
        }
      }
      
      final date = DateTime.parse(entry['timestamp']).toLocal().toString().split(' ')[0];
      final outbreakName = _escapeCsvField(entry['outbreakName']);
      final wardUnit = _escapeCsvField(entry['wardUnit']);
      final completedItemsStr = _escapeCsvField(completedItems.join('; '));
      final completionPercentage = '${(entry['completionPercentage'] * 100).toStringAsFixed(1)}%';
      final notes = _escapeCsvField(entry['notes']);
      
      buffer.writeln('$date,$outbreakName,$wardUnit,$completedItemsStr,$completionPercentage,$notes');
    }
    
    return buffer.toString();
  }

  // Escape CSV field
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  // Show snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Load saved entry
  void _loadSavedEntry(Map<String, dynamic> entry) {
    setState(() {
      _outbreakNameController.text = entry['outbreakName'];
      _wardUnitController.text = entry['wardUnit'];
      _notesController.text = entry['notes'];
      
      final savedItems = Map<String, Map<String, bool>>.from(entry['checklistItems']);
      for (var category in _checklistItems.keys) {
        if (savedItems.containsKey(category)) {
          for (var item in _checklistItems[category]!.keys) {
            if (savedItems[category]!.containsKey(item)) {
              _checklistItems[category]![item] = savedItems[category]![item]!;
            }
          }
        }
      }
    });
  }

  // Delete saved entry
  Future<void> _deleteSavedEntry(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('control_checklist_entries') ?? [];
      entriesJson.removeAt(index);
      await prefs.setStringList('control_checklist_entries', entriesJson);
      await _loadSavedEntries();
      _showSnackBar('Entry deleted successfully');
    } catch (e) {
      _showSnackBar('Failed to delete entry', isError: true);
    }
  }

  // Clear all data
  void _clearAllData() {
    setState(() {
      _outbreakNameController.clear();
      _wardUnitController.clear();
      _notesController.clear();
      
      for (var category in _checklistItems.values) {
        for (var key in category.keys) {
          category[key] = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outbreak Control Checklist'),
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
            // Progress Bar (Pinned)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textSecondary.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildProgressSection(),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntroPanel(),
                  const SizedBox(height: 24),

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
                        'Export Checklist',
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
                  const SizedBox(height: 24),

                  _buildOutbreakDetailsForm(),
                  const SizedBox(height: 24),
                  _buildChecklistSection(),
                  const SizedBox(height: 24),
                  _buildNotesSection(),
                  const SizedBox(height: 24),

                  _buildActionsSection(),
                  const SizedBox(height: 24),
                  _buildHistorySection(),
                  const SizedBox(height: 24),
                  _buildReferencesSection(),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  // Build intro panel
  Widget _buildIntroPanel() {
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
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.checklist_outlined,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Outbreak Control Checklist',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track and document outbreak control actions step by step',
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
          Text(
            'Use this checklist to ensure all essential outbreak control measures are implemented and tracked.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Build progress section
  Widget _buildProgressSection() {
    final percentage = _completionPercentage;
    final completedCount = _checklistItems.values
        .expand((category) => category.values)
        .where((completed) => completed)
        .length;
    final totalCount = _checklistItems.values
        .expand((category) => category.values)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Completed $completedCount of $totalCount actions',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.neutral.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}% Complete',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _progressColor,
          ),
        ),
      ],
    );
  }

  // Build outbreak details form
  Widget _buildOutbreakDetailsForm() {
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
          const Text(
            'Outbreak Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _outbreakNameController,
            decoration: InputDecoration(
              labelText: 'Outbreak Name *',
              hintText: 'e.g., MRSA Outbreak - ICU',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _wardUnitController,
            decoration: InputDecoration(
              labelText: 'Ward/Unit',
              hintText: 'e.g., ICU, Medical Ward 3',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Build checklist section
  Widget _buildChecklistSection() {
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
          const Text(
            'Control Measures Checklist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._checklistItems.entries.map((categoryEntry) {
            final categoryName = categoryEntry.key;
            final items = categoryEntry.value;
            final isCollapsed = _categoryCollapsed[categoryName] ?? false;

            return Column(
              children: [
                _buildCategoryHeader(categoryName, isCollapsed),
                if (!isCollapsed) ...[
                  const SizedBox(height: 8),
                  ...items.entries.map((itemEntry) {
                    return _buildChecklistItem(
                      categoryName,
                      itemEntry.key,
                      itemEntry.value,
                    );
                  }),
                ],
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  // Build category header
  Widget _buildCategoryHeader(String categoryName, bool isCollapsed) {
    final categoryItems = _checklistItems[categoryName]!;
    final completedCount = categoryItems.values.where((completed) => completed).length;
    final totalCount = categoryItems.length;

    return InkWell(
      onTap: () {
        setState(() {
          _categoryCollapsed[categoryName] = !isCollapsed;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCollapsed ? Icons.expand_more : Icons.expand_less,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                categoryName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: completedCount == totalCount
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$completedCount/$totalCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: completedCount == totalCount
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build checklist item
  Widget _buildChecklistItem(String categoryName, String itemName, bool isCompleted) {
    final isOther = itemName.startsWith('Other (specify)');
    TextEditingController? otherController;

    if (isOther) {
      // Map category to appropriate controller
      if (categoryName == 'Patient Measures') {
        otherController = _patientOtherController;
      } else if (categoryName == 'Environmental Measures') {
        otherController = _environmentalOtherController;
      } else if (categoryName == 'Staff Measures') {
        otherController = _staffOtherController;
      } else if (categoryName == 'Communication & Documentation') {
        otherController = _communicationOtherController;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _checklistItems[categoryName]![itemName] = !isCompleted;
                if (!isCompleted == false && otherController != null) {
                  otherController.clear();
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success.withValues(alpha: 0.05)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.neutral.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.success : Colors.transparent,
                      border: Border.all(
                        color: isCompleted ? AppColors.success : AppColors.neutral,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      itemName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.textPrimary,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOther && isCompleted && otherController != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
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
      ),
    );
  }

  // Build notes section
  Widget _buildNotesSection() {
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
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add any additional notes or observations...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  // Build actions section
  Widget _buildActionsSection() {
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
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveEntry,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isLoading ? 'Saving...' : 'Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _clearAllData,
              icon: const Icon(Icons.clear_all_outlined),
              label: const Text('Clear All'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build history section
  Widget _buildHistorySection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saved Entries',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_savedEntries.isNotEmpty)
                Text(
                  '${_savedEntries.length} entries',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_savedEntries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.neutral.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.neutral.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history_outlined,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No saved entries yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Save your first checklist to see it here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_savedEntries.length, (index) {
              final entry = _savedEntries[index];
              return _buildHistoryItem(entry, index);
            }),
        ],
      ),
    );
  }

  // Build history item
  Widget _buildHistoryItem(Map<String, dynamic> entry, int index) {
    final date = DateTime.parse(entry['timestamp']).toLocal();
    final dateStr = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    final percentage = (entry['completionPercentage'] * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.neutral.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['outbreakName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entry['wardUnit'].isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry['wardUnit'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProgressColorFromPercentage(entry['completionPercentage']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getProgressColorFromPercentage(entry['completionPercentage']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _loadSavedEntry(entry),
                  icon: const Icon(Icons.restore_outlined, size: 16),
                  label: const Text('Load'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _deleteSavedEntry(index),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Get progress color from percentage
  Color _getProgressColorFromPercentage(double percentage) {
    if (percentage >= 0.7) return AppColors.success;
    if (percentage >= 0.3) return AppColors.warning;
    return AppColors.error;
  }

  // Build references section
  Widget _buildReferencesSection() {
    final references = [
      {
        'title': 'WHO – Outbreak Control Measures Guidance',
        'url': 'https://www.who.int/emergencies/disease-outbreak-news',
      },
      {
        'title': 'CDC – Infection Prevention During Outbreaks',
        'url': 'https://www.cdc.gov/infectioncontrol/guidelines/isolation/index.html',
      },
      {
        'title': 'GDIPC/Weqaya – National Outbreak Response Standards',
        'url': 'https://www.moph.gov.qa/english/derpartments/policyaffairs/hpps/pages/weqaya.aspx',
      },
    ];

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
              Icon(
                Icons.menu_book_outlined,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'References',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...references.map((ref) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _launchURL(ref['url']!),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.open_in_new,
                        color: AppColors.info,
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ref['title']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.info,
                          ),
                        ),
                      ),
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

  // Launch URL
  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not launch URL', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error launching URL', isError: true);
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
    if (_outbreakNameController.text.isEmpty) {
      _showSnackBar('Please enter outbreak name before exporting', isError: true);
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
      'Outbreak Name': _outbreakNameController.text,
      'Ward/Unit': _wardUnitController.text.isEmpty ? 'N/A' : _wardUnitController.text,
      'Completion': '${(_completionPercentage * 100).toStringAsFixed(1)}%',
    };

    final results = {
      'Patient Measures': _getCategoryCompletionSummary('Patient Measures'),
      'Environmental Measures': _getCategoryCompletionSummary('Environmental Measures'),
      'Staff Measures': _getCategoryCompletionSummary('Staff Measures'),
      'Communication & Documentation': _getCategoryCompletionSummary('Communication & Documentation'),
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Control Checklist',
      inputs: inputs,
      results: results,
      interpretation: 'Outbreak control checklist with ${(_completionPercentage * 100).toStringAsFixed(1)}% completion. '
          'Systematic implementation of infection prevention measures per CDC/WHO guidelines.',
    );
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Outbreak Name': _outbreakNameController.text,
      'Ward/Unit': _wardUnitController.text.isEmpty ? 'N/A' : _wardUnitController.text,
      'Completion': '${(_completionPercentage * 100).toStringAsFixed(1)}%',
    };

    final results = {
      'Patient Measures': _getCategoryCompletionSummary('Patient Measures'),
      'Environmental Measures': _getCategoryCompletionSummary('Environmental Measures'),
      'Staff Measures': _getCategoryCompletionSummary('Staff Measures'),
      'Communication & Documentation': _getCategoryCompletionSummary('Communication & Documentation'),
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Control Checklist',
      inputs: inputs,
      results: results,
      interpretation: 'Outbreak control checklist with ${(_completionPercentage * 100).toStringAsFixed(1)}% completion. '
          'Systematic implementation of infection prevention measures per CDC/WHO guidelines.',
    );
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Outbreak Name': _outbreakNameController.text,
      'Ward/Unit': _wardUnitController.text.isEmpty ? 'N/A' : _wardUnitController.text,
      'Completion': '${(_completionPercentage * 100).toStringAsFixed(1)}%',
    };

    final results = {
      'Patient Measures': _getCategoryCompletionSummary('Patient Measures'),
      'Environmental Measures': _getCategoryCompletionSummary('Environmental Measures'),
      'Staff Measures': _getCategoryCompletionSummary('Staff Measures'),
      'Communication & Documentation': _getCategoryCompletionSummary('Communication & Documentation'),
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Control Checklist',
      inputs: inputs,
      results: results,
      interpretation: 'Outbreak control checklist with ${(_completionPercentage * 100).toStringAsFixed(1)}% completion. '
          'Systematic implementation of infection prevention measures per CDC/WHO guidelines.',
    );
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final csvContent = _generateCSVContent();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'ipc_control_checklist_$timestamp';

    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: filename,
      csvContent: csvContent,
      shareText: 'IPC Control Checklist Export\nOutbreak: ${_outbreakNameController.text}\nCompletion: ${(_completionPercentage * 100).toStringAsFixed(1)}%',
    );
  }

  String _getCategoryCompletionSummary(String category) {
    final items = _checklistItems[category]!;
    final completed = items.values.where((v) => v).length;
    final total = items.length;
    return '$completed/$total completed';
  }

  void _loadExample() {
    setState(() {
      _outbreakNameController.text = 'Norovirus Outbreak - Ward 3A';
      _wardUnitController.text = 'Medical Ward 3A';
      _notesController.text = 'Outbreak detected on ${DateTime.now().subtract(Duration(days: 3)).toString().split(' ')[0]}. Enhanced measures implemented immediately.';

      // Example: Partially completed checklist
      _checklistItems['Patient Measures']!['Isolation of suspected/confirmed cases'] = true;
      _checklistItems['Patient Measures']!['Cohorting if needed'] = true;
      _checklistItems['Patient Measures']!['Dedicated staff for outbreak ward'] = false;

      _checklistItems['Environmental Measures']!['Enhanced cleaning & disinfection'] = true;
      _checklistItems['Environmental Measures']!['Equipment disinfection'] = true;
      _checklistItems['Environmental Measures']!['Water/air/environmental checks if indicated'] = false;

      _checklistItems['Staff Measures']!['Staff screening (if outbreak requires)'] = true;
      _checklistItems['Staff Measures']!['Hand hygiene audit'] = false;
      _checklistItems['Staff Measures']!['PPE availability & compliance check'] = true;

      _checklistItems['Communication & Documentation']!['Notify hospital leadership'] = true;
      _checklistItems['Communication & Documentation']!['Notify GDIPC/Weqaya (as per regulations)'] = true;
      _checklistItems['Communication & Documentation']!['Daily outbreak update note'] = false;
    });

    _showSnackBar('Example checklist loaded successfully');
  }
}
