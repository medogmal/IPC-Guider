import 'package:flutter/material.dart';

/// Bundle category enum for filtering and organization
enum BundleCategory {
  all,
  vap,
  clabsi,
  cauti,
  ssi,
  mdro,
  general;

  /// Get display name for the category
  String get displayName {
    switch (this) {
      case BundleCategory.all:
        return 'All';
      case BundleCategory.vap:
        return 'VAP';
      case BundleCategory.clabsi:
        return 'CLABSI';
      case BundleCategory.cauti:
        return 'CAUTI';
      case BundleCategory.ssi:
        return 'SSI';
      case BundleCategory.mdro:
        return 'MDRO';
      case BundleCategory.general:
        return 'General';
    }
  }

  /// Get full name for the category
  String get fullName {
    switch (this) {
      case BundleCategory.all:
        return 'All Bundles';
      case BundleCategory.vap:
        return 'Ventilator-Associated Pneumonia';
      case BundleCategory.clabsi:
        return 'Central Line-Associated Bloodstream Infection';
      case BundleCategory.cauti:
        return 'Catheter-Associated Urinary Tract Infection';
      case BundleCategory.ssi:
        return 'Surgical Site Infection';
      case BundleCategory.mdro:
        return 'Multidrug-Resistant Organisms';
      case BundleCategory.general:
        return 'General IPC Bundles';
    }
  }

  /// Get color for the category (muted modern palette)
  Color get color {
    switch (this) {
      case BundleCategory.all:
        return const Color(0xFF9E9E9E); // Muted grey
      case BundleCategory.vap:
        return const Color(0xFF4DB6AC); // Muted teal (Respiratory)
      case BundleCategory.clabsi:
        return const Color(0xFFE57373); // Muted red/coral (Bloodstream)
      case BundleCategory.cauti:
        return const Color(0xFF64B5F6); // Muted blue (Urinary)
      case BundleCategory.ssi:
        return const Color(0xFFFFB74D); // Muted amber (Surgical)
      case BundleCategory.mdro:
        return const Color(0xFF81C784); // Muted green (MDRO)
      case BundleCategory.general:
        return const Color(0xFFBA68C8); // Muted purple (Universal)
    }
  }

  /// Get icon for the category
  IconData get icon {
    switch (this) {
      case BundleCategory.all:
        return Icons.grid_view;
      case BundleCategory.vap:
        return Icons.air; // Respiratory/ventilator
      case BundleCategory.clabsi:
        return Icons.bloodtype; // Bloodstream
      case BundleCategory.cauti:
        return Icons.water_drop; // Urinary
      case BundleCategory.ssi:
        return Icons.healing; // Surgical
      case BundleCategory.mdro:
        return Icons.shield_outlined; // MDRO protection
      case BundleCategory.general:
        return Icons.medical_services; // General medical
    }
  }

  /// Parse category from string (case-insensitive)
  static BundleCategory fromString(String value) {
    final lowerValue = value.toLowerCase().trim();
    switch (lowerValue) {
      case 'vap':
        return BundleCategory.vap;
      case 'clabsi':
        return BundleCategory.clabsi;
      case 'cauti':
        return BundleCategory.cauti;
      case 'ssi':
        return BundleCategory.ssi;
      case 'mdro':
        return BundleCategory.mdro;
      case 'general':
        return BundleCategory.general;
      default:
        return BundleCategory.general;
    }
  }

  /// Convert to string for JSON
  String toJsonString() {
    switch (this) {
      case BundleCategory.all:
        return 'all';
      case BundleCategory.vap:
        return 'VAP';
      case BundleCategory.clabsi:
        return 'CLABSI';
      case BundleCategory.cauti:
        return 'CAUTI';
      case BundleCategory.ssi:
        return 'SSI';
      case BundleCategory.mdro:
        return 'MDRO';
      case BundleCategory.general:
        return 'General';
    }
  }
}

