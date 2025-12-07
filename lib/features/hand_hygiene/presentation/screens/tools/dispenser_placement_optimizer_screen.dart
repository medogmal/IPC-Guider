import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/back_button.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../../features/outbreak/data/repositories/history_repository.dart';
import '../../../../../features/outbreak/data/models/history_entry.dart';

/// Dispenser Placement Optimizer Tool
/// Calculate optimal number and placement of ABHS dispensers based on WHO and CDC guidelines
class DispenserPlacementOptimizerScreen extends ConsumerStatefulWidget {
  const DispenserPlacementOptimizerScreen({super.key});

  @override
  ConsumerState<DispenserPlacementOptimizerScreen> createState() => _DispenserPlacementOptimizerScreenState();
}

class _DispenserPlacementOptimizerScreenState extends ConsumerState<DispenserPlacementOptimizerScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Input controllers
  final _bedsController = TextEditingController();
  final _examRoomsController = TextEditingController();
  final _corridorLengthController = TextEditingController();
  final _nursingStationsController = TextEditingController();
  final _entrancesController = TextEditingController();
  
  // State variables
  String? _selectedUnitType;
  
  // Results
  int? _pointOfCareDispensers;
  int? _examRoomDispensers;
  int? _corridorDispensers;
  int? _nursingStationDispensers;
  int? _entranceDispensers;
  int? _totalDispensers;
  String? _placementRecommendations;
  String? _fireSafetyCheck;
  String? _costEstimate;
  
  // Loading state
  bool _isCalculating = false;

  @override
  void dispose() {
    _bedsController.dispose();
    _examRoomsController.dispose();
    _corridorLengthController.dispose();
    _nursingStationsController.dispose();
    _entrancesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Dispenser Placement Optimizer',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.medium,
            AppSpacing.medium,
            AppSpacing.large,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              _buildHeaderCard(),
              const SizedBox(height: AppSpacing.medium),

              // Quick Guide Button
              _buildQuickGuideButton(),
              const SizedBox(height: AppSpacing.medium),

              // Load Example Button
              _buildLoadExampleButton(),
              const SizedBox(height: AppSpacing.large),

              // Input Card
              _buildInputCard(),
              const SizedBox(height: AppSpacing.large),

              // Calculate Button
              _buildCalculateButton(),
              
              // Results Section (conditional)
              if (_totalDispensers != null) ...[
                const SizedBox(height: AppSpacing.large),
                _buildResultsCard(),
                const SizedBox(height: AppSpacing.medium),
                _buildBreakdownCard(),
                const SizedBox(height: AppSpacing.medium),
                _buildPlacementRecommendationsSection(),
                const SizedBox(height: AppSpacing.medium),
                _buildFireSafetySection(),
                const SizedBox(height: AppSpacing.medium),
                _buildCostEstimateSection(),
                const SizedBox(height: AppSpacing.medium),
                _buildActionButtons(),
                const SizedBox(height: AppSpacing.large),
                _buildReferences(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.extraLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.place_outlined,
              size: 56,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Dispenser Placement Optimizer',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Calculate optimal ABHS dispenser requirements',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickGuideButton() {
    return OutlinedButton.icon(
      onPressed: _showQuickGuide,
      icon: const Icon(Icons.info_outline),
      label: const Text('Quick Guide: Dispenser Placement'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.medium,
        ),
      ),
    );
  }

  Widget _buildLoadExampleButton() {
    return OutlinedButton.icon(
      onPressed: _loadExample,
      icon: const Icon(Icons.file_download_outlined),
      label: const Text('Load Example (20-bed ICU)'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.info,
        side: BorderSide(color: AppColors.info),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.medium,
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: AppColors.neutralLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.input_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  'Unit Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            
            // Unit Type
            DropdownButtonFormField<String>(
              value: _selectedUnitType,
              decoration: InputDecoration(
                labelText: 'Unit/Ward Type *',
                prefixIcon: const Icon(Icons.local_hospital_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              items: _unitTypeOptions.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnitType = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a unit type';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            
            // Number of Beds
            TextFormField(
              controller: _bedsController,
              decoration: InputDecoration(
                labelText: 'Number of Patient Beds *',
                hintText: 'e.g., 20',
                prefixIcon: const Icon(Icons.bed_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter number of beds';
                }
                final beds = int.tryParse(value);
                if (beds == null || beds <= 0) {
                  return 'Please enter a valid number (>0)';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.medium),

            // Number of Exam/Procedure Rooms
            TextFormField(
              controller: _examRoomsController,
              decoration: InputDecoration(
                labelText: 'Number of Exam/Procedure Rooms',
                hintText: 'e.g., 4 (optional)',
                prefixIcon: const Icon(Icons.meeting_room_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: AppSpacing.medium),

            // Corridor Length
            TextFormField(
              controller: _corridorLengthController,
              decoration: InputDecoration(
                labelText: 'Corridor Length (meters)',
                hintText: 'e.g., 50 (optional)',
                prefixIcon: const Icon(Icons.straighten_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: AppSpacing.medium),

            // Number of Nursing Stations
            TextFormField(
              controller: _nursingStationsController,
              decoration: InputDecoration(
                labelText: 'Number of Nursing Stations',
                hintText: 'e.g., 2 (optional)',
                prefixIcon: const Icon(Icons.desk_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: AppSpacing.medium),

            // Number of Entrances/Exits
            TextFormField(
              controller: _entrancesController,
              decoration: InputDecoration(
                labelText: 'Number of Entrances/Exits',
                hintText: 'e.g., 3 (optional)',
                prefixIcon: const Icon(Icons.door_front_door_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return FilledButton(
      onPressed: _isCalculating ? null : _calculate,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: _isCalculating
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calculate_outlined),
                const SizedBox(width: AppSpacing.small),
                Text(
                  'Calculate Dispenser Requirements',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
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
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AppColors.surface,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Total Dispensers Required',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.extraSmall),
          Text(
            '$_totalDispensers',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                  fontSize: 56,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.small),
          _buildContextRow(Icons.local_hospital_outlined, _selectedUnitType ?? 'N/A'),
          const SizedBox(height: AppSpacing.extraSmall),
          _buildContextRow(Icons.bed_outlined, '${_bedsController.text} beds'),
        ],
      ),
    );
  }

  Widget _buildContextRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.surface.withValues(alpha: 0.8),
        ),
        const SizedBox(width: AppSpacing.extraSmall),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.surface.withValues(alpha: 0.8),
              ),
        ),
      ],
    );
  }

  Widget _buildBreakdownCard() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: AppColors.neutralLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  'Dispenser Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),

            _buildBreakdownRow('Point-of-Care (Bedside)', _pointOfCareDispensers!, AppColors.primary),
            if (_examRoomDispensers! > 0) ...[
              const SizedBox(height: AppSpacing.small),
              _buildBreakdownRow('Exam/Procedure Rooms', _examRoomDispensers!, AppColors.info),
            ],
            if (_corridorDispensers! > 0) ...[
              const SizedBox(height: AppSpacing.small),
              _buildBreakdownRow('Corridors', _corridorDispensers!, AppColors.warning),
            ],
            if (_nursingStationDispensers! > 0) ...[
              const SizedBox(height: AppSpacing.small),
              _buildBreakdownRow('Nursing Stations', _nursingStationDispensers!, AppColors.success),
            ],
            if (_entranceDispensers! > 0) ...[
              const SizedBox(height: AppSpacing.small),
              _buildBreakdownRow('Entrances/Exits', _entranceDispensers!, AppColors.secondary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ),
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildPlacementRecommendationsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
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
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.info,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                'Placement Recommendations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            _placementRecommendations ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFireSafetySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                'Fire Safety Compliance (NFPA 101)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            _fireSafetyCheck ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostEstimateSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money_outlined,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                'Cost Estimate',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            _costEstimate ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _saveToHistory,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save to History'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: FilledButton.icon(
            onPressed: _showExportOptions,
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Export'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferences() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: AppColors.neutralLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.library_books_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  'References',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ..._references.asMap().entries.map((entry) {
              final index = entry.key;
              final ref = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _references.length - 1 ? AppSpacing.small : 0,
                ),
                child: InkWell(
                  onTap: () => _launchURL(ref['url']!),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.small),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: Text(
                            ref['title']!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                        Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  void _calculate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    // Simulate calculation delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Parse inputs
    final beds = int.parse(_bedsController.text);
    final examRooms = _examRoomsController.text.isEmpty ? 0 : int.parse(_examRoomsController.text);
    final corridorLength = _corridorLengthController.text.isEmpty ? 0 : int.parse(_corridorLengthController.text);
    final nursingStations = _nursingStationsController.text.isEmpty ? 1 : int.parse(_nursingStationsController.text);
    final entrances = _entrancesController.text.isEmpty ? 2 : int.parse(_entrancesController.text);

    // Calculate dispensers
    // Point-of-Care: 1 dispenser per bed (WHO recommendation)
    final pointOfCare = beds;

    // Exam Rooms: 1 dispenser per room entrance
    final examRoom = examRooms;

    // Corridors: 1 dispenser every 10 meters (CDC guideline)
    final corridor = (corridorLength / 10).ceil();

    // Nursing Stations: 1 dispenser per station
    final nursingStation = nursingStations;

    // Entrances/Exits: 1 dispenser per entrance/exit
    final entrance = entrances;

    // Total
    final total = pointOfCare + examRoom + corridor + nursingStation + entrance;

    // Generate recommendations
    final recommendations = _generatePlacementRecommendations(beds, examRooms, corridorLength);

    // Generate fire safety check
    final fireSafety = _generateFireSafetyCheck();

    // Generate cost estimate
    final cost = _generateCostEstimate(total);

    setState(() {
      _pointOfCareDispensers = pointOfCare;
      _examRoomDispensers = examRoom;
      _corridorDispensers = corridor;
      _nursingStationDispensers = nursingStation;
      _entranceDispensers = entrance;
      _totalDispensers = total;
      _placementRecommendations = recommendations;
      _fireSafetyCheck = fireSafety;
      _costEstimate = cost;
      _isCalculating = false;
    });
  }

  String _generatePlacementRecommendations(int beds, int examRooms, int corridorLength) {
    final buffer = StringBuffer();

    buffer.writeln('• Place dispensers at point-of-care (bedside or door entrance)');
    buffer.writeln('• Install dispensers at eye level (120-150 cm from floor)');
    buffer.writeln('• Ensure dispensers are visible and within 5 steps of patient');

    if (examRooms > 0) {
      buffer.writeln('• Mount dispensers at exam room entrances for easy access');
    }

    if (corridorLength > 0) {
      buffer.writeln('• Space corridor dispensers evenly (every 10 meters)');
    }

    buffer.writeln('• Avoid placement near ignition sources (NFPA 101 compliance)');
    buffer.writeln('• Consider high-traffic areas and workflow patterns');
    buffer.writeln('• Ensure adequate lighting for dispenser visibility');

    return buffer.toString().trim();
  }

  String _generateFireSafetyCheck() {
    final buffer = StringBuffer();

    buffer.writeln('✓ Maximum 1.2L dispenser capacity in corridors (NFPA 101)');
    buffer.writeln('✓ Minimum 1-inch clearance from ignition sources');
    buffer.writeln('✓ Maximum 95% alcohol concentration');
    buffer.writeln('✓ Wall-mounted dispensers preferred over free-standing');
    buffer.writeln('✓ Ensure proper ventilation in dispenser areas');
    buffer.writeln('✓ Install fire-rated dispensers in high-risk areas');

    return buffer.toString().trim();
  }

  String _generateCostEstimate(int total) {
    final dispenserCostLow = total * 15;
    final dispenserCostHigh = total * 30;
    final installationCostLow = total * 10;
    final installationCostHigh = total * 20;
    final totalCostLow = dispenserCostLow + installationCostLow;
    final totalCostHigh = dispenserCostHigh + installationCostHigh;

    final buffer = StringBuffer();

    buffer.writeln('Dispenser Cost: \$${dispenserCostLow.toStringAsFixed(0)} - \$${dispenserCostHigh.toStringAsFixed(0)}');
    buffer.writeln('Installation Cost: \$${installationCostLow.toStringAsFixed(0)} - \$${installationCostHigh.toStringAsFixed(0)}');
    buffer.writeln('');
    buffer.writeln('Total Estimated Cost: \$${totalCostLow.toStringAsFixed(0)} - \$${totalCostHigh.toStringAsFixed(0)}');
    buffer.writeln('');
    buffer.writeln('Note: Costs are estimates and may vary based on dispenser type, brand, and installation complexity.');

    return buffer.toString().trim();
  }

  void _loadExample() {
    setState(() {
      _selectedUnitType = 'Intensive Care Unit (ICU)';
      _bedsController.text = '20';
      _examRoomsController.text = '4';
      _corridorLengthController.text = '50';
      _nursingStationsController.text = '2';
      _entrancesController.text = '3';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example loaded: 20-bed ICU'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveToHistory() async {
    if (_totalDispensers == null) return;

    try {
      final historyRepo = HistoryRepository();
      final entry = HistoryEntry.fromCalculator(
        calculatorName: 'Dispenser Placement Optimizer',
        inputs: {
          'Unit Type': _selectedUnitType ?? 'N/A',
          'Number of Beds': _bedsController.text,
          'Exam Rooms': _examRoomsController.text.isEmpty ? '0' : _examRoomsController.text,
          'Corridor Length (m)': _corridorLengthController.text.isEmpty ? '0' : _corridorLengthController.text,
          'Nursing Stations': _nursingStationsController.text.isEmpty ? '1' : _nursingStationsController.text,
          'Entrances/Exits': _entrancesController.text.isEmpty ? '2' : _entrancesController.text,
        },
        result: '$_totalDispensers dispensers required',
        tags: ['Hand Hygiene', 'Dispenser Placement', _selectedUnitType ?? 'N/A'],
      );

      await historyRepo.addEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to history successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
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
          ),
        );
      }
    }
  }

  void _showExportOptions() {
    if (_totalDispensers == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportModal(
        onExportPDF: _exportAsPDF,
        onExportExcel: _exportAsExcel,
        onExportCSV: _exportAsCSV,
        onExportText: _exportAsText,
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    Navigator.pop(context);
    final success = await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Dispenser Placement Optimizer',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Unit Type': _selectedUnitType ?? 'N/A',
        'Number of Beds': _bedsController.text,
        'Exam Rooms': _examRoomsController.text.isEmpty ? '0' : _examRoomsController.text,
        'Corridor Length (m)': _corridorLengthController.text.isEmpty ? '0' : _corridorLengthController.text,
        'Nursing Stations': _nursingStationsController.text.isEmpty ? '1' : _nursingStationsController.text,
        'Entrances/Exits': _entrancesController.text.isEmpty ? '2' : _entrancesController.text,
      },
      results: {
        'Total Dispensers Required': _totalDispensers.toString(),
        'Point-of-Care (Bedside)': _pointOfCareDispensers.toString(),
        'Exam/Procedure Rooms': _examRoomDispensers.toString(),
        'Corridors': _corridorDispensers.toString(),
        'Nursing Stations': _nursingStationDispensers.toString(),
        'Entrances/Exits': _entranceDispensers.toString(),
      },
      benchmark: {
        'Placement Recommendations': _placementRecommendations ?? '',
        'Fire Safety Compliance': _fireSafetyCheck ?? '',
        'Cost Estimate': _costEstimate ?? '',
      },
      references: _references.map((ref) => ref['title']!).toList(),
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported successfully to PDF'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);
    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'Dispenser Placement Optimizer',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Unit Type': _selectedUnitType ?? 'N/A',
        'Number of Beds': _bedsController.text,
        'Exam Rooms': _examRoomsController.text.isEmpty ? '0' : _examRoomsController.text,
        'Corridor Length (m)': _corridorLengthController.text.isEmpty ? '0' : _corridorLengthController.text,
        'Nursing Stations': _nursingStationsController.text.isEmpty ? '1' : _nursingStationsController.text,
        'Entrances/Exits': _entrancesController.text.isEmpty ? '2' : _entrancesController.text,
      },
      results: {
        'Total Dispensers Required': _totalDispensers.toString(),
        'Point-of-Care (Bedside)': _pointOfCareDispensers.toString(),
        'Exam/Procedure Rooms': _examRoomDispensers.toString(),
        'Corridors': _corridorDispensers.toString(),
        'Nursing Stations': _nursingStationDispensers.toString(),
        'Entrances/Exits': _entranceDispensers.toString(),
      },
      benchmark: {
        'Placement Recommendations': _placementRecommendations ?? '',
        'Fire Safety Compliance': _fireSafetyCheck ?? '',
        'Cost Estimate': _costEstimate ?? '',
      },
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported successfully to Excel'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);
    final success = await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'Dispenser Placement Optimizer',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Unit Type': _selectedUnitType ?? 'N/A',
        'Number of Beds': _bedsController.text,
        'Exam Rooms': _examRoomsController.text.isEmpty ? '0' : _examRoomsController.text,
        'Corridor Length (m)': _corridorLengthController.text.isEmpty ? '0' : _corridorLengthController.text,
        'Nursing Stations': _nursingStationsController.text.isEmpty ? '1' : _nursingStationsController.text,
        'Entrances/Exits': _entrancesController.text.isEmpty ? '2' : _entrancesController.text,
      },
      results: {
        'Total Dispensers Required': _totalDispensers.toString(),
        'Point-of-Care (Bedside)': _pointOfCareDispensers.toString(),
        'Exam/Procedure Rooms': _examRoomDispensers.toString(),
        'Corridors': _corridorDispensers.toString(),
        'Nursing Stations': _nursingStationDispensers.toString(),
        'Entrances/Exits': _entranceDispensers.toString(),
      },
      benchmark: {
        'Placement Recommendations': _placementRecommendations ?? '',
        'Fire Safety Compliance': _fireSafetyCheck ?? '',
        'Cost Estimate': _costEstimate ?? '',
      },
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported successfully to CSV'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);
    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Dispenser Placement Optimizer',
      formula: _knowledgePanelData.formula,
      inputs: {
        'Unit Type': _selectedUnitType ?? 'N/A',
        'Number of Beds': _bedsController.text,
        'Exam Rooms': _examRoomsController.text.isEmpty ? '0' : _examRoomsController.text,
        'Corridor Length (m)': _corridorLengthController.text.isEmpty ? '0' : _corridorLengthController.text,
        'Nursing Stations': _nursingStationsController.text.isEmpty ? '1' : _nursingStationsController.text,
        'Entrances/Exits': _entrancesController.text.isEmpty ? '2' : _entrancesController.text,
      },
      results: {
        'Total Dispensers Required': _totalDispensers.toString(),
        'Point-of-Care (Bedside)': _pointOfCareDispensers.toString(),
        'Exam/Procedure Rooms': _examRoomDispensers.toString(),
        'Corridors': _corridorDispensers.toString(),
        'Nursing Stations': _nursingStationDispensers.toString(),
        'Entrances/Exits': _entranceDispensers.toString(),
      },
      benchmark: {
        'Placement Recommendations': _placementRecommendations ?? '',
        'Fire Safety Compliance': _fireSafetyCheck ?? '',
        'Cost Estimate': _costEstimate ?? '',
      },
      references: _references.map((ref) => ref['title']!).toList(),
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exported successfully to Text'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  void _launchURL(String url) async {
    // URL launching handled by platform
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: $url'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Data
  static const List<String> _unitTypeOptions = [
    'Intensive Care Unit (ICU)',
    'Medical Ward',
    'Surgical Ward',
    'Emergency Department',
    'Operating Room',
    'Pediatric Ward',
    'Neonatal ICU (NICU)',
    'Dialysis Unit',
    'Oncology Ward',
    'Outpatient Clinic',
  ];

  static final List<Map<String, String>> _references = [
    {
      'title': 'WHO Guidelines on Hand Hygiene in Health Care (2009) - ABHS Dispenser Placement',
      'url': 'https://www.who.int/publications/i/item/9789241597906',
    },
    {
      'title': 'CDC: Hand Hygiene in Healthcare Settings - Infrastructure Requirements',
      'url': 'https://www.cdc.gov/hand-hygiene/hcp/index.html',
    },
    {
      'title': 'NFPA 101 Life Safety Code (2021) - Section 19.3.2.6',
      'url': 'https://www.nfpa.org/codes-and-standards/all-codes-and-standards/list-of-codes-and-standards/detail?code=101',
    },
  ];

  // Knowledge Panel Data
  static final _knowledgePanelData = KnowledgePanelData(
    definition: 'The Dispenser Placement Optimizer calculates the optimal number and placement of alcohol-based hand sanitizer (ABHS) dispensers '
        'based on WHO and CDC guidelines. Proper dispenser placement is critical for maximizing hand hygiene compliance and ensuring accessibility '
        'at all points of care.',
    formula: 'Total Dispensers = Point-of-Care + Exam Rooms + Corridors + Nursing Stations + Entrances\n\n'
        '• Point-of-Care: 1 dispenser per bed (WHO)\n'
        '• Exam Rooms: 1 dispenser per room entrance\n'
        '• Corridors: 1 dispenser every 10 meters (CDC)\n'
        '• Nursing Stations: 1 dispenser per station\n'
        '• Entrances/Exits: 1 dispenser per entrance/exit',
    example: '**Example: 20-bed ICU**\n\n'
        '**Inputs**:\n'
        '• Unit Type: Intensive Care Unit (ICU)\n'
        '• Number of Beds: 20\n'
        '• Exam/Procedure Rooms: 4\n'
        '• Corridor Length: 50 meters\n'
        '• Nursing Stations: 2\n'
        '• Entrances/Exits: 3\n\n'
        '**Calculation**:\n'
        '• Point-of-Care: 20 dispensers (1 per bed)\n'
        '• Exam Rooms: 4 dispensers (1 per room)\n'
        '• Corridors: 5 dispensers (50m ÷ 10m)\n'
        '• Nursing Stations: 2 dispensers\n'
        '• Entrances/Exits: 3 dispensers\n'
        '• **Total: 34 dispensers**',
    interpretation: '**Placement Guidelines:**\n\n'
        '• **Point-of-Care**: Place dispensers at bedside or door entrance, within 5 steps of patient\n'
        '• **Eye Level**: Install at 120-150 cm from floor for visibility and accessibility\n'
        '• **High-Traffic Areas**: Prioritize areas with frequent HCW movement\n'
        '• **Visibility**: Ensure dispensers are clearly visible and well-lit\n'
        '• **Workflow Integration**: Consider clinical workflow patterns\n\n'
        '**Fire Safety (NFPA 101):**\n'
        '• Maximum 1.2L capacity in corridors\n'
        '• Minimum 1-inch clearance from ignition sources\n'
        '• Maximum 95% alcohol concentration\n'
        '• Wall-mounted preferred over free-standing',
    whenUsed: 'Use this tool during facility design, renovation, or IPC infrastructure audits. '
        'Essential for calculating dispenser requirements for new units, optimizing existing placements, '
        'and ensuring compliance with WHO/CDC guidelines and NFPA 101 fire safety standards. '
        'Ideal for IPC teams, facility managers, and architects.',
    references: [
      Reference(
        title: 'WHO Guidelines on Hand Hygiene in Health Care (2009) - ABHS Dispenser Placement',
        url: 'https://www.who.int/publications/i/item/9789241597906',
      ),
      Reference(
        title: 'CDC: Hand Hygiene in Healthcare Settings - Infrastructure Requirements',
        url: 'https://www.cdc.gov/hand-hygiene/hcp/index.html',
      ),
      Reference(
        title: 'NFPA 101 Life Safety Code (2021) - Section 19.3.2.6',
        url: 'https://www.nfpa.org/codes-and-standards/all-codes-and-standards/list-of-codes-and-standards/detail?code=101',
      ),
    ],
  );
}
