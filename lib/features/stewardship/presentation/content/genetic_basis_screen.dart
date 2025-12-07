import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class GeneticBasisScreen extends StatelessWidget {
  const GeneticBasisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Genetic Basis of Resistance'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.biotech,
            iconColor: AppColors.info,  // Blue: Genetic basis
            title: 'Genetic Basis of Resistance',
            subtitle: 'Antimicrobial Resistance Mechanisms',
            description:
                'Understanding how resistance genes are acquired and spread through bacterial populations.',
          ),
          const SizedBox(height: 20),

          // Introduction Card
          IntroductionCard(
            text:
                'Antimicrobial resistance genes can be acquired through two main pathways: vertical gene transfer (inheritance from parent to daughter cells during replication) via chromosomal mutations, and horizontal gene transfer (HGT) - the acquisition of genetic material from other bacteria. HGT is the primary driver of rapid resistance spread and is responsible for most clinically significant multidrug-resistant organisms.',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // Two Pathways Card
          _buildTwoPathwaysCard(),
          const SizedBox(height: 16),

          // Chromosomal Mutations Card
          StructuredContentCard(
            heading: 'Chromosomal Mutations',
            content:
                '''Spontaneous mutations occur during DNA replication at a rate of approximately 1 in 10⁶ to 10⁹ cell divisions. While most mutations are neutral or deleterious, some confer survival advantages under antimicrobial pressure.

Examples include:
• Fluoroquinolone resistance: mutations in gyrA and parC genes (encoding DNA gyrase and topoisomerase IV)
• Rifampin resistance: mutations in rpoB gene (encoding RNA polymerase)
• Streptomycin resistance: mutations in rpsL gene (encoding ribosomal protein S12)

Chromosomal mutations are typically passed vertically to daughter cells and cannot be transferred horizontally.''',
            icon: Icons.biotech,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // HGT Diagram Card - Special UI Element
          _buildHGTDiagramCard(),
          const SizedBox(height: 16),

          // Plasmids Card with Example
          _buildPlasmidsCard(),
          const SizedBox(height: 16),

          // Plasmid Types Card
          StructuredContentCard(
            heading: 'Clinically Important Plasmid Types',
            content:
                '''Plasmids are classified by incompatibility (Inc) groups based on replication mechanisms:

• IncF plasmids: Most common in Enterobacterales, carry ESBLs (blaCTX-M) and carbapenemases (blaNDM)
• IncA/C plasmids: Broad host range, carry blaCMY genes
• IncN plasmids: Carry blaKPC genes
• IncX plasmids: Carry blaNDM genes

Some plasmids are conjugative (self-transmissible), while others require helper plasmids for transfer.''',
            icon: Icons.category,
            color: AppColors.info,
          ),
          const SizedBox(height: 16),

          // Transposons Card
          _buildTransposonsCard(),
          const SizedBox(height: 16),

          // Integrons Card
          StructuredContentCard(
            heading: 'Integrons: Gene Cassette Capture Systems',
            content:
                '''Integrons are genetic elements that capture and express gene cassettes, often containing resistance genes. Class 1 integrons are the most clinically significant, found in over 50% of Gram-negative clinical isolates.

They typically carry genes encoding resistance to:
• Aminoglycosides (aadA - streptomycin resistance)
• Trimethoprim (dfrA genes)
• Beta-lactams
• Quaternary ammonium compounds (qacE)

Integrons are often located on plasmids or transposons, facilitating their spread.''',
            icon: Icons.view_module,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),

          // Resistance Gene Reservoirs Card with Example
          _buildReservoirsCard(),
          const SizedBox(height: 16),

          // Clinical Implications Card
          _buildClinicalImplicationsCard(),
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

  Widget _buildTwoPathwaysCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Vertical vs horizontal
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
                  Icons.alt_route,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Two Pathways of Resistance Acquisition',
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
          _buildPathwayRow(
            '1',
            'Vertical Gene Transfer',
            'Chromosomal mutations passed from parent to daughter cells',
            'Slower spread, cannot transfer between species',
            AppColors.info,
            Icons.arrow_downward,
          ),
          const SizedBox(height: 12),
          _buildPathwayRow(
            '2',
            'Horizontal Gene Transfer (HGT)',
            'Acquisition of resistance genes from other bacteria',
            'Rapid spread, can cross species boundaries',
            AppColors.success,
            Icons.swap_horiz,
          ),
        ],
      ),
    );
  }

  Widget _buildPathwayRow(
    String number,
    String title,
    String description,
    String characteristic,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  characteristic,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w600,
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

  Widget _buildHGTDiagramCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Mechanisms
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
                  Icons.account_tree,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Three Mechanisms of Horizontal Gene Transfer',
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
          const SizedBox(height: 20),
          _buildHGTMechanism(
            '1',
            'Transformation',
            'Uptake of naked DNA from the environment',
            'Example: S. pneumoniae acquiring penicillin resistance genes from commensal streptococci',
            AppColors.info,
            Icons.download,
          ),
          const SizedBox(height: 16),
          _buildHGTMechanism(
            '2',
            'Transduction',
            'Transfer of DNA via bacteriophages (viruses that infect bacteria)',
            'Example: Phage-mediated transfer of toxin genes in S. aureus',
            AppColors.warning,
            Icons.coronavirus_outlined,
          ),
          const SizedBox(height: 16),
          _buildHGTMechanism(
            '3',
            'Conjugation',
            'Direct transfer of DNA through pili (most common mechanism for resistance spread)',
            'Example: Plasmid transfer between E. coli cells carrying carbapenemase genes',
            AppColors.error,
            Icons.link,
          ),
        ],
      ),
    );
  }

  Widget _buildHGTMechanism(
    String number,
    String title,
    String description,
    String example,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Example: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: example),
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

  Widget _buildPlasmidsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Plasmids
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
                  Icons.album,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Plasmids: Primary Vehicles for Resistance',
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
            'Plasmids are circular, extrachromosomal DNA molecules that can replicate independently of the bacterial chromosome. They are the most important vehicles for resistance gene dissemination.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            'Resistance plasmids often carry multiple resistance genes',
            AppColors.info,
          ),
          _buildBulletPoint(
            'Single transfer event can confer multidrug resistance',
            AppColors.info,
          ),
          _buildBulletPoint(
            'Can transfer between different bacterial species',
            AppColors.info,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.info,
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
                              'The IncF plasmid family commonly carries blaCTX-M genes (ESBLs), blaNDM genes (carbapenemases), and aminoglycoside resistance genes, enabling rapid spread of multidrug resistance among Enterobacterales.',
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

  Widget _buildTransposonsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),  // Red: Transposons critical
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
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
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.compare_arrows,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Transposons: Mobile Genetic Elements',
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
            'Transposons are mobile genetic elements that can move within and between DNA molecules (chromosomes and plasmids). They carry resistance genes flanked by insertion sequences (IS elements) that facilitate movement.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            'Tn4401 carries the blaKPC gene (global spread of KPC-producing Enterobacterales)',
            AppColors.error,
          ),
          _buildBulletPoint(
            'Tn1546 carries vanA gene (vancomycin resistance in Enterococcus)',
            AppColors.error,
          ),
          _buildBulletPoint(
            'Tn10 carries tetracycline resistance genes',
            AppColors.error,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.error,
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
                          text: 'Clinical Significance: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'Composite transposons contain resistance genes flanked by two IS elements, allowing them to "jump" between plasmids and chromosomes, facilitating rapid resistance spread.',
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

  Widget _buildReservoirsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Reservoirs
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
                  Icons.water_drop,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Resistance Gene Reservoirs',
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
            'Environmental bacteria, commensal flora, and agricultural settings serve as reservoirs for resistance genes. Soil bacteria produce antimicrobials naturally and possess resistance genes to protect themselves. These genes can be transferred to human pathogens.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            'Environmental bacteria (soil, water)',
            AppColors.warning,
          ),
          _buildBulletPoint(
            'Commensal flora (gut, skin)',
            AppColors.warning,
          ),
          _buildBulletPoint(
            'Agricultural settings (livestock, crops)',
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
                  Icons.public,
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
                              'The blaNDM gene (New Delhi metallo-beta-lactamase) likely originated from environmental bacteria in the Indian subcontinent and spread globally through plasmid transfer. Agricultural use of antimicrobials creates selective pressure and amplifies resistance gene reservoirs.',
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

  Widget _buildClinicalImplicationsCard() {
    return StructuredContentCard(
      heading: 'Clinical Implications',
      content:
          '''Understanding the genetic basis of resistance informs treatment decisions and infection control strategies:

• Plasmid-mediated resistance can spread rapidly within healthcare facilities, requiring enhanced infection prevention measures
• Chromosomal mutations are less transmissible but can emerge during therapy, emphasizing the importance of adequate dosing and duration
• Molecular testing (PCR, whole-genome sequencing) can detect resistance genes before phenotypic resistance is apparent, enabling earlier intervention

EXAMPLE: Detection of blaKPC gene in a carbapenem-susceptible isolate (due to low expression) prompts contact precautions to prevent spread, even though the organism is phenotypically susceptible.''',
      icon: Icons.medical_information,
      color: AppColors.info,
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
      'Two pathways: vertical (chromosomal mutations) and horizontal gene transfer (HGT)',
      'HGT mechanisms: transformation, transduction, and conjugation',
      'Plasmids are the primary vehicles for resistance dissemination',
      'IncF plasmids commonly carry ESBLs and carbapenemases',
      'Transposons (e.g., Tn4401 with blaKPC) facilitate gene movement',
      'Class 1 integrons found in >50% of Gram-negative isolates',
      'Environmental bacteria and agriculture serve as resistance gene reservoirs',
      'Molecular testing can detect resistance genes before phenotypic resistance',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Key takeaways
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
        'label': 'Nature Reviews Microbiology: Horizontal gene transfer and the evolution of bacterial resistance (2021)',
        'url': 'https://www.nature.com/articles/s41579-021-00583-2'
      },
      {
        'label': 'CDC: How Resistance Happens',
        'url': 'https://www.cdc.gov/antibiotic-use/antibiotic-resistance/how-resistance-happens.html'
      },
      {
        'label': 'WHO: Antimicrobial resistance - Mechanisms',
        'url': 'https://www.who.int/news-room/fact-sheets/detail/antimicrobial-resistance'
      },
      {
        'label': 'Clinical Microbiology Reviews: Mobile genetic elements and antibiotic resistance (2020)',
        'url': 'https://journals.asm.org/journal/cmr'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: References
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

