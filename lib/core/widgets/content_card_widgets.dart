import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

/// Reusable content card widgets following the Outbreak module design pattern
/// These widgets provide consistent visual hierarchy, spacing, and interaction
/// across all modules while allowing flexible content adaptation

/// Header card with icon, title, subtitle, and description
class ContentHeaderCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;

  const ContentHeaderCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Introduction paragraph card with clean typography
class IntroductionCard extends StatelessWidget {
  final String text;
  final bool isHighlighted;

  const IntroductionCard({
    super.key,
    required this.text,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.info.withValues(alpha: 0.05)  // Blue for highlighted informational content
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(
                color: AppColors.info.withValues(alpha: 0.2),  // Blue border for highlighted content
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          height: 1.7,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Structured content card with icon, heading, and bullet points
class StructuredContentCard extends StatelessWidget {
  final String heading;
  final String content;
  final IconData icon;
  final Color color;

  const StructuredContentCard({
    super.key,
    required this.heading,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
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
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  heading,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content with bullet parsing
          _buildContentWithBullets(content, color),
        ],
      ),
    );
  }

  Widget _buildContentWithBullets(String content, Color accentColor) {
    final items = <String>[];
    
    // Parse numbered list: (1), (2), (3)
    if (content.contains('(1)')) {
      final parts = content.split(RegExp(r'\(\d+\)'));
      for (var part in parts) {
        final trimmed = part.trim();
        if (trimmed.isNotEmpty && trimmed.length > 5) {
          items.add(trimmed);
        }
      }
    }
    // Parse semicolon-separated list
    else if (content.contains(';') && content.split(';').length > 2) {
      items.addAll(
        content.split(';')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e.length > 5)
      );
    }
    // Single paragraph
    else {
      items.add(content);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => _buildBulletItem(item, accentColor)).toList(),
    );
  }

  Widget _buildBulletItem(String text, Color accentColor) {
    // Check for title - description format (separated by dash)
    String? title;
    String? description;
    
    if (text.contains(' - ')) {
      final dashIndex = text.indexOf(' - ');
      title = text.substring(0, dashIndex).trim();
      description = text.substring(dashIndex + 3).trim();
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              Icons.check_circle_outline,
              color: accentColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: title != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

