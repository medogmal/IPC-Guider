import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design/design_tokens.dart';

class ThresholdsTriggersScreen extends StatelessWidget {
  const ThresholdsTriggersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thresholds & Triggers for Outbreak Investigation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),

      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header Card
            Container(
              width: double.infinity,
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
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.warning_amber_outlined,
                          color: AppColors.warning,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thresholds & Triggers for Outbreak Investigation',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Criteria for initiating outbreak investigation protocols',
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

            // 1. Numerical Thresholds
            _buildSection(
              '1. Numerical Thresholds',
              'A numerical threshold is reached when a specified number of epidemiologically linked cases of the same infection or organism arise within a defined time and unit, or when there is a sudden, statistically significant rise above background incidence.',
              [
                _buildThresholdItem(
                  '≥3 epidemiologically linked cases',
                  'Same infection/organism within a short period in the same unit',
                  'Example: 3 cases of MRSA bloodstream infections in ICU within 10 days',
                ),
                _buildThresholdItem(
                  'Sudden increase above baseline',
                  'Compared to historical facility/ward data',
                  'Example: Doubling of CRE cases compared to last month\'s baseline',
                ),
                _buildThresholdItem(
                  'Mortality or severe morbidity clusters',
                  'Associated with the same agent',
                  'Example: Multiple deaths in ICU patients within a week linked to the same organism',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. Epidemiological Triggers
            _buildSection(
              '2. Epidemiological Triggers',
              'Non-numerical, pattern-based signals that suggest an abnormal event; may include rare pathogens, unusual case presentations, or obvious clustering.',
              [
                _buildThresholdItem(
                  'Unusual or rare pathogens',
                  'Unexpected resistance or emerging infections',
                  'Example: A single confirmed case of cholera in a non-endemic area',
                ),
                _buildThresholdItem(
                  'Infections from uncommon sites',
                  'Unusual anatomical locations',
                  'Example: Burkholderia cepacia isolated from blood cultures across different wards',
                ),
                _buildThresholdItem(
                  'Clustering by time, place, or person',
                  'Linked to a unit, device, or exposure',
                  'Example: 4 ventilator-associated pneumonia cases in the same ward during one week',
                ),
                _buildThresholdItem(
                  'Pseudo-outbreak suspicion',
                  'Rise in positive cultures without clinical correlation',
                  'Example: Increase in Candida cultures due to lab reagent contamination',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. Organism-Specific Thresholds
            _buildOrganismThresholds(),

            const SizedBox(height: 24),

            // 4. Sentinel Single-Case Alerts
            _buildSentinelAlerts(),

            const SizedBox(height: 32),

            // References
            _buildReferences(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String definition, List<Widget> items) {
    return Container(
      width: double.infinity,
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
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Definition:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  definition,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildThresholdItem(String title, String description, String example) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              example,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.success,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganismThresholds() {
    return Container(
      width: double.infinity,
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
            '3. Organism-Specific Thresholds (Classification Matrix)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Definition:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pathogen-specific minimum case counts which trigger notification and mandatory investigation. Extracted directly from GDIPC (reflecting ministry and international standards).',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Class A
          _buildClassSection(
            'Class A (High-Risk Organisms: ≥8 cases)',
            AppColors.error,
            [
              'Acinetobacter baumannii complex (MDR, PDR, XDR) ≥8 cases',
              'Burkholderia cepacia ≥8 cases',
              'Klebsiella pneumoniae (CRKP, ESBL) ≥8 cases',
              'MRSA ≥8 cases',
              'Pseudomonas aeruginosa, Salmonella spp. ≥8 cases',
              'Clostridium difficile ≥8 cases',
              'VRE ≥8 cases',
              'Legionella pneumophila ≥8 cases',
              'Candida auris ≥8 cases',
              'COVID-19 ≥11 cases',
              'Not Known / Emerging Organism → any single case',
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Class B
          _buildClassSection(
            'Class B (Moderate Threshold: 3–7 cases trigger)',
            AppColors.warning,
            [
              'Acinetobacter baumannii complex (MDR, PDR, XDR) 5–7 cases',
              'MRSA, Pseudomonas aeruginosa 5–7 cases',
              'Clostridium difficile 5–7 cases',
              'VRE 5–7 cases',
              'Legionella pneumophila 3–7 cases',
              'Candida auris 5–7 cases',
              'Aspergillus spp. 3–4 cases',
              'COVID-19 6–10 cases',
              'MERS-CoV 3–5 cases',
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Class C
          _buildClassSection(
            'Class C (Minimum Threshold: 1–4 cases trigger)',
            AppColors.success,
            [
              'Acinetobacter baumannii complex (MDR, PDR, XDR) 2–4 cases',
              'MRSA, MDR Pseudomonas spp. 2–4 cases',
              'Clostridium difficile 2–4 cases',
              'VRE 2–4 cases',
              'Legionella pneumophila 1–2 cases',
              'Candida auris 1–4 cases',
              'Aspergillus spp. 1–2 cases',
              'COVID-19 2–5 cases',
              'MERS-CoV 1–2 cases',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassSection(String title, Color color, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSentinelAlerts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.1),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.priority_high,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '4. Sentinel Single-Case Alerts (Critical Red Flag)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Definition:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Immediate mandatory investigation upon one confirmed case of certain "notifiable" critical, emerging, or biothreat pathogens per CDC/WHO/GDIPC standards.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Critical High-Risk Pathogens:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          _buildSentinelItem(
            'MDR/XDR Mycobacterium tuberculosis',
            'Any confirmed case requires immediate investigation',
          ),
          _buildSentinelItem(
            'Category A bioterrorism agents',
            'Examples: Anthrax, Smallpox, Plague, Botulism, Tularemia, Viral hemorrhagic fevers',
          ),
          _buildSentinelItem(
            'Novel/emerging pathogens',
            'Example: Rift Valley Fever virus',
          ),
        ],
      ),
    );
  }

  Widget _buildSentinelItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: AppColors.error,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferences() {
    return Container(
      width: double.infinity,
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
              Icon(
                Icons.library_books_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'References',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReferenceButton(
            'GDIPC Healthcare-Associated Outbreak Management Manual 2023',
            'https://www.moh.gov.sa/Ministry/Rules/Documents/Healthcare-Associated-Outbreak-Management-Manual.pdf',
          ),
          const SizedBox(height: 8),
          _buildReferenceButton(
            'WHO Guidelines on Outbreak Investigation',
            'https://www.who.int/teams/control-of-neglected-tropical-diseases',
          ),
          const SizedBox(height: 8),
          _buildReferenceButton(
            'CDC Infection Control and Outbreak Investigation',
            'https://www.cdc.gov/outbreaks/index.html',
          ),
          const SizedBox(height: 8),
          _buildReferenceButton(
            'CDC MDRO Prevention and Control',
            'https://www.cdc.gov/infectioncontrol/hcp/mdro-management/prevention-control.html',
          ),
          const SizedBox(height: 8),
          _buildReferenceButton(
            'CDC Transmission-Based Precautions',
            'https://www.cdc.gov/infectioncontrol/basics/transmission-based-precautions.html',
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceButton(String title, String url) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _launchURL(url),
        icon: Icon(
          Icons.open_in_new,
          size: 16,
          color: AppColors.primary,
        ),
        label: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
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
