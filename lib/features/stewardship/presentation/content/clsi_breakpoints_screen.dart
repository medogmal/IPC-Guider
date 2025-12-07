import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

/// CLSI Breakpoints and MIC Interpretation Screen
/// Comprehensive evidence-based guidance on CLSI M100 35th Edition (2025) and MIC interpretation
class ClsiBreakpointsScreen extends StatelessWidget {
  const ClsiBreakpointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CLSI Breakpoints and MIC Interpretation'),
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.science_outlined,
            iconColor: AppColors.info,
            title: 'CLSI Breakpoints and MIC Interpretation',
            subtitle: 'FDA-Recognized Standards for Antimicrobial Susceptibility Testing',
            description:
                'The Clinical and Laboratory Standards Institute (CLSI) publishes evidence-based guidelines for antimicrobial susceptibility testing (AST) that are recognized by the FDA and used worldwide. On January 16, 2025, the FDA recognized CLSI M100 35th Edition (2025), representing a major advancement in standardizing AST interpretation and combating antimicrobial resistance.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.category_outlined,
            color: AppColors.primary,
            heading: 'CLSI M100 35th Edition (2025) - Breakpoint Categories',
            content:
                'This document provides breakpoints for aerobic and anaerobic bacteria. Breakpoint categories include: Susceptible (S) - the antimicrobial is likely to inhibit growth of the pathogen if the antimicrobial reaches the concentrations at the infection site; Intermediate (I) - the antimicrobial may be effective at higher doses or at sites where the drug is concentrated (e.g., urine); Resistant (R) - the antimicrobial is not likely to inhibit growth even with maximal dosing; Susceptible-Dose Dependent (SDD) - susceptibility depends on the dosing regimen (higher doses may be required).',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.biotech_outlined,
            color: AppColors.success,
            heading: 'MIC (Minimum Inhibitory Concentration)',
            content:
                'MIC is the lowest concentration of an antimicrobial that inhibits visible growth of a microorganism after overnight incubation. MIC values guide dosing decisions and predict clinical outcomes. For example, vancomycin MIC ≥1.5 µg/mL for MRSA bacteremia is associated with treatment failure, even though the breakpoint for susceptibility is ≤2 µg/mL. Understanding MIC values beyond categorical interpretation (S/I/R) is critical for antimicrobial stewardship.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.timeline_outlined,
            color: AppColors.primary,  // Teal: Clinical pharmacology concept
            heading: 'Pharmacokinetic/Pharmacodynamic (PK/PD) Breakpoints',
            content:
                'PK/PD breakpoints are based on the relationship between drug exposure and microbiological effect. Time-dependent antibiotics (e.g., beta-lactams) require time above MIC (T>MIC) for efficacy; concentration-dependent antibiotics (e.g., aminoglycosides, fluoroquinolones) require peak concentration/MIC (Cmax/MIC) or area under the curve/MIC (AUC/MIC) ratios. PK/PD principles guide dosing optimization and breakpoint determination.',
          ),
          const SizedBox(height: 16),
          _buildNewAgentsCard(),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.medical_services_outlined,
            color: AppColors.info,  // Blue: Laboratory testing standard
            heading: 'CLSI M45 3rd Edition (2025) - Fastidious Bacteria',
            content:
                'This document covers organisms that require special media or incubation conditions, including H. influenzae, M. catarrhalis, N. gonorrhoeae, N. meningitidis, S. pneumoniae, Streptococcus groups A/B/C/G, HACEK organisms (Haemophilus, Aggregatibacter, Cardiobacterium, Eikenella, Kingella), and nutritionally variant streptococci (Abiotrophia, Granulicatella). Special requirements include chocolate agar, extended incubation (5-7 days for HACEK), CO₂ atmosphere, and pyridoxal supplementation for nutritionally variant streptococci.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.coronavirus_outlined,
            color: AppColors.warning,  // Amber: Fungal testing requires special attention
            heading: 'CLSI M27/M44 3rd Edition (2025) - Antifungal Testing for Yeasts',
            content:
                'This document provides breakpoints for Candida species and other yeasts. Echinocandins (caspofungin, micafungin, anidulafungin) are first-line therapy for candidemia; azoles (fluconazole, voriconazole) are used for less severe infections or step-down therapy. C. glabrata is intrinsically susceptible-dose dependent (SDD) to fluconazole; C. krusei is intrinsically resistant to fluconazole. Broth microdilution is the reference method; disk diffusion is NOT validated for antifungal testing.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.grass_outlined,
            color: AppColors.warning,  // Amber: Filamentous fungi testing requires special attention
            heading: 'CLSI M38/M51 3rd Edition (2025) - Antifungal Testing for Filamentous Fungi',
            content:
                'This document covers molds such as Aspergillus species. Voriconazole and isavuconazole are first-line agents for invasive aspergillosis; amphotericin B is an alternative. Antifungal susceptibility testing for molds is technically challenging and should be performed by reference laboratories.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.school_outlined,
            color: AppColors.primary,
            heading: 'Clinical Implications of Breakpoint Changes for Stewardship',
            content:
                'Updated breakpoints reflect new PK/PD data, clinical outcomes, and resistance mechanisms. Stewardship programs must stay current with CLSI updates to ensure appropriate empiric therapy selection, antibiogram interpretation, and prescriber education. For example, recognizing ceftazidime-avibactam susceptibility in CRE allows targeted therapy instead of colistin or tigecycline, which have more toxicity and lower efficacy.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.verified_outlined,
            color: AppColors.success,
            heading: 'Quality Control and Proficiency Testing',
            content:
                'Laboratories must perform daily quality control (QC) using ATCC reference strains to ensure accurate AST results. QC failures require investigation and corrective action before reporting patient results. Proficiency testing (e.g., College of American Pathologists surveys) ensures ongoing competency and identifies systematic errors. Stewardship teams should collaborate with microbiology laboratories to review QC data and address discrepancies.',
          ),
          const SizedBox(height: 16),
          _buildKeyTakeawaysCard(),
          const SizedBox(height: 16),
          _buildReferencesCard(context),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildNewAgentsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.new_releases_outlined,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Recent Breakpoint Updates in CLSI M100 35th Edition (2025)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAgentItem(
            'Ceftazidime-avibactam for CRE',
            'S ≤8 µg/mL, R ≥16 µg/mL. Critical treatment option for carbapenem-resistant Enterobacterales.',
          ),
          _buildAgentItem(
            'Cefiderocol (siderophore cephalosporin)',
            'Requires iron-depleted media for accurate testing. S ≤4 µg/mL for Enterobacterales and P. aeruginosa.',
          ),
          _buildAgentItem(
            'Meropenem-vaborbactam for Enterobacterales',
            'S ≤4 µg/mL, R ≥16 µg/mL. Effective against KPC-producing organisms.',
          ),
          _buildAgentItem(
            'Imipenem-relebactam for Enterobacterales and P. aeruginosa',
            'S ≤2 µg/mL, R ≥8 µg/mL. Provides critical treatment options for multidrug-resistant Gram-negative infections.',
          ),
        ],
      ),
    );
  }

  Widget _buildAgentItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'CLSI M100 35th Ed. (2025) recognized by FDA on January 16, 2025 - major advancement for AST standardization',
      'Breakpoint categories: S (susceptible), I (intermediate), R (resistant), SDD (susceptible-dose dependent)',
      'MIC (Minimum Inhibitory Concentration) guides dosing decisions beyond categorical S/I/R interpretation',
      'PK/PD breakpoints: Time-dependent (beta-lactams, T>MIC) vs. concentration-dependent (aminoglycosides, Cmax/MIC)',
      'New agents in CLSI M100 35th Ed.: Ceftazidime-avibactam, cefiderocol (iron-depleted media), meropenem-vaborbactam, imipenem-relebactam',
      'CLSI M45 3rd Ed. (2025): Fastidious bacteria (H. influenzae, HACEK, S. pneumoniae) - special media and incubation required',
      'CLSI M27/M44 3rd Ed. (2025): Antifungal testing for yeasts (Candida) - broth microdilution only, no disk diffusion',
      'Quality control and proficiency testing ensure accurate AST results - stewardship teams should collaborate with microbiology',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
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
          ...keyPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
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
    );
  }

  Widget _buildReferencesCard(BuildContext context) {
    final references = [
      {
        'label': 'CLSI M100 35th Edition (2025) - Performance Standards for Antimicrobial Susceptibility Testing',
        'url': 'https://clsi.org/standards/products/microbiology/documents/m100/',
      },
      {
        'label': 'FDA Recognition of CLSI Breakpoints (January 16, 2025)',
        'url': 'https://www.fda.gov/medical-devices/antimicrobial-susceptibility-test-ast-systems/recognized-susceptibility-test-interpretive-criteria',
      },
      {
        'label': 'CLSI M45 3rd Edition (2025) - Fastidious Bacteria',
        'url': 'https://clsi.org/standards/products/microbiology/documents/m45/',
      },
      {
        'label': 'CLSI M27/M44 3rd Edition (2025) - Antifungal Testing for Yeasts',
        'url': 'https://clsi.org/standards/products/microbiology/documents/m27/',
      },
      {
        'label': 'Humphries RM, Simner PJ. Major updates to FDA-recognized CLSI breakpoints. J Clin Microbiol. 2025 Apr.',
        'url': 'https://journals.asm.org/journal/jcm',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.library_books_outlined,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
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
          ...references.map((ref) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _launchUrl(ref['url']!),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.open_in_new,
                          color: AppColors.info,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ref['label']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.info,
                              decoration: TextDecoration.underline,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}


