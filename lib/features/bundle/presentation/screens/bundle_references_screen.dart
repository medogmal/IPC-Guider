import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../data/models/bundle.dart';
import '../../data/models/bundle_category.dart';

/// Screen for displaying bundle references with external links.
/// 
/// Features:
/// - List of official references
/// - External link launching
/// - Error handling for link failures
/// - Accessibility support
class BundleReferencesScreen extends StatelessWidget {
  final Bundle bundle;

  const BundleReferencesScreen({
    super.key,
    required this.bundle,
  });

  BundleCategory get _category => BundleCategory.fromString(bundle.category);

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Cannot open this link');
        }
        return;
      }

      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to open link: $e');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'References',
        backgroundColor: _category.color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: _category.color.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(
                  color: _category.color.withValues(alpha: 0.2),
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
                      _category.icon,
                      size: 20,
                      color: _category.color,
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      child: Text(
                        bundle.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  '${bundle.references.length} official reference${bundle.references.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          // References list
          Expanded(
            child: bundle.references.isEmpty
                ? _buildEmptyState(context)
                : _buildReferencesList(context, bottomPadding),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'No References Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'This bundle does not have any references yet',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferencesList(BuildContext context, double bottomPadding) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
      itemCount: bundle.references.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.small),
      itemBuilder: (context, index) {
        final reference = bundle.references[index];
        return _buildReferenceCard(context, reference, index + 1);
      },
    );
  }

  Widget _buildReferenceCard(
    BuildContext context,
    BundleReference reference,
    int number,
  ) {
    return Card(
      elevation: 1,
      shadowColor: AppColors.textSecondary.withValues(alpha: 0.1),
      surfaceTintColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.neutralLight.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _launchUrl(context, reference.url),
        child: Semantics(
          button: true,
          label: 'Reference $number: ${reference.label}. Tap to open external link.',
          hint: 'Opens in external browser',
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number indicator
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _category.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _category.color,
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
                        reference.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.extraSmall),
                      Row(
                        children: [
                          Icon(
                            Icons.open_in_new,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Open external link',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

