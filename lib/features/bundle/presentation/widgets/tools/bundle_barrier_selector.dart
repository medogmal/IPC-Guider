import 'package:flutter/material.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../data/models/bundle_tool_enums.dart';

/// Multi-select widget for bundle barriers
class BundleBarrierSelector extends StatelessWidget {
  final List<BundleBarrier> selectedBarriers;
  final Function(List<BundleBarrier>) onChanged;
  final String? otherBarrierText;
  final Function(String)? onOtherBarrierChanged;

  const BundleBarrierSelector({
    super.key,
    required this.selectedBarriers,
    required this.onChanged,
    this.otherBarrierText,
    this.onOtherBarrierChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Barriers to Compliance (Select all that apply)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.small),

        // Barrier chips
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: BundleBarrier.values.map((barrier) {
            final isSelected = selectedBarriers.contains(barrier);
            return FilterChip(
              label: Text(barrier.displayName),
              selected: isSelected,
              onSelected: (selected) {
                final newBarriers = List<BundleBarrier>.from(selectedBarriers);
                if (selected) {
                  newBarriers.add(barrier);
                } else {
                  newBarriers.remove(barrier);
                }
                onChanged(newBarriers);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.neutralLight,
                width: isSelected ? 2 : 1,
              ),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),

        // "Other" text field (shown when "Other" is selected)
        if (selectedBarriers.contains(BundleBarrier.other)) ...[
          const SizedBox(height: AppSpacing.medium),
          TextFormField(
            initialValue: otherBarrierText,
            decoration: InputDecoration(
              labelText: 'Please specify other barrier',
              hintText: 'e.g., Cultural barriers, Language barriers',
              prefixIcon: const Icon(Icons.edit_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            maxLength: 200,
            maxLines: 2,
            onChanged: onOtherBarrierChanged,
            validator: (value) {
              if (selectedBarriers.contains(BundleBarrier.other) &&
                  (value == null || value.trim().isEmpty)) {
                return 'Please specify the other barrier';
              }
              return null;
            },
          ),
        ],

        // Helper text
        const SizedBox(height: AppSpacing.small),
        Text(
          'Identifying barriers helps develop targeted interventions',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

