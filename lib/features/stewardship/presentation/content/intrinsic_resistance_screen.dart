import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Intrinsic Resistance and AST Interpretation Screen
/// Comprehensive evidence-based guidance on intrinsic resistance patterns for accurate AST interpretation
class IntrinsicResistanceScreen extends StatelessWidget {
  const IntrinsicResistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intrinsic Resistance and AST Interpretation'),
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
        // Header Card
        ContentHeaderCard(
          title: 'Intrinsic Resistance and AST Interpretation',
          subtitle: 'Understanding inherent resistance patterns for accurate AST interpretation and stewardship',
          description:
              'Intrinsic resistance is inherent, naturally occurring resistance present in all strains of a bacterial species due to structural or functional characteristics. Unlike acquired resistance (which is gained through genetic mutations or horizontal gene transfer), intrinsic resistance is predictable and consistent across all strains of a species. Understanding intrinsic resistance is critical for antimicrobial stewardship teams to prevent inappropriate prescribing, interpret AST reports correctly, and construct accurate antibiograms.',
          icon: Icons.shield_outlined,
          iconColor: AppColors.info,
        ),
        const SizedBox(height: 16),

        // Section 1: Definition and Distinction
        StructuredContentCard(
          heading: 'Definition and Distinction',
          content:
              'Intrinsic resistance is resistance that is naturally present in all members of a bacterial species due to inherent structural or functional characteristics (e.g., lack of target, impermeability, efflux pumps, chromosomal enzymes). Acquired resistance is resistance gained through genetic mutations or horizontal gene transfer (e.g., ESBL, carbapenemase, mecA gene). The key distinction is that intrinsic resistance is predictable and consistent across all strains, while acquired resistance is variable and unpredictable.',
          icon: Icons.info_outline,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),

        // Section 2: Mechanisms of Intrinsic Resistance
        StructuredContentCard(
          heading: 'Mechanisms of Intrinsic Resistance',
          content:
              '(1) Lack of target - organism lacks the antimicrobial target (e.g., Mycoplasma lacks cell wall → intrinsically resistant to all beta-lactams); (2) Impermeability - outer membrane prevents drug entry (e.g., Gram-negative bacteria intrinsically resistant to vancomycin due to large molecular size); (3) Efflux pumps - constitutive efflux pumps remove drug before it reaches target (e.g., P. aeruginosa MexAB-OprM efflux pump); (4) Enzymatic inactivation - chromosomally encoded enzymes inactivate drug (e.g., S. maltophilia L1/L2 metallo-beta-lactamases hydrolyze carbapenems); (5) Target modification - inherent target structure prevents drug binding (e.g., Enterococcus low-affinity PBPs → intrinsic resistance to cephalosporins).',
          icon: Icons.science_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),

        // Section 3: Clinical Significance for Stewardship
        StructuredContentCard(
          heading: 'Clinical Significance for Stewardship',
          content:
              '(1) AST reporting - laboratories should NOT report intrinsically resistant organism-antimicrobial combinations per CLSI M100 Table 1A; (2) Antibiogram construction - intrinsically resistant combinations must be excluded from antibiogram calculations to avoid misleading susceptibility rates; (3) Empiric therapy selection - intrinsic resistance patterns guide appropriate empiric therapy selection and prevent futile therapy; (4) Prescriber education - common prescribing errors involve intrinsically resistant combinations (e.g., cephalosporins for Enterococcus, TMP-SMX for P. aeruginosa); (5) Quality assurance - intrinsic resistance patterns serve as internal quality control for AST accuracy.',
          icon: Icons.medical_services_outlined,
          color: AppColors.info,
        ),
        const SizedBox(height: 16),

        // Custom Card: Gram-Positive Intrinsic Resistance
        _buildGramPositiveCard(),
        const SizedBox(height: 16),

        // Custom Card: Gram-Negative Intrinsic Resistance
        _buildGramNegativeCard(),
        const SizedBox(height: 16),

        // Section 4: Anaerobic Intrinsic Resistance
        StructuredContentCard(
          heading: 'Anaerobic Intrinsic Resistance',
          content:
              'All anaerobic bacteria (Bacteroides fragilis, Clostridium spp., Peptostreptococcus spp., Fusobacterium spp.) are intrinsically resistant to aminoglycosides because aminoglycosides require oxygen for active uptake into bacterial cells (oxygen-dependent transport) → never use aminoglycosides for anaerobic infections. Clostridioides difficile is intrinsically resistant to most cephalosporins due to efflux → cephalosporins are a major risk factor for C. difficile infection (CDI) due to disruption of gut microbiota.',
          icon: Icons.air,
          color: AppColors.warning,
        ),
        const SizedBox(height: 16),

        // Custom Card: Fungal Intrinsic Resistance
        _buildFungalResistanceCard(),
        const SizedBox(height: 16),

        // Section 5: Atypical Organisms Intrinsic Resistance
        StructuredContentCard(
          heading: 'Atypical Organisms Intrinsic Resistance',
          content:
              'Mycoplasma pneumoniae and Chlamydia spp. (C. pneumoniae, C. trachomatis) are intrinsically resistant to all beta-lactams because they lack a cell wall (no peptidoglycan) → use macrolides (azithromycin, clarithromycin), fluoroquinolones (levofloxacin, moxifloxacin), or tetracyclines (doxycycline) for atypical pneumonia. Legionella pneumophila is intrinsically resistant to most beta-lactams due to intracellular location → use macrolides or fluoroquinolones for Legionnaires\' disease.',
          icon: Icons.coronavirus_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),

        // Section 6: CLSI Guidance on Intrinsic Resistance Reporting
        StructuredContentCard(
          heading: 'CLSI Guidance on Intrinsic Resistance Reporting',
          content:
              'CLSI M100 35th Edition (2025) Table 1A provides a comprehensive list of intrinsic resistance patterns that should NOT be reported by clinical microbiology laboratories. If an organism appears \'susceptible\' to an intrinsically resistant antimicrobial, this indicates: (1) Organism misidentification (e.g., Enterococcus misidentified as Streptococcus); (2) AST methodology error (e.g., wrong panel, wrong incubation conditions); (3) Reporting error (e.g., manual transcription error). Stewardship teams should review AST reports for inappropriate reporting of intrinsically resistant combinations and alert the laboratory to investigate.',
          icon: Icons.rule_outlined,
          color: AppColors.info,
        ),
        const SizedBox(height: 16),

        // Section 7: Antibiogram Construction and Intrinsic Resistance
        StructuredContentCard(
          heading: 'Antibiogram Construction and Intrinsic Resistance',
          content:
              'When constructing institutional antibiograms per CLSI M39 guidelines, intrinsically resistant organism-antimicrobial combinations must be excluded from susceptibility calculations. For example, when calculating ceftriaxone susceptibility for Gram-negative organisms, exclude Enterococcus, Stenotrophomonas, Burkholderia, and other intrinsically resistant organisms. Failure to exclude intrinsically resistant combinations will artificially inflate susceptibility rates and mislead prescribers.',
          icon: Icons.bar_chart_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),

        // Custom Card: Common Prescribing Errors
        _buildPrescribingErrorsCard(),
        const SizedBox(height: 16),

        // Section 8: Quality Assurance and Intrinsic Resistance
        StructuredContentCard(
          heading: 'Quality Assurance and Intrinsic Resistance',
          content:
              'Intrinsic resistance patterns serve as internal quality control for AST accuracy. If an organism appears \'susceptible\' to an intrinsically resistant antimicrobial, investigate: (1) Organism identification - confirm species identification using MALDI-TOF or 16S rRNA sequencing; (2) AST methodology - verify correct panel, media, incubation conditions, and inoculum density; (3) Quality control strains - review QC data for the same antimicrobial-organism combination; (4) Reporting process - check for manual transcription errors or software errors. Document the investigation and corrective action in the laboratory quality management system.',
          icon: Icons.verified_outlined,
          color: AppColors.success,
        ),
        const SizedBox(height: 16),

        // Section 9: Stewardship Interventions for Intrinsic Resistance Errors
        StructuredContentCard(
          heading: 'Stewardship Interventions for Intrinsic Resistance Errors',
          content:
              'When stewardship teams identify prescribing of intrinsically resistant agents: (1) Immediate intervention - contact prescriber to modify order (phone call or electronic alert); (2) Education - explain intrinsic resistance pattern and appropriate alternatives; (3) Documentation - document intervention in medical record and stewardship database; (4) Follow-up - verify order modification and clinical response; (5) Aggregate data - track frequency of intrinsic resistance errors by prescriber, service, and organism to identify educational opportunities. Common interventions include switching cephalosporins to ampicillin for Enterococcus, switching TMP-SMX to ciprofloxacin for P. aeruginosa, and switching carbapenems to TMP-SMX for S. maltophilia.',
          icon: Icons.support_agent_outlined,
          color: AppColors.info,
        ),
        const SizedBox(height: 16),

        // Key Takeaways Card
        _buildKeyTakeawaysCard(),
        const SizedBox(height: 16),

        // References Card
        _buildReferencesCard(context),
        const SizedBox(height: 48),
      ],
    ),
    );
  }

  // Helper method: Gram-Positive Intrinsic Resistance Card
  Widget _buildGramPositiveCard() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report_outlined, color: AppColors.success, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gram-Positive Intrinsic Resistance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSubsection(
              'Enterococcus spp.',
              '• Cephalosporins (all generations): Low-affinity PBPs → never use cephalosporins\n'
              '• Aminoglycosides (low-level): Impermeability → require synergy with cell wall-active agent\n'
              '• Ampicillin (E. faecium): PBP5 alteration → use vancomycin or linezolid\n'
              '• Clindamycin: Lack of target → never use clindamycin',
            ),
            const SizedBox(height: 12),
            _buildSubsection(
              'Staphylococcus saprophyticus',
              '• Novobiocin: Efflux → diagnostic marker for S. saprophyticus (novobiocin-resistant coagulase-negative Staph)\n'
              '• Common cause of uncomplicated UTI in young women',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method: Gram-Negative Intrinsic Resistance Card
  Widget _buildGramNegativeCard() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report_outlined, color: AppColors.error, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gram-Negative Intrinsic Resistance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSubsection(
              'Pseudomonas aeruginosa',
              '• Ampicillin, amoxicillin, 1st/2nd-gen cephalosporins: Impermeability + efflux\n'
              '• TMP-SMX: Efflux\n'
              '• Use antipseudomonal agents only: ceftazidime, cefepime, piperacillin-tazobactam, carbapenems, fluoroquinolones',
            ),
            const SizedBox(height: 12),
            _buildSubsection(
              'Stenotrophomonas maltophilia',
              '• All carbapenems: L1/L2 metallo-beta-lactamases\n'
              '• First-line: TMP-SMX; alternatives: levofloxacin, minocycline, ceftazidime',
            ),
            const SizedBox(height: 12),
            _buildSubsection(
              'Burkholderia cepacia',
              '• Aminoglycosides, colistin: Impermeability\n'
              '• Significant pathogen in cystic fibrosis (\'cepacia syndrome\')\n'
              '• First-line: TMP-SMX or ceftazidime',
            ),
            const SizedBox(height: 12),
            _buildSubsection(
              'Serratia, Morganella, Proteus, Providencia',
              '• Serratia: Colistin/polymyxin B (LPS modification)\n'
              '• Morganella/Providencia: Colistin/polymyxin B (LPS modification)\n'
              '• Proteus: Tigecycline (efflux) → never use tigecycline for Proteus',
            ),
            const SizedBox(height: 12),
            _buildSubsection(
              'Acinetobacter baumannii',
              '• Ertapenem: Impermeability → use meropenem or imipenem (NOT ertapenem)\n'
              '• Sulbactam has intrinsic activity: ampicillin-sulbactam 9 g q8h may be effective',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method: Fungal Intrinsic Resistance Card
  Widget _buildFungalResistanceCard() {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.coronavirus_outlined, color: AppColors.warning, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Fungal Intrinsic Resistance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSubsection(
              'Candida krusei',
              '• Fluconazole: Altered target (ERG11 mutation)\n'
              '• Use echinocandin or amphotericin B first-line\n'
              '• Accounts for 2-5% of candidemia cases',
            ),
            const SizedBox(height: 12),
            _buildSubsection(
              'Candida glabrata',
              '• Fluconazole (SDD): Efflux pumps (CDR1, CDR2)\n'
              '• High-dose fluconazole (800 mg daily) may be effective, but echinocandins preferred\n'
              '• Accounts for 15-20% of candidemia; developing echinocandin resistance (5-10%)',
            ),
            const SizedBox(height: 12),
            _buildSubsection(
              'Aspergillus and Mucorales',
              '• Aspergillus: Fluconazole (lack of target) → use voriconazole or isavuconazole\n'
              '• Mucorales: Voriconazole/posaconazole (lack of target) → use amphotericin B\n'
              '• Mucormycosis associated with DKA, hematologic malignancies, transplantation',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method: Common Prescribing Errors Card
  Widget _buildPrescribingErrorsCard() {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: AppColors.error, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Common Prescribing Errors (STEWARDSHIP RED FLAGS)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildErrorItem(
              '❌ Cephalosporins for Enterococcus',
              'Example: Ceftriaxone for E. faecalis UTI',
              'Intervention: Switch to ampicillin or nitrofurantoin',
            ),
            const SizedBox(height: 12),
            _buildErrorItem(
              '❌ TMP-SMX for P. aeruginosa',
              'Example: TMP-SMX for P. aeruginosa UTI',
              'Intervention: Switch to ciprofloxacin or ceftazidime',
            ),
            const SizedBox(height: 12),
            _buildErrorItem(
              '❌ Carbapenems for S. maltophilia',
              'Example: Meropenem for S. maltophilia pneumonia',
              'Intervention: Switch to TMP-SMX',
            ),
            const SizedBox(height: 12),
            _buildErrorItem(
              '❌ Fluconazole for C. krusei',
              'Example: Fluconazole for C. krusei candidemia',
              'Intervention: Switch to echinocandin',
            ),
            const SizedBox(height: 12),
            _buildErrorItem(
              '❌ Beta-lactams for atypical pneumonia',
              'Example: Ceftriaxone monotherapy for Mycoplasma pneumonia',
              'Intervention: Add macrolide or switch to fluoroquinolone',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method: Key Takeaways Card
  Widget _buildKeyTakeawaysCard() {
    return Card(
      elevation: 2,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.success, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Key Takeaways',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTakeawayItem(
              'Intrinsic resistance is inherent and predictable: All strains of a species share the same intrinsic resistance pattern (unlike acquired resistance)',
            ),
            _buildTakeawayItem(
              'Enterococcus intrinsic resistance: Resistant to cephalosporins (all), aminoglycosides (low-level), clindamycin → use ampicillin (E. faecalis) or vancomycin/linezolid (E. faecium)',
            ),
            _buildTakeawayItem(
              'P. aeruginosa intrinsic resistance: Resistant to ampicillin, 1st/2nd-gen cephalosporins, TMP-SMX → use antipseudomonal agents only (ceftazidime, cefepime, piperacillin-tazobactam, carbapenems, fluoroquinolones)',
            ),
            _buildTakeawayItem(
              'S. maltophilia intrinsic carbapenem resistance: Resistant to all carbapenems due to L1/L2 metallo-beta-lactamases → use TMP-SMX first-line',
            ),
            _buildTakeawayItem(
              'Anaerobes intrinsically resistant to aminoglycosides: Aminoglycosides require oxygen for uptake → never use for anaerobic infections',
            ),
            _buildTakeawayItem(
              'C. krusei intrinsically resistant to fluconazole: Use echinocandin or amphotericin B first-line',
            ),
            _buildTakeawayItem(
              'Atypical organisms intrinsically resistant to beta-lactams: Mycoplasma, Chlamydia, Legionella lack cell wall → use macrolides, fluoroquinolones, or tetracyclines',
            ),
            _buildTakeawayItem(
              'AST reporting rule: Laboratories should NOT report intrinsically resistant organism-antimicrobial combinations per CLSI M100 Table 1A',
            ),
            _buildTakeawayItem(
              'Stewardship red flag: Prescribing intrinsically resistant agents is a stewardship intervention opportunity (education, order modification)',
            ),
            _buildTakeawayItem(
              'Antibiogram exclusion: Intrinsically resistant combinations must be excluded from antibiogram calculations to avoid misleading susceptibility rates',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method: References Card
  Widget _buildReferencesCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books_outlined, color: AppColors.info, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Official References',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReferenceItem(
              context,
              'CLSI M100 35th Edition (2025) - Performance Standards for Antimicrobial Susceptibility Testing (Table 1A: Intrinsic Resistance)',
              'https://clsi.org/standards/products/microbiology/documents/m100/',
            ),
            const SizedBox(height: 12),
            _buildReferenceItem(
              context,
              'CDC Antibiotic Resistance Threats Report (2019) - Intrinsic Resistance Patterns for Priority Pathogens',
              'https://www.cdc.gov/drugresistance/biggest-threats.html',
            ),
            const SizedBox(height: 12),
            _buildReferenceItem(
              context,
              'IDSA/SHEA Antimicrobial Stewardship Guidelines (2016) - Prescriber Education on Intrinsic Resistance',
              'https://www.idsociety.org/practice-guideline/antimicrobial-stewardship/',
            ),
            const SizedBox(height: 12),
            _buildReferenceItem(
              context,
              'WHO Priority Pathogens List (2024) - Intrinsic Resistance in Critical Priority Pathogens',
              'https://www.who.int/news/item/17-05-2024-who-updates-list-of-drug-resistant-bacteria-most-threatening-to-human-health',
            ),
            const SizedBox(height: 12),
            _buildReferenceItem(
              context,
              'EUCAST Expert Rules and Intrinsic Resistance Tables (2024)',
              'https://www.eucast.org/expert_rules_and_intrinsic_resistance/',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method: Build subsection
  Widget _buildSubsection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Helper method: Build error item
  Widget _buildErrorItem(String error, String example, String intervention) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          error,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          example,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          intervention,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.success,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Helper method: Build takeaway item
  Widget _buildTakeawayItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method: Build reference item
  Widget _buildReferenceItem(BuildContext context, String label, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.open_in_new, color: AppColors.info, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

