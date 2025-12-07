import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/navigation/navigation_state_manager.dart';
import '../../../core/widgets/back_button.dart';
import '../domain/organism_precaution.dart';
import '../data/isolation_providers.dart';

class IsolationListScreen extends ConsumerStatefulWidget {
  const IsolationListScreen({super.key});

  static const _types = [
    'All',
    'Airborne',
    'Droplet',
    'Contact',
    'Contact-Enteric',
  ];

  @override
  ConsumerState<IsolationListScreen> createState() => _IsolationListScreenState();
}

class _IsolationListScreenState extends ConsumerState<IsolationListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _restoreState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _restoreState() {
    final savedState = ref.getNavigationState('/isolation');
    if (savedState != null) {
      // Restore search query
      if (savedState.containsKey('searchQuery')) {
        _searchController.text = savedState['searchQuery'];
        ref.read(isolationFilterProvider.notifier).state = 
            ref.read(isolationFilterProvider).copyWith(query: savedState['searchQuery']);
      }

      // Restore filters
      if (savedState.containsKey('filters')) {
        final filters = savedState['filters'] as Map<String, dynamic>;
        // Apply filters to the provider
        if (filters.containsKey('type')) {
          ref.read(isolationFilterProvider.notifier).state = 
              ref.read(isolationFilterProvider).copyWith(type: filters['type']);
        }
      }
    }
  }

  void _saveState() {
    final state = {
      'searchQuery': _searchController.text,
      'filters': {
        'type': ref.read(isolationFilterProvider).type,
      },
    };

    ref.saveNavigationState('/isolation', state);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(isolationFilteredProvider);
    final filter = ref.watch(isolationFilterProvider);

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'Isolation & PPE',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search organism/condition...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (q) {
                    ref.read(isolationFilterProvider.notifier).state = 
                        filter.copyWith(query: q);
                    _saveState();
                  },
                ),
                const SizedBox(height: 8),

                // Filters + Actions row
                Row(
                  children: [
                    // Filter chips
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: IsolationListScreen._types.map((t) {
                            final isAll = t == 'All';
                            final selected = (filter.type == null && isAll) ||
                                (filter.type == t && !isAll);

                            final bgColor = isAll
                                ? (selected
                                    ? Colors.grey.withValues(alpha: 0.25)
                                    : Colors.grey.withValues(alpha: 0.12))
                                : t.isolationColor.withValues(alpha: selected ? 0.25 : 0.12);

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: ChoiceChip(
                                label: Text(t),
                                selected: selected,
                                selectedColor: bgColor,
                                onSelected: (_) {
                                  final notifier =
                                      ref.read(isolationFilterProvider.notifier);
                                  if (isAll) {
                                    // Reset to "All"
                                    notifier.state = filter.copyWith(setTypeNull: true);
                                  } else if (filter.type == t) {
                                    // Toggle off -> back to "All"
                                    notifier.state = filter.copyWith(setTypeNull: true);
                                  } else {
                                    notifier.state = filter.copyWith(type: t);
                                  }
                                  _saveState();
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Actions: Start Quiz + General Principles
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 32,
                          child: FilledButton.icon(
                            onPressed: () => context.go('/quiz/isolation'),
                            icon: const Icon(Icons.play_arrow, size: 14),
                            label: const Text('Quiz', style: TextStyle(fontSize: 11)),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 120,
                          height: 32,
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/isolation/principles'),
                            icon: const Icon(Icons.menu_book_outlined, size: 14),
                            label: const Text('Principles', style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Results list
          Expanded(
            child: filtered.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('No results'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final o = items[i];
                        return _OrganismTile(item: o);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganismTile extends StatelessWidget {
  final OrganismPrecaution item;
  const _OrganismTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final chips = item.isolationTypes
        .map((t) => Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: t.isolationColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(t, style: const TextStyle(fontSize: 12)),
            ))
        .toList();

    return ListTile(
      title: Text(item.organism),
      subtitle: Wrap(children: chips),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/isolation/${item.id}'),
    );
  }
}
