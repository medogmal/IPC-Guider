import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/design/design_tokens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        const SizedBox(height: AppSpacing.small),
        Text(
          'IPC-guider',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.medium),
        IpcCard(
          title: 'Start a Calculation',
          icon: Icons.calculate_outlined,
          onTap: () => context.go('/calc'),
        ),
        IpcCard(
          title: 'Isolation & PPE',
          icon: Icons.verified_user_outlined,
          onTap: () => context.go('/isolation'),
        ),
        IpcCard(
          title: 'Bundles',
          icon: Icons.checklist_outlined,
          onTap: () => context.go('/tools/bundles'),
        ),
        const IpcCard(
          title: 'Hand Hygiene Audit',
          icon: Icons.clean_hands_outlined,
        ),
        const IpcCard(
          title: 'Outbreak Notes',
          icon: Icons.note_alt_outlined,
        ),
      ],
    );
  }
}
