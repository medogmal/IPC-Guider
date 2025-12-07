import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class PriorityMdrosScreen extends StatelessWidget {
  const PriorityMdrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Priority MDROs'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.error,  // Red: Critical priority pathogens
            title: 'Priority Multidrug-Resistant Organisms',
            subtitle: 'Antimicrobial Resistance Mechanisms',
            description:
                'Understanding the priority MDROs that pose the greatest threats to public health.',
          ),
          const SizedBox(height: 20),

          // Introduction Card
          IntroductionCard(
            text:
                'Multidrug-resistant organisms (MDROs) are bacteria resistant to one or more classes of antimicrobial agents. The CDC and WHO have identified priority MDROs that pose the greatest threats to public health due to their resistance profiles, virulence, transmissibility, and limited treatment options. Understanding these organisms is essential for appropriate empiric therapy, infection control, and stewardship interventions.',
            isHighlighted: true,
          ),
          const SizedBox(height: 20),

          // Priority MDROs Grid Title
          const Text(
            'Seven Priority MDROs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Organism Cards Grid
          _buildOrganismGrid(context),
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

  Widget _buildOrganismGrid(BuildContext context) {
    // Check screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    if (isWideScreen) {
      // 2-column layout for tablets/wide screens
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMRSACard()),
              const SizedBox(width: 16),
              Expanded(child: _buildVRECard()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildESBLCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildCRECard()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPseudomonasCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildAcinetobacterCard()),
            ],
          ),
          const SizedBox(height: 16),
          _buildCDiffCard(),
        ],
      );
    } else {
      // Single column layout for mobile
      return Column(
        children: [
          _buildMRSACard(),
          const SizedBox(height: 16),
          _buildVRECard(),
          const SizedBox(height: 16),
          _buildESBLCard(),
          const SizedBox(height: 16),
          _buildCRECard(),
          const SizedBox(height: 16),
          _buildPseudomonasCard(),
          const SizedBox(height: 16),
          _buildAcinetobacterCard(),
          const SizedBox(height: 16),
          _buildCDiffCard(),
        ],
      );
    }
  }

  Widget _buildOrganismCard({
    required String title,
    required String subtitle,
    required String resistance,
    required String treatment,
    required String example,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
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
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow('Resistance', resistance, color),
          const SizedBox(height: 10),
          _buildInfoRow('Treatment', treatment, color),
          const SizedBox(height: 12),
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
                  Icons.medical_information_outlined,
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

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMRSACard() {
    return _buildOrganismCard(
      title: 'MRSA',
      subtitle: 'Methicillin-Resistant S. aureus',
      resistance: 'Resistant to all beta-lactams (except ceftaroline) due to mecA gene encoding PBP2a',
      treatment: 'Vancomycin (first-line), daptomycin (bacteremia), linezolid (pneumonia), ceftaroline',
      example: 'MRSA bacteremia: vancomycin 15-20 mg/kg IV q8-12h, target trough 15-20 mcg/mL',
      color: AppColors.error,  // Red: MRSA critical pathogen
      icon: Icons.coronavirus_outlined,
    );
  }

  Widget _buildVRECard() {
    return _buildOrganismCard(
      title: 'VRE',
      subtitle: 'Vancomycin-Resistant Enterococcus',
      resistance: 'Resistant to vancomycin due to van genes (vanA, vanB) that modify peptidoglycan precursors',
      treatment: 'Linezolid (bacteriostatic), daptomycin 8-12 mg/kg (bacteremia), tigecycline',
      example: 'VRE bacteremia: daptomycin 10 mg/kg IV daily + consider combination therapy',
      color: AppColors.error,  // Red: VRE critical pathogen
      icon: Icons.biotech,
    );
  }

  Widget _buildESBLCard() {
    return _buildOrganismCard(
      title: 'ESBL',
      subtitle: 'Extended-Spectrum Beta-Lactamases',
      resistance: 'Hydrolyze 3rd-gen cephalosporins and aztreonam. Most common: CTX-M, SHV, TEM',
      treatment: 'Carbapenems (first-line for serious infections), piperacillin-tazobactam (UTI, non-severe)',
      example: 'ESBL E. coli pyelonephritis: ertapenem 1g IV daily or meropenem 1g IV q8h',
      color: AppColors.error,  // Red: ESBL critical resistance
      icon: Icons.science,
    );
  }

  Widget _buildCRECard() {
    return _buildOrganismCard(
      title: 'CRE',
      subtitle: 'Carbapenem-Resistant Enterobacterales',
      resistance: 'Resistant to carbapenems through carbapenemases (KPC, NDM, OXA-48, VIM, IMP). Mortality 40-50%',
      treatment: 'Ceftazidime-avibactam (KPC, OXA-48), meropenem-vaborbactam (KPC), cefiderocol (all types), colistin',
      example: 'KPC K. pneumoniae bacteremia: ceftazidime-avibactam 2.5g IV q8h + second agent',
      color: AppColors.error,  // Red: CRE critical resistance
      icon: Icons.dangerous,
    );
  }

  Widget _buildPseudomonasCard() {
    return _buildOrganismCard(
      title: 'MDR Pseudomonas',
      subtitle: 'Multidrug-Resistant P. aeruginosa',
      resistance: 'Efflux pumps (MexAB-OprM), porin loss (OprD), beta-lactamases (AmpC, ESBLs, carbapenemases)',
      treatment: 'Ceftolozane-tazobactam, ceftazidime-avibactam, combination therapy (beta-lactam + aminoglycoside)',
      example: 'MDR P. aeruginosa VAP: ceftolozane-tazobactam 3g IV q8h + tobramycin 7 mg/kg IV daily',
      color: AppColors.error,  // Red: MDR Pseudomonas critical pathogen
      icon: Icons.water_drop,
    );
  }

  Widget _buildAcinetobacterCard() {
    return _buildOrganismCard(
      title: 'MDR Acinetobacter',
      subtitle: 'Multidrug-Resistant A. baumannii',
      resistance: 'Carbapenemases (OXA-23, OXA-24, NDM), efflux pumps, porin loss. Extremely limited options',
      treatment: 'Colistin (nephrotoxic), tigecycline (not for bloodstream), sulbactam, cefiderocol, combination therapy',
      example: 'Carbapenem-resistant A. baumannii pneumonia: colistin 5 mg/kg load, then 2.5 mg/kg IV q12h + tigecycline',
      color: AppColors.error,  // Red: CRAB critical pathogen
      icon: Icons.bug_report,
    );
  }

  Widget _buildCDiffCard() {
    return _buildOrganismCard(
      title: 'C. difficile',
      subtitle: 'Clostridioides difficile',
      resistance: 'Spore-forming anaerobe causing antibiotic-associated diarrhea. Hypervirulent strains (NAP1/BI/027)',
      treatment: 'Oral vancomycin 125mg QID or fidaxomicin 200mg BID (10 days). Severe: add IV metronidazole. Recurrent: FMT',
      example: 'Severe CDI (WBC 25K, Cr 2.0): oral vancomycin 125mg QID + IV metronidazole 500mg q8h',
      color: AppColors.warning,  // Amber: C. diff requires special attention
      icon: Icons.eco,
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'MRSA: Resistant to all beta-lactams; treat with vancomycin, daptomycin, or linezolid',
      'VRE: Resistant to vancomycin; treat with linezolid or high-dose daptomycin',
      'ESBL: Resistant to 3rd-gen cephalosporins; treat with carbapenems',
      'CRE: Resistant to carbapenems; treat with ceftazidime-avibactam, meropenem-vaborbactam, or cefiderocol',
      'MDR Pseudomonas: Treat with ceftolozane-tazobactam or combination therapy',
      'MDR Acinetobacter: Limited options; colistin + tigecycline or cefiderocol',
      'C. difficile: Treat with oral vancomycin or fidaxomicin; FMT for recurrent CDI',
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
        'label': 'CDC Antibiotic Resistance Threats Report (2019)',
        'url': 'https://www.cdc.gov/drugresistance/biggest-threats.html'
      },
      {
        'label': 'WHO Priority Pathogens List 2024',
        'url':
            'https://www.who.int/news/item/17-05-2024-who-updates-list-of-drug-resistant-bacteria'
      },
      {
        'label': 'IDSA Guidelines: Treatment of MRSA Infections (2011)',
        'url': 'https://academic.oup.com/cid/article/52/3/e18/382244'
      },
      {
        'label': 'IDSA/SHEA Guidelines: Clostridioides difficile Infection (2021)',
        'url': 'https://academic.oup.com/cid/article/73/5/e1029/6298219'
      },
      {
        'label': 'Sanford Guide to Antimicrobial Therapy (2024)',
        'url': 'https://www.sanfordguide.com/'
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

