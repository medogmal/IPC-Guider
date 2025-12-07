import 'package:flutter/material.dart';
import 'cds_condition.dart';

/// Category model for Clinical Decision Support
class CDSCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<CDSCondition> conditions;

  const CDSCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.conditions = const [],
  });

  factory CDSCategory.fromJson(Map<String, dynamic> json) {
    return CDSCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: _parseIcon(json['icon'] as String?),
      color: _parseColor(json['color'] as String?),
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((cond) => CDSCondition.fromJson(cond as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': _iconToString(icon),
      'color': '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      'conditions': conditions.map((cond) => cond.toJson()).toList(),
    };
  }

  static IconData _parseIcon(String? iconName) {
    switch (iconName) {
      case 'air':
        return Icons.air;
      case 'face':
        return Icons.face;
      case 'water_drop':
        return Icons.water_drop;
      case 'favorite':
        return Icons.favorite;
      case 'healing':
        return Icons.healing;
      case 'restaurant':
        return Icons.restaurant;
      case 'coronavirus':
        return Icons.coronavirus;
      case 'bloodtype':
        return Icons.bloodtype;
      case 'psychology':
        return Icons.psychology;
      case 'accessibility':
        return Icons.accessibility;
      case 'visibility':
        return Icons.visibility;
      case 'thermostat':
        return Icons.thermostat;
      case 'flight':
        return Icons.flight;
      case 'medical_services':
        return Icons.medical_services;
      default:
        return Icons.medical_information;
    }
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.air) return 'air';
    if (icon == Icons.face) return 'face';
    if (icon == Icons.water_drop) return 'water_drop';
    if (icon == Icons.favorite) return 'favorite';
    if (icon == Icons.healing) return 'healing';
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.coronavirus) return 'coronavirus';
    if (icon == Icons.bloodtype) return 'bloodtype';
    if (icon == Icons.psychology) return 'psychology';
    if (icon == Icons.accessibility) return 'accessibility';
    if (icon == Icons.visibility) return 'visibility';
    if (icon == Icons.thermostat) return 'thermostat';
    if (icon == Icons.flight) return 'flight';
    if (icon == Icons.medical_services) return 'medical_services';
    return 'medical_information';
  }

  static Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return const Color(0xFF2196F3);
    }
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

