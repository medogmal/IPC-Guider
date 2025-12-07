import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

/// Resistance Mechanisms and AST Pitfalls Screen
/// Comprehensive evidence-based guidance on resistance mechanisms and AST pitfalls
class ResistanceAstPitfallsScreen extends StatelessWidget {
  const ResistanceAstPitfallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resistance Mechanisms and AST Pitfalls'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          ContentHeaderCard(
            icon: Icons.warning_outlined,
            iconColor: AppColors.error,
            title: 'Resistance Mechanisms and AST Pitfalls',
            subtitle: 'Critical Knowledge for Accurate AST Interpretation and Stewardship',
            description:
                'Understanding resistance mechanisms and recognizing AST pitfalls is essential for antimicrobial stewardship. Misinterpretation of AST results can lead to treatment failure, adverse events, and continued antimicrobial resistance. This section covers key resistance mechanisms, detection methods, and common pitfalls that stewardship teams must recognize.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.bug_report_outlined,
            color: AppColors.error,
            heading: 'ESBL (Extended-Spectrum Beta-Lactamase) Detection',
            content:
                'ESBLs are enzymes that hydrolyze extended-spectrum cephalosporins (ceftriaxone, ceftazidime, cefotaxime) and aztreonam but are inhibited by clavulanate. ESBL-producing Enterobacterales (E. coli, Klebsiella) are resistant to penicillins, cephalosporins (except cephamycins like cefoxitin), and aztreonam. Carbapenems (meropenem, imipenem, ertapenem) are the treatment of choice for serious ESBL infections. Cefepime may appear susceptible in vitro but has variable clinical efficacy; avoid for serious infections. Piperacillin-tazobactam may be effective for urinary tract infections or low-burden infections but should be avoided for bacteremia or high-burden infections. CLSI M100 recommends phenotypic confirmation testing (ceftazidime vs. ceftazidime-clavulanate disk diffusion) for ESBL detection.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.coronavirus_outlined,
            color: AppColors.warning,  // Amber: Inducible resistance requires caution
            heading: 'AmpC Beta-Lactamase Detection',
            content:
                'AmpC beta-lactamases are chromosomally encoded in ESCPM organisms (Enterobacter, Serratia, Citrobacter, Providencia, Morganella) and can be plasmid-mediated in E. coli and Klebsiella. AmpC is inducible: Exposure to beta-lactams (e.g., cefazolin, ampicillin-sulbactam) induces AmpC expression, leading to treatment failure even if the organism appears susceptible in vitro. Avoid cephalosporins (except cefepime at high doses) for serious infections caused by ESCPM organisms. Carbapenems are the treatment of choice for serious AmpC-producing infections. Cefepime resistance in AmpC-producing organisms suggests high-level AmpC expression or co-production of ESBL; use carbapenems.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.shield_outlined,
            color: AppColors.error,
            heading: 'Carbapenemase Detection',
            content:
                'Carbapenemases hydrolyze carbapenems and are a critical threat. Major carbapenemase types: KPC (Klebsiella pneumoniae carbapenemase) - most common in the U.S., inhibited by vaborbactam and avibactam; NDM (New Delhi metallo-beta-lactamase) - metallo-beta-lactamase, not inhibited by vaborbactam or avibactam; OXA-48 - oxacillinase, variable carbapenem MICs; VIM, IMP - metallo-beta-lactamases. Detection methods: Modified carbapenem inactivation method (mCIM) - phenotypic test; Molecular methods (PCR, whole-genome sequencing) - genotypic detection. Treatment options: KPC - ceftazidime-avibactam, meropenem-vaborbactam, imipenem-relebactam; NDM - aztreonam + ceftazidime-avibactam (combination), cefiderocol; OXA-48 - ceftazidime-avibactam, cefiderocol.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.science_outlined,
            color: AppColors.error,  // Red: Critical AST pitfall
            heading: 'Heteroresistance',
            content:
                'Heteroresistance refers to the presence of resistant subpopulations within a susceptible population. Routine AST may report the organism as susceptible, but resistant subpopulations can emerge during therapy, leading to treatment failure. Examples: hVISA (heteroresistant VISA) - MRSA with vancomycin-resistant subpopulations (MIC 4-8 µg/mL); Colistin heteroresistance - Gram-negative organisms with colistin-resistant subpopulations. Detection: Population analysis profiling (PAP-AUC) is the gold standard but labor-intensive; not performed routinely. Clinical implication: Suspect heteroresistance if persistent infection despite adequate therapy and susceptible AST results.',
          ),
          const SizedBox(height: 16),
          _buildCAurisCard(),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.biotech_outlined,
            color: AppColors.info,  // Blue: Laboratory testing methodology
            heading: 'Fastidious Organisms and Special Testing Requirements',
            content:
                'Fastidious organisms require special media, incubation conditions, or extended incubation times for accurate AST. H. influenzae: Beta-lactamase testing (nitrocefin disk) required; ampicillin-resistant if beta-lactamase positive. HACEK organisms: Extended incubation (5-7 days) required for accurate AST; ampicillin resistance is rare but increasing. S. pneumoniae: Site-specific breakpoints (meningitis vs. non-meningitis) are critical; penicillin MIC ≤0.06 µg/mL for meningitis, ≤2 µg/mL for non-meningitis. N. meningitidis: Penicillin MIC ≥0.12 µg/mL indicates reduced susceptibility; ceftriaxone is preferred for meningitis.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.medical_services_outlined,
            color: AppColors.primary,
            heading: 'N. gonorrhoeae Resistance Mechanisms',
            content:
                'N. gonorrhoeae is a CDC urgent threat due to rising resistance to all antimicrobials. Cephalosporin resistance: Mosaic penA gene mutations reduce ceftriaxone susceptibility; MIC ≥0.125 µg/mL is concerning (CDC surveillance threshold). Azithromycin resistance: High-level resistance (MIC ≥256 µg/mL) is common; azithromycin is no longer recommended for dual therapy. Fluoroquinolone resistance: Widespread (>30% in the U.S.); ciprofloxacin is no longer recommended. Current treatment: Ceftriaxone 500 mg IM single dose (1 g if weight >150 kg); test-of-cure culture recommended for elevated MICs.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.water_drop_outlined,
            color: AppColors.primary,  // Teal: Organism characteristic
            heading: 'Stenotrophomonas maltophilia AST Considerations',
            content:
                'S. maltophilia is intrinsically resistant to carbapenems due to L1 and L2 metallo-beta-lactamases. Trimethoprim-sulfamethoxazole (TMP-SMX) is the first-line agent; resistance is rare but increasing. Alternative agents: Levofloxacin (if susceptible), minocycline, ceftazidime (variable efficacy), ticarcillin-clavulanate (no longer available in many countries). AST pitfall: Automated systems may report susceptibility to agents with poor clinical efficacy (e.g., ceftazidime); always review AST results with clinical context.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.coronavirus_outlined,
            color: AppColors.error,
            heading: 'Acinetobacter baumannii Multidrug Resistance',
            content:
                'A. baumannii is a CDC serious threat due to carbapenem resistance and limited treatment options. Carbapenem-resistant A. baumannii (CRAB): Colistin or polymyxin B (nephrotoxic, last resort); Cefiderocol (siderophore cephalosporin, FDA-approved 2019); Combination therapy (colistin + carbapenem, colistin + ampicillin-sulbactam) may have synergy. Sulbactam has intrinsic activity against A. baumannii; ampicillin-sulbactam 9 g q8h (sulbactam 3 g component) may be effective. AST pitfall: Colistin MIC testing is unreliable; broth microdilution is the only validated method.',
          ),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.grass_outlined,
            color: AppColors.warning,  // Amber: Special testing requirements
            heading: 'Anaerobic Bacteria Susceptibility Testing',
            content:
                'Anaerobic AST is technically challenging and not routinely performed. Indications for anaerobic AST: Brain abscess, endocarditis, osteomyelitis, prosthetic joint infection, bacteremia with no source control. Resistance trends: Bacteroides fragilis group - increasing resistance to clindamycin (20-40%) and metronidazole (rare but emerging); Clostridioides difficile - metronidazole resistance emerging (MIC >2 µg/mL); vancomycin resistance is rare. Treatment: Metronidazole for mild-moderate infections; vancomycin for severe or metronidazole-resistant C. difficile; carbapenems or piperacillin-tazobactam for serious anaerobic infections.',
          ),
          const SizedBox(height: 16),
          _buildAstPitfallsCard(),
          const SizedBox(height: 16),
          _buildBetaLactamAllergyCard(),
          const SizedBox(height: 16),
          StructuredContentCard(
            icon: Icons.medical_information_outlined,
            color: AppColors.primary,
            heading: 'Stewardship Role in AST Interpretation',
            content:
                'Antimicrobial stewardship teams play a critical role in AST interpretation and education. Review discrepant AST results with microbiology laboratory (e.g., cefepime-susceptible ESBL, colistin-susceptible CRAB). Educate prescribers on resistance mechanisms and AST pitfalls (e.g., avoid cephalosporins for ESCPM organisms, avoid fluoroquinolones for N. gonorrhoeae). Collaborate with infection control to identify outbreaks of resistant organisms (e.g., carbapenemase-producing Enterobacterales, C. auris). Advocate for molecular diagnostics and rapid AST technologies to improve time to appropriate therapy.',
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

  Widget _buildCAurisCard() {
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
                  Icons.coronavirus_outlined,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Candida auris Identification and AST Challenges (CRITICAL)',
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
            'C. auris is a CDC urgent threat and WHO critical priority pathogen due to multidrug resistance, environmental persistence, and outbreak potential. C. auris was first identified in 2009 and has since spread globally, causing healthcare-associated outbreaks with high mortality (30-60%).',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildCAurisItem(
            'Identification Challenges',
            'Conventional methods (API, Vitek 2) misidentify C. auris as C. haemulonii or C. duobushaemulonii. MALDI-TOF MS or molecular methods (PCR, sequencing) are required for accurate identification. All Candida isolates from sterile sites should be identified to species level.',
            Icons.search_outlined,
          ),
          _buildCAurisItem(
            'Resistance Profile',
            '90% fluconazole-resistant (MIC ≥32 µg/mL); 30-40% amphotericin B-resistant (MIC ≥2 µg/mL); Echinocandin resistance emerging (5-10%, FKS mutations); Pan-resistant isolates reported (resistant to all three classes).',
            Icons.shield_outlined,
          ),
          _buildCAurisItem(
            'AST Challenges',
            'Broth microdilution is the reference method per CLSI M27/M44 3rd Edition (2025). Disk diffusion is NOT validated for C. auris. Echinocandin MIC testing is critical; FKS mutations confer resistance (anidulafungin MIC ≥4 µg/mL, micafungin MIC ≥4 µg/mL).',
            Icons.biotech_outlined,
          ),
          _buildCAurisItem(
            'Treatment',
            'Echinocandins are first-line therapy (anidulafungin 200 mg loading dose, then 100 mg daily; micafungin 100 mg daily). High-dose liposomal amphotericin B (5 mg/kg/day) for echinocandin-resistant isolates. Combination therapy (echinocandin + amphotericin B) for pan-resistant isolates.',
            Icons.medication_outlined,
          ),
          _buildCAurisItem(
            'Infection Control',
            'Contact precautions, dedicated equipment, environmental disinfection with sporicidal agents (e.g., chlorine-based disinfectants, hydrogen peroxide vapor). C. auris persists on surfaces for weeks; aggressive environmental cleaning is critical.',
            Icons.cleaning_services_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildCAurisItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              icon,
              color: AppColors.error,
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
                    color: AppColors.error,
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

  Widget _buildAstPitfallsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
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
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_outlined,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AST Pitfalls and Troubleshooting',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPitfallItem(
            'Cefepime-susceptible ESBL',
            'Cefepime may appear susceptible in vitro but has variable clinical efficacy for ESBL infections. Avoid cefepime for serious ESBL infections (bacteremia, pneumonia); use carbapenems.',
          ),
          _buildPitfallItem(
            'Inducible AmpC resistance',
            'ESCPM organisms may appear susceptible to cephalosporins but develop resistance during therapy. Avoid cephalosporins for serious ESCPM infections; use carbapenems or cefepime at high doses.',
          ),
          _buildPitfallItem(
            'Colistin MIC testing',
            'Colistin MIC testing is unreliable; only broth microdilution is validated. Automated systems (Vitek 2, MicroScan) are NOT validated for colistin.',
          ),
          _buildPitfallItem(
            'Daptomycin calcium requirement',
            'Daptomycin MIC testing requires calcium-adjusted media (50 mg/L Ca²⁺) per CLSI guidelines. Standard media underestimates MIC.',
          ),
          _buildPitfallItem(
            'Cefiderocol iron-depleted media',
            'Cefiderocol MIC testing requires iron-depleted media per CLSI M100. Standard media overestimates MIC (false resistance).',
          ),
          _buildPitfallItem(
            'Heteroresistance',
            'Routine AST may miss resistant subpopulations (hVISA, colistin heteroresistance). Suspect if persistent infection despite susceptible AST.',
          ),
        ],
      ),
    );
  }

  Widget _buildPitfallItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.error_outline,
              color: AppColors.warning,
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
                    color: AppColors.warning,
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

  Widget _buildBetaLactamAllergyCard() {
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
                  Icons.medical_information_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Beta-Lactam Allergy Assessment and Cross-Reactivity (CRITICAL)',
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
          Text(
            'Beta-lactam allergy is reported by 10% of patients, but <1% have true IgE-mediated allergy. Penicillin allergy labels lead to unnecessary use of broad-spectrum antibiotics (vancomycin, fluoroquinolones, carbapenems), increased healthcare costs, and worse patient outcomes (longer hospital stays, higher mortality, more C. difficile infections).',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildAllergyItem(
            'Penicillin to Cephalosporin Cross-Reactivity',
            '<2% for first-generation cephalosporins (cefazolin); <1% for second-generation and third-generation cephalosporins (ceftriaxone, cefepime). Cross-reactivity is due to shared R1 side chain, not beta-lactam ring. Ceftriaxone and cefepime have different R1 side chains from penicillin → safe in most penicillin-allergic patients.',
          ),
          _buildAllergyItem(
            'Penicillin to Carbapenem Cross-Reactivity',
            '<1% for carbapenems (meropenem, imipenem, ertapenem). Carbapenems are safe in most penicillin-allergic patients, even those with history of anaphylaxis.',
          ),
          _buildAllergyItem(
            'Penicillin to Aztreonam Cross-Reactivity',
            '<1% for aztreonam (monobactam). Aztreonam is safe in most penicillin-allergic patients. Exception: Ceftazidime and aztreonam share the same R1 side chain → avoid aztreonam if ceftazidime allergy.',
          ),
          _buildAllergyItem(
            'Penicillin Allergy Assessment',
            'History of reaction: Anaphylaxis (immediate, life-threatening) vs. non-anaphylactic (rash, GI upset). Timing: Recent (<5 years) vs. remote (>10 years); 80% of patients lose penicillin-specific IgE after 10 years. Penicillin skin testing: Negative predictive value >95%; safe to administer penicillin if negative. Oral challenge: Gold standard for ruling out penicillin allergy.',
          ),
          _buildAllergyItem(
            'Stewardship Implications',
            'Penicillin allergy de-labeling programs reduce unnecessary broad-spectrum antibiotic use by 30-50%. Pharmacist-led allergy assessment and skin testing programs are cost-effective and improve patient outcomes. CDC recommends penicillin allergy assessment for all patients with penicillin allergy labels.',
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyItem(String title, String description) {
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
                    color: AppColors.primary,
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
      'ESBL detection: Carbapenems are first-line for serious infections; avoid cefepime despite in vitro susceptibility',
      'AmpC inducible resistance: Avoid cephalosporins for ESCPM organisms (Enterobacter, Serratia, Citrobacter); use carbapenems',
      'Carbapenemase detection: KPC (ceftazidime-avibactam, meropenem-vaborbactam), NDM (aztreonam + ceftazidime-avibactam, cefiderocol)',
      'Heteroresistance: hVISA and colistin heteroresistance not detected by routine AST → suspect if persistent infection despite susceptible AST',
      'C. auris: MALDI-TOF or molecular methods required for identification; 90% fluconazole-resistant; echinocandins first-line',
      'Fastidious organisms: H. influenzae (beta-lactamase testing), HACEK (extended incubation 5-7 days), S. pneumoniae (site-specific breakpoints)',
      'N. gonorrhoeae: Ceftriaxone MIC ≥0.125 µg/mL concerning; azithromycin no longer recommended; test-of-cure for elevated MICs',
      'AST pitfalls: Colistin (broth microdilution only), daptomycin (calcium-adjusted media), cefiderocol (iron-depleted media)',
      'Beta-lactam allergy: Penicillin to cephalosporin cross-reactivity <2%; penicillin to carbapenem <1%; de-labeling programs reduce broad-spectrum use by 30-50%',
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
        'label': 'CDC Antibiotic Resistance Threats Report (2019) - Carbapenemase-Producing Enterobacterales',
        'url': 'https://www.cdc.gov/drugresistance/biggest-threats.html',
      },
      {
        'label': 'CDC Candida auris Interim Guidance (2023)',
        'url': 'https://www.cdc.gov/fungal/candida-auris/c-auris-infection-control.html',
      },
      {
        'label': 'CDC Penicillin Allergy Guidance (2017) - Evaluation and Diagnosis',
        'url': 'https://www.cdc.gov/antibiotic-use/community/for-hcp/penicillin-allergy.html',
      },
      {
        'label': 'Blumenthal KG, et al. Antibiotic Allergy. Lancet. 2019.',
        'url': 'https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(18)32218-9/fulltext',
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


