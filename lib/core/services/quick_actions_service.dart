import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quick_action_item.dart';
import '../design/design_tokens.dart';

/// Service for managing user's quick action preferences
class QuickActionsService {
  static const String _storageKey = 'quick_actions_preferences';
  static const int _maxQuickActions = 6; // Maximum number of quick actions to display

  /// Get all available quick action items across all modules
  static List<QuickActionItem> getAllAvailableActions() {
    return [
      // IPC Calculators
      const QuickActionItem(
        id: 'calculator_hub',
        title: 'IPC Calculators',
        subtitle: 'HAI & IPC metrics',
        route: '/calculator',
        icon: Icons.calculate_outlined,
        color: AppColors.primary,
        category: 'Calculator',
      ),
      const QuickActionItem(
        id: 'clabsi_calculator',
        title: 'CLABSI Calculator',
        subtitle: 'Central line infections',
        route: '/calculator/clabsi',
        icon: Icons.bloodtype_outlined,
        color: AppColors.error,
        category: 'Calculator',
      ),
      const QuickActionItem(
        id: 'cauti_calculator',
        title: 'CAUTI Calculator',
        subtitle: 'Catheter infections',
        route: '/calculator/cauti',
        icon: Icons.water_drop_outlined,
        color: AppColors.info,
        category: 'Calculator',
      ),
      const QuickActionItem(
        id: 'vae_calculator',
        title: 'VAE Calculator',
        subtitle: 'Ventilator events',
        route: '/calculator/vae',
        icon: Icons.air_outlined,
        color: AppColors.primary,
        category: 'Calculator',
      ),

      // Hand Hygiene Tools
      const QuickActionItem(
        id: 'hand_hygiene_hub',
        title: 'Hand Hygiene Tools',
        subtitle: 'Compliance & monitoring',
        route: '/hand-hygiene/tools',
        icon: Icons.clean_hands_outlined,
        color: AppColors.success,
        category: 'Hand Hygiene',
      ),
      const QuickActionItem(
        id: 'who_observation',
        title: 'WHO 5 Moments',
        subtitle: 'Observation tracker',
        route: '/hand-hygiene/tools/who-observation',
        icon: Icons.visibility_outlined,
        color: AppColors.success,
        category: 'Hand Hygiene',
      ),
      const QuickActionItem(
        id: 'product_usage',
        title: 'Product Usage',
        subtitle: 'ABHS consumption',
        route: '/hand-hygiene/tools/product-usage',
        icon: Icons.local_drink_outlined,
        color: AppColors.info,
        category: 'Hand Hygiene',
      ),
      const QuickActionItem(
        id: 'dispenser_placement',
        title: 'Dispenser Placement',
        subtitle: 'Optimal locations',
        route: '/hand-hygiene/tools/dispenser-placement',
        icon: Icons.place_outlined,
        color: AppColors.primary,
        category: 'Hand Hygiene',
      ),

      // Outbreak Management Tools
      const QuickActionItem(
        id: 'outbreak_hub',
        title: 'Outbreak Tools',
        subtitle: 'Detection & response',
        route: '/outbreak',
        icon: Icons.warning_amber_outlined,
        color: AppColors.warning,
        category: 'Outbreak',
      ),
      const QuickActionItem(
        id: 'epidemic_curve',
        title: 'Epidemic Curve',
        subtitle: 'Visualize outbreak',
        route: '/outbreak/analytics/enhanced-epidemic-curve',
        icon: Icons.show_chart_outlined,
        color: AppColors.warning,
        category: 'Outbreak',
      ),
      const QuickActionItem(
        id: 'attack_rate',
        title: 'Attack Rate',
        subtitle: 'Calculate outbreak rate',
        route: '/outbreak/analytics/attack-rate',
        icon: Icons.percent_outlined,
        color: AppColors.error,
        category: 'Outbreak',
      ),
      const QuickActionItem(
        id: 'contact_tracing',
        title: 'Contact Tracing',
        subtitle: 'Track exposures',
        route: '/outbreak/analytics/contact-tracing',
        icon: Icons.people_outline,
        color: AppColors.info,
        category: 'Outbreak',
      ),

      // Bundle Tools
      const QuickActionItem(
        id: 'bundle_hub',
        title: 'Bundle Tools',
        subtitle: 'Compliance tracking',
        route: '/bundles/tools',
        icon: Icons.checklist_outlined,
        color: AppColors.primary,
        category: 'Bundle',
      ),
      const QuickActionItem(
        id: 'bundle_audit',
        title: 'Bundle Audit',
        subtitle: 'Element tracking',
        route: '/bundles/tools/audit',
        icon: Icons.checklist_outlined,
        color: AppColors.primary,
        category: 'Bundle',
      ),
      const QuickActionItem(
        id: 'gap_analysis',
        title: 'Gap Analysis',
        subtitle: 'Root cause analysis',
        route: '/bundles/tools/gap-analysis',
        icon: Icons.analytics_outlined,
        color: AppColors.info,
        category: 'Bundle',
      ),

      // Stewardship Tools
      const QuickActionItem(
        id: 'stewardship_hub',
        title: 'Stewardship Tools',
        subtitle: 'Antimicrobial management',
        route: '/stewardship/tools',
        icon: Icons.medication_outlined,
        color: AppColors.secondary,
        category: 'Stewardship',
      ),
    ];
  }

  /// Get default quick actions (shown when user hasn't customized)
  static List<QuickActionItem> getDefaultQuickActions() {
    final all = getAllAvailableActions();
    return [
      all.firstWhere((a) => a.id == 'calculator_hub'),
      all.firstWhere((a) => a.id == 'outbreak_hub'),
      all.firstWhere((a) => a.id == 'hand_hygiene_hub'),
      all.firstWhere((a) => a.id == 'bundle_hub'),
    ];
  }

  /// Load user's selected quick actions from storage
  static Future<List<QuickActionItem>> loadUserQuickActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return getDefaultQuickActions();
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      final List<QuickActionItem> actions = jsonList
          .map((json) => QuickActionItem.fromJson(json as Map<String, dynamic>))
          .toList();

      // Validate that actions still exist in available actions
      final availableIds = getAllAvailableActions().map((a) => a.id).toSet();
      final validActions = actions.where((a) => availableIds.contains(a.id)).toList();

      if (validActions.isEmpty) {
        return getDefaultQuickActions();
      }

      return validActions;
    } catch (e) {
      debugPrint('Error loading quick actions: $e');
      return getDefaultQuickActions();
    }
  }

  /// Save user's selected quick actions to storage
  static Future<bool> saveUserQuickActions(List<QuickActionItem> actions) async {
    try {
      // Limit to max quick actions
      final limitedActions = actions.take(_maxQuickActions).toList();

      final prefs = await SharedPreferences.getInstance();
      final jsonList = limitedActions.map((a) => a.toJson()).toList();
      final jsonString = json.encode(jsonList);

      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving quick actions: $e');
      return false;
    }
  }

  /// Reset to default quick actions
  static Future<bool> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Error resetting quick actions: $e');
      return false;
    }
  }

  /// Get maximum number of quick actions allowed
  static int get maxQuickActions => _maxQuickActions;

  /// Group available actions by category
  static Map<String, List<QuickActionItem>> getActionsByCategory() {
    final actions = getAllAvailableActions();
    final Map<String, List<QuickActionItem>> grouped = {};

    for (final action in actions) {
      if (!grouped.containsKey(action.category)) {
        grouped[action.category] = [];
      }
      grouped[action.category]!.add(action);
    }

    return grouped;
  }
}

