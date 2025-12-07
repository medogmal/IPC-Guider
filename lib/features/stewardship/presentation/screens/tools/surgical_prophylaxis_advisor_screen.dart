import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/storage/tool_storage_service.dart';
import '../../../domain/models/surgical_prophylaxis.dart';
import '../../../data/repositories/surgical_prophylaxis_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SurgicalProphylaxisAdvisorScreen extends StatefulWidget {
  const SurgicalProphylaxisAdvisorScreen({super.key});

  @override
  State<SurgicalProphylaxisAdvisorScreen> createState() =>
      _SurgicalProphylaxisAdvisorScreenState();
}

class _SurgicalProphylaxisAdvisorScreenState extends State<SurgicalProphylaxisAdvisorScreen> {
  // Wizard state
  int _currentStep = 0;

  // Data
  final SurgicalProphylaxisRepository _repository =
      SurgicalProphylaxisRepository();
  List<SurgicalProcedure> _allProcedures = [];
  List<SurgicalProcedure> _filteredProcedures = [];
  SurgicalProcedure? _selectedProcedure;
  Map<String, dynamic>? _recommendationData;

  // Patient profile
  bool _hasBetaLactamAllergy = false;
  bool _hasMRSAColonization = false;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // UI state
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentSavedId;
  SurgicalSpecialty? _selectedSpecialty;
  final TextEditingController _searchController = TextEditingController();

  // Storage
  final ToolStorageService<SavedProphylaxisRecommendation> _storageService =
      ToolStorageService<SavedProphylaxisRecommendation>(
    storageKey: 'surgical_prophylaxis_data',
    fromJson: SavedProphylaxisRecommendation.fromJson,
    toJson: (item) => item.toJson(),
    getId: (item) => item.id,
  );

  // Screenshot
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final procedures = await _repository.loadProcedures();
      setState(() {
        _allProcedures = procedures;
        _filteredProcedures = procedures;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load procedures: $e';
        _isLoading = false;
      });
    }
  }

  void _filterProcedures() {
    setState(() {
      _filteredProcedures = _allProcedures.where((procedure) {
        final matchesSearch = _searchController.text.isEmpty ||
            procedure.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            procedure.description
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesSpecialty = _selectedSpecialty == null ||
            procedure.specialty == _selectedSpecialty;

        return matchesSearch && matchesSpecialty;
      }).toList();
    });
  }

  Future<void> _generateRecommendation() async {
    if (_selectedProcedure == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final patientProfile = PatientProfile(
        hasBetaLactamAllergy: _hasBetaLactamAllergy,
        hasMRSAColonization: _hasMRSAColonization,
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
      );

      final recommendation = await _repository.getRecommendation(
        procedureId: _selectedProcedure!.id,
        patientProfile: patientProfile,
      );

      setState(() {
        _recommendationData = recommendation;
        _isLoading = false;
        _currentStep = 2; // Move to recommendation step
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate recommendation: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Surgical Prophylaxis Advisor'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(bottomPadding),
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
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(double bottomPadding) {
    return Column(
      children: [
        // Header Section
        _buildHeaderSection(),
        // Stepper header
        _buildStepperHeader(),
        const Divider(height: 1),
        // Step content
        Expanded(
          child: _buildStepContent(bottomPadding),
        ),
        // Navigation buttons
        if (_currentStep < 2) _buildNavigationButtons(),
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
                    Icons.medical_services_outlined,
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
                        'Surgical Prophylaxis Advisor',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Evidence-based antibiotic prophylaxis for surgical procedures',
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

  Widget _buildStepperHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      color: AppColors.surface,
      child: Row(
        children: [
          _buildStepIndicator(0, 'Procedure', Icons.local_hospital),
          _buildStepConnector(0),
          _buildStepIndicator(1, 'Patient', Icons.person),
          _buildStepConnector(1),
          _buildStepIndicator(2, 'Recommendation', Icons.medication),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.success
                : isActive
                    ? AppColors.primary
                    : AppColors.neutralLight,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted || isActive ? Colors.white : AppColors.textSecondary,
            size: 24,
          ),
        ),
        const SizedBox(height: AppSpacing.extraSmall),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 30),
        color: isCompleted
            ? AppColors.success
            : AppColors.textSecondary.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildStepContent(double bottomPadding) {
    switch (_currentStep) {
      case 0:
        return _buildProcedureSelectionStep(bottomPadding);
      case 1:
        return _buildPatientAssessmentStep(bottomPadding);
      case 2:
        return _buildRecommendationStep(bottomPadding);
      default:
        return const SizedBox();
    }
  }

  Widget _buildNavigationButtons() {
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
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.neutralLight, width: 1.5),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _canProceed() ? _handleNext : null,
              icon: Icon(_currentStep == 1 ? Icons.check : Icons.arrow_forward),
              label: Text(_currentStep == 1 ? 'Generate' : 'Next'),
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

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedProcedure != null;
      case 1:
        return true; // Patient assessment is optional
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep == 0) {
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      _generateRecommendation();
    }
  }

  Widget _buildProcedureSelectionStep(double bottomPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Surgical Procedure',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Choose the procedure for prophylaxis recommendation',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.large),

          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search procedures...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterProcedures();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => _filterProcedures(),
          ),
          const SizedBox(height: AppSpacing.medium),

          // Specialty filter chips
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedSpecialty == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedSpecialty = null;
                    _filterProcedures();
                  });
                },
              ),
              ...SurgicalSpecialty.values.map((specialty) {
                return FilterChip(
                  label: Text(specialty.displayName),
                  selected: _selectedSpecialty == specialty,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpecialty = selected ? specialty : null;
                      _filterProcedures();
                    });
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.large),

          // Procedure list
          if (_filteredProcedures.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.extraLarge),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      'No procedures found',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._filteredProcedures.map((procedure) {
              final isSelected = _selectedProcedure?.id == procedure.id;
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.medium),
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedProcedure = procedure;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.neutralLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.local_hospital,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                procedure.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.extraSmall),
                              Text(
                                procedure.specialty.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.extraSmall),
                              Text(
                                procedure.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 28,
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

  Widget _buildPatientAssessmentStep(double bottomPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Assessment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Provide patient information to personalize the recommendation',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.large),

          // Selected procedure summary
          if (_selectedProcedure != null)
            Card(
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Row(
                  children: [
                    Icon(Icons.local_hospital, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Procedure',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _selectedProcedure!.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.large),

          // Allergy screening
          Text(
            'Allergy Screening',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          SwitchListTile(
            title: const Text('Beta-Lactam Allergy'),
            subtitle: const Text('Penicillin, cephalosporin, or carbapenem allergy'),
            value: _hasBetaLactamAllergy,
            onChanged: (value) {
              setState(() {
                _hasBetaLactamAllergy = value;
              });
            },
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
          ),
          const Divider(),

          // MRSA colonization
          Text(
            'MRSA Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          SwitchListTile(
            title: const Text('Known MRSA Colonization'),
            subtitle: const Text('Patient has documented MRSA colonization'),
            value: _hasMRSAColonization,
            onChanged: (value) {
              setState(() {
                _hasMRSAColonization = value;
              });
            },
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
          ),
          const Divider(),

          // Weight input
          Text(
            'Patient Weight (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Weight (kg)',
              hintText: 'Enter patient weight',
              suffixText: 'kg',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'Used for weight-based dosing adjustments',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationStep(double bottomPadding) {
    if (_recommendationData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final procedure = _recommendationData!['procedure'] as SurgicalProcedure;
    final primaryRec =
        _recommendationData!['primaryRecommendation'] as ProphylaxisRecommendation;
    final alternatives = _recommendationData!['alternatives']
        as List<ProphylaxisRecommendation>;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      child: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Prophylaxis Recommendation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Evidence-based recommendation for ${procedure.name}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.large),

              // Primary recommendation card
              _buildRecommendationCard(primaryRec, isPrimary: true),

              // Alternatives
              if (alternatives.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.large),
                Text(
                  'Alternative Options',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                ...alternatives.map((alt) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                      child: _buildRecommendationCard(alt, isPrimary: false),
                    )),
              ],

              // Special considerations
              const SizedBox(height: AppSpacing.large),
              _buildSpecialConsiderationsCard(procedure),

              // References
              const SizedBox(height: AppSpacing.large),
              _buildReferencesCard(procedure),

              // Save & Export Buttons
              const SizedBox(height: AppSpacing.large),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _save,
                      icon: Icon(Icons.save_outlined, size: 20, color: AppColors.success),
                      label: Text(
                        'Save',
                        style: TextStyle(color: AppColors.success),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.success, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showExportOptions,
                      icon: Icon(Icons.file_download, size: 20, color: AppColors.primary),
                      label: Text(
                        'Export',
                        style: TextStyle(color: AppColors.primary),
                      ),
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
              ),
              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    ProphylaxisRecommendation recommendation, {
    required bool isPrimary,
  }) {
    return Card(
      elevation: isPrimary ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.small,
                    vertical: AppSpacing.extraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? AppColors.primary
                        : AppColors.info,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isPrimary ? 'PRIMARY' : 'ALTERNATIVE',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.medication,
                  color: isPrimary ? AppColors.primary : AppColors.info,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),

            // Antibiotic name
            Text(
              recommendation.antibioticName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),

            // Dose
            _buildInfoRow(Icons.science, 'Dose', recommendation.dose),
            const SizedBox(height: AppSpacing.small),

            // Route
            _buildInfoRow(Icons.local_hospital, 'Route', recommendation.route),
            const SizedBox(height: AppSpacing.small),

            // Timing
            _buildInfoRow(Icons.schedule, 'Timing', recommendation.timing),
            const SizedBox(height: AppSpacing.small),

            // Duration
            _buildInfoRow(Icons.timer, 'Duration', recommendation.duration),

            if (recommendation.redosingInterval != null) ...[
              const SizedBox(height: AppSpacing.small),
              _buildInfoRow(Icons.repeat, 'Redosing', recommendation.redosingInterval!),
            ],

            const Divider(height: AppSpacing.large),

            // Rationale
            Text(
              'Rationale',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              recommendation.rationale,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),

            // Warnings
            if (recommendation.warnings.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.medium),
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.warning, size: 16),
                        const SizedBox(width: AppSpacing.small),
                        Text(
                          'Warnings',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                    ...recommendation.warnings.map((warning) => Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.medium,
                            top: AppSpacing.extraSmall,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: AppColors.warning)),
                              Expanded(
                                child: Text(
                                  warning,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],

            // Monitoring
            if (recommendation.monitoring != null &&
                recommendation.monitoring!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.medium),
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monitor_heart, color: AppColors.info, size: 16),
                        const SizedBox(width: AppSpacing.small),
                        Text(
                          'Monitoring',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                    ...recommendation.monitoring!.map((item) => Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.medium,
                            top: AppSpacing.extraSmall,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: AppColors.info)),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.small),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialConsiderationsCard(SurgicalProcedure procedure) {
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
                Text(
                  'Special Considerations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ...procedure.specialConsiderations.map((consideration) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSpacing.small),
                      Expanded(
                        child: Text(
                          consideration,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildReferencesCard(SurgicalProcedure procedure) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books, color: AppColors.info),
                const SizedBox(width: AppSpacing.small),
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
            const SizedBox(height: AppSpacing.medium),
            ...procedure.references.map((reference) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: InkWell(
                    onTap: () => _launchURL(reference.url),
                    child: Row(
                      children: [
                        Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: Text(
                            reference.label,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _save() async {
    if (_recommendationData == null || _selectedProcedure == null) return;

    final primaryRec =
        _recommendationData!['primaryRecommendation'] as ProphylaxisRecommendation;
    final alternatives = _recommendationData!['alternatives']
        as List<ProphylaxisRecommendation>;

    final patientProfile = PatientProfile(
      hasBetaLactamAllergy: _hasBetaLactamAllergy,
      hasMRSAColonization: _hasMRSAColonization,
      weight: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
    );

    final saved = SavedProphylaxisRecommendation(
      id: _currentSavedId ?? const Uuid().v4(),
      timestamp: DateTime.now(),
      procedureName: _selectedProcedure!.name,
      procedureId: _selectedProcedure!.id,
      patientProfile: patientProfile,
      recommendation: primaryRec,
      alternatives: alternatives,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await _storageService.save(saved);
    _currentSavedId = saved.id;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recommendation saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showExportOptions() {
    if (_recommendationData == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => ExportModal(
        onExportPDF: _exportToPdf,
        onExportExcel: _exportToExcel,
        onExportCSV: _exportToCsv,
        onExportText: _exportToText,
        onExportPhoto: _exportToImage,
        enablePhoto: true,
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
                      title: 'What is Surgical Prophylaxis?',
                      content:
                          'Surgical antimicrobial prophylaxis (SAP) is the administration of antibiotics before, during, or immediately after surgery to prevent surgical site infections (SSIs). Appropriate prophylaxis reduces SSI risk by 40-60% while minimizing unnecessary antibiotic exposure, resistance development, and adverse effects.',
                    ),
                    _buildGuideSection(
                      context,
                      icon: Icons.access_time_outlined,
                      title: 'Timing is Critical',
                      content:
                          '• Administer within 60 minutes before incision (optimal: 30-60 minutes)\n'
                          '• Vancomycin and fluoroquinolones: start 120 minutes before incision (slow infusion)\n'
                          '• Goal: achieve therapeutic tissue concentrations at time of incision\n'
                          '• Redose if procedure duration exceeds 2 half-lives of the antibiotic',
                    ),
                    _buildGuideSection(
                      context,
                      icon: Icons.timer_outlined,
                      title: 'Duration Guidelines',
                      content:
                          '• Single dose is sufficient for most clean and clean-contaminated procedures\n'
                          '• Maximum 24 hours for cardiac and orthopedic procedures with prosthetic implants\n'
                          '• No benefit beyond 24 hours - prolonged courses increase C. difficile risk and resistance\n'
                          '• Discontinue prophylaxis within 24 hours unless therapeutic antibiotics are indicated',
                    ),
                    _buildGuideSection(
                      context,
                      icon: Icons.medication_outlined,
                      title: 'First-Line Agents',
                      content:
                          '• Cefazolin 2g IV: Most clean and clean-contaminated procedures (cardiac, orthopedic, vascular, neurosurgery)\n'
                          '• Cefazolin 2g + Metronidazole 500mg: Colorectal surgery\n'
                          '• Cefoxitin 2g or Ertapenem 1g: Alternative for colorectal\n'
                          '• Weight-based dosing: Cefazolin 3g if weight ≥120kg',
                    ),
                    _buildGuideSection(
                      context,
                      icon: Icons.warning_amber_outlined,
                      title: 'Beta-Lactam Allergy',
                      content:
                          '• Vancomycin 15mg/kg IV: Alternative for most procedures\n'
                          '• Clindamycin 900mg IV: Alternative for clean procedures\n'
                          '• Metronidazole 500mg IV: Add for anaerobic coverage (colorectal, gynecologic)\n'
                          '• Aztreonam 2g IV: Alternative for Gram-negative coverage if severe penicillin allergy',
                    ),
                    _buildGuideSection(
                      context,
                      icon: Icons.coronavirus_outlined,
                      title: 'MRSA Considerations',
                      content:
                          '• Add vancomycin 15mg/kg IV to standard cefazolin for known MRSA colonization\n'
                          '• Consider dual prophylaxis for cardiac and orthopedic procedures with implants\n'
                          '• Preoperative MRSA decolonization (mupirocin + chlorhexidine) reduces SSI risk\n'
                          '• Institutions with high MRSA rates (>20%) may require routine dual prophylaxis',
                    ),
                    _buildGuideSection(
                      context,
                      icon: Icons.book_outlined,
                      title: 'References',
                      content:
                          '• ASHP/IDSA/SIS Clinical Practice Guidelines for Antimicrobial Prophylaxis in Surgery (2013)\n'
                          '• WHO Global Guidelines for the Prevention of Surgical Site Infection (2018)\n'
                          '• CDC Healthcare Infection Control Practices Advisory Committee (HICPAC)\n'
                          '• Bratzler DW, et al. Clinical practice guidelines for antimicrobial prophylaxis in surgery. Am J Health Syst Pharm. 2013;70(3):195-283',
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
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
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
      // Step 1: Select a common procedure - Total Hip Arthroplasty
      _selectedProcedure = _allProcedures.firstWhere(
        (p) => p.id == 'total-hip-arthroplasty',
        orElse: () => _allProcedures.isNotEmpty
            ? _allProcedures.first
            : throw Exception('No procedures available'),
      );

      // Step 2: Patient profile - Example: 75-year-old patient with MRSA colonization
      _hasBetaLactamAllergy = false;
      _hasMRSAColonization = true; // MRSA colonization requires dual prophylaxis
      _weightController.text = '85'; // 85 kg patient

      // Step 3: Generate recommendation
      _currentStep = 2;
      _generateRecommendation();

      // Add example notes
      _notesController.text =
          'Example: 75-year-old patient undergoing total hip arthroplasty with known MRSA colonization. Dual prophylaxis (cefazolin + vancomycin) recommended.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Example loaded - Total Hip Arthroplasty with MRSA colonization'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Export methods
  Future<void> _exportToPdf() async {
    if (_recommendationData == null || _selectedProcedure == null) return;

    final procedure = _selectedProcedure!;
    final primaryRec =
        _recommendationData!['primaryRecommendation'] as ProphylaxisRecommendation;

    final inputs = {
      'Procedure': procedure.name,
      'Specialty': procedure.specialty.displayName,
      'Classification': procedure.classification.displayName,
      'Beta-Lactam Allergy': _hasBetaLactamAllergy ? 'Yes' : 'No',
      'MRSA Colonization': _hasMRSAColonization ? 'Yes' : 'No',
      if (_weightController.text.isNotEmpty) 'Weight': '${_weightController.text} kg',
    };

    final results = {
      'Antibiotic': primaryRec.antibioticName,
      'Dose': primaryRec.dose,
      'Route': primaryRec.route,
      'Timing': primaryRec.timing,
      'Duration': primaryRec.duration,
      if (primaryRec.redosingInterval != null)
        'Redosing': primaryRec.redosingInterval!,
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Surgical Prophylaxis Advisor',
      inputs: inputs,
      results: results,
      interpretation: primaryRec.rationale,
    );
  }

  Future<void> _exportToExcel() async {
    if (_recommendationData == null || _selectedProcedure == null) return;

    final procedure = _selectedProcedure!;
    final primaryRec =
        _recommendationData!['primaryRecommendation'] as ProphylaxisRecommendation;

    final inputs = {
      'Procedure': procedure.name,
      'Specialty': procedure.specialty.displayName,
      'Classification': procedure.classification.displayName,
      'Beta-Lactam Allergy': _hasBetaLactamAllergy ? 'Yes' : 'No',
      'MRSA Colonization': _hasMRSAColonization ? 'Yes' : 'No',
      if (_weightController.text.isNotEmpty) 'Weight': '${_weightController.text} kg',
    };

    final results = {
      'Antibiotic': primaryRec.antibioticName,
      'Dose': primaryRec.dose,
      'Route': primaryRec.route,
      'Timing': primaryRec.timing,
      'Duration': primaryRec.duration,
      if (primaryRec.redosingInterval != null)
        'Redosing': primaryRec.redosingInterval!,
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Surgical Prophylaxis Advisor',
      inputs: inputs,
      results: results,
      interpretation: primaryRec.rationale,
    );
  }

  Future<void> _exportToCsv() async {
    if (_recommendationData == null || _selectedProcedure == null) return;

    final procedure = _selectedProcedure!;
    final primaryRec =
        _recommendationData!['primaryRecommendation'] as ProphylaxisRecommendation;

    final inputs = {
      'Procedure': procedure.name,
      'Specialty': procedure.specialty.displayName,
      'Classification': procedure.classification.displayName,
      'Beta-Lactam Allergy': _hasBetaLactamAllergy ? 'Yes' : 'No',
      'MRSA Colonization': _hasMRSAColonization ? 'Yes' : 'No',
      if (_weightController.text.isNotEmpty) 'Weight': '${_weightController.text} kg',
    };

    final results = {
      'Antibiotic': primaryRec.antibioticName,
      'Dose': primaryRec.dose,
      'Route': primaryRec.route,
      'Timing': primaryRec.timing,
      'Duration': primaryRec.duration,
      if (primaryRec.redosingInterval != null)
        'Redosing': primaryRec.redosingInterval!,
    };

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Surgical Prophylaxis Advisor',
      inputs: inputs,
      results: results,
      interpretation: primaryRec.rationale,
    );
  }

  Future<void> _exportToText() async {
    if (_recommendationData == null || _selectedProcedure == null) return;

    final procedure = _selectedProcedure!;
    final primaryRec =
        _recommendationData!['primaryRecommendation'] as ProphylaxisRecommendation;

    final inputs = {
      'Procedure': procedure.name,
      'Specialty': procedure.specialty.displayName,
      'Classification': procedure.classification.displayName,
      'Beta-Lactam Allergy': _hasBetaLactamAllergy ? 'Yes' : 'No',
      'MRSA Colonization': _hasMRSAColonization ? 'Yes' : 'No',
      if (_weightController.text.isNotEmpty) 'Weight': '${_weightController.text} kg',
    };

    final results = {
      'Antibiotic': primaryRec.antibioticName,
      'Dose': primaryRec.dose,
      'Route': primaryRec.route,
      'Timing': primaryRec.timing,
      'Duration': primaryRec.duration,
      if (primaryRec.redosingInterval != null)
        'Redosing': primaryRec.redosingInterval!,
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Surgical Prophylaxis Advisor',
      inputs: inputs,
      results: results,
      interpretation: primaryRec.rationale,
    );
  }

  Future<void> _exportToImage() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) {
        throw Exception('Failed to capture screenshot');
      }

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/surgical_prophylaxis_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath)],
        subject: 'Surgical Prophylaxis Recommendation',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

