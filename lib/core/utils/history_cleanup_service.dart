import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service to clean up old history storage from SharedPreferences
/// This is a one-time cleanup before migrating to unified history system
class HistoryCleanupService {
  /// List of all old SharedPreferences keys used for history storage
  static const List<String> _oldHistoryKeys = [
    // Calculator module keys
    'calculator_history', // Generic calculator history
    'clabsi_history',
    'cauti_history',
    'SSI_history',
    'vae_history',
    'blood_culture_contamination_history',
    'sick_leave_rate_history',
    'nsi_rate_history',
    'pep_percentage_history',
    'tat_compliance_history',
    'rejection_rate_history',
    'appropriate_specimen_history',
    'ddd_history',
    'dur_history',
    'colonization_pressure_history',
    'mdro_incidence_history',
    'antibiotic_utilization_history',
    'dot_history',
    'culture_guided_therapy_history',
    'deescalation_rate_history',
    'bundle_compliance_history',
    'infection_reduction_history',
    'ipc_audit_score_history',
    'isolation_compliance_history',
    'observation_compliance_history',
    'screening_yield_history',
    'vaccination_coverage_history',
    'environmental_positivity_rate_history',
    'disinfection_compliance_history',
    'sterilization_failure_rate_history',
    
    // Outbreak module keys
    'analytics_history',
    'sensitivity_specificity_history',
    'sample_size_history',
    'p_value_history',
    'disinfectant_selection_history',
    'risk_assessment_history',
    'epicurve_history',
    'comparison_history',
    'histogram_history',
    'timeline_history',
    'control_checklist_entries',
    'case_definition_history',
    'contact_tracing_index_case',
    'contact_tracing_contacts',
    
    // Mode preferences (not critical but good to clean)
    'enhanced_epi_curve_advanced_mode',
    'histogram_advanced_mode',
    'comparison_advanced_mode',
  ];

  /// Clean up all old history keys from SharedPreferences
  /// Returns the number of keys successfully removed
  static Future<int> cleanupAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int removedCount = 0;

      for (final key in _oldHistoryKeys) {
        if (prefs.containsKey(key)) {
          final success = await prefs.remove(key);
          if (success) {
            removedCount++;
            debugPrint('✅ Removed old history key: $key');
          } else {
            debugPrint('⚠️ Failed to remove key: $key');
          }
        }
      }

      // Mark cleanup as complete
      await prefs.setBool('history_cleanup_completed', true);
      await prefs.setString('history_cleanup_date', DateTime.now().toIso8601String());

      debugPrint('🎉 History cleanup complete! Removed $removedCount keys.');
      return removedCount;
    } catch (e) {
      debugPrint('❌ Error during history cleanup: $e');
      return 0;
    }
  }

  /// Check if cleanup has already been performed
  static Future<bool> isCleanupCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('history_cleanup_completed') ?? false;
    } catch (e) {
      debugPrint('Error checking cleanup status: $e');
      return false;
    }
  }

  /// Get the date when cleanup was performed
  static Future<DateTime?> getCleanupDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString('history_cleanup_date');
      if (dateString != null) {
        return DateTime.parse(dateString);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting cleanup date: $e');
      return null;
    }
  }

  /// Get count of old history keys that still exist
  static Future<int> getOldHistoryKeysCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int count = 0;

      for (final key in _oldHistoryKeys) {
        if (prefs.containsKey(key)) {
          count++;
        }
      }

      return count;
    } catch (e) {
      debugPrint('Error counting old history keys: $e');
      return 0;
    }
  }

  /// Get list of old history keys that still exist
  static Future<List<String>> getExistingOldHistoryKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingKeys = <String>[];

      for (final key in _oldHistoryKeys) {
        if (prefs.containsKey(key)) {
          existingKeys.add(key);
        }
      }

      return existingKeys;
    } catch (e) {
      debugPrint('Error getting existing old history keys: $e');
      return [];
    }
  }

  /// Reset cleanup flag (for testing purposes)
  static Future<void> resetCleanupFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('history_cleanup_completed');
      await prefs.remove('history_cleanup_date');
      debugPrint('Cleanup flag reset');
    } catch (e) {
      debugPrint('Error resetting cleanup flag: $e');
    }
  }

  /// Get detailed report of old history storage
  static Future<Map<String, dynamic>> getCleanupReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final report = <String, dynamic>{};
      
      report['cleanupCompleted'] = await isCleanupCompleted();
      report['cleanupDate'] = await getCleanupDate();
      report['oldKeysCount'] = await getOldHistoryKeysCount();
      report['existingKeys'] = await getExistingOldHistoryKeys();
      
      // Calculate total entries across all old keys
      int totalEntries = 0;
      for (final key in _oldHistoryKeys) {
        if (prefs.containsKey(key)) {
          final value = prefs.get(key);
          if (value is List) {
            totalEntries += value.length;
          }
        }
      }
      report['totalOldEntries'] = totalEntries;

      return report;
    } catch (e) {
      debugPrint('Error generating cleanup report: $e');
      return {};
    }
  }
}

