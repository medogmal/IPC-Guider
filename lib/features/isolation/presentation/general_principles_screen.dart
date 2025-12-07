import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Loads JSON from assets/data/isolation_principles.v1.json
final principlesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final raw = await rootBundle.loadString('assets/data/isolation_principles.v1.json');
    return json.decode(raw) as Map<String, dynamic>;
  } catch (_) {
    return {}; // graceful fallback if file missing
  }
});

class GeneralPrinciplesScreen extends ConsumerWidget {
  const GeneralPrinciplesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(principlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Isolation – General Principles'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (map) {
          if (map.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: _MissingAssetNotice(),
            );
          }

          // --- ENHANCED DATA PARSING ---
          final donning = (map['donning'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
          final doffing = (map['doffing'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
          final components = (map['components'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
          final mistakes = (map['commonMistakes'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
          final tips = (map['tips'] as List?)?.cast<String>() ?? const [];
          final references = (map['references'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Donning steps
              if (donning.isNotEmpty)
                _StepsList(title: 'DONNING (Putting On) PPE', steps: donning),
              const SizedBox(height: 16),

              // Doffing steps
              if (doffing.isNotEmpty)
                _StepsList(title: 'DOFFING (Taking Off) PPE', steps: doffing),
              const SizedBox(height: 16),

              // Components per isolation type
              if (components.isNotEmpty)
                _ComponentsBlock(components: components),
              const SizedBox(height: 16),

              // Common mistakes with fixes
              if (mistakes.isNotEmpty)
                _MistakesBlock(mistakes: mistakes),
              const SizedBox(height: 16),

              if (tips.isNotEmpty)
                _TipsBlock(tips: tips),
              const SizedBox(height: 16),

              // References section
              if (references.isNotEmpty) ...[
                const SizedBox(height: 4),
                _ReferencesBlock(references: references),
              ],

              // Bottom padding for mobile responsiveness
              const SizedBox(height: 48),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.grey.shade800,
        letterSpacing: 0.5,
      ),
    );
  }
}

// --- ENHANCED WIDGET: _StepsList with Modern Cards ---
class _StepsList extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> steps;
  const _StepsList({required this.title, required this.steps});

  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'wash':
      case 'hand':
        return Icons.wash;
      case 'gown':
        return Icons.accessibility_new;
      case 'mask':
        return Icons.masks;
      case 'goggles':
      case 'faceshield':
        return Icons.remove_red_eye;
      case 'gloves':
        return Icons.front_hand;
      default:
        return Icons.circle;
    }
  }

  Color _getIconColor(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'wash':
      case 'hand':
        return Colors.cyan;
      case 'gown':
        return Colors.indigo;
      case 'mask':
        return Colors.teal;
      case 'goggles':
      case 'faceshield':
        return Colors.amber;
      case 'gloves':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((e) {
          final idx = e.key + 1;
          final item = e.value;
          final stepTitle = item['title'] as String? ?? 'No Title';
          final stepNote = item['note'] as String? ?? '';
          final iconName = item['icon'] as String? ?? '';
          final color = _getIconColor(iconName);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            _getIconFromString(iconName),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Center(
                              child: Text(
                                '$idx',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step title
                        Text(
                          stepTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        // Main note
                        if (stepNote.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            stepNote,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                        // Warning - simplified to text only
                        if (item['warning'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '⚠️ ${item['warning'] as String}',
                            style: TextStyle(
                              color: Colors.amber.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// --- ENHANCED WIDGET: _ComponentsBlock ---
class _ComponentsBlock extends StatelessWidget {
  final List<Map<String, dynamic>> components;
  const _ComponentsBlock({required this.components});

  Color _getColorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Isolation Precautions'),
        const SizedBox(height: 12),
        ...components.map((component) {
          final type = component['type'] as String? ?? 'Unknown';
          final items = (component['items'] as List?)?.cast<String>() ?? [];
          final colorHex = component['color'] as String? ?? '#6B7280';
          final color = _getColorFromHex(colorHex);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Isolation type header in colored card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Items without cards, clean text layout
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 7, right: 8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// --- ENHANCED WIDGET: _MistakesBlock ---
class _MistakesBlock extends StatelessWidget {
  final List<Map<String, dynamic>> mistakes;
  const _MistakesBlock({required this.mistakes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Common Mistakes & Fixes'),
        const SizedBox(height: 12),
        ...mistakes.map((m) {
          final mistakeText = m['mistake']?.toString() ?? 'Mistake';
          final fix = m['fix']?.toString() ?? '';
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.shade200,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mistake header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mistakeText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Fix section
                  if (fix.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fix:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  fix,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade700,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}


// --- ENHANCED WIDGET: _TipsBlock ---
class _TipsBlock extends StatelessWidget {
  final List<String> tips;
  const _TipsBlock({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Practical Tips'),
        const SizedBox(height: 12),
        ...tips.map((tip) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade200,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// --- REFERENCES WIDGET ---
class _ReferencesBlock extends StatelessWidget {
  final List<Map<String, dynamic>> references;
  const _ReferencesBlock({required this.references});

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('References & Guidelines'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: references.map((ref) {
            final label = ref['label'] as String? ?? 'Reference';
            final url = ref['url'] as String? ?? '';
            final hasUrl = url.isNotEmpty;
            
            return hasUrl
                ? OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(label, overflow: TextOverflow.ellipsis),
                    onPressed: () => _launchUrl(url),
                  )
                : Chip(label: Text(label));
          }).toList(),
        ),
      ],
    );
  }
}


class _MissingAssetNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'No data found.\n\n'
      'Add JSON at: assets/data/isolation_principles.v1.json\n'
      'Optionally add image at: assets/images/donning_doffing.png\n'
      'Then run a full restart.',
      style: TextStyle(color: Colors.redAccent),
    );
  }
}