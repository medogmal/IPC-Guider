import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/stewardship_section.dart';
import '../../data/repositories/stewardship_repository.dart';
import '../widgets/stewardship_page_card.dart';
import '../../../../core/design/design_tokens.dart';

/// Screen displaying list of pages within an antimicrobial stewardship section
class StewardshipSectionDetailScreen extends StatefulWidget {
  final String sectionId;

  const StewardshipSectionDetailScreen({
    super.key,
    required this.sectionId,
  });

  @override
  State<StewardshipSectionDetailScreen> createState() =>
      _StewardshipSectionDetailScreenState();
}

class _StewardshipSectionDetailScreenState
    extends State<StewardshipSectionDetailScreen> {
  final _repository = StewardshipRepository();

  StewardshipSection? _section;
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

    return Column(
      children: [
        // Section header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              bottom: BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _section!.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                _section!.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: AppSpacing.small),
              Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_section!.pages.length} ${_section!.pages.length == 1 ? 'page' : 'pages'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
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
                    return StewardshipPageCard(
                      page: page,
                      onTap: () {
                        context.push(
                          '/stewardship/section/${widget.sectionId}/page/${page.id}',
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

