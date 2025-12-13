import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/knowledge_panel_widget.dart';
import '../../../../core/widgets/export_modal.dart';
import '../../../../core/services/unified_export_service.dart';

class OutbreakTimelineTool extends StatefulWidget {
  const OutbreakTimelineTool({super.key});

  @override
  State<OutbreakTimelineTool> createState() => _OutbreakTimelineToolState();
}

class _OutbreakTimelineToolState extends State<OutbreakTimelineTool> {
  final ScreenshotController _screenshotController = ScreenshotController();

  // Timeline events
  final List<TimelineEvent> _events = [];
  String? _errorMessage;

  // Knowledge Panel Data
  final _knowledgePanelData = const KnowledgePanelData(
    definition: 'Chronological sequence of exposures, onsets, interventions.',
    example: 'Exposure → Symptoms → Isolation → Decline.',
    interpretation: 'Correlates control actions with case reduction.',
    whenUsed: 'Step 10 (evaluation and closure).',
    inputDataType: 'Key dates, event labels (e.g., exposure, onset, action).',
    references: [
      Reference(
        title: 'CDC Outbreak Investigation Timeline',
        url: 'https://www.cdc.gov/eis/field-epi-manual/chapters/Outbreak-Investigation.html',
      ),
      Reference(
        title: 'WHO Outbreak Investigation Toolkit',
        url: 'https://www.who.int/emergencies/outbreak-toolkit/disease-outbreak-toolboxes',
      ),
      Reference(
        title: 'GDIPC Outbreak Manual',
        url: 'https://www.gdipc.org',
      ),
    ],
  );

  // Form controllers for manual input
  final _descriptionController = TextEditingController();
  final _otherEventTypeController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedEventType = 'Case onset';
  
  // Timeline display
  final ScrollController _timelineScrollController = ScrollController();

  final List<String> _eventTypes = [
    'Case onset',
    'Intervention',
    'Lab report',
    'Notification',
    'Control measure',
    'Other'
  ];

  // Event type colors (colorblind-friendly palette)
  final Map<String, Color> _eventColors = {
    'Case onset': const Color(0xFFE53E3E),      // Red
    'Intervention': const Color(0xFF38A169),    // Green
    'Lab report': const Color(0xFFD69E2E),     // Orange
    'Notification': const Color(0xFF3182CE),   // Blue
    'Control measure': const Color(0xFF805AD5), // Purple
    'Other': const Color(0xFF718096),          // Gray
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    _otherEventTypeController.dispose();
    _timelineScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outbreak Timeline'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // Quick Guide Button
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

            // Load Sample Data Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadExample,
                icon: Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
                label: Text(
                  'Load Sample Data',
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

            // Event Input Panel
            _buildEventInputPanel(),
            const SizedBox(height: 20),
            
            // Timeline Chart
            if (_events.isNotEmpty) ...[
              _buildTimelineChart(),
              const SizedBox(height: 20),

              // Summary Panel
              _buildSummaryPanel(),
              const SizedBox(height: 20),

              // Export Buttons
              _buildExportButtons(),
              const SizedBox(height: 20),
            ],

            // Error Message
            if (_errorMessage != null) ...[
              _buildErrorMessage(),
              const SizedBox(height: 20),
            ],

            // Hint for minimum events
            if (_events.isEmpty) ...[
              _buildMinimumEventsHint(),
              const SizedBox(height: 20),
            ],



            // References
            _buildReferences(),
            ],
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.timeline,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outbreak Timeline',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track cases, interventions, and reports across time',
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

  Widget _buildEventInputPanel() {
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
              Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Add Timeline Event',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Picker
          Text(
            'Event Date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate != null
                      ? _formatDate(_selectedDate!)
                      : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Event Type Dropdown
          Text(
            'Event Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedEventType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _eventTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _eventColors[type],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(type),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEventType = value!;
              });
            },
          ),

          // Other Event Type Field (conditional)
          if (_selectedEventType == 'Other') ...[
            const SizedBox(height: 16),
            Text(
              'Specify Event Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _otherEventTypeController,
              decoration: const InputDecoration(
                hintText: 'Enter custom event type',
                border: OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Description Field
          Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Brief description of the event',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          // Add Event Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addEvent,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineChart() {
    if (_events.isEmpty) return const SizedBox.shrink();

    // Sort events by date
    final sortedEvents = List<TimelineEvent>.from(_events)
      ..sort((a, b) => a.date.compareTo(b.date));

    final firstDate = sortedEvents.first.date;
    final lastDate = sortedEvents.last.date;
    final totalDays = lastDate.difference(firstDate).inDays + 1;

    return Screenshot(
      controller: _screenshotController,
      child: Container(
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
                Icon(Icons.timeline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Timeline Chart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_events.length} events',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

          // Timeline Chart
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              controller: _timelineScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: math.max(MediaQuery.of(context).size.width - 72, totalDays * 20.0),
                child: CustomPaint(
                  painter: TimelinePainter(
                    events: sortedEvents,
                    firstDate: firstDate,
                    lastDate: lastDate,
                    eventColors: _eventColors,
                    onEventTap: _showEventDetails,
                  ),
                  child: GestureDetector(
                    onTapDown: (details) {
                      _handleTimelineTap(details, sortedEvents, firstDate, lastDate);
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: _eventTypes.where((type) =>
              _events.any((event) => event.type == type)
            ).map((type) {
              final count = _events.where((event) => event.type == type).length;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _eventColors[type] ?? AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$type ($count)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildSummaryPanel() {
    if (_events.isEmpty) return const SizedBox.shrink();

    // Calculate summary statistics
    final eventCounts = <String, int>{};
    for (final event in _events) {
      eventCounts[event.type] = (eventCounts[event.type] ?? 0) + 1;
    }

    final sortedEvents = List<TimelineEvent>.from(_events)
      ..sort((a, b) => a.date.compareTo(b.date));

    final firstEvent = sortedEvents.first;
    final lastEvent = sortedEvents.last;
    final outbreakDuration = lastEvent.date.difference(firstEvent.date).inDays;

    // Find first case and first intervention
    final firstCase = sortedEvents.where((e) => e.type == 'Case onset').firstOrNull;
    final firstIntervention = sortedEvents.where((e) => e.type == 'Intervention').firstOrNull;

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
              Icon(Icons.insights, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Timeline Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Event counts
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: eventCounts.entries.map((entry) {
              return _buildSummaryItem(
                entry.key,
                '${entry.value} events',
                _eventColors[entry.key]!,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Timeline metrics
          _buildSummaryItem(
            'Outbreak Duration',
            '$outbreakDuration days',
            AppColors.info,
          ),

          const SizedBox(height: 12),

          if (firstCase != null && firstIntervention != null) ...[
            _buildSummaryItem(
              'Response Time',
              '${firstIntervention.date.difference(firstCase.date).inDays} days from first case to intervention',
              AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimumEventsHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add at least one event to generate the timeline chart.',
              style: TextStyle(
                color: AppColors.info,
                fontSize: 14,
              ),
            ),
          ),
        ],
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
              Icon(Icons.library_books, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'References',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildReferenceButton(
                'WHO - Outbreak Investigation Manual',
                'https://www.who.int/emergencies/outbreak-toolkit/disease-outbreak-toolboxes',
              ),
              _buildReferenceButton(
                'CDC - Steps of Outbreak Investigation',
                'https://www.cdc.gov/csels/dsepd/ss1978/lesson2/section2.html',
              ),
              _buildReferenceButton(
                'GDIPC - Reporting and Control Timelines',
                'https://www.gdipc.org',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceButton(String title, String url) {
    return OutlinedButton.icon(
      onPressed: () => _launchURL(url),
      icon: const Icon(Icons.open_in_new, size: 16),
      label: Text(
        title,
        style: const TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // Core logic methods
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _errorMessage = null;
      });
    }
  }

  void _addEvent() {
    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Please select an event date';
      });
      return;
    }

    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an event description';
      });
      return;
    }

    // Validate "Other" event type
    String eventType = _selectedEventType;
    if (_selectedEventType == 'Other') {
      final customType = _otherEventTypeController.text.trim();
      if (customType.isEmpty) {
        setState(() {
          _errorMessage = 'Please specify the custom event type';
        });
        return;
      }
      eventType = customType;
    }

    // Check for duplicate events
    final isDuplicate = _events.any((event) =>
      event.date.isAtSameMomentAs(_selectedDate!) &&
      event.type == eventType &&
      event.description == description
    );

    if (isDuplicate) {
      setState(() {
        _errorMessage = 'This event already exists in the timeline';
      });
      return;
    }

    setState(() {
      _events.add(TimelineEvent(
        date: _selectedDate!,
        type: eventType,
        description: description,
      ));

      // Clear form
      _selectedDate = null;
      _descriptionController.clear();
      _otherEventTypeController.clear();
      _errorMessage = null;
    });
  }



  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleTimelineTap(TapDownDetails details, List<TimelineEvent> sortedEvents,
                         DateTime firstDate, DateTime lastDate) {
    // Calculate which event was tapped based on position
    final totalDays = lastDate.difference(firstDate).inDays + 1;
    final chartWidth = math.max(MediaQuery.of(context).size.width - 72, totalDays * 20.0);
    final tapX = details.localPosition.dx;

    // Find the closest event to the tap position
    TimelineEvent? closestEvent;
    double closestDistance = double.infinity;

    for (final event in sortedEvents) {
      final dayOffset = event.date.difference(firstDate).inDays;
      final eventX = (dayOffset / totalDays) * chartWidth;
      final distance = (tapX - eventX).abs();

      if (distance < closestDistance && distance < 30) { // 30px tap tolerance
        closestDistance = distance;
        closestEvent = event;
      }
    }

    if (closestEvent != null) {
      _showEventDetails(closestEvent);
    }
  }

  void _showEventDetails(TimelineEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _eventColors[event.type],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(event.type),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${_formatDate(event.date)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Description: ${event.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeEvent(event);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _removeEvent(TimelineEvent event) {
    setState(() {
      _events.remove(event);
    });
  }

  Future<void> _saveTimeline() async {
    if (_events.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('timeline_history') ?? [];

      final result = {
        'timestamp': DateTime.now().toIso8601String(),
        'eventCount': _events.length,
        'events': _events.map((e) => {
          'date': e.date.toIso8601String(),
          'type': e.type,
          'description': e.description,
        }).toList(),
      };

      history.add(jsonEncode(result));
      await prefs.setStringList('timeline_history', history);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Timeline saved to history'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildExportButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveTimeline,
            icon: const Icon(Icons.save, size: 20),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showExportModal,
            icon: const Icon(Icons.file_download_outlined, size: 20),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary, width: 2),
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showExportModal() {
    if (_events.isEmpty) return;

    ExportModal.show(
      context: context,
      onExportPDF: _exportAsPDF,
      onExportCSV: _exportAsCSV,
      onExportExcel: _exportAsExcel,
      onExportText: _exportAsText,
      onExportPhoto: _captureAndShareChart,
      enablePhoto: true,
    );
  }



  Future<void> _captureAndShareChart() async {
    try {
      final image = await _screenshotController.capture();

      if (image != null && mounted) {
        final timestamp = DateTime.now();
        final filename = 'ipc_timeline_${timestamp.millisecondsSinceEpoch}.png';

        // Add watermark per EXPORT_STANDARDS.md
        final watermarkedImage = await UnifiedExportService.addWatermarkToScreenshot(
          screenshotBytes: image,
        );

        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : const Rect.fromLTWH(0, 0, 1, 1);
        await Share.shareXFiles(
          [XFile.fromData(watermarkedImage, name: filename, mimeType: 'image/png')],
          text: 'Outbreak Timeline\n'
                'Generated: ${timestamp.toString().split('.')[0]}\n'
                'Total Events: ${_events.length}',
          sharePositionOrigin: origin,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing chart: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportAsCSV() async {
    if (_events.isEmpty) return;

    final timestamp = DateTime.now();
    final filename = 'ipc_timeline_${timestamp.millisecondsSinceEpoch}';

    // Sort events by date for export
    final sortedEvents = List<TimelineEvent>.from(_events)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Create CSV content
    final csvContent = StringBuffer();

    // Header
    csvContent.writeln('Date,Event_Type,Description');

    // Data rows
    for (final event in sortedEvents) {
      final dateStr = '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}-${event.date.day.toString().padLeft(2, '0')}';
      csvContent.writeln('$dateStr,${event.type},"${event.description}"');
    }

    // Export using UnifiedExportService
    await UnifiedExportService.exportAsCSV(
      context: context,
      filename: filename,
      csvContent: csvContent.toString(),
      shareText: 'Outbreak Timeline\nTotal Events: ${_events.length}',
    );
  }

  Future<void> _exportAsExcel() async {
    if (_events.isEmpty) return;

    // Sort events by date for export
    final sortedEvents = List<TimelineEvent>.from(_events)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Prepare data for Excel export
    final headers = ['Date', 'Event Type', 'Description'];
    final data = sortedEvents.map((event) {
      final dateStr = '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}-${event.date.day.toString().padLeft(2, '0')}';
      return [dateStr, event.type, event.description];
    }).toList();

    await UnifiedExportService.exportVisualizationAsExcel(
      context: context,
      toolName: 'Outbreak Timeline',
      headers: headers,
      data: data,
      metadata: {
        'Total Events': _events.length.toString(),
        'Date Range': '${sortedEvents.first.date.year}-${sortedEvents.first.date.month.toString().padLeft(2, '0')}-${sortedEvents.first.date.day.toString().padLeft(2, '0')} to ${sortedEvents.last.date.year}-${sortedEvents.last.date.month.toString().padLeft(2, '0')}-${sortedEvents.last.date.day.toString().padLeft(2, '0')}',
      },
    );
  }

  Future<void> _exportAsPDF() async {
    if (_events.isEmpty) return;

    // Sort events by date for export
    final sortedEvents = List<TimelineEvent>.from(_events)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Prepare inputs and results for PDF
    final inputs = {
      'Total Events': _events.length.toString(),
      'Date Range': '${sortedEvents.first.date.year}-${sortedEvents.first.date.month.toString().padLeft(2, '0')}-${sortedEvents.first.date.day.toString().padLeft(2, '0')} to ${sortedEvents.last.date.year}-${sortedEvents.last.date.month.toString().padLeft(2, '0')}-${sortedEvents.last.date.day.toString().padLeft(2, '0')}',
    };

    final results = <String, dynamic>{};
    for (int i = 0; i < sortedEvents.length; i++) {
      final event = sortedEvents[i];
      final dateStr = '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}-${event.date.day.toString().padLeft(2, '0')}';
      results['Event ${i + 1}'] = '$dateStr - ${event.type}: ${event.description}';
    }

    await UnifiedExportService.exportCalculatorAsPDF(
      context: context,
      toolName: 'Outbreak Timeline',
      inputs: inputs,
      results: results,
      interpretation: 'Timeline of ${_events.length} outbreak-related events',
      references: [
        'WHO Outbreak Investigation Guidelines',
        'https://www.who.int/publications/i/item/9789241519221',
      ],
    );
  }

  Future<void> _exportAsText() async {
    if (_events.isEmpty) return;

    // Sort events by date for export
    final sortedEvents = List<TimelineEvent>.from(_events)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Prepare inputs and results for text export
    final inputs = {
      'Total Events': _events.length.toString(),
      'Date Range': '${sortedEvents.first.date.year}-${sortedEvents.first.date.month.toString().padLeft(2, '0')}-${sortedEvents.first.date.day.toString().padLeft(2, '0')} to ${sortedEvents.last.date.year}-${sortedEvents.last.date.month.toString().padLeft(2, '0')}-${sortedEvents.last.date.day.toString().padLeft(2, '0')}',
    };

    final results = <String, dynamic>{};
    for (int i = 0; i < sortedEvents.length; i++) {
      final event = sortedEvents[i];
      final dateStr = '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}-${event.date.day.toString().padLeft(2, '0')}';
      results['Event ${i + 1}'] = '$dateStr - ${event.type}: ${event.description}';
    }

    await UnifiedExportService.exportCalculatorAsText(
      context: context,
      toolName: 'Outbreak Timeline',
      inputs: inputs,
      results: results,
      interpretation: 'Timeline of ${_events.length} outbreak-related events',
      references: [
        'WHO Outbreak Investigation Guidelines',
        'https://www.who.int/publications/i/item/9789241519221',
      ],
    );
  }

  void _loadExample() {
    setState(() {
      _events.clear();
      _events.addAll([
        TimelineEvent(
          date: DateTime.now().subtract(const Duration(days: 14)),
          type: 'Case onset',
          description: 'First Case Identified - Index case reported with symptoms',
        ),
        TimelineEvent(
          date: DateTime.now().subtract(const Duration(days: 12)),
          type: 'Case onset',
          description: 'Second Case - Staff member developed symptoms',
        ),
        TimelineEvent(
          date: DateTime.now().subtract(const Duration(days: 10)),
          type: 'Notification',
          description: 'Outbreak Declared - Cluster of 5 cases confirmed',
        ),
        TimelineEvent(
          date: DateTime.now().subtract(const Duration(days: 9)),
          type: 'Lab report',
          description: 'Lab Confirmation - Norovirus GII.4 identified',
        ),
        TimelineEvent(
          date: DateTime.now().subtract(const Duration(days: 7)),
          type: 'Intervention',
          description: 'Control Measures Implemented - Enhanced cleaning and isolation protocols',
        ),
        TimelineEvent(
          date: DateTime.now().subtract(const Duration(days: 5)),
          type: 'Control measure',
          description: 'Ward Closure - Affected ward closed to new admissions',
        ),
        TimelineEvent(
          date: DateTime.now().subtract(const Duration(days: 2)),
          type: 'Case onset',
          description: 'Last Case - Final case reported, outbreak declining',
        ),
      ]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Example loaded: Complete Norovirus outbreak timeline (7 events, 14 days)'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.menu_book, color: AppColors.info, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Quick Guide',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.textTertiary.withValues(alpha: 0.2)),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: KnowledgePanelWidget(data: _knowledgePanelData),
                ),
              ),
            ],
          ),
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
}

// Data classes
class TimelineEvent {
  final DateTime date;
  final String type;
  final String description;

  TimelineEvent({
    required this.date,
    required this.type,
    required this.description,
  });
}

// Custom painter for timeline chart
class TimelinePainter extends CustomPainter {
  final List<TimelineEvent> events;
  final DateTime firstDate;
  final DateTime lastDate;
  final Map<String, Color> eventColors;
  final Function(TimelineEvent) onEventTap;

  TimelinePainter({
    required this.events,
    required this.firstDate,
    required this.lastDate,
    required this.eventColors,
    required this.onEventTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw timeline axis
    paint.color = Colors.grey.shade400;
    canvas.drawLine(
      Offset(0, size.height - 40),
      Offset(size.width, size.height - 40),
      paint,
    );

    // Calculate positions
    final totalDays = lastDate.difference(firstDate).inDays + 1;

    // Group events by date to handle overlaps
    final eventsByDate = <DateTime, List<TimelineEvent>>{};
    for (final event in events) {
      final dateKey = DateTime(event.date.year, event.date.month, event.date.day);
      eventsByDate.putIfAbsent(dateKey, () => []).add(event);
    }

    // Draw events
    eventsByDate.forEach((date, eventsOnDate) {
      final dayOffset = date.difference(firstDate).inDays;
      final x = (dayOffset / totalDays) * size.width;

      // Draw vertical line for this date
      paint.color = Colors.grey.shade300;
      canvas.drawLine(
        Offset(x, size.height - 50),
        Offset(x, size.height - 30),
        paint,
      );

      // Draw events with vertical stacking
      for (int i = 0; i < eventsOnDate.length; i++) {
        final event = eventsOnDate[i];
        final y = size.height - 80 - (i * 25);

        // Draw event marker
        paint.style = PaintingStyle.fill;
        paint.color = eventColors[event.type] ?? Colors.grey;
        canvas.drawCircle(Offset(x, y), 8, paint);

        // Draw event type label
        final textPainter = TextPainter(
          text: TextSpan(
            text: event.type.split(' ').first, // First word only
            style: TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 25));
      }

      // Draw date label
      final dateText = '${date.day}/${date.month}';
      final datePainter = TextPainter(
        text: TextSpan(
          text: dateText,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      datePainter.layout();
      datePainter.paint(canvas, Offset(x - datePainter.width / 2, size.height - 20));
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
