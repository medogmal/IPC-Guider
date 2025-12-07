import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/widgets/back_button.dart';
import '../../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../../features/outbreak/data/repositories/history_repository.dart';
import '../../../../../features/outbreak/data/models/history_entry.dart';
import '../../../data/models/sepsis_bundle_record.dart';

class SepsisBundleCheckerScreen extends StatefulWidget {
  const SepsisBundleCheckerScreen({super.key});

  @override
  State<SepsisBundleCheckerScreen> createState() => _SepsisBundleCheckerScreenState();
}

class _SepsisBundleCheckerScreenState extends State<SepsisBundleCheckerScreen> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _unitController = TextEditingController();
  final _auditorController = TextEditingController();
  final _patientIdController = TextEditingController();
  final _lactateValueController = TextEditingController();
  final _fluidVolumeController = TextEditingController();

  // Date/Time fields
  DateTime _recognitionTime = DateTime.now();
  DateTime _auditDate = DateTime.now();

  // Element completion status
  bool _lactateMeasured = false;
  DateTime? _lactateTime;

  bool _bloodCulturesObtained = false;
  DateTime? _bloodCulturesTime;

  bool _antibioticsAdministered = false;
  DateTime? _antibioticsTime;

  bool _fluidResuscitationGiven = false;
  DateTime? _fluidResuscitationTime;

  bool _vasopressorsApplied = false;
  DateTime? _vasopressorsTime;
  bool _vasopressorsIndicated = false;

  // Results
  SepsisBundleRecord? _result;

  @override
  void dispose() {
    _unitController.dispose();
    _auditorController.dispose();
    _patientIdController.dispose();
    _lactateValueController.dispose();
    _fluidVolumeController.dispose();
    super.dispose();
  }

  void _loadExample() {
    setState(() {
      _recognitionTime = DateTime.now().subtract(const Duration(hours: 2));
      _auditDate = DateTime.now();
      _unitController.text = 'Emergency Department';
      _auditorController.text = 'Dr. Sarah Johnson';
      _patientIdController.text = 'PT-2024-001';

      // Element 1: Lactate measured at 15 minutes
      _lactateMeasured = true;
      _lactateTime = _recognitionTime.add(const Duration(minutes: 15));
      _lactateValueController.text = '3.2';

      // Element 2: Blood cultures at 20 minutes
      _bloodCulturesObtained = true;
      _bloodCulturesTime = _recognitionTime.add(const Duration(minutes: 20));

      // Element 3: Antibiotics at 45 minutes
      _antibioticsAdministered = true;
      _antibioticsTime = _recognitionTime.add(const Duration(minutes: 45));

      // Element 4: Fluid resuscitation at 30 minutes
      _fluidResuscitationGiven = true;
      _fluidResuscitationTime = _recognitionTime.add(const Duration(minutes: 30));
      _fluidVolumeController.text = '2100';

      // Element 5: Vasopressors indicated and applied at 50 minutes
      _vasopressorsIndicated = true;
      _vasopressorsApplied = true;
      _vasopressorsTime = _recognitionTime.add(const Duration(minutes: 50));

      _result = null;
    });
  }

  void _checkCompliance() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _result = SepsisBundleRecord.calculate(
        recognitionTime: _recognitionTime,
        auditDate: _auditDate,
        unitLocation: _unitController.text.trim(),
        auditorName: _auditorController.text.trim(),
        patientId: _patientIdController.text.trim().isEmpty
            ? null
            : _patientIdController.text.trim(),
        lactateMeasured: _lactateMeasured,
        lactateTime: _lactateTime,
        lactateValue: _lactateValueController.text.trim().isEmpty
            ? null
            : double.tryParse(_lactateValueController.text.trim()),
        bloodCulturesObtained: _bloodCulturesObtained,
        bloodCulturesTime: _bloodCulturesTime,
        antibioticsAdministered: _antibioticsAdministered,
        antibioticsTime: _antibioticsTime,
        fluidResuscitationGiven: _fluidResuscitationGiven,
        fluidResuscitationTime: _fluidResuscitationTime,
        fluidVolume: _fluidVolumeController.text.trim().isEmpty
            ? null
            : double.tryParse(_fluidVolumeController.text.trim()),
        vasopressorsApplied: _vasopressorsApplied,
        vasopressorsTime: _vasopressorsTime,
        vasopressorsIndicated: _vasopressorsIndicated,
      );
    });

    // Scroll to results
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _saveToHistory() async {
    if (_result == null) return;

    try {
      final entry = HistoryEntry.fromCalculator(
        calculatorName: 'Sepsis Bundle Checker',
        inputs: {
          'Recognition Time': DateFormat('yyyy-MM-dd HH:mm').format(_result!.recognitionTime),
          'Audit Date': DateFormat('yyyy-MM-dd').format(_result!.auditDate),
          'Unit': _result!.unitLocation,
          'Auditor': _result!.auditorName,
          if (_result!.patientId != null) 'Patient ID': _result!.patientId!,
          'Lactate Measured': _result!.lactateMeasured ? 'Yes' : 'No',
          if (_result!.lactateValue != null) 'Lactate Value': '${_result!.lactateValue} mmol/L',
          'Blood Cultures': _result!.bloodCulturesObtained ? 'Yes' : 'No',
          'Antibiotics': _result!.antibioticsAdministered ? 'Yes' : 'No',
          'Fluid Resuscitation': _result!.fluidResuscitationGiven ? 'Yes' : 'No',
          if (_result!.fluidVolume != null) 'Fluid Volume': '${_result!.fluidVolume} mL',
          'Vasopressors Indicated': _result!.vasopressorsIndicated ? 'Yes' : 'No',
          'Vasopressors Applied': _result!.vasopressorsApplied ? 'Yes' : 'No',
        },
        result: '${_result!.compliancePercentage.toStringAsFixed(1)}% compliance',
      );

      await HistoryRepository().addEntry(entry);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Saved to history'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving to history: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showExportModal() {
    if (_result == null) return;

    ExportModal.show(
      context: context,
      onExportPDF: () => _exportAs('pdf'),
      onExportExcel: () => _exportAs('excel'),
      onExportCSV: () => _exportAs('csv'),
      onExportText: () => _exportAs('text'),
      enablePhoto: false,
    );
  }

  Future<void> _exportAs(String format) async {
    if (_result == null) return;

    context.pop(); // Close modal

    try {
      final inputs = {
        'Recognition Time': DateFormat('yyyy-MM-dd HH:mm').format(_result!.recognitionTime),
        'Audit Date': DateFormat('yyyy-MM-dd').format(_result!.auditDate),
        'Unit': _result!.unitLocation,
        'Auditor': _result!.auditorName,
        if (_result!.patientId != null) 'Patient ID': _result!.patientId!,
      };

      final results = {
        'Compliance': '${_result!.compliancePercentage.toStringAsFixed(1)}%',
        'Compliant Elements': '${_result!.compliantElements}/${_result!.totalElements}',
        'Compliance Level': _result!.complianceLevel,
        'Hour-1 Compliant': _result!.hour1Compliant ? 'Yes' : 'No',
      };

      // Convert recommendations list to string
      final recommendationsText = _result!.recommendations.isNotEmpty
          ? _result!.recommendations.map((r) => '• $r').join('\n')
          : null;

      switch (format) {
        case 'pdf':
          await UnifiedExportService.exportCalculatorAsPDF(
            context: context,
            toolName: 'Sepsis Bundle Checker',
            inputs: inputs,
            results: results,
            interpretation: _result!.interpretation,
            recommendations: recommendationsText,
          );
          break;
        case 'excel':
          await UnifiedExportService.exportCalculatorAsExcel(
            context: context,
            toolName: 'Sepsis Bundle Checker',
            inputs: inputs,
            results: results,
            interpretation: _result!.interpretation,
            recommendations: recommendationsText,
          );
          break;
        case 'csv':
          await UnifiedExportService.exportCalculatorAsCSV(
            context: context,
            toolName: 'Sepsis Bundle Checker',
            inputs: inputs,
            results: results,
            interpretation: _result!.interpretation,
            recommendations: recommendationsText,
          );
          break;
        case 'text':
          await UnifiedExportService.exportCalculatorAsText(
            context: context,
            toolName: 'Sepsis Bundle Checker',
            inputs: inputs,
            results: results,
            interpretation: _result!.interpretation,
            recommendations: recommendationsText,
          );
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Exported as ${format.toUpperCase()}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutralLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: const KnowledgePanelWidget(
                    data: KnowledgePanelData(
                      definition: 'Sepsis Bundle Checker tracks compliance with the Surviving Sepsis Campaign Hour-1 Bundle, a time-critical intervention bundle proven to reduce sepsis mortality. The tool monitors completion time for each element and identifies delays beyond target windows.',
                      example: 'Example: A patient with suspected septic shock is recognized at 10:00 AM. Lactate is measured at 10:15 (15 min), blood cultures at 10:20 (20 min), antibiotics at 10:45 (45 min), fluids started at 10:30 (30 min), and vasopressors at 11:15 (75 min - delayed). Overall compliance: 80% (4/5 on-time).',
                      interpretation: 'Compliance ≥90% (Excellent) indicates optimal sepsis response. Scores 75-89% (Good) suggest minor delays. Scores 50-74% (Fair) require process review. Scores <50% (Poor) indicate critical gaps requiring immediate intervention. Time violations highlight specific bottlenecks in the sepsis response pathway.',
                      whenUsed: 'Use for real-time sepsis response auditing, quality improvement initiatives, identifying system delays, training staff on Hour-1 Bundle compliance, and benchmarking sepsis care performance across units or time periods.',
                      inputDataType: 'Sepsis recognition time (baseline), audit date, unit location, auditor name, patient ID (optional), completion status and time for each Hour-1 Bundle element (lactate, blood cultures, antibiotics, fluids, vasopressors), lactate value (mmol/L), fluid volume (mL), and vasopressor indication status.',
                      references: [],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Sepsis Bundle Checker',
        fitTitle: true,
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.large, // Bottom padding for mobile
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.medium),

              // Quick Guide button
              _buildQuickGuideButton(),
              const SizedBox(height: AppSpacing.medium),

              // Load Example button
              _buildLoadExampleButton(),
              const SizedBox(height: AppSpacing.large),

              _buildAuditDetailsSection(),
              const SizedBox(height: AppSpacing.medium),
              _buildBundleElementsSection(),
              const SizedBox(height: AppSpacing.medium),
              _buildActionButtons(),
              if (_result != null) ...[
                const SizedBox(height: AppSpacing.large),
                _buildResultsSection(),
                const SizedBox(height: AppSpacing.large), // Extra bottom padding after results
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medical_services, color: AppColors.error, size: 28),
                SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    'Sepsis Hour-1 Bundle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'Track compliance with the Surviving Sepsis Campaign Hour-1 Bundle. '
              'All elements should ideally be completed within 1 hour of sepsis recognition.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditDetailsSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.medium),
            // Recognition Time
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time, color: AppColors.error),
              title: const Text('Sepsis Recognition Time'),
              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_recognitionTime)),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _recognitionTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null && mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_recognitionTime),
                    );
                    if (time != null) {
                      setState(() {
                        _recognitionTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ),
            const Divider(),
            // Audit Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: AppColors.primary),
              title: const Text('Audit Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_auditDate)),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _auditDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _auditDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Unit/Location *',
                hintText: 'e.g., Emergency Department',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter unit/location';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            TextFormField(
              controller: _auditorController,
              decoration: const InputDecoration(
                labelText: 'Auditor Name *',
                hintText: 'e.g., Dr. Sarah Johnson',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter auditor name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            TextFormField(
              controller: _patientIdController,
              decoration: const InputDecoration(
                labelText: 'Patient ID (Optional)',
                hintText: 'e.g., PT-2024-001',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleElementsSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hour-1 Bundle Elements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'Check each element completed and enter the completion time',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildElement1(),
            const Divider(height: AppSpacing.large),
            _buildElement2(),
            const Divider(height: AppSpacing.large),
            _buildElement3(),
            const Divider(height: AppSpacing.large),
            _buildElement4(),
            const Divider(height: AppSpacing.large),
            _buildElement5(),
          ],
        ),
      ),
    );
  }

  Widget _buildElement1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _lactateMeasured,
              onChanged: (value) {
                setState(() {
                  _lactateMeasured = value ?? false;
                  if (!_lactateMeasured) {
                    _lactateTime = null;
                    _lactateValueController.clear();
                  }
                });
              },
            ),
            const Expanded(
              child: Text(
                '1. Measure lactate level',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        if (_lactateMeasured) ...[
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule, size: 20),
                  title: Text(
                    _lactateTime == null
                        ? 'Tap to set completion time'
                        : 'Completed: ${DateFormat('HH:mm').format(_lactateTime!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: _lactateTime != null
                      ? Text(
                          '${_lactateTime!.difference(_recognitionTime).inMinutes} min',
                          style: TextStyle(
                            fontSize: 13,
                            color: _lactateTime!.difference(_recognitionTime).inMinutes <= 60
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_lactateTime ?? _recognitionTime),
                    );
                    if (time != null) {
                      setState(() {
                        _lactateTime = DateTime(
                          _recognitionTime.year,
                          _recognitionTime.month,
                          _recognitionTime.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.small),
                TextFormField(
                  controller: _lactateValueController,
                  decoration: const InputDecoration(
                    labelText: 'Lactate Value (mmol/L)',
                    hintText: 'e.g., 3.2',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildElement2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _bloodCulturesObtained,
              onChanged: (value) {
                setState(() {
                  _bloodCulturesObtained = value ?? false;
                  if (!_bloodCulturesObtained) {
                    _bloodCulturesTime = null;
                  }
                });
              },
            ),
            const Expanded(
              child: Text(
                '2. Obtain blood cultures before antibiotics',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        if (_bloodCulturesObtained) ...[
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule, size: 20),
              title: Text(
                _bloodCulturesTime == null
                    ? 'Tap to set completion time'
                    : 'Completed: ${DateFormat('HH:mm').format(_bloodCulturesTime!)}',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: _bloodCulturesTime != null
                  ? Text(
                      '${_bloodCulturesTime!.difference(_recognitionTime).inMinutes} min',
                      style: TextStyle(
                        fontSize: 13,
                        color: _bloodCulturesTime!.difference(_recognitionTime).inMinutes <= 60
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_bloodCulturesTime ?? _recognitionTime),
                );
                if (time != null) {
                  setState(() {
                    _bloodCulturesTime = DateTime(
                      _recognitionTime.year,
                      _recognitionTime.month,
                      _recognitionTime.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildElement3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _antibioticsAdministered,
              onChanged: (value) {
                setState(() {
                  _antibioticsAdministered = value ?? false;
                  if (!_antibioticsAdministered) {
                    _antibioticsTime = null;
                  }
                });
              },
            ),
            const Expanded(
              child: Text(
                '3. Administer broad-spectrum antibiotics',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        if (_antibioticsAdministered) ...[
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule, size: 20),
              title: Text(
                _antibioticsTime == null
                    ? 'Tap to set completion time'
                    : 'Completed: ${DateFormat('HH:mm').format(_antibioticsTime!)}',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: _antibioticsTime != null
                  ? Text(
                      '${_antibioticsTime!.difference(_recognitionTime).inMinutes} min',
                      style: TextStyle(
                        fontSize: 13,
                        color: _antibioticsTime!.difference(_recognitionTime).inMinutes <= 60
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_antibioticsTime ?? _recognitionTime),
                );
                if (time != null) {
                  setState(() {
                    _antibioticsTime = DateTime(
                      _recognitionTime.year,
                      _recognitionTime.month,
                      _recognitionTime.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildElement4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _fluidResuscitationGiven,
              onChanged: (value) {
                setState(() {
                  _fluidResuscitationGiven = value ?? false;
                  if (!_fluidResuscitationGiven) {
                    _fluidResuscitationTime = null;
                    _fluidVolumeController.clear();
                  }
                });
              },
            ),
            const Expanded(
              child: Text(
                '4. Begin 30mL/kg crystalloid (if hypotension/lactate ≥4)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        if (_fluidResuscitationGiven) ...[
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule, size: 20),
                  title: Text(
                    _fluidResuscitationTime == null
                        ? 'Tap to set completion time'
                        : 'Completed: ${DateFormat('HH:mm').format(_fluidResuscitationTime!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: _fluidResuscitationTime != null
                      ? Text(
                          '${_fluidResuscitationTime!.difference(_recognitionTime).inMinutes} min',
                          style: TextStyle(
                            fontSize: 13,
                            color: _fluidResuscitationTime!.difference(_recognitionTime).inMinutes <= 180
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_fluidResuscitationTime ?? _recognitionTime),
                    );
                    if (time != null) {
                      setState(() {
                        _fluidResuscitationTime = DateTime(
                          _recognitionTime.year,
                          _recognitionTime.month,
                          _recognitionTime.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.small),
                TextFormField(
                  controller: _fluidVolumeController,
                  decoration: const InputDecoration(
                    labelText: 'Fluid Volume (mL)',
                    hintText: 'e.g., 2100',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildElement5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _vasopressorsIndicated,
              onChanged: (value) {
                setState(() {
                  _vasopressorsIndicated = value ?? false;
                  if (!_vasopressorsIndicated) {
                    _vasopressorsApplied = false;
                    _vasopressorsTime = null;
                  }
                });
              },
            ),
            const Expanded(
              child: Text(
                '5. Vasopressors indicated? (hypotensive during/after fluids)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        if (_vasopressorsIndicated) ...[
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _vasopressorsApplied,
                      onChanged: (value) {
                        setState(() {
                          _vasopressorsApplied = value ?? false;
                          if (!_vasopressorsApplied) {
                            _vasopressorsTime = null;
                          }
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Vasopressors applied (MAP ≥65 mmHg)',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                if (_vasopressorsApplied) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule, size: 20),
                    title: Text(
                      _vasopressorsTime == null
                          ? 'Tap to set completion time'
                          : 'Completed: ${DateFormat('HH:mm').format(_vasopressorsTime!)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: _vasopressorsTime != null
                        ? Text(
                            '${_vasopressorsTime!.difference(_recognitionTime).inMinutes} min',
                            style: TextStyle(
                              fontSize: 13,
                              color: _vasopressorsTime!.difference(_recognitionTime).inMinutes <= 60
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_vasopressorsTime ?? _recognitionTime),
                      );
                      if (time != null) {
                        setState(() {
                          _vasopressorsTime = DateTime(
                            _recognitionTime.year,
                            _recognitionTime.month,
                            _recognitionTime.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickGuideButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showQuickGuide,
        icon: const Icon(Icons.menu_book, color: AppColors.info),
        label: const Text(
          'Quick Guide',
          style: TextStyle(
            color: AppColors.info,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.info, width: 1.5),
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
        icon: const Icon(Icons.lightbulb_outline, color: AppColors.success),
        label: const Text(
          'Load Example Data',
          style: TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.success, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton.icon(
      onPressed: _checkCompliance,
      icon: const Icon(Icons.check_circle_outline),
      label: const Text('Check Compliance'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_result == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildComplianceSummary(),
        const SizedBox(height: AppSpacing.medium),
        _buildElementDetails(),
        const SizedBox(height: AppSpacing.medium),
        _buildInterpretation(),
        const SizedBox(height: AppSpacing.medium),
        _buildRecommendations(),
        const SizedBox(height: AppSpacing.medium),
        _buildReferences(),
        const SizedBox(height: AppSpacing.medium),
        _buildExportSaveButtons(),
      ],
    );
  }

  Widget _buildComplianceSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            const Text(
              'Compliance Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.medium),
            // Compliance gauge
            SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: _result!.compliancePercentage / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _result!.compliancePercentage >= 80
                            ? AppColors.success
                            : _result!.compliancePercentage >= 60
                                ? AppColors.warning
                                : AppColors.error,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_result!.compliancePercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _result!.complianceLevel,
                        style: TextStyle(
                          fontSize: 14,
                          color: _result!.compliancePercentage >= 80
                              ? AppColors.success
                              : _result!.compliancePercentage >= 60
                                  ? AppColors.warning
                                  : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Compliant Elements',
                  '${_result!.compliantElements}/${_result!.totalElements}',
                  Icons.check_circle,
                  AppColors.success,
                ),
                _buildSummaryItem(
                  'Hour-1 Compliant',
                  _result!.hour1Compliant ? 'Yes' : 'No',
                  _result!.hour1Compliant ? Icons.check_circle : Icons.warning,
                  _result!.hour1Compliant ? AppColors.success : AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: AppSpacing.extraSmall),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildElementDetails() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.list_alt, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'Element Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildElementDetailRow(
              '1. Lactate Measurement',
              _result!.lactateMeasured,
              _result!.lactateTime,
            ),
            const Divider(),
            _buildElementDetailRow(
              '2. Blood Cultures',
              _result!.bloodCulturesObtained,
              _result!.bloodCulturesTime,
            ),
            const Divider(),
            _buildElementDetailRow(
              '3. Broad-Spectrum Antibiotics',
              _result!.antibioticsAdministered,
              _result!.antibioticsTime,
            ),
            const Divider(),
            _buildElementDetailRow(
              '4. Fluid Resuscitation (30mL/kg)',
              _result!.fluidResuscitationGiven,
              _result!.fluidResuscitationTime,
            ),
            if (_result!.vasopressorsIndicated) ...[
              const Divider(),
              _buildElementDetailRow(
                '5. Vasopressors (MAP ≥65 mmHg)',
                _result!.vasopressorsApplied,
                _result!.vasopressorsTime,
              ),
            ],
            if (_result!.timeViolations.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.medium),
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.warning, size: 18),
                        SizedBox(width: AppSpacing.extraSmall),
                        Text(
                          'Time Violations',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.extraSmall),
                    ...(_result!.timeViolations.map((violation) => Padding(
                          padding: const EdgeInsets.only(left: 24, top: 4),
                          child: Text(
                            '${violation.element}: +${violation.delayMinutes} min delay',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildElementDetailRow(String element, bool completed, DateTime? time) {
    final timeDiff = time?.difference(_result!.recognitionTime).inMinutes;
    final isOnTime = timeDiff != null && timeDiff <= 60;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.extraSmall),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.cancel,
            color: completed ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              element,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (time != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isOnTime
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$timeDiff min',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOnTime ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInterpretation() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'Interpretation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              _result!.interpretation,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'Recommendations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ...(_result!.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ))),
          ],
        ),
      ),
    );
  }

  Widget _buildReferences() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.library_books, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.small),
                Text(
                  'References',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildReferenceItem(
              'Surviving Sepsis Campaign: International Guidelines for Management of Sepsis and Septic Shock 2021',
              'https://www.sccm.org/survivingsepsiscampaign/guidelines',
            ),
            const SizedBox(height: AppSpacing.small),
            _buildReferenceItem(
              'Surviving Sepsis Campaign Hour-1 Bundle',
              'https://www.sccm.org/survivingsepsiscampaign/hour-1-bundle',
            ),
            const SizedBox(height: AppSpacing.small),
            _buildReferenceItem(
              'WHO Sepsis Guidelines',
              'https://www.who.int/news-room/fact-sheets/detail/sepsis',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceItem(String label, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.link, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.extraSmall),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSaveButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveToHistory,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showExportModal,
            icon: const Icon(Icons.file_download),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

