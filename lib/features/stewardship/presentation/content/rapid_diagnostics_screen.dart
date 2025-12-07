import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

/// Rapid Diagnostics and Stewardship Integration Screen
/// Comprehensive evidence-based guidance on rapid diagnostics and stewardship integration
class RapidDiagnosticsScreen extends StatelessWidget {
  const RapidDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapid Diagnostics and Stewardship Integration'),
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.speed_outlined,
            iconColor: AppColors.info,
            title: 'Rapid Diagnostics and Stewardship Integration',
            subtitle: 'Leveraging Technology for Faster, Smarter Antimicrobial Decisions',
            description:
                'Rapid diagnostic technologies provide organism identification and resistance gene detection in hours instead of days, enabling earlier de-escalation from empiric broad-spectrum therapy or escalation to targeted therapy. Integration with antimicrobial stewardship programs is critical for maximizing clinical impact.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.biotech_outlined,
            color: AppColors.success,
            heading: 'MALDI-TOF MS (Matrix-Assisted Laser Desorption/Ionization Time-of-Flight Mass Spectrometry)',
            content:
                'MALDI-TOF MS provides rapid organism identification in minutes compared to days for conventional methods. MALDI-TOF analyzes protein profiles to identify bacteria and fungi with >95% accuracy for common pathogens. Impact on time to appropriate therapy: MALDI-TOF reduces time to organism identification by 24-48 hours, allowing earlier de-escalation from empiric broad-spectrum therapy or escalation to targeted therapy. Stewardship workflow integration: Real-time alerts for positive blood cultures (text/pager alerts to stewardship team) enable pharmacist-driven interventions within hours of organism identification.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.coronavirus_outlined,
            color: AppColors.error,
            heading: 'C. auris Identification via MALDI-TOF (CRITICAL)',
            content:
                'C. auris is a CDC urgent threat due to multidrug resistance, environmental persistence, and outbreak potential. Conventional methods (API, Vitek 2) misidentify C. auris as C. haemulonii or C. duobushaemulonii. MALDI-TOF or molecular methods (PCR, sequencing) are required for accurate identification. Clinical implication: Early C. auris identification triggers infection control measures (contact precautions, dedicated equipment, environmental disinfection with sporicidal agents) and appropriate antifungal selection (echinocandin first-line; avoid fluconazole due to 90% resistance rate).',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.science_outlined,
            color: AppColors.primary,
            heading: 'Molecular Rapid Diagnostic Panels',
            content:
                'Blood culture panels (e.g., BioFire FilmArray BCID, Verigene, T2Candida) provide organism identification and resistance gene detection in 1-3 hours directly from positive blood cultures. Organisms detected: Gram-positive (S. aureus, Enterococcus, Streptococcus), Gram-negative (E. coli, Klebsiella, Pseudomonas, Acinetobacter), Candida species. Resistance genes detected: mecA (MRSA), vanA/vanB (VRE), KPC, NDM, OXA-48, VIM, IMP (carbapenemases). Respiratory panels detect viral and bacterial pathogens (influenza, RSV, SARS-CoV-2, S. pneumoniae, M. pneumoniae), reducing unnecessary antibiotics for viral infections. Gastrointestinal panels detect bacterial, viral, and parasitic pathogens (Salmonella, Shigella, Campylobacter, C. difficile, norovirus, Giardia).',
          ),
          const SizedBox(height: 16),
          _buildCDiffTestingCard(),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.warning_outlined,
            color: AppColors.warning,  // Amber: Important stewardship consideration
            heading: 'Stewardship Implications for C. difficile Testing',
            content:
                'PCR-only testing leads to unnecessary treatment (metronidazole or vancomycin for colonization), prolonged isolation (contact precautions), and healthcare costs (\$10,000-\$30,000 per case). Repeat testing within 7 days is NOT recommended (IDSA/SHEA 2021) because PCR remains positive for weeks after treatment, even with clinical resolution. "Test of cure" is NOT indicated; clinical improvement is the endpoint. Clinical scenario: 65-year-old woman with diarrhea (5 loose stools/day), positive C. difficile PCR, negative toxin EIA. Interpretation: Likely colonization, not active CDI. Action: Consider alternative diagnosis (laxatives, tube feeds, other infections), do not treat with metronidazole or vancomycin unless high clinical suspicion.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.medical_services_outlined,
            color: AppColors.info,  // Blue: Informational stewardship guidance
            heading: 'Syndromic Panels and Stewardship Considerations',
            content:
                'Positive predictive value (PPV) varies by prevalence; low PPV in low-prevalence settings leads to false positives. Colonization vs. infection: Respiratory panels may detect colonizers (S. aureus, S. pneumoniae, H. influenzae) that are not causing the current illness; clinical correlation is required. Risk of overtreatment: Broad panels may lead to unnecessary antibiotics for non-pathogenic organisms or viral infections. Stewardship review: Pharmacist or infectious diseases physician review of all positive results to guide appropriate therapy, de-escalation, or discontinuation.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.speed_outlined,
            color: AppColors.success,
            heading: 'Rapid AST Technologies',
            content:
                'Accelerate Pheno system provides organism identification and AST in 7 hours (vs. 48-72 hours for conventional methods) directly from positive blood cultures. Phenotypic AST provides MIC values for multiple antibiotics, allowing precise therapy selection. Genotypic resistance detection (e.g., GeneXpert for mecA, vanA/B, KPC) detects resistance genes but may miss novel mechanisms or heteroresistance. Combination of genotypic and phenotypic methods provides optimal stewardship guidance.',
          ),
          const SizedBox(height: 16),
          _buildStewardshipIntegrationCard(),
          const SizedBox(height: 16),
          _buildKeyTakeawaysCard(),
          const SizedBox(height: 16),
          _buildReferencesCard(context),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildCDiffTestingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
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
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bug_report_outlined,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Clostridioides difficile Testing Algorithms (CRITICAL)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'C. difficile is the most common healthcare-associated infection in the United States, causing 500,000 infections and 29,000 deaths annually. However, 10-30% of hospitalized patients are colonized with C. difficile (carry the organism without symptoms). PCR-only testing (1-step NAAT) has high sensitivity but detects both colonization and infection, leading to over-diagnosis and overtreatment. IDSA/SHEA guidelines (2021) recommend 2-step or 3-step algorithms to improve specificity.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildTestingAlgorithmItem(
            '1-Step PCR (NAAT only)',
            'High sensitivity (>95%) but detects colonization → Over-diagnosis, unnecessary treatment, isolation, and healthcare costs.',
            AppColors.error,
          ),
          _buildTestingAlgorithmItem(
            '2-Step Algorithm (RECOMMENDED)',
            'Step 1: GDH (glutamate dehydrogenase) antigen screen (high sensitivity, low specificity). Step 2: If GDH positive → Toxin EIA (enzyme immunoassay) for confirmation (high specificity). Result interpretation: GDH+/Toxin+ = Active CDI (treat); GDH+/Toxin- = Likely colonization (do not treat, consider alternative diagnosis); GDH-/Toxin- = Negative.',
            AppColors.success,
          ),
          _buildTestingAlgorithmItem(
            '3-Step Algorithm (most specific)',
            'Step 1: GDH screen. Step 2: If GDH positive → PCR. Step 3: If PCR positive → Toxin EIA for confirmation. This algorithm reduces false positives compared to PCR-only testing.',
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTestingAlgorithmItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle_outline,
              color: color,
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
                    color: color,
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

  Widget _buildStewardshipIntegrationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
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
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.integration_instructions_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Stewardship Integration Strategies',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildIntegrationItem(
            'Real-time alerts for positive blood cultures',
            'Text/pager alerts to stewardship team within 1 hour of MALDI-TOF or molecular panel result.',
          ),
          _buildIntegrationItem(
            'Pharmacist-driven interventions',
            'Review rapid diagnostic results and recommend de-escalation (e.g., MRSA-negative → discontinue vancomycin) or escalation (e.g., KPC-positive → start ceftazidime-avibactam).',
          ),
          _buildIntegrationItem(
            'De-escalation protocols',
            'Triggered by rapid AST results (e.g., ESBL-negative E. coli → de-escalate from meropenem to ceftriaxone).',
          ),
          _buildIntegrationItem(
            'Metrics',
            'Time to appropriate therapy (target <6 hours), time to de-escalation (target <24 hours), antibiotic days saved (target 20-30% reduction in broad-spectrum use).',
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
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
      'MALDI-TOF MS: Rapid organism identification in minutes (vs. days) → reduces time to appropriate therapy by 24-48 hours',
      'C. auris identification: MALDI-TOF or molecular methods required (conventional methods misidentify) → triggers infection control and echinocandin therapy',
      'Molecular panels: Blood culture panels (1-3 hours) detect organisms and resistance genes (mecA, vanA/B, KPC, NDM) → enables targeted therapy',
      'C. difficile testing: 2-step algorithm (GDH + toxin EIA) RECOMMENDED by IDSA/SHEA 2021 → reduces over-diagnosis from PCR-only testing',
      'C. difficile stewardship: Avoid PCR-only testing, restrict repeat testing within 7 days, no test-of-cure → 30-50% reduction in CDI diagnosis',
      'Syndromic panels: Risk of overtreatment (colonization vs. infection) → requires stewardship review and clinical correlation',
      'Rapid AST: Accelerate Pheno (7 hours) provides MIC values → enables precise therapy selection and de-escalation',
      'Stewardship integration: Real-time alerts, pharmacist-driven interventions, de-escalation protocols → time to appropriate therapy <6 hours',
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
        'label': 'IDSA/SHEA Guidelines on Clostridioides difficile Infection (2021)',
        'url': 'https://www.idsociety.org/practice-guideline/clostridioides-difficile/',
      },
      {
        'label': 'CDC Antibiotic Resistance Threats Report (2019) - C. auris as Urgent Threat',
        'url': 'https://www.cdc.gov/drugresistance/biggest-threats.html',
      },
      {
        'label': 'WHO Fungal Priority Pathogens List (2022) - C. auris as Critical Priority',
        'url': 'https://www.who.int/publications/i/item/9789240060241',
      },
      {
        'label': 'Banerjee R, et al. Randomized Trial of Rapid Multiplex PCR-Based Blood Culture Identification and ASP Intervention. Clin Infect Dis. 2018.',
        'url': 'https://academic.oup.com/cid/article/66/7/1071/4554402',
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


