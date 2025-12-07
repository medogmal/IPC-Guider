import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/back_button.dart';
import '../data/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Settings',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.text_fields_outlined,
                title: 'Text Size',
                subtitle: 'Adjust text scaling for better readability',
                trailing: DropdownButton<double>(
                  value: settings.textScaleFactor,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 0.8, child: Text('Small')),
                    DropdownMenuItem(value: 1.0, child: Text('Normal')),
                    DropdownMenuItem(value: 1.2, child: Text('Large')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).setTextScaleFactor(value);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Data Management Section
          _SettingsSection(
            title: 'Data Management',
            children: [
              _SettingsTile(
                icon: Icons.cleaning_services_outlined,
                title: 'History Cleanup',
                subtitle: 'Remove old history data before migration',
                trailing: TextButton(
                  onPressed: () => context.go('/settings/history-cleanup'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.warning,
                  ),
                  child: const Text('Cleanup'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: 'Version 1.0.0+1',
                trailing: const SizedBox(),
              ),
              _SettingsTile(
                icon: Icons.update_outlined,
                title: 'Last Updated',
                subtitle: 'December 6, 2025',
                trailing: const SizedBox(),
              ),
            ],
          ),

          // Bottom padding for mobile responsiveness
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
