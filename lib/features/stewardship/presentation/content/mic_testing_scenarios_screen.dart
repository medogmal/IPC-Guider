import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

/// MIC Testing and Clinical Scenarios Screen
/// Comprehensive evidence-based guidance on MIC testing methods and clinical scenarios
class MicTestingScenariosScreen extends StatelessWidget {
  const MicTestingScenariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MIC Testing and Clinical Scenarios'),
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.medical_information_outlined,
            iconColor: AppColors.info,
            title: 'MIC Testing and Clinical Scenarios',
            subtitle: 'Evidence-Based MIC Interpretation for Antimicrobial Stewardship',
            description:
                'MIC testing provides quantitative antimicrobial susceptibility data that guides dosing decisions and predicts clinical outcomes. Understanding MIC values beyond categorical S/I/R interpretation is critical for optimizing therapy and improving patient outcomes.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.biotech_outlined,
            color: AppColors.primary,
            heading: 'MIC Testing Methods',
            content:
                'Broth microdilution is the gold standard reference method, providing quantitative MIC values in µg/mL. E-test (gradient diffusion) provides MIC values and is useful for fastidious organisms or when automated systems are unavailable. Automated systems (e.g., Vitek 2, MicroScan, Phoenix) provide rapid results (4-18 hours) but may have limitations for certain organism-drug combinations. Disk diffusion (Kirby-Bauer) provides categorical results (S/I/R) based on zone diameters but does not provide MIC values.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.warning_outlined,
            color: AppColors.error,
            heading: 'Vancomycin MIC and MRSA Bacteremia',
            content:
                'Vancomycin has been the cornerstone of MRSA bacteremia treatment for decades, but MIC creep (gradual increase in MIC values over time) is associated with treatment failure. MRSA isolates with vancomycin MIC ≥1.5 µg/mL (even though susceptible by CLSI breakpoint of ≤2 µg/mL) have higher rates of treatment failure, persistent bacteremia, and mortality. IDSA guidelines (2011, updated 2021) recommend E-test for all positive MRSA blood cultures to guide therapy decisions.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.coronavirus_outlined,
            color: AppColors.error,  // Red: Critical resistance detection
            heading: 'Heteroresistant VISA (hVISA) Detection',
            content:
                'hVISA refers to MRSA isolates with subpopulations that have reduced vancomycin susceptibility (MIC 4-8 µg/mL). hVISA is not detected by routine AST but is associated with vancomycin treatment failure. Detection methods include population analysis profiling (PAP-AUC, gold standard but labor-intensive) and screening methods (e.g., vancomycin screen agar with 6 µg/mL). Clinical suspicion for hVISA: Persistent MRSA bacteremia despite adequate vancomycin dosing (AUC/MIC ≥400), MIC ≥1.5 µg/mL, or prior vancomycin exposure.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.medication_outlined,
            color: AppColors.success,
            heading: 'Alternative Agents for MRSA Bacteremia',
            content:
                'When vancomycin MIC ≥1.5 µg/mL or hVISA suspected: Daptomycin 8-10 mg/kg/day (higher doses for bacteremia/endocarditis); Linezolid 600 mg IV/PO q12h (bacteriostatic, avoid for high-burden infections); Ceftaroline 600 mg IV q8h (bactericidal, excellent for MRSA bacteremia and endocarditis); Combination therapy (vancomycin + beta-lactam) may have synergy. Clinical scenario: 65-year-old man with MRSA bacteremia, vancomycin MIC = 2 µg/mL by E-test, persistent bacteremia on day 5 despite vancomycin AUC = 450 → Switch to daptomycin 10 mg/kg/day or ceftaroline 600 mg q8h.',
          ),
          const SizedBox(height: 16),
          _buildClinicalScenariosSection(),
          const SizedBox(height: 16),
          _buildKeyTakeawaysCard(),
          const SizedBox(height: 16),
          _buildReferencesCard(context),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildClinicalScenariosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Critical Clinical Scenarios',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildScenarioCard(
          'S. pneumoniae Meningitis - Site-Specific Breakpoints',
          'Penicillin and cephalosporin breakpoints for S. pneumoniae differ based on infection site. Meningitis breakpoints are much stricter than non-meningitis breakpoints.',
          'Clinical scenario: 45-year-old woman with bacterial meningitis, CSF culture grows S. pneumoniae with penicillin MIC = 0.12 µg/mL. Interpretation: Resistant for meningitis (breakpoint S ≤0.06 µg/mL) but susceptible for non-meningitis infections (oral breakpoint S ≤2 µg/mL). Treatment: Vancomycin 15-20 mg/kg q8-12h + ceftriaxone 2 g q12h (empiric for meningitis). If ceftriaxone MIC ≤0.5 µg/mL, continue ceftriaxone alone. Avoid penicillin monotherapy for meningitis even if "susceptible" by non-meningitis breakpoints.',
          'Outcome: Successful treatment with ceftriaxone monotherapy after confirming MIC ≤0.5 µg/mL.',
          AppColors.error,
        ),
        const SizedBox(height: 12),
        _buildScenarioCard(
          'Enterococcus Species and Vancomycin Resistance',
          'Vancomycin-resistant enterococci (VRE) are a major healthcare-associated pathogen. VRE screening detects vanA and vanB genes (high-level resistance, MIC >256 µg/mL).',
          'Clinical scenario: 70-year-old man with E. faecium bacteremia, vancomycin-resistant (vanA gene), daptomycin MIC = 4 µg/mL (susceptible ≤4 µg/mL). Treatment: Start daptomycin 8-10 mg/kg/day or consider linezolid if daptomycin MIC is elevated. Note: Daptomycin MIC testing requires calcium-adjusted media (50 mg/L Ca²⁺) per CLSI guidelines.',
          'Outcome: Successful treatment with daptomycin 10 mg/kg/day.',
          AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildScenarioCard(
          'Candida glabrata Candidemia',
          'Candidemia is a life-threatening infection with 40% mortality. Echinocandins are first-line therapy per IDSA guidelines (2016, updated 2024).',
          'Clinical scenario: 60-year-old woman with candidemia, blood culture grows C. glabrata, fluconazole MIC = 16 µg/mL (SDD). Interpretation: Susceptible-dose dependent; high-dose fluconazole (800 mg daily) may be effective, but echinocandins are preferred due to superior efficacy and lower resistance rates. Treatment: Micafungin 100 mg IV daily or anidulafungin 200 mg loading dose, then 100 mg daily. Stewardship implication: Antifungal stewardship programs should review all candidemia cases for appropriate agent selection, dosing, and duration (14 days after first negative blood culture and resolution of symptoms).',
          'Outcome: Successful treatment with micafungin 100 mg daily for 14 days.',
          AppColors.error,  // Red: Critical fungal pathogen
        ),
        const SizedBox(height: 12),
        _buildScenarioCard(
          'N. gonorrhoeae and Cephalosporin Resistance',
          'N. gonorrhoeae is a CDC urgent threat due to rising cephalosporin resistance. Ceftriaxone MIC creep: MIC ≥0.125 µg/mL is concerning (CDC surveillance threshold); treatment failures reported with MIC ≥0.5 µg/mL.',
          'Clinical scenario: 25-year-old man with urethral discharge, culture grows N. gonorrhoeae with ceftriaxone MIC = 0.25 µg/mL. Interpretation: Susceptible (breakpoint S ≤0.25 µg/mL) but concerning due to MIC creep. Action: Treat with ceftriaxone 500 mg IM, report elevated MIC to public health, perform test-of-cure culture in 1 week. Current CDC treatment recommendation (2020): Ceftriaxone 500 mg IM single dose (1 g if weight >150 kg). Azithromycin is no longer recommended for dual therapy due to high-level resistance (MIC ≥256 µg/mL).',
          'Outcome: Successful treatment with ceftriaxone 500 mg IM, test-of-cure negative.',
          AppColors.warning,  // Amber: MIC creep concern
        ),
        const SizedBox(height: 12),
        _buildScenarioCard(
          'Pseudomonas aeruginosa and Difficult-to-Treat Resistance (DTR-PA)',
          'DTR-PA is defined as P. aeruginosa resistant to all beta-lactams (piperacillin-tazobactam, ceftazidime, cefepime, meropenem, imipenem) AND fluoroquinolones. DTR-PA is associated with high mortality (30-40%) and limited treatment options.',
          'Clinical scenario: 55-year-old man with ventilator-associated pneumonia, sputum culture grows P. aeruginosa with meropenem MIC = 4 µg/mL (intermediate). Action: Consider higher-dose meropenem (2 g q8h extended infusion over 3 hours) or switch to ceftolozane-tazobactam. Treatment options: Ceftolozane-tazobactam 3 g q8h (extended infusion), ceftazidime-avibactam 2.5 g q8h, imipenem-relebactam 1.25 g q6h, colistin (last resort due to nephrotoxicity). Stewardship implication: Early identification of DTR-PA triggers infectious diseases consultation and consideration of newer agents.',
          'Outcome: Successful treatment with ceftolozane-tazobactam 3 g q8h.',
          AppColors.error,  // Red: DTR-PA critical resistance
        ),
      ],
    );
  }

  Widget _buildScenarioCard(String title, String background, String management, String outcome, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.person_outline, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Background: $background',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Management: $management',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    outcome,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                      height: 1.4,
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

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'MIC testing methods: Broth microdilution (gold standard), E-test (gradient diffusion), automated systems (4-18 hours), disk diffusion (S/I/R only)',
      'Vancomycin MIC ≥1.5 µg/mL for MRSA bacteremia → treatment failure risk → consider daptomycin, linezolid, or ceftaroline',
      'hVISA (heteroresistant VISA): Subpopulations with reduced vancomycin susceptibility → not detected by routine AST → associated with treatment failure',
      'S. pneumoniae site-specific breakpoints: Meningitis (penicillin S ≤0.06, ceftriaxone S ≤0.5) vs. non-meningitis (penicillin S ≤2-8, ceftriaxone S ≤1)',
      'VRE: Daptomycin first-line (calcium-adjusted media required for MIC testing), linezolid alternative (resistance emerging)',
      'Candida: Echinocandins first-line for candidemia; C. glabrata SDD to fluconazole; C. auris often fluconazole-resistant',
      'N. gonorrhoeae: Ceftriaxone MIC ≥0.125 µg/mL concerning (MIC creep) → report to public health, test-of-cure',
      'DTR-P. aeruginosa: Resistant to all beta-lactams + fluoroquinolones → ceftolozane-tazobactam, ceftazidime-avibactam, or colistin',
      'M. tuberculosis: GeneXpert MTB/RIF detects rifampin resistance in 2 hours → guides MDR-TB vs. drug-susceptible TB therapy',
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
        'label': 'IDSA Guidelines on MRSA Bacteremia (2011, updated 2021)',
        'url': 'https://www.idsociety.org/practice-guideline/mrsa/',
      },
      {
        'label': 'IDSA Guidelines on Candidiasis (2016, updated 2024)',
        'url': 'https://www.idsociety.org/practice-guideline/candidiasis/',
      },
      {
        'label': 'CDC Sexually Transmitted Infections Treatment Guidelines (2021)',
        'url': 'https://www.cdc.gov/std/treatment-guidelines/default.htm',
      },
      {
        'label': 'IDSA Guidance on Difficult-to-Treat Resistance in Gram-Negative Infections (2020)',
        'url': 'https://www.idsociety.org/practice-guideline/amr-guidance-2.0/',
      },
      {
        'label': 'WHO Guidelines on Tuberculosis Drug Susceptibility Testing (2023)',
        'url': 'https://www.who.int/publications/i/item/9789240082175',
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

