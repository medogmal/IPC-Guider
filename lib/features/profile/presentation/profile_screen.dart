import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/back_button.dart';
import '../../quiz/data/quiz_progress.dart';
import '../../quiz/domain/quiz_models.dart';
import '../data/user_profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _professionController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider);
      _nameController.text = profile.name ?? '';
      _titleController.text = profile.title ?? '';
      _professionController.text = profile.profession ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    await ref.read(userProfileProvider.notifier).updateProfile(
          name: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          profession: _professionController.text.trim().isEmpty
              ? null
              : _professionController.text.trim(),
        );
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final progressMap = ref.watch(progressStoreProvider);

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Profile',
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name & Title
                  if (_isEditing) ...[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name (optional)',
                        hintText: 'e.g., John Smith',
                        border: OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title (optional)',
                        hintText: 'e.g., Dr., Mr., Ms., Nurse',
                        border: OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _professionController,
                      decoration: const InputDecoration(
                        labelText: 'Profession (optional)',
                        hintText: 'e.g., Infection Preventionist',
                        border: OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Reset to saved values
                            _nameController.text = profile.name ?? '';
                            _titleController.text = profile.title ?? '';
                            _professionController.text = profile.profession ?? '';
                            setState(() => _isEditing = false);
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _saveProfile,
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      profile.name ?? 'IPC Professional',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (profile.title != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.title!,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (profile.profession != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.profession!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ],
              ),
            ),

            // Badges Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quiz Achievements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete quizzes to earn badges and showcase your expertise',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Module Badges
                  ...QuizModule.values.map((module) {
                    final moduleStr = moduleId(module);
                    final progress = progressMap[moduleStr] ??
                        ModuleProgress.empty(moduleStr);
                    return _buildModuleBadgeCard(module, progress);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleBadgeCard(QuizModule module, ModuleProgress progress) {
    final badge = moduleFinalBadge[module]!;
    final completedStages =
        progress.stageBadgesEarned.where((earned) => earned).length;
    final totalStages = 5;
    final isComplete = progress.moduleBadgeEarned;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Module Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: badge.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    badge.icon,
                    color: badge.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Module Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getModuleName(module),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedStages/$totalStages stages completed',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Master Badge (if earned)
                if (isComplete)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: badge.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Master',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completedStages / totalStages,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(badge.color),
              ),
            ),

            const SizedBox(height: 12),

            // Stage Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(totalStages, (index) {
                final stageNum = index + 1;
                final earned = progress.stageBadgesEarned[index];
                final stageBadge = stageBadges[stageNum]!;
                final bestScore = progress.bestScores[index];

                return Opacity(
                  opacity: earned ? 1.0 : 0.3,
                  child: Chip(
                    avatar: Icon(
                      stageBadge.icon,
                      size: 16,
                      color: earned ? stageBadge.color : Colors.grey,
                    ),
                    label: Text(
                      '${stageBadge.title}${earned ? " ($bestScore/10)" : ""}',
                      style: TextStyle(
                        fontSize: 12,
                        color: earned ? stageBadge.color : Colors.grey,
                        fontWeight: earned ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: earned
                        ? stageBadge.color.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    side: BorderSide(
                      color: earned ? stageBadge.color : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),

            // Bottom padding for mobile responsiveness
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  String _getModuleName(QuizModule module) {
    switch (module) {
      case QuizModule.isolation:
        return 'Isolation & PPE';
      case QuizModule.calculators:
        return 'IPC Calculators';
      case QuizModule.outbreak:
        return 'Outbreak Investigation';
      case QuizModule.bundles:
        return 'Bundle Care';
      case QuizModule.handHygiene:
        return 'Hand Hygiene';
      case QuizModule.stewardship:
        return 'Antimicrobial Stewardship';
    }
  }
}

