import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../data/models/cds_category.dart';
import '../../data/models/cds_condition.dart';
import '../../data/repositories/cds_repository.dart';

/// Condition detail screen with tabbed sections
class CDSConditionDetailScreen extends StatefulWidget {
  final String categoryId;
  final String conditionId;

  const CDSConditionDetailScreen({
    super.key,
    required this.categoryId,
    required this.conditionId,
  });

  @override
  State<CDSConditionDetailScreen> createState() => _CDSConditionDetailScreenState();
}

class _CDSConditionDetailScreenState extends State<CDSConditionDetailScreen>
    with SingleTickerProviderStateMixin {
  final CDSRepository _repository = CDSRepository();
  CDSCategory? _category;
  CDSCondition? _condition;
  bool _isLoading = true;
  late TabController _tabController;

  final List<Map<String, dynamic>> _tabs = [
    {'id': 'overview', 'label': 'Overview', 'icon': Icons.info_outline},
    {'id': 'diagnostics', 'label': 'Diagnostics', 'icon': Icons.science_outlined},
    {'id': 'microbiology', 'label': 'Microbiology', 'icon': Icons.biotech_outlined},
    {'id': 'empiric', 'label': 'Empiric Rx', 'icon': Icons.medication_outlined},
    {'id': 'definitive', 'label': 'Definitive Rx', 'icon': Icons.check_circle_outline},
    {'id': 'duration', 'label': 'Duration', 'icon': Icons.schedule_outlined},
    {'id': 'special', 'label': 'Special', 'icon': Icons.warning_amber_outlined},
    {'id': 'stewardship', 'label': 'Stewardship', 'icon': Icons.verified_outlined},
    {'id': 'references', 'label': 'References', 'icon': Icons.library_books_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadCondition();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCondition() async {
    try {
      final category = await _repository.loadCategory(widget.categoryId);
      final condition = category.conditions.firstWhere(
        (c) => c.id == widget.conditionId,
      );

      setState(() {
        _category = category;
        _condition = condition;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load condition: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _condition == null
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
                        'Condition not found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      // App bar with condition name
                      SliverAppBar(
                        title: Text(_condition!.name),
                        backgroundColor: _category?.color ?? AppColors.primary,
                        foregroundColor: Colors.white,
                        pinned: true,
                        floating: true,
                        elevation: 0,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.bookmark_border),
                            onPressed: () {
                              // TODO: Implement favorites
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              // TODO: Implement share
                            },
                          ),
                        ],
                      ),

                      // Tab bar
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverTabBarDelegate(
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelColor: _category?.color ?? AppColors.primary,
                            unselectedLabelColor: AppColors.textSecondary,
                            indicatorColor: _category?.color ?? AppColors.primary,
                            indicatorWeight: 3,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                            tabs: _tabs.map((tab) {
                              return Tab(
                                icon: Icon(tab['icon'] as IconData, size: 20),
                                text: tab['label'] as String,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tab) {
                      return _buildTabContent(tab['id'] as String);
                    }).toList(),
                  ),
                ),
    );
  }

  Widget _buildTabContent(String tabId) {
    // Get section data
    final section = _condition?.sections[tabId];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: AppSpacing.large,
        right: AppSpacing.large,
        top: AppSpacing.large,
        bottom: AppSpacing.extraLarge + 16, // 48px bottom padding for better mobile UX
      ),
      child: section != null
          ? (tabId == 'references'
              ? _buildReferencesContent(section.references)
              : _buildSectionContent(section.content))
          : Center(
              child: Text(
                'Content coming soon',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
    );
  }

  Widget _buildReferencesContent(List<dynamic> references) {
    if (references.isEmpty) {
      return Center(
        child: Text(
          'No references available',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: references.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final ref = entry.value;
        final label = ref.label ?? '';
        final url = ref.url ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.medium),
          child: InkWell(
            onTap: url.isNotEmpty
                ? () async {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reference number
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  // Reference content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (url.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            url,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // External link icon
                  if (url.isNotEmpty)
                    Icon(
                      Icons.open_in_new,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionContent(Map<String, dynamic> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;

        if (value is String) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: _buildContentCard(
              title: _formatTitle(key),
              content: value,
            ),
          );
        } else if (value is List) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: _buildContentCard(
              title: _formatTitle(key),
              content: value.map((e) => '• $e').join('\n'),
            ),
          );
        } else if (value is Map) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: _buildNestedContent(key, value as Map<String, dynamic>),
          );
        }

        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildContentCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_category?.color ?? AppColors.primary).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNestedContent(String title, Map<String, dynamic> content) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_category?.color ?? AppColors.primary).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTitle(title),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _category?.color ?? AppColors.primary,
                ),
          ),
          const SizedBox(height: AppSpacing.small),
          ...content.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.small),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatTitle(entry.key),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.extraSmall),
                  Text(
                    entry.value.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatTitle(String key) {
    // Medical abbreviations that should be ALL CAPS
    final abbreviations = {
      'hiv', 'aids', 'cd4', 'cd8', 'po', 'iv', 'im', 'sc', 'sq', 'pr', 'sl',
      'tid', 'bid', 'qid', 'qd', 'qhs', 'prn', 'mdro', 'mrsa', 'mssa', 'esbl',
      'cre', 'vre', 'kpc', 'hcv', 'hbv', 'crp', 'esr', 'wbc', 'rbc', 'cbc',
      'bmp', 'cmp', 'pct', 'pcr', 'naat', 'mic', 'ct', 'mri', 'cxr', 'pet',
      'icu', 'ed', 'or', 'cap', 'hap', 'vap', 'hcap', 'copd', 'aecopd', 'cf',
      'uti', 'ssi', 'clabsi', 'cauti', 'cns', 'gi', 'gu', 'ent', 'lft', 'lfts',
      'abg', 'vbg', 'bal', 'ams', 'ast', 'alt', 'idsa', 'ats', 'cdc', 'who',
      'clsi', 'eucast', 'tmp', 'smx', 'pe', 'dvt', 'mi', 'chf', 'dm', 'htn',
      'ckd', 'esrd', 'ppe', 'ppd', 'tb', 'cmv', 'pcp', 'rsv', 'ntm', 'abpa',
      'ivdu', 'urti', 'niv', 'xdr', 'npv', 'fev1', 'saba', 'sama', 'laba',
      'gerd', 'ra', 'ana', 'bnp', 'igg', 'igm', 'iga', 'igg4', 'hla', 'dna',
      'rna', 'eia', 'elisa', 'rdt', 'csf', 'bun', 'inr', 'pt', 'ptt', 'aptt',
      'ldh', 'cpk', 'ck', 'tsh', 'ft4', 'ft3', 'acth', 'lh', 'fsh', 'hcg',
      'psa', 'afp', 'cea', 'ca', 'ekg', 'ecg', 'echo', 'tee', 'tte', 'us',
      'heent', 'cv', 'resp', 'msk', 'neuro', 'psych', 'derm',
      'q', 'h', 'mg', 'g', 'kg', 'ml', 'l', 'mcg', 'ng', 'iu', 'meq',
    };

    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          final lowerWord = word.toLowerCase();
          // Check if it's a medical abbreviation
          if (abbreviations.contains(lowerWord)) {
            return word.toUpperCase();
          }
          // Otherwise, capitalize first letter only
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

/// Sliver tab bar delegate for pinned tabs
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

