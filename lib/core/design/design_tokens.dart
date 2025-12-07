import 'package:flutter/material.dart';

class AppColors {
  // Professional Medical App Color Palette - Light Theme

  // Primary Colors - Muted Medical Blues/Teals
  static const primary = Color(0xFF4A90A4);        // Muted teal-blue
  static const primaryLight = Color(0xFF7BB3C7);   // Light teal
  static const primaryDark = Color(0xFF2C5F6F);    // Dark teal

  // Secondary Colors - Muted Greys
  static const secondary = Color(0xFF6B7280);      // Professional grey
  static const secondaryLight = Color(0xFF9CA3AF); // Light grey
  static const secondaryDark = Color(0xFF374151);  // Dark grey

  // Background Colors
  static const background = Color(0xFFF8FAFC);     // Very light blue-grey
  static const surface = Color(0xFFFFFFFF);        // Pure white
  static const surfaceVariant = Color(0xFFF1F5F9); // Light grey-blue

  // Text Colors
  static const textPrimary = Color(0xFF1E293B);    // Dark slate
  static const textSecondary = Color(0xFF64748B);  // Medium slate
  static const textTertiary = Color(0xFF94A3B8);   // Light slate

  // Status Colors - Muted Medical Palette
  static const success = Color(0xFF059669);        // Muted green
  static const successLight = Color(0xFFD1FAE5);   // Light green background
  static const warning = Color(0xFFD97706);        // Muted amber
  static const warningLight = Color(0xFFFEF3C7);   // Light amber background
  static const error = Color(0xFFDC2626);          // Muted red
  static const errorLight = Color(0xFFFEE2E2);     // Light red background
  static const info = Color(0xFF2563EB);           // Muted blue
  static const infoLight = Color(0xFFDBEAFE);      // Light blue background

  // Isolation Precaution Colors - Muted Medical Standards
  static const airborne = Color(0xFF3B82F6);      // Muted blue
  static const droplet = Color(0xFF10B981);       // Muted emerald
  static const contact = Color(0xFFEF4444);       // Muted red
  static const enteric = Color(0xFFF59E0B);       // Muted amber
  static const protective = Color(0xFF8B5CF6);    // Muted purple

  // Interactive Tools Border - Golden Gradient
  static const interactiveBorderLight = Color(0xFFFBBF24);  // Light golden yellow
  static const interactiveBorderDark = Color(0xFFD97706);   // Deep golden amber

  // Legacy interactive color (kept for backward compatibility, but prefer primary for icons/text)
  static const interactive = Color(0xFF4A90A4);        // Use primary instead
  static const interactiveLight = Color(0xFFEDE9FE);   // Light purple background (deprecated)
  static const interactiveDark = Color(0xFF5B21B6);    // Dark purple (deprecated)
  static const interactiveGradientStart = Color(0xFF8B5CF6);  // Lighter purple for gradient (deprecated)
  static const interactiveGradientEnd = Color(0xFF6D28D9);    // Deeper purple for gradient (deprecated)

  // Neutral Colors
  static const neutralDark = Color(0xFF0F172A);
  static const neutral = Color(0xFF64748B);
  static const neutralLight = Color(0xFFE2E8F0);
  static const neutralLighter = Color(0xFFF1F5F9);
}

/// AMS (Antimicrobial Stewardship) Module-Specific Semantic Colors
///
/// This class provides semantic color aliases specifically for the AMS module,
/// ensuring consistent and meaningful color usage across all stewardship content.
///
/// **Usage Guidelines**:
/// - Use these semantic aliases instead of generic AppColors when the meaning is clear
/// - Follow the AMS Color Style Guide (docs/AMS_COLOR_STYLE_GUIDE.md)
/// - Never use hardcoded Color(0xFFXXXXXX) values in AMS screens
///
/// **Color Meanings**:
/// - Red (error): Critical resistance mechanisms, warnings, priority pathogens
/// - Amber (warning): Cautions, special considerations, timing issues
/// - Green (success): Best practices, quality control, susceptibility
/// - Blue (info): Laboratory standards, guidelines, references
/// - Teal (primary): General clinical content, definitions, mechanisms
class AMSColors {
  // Resistance & Microbiology
  /// Color for resistance mechanisms (ESBL, carbapenemase, AmpC, etc.)
  static const resistance = AppColors.error;           // Red

  /// Color for susceptibility patterns and effective therapies
  static const susceptibility = AppColors.success;     // Green

  /// Color for laboratory standards, testing methods, and AST procedures
  static const laboratory = AppColors.info;            // Blue

  // Clinical & Stewardship
  /// Color for general clinical concepts, definitions, and mechanisms
  static const clinical = AppColors.primary;           // Teal

  /// Color for stewardship interventions and strategies
  static const stewardship = AppColors.info;           // Blue

  /// Color for best practices and evidence-based recommendations
  static const bestPractice = AppColors.success;       // Green

  // Warnings & Cautions
  /// Color for critical warnings, common errors, and safety concerns
  static const critical = AppColors.error;             // Red

  /// Color for cautions, special considerations, and timing issues
  static const caution = AppColors.warning;            // Amber

  // Organisms & Pathogens
  /// Color for priority pathogens and multidrug-resistant organisms (MDROs)
  static const pathogen = AppColors.error;             // Red

  /// Color for general organism characteristics and classifications
  static const organism = AppColors.primary;           // Teal

  // Documentation & References
  /// Color for guidelines, standards (CLSI, EUCAST, CDC, IDSA, WHO)
  static const guideline = AppColors.info;             // Blue

  /// Color for references, citations, and external documentation
  static const reference = AppColors.info;             // Blue
}

// Convenience: map isolation type string to a color token
extension IsolationTypeColor on String {
  Color get isolationColor {
    switch (this) {
      case 'Airborne':
        return AppColors.airborne;
      case 'Droplet':
        return AppColors.droplet;
      case 'Contact':
        return AppColors.contact;
      case 'Contact-Enteric':
        return AppColors.enteric;
      case 'Protective':
        return AppColors.protective;
      default:
        return AppColors.neutral;
    }
  }
}

class AppSpacing {
  static const double extraSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
}

// Professional medical status colors helper
class MedicalColors {
  static const success = AppColors.success;
  static const successBackground = AppColors.successLight;
  static const warning = AppColors.warning;
  static const warningBackground = AppColors.warningLight;
  static const error = AppColors.error;
  static const errorBackground = AppColors.errorLight;
  static const info = AppColors.info;
  static const infoBackground = AppColors.infoLight;

  // Get appropriate text color for background
  static Color getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColors.textPrimary : Colors.white;
  }

  // Get muted version of any color
  static Color getMutedColor(Color color, {double opacity = 0.1}) {
    return color.withValues(alpha: opacity);
  }
}
