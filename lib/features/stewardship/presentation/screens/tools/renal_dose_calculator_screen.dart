import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/storage/tool_storage_service.dart';
import '../../../data/renal_function_calculator.dart';
import '../../../data/renal_dosing_database.dart';
import '../../../domain/models/renal_function.dart';
import '../../../domain/models/saved_renal_calculation.dart';

/// Renal Dose Adjustment Calculator Screen
/// 4-step wizard: Patient Info → CrCl Calculation → Drug Selection → Dose Recommendation
class RenalDoseCalculatorScreen extends StatefulWidget {
  const RenalDoseCalculatorScreen({super.key});

  @override
  State<RenalDoseCalculatorScreen> createState() => _RenalDoseCalculatorScreenState();
}

class _RenalDoseCalculatorScreenState extends State<RenalDoseCalculatorScreen> {
  int _currentStep = 0;

  // Patient info controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _creatinineController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isMale = true;

  // Calculation method
  String _calculationMethod = 'cockcroft-gault';

  // Results
  RenalFunctionResult? _renalFunctionResult;
  String? _selectedAntibioticId;
  DoseAdjustment? _doseAdjustment;

  // Storage (using generic ToolStorageService)
  final ToolStorageService<SavedRenalCalculation> _storageService = ToolStorageService<SavedRenalCalculation>(
    storageKey: 'renal_calculations',
    fromJson: SavedRenalCalculation.fromJson,
    toJson: (item) => item.toJson(),
    getId: (item) => item.id,
  );
  String? _currentCalculationId;

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _creatinineController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Renal Dose Calculator'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header section with Quick Guide and Load Example buttons
          _buildHeaderSection(),

          // Progress indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: _buildStepContent(bottomPadding),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
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
                    Icons.medication_liquid_outlined,
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
                        'Renal Dose Calculator',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Calculate renal function and adjust antibiotic doses for patients with renal impairment',
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
              // Handle
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, color: AppColors.info, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Quick Guide',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildGuideSection(
                      'What is Renal Dose Adjustment?',
                      'Renal dose adjustment is the process of modifying antibiotic dosages for patients with impaired kidney function to prevent drug accumulation, toxicity, and ensure therapeutic efficacy.',
                      Icons.info_outline,
                      AppColors.info,
                    ),
                    const SizedBox(height: 20),
                    _buildGuideSection(
                      'Calculation Methods',
                      '• Cockcroft-Gault: Estimates CrCl based on age, weight, gender, and serum creatinine\n'
                      '• MDRD: Modification of Diet in Renal Disease equation\n'
                      '• CKD-EPI: Chronic Kidney Disease Epidemiology Collaboration equation (most accurate)',
                      Icons.calculate_outlined,
                      AppColors.primary,
                    ),
                    const SizedBox(height: 20),
                    _buildGuideSection(
                      '4-Step Workflow',
                      '1. Patient Info: Enter demographics (age, weight, serum creatinine, gender)\n'
                      '2. CrCl Calculation: Calculate renal function using selected method\n'
                      '3. Drug Selection: Choose antibiotic from database\n'
                      '4. Dose Recommendation: View adjusted dose, rationale, warnings, and monitoring',
                      Icons.list_alt,
                      AppColors.success,
                    ),
                    const SizedBox(height: 20),
                    _buildGuideSection(
                      'Renal Function Categories',
                      '• Normal: CrCl ≥90 mL/min\n'
                      '• Mild Impairment: CrCl 60-89 mL/min\n'
                      '• Moderate Impairment: CrCl 30-59 mL/min\n'
                      '• Severe Impairment: CrCl 15-29 mL/min\n'
                      '• End-Stage Renal Disease: CrCl <15 mL/min',
                      Icons.category_outlined,
                      AppColors.warning,
                    ),
                    const SizedBox(height: 20),
                    _buildGuideSection(
                      'Clinical Considerations',
                      '• Always verify patient weight (actual vs ideal body weight)\n'
                      '• Consider loading doses for severe infections\n'
                      '• Monitor drug levels when available (vancomycin, aminoglycosides)\n'
                      '• Adjust for hemodialysis or CRRT if applicable\n'
                      '• Reassess renal function regularly',
                      Icons.warning_amber_outlined,
                      AppColors.error,
                    ),
                    const SizedBox(height: 20),
                    _buildGuideSection(
                      'References',
                      '• Cockcroft DW, Gault MH. Nephron. 1976;16(1):31-41\n'
                      '• Levey AS, et al. Ann Intern Med. 2009;150(9):604-612\n'
                      '• Sanford Guide to Antimicrobial Therapy 2024\n'
                      '• Lexicomp Drug Information Database',
                      Icons.library_books_outlined,
                      AppColors.textSecondary,
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

  Widget _buildGuideSection(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _loadExample() {
    setState(() {
      // Step 1: Patient Info - Example: 75-year-old male with moderate renal impairment
      _ageController.text = '75';
      _weightController.text = '70';
      _creatinineController.text = '2.1';
      _isMale = true;
      _calculationMethod = 'cockcroft-gault';

      // Step 2: Calculate renal function
      final patient = PatientInfo(
        age: 75,
        weight: 70,
        serumCreatinine: 2.1,
        isMale: true,
      );
      _renalFunctionResult = RenalFunctionCalculator.calculateAll(
        patient,
        preferredMethod: _calculationMethod,
      );

      // Step 3: Select antibiotic - Vancomycin (commonly adjusted for renal function)
      _selectedAntibioticId = 'vancomycin';
      _doseAdjustment = RenalDosingDatabase.getDoseAdjustment(
        'vancomycin',
        _renalFunctionResult!.category,
      );

      // Step 4: Jump to results
      _currentStep = 3;

      // Add example notes
      _notesController.text = 'Example patient: 75yo male with moderate renal impairment (CrCl ~30 mL/min). Monitor vancomycin trough levels closely.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Example loaded successfully - Review dose recommendation'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildProgressIndicator() {
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
      child: Row(
        children: [
          _buildStepIndicator(0, 'Patient Info', Icons.person_outline),
          _buildStepConnector(0),
          _buildStepIndicator(1, 'CrCl Calculation', Icons.calculate_outlined),
          _buildStepConnector(1),
          _buildStepIndicator(2, 'Drug Selection', Icons.medication_outlined),
          _buildStepConnector(2),
          _buildStepIndicator(3, 'Dose Recommendation', Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success
                  : isActive
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isActive || isCompleted ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
        return _buildPatientInfoStep(bottomPadding);
      case 1:
        return _buildCalculationStep(bottomPadding);
      case 2:
        return _buildDrugSelectionStep(bottomPadding);
      case 3:
        return _buildDoseRecommendationStep(bottomPadding);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPatientInfoStep(double bottomPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Patient Information',
            icon: Icons.person_outline,
            children: [
              Text(
                'Enter patient demographics for renal function calculation',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Age
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age (years)',
                  hintText: 'Enter age (18-120)',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Weight
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'Enter weight (30-300)',
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Serum Creatinine
              TextField(
                controller: _creatinineController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Serum Creatinine (mg/dL)',
                  hintText: 'Enter SCr (0.1-20)',
                  prefixIcon: const Icon(Icons.science_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Gender
              Row(
                children: [
                  const Icon(Icons.wc_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Text('Gender:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Male')),
                        ButtonSegment(value: false, label: Text('Female')),
                      ],
                      selected: {_isMale},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setState(() {
                          _isMale = newSelection.first;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationStep(double bottomPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Calculation Method',
            icon: Icons.calculate_outlined,
            children: [
              Text(
                'Select preferred calculation method',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              RadioListTile<String>(
                value: 'cockcroft-gault',
                groupValue: _calculationMethod,
                onChanged: (value) {
                  setState(() {
                    _calculationMethod = value!;
                  });
                },
                title: const Text('Cockcroft-Gault (CrCl)'),
                subtitle: const Text('Most widely used for drug dosing'),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                value: 'mdrd',
                groupValue: _calculationMethod,
                onChanged: (value) {
                  setState(() {
                    _calculationMethod = value!;
                  });
                },
                title: const Text('MDRD (eGFR)'),
                subtitle: const Text('Common in lab reports'),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                value: 'ckd-epi',
                groupValue: _calculationMethod,
                onChanged: (value) {
                  setState(() {
                    _calculationMethod = value!;
                  });
                },
                title: const Text('CKD-EPI (eGFR)'),
                subtitle: const Text('Most accurate for CKD staging'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),

          // Calculate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _calculateRenalFunction,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Renal Function'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.medium),
              ),
            ),
          ),

          // Results (if calculated)
          if (_renalFunctionResult != null) ...[
            const SizedBox(height: AppSpacing.large),
            _buildRenalFunctionResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          ...children,
        ],
      ),
    );
  }

  void _calculateRenalFunction() {
    // Validate inputs
    final age = double.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);
    final creatinine = double.tryParse(_creatinineController.text);

    if (age == null || weight == null || creatinine == null) {
      _showErrorDialog('Please enter valid numbers for all fields');
      return;
    }

    final patient = PatientInfo(
      age: age,
      weight: weight,
      serumCreatinine: creatinine,
      isMale: _isMale,
    );

    final validation = RenalFunctionCalculator.validatePatientInfo(patient);
    if (validation != null) {
      _showErrorDialog(validation);
      return;
    }

    setState(() {
      _renalFunctionResult = RenalFunctionCalculator.calculateAll(
        patient,
        preferredMethod: _calculationMethod,
      );
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildRenalFunctionResults() {
    if (_renalFunctionResult == null) return const SizedBox();

    final result = _renalFunctionResult!;
    return _buildSectionCard(
      title: 'Renal Function Results',
      icon: Icons.assessment_outlined,
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.small,
            vertical: AppSpacing.extraSmall,
          ),
          decoration: BoxDecoration(
            color: _getCategoryColor(result.category),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${result.category.label} (${result.category.range})',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),

        // Results table
        _buildResultRow('Cockcroft-Gault (CrCl)', '${result.crClCockcroftGault.toStringAsFixed(1)} mL/min'),
        _buildResultRow('MDRD (eGFR)', '${result.eGfrMdrd.toStringAsFixed(1)} mL/min/1.73m²'),
        _buildResultRow('CKD-EPI (eGFR)', '${result.eGfrCkdEpi.toStringAsFixed(1)} mL/min/1.73m²'),

        const SizedBox(height: AppSpacing.small),
        const Divider(),
        const SizedBox(height: AppSpacing.small),

        // Interpretation
        Text(
          RenalFunctionCalculator.getInterpretation(result.category),
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(RenalCategory category) {
    switch (category) {
      case RenalCategory.normal:
        return AppColors.success;
      case RenalCategory.mild:
        return AppColors.info;
      case RenalCategory.moderate:
        return AppColors.warning;
      case RenalCategory.severe:
      case RenalCategory.esrd:
        return AppColors.error;
    }
  }

  Widget _buildDrugSelectionStep(double bottomPadding) {
    if (_renalFunctionResult == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 64,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Please calculate renal function first',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final antibioticIds = RenalDosingDatabase.getAllAntibioticIds();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Select Antibiotic',
            icon: Icons.medication_outlined,
            children: [
              Text(
                'Choose the antibiotic for dose adjustment',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),

              // Antibiotic list
              ...antibioticIds.map((id) {
                final name = RenalDosingDatabase.getAntibioticName(id);
                final isSelected = _selectedAntibioticId == id;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.small),
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : null,
                  child: ListTile(
                    leading: Icon(
                      Icons.medication,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedAntibioticId = id;
                        // Get dose adjustment
                        _doseAdjustment = RenalDosingDatabase.getDoseAdjustment(
                          id,
                          _renalFunctionResult!.category,
                        );
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoseRecommendationStep(double bottomPadding) {
    if (_doseAdjustment == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 64,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Please select an antibiotic first',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dose = _doseAdjustment!;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with antibiotic name and renal category
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.info.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.medication, color: AppColors.primary, size: 32),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dose.antibioticName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(dose.renalCategory),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          dose.renalCategory.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.medium),

          // Dosing information
          _buildSectionCard(
            title: 'Dose Adjustment',
            icon: Icons.science_outlined,
            children: [
              _buildDoseInfoRow('Normal Dose', dose.normalDose, Icons.info_outline),
              const Divider(),
              _buildDoseInfoRow('Adjusted Dose', dose.adjustedDose, Icons.check_circle, isHighlight: true),
              _buildDoseInfoRow('Interval', dose.interval, Icons.schedule),
              if (dose.loadingDose != null) ...[
                const Divider(),
                _buildDoseInfoRow('Loading Dose', dose.loadingDose!, Icons.bolt_outlined, color: AppColors.warning),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.medium),

          // Rationale
          _buildSectionCard(
            title: 'Rationale',
            icon: Icons.lightbulb_outline,
            children: [
              Text(
                dose.rationale,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),

          // Warnings
          if (dose.warnings.isNotEmpty)
            _buildSectionCard(
              title: 'Warnings',
              icon: Icons.warning_amber_outlined,
              children: [
                ...dose.warnings.map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning, color: AppColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              warning,
                              style: TextStyle(fontSize: 13, color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          const SizedBox(height: AppSpacing.medium),

          // Monitoring
          if (dose.monitoring.isNotEmpty)
            _buildSectionCard(
              title: 'Monitoring',
              icon: Icons.monitor_heart_outlined,
              children: [
                ...dose.monitoring.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check, color: AppColors.success, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(item, style: const TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),

          // Hemodialysis note
          if (dose.hemodialysisNote != null) ...[
            const SizedBox(height: AppSpacing.medium),
            _buildSectionCard(
              title: 'Hemodialysis',
              icon: Icons.water_drop_outlined,
              children: [
                Text(
                  dose.hemodialysisNote!,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],

          // CRRT note
          if (dose.crrtNote != null) ...[
            const SizedBox(height: AppSpacing.medium),
            _buildSectionCard(
              title: 'CRRT',
              icon: Icons.water_outlined,
              children: [
                Text(
                  dose.crrtNote!,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],

          // Clinical Notes Section
          const SizedBox(height: AppSpacing.medium),
          _buildSectionCard(
            title: 'Clinical Notes',
            icon: Icons.note_outlined,
            children: [
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add clinical notes, special considerations, or follow-up plans...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          // Save & Export Buttons
          const SizedBox(height: AppSpacing.large),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveCalculation,
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
    );
  }

  Widget _buildDoseInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlight = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? (isHighlight ? AppColors.primary : AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                    color: color ?? (isHighlight ? AppColors.primary : null),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
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
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.small),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _canProceed() ? _handleNext : null,
              icon: Icon(_currentStep == 3 ? Icons.check : Icons.arrow_forward),
              label: Text(_currentStep == 3 ? 'Done' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _ageController.text.isNotEmpty &&
            _weightController.text.isNotEmpty &&
            _creatinineController.text.isNotEmpty;
      case 1:
        return _renalFunctionResult != null;
      case 2:
        return _selectedAntibioticId != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  // Save calculation
  Future<void> _saveCalculation() async {
    if (_renalFunctionResult == null) return;

    final patientInitials = await _showPatientInitialsDialog();
    if (patientInitials == null || patientInitials.isEmpty) return;

    final patient = PatientInfo(
      age: double.parse(_ageController.text),
      weight: double.parse(_weightController.text),
      serumCreatinine: double.parse(_creatinineController.text),
      isMale: _isMale,
    );

    final calculation = SavedRenalCalculation(
      id: _currentCalculationId ?? const Uuid().v4(),
      timestamp: DateTime.now(),
      patientInitials: patientInitials,
      patientInfo: patient,
      renalFunctionResult: _renalFunctionResult!,
      calculationMethod: _calculationMethod,
      doseAdjustment: _doseAdjustment,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await _storageService.save(calculation);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calculation saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }

    setState(() {
      _currentCalculationId = calculation.id;
    });
  }

  Future<String?> _showPatientInitialsDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Calculation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Patient Initials',
            hintText: 'e.g., JD',
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Export options
  void _showExportOptions() {
    ExportModal.show(
      context: context,
      onExportPDF: _exportToPdf,
      onExportCSV: () {
        // CSV export not implemented for renal dose calculator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV export not available for renal dose calculations'),
            backgroundColor: AppColors.info,
          ),
        );
      },
      onExportExcel: _exportToExcel,
      onExportText: () {
        // Text export not implemented for renal dose calculator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text export not available for renal dose calculations'),
            backgroundColor: AppColors.info,
          ),
        );
      },
      enablePhoto: false,
    );
  }

  // Export to PDF
  Future<void> _exportToPdf() async {
    if (_renalFunctionResult == null || _doseAdjustment == null) return;

    // Prepare warnings and monitoring as strings
    final warningsText = _doseAdjustment!.warnings.isNotEmpty
        ? _doseAdjustment!.warnings.map((w) => '• $w').join('\n')
        : 'None';

    final monitoringText = _doseAdjustment!.monitoring.isNotEmpty
        ? _doseAdjustment!.monitoring.map((m) => '• $m').join('\n')
        : 'None';

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Renal Dose Adjustment Calculator',
      inputs: {
        'Age': '${_ageController.text} years',
        'Weight': '${_weightController.text} kg',
        'Serum Creatinine': '${_creatinineController.text} mg/dL',
        'Gender': _isMale ? 'Male' : 'Female',
        'Calculation Method': _calculationMethod.toUpperCase(),
      },
      results: {
        'CrCl (Cockcroft-Gault)': '${_renalFunctionResult!.crClCockcroftGault.toStringAsFixed(1)} mL/min',
        'eGFR (MDRD)': '${_renalFunctionResult!.eGfrMdrd.toStringAsFixed(1)} mL/min/1.73m²',
        'eGFR (CKD-EPI)': '${_renalFunctionResult!.eGfrCkdEpi.toStringAsFixed(1)} mL/min/1.73m²',
        'Renal Category': '${_renalFunctionResult!.category.label} (${_renalFunctionResult!.category.range})',
        'Antibiotic': _doseAdjustment!.antibioticName,
        'Normal Dose': _doseAdjustment!.normalDose,
        'Adjusted Dose': _doseAdjustment!.adjustedDose,
        'Interval': _doseAdjustment!.interval,
        if (_doseAdjustment!.loadingDose != null)
          'Loading Dose': _doseAdjustment!.loadingDose!,
      },
      interpretation: _doseAdjustment!.rationale,
      recommendations: 'WARNINGS:\n$warningsText\n\nMONITORING:\n$monitoringText${_notesController.text.isNotEmpty ? '\n\nCLINICAL NOTES:\n${_notesController.text}' : ''}',
    );
  }

  // Export to Excel
  Future<void> _exportToExcel() async {
    if (_renalFunctionResult == null || _doseAdjustment == null) return;

    // Prepare warnings and monitoring as strings
    final warningsText = _doseAdjustment!.warnings.isNotEmpty
        ? _doseAdjustment!.warnings.map((w) => '• $w').join('\n')
        : 'None';

    final monitoringText = _doseAdjustment!.monitoring.isNotEmpty
        ? _doseAdjustment!.monitoring.map((m) => '• $m').join('\n')
        : 'None';

    // Build recommendations string
    final recommendationsBuffer = StringBuffer();
    recommendationsBuffer.writeln('WARNINGS:');
    recommendationsBuffer.writeln(warningsText);
    recommendationsBuffer.writeln();
    recommendationsBuffer.writeln('MONITORING:');
    recommendationsBuffer.writeln(monitoringText);

    if (_doseAdjustment!.hemodialysisNote != null) {
      recommendationsBuffer.writeln();
      recommendationsBuffer.writeln('HEMODIALYSIS:');
      recommendationsBuffer.writeln(_doseAdjustment!.hemodialysisNote!);
    }

    if (_doseAdjustment!.crrtNote != null) {
      recommendationsBuffer.writeln();
      recommendationsBuffer.writeln('CRRT:');
      recommendationsBuffer.writeln(_doseAdjustment!.crrtNote!);
    }

    if (_notesController.text.isNotEmpty) {
      recommendationsBuffer.writeln();
      recommendationsBuffer.writeln('CLINICAL NOTES:');
      recommendationsBuffer.writeln(_notesController.text);
    }

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Renal Dose Adjustment Calculator',
      inputs: {
        'Age': '${_ageController.text} years',
        'Weight': '${_weightController.text} kg',
        'Serum Creatinine': '${_creatinineController.text} mg/dL',
        'Gender': _isMale ? 'Male' : 'Female',
        'Calculation Method': _calculationMethod.toUpperCase(),
      },
      results: {
        'CrCl (Cockcroft-Gault)': '${_renalFunctionResult!.crClCockcroftGault.toStringAsFixed(1)} mL/min',
        'eGFR (MDRD)': '${_renalFunctionResult!.eGfrMdrd.toStringAsFixed(1)} mL/min/1.73m²',
        'eGFR (CKD-EPI)': '${_renalFunctionResult!.eGfrCkdEpi.toStringAsFixed(1)} mL/min/1.73m²',
        'Renal Category': '${_renalFunctionResult!.category.label} (${_renalFunctionResult!.category.range})',
        'Antibiotic': _doseAdjustment!.antibioticName,
        'Normal Dose': _doseAdjustment!.normalDose,
        'Adjusted Dose': _doseAdjustment!.adjustedDose,
        'Interval': _doseAdjustment!.interval,
        if (_doseAdjustment!.loadingDose != null)
          'Loading Dose': _doseAdjustment!.loadingDose!,
      },
      interpretation: _doseAdjustment!.rationale,
      recommendations: recommendationsBuffer.toString(),
    );
  }

}

