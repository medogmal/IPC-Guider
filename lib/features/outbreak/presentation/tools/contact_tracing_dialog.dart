import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';

// Contact dialog helper methods
class ContactTracingDialog {
  static Future<Map<String, dynamic>?> showAddContactDialog({
    required BuildContext context,
    Map<String, dynamic>? existingContact,
  }) async {
    // Controllers
    final nameController = TextEditingController(text: existingContact?['contactName'] ?? '');
    final idController = TextEditingController(text: existingContact?['contactId'] ?? '');
    final phoneController = TextEditingController(text: existingContact?['contactPhone'] ?? '');
    final locationController = TextEditingController(text: existingContact?['exposureLocation'] ?? '');
    final notesController = TextEditingController(text: existingContact?['notes'] ?? '');

    // State variables
    String contactType = existingContact?['contactType'] as String? ?? 'Close Contact';
    DateTime? exposureDate = existingContact != null
        ? DateTime.parse(existingContact['exposureDate'] as String)
        : null;
    String duration = existingContact?['exposureDuration'] as String? ?? '15-60 min';
    String distance = existingContact?['distance'] as String? ?? '1-2 meters';
    List<String> ppeUsed = existingContact != null && existingContact['ppeUsed'] != null
        ? List<String>.from(existingContact['ppeUsed'] as List)
        : [];
    String monitoringStatus = existingContact?['monitoringStatus'] as String? ?? 'Active';
    bool symptomDeveloped = existingContact?['symptomDeveloped'] as bool? ?? false;
    DateTime? testDate = existingContact != null && existingContact['testDate'] != null
        ? DateTime.parse(existingContact['testDate'] as String)
        : null;
    String testResult = existingContact?['testResult'] as String? ?? '';

    final contactTypes = ['Household', 'Healthcare', 'Close Contact', 'Casual Contact'];
    final durations = ['<15 min', '15-60 min', '1-4 hours', '>4 hours'];
    final distances = ['<1 meter', '1-2 meters', '>2 meters'];
    final ppeOptions = ['Mask', 'Gloves', 'Gown', 'Face Shield', 'None'];
    final monitoringStatuses = ['Active', 'Completed', 'Lost to Follow-up'];

    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.person_add, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            existingContact == null ? 'Add Contact' : 'Edit Contact',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Form content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Contact Details
                          _buildSectionHeader('Contact Details', Icons.person_outline),
                          const SizedBox(height: 12),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Contact Name *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.badge_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: idController,
                            decoration: InputDecoration(
                              labelText: 'Contact ID (optional)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.numbers),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone (optional)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.phone_outlined),
                            ),
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 24),

                          // Section 2: Exposure Details
                          _buildSectionHeader('Exposure Details', Icons.coronavirus_outlined),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: contactType,
                            decoration: InputDecoration(
                              labelText: 'Contact Type *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.category_outlined),
                            ),
                            items: contactTypes.map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            )).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => contactType = value);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: exposureDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => exposureDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Exposure Date *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                exposureDate != null
                                    ? '${exposureDate!.year}-${exposureDate!.month.toString().padLeft(2, '0')}-${exposureDate!.day.toString().padLeft(2, '0')}'
                                    : 'Select date',
                                style: TextStyle(
                                  color: exposureDate != null ? AppColors.textPrimary : AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: locationController,
                            decoration: InputDecoration(
                              labelText: 'Exposure Location *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: duration,
                            decoration: InputDecoration(
                              labelText: 'Exposure Duration *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.timer_outlined),
                            ),
                            items: durations.map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d),
                            )).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => duration = value);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: distance,
                            decoration: InputDecoration(
                              labelText: 'Distance *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.social_distance_outlined),
                            ),
                            items: distances.map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d),
                            )).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => distance = value);
                              }
                            },
                          ),

                          const SizedBox(height: 24),

                          // Section 3: PPE Used
                          _buildSectionHeader('PPE Used', Icons.shield_outlined),
                          const SizedBox(height: 8),
                          ...ppeOptions.map((ppe) => CheckboxListTile(
                            title: Text(ppe),
                            value: ppeUsed.contains(ppe),
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  if (ppe == 'None') {
                                    ppeUsed = ['None'];
                                  } else {
                                    ppeUsed.remove('None');
                                    ppeUsed.add(ppe);
                                  }
                                } else {
                                  ppeUsed.remove(ppe);
                                }
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          )),

                          const SizedBox(height: 16),

                          // Risk Level Display (Auto-calculated)
                          _buildRiskLevelDisplay(
                            _calculateRiskLevel(contactType, duration, distance, ppeUsed),
                          ),

                          const SizedBox(height: 24),

                          // Section 4: Follow-up (Optional)
                          _buildSectionHeader('Follow-up (Optional)', Icons.medical_services_outlined),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: monitoringStatus,
                            decoration: InputDecoration(
                              labelText: 'Monitoring Status',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.monitor_heart_outlined),
                            ),
                            items: monitoringStatuses.map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            )).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => monitoringStatus = value);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            title: const Text('Symptoms Developed?'),
                            value: symptomDeveloped,
                            onChanged: (value) {
                              setState(() => symptomDeveloped = value);
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: notesController,
                            decoration: InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.note_outlined),
                            ),
                            maxLines: 3,
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Action buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textSecondary.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Validation
                              if (nameController.text.trim().isEmpty ||
                                  exposureDate == null ||
                                  locationController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill all required fields'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              if (ppeUsed.isEmpty) {
                                ppeUsed = ['None'];
                              }

                              // Calculate risk level
                              final riskLevel = _calculateRiskLevel(contactType, duration, distance, ppeUsed);

                              // Create contact data
                              final contactData = {
                                'id': existingContact?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                'contactName': nameController.text.trim(),
                                'contactId': idController.text.trim(),
                                'contactPhone': phoneController.text.trim(),
                                'contactType': contactType,
                                'exposureDate': exposureDate!.toIso8601String(),
                                'exposureLocation': locationController.text.trim(),
                                'exposureDuration': duration,
                                'distance': distance,
                                'ppeUsed': ppeUsed,
                                'riskLevel': riskLevel,
                                'monitoringStatus': monitoringStatus,
                                'symptomDeveloped': symptomDeveloped,
                                'testDate': testDate?.toIso8601String(),
                                'testResult': testResult,
                                'notes': notesController.text.trim(),
                              };

                              Navigator.pop(context, contactData);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(existingContact == null ? 'Add Contact' : 'Update Contact'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
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

  static Widget _buildRiskLevelDisplay(String riskLevel) {
    Color color;
    IconData icon;
    
    switch (riskLevel) {
      case 'High':
        color = AppColors.error;
        icon = Icons.warning;
        break;
      case 'Medium':
        color = AppColors.warning;
        icon = Icons.info_outline;
        break;
      case 'Low':
        color = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      default:
        color = AppColors.neutral;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk Level: $riskLevel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Auto-calculated based on exposure factors',
                  style: TextStyle(
                    fontSize: 12,
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

  static String _calculateRiskLevel(String contactType, String duration, String distance, List<String> ppeUsed) {
    int riskScore = 0;

    // Contact type scoring
    if (contactType == 'Household') {
      riskScore += 3;
    } else if (contactType == 'Healthcare') {
      riskScore += 2;
    } else if (contactType == 'Close Contact') {
      riskScore += 2;
    } else if (contactType == 'Casual Contact') {
      riskScore += 1;
    }

    // Duration scoring
    if (duration == '>4 hours') {
      riskScore += 3;
    } else if (duration == '1-4 hours') {
      riskScore += 2;
    } else if (duration == '15-60 min') {
      riskScore += 1;
    }

    // Distance scoring
    if (distance == '<1 meter') {
      riskScore += 2;
    } else if (distance == '1-2 meters') {
      riskScore += 1;
    }

    // PPE scoring (protective)
    if (ppeUsed.contains('None')) {
      riskScore += 2;
    } else {
      if (ppeUsed.contains('Mask') && ppeUsed.contains('Gown')) {
        riskScore -= 2;
      } else if (ppeUsed.contains('Mask')) {
        riskScore -= 1;
      }
    }

    // Risk level determination
    if (riskScore >= 6) {
      return 'High';
    }
    if (riskScore >= 3) {
      return 'Medium';
    }
    return 'Low';
  }
}

