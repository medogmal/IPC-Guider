import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';

class DiseaseLevelsScreen extends StatelessWidget {
  const DiseaseLevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Levels of Disease'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          children: [
          // Header Card
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.trending_up_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Levels of Disease',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sporadic, Endemic, Epidemic, Pandemic',
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
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sporadic
          _buildLevelCard(
            title: 'Sporadic',
            definition: 'Cases occur irregularly and infrequently.',
            example: 'A single case of tetanus in a rural village.',
            color: AppColors.success,
            icon: Icons.scatter_plot_outlined,
          ),

          const SizedBox(height: 16),

          // Endemic
          _buildLevelCard(
            title: 'Endemic',
            definition: 'Constant presence of a disease within a geographic area or population.',
            example: 'Malaria in sub-Saharan Africa.',
            color: AppColors.warning,
            icon: Icons.location_on_outlined,
          ),

          const SizedBox(height: 16),

          // Epidemic/Outbreak
          _buildLevelCard(
            title: 'Epidemic/Outbreak',
            definition: 'Occurrence of cases in excess of what is normally expected in a defined community or region.',
            example: 'Norovirus outbreak in a nursing home.',
            color: AppColors.error,
            icon: Icons.trending_up_outlined,
          ),

          const SizedBox(height: 16),

          // Pandemic
          _buildLevelCard(
            title: 'Pandemic',
            definition: 'An epidemic occurring worldwide or over a very wide area, crossing international boundaries and affecting many people.',
            example: 'COVID-19 pandemic starting in 2019.',
            color: const Color(0xFF9C27B0), // Purple
            icon: Icons.public_outlined,
          ),

          const SizedBox(height: 16),

          // Cluster
          _buildLevelCard(
            title: 'Cluster',
            definition: 'An aggregation of cases grouped in place and time suspected to be greater than expected.',
            example: '3 cases of multidrug-resistant Klebsiella in one ICU ward within 3 weeks.',
            color: AppColors.info,
            icon: Icons.group_work_outlined,
          ),

          const SizedBox(height: 16),

          // Pseudo-outbreak
          _buildLevelCard(
            title: 'Pseudo-outbreak',
            definition: 'False increase in reported cases, usually due to contamination or laboratory error.',
            example: 'E.coli isolated from blood culture samples of asymptomatic patients, pseudo-outbreak traced to contaminated lab media.',
            color: AppColors.textTertiary,
            icon: Icons.error_outline,
          ),

          const SizedBox(height: 24),

          // References Section
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Official References',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildReferenceItem(
                  'CDC Principles of Epidemiology',
                  'https://www.cdc.gov/csels/dsepd/ss1978/',
                ),
                _buildReferenceItem(
                  'WHO Disease Outbreak Investigation',
                  'https://www.who.int/publications/i/item/WHO-HSE-GCR-LYO-2017.5',
                ),
                ],
              ),
            ),
            ],
          ),
        ),
    );
  }


  Widget _buildLevelCard({
    required String title,
    required String definition,
    required String example,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            definition,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Example:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  example,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(
                Icons.link_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Icon(
                Icons.open_in_new,
                color: AppColors.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error if needed
    }
  }
}
