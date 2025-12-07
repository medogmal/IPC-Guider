import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../data/models/pathogen_detail.dart';
import '../domain/providers/outbreak_group_providers.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;
  final String dataFile;
  final Color color;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.dataFile,
    required this.color,
  });

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? _expandedPathogenId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final groupDataAsync = ref.watch(groupDataProvider(widget.dataFile));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: groupDataAsync.when(
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
                  'Failed to load group data',
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
        data: (groupData) {
          final filteredPathogens = _searchQuery.isEmpty
              ? groupData.pathogens
              : groupData.pathogens.where((p) {
                  final query = _searchQuery.toLowerCase();
                  return p.name.toLowerCase().contains(query) ||
                      p.scientificName.toLowerCase().contains(query) ||
                      p.definition.toLowerCase().contains(query);
                }).toList();

          return SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
              children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search within group...',
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
              ),
              const SizedBox(height: 16),

              // Pathogen Count
              Text(
                '${filteredPathogens.length} pathogen${filteredPathogens.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Pathogens List
              if (filteredPathogens.isEmpty)
                Center(
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
                      ],
                    ),
                  ),
                )
              else
                ...filteredPathogens.map((pathogen) => _buildPathogenCard(pathogen)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPathogenCard(PathogenDetail pathogen) {
    final isExpanded = _expandedPathogenId == pathogen.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.coronavirus_outlined,
              color: widget.color,
              size: 32,
            ),
            title: Text(
              pathogen.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              pathogen.scientificName.isNotEmpty ? pathogen.scientificName : pathogen.definition,
              maxLines: isExpanded ? null : 2,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: widget.color,
            ),
            onTap: () {
              setState(() {
                _expandedPathogenId = isExpanded ? null : pathogen.id;
              });
            },
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pathogen.definition.isNotEmpty) ...[
                    Text(
                      pathogen.definition,
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/outbreak/groups/${widget.groupId}/pathogen/${pathogen.id}', extra: {
                        'pathogen': pathogen,
                        'groupName': widget.groupName,
                        'color': widget.color,
                      });
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('View Full Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      foregroundColor: Colors.white,
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
}

