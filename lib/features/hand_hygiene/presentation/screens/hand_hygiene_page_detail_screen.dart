import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/hand_hygiene_section.dart';
import '../../data/repositories/hand_hygiene_repository.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

/// Screen displaying full content of a hand hygiene page
class HandHygienePageDetailScreen extends StatefulWidget {
  final String sectionId;
  final String pageId;

  const HandHygienePageDetailScreen({
    super.key,
    required this.sectionId,
    required this.pageId,
  });

  @override
  State<HandHygienePageDetailScreen> createState() =>
      _HandHygienePageDetailScreenState();
}

class _HandHygienePageDetailScreenState
    extends State<HandHygienePageDetailScreen> {
  final _repository = HandHygieneRepository();

  HandHygienePage? _page;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final page = await _repository.getPageById(widget.pageId);

      if (page == null) {
        setState(() {
          _errorMessage = 'Page not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _page = page;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load page: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(_page?.name ?? 'Page'),
        elevation: 0,
      ),
      body: _buildContent(bottomPadding),
    );
  }

  Widget _buildContent(double bottomPadding) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: AppSpacing.medium),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: AppSpacing.medium),
              ElevatedButton.icon(
                onPressed: _loadPage,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_page == null) {
      return const Center(child: Text('Page not found'));
    }

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card (like AMS module)
          ContentHeaderCard(
            icon: Icons.clean_hands,
            iconColor: AppColors.success,
            title: _page!.name,
            subtitle: 'Hand Hygiene Best Practices',
            description: 'Evidence-based guidance for effective hand hygiene in healthcare settings',
          ),

          const SizedBox(height: AppSpacing.medium),

          // Introduction Card (first paragraph as overview)
          if (_page!.content.isNotEmpty)
            IntroductionCard(
              text: _page!.content.first,
              isHighlighted: true,
            ),

          const SizedBox(height: AppSpacing.medium),

          // Content sections as structured cards
          ..._buildStructuredContent(),

          // Key Points Card
          if (_page!.keyPoints.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.medium),
            StructuredContentCard(
              icon: Icons.lightbulb_outline,
              heading: 'Key Points',
              color: AppColors.success,
              content: _page!.keyPoints.join('\n• '),
            ),
          ],

          // References Card
          if (_page!.references.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.medium),
            _buildReferencesCard(),
          ],

          const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  /// Build structured content cards from plain text paragraphs
  List<Widget> _buildStructuredContent() {
    if (_page!.content.length <= 1) return [];

    final List<Widget> widgets = [];

    // Skip first paragraph (used in IntroductionCard)
    for (int i = 1; i < _page!.content.length; i++) {
      final paragraph = _page!.content[i];

      // Check if this is a WHO 5 Moments paragraph
      if (paragraph.contains('MOMENT')) {
        widgets.add(_buildMomentCard(paragraph, i));
        widgets.add(const SizedBox(height: AppSpacing.medium));
        continue;
      }

      // Check if this is a section with a heading (contains colon in first 80 chars)
      final colonIndex = paragraph.indexOf(':');
      if (colonIndex > 0 && colonIndex < 80) {
        final heading = paragraph.substring(0, colonIndex).trim();
        final content = paragraph.substring(colonIndex + 1).trim();

        // Determine color based on keywords
        Color color = AppColors.info;
        IconData icon = Icons.info_outline;

        if (heading.toUpperCase().contains('REQUIRED') ||
            heading.toUpperCase().contains('MUST') ||
            heading.toUpperCase().contains('CRITICAL')) {
          color = AppColors.error;
          icon = Icons.warning_outlined;
        } else if (heading.toUpperCase().contains('CAUTION') ||
                   heading.toUpperCase().contains('IMPORTANT') ||
                   heading.toUpperCase().contains('NOTE')) {
          color = AppColors.warning;
          icon = Icons.error_outline;
        } else if (heading.toUpperCase().contains('BEST') ||
                   heading.toUpperCase().contains('RECOMMENDED') ||
                   heading.toUpperCase().contains('EFFECTIVE')) {
          color = AppColors.success;
          icon = Icons.check_circle_outline;
        }

        widgets.add(
          StructuredContentCard(
            icon: icon,
            heading: heading,
            color: color,
            content: content,
          ),
        );
      } else {
        // Regular paragraph - extract intelligent heading from first sentence
        final heading = _extractHeadingFromParagraph(paragraph);
        final color = _determineColorFromContent(paragraph);
        final icon = _determineIconFromContent(paragraph);

        widgets.add(
          StructuredContentCard(
            icon: icon,
            heading: heading,
            color: color,
            content: paragraph,
          ),
        );
      }

      widgets.add(const SizedBox(height: AppSpacing.medium));
    }

    return widgets;
  }

  /// Extract intelligent heading from paragraph content
  String _extractHeadingFromParagraph(String paragraph) {
    // Try to extract first sentence or key phrase
    final sentences = paragraph.split(RegExp(r'[.!?]\s+'));
    if (sentences.isEmpty) return 'Information';

    final firstSentence = sentences.first.trim();

    // If first sentence is too long, extract key phrase
    if (firstSentence.length > 60) {
      // Look for key phrases
      if (firstSentence.contains('healthcare-associated infections')) {
        return 'Healthcare-Associated Infections (HAIs)';
      } else if (firstSentence.contains('compliance')) {
        return 'Compliance Impact';
      } else if (firstSentence.contains('healthcare workers')) {
        return 'Healthcare Worker Protection';
      } else if (firstSentence.contains('COVID-19') || firstSentence.contains('pandemic')) {
        return 'Pandemic Response';
      } else if (firstSentence.contains('transmission')) {
        return 'Pathogen Transmission';
      } else if (firstSentence.contains('impact') || firstSentence.contains('significant')) {
        return 'Clinical Impact';
      } else {
        // Extract first 50 chars and add ellipsis
        return '${firstSentence.substring(0, firstSentence.length > 50 ? 50 : firstSentence.length)}...';
      }
    }

    return firstSentence;
  }

  /// Determine color based on paragraph content
  Color _determineColorFromContent(String content) {
    final upperContent = content.toUpperCase();

    if (upperContent.contains('CRITICAL') ||
        upperContent.contains('DEATH') ||
        upperContent.contains('SIGNIFICANT') ||
        upperContent.contains('TENS OF THOUSANDS')) {
      return AppColors.error;
    } else if (upperContent.contains('IMPORTANT') ||
               upperContent.contains('CAUTION') ||
               upperContent.contains('PANDEMIC')) {
      return AppColors.warning;
    } else if (upperContent.contains('IMPROVE') ||
               upperContent.contains('REDUCE') ||
               upperContent.contains('PROTECT') ||
               upperContent.contains('EFFECTIVE')) {
      return AppColors.success;
    } else {
      return AppColors.info;
    }
  }

  /// Determine icon based on paragraph content
  IconData _determineIconFromContent(String content) {
    final upperContent = content.toUpperCase();

    if (upperContent.contains('DEATH') || upperContent.contains('CRITICAL')) {
      return Icons.warning_outlined;
    } else if (upperContent.contains('PROTECT') || upperContent.contains('WORKER')) {
      return Icons.shield_outlined;
    } else if (upperContent.contains('IMPROVE') || upperContent.contains('REDUCE')) {
      return Icons.trending_down;
    } else if (upperContent.contains('PANDEMIC') || upperContent.contains('COVID')) {
      return Icons.coronavirus_outlined;
    } else if (upperContent.contains('TRANSMISSION') || upperContent.contains('SPREAD')) {
      return Icons.sync_alt;
    } else if (upperContent.contains('COMPLIANCE')) {
      return Icons.check_circle_outline;
    } else {
      return Icons.info_outline;
    }
  }

  /// Build WHO 5 Moments card with color coding
  Widget _buildMomentCard(String content, int index) {
    // Extract moment number and details
    final momentMatch = RegExp(r'MOMENT (\d+):\s*(.+?)\s*-\s*(.+)').firstMatch(content);
    if (momentMatch == null) {
      // Fallback to StructuredContentCard
      return StructuredContentCard(
        icon: Icons.info_outline,
        heading: 'Information',
        color: AppColors.info,
        content: content,
      );
    }

    final momentNumber = momentMatch.group(1)!;
    final momentTitle = momentMatch.group(2)!;
    final momentDescription = momentMatch.group(3)!;

    // Color coding for different moments
    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.warning,
      AppColors.error,
      AppColors.success,
    ];
    final icons = [
      Icons.touch_app,
      Icons.medical_services,
      Icons.warning_amber,
      Icons.person,
      Icons.bed,
    ];

    final momentIndex = int.parse(momentNumber) - 1;
    final color = colors[momentIndex % colors.length];
    final icon = icons[momentIndex % icons.length];

    return StructuredContentCard(
      icon: icon,
      heading: 'MOMENT $momentNumber: $momentTitle',
      color: color,
      content: momentDescription,
    );
  }

  /// Build references card (AMS-style)
  Widget _buildReferencesCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.library_books,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'References',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_page!.references.length} official ${_page!.references.length == 1 ? 'source' : 'sources'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          ..._page!.references.asMap().entries.map((entry) {
            final index = entry.key;
            final ref = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _launchURL(ref.url),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ref.label,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        size: 18,
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Launch URL helper
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

