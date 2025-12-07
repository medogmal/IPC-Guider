import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/models/quick_action_item.dart';
import '../../../core/services/quick_actions_service.dart';
import '../../../core/widgets/back_button.dart';

class QuickActionsSettingsScreen extends StatefulWidget {
  const QuickActionsSettingsScreen({super.key});

  @override
  State<QuickActionsSettingsScreen> createState() => _QuickActionsSettingsScreenState();
}

class _QuickActionsSettingsScreenState extends State<QuickActionsSettingsScreen> {
  List<QuickActionItem> _selectedActions = [];
  Map<String, List<QuickActionItem>> _actionsByCategory = {};
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final selected = await QuickActionsService.loadUserQuickActions();
    final grouped = QuickActionsService.getActionsByCategory();

    setState(() {
      _selectedActions = List.from(selected);
      _actionsByCategory = grouped;
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    final success = await QuickActionsService.saveUserQuickActions(_selectedActions);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Quick actions saved successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() => _hasChanges = false);

        // Navigate back to home screen after successful save
        // This ensures the home screen reloads the quick actions
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          context.pop(true); // Return true to indicate changes were saved
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save quick actions'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults?'),
        content: const Text('This will restore the default quick actions. Your custom selection will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await QuickActionsService.resetToDefaults();
      await _loadData();
      setState(() => _hasChanges = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reset to default quick actions'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleAction(QuickActionItem action) {
    setState(() {
      if (_selectedActions.contains(action)) {
        _selectedActions.remove(action);
      } else {
        if (_selectedActions.length < QuickActionsService.maxQuickActions) {
          _selectedActions.add(action);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum ${QuickActionsService.maxQuickActions} quick actions allowed'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
      _hasChanges = true;
    });
  }

  void _reorderActions(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedActions.removeAt(oldIndex);
      _selectedActions.insert(newIndex, item);
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: 'Customize Quick Actions',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 24),
                        _buildSelectedActionsSection(),
                        const SizedBox(height: 24),
                        _buildAvailableActionsSection(),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(bottomPadding),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customize Your Quick Actions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select up to ${QuickActionsService.maxQuickActions} tools to appear on your home screen. Drag to reorder.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected (${_selectedActions.length}/${QuickActionsService.maxQuickActions})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _selectedActions.isEmpty ? null : _resetToDefaults,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedActions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.neutralLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.neutralLight.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.touch_app_outlined, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 8),
                  Text(
                    'No quick actions selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap items below to add them',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: _reorderActions,
            itemCount: _selectedActions.length,
            itemBuilder: (context, index) {
              final action = _selectedActions[index];
              return _buildSelectedActionCard(action, index, key: ValueKey(action.id));
            },
          ),
      ],
    );
  }

  Widget _buildSelectedActionCard(QuickActionItem action, int index, {required Key key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(action.icon, color: action.color, size: 24),
        ),
        title: Text(
          action.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          action.subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '#${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.drag_handle, color: AppColors.textTertiary),
          ],
        ),
        onTap: () => _toggleAction(action),
      ),
    );
  }

  Widget _buildAvailableActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Tools',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._actionsByCategory.entries.map((entry) {
          return _buildCategorySection(entry.key, entry.value);
        }),
      ],
    );
  }

  Widget _buildCategorySection(String category, List<QuickActionItem> actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        ...actions.map((action) => _buildAvailableActionCard(action)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAvailableActionCard(QuickActionItem action) {
    final isSelected = _selectedActions.contains(action);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 0 : 1,
      color: isSelected ? AppColors.success.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppColors.success.withValues(alpha: 0.5), width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(action.icon, color: action.color, size: 24),
        ),
        title: Text(
          action.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          action.subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: AppColors.success, size: 24)
            : Icon(Icons.add_circle_outline, color: AppColors.textTertiary, size: 24),
        onTap: () => _toggleAction(action),
      ),
    );
  }

  Widget _buildBottomBar(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.primary),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _hasChanges ? _saveChanges : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
