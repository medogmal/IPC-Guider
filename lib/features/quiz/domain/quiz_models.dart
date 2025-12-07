import 'package:flutter/material.dart';

/// Quiz module identifiers (expand later: hand_hygiene, etc.)
enum QuizModule { isolation, calculators, outbreak, bundles, handHygiene, stewardship }

/// Convert string to enum
QuizModule moduleFromString(String s) {
  switch (s.toLowerCase()) {
    case 'isolation':
      return QuizModule.isolation;
    case 'calculators':
      return QuizModule.calculators;
    case 'outbreak':
      return QuizModule.outbreak;
    case 'bundles':
      return QuizModule.bundles;
    case 'hand_hygiene':
      return QuizModule.handHygiene;
    case 'stewardship':
      return QuizModule.stewardship;
    default:
      return QuizModule.isolation;
  }
}

/// Convert enum to string
String moduleId(QuizModule m) {
  switch (m) {
    case QuizModule.isolation:
      return 'isolation';
    case QuizModule.calculators:
      return 'calculators';
    case QuizModule.outbreak:
      return 'outbreak';
    case QuizModule.bundles:
      return 'bundles';
    case QuizModule.handHygiene:
      return 'hand_hygiene';
    case QuizModule.stewardship:
      return 'stewardship';
  }
}

/// Stage name & badge style per stage (1..5) and module name+final badge.
class BadgeSpec {
  final String title;
  final Color color;
  final IconData icon;
  const BadgeSpec(this.title, this.color, this.icon);
}

/// Suggested palette & titles per stage (consistent, readable on light/PNG):
/// 1: Novice (green), 2: Practitioner (teal), 3: Proficient (blue),
/// 4: Advanced (purple), 5: Expert (amber)
const stageBadges = <int, BadgeSpec>{
  1: BadgeSpec('Novice', Color(0xFF22C55E), Icons.school),
  2: BadgeSpec('Practitioner', Color(0xFF14B8A6), Icons.workspace_premium),
  3: BadgeSpec('Proficient', Color(0xFF3B82F6), Icons.verified),
  4: BadgeSpec('Advanced', Color(0xFF8B5CF6), Icons.military_tech),
  5: BadgeSpec('Expert', Color(0xFFF59E0B), Icons.star_rate),
};

/// Module final badge (earned when all 5 stages passed in module)
/// Using muted/professional colors for medical aesthetic (WCAG compliant)
const moduleFinalBadge = {
  QuizModule.isolation:
      BadgeSpec('Isolation & PPE Master', Color(0xFF5B8C85), Icons.emoji_events), // Muted teal
  QuizModule.calculators:
      BadgeSpec('IPC Calculator Master', Color(0xFF6B7280), Icons.calculate), // Professional gray
  QuizModule.outbreak:
      BadgeSpec('Outbreak Investigation Master', Color(0xFF8B7355), Icons.biotech), // Muted brown
  QuizModule.bundles:
      BadgeSpec('Bundle Care Master', Color(0xFF4A7C9D), Icons.emoji_events), // Soft blue
  QuizModule.handHygiene:
      BadgeSpec('Hand Hygiene Master', Color(0xFF22C55E), Icons.clean_hands), // Success green
  QuizModule.stewardship:
      BadgeSpec('Antimicrobial Stewardship Master', Color(0xFF7C3AED), Icons.medication), // Purple
};

/// In-stage progress (mid-quiz state for resume functionality)
class InStageProgress {
  final String module; // e.g. "isolation"
  final int stage; // 1..5
  final int currentQuestionIndex; // 0..9
  final int correctCount; // 0..10
  final List<int?> selectedAnswers; // length 10, null if not answered yet

  const InStageProgress({
    required this.module,
    required this.stage,
    required this.currentQuestionIndex,
    required this.correctCount,
    required this.selectedAnswers,
  });

  factory InStageProgress.empty(String module, int stage) => InStageProgress(
        module: module,
        stage: stage,
        currentQuestionIndex: 0,
        correctCount: 0,
        selectedAnswers: List.filled(10, null),
      );

  InStageProgress copyWith({
    int? currentQuestionIndex,
    int? correctCount,
    List<int?>? selectedAnswers,
  }) {
    return InStageProgress(
      module: module,
      stage: stage,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      correctCount: correctCount ?? this.correctCount,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }

  Map<String, dynamic> toJson() => {
        'module': module,
        'stage': stage,
        'currentQuestionIndex': currentQuestionIndex,
        'correctCount': correctCount,
        'selectedAnswers': selectedAnswers,
      };

  static InStageProgress fromJson(Map<String, dynamic> m) => InStageProgress(
        module: m['module']?.toString() ?? 'isolation',
        stage: m['stage'] ?? 1,
        currentQuestionIndex: m['currentQuestionIndex'] ?? 0,
        correctCount: m['correctCount'] ?? 0,
        selectedAnswers: (m['selectedAnswers'] as List?)
                ?.map((e) => e as int?)
                .toList() ??
            List.filled(10, null),
      );
}

/// Offline progress stored per module.
class ModuleProgress {
  final String module; // e.g. "isolation"
  final int unlockedStage; // highest unlocked stage (1..5)
  final List<int> bestScores; // length 5, best per stage
  final List<bool> stageBadgesEarned; // length 5
  final bool moduleBadgeEarned;
  final InStageProgress? inStageProgress; // null if no in-progress quiz

  const ModuleProgress({
    required this.module,
    required this.unlockedStage,
    required this.bestScores,
    required this.stageBadgesEarned,
    required this.moduleBadgeEarned,
    this.inStageProgress,
  });

  factory ModuleProgress.empty(String module) => ModuleProgress(
        module: module,
        unlockedStage: 1,
        bestScores: List.filled(5, 0),
        stageBadgesEarned: List.filled(5, false),
        moduleBadgeEarned: false,
        inStageProgress: null,
      );

  ModuleProgress copyWith({
    int? unlockedStage,
    List<int>? bestScores,
    List<bool>? stageBadgesEarned,
    bool? moduleBadgeEarned,
    InStageProgress? inStageProgress,
    bool clearInStageProgress = false,
  }) {
    return ModuleProgress(
      module: module,
      unlockedStage: unlockedStage ?? this.unlockedStage,
      bestScores: bestScores ?? this.bestScores,
      stageBadgesEarned: stageBadgesEarned ?? this.stageBadgesEarned,
      moduleBadgeEarned: moduleBadgeEarned ?? this.moduleBadgeEarned,
      inStageProgress:
          clearInStageProgress ? null : (inStageProgress ?? this.inStageProgress),
    );
  }

  Map<String, dynamic> toJson() => {
        'module': module,
        'unlockedStage': unlockedStage,
        'bestScores': bestScores,
        'stageBadgesEarned': stageBadgesEarned,
        'moduleBadgeEarned': moduleBadgeEarned,
        'inStageProgress': inStageProgress?.toJson(),
      };

  static ModuleProgress fromJson(Map<String, dynamic> m) => ModuleProgress(
        module: m['module']?.toString() ?? 'isolation',
        unlockedStage: m['unlockedStage'] ?? 1,
        bestScores: (m['bestScores'] as List).map((e) => e as int).toList(),
        stageBadgesEarned:
            (m['stageBadgesEarned'] as List).map((e) => e as bool).toList(),
        moduleBadgeEarned: m['moduleBadgeEarned'] ?? false,
        inStageProgress: m['inStageProgress'] != null
            ? InStageProgress.fromJson(m['inStageProgress'])
            : null,
      );
}
