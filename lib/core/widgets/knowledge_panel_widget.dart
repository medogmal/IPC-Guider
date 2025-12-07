import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

class KnowledgePanelWidget extends StatefulWidget {
  final KnowledgePanelData data;

  const KnowledgePanelWidget({
    super.key,
    required this.data,
  });

  @override
  State<KnowledgePanelWidget> createState() => _KnowledgePanelWidgetState();
}

class _KnowledgePanelWidgetState extends State<KnowledgePanelWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Definition
                  _buildSection(
                    'Definition',
                    widget.data.definition,
                    Icons.description_outlined,
                    AppColors.primary,
                  ),

                  if (widget.data.formula != null) ...[
                    const SizedBox(height: 16),
                    // Formula
                    _buildSection(
                      'Formula',
                      widget.data.formula!,
                      Icons.calculate_outlined,
                      AppColors.secondary,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Example
                  _buildSection(
                    'Example',
                    widget.data.example,
                    Icons.lightbulb_outline,
                    AppColors.warning,
                  ),

                  const SizedBox(height: 16),

                  // Interpretation
                  _buildSection(
                    'Interpretation',
                    widget.data.interpretation,
                    Icons.psychology_outlined,
                    AppColors.success,
                  ),

                  const SizedBox(height: 16),

                  // Indications/Use
                  _buildSection(
                    'Indications/Use',
                    widget.data.whenUsed,
                    Icons.timeline_outlined,
                    AppColors.info,
                  ),

                  if (widget.data.inputDataType != null) ...[
                    const SizedBox(height: 16),
                    // Input Data Type
                    _buildSection(
                      'Input Data Type',
                      widget.data.inputDataType!,
                      Icons.input_outlined,
                      AppColors.protective,
                    ),
                  ],

                  // Note: References removed from Quick Guide modal
                  // References are now only displayed at the end of each tool page
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // References section removed - now only displayed at end of tool pages
}

class KnowledgePanelData {
  final String definition;
  final String? formula;
  final String example;
  final String interpretation;
  final String whenUsed;
  final String? inputDataType;
  final List<Reference> references; // Required - but not displayed in Quick Guide modal

  const KnowledgePanelData({
    required this.definition,
    this.formula,
    required this.example,
    required this.interpretation,
    required this.whenUsed,
    this.inputDataType,
    required this.references, // Required parameter
  });
}

class Reference {
  final String title;
  final String url;

  const Reference({
    required this.title,
    required this.url,
  });
}