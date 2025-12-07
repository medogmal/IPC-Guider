import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/back_button.dart';
import '../data/quiz_providers.dart';
import '../domain/quiz_question.dart';
import '../domain/quiz_models.dart';
import '../data/quiz_progress.dart';
import 'stage_result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String moduleId;
  final int initialStage;
  const QuizScreen({super.key, required this.moduleId, this.initialStage = 1});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  String? _initializedForModule;
  bool _hasShownResumeDialog = false;

  void _initIfNeeded() {
    if (_initializedForModule != widget.moduleId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForResumeProgress();
      });
      _initializedForModule = widget.moduleId;
    }
  }

  void _checkForResumeProgress() {
    final storeMap = ref.read(progressStoreProvider);
    final progress = storeMap[widget.moduleId];

    if (progress?.inStageProgress != null && !_hasShownResumeDialog) {
      _hasShownResumeDialog = true;
      final inProgress = progress!.inStageProgress!;

      // Show resume dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Resume Quiz?'),
          content: Text(
            'You have an unfinished quiz at Stage ${inProgress.stage}, '
            'Question ${inProgress.currentQuestionIndex + 1}/10.\n\n'
            'Would you like to resume where you left off or start over?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Start fresh
                ref.read(quizControllerProvider.notifier).startModule(
                      moduleFromString(widget.moduleId),
                      inProgress.stage,
                    );
              },
              child: const Text('Start Over'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Resume from saved progress
                ref.read(quizControllerProvider.notifier).startModule(
                      moduleFromString(widget.moduleId),
                      inProgress.stage,
                    );
                ref.read(quizControllerProvider.notifier).resumeFromProgress(inProgress);
              },
              child: const Text('Resume'),
            ),
          ],
        ),
      );
    } else {
      // No saved progress, start normally
      ref.read(quizControllerProvider.notifier).startModule(
            moduleFromString(widget.moduleId),
            widget.initialStage,
          );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializedForModule = null;
    _hasShownResumeDialog = false;
  }

  @override
  void didUpdateWidget(covariant QuizScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moduleId != widget.moduleId) {
      _initializedForModule = null;
      _hasShownResumeDialog = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initIfNeeded();

    final run = ref.watch(quizControllerProvider);
    final storeMap = ref.watch(progressStoreProvider);
    final progress =
        storeMap[widget.moduleId] ?? ModuleProgress.empty(widget.moduleId);

    final allowedStage = progress.unlockedStage;
    if (run.stage > allowedStage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(quizControllerProvider.notifier).restartStage(allowedStage);
      });
    }

    final questions = ref.watch(currentStageQuestionsProvider);
    final currentStage = run.stage.clamp(1, allowedStage);

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Quiz – ${widget.moduleId.toUpperCase()} (Stage $currentStage)',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text('Best: ${progress.bestScores[currentStage - 1]}/10'),
            ),
          )
        ],
      ),
      body: questions.isEmpty
          ? const Center(child: Text('No questions for this stage yet.'))
          : _QuizBody(questions: questions),
    );
  }
}

class _QuizBody extends ConsumerStatefulWidget {
  final List<QuizQuestion> questions;
  const _QuizBody({required this.questions});

  @override
  ConsumerState<_QuizBody> createState() => _QuizBodyState();
}

class _QuizBodyState extends ConsumerState<_QuizBody> {
  int? _selected;           // 0..3
  bool _checked = false;    // pressed "Check answer"?
  bool _isCorrect = false;  // result of the check

  void _resetForNext() {
    setState(() {
      _selected = null;
      _checked = false;
      _isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(quizControllerProvider);
    final q = widget.questions[run.index.clamp(0, widget.questions.length - 1)];
    final progress = (run.index + 1) / 10.0;

    if (run.finishedStage) {
      return StageResultScreen(
        stage: run.stage,
        module: run.module,
        correct: run.correct,
      );
    }

    return SafeArea(
      child: Column(
        children: [
          // Top progress + header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 12),
                Text('Question ${run.index + 1} of 10',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: Text(q.question, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                ...List.generate(q.options.length, (i) {
                  final selected = _selected == i;
                  final disabled = _checked; // lock after checking
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      enabled: !disabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color:
                              selected ? AppColors.primary : Colors.grey.shade300,
                        ),
                      ),
                      title: Text(q.options[i]),
                      leading: Radio<int>(
                        value: i,
                        groupValue: _selected,
                        onChanged:
                            disabled ? null : (v) => setState(() => _selected = v),
                      ),
                      onTap: disabled ? null : () => setState(() => _selected = i),
                    ),
                  );
                }),

                const SizedBox(height: 8),

                // Explanation + References (visible after "Check answer")
                if (_checked) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.cancel,
                        color: _isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          q.explanation,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (q.references.isNotEmpty) ...[
                    const Text('References',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: q.references.map((r) {
                        return OutlinedButton.icon(
                          onPressed: () => _launchRef(r.url),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: Text(
                            r.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],

                // Extra bottom spacing so last buttons don't hide behind nav bars
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Fixed bottom CTA bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: !_checked
                    ? (_selected == null
                        ? null
                        : () {
                            final correct = _selected == q.answerIndex;
                            setState(() {
                              _isCorrect = correct;
                              _checked = true;
                            });
                          })
                    : () {
                        ref
                            .read(quizControllerProvider.notifier)
                            .answer(_isCorrect, _selected!);
                        _resetForNext();
                      },
                child: Text(!_checked
                    ? 'Check answer'
                    : (run.index == 9 ? 'Finish Stage' : 'Next')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchRef(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
