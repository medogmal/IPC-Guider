import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../domain/providers/outbreak_group_providers.dart';

class OutbreakGroupsScreen extends ConsumerStatefulWidget {
  const OutbreakGroupsScreen({super.key});

  @override
  ConsumerState<OutbreakGroupsScreen> createState() => _OutbreakGroupsScreenState();
}

class _OutbreakGroupsScreenState extends ConsumerState<OutbreakGroupsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final indexAsync = ref.watch(outbreakGroupsIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outbreak-Specific Groups'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: indexAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Failed to load outbreak groups',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        data: (index) => SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
            children: [
            // Section Header
            _buildSectionHeader(),
            const SizedBox(height: 16),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24),

            // Show search results if searching
            if (_searchQuery.isNotEmpty)
              _buildSearchResults()
            else
              // Show type groups
              ...index.types.map((type) => _buildTypeSection(type)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.biotech_outlined, color: AppColors.error, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Outbreak-Specific Groups',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Organized by pathogen type and clinical group',
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
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search pathogens...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildSearchResults() {
    final searchAsync = ref.watch(pathogenSearchProvider(_searchQuery));

    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Search failed: $error', style: TextStyle(color: AppColors.error)),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'No pathogens found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${results.length} result${results.length == 1 ? '' : 's'} found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ...results.map((result) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: IpcCard(
                    title: result.pathogen.name,
                    subtitle: '${result.groupName} • ${result.typeName}',
                    icon: Icons.coronavirus_outlined,
                    onTap: () {
                      // Navigate to pathogen detail
                      // TODO: Implement navigation
                    },
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildTypeSection(dynamic type) {
    final color = _parseColor(type.color as String);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(_getIconData(type.icon), color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                type.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Groups
        ...type.groups.map((group) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildGroupCard(group, color),
            )),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGroupCard(dynamic group, Color color) {
    return IpcCard(
      title: group.name,
      subtitle: '${group.pathogenCount} pathogen${group.pathogenCount == 1 ? '' : 's'}',
      icon: _getIconData(group.icon),
      onTap: () {
        context.push('/outbreak/groups/${group.id}', extra: {
          'group': group,
          'color': color,
        });
      },
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'bacteria':
        return Icons.biotech;
      case 'coronavirus':
      case 'virus':
        return Icons.coronavirus;
      case 'eco':
      case 'mushroom':
        return Icons.eco;
      case 'shield_moon':
        return Icons.shield;
      case 'air':
        return Icons.air;
      case 'restaurant':
        return Icons.restaurant;
      case 'healing':
        return Icons.healing;
      case 'psychology':
        return Icons.psychology;
      case 'warning':
        return Icons.warning;
      case 'water_drop':
        return Icons.water_drop;
      case 'bubble_chart':
        return Icons.bubble_chart;
      case 'grain':
        return Icons.grain;
      case 'change_circle':
        return Icons.change_circle;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.circle;
    }
  }
}

