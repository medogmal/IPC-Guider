import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';
import '../../../outbreak/data/models/history_entry.dart';
import '../../../outbreak/data/repositories/history_repository.dart';

class AppropriateSpecimenCalculator extends ConsumerStatefulWidget {
  const AppropriateSpecimenCalculator({super.key});

  @override
  ConsumerState<AppropriateSpecimenCalculator> createState() =>
      _AppropriateSpecimenCalculatorState();
}

class _AppropriateSpecimenCalculatorState
    extends ConsumerState<AppropriateSpecimenCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _validSamplesController = TextEditingController();
  final _totalReceivedController = TextEditingController();

  String _selectedSpecimenType = 'General';
  double? _appropriateRate;
  String? _interpretation;
  bool _isCalculated = false;

  final List<String> _specimenTypes = [
    'General',
    'Blood Culture',
    'Urine',
    'Stool',
    'Sputum',
    'CSF',
    'Swabs',
    'Tissue',
    'Sterile Body Fluid',
    'Molecular',
  ];

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Appropriate Specimen % measures the percentage of microbiological specimens that meet acceptance criteria for processing. This reflects the quality of specimen collection, handling, and transport practices.',
    formula: '(Valid/Accepted Samples ÷ Total Samples Received) × 100',
    example: '950 valid samples out of 1,000 received → 95% appropriate specimen rate',
    interpretation: 'Higher rates indicate better specimen collection practices and staff training. Low rates suggest need for education on proper collection techniques, transport conditions, and labeling requirements.',
    whenUsed: 'Use this calculator for continuous quality monitoring of pre-analytical specimen quality. Essential for laboratory accreditation, quality improvement initiatives, and identifying training needs. Calculate monthly or quarterly for trend analysis.',
    inputDataType: 'Number of valid/accepted specimens and total specimens received for the surveillance period. Specify specimen type for accurate benchmarking.',
    references: [
      Reference(
        title: 'CLSI GP44: Quality Management for Specimen Collection',
        url: 'https://clsi.org/standards/products/quality-management-system/documents/gp44/',
      ),
      Reference(
        title: 'CAP Laboratory Accreditation Program - Pre-analytical Standards',
        url: 'https://www.cap.org/laboratory-improvement/accreditation/laboratory-accreditation-program',
      ),
      Reference(
        title: 'WHO Guidelines on Specimen Collection and Transport',
        url: 'https://www.who.int/publications/i/item/laboratory-testing-for-2019-novel-coronavirus-in-suspected-human-cases',
      ),
    ],
  );

  @override
  void dispose() {
    _validSamplesController.dispose();
    _totalReceivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'Appropriate Specimen %',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Header Card
              _buildHeaderCard(),
              const SizedBox(height: 16),

              // Formula Card
              _buildFormulaCard(),
              const SizedBox(height: 16),

              // Quick Guide Button
              _buildQuickGuideButton(),
              const SizedBox(height: 12),

              // Load Example Button
              _buildLoadExampleButton(),
              const SizedBox(height: 16),

              // Specimen Type Dropdown
              _buildSpecimenTypeDropdown(),
              const SizedBox(height: 20),

              // Input Card
              _buildInputCard(),
              const SizedBox(height: 24),

              // Calculate Button
              _buildCalculateButton(),

              if (_isCalculated) ...[
                const SizedBox(height: 20),
                _buildResultsCard(),
                const SizedBox(height: 20),
                _buildAcceptanceCriteriaCard(),
              ],

              const SizedBox(height: 24),

              // References Section - Always visible
              _buildReferences(),
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
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            'Appropriate Specimen %',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Specimen Quality Metric',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaCard() {
    return Container(
      width: double.infinity,
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
              Icon(Icons.calculate_outlined, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Formula',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double fontSize = 16.0;
                  if (constraints.maxWidth < 300) {
                    fontSize = 11.0;
                  } else if (constraints.maxWidth < 400) {
                    fontSize = 13.0;
                  }

                  return Math.tex(
                    r'\text{Appropriate Specimen } \% = \frac{\text{Valid Samples} \times 100}{\text{Total Samples}}',
                    textStyle: TextStyle(fontSize: fontSize),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecimenTypeDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Specimen Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecimenType,
              decoration: InputDecoration(
                labelText: 'Select Specimen Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              items: _specimenTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpecimenType = value!;
                  _isCalculated = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickGuideButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showQuickGuide(context),
        icon: Icon(Icons.menu_book, color: AppColors.info, size: 20),
        label: Text(
          'Quick Guide',
          style: TextStyle(
            fontSize: 16,
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
    );
  }

  Widget _buildLoadExampleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loadExample,
        icon: Icon(Icons.lightbulb_outline, color: AppColors.success, size: 20),
        label: Text(
          'Load Example',
          style: TextStyle(
            fontSize: 16,
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
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.input, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Input Data',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _validSamplesController,
              decoration: InputDecoration(
                labelText: 'Valid/Accepted Samples',
                hintText: 'Enter number of valid samples',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.check_circle, color: AppColors.success),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter valid samples';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) < 0) {
                  return 'Value cannot be negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalReceivedController,
              decoration: InputDecoration(
                labelText: 'Total Samples Received',
                hintText: 'Enter total samples received',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.all_inbox, color: AppColors.info),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total samples';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) <= 0) {
                  return 'Value must be greater than 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _calculate();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calculate, size: 24),
          const SizedBox(width: 12),
          Text(
            'Calculate',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  void _calculate() {
    final validSamples = int.parse(_validSamplesController.text);
    final totalReceived = int.parse(_totalReceivedController.text);

    if (validSamples > totalReceived) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Valid samples cannot exceed total samples'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _appropriateRate = (validSamples * 100) / totalReceived;

      // Get benchmark for specimen type
      final benchmark = _getBenchmarkForSpecimenType();

      // Interpretation
      if (_appropriateRate! >= benchmark) {
        _interpretation =
            'Excellent specimen quality (≥${benchmark.toStringAsFixed(0)}%). Your appropriate specimen rate meets or exceeds the benchmark for $_selectedSpecimenType specimens. This indicates excellent collection, handling, and transport practices. Continue current practices and use as a benchmark for training.';
      } else if (_appropriateRate! >= benchmark - 5) {
        _interpretation =
            'Acceptable performance (${(benchmark - 5).toStringAsFixed(0)}-${(benchmark - 1).toStringAsFixed(0)}%). Your appropriate specimen rate is slightly below the benchmark of ${benchmark.toStringAsFixed(0)}% for $_selectedSpecimenType specimens. Minor improvement needed. Review collection protocols and staff training to achieve ≥${benchmark.toStringAsFixed(0)}%.';
      } else if (_appropriateRate! >= benchmark - 10) {
        _interpretation =
            'Needs improvement (${(benchmark - 10).toStringAsFixed(0)}-${(benchmark - 6).toStringAsFixed(0)}%). Your appropriate specimen rate is below the benchmark of ${benchmark.toStringAsFixed(0)}% for $_selectedSpecimenType specimens. Action required: Staff retraining on proper collection technique, specimen handling, and transport requirements. Review rejection reasons and implement corrective measures.';
      } else {
        _interpretation =
            'Critical (<${(benchmark - 10).toStringAsFixed(0)}%). Your appropriate specimen rate is critically low for $_selectedSpecimenType specimens. Immediate intervention required: Comprehensive staff retraining, audit of all collection practices, review of transport protocols, and implementation of quality improvement initiatives. Low appropriate rates lead to delayed diagnosis, repeat collections, and compromised patient care.';
      }

      _isCalculated = true;
    });
  }

  double _getBenchmarkForSpecimenType() {
    switch (_selectedSpecimenType) {
      case 'Blood Culture':
        return 98.0;
      case 'CSF':
        return 98.0;
      case 'Sterile Body Fluid':
        return 98.0;
      case 'Molecular':
        return 97.0;
      case 'Urine':
        return 95.0;
      case 'Swabs':
        return 95.0;
      case 'Tissue':
        return 95.0;
      case 'Stool':
        return 90.0;
      case 'Sputum':
        return 85.0;
      case 'General':
      default:
        return 95.0;
    }
  }

  Color _getResultColor() {
    final benchmark = _getBenchmarkForSpecimenType();
    if (_appropriateRate! >= benchmark) {
      return AppColors.success;
    } else if (_appropriateRate! >= benchmark - 5) {
      return AppColors.info;
    } else if (_appropriateRate! >= benchmark - 10) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  Widget _buildResultsCard() {
    final resultColor = _getResultColor();
    final benchmark = _getBenchmarkForSpecimenType();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: resultColor, width: 2),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: resultColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: resultColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Appropriate Specimen Rate',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_appropriateRate!.toStringAsFixed(2)}%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: resultColor,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Specimen Type: $_selectedSpecimenType',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Benchmark: ≥${benchmark.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interpretation',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _interpretation!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveToHistory,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showExportModal(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptanceCriteriaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist, color: AppColors.info, size: 24),
              const SizedBox(width: 12),
              Text(
                'Acceptance Criteria: $_selectedSpecimenType',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._getAcceptanceCriteriaForSpecimenType().map((criterion) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        criterion,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  List<String> _getAcceptanceCriteriaForSpecimenType() {
    switch (_selectedSpecimenType) {
      case 'Blood Culture':
        return [
          'Proper volume (8-10mL per bottle for adults)',
          'Correct bottles used (aerobic and anaerobic)',
          'No contamination of bottle tops',
          'Proper labeling with patient ID and collection time',
          'Collected before antibiotic administration (when possible)',
        ];
      case 'Urine':
        return [
          'Midstream clean catch or catheter specimen',
          'Proper sterile container',
          'Transported within 2 hours or refrigerated',
          'Minimum volume 3mL',
          'No contamination with fecal matter',
        ];
      case 'Stool':
        return [
          'Fresh sample (within 2 hours of passage)',
          'Proper leak-proof container',
          'No contamination with urine',
          'Adequate volume (pea-sized or 1-2g)',
          'Transported at room temperature',
        ];
      case 'Sputum':
        return [
          'Deep cough specimen (not saliva)',
          '<10 epithelial cells per low-power field',
          '>25 WBCs per low-power field',
          'Proper sterile container',
          'Collected before antibiotic administration (when possible)',
        ];
      case 'CSF':
        return [
          'Sterile container',
          'Proper tube sequence (tube 1: chemistry, tube 2: microbiology, tube 3: cell count)',
          'Immediate transport to lab',
          'Minimum volume 1mL for culture',
          'No delay in processing',
        ];
      case 'Swabs':
        return [
          'Appropriate swab type for specimen site',
          'Proper transport medium (Stuart\'s or Amies)',
          'Labeled with specific anatomical site',
          'Not dried out',
          'Transported within 2 hours',
        ];
      case 'Tissue':
        return [
          'Sterile container (not formalin)',
          'Adequate size (>1cm³ when possible)',
          'Immediate transport to lab',
          'Kept moist with sterile saline if needed',
          'No delay in processing',
        ];
      case 'Sterile Body Fluid':
        return [
          'Sterile container',
          'Proper volume (minimum 1mL)',
          'Immediate transport to lab',
          'Labeled with specific fluid type',
          'No delay in processing',
        ];
      case 'Molecular':
        return [
          'Proper collection device (swab/tube specific for molecular testing)',
          'Correct transport medium',
          'Temperature requirements met (often refrigerated or frozen)',
          'Proper labeling',
          'Within stability window for test',
        ];
      case 'General':
      default:
        return [
          'Proper collection technique',
          'Appropriate container',
          'Adequate volume',
          'Proper labeling (patient ID, date, time, site)',
          'Timely transport to lab',
          'No contamination',
        ];
    }
  }

  void _loadExample() {
    setState(() {
      switch (_selectedSpecimenType) {
        case 'Blood Culture':
          _validSamplesController.text = '485';
          _totalReceivedController.text = '500';
          break;
        case 'Urine':
          _validSamplesController.text = '428';
          _totalReceivedController.text = '450';
          break;
        case 'Sputum':
          _validSamplesController.text = '170';
          _totalReceivedController.text = '200';
          break;
        default:
          _validSamplesController.text = '380';
          _totalReceivedController.text = '400';
      }
      _isCalculated = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Example loaded for $_selectedSpecimenType'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
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
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, color: AppColors.info, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Guide',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.textTertiary.withValues(alpha: 0.2)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.library_books, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Scientific References',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReferenceItem(
            '1. CLSI GP44: Quality Management for Specimen Collection',
            'Clinical and Laboratory Standards Institute guidelines for pre-analytical quality',
          ),
          const SizedBox(height: 12),
          _buildReferenceItem(
            '2. CAP Laboratory Accreditation Program - Pre-analytical Standards',
            'College of American Pathologists standards for specimen acceptance',
          ),
          const SizedBox(height: 12),
          _buildReferenceItem(
            '3. WHO Guidelines on Specimen Collection and Transport',
            'World Health Organization recommendations for specimen handling',
          ),
          const SizedBox(height: 12),
          _buildReferenceItem(
            '4. IDSA Guidelines: Diagnostic Microbiology',
            'Infectious Diseases Society of America guidelines for specimen quality',
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToHistory() async {
    try {
      final repository = HistoryRepository();
      if (!repository.isInitialized) {
        await repository.initialize();
      }

      final historyEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Appropriate Specimen Rate',
        inputs: {
          'Specimen Type': _selectedSpecimenType,
          'Valid Samples': _validSamplesController.text,
          'Total Received': _totalReceivedController.text,
        },
        result: 'Appropriate Rate: ${_appropriateRate!.toStringAsFixed(2)}%\n'
            'Interpretation: $_interpretation',
        notes: '',
        tags: ['laboratory', 'specimen', 'quality', 'pre-analytical'],
      );

      await repository.addEntry(historyEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to history'),
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
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showExportModal(BuildContext context) {
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
    final benchmark = _getBenchmarkForSpecimenType();
    final success = await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Appropriate Specimen %',
      formula: '(Valid/Accepted Samples × 100) / Total Samples Received',
      inputs: {
        'Specimen Type': _selectedSpecimenType,
        'Valid/Accepted Samples': _validSamplesController.text,
        'Total Samples Received': _totalReceivedController.text,
      },
      results: {
        'Appropriate Specimen Rate': '${_appropriateRate!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': '≥${benchmark.toStringAsFixed(0)}%',
        'unit': 'appropriate specimen rate',
        'source': 'CLSI GP44 Guidelines',
        'status': _appropriateRate! >= benchmark ? 'Meets Target' : 'Below Target',
      },
      interpretation: _interpretation,
      references: [
        'CLSI GP44: Quality Management for Specimen Collection',
        'CAP Laboratory Accreditation Program - Pre-analytical Standards',
        'WHO Guidelines on Specimen Collection and Transport',
        'IDSA Guidelines: Diagnostic Microbiology',
      ],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Exported as PDF' : 'Export failed'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _exportAsExcel() async {
    final benchmark = _getBenchmarkForSpecimenType();
    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Appropriate Specimen %',
      formula: '(Valid/Accepted Samples × 100) / Total Samples Received',
      inputs: {
        'Specimen Type': _selectedSpecimenType,
        'Valid/Accepted Samples': _validSamplesController.text,
        'Total Samples Received': _totalReceivedController.text,
      },
      results: {
        'Appropriate Specimen Rate': '${_appropriateRate!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': '≥${benchmark.toStringAsFixed(0)}%',
        'unit': 'appropriate specimen rate',
        'source': 'CLSI GP44 Guidelines',
        'status': _appropriateRate! >= benchmark ? 'Meets Target' : 'Below Target',
      },
      interpretation: _interpretation,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Exported as Excel' : 'Export failed'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _exportAsCSV() async {
    final benchmark = _getBenchmarkForSpecimenType();
    final success = await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Appropriate Specimen %',
      formula: '(Valid/Accepted Samples × 100) / Total Samples Received',
      inputs: {
        'Specimen Type': _selectedSpecimenType,
        'Valid/Accepted Samples': _validSamplesController.text,
        'Total Samples Received': _totalReceivedController.text,
      },
      results: {
        'Appropriate Specimen Rate': '${_appropriateRate!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': '≥${benchmark.toStringAsFixed(0)}%',
        'unit': 'appropriate specimen rate',
        'source': 'CLSI GP44 Guidelines',
        'status': _appropriateRate! >= benchmark ? 'Meets Target' : 'Below Target',
      },
      interpretation: _interpretation,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Exported as CSV' : 'Export failed'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _exportAsText() async {
    final benchmark = _getBenchmarkForSpecimenType();
    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Appropriate Specimen %',
      formula: '(Valid/Accepted Samples × 100) / Total Samples Received',
      inputs: {
        'Specimen Type': _selectedSpecimenType,
        'Valid/Accepted Samples': _validSamplesController.text,
        'Total Samples Received': _totalReceivedController.text,
      },
      results: {
        'Appropriate Specimen Rate': '${_appropriateRate!.toStringAsFixed(2)}%',
      },
      benchmark: {
        'target': '≥${benchmark.toStringAsFixed(0)}%',
        'unit': 'appropriate specimen rate',
        'source': 'CLSI GP44 Guidelines',
        'status': _appropriateRate! >= benchmark ? 'Meets Target' : 'Below Target',
      },
      interpretation: _interpretation,
      references: [
        'CLSI GP44: Quality Management for Specimen Collection',
        'CAP Laboratory Accreditation Program - Pre-analytical Standards',
        'WHO Guidelines on Specimen Collection and Transport',
        'IDSA Guidelines: Diagnostic Microbiology',
      ],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Exported as Text' : 'Export failed'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}



