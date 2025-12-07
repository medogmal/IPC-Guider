import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';
import '../../data/models/cds_category.dart';
import '../../data/models/cds_condition.dart';
import '../../data/repositories/cds_repository.dart';
import '../widgets/cds_condition_card.dart';
import '../widgets/cds_search_bar.dart';

/// Category detail screen showing conditions
class CDSCategoryScreen extends StatefulWidget {
  final String categoryId;

  const CDSCategoryScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<CDSCategoryScreen> createState() => _CDSCategoryScreenState();
}

class _CDSCategoryScreenState extends State<CDSCategoryScreen> {
  final CDSRepository _repository = CDSRepository();
  CDSCategory? _category;
  List<CDSCondition> _filteredConditions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    try {
      final category = await _repository.loadCategory(widget.categoryId);
      setState(() {
        _category = category;
        _filteredConditions = category.conditions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load category: $e')),
        );
      }
    }
  }

  void _onSearch(String query) {
    if (_category == null) return;

    setState(() {
      if (query.isEmpty) {
        _filteredConditions = _category!.conditions;
      } else {
        _filteredConditions = _category!.conditions.where((condition) {
          return condition.name.toLowerCase().contains(query.toLowerCase()) ||
              condition.shortDescription.toLowerCase().contains(query.toLowerCase()) ||
              condition.synonyms.any((syn) => syn.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_category?.name ?? 'Loading...'),
        backgroundColor: _category?.color ?? AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _category == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        'Failed to load category',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Category header
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.large),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _category!.color,
                              _category!.color.withValues(alpha: 0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.medium),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _category!.icon,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            Text(
                              _category!.description,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    height: 1.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.small),
                            Text(
                              '${_category!.conditions.length} conditions',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.large),
                        child: CDSSearchBar(
                          hintText: 'Search conditions in this category...',
                          onSearch: _onSearch,
                          onClear: () => _onSearch(''),
                        ),
                      ),
                    ),

                    // Conditions list
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final condition = _filteredConditions[index];
                            return CDSConditionCard(
                              condition: condition,
                              categoryColor: _category!.color,
                              categoryIcon: _category!.icon,
                              onTap: () {
                                context.push(
                                  '/cds/category/${widget.categoryId}/condition/${condition.id}',
                                );
                              },
                            );
                          },
                          childCount: _filteredConditions.length,
                        ),
                      ),
                    ),

                    // Bottom spacing
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.extraLarge),
                    ),
                  ],
                ),
    );
  }
}

