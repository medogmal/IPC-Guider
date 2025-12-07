import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../../core/design/design_tokens.dart';
import '../../../domain/models/antibiotic_spectrum.dart';
import '../../../data/repositories/spectrum_repository.dart';
import 'antibiotic_detail_screen.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../../core/widgets/export_modal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Antibiotic Spectrum Visualizer Screen
/// 
/// Visual comparison of antibiotic coverage spectra across different organism categories
class SpectrumVisualizerScreen extends StatefulWidget {
  const SpectrumVisualizerScreen({super.key});

  @override
  State<SpectrumVisualizerScreen> createState() => _SpectrumVisualizerScreenState();
}

class _SpectrumVisualizerScreenState extends State<SpectrumVisualizerScreen> {
  final SpectrumRepository _repository = SpectrumRepository();

  // Data
  List<AntibioticSpectrum> _allAntibiotics = [];
  List<Organism> _allOrganisms = [];
  List<AntibioticSpectrum> _filteredAntibiotics = [];

  // UI State
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  OrganismCategory? _selectedCategory;
  SpectrumBreadth? _selectedBreadth;
  String? _selectedClass;
  int _selectedViewIndex = 0; // 0: Matrix, 1: Comparison, 2: List

  // Comparison State
  final List<String> _selectedForComparison = []; // Antibiotic IDs
  static const int _maxComparisonItems = 3;

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final antibiotics = await _repository.getAntibiotics();
      final organisms = await _repository.getOrganisms();

      setState(() {
        _allAntibiotics = antibiotics;
        _allOrganisms = organisms;
        _filteredAntibiotics = antibiotics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load spectrum data: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAntibiotics = _allAntibiotics.where((antibiotic) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!antibiotic.name.toLowerCase().contains(query) &&
              !antibiotic.genericName.toLowerCase().contains(query) &&
              !antibiotic.antibioticClass.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Breadth filter
        if (_selectedBreadth != null && antibiotic.spectrumBreadth != _selectedBreadth) {
          return false;
        }

        // Class filter
        if (_selectedClass != null && antibiotic.antibioticClass != _selectedClass) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  // Export Methods
  void _showExportOptions() {
    ExportModal.show(
      context: context,
      onExportPDF: _exportToPdf,
      onExportCSV: _exportToCsv,
      onExportExcel: _exportToExcel,
      onExportPhoto: _exportToImage,
      onExportText: _exportToText,
    );
  }

  Future<void> _exportToPdf() async {
    try {
      final exportData = _prepareExportData();
      await UnifiedExportService.exportCalculatorAsPDF(
        context: context,
        toolName: 'Antibiotic Spectrum Visualizer',
        inputs: exportData['inputs'] as Map<String, dynamic>,
        results: exportData['results'] as Map<String, dynamic>,
        interpretation: exportData['interpretation'] as String?,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _exportToCsv() async {
    try {
      final csvContent = _generateCsvContent();
      await UnifiedExportService.exportAsCSV(
        context: context,
        filename: 'antibiotic_spectrum_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
        csvContent: csvContent,
        toolName: 'Antibiotic Spectrum Visualizer',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final exportData = _prepareVisualizationData();
      await UnifiedExportService.exportVisualizationAsExcel(
        context: context,
        toolName: 'Antibiotic Spectrum Visualizer',
        headers: exportData['headers'] as List<String>,
        data: exportData['data'] as List<List<dynamic>>,
        metadata: exportData['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _exportToText() async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('ANTIBIOTIC SPECTRUM ANALYSIS');
      buffer.writeln('Generated from IPC Guider');
      buffer.writeln('=' * 50);
      buffer.writeln();

      for (final antibiotic in _filteredAntibiotics) {
        buffer.writeln('${antibiotic.name} (${antibiotic.genericName})');
        buffer.writeln('Class: ${antibiotic.antibioticClass}');
        buffer.writeln('Spectrum: ${antibiotic.spectrumBreadth.displayName}');
        if (antibiotic.clinicalUse != null) {
          buffer.writeln('Clinical Use: ${antibiotic.clinicalUse}');
        }
        buffer.writeln();
      }

      final exportData = _prepareExportData();
      await UnifiedExportService.exportCalculatorAsText(
        context: context,
        toolName: 'Antibiotic Spectrum Visualizer',
        inputs: exportData['inputs'] as Map<String, dynamic>,
        results: exportData['results'] as Map<String, dynamic>,
        interpretation: buffer.toString(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _exportToImage() async {
    try {
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Generating Image...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // Capture screenshot
      final imageBytes = await _screenshotController.capture();
      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Save image
      final output = await getTemporaryDirectory();
      final dateFormat = DateFormat('yyyy-MM-dd');
      final now = DateTime.now();
      final filename = 'antibiotic_spectrum_${dateFormat.format(now)}.png';
      final file = File('${output.path}/$filename');
      await file.writeAsBytes(imageBytes);

      // Share image
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Antibiotic Spectrum Analysis - Generated by IPC Guider',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _prepareExportData() {
    return {
      'inputs': {
        'Total Antibiotics': _filteredAntibiotics.length.toString(),
        'Total Organisms': _allOrganisms.length.toString(),
        'View Mode': _selectedViewIndex == 0 ? 'Matrix' : _selectedViewIndex == 1 ? 'Comparison' : 'List',
        'Filters Applied': _getFiltersApplied(),
      },
      'results': {
        'Antibiotics': _filteredAntibiotics.map((ab) => ab.name).join(', '),
        'Classes': _filteredAntibiotics.map((ab) => ab.antibioticClass).toSet().join(', '),
      },
      'interpretation': _generateInterpretation(),
    };
  }

  String _getFiltersApplied() {
    final filters = <String>[];
    if (_searchQuery.isNotEmpty) filters.add('Search: "$_searchQuery"');
    if (_selectedBreadth != null) filters.add('Spectrum: ${_selectedBreadth!.displayName}');
    if (_selectedClass != null) filters.add('Class: $_selectedClass');
    if (_selectedCategory != null) filters.add('Category: ${_selectedCategory!.displayName}');
    return filters.isEmpty ? 'None' : filters.join(', ');
  }

  String _generateInterpretation() {
    final buffer = StringBuffer();
    buffer.writeln('Antibiotic Spectrum Analysis Summary');
    buffer.writeln('');
    buffer.writeln('Total Antibiotics Analyzed: ${_filteredAntibiotics.length}');
    buffer.writeln('Total Organisms: ${_allOrganisms.length}');
    buffer.writeln('');

    for (final antibiotic in _filteredAntibiotics) {
      buffer.writeln('${antibiotic.name} (${antibiotic.genericName})');
      buffer.writeln('  Class: ${antibiotic.antibioticClass}');
      buffer.writeln('  Spectrum: ${antibiotic.spectrumBreadth.displayName}');
      if (antibiotic.clinicalUse != null) {
        buffer.writeln('  Clinical Use: ${antibiotic.clinicalUse}');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _generateCsvContent() {
    final buffer = StringBuffer();

    // Header row
    buffer.write('Antibiotic,Generic Name,Class,Spectrum');
    for (final organism in _allOrganisms) {
      buffer.write(',${organism.commonName}');
    }
    buffer.writeln();

    // Data rows
    for (final antibiotic in _filteredAntibiotics) {
      buffer.write('"${antibiotic.name}","${antibiotic.genericName}","${antibiotic.antibioticClass}","${antibiotic.spectrumBreadth.displayName}"');
      for (final organism in _allOrganisms) {
        final coverage = antibiotic.getCoverageFor(organism.id);
        buffer.write(',"${coverage?.displayName ?? 'N/A'}"');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  Map<String, dynamic> _prepareVisualizationData() {
    final headers = <String>['Antibiotic', 'Generic Name', 'Class', 'Spectrum'];
    headers.addAll(_allOrganisms.map((o) => o.commonName));

    final data = <List<dynamic>>[];
    for (final antibiotic in _filteredAntibiotics) {
      final row = <dynamic>[
        antibiotic.name,
        antibiotic.genericName,
        antibiotic.antibioticClass,
        antibiotic.spectrumBreadth.displayName,
      ];

      for (final organism in _allOrganisms) {
        final coverage = antibiotic.getCoverageFor(organism.id);
        row.add(coverage?.displayName ?? 'N/A');
      }

      data.add(row);
    }

    return {
      'headers': headers,
      'data': data,
      'metadata': {
        'Total Antibiotics': _filteredAntibiotics.length,
        'Total Organisms': _allOrganisms.length,
        'Filters': _getFiltersApplied(),
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antibiotic Spectrum Visualizer'),
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildMainContent(bottomPadding),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.medium),
          Text('Loading spectrum data...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              _errorMessage ?? 'Unknown error',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(double bottomPadding) {
    return Column(
      children: [
        // Header Section
        _buildHeaderSection(),

        // Search and Filters
        _buildSearchAndFilters(),

        // View Selector
        _buildViewSelector(),

        // Content
        Expanded(
          child: _buildSelectedView(bottomPadding),
        ),

        // Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header Card
          Container(
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
                    Icons.grid_on_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Antibiotic Spectrum Visualizer',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Compare antibiotic coverage across organism categories',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Quick Guide Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showQuickGuide(context),
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
          ),
          const SizedBox(height: 12),
          // Load Example Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _loadExample,
              icon: Icon(Icons.lightbulb_outline, color: AppColors.success),
              label: Text(
                'Load Example',
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
          ),
        ],
      ),
    );
  }

  void _showQuickGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, color: AppColors.info, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Guide',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.neutralLight),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  children: [
                    _buildGuideSection(
                      context,
                      icon: Icons.info_outline,
                      title: 'What is Antibiotic Spectrum?',
                      content:
                          'Antibiotic spectrum refers to the range of bacteria that an antibiotic can effectively target. Understanding spectrum helps clinicians choose the most appropriate antibiotic for empiric therapy or targeted treatment.',
                    ),
                    _buildGuideSection(
                      context,
                      icon: Icons.category_outlined,
                      title: 'Spectrum Categories',
                      content:
                          '• Narrow Spectrum: Targets specific bacterial groups (e.g., Penicillin G for Streptococcus)\n'
                          '• Broad Spectrum: Covers both Gram-positive and Gram-negative bacteria (e.g., Amoxicillin-Clavulanate)\n'
                          '• Extended Spectrum: Enhanced activity against resistant organisms (e.g., Carbapenems)',
                    ),
                    _buildGuideSection(
                      context,
                      icon: Icons.view_module_outlined,
                      title: 'View Modes',
                      content:
                          '• Matrix View: Visual grid showing coverage across all organism categories\n'
                          '• Comparison View: Side-by-side comparison of up to 3 antibiotics\n'
                          '• List View: Detailed list with coverage percentages and notes',
                    ),
                    _buildGuideSection(
                      context,
                      icon: Icons.filter_alt_outlined,
                      title: 'Filtering Options',
                      content:
                          '• Search: Find antibiotics by name, generic name, or class\n'
                          '• Spectrum Breadth: Filter by narrow, broad, or extended spectrum\n'
                          '• Antibiotic Class: Filter by drug class (e.g., Beta-lactams, Fluoroquinolones)\n'
                          '• Organism Category: Filter by target organisms (Gram+, Gram-, Anaerobes, etc.)',
                    ),
                    _buildGuideSection(
                      context,
                      icon: Icons.lightbulb_outline,
                      title: 'Clinical Considerations',
                      content:
                          '• Always consider local resistance patterns (antibiogram)\n'
                          '• Narrow spectrum preferred when pathogen is known (antimicrobial stewardship)\n'
                          '• Broad spectrum may be needed for empiric therapy in severe infections\n'
                          '• Consider patient allergies, renal/hepatic function, and drug interactions',
                    ),
                    _buildGuideSection(
                      context,
                      icon: Icons.book_outlined,
                      title: 'References',
                      content:
                          '• Sanford Guide to Antimicrobial Therapy\n'
                          '• IDSA Clinical Practice Guidelines\n'
                          '• WHO Model List of Essential Medicines\n'
                          '• CDC Antibiotic Prescribing and Use Guidelines\n'
                          '• Johns Hopkins ABX Guide',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  void _loadExample() {
    setState(() {
      // Clear existing filters
      _searchQuery = '';
      _searchController.clear();
      _selectedBreadth = SpectrumBreadth.broad;
      _selectedClass = null;
      _selectedCategory = null;
      _selectedForComparison.clear();

      // Apply broad spectrum filter
      _applyFilters();

      // Select 3 common broad-spectrum antibiotics for comparison
      // Find Amoxicillin-Clavulanate, Ceftriaxone, and Levofloxacin
      final exampleAntibiotics = [
        'amoxicillin-clavulanate',
        'ceftriaxone',
        'levofloxacin',
      ];

      for (final id in exampleAntibiotics) {
        final antibiotic = _filteredAntibiotics.firstWhere(
          (a) => a.id == id,
          orElse: () => _filteredAntibiotics.isNotEmpty
              ? _filteredAntibiotics.first
              : _allAntibiotics.first,
        );
        if (!_selectedForComparison.contains(antibiotic.id) &&
            _selectedForComparison.length < _maxComparisonItems) {
          _selectedForComparison.add(antibiotic.id);
        }
      }

      // Switch to Comparison view
      _selectedViewIndex = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Example loaded - Comparing 3 broad-spectrum antibiotics'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.neutralLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                  _selectedBreadth = null;
                  _selectedClass = null;
                  _selectedCategory = null;
                  _selectedForComparison.clear();
                  _applyFilters();
                });
              },
              icon: const Icon(Icons.clear_all, color: AppColors.textSecondary),
              label: const Text(
                'Clear Filters',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.neutralLight, width: 1.5),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showExportOptions,
              icon: const Icon(Icons.file_download),
              label: const Text('Export'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.neutralLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search antibiotics...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.small,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _applyFilters();
            },
          ),
          const SizedBox(height: AppSpacing.small),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Breadth Filter
                _buildFilterChip(
                  label: _selectedBreadth?.displayName ?? 'All Spectra',
                  icon: Icons.tune,
                  isSelected: _selectedBreadth != null,
                  onTap: () => _showBreadthFilter(),
                ),
                const SizedBox(width: AppSpacing.small),

                // Class Filter
                _buildFilterChip(
                  label: _selectedClass ?? 'All Classes',
                  icon: Icons.category_outlined,
                  isSelected: _selectedClass != null,
                  onTap: () => _showClassFilter(),
                ),
                const SizedBox(width: AppSpacing.small),

                // Category Filter (for organisms)
                _buildFilterChip(
                  label: _selectedCategory?.displayName ?? 'All Organisms',
                  icon: Icons.biotech_outlined,
                  isSelected: _selectedCategory != null,
                  onTap: () => _showCategoryFilter(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: AppSpacing.extraSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutralLight,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.neutralLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildViewTab(
            index: 0,
            icon: Icons.grid_on_outlined,
            label: 'Matrix',
          ),
          const SizedBox(width: AppSpacing.small),
          _buildViewTab(
            index: 1,
            icon: Icons.compare_arrows_outlined,
            label: 'Compare',
          ),
          const SizedBox(width: AppSpacing.small),
          _buildViewTab(
            index: 2,
            icon: Icons.list_outlined,
            label: 'List',
          ),
        ],
      ),
    );
  }

  Widget _buildViewTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedViewIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedViewIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedView(double bottomPadding) {
    switch (_selectedViewIndex) {
      case 0:
        return _buildMatrixView(bottomPadding);
      case 1:
        return _buildComparisonView(bottomPadding);
      case 2:
        return _buildListView(bottomPadding);
      default:
        return _buildMatrixView(bottomPadding);
    }
  }

  // Filter Dialogs
  void _showBreadthFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Spectrum Breadth'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Spectra'),
              leading: Radio<SpectrumBreadth?>(
                value: null,
                groupValue: _selectedBreadth,
                onChanged: (value) {
                  setState(() {
                    _selectedBreadth = value;
                  });
                  _applyFilters();
                  Navigator.pop(context);
                },
              ),
            ),
            ...SpectrumBreadth.values.map((breadth) {
              return ListTile(
                title: Text(breadth.displayName),
                leading: Radio<SpectrumBreadth?>(
                  value: breadth,
                  groupValue: _selectedBreadth,
                  onChanged: (value) {
                    setState(() {
                      _selectedBreadth = value;
                    });
                    _applyFilters();
                    Navigator.pop(context);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showClassFilter() async {
    final classes = await _repository.getAntibioticClasses();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Antibiotic Class'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Classes'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: _selectedClass,
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
                    });
                    _applyFilters();
                    Navigator.pop(context);
                  },
                ),
              ),
              ...classes.map((className) {
                return ListTile(
                  title: Text(className),
                  leading: Radio<String?>(
                    value: className,
                    groupValue: _selectedClass,
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value;
                      });
                      _applyFilters();
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Organism Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Organisms'),
              leading: Radio<OrganismCategory?>(
                value: null,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ...OrganismCategory.values.map((category) {
              return ListTile(
                title: Text(category.displayName),
                leading: Radio<OrganismCategory?>(
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // View Implementations
  Widget _buildMatrixView(double bottomPadding) {
    if (_filteredAntibiotics.isEmpty) {
      return _buildEmptyState();
    }

    // Filter organisms by selected category
    final displayOrganisms = _selectedCategory != null
        ? _allOrganisms.where((o) => o.category == _selectedCategory).toList()
        : _allOrganisms;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coverage Matrix',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Showing ${_filteredAntibiotics.length} antibiotics × ${displayOrganisms.length} organisms',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),

          // Matrix Table (wrapped for image export)
          Screenshot(
            controller: _screenshotController,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildCoverageMatrix(displayOrganisms),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView(double bottomPadding) {
    if (_selectedForComparison.isEmpty) {
      return _buildComparisonEmptyState();
    }

    final selectedAntibiotics = _allAntibiotics
        .where((ab) => _selectedForComparison.contains(ab.id))
        .toList();

    return Column(
      children: [
        // Selection info banner
        Container(
          padding: const EdgeInsets.all(AppSpacing.medium),
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(Icons.compare_arrows, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${selectedAntibiotics.length} antibiotic(s) selected for comparison',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedForComparison.clear();
                  });
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ),

        // Comparison table
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
            child: _buildComparisonTable(selectedAntibiotics),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonEmptyState() {
    return Column(
      children: [
        // Instructions banner
        Container(
          padding: const EdgeInsets.all(AppSpacing.medium),
          color: AppColors.info.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Select 2-3 antibiotics from the list below to compare',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Selectable antibiotic list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: _filteredAntibiotics.length,
            itemBuilder: (context, index) {
              final antibiotic = _filteredAntibiotics[index];
              final isSelected = _selectedForComparison.contains(antibiotic.id);
              final canSelect = _selectedForComparison.length < _maxComparisonItems;

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.small),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (canSelect || isSelected)
                      ? (value) {
                          setState(() {
                            if (value == true) {
                              _selectedForComparison.add(antibiotic.id);
                            } else {
                              _selectedForComparison.remove(antibiotic.id);
                            }
                          });
                        }
                      : null,
                  title: Text(
                    antibiotic.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${antibiotic.antibioticClass} • ${antibiotic.spectrumBreadth.displayName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSpectrumColor(antibiotic.spectrumBreadth)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medication,
                      color: _getSpectrumColor(antibiotic.spectrumBreadth),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonTable(List<AntibioticSpectrum> antibiotics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Side-by-Side Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildComparisonDataTable(antibiotics),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(double bottomPadding) {
    if (_filteredAntibiotics.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      itemCount: _filteredAntibiotics.length,
      itemBuilder: (context, index) {
        final antibiotic = _filteredAntibiotics[index];
        return _buildAntibioticCard(antibiotic);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'No antibiotics found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageMatrix(List<Organism> organisms) {
    return Table(
      border: TableBorder.all(
        color: AppColors.neutralLight,
        width: 1,
      ),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        // Header Row
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          children: [
            _buildMatrixHeaderCell('Antibiotic'),
            ...organisms.map((organism) => _buildMatrixHeaderCell(
                  organism.commonName,
                  isVertical: true,
                )),
          ],
        ),

        // Data Rows
        ..._filteredAntibiotics.map((antibiotic) {
          return TableRow(
            children: [
              _buildMatrixAntibioticCell(antibiotic),
              ...organisms.map((organism) {
                final coverage = antibiotic.getCoverageFor(organism.id);
                return _buildMatrixCoverageCell(coverage);
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMatrixHeaderCell(String text, {bool isVertical = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.small),
      height: isVertical ? 120 : null,
      child: isVertical
          ? RotatedBox(
              quarterTurns: 3,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
    );
  }

  Widget _buildMatrixAntibioticCell(AntibioticSpectrum antibiotic) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            antibiotic.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            antibiotic.antibioticClass,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixCoverageCell(CoverageLevel? coverage) {
    final color = _getCoverageColor(coverage);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.small),
      color: color.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          _getCoverageIcon(coverage),
          size: 16,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAntibioticCard(AntibioticSpectrum antibiotic) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AntibioticDetailScreen(
                antibiotic: antibiotic,
                organisms: _allOrganisms,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
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
                          antibiotic.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          antibiotic.genericName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.small,
                      vertical: AppSpacing.extraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: _getSpectrumColor(antibiotic.spectrumBreadth)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      antibiotic.spectrumBreadth.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getSpectrumColor(antibiotic.spectrumBreadth),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                antibiotic.antibioticClass,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (antibiotic.clinicalUse != null) ...[
                const SizedBox(height: AppSpacing.small),
                Text(
                  antibiotic.clinicalUse!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getCoverageColor(CoverageLevel? level) {
    if (level == null) return AppColors.textSecondary;

    switch (level) {
      case CoverageLevel.excellent:
        return AppColors.success;
      case CoverageLevel.good:
        return AppColors.info;
      case CoverageLevel.variable:
        return AppColors.warning;
      case CoverageLevel.poor:
        return const Color(0xFFFF9800); // Orange
      case CoverageLevel.none:
        return AppColors.error;
    }
  }

  IconData _getCoverageIcon(CoverageLevel? level) {
    if (level == null) return Icons.help_outline;

    switch (level) {
      case CoverageLevel.excellent:
        return Icons.check_circle;
      case CoverageLevel.good:
        return Icons.check;
      case CoverageLevel.variable:
        return Icons.warning_amber;
      case CoverageLevel.poor:
        return Icons.remove_circle_outline;
      case CoverageLevel.none:
        return Icons.cancel;
    }
  }

  Color _getSpectrumColor(SpectrumBreadth breadth) {
    switch (breadth) {
      case SpectrumBreadth.narrow:
        return AppColors.info;
      case SpectrumBreadth.extended:
        return AppColors.warning;
      case SpectrumBreadth.broad:
        return AppColors.error;
    }
  }

  Widget _buildComparisonDataTable(List<AntibioticSpectrum> antibiotics) {
    // Group organisms by category for better organization
    final Map<OrganismCategory, List<Organism>> groupedOrganisms = {};
    for (final organism in _allOrganisms) {
      groupedOrganisms.putIfAbsent(organism.category, () => []).add(organism);
    }

    return Table(
      border: TableBorder.all(
        color: AppColors.neutralLight,
        width: 1,
      ),
      columnWidths: {
        0: const FixedColumnWidth(200),
        for (int i = 0; i < antibiotics.length; i++)
          i + 1: const FixedColumnWidth(150),
      },
      children: [
        // Header row - Antibiotic names
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          children: [
            _buildComparisonHeaderCell('Organism'),
            ...antibiotics.map((ab) => _buildComparisonHeaderCell(ab.name)),
          ],
        ),

        // Basic info rows
        TableRow(
          children: [
            _buildComparisonInfoCell('Generic Name', isLabel: true),
            ...antibiotics.map((ab) => _buildComparisonInfoCell(ab.genericName)),
          ],
        ),
        TableRow(
          children: [
            _buildComparisonInfoCell('Class', isLabel: true),
            ...antibiotics.map((ab) => _buildComparisonInfoCell(ab.antibioticClass)),
          ],
        ),
        TableRow(
          children: [
            _buildComparisonInfoCell('Spectrum', isLabel: true),
            ...antibiotics.map((ab) => _buildComparisonInfoCell(
                  ab.spectrumBreadth.displayName,
                  color: _getSpectrumColor(ab.spectrumBreadth),
                )),
          ],
        ),

        // Category headers and organism rows
        ...groupedOrganisms.entries.expand((entry) {
          return [
            // Category header
            TableRow(
              decoration: BoxDecoration(
                color: AppColors.neutralLight.withValues(alpha: 0.5),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    entry.key.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...List.generate(
                  antibiotics.length,
                  (_) => const SizedBox.shrink(),
                ),
              ],
            ),
            // Organism rows
            ...entry.value.map((organism) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      organism.commonName,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ...antibiotics.map((ab) {
                    final coverage = ab.getCoverageFor(organism.id);
                    return _buildComparisonCoverageCell(coverage);
                  }),
                ],
              );
            }),
          ];
        }),
      ],
    );
  }

  Widget _buildComparisonHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildComparisonInfoCell(String text, {bool isLabel = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: isLabel ? AppColors.neutralLight.withValues(alpha: 0.3) : null,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isLabel ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isLabel ? AppColors.textPrimary : AppColors.textSecondary),
          fontSize: 13,
        ),
        textAlign: isLabel ? TextAlign.left : TextAlign.center,
      ),
    );
  }

  Widget _buildComparisonCoverageCell(CoverageLevel? coverage) {
    final color = _getCoverageColor(coverage);
    final icon = _getCoverageIcon(coverage);

    return Container(
      padding: const EdgeInsets.all(8),
      color: color.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            coverage?.displayName ?? 'N/A',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

