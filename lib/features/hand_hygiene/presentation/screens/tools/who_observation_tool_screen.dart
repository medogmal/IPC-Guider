import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../../../core/widgets/back_button.dart';
import '../../../../../core/widgets/export_modal.dart';
import '../../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../../core/services/unified_export_service.dart';
import '../../../../../features/outbreak/data/repositories/history_repository.dart';
import '../../../../../features/outbreak/data/models/history_entry.dart';

/// WHO 5 Moments Hand Hygiene Observation Tool
/// Digital implementation of WHO Hand Hygiene Observation Tool for real-time compliance monitoring
class WhoObservationToolScreen extends StatefulWidget {
  const WhoObservationToolScreen({super.key});

  @override
  State<WhoObservationToolScreen> createState() => _WhoObservationToolScreenState();
}

class _WhoObservationToolScreenState extends State<WhoObservationToolScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Input controllers
  final _observerNameController = TextEditingController();
  final _dateTimeController = TextEditingController();
  
  // State variables
  String? _selectedUnit;
  String? _selectedHcwRole;
  
  // Observation data: Map<moment, Map<'opportunities' | 'performed' | 'missed', int>>
  final Map<int, Map<String, int>> _observations = {
    1: {'opportunities': 0, 'performed': 0, 'missed': 0},
    2: {'opportunities': 0, 'performed': 0, 'missed': 0},
    3: {'opportunities': 0, 'performed': 0, 'missed': 0},
    4: {'opportunities': 0, 'performed': 0, 'missed': 0},
    5: {'opportunities': 0, 'performed': 0, 'missed': 0},
  };
  
  // Results
  double? _overallCompliance;
  Map<int, double>? _momentCompliances;
  String? _interpretation;
  String? _benchmark;
  String? _action;
  
  // Loading state
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _dateTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
  }

  @override
  void dispose() {
    _observerNameController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackAppBar(
        title: 'WHO 5 Moments Observation',
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

              // Observer Information Card
              _buildObserverInfoCard(),
              const SizedBox(height: AppSpacing.large),

              // Observation Grid Card
              _buildObservationGridCard(),
              const SizedBox(height: AppSpacing.large),

              // Calculate Button
              _buildCalculateButton(),
              
              // Results Section (conditional)
              if (_overallCompliance != null) ...[
                const SizedBox(height: AppSpacing.large),
                _buildResultsCard(),
                const SizedBox(height: AppSpacing.medium),
                _buildMomentComplianceCard(),
                const SizedBox(height: AppSpacing.medium),
                _buildInterpretationSection(),
                const SizedBox(height: AppSpacing.medium),
                _buildBenchmarkSection(),
                if (_action != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  _buildActionSection(),
                ],
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
            AppColors.success,
            AppColors.success.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.4),
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
              Icons.clean_hands_outlined,
              size: 56,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'WHO 5 Moments Observation Tool',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Real-time hand hygiene compliance monitoring',
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
      label: const Text('Quick Guide: WHO 5 Moments'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.success,
        side: BorderSide(color: AppColors.success),
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
      label: const Text('Load Example Observation'),
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

  Widget _buildObserverInfoCard() {
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
                  Icons.person_outline,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  'Observer Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            
            // Observer Name
            TextFormField(
              controller: _observerNameController,
              decoration: InputDecoration(
                labelText: 'Observer Name *',
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter observer name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            
            // Unit/Ward
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              decoration: InputDecoration(
                labelText: 'Unit/Ward *',
                prefixIcon: const Icon(Icons.local_hospital_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              items: _unitOptions.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a unit/ward';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.medium),

            // Date & Time
            TextFormField(
              controller: _dateTimeController,
              decoration: InputDecoration(
                labelText: 'Date & Time *',
                hintText: 'YYYY-MM-DD HH:MM',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              readOnly: true,
              onTap: _selectDateTime,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select date and time';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.medium),

            // Healthcare Worker Role
            DropdownButtonFormField<String>(
              value: _selectedHcwRole,
              decoration: InputDecoration(
                labelText: 'Healthcare Worker Role *',
                prefixIcon: const Icon(Icons.work_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              items: _hcwRoleOptions.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHcwRole = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select HCW role';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationGridCard() {
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
                  Icons.grid_on_outlined,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    'Observation Grid',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Record opportunities and actions for each moment',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.large),

            // Observation Grid
            ..._buildObservationRows(),

            const SizedBox(height: AppSpacing.medium),

            // Total Summary
            _buildTotalSummary(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildObservationRows() {
    final moments = [
      {'id': 1, 'title': 'Before touching patient', 'icon': Icons.person_outline},
      {'id': 2, 'title': 'Before clean/aseptic procedure', 'icon': Icons.medical_services_outlined},
      {'id': 3, 'title': 'After body fluid exposure risk', 'icon': Icons.warning_amber_outlined},
      {'id': 4, 'title': 'After touching patient', 'icon': Icons.person_outline},
      {'id': 5, 'title': 'After touching patient surroundings', 'icon': Icons.chair_outlined},
    ];

    return moments.map((moment) {
      final momentId = moment['id'] as int;
      return Column(
        children: [
          _buildMomentRow(
            momentId: momentId,
            title: moment['title'] as String,
            icon: moment['icon'] as IconData,
          ),
          if (momentId < 5) const SizedBox(height: AppSpacing.medium),
        ],
      );
    }).toList();
  }

  Widget _buildMomentRow({
    required int momentId,
    required String title,
    required IconData icon,
  }) {
    final data = _observations[momentId]!;
    final opportunities = data['opportunities']!;
    final performed = data['performed']!;
    final missed = data['missed']!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: AppSpacing.medium,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Moment Title
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.small,
              vertical: AppSpacing.extraSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: AppColors.success),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    'Moment $momentId: $title',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.medium),

          // Counters Row - reduced spacing for mobile
          Row(
            children: [
              // Opportunities Counter
              Expanded(
                child: _buildCounter(
                  label: 'Opportunities',
                  value: opportunities,
                  color: AppColors.info,
                  onIncrement: () => _incrementCounter(momentId, 'opportunities'),
                  onDecrement: () => _decrementCounter(momentId, 'opportunities'),
                ),
              ),
              const SizedBox(width: 4),

              // Performed Counter
              Expanded(
                child: _buildCounter(
                  label: 'Performed',
                  value: performed,
                  color: AppColors.success,
                  onIncrement: () => _incrementCounter(momentId, 'performed'),
                  onDecrement: () => _decrementCounter(momentId, 'performed'),
                ),
              ),
              const SizedBox(width: 4),

              // Missed Counter
              Expanded(
                child: _buildCounter(
                  label: 'Missed',
                  value: missed,
                  color: AppColors.error,
                  onIncrement: () => _incrementCounter(momentId, 'missed'),
                  onDecrement: () => _decrementCounter(momentId, 'missed'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounter({
    required String label,
    required int value,
    required Color color,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    // Shorten labels for mobile responsiveness
    final shortLabel = label == 'Opportunities'
        ? 'Oppor...'
        : label == 'Performed'
            ? 'Perfor...'
            : label;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label with better mobile sizing
          Text(
            shortLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Counter controls - more compact for mobile
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrement Button - smaller for mobile
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: value > 0 ? onDecrement : null,
                  borderRadius: BorderRadius.circular(6.0),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: value > 0 ? color.withValues(alpha: 0.15) : AppColors.neutralLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: value > 0 ? color.withValues(alpha: 0.2) : AppColors.neutralLight.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.remove_rounded,
                      size: 14,
                      color: value > 0 ? color : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Value Display - flexible width for mobile
              Container(
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: color.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Increment Button - smaller for mobile
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onIncrement,
                  borderRadius: BorderRadius.circular(6.0),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: color.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary() {
    final totalOpportunities = _observations.values.fold<int>(
      0,
      (sum, data) => sum + (data['opportunities'] ?? 0),
    );
    final totalPerformed = _observations.values.fold<int>(
      0,
      (sum, data) => sum + (data['performed'] ?? 0),
    );
    final totalMissed = _observations.values.fold<int>(
      0,
      (sum, data) => sum + (data['missed'] ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Opportunities', totalOpportunities, AppColors.info),
          _buildSummaryItem('Total Performed', totalPerformed, AppColors.success),
          _buildSummaryItem('Total Missed', totalMissed, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int value, Color color) {
    return Flexible(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    final totalOpportunities = _observations.values.fold<int>(
      0,
      (sum, data) => sum + (data['opportunities'] ?? 0),
    );
    final isValid = totalOpportunities > 0;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: isValid && !_isCalculating ? _calculateCompliance : null,
        icon: _isCalculating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.calculate_outlined),
        label: Text(
          _isCalculating ? 'Calculating...' : 'Calculate Compliance',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.success,
          disabledBackgroundColor: AppColors.neutralLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
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
            AppColors.success,
            AppColors.success.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Overall Compliance Rate',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            '${_overallCompliance!.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                  fontSize: 56,
                ),
          ),
          const SizedBox(height: AppSpacing.medium),

          // Context Information
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                _buildContextRow('Observer', _observerNameController.text),
                const SizedBox(height: AppSpacing.small),
                _buildContextRow('Unit/Ward', _selectedUnit ?? 'N/A'),
                const SizedBox(height: AppSpacing.small),
                _buildContextRow('HCW Role', _selectedHcwRole ?? 'N/A'),
                const SizedBox(height: AppSpacing.small),
                _buildContextRow('Date & Time', _dateTimeController.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.surface.withValues(alpha: 0.8),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildMomentComplianceCard() {
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
                  Icons.bar_chart_outlined,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  'Compliance by Moment',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),

            ..._buildMomentComplianceBars(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMomentComplianceBars() {
    final moments = [
      'Before touching patient',
      'Before clean/aseptic procedure',
      'After body fluid exposure risk',
      'After touching patient',
      'After touching patient surroundings',
    ];

    return List.generate(5, (index) {
      final momentId = index + 1;
      final compliance = _momentCompliances![momentId]!;
      final opportunities = _observations[momentId]!['opportunities']!;

      return Column(
        children: [
          _buildComplianceBar(
            label: 'Moment $momentId',
            subtitle: moments[index],
            compliance: compliance,
            opportunities: opportunities,
          ),
          if (index < 4) const SizedBox(height: AppSpacing.medium),
        ],
      );
    });
  }

  Widget _buildComplianceBar({
    required String label,
    required String subtitle,
    required double compliance,
    required int opportunities,
  }) {
    Color barColor;
    if (compliance >= 90) {
      barColor = AppColors.success;
    } else if (compliance >= 70) {
      barColor = AppColors.warning;
    } else {
      barColor = AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '${compliance.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: barColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.small),

        // Progress Bar
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.neutralLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            FractionallySizedBox(
              widthFactor: compliance / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.extraSmall),
        Text(
          '$opportunities opportunities observed',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  Widget _buildInterpretationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Interpretation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _interpretation!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
                Icons.flag_outlined,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Benchmark',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _benchmark!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
                Icons.assignment_outlined,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Recommended Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _action!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
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
              foregroundColor: AppColors.success,
              side: BorderSide(color: AppColors.success),
              padding: const EdgeInsets.symmetric(vertical: 16),
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
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                  'Official References',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            ..._knowledgePanelData.references.map((ref) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
                child: InkWell(
                  onTap: () => _launchURL(ref.url),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.small,
                      horizontal: AppSpacing.small,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: Text(
                            ref.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                        Icon(
                          Icons.open_in_new,
                          size: 14,
                          color: AppColors.textSecondary,
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
  void _incrementCounter(int momentId, String type) {
    setState(() {
      _observations[momentId]![type] = _observations[momentId]![type]! + 1;

      // Auto-sync: opportunities = performed + missed
      if (type == 'performed' || type == 'missed') {
        _observations[momentId]!['opportunities'] =
            _observations[momentId]!['performed']! + _observations[momentId]!['missed']!;
      }
    });
  }

  void _decrementCounter(int momentId, String type) {
    setState(() {
      if (_observations[momentId]![type]! > 0) {
        _observations[momentId]![type] = _observations[momentId]![type]! - 1;

        // Auto-sync: opportunities = performed + missed
        if (type == 'performed' || type == 'missed') {
          _observations[momentId]!['opportunities'] =
              _observations[momentId]!['performed']! + _observations[momentId]!['missed']!;
        }
      }
    });
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        _dateTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
      }
    }
  }

  void _loadExample() {
    setState(() {
      _observerNameController.text = 'Dr. Sarah Johnson';
      _selectedUnit = 'Intensive Care Unit (ICU)';
      _selectedHcwRole = 'Registered Nurse';
      _dateTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      // Example observation data (ICU scenario with good compliance)
      _observations[1] = {'opportunities': 8, 'performed': 7, 'missed': 1};
      _observations[2] = {'opportunities': 5, 'performed': 5, 'missed': 0};
      _observations[3] = {'opportunities': 3, 'performed': 3, 'missed': 0};
      _observations[4] = {'opportunities': 8, 'performed': 7, 'missed': 1};
      _observations[5] = {'opportunities': 6, 'performed': 5, 'missed': 1};
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example observation loaded'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _calculateCompliance() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    // Simulate calculation delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Calculate overall compliance
    final totalOpportunities = _observations.values.fold<int>(
      0,
      (sum, data) => sum + (data['opportunities'] ?? 0),
    );
    final totalPerformed = _observations.values.fold<int>(
      0,
      (sum, data) => sum + (data['performed'] ?? 0),
    );

    final overallCompliance = totalOpportunities > 0
        ? (totalPerformed / totalOpportunities) * 100
        : 0.0;

    // Calculate moment-specific compliance
    final momentCompliances = <int, double>{};
    for (var momentId = 1; momentId <= 5; momentId++) {
      final opportunities = _observations[momentId]!['opportunities']!;
      final performed = _observations[momentId]!['performed']!;
      momentCompliances[momentId] = opportunities > 0
          ? (performed / opportunities) * 100
          : 0.0;
    }

    // Generate interpretation
    String interpretation;
    String? action;
    if (overallCompliance >= 90) {
      interpretation = '✅ **Excellent Hand Hygiene Compliance** (≥90%)\n\n'
          'The observed healthcare worker demonstrates excellent adherence to WHO hand hygiene guidelines. '
          'This level of compliance meets the WHO target and indicates strong infection prevention practices. '
          'Continue to reinforce positive behavior and share best practices with the team.';
      action = null; // No action needed for excellent compliance
    } else if (overallCompliance >= 70) {
      interpretation = '⚠️ **Good Hand Hygiene Compliance** (70-89%)\n\n'
          'The observed healthcare worker shows good adherence to hand hygiene practices, but there is room for improvement. '
          'This level of compliance is above the CDC minimum recommendation (≥80%) but below the WHO target (≥90%). '
          'Focus on identifying and addressing specific moments with lower compliance.';
      action = '**Recommended Actions:**\n\n'
          '1. **Targeted Education**: Provide feedback on specific moments with missed opportunities\n'
          '2. **Barrier Assessment**: Identify and address barriers to compliance (time, accessibility, skin irritation)\n'
          '3. **Positive Reinforcement**: Acknowledge good practices and encourage consistency\n'
          '4. **Peer Observation**: Encourage peer-to-peer observation and feedback\n'
          '5. **Follow-up Audit**: Schedule follow-up observation within 2-4 weeks';
    } else if (overallCompliance >= 50) {
      interpretation = '⚠️ **Fair Hand Hygiene Compliance** (50-69%)\n\n'
          'The observed healthcare worker shows fair adherence to hand hygiene practices, but significant improvement is needed. '
          'This level of compliance is below both WHO and CDC recommendations and indicates a moderate risk for healthcare-associated infections. '
          'Immediate intervention is required to improve compliance.';
      action = '**Immediate Actions Required:**\n\n'
          '1. **Individual Feedback**: Provide immediate, constructive feedback to the healthcare worker\n'
          '2. **Education Session**: Schedule mandatory hand hygiene training\n'
          '3. **Barrier Removal**: Assess and address systemic barriers (dispenser placement, product availability)\n'
          '4. **Supervision**: Increase supervision and observation frequency\n'
          '5. **Unit-Level Intervention**: Implement unit-wide hand hygiene improvement campaign\n'
          '6. **Weekly Audits**: Conduct weekly observations until compliance improves to ≥80%';
    } else {
      interpretation = '🚨 **Poor Hand Hygiene Compliance** (<50%)\n\n'
          'The observed healthcare worker demonstrates poor adherence to hand hygiene practices. '
          'This level of compliance is critically low and poses a significant risk for healthcare-associated infections. '
          'Urgent intervention is required to protect patient safety.';
      action = '**URGENT Actions Required:**\n\n'
          '1. **Immediate Feedback**: Provide immediate, direct feedback to the healthcare worker and their supervisor\n'
          '2. **Mandatory Training**: Require immediate completion of hand hygiene competency training\n'
          '3. **Performance Improvement Plan**: Initiate formal performance improvement process\n'
          '4. **Daily Supervision**: Implement daily direct observation until compliance improves\n'
          '5. **Root Cause Analysis**: Conduct thorough investigation of barriers and contributing factors\n'
          '6. **Unit Assessment**: Evaluate unit-wide compliance and implement comprehensive improvement program\n'
          '7. **Leadership Engagement**: Escalate to unit leadership and infection prevention committee\n'
          '8. **Daily Audits**: Conduct daily observations until compliance reaches ≥70%, then weekly until ≥90%';
    }

    final benchmark = '**WHO Target**: ≥90% compliance\n'
        '**CDC Recommendation**: ≥80% compliance\n\n'
        '**Your Result**: ${overallCompliance.toStringAsFixed(1)}% overall compliance\n\n'
        '**Moment-Specific Benchmarks**:\n'
        '• Moment 1 (Before touching patient): ${momentCompliances[1]!.toStringAsFixed(1)}%\n'
        '• Moment 2 (Before clean/aseptic procedure): ${momentCompliances[2]!.toStringAsFixed(1)}%\n'
        '• Moment 3 (After body fluid exposure): ${momentCompliances[3]!.toStringAsFixed(1)}%\n'
        '• Moment 4 (After touching patient): ${momentCompliances[4]!.toStringAsFixed(1)}%\n'
        '• Moment 5 (After touching surroundings): ${momentCompliances[5]!.toStringAsFixed(1)}%';

    setState(() {
      _overallCompliance = overallCompliance;
      _momentCompliances = momentCompliances;
      _interpretation = interpretation;
      _benchmark = benchmark;
      _action = action;
      _isCalculating = false;
    });
  }

  Future<void> _saveToHistory() async {
    try {
      final historyRepo = HistoryRepository();
      final entry = HistoryEntry.fromCalculator(
        calculatorName: 'WHO 5 Moments Observation Tool',
        inputs: {
          'Observer': _observerNameController.text,
          'Unit/Ward': _selectedUnit ?? 'N/A',
          'HCW Role': _selectedHcwRole ?? 'N/A',
          'Date & Time': _dateTimeController.text,
          'Total Opportunities': _observations.values.fold<int>(0, (sum, data) => sum + (data['opportunities'] ?? 0)).toString(),
          'Total Performed': _observations.values.fold<int>(0, (sum, data) => sum + (data['performed'] ?? 0)).toString(),
          'Total Missed': _observations.values.fold<int>(0, (sum, data) => sum + (data['missed'] ?? 0)).toString(),
        },
        result: '${_overallCompliance!.toStringAsFixed(1)}% compliance',
        tags: ['Hand Hygiene', 'WHO 5 Moments', 'Observation', _selectedUnit ?? 'Unknown Unit'],
      );

      await historyRepo.addEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to history successfully'),
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

  void _showExportOptions() {
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

    // Prepare moment-specific data
    final momentData = <String, String>{};
    for (var i = 1; i <= 5; i++) {
      momentData['Moment $i Compliance'] = '${_momentCompliances![i]!.toStringAsFixed(1)}%';
      momentData['Moment $i Opportunities'] = _observations[i]!['opportunities'].toString();
      momentData['Moment $i Performed'] = _observations[i]!['performed'].toString();
      momentData['Moment $i Missed'] = _observations[i]!['missed'].toString();
    }

    final success = await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'WHO 5 Moments Hand Hygiene Observation Tool',
      formula: 'Compliance Rate = (Actions Performed / Total Opportunities) × 100',
      inputs: {
        'Observer Name': _observerNameController.text,
        'Unit/Ward': _selectedUnit ?? 'N/A',
        'Healthcare Worker Role': _selectedHcwRole ?? 'N/A',
        'Date & Time': _dateTimeController.text,
        'Total Opportunities': _observations.values.fold<int>(0, (sum, data) => sum + (data['opportunities'] ?? 0)).toString(),
        'Total Performed': _observations.values.fold<int>(0, (sum, data) => sum + (data['performed'] ?? 0)).toString(),
        'Total Missed': _observations.values.fold<int>(0, (sum, data) => sum + (data['missed'] ?? 0)).toString(),
        ...momentData,
      },
      results: {
        'Overall Compliance Rate': '${_overallCompliance!.toStringAsFixed(1)}%',
        'Moment 1 Compliance': '${_momentCompliances![1]!.toStringAsFixed(1)}%',
        'Moment 2 Compliance': '${_momentCompliances![2]!.toStringAsFixed(1)}%',
        'Moment 3 Compliance': '${_momentCompliances![3]!.toStringAsFixed(1)}%',
        'Moment 4 Compliance': '${_momentCompliances![4]!.toStringAsFixed(1)}%',
        'Moment 5 Compliance': '${_momentCompliances![5]!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': 'WHO: ≥90%, CDC: ≥80%',
        'unit': '% compliance',
        'source': 'WHO Guidelines on Hand Hygiene in Health Care (2009)',
        'status': _overallCompliance! >= 90 ? 'Excellent' : _overallCompliance! >= 70 ? 'Good' : _overallCompliance! >= 50 ? 'Fair' : 'Poor',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF exported successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exportAsExcel() async {
    Navigator.pop(context);

    // Prepare moment-specific data
    final momentData = <String, String>{};
    for (var i = 1; i <= 5; i++) {
      momentData['Moment $i Compliance'] = '${_momentCompliances![i]!.toStringAsFixed(1)}%';
      momentData['Moment $i Opportunities'] = _observations[i]!['opportunities'].toString();
      momentData['Moment $i Performed'] = _observations[i]!['performed'].toString();
      momentData['Moment $i Missed'] = _observations[i]!['missed'].toString();
    }

    final success = await UnifiedExportService.exportCalculatorAsExcel(
      context: context,
      toolName: 'WHO 5 Moments Hand Hygiene Observation Tool',
      formula: 'Compliance Rate = (Actions Performed / Total Opportunities) × 100',
      inputs: {
        'Observer Name': _observerNameController.text,
        'Unit/Ward': _selectedUnit ?? 'N/A',
        'Healthcare Worker Role': _selectedHcwRole ?? 'N/A',
        'Date & Time': _dateTimeController.text,
        'Total Opportunities': _observations.values.fold<int>(0, (sum, data) => sum + (data['opportunities'] ?? 0)).toString(),
        'Total Performed': _observations.values.fold<int>(0, (sum, data) => sum + (data['performed'] ?? 0)).toString(),
        'Total Missed': _observations.values.fold<int>(0, (sum, data) => sum + (data['missed'] ?? 0)).toString(),
        ...momentData,
      },
      results: {
        'Overall Compliance Rate': '${_overallCompliance!.toStringAsFixed(1)}%',
        'Moment 1 Compliance': '${_momentCompliances![1]!.toStringAsFixed(1)}%',
        'Moment 2 Compliance': '${_momentCompliances![2]!.toStringAsFixed(1)}%',
        'Moment 3 Compliance': '${_momentCompliances![3]!.toStringAsFixed(1)}%',
        'Moment 4 Compliance': '${_momentCompliances![4]!.toStringAsFixed(1)}%',
        'Moment 5 Compliance': '${_momentCompliances![5]!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': 'WHO: ≥90%, CDC: ≥80%',
        'unit': '% compliance',
        'source': 'WHO Guidelines on Hand Hygiene in Health Care (2009)',
        'status': _overallCompliance! >= 90 ? 'Excellent' : _overallCompliance! >= 70 ? 'Good' : _overallCompliance! >= 50 ? 'Fair' : 'Poor',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Excel file exported successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exportAsCSV() async {
    Navigator.pop(context);

    // Prepare moment-specific data
    final momentData = <String, String>{};
    for (var i = 1; i <= 5; i++) {
      momentData['Moment $i Compliance'] = '${_momentCompliances![i]!.toStringAsFixed(1)}%';
      momentData['Moment $i Opportunities'] = _observations[i]!['opportunities'].toString();
      momentData['Moment $i Performed'] = _observations[i]!['performed'].toString();
      momentData['Moment $i Missed'] = _observations[i]!['missed'].toString();
    }

    final success = await UnifiedExportService.exportCalculatorAsCSV(
      context: context,
      toolName: 'WHO 5 Moments Hand Hygiene Observation Tool',
      formula: 'Compliance Rate = (Actions Performed / Total Opportunities) × 100',
      inputs: {
        'Observer Name': _observerNameController.text,
        'Unit/Ward': _selectedUnit ?? 'N/A',
        'Healthcare Worker Role': _selectedHcwRole ?? 'N/A',
        'Date & Time': _dateTimeController.text,
        'Total Opportunities': _observations.values.fold<int>(0, (sum, data) => sum + (data['opportunities'] ?? 0)).toString(),
        'Total Performed': _observations.values.fold<int>(0, (sum, data) => sum + (data['performed'] ?? 0)).toString(),
        'Total Missed': _observations.values.fold<int>(0, (sum, data) => sum + (data['missed'] ?? 0)).toString(),
        ...momentData,
      },
      results: {
        'Overall Compliance Rate': '${_overallCompliance!.toStringAsFixed(1)}%',
        'Moment 1 Compliance': '${_momentCompliances![1]!.toStringAsFixed(1)}%',
        'Moment 2 Compliance': '${_momentCompliances![2]!.toStringAsFixed(1)}%',
        'Moment 3 Compliance': '${_momentCompliances![3]!.toStringAsFixed(1)}%',
        'Moment 4 Compliance': '${_momentCompliances![4]!.toStringAsFixed(1)}%',
        'Moment 5 Compliance': '${_momentCompliances![5]!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': 'WHO: ≥90%, CDC: ≥80%',
        'unit': '% compliance',
        'source': 'WHO Guidelines on Hand Hygiene in Health Care (2009)',
        'status': _overallCompliance! >= 90 ? 'Excellent' : _overallCompliance! >= 70 ? 'Good' : _overallCompliance! >= 50 ? 'Fair' : 'Poor',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('CSV file exported successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exportAsText() async {
    Navigator.pop(context);

    // Prepare moment-specific data
    final momentData = <String, String>{};
    for (var i = 1; i <= 5; i++) {
      momentData['Moment $i Compliance'] = '${_momentCompliances![i]!.toStringAsFixed(1)}%';
      momentData['Moment $i Opportunities'] = _observations[i]!['opportunities'].toString();
      momentData['Moment $i Performed'] = _observations[i]!['performed'].toString();
      momentData['Moment $i Missed'] = _observations[i]!['missed'].toString();
    }

    final success = await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'WHO 5 Moments Hand Hygiene Observation Tool',
      formula: 'Compliance Rate = (Actions Performed / Total Opportunities) × 100',
      inputs: {
        'Observer Name': _observerNameController.text,
        'Unit/Ward': _selectedUnit ?? 'N/A',
        'Healthcare Worker Role': _selectedHcwRole ?? 'N/A',
        'Date & Time': _dateTimeController.text,
        'Total Opportunities': _observations.values.fold<int>(0, (sum, data) => sum + (data['opportunities'] ?? 0)).toString(),
        'Total Performed': _observations.values.fold<int>(0, (sum, data) => sum + (data['performed'] ?? 0)).toString(),
        'Total Missed': _observations.values.fold<int>(0, (sum, data) => sum + (data['missed'] ?? 0)).toString(),
        ...momentData,
      },
      results: {
        'Overall Compliance Rate': '${_overallCompliance!.toStringAsFixed(1)}%',
        'Moment 1 Compliance': '${_momentCompliances![1]!.toStringAsFixed(1)}%',
        'Moment 2 Compliance': '${_momentCompliances![2]!.toStringAsFixed(1)}%',
        'Moment 3 Compliance': '${_momentCompliances![3]!.toStringAsFixed(1)}%',
        'Moment 4 Compliance': '${_momentCompliances![4]!.toStringAsFixed(1)}%',
        'Moment 5 Compliance': '${_momentCompliances![5]!.toStringAsFixed(1)}%',
      },
      benchmark: {
        'target': 'WHO: ≥90%, CDC: ≥80%',
        'unit': '% compliance',
        'source': 'WHO Guidelines on Hand Hygiene in Health Care (2009)',
        'status': _overallCompliance! >= 90 ? 'Excellent' : _overallCompliance! >= 70 ? 'Good' : _overallCompliance! >= 50 ? 'Fair' : 'Poor',
      },
      recommendations: _action,
      interpretation: _interpretation,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Text file exported successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Constants
  static const List<String> _unitOptions = [
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

  static const List<String> _hcwRoleOptions = [
    'Registered Nurse',
    'Physician',
    'Resident/Fellow',
    'Respiratory Therapist',
    'Physical Therapist',
    'Occupational Therapist',
    'Pharmacist',
    'Laboratory Technician',
    'Radiology Technician',
    'Environmental Services',
  ];

  // Knowledge Panel Data
  static final _knowledgePanelData = KnowledgePanelData(
    definition: 'The WHO 5 Moments for Hand Hygiene is a globally recognized framework for hand hygiene compliance monitoring. '
        'It defines five critical moments when healthcare workers should perform hand hygiene to prevent healthcare-associated infections.',
    formula: 'Compliance Rate = (Actions Performed / Total Opportunities) × 100',
    example: '**Example Observation Session:**\n\n'
        '**Setting**: ICU, 30-minute observation of a registered nurse\n\n'
        '**Observations**:\n'
        '• Moment 1 (Before touching patient): 8 opportunities, 7 performed, 1 missed\n'
        '• Moment 2 (Before clean/aseptic procedure): 5 opportunities, 5 performed, 0 missed\n'
        '• Moment 3 (After body fluid exposure): 3 opportunities, 3 performed, 0 missed\n'
        '• Moment 4 (After touching patient): 8 opportunities, 7 performed, 1 missed\n'
        '• Moment 5 (After touching surroundings): 6 opportunities, 5 performed, 1 missed\n\n'
        '**Calculation**:\n'
        '• Total Opportunities: 30\n'
        '• Total Performed: 27\n'
        '• Overall Compliance: (27 / 30) × 100 = 90.0%\n\n'
        '**Interpretation**: Excellent compliance (≥90%), meets WHO target',
    interpretation: '**WHO 5 Moments Explained:**\n\n'
        '**Moment 1 - Before touching a patient**: Protects the patient from harmful germs on your hands\n\n'
        '**Moment 2 - Before clean/aseptic procedure**: Protects the patient from harmful germs, including their own, entering their body\n\n'
        '**Moment 3 - After body fluid exposure risk**: Protects you and the healthcare environment from harmful patient germs\n\n'
        '**Moment 4 - After touching a patient**: Protects you and the healthcare environment from harmful patient germs\n\n'
        '**Moment 5 - After touching patient surroundings**: Protects you and the healthcare environment from harmful patient germs\n\n'
        '**Compliance Benchmarks:**\n'
        '• ≥90%: Excellent (WHO target)\n'
        '• 70-89%: Good (needs improvement)\n'
        '• 50-69%: Fair (requires intervention)\n'
        '• <50%: Poor (urgent action needed)',
    whenUsed: 'Use this tool during clinical rounds to observe healthcare workers and assess hand hygiene compliance. '
        'Conduct observations for 20-30 minutes per session. Record all opportunities and actions for each of the 5 moments. '
        'Ideal for IPC audits, quality improvement initiatives, and staff education.',
    references: [
      Reference(
        title: 'WHO Guidelines on Hand Hygiene in Health Care (2009)',
        url: 'https://www.who.int/publications/i/item/9789241597906',
      ),
      Reference(
        title: 'WHO Hand Hygiene Observation Tool',
        url: 'https://www.who.int/infection-prevention/tools/hand-hygiene/en/',
      ),
      Reference(
        title: 'CDC Hand Hygiene in Healthcare Settings',
        url: 'https://www.cdc.gov/hand-hygiene/hcp/index.html',
      ),
    ],
  );
}
