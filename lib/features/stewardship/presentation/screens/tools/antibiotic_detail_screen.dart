import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/design/design_tokens.dart';
import '../../../domain/models/antibiotic_spectrum.dart';

/// Detail screen showing comprehensive information about a single antibiotic
class AntibioticDetailScreen extends StatelessWidget {
  final AntibioticSpectrum antibiotic;
  final List<Organism> organisms;

  const AntibioticDetailScreen({
    super.key,
    required this.antibiotic,
    required this.organisms,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(antibiotic.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(AppSpacing.medium, AppSpacing.medium, AppSpacing.medium, bottomPadding + 64),
        children: [
          // Header Card
          _buildHeaderCard(context),
          const SizedBox(height: AppSpacing.medium),

          // Clinical Use Card
          if (antibiotic.clinicalUse != null) ...[
            _buildClinicalUseCard(context),
            const SizedBox(height: AppSpacing.medium),
          ],

          // Key Points Card
          if (antibiotic.keyPoints != null && antibiotic.keyPoints!.isNotEmpty) ...[
            _buildKeyPointsCard(context),
            const SizedBox(height: AppSpacing.medium),
          ],

          // Coverage Table Card
          _buildCoverageTableCard(context),
          const SizedBox(height: AppSpacing.medium),

          // References Card
          if (antibiotic.references.isNotEmpty) ...[
            _buildReferencesCard(context),
            const SizedBox(height: AppSpacing.large),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getSpectrumColor(antibiotic.spectrumBreadth).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medication,
                  color: _getSpectrumColor(antibiotic.spectrumBreadth),
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      antibiotic.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      antibiotic.genericName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                antibiotic.antibioticClass,
                Icons.category,
                AppColors.info,
              ),
              _buildBadge(
                antibiotic.spectrumBreadth.displayName,
                Icons.radar,
                _getSpectrumColor(antibiotic.spectrumBreadth),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSpectrumColor(SpectrumBreadth breadth) {
    switch (breadth) {
      case SpectrumBreadth.narrow:
        return AppColors.info;
      case SpectrumBreadth.extended:
        return AppColors.warning;
      case SpectrumBreadth.broad:
        return AppColors.error;
    }
  }

  Widget _buildClinicalUseCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Clinical Use',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              antibiotic.clinicalUse!,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyPointsCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Key Points',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...antibiotic.keyPoints!.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageTableCard(BuildContext context) {
    // Group organisms by category
    final Map<OrganismCategory, List<Organism>> groupedOrganisms = {};
    for (final organism in organisms) {
      groupedOrganisms.putIfAbsent(organism.category, () => []).add(organism);
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.grid_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Spectrum Coverage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...groupedOrganisms.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Text(
                      entry.key.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  ...entry.value.map((organism) {
                    final coverage = antibiotic.getCoverageFor(organism.id);
                    final notes = antibiotic.getCoverageNotesFor(organism.id);
                    return _buildCoverageRow(organism, coverage, notes);
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageRow(Organism organism, CoverageLevel? coverage, String? notes) {
    final color = _getCoverageColor(coverage);
    final icon = _getCoverageIcon(coverage);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  organism.commonName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  coverage?.displayName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              notes,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getCoverageColor(CoverageLevel? level) {
    if (level == null) return AppColors.neutral;
    switch (level) {
      case CoverageLevel.excellent:
        return AppColors.success;
      case CoverageLevel.good:
        return AppColors.info;
      case CoverageLevel.variable:
        return AppColors.warning;
      case CoverageLevel.poor:
        return const Color(0xFFFF9800); // Orange
      case CoverageLevel.none:
        return AppColors.error;
    }
  }

  IconData _getCoverageIcon(CoverageLevel? level) {
    if (level == null) return Icons.help_outline;
    switch (level) {
      case CoverageLevel.excellent:
        return Icons.check_circle;
      case CoverageLevel.good:
        return Icons.check;
      case CoverageLevel.variable:
        return Icons.warning_amber;
      case CoverageLevel.poor:
        return Icons.remove_circle_outline;
      case CoverageLevel.none:
        return Icons.cancel;
    }
  }

  Widget _buildReferencesCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Official References',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: antibiotic.references.map((ref) {
                return OutlinedButton.icon(
                  onPressed: () => _launchUrl(ref.url),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(
                    ref.label,
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: BorderSide(color: AppColors.info.withValues(alpha: 0.5)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

