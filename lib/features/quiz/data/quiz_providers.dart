import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quiz_question.dart';
import '../domain/quiz_models.dart';
import 'quiz_progress.dart';

/// Load all questions from module-specific assets (offline)
final quizQuestionsProvider = FutureProvider<List<QuizQuestion>>((ref) async {
  final List<QuizQuestion> allQuestions = [];

  // Load isolation/PPE questions
  try {
    final isolationRaw = await rootBundle.loadString('assets/data/quiz_isolation_ppe.v1.json');
    final isolationMap = json.decode(isolationRaw) as Map<String, dynamic>;
    final isolationQuestions = (isolationMap['questions'] as List)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    allQuestions.addAll(isolationQuestions);
  } catch (e) {
    // Error loading isolation quiz - continue with other quizzes
  }

  // Load calculator questions
  try {
    final calculatorRaw = await rootBundle.loadString('assets/data/quiz_calculators.v1.json');
    final calculatorMap = json.decode(calculatorRaw) as Map<String, dynamic>;
    final calculatorQuestions = (calculatorMap['questions'] as List)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    allQuestions.addAll(calculatorQuestions);
  } catch (e) {
    // Error loading calculator quiz - continue with other quizzes
  }

  // Load outbreak questions
  try {
    final outbreakRaw = await rootBundle.loadString('assets/data/quiz_outbreak.v1.json');
    final outbreakMap = json.decode(outbreakRaw) as Map<String, dynamic>;
    final outbreakQuestions = (outbreakMap['questions'] as List)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    allQuestions.addAll(outbreakQuestions);
  } catch (e) {
    // Error loading outbreak quiz - continue with other quizzes
  }

  // Load bundle questions
  try {
    final bundleRaw = await rootBundle.loadString('assets/data/quiz_bundles.v1.json');
    final bundleMap = json.decode(bundleRaw) as Map<String, dynamic>;
    final bundleQuestions = (bundleMap['questions'] as List)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    allQuestions.addAll(bundleQuestions);
  } catch (e) {
    // Error loading bundle quiz - continue with other quizzes
  }

  // Load hand hygiene questions
  try {
    final handHygieneRaw = await rootBundle.loadString('assets/data/quiz_hand_hygiene.v1.json');
    final handHygieneMap = json.decode(handHygieneRaw) as Map<String, dynamic>;
    final handHygieneQuestions = (handHygieneMap['questions'] as List)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    allQuestions.addAll(handHygieneQuestions);
  } catch (e) {
    // Error loading hand hygiene quiz - continue with other quizzes
  }

  // Load stewardship questions
  try {
    final stewardshipRaw = await rootBundle.loadString('assets/data/quiz_stewardship.v1.json');
    final stewardshipMap = json.decode(stewardshipRaw) as Map<String, dynamic>;
    final stewardshipQuestions = (stewardshipMap['questions'] as List)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    allQuestions.addAll(stewardshipQuestions);
  } catch (e) {
    // Error loading stewardship quiz - continue with other quizzes
  }

  return allQuestions;
});

/// Current quiz run (one stage at a time)
class QuizRun {
  final QuizModule module;
  final int stage;           // 1..5
  final int index;           // 0..9 within stage
  final int correct;         // number of correct answers in this stage
  final bool finishedStage;  // true after 10 questions
  final List<int?> selectedAnswers; // length 10, stores selected answer index for each question

  const QuizRun({
    required this.module,
    required this.stage,
    this.index = 0,
    this.correct = 0,
    this.finishedStage = false,
    List<int?>? selectedAnswers,
  }) : selectedAnswers = selectedAnswers ?? const [];

  QuizRun copyWith({
    QuizModule? module,
    int? stage,
    int? index,
    int? correct,
    bool? finishedStage,
    List<int?>? selectedAnswers,
  }) {
    return QuizRun(
      module: module ?? this.module,
      stage: stage ?? this.stage,
      index: index ?? this.index,
      correct: correct ?? this.correct,
      finishedStage: finishedStage ?? this.finishedStage,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}

class QuizController extends StateNotifier<QuizRun> {
  final Ref ref;
  QuizController(this.ref) : super(const QuizRun(module: QuizModule.isolation, stage: 1));

  void startModule(QuizModule m, int stage) {
    state = QuizRun(
      module: m,
      stage: stage,
      selectedAnswers: List.filled(10, null),
    );
  }

  void restartStage(int stage) {
    // Clear in-stage progress when restarting
    final store = ref.read(progressStoreProvider.notifier);
    store.clearInStageProgress(moduleId(state.module));

    state = state.copyWith(
      stage: stage,
      index: 0,
      correct: 0,
      finishedStage: false,
      selectedAnswers: List.filled(10, null),
    );
  }

  /// Resume from saved in-stage progress
  void resumeFromProgress(InStageProgress progress) {
    state = QuizRun(
      module: state.module,
      stage: progress.stage,
      index: progress.currentQuestionIndex,
      correct: progress.correctCount,
      finishedStage: false,
      selectedAnswers: List.from(progress.selectedAnswers),
    );
  }

  Future<void> answer(bool isCorrect, int selectedAnswerIndex) async {
    final nextIndex = state.index + 1;
    final nextCorrect = isCorrect ? state.correct + 1 : state.correct;
    final finished = nextIndex >= 10;

    // Update selected answers list
    final updatedAnswers = List<int?>.from(state.selectedAnswers);
    if (updatedAnswers.length < 10) {
      updatedAnswers.addAll(List.filled(10 - updatedAnswers.length, null));
    }
    updatedAnswers[state.index] = selectedAnswerIndex;

    final newState = state.copyWith(
      index: nextIndex,
      correct: nextCorrect,
      finishedStage: finished,
      selectedAnswers: updatedAnswers,
    );
    state = newState;

    final store = ref.read(progressStoreProvider.notifier);

    if (finished) {
      final passed = stagePassed(newState.correct);
      // Save final stage result and clear in-stage progress
      await store.updateStageResult(
        module: moduleId(state.module),
        stage: state.stage,
        score: newState.correct,
        passed: passed,
      );
    } else {
      // Save in-stage progress after each question
      await store.saveInStageProgress(
        module: moduleId(state.module),
        stage: state.stage,
        currentQuestionIndex: nextIndex,
        correctCount: nextCorrect,
        selectedAnswers: updatedAnswers,
      );
    }
  }
}

final quizControllerProvider =
    StateNotifierProvider<QuizController, QuizRun>((ref) => QuizController(ref));

/// Questions for current module+stage (first 10)
final currentStageQuestionsProvider =
    Provider<List<QuizQuestion>>((ref) {
  final run = ref.watch(quizControllerProvider);
  final all = ref.watch(quizQuestionsProvider).maybeWhen(
        data: (q) => q,
        orElse: () => <QuizQuestion>[],
      );
  final moduleStr = moduleId(run.module);
  final qs = all.where((e) => e.module == moduleStr && e.stage == run.stage).take(10).toList();
  return qs;
});

/// Passing rule: >= 70% (7/10)
bool stagePassed(int correct) => correct >= 7;
