import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/quiz_providers.dart';
import '../domain/quiz_models.dart';
import '../data/quiz_progress.dart';
import '../widgets/quiz_badge_chip.dart';

class StageResultScreen extends ConsumerWidget {
  final int stage;
  final QuizModule module;
  final int correct;
  const StageResultScreen({super.key, required this.stage, required this.module, required this.correct});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passed = stagePassed(correct);
    final spec = stageBadges[stage]!;
    final moduleIdStr = moduleId(module);
    final progress = ref.watch(progressStoreProvider)[moduleIdStr] ?? ModuleProgress.empty(moduleIdStr);
    final moduleBadge = moduleFinalBadge[module]!;

    final title = passed ? 'Congratulations!' : 'Try Again';
    final color = passed ? Colors.green : Colors.orange;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(passed ? Icons.emoji_events : Icons.refresh, size: 72, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Stage $stage score: $correct / 10'),

            const SizedBox(height: 16),
            if (passed) QuizBadgeChip(spec: spec, subtitle: 'Stage $stage badge'),

            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Text('Unlocked up to: Stage ${progress.unlockedStage}'),
                if (progress.moduleBadgeEarned)
                  QuizBadgeChip(spec: moduleBadge, subtitle: 'Module badge'),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(quizControllerProvider.notifier).restartStage(stage);
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Retry stage'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: passed
                      ? () {
                          final next = (stage < 5) ? stage + 1 : 1;
                          ref.read(quizControllerProvider.notifier).restartStage(next);
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(stage < 5 ? 'Next stage' : 'Restart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
