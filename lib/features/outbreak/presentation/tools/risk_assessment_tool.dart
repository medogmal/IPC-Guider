import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../../core/widgets/export_modal.dart';

class RiskAssessmentTool extends ConsumerStatefulWidget {
  const RiskAssessmentTool({super.key});

  @override
  ConsumerState<RiskAssessmentTool> createState() => _RiskAssessmentToolState();
}

class _RiskAssessmentToolState extends ConsumerState<RiskAssessmentTool> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Patient Factors
  String? _patientPopulation;
  String? _immunocompromisedStatus;
  String? _deviceUse;
  String? _antibioticExposure;

  // Step 2: Environmental Factors
  String? _ventilationStatus;
  String? _cleaningFrequency;
  String? _waterQuality;
  String? _crowdingLevel;

  // Step 3: Pathogen Factors
  String? _pathogenType;
  String? _transmissionMode;
  String? _resistancePattern;
  String? _virulenceLevel;

  // Results
  int? _totalScore;
  String? _riskLevel;
  Color? _riskColor;
  List<String>? _recommendations;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Risk Assessment Tool'),
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(),

              // Content
              Expanded(
                child: _totalScore == null
                    ? _buildStepContent(bottomPadding)
                    : _buildResultsScreen(bottomPadding),
              ),

              // Navigation Buttons
              if (_totalScore == null) _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
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
      child: Row(
        children: [
          _buildStepIndicator(0, 'Patient', Icons.person),
          _buildStepConnector(0),
          _buildStepIndicator(1, 'Environment', Icons.home),
          _buildStepConnector(1),
          _buildStepIndicator(2, 'Pathogen', Icons.biotech),
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
                      : AppColors.textSecondary.withValues(alpha: 0.2),
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
        margin: const EdgeInsets.only(bottom: 20),
        color: isCompleted
            ? AppColors.success
            : AppColors.textSecondary.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildStepContent(double bottomPadding) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
      children: [
        // Quick Guide and Load Example buttons
        if (_currentStep == 0) ...[
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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _loadExample,
              icon: Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
              label: Text(
                'Load Example',
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
        ],

        if (_currentStep == 0) _buildPatientFactorsStep(),
        if (_currentStep == 1) _buildEnvironmentalFactorsStep(),
        if (_currentStep == 2) _buildPathogenFactorsStep(),
      ],
    );
  }

  Widget _buildPatientFactorsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Patient Risk Factors',
          'Assess patient population and susceptibility',
          Icons.person,
          AppColors.primary,
        ),
        const SizedBox(height: 24),
        
        _buildDropdownField(
          label: 'Patient Population',
          value: _patientPopulation,
          items: const [
            {'value': 'general', 'label': 'General ward (1 point)', 'score': 1},
            {'value': 'icu', 'label': 'ICU/Critical care (3 points)', 'score': 3},
            {'value': 'immunocompromised', 'label': 'Immunocompromised unit (4 points)', 'score': 4},
            {'value': 'neonatal', 'label': 'Neonatal/Pediatric ICU (4 points)', 'score': 4},
          ],
          onChanged: (value) => setState(() => _patientPopulation = value),
        ),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: 'Immunocompromised Status',
          value: _immunocompromisedStatus,
          items: const [
            {'value': 'none', 'label': 'No immunocompromise (0 points)', 'score': 0},
            {'value': 'mild', 'label': 'Mild (diabetes, elderly) (1 point)', 'score': 1},
            {'value': 'moderate', 'label': 'Moderate (steroids, chemotherapy) (2 points)', 'score': 2},
            {'value': 'severe', 'label': 'Severe (transplant, HIV) (3 points)', 'score': 3},
          ],
          onChanged: (value) => setState(() => _immunocompromisedStatus = value),
        ),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: 'Invasive Device Use',
          value: _deviceUse,
          items: const [
            {'value': 'none', 'label': 'No devices (0 points)', 'score': 0},
            {'value': 'peripheral', 'label': 'Peripheral IV only (1 point)', 'score': 1},
            {'value': 'central', 'label': 'Central line or urinary catheter (2 points)', 'score': 2},
            {'value': 'ventilator', 'label': 'Mechanical ventilation (3 points)', 'score': 3},
          ],
          onChanged: (value) => setState(() => _deviceUse = value),
        ),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: 'Recent Antibiotic Exposure',
          value: _antibioticExposure,
          items: const [
            {'value': 'none', 'label': 'No recent antibiotics (0 points)', 'score': 0},
            {'value': 'single', 'label': 'Single agent <7 days (1 point)', 'score': 1},
            {'value': 'multiple', 'label': 'Multiple agents or >7 days (2 points)', 'score': 2},
            {'value': 'broad', 'label': 'Broad-spectrum >14 days (3 points)', 'score': 3},
          ],
          onChanged: (value) => setState(() => _antibioticExposure = value),
        ),
      ],
    );
  }

  Widget _buildEnvironmentalFactorsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Environmental Risk Factors',
          'Assess facility infrastructure and practices',
          Icons.home,
          AppColors.info,
        ),
        const SizedBox(height: 24),
        
        _buildDropdownField(
          label: 'Ventilation Status',
          value: _ventilationStatus,
          items: const [
            {'value': 'adequate', 'label': 'Adequate (≥6 ACH) (0 points)', 'score': 0},
            {'value': 'suboptimal', 'label': 'Suboptimal (4-6 ACH) (1 point)', 'score': 1},
            {'value': 'poor', 'label': 'Poor (<4 ACH) (2 points)', 'score': 2},
            {'value': 'none', 'label': 'No mechanical ventilation (3 points)', 'score': 3},
          ],
          onChanged: (value) => setState(() => _ventilationStatus = value),
        ),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: 'Cleaning Frequency',
          value: _cleaningFrequency,
          items: const [
            {'value': 'enhanced', 'label': 'Enhanced (≥3x daily) (0 points)', 'score': 0},
            {'value': 'standard', 'label': 'Standard (2x daily) (1 point)', 'score': 1},
            {'value': 'minimal', 'label': 'Minimal (1x daily) (2 points)', 'score': 2},
            {'value': 'inadequate', 'label': 'Inadequate (<1x daily) (3 points)', 'score': 3},
          ],
          onChanged: (value) => setState(() => _cleaningFrequency = value),
        ),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: 'Water Quality',
          value: _waterQuality,
          items: const [
            {'value': 'excellent', 'label': 'Excellent (tested, filtered) (0 points)', 'score': 0},
            {'value': 'good', 'label': 'Good (tested, no issues) (1 point)', 'score': 1},
            {'value': 'fair', 'label': 'Fair (not regularly tested) (2 points)', 'score': 2},
            {'value': 'poor', 'label': 'Poor (known issues) (3 points)', 'score': 3},
          ],
          onChanged: (value) => setState(() => _waterQuality = value),
        ),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: 'Crowding Level',
          value: _crowdingLevel,
          items: const [
            {'value': 'low', 'label': 'Low (<80% occupancy) (0 points)', 'score': 0},
            {'value': 'moderate', 'label': 'Moderate (80-100% occupancy) (1 point)', 'score': 1},
            {'value': 'high', 'label': 'High (>100% occupancy) (2 points)', 'score': 2},
            {'value': 'severe', 'label': 'Severe (hallway beds) (3 points)', 'score': 3},
          ],
          onChanged: (value) => setState(() => _crowdingLevel = value),
        ),
      ],
    );
  }

  Widget _buildPathogenFactorsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Pathogen Risk Factors',
          'Assess pathogen characteristics',
          Icons.biotech,
          AppColors.warning,
        ),
        const SizedBox(height: 24),

        _buildDropdownField(
          label: 'Pathogen Type',
          value: _pathogenType,
          items: const [
            {'value': 'bacteria_sensitive', 'label': 'Bacteria (antibiotic-sensitive) (1 point)', 'score': 1},
            {'value': 'bacteria_resistant', 'label': 'Bacteria (MDR/XDR) (3 points)', 'score': 3},
            {'value': 'virus', 'label': 'Virus (respiratory/enteric) (2 points)', 'score': 2},
            {'value': 'fungus', 'label': 'Fungus (Candida auris, Aspergillus) (3 points)', 'score': 3},
            {'value': 'spore', 'label': 'Spore-forming (C. diff) (3 points)', 'score': 3},
          ],
          onChanged: (value) => setState(() => _pathogenType = value),
        ),
        const SizedBox(height: 16),

        _buildDropdownField(
          label: 'Transmission Mode',
          value: _transmissionMode,
          items: const [
            {'value': 'contact', 'label': 'Contact transmission (2 points)', 'score': 2},
            {'value': 'droplet', 'label': 'Droplet transmission (2 points)', 'score': 2},
            {'value': 'airborne', 'label': 'Airborne transmission (4 points)', 'score': 4},
            {'value': 'multiple', 'label': 'Multiple routes (4 points)', 'score': 4},
          ],
          onChanged: (value) => setState(() => _transmissionMode = value),
        ),
        const SizedBox(height: 16),

        _buildDropdownField(
          label: 'Resistance Pattern',
          value: _resistancePattern,
          items: const [
            {'value': 'none', 'label': 'No resistance (0 points)', 'score': 0},
            {'value': 'single', 'label': 'Single drug resistance (1 point)', 'score': 1},
            {'value': 'mdr', 'label': 'MDR (≥3 classes) (2 points)', 'score': 2},
            {'value': 'xdr', 'label': 'XDR/PDR (3 points)', 'score': 3},
          ],
          onChanged: (value) => setState(() => _resistancePattern = value),
        ),
        const SizedBox(height: 16),

        _buildDropdownField(
          label: 'Virulence Level',
          value: _virulenceLevel,
          items: const [
            {'value': 'low', 'label': 'Low virulence (1 point)', 'score': 1},
            {'value': 'moderate', 'label': 'Moderate virulence (2 points)', 'score': 2},
            {'value': 'high', 'label': 'High virulence (3 points)', 'score': 3},
            {'value': 'extreme', 'label': 'Extreme (VHF, novel pathogen) (4 points)', 'score': 4},
          ],
          onChanged: (value) => setState(() => _virulenceLevel = value),
        ),
      ],
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon, Color color) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            hint: const Text('Select an option'),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'] as String,
                child: Text(
                  item['label'] as String,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an option';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
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
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleNext,
              icon: Icon(_currentStep == 2 ? Icons.check : Icons.arrow_forward),
              label: Text(_currentStep == 2 ? 'Calculate Risk' : 'Next'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _calculateRisk();
    }
  }

  void _calculateRisk() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      // Calculate total score
      int score = 0;

      // Patient factors (max 13 points)
      score += _getScore(_patientPopulation, [
        {'value': 'general', 'score': 1},
        {'value': 'icu', 'score': 3},
        {'value': 'immunocompromised', 'score': 4},
        {'value': 'neonatal', 'score': 4},
      ]);
      score += _getScore(_immunocompromisedStatus, [
        {'value': 'none', 'score': 0},
        {'value': 'mild', 'score': 1},
        {'value': 'moderate', 'score': 2},
        {'value': 'severe', 'score': 3},
      ]);
      score += _getScore(_deviceUse, [
        {'value': 'none', 'score': 0},
        {'value': 'peripheral', 'score': 1},
        {'value': 'central', 'score': 2},
        {'value': 'ventilator', 'score': 3},
      ]);
      score += _getScore(_antibioticExposure, [
        {'value': 'none', 'score': 0},
        {'value': 'single', 'score': 1},
        {'value': 'multiple', 'score': 2},
        {'value': 'broad', 'score': 3},
      ]);

      // Environmental factors (max 12 points)
      score += _getScore(_ventilationStatus, [
        {'value': 'adequate', 'score': 0},
        {'value': 'suboptimal', 'score': 1},
        {'value': 'poor', 'score': 2},
        {'value': 'none', 'score': 3},
      ]);
      score += _getScore(_cleaningFrequency, [
        {'value': 'enhanced', 'score': 0},
        {'value': 'standard', 'score': 1},
        {'value': 'minimal', 'score': 2},
        {'value': 'inadequate', 'score': 3},
      ]);
      score += _getScore(_waterQuality, [
        {'value': 'excellent', 'score': 0},
        {'value': 'good', 'score': 1},
        {'value': 'fair', 'score': 2},
        {'value': 'poor', 'score': 3},
      ]);
      score += _getScore(_crowdingLevel, [
        {'value': 'low', 'score': 0},
        {'value': 'moderate', 'score': 1},
        {'value': 'high', 'score': 2},
        {'value': 'severe', 'score': 3},
      ]);

      // Pathogen factors (max 13 points)
      score += _getScore(_pathogenType, [
        {'value': 'bacteria_sensitive', 'score': 1},
        {'value': 'bacteria_resistant', 'score': 3},
        {'value': 'virus', 'score': 2},
        {'value': 'fungus', 'score': 3},
        {'value': 'spore', 'score': 3},
      ]);
      score += _getScore(_transmissionMode, [
        {'value': 'contact', 'score': 2},
        {'value': 'droplet', 'score': 2},
        {'value': 'airborne', 'score': 4},
        {'value': 'multiple', 'score': 4},
      ]);
      score += _getScore(_resistancePattern, [
        {'value': 'none', 'score': 0},
        {'value': 'single', 'score': 1},
        {'value': 'mdr', 'score': 2},
        {'value': 'xdr', 'score': 3},
      ]);
      score += _getScore(_virulenceLevel, [
        {'value': 'low', 'score': 1},
        {'value': 'moderate', 'score': 2},
        {'value': 'high', 'score': 3},
        {'value': 'extreme', 'score': 4},
      ]);

      // Determine risk level (max possible score: 38)
      String riskLevel;
      Color riskColor;
      List<String> recommendations;

      if (score <= 10) {
        riskLevel = 'LOW RISK';
        riskColor = AppColors.success;
        recommendations = [
          'Maintain standard precautions',
          'Continue routine surveillance',
          'Ensure hand hygiene compliance',
          'Monitor for any changes in risk factors',
          'Document baseline assessment',
        ];
      } else if (score <= 20) {
        riskLevel = 'MODERATE RISK';
        riskColor = AppColors.warning;
        recommendations = [
          'Implement enhanced surveillance',
          'Increase environmental cleaning frequency',
          'Audit hand hygiene and PPE compliance',
          'Consider cohorting if multiple cases',
          'Review and optimize antibiotic use',
          'Educate staff on transmission precautions',
          'Monitor daily for new cases',
        ];
      } else {
        riskLevel = 'HIGH RISK';
        riskColor = AppColors.error;
        recommendations = [
          'Activate outbreak response team immediately',
          'Implement strict isolation precautions',
          'Cohort patients and dedicate staff',
          'Enhanced environmental cleaning (≥3x daily)',
          'Daily audits of IPC compliance',
          'Restrict admissions if possible',
          'Screen contacts and exposed patients',
          'Consider unit closure if transmission continues',
          'Notify infection control and administration',
          'Implement antimicrobial stewardship interventions',
        ];
      }

      setState(() {
        _totalScore = score;
        _riskLevel = riskLevel;
        _riskColor = riskColor;
        _recommendations = recommendations;
        _isLoading = false;
      });
    });
  }

  int _getScore(String? value, List<Map<String, dynamic>> items) {
    if (value == null) return 0;
    final item = items.firstWhere(
      (item) => item['value'] == value,
      orElse: () => {'score': 0},
    );
    return item['score'] as int;
  }

  Widget _buildResultsScreen(double bottomPadding) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
      children: [
        // Risk Score Card
        _buildRiskScoreCard(),
        const SizedBox(height: 24),

        // Risk Breakdown
        _buildRiskBreakdown(),
        const SizedBox(height: 24),

        // Recommendations
        _buildRecommendationsCard(),
        const SizedBox(height: 24),

        // Action Buttons
        _buildResultActions(),
        const SizedBox(height: 24),

        // References
        _buildReferencesCard(),
      ],
    );
  }

  Widget _buildRiskScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _riskColor!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _riskColor!,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getRiskIcon(),
            color: _riskColor,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _riskLevel!,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _riskColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total Risk Score: $_totalScore / 38',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _totalScore! / 38,
            backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(_riskColor!),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBreakdown() {
    // Calculate category scores
    int patientScore = 0;
    patientScore += _getScore(_patientPopulation, [
      {'value': 'general', 'score': 1},
      {'value': 'icu', 'score': 3},
      {'value': 'immunocompromised', 'score': 4},
      {'value': 'neonatal', 'score': 4},
    ]);
    patientScore += _getScore(_immunocompromisedStatus, [
      {'value': 'none', 'score': 0},
      {'value': 'mild', 'score': 1},
      {'value': 'moderate', 'score': 2},
      {'value': 'severe', 'score': 3},
    ]);
    patientScore += _getScore(_deviceUse, [
      {'value': 'none', 'score': 0},
      {'value': 'peripheral', 'score': 1},
      {'value': 'central', 'score': 2},
      {'value': 'ventilator', 'score': 3},
    ]);
    patientScore += _getScore(_antibioticExposure, [
      {'value': 'none', 'score': 0},
      {'value': 'single', 'score': 1},
      {'value': 'multiple', 'score': 2},
      {'value': 'broad', 'score': 3},
    ]);

    int environmentScore = 0;
    environmentScore += _getScore(_ventilationStatus, [
      {'value': 'adequate', 'score': 0},
      {'value': 'suboptimal', 'score': 1},
      {'value': 'poor', 'score': 2},
      {'value': 'none', 'score': 3},
    ]);
    environmentScore += _getScore(_cleaningFrequency, [
      {'value': 'enhanced', 'score': 0},
      {'value': 'standard', 'score': 1},
      {'value': 'minimal', 'score': 2},
      {'value': 'inadequate', 'score': 3},
    ]);
    environmentScore += _getScore(_waterQuality, [
      {'value': 'excellent', 'score': 0},
      {'value': 'good', 'score': 1},
      {'value': 'fair', 'score': 2},
      {'value': 'poor', 'score': 3},
    ]);
    environmentScore += _getScore(_crowdingLevel, [
      {'value': 'low', 'score': 0},
      {'value': 'moderate', 'score': 1},
      {'value': 'high', 'score': 2},
      {'value': 'severe', 'score': 3},
    ]);

    int pathogenScore = 0;
    pathogenScore += _getScore(_pathogenType, [
      {'value': 'bacteria_sensitive', 'score': 1},
      {'value': 'bacteria_resistant', 'score': 3},
      {'value': 'virus', 'score': 2},
      {'value': 'fungus', 'score': 3},
      {'value': 'spore', 'score': 3},
    ]);
    pathogenScore += _getScore(_transmissionMode, [
      {'value': 'contact', 'score': 2},
      {'value': 'droplet', 'score': 2},
      {'value': 'airborne', 'score': 4},
      {'value': 'multiple', 'score': 4},
    ]);
    pathogenScore += _getScore(_resistancePattern, [
      {'value': 'none', 'score': 0},
      {'value': 'single', 'score': 1},
      {'value': 'mdr', 'score': 2},
      {'value': 'xdr', 'score': 3},
    ]);
    pathogenScore += _getScore(_virulenceLevel, [
      {'value': 'low', 'score': 1},
      {'value': 'moderate', 'score': 2},
      {'value': 'high', 'score': 3},
      {'value': 'extreme', 'score': 4},
    ]);

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
          Text(
            'Risk Score Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildBreakdownItem('Patient Factors', patientScore, 13, AppColors.primary),
          const SizedBox(height: 12),
          _buildBreakdownItem('Environmental Factors', environmentScore, 12, AppColors.info),
          const SizedBox(height: 12),
          _buildBreakdownItem('Pathogen Factors', pathogenScore, 13, AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, int score, int maxScore, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$score / $maxScore',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: score / maxScore,
          backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
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
              Icon(Icons.recommend, color: _riskColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Recommended Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._recommendations!.map((recommendation) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle, color: _riskColor, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildResultActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('New Assessment'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveResult,
            icon: const Icon(Icons.save),
            label: const Text('Save Result'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showExportModal,
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Export Report'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferencesCard() {
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
              Icon(Icons.library_books, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'References',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _launchURL('https://www.cdc.gov/infectioncontrol/guidelines/environmental/appendix/air.html'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(Icons.open_in_new, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'CDC – Risk Assessment Tools for Healthcare Settings',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _launchURL('https://www.who.int/publications/i/item/9789241511827'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(Icons.open_in_new, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'WHO – IPC Risk Assessment Framework',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _launchURL('https://apic.org/resources/'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(Icons.open_in_new, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'APIC – Outbreak Investigation and Control',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _launchURL('https://www.moh.gov.sa/en/Ministry/MediaCenter/Publications/Pages/Publications-2023-10-17-001.aspx'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(Icons.open_in_new, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'GDIPC/Weqaya – Risk Stratification Guidelines (Saudi Arabia)',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRiskIcon() {
    if (_riskLevel == 'LOW RISK') return Icons.check_circle;
    if (_riskLevel == 'MODERATE RISK') return Icons.warning;
    return Icons.error;
  }

  // Show Quick Guide modal
  void _showQuickGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.info),
            const SizedBox(width: 12),
            const Text('Quick Guide'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Indications/Use',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This tool helps assess infection risk in healthcare settings by evaluating patient, environmental, and pathogen factors.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text(
                'Scoring System',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• LOW RISK: 0-15 points\n• MODERATE RISK: 16-30 points\n• HIGH RISK: 31+ points',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text(
                'Interpretation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Higher scores indicate greater infection risk and require more intensive control measures.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Load example data
  void _loadExample() {
    setState(() {
      // Patient Risk Factors
      _patientPopulation = 'icu'; // ✅ Valid
      _immunocompromisedStatus = 'moderate'; // ✅ Valid
      _deviceUse = 'ventilator'; // Fixed: was 'multiple', should be 'ventilator'
      _antibioticExposure = 'broad'; // Fixed: was 'broadSpectrum', should be 'broad'

      // Environmental Risk Factors
      _ventilationStatus = 'poor'; // Fixed: was 'mechanical', should be 'poor'
      _cleaningFrequency = 'minimal'; // Fixed: was 'daily', should be 'minimal'
      _waterQuality = 'fair'; // Fixed: was 'treated', should be 'fair'
      _crowdingLevel = 'high'; // Fixed: was 'overcrowded', should be 'high'

      // Pathogen Risk Factors
      _pathogenType = 'bacteria_resistant'; // Fixed: was 'mdr', should be 'bacteria_resistant'
      _transmissionMode = 'airborne'; // ✅ Valid
      _resistancePattern = 'mdr'; // Fixed: was 'multiDrug', should be 'mdr'
      _virulenceLevel = 'high'; // ✅ Valid
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example loaded: ICU patient with MDR pathogen and high-risk environment'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // Launch URL
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Show export modal
  void _showExportModal() {
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
      'Patient Population': _patientPopulation ?? 'N/A',
      'Immunocompromised Status': _immunocompromisedStatus ?? 'N/A',
      'Device Use': _deviceUse ?? 'N/A',
      'Antibiotic Exposure': _antibioticExposure ?? 'N/A',
      'Ventilation Status': _ventilationStatus ?? 'N/A',
      'Cleaning Frequency': _cleaningFrequency ?? 'N/A',
      'Water Quality': _waterQuality ?? 'N/A',
      'Crowding Level': _crowdingLevel ?? 'N/A',
      'Pathogen Type': _pathogenType ?? 'N/A',
      'Transmission Mode': _transmissionMode ?? 'N/A',
      'Resistance Pattern': _resistancePattern ?? 'N/A',
      'Virulence Level': _virulenceLevel ?? 'N/A',
    };

    final results = {
      'Total Score': _totalScore?.toString() ?? 'N/A',
      'Risk Level': _riskLevel ?? 'N/A',
      'Recommendations': _recommendations?.join('\n') ?? 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Risk Assessment Tool',
      inputs: inputs,
      results: results,
    );
  }

  // Export as Excel
  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Patient Population': _patientPopulation ?? 'N/A',
      'Immunocompromised Status': _immunocompromisedStatus ?? 'N/A',
      'Device Use': _deviceUse ?? 'N/A',
      'Antibiotic Exposure': _antibioticExposure ?? 'N/A',
      'Ventilation Status': _ventilationStatus ?? 'N/A',
      'Cleaning Frequency': _cleaningFrequency ?? 'N/A',
      'Water Quality': _waterQuality ?? 'N/A',
      'Crowding Level': _crowdingLevel ?? 'N/A',
      'Pathogen Type': _pathogenType ?? 'N/A',
      'Transmission Mode': _transmissionMode ?? 'N/A',
      'Resistance Pattern': _resistancePattern ?? 'N/A',
      'Virulence Level': _virulenceLevel ?? 'N/A',
    };

    final results = {
      'Total Score': _totalScore?.toString() ?? 'N/A',
      'Risk Level': _riskLevel ?? 'N/A',
      'Recommendations': _recommendations?.join('\n') ?? 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Risk Assessment Tool',
      inputs: inputs,
      results: results,
    );
  }

  // Export as CSV
  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final inputs = {
      'Patient Population': _patientPopulation ?? 'N/A',
      'Immunocompromised Status': _immunocompromisedStatus ?? 'N/A',
      'Device Use': _deviceUse ?? 'N/A',
      'Antibiotic Exposure': _antibioticExposure ?? 'N/A',
      'Ventilation Status': _ventilationStatus ?? 'N/A',
      'Cleaning Frequency': _cleaningFrequency ?? 'N/A',
      'Water Quality': _waterQuality ?? 'N/A',
      'Crowding Level': _crowdingLevel ?? 'N/A',
      'Pathogen Type': _pathogenType ?? 'N/A',
      'Transmission Mode': _transmissionMode ?? 'N/A',
      'Resistance Pattern': _resistancePattern ?? 'N/A',
      'Virulence Level': _virulenceLevel ?? 'N/A',
    };

    final results = {
      'Total Score': _totalScore?.toString() ?? 'N/A',
      'Risk Level': _riskLevel ?? 'N/A',
      'Recommendations': _recommendations?.join('\n') ?? 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Risk Assessment Tool',
      inputs: inputs,
      results: results,
    );
  }

  // Export as Text
  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Patient Population': _patientPopulation ?? 'N/A',
      'Immunocompromised Status': _immunocompromisedStatus ?? 'N/A',
      'Device Use': _deviceUse ?? 'N/A',
      'Antibiotic Exposure': _antibioticExposure ?? 'N/A',
      'Ventilation Status': _ventilationStatus ?? 'N/A',
      'Cleaning Frequency': _cleaningFrequency ?? 'N/A',
      'Water Quality': _waterQuality ?? 'N/A',
      'Crowding Level': _crowdingLevel ?? 'N/A',
      'Pathogen Type': _pathogenType ?? 'N/A',
      'Transmission Mode': _transmissionMode ?? 'N/A',
      'Resistance Pattern': _resistancePattern ?? 'N/A',
      'Virulence Level': _virulenceLevel ?? 'N/A',
    };

    final results = {
      'Total Score': _totalScore?.toString() ?? 'N/A',
      'Risk Level': _riskLevel ?? 'N/A',
      'Recommendations': _recommendations?.join('\n') ?? 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Risk Assessment Tool',
      inputs: inputs,
      results: results,
    );
  }

  // Save result to history
  Future<void> _saveResult() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('risk_assessment_history') ?? [];

    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'patientPopulation': _patientPopulation ?? 'N/A',
      'immunocompromisedStatus': _immunocompromisedStatus ?? 'N/A',
      'deviceUse': _deviceUse ?? 'N/A',
      'antibioticExposure': _antibioticExposure ?? 'N/A',
      'ventilationStatus': _ventilationStatus ?? 'N/A',
      'cleaningFrequency': _cleaningFrequency ?? 'N/A',
      'waterQuality': _waterQuality ?? 'N/A',
      'crowdingLevel': _crowdingLevel ?? 'N/A',
      'pathogenType': _pathogenType ?? 'N/A',
      'transmissionMode': _transmissionMode ?? 'N/A',
      'resistancePattern': _resistancePattern ?? 'N/A',
      'virulenceLevel': _virulenceLevel ?? 'N/A',
      'totalScore': _totalScore?.toString() ?? 'N/A',
      'riskLevel': _riskLevel ?? 'N/A',
      'recommendations': _recommendations?.join(', ') ?? 'N/A',
    };

    history.insert(0, jsonEncode(entry));

    // Keep only last 50 entries
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    await prefs.setStringList('risk_assessment_history', history);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Assessment saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _patientPopulation = null;
      _immunocompromisedStatus = null;
      _deviceUse = null;
      _antibioticExposure = null;
      _ventilationStatus = null;
      _cleaningFrequency = null;
      _waterQuality = null;
      _crowdingLevel = null;
      _pathogenType = null;
      _transmissionMode = null;
      _resistancePattern = null;
      _virulenceLevel = null;
      _totalScore = null;
      _riskLevel = null;
      _riskColor = null;
      _recommendations = null;
    });
  }
}

