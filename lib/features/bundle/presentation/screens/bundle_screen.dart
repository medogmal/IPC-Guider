import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../data/models/bundle.dart';
import '../../data/models/bundle_category.dart';
import '../../data/repositories/bundle_repository.dart';
import '../widgets/bundle_list_item.dart';
import '../widgets/bundle_category_chip.dart';

/// Main screen for displaying the list of care bundles.
/// 
/// Features:
/// - Search functionality
/// - Category filtering with chips
/// - Loading/empty/error states
/// - Navigation to bundle details
class BundleScreen extends StatefulWidget {
  const BundleScreen({super.key});

  @override
  State<BundleScreen> createState() => _BundleScreenState();
}

class _BundleScreenState extends State<BundleScreen> {
  final _repository = BundleRepository();
  final _searchController = TextEditingController();
  
  BundleCategory _selectedCategory = BundleCategory.all;
  String _searchQuery = '';
  
  List<Bundle>? _allBundles;
  List<Bundle>? _filteredBundles;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBundles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBundles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bundles = await _repository.getAllBundles();
      setState(() {
        _allBundles = bundles;
        _filteredBundles = bundles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    if (_allBundles == null) return;

    List<Bundle> filtered = _allBundles!;

    // Apply category filter
    if (_selectedCategory != BundleCategory.all) {
      final categoryString = _selectedCategory.toJsonString();
      filtered = filtered
          .where((b) => b.category.toLowerCase() == categoryString.toLowerCase())
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((bundle) {
        return bundle.name.toLowerCase().contains(lowerQuery) ||
            bundle.description.toLowerCase().contains(lowerQuery) ||
            bundle.category.toLowerCase().contains(lowerQuery) ||
            bundle.components.any(
                (component) => component.toLowerCase().contains(lowerQuery)) ||
            bundle.keyPoints
                .any((keyPoint) => keyPoint.toLowerCase().contains(lowerQuery));
      }).toList();
    }

    setState(() {
      _filteredBundles = filtered;
    });
  }

  void _onCategorySelected(BundleCategory category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onBundleTap(Bundle bundle) {
    context.push('/bundles/detail', extra: bundle);
  }

  int _getCategoryCount(BundleCategory category) {
    if (_allBundles == null) return 0;

    if (category == BundleCategory.all) {
      return _allBundles!.length;
    }

    final categoryString = category.toJsonString();
    return _allBundles!
        .where((bundle) =>
            bundle.category.toLowerCase() == categoryString.toLowerCase())
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Care Bundles',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              AppSpacing.medium,
              AppSpacing.medium,
              AppSpacing.small,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search bundles...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.neutralLight,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.neutralLight,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
              children: BundleCategory.values.map((category) {
                final count = _allBundles != null
                    ? _getCategoryCount(category)
                    : null;

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.small),
                  child: BundleCategoryChip(
                    category: category,
                    isSelected: _selectedCategory == category,
                    onTap: () => _onCategorySelected(category),
                    count: count,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.small),

          // Quiz Button (matching isolation & calculator style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  height: 32,
                  child: FilledButton.icon(
                    onPressed: () => context.go('/quiz/bundles'),
                    icon: const Icon(Icons.play_arrow, size: 14),
                    label: const Text('Quiz', style: TextStyle(fontSize: 11)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.small),

          // Content area
          Expanded(
            child: _buildContent(bottomPadding),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(double bottomPadding) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_filteredBundles == null || _filteredBundles!.isEmpty) {
      return _buildEmptyState();
    }

    return _buildBundleList(bottomPadding);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.medium),
          Text(
            'Loading bundles...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
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
              'Failed to load bundles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              _error ?? 'Unknown error',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton.icon(
              onPressed: _loadBundles,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty;
    final isFiltering = _selectedCategory != BundleCategory.all;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.checklist_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              isSearching ? 'No bundles found' : 'No bundles available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              isSearching
                  ? 'Try a different search term or filter'
                  : 'Bundle data is not available',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSearching || isFiltering) ...[
              const SizedBox(height: AppSpacing.large),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = BundleCategory.all;
                  });
                  _applyFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBundleList(double bottomPadding) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      itemCount: _filteredBundles!.length + 1, // +1 for tools card
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.medium),
      itemBuilder: (context, index) {
        // First item is the tools card
        if (index == 0) {
          return _buildBundleToolsCard(context);
        }

        // Remaining items are bundles
        final bundleIndex = index - 1;
        final bundle = _filteredBundles![bundleIndex];
        return BundleListItem(
          bundle: bundle,
          onTap: () => _onBundleTap(bundle),
        );
      },
    );
  }

  Widget _buildBundleToolsCard(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/bundles/tools'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.large),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.info.withValues(alpha: 0.08),
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
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_fix_high,
                  color: AppColors.primary,
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
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Audit tools, gap analysis, risk assessment & dashboards',
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
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

