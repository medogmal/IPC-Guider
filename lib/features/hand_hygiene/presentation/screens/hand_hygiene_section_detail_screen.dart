import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/hand_hygiene_section.dart';
import '../../data/repositories/hand_hygiene_repository.dart';
import '../widgets/hand_hygiene_page_card.dart';
import '../../../../core/design/design_tokens.dart';

/// Screen displaying list of pages within a hand hygiene section
class HandHygieneSectionDetailScreen extends StatefulWidget {
  final String sectionId;

  const HandHygieneSectionDetailScreen({
    super.key,
    required this.sectionId,
  });

  @override
  State<HandHygieneSectionDetailScreen> createState() =>
      _HandHygieneSectionDetailScreenState();
}

class _HandHygieneSectionDetailScreenState
    extends State<HandHygieneSectionDetailScreen> {
  final _repository = HandHygieneRepository();

  HandHygieneSection? _section;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSection();
  }

  Future<void> _loadSection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final section = await _repository.getSectionById(widget.sectionId);

      if (section == null) {
        setState(() {
          _errorMessage = 'Section not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _section = section;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load section: $e';
        _isLoading = false;
      });
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fundamentals':
        return Icons.school_outlined;
      case 'techniques':
        return Icons.pan_tool_outlined;
      case 'compliance monitoring':
        return Icons.assessment_outlined;
      case 'infrastructure & products':
        return Icons.build_outlined;
      case 'special situations':
        return Icons.warning_amber_outlined;
      default:
        return Icons.clean_hands_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fundamentals':
        return AppColors.primary;
      case 'techniques':
        return AppColors.success;
      case 'compliance monitoring':
        return AppColors.info;
      case 'infrastructure & products':
        return AppColors.warning;
      case 'special situations':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(_section?.name ?? 'Section'),
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
                onPressed: _loadSection,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_section == null) {
      return const Center(child: Text('Section not found'));
    }

    final categoryColor = _getCategoryColor(_section!.category);
    final categoryIcon = _getCategoryIcon(_section!.category);

    return Column(
      children: [
        // Compact Header (reduced size, no colored background, no page count chip)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              bottom: BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _section!.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _section!.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Pages list
        Expanded(
          child: _section!.pages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          'No pages available',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
                  itemCount: _section!.pages.length,
                  itemBuilder: (context, index) {
                    final page = _section!.pages[index];
                    return HandHygienePageCard(
                      page: page,
                      onTap: () {
                        context.push(
                          '/hand-hygiene/section/${widget.sectionId}/page/${page.id}',
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

