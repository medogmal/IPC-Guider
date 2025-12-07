import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../../core/widgets/export_modal.dart';

class DisinfectantSelectionTool extends ConsumerStatefulWidget {
  const DisinfectantSelectionTool({super.key});

  @override
  ConsumerState<DisinfectantSelectionTool> createState() => _DisinfectantSelectionToolState();
}

class _DisinfectantSelectionToolState extends ConsumerState<DisinfectantSelectionTool> {
  final _formKey = GlobalKey<FormState>();
  
  // Input fields
  String? _pathogenType;
  String? _surfaceType;
  String? _contactTimeAvailable;
  
  // Results
  List<Map<String, dynamic>>? _recommendations;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disinfectant Selection Tool'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        bottom: false,
        child: _recommendations == null ? _buildInputForm(bottomPadding) : _buildResultsScreen(bottomPadding),
      ),
    );
  }

  Widget _buildInputForm(double bottomPadding) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.science, color: AppColors.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Appropriate Disinfectant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get evidence-based recommendations for your situation',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Guide and Load Example buttons
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
          const SizedBox(height: 24),

          // Pathogen Type
          _buildDropdownField(
            label: 'Pathogen Type',
            icon: Icons.biotech,
            value: _pathogenType,
            items: const [
              {'value': 'mrsa_vre', 'label': 'MRSA / VRE (Resistant bacteria)'},
              {'value': 'c_diff', 'label': 'C. difficile (Spore-forming)'},
              {'value': 'norovirus', 'label': 'Norovirus (Non-enveloped virus)'},
              {'value': 'covid19', 'label': 'COVID-19 / Influenza (Enveloped virus)'},
              {'value': 'candida_auris', 'label': 'Candida auris (Resistant fungus)'},
              {'value': 'tb', 'label': 'Tuberculosis / Mycobacteria'},
              {'value': 'cre', 'label': 'CRE / Carbapenem-resistant bacteria'},
              {'value': 'rotavirus', 'label': 'Rotavirus (Non-enveloped virus)'},
              {'value': 'hbv_hcv', 'label': 'Hepatitis B/C (Bloodborne)'},
              {'value': 'general', 'label': 'General bacteria (non-resistant)'},
            ],
            onChanged: (value) => setState(() => _pathogenType = value),
          ),
          const SizedBox(height: 20),

          // Surface Type
          _buildDropdownField(
            label: 'Surface Type',
            icon: Icons.layers,
            value: _surfaceType,
            items: const [
              {'value': 'high_touch', 'label': 'High-touch surfaces (bed rails, door handles)'},
              {'value': 'patient_equipment', 'label': 'Patient care equipment (BP cuffs, stethoscopes)'},
              {'value': 'floors', 'label': 'Floors and large surfaces'},
              {'value': 'electronics', 'label': 'Electronics (keyboards, monitors)'},
              {'value': 'medical_devices', 'label': 'Non-critical medical devices'},
              {'value': 'bathroom', 'label': 'Bathroom fixtures'},
              {'value': 'food_surfaces', 'label': 'Food preparation surfaces'},
            ],
            onChanged: (value) => setState(() => _surfaceType = value),
          ),
          const SizedBox(height: 20),

          // Contact Time Available
          _buildDropdownField(
            label: 'Contact Time Available',
            icon: Icons.timer,
            value: _contactTimeAvailable,
            items: const [
              {'value': 'short', 'label': 'Short (1-2 minutes) - Quick turnover'},
              {'value': 'standard', 'label': 'Standard (3-5 minutes) - Routine cleaning'},
              {'value': 'extended', 'label': 'Extended (5-10 minutes) - Terminal cleaning'},
              {'value': 'maximum', 'label': 'Maximum (>10 minutes) - Outbreak response'},
            ],
            onChanged: (value) => setState(() => _contactTimeAvailable = value),
          ),
          const SizedBox(height: 32),

          // Calculate Button
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _getRecommendations,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search),
              label: const Text('Get Recommendations', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Reference Card
          _buildQuickReferenceCard(),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<Map<String, String>> items,
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
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
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
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(
                  item['label']!,
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

  Widget _buildQuickReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick Reference',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Always clean before disinfecting (remove organic matter)\n'
            '• Follow manufacturer\'s contact time exactly\n'
            '• Use EPA-registered disinfectants\n'
            '• Wear appropriate PPE (gloves minimum, eye protection for splashes)\n'
            '• Ensure adequate ventilation when using chemicals\n'
            '• Never mix disinfectants (especially bleach + ammonia)',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _getRecommendations() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      final recommendations = _generateRecommendations(
        _pathogenType!,
        _surfaceType!,
        _contactTimeAvailable!,
      );

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    });
  }

  List<Map<String, dynamic>> _generateRecommendations(
    String pathogen,
    String surface,
    String contactTime,
  ) {
    // Define disinfectant database
    final Map<String, List<Map<String, dynamic>>> pathogenDisinfectants = {
      'mrsa_vre': [
        {
          'name': 'Quaternary Ammonium Compounds (Quats)',
          'concentration': '200-800 ppm',
          'contactTime': '1-10 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves',
          'notes': 'Effective against most bacteria, low toxicity',
        },
        {
          'name': 'Phenolic Disinfectants',
          'concentration': 'Per manufacturer',
          'contactTime': '10 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves, eye protection',
          'notes': 'Broad spectrum, avoid on food surfaces',
        },
        {
          'name': 'Sodium Hypochlorite (Bleach)',
          'concentration': '1:100 dilution (500 ppm)',
          'contactTime': '5-10 minutes',
          'effectiveness': 'Very High',
          'ppe': 'Gloves, eye protection',
          'notes': 'Corrosive, ensure ventilation',
        },
      ],
      'c_diff': [
        {
          'name': 'Sodium Hypochlorite (Bleach)',
          'concentration': '1:10 dilution (5000 ppm)',
          'contactTime': '5-10 minutes',
          'effectiveness': 'Very High (Sporicidal)',
          'ppe': 'Gloves, eye protection, gown',
          'notes': 'REQUIRED for C. diff - only sporicidal agent',
        },
        {
          'name': 'EPA-Registered Sporicidal Disinfectant',
          'concentration': 'Per manufacturer',
          'contactTime': '5-10 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves, eye protection',
          'notes': 'Alternative if bleach not suitable for surface',
        },
      ],
      'norovirus': [
        {
          'name': 'Sodium Hypochlorite (Bleach)',
          'concentration': '1000-5000 ppm',
          'contactTime': '5-10 minutes',
          'effectiveness': 'Very High',
          'ppe': 'Gloves, eye protection, gown',
          'notes': 'Most effective against non-enveloped viruses',
        },
        {
          'name': 'EPA List G Disinfectants',
          'concentration': 'Per manufacturer',
          'contactTime': '5-10 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves',
          'notes': 'Registered for norovirus claims',
        },
      ],
      'covid19': [
        {
          'name': 'EPA List N Disinfectants',
          'concentration': 'Per manufacturer',
          'contactTime': '1-10 minutes',
          'effectiveness': 'Very High',
          'ppe': 'Gloves',
          'notes': 'Effective against SARS-CoV-2',
        },
        {
          'name': 'Alcohol (70% Ethanol or Isopropanol)',
          'concentration': '70%',
          'contactTime': '1-2 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves',
          'notes': 'Fast-acting, flammable, avoid electronics',
        },
        {
          'name': 'Hydrogen Peroxide',
          'concentration': '0.5-7%',
          'contactTime': '1-5 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves, eye protection',
          'notes': 'Environmentally friendly, safe for electronics',
        },
      ],
      'candida_auris': [
        {
          'name': 'Sodium Hypochlorite (Bleach)',
          'concentration': '1:10 dilution (5000 ppm)',
          'contactTime': '5-10 minutes',
          'effectiveness': 'Very High',
          'ppe': 'Gloves, eye protection, gown',
          'notes': 'Preferred agent for C. auris',
        },
        {
          'name': 'EPA-Registered Sporicidal Disinfectant',
          'concentration': 'Per manufacturer',
          'contactTime': '5-10 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves, eye protection',
          'notes': 'Must have sporicidal claims',
        },
      ],
      'tb': [
        {
          'name': 'EPA-Registered Tuberculocidal Disinfectant',
          'concentration': 'Per manufacturer',
          'contactTime': '10 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves, N95 respirator if aerosol risk',
          'notes': 'Must have tuberculocidal claims',
        },
        {
          'name': 'Phenolic Disinfectants',
          'concentration': 'Per manufacturer',
          'contactTime': '10 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves, eye protection',
          'notes': 'Effective against mycobacteria',
        },
      ],
      'cre': [
        {
          'name': 'Quaternary Ammonium Compounds',
          'concentration': '200-800 ppm',
          'contactTime': '5-10 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves',
          'notes': 'Effective against CRE',
        },
        {
          'name': 'Sodium Hypochlorite (Bleach)',
          'concentration': '1:100 dilution (500 ppm)',
          'contactTime': '5-10 minutes',
          'effectiveness': 'Very High',
          'ppe': 'Gloves, eye protection',
          'notes': 'Broad spectrum, highly effective',
        },
      ],
      'rotavirus': [
        {
          'name': 'Sodium Hypochlorite (Bleach)',
          'concentration': '1000-5000 ppm',
          'contactTime': '5-10 minutes',
          'effectiveness': 'Very High',
          'ppe': 'Gloves, eye protection',
          'notes': 'Most effective for non-enveloped viruses',
        },
      ],
      'hbv_hcv': [
        {
          'name': 'Sodium Hypochlorite (Bleach)',
          'concentration': '1:100 dilution (500 ppm)',
          'contactTime': '10 minutes',
          'effectiveness': 'Very High',
          'ppe': 'Gloves, eye protection, gown',
          'notes': 'Effective for bloodborne pathogens',
        },
        {
          'name': 'EPA-Registered Hospital Disinfectant',
          'concentration': 'Per manufacturer',
          'contactTime': '5-10 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves',
          'notes': 'Must have HBV/HCV claims',
        },
      ],
      'general': [
        {
          'name': 'Quaternary Ammonium Compounds',
          'concentration': '200-800 ppm',
          'contactTime': '1-5 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves',
          'notes': 'General purpose, low toxicity',
        },
        {
          'name': 'Hydrogen Peroxide',
          'concentration': '0.5-3%',
          'contactTime': '1-5 minutes',
          'effectiveness': 'High',
          'ppe': 'Gloves',
          'notes': 'Environmentally friendly',
        },
      ],
    };

    List<Map<String, dynamic>> recommendations = pathogenDisinfectants[pathogen] ?? [];

    // Filter based on contact time if needed
    if (contactTime == 'short') {
      recommendations = recommendations.where((r) {
        final time = r['contactTime'] as String;
        return time.contains('1-2') || time.contains('1-5');
      }).toList();
    }

    // Add surface-specific warnings
    for (var rec in recommendations) {
      if (surface == 'electronics' && rec['name'].contains('Bleach')) {
        rec['surfaceWarning'] = '⚠️ Bleach may damage electronics - use with caution or choose alternative';
      }
      if (surface == 'food_surfaces' && rec['name'].contains('Phenolic')) {
        rec['surfaceWarning'] = '⚠️ Do not use phenolics on food surfaces';
      }
    }

    return recommendations;
  }

  Widget _buildResultsScreen(double bottomPadding) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
      children: [
        // Header with selection summary
        _buildSelectionSummary(),
        const SizedBox(height: 24),

        // Recommendations
        if (_recommendations!.isEmpty)
          _buildNoRecommendationsCard()
        else
          ..._recommendations!.asMap().entries.map((entry) {
            final index = entry.key;
            final rec = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildRecommendationCard(rec, index + 1),
            );
          }),

        const SizedBox(height: 16),

        // Action Buttons
        _buildResultActions(),
        const SizedBox(height: 24),

        // Safety Guidelines
        _buildSafetyGuidelines(),
        const SizedBox(height: 24),

        // References
        _buildReferencesCard(),
      ],
    );
  }

  Widget _buildSelectionSummary() {
    final pathogenLabels = {
      'mrsa_vre': 'MRSA / VRE',
      'c_diff': 'C. difficile',
      'norovirus': 'Norovirus',
      'covid19': 'COVID-19 / Influenza',
      'candida_auris': 'Candida auris',
      'tb': 'Tuberculosis',
      'cre': 'CRE',
      'rotavirus': 'Rotavirus',
      'hbv_hcv': 'Hepatitis B/C',
      'general': 'General bacteria',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 28),
              const SizedBox(width: 12),
              Text(
                'Recommendations Ready',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Pathogen', pathogenLabels[_pathogenType] ?? ''),
          const SizedBox(height: 8),
          _buildSummaryRow('Surface', _getSurfaceLabel(_surfaceType!)),
          const SizedBox(height: 8),
          _buildSummaryRow('Contact Time', _getContactTimeLabel(_contactTimeAvailable!)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
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

  String _getSurfaceLabel(String value) {
    final labels = {
      'high_touch': 'High-touch surfaces',
      'patient_equipment': 'Patient care equipment',
      'floors': 'Floors and large surfaces',
      'electronics': 'Electronics',
      'medical_devices': 'Non-critical medical devices',
      'bathroom': 'Bathroom fixtures',
      'food_surfaces': 'Food preparation surfaces',
    };
    return labels[value] ?? value;
  }

  String _getContactTimeLabel(String value) {
    final labels = {
      'short': 'Short (1-2 minutes)',
      'standard': 'Standard (3-5 minutes)',
      'extended': 'Extended (5-10 minutes)',
      'maximum': 'Maximum (>10 minutes)',
    };
    return labels[value] ?? value;
  }

  Widget _buildNoRecommendationsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.warning, color: AppColors.warning, size: 48),
          const SizedBox(height: 16),
          Text(
            'No Specific Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No disinfectants match your criteria. Try adjusting contact time or consult infection control.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec, int rank) {
    final hasWarning = rec.containsKey('surfaceWarning');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank == 1
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.textSecondary.withValues(alpha: 0.2),
          width: rank == 1 ? 2 : 1,
        ),
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
          // Header with rank
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: rank == 1
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  rank == 1 ? 'RECOMMENDED' : 'OPTION $rank',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: rank == 1 ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getEffectivenessColor(rec['effectiveness']).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  rec['effectiveness'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getEffectivenessColor(rec['effectiveness']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Disinfectant name
          Text(
            rec['name'],
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Details
          _buildDetailRow(Icons.science, 'Concentration', rec['concentration']),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.timer, 'Contact Time', rec['contactTime']),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.health_and_safety, 'PPE Required', rec['ppe']),
          const SizedBox(height: 16),

          // Notes
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec['notes'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Surface warning if applicable
          if (hasWarning) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec['surfaceWarning'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
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

  Color _getEffectivenessColor(String effectiveness) {
    if (effectiveness.contains('Very High')) return AppColors.success;
    if (effectiveness.contains('High')) return AppColors.info;
    return AppColors.warning;
  }

  Widget _buildResultActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('New Search'),
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
            label: const Text('Export Guide'),
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

  Widget _buildSafetyGuidelines() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Safety Guidelines',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSafetyItem('Always clean surfaces before disinfecting to remove organic matter'),
          _buildSafetyItem('Follow manufacturer\'s contact time exactly - do not wipe early'),
          _buildSafetyItem('Wear appropriate PPE: gloves minimum, eye protection for splashes'),
          _buildSafetyItem('Ensure adequate ventilation when using chemical disinfectants'),
          _buildSafetyItem('Never mix disinfectants (especially bleach + ammonia = toxic gas)'),
          _buildSafetyItem('Store disinfectants in original containers with labels'),
          _buildSafetyItem('Keep disinfectants away from patients and food'),
          _buildSafetyItem('Check surface compatibility before use'),
          _buildSafetyItem('Dispose of used disinfectant solutions properly'),
        ],
      ),
    );
  }

  Widget _buildSafetyItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle_outline, color: AppColors.error, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
            onPressed: () => _launchURL('https://www.epa.gov/coronavirus/about-list-n-disinfectants-coronavirus-covid-19-0'),
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
                    'EPA – List N: Disinfectants for Coronavirus (COVID-19)',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _launchURL('https://www.epa.gov/pesticide-registration/list-g-epas-registered-antimicrobial-products-effective-against-norovirus'),
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
                    'EPA – List G: Disinfectants for Norovirus',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _launchURL('https://www.cdc.gov/infectioncontrol/guidelines/disinfection/'),
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
                    'CDC – Guideline for Disinfection and Sterilization in Healthcare Facilities',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _launchURL('https://www.who.int/publications/i/item/WHO-2019-nCoV-Disinfection-2020.1'),
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
                    'WHO – Cleaning and Disinfection of Environmental Surfaces',
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
                    'GDIPC/Weqaya – Environmental Cleaning Standards (Saudi Arabia)',
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
                'This tool helps select the most appropriate disinfectant based on pathogen type, surface type, and available contact time.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text(
                'How to Use',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Select the pathogen type\n2. Choose the surface type\n3. Specify available contact time\n4. Review recommendations',
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
                'Recommendations are ranked by effectiveness. Always follow manufacturer instructions and facility protocols.',
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
      _pathogenType = 'c_diff';
      _surfaceType = 'high_touch';
      _contactTimeAvailable = 'extended'; // Fixed: use valid dropdown value
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example loaded: C. difficile on high-touch surfaces with extended contact time'),
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
      'Pathogen Type': _pathogenType ?? 'N/A',
      'Surface Type': _surfaceType ?? 'N/A',
      'Contact Time Available': _contactTimeAvailable ?? 'N/A',
    };

    final results = {
      'Recommendations': _recommendations?.map((r) => r['name']).join('\n') ?? 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Disinfectant Selection Tool',
      inputs: inputs,
      results: results,
    );
  }

  // Export as Excel
  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    final inputs = {
      'Pathogen Type': _pathogenType ?? 'N/A',
      'Surface Type': _surfaceType ?? 'N/A',
      'Contact Time Available': _contactTimeAvailable ?? 'N/A',
    };

    final results = {
      'Recommendations': _recommendations?.map((r) => r['name']).join('\n') ?? 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Disinfectant Selection Tool',
      inputs: inputs,
      results: results,
    );
  }

  // Export as CSV
  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    final inputs = {
      'Pathogen Type': _pathogenType ?? 'N/A',
      'Surface Type': _surfaceType ?? 'N/A',
      'Contact Time Available': _contactTimeAvailable ?? 'N/A',
    };

    final results = {
      'Recommendations': _recommendations?.map((r) => r['name']).join('\n') ?? 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Disinfectant Selection Tool',
      inputs: inputs,
      results: results,
    );
  }

  // Export as Text
  Future<void> _exportAsText() async {
    Navigator.pop(context);

    final inputs = {
      'Pathogen Type': _pathogenType ?? 'N/A',
      'Surface Type': _surfaceType ?? 'N/A',
      'Contact Time Available': _contactTimeAvailable ?? 'N/A',
    };

    final results = {
      'Recommendations': _recommendations?.map((r) => r['name']).join('\n') ?? 'N/A',
    };

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Disinfectant Selection Tool',
      inputs: inputs,
      results: results,
    );
  }

  // Save result to history
  Future<void> _saveResult() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('disinfectant_selection_history') ?? [];

    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'pathogenType': _pathogenType ?? 'N/A',
      'surfaceType': _surfaceType ?? 'N/A',
      'contactTimeAvailable': _contactTimeAvailable ?? 'N/A',
      'recommendations': _recommendations?.map((r) => r['name']).join(', ') ?? 'N/A',
    };

    history.insert(0, jsonEncode(entry));

    // Keep only last 50 entries
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    await prefs.setStringList('disinfectant_selection_history', history);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selection saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _reset() {
    setState(() {
      _pathogenType = null;
      _surfaceType = null;
      _contactTimeAvailable = null;
      _recommendations = null;
    });
  }
}
