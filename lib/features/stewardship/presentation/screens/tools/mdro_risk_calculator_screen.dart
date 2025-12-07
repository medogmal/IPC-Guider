import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/back_button.dart';
import '../../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../data/models/mdro_assessment.dart';
import '../../../data/repositories/mdro_risk_repository.dart';
import '../../../data/services/mdro_risk_storage_service.dart';

class MdroRiskCalculatorScreen extends ConsumerStatefulWidget {
  const MdroRiskCalculatorScreen({super.key});

  @override
  ConsumerState<MdroRiskCalculatorScreen> createState() => _MdroRiskCalculatorScreenState();
}

class _MdroRiskCalculatorScreenState extends ConsumerState<MdroRiskCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = MdroRiskRepository();
  final _storageService = MdroRiskStorageService();

  // State variables
  bool _isLoading = false;
  bool _showResults = false;
  MdroAssessment? _assessment;
  List<Map<String, dynamic>> _references = [];

  // Input variables - Patient Demographics
  String? _selectedAge;
  String? _selectedGender;

  // Input variables - Healthcare Exposure
  String? _selectedHospitalAdmission;
  String? _selectedIcuStay;
  String? _selectedNursingHome;
  bool _hemodialysis = false;
  bool _surgery = false;

  // Input variables - Antibiotic Exposure
  String? _selectedAntibioticUse;
  final List<String> _selectedBroadSpectrumAntibiotics = [];

  // Input variables - Clinical Factors
  final List<String> _selectedInvasiveDevices = [];
  final List<String> _selectedImmunosuppression = [];
  final List<String> _selectedChronicConditions = [];

  // Input variables - Previous MDRO History
  String? _selectedPriorMdro;
  final List<String> _selectedMdroTypes = [];

  // Input variables - Geographic/Epidemiologic
  bool _internationalTravel = false;
  bool _knownMdroContact = false;

  // Dropdown options
  final List<String> _ageOptions = [
    '<1 year',
    '1-17 years',
    '18-64 years',
    '65-79 years',
    '≥80 years',
  ];

  final List<String> _genderOptions = ['Male', 'Female'];

  final List<String> _hospitalAdmissionOptions = [
    'None',
    '1-2 days',
    '3-7 days',
    '8-14 days',
    '>14 days',
  ];

  final List<String> _icuStayOptions = [
    'No',
    'Yes (<7 days)',
    'Yes (≥7 days)',
  ];

  final List<String> _nursingHomeOptions = [
    'No',
    'Yes (<30 days)',
    'Yes (≥30 days)',
  ];

  final List<String> _antibioticUseOptions = [
    'None',
    '1-3 days',
    '4-7 days',
    '8-14 days',
    '>14 days',
  ];

  final List<String> _broadSpectrumAntibioticOptions = [
    '3rd/4th gen cephalosporins',
    'Carbapenems',
    'Fluoroquinolones',
    'Piperacillin-tazobactam',
  ];

  final List<String> _invasiveDeviceOptions = [
    'Central line',
    'Urinary catheter',
    'Endotracheal tube',
    'Surgical drain',
  ];

  final List<String> _immunosuppressionOptions = [
    'Chemotherapy',
    'Solid organ transplant',
    'Hematopoietic stem cell transplant',
    'Chronic steroids (>10mg/day prednisone)',
    'HIV/AIDS (CD4 <200)',
  ];

  final List<String> _chronicConditionOptions = [
    'Diabetes mellitus',
    'Chronic kidney disease',
    'Chronic liver disease',
    'COPD',
    'Malignancy',
  ];

  final List<String> _priorMdroOptions = [
    'No',
    'Yes (>12 months ago)',
    'Yes (within 12 months)',
  ];

  final List<String> _mdroTypeOptions = [
    'MRSA',
    'VRE',
    'ESBL',
    'CRE',
    'MDR Pseudomonas',
    'MDR Acinetobacter',
    'C. difficile',
  ];

  @override
  void initState() {
    super.initState();
    _loadReferences();
  }

  Future<void> _loadReferences() async {
    try {
      final references = await _repository.getReferences();
      setState(() {
        _references = references;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'MDRO Risk Calculator',
        backgroundColor: AppColors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showQuickGuide,
            tooltip: 'Quick Guide',
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),

              // Quick Guide Button
              SizedBox(
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

              const SizedBox(height: 24),
              _buildInputSection(),
              if (_showResults && _assessment != null) ...[
                const SizedBox(height: AppSpacing.large),
                _buildResultsSection(),
              ],
              const SizedBox(height: AppSpacing.large),
              _buildReferencesSection(),
              const SizedBox(height: 48),
            ],
          ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.biotech_outlined,
                  color: AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MDRO Risk Calculator',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Predict patient-specific multidrug-resistant organism risk',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Form(
      key: _formKey,
      child: Container(
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
            // Section 1: Patient Demographics
            _buildSectionHeader('Patient Demographics', Icons.person_outline),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAge,
              decoration: const InputDecoration(
                labelText: 'Age *',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: _ageOptions.map((age) {
                return DropdownMenuItem(value: age, child: Text(age));
              }).toList(),
              onChanged: (value) => setState(() => _selectedAge = value),
              validator: (value) => value == null ? 'Please select age' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender (Optional)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: _genderOptions.map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Section 2: Healthcare Exposure (Past 90 Days)
            _buildSectionHeader('Healthcare Exposure (Past 90 Days)', Icons.local_hospital_outlined),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedHospitalAdmission,
              decoration: const InputDecoration(
                labelText: 'Hospital Admission *',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: _hospitalAdmissionOptions.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: (value) => setState(() => _selectedHospitalAdmission = value),
              validator: (value) => value == null ? 'Please select hospital admission' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedIcuStay,
              decoration: const InputDecoration(
                labelText: 'ICU Stay *',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: _icuStayOptions.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: (value) => setState(() => _selectedIcuStay = value),
              validator: (value) => value == null ? 'Please select ICU stay' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedNursingHome,
              decoration: const InputDecoration(
                labelText: 'Nursing Home/LTCF Residence *',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: _nursingHomeOptions.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: (value) => setState(() => _selectedNursingHome = value),
              validator: (value) => value == null ? 'Please select nursing home status' : null,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Hemodialysis'),
              value: _hemodialysis,
              onChanged: (value) => setState(() => _hemodialysis = value ?? false),
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Surgery'),
              value: _surgery,
              onChanged: (value) => setState(() => _surgery = value ?? false),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Section 3: Antibiotic Exposure (Past 90 Days)
            _buildSectionHeader('Antibiotic Exposure (Past 90 Days)', Icons.medication_outlined),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAntibioticUse,
              decoration: const InputDecoration(
                labelText: 'Antibiotic Use *',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: _antibioticUseOptions.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: (value) => setState(() => _selectedAntibioticUse = value),
              validator: (value) => value == null ? 'Please select antibiotic use' : null,
            ),
            const SizedBox(height: 16),
            Text(
              'Broad-Spectrum Antibiotics (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ..._broadSpectrumAntibioticOptions.map((antibiotic) {
              return CheckboxListTile(
                title: Text(antibiotic),
                value: _selectedBroadSpectrumAntibiotics.contains(antibiotic),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedBroadSpectrumAntibiotics.add(antibiotic);
                    } else {
                      _selectedBroadSpectrumAntibiotics.remove(antibiotic);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Section 4: Clinical Factors
            _buildSectionHeader('Clinical Factors', Icons.medical_services_outlined),
            const SizedBox(height: 16),
            Text(
              'Invasive Devices (Current)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ..._invasiveDeviceOptions.map((device) {
              return CheckboxListTile(
                title: Text(device),
                value: _selectedInvasiveDevices.contains(device),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedInvasiveDevices.add(device);
                    } else {
                      _selectedInvasiveDevices.remove(device);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 16),
            Text(
              'Immunosuppression',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ..._immunosuppressionOptions.map((condition) {
              return CheckboxListTile(
                title: Text(condition),
                value: _selectedImmunosuppression.contains(condition),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedImmunosuppression.add(condition);
                    } else {
                      _selectedImmunosuppression.remove(condition);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 16),
            Text(
              'Chronic Conditions (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ..._chronicConditionOptions.map((condition) {
              return CheckboxListTile(
                title: Text(condition),
                value: _selectedChronicConditions.contains(condition),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedChronicConditions.add(condition);
                    } else {
                      _selectedChronicConditions.remove(condition);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Section 5: Previous MDRO History
            _buildSectionHeader('Previous MDRO History', Icons.history),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriorMdro,
              decoration: const InputDecoration(
                labelText: 'Prior MDRO Colonization/Infection *',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: _priorMdroOptions.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: (value) => setState(() => _selectedPriorMdro = value),
              validator: (value) => value == null ? 'Please select prior MDRO status' : null,
            ),
            if (_selectedPriorMdro != null && _selectedPriorMdro != 'No') ...[
              const SizedBox(height: 16),
              Text(
                'MDRO Type(s)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ..._mdroTypeOptions.map((type) {
                return CheckboxListTile(
                  title: Text(type),
                  value: _selectedMdroTypes.contains(type),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedMdroTypes.add(type);
                      } else {
                        _selectedMdroTypes.remove(type);
                      }
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Section 6: Geographic/Epidemiologic Factors
            _buildSectionHeader('Geographic/Epidemiologic Factors', Icons.public),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('International Travel/Healthcare (past 12 months)'),
              subtitle: const Text('Travel to high-prevalence region with healthcare exposure'),
              value: _internationalTravel,
              onChanged: (value) => setState(() => _internationalTravel = value ?? false),
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Known MDRO Contact'),
              subtitle: const Text('Household contact or roommate with known MDRO'),
              value: _knownMdroContact,
              onChanged: (value) => setState(() => _knownMdroContact = value ?? false),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _calculateRisk,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.calculate, size: 20),
                label: Text(_isLoading ? 'Calculating...' : 'Calculate MDRO Risk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _calculateRisk() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final scoringRules = await _repository.getScoringRules();
      final thresholds = await _repository.getRiskThresholds();
      final organismRiskFactors = await _repository.getOrganismRiskFactors();
      final recommendations = await _repository.getRecommendations();

      final inputs = {
        'age': _selectedAge!,
        'gender': _selectedGender,
        'hospitalAdmission': _selectedHospitalAdmission!,
        'icuStay': _selectedIcuStay!,
        'nursingHome': _selectedNursingHome!,
        'hemodialysis': _hemodialysis,
        'surgery': _surgery,
        'antibioticUse': _selectedAntibioticUse!,
        'broadSpectrumAntibiotics': _selectedBroadSpectrumAntibiotics,
        'invasiveDevices': _selectedInvasiveDevices,
        'immunosuppression': _selectedImmunosuppression,
        'chronicConditions': _selectedChronicConditions,
        'priorMdro': _selectedPriorMdro!,
        'mdroTypes': _selectedMdroTypes,
        'internationalTravel': _internationalTravel,
        'knownMdroContact': _knownMdroContact,
      };

      final riskScore = _repository.calculateRiskScore(inputs, scoringRules);
      final riskCategoryData = _repository.getRiskCategory(riskScore, thresholds);
      final organismRisks = _repository.calculateOrganismRisks(inputs, organismRiskFactors);

      final riskCategory = riskCategoryData['label'] as String;
      final mdroProbability = (riskCategoryData['probability'] as int).toDouble();

      // Map risk category to JSON key
      String riskKey;
      if (riskCategory == 'Low Risk') {
        riskKey = 'low';
      } else if (riskCategory == 'Moderate Risk') {
        riskKey = 'moderate';
      } else if (riskCategory == 'High Risk') {
        riskKey = 'high';
      } else if (riskCategory == 'Very High Risk') {
        riskKey = 'veryHigh';
      } else {
        riskKey = 'low'; // fallback
      }

      final recommendationData = recommendations[riskKey] as Map<String, dynamic>;

      final assessment = MdroAssessment(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        age: _selectedAge!,
        gender: _selectedGender,
        hospitalAdmission: _selectedHospitalAdmission!,
        icuStay: _selectedIcuStay!,
        nursingHome: _selectedNursingHome!,
        hemodialysis: _hemodialysis,
        surgery: _surgery,
        antibioticUse: _selectedAntibioticUse!,
        broadSpectrumAntibiotics: _selectedBroadSpectrumAntibiotics,
        invasiveDevices: _selectedInvasiveDevices,
        immunosuppression: _selectedImmunosuppression,
        chronicConditions: _selectedChronicConditions,
        priorMdro: _selectedPriorMdro!,
        mdroTypes: _selectedMdroTypes,
        internationalTravel: _internationalTravel,
        knownMdroContact: _knownMdroContact,
        riskScore: riskScore,
        riskCategory: riskCategory,
        mdroProbability: mdroProbability,
        riskExplanation: _generateRiskExplanation(riskScore, riskCategory, inputs),
        organismRisks: organismRisks,
        isolationPrecautions: [recommendationData['isolation'] as String],
        screeningRecommendations: [recommendationData['screening'] as String],
        empiricTherapy: recommendationData['empiricTherapy'] as String,
        stewardshipRecommendations: List<String>.from(recommendationData['stewardship'] as List),
      );

      setState(() {
        _assessment = assessment;
        _showResults = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculating risk: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _generateRiskExplanation(int score, String category, Map<String, dynamic> inputs) {
    final List<String> factors = [];

    if (inputs['hospitalAdmission'] != 'None') {
      factors.add('recent hospitalization');
    }
    if (inputs['icuStay'] != 'No') {
      factors.add('ICU stay');
    }
    if (inputs['nursingHome'] != 'No') {
      factors.add('nursing home residence');
    }
    if (inputs['hemodialysis'] as bool) {
      factors.add('hemodialysis');
    }
    if (inputs['antibioticUse'] != 'None') {
      factors.add('antibiotic exposure');
    }
    if ((inputs['broadSpectrumAntibiotics'] as List).isNotEmpty) {
      factors.add('broad-spectrum antibiotics');
    }
    if ((inputs['invasiveDevices'] as List).isNotEmpty) {
      factors.add('invasive devices');
    }
    if ((inputs['immunosuppression'] as List).isNotEmpty) {
      factors.add('immunosuppression');
    }
    if (inputs['priorMdro'] != 'No') {
      factors.add('prior MDRO history');
    }

    String explanation = 'Risk score: $score/100 ($category). ';
    if (factors.isNotEmpty) {
      explanation += 'Key risk factors: ${factors.join(", ")}.';
    } else {
      explanation += 'No significant risk factors identified.';
    }

    return explanation;
  }

  Widget _buildResultsSection() {
    if (_assessment == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildRiskScoreCard(),
        const SizedBox(height: AppSpacing.medium),
        _buildOrganismRiskCard(),
        const SizedBox(height: AppSpacing.medium),
        _buildRecommendationsCard(),
        const SizedBox(height: AppSpacing.medium),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildRiskScoreCard() {
    Color riskColor = AppColors.success;
    IconData riskIcon = Icons.check_circle;

    if (_assessment!.riskCategory == 'Very High Risk') {
      riskColor = AppColors.error;
      riskIcon = Icons.error;
    } else if (_assessment!.riskCategory == 'High Risk') {
      riskColor = AppColors.warning;
      riskIcon = Icons.warning;
    } else if (_assessment!.riskCategory == 'Moderate Risk') {
      riskColor = AppColors.info;
      riskIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(riskIcon, color: riskColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MDRO Risk Assessment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_assessment!.riskCategory.toUpperCase()} (${_assessment!.riskScore}/100)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _assessment!.riskExplanation,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 20, color: riskColor),
                const SizedBox(width: 8),
                Text(
                  'Estimated MDRO Probability: ${_assessment!.mdroProbability.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: riskColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganismRiskCard() {
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
              Icon(Icons.biotech, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Organism-Specific Risk Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._assessment!.organismRisks.entries.map((entry) {
            Color badgeColor = AppColors.success;
            if (entry.value == 'High') {
              badgeColor = AppColors.warning;
            } else if (entry.value == 'Moderate') {
              badgeColor = AppColors.info;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
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
              Icon(Icons.medical_services, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Clinical Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendationSection('Isolation Precautions', _assessment!.isolationPrecautions[0]),
          const SizedBox(height: 12),
          _buildRecommendationSection('Screening', _assessment!.screeningRecommendations[0]),
          const SizedBox(height: 12),
          _buildRecommendationSection('Empiric Therapy', _assessment!.empiricTherapy),
          const SizedBox(height: 12),
          Text(
            'Antimicrobial Stewardship:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ..._assessment!.stewardshipRecommendations.map((rec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: AppColors.primary, fontSize: 16)),
                  Expanded(
                    child: Text(
                      rec,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveAssessment,
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

  Widget _buildReferencesSection() {
    if (_references.isEmpty) return const SizedBox.shrink();

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
              Icon(Icons.library_books, size: 20, color: AppColors.primary),
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
          const SizedBox(height: 16),
          ..._references.asMap().entries.map((entry) {
            final index = entry.key;
            final ref = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _launchURL(ref['url'] as String),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ref['title'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.info,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.open_in_new, size: 16, color: AppColors.info),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveAssessment() async {
    if (_assessment == null) return;

    try {
      await _storageService.saveAssessment(_assessment!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Assessment saved successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving assessment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showExportModal() {
    if (_assessment == null) return;

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
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: SafeArea(
            child: KnowledgePanelWidget(
              data: KnowledgePanelData(
                definition: 'The MDRO Risk Calculator is an evidence-based tool that predicts patient-specific risk of colonization or infection with multidrug-resistant organisms (MDROs) to guide screening, isolation precautions, and empiric therapy decisions.',
                formula: 'Evidence-based scoring system (0-100 points) based on CDC/WHO/IDSA guidelines',
                example: 'Example: 80-year-old patient with 15-day hospitalization, ICU stay ≥7 days, nursing home residence ≥30 days, hemodialysis, >14 days of antibiotics including carbapenems and fluoroquinolones, central line, urinary catheter, chronic steroids, diabetes, CKD, prior MRSA and VRE within 12 months → Very High Risk (70+ points, >50% MDRO probability)',
                interpretation: 'Risk Categories:\n\n• Low Risk (0-20 points, <10% probability): Standard precautions, no routine screening, narrow-spectrum empiric therapy\n\n• Moderate Risk (21-40 points, 10-30% probability): Consider contact precautions, targeted screening, MRSA/ESBL coverage if septic\n\n• High Risk (41-60 points, 30-50% probability): Contact precautions, active surveillance cultures, broad-spectrum empiric therapy, mandatory ID consultation\n\n• Very High Risk (>60 points, >50% probability): Strict isolation, comprehensive screening, maximum broad-spectrum coverage, consider CRE coverage',
                whenUsed: 'Use this calculator when:\n\n1. Admitting patients from high-risk settings (nursing homes, hospitals, international healthcare)\n2. Deciding empiric antibiotic therapy for septic patients\n3. Determining need for contact precautions and active surveillance cultures\n4. Guiding antimicrobial stewardship interventions\n5. Stratifying patients for targeted MDRO screening programs\n\nKey Risk Factors:\n• Prior MDRO colonization (strongest predictor: 50-80% persistence at 1 year)\n• ICU stay and broad-spectrum antibiotics (major modifiable factors)\n• International healthcare exposure (increases CRE/NDM risk 10-20x)\n• Organism-specific risks guide targeted screening (MRSA: nasal, VRE/ESBL/CRE: rectal)\n\nNote: This tool is for educational purposes; clinical judgment and local epidemiology should guide final decisions.',
                references: _references.map((ref) => Reference(
                  title: ref['title'] as String,
                  url: ref['url'] as String,
                )).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loadExample() {
    setState(() {
      _selectedAge = '≥80 years';
      _selectedGender = 'Male';
      _selectedHospitalAdmission = '>14 days';
      _selectedIcuStay = 'Yes (≥7 days)';
      _selectedNursingHome = 'Yes (≥30 days)';
      _hemodialysis = true;
      _surgery = false;
      _selectedAntibioticUse = '>14 days';
      _selectedBroadSpectrumAntibiotics.clear();
      _selectedBroadSpectrumAntibiotics.addAll(['Carbapenems', 'Fluoroquinolones']);
      _selectedInvasiveDevices.clear();
      _selectedInvasiveDevices.addAll(['Central line', 'Urinary catheter']);
      _selectedImmunosuppression.clear();
      _selectedImmunosuppression.add('Chronic steroids (>10mg/day prednisone)');
      _selectedChronicConditions.clear();
      _selectedChronicConditions.addAll(['Diabetes mellitus', 'Chronic kidney disease']);
      _selectedPriorMdro = 'Yes (within 12 months)';
      _selectedMdroTypes.clear();
      _selectedMdroTypes.addAll(['MRSA', 'VRE']);
      _internationalTravel = false;
      _knownMdroContact = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example loaded: Very high-risk patient'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    if (_assessment == null) return;

    try {
      final inputs = {
        'Age': _assessment!.age,
        if (_assessment!.gender != null) 'Gender': _assessment!.gender!,
        'Hospital Admission (90d)': _assessment!.hospitalAdmission,
        'ICU Stay (90d)': _assessment!.icuStay,
        'Nursing Home (90d)': _assessment!.nursingHome,
        'Hemodialysis': _assessment!.hemodialysis ? 'Yes' : 'No',
        'Surgery (90d)': _assessment!.surgery ? 'Yes' : 'No',
        'Antibiotic Use (90d)': _assessment!.antibioticUse,
        if (_assessment!.broadSpectrumAntibiotics.isNotEmpty)
          'Broad-Spectrum Antibiotics': _assessment!.broadSpectrumAntibiotics.join(', '),
        if (_assessment!.invasiveDevices.isNotEmpty)
          'Invasive Devices': _assessment!.invasiveDevices.join(', '),
        if (_assessment!.immunosuppression.isNotEmpty)
          'Immunosuppression': _assessment!.immunosuppression.join(', '),
        if (_assessment!.chronicConditions.isNotEmpty)
          'Chronic Conditions': _assessment!.chronicConditions.join(', '),
        'Prior MDRO': _assessment!.priorMdro,
        if (_assessment!.mdroTypes.isNotEmpty)
          'MDRO Types': _assessment!.mdroTypes.join(', '),
        'International Travel': _assessment!.internationalTravel ? 'Yes' : 'No',
        'Known MDRO Contact': _assessment!.knownMdroContact ? 'Yes' : 'No',
      };

      final results = {
        'Risk Score': '${_assessment!.riskScore}/100',
        'Risk Category': _assessment!.riskCategory,
        'MDRO Probability': '${_assessment!.mdroProbability.toStringAsFixed(0)}%',
        'Risk Explanation': _assessment!.riskExplanation,
        'Organism Risks': _assessment!.organismRisks.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('\n'),
        'Isolation Precautions': _assessment!.isolationPrecautions.join('\n'),
        'Screening': _assessment!.screeningRecommendations.join('\n'),
        'Empiric Therapy': _assessment!.empiricTherapy,
      };

      await UnifiedExportService.exportCalculatorAsPDF(
        context: context,
        toolName: 'MDRO Risk Calculator',
        formula: 'Evidence-based scoring system (0-100 points)',
        inputs: inputs,
        results: results,
        benchmark: {},
        recommendations: _assessment!.stewardshipRecommendations.join('\n'),
        interpretation: _assessment!.riskExplanation,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Exported as PDF successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _exportAsExcel() async {
    if (_assessment == null) return;

    try {
      final inputs = {
        'Age': _assessment!.age,
        if (_assessment!.gender != null) 'Gender': _assessment!.gender!,
        'Hospital Admission (90d)': _assessment!.hospitalAdmission,
        'ICU Stay (90d)': _assessment!.icuStay,
        'Nursing Home (90d)': _assessment!.nursingHome,
        'Hemodialysis': _assessment!.hemodialysis ? 'Yes' : 'No',
        'Surgery (90d)': _assessment!.surgery ? 'Yes' : 'No',
        'Antibiotic Use (90d)': _assessment!.antibioticUse,
        if (_assessment!.broadSpectrumAntibiotics.isNotEmpty)
          'Broad-Spectrum Antibiotics': _assessment!.broadSpectrumAntibiotics.join(', '),
        if (_assessment!.invasiveDevices.isNotEmpty)
          'Invasive Devices': _assessment!.invasiveDevices.join(', '),
        if (_assessment!.immunosuppression.isNotEmpty)
          'Immunosuppression': _assessment!.immunosuppression.join(', '),
        if (_assessment!.chronicConditions.isNotEmpty)
          'Chronic Conditions': _assessment!.chronicConditions.join(', '),
        'Prior MDRO': _assessment!.priorMdro,
        if (_assessment!.mdroTypes.isNotEmpty)
          'MDRO Types': _assessment!.mdroTypes.join(', '),
        'International Travel': _assessment!.internationalTravel ? 'Yes' : 'No',
        'Known MDRO Contact': _assessment!.knownMdroContact ? 'Yes' : 'No',
      };

      final results = {
        'Risk Score': '${_assessment!.riskScore}/100',
        'Risk Category': _assessment!.riskCategory,
        'MDRO Probability': '${_assessment!.mdroProbability.toStringAsFixed(0)}%',
        'Risk Explanation': _assessment!.riskExplanation,
        'Organism Risks': _assessment!.organismRisks.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('\n'),
        'Isolation Precautions': _assessment!.isolationPrecautions.join('\n'),
        'Screening': _assessment!.screeningRecommendations.join('\n'),
        'Empiric Therapy': _assessment!.empiricTherapy,
      };

      await UnifiedExportService.exportCalculatorAsExcel(
        context: context,
        toolName: 'MDRO Risk Calculator',
        formula: 'Evidence-based scoring system (0-100 points)',
        inputs: inputs,
        results: results,
        benchmark: {},
        recommendations: _assessment!.stewardshipRecommendations.join('\n'),
        interpretation: _assessment!.riskExplanation,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Exported as Excel successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting Excel: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _exportAsCSV() async {
    if (_assessment == null) return;

    try {
      final inputs = {
        'Age': _assessment!.age,
        if (_assessment!.gender != null) 'Gender': _assessment!.gender!,
        'Hospital Admission (90d)': _assessment!.hospitalAdmission,
        'ICU Stay (90d)': _assessment!.icuStay,
        'Nursing Home (90d)': _assessment!.nursingHome,
        'Hemodialysis': _assessment!.hemodialysis ? 'Yes' : 'No',
        'Surgery (90d)': _assessment!.surgery ? 'Yes' : 'No',
        'Antibiotic Use (90d)': _assessment!.antibioticUse,
        if (_assessment!.broadSpectrumAntibiotics.isNotEmpty)
          'Broad-Spectrum Antibiotics': _assessment!.broadSpectrumAntibiotics.join('; '),
        if (_assessment!.invasiveDevices.isNotEmpty)
          'Invasive Devices': _assessment!.invasiveDevices.join('; '),
        if (_assessment!.immunosuppression.isNotEmpty)
          'Immunosuppression': _assessment!.immunosuppression.join('; '),
        if (_assessment!.chronicConditions.isNotEmpty)
          'Chronic Conditions': _assessment!.chronicConditions.join('; '),
        'Prior MDRO': _assessment!.priorMdro,
        if (_assessment!.mdroTypes.isNotEmpty)
          'MDRO Types': _assessment!.mdroTypes.join('; '),
        'International Travel': _assessment!.internationalTravel ? 'Yes' : 'No',
        'Known MDRO Contact': _assessment!.knownMdroContact ? 'Yes' : 'No',
      };

      final results = {
        'Risk Score': '${_assessment!.riskScore}/100',
        'Risk Category': _assessment!.riskCategory,
        'MDRO Probability': '${_assessment!.mdroProbability.toStringAsFixed(0)}%',
        'Risk Explanation': _assessment!.riskExplanation,
        'Organism Risks': _assessment!.organismRisks.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('; '),
        'Isolation Precautions': _assessment!.isolationPrecautions.join('; '),
        'Screening': _assessment!.screeningRecommendations.join('; '),
        'Empiric Therapy': _assessment!.empiricTherapy,
      };

      await UnifiedExportService.exportCalculatorAsCSV(
        context: context,
        toolName: 'MDRO Risk Calculator',
        formula: 'Evidence-based scoring system (0-100 points)',
        inputs: inputs,
        results: results,
        benchmark: {},
        recommendations: _assessment!.stewardshipRecommendations.join('; '),
        interpretation: _assessment!.riskExplanation,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Exported as CSV successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting CSV: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _exportAsText() async {
    if (_assessment == null) return;

    try {
      final inputs = {
        'Age': _assessment!.age,
        if (_assessment!.gender != null) 'Gender': _assessment!.gender!,
        'Hospital Admission (90d)': _assessment!.hospitalAdmission,
        'ICU Stay (90d)': _assessment!.icuStay,
        'Nursing Home (90d)': _assessment!.nursingHome,
        'Hemodialysis': _assessment!.hemodialysis ? 'Yes' : 'No',
        'Surgery (90d)': _assessment!.surgery ? 'Yes' : 'No',
        'Antibiotic Use (90d)': _assessment!.antibioticUse,
        if (_assessment!.broadSpectrumAntibiotics.isNotEmpty)
          'Broad-Spectrum Antibiotics': _assessment!.broadSpectrumAntibiotics.join(', '),
        if (_assessment!.invasiveDevices.isNotEmpty)
          'Invasive Devices': _assessment!.invasiveDevices.join(', '),
        if (_assessment!.immunosuppression.isNotEmpty)
          'Immunosuppression': _assessment!.immunosuppression.join(', '),
        if (_assessment!.chronicConditions.isNotEmpty)
          'Chronic Conditions': _assessment!.chronicConditions.join(', '),
        'Prior MDRO': _assessment!.priorMdro,
        if (_assessment!.mdroTypes.isNotEmpty)
          'MDRO Types': _assessment!.mdroTypes.join(', '),
        'International Travel': _assessment!.internationalTravel ? 'Yes' : 'No',
        'Known MDRO Contact': _assessment!.knownMdroContact ? 'Yes' : 'No',
      };

      final results = {
        'Risk Score': '${_assessment!.riskScore}/100',
        'Risk Category': _assessment!.riskCategory,
        'MDRO Probability': '${_assessment!.mdroProbability.toStringAsFixed(0)}%',
        'Risk Explanation': _assessment!.riskExplanation,
        'Organism Risks': _assessment!.organismRisks.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('\n'),
        'Isolation Precautions': _assessment!.isolationPrecautions.join('\n'),
        'Screening': _assessment!.screeningRecommendations.join('\n'),
        'Empiric Therapy': _assessment!.empiricTherapy,
      };

      await UnifiedExportService.exportCalculatorAsText(
        context: context,
        toolName: 'MDRO Risk Calculator',
        formula: 'Evidence-based scoring system (0-100 points)',
        inputs: inputs,
        results: results,
        benchmark: {},
        recommendations: _assessment!.stewardshipRecommendations.join('\n'),
        interpretation: _assessment!.riskExplanation,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Exported as Text successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting Text: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
