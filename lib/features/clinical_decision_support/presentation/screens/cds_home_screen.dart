import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';
import '../../data/models/cds_category.dart';
import '../../data/repositories/cds_repository.dart';
import '../widgets/cds_category_card.dart';
import '../widgets/cds_search_bar.dart';

/// Clinical Decision Support Home Screen
class CDSHomeScreen extends StatefulWidget {
  const CDSHomeScreen({super.key});

  @override
  State<CDSHomeScreen> createState() => _CDSHomeScreenState();
}

class _CDSHomeScreenState extends State<CDSHomeScreen> {
  final CDSRepository _repository = CDSRepository();
  List<CDSCategory> _categories = [];
  List<CDSCategory> _filteredCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _repository.getAllCategories();
      setState(() {
        _categories = categories;
        _filteredCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _categories;
      } else {
        _filteredCategories = _categories.where((category) {
          return category.name.toLowerCase().contains(query.toLowerCase()) ||
              category.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clinical Decision Support'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Header section
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.85),
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
                          child: const Icon(
                            Icons.medical_information,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          'Evidence-Based Clinical Guidelines',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          'Comprehensive antibiotic therapy guidance for 100+ clinical syndromes',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.95),
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
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
                      hintText: 'Search conditions, syndromes, pathogens...',
                      onSearch: _onSearch,
                      onClear: () => _onSearch(''),
                    ),
                  ),
                ),

                // Categories list
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = _filteredCategories[index];
                        return CDSCategoryCard(
                          category: category,
                          onTap: () {
                            context.push('/cds/category/${category.id}');
                          },
                        );
                      },
                      childCount: _filteredCategories.length,
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

