import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/design/design_tokens.dart';

class SurveillanceTypeScreen extends StatefulWidget {
  const SurveillanceTypeScreen({super.key});

  @override
  State<SurveillanceTypeScreen> createState() => _SurveillanceTypeScreenState();
}

class _SurveillanceTypeScreenState extends State<SurveillanceTypeScreen> {
  // Questionnaire state
  int currentQuestion = 0;
  final Map<int, int?> answers = {};
  bool showResults = false;

  // Questions data
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What is your current situation?',
      'options': [
        {'text': 'Suspected outbreak or cluster under investigation', 'weights': {'active': 3, 'passive': 0, 'sentinel': 1, 'syndromic': 1}},
        {'text': 'Routine monitoring of endemic infections', 'weights': {'active': 0, 'passive': 3, 'sentinel': 2, 'syndromic': 0}},
        {'text': 'Need early warning for emerging threats', 'weights': {'active': 2, 'passive': 0, 'sentinel': 2, 'syndromic': 3}},
        {'text': 'Limited lab testing capacity', 'weights': {'active': 0, 'passive': 1, 'sentinel': 1, 'syndromic': 3}},
      ],
    },
    {
      'question': 'What is your priority?',
      'options': [
        {'text': 'Highest sensitivity and timeliness (even if resource-intensive)', 'weights': {'active': 3, 'passive': 0, 'sentinel': 1, 'syndromic': 2}},
        {'text': 'Sustainable long-term monitoring', 'weights': {'active': 0, 'passive': 3, 'sentinel': 2, 'syndromic': 0}},
        {'text': 'Earliest possible signals (before lab confirmation)', 'weights': {'active': 1, 'passive': 0, 'sentinel': 1, 'syndromic': 3}},
        {'text': 'Focus on high-risk populations/units', 'weights': {'active': 2, 'passive': 0, 'sentinel': 3, 'syndromic': 1}},
      ],
    },
    {
      'question': 'What resources do you have?',
      'options': [
        {'text': 'Dedicated IPC staff available for intensive case-finding', 'weights': {'active': 3, 'passive': 0, 'sentinel': 2, 'syndromic': 1}},
        {'text': 'Rely on clinical staff reporting', 'weights': {'active': 0, 'passive': 3, 'sentinel': 1, 'syndromic': 1}},
        {'text': 'Limited staff, need automated/proxy data', 'weights': {'active': 0, 'passive': 1, 'sentinel': 1, 'syndromic': 3}},
        {'text': 'Mix of active and passive approaches', 'weights': {'active': 2, 'passive': 2, 'sentinel': 3, 'syndromic': 1}},
      ],
    },
    {
      'question': 'What is your timeframe?',
      'options': [
        {'text': 'Short-term intensive investigation (days to weeks)', 'weights': {'active': 3, 'passive': 0, 'sentinel': 1, 'syndromic': 2}},
        {'text': 'Long-term continuous surveillance (months to years)', 'weights': {'active': 0, 'passive': 3, 'sentinel': 2, 'syndromic': 0}},
        {'text': 'Need immediate signals (hours to days)', 'weights': {'active': 2, 'passive': 0, 'sentinel': 1, 'syndromic': 3}},
        {'text': 'Flexible, depends on situation', 'weights': {'active': 1, 'passive': 2, 'sentinel': 3, 'syndromic': 1}},
      ],
    },
    {
      'question': 'What is your acceptable specificity?',
      'options': [
        {'text': 'Need high specificity (confirmed cases only)', 'weights': {'active': 3, 'passive': 2, 'sentinel': 2, 'syndromic': 0}},
        {'text': 'Lower specificity acceptable initially (syndromic/proxy data)', 'weights': {'active': 0, 'passive': 0, 'sentinel': 1, 'syndromic': 3}},
        {'text': 'Balance between sensitivity and specificity', 'weights': {'active': 2, 'passive': 2, 'sentinel': 3, 'syndromic': 1}},
        {'text': 'Prioritize sensitivity over specificity', 'weights': {'active': 3, 'passive': 0, 'sentinel': 1, 'syndromic': 2}},
      ],
    },
  ];

  // Surveillance type data
  final Map<String, Map<String, dynamic>> surveillanceTypes = {
    'active': {
      'title': 'Active Surveillance',
      'definition': 'Proactive, systematic case finding by IPC/epidemiology staff (e.g., chart reviews, ward rounds, direct contact with units).',
      'whenToUse': 'Suspected outbreak; need rapid, high-quality data; short-term intensive follow-up.',
      'benefits': 'High sensitivity and timeliness; reduces under-reporting; strong during outbreaks.',
      'limitations': 'Resource-intensive; not ideal long-term.',
      'color': const Color(0xFFB85C5C), // Muted red
      'icon': Icons.search_outlined,
    },
    'passive': {
      'title': 'Passive Surveillance',
      'definition': 'Routine, ongoing reporting from clinical units/labs without additional active case-finding by IPC staff.',
      'whenToUse': 'Baseline monitoring; stable settings; long-term trend tracking.',
      'benefits': 'Low cost; sustainable; wide coverage.',
      'limitations': 'Lower sensitivity; delays; under-reporting possible.',
      'color': const Color(0xFF6B9B6B), // Muted green
      'icon': Icons.trending_up_outlined,
    },
    'sentinel': {
      'title': 'Sentinel Surveillance',
      'definition': 'Enhanced, detailed surveillance in selected sites ("sentinel" units) to detect trends/signals representative of the wider system.',
      'whenToUse': 'Need higher-quality data from representative units; piloting methods; monitoring specific conditions.',
      'benefits': 'Better data quality than passive; focused; scalable.',
      'limitations': 'Not fully representative; site selection bias.',
      'color': const Color(0xFFB8914D), // Muted amber
      'icon': Icons.radar_outlined,
    },
    'syndromic': {
      'title': 'Syndromic Surveillance',
      'definition': 'Rapid surveillance based on symptom complexes (e.g., fever + cough) or proxy data (e.g., absenteeism) before lab confirmation.',
      'whenToUse': 'Early detection; rapidly evolving respiratory/viral illness; low testing capacity.',
      'benefits': 'Very timely; early signal detection; useful in surges.',
      'limitations': 'Lower specificity; false positives; needs validation.',
      'color': const Color(0xFF5B8A8A), // Muted teal
      'icon': Icons.speed_outlined,
    },
  };

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Surveillance Type'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        actions: [
          if (showResults)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _resetQuestionnaire,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Start Over',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: showResults ? _buildResultsView(bottomPadding) : _buildQuestionnaireView(bottomPadding),
      ),
    );
  }

  Widget _buildQuestionnaireView(double bottomPadding) {
    final question = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestion + 1} of ${questions.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question['question'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Options
          ...List.generate(question['options'].length, (index) {
            final option = question['options'][index];
            final isSelected = answers[currentQuestion] == index;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _selectOption(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option['text'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              if (currentQuestion > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousQuestion,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              if (currentQuestion > 0) const SizedBox(width: 12),
              Expanded(
                flex: currentQuestion == 0 ? 1 : 1,
                child: ElevatedButton.icon(
                  onPressed: answers.containsKey(currentQuestion)
                      ? _nextQuestion
                      : null,
                  icon: Icon(
                    currentQuestion == questions.length - 1
                        ? Icons.check_circle_outline
                        : Icons.arrow_forward,
                    size: 18,
                  ),
                  label: Text(
                    currentQuestion == questions.length - 1
                        ? 'See Results'
                        : 'Next',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: AppColors.textTertiary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(double bottomPadding) {
    final scores = _calculateScores();
    final sortedTypes = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topType = sortedTypes.first.key;
    final topScore = sortedTypes.first.value;
    final alternatives = sortedTypes.skip(1).take(2).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recommendation Ready',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on your answers',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Best Match Card
          _buildRecommendationCard(topType, topScore, isTop: true),

          const SizedBox(height: 16),

          // Alternatives
          if (alternatives.isNotEmpty) ...[
            Text(
              'Also Consider',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ...alternatives.map((entry) =>
              _buildRecommendationCard(entry.key, entry.value, isTop: false)
            ),
          ],

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showCompareView,
                  icon: const Icon(Icons.compare_arrows, size: 18),
                  label: const Text('Compare All'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveResult,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save Result'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // References
          _buildReferences(),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String type, int score, {required bool isTop}) {
    final data = surveillanceTypes[type]!;
    final color = data['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isTop ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop ? color.withValues(alpha: 0.4) : AppColors.textTertiary.withValues(alpha: 0.2),
          width: isTop ? 2 : 1,
        ),
        boxShadow: isTop ? [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTop ? 12 : 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  data['icon'],
                  color: color,
                  size: isTop ? 28 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['title'],
                            style: TextStyle(
                              fontSize: isTop ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isTop)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B9B6B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Best Match',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B9B6B),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (!isTop) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Alternative',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoSection('Definition', data['definition']),
          const SizedBox(height: 8),
          _buildInfoSection('When to Use', data['whenToUse']),
          const SizedBox(height: 8),
          _buildInfoSection('Benefits', data['benefits']),
          const SizedBox(height: 8),
          _buildInfoSection('Limitations', data['limitations']),
          if (isTop) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getWhyThisFits(type),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // Helper methods
  void _selectOption(int optionIndex) {
    setState(() {
      answers[currentQuestion] = optionIndex;
    });
  }

  void _nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      setState(() {
        showResults = true;
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
      });
    }
  }

  void _resetQuestionnaire() {
    setState(() {
      currentQuestion = 0;
      answers.clear();
      showResults = false;
    });
  }

  Map<String, int> _calculateScores() {
    final scores = <String, int>{
      'active': 0,
      'passive': 0,
      'sentinel': 0,
      'syndromic': 0,
    };

    for (var i = 0; i < questions.length; i++) {
      final answerIndex = answers[i];
      if (answerIndex != null) {
        final option = questions[i]['options'][answerIndex];
        final weights = option['weights'] as Map<String, int>;
        for (final entry in weights.entries) {
          scores[entry.key] = (scores[entry.key] ?? 0) + entry.value;
        }
      }
    }

    return scores;
  }

  String _getWhyThisFits(String type) {
    final reasons = <String>[];

    for (var i = 0; i < questions.length; i++) {
      final answerIndex = answers[i];
      if (answerIndex != null) {
        final option = questions[i]['options'][answerIndex];
        final weights = option['weights'] as Map<String, int>;
        if (weights[type] != null && weights[type]! >= 2) {
          reasons.add(option['text']);
        }
      }
    }

    if (reasons.isEmpty) {
      return 'This type matches your overall scenario best.';
    }

    return 'Why this fits: ${reasons.take(3).join('; ')}.';
  }

  Widget _buildReferences() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.library_books_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'References',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReferenceButton(
            'WHO Surveillance Guidelines',
            'https://www.who.int/teams/control-of-neglected-tropical-diseases',
          ),
          const SizedBox(height: 6),
          _buildReferenceButton(
            'CDC Public Health Surveillance',
            'https://www.cdc.gov/outbreaks/index.html',
          ),
          const SizedBox(height: 6),
          _buildReferenceButton(
            'GDIPC/Weqaya National Reporting',
            'https://www.moh.gov.sa/Ministry/Rules/Documents/Healthcare-Associated-Outbreak-Management-Manual.pdf',
          ),
          const SizedBox(height: 6),
          _buildReferenceButton(
            'APIC/NHSN IPC Surveillance',
            'https://www.cdc.gov/infectioncontrol/basics/transmission-based-precautions.html',
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceButton(String title, String url) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _launchURL(url),
        icon: Icon(
          Icons.open_in_new,
          size: 14,
          color: AppColors.primary,
        ),
        label: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }

  void _showCompareView() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCompareModal(),
    );
  }

  Widget _buildCompareModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Compare Surveillance Types',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Comparison Table
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildComparisonTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Table(
      border: TableBorder.all(
        color: AppColors.textTertiary.withValues(alpha: 0.3),
        width: 1,
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1.5),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          children: [
            _buildTableCell('Criteria', isHeader: true),
            _buildTableCell('Active', isHeader: true),
            _buildTableCell('Passive', isHeader: true),
            _buildTableCell('Sentinel', isHeader: true),
            _buildTableCell('Syndromic', isHeader: true),
          ],
        ),
        // Rows
        TableRow(children: [
          _buildTableCell('Timeliness'),
          _buildTableCell('High'),
          _buildTableCell('Low'),
          _buildTableCell('Medium'),
          _buildTableCell('High'),
        ]),
        TableRow(children: [
          _buildTableCell('Resources'),
          _buildTableCell('High'),
          _buildTableCell('Low'),
          _buildTableCell('Medium'),
          _buildTableCell('Medium'),
        ]),
        TableRow(children: [
          _buildTableCell('Sensitivity'),
          _buildTableCell('High'),
          _buildTableCell('Medium'),
          _buildTableCell('Medium'),
          _buildTableCell('High'),
        ]),
        TableRow(children: [
          _buildTableCell('Specificity'),
          _buildTableCell('High'),
          _buildTableCell('Medium'),
          _buildTableCell('Medium'),
          _buildTableCell('Low'),
        ]),
        TableRow(children: [
          _buildTableCell('Best Use Case'),
          _buildTableCell('Outbreaks'),
          _buildTableCell('Baseline trends'),
          _buildTableCell('Signal/trend in key units'),
          _buildTableCell('Early detection'),
        ]),
        TableRow(children: [
          _buildTableCell('Limitations'),
          _buildTableCell('Costly'),
          _buildTableCell('Under-reporting'),
          _buildTableCell('Not representative'),
          _buildTableCell('False positives'),
        ]),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          color: isHeader ? AppColors.primary : AppColors.textPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _saveResult() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = _calculateScores();
    final sortedTypes = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topType = sortedTypes.first.key;

    final result = {
      'timestamp': DateTime.now().toIso8601String(),
      'recommendedType': surveillanceTypes[topType]!['title'],
      'scores': scores,
      'answers': answers.map((key, value) => MapEntry(key.toString(), value)),
    };

    final history = prefs.getStringList('surveillance_history') ?? [];
    history.insert(0, jsonEncode(result));

    // Keep only last 10 entries
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await prefs.setStringList('surveillance_history', history);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Result saved successfully'),
            ],
          ),
          backgroundColor: const Color(0xFF6B9B6B), // Muted green
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error if needed
    }
  }
}
