import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/back_button.dart';
import '../../data/models/bundle.dart';
import '../../data/models/bundle_category.dart';
import '../widgets/bundle_component_card.dart';

/// Detail screen for displaying a single care bundle.
/// 
/// Features:
/// - Bundle header with category color
/// - Components list
/// - Rationale section
/// - Implementation guide
/// - Key points
/// - References
/// - Share functionality
class BundleDetailScreen extends StatelessWidget {
  final Bundle bundle;

  const BundleDetailScreen({
    super.key,
    required this.bundle,
  });

  BundleCategory get _category => BundleCategory.fromString(bundle.category);

  void _onShareTap(BuildContext context) {
    final text = _buildShareText();
    Share.share(
      text,
      subject: bundle.name,
    );
  }

  String _buildShareText() {
    final buffer = StringBuffer();
    buffer.writeln('${bundle.name}\n');
    buffer.writeln('Category: ${_category.fullName}\n');
    buffer.writeln('Description: ${bundle.description}\n');
    buffer.writeln('\nComponents:');
    for (var i = 0; i < bundle.components.length; i++) {
      buffer.writeln('${i + 1}. ${bundle.components[i]}');
    }
    buffer.writeln('\nRationale:');
    buffer.writeln(bundle.rationale);
    buffer.writeln('\nImplementation:');
    buffer.writeln(bundle.implementation);
    if (bundle.keyPoints.isNotEmpty) {
      buffer.writeln('\nKey Points:');
      for (var point in bundle.keyPoints) {
        buffer.writeln('• $point');
      }
    }
    buffer.writeln('\n---');
    buffer.writeln('Shared from IPC Guider');
    return buffer.toString();
  }

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
    return Scaffold(
      appBar: AppBackAppBar(
        title: bundle.name,
        backgroundColor: _category.color,
        foregroundColor: Colors.white,
        elevation: 0,
        fitTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _onShareTap(context),
            tooltip: 'Share bundle',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.large, // Bottom padding for mobile
        ),
        children: [
          // Header card
          _buildHeaderCard(context),

          // Bundle Tools button
          const SizedBox(height: AppSpacing.medium),
          _buildBundleToolsButton(context),

          // Components section
          BundleSectionHeader(
            title: 'Components',
            subtitle: '${bundle.components.length} elements',
            icon: Icons.checklist_outlined,
            color: _category.color,
          ),
          ...bundle.components.asMap().entries.map((entry) {
            return BundleComponentCard(
              number: entry.key + 1,
              component: entry.value,
              color: _category.color,
            );
          }),

          // Rationale section
          BundleSectionHeader(
            title: 'Rationale',
            subtitle: 'Why this bundle matters',
            icon: Icons.lightbulb_outline,
            color: _category.color,
          ),
          _buildTextCard(context, bundle.rationale),

          // Implementation section
          BundleSectionHeader(
            title: 'Implementation',
            subtitle: 'How to apply this bundle',
            icon: Icons.settings_suggest_outlined,
            color: _category.color,
          ),
          _buildTextCard(context, bundle.implementation),

          // Key points section
          if (bundle.keyPoints.isNotEmpty) ...[
            BundleSectionHeader(
              title: 'Key Points',
              subtitle: '${bundle.keyPoints.length} important notes',
              icon: Icons.star_outline,
              color: _category.color,
            ),
            ...bundle.keyPoints.map((point) {
              return BundleKeyPointCard(
                keyPoint: point,
                color: _category.color,
              );
            }),
          ],

          // References section (inline display)
          if (bundle.references.isNotEmpty) ...[
            BundleSectionHeader(
              title: 'References',
              subtitle: '${bundle.references.length} official sources',
              icon: Icons.library_books_outlined,
              color: _category.color,
            ),
            _buildReferencesSection(context),
          ],

          const SizedBox(height: AppSpacing.large),
        ],
      ),
    );
  }

  Widget _buildBundleToolsButton(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/bundles/tools'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.info.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bundle Tools & Audits',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Access audit tools, gap analysis, and performance dashboards',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: _category.color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _category.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _category.color.withValues(alpha: 0.05),
              _category.color.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _category.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _category.color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _category.icon,
                    size: 16,
                    color: _category.color,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _category.fullName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _category.color,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.medium),

            // Description
            Text(
              bundle.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextCard(BuildContext context, String text) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.neutralLight.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
        ),
      ),
    );
  }

  Widget _buildReferencesSection(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _category.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // References list
            ...bundle.references.asMap().entries.map((entry) {
              final index = entry.key;
              final reference = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < bundle.references.length - 1
                      ? AppSpacing.small
                      : 0,
                ),
                child: _buildReferenceLink(context, reference, index + 1),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceLink(
    BuildContext context,
    BundleReference reference,
    int number,
  ) {
    return InkWell(
      onTap: () => _launchUrl(context, reference.url),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.small,
          horizontal: AppSpacing.extraSmall,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _category.color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _category.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.small),

            // Reference content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reference.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Open external link',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // External link icon
            Icon(
              Icons.link,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

