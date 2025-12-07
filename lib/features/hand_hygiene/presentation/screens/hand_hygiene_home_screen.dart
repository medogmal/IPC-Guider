import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/hand_hygiene_section.dart';
import '../../data/repositories/hand_hygiene_repository.dart';
import '../widgets/hand_hygiene_section_card.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';

/// Home screen for Hand Hygiene module
/// Displays list of sections with search and category filtering
class HandHygieneHomeScreen extends StatefulWidget {
  const HandHygieneHomeScreen({super.key});

  @override
  State<HandHygieneHomeScreen> createState() => _HandHygieneHomeScreenState();
}

class _HandHygieneHomeScreenState extends State<HandHygieneHomeScreen> {
  final _repository = HandHygieneRepository();
  final _searchController = TextEditingController();

  List<HandHygieneSection> _allSections = [];
  List<HandHygieneSection> _filteredSections = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sections = await _repository.getAllSections();
      final categories = await _repository.getCategories();

      setState(() {
        _allSections = sections;
        _filteredSections = sections;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load hand hygiene data: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      // Start with all sections
      var filtered = _allSections;

      // Apply category filter
      if (_selectedCategory != 'All') {
        filtered = filtered
            .where((section) => section.category == _selectedCategory)
            .toList();
      }

      // Apply search filter
      final query = _searchController.text.toLowerCase();
      if (query.isNotEmpty) {
        filtered = filtered.where((section) {
          // Search in section name and description
          final nameMatch = section.name.toLowerCase().contains(query);
          final descMatch = section.description.toLowerCase().contains(query);

          // Search in page names and content
          final pageMatch = section.pages.any((page) {
            return page.name.toLowerCase().contains(query) ||
                page.content.any((c) => c.toLowerCase().contains(query)) ||
                page.keyPoints.any((k) => k.toLowerCase().contains(query));
          });

          return nameMatch || descMatch || pageMatch;
        }).toList();
      }

      _filteredSections = filtered;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Hand Hygiene',
        elevation: 0,
      ),
      body: Column(
        children: [
          // Compact Header with quiz button (reduced size, subtle styling)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                Row(
                  children: [
                    Icon(
                      Icons.clean_hands,
                      color: AppColors.success,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hand Hygiene',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Moments, technique, and compliance',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Quiz button
                    SizedBox(
                      width: 100,
                      height: 32,
                      child: FilledButton.icon(
                        onPressed: () => context.go('/quiz/hand_hygiene'),
                        icon: const Icon(Icons.play_arrow, size: 14),
                        label: const Text('Quiz', style: TextStyle(fontSize: 11)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search bar (compact)
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search sections and pages...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category filter chips
          if (_categories.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.small,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.small),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) => _onCategorySelected(category),
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Content
          Expanded(
            child: _buildContent(bottomPadding),
          ),
        ],
      ),
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
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredSections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'No sections found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Try adjusting your search or filters',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      itemCount: _filteredSections.length + 1, // +1 for Interactive Tools button
      itemBuilder: (context, index) {
        // First item is the Interactive Tools button
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: _buildInteractiveToolsButton(context),
          );
        }

        // Remaining items are sections
        final sectionIndex = index - 1;
        final section = _filteredSections[sectionIndex];
        return HandHygieneSectionCard(
          section: section,
          onTap: () {
            context.push('/hand-hygiene/section/${section.id}');
          },
        );
      },
    );
  }

  Widget _buildInteractiveToolsButton(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/hand-hygiene/tools'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                AppColors.success.withValues(alpha: 0.1),
                AppColors.info.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_fix_high,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interactive Tools',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'WHO observation tool, product usage tracker & more',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.success,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

