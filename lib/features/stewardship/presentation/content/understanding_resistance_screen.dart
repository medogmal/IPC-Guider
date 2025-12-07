import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class UnderstandingResistanceScreen extends StatelessWidget {
  const UnderstandingResistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Understanding Antimicrobial Resistance'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.error,
            title: 'Understanding Antimicrobial Resistance',
            subtitle: 'Antimicrobial Resistance Mechanisms',
            description:
                'AMR is one of the top 10 global public health threats, causing 1.27 million deaths annually.',
          ),
          const SizedBox(height: 20),

          // Introduction Card
          IntroductionCard(
            text:
                'Antimicrobial resistance (AMR) occurs when bacteria, viruses, fungi, and parasites evolve to resist the effects of medications, making infections harder to treat and increasing the risk of disease spread, severe illness, and death. AMR is one of the top 10 global public health threats facing humanity, according to the World Health Organization.',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // Global Burden Card
          StructuredContentCard(
            heading: 'The Global Burden of AMR',
            content:
                '''The 2024 WHO Priority Pathogens List identifies 15 families of antibiotic-resistant bacteria that pose the greatest threat to human health.

• In the United States: More than 2.8 million antibiotic-resistant infections occur each year, resulting in more than 35,000 deaths
• Globally: AMR was directly responsible for 1.27 million deaths in 2019 and contributed to 4.95 million deaths
• Economic impact: AMR could result in \$1 trillion in additional healthcare costs by 2050 and reduce global GDP by \$1-3.4 trillion annually
• In the US alone: AMR adds \$20 billion in excess healthcare costs and \$35 billion in lost productivity each year''',
            icon: Icons.public,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),

          // Timeline Card - Special UI Element
          _buildTimelineCard(),
          const SizedBox(height: 16),

          // Resistance Development Card
          StructuredContentCard(
            heading: 'How Resistance Develops',
            content:
                '''Resistance develops through two main mechanisms:

• Spontaneous genetic mutations: Occur during DNA replication at a rate of approximately 1 in 10⁶ to 10⁹ cell divisions
• Horizontal gene transfer: Acquisition of resistance genes from other bacteria through plasmids, transposons, or bacteriophages

Once resistance emerges, selective pressure from antimicrobial use allows resistant strains to survive and proliferate while susceptible strains are eliminated.''',
            icon: Icons.biotech,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // Selective Pressure Card with Example
          _buildSelectivePressureCard(),
          const SizedBox(height: 16),

          // WHO Priority Tiers Card
          StructuredContentCard(
            heading: 'WHO Priority Pathogens List',
            content:
                '''The WHO categorizes antimicrobial resistance threats into three priority tiers:

CRITICAL PRIORITY:
• Carbapenem-resistant Acinetobacter baumannii
• Carbapenem-resistant Pseudomonas aeruginosa
• Carbapenem-resistant and ESBL-producing Enterobacterales

HIGH PRIORITY:
• Vancomycin-resistant Enterococcus faecium
• Methicillin-resistant Staphylococcus aureus (MRSA)
• Clarithromycin-resistant Helicobacter pylori
• Fluoroquinolone-resistant Campylobacter, Salmonella, Neisseria gonorrhoeae

MEDIUM PRIORITY:
• Penicillin-non-susceptible Streptococcus pneumoniae
• Ampicillin-resistant Haemophilus influenzae
• Fluoroquinolone-resistant Shigella''',
            icon: Icons.priority_high,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),

          // Economic Impact Card
          StructuredContentCard(
            heading: 'Economic & Healthcare Impact',
            content:
                '''Beyond the human toll, AMR threatens modern medicine:

• Surgeries, chemotherapy, organ transplants, and neonatal care all rely on effective antibiotics to prevent and treat infections
• The World Bank estimates AMR could result in \$1 trillion in additional healthcare costs by 2050
• AMR reduces global GDP by \$1-3.4 trillion annually
• In the United States, AMR adds \$20 billion in excess healthcare costs and \$35 billion in lost productivity each year''',
            icon: Icons.attach_money,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),

          // Prevention Strategies Card with Example
          _buildPreventionCard(),
          const SizedBox(height: 20),

          // Key Takeaways Card
          _buildKeyTakeawaysCard(),
          const SizedBox(height: 20),

          // References Card
          _buildReferencesCard(context),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timeline,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Historical Timeline: The Race Between Antibiotics and Resistance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            '1940s',
            'Penicillin introduced',
            'Penicillin resistance in S. aureus emerged within 4 years',
            AppColors.success,
          ),
          _buildTimelineItem(
            '1961',
            'Methicillin introduced',
            'MRSA (Methicillin-resistant S. aureus) reported just 2 years later',
            AppColors.warning,
          ),
          _buildTimelineItem(
            '1988',
            'Vancomycin widely used',
            'VRE (Vancomycin-resistant Enterococcus) emerged',
            AppColors.error,
          ),
          _buildTimelineItem(
            '1990s',
            'Carbapenems introduced',
            'CRE (Carbapenem-resistant Enterobacterales) first reported',
            AppColors.info,
          ),
          _buildTimelineItem(
            '2020s',
            'Present day',
            'Pan-drug-resistant organisms (resistant to all available antibiotics) documented',
            AppColors.error,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String year,
    String event,
    String resistance,
    Color color, {
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: color.withValues(alpha: 0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    year,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    resistance,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectivePressureCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.science,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Selective Pressure & Resistance Amplification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Antimicrobial use creates selective pressure that favors the survival and spread of resistant organisms. Key factors that amplify resistance include:',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            'Inappropriate antimicrobial use (wrong drug, dose, or duration)',
            AppColors.warning,
          ),
          _buildBulletPoint(
            'Overuse in healthcare and agriculture',
            AppColors.warning,
          ),
          _buildBulletPoint(
            'Inadequate infection prevention and control',
            AppColors.warning,
          ),
          _buildBulletPoint(
            'Poor sanitation and hygiene',
            AppColors.warning,
          ),
          _buildBulletPoint(
            'International travel and trade',
            AppColors.warning,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Example: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'A patient receiving broad-spectrum antibiotics for a viral infection eliminates susceptible gut flora, allowing resistant bacteria (such as C. difficile or VRE) to colonize and potentially cause infection.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreventionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Preventing Resistance Emergence',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'A multifaceted approach is required to prevent resistance:',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            'Antimicrobial stewardship programs to optimize use',
            AppColors.success,
          ),
          _buildBulletPoint(
            'Infection prevention and control to reduce transmission',
            AppColors.success,
          ),
          _buildBulletPoint(
            'Vaccination to prevent infections',
            AppColors.success,
          ),
          _buildBulletPoint(
            'Improved diagnostics for targeted therapy',
            AppColors.success,
          ),
          _buildBulletPoint(
            'Research and development of new antimicrobials and alternatives',
            AppColors.success,
          ),
          _buildBulletPoint(
            'Global surveillance and coordination',
            AppColors.success,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Success Story: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'Implementing a hospital-wide hand hygiene program combined with antimicrobial stewardship reduced MRSA infections by 50% and C. difficile infections by 40% in a 500-bed hospital.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'AMR causes 1.27 million deaths globally per year (2019 data)',
      'Resistance emerged rapidly after each new antibiotic introduction',
      'Two main mechanisms: genetic mutations and horizontal gene transfer',
      'Selective pressure from antimicrobial use drives resistance amplification',
      'WHO Priority Pathogens List: Critical, High, and Medium priority tiers',
      'Economic impact: \$1 trillion in healthcare costs by 2050',
      'Prevention requires stewardship, infection control, vaccination, and diagnostics',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1.5,
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
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Key Takeaways',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...keyPoints.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
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

  Widget _buildReferencesCard(BuildContext context) {
    final references = [
      {
        'label': 'WHO Priority Pathogens List 2024',
        'url':
            'https://www.who.int/news/item/17-05-2024-who-updates-list-of-drug-resistant-bacteria'
      },
      {
        'label': 'CDC Antibiotic Resistance Threats Report (2019)',
        'url': 'https://www.cdc.gov/drugresistance/biggest-threats.html'
      },
      {
        'label':
            'The Lancet: Global burden of bacterial antimicrobial resistance (2022)',
        'url':
            'https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(21)02724-0/fulltext'
      },
      {
        'label': 'WHO Global Action Plan on Antimicrobial Resistance (2015)',
        'url': 'https://www.who.int/publications/i/item/9789241509763'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1.5,
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
          const SizedBox(height: 16),
          ...references.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () async {
                  final url = Uri.parse(entry.value['url']!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: AppColors.info,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value['label']!,
                          style: const TextStyle(
                            color: AppColors.info,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

