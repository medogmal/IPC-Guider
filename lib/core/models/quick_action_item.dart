import 'package:flutter/material.dart';

/// Model representing a quick action item that can be displayed on the home screen
class QuickActionItem {
  final String id;
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;
  final String category; // e.g., 'Hand Hygiene', 'Outbreak', 'Calculator', etc.
  final bool isEnabled;

  const QuickActionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.color,
    required this.category,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'route': route,
      'icon': icon.codePoint,
      'color': color.value,
      'category': category,
      'isEnabled': isEnabled,
    };
  }

  factory QuickActionItem.fromJson(Map<String, dynamic> json) {
    return QuickActionItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      route: json['route'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      category: json['category'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  QuickActionItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? route,
    IconData? icon,
    Color? color,
    String? category,
    bool? isEnabled,
  }) {
    return QuickActionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      route: route ?? this.route,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuickActionItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

