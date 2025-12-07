import 'package:flutter/material.dart';
import '../../data/models/stewardship_section.dart';
import '../../../../core/design/design_tokens.dart';

/// Card widget for displaying an antimicrobial stewardship page in the list
class StewardshipPageCard extends StatelessWidget {
  final StewardshipPage page;
  final VoidCallback onTap;

  const StewardshipPageCard({
    super.key,
    required this.page,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get first paragraph as preview (limit to 150 characters)
    final preview = page.content.isNotEmpty
        ? (page.content.first.length > 150
            ? '${page.content.first.substring(0, 150)}...'
            : page.content.first)
        : 'No content available';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.1), // Purple
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: Color(0xFF9C27B0), // Purple
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      preview,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

