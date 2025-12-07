import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/back_button.dart';
import '../../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../data/models/allergy_assessment.dart';
import '../../../data/repositories/allergy_cross_reactivity_repository.dart';
import '../../../data/services/allergy_checker_storage_service.dart';

class AllergyCheckerScreen extends ConsumerStatefulWidget {
  const AllergyCheckerScreen({super.key});

  @override
  ConsumerState<AllergyCheckerScreen> createState() => _AllergyCheckerScreenState();
}

class _AllergyCheckerScreenState extends ConsumerState<AllergyCheckerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AllergyCrossReactivityRepository();
  final _storageService = AllergyCheckerStorageService();

  // Input state
  String? _selectedDrug;
  String? _selectedDrugClass;
  String _selectedReactionType = 'Type I (IgE-mediated)';
  String _selectedReactionSeverity = 'Moderate';
  String? _selectedTimeSinceReaction;
  final List<String> _selectedClinicalContext = [];

  // Results state
  AllergyAssessment? _assessment;
  bool _isLoading = false;
  bool _showResults = false;

  // Data
  List<String> _allDrugs = [];
  List<Map<String, dynamic>> _references = [];

  final List<String> _reactionTypes = [
    'Type I (IgE-mediated)',
    'Type II (Cytotoxic)',
    'Type III (Immune Complex)',
    'Type IV (Delayed)',
    'Unknown/Not Documented',
  ];

  final List<String> _reactionSeverities = [
    'Severe',
    'Moderate',
    'Mild',
    'Unknown',
  ];

  final List<String> _timeSinceReactionOptions = [
    '<1 month',
    '1-6 months',
    '6-12 months',
    '1-5 years',
    '>5 years',
    'Unknown',
  ];

  final List<String> _clinicalContextOptions = [
    'Life-threatening infection',
    'Immunocompromised patient',
    'Limited alternative options',
    'Previous allergy testing performed',
  ];

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'The Allergy Cross-Reactivity Checker is an educational tool that assesses the risk of cross-reactivity between antibiotics when a patient has a documented drug allergy. It provides evidence-based guidance on safe alternatives and helps address antibiotic allergy over-reporting (10% report allergies, but <1% have true IgE-mediated allergies).',
    example: 'Patient with documented penicillin allergy (mild rash 5 years ago) needs antibiotic for pneumonia. Tool assesses cross-reactivity risk with cephalosporins: 3rd/4th generation cephalosporins have <1% cross-reactivity and are safe to use. Avoid 1st generation cephalosporins if concerned.',
    interpretation: 'Risk levels guide antibiotic selection: High risk (>10%) = avoid entire class; Moderate risk (1-10%) = use with caution or alternatives; Low risk (<1%) = generally safe; Negligible (<0.1%) = safe to use. Severity of original reaction is critical: anaphylaxis requires absolute avoidance, mild rash may allow cautious use or delabeling.',
    whenUsed: 'Use when prescribing antibiotics for patients with documented drug allergies, during antimicrobial stewardship rounds, when considering allergy delabeling programs, or when evaluating cross-reactivity risk for alternative antibiotics. Essential for safe prescribing and reducing unnecessary broad-spectrum antibiotic use.',
    inputDataType: 'Allergic drug name, reaction type (IgE-mediated, cytotoxic, immune complex, delayed), reaction severity (severe, moderate, mild), time since reaction, and clinical context (life-threatening infection, immunocompromised, limited alternatives).',
    references: [
      Reference(
        title: 'IDSA Penicillin Allergy Guidelines',
        url: 'https://www.idsociety.org/practice-guideline/',
      ),
      Reference(
        title: 'CDC Antibiotic Allergy Assessment',
        url: 'https://www.cdc.gov/antibiotic-use/',
      ),
      Reference(
        title: 'WHO Essential Medicines List',
        url: 'https://www.who.int/publications/i/item/WHO-MHP-HPS-EML-2023.02',
      ),
      Reference(
        title: 'AAAAI Drug Allergy Practice Parameters',
        url: 'https://www.aaaai.org/',
      ),
      Reference(
        title: 'BSACI Beta-Lactam Allergy Guidelines',
        url: 'https://www.bsaci.org/',
      ),
      Reference(
        title: 'APIC Antimicrobial Stewardship Guide',
        url: 'https://apic.org/',
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final drugs = await _repository.getAllDrugs();
      final refs = await _repository.getReferences();
      setState(() {
        _allDrugs = drugs;
        _references = refs;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Allergy Cross-Reactivity Checker',
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 24),
                _buildResultsSection(),
              ],
              const SizedBox(height: 24),
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
                  Icons.warning_amber_outlined,
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
                      'Antibiotic Allergy Cross-Reactivity Checker',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assess cross-reactivity risk and identify safe alternatives',
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
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.large),
            child: KnowledgePanelWidget(
              data: _knowledgePanelData,
            ),
          ),
        ),
      ),
    );
  }

  void _loadExample() {
    setState(() {
      _selectedDrug = 'Amoxicillin';
      _selectedDrugClass = 'penicillins';
      _selectedReactionType = 'Type IV (Delayed)';
      _selectedReactionSeverity = 'Mild';
      _selectedTimeSinceReaction = '>5 years';
      _selectedClinicalContext.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example loaded: Amoxicillin allergy (mild rash, >5 years ago)'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildInputSection() {
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
              Icon(Icons.input_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Allergy Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Allergic Drug Dropdown
          Text(
            'Allergic Drug *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedDrug,
            decoration: InputDecoration(
              hintText: 'Select allergic drug',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _allDrugs.map((drug) {
              return DropdownMenuItem(
                value: drug,
                child: Text(drug),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                final drugClass = await _repository.findDrugClass(value);
                setState(() {
                  _selectedDrug = value;
                  _selectedDrugClass = drugClass?['id'] as String?;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an allergic drug';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Reaction Type
          Text(
            'Reaction Type *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ..._reactionTypes.map((type) {
            return RadioListTile<String>(
              title: Text(type, style: const TextStyle(fontSize: 14)),
              value: type,
              groupValue: _selectedReactionType,
              onChanged: (value) {
                setState(() {
                  _selectedReactionType = value!;
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }),
          const SizedBox(height: 20),

          // Reaction Severity
          Text(
            'Reaction Severity *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ..._reactionSeverities.map((severity) {
            Color severityColor = AppColors.textPrimary;
            if (severity == 'Severe') severityColor = AppColors.error;
            if (severity == 'Moderate') severityColor = AppColors.warning;
            if (severity == 'Mild') severityColor = AppColors.success;

            return RadioListTile<String>(
              title: Text(
                severity,
                style: TextStyle(fontSize: 14, color: severityColor, fontWeight: FontWeight.w600),
              ),
              value: severity,
              groupValue: _selectedReactionSeverity,
              onChanged: (value) {
                setState(() {
                  _selectedReactionSeverity = value!;
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }),
          const SizedBox(height: 20),

          // Time Since Reaction (Optional)
          Text(
            'Time Since Reaction (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedTimeSinceReaction,
            decoration: InputDecoration(
              hintText: 'Select time since reaction',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _timeSinceReactionOptions.map((time) {
              return DropdownMenuItem(
                value: time,
                child: Text(time),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTimeSinceReaction = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // Clinical Context (Optional)
          Text(
            'Clinical Context (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ..._clinicalContextOptions.map((context) {
            return CheckboxListTile(
              title: Text(context, style: const TextStyle(fontSize: 14)),
              value: _selectedClinicalContext.contains(context),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedClinicalContext.add(context);
                  } else {
                    _selectedClinicalContext.remove(context);
                  }
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
          const SizedBox(height: 24),

          // Assess Risk Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _assessRisk,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Assess Cross-Reactivity Risk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _assessRisk() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDrug == null || _selectedDrugClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an allergic drug'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get cross-reactivity data
      final crossReactivity = await _repository.getCrossReactivity(_selectedDrugClass!);
      final safeAlternativesData = await _repository.getSafeAlternatives(_selectedDrugClass!);

      // Calculate risk and generate recommendations
      final riskData = _calculateRisk(crossReactivity);
      final safeAlternatives = _generateSafeAlternatives(safeAlternativesData, riskData);
      final avoidList = _generateAvoidList(crossReactivity);
      final clinicalGuidance = _generateClinicalGuidance(riskData);
      final recommendations = _generateRecommendations(riskData);

      // Create assessment
      final assessment = AllergyAssessment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        allergicDrug: _selectedDrug!,
        drugClass: _selectedDrugClass!,
        reactionType: _selectedReactionType,
        reactionSeverity: _selectedReactionSeverity,
        timeSinceReaction: _selectedTimeSinceReaction,
        clinicalContext: List.from(_selectedClinicalContext),
        timestamp: DateTime.now(),
        riskLevel: riskData['level'] as String,
        riskPercentage: riskData['percentage'] as double,
        riskExplanation: riskData['explanation'] as String,
        safeAlternatives: safeAlternatives,
        avoidList: avoidList,
        clinicalGuidance: clinicalGuidance,
        recommendations: recommendations,
      );

      setState(() {
        _assessment = assessment;
        _showResults = true;
        _isLoading = false;
      });

      // Scroll to results
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assessing risk: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _calculateRisk(Map<String, dynamic>? crossReactivity) {
    if (crossReactivity == null || crossReactivity.isEmpty) {
      return {
        'level': 'Negligible',
        'percentage': 0.1,
        'explanation': 'No significant cross-reactivity data available for this drug class.',
      };
    }

    // Determine highest risk based on severity and reaction type
    double maxRisk = 0.0;
    String riskLevel = 'Negligible';
    String explanation = '';

    crossReactivity.forEach((key, value) {
      final data = value as Map<String, dynamic>;
      final riskPercentage = (data['riskPercentage'] as num).toDouble();
      final condition = data['condition'] as String;

      // Check if condition matches current severity
      bool conditionMatches = false;
      if (condition == 'any_reaction') {
        conditionMatches = true;
      } else if (condition == 'severe_reaction' && _selectedReactionSeverity == 'Severe') {
        conditionMatches = true;
      } else if (condition == 'anaphylaxis' && _selectedReactionType.contains('IgE-mediated') && _selectedReactionSeverity == 'Severe') {
        conditionMatches = true;
      }

      if (conditionMatches && riskPercentage > maxRisk) {
        maxRisk = riskPercentage;
        riskLevel = data['riskLevel'] as String;
        explanation = data['explanation'] as String;
      }
    });

    // Adjust risk based on severity
    if (_selectedReactionSeverity == 'Severe' && maxRisk < 5.0) {
      maxRisk = maxRisk * 1.5; // Increase risk for severe reactions
      riskLevel = maxRisk > 10 ? 'High' : maxRisk > 1 ? 'Moderate' : 'Low';
    }

    // Capitalize risk level
    riskLevel = riskLevel[0].toUpperCase() + riskLevel.substring(1);

    return {
      'level': riskLevel,
      'percentage': maxRisk,
      'explanation': explanation,
    };
  }

  List<SafeAlternative> _generateSafeAlternatives(
    List<Map<String, dynamic>> alternativesData,
    Map<String, dynamic> riskData,
  ) {
    return alternativesData.map((data) {
      return SafeAlternative(
        drugName: data['drugName'] as String,
        drugClass: data['drugClass'] as String,
        crossReactivityRisk: (data['crossReactivityRisk'] as num).toDouble(),
        clinicalUse: data['clinicalUse'] as String,
        dosingConsiderations: data['dosingConsiderations'] as String,
      );
    }).toList();
  }

  List<AvoidDrug> _generateAvoidList(Map<String, dynamic>? crossReactivity) {
    if (crossReactivity == null) return [];

    final List<AvoidDrug> avoidList = [];

    crossReactivity.forEach((key, value) {
      final data = value as Map<String, dynamic>;
      final riskPercentage = (data['riskPercentage'] as num).toDouble();
      final riskLevel = data['riskLevel'] as String;

      // Add to avoid list if high or moderate risk
      if (riskLevel == 'high' || riskLevel == 'moderate') {
        avoidList.add(AvoidDrug(
          drugName: key.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
          drugClass: key,
          reason: data['explanation'] as String,
          crossReactivityRisk: riskPercentage,
        ));
      }
    });

    return avoidList;
  }

  String _generateClinicalGuidance(Map<String, dynamic> riskData) {
    final riskLevel = riskData['level'] as String;

    String guidance = '';

    if (riskLevel == 'High') {
      guidance = 'HIGH RISK: Avoid all cross-reactive antibiotics. Consider alternative classes with no structural similarity. ';
    } else if (riskLevel == 'Moderate') {
      guidance = 'MODERATE RISK: Use cross-reactive antibiotics with caution. Consider allergy testing or graded challenge if clinically necessary. ';
    } else if (riskLevel == 'Low') {
      guidance = 'LOW RISK: Cross-reactive antibiotics can generally be used safely, especially if original reaction was mild and non-IgE-mediated. ';
    } else {
      guidance = 'NEGLIGIBLE RISK: No significant cross-reactivity expected. Safe to use alternative antibiotics. ';
    }

    // Add severity-specific guidance
    if (_selectedReactionSeverity == 'Severe') {
      guidance += 'Given the severe nature of the original reaction, exercise extreme caution and consider allergy consultation. ';
    }

    // Add clinical context guidance
    if (_selectedClinicalContext.contains('Life-threatening infection')) {
      guidance += 'In life-threatening infections, risk-benefit analysis may favor using cross-reactive antibiotics under close monitoring. ';
    }

    if (_selectedClinicalContext.contains('Previous allergy testing performed')) {
      guidance += 'Previous allergy testing results should guide antibiotic selection. ';
    }

    return guidance;
  }

  List<String> _generateRecommendations(Map<String, dynamic> riskData) {
    final List<String> recommendations = [];
    final riskLevel = riskData['level'] as String;

    if (riskLevel == 'High' || riskLevel == 'Moderate') {
      recommendations.add('Consider allergy consultation for risk stratification');
      recommendations.add('Document allergy details in medical record');
      recommendations.add('Consider penicillin skin testing if beta-lactam allergy');
    }

    if (_selectedReactionSeverity == 'Severe') {
      recommendations.add('Avoid all cross-reactive antibiotics');
      recommendations.add('Consider desensitization protocol if no alternatives');
    }

    if (_selectedTimeSinceReaction != null && (_selectedTimeSinceReaction!.contains('>5 years') || _selectedTimeSinceReaction!.contains('1-5 years'))) {
      recommendations.add('Consider allergy delabeling program - many childhood allergies resolve');
    }

    if (_selectedClinicalContext.contains('Limited alternative options')) {
      recommendations.add('Consult infectious disease specialist for alternative regimens');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Use safe alternatives listed above');
      recommendations.add('Monitor for any allergic reactions');
    }

    return recommendations;
  }

  Widget _buildResultsSection() {
    if (_assessment == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assessment Results',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        _buildRiskAssessmentCard(),
        const SizedBox(height: 16),
        _buildSafeAlternativesCard(),
        const SizedBox(height: 16),
        _buildAvoidListCard(),
        const SizedBox(height: 16),
        _buildClinicalGuidanceCard(),
        const SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildRiskAssessmentCard() {
    if (_assessment == null) return const SizedBox.shrink();

    Color riskColor = AppColors.success;
    IconData riskIcon = Icons.check_circle;

    if (_assessment!.riskLevel == 'High') {
      riskColor = AppColors.error;
      riskIcon = Icons.error;
    } else if (_assessment!.riskLevel == 'Moderate') {
      riskColor = AppColors.warning;
      riskIcon = Icons.warning;
    } else if (_assessment!.riskLevel == 'Low') {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(riskIcon, color: riskColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cross-Reactivity Risk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_assessment!.riskLevel.toUpperCase()} (${_assessment!.riskPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: riskColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _assessment!.riskExplanation,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeAlternativesCard() {
    if (_assessment == null || _assessment!.safeAlternatives.isEmpty) {
      return const SizedBox.shrink();
    }

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
              Icon(Icons.medication, color: AppColors.success, size: 24),
              const SizedBox(width: 12),
              Text(
                'Safe Alternatives',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._assessment!.safeAlternatives.map((alt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alt.drugName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${alt.crossReactivityRisk.toStringAsFixed(1)}% risk',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alt.drugClass,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alt.clinicalUse,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dosing: ${alt.dosingConsiderations}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAvoidListCard() {
    if (_assessment == null || _assessment!.avoidList.isEmpty) {
      return const SizedBox.shrink();
    }

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
              Icon(Icons.block, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Antibiotics to Avoid',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._assessment!.avoidList.map((avoid) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            avoid.drugName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${avoid.crossReactivityRisk.toStringAsFixed(1)}% risk',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      avoid.reason,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildClinicalGuidanceCard() {
    if (_assessment == null) return const SizedBox.shrink();

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
              Icon(Icons.lightbulb_outline, color: AppColors.info, size: 24),
              const SizedBox(width: 12),
              Text(
                'Clinical Guidance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _assessment!.clinicalGuidance,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (_assessment!.recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Recommendations:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ..._assessment!.recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref['title'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.info,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: AppColors.info,
                    ),
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

  Future<void> _exportAsPDF() async {
    if (_assessment == null) return;

    try {
      final inputs = {
        'Allergic Drug': _assessment!.allergicDrug,
        'Drug Class': _assessment!.drugClass,
        'Reaction Type': _assessment!.reactionType,
        'Reaction Severity': _assessment!.reactionSeverity,
        if (_assessment!.timeSinceReaction != null)
          'Time Since Reaction': _assessment!.timeSinceReaction!,
        if (_assessment!.clinicalContext.isNotEmpty)
          'Clinical Context': _assessment!.clinicalContext.join(', '),
      };

      final results = {
        'Risk Level': _assessment!.riskLevel,
        'Risk Percentage': '${_assessment!.riskPercentage.toStringAsFixed(1)}%',
        'Risk Explanation': _assessment!.riskExplanation,
        'Safe Alternatives': _assessment!.safeAlternatives
            .map((alt) => '${alt.drugName} (${alt.drugClass}) - ${alt.crossReactivityRisk.toStringAsFixed(1)}% risk')
            .join('\n'),
        if (_assessment!.avoidList.isNotEmpty)
          'Antibiotics to Avoid': _assessment!.avoidList
              .map((avoid) => '${avoid.drugName} - ${avoid.reason}')
              .join('\n'),
      };

      await UnifiedExportService.exportCalculatorAsPDF(
        context: context,
        toolName: 'Allergy Cross-Reactivity Checker',
        formula: 'Clinical Decision Support Tool',
        inputs: inputs,
        results: results,
        benchmark: {},
        recommendations: _assessment!.recommendations.join('\n'),
        interpretation: _assessment!.clinicalGuidance,
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
        'Allergic Drug': _assessment!.allergicDrug,
        'Drug Class': _assessment!.drugClass,
        'Reaction Type': _assessment!.reactionType,
        'Reaction Severity': _assessment!.reactionSeverity,
        if (_assessment!.timeSinceReaction != null)
          'Time Since Reaction': _assessment!.timeSinceReaction!,
        if (_assessment!.clinicalContext.isNotEmpty)
          'Clinical Context': _assessment!.clinicalContext.join(', '),
      };

      final results = {
        'Risk Level': _assessment!.riskLevel,
        'Risk Percentage': '${_assessment!.riskPercentage.toStringAsFixed(1)}%',
        'Risk Explanation': _assessment!.riskExplanation,
        'Safe Alternatives': _assessment!.safeAlternatives
            .map((alt) => '${alt.drugName} (${alt.drugClass}) - ${alt.crossReactivityRisk.toStringAsFixed(1)}% risk')
            .join('\n'),
        if (_assessment!.avoidList.isNotEmpty)
          'Antibiotics to Avoid': _assessment!.avoidList
              .map((avoid) => '${avoid.drugName} - ${avoid.reason}')
              .join('\n'),
      };

      await UnifiedExportService.exportCalculatorAsExcel(
        context: context,
        toolName: 'Allergy Cross-Reactivity Checker',
        formula: 'Clinical Decision Support Tool',
        inputs: inputs,
        results: results,
        benchmark: {},
        recommendations: _assessment!.recommendations.join('\n'),
        interpretation: _assessment!.clinicalGuidance,
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
        'Allergic Drug': _assessment!.allergicDrug,
        'Drug Class': _assessment!.drugClass,
        'Reaction Type': _assessment!.reactionType,
        'Reaction Severity': _assessment!.reactionSeverity,
        if (_assessment!.timeSinceReaction != null)
          'Time Since Reaction': _assessment!.timeSinceReaction!,
        if (_assessment!.clinicalContext.isNotEmpty)
          'Clinical Context': _assessment!.clinicalContext.join(', '),
      };

      final results = {
        'Risk Level': _assessment!.riskLevel,
        'Risk Percentage': '${_assessment!.riskPercentage.toStringAsFixed(1)}%',
        'Risk Explanation': _assessment!.riskExplanation,
        'Safe Alternatives': _assessment!.safeAlternatives
            .map((alt) => '${alt.drugName} (${alt.drugClass}) - ${alt.crossReactivityRisk.toStringAsFixed(1)}% risk')
            .join('; '),
        if (_assessment!.avoidList.isNotEmpty)
          'Antibiotics to Avoid': _assessment!.avoidList
              .map((avoid) => '${avoid.drugName} - ${avoid.reason}')
              .join('; '),
      };

      await UnifiedExportService.exportCalculatorAsCSV(
        context: context,
        toolName: 'Allergy Cross-Reactivity Checker',
        formula: 'Clinical Decision Support Tool',
        inputs: inputs,
        results: results,
        benchmark: {},
        recommendations: _assessment!.recommendations.join('; '),
        interpretation: _assessment!.clinicalGuidance,
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
        'Allergic Drug': _assessment!.allergicDrug,
        'Drug Class': _assessment!.drugClass,
        'Reaction Type': _assessment!.reactionType,
        'Reaction Severity': _assessment!.reactionSeverity,
        if (_assessment!.timeSinceReaction != null)
          'Time Since Reaction': _assessment!.timeSinceReaction!,
        if (_assessment!.clinicalContext.isNotEmpty)
          'Clinical Context': _assessment!.clinicalContext.join(', '),
      };

      final results = {
        'Risk Level': _assessment!.riskLevel,
        'Risk Percentage': '${_assessment!.riskPercentage.toStringAsFixed(1)}%',
        'Risk Explanation': _assessment!.riskExplanation,
        'Safe Alternatives': _assessment!.safeAlternatives
            .map((alt) => '${alt.drugName} (${alt.drugClass}) - ${alt.crossReactivityRisk.toStringAsFixed(1)}% risk')
            .join('\n'),
        if (_assessment!.avoidList.isNotEmpty)
          'Antibiotics to Avoid': _assessment!.avoidList
              .map((avoid) => '${avoid.drugName} - ${avoid.reason}')
              .join('\n'),
      };

      await UnifiedExportService.exportCalculatorAsText(
        context: context,
        toolName: 'Allergy Cross-Reactivity Checker',
        formula: 'Clinical Decision Support Tool',
        inputs: inputs,
        results: results,
        benchmark: {},
        recommendations: _assessment!.recommendations.join('\n'),
        interpretation: _assessment!.clinicalGuidance,
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
