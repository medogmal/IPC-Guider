import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as excel_pkg;
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../data/organism_definitions.dart';
import '../../../data/tiered_antibiotic_panels.dart';
import '../../../data/antibiotic_definitions.dart';
import '../../../data/intrinsic_resistance_matrix.dart';
import '../../../domain/models/organism_definition.dart';
import '../../../domain/models/antibiotic_tier.dart';

/// Antibiogram Builder Screen - Clean Rebuild
///
/// A comprehensive tool for creating facility-specific cumulative antibiograms
/// following CLSI M39-A4 (2022) guidelines.
///
/// This is a minimal working version with clean navigation.
/// Features will be implemented incrementally following the documentation.
class AntibiogramBuilderScreen extends StatefulWidget {
  const AntibiogramBuilderScreen({super.key});

  @override
  State<AntibiogramBuilderScreen> createState() => _AntibiogramBuilderScreenState();
}

class _AntibiogramBuilderScreenState extends State<AntibiogramBuilderScreen> {
  // ═══════════════════════════════════════════════════════════
  // STATE VARIABLES
  // ═══════════════════════════════════════════════════════════

  /// Current step index (0-4)
  int _currentStep = 0;

  /// Step titles
  final List<String> _stepTitles = [
    'Configuration',
    'Organism Selection',
    'Smart Panel Selection',
    'Data Entry',
    'Results',
  ];

  // ───────────────────────────────────────────────────────────
  // STEP 0: CONFIGURATION STATE
  // ───────────────────────────────────────────────────────────

  final TextEditingController _facilityNameController = TextEditingController();
  String _selectedUnit = 'Hospital-Wide';
  DateTimeRange? _dateRange;
  String _selectedSpecimenSource = 'All Specimens';
  bool _applyFirstIsolateRule = true;
  bool _excludeDuplicates = true;
  bool _minimumThreshold = true;
  bool _clinicallyRelevantOnly = true;

  // ───────────────────────────────────────────────────────────
  // STEP 1: ORGANISM SELECTION STATE
  // ───────────────────────────────────────────────────────────

  final Set<String> _selectedOrganisms = {};

  // ───────────────────────────────────────────────────────────
  // STEP 2: SMART PANEL SELECTION STATE
  // ───────────────────────────────────────────────────────────

  String _panelSelectionMode = 'smart'; // 'smart', 'custom', 'all'
  String _selectedSpecimenType = 'blood';
  final Set<String> _selectedTiers = {'classA', 'classB', 'classC'};
  final Map<String, List<String>> _selectedAntibioticsPerOrganism = {};

  // ───────────────────────────────────────────────────────────
  // STEP 3: DATA ENTRY STATE
  // ───────────────────────────────────────────────────────────

  final List<Map<String, dynamic>> _antibiogramData = [];

  // ───────────────────────────────────────────────────────────
  // STEP 4: RESULTS DISPLAY STATE
  // ───────────────────────────────────────────────────────────

  String _resultsViewMode = 'list'; // 'list' or 'table'

  // ───────────────────────────────────────────────────────────
  // EXPORT STATE
  // ───────────────────────────────────────────────────────────

  final GlobalKey _tableViewKey = GlobalKey();
  bool _isExporting = false;

  // ═══════════════════════════════════════════════════════════
  // LIFECYCLE METHODS
  // ═══════════════════════════════════════════════════════════

  @override
  void dispose() {
    _facilityNameController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD METHOD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antibiogram Builder'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeaderSection(),
          _buildProgressIndicator(),
          Expanded(child: _buildStepContent(bottomPadding)),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER SECTION
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Build a professional antibiogram following CLSI M39-A4 guidelines',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          OutlinedButton.icon(
            onPressed: _loadExample,
            icon: const Icon(Icons.lightbulb_outline, size: 18),
            label: const Text('Load Example'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PROGRESS INDICATOR
  // ═══════════════════════════════════════════════════════════

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.textSecondary.withValues(alpha: 0.2),
                        ),
                      ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive || isCompleted
                            ? AppColors.primary
                            : AppColors.textSecondary.withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive || isCompleted
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    if (index < _stepTitles.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.textSecondary.withValues(alpha: 0.2),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STEP CONTENT
  // ═══════════════════════════════════════════════════════════

  Widget _buildStepContent(double bottomPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.large, AppSpacing.large, AppSpacing.large, bottomPadding + 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _stepTitles[_currentStep],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          _buildStepWidget(),
        ],
      ),
    );
  }

  Widget _buildStepWidget() {
    switch (_currentStep) {
      case 0:
        return _buildConfigurationStep();
      case 1:
        return _buildOrganismSelectionStep();
      case 2:
        return _buildSmartPanelSelectionStep();
      case 3:
        return _buildDataEntryStep();
      case 4:
        return _buildResultsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 0: CONFIGURATION
  // ═══════════════════════════════════════════════════════════

  Widget _buildConfigurationStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Facility Information Section
          _buildSectionCard(
            title: 'Facility Information',
            icon: Icons.business_outlined,
            children: [
              TextField(
                controller: _facilityNameController,
                decoration: const InputDecoration(
                  labelText: 'Facility Name *',
                  hintText: 'Enter hospital or facility name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit/Department',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Hospital-Wide', child: Text('Hospital-Wide')),
                  DropdownMenuItem(value: 'ICU', child: Text('ICU')),
                  DropdownMenuItem(value: 'Medical Ward', child: Text('Medical Ward')),
                  DropdownMenuItem(value: 'Surgical Ward', child: Text('Surgical Ward')),
                  DropdownMenuItem(value: 'Emergency Department', child: Text('Emergency Department')),
                  DropdownMenuItem(value: 'Pediatrics', child: Text('Pediatrics')),
                  DropdownMenuItem(value: 'NICU', child: Text('NICU')),
                ],
                onChanged: (value) {
                  if (value != null && mounted) {
                    setState(() {
                      _selectedUnit = value;
                    });
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.medium),

          // Analysis Period Section
          _buildSectionCard(
            title: 'Analysis Period',
            icon: Icons.calendar_today_outlined,
            children: [
              InkWell(
                onTap: _selectDateRange,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date Range *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dateRange == null
                        ? 'Select date range'
                        : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                    style: TextStyle(
                      color: _dateRange == null ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              DropdownButtonFormField<String>(
                initialValue: _selectedSpecimenSource,
                decoration: const InputDecoration(
                  labelText: 'Specimen Source',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'All Specimens', child: Text('All Specimens')),
                  DropdownMenuItem(value: 'Blood', child: Text('Blood')),
                  DropdownMenuItem(value: 'Urine', child: Text('Urine')),
                  DropdownMenuItem(value: 'Respiratory', child: Text('Respiratory')),
                  DropdownMenuItem(value: 'Wound', child: Text('Wound')),
                  DropdownMenuItem(value: 'CSF', child: Text('CSF')),
                ],
                onChanged: (value) {
                  if (value != null && mounted) {
                    setState(() {
                      _selectedSpecimenSource = value;
                    });
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.medium),

          // CLSI M39-A4 Compliance Section
          _buildSectionCard(
            title: 'CLSI M39-A4 Compliance',
            icon: Icons.verified_outlined,
            children: [
              CheckboxListTile(
                value: _applyFirstIsolateRule,
                onChanged: (value) {
                  if (value != null && mounted) {
                    setState(() {
                      _applyFirstIsolateRule = value;
                    });
                  }
                },
                title: const Text('Apply First Isolate Rule'),
                subtitle: const Text('Include only first isolate per patient per analysis period'),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _excludeDuplicates,
                onChanged: (value) {
                  if (value != null && mounted) {
                    setState(() {
                      _excludeDuplicates = value;
                    });
                  }
                },
                title: const Text('Exclude Duplicate Isolates'),
                subtitle: const Text('Exclude duplicate isolates from same patient within 30 days'),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _minimumThreshold,
                onChanged: (value) {
                  if (value != null && mounted) {
                    setState(() {
                      _minimumThreshold = value;
                    });
                  }
                },
                title: const Text('Minimum Threshold (N≥30)'),
                subtitle: const Text('Report only combinations with ≥30 isolates'),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _clinicallyRelevantOnly,
                onChanged: (value) {
                  if (value != null && mounted) {
                    setState(() {
                      _clinicallyRelevantOnly = value;
                    });
                  }
                },
                title: const Text('Clinically Relevant Only'),
                subtitle: const Text('Exclude intrinsically resistant combinations'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 1: ORGANISM SELECTION
  // ═══════════════════════════════════════════════════════════

  Widget _buildOrganismSelectionStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectAllOrganisms,
                  icon: const Icon(Icons.check_box, size: 18),
                  label: const Text('Select All'),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearAllOrganisms,
                  icon: const Icon(Icons.check_box_outline_blank, size: 18),
                  label: const Text('Clear All'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.medium),

          // Gram-Negative Bacteria
          _buildOrganismCategoryCard(
            title: 'Gram-Negative Bacteria',
            organisms: OrganismDefinitions.gramNegative,
            color: Colors.red,
          ),

          const SizedBox(height: AppSpacing.medium),

          // Gram-Positive Bacteria
          _buildOrganismCategoryCard(
            title: 'Gram-Positive Bacteria',
            organisms: OrganismDefinitions.gramPositive,
            color: Colors.blue,
          ),

          const SizedBox(height: AppSpacing.medium),

          // Candida Species
          _buildOrganismCategoryCard(
            title: 'Candida Species',
            organisms: OrganismDefinitions.other,
            color: Colors.purple,
          ),

          const SizedBox(height: AppSpacing.medium),

          // Selection Summary
          if (_selectedOrganisms.isNotEmpty)
            Card(
              color: AppColors.success.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      child: Text(
                        '${_selectedOrganisms.length} organism(s) selected',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrganismCategoryCard({
    required String title,
    required List<OrganismDefinition> organisms,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${organisms.where((o) => _selectedOrganisms.contains(o.id)).length}/${organisms.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ...organisms.map((organism) {
              final isSelected = _selectedOrganisms.contains(organism.id);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      if (value == true) {
                        _selectedOrganisms.add(organism.id);
                      } else {
                        _selectedOrganisms.remove(organism.id);
                      }
                    });
                  }
                },
                title: Text(organism.name),
                subtitle: organism.abbreviation != null
                    ? Text(organism.abbreviation ?? '')
                    : null,
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 2: SMART PANEL SELECTION
  // ═══════════════════════════════════════════════════════════

  Widget _buildSmartPanelSelectionStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel Selection Mode
          _buildSectionCard(
            title: 'Panel Selection Mode',
            icon: Icons.tune_outlined,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'smart',
                    label: Text('Smart'),
                    icon: Icon(Icons.auto_awesome, size: 18),
                  ),
                  ButtonSegment(
                    value: 'all',
                    label: Text('All'),
                    icon: Icon(Icons.list, size: 18),
                  ),
                ],
                selected: {_panelSelectionMode},
                onSelectionChanged: (Set<String> newSelection) {
                  if (mounted) {
                    setState(() {
                      _panelSelectionMode = newSelection.first;
                      _updateSelectedAntibiotics();
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.small),
              if (_panelSelectionMode == 'smart')
                Text(
                  'Organism-specific panels based on CLSI M100-2025 guidelines',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Text(
                  'All available antibiotics (excluding intrinsic resistance)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.medium),

          // Smart Panel Configuration (only shown in smart mode)
          if (_panelSelectionMode == 'smart') ...[
            _buildSectionCard(
              title: 'Specimen Type',
              icon: Icons.science_outlined,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedSpecimenType,
                  decoration: const InputDecoration(
                    labelText: 'Specimen Source',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Sources')),
                    DropdownMenuItem(value: 'blood', child: Text('Blood')),
                    DropdownMenuItem(value: 'urine', child: Text('Urine')),
                    DropdownMenuItem(value: 'respiratory', child: Text('Respiratory')),
                    DropdownMenuItem(value: 'wound', child: Text('Wound')),
                    DropdownMenuItem(value: 'csf', child: Text('CSF')),
                  ],
                  onChanged: (value) {
                    if (value != null && mounted) {
                      setState(() {
                        _selectedSpecimenType = value;
                        _updateSelectedAntibiotics();
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.medium),

            _buildSectionCard(
              title: 'Antibiotic Tiers (CLSI M100-2025)',
              icon: Icons.layers_outlined,
              children: [
                CheckboxListTile(
                  value: _selectedTiers.contains('classA'),
                  onChanged: (value) => _toggleTier('classA', value),
                  title: const Text('Class A - Primary Agents'),
                  subtitle: const Text('First-line antibiotics'),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _selectedTiers.contains('classB'),
                  onChanged: (value) => _toggleTier('classB', value),
                  title: const Text('Class B - Alternative Agents'),
                  subtitle: const Text('Second-line antibiotics'),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _selectedTiers.contains('classC'),
                  onChanged: (value) => _toggleTier('classC', value),
                  title: const Text('Class C - Supplementary Agents'),
                  subtitle: const Text('Additional testing options'),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _selectedTiers.contains('classU'),
                  onChanged: (value) => _toggleTier('classU', value),
                  title: const Text('Class U - Urine-Only Agents'),
                  subtitle: const Text('For urinary tract infections'),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _selectedTiers.contains('classO'),
                  onChanged: (value) => _toggleTier('classO', value),
                  title: const Text('Class O - Other Agents'),
                  subtitle: const Text('Colistin, tigecycline, etc.'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.medium),

          // Summary
          Card(
            color: AppColors.info.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: AppSpacing.small),
                      const Text(
                        'Panel Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    _getPanelSummary(),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 3: DATA ENTRY
  // ═══════════════════════════════════════════════════════════

  Widget _buildDataEntryStep() {
    if (_antibiogramData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'No data entry fields available',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Please go back and select organisms and antibiotics',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            color: AppColors.info.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Text(
                      'Enter susceptibility data for ${_antibiogramData.length} organism-antibiotic combinations. S + I + R must equal Total.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.medium),

          // Data Entry Cards (grouped by organism)
          ..._buildDataEntryCards(),
        ],
      ),
    );
  }

  List<Widget> _buildDataEntryCards() {
    final Map<String, List<Map<String, dynamic>>> dataByOrganism = {};

    for (final entry in _antibiogramData) {
      final organismId = entry['organismId'] as String;
      dataByOrganism.putIfAbsent(organismId, () => []).add(entry);
    }

    final widgets = <Widget>[];

    for (final entry in dataByOrganism.entries) {
      final organismId = entry.key;
      final organismData = entry.value;
      final organism = OrganismDefinitions.getById(organismId);

      if (organism == null) continue;

      widgets.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organism.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                ...organismData.map((data) => _buildDataEntryRow(data)),
              ],
            ),
          ),
        ),
      );

      widgets.add(const SizedBox(height: AppSpacing.medium));
    }

    return widgets;
  }

  Widget _buildDataEntryRow(Map<String, dynamic> data) {
    final antibioticId = data['antibioticId'] as String;
    final antibiotic = AntibioticDefinitions.getById(antibioticId);

    if (antibiotic == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            antibiotic.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'S',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    data['susceptibleCount'] = int.tryParse(value) ?? 0;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'I',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    data['intermediateCount'] = int.tryParse(value) ?? 0;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'R',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    data['resistantCount'] = int.tryParse(value) ?? 0;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Total',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    data['totalIsolates'] = int.tryParse(value) ?? 0;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 4: RESULTS
  // ═══════════════════════════════════════════════════════════

  Widget _buildResultsStep() {
    if (_antibiogramData.isEmpty || _antibiogramData.every((d) => (d['totalIsolates'] as int) == 0)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'No results to display',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Please go back and enter susceptibility data',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with View Mode Toggle
          _buildResultsHeader(),

          const SizedBox(height: AppSpacing.medium),

          // Legend
          _buildLegend(),

          const SizedBox(height: AppSpacing.medium),

          // Antibiogram Display (List or Table view)
          if (_resultsViewMode == 'list')
            _buildAntibiogramListView()
          else
            RepaintBoundary(
              key: _tableViewKey,
              child: _buildAntibiogramTableView(),
            ),

          const SizedBox(height: AppSpacing.large),

          // Export Buttons
          _buildExportButtons(),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
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
                        _facilityNameController.text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        'Cumulative Antibiogram Report',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // View Mode Toggle
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildViewModeButton(
                        icon: Icons.view_list,
                        label: 'List',
                        isSelected: _resultsViewMode == 'list',
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              _resultsViewMode = 'list';
                            });
                          }
                        },
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: AppColors.textSecondary.withValues(alpha: 0.2),
                      ),
                      _buildViewModeButton(
                        icon: Icons.table_chart,
                        label: 'Table',
                        isSelected: _resultsViewMode == 'table',
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              _resultsViewMode = 'table';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Row(
              children: [
                Icon(Icons.business, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.small),
                Text('Unit: $_selectedUnit'),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.small),
                Text(
                  _dateRange != null
                      ? 'Period: ${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                      : 'Period: Not specified',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Row(
              children: [
                Icon(Icons.science, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.small),
                Text('Specimen: $_selectedSpecimenSource'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            const Text(
              'Legend: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildLegendItem('≥90%', Colors.green),
            _buildLegendItem('80-89%', Colors.yellow.shade700),
            _buildLegendItem('60-79%', Colors.orange),
            _buildLegendItem('<60%', Colors.red),
            _buildLegendItem('N<30', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // NAVIGATION BUTTONS
  // ═══════════════════════════════════════════════════════════

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleNext,
              icon: Icon(_currentStep == 4 ? Icons.check : Icons.arrow_forward),
              label: Text(_currentStep == 4 ? 'Done' : 'Next'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // NAVIGATION HANDLERS
  // ═══════════════════════════════════════════════════════════

  void _handleNext() {
    // Validate current step before proceeding
    if (_currentStep == 0 && !_validateStep0()) {
      return;
    }
    if (_currentStep == 1 && !_validateStep1()) {
      return;
    }
    if (_currentStep == 2 && !_validateStep2()) {
      return;
    }
    if (_currentStep == 3 && !_validateStep3()) {
      return;
    }

    // Update selected antibiotics when moving from Step 1 to Step 2
    if (_currentStep == 1) {
      _updateSelectedAntibiotics();
    }

    // Initialize data entry when moving from Step 2 to Step 3
    if (_currentStep == 2) {
      _initializeDataEntry();
    }

    // Generate results when moving from Step 3 to Step 4
    if (_currentStep == 3) {
      _generateResults();
    }

    if (_currentStep < 4) {
      if (mounted) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      // Done - return to previous screen
      Navigator.of(context).pop();
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      if (mounted) {
        setState(() {
          _currentStep--;
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppSpacing.small),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _dateRange ?? DateTimeRange(start: oneYearAgo, end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _validateStep0() {
    if (_facilityNameController.text.trim().isEmpty) {
      _showError('Please enter facility name');
      return false;
    }
    if (_dateRange == null) {
      _showError('Please select date range');
      return false;
    }
    return true;
  }

  bool _validateStep1() {
    if (_selectedOrganisms.isEmpty) {
      _showError('Please select at least one organism');
      return false;
    }
    return true;
  }

  void _selectAllOrganisms() {
    if (mounted) {
      setState(() {
        _selectedOrganisms.clear();
        _selectedOrganisms.addAll(OrganismDefinitions.all.map((o) => o.id));
      });
    }
  }

  void _clearAllOrganisms() {
    if (mounted) {
      setState(() {
        _selectedOrganisms.clear();
      });
    }
  }

  void _updateSelectedAntibiotics() {
    _selectedAntibioticsPerOrganism.clear();

    for (final organismId in _selectedOrganisms) {
      _selectedAntibioticsPerOrganism[organismId] = _getAntibioticsForOrganism(organismId);
    }
  }

  List<String> _getAntibioticsForOrganism(String organismId) {
    if (_panelSelectionMode == 'all') {
      // Return all antibiotics except intrinsically resistant ones
      return AntibioticDefinitions.all
          .where((abx) => !IntrinsicResistanceMatrix.isIntrinsicallyResistant(organismId, abx.id))
          .map((abx) => abx.id)
          .toList();
    } else if (_panelSelectionMode == 'smart') {
      // Get smart panel based on specimen type
      final panel = TieredAntibioticPanels.getPanel(
        organismId: organismId,
        specimenSource: _selectedSpecimenType,
      );

      if (panel == null) return [];

      // Filter by selected tiers
      final antibiotics = <String>[];
      for (final tierString in _selectedTiers) {
        final tier = _parseTier(tierString);
        antibiotics.addAll(panel.antibioticsByTier[tier] ?? []);
      }

      return antibiotics;
    } else {
      // Custom mode: return manually selected antibiotics
      return _selectedAntibioticsPerOrganism[organismId] ?? [];
    }
  }

  AntibioticTier _parseTier(String tierString) {
    switch (tierString) {
      case 'classA':
        return AntibioticTier.classA;
      case 'classB':
        return AntibioticTier.classB;
      case 'classC':
        return AntibioticTier.classC;
      case 'classU':
        return AntibioticTier.classU;
      case 'classO':
        return AntibioticTier.classO;
      default:
        return AntibioticTier.classA;
    }
  }

  void _toggleTier(String tier, bool? value) {
    if (value == null) return;

    if (mounted) {
      setState(() {
        if (value) {
          _selectedTiers.add(tier);
        } else {
          _selectedTiers.remove(tier);
        }
        _updateSelectedAntibiotics();
      });
    }
  }

  String _getPanelSummary() {
    if (_panelSelectionMode == 'all') {
      int totalAntibiotics = 0;
      for (final organismId in _selectedOrganisms) {
        totalAntibiotics += _getAntibioticsForOrganism(organismId).length;
      }
      return 'All available antibiotics will be included for ${_selectedOrganisms.length} organism(s). Total combinations: $totalAntibiotics';
    } else {
      int totalAntibiotics = 0;
      for (final organismId in _selectedOrganisms) {
        totalAntibiotics += _getAntibioticsForOrganism(organismId).length;
      }
      return 'Smart panels configured for ${_selectedOrganisms.length} organism(s) with ${_selectedTiers.length} tier(s) selected. Total combinations: $totalAntibiotics';
    }
  }

  bool _validateStep2() {
    if (_panelSelectionMode == 'smart' && _selectedTiers.isEmpty) {
      _showError('Please select at least one antibiotic tier');
      return false;
    }
    return true;
  }

  void _initializeDataEntry() {
    _antibiogramData.clear();

    for (final organismId in _selectedOrganisms) {
      final organism = OrganismDefinitions.getById(organismId);
      if (organism == null) continue;

      final antibiotics = _selectedAntibioticsPerOrganism[organismId] ?? [];

      for (final antibioticId in antibiotics) {
        final antibiotic = AntibioticDefinitions.getById(antibioticId);
        if (antibiotic == null) continue;

        // Skip intrinsically resistant combinations
        if (_clinicallyRelevantOnly &&
            IntrinsicResistanceMatrix.isIntrinsicallyResistant(organismId, antibioticId)) {
          continue;
        }

        _antibiogramData.add({
          'organismId': organismId,
          'organismName': organism.name,
          'antibioticId': antibioticId,
          'antibioticName': antibiotic.name,
          'susceptibleCount': 0,
          'intermediateCount': 0,
          'resistantCount': 0,
          'totalIsolates': 0,
        });
      }
    }
  }

  bool _validateStep3() {
    // Check if at least some data has been entered
    final hasData = _antibiogramData.any((data) => (data['totalIsolates'] as int) > 0);

    if (!hasData) {
      _showError('Please enter data for at least one organism-antibiotic combination');
      return false;
    }

    return true;
  }

  void _generateResults() {
    // Results are already in _antibiogramData
    // This method can be used for additional processing if needed
  }

  // ═══════════════════════════════════════════════════════════
  // LIST VIEW (Detailed Cards)
  // ═══════════════════════════════════════════════════════════

  Widget _buildAntibiogramListView() {
    // Group data by organism category (Gram-negative, Gram-positive, Other/Candida)
    final Map<String, Map<String, List<Map<String, dynamic>>>> dataByCategory = {
      'gram-negative': {},
      'gram-positive': {},
      'other': {},
    };

    for (final entry in _antibiogramData) {
      if ((entry['totalIsolates'] as int) > 0) {
        final organismId = entry['organismId'] as String;
        final organism = OrganismDefinitions.getById(organismId);

        if (organism != null) {
          final category = organism.category;
          dataByCategory[category]!.putIfAbsent(organismId, () => []).add(entry);
        }
      }
    }

    // Check if we have any data
    final hasData = dataByCategory.values.any((cat) => cat.isNotEmpty);
    if (!hasData) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gram-Negative Section
        if (dataByCategory['gram-negative']!.isNotEmpty)
          _buildCategorySection(
            'Hospital-Wide Gram-Negative (GNR)',
            dataByCategory['gram-negative']!,
            AppColors.error.withValues(alpha: 0.1),
          ),

        if (dataByCategory['gram-negative']!.isNotEmpty &&
            (dataByCategory['gram-positive']!.isNotEmpty || dataByCategory['other']!.isNotEmpty))
          const SizedBox(height: AppSpacing.large),

        // Gram-Positive Section
        if (dataByCategory['gram-positive']!.isNotEmpty)
          _buildCategorySection(
            'Hospital-Wide Gram-Positive (GPC)',
            dataByCategory['gram-positive']!,
            AppColors.info.withValues(alpha: 0.1),
          ),

        if (dataByCategory['gram-positive']!.isNotEmpty && dataByCategory['other']!.isNotEmpty)
          const SizedBox(height: AppSpacing.large),

        // Candida/Other Section
        if (dataByCategory['other']!.isNotEmpty)
          _buildCategorySection(
            'Fungal Infections',
            dataByCategory['other']!,
            AppColors.warning.withValues(alpha: 0.1),
          ),
      ],
    );
  }

  Widget _buildCategorySection(
    String title,
    Map<String, List<Map<String, dynamic>>> dataByOrganism,
    Color backgroundColor,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Organism Data
          Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dataByOrganism.entries.map((entry) {
                final organismId = entry.key;
                final organismData = entry.value;
                final organism = OrganismDefinitions.getById(organismId);

                if (organism == null) {
                  return const SizedBox.shrink();
                }

                // Calculate total isolates for this organism
                final totalOrganismIsolates = organismData.isNotEmpty
                    ? (organismData.first['totalIsolates'] as int)
                    : 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Organism name with isolate count
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            organism.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'n=$totalOrganismIsolates',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),

                    // Antibiotic susceptibility data
                    ...organismData.map((data) {
                      final antibioticId = data['antibioticId'] as String;
                      final antibiotic = AntibioticDefinitions.getById(antibioticId);

                      if (antibiotic == null) {
                        return const SizedBox.shrink();
                      }

                      final susceptibleCount = data['susceptibleCount'] as int;
                      final totalIsolates = data['totalIsolates'] as int;

                      final percentage = totalIsolates > 0
                          ? (susceptibleCount / totalIsolates * 100).round()
                          : 0;

                      final color = _getSusceptibilityColor(percentage.toDouble(), totalIsolates);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.small),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                antibiotic.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.small),
                            Container(
                              width: 70,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                totalIsolates < 30 ? 'N<30' : '$percentage%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.medium),
                    const Divider(),
                    const SizedBox(height: AppSpacing.small),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TABLE VIEW (CLSI Format: Organisms × Antibiotics)
  // ═══════════════════════════════════════════════════════════

  Widget _buildAntibiogramTableView() {
    // Group data by organism category
    final Map<String, Map<String, List<Map<String, dynamic>>>> dataByCategory = {
      'gram-negative': {},
      'gram-positive': {},
      'other': {},
    };

    for (final entry in _antibiogramData) {
      if ((entry['totalIsolates'] as int) > 0) {
        final organismId = entry['organismId'] as String;
        final organism = OrganismDefinitions.getById(organismId);

        if (organism != null) {
          final category = organism.category;
          dataByCategory[category]!.putIfAbsent(organismId, () => []).add(entry);
        }
      }
    }

    // Check if we have any data
    final hasData = dataByCategory.values.any((cat) => cat.isNotEmpty);
    if (!hasData) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gram-Negative Table
        if (dataByCategory['gram-negative']!.isNotEmpty)
          _buildCLSITable(
            'Hospital-Wide Gram-Negative (GNR)',
            dataByCategory['gram-negative']!,
            AppColors.error.withValues(alpha: 0.1),
          ),

        if (dataByCategory['gram-negative']!.isNotEmpty &&
            (dataByCategory['gram-positive']!.isNotEmpty || dataByCategory['other']!.isNotEmpty))
          const SizedBox(height: AppSpacing.large),

        // Gram-Positive Table
        if (dataByCategory['gram-positive']!.isNotEmpty)
          _buildCLSITable(
            'Hospital-Wide Gram-Positive (GPC)',
            dataByCategory['gram-positive']!,
            AppColors.info.withValues(alpha: 0.1),
          ),

        if (dataByCategory['gram-positive']!.isNotEmpty && dataByCategory['other']!.isNotEmpty)
          const SizedBox(height: AppSpacing.large),

        // Candida/Other Table
        if (dataByCategory['other']!.isNotEmpty)
          _buildCLSITable(
            'Fungal Infections',
            dataByCategory['other']!,
            AppColors.warning.withValues(alpha: 0.1),
          ),
      ],
    );
  }

  Widget _buildCLSITable(
    String title,
    Map<String, List<Map<String, dynamic>>> dataByOrganism,
    Color backgroundColor,
  ) {
    // Get all unique antibiotics for this category
    final Set<String> allAntibioticIds = {};
    for (final organismData in dataByOrganism.values) {
      for (final data in organismData) {
        allAntibioticIds.add(data['antibioticId'] as String);
      }
    }

    final antibioticsList = allAntibioticIds.toList();

    // Build data matrix: organism -> antibiotic -> data
    final Map<String, Map<String, Map<String, dynamic>>> dataMatrix = {};
    for (final entry in dataByOrganism.entries) {
      final organismId = entry.key;
      dataMatrix[organismId] = {};

      for (final data in entry.value) {
        final antibioticId = data['antibioticId'] as String;
        dataMatrix[organismId]![antibioticId] = data;
      }
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Horizontal Scrollable Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  AppColors.primary.withValues(alpha: 0.1),
                ),
                border: TableBorder.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.2),
                  width: 1,
                ),
                columns: [
                  // Organism column
                  const DataColumn(
                    label: Text(
                      'Organism',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Antibiotic columns
                  ...antibioticsList.map((antibioticId) {
                    final antibiotic = AntibioticDefinitions.getById(antibioticId);
                    return DataColumn(
                      label: Text(
                        antibiotic?.abbreviation ?? antibioticId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                  // N Tested column
                  const DataColumn(
                    label: Text(
                      'N Tested',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                rows: dataByOrganism.keys.map((organismId) {
                  final organism = OrganismDefinitions.getById(organismId);
                  final organismData = dataMatrix[organismId]!;

                  // Get total isolates for this organism
                  final totalIsolates = organismData.values.isNotEmpty
                      ? (organismData.values.first['totalIsolates'] as int)
                      : 0;

                  return DataRow(
                    cells: [
                      // Organism name cell
                      DataCell(
                        Text(
                          organism?.name ?? organismId,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      // Antibiotic susceptibility cells
                      ...antibioticsList.map((antibioticId) {
                        final data = organismData[antibioticId];

                        if (data == null) {
                          // No data for this combination
                          return const DataCell(
                            Center(
                              child: Text(
                                '—',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }

                        final susceptibleCount = data['susceptibleCount'] as int;
                        final totalIsolates = data['totalIsolates'] as int;

                        if (totalIsolates == 0) {
                          return const DataCell(
                            Center(
                              child: Text(
                                '—',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }

                        final percentage = (susceptibleCount / totalIsolates * 100).round();
                        final color = _getSusceptibilityColor(percentage.toDouble(), totalIsolates);

                        return DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              totalIsolates < 30 ? 'N<30' : '$percentage%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }),
                      // N Tested cell
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            totalIsolates.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSusceptibilityColor(double percentage, int totalIsolates) {
    if (totalIsolates < 30) {
      return Colors.grey;
    } else if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 80) {
      return Colors.yellow.shade700;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildExportButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.small),
                      Text(
                        'Export your antibiogram in various formats',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isExporting)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _exportToPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF'),
                ),
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _exportToExcel,
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Excel'),
                ),
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _exportToCSV,
                  icon: const Icon(Icons.description),
                  label: const Text('CSV'),
                ),
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _exportToTXT,
                  icon: const Icon(Icons.text_snippet),
                  label: const Text('TXT'),
                ),
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _exportToImage,
                  icon: const Icon(Icons.image),
                  label: const Text('PNG'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EXPORT FUNCTIONALITY
  // ═══════════════════════════════════════════════════════════

  /// Helper method to organize data by category for export
  Map<String, Map<String, List<Map<String, dynamic>>>> _getOrganizedDataForExport() {
    final Map<String, Map<String, List<Map<String, dynamic>>>> dataByCategory = {
      'gram-negative': {},
      'gram-positive': {},
      'other': {},
    };

    for (final entry in _antibiogramData) {
      if ((entry['totalIsolates'] as int) > 0) {
        final organismId = entry['organismId'] as String;
        final organism = OrganismDefinitions.getById(organismId);

        if (organism != null) {
          final category = organism.category;
          dataByCategory[category]!.putIfAbsent(organismId, () => []).add(entry);
        }
      }
    }

    return dataByCategory;
  }

  /// Helper method to get metadata for export
  Map<String, String> _getExportMetadata() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return {
      'facilityName': _facilityNameController.text,
      'unit': _selectedUnit,
      'dateRange': _dateRange != null
          ? '${dateFormat.format(_dateRange!.start)} - ${dateFormat.format(_dateRange!.end)}'
          : 'Not specified',
      'specimenSource': _selectedSpecimenSource,
      'generatedDate': dateFormat.format(DateTime.now()),
      'generatedTime': DateFormat('hh:mm a').format(DateTime.now()),
      'guidelines': [
        if (_applyFirstIsolateRule) 'First Isolate Rule',
        if (_excludeDuplicates) 'Exclude Duplicates',
        if (_minimumThreshold) 'Minimum 30 Isolates',
        if (_clinicallyRelevantOnly) 'Clinically Relevant Only',
      ].join(', '),
    };
  }

  /// Helper method to calculate susceptibility percentage
  String _calculatePercentage(Map<String, dynamic> data) {
    final susceptible = data['susceptibleCount'] as int;
    final total = data['totalIsolates'] as int;
    if (total == 0) return '—';
    final percentage = (susceptible / total * 100).round();
    return '$percentage%';
  }

  // ───────────────────────────────────────────────────────────
  // PDF EXPORT
  // ───────────────────────────────────────────────────────────

  Future<void> _exportToPDF() async {
    try {
      setState(() => _isExporting = true);

      final metadata = _getExportMetadata();
      final dataByCategory = _getOrganizedDataForExport();

      // Check if we have data
      final hasData = dataByCategory.values.any((cat) => cat.isNotEmpty);
      if (!hasData) {
        _showError('No data to export');
        setState(() => _isExporting = false);
        return;
      }

      // Create PDF document
      final pdf = pw.Document();

      // Add pages for each category
      if (dataByCategory['gram-negative']!.isNotEmpty) {
        pdf.addPage(_buildPDFPage(
          'Hospital-Wide Gram-Negative (GNR)',
          dataByCategory['gram-negative']!,
          metadata,
          isFirstPage: true,
        ));
      }

      if (dataByCategory['gram-positive']!.isNotEmpty) {
        pdf.addPage(_buildPDFPage(
          'Hospital-Wide Gram-Positive (GPC)',
          dataByCategory['gram-positive']!,
          metadata,
          isFirstPage: dataByCategory['gram-negative']!.isEmpty,
        ));
      }

      if (dataByCategory['other']!.isNotEmpty) {
        pdf.addPage(_buildPDFPage(
          'Fungal Infections',
          dataByCategory['other']!,
          metadata,
          isFirstPage: dataByCategory['gram-negative']!.isEmpty &&
              dataByCategory['gram-positive']!.isEmpty,
        ));
      }

      // Save PDF
      final output = await getTemporaryDirectory();
      final fileName = 'Antibiogram_${metadata['facilityName']}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Share the file
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(ui.Offset.zero) & box.size) : const ui.Rect.fromLTWH(0, 0, 1, 1);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Cumulative Antibiogram Report',
        text: 'Antibiogram report for ${metadata['facilityName']}',
        sharePositionOrigin: origin,
      );

      _showSuccess('PDF exported successfully');
    } catch (e) {
      _showError('Failed to export PDF: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  pw.Page _buildPDFPage(
    String title,
    Map<String, List<Map<String, dynamic>>> dataByOrganism,
    Map<String, String> metadata, {
    required bool isFirstPage,
  }) {
    // Get all unique antibiotics
    final Set<String> allAntibioticIds = {};
    for (final organismData in dataByOrganism.values) {
      for (final data in organismData) {
        allAntibioticIds.add(data['antibioticId'] as String);
      }
    }
    final antibioticsList = allAntibioticIds.toList();

    // Build data matrix
    final Map<String, Map<String, Map<String, dynamic>>> dataMatrix = {};
    for (final entry in dataByOrganism.entries) {
      final organismId = entry.key;
      dataMatrix[organismId] = {};
      for (final data in entry.value) {
        final antibioticId = data['antibioticId'] as String;
        dataMatrix[organismId]![antibioticId] = data;
      }
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header (only on first page)
            if (isFirstPage) ...[
              pw.Text(
                metadata['facilityName']!,
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Cumulative Antibiogram Report',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Unit: ${metadata['unit']}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Date Range: ${metadata['dateRange']}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Specimen: ${metadata['specimenSource']}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Generated: ${metadata['generatedDate']}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Guidelines: ${metadata['guidelines']}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
            ],

            // Section title
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            // Table
            pw.Expanded(
              child: pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  for (int i = 0; i < antibioticsList.length; i++)
                    i + 1: const pw.FlexColumnWidth(1),
                  antibioticsList.length + 1: const pw.FixedColumnWidth(50),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Organism', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                      ),
                      ...antibioticsList.map((abxId) {
                        final abx = AntibioticDefinitions.getById(abxId);
                        return pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            abx?.abbreviation ?? abxId.toUpperCase(),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                            textAlign: pw.TextAlign.center,
                          ),
                        );
                      }),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('N', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                      ),
                    ],
                  ),
                  // Data rows
                  ...dataMatrix.entries.map((entry) {
                    final organismId = entry.key;
                    final organism = OrganismDefinitions.getById(organismId);
                    final organismName = organism?.abbreviation ?? organismId;

                    // Calculate total isolates for this organism
                    int totalIsolates = 0;
                    for (final data in entry.value.values) {
                      final count = data['totalIsolates'] as int;
                      if (count > totalIsolates) totalIsolates = count;
                    }

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(organismName, style: const pw.TextStyle(fontSize: 9)),
                        ),
                        ...antibioticsList.map((abxId) {
                          final data = entry.value[abxId];
                          final percentage = data != null ? _calculatePercentage(data) : '—';
                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              percentage,
                              style: const pw.TextStyle(fontSize: 8),
                              textAlign: pw.TextAlign.center,
                            ),
                          );
                        }),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            totalIsolates.toString(),
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────
  // EXCEL EXPORT
  // ───────────────────────────────────────────────────────────

  Future<void> _exportToExcel() async {
    try {
      setState(() => _isExporting = true);

      final metadata = _getExportMetadata();
      final dataByCategory = _getOrganizedDataForExport();

      // Check if we have data
      final hasData = dataByCategory.values.any((cat) => cat.isNotEmpty);
      if (!hasData) {
        _showError('No data to export');
        setState(() => _isExporting = false);
        return;
      }

      // Create Excel workbook
      final excel = excel_pkg.Excel.createExcel();

      // Remove default sheet
      excel.delete('Sheet1');

      // Add sheets for each category
      if (dataByCategory['gram-negative']!.isNotEmpty) {
        _addExcelSheet(
          excel,
          'Gram-Negative',
          'Hospital-Wide Gram-Negative (GNR)',
          dataByCategory['gram-negative']!,
          metadata,
        );
      }

      if (dataByCategory['gram-positive']!.isNotEmpty) {
        _addExcelSheet(
          excel,
          'Gram-Positive',
          'Hospital-Wide Gram-Positive (GPC)',
          dataByCategory['gram-positive']!,
          metadata,
        );
      }

      if (dataByCategory['other']!.isNotEmpty) {
        _addExcelSheet(
          excel,
          'Candida',
          'Fungal Infections',
          dataByCategory['other']!,
          metadata,
        );
      }

      // Save Excel file
      final output = await getTemporaryDirectory();
      final fileName = 'Antibiogram_${metadata['facilityName']}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${output.path}/$fileName');
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);

        // Share the file
        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null ? (box.localToGlobal(ui.Offset.zero) & box.size) : const ui.Rect.fromLTWH(0, 0, 1, 1);
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Cumulative Antibiogram Report',
          text: 'Antibiogram report for ${metadata['facilityName']}',
          sharePositionOrigin: origin,
        );

        _showSuccess('Excel file exported successfully');
      } else {
        _showError('Failed to generate Excel file');
      }
    } catch (e) {
      _showError('Failed to export Excel: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _addExcelSheet(
    excel_pkg.Excel excel,
    String sheetName,
    String title,
    Map<String, List<Map<String, dynamic>>> dataByOrganism,
    Map<String, String> metadata,
  ) {
    final sheet = excel[sheetName];

    int currentRow = 0;

    // Add metadata header
    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
      ..value = excel_pkg.TextCellValue(metadata['facilityName']!)
      ..cellStyle = excel_pkg.CellStyle(bold: true, fontSize: 16);
    currentRow++;

    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
      ..value = excel_pkg.TextCellValue('Cumulative Antibiogram Report')
      ..cellStyle = excel_pkg.CellStyle(fontSize: 12);
    currentRow++;

    currentRow++; // Empty row

    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = excel_pkg.TextCellValue('Unit: ${metadata['unit']}');
    currentRow++;

    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = excel_pkg.TextCellValue('Date Range: ${metadata['dateRange']}');
    currentRow++;

    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = excel_pkg.TextCellValue('Specimen: ${metadata['specimenSource']}');
    currentRow++;

    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = excel_pkg.TextCellValue('Generated: ${metadata['generatedDate']}');
    currentRow++;

    currentRow++; // Empty row

    // Add section title
    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
      ..value = excel_pkg.TextCellValue(title)
      ..cellStyle = excel_pkg.CellStyle(bold: true, fontSize: 14);
    currentRow++;

    currentRow++; // Empty row

    // Get all unique antibiotics
    final Set<String> allAntibioticIds = {};
    for (final organismData in dataByOrganism.values) {
      for (final data in organismData) {
        allAntibioticIds.add(data['antibioticId'] as String);
      }
    }
    final antibioticsList = allAntibioticIds.toList();

    // Build data matrix
    final Map<String, Map<String, Map<String, dynamic>>> dataMatrix = {};
    for (final entry in dataByOrganism.entries) {
      final organismId = entry.key;
      dataMatrix[organismId] = {};
      for (final data in entry.value) {
        final antibioticId = data['antibioticId'] as String;
        dataMatrix[organismId]![antibioticId] = data;
      }
    }

    // Add table header
    int col = 0;
    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow))
      ..value = excel_pkg.TextCellValue('Organism')
      ..cellStyle = excel_pkg.CellStyle(bold: true);

    for (final abxId in antibioticsList) {
      final abx = AntibioticDefinitions.getById(abxId);
      sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow))
        ..value = excel_pkg.TextCellValue(abx?.abbreviation ?? abxId.toUpperCase())
        ..cellStyle = excel_pkg.CellStyle(bold: true);
    }

    sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow))
      ..value = excel_pkg.TextCellValue('N Tested')
      ..cellStyle = excel_pkg.CellStyle(bold: true);

    currentRow++;

    // Add data rows
    for (final entry in dataMatrix.entries) {
      final organismId = entry.key;
      final organism = OrganismDefinitions.getById(organismId);
      final organismName = organism?.abbreviation ?? organismId;

      // Calculate total isolates
      int totalIsolates = 0;
      for (final data in entry.value.values) {
        final count = data['totalIsolates'] as int;
        if (count > totalIsolates) totalIsolates = count;
      }

      col = 0;
      sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow))
          .value = excel_pkg.TextCellValue(organismName);

      for (final abxId in antibioticsList) {
        final data = entry.value[abxId];
        final percentage = data != null ? _calculatePercentage(data) : '—';
        sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow))
            .value = excel_pkg.TextCellValue(percentage);
      }

      sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow))
          .value = excel_pkg.TextCellValue(totalIsolates.toString());

      currentRow++;
    }
  }

  // ───────────────────────────────────────────────────────────
  // CSV EXPORT
  // ───────────────────────────────────────────────────────────

  Future<void> _exportToCSV() async {
    try {
      setState(() => _isExporting = true);

      final metadata = _getExportMetadata();
      final dataByCategory = _getOrganizedDataForExport();

      // Check if we have data
      final hasData = dataByCategory.values.any((cat) => cat.isNotEmpty);
      if (!hasData) {
        _showError('No data to export');
        setState(() => _isExporting = false);
        return;
      }

      final output = await getTemporaryDirectory();
      final List<XFile> files = [];

      // Create CSV for each category
      if (dataByCategory['gram-negative']!.isNotEmpty) {
        final file = await _createCSVFile(
          output.path,
          'GramNegative',
          'Hospital-Wide Gram-Negative (GNR)',
          dataByCategory['gram-negative']!,
          metadata,
        );
        files.add(XFile(file.path));
      }

      if (dataByCategory['gram-positive']!.isNotEmpty) {
        final file = await _createCSVFile(
          output.path,
          'GramPositive',
          'Hospital-Wide Gram-Positive (GPC)',
          dataByCategory['gram-positive']!,
          metadata,
        );
        files.add(XFile(file.path));
      }

      if (dataByCategory['other']!.isNotEmpty) {
        final file = await _createCSVFile(
          output.path,
          'Candida',
          'Fungal Infections',
          dataByCategory['other']!,
          metadata,
        );
        files.add(XFile(file.path));
      }

      // Share the files
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(ui.Offset.zero) & box.size) : const ui.Rect.fromLTWH(0, 0, 1, 1);
      await Share.shareXFiles(
        files,
        subject: 'Cumulative Antibiogram Report (CSV)',
        text: 'Antibiogram report for ${metadata['facilityName']}',
        sharePositionOrigin: origin,
      );

      _showSuccess('CSV files exported successfully');
    } catch (e) {
      _showError('Failed to export CSV: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<File> _createCSVFile(
    String outputPath,
    String filePrefix,
    String title,
    Map<String, List<Map<String, dynamic>>> dataByOrganism,
    Map<String, String> metadata,
  ) async {
    final List<List<dynamic>> rows = [];

    // Add metadata
    rows.add(['Facility', metadata['facilityName']]);
    rows.add(['Unit', metadata['unit']]);
    rows.add(['Date Range', metadata['dateRange']]);
    rows.add(['Specimen', metadata['specimenSource']]);
    rows.add(['Generated', metadata['generatedDate']]);
    rows.add([]); // Empty row
    rows.add([title]);
    rows.add([]); // Empty row

    // Get all unique antibiotics
    final Set<String> allAntibioticIds = {};
    for (final organismData in dataByOrganism.values) {
      for (final data in organismData) {
        allAntibioticIds.add(data['antibioticId'] as String);
      }
    }
    final antibioticsList = allAntibioticIds.toList();

    // Build data matrix
    final Map<String, Map<String, Map<String, dynamic>>> dataMatrix = {};
    for (final entry in dataByOrganism.entries) {
      final organismId = entry.key;
      dataMatrix[organismId] = {};
      for (final data in entry.value) {
        final antibioticId = data['antibioticId'] as String;
        dataMatrix[organismId]![antibioticId] = data;
      }
    }

    // Add header row
    final headerRow = ['Organism'];
    for (final abxId in antibioticsList) {
      final abx = AntibioticDefinitions.getById(abxId);
      headerRow.add(abx?.abbreviation ?? abxId.toUpperCase());
    }
    headerRow.add('N Tested');
    rows.add(headerRow);

    // Add data rows
    for (final entry in dataMatrix.entries) {
      final organismId = entry.key;
      final organism = OrganismDefinitions.getById(organismId);
      final organismName = organism?.abbreviation ?? organismId;

      // Calculate total isolates
      int totalIsolates = 0;
      for (final data in entry.value.values) {
        final count = data['totalIsolates'] as int;
        if (count > totalIsolates) totalIsolates = count;
      }

      final dataRow = [organismName];
      for (final abxId in antibioticsList) {
        final data = entry.value[abxId];
        final percentage = data != null ? _calculatePercentage(data) : '—';
        dataRow.add(percentage);
      }
      dataRow.add(totalIsolates.toString());
      rows.add(dataRow);
    }

    // Convert to CSV
    final csvData = const ListToCsvConverter().convert(rows);

    // Save file
    final fileName = 'Antibiogram_${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('$outputPath/$fileName');
    await file.writeAsString(csvData);

    return file;
  }

  // ───────────────────────────────────────────────────────────
  // TXT EXPORT
  // ───────────────────────────────────────────────────────────

  Future<void> _exportToTXT() async {
    try {
      setState(() => _isExporting = true);

      final metadata = _getExportMetadata();
      final dataByCategory = _getOrganizedDataForExport();

      // Check if we have data
      final hasData = dataByCategory.values.any((cat) => cat.isNotEmpty);
      if (!hasData) {
        _showError('No data to export');
        setState(() => _isExporting = false);
        return;
      }

      final StringBuffer buffer = StringBuffer();

      // Add header
      buffer.writeln('═══════════════════════════════════════════════════════════');
      buffer.writeln('${metadata['facilityName']}');
      buffer.writeln('Cumulative Antibiogram Report');
      buffer.writeln('═══════════════════════════════════════════════════════════');
      buffer.writeln();
      buffer.writeln('Unit: ${metadata['unit']}');
      buffer.writeln('Date Range: ${metadata['dateRange']}');
      buffer.writeln('Specimen: ${metadata['specimenSource']}');
      buffer.writeln('Generated: ${metadata['generatedDate']} at ${metadata['generatedTime']}');
      buffer.writeln('Guidelines: ${metadata['guidelines']}');
      buffer.writeln();

      // Add each category
      if (dataByCategory['gram-negative']!.isNotEmpty) {
        _addTXTSection(
          buffer,
          'Hospital-Wide Gram-Negative (GNR)',
          dataByCategory['gram-negative']!,
        );
      }

      if (dataByCategory['gram-positive']!.isNotEmpty) {
        _addTXTSection(
          buffer,
          'Hospital-Wide Gram-Positive (GPC)',
          dataByCategory['gram-positive']!,
        );
      }

      if (dataByCategory['other']!.isNotEmpty) {
        _addTXTSection(
          buffer,
          'Fungal Infections',
          dataByCategory['other']!,
        );
      }

      // Save file
      final output = await getTemporaryDirectory();
      final fileName = 'Antibiogram_${metadata['facilityName']}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${output.path}/$fileName');
      await file.writeAsString(buffer.toString());

      // Share the file
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(ui.Offset.zero) & box.size) : const ui.Rect.fromLTWH(0, 0, 1, 1);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Cumulative Antibiogram Report',
        text: 'Antibiogram report for ${metadata['facilityName']}',
        sharePositionOrigin: origin,
      );

      _showSuccess('Text file exported successfully');
    } catch (e) {
      _showError('Failed to export TXT: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _addTXTSection(
    StringBuffer buffer,
    String title,
    Map<String, List<Map<String, dynamic>>> dataByOrganism,
  ) {
    buffer.writeln('───────────────────────────────────────────────────────────');
    buffer.writeln(title);
    buffer.writeln('───────────────────────────────────────────────────────────');
    buffer.writeln();

    // Get all unique antibiotics
    final Set<String> allAntibioticIds = {};
    for (final organismData in dataByOrganism.values) {
      for (final data in organismData) {
        allAntibioticIds.add(data['antibioticId'] as String);
      }
    }
    final antibioticsList = allAntibioticIds.toList();

    // Build data matrix
    final Map<String, Map<String, Map<String, dynamic>>> dataMatrix = {};
    for (final entry in dataByOrganism.entries) {
      final organismId = entry.key;
      dataMatrix[organismId] = {};
      for (final data in entry.value) {
        final antibioticId = data['antibioticId'] as String;
        dataMatrix[organismId]![antibioticId] = data;
      }
    }

    // Create table header
    final List<String> headers = ['Organism'];
    for (final abxId in antibioticsList) {
      final abx = AntibioticDefinitions.getById(abxId);
      headers.add(abx?.abbreviation ?? abxId.toUpperCase());
    }
    headers.add('N');

    // Calculate column widths
    final List<int> columnWidths = headers.map((h) => h.length).toList();

    // Update widths based on data
    for (final entry in dataMatrix.entries) {
      final organism = OrganismDefinitions.getById(entry.key);
      final organismName = organism?.abbreviation ?? entry.key;
      if (organismName.length > columnWidths[0]) {
        columnWidths[0] = organismName.length;
      }
    }

    // Print header
    buffer.write(headers[0].padRight(columnWidths[0] + 2));
    for (int i = 1; i < headers.length; i++) {
      buffer.write(headers[i].padLeft(8));
    }
    buffer.writeln();

    // Print separator
    buffer.writeln('─' * (columnWidths[0] + 2 + (headers.length - 1) * 8));

    // Print data rows
    for (final entry in dataMatrix.entries) {
      final organismId = entry.key;
      final organism = OrganismDefinitions.getById(organismId);
      final organismName = organism?.abbreviation ?? organismId;

      // Calculate total isolates
      int totalIsolates = 0;
      for (final data in entry.value.values) {
        final count = data['totalIsolates'] as int;
        if (count > totalIsolates) totalIsolates = count;
      }

      buffer.write(organismName.padRight(columnWidths[0] + 2));
      for (final abxId in antibioticsList) {
        final data = entry.value[abxId];
        final percentage = data != null ? _calculatePercentage(data) : '—';
        buffer.write(percentage.padLeft(8));
      }
      buffer.write(totalIsolates.toString().padLeft(8));
      buffer.writeln();
    }

    buffer.writeln();
  }

  // ───────────────────────────────────────────────────────────
  // PNG/IMAGE EXPORT
  // ───────────────────────────────────────────────────────────

  Future<void> _exportToImage() async {
    try {
      setState(() => _isExporting = true);

      final metadata = _getExportMetadata();

      // Switch to table view if not already
      final wasListView = _resultsViewMode == 'list';
      if (wasListView) {
        setState(() => _resultsViewMode = 'table');
        // Wait for the UI to update
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Capture the table view
      final RenderRepaintBoundary? boundary = _tableViewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        _showError('Unable to capture table view');
        if (wasListView) {
          setState(() => _resultsViewMode = 'list');
        }
        setState(() => _isExporting = false);
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        _showError('Failed to generate image');
        if (wasListView) {
          setState(() => _resultsViewMode = 'list');
        }
        setState(() => _isExporting = false);
        return;
      }

      // Save image
      final output = await getTemporaryDirectory();
      final fileName = 'Antibiogram_${metadata['facilityName']}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Restore view mode
      if (wasListView) {
        setState(() => _resultsViewMode = 'list');
      }

      // Share the file
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(ui.Offset.zero) & box.size) : const ui.Rect.fromLTWH(0, 0, 1, 1);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Cumulative Antibiogram Report',
        text: 'Antibiogram report for ${metadata['facilityName']}',
        sharePositionOrigin: origin,
      );

      _showSuccess('Image exported successfully');
    } catch (e) {
      _showError('Failed to export image: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD EXAMPLE
  // ═══════════════════════════════════════════════════════════

  void _loadExample() {
    try {
      if (!mounted) return;

      setState(() {
        // STEP 0: Configuration
        _facilityNameController.text = 'General Hospital';
        _selectedUnit = 'Hospital-Wide';
        final now = DateTime.now();
        _dateRange = DateTimeRange(
          start: DateTime(now.year - 1, 1, 1),
          end: DateTime(now.year - 1, 12, 31),
        );
        _selectedSpecimenSource = 'All Specimens';
        _applyFirstIsolateRule = true;
        _excludeDuplicates = true;
        _minimumThreshold = true;
        _clinicallyRelevantOnly = true;

        // STEP 1: Organism Selection (Expanded for comprehensive testing)
        // Total: 24 organisms (12 GNR + 8 GPC + 4 Candida)
        _selectedOrganisms.clear();
        _selectedOrganisms.addAll([
          // ═══════════════════════════════════════════════════════════
          // GRAM-NEGATIVE BACTERIA (12 organisms)
          // ═══════════════════════════════════════════════════════════
          'e-coli',                      // E. coli
          'k-pneumoniae',                // K. pneumoniae
          'p-aeruginosa',                // P. aeruginosa
          'a-baumannii',                 // A. baumannii
          'enterobacter-spp',            // Enterobacter spp.
          'proteus-mirabilis',           // P. mirabilis
          'serratia-marcescens',         // S. marcescens
          'citrobacter-freundii',        // C. freundii
          'citrobacter-koseri',          // C. koseri
          'proteus-vulgaris',            // P. vulgaris
          'morganella-morganii',         // M. morganii
          'stenotrophomonas-maltophilia', // S. maltophilia

          // ═══════════════════════════════════════════════════════════
          // GRAM-POSITIVE BACTERIA (8 organisms)
          // ═══════════════════════════════════════════════════════════
          'mssa',                        // MSSA
          'mrsa',                        // MRSA
          's-epidermidis',               // S. epidermidis
          's-saprophyticus',             // S. saprophyticus
          'enterococcus-faecalis',       // E. faecalis
          'enterococcus-faecium',        // E. faecium
          's-pneumoniae',                // S. pneumoniae
          'beta-hemolytic-strep',        // β-Hemolytic Strep

          // ═══════════════════════════════════════════════════════════
          // CANDIDA SPECIES (4 organisms)
          // ═══════════════════════════════════════════════════════════
          'candida-albicans',            // C. albicans
          'candida-glabrata',            // C. glabrata
          'candida-tropicalis',          // C. tropicalis
          'candida-parapsilosis',        // C. parapsilosis
        ]);

        // STEP 2: Smart Panel Selection
        _panelSelectionMode = 'smart';
        _selectedSpecimenType = 'all';
        _selectedTiers.clear();
        _selectedTiers.addAll({'classA', 'classB', 'classC'});

        // Update antibiotics for selected organisms
        _updateSelectedAntibiotics();

        // STEP 3: Initialize data entry with example data
        _initializeDataEntry();
        _loadExampleData();

        // Navigate to results
        _currentStep = 4;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Example data loaded successfully! Showing hospital-wide antibiogram.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error loading example: $e'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Load realistic example susceptibility data
  /// Based on typical hospital-wide antibiogram patterns
  void _loadExampleData() {
    // Example data map: organismId -> antibioticId -> [susceptible, total]
    final Map<String, Map<String, List<int>>> exampleData = {
      // ═══════════════════════════════════════════════════════════
      // GRAM-NEGATIVE BACTERIA
      // ═══════════════════════════════════════════════════════════

      'e-coli': {
        'amikacin': [495, 772],
        'amoxicillin-clavulanate': [386, 772],
        'ampicillin': [309, 772],
        'aztreonam': [386, 772],
        'cefepime': [386, 772],
        'cefotaxime': [378, 772],
        'ceftazidime': [363, 772],
        'ceftriaxone': [363, 772],
        'ciprofloxacin': [564, 772],
        'gentamicin': [641, 772],
        'imipenem': [741, 772],
        'meropenem': [757, 772],
        'nitrofurantoin': [633, 772],
        'piperacillin-tazobactam': [602, 772],
        'tobramycin': [571, 772],
      },

      'k-pneumoniae': {
        'amikacin': [387, 478],
        'amoxicillin-clavulanate': [363, 478],
        'ampicillin': [0, 478], // Intrinsically resistant
        'aztreonam': [363, 478],
        'cefepime': [349, 478],
        'cefotaxime': [268, 478],
        'ceftazidime': [220, 478],
        'ceftriaxone': [220, 478],
        'ciprofloxacin': [411, 478],
        'gentamicin': [382, 478],
        'imipenem': [444, 478],
        'meropenem': [454, 478],
        'nitrofurantoin': [248, 478],
        'piperacillin-tazobactam': [387, 478],
        'tobramycin': [377, 478],
      },

      'p-aeruginosa': {
        'amikacin': [52, 65],
        'aztreonam': [26, 65],
        'cefepime': [39, 65],
        'ceftazidime': [18, 65],
        'ciprofloxacin': [0, 65],
        'gentamicin': [56, 65],
        'imipenem': [58, 65],
        'meropenem': [61, 65],
        'piperacillin-tazobactam': [4, 65],
        'tobramycin': [49, 65],
      },

      'a-baumannii': {
        'amikacin': [24, 28],
        'cefepime': [4, 28],
        'ciprofloxacin': [0, 28],
        'gentamicin': [25, 28],
        'imipenem': [27, 28],
        'meropenem': [28, 28],
        'tobramycin': [25, 28],
      },

      'enterobacter-spp': {
        'amikacin': [95, 120],
        'cefepime': [102, 120],
        'ceftazidime': [84, 120],
        'ceftriaxone': [78, 120],
        'ciprofloxacin': [96, 120],
        'gentamicin': [108, 120],
        'meropenem': [114, 120],
        'piperacillin-tazobactam': [90, 120],
        'tmp-smx': [84, 120],
      },

      'proteus-mirabilis': {
        'amikacin': [88, 95],
        'ampicillin': [76, 95],
        'cefazolin': [85, 95],
        'cefepime': [90, 95],
        'ceftriaxone': [88, 95],
        'ciprofloxacin': [81, 95],
        'gentamicin': [86, 95],
        'meropenem': [95, 95],
        'tmp-smx': [71, 95],
      },

      'serratia-marcescens': {
        'amikacin': [52, 65],
        'cefepime': [55, 65],
        'ceftazidime': [49, 65],
        'ceftriaxone': [45, 65],
        'ciprofloxacin': [52, 65],
        'gentamicin': [58, 65],
        'meropenem': [62, 65],
        'piperacillin-tazobactam': [46, 65],
        'tmp-smx': [42, 65],
      },

      'citrobacter-freundii': {
        'amikacin': [68, 75],
        'cefepime': [64, 75],
        'ceftazidime': [56, 75],
        'ceftriaxone': [53, 75],
        'ciprofloxacin': [64, 75],
        'gentamicin': [68, 75],
        'meropenem': [72, 75],
        'piperacillin-tazobactam': [60, 75],
        'tmp-smx': [56, 75],
      },

      'citrobacter-koseri': {
        'amikacin': [82, 90],
        'cefepime': [81, 90],
        'ceftazidime': [77, 90],
        'ceftriaxone': [74, 90],
        'ciprofloxacin': [79, 90],
        'gentamicin': [83, 90],
        'meropenem': [88, 90],
        'piperacillin-tazobactam': [76, 90],
        'tmp-smx': [72, 90],
      },

      'proteus-vulgaris': {
        'amikacin': [38, 45],
        'cefepime': [40, 45],
        'ceftazidime': [36, 45],
        'ceftriaxone': [34, 45],
        'ciprofloxacin': [36, 45],
        'gentamicin': [39, 45],
        'meropenem': [43, 45],
        'piperacillin-tazobactam': [35, 45],
        'tmp-smx': [32, 45],
      },

      'morganella-morganii': {
        'amikacin': [48, 55],
        'cefepime': [47, 55],
        'ceftazidime': [44, 55],
        'ceftriaxone': [41, 55],
        'ciprofloxacin': [46, 55],
        'gentamicin': [49, 55],
        'meropenem': [53, 55],
        'piperacillin-tazobactam': [43, 55],
        'tmp-smx': [39, 55],
      },

      'stenotrophomonas-maltophilia': {
        'ceftazidime': [18, 32],
        'levofloxacin': [26, 32],
        'tigecycline': [29, 32],
        'tmp-smx': [30, 32],
      },

      // ═══════════════════════════════════════════════════════════
      // GRAM-POSITIVE BACTERIA
      // ═══════════════════════════════════════════════════════════

      'mssa': {
        'ciprofloxacin': [355, 427],
        'clindamycin': [355, 427],
        'erythromycin': [320, 427],
        'gentamicin': [427, 427],
        'linezolid': [427, 427],
        'nitrofurantoin': [423, 427],
        'oxacillin': [427, 427],
        'penicillin': [34, 427],
        'rifampin': [398, 427],
        'tetracycline': [423, 427],
        'tmp-smx': [397, 427],
        'vancomycin': [427, 427],
      },

      'mrsa': {
        'ciprofloxacin': [0, 202],
        'clindamycin': [129, 202],
        'erythromycin': [40, 202],
        'gentamicin': [202, 202],
        'linezolid': [202, 202],
        'nitrofurantoin': [198, 202],
        'oxacillin': [0, 202], // MRSA = resistant to oxacillin
        'penicillin': [0, 202],
        'rifampin': [47, 202],
        'tetracycline': [103, 202],
        'tmp-smx': [23, 202],
        'vancomycin': [202, 202],
      },

      's-pneumoniae': {
        'amoxicillin': [180, 200],
        'azithromycin': [140, 200],
        'ceftriaxone': [196, 200],
        'erythromycin': [138, 200],
        'levofloxacin': [188, 200],
        'penicillin': [160, 200],
        'tetracycline': [120, 200],
        'vancomycin': [200, 200],
      },

      's-epidermidis': {
        'daptomycin': [85, 85],
        'linezolid': [85, 85],
        'oxacillin': [34, 85],
        'rifampin': [76, 85],
        'tmp-smx': [68, 85],
        'vancomycin': [85, 85],
      },

      's-saprophyticus': {
        'amoxicillin': [48, 55],
        'ciprofloxacin': [50, 55],
        'levofloxacin': [52, 55],
        'nitrofurantoin': [54, 55],
        'tmp-smx': [49, 55],
      },

      'enterococcus-faecalis': {
        'ampicillin': [142, 150],
        'daptomycin': [150, 150],
        'linezolid': [150, 150],
        'nitrofurantoin': [148, 150],
        'vancomycin': [150, 150],
      },

      'enterococcus-faecium': {
        'daptomycin': [68, 75],
        'linezolid': [75, 75],
        'vancomycin': [60, 75],
      },

      'beta-hemolytic-strep': {
        'amoxicillin': [95, 95],
        'ampicillin': [95, 95],
        'azithromycin': [88, 95],
        'ceftriaxone': [95, 95],
        'clindamycin': [85, 95],
        'erythromycin': [82, 95],
        'penicillin': [95, 95],
        'vancomycin': [95, 95],
      },

      // ═══════════════════════════════════════════════════════════
      // CANDIDA SPECIES
      // ═══════════════════════════════════════════════════════════

      'candida-albicans': {
        'amphotericin-b': [173, 180],
        'caspofungin': [180, 180],
        'fluconazole': [176, 180],
        'micafungin': [180, 180],
        'voriconazole': [180, 180],
      },

      'candida-glabrata': {
        'amphotericin-b': [88, 95],
        'caspofungin': [95, 95],
        'micafungin': [95, 95],
        'voriconazole': [76, 95],
      },

      'candida-tropicalis': {
        'amphotericin-b': [68, 72],
        'caspofungin': [72, 72],
        'fluconazole': [65, 72],
        'micafungin': [72, 72],
        'voriconazole': [70, 72],
      },

      'candida-parapsilosis': {
        'amphotericin-b': [58, 62],
        'caspofungin': [56, 62],
        'fluconazole': [60, 62],
        'micafungin': [55, 62],
        'voriconazole': [59, 62],
      },
    };

    // Populate _antibiogramData with example values
    for (final entry in _antibiogramData) {
      final organismId = entry['organismId'] as String;
      final antibioticId = entry['antibioticId'] as String;

      if (exampleData.containsKey(organismId) &&
          exampleData[organismId]!.containsKey(antibioticId)) {
        final data = exampleData[organismId]![antibioticId]!;
        final susceptible = data[0];
        final total = data[1];
        final resistant = total - susceptible;

        entry['susceptibleCount'] = susceptible;
        entry['resistantCount'] = resistant;
        entry['intermediateCount'] = 0;
        entry['totalIsolates'] = total;
      }
    }
  }
}
