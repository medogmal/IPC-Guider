import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';

/// Dedicated screen for "Surgical Antimicrobial Prophylaxis"
/// Comprehensive evidence-based guidance on surgical prophylaxis timing, selection, and duration
class SurgicalProphylaxisScreen extends StatelessWidget {
  const SurgicalProphylaxisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Surgical Antimicrobial Prophylaxis'),
        elevation: 0,
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.medical_services_outlined,
            iconColor: AppColors.success,
            title: 'Surgical Antimicrobial Prophylaxis',
            subtitle: 'Evidence-Based SSI Prevention',
            description:
                'Surgical antimicrobial prophylaxis (SAP) is the administration of antibiotics before, during, or immediately after surgery to prevent surgical site infections (SSIs). Appropriate prophylaxis reduces SSI risk by 40-60% while minimizing unnecessary antibiotic exposure, resistance development, and adverse effects. SAP is one of the most common uses of antibiotics in hospitals (20-30% of all antibiotic use) and represents a major stewardship opportunity.',
          ),
          const SizedBox(height: 20),

          // Goals of Surgical Prophylaxis
          StructuredContentCard(
            heading: 'Goals of Surgical Prophylaxis',
            content:
                '(1) Prevent surgical site infections (SSIs) by achieving therapeutic tissue concentrations at the time of incision; (2) Minimize antimicrobial resistance by using narrow-spectrum agents for the shortest effective duration; (3) Reduce adverse effects (C. difficile, allergic reactions, nephrotoxicity) by avoiding unnecessary prolonged courses; (4) Optimize cost-effectiveness by selecting appropriate agents and durations based on evidence-based guidelines.',
            icon: Icons.flag_outlined,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),

          // Surgical Wound Classification
          StructuredContentCard(
            heading: 'Surgical Wound Classification',
            content:
                'The CDC classifies surgical wounds into four categories based on contamination risk, which guides prophylaxis decisions. (1) **Clean** (Class I): No inflammation, no entry into respiratory/GI/GU tracts, no break in aseptic technique (e.g., hernia repair, joint replacement). Prophylaxis recommended only for procedures involving prosthetic implants or high-risk patients. (2) **Clean-Contaminated** (Class II): Controlled entry into respiratory/GI/GU tracts without significant spillage (e.g., elective colorectal surgery, hysterectomy, biliary surgery). Prophylaxis recommended for all cases. (3) **Contaminated** (Class III): Open traumatic wounds, major break in sterile technique, gross spillage from GI tract (e.g., penetrating trauma, bowel perforation). Therapeutic antibiotics required, not prophylaxis. (4) **Dirty** (Class IV): Established infection or perforated viscus (e.g., abscess, peritonitis). Therapeutic antibiotics required, not prophylaxis.',
            icon: Icons.category_outlined,
            color: AppColors.info,  // Blue: Educational classification system
          ),
          const SizedBox(height: 16),

          // Timing of Prophylaxis
          StructuredContentCard(
            heading: 'Timing of Prophylaxis',
            content:
                'Optimal timing is within 60 minutes before surgical incision to achieve therapeutic tissue concentrations when bacteria are introduced. For vancomycin and fluoroquinolones (longer infusion times), administer within 120 minutes before incision. Prophylaxis administered too early (>60 minutes) or too late (after incision) increases SSI risk by 2-3 fold. Redosing is required for prolonged procedures.',
            icon: Icons.schedule,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),

          // Duration of Prophylaxis
          StructuredContentCard(
            heading: 'Duration of Prophylaxis',
            content:
                'Single-dose prophylaxis is sufficient for most clean and clean-contaminated procedures. For cardiac and orthopedic procedures with prosthetic implants, prophylaxis may be continued for up to 24 hours postoperatively. **No benefit** has been demonstrated for prophylaxis beyond 24 hours; prolonged courses increase C. difficile risk, antimicrobial resistance, and adverse effects without reducing SSI rates. Discontinue prophylaxis within 24 hours unless therapeutic antibiotics are indicated for established infection.',
            icon: Icons.timer_outlined,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),

          // Procedure-Specific Recommendations
          _buildProcedureSpecificCard(),
          const SizedBox(height: 16),

          // Redosing Intervals
          StructuredContentCard(
            heading: 'Redosing Intervals for Prolonged Procedures',
            content:
                'Redosing is required when procedure duration exceeds 2 half-lives of the antibiotic to maintain therapeutic tissue concentrations. (1) **Cefazolin**: Redose 2g IV every 4 hours if procedure duration >4 hours (half-life ~2 hours). (2) **Cefoxitin**: Redose 2g IV every 2 hours if procedure duration >2 hours (half-life ~1 hour). (3) **Cefuroxime**: Redose 1.5g IV every 4 hours if procedure duration >4 hours. (4) **Vancomycin**: Redose 15mg/kg IV every 12 hours if procedure duration >12 hours (rarely needed). (5) **Clindamycin**: Redose 900mg IV every 6 hours if procedure duration >6 hours. (6) **Massive Blood Loss**: Redose immediately if blood loss exceeds 1,500 mL (dilutional effect reduces tissue concentrations).',
            icon: Icons.refresh,
            color: AppColors.warning,  // Amber: Time-sensitive redosing caution
          ),
          const SizedBox(height: 16),

          // Beta-Lactam Allergy Management
          StructuredContentCard(
            heading: 'Beta-Lactam Allergy Management',
            content:
                'Careful allergy assessment is essential to avoid unnecessary use of broad-spectrum alternatives (vancomycin, fluoroquinolones). (1) **Type I Hypersensitivity** (anaphylaxis, angioedema, bronchospasm, urticaria within 1 hour): Avoid all beta-lactams. Use vancomycin 15mg/kg IV or clindamycin 900mg IV (depending on procedure). (2) **Non-Severe Reactions** (delayed rash, nausea, diarrhea): Cephalosporins are acceptable. Cross-reactivity between penicillins and cephalosporins is <1% for non-anaphylactic reactions. (3) **Unknown or Unclear History**: Perform allergy assessment or skin testing if time permits. If urgent surgery, use vancomycin or clindamycin.',
            icon: Icons.warning_amber_rounded,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),

          // Weight-Based Dosing for Obesity
          StructuredContentCard(
            heading: 'Weight-Based Dosing for Obesity',
            content:
                'Obesity is an independent risk factor for SSI due to increased adipose tissue, altered pharmacokinetics, and subtherapeutic tissue concentrations with standard doses. (1) **Cefazolin**: Use 3g IV (instead of 2g) if weight ≥120kg. Evidence shows standard 2g dose achieves subtherapeutic tissue concentrations in obese patients. (2) **Cefoxitin**: Use 3g IV (instead of 2g) if weight ≥120kg. (3) **Vancomycin**: Use 15mg/kg IV based on actual body weight (maximum 2g per dose for practical reasons, though higher doses may be needed for morbid obesity). (4) **Clindamycin**: Use 900mg IV (standard dose adequate for most patients).',
            icon: Icons.monitor_weight_outlined,
            color: AppColors.warning,  // Amber: Special population requiring dose adjustment
          ),
          const SizedBox(height: 16),

          // MRSA Colonization
          StructuredContentCard(
            heading: 'MRSA Colonization and High-Risk Patients',
            content:
                'Add vancomycin 15mg/kg IV to standard cefazolin prophylaxis for patients with known MRSA colonization or institutions with high MRSA rates (>20% of S. aureus isolates). This dual prophylaxis is recommended for cardiac and orthopedic procedures with prosthetic implants. Preoperative MRSA decolonization (mupirocin nasal ointment BID + chlorhexidine body wash daily for 5 days) reduces SSI risk and may eliminate need for vancomycin prophylaxis.',
            icon: Icons.coronavirus_outlined,
            color: AppColors.error,  // Red: Critical pathogen (MRSA)
          ),
          const SizedBox(height: 16),

          // Common Stewardship Pitfalls
          _buildPitfallsCard(),
          const SizedBox(height: 20),

          // Clinical Scenarios Section
          _buildClinicalScenariosSection(),
          const SizedBox(height: 20),

          // Key Takeaways Section
          _buildKeyTakeawaysCard(),
          const SizedBox(height: 20),

          // References Section
          _buildReferencesCard(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }


  Widget _buildProcedureSpecificCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
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
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.local_hospital, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Procedure-Specific Recommendations',
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
          _buildProcedureItem(
            '1. Cardiac Surgery (CABG, valve replacement)',
            'Cefazolin 2g IV (or cefuroxime 1.5g IV) within 60 minutes before incision. Redose cefazolin q4h if procedure >4 hours. Duration: single dose or up to 24 hours. Alternative for beta-lactam allergy: vancomycin 15mg/kg IV.',
          ),
          _buildProcedureItem(
            '2. Orthopedic Surgery (joint replacement, spine surgery)',
            'Cefazolin 2g IV (3g if weight ≥120kg) within 60 minutes before incision. Redose q4h if procedure >4 hours. Duration: single dose or up to 24 hours. Add vancomycin 15mg/kg IV if known MRSA colonization.',
          ),
          _buildProcedureItem(
            '3. Colorectal Surgery',
            'Cefazolin 2g IV + metronidazole 500mg IV (or cefoxitin 2g IV, or ertapenem 1g IV) within 60 minutes before incision. Duration: single dose or up to 24 hours.',
          ),
          _buildProcedureItem(
            '4. Cesarean Section',
            'Cefazolin 2g IV (3g if weight ≥120kg) after umbilical cord clamping (or within 60 minutes before incision for scheduled cesarean). Duration: single dose. Alternative: clindamycin 900mg IV + gentamicin 5mg/kg IV.',
          ),
          _buildProcedureItem(
            '5. Hysterectomy (abdominal or vaginal)',
            'Cefazolin 2g IV (or cefoxitin 2g IV, or cefotetan 2g IV) within 60 minutes before incision. Duration: single dose.',
          ),
          _buildProcedureItem(
            '6. Vascular Surgery (aortic, lower extremity bypass)',
            'Cefazolin 2g IV within 60 minutes before incision. Redose q4h if procedure >4 hours. Duration: single dose or up to 24 hours.',
          ),
          _buildProcedureItem(
            '7. Neurosurgery (craniotomy, spine surgery)',
            'Cefazolin 2g IV within 60 minutes before incision. Redose q4h if procedure >4 hours. Duration: single dose or up to 24 hours.',
          ),
        ],
      ),
    );
  }

  Widget _buildProcedureItem(String title, String description) {
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

  Widget _buildPitfallsCard() {
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
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Common Stewardship Pitfalls',
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
          _buildPitfallItem(
            'Timing Errors',
            'Prophylaxis administered too early (>60 minutes before incision) or too late (after incision) increases SSI risk. Use preoperative checklists and anesthesia protocols.',
          ),
          _buildPitfallItem(
            'Prolonged Duration',
            'Prophylaxis continued beyond 24 hours without indication increases C. difficile risk and resistance. Implement automatic stop orders at 24 hours.',
          ),
          _buildPitfallItem(
            'Failure to Redose',
            'Inadequate redosing during prolonged procedures leads to subtherapeutic tissue concentrations. Use intraoperative reminders and anesthesia protocols.',
          ),
          _buildPitfallItem(
            'Inappropriate Vancomycin Use',
            'Vancomycin used routinely instead of cefazolin increases costs, infusion time, and resistance. Reserve vancomycin for beta-lactam allergy or MRSA colonization.',
          ),
          _buildPitfallItem(
            'Inadequate Dosing in Obesity',
            'Standard doses in obese patients (≥120kg) achieve subtherapeutic concentrations. Use weight-based dosing (cefazolin 3g, vancomycin 15mg/kg).',
          ),
          _buildPitfallItem(
            'Prophylaxis for Contaminated/Dirty Wounds',
            'Therapeutic antibiotics (not prophylaxis) are required for established infections. Prophylaxis is ineffective once infection is present.',
          ),
        ],
      ),
    );
  }

  Widget _buildPitfallItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.warning,
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

  Widget _buildClinicalScenariosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clinical Scenarios',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildScenarioCard(
          'Scenario 1: Elective Total Knee Replacement',
          'A 65-year-old man (weight 85kg) undergoes elective total knee replacement. No known drug allergies. MRSA screening negative.',
          'Prophylaxis: Cefazolin 2g IV administered 30 minutes before incision (optimal timing). Procedure duration: 2.5 hours (no redosing needed, as <4 hours). Prophylaxis discontinued at 24 hours postoperatively.',
          'No SSI, appropriate stewardship.',
          AppColors.success,
        ),
        const SizedBox(height: 12),
        _buildScenarioCard(
          'Scenario 2: Cardiac Surgery with MRSA Colonization',
          'A 70-year-old woman (weight 75kg) undergoes CABG. Known MRSA nasal colonization.',
          'Prophylaxis: Cefazolin 2g IV + vancomycin 15mg/kg (1,125mg, round to 1g) IV started 90 minutes before incision (vancomycin infused over 1 hour). Procedure duration: 5 hours. Redosing: Cefazolin 2g IV at 4 hours intraoperatively. Prophylaxis discontinued at 24 hours postoperatively.',
          'No SSI, appropriate dual prophylaxis for MRSA risk.',
          AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildScenarioCard(
          'Scenario 3: Colorectal Surgery with Penicillin Allergy',
          'A 60-year-old man (weight 90kg) undergoes elective sigmoid colectomy. History of penicillin allergy (rash 10 years ago, non-anaphylactic).',
          'Allergy assessment: Non-severe reaction, cephalosporins acceptable (cross-reactivity <1%). Prophylaxis: Cefazolin 2g IV + metronidazole 500mg IV administered 45 minutes before incision. Procedure duration: 3 hours (no redosing needed). Prophylaxis discontinued at 24 hours postoperatively.',
          'No SSI, no allergic reaction, appropriate use of cephalosporin despite penicillin allergy history.',
          AppColors.primary,  // Teal: Clinical scenario
        ),
        const SizedBox(height: 12),
        _buildScenarioCard(
          'Scenario 4: Emergency Cesarean Section',
          'A 28-year-old woman (weight 95kg) undergoes emergency cesarean section for fetal distress. No known drug allergies.',
          'Prophylaxis: Cefazolin 2g IV administered immediately after umbilical cord clamping (standard practice to avoid fetal exposure, though pre-incision dosing is also acceptable). Duration: Single dose (no postoperative doses).',
          'No SSI, appropriate single-dose prophylaxis.',
          AppColors.success,  // Green: Best practice example
        ),
        const SizedBox(height: 12),
        _buildScenarioCard(
          'Scenario 5: Obese Patient Undergoing Spine Surgery',
          'A 50-year-old man (weight 140kg, BMI 42) undergoes lumbar spine fusion with instrumentation. No known drug allergies.',
          'Prophylaxis: Cefazolin 3g IV (weight-based dosing for obesity) administered 40 minutes before incision. Procedure duration: 6 hours. Redosing: Cefazolin 3g IV at 4 hours intraoperatively. Prophylaxis discontinued at 24 hours postoperatively.',
          'No SSI, appropriate weight-based dosing and redosing for prolonged procedure.',
          AppColors.warning,  // Amber: Special consideration (obesity + redosing)
        ),
      ],
    );
  }

  Widget _buildScenarioCard(String title, String patient, String management, String outcome, Color color) {
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
            'Patient: $patient',
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
                    'Outcome: $outcome',
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
      'Timing: within 60 minutes before incision (120 minutes for vancomycin/fluoroquinolones) to achieve therapeutic tissue concentrations',
      'Duration: single dose for most procedures; maximum 24 hours for cardiac/orthopedic with implants (no benefit beyond 24 hours)',
      'Wound classification: clean (implants only), clean-contaminated (all cases), contaminated/dirty (therapeutic antibiotics, not prophylaxis)',
      'First-line agent: cefazolin 2g IV for most procedures (cardiac, orthopedic, vascular, neurosurgery)',
      'Colorectal: cefazolin 2g + metronidazole 500mg (or cefoxitin 2g, or ertapenem 1g)',
      'Redosing: cefazolin q4h, cefoxitin q2h if procedure duration exceeds 2 half-lives; redose immediately if blood loss >1,500 mL',
      'Obesity: cefazolin 3g (not 2g) if weight ≥120kg; vancomycin 15mg/kg actual body weight',
      'Beta-lactam allergy: vancomycin 15mg/kg or clindamycin 900mg for anaphylaxis; cephalosporins acceptable for non-severe reactions (<1% cross-reactivity)',
      'MRSA colonization: add vancomycin 15mg/kg to cefazolin for cardiac/orthopedic procedures with implants',
      'Common pitfalls: wrong timing (>60 min or after incision), prolonged duration (>24h), failure to redose, routine vancomycin use, inadequate dosing in obesity',
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
        'label': 'ASHP/IDSA/SIS/SHEA Clinical Practice Guidelines for Antimicrobial Prophylaxis in Surgery (2013)',
        'url': 'https://academic.oup.com/cid/article/56/2/e30/382067',
      },
      {
        'label': 'WHO Global Guidelines for the Prevention of Surgical Site Infection (2018)',
        'url': 'https://www.who.int/publications/i/item/9789241550475',
      },
      {
        'label': 'CDC Guideline for the Prevention of Surgical Site Infection (2017)',
        'url': 'https://www.cdc.gov/infectioncontrol/guidelines/ssi/',
      },
      {
        'label': 'ACOG Practice Bulletin: Antimicrobial Prophylaxis for Cesarean Delivery (2018)',
        'url': 'https://www.acog.org/clinical/clinical-guidance/practice-bulletin/articles/2018/06/use-of-prophylactic-antibiotics-in-labor-and-delivery',
      },
      {
        'label': 'AAOS/ADA Guideline: Prevention of Orthopaedic Implant Infection (2022)',
        'url': 'https://www.aaos.org/quality/quality-programs/lower-extremity-programs/appropriate-use-criteria-for-the-management-of-patients-with-orthopaedic-implants-undergoing-dental-procedures/',
      },
      {
        'label': 'STS Practice Guideline: Antibiotic Prophylaxis in Cardiac Surgery (2018)',
        'url': 'https://www.sts.org/quality-research-patient-safety/quality/quality-resources',
      },
      {
        'label': 'Sanford Guide to Antimicrobial Therapy (2024)',
        'url': 'https://www.sanfordguide.com/',
      },
      {
        'label': 'Bratzler DW, et al. Clinical Practice Guidelines for Antimicrobial Prophylaxis in Surgery. Am J Health Syst Pharm (2013)',
        'url': 'https://academic.oup.com/ajhp/article/70/3/195/5102902',
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


