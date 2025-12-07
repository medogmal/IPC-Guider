import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';

/// A card widget that displays available interactive tools for a specific outbreak investigation step.
/// 
/// This widget provides a modern, professional UI for navigating to related interactive tools
/// directly from step screens, improving workflow efficiency for outbreak investigators.
class InteractiveToolsCard extends StatelessWidget {
  final List<InteractiveTool> tools;
  
  const InteractiveToolsCard({
    super.key,
    required this.tools,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show the card if there are no tools
    if (tools.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.touch_app_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Interactive Tools Available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                // Badge showing number of tools
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tools.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tool Buttons
            ...tools.asMap().entries.map((entry) {
              final index = entry.key;
              final tool = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < tools.length - 1 ? 8 : 0,
                ),
                child: _ToolButton(tool: tool),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Individual tool button widget
class _ToolButton extends StatelessWidget {
  final InteractiveTool tool;

  const _ToolButton({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.neutralLight,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(tool.route),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  tool.icon,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tool.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Data model representing an interactive tool
class InteractiveTool {
  final String name;
  final String route;
  final IconData icon;
  
  const InteractiveTool({
    required this.name,
    required this.route,
    required this.icon,
  });
}

