import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page 6: Special Populations
/// Pattern 2: Practical/Action-Oriented
/// Special UI: Population-specific cards, clinical scenarios
class SpecialPopulationsScreen extends StatelessWidget {
  const SpecialPopulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Populations'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.people_outlined,
            iconColor: AppColors.success,  // Green: Special populations best practice
            title: 'Special Populations',
            subtitle: 'Pediatric, Geriatric, Pregnancy, Immunocompromised, Critically Ill',
            description: 'Dosing considerations and clinical management for special patient populations',
          ),
          const SizedBox(height: 16),

          // Introduction Card
          const IntroductionCard(
            text: 'Special populations require tailored antimicrobial dosing and management due to altered pharmacokinetics, pharmacodynamics, and unique safety considerations. This includes pediatric patients, geriatric patients, pregnant/lactating women, immunocompromised patients, and critically ill patients.',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // Pediatric Dosing Card
          _buildPediatricCard(),
          const SizedBox(height: 16),

          // Geriatric Considerations Card
          _buildGeriatricCard(),
          const SizedBox(height: 16),

          // Pregnancy & Lactation Card
          _buildPregnancyCard(),
          const SizedBox(height: 16),

          // Immunocompromised Card
          _buildImmunocompromisedCard(),
          const SizedBox(height: 16),

          // Critically Ill Card
          _buildCriticallyIllCard(),
          const SizedBox(height: 16),

          // Clinical Example 1: Pediatric Pneumonia
          _buildClinicalExample1(),
          const SizedBox(height: 16),

          // Clinical Example 2: Geriatric UTI
          _buildClinicalExample2(),
          const SizedBox(height: 16),

          // Clinical Example 3: Pregnancy Pyelonephritis
          _buildClinicalExample3(),
          const SizedBox(height: 16),

          // Clinical Example 4: Neutropenic Fever
          _buildClinicalExample4(),
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

  Widget _buildPediatricCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Pediatric dosing
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
                child: const Icon(Icons.child_care, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pediatric Dosing Considerations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Pediatric dosing is typically weight-based (mg/kg) to account for differences in body composition, organ function, and drug metabolism.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 14),
          _buildPediatricItem('Weight-Based Dosing', 'Most antibiotics dosed in mg/kg (e.g., amoxicillin 90mg/kg/day divided TID for pneumonia)', Icons.scale),
          _buildPediatricItem('Avoid Fluoroquinolones', 'Risk of cartilage damage in children <8 years (except cystic fibrosis)', Icons.warning_amber),
          _buildPediatricItem('Avoid Tetracyclines', 'Risk of tooth discoloration in children <8 years', Icons.warning_amber),
          _buildPediatricItem('Renal Function', 'Adjust doses for renally cleared drugs in neonates and infants (immature renal function)', Icons.water_damage),
        ],
      ),
    );
  }

  Widget _buildPediatricItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.info, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeriatricCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Geriatric considerations
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
                child: const Icon(Icons.elderly, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Geriatric Considerations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGeriatricItem('Age-Related Renal Decline', 'CrCl declines with age; use Cockcroft-Gault equation to estimate renal function', Icons.trending_down),
          _buildGeriatricItem('Polypharmacy', 'Increased risk of drug-drug interactions; review medication list', Icons.medication),
          _buildGeriatricItem('Avoid Fluoroquinolones', 'FDA warning: increased risk of aortic dissection, tendon rupture, peripheral neuropathy', Icons.warning_amber),
          _buildGeriatricItem('Delirium Risk', 'Cefepime, fluoroquinolones can cause neurotoxicity in elderly with renal impairment', Icons.psychology),
        ],
      ),
    );
  }

  Widget _buildGeriatricItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.info, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Pregnancy caution
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
                child: const Icon(Icons.pregnant_woman, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pregnancy & Lactation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Safe Antibiotics:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.success),
          ),
          const SizedBox(height: 8),
          const Text('• Penicillins (amoxicillin, ampicillin)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Cephalosporins (ceftriaxone, cefazolin)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Azithromycin', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          const Text(
            'Avoid:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.error),
          ),
          const SizedBox(height: 8),
          const Text('• Fluoroquinolones (cartilage damage)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Tetracyclines (tooth discoloration, bone growth inhibition)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Aminoglycosides (ototoxicity, nephrotoxicity)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildImmunocompromisedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Immunocompromised
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
                child: const Icon(Icons.shield_outlined, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Immunocompromised Patients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Neutropenic Fever (ANC <500 cells/µL):',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.info),
          ),
          const SizedBox(height: 8),
          const Text('• Empiric therapy: antipseudomonal beta-lactam (cefepime, piperacillin-tazobactam, meropenem)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Add vancomycin if: catheter-related infection, skin/soft tissue infection, hemodynamic instability', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Add antifungal (voriconazole, caspofungin) if fever persists >4-7 days despite antibiotics', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          const Text(
            'Solid Organ Transplant:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.info),
          ),
          const SizedBox(height: 8),
          const Text('• Broader coverage for opportunistic pathogens (Nocardia, Aspergillus, CMV)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Drug-drug interactions with immunosuppressants (tacrolimus, cyclosporine)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildCriticallyIllCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),  // Red: Critically ill critical
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
                child: const Icon(Icons.local_hospital, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Critically Ill Patients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Altered Pharmacokinetics:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.error),
          ),
          const SizedBox(height: 8),
          const Text('• Increased volume of distribution (Vd) due to fluid resuscitation → higher loading doses required', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Augmented renal clearance (ARC) in young trauma/burn patients → higher maintenance doses', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Decreased renal clearance in AKI → dose reduction required', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          const Text(
            'Dosing Strategies:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.error),
          ),
          const SizedBox(height: 8),
          const Text('• Extended or continuous infusions for beta-lactams (maximize time above MIC)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Therapeutic drug monitoring (TDM) for vancomycin, aminoglycosides', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Consult pharmacist or ID specialist for complex dosing', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildClinicalExample1() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Pediatric example
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.info, borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('1', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 1: Pediatric Pneumonia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 5-year-old child (weight 20 kg) with community-acquired pneumonia.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('DOSING', 'Amoxicillin 90 mg/kg/day = 1,800 mg/day divided TID = 600 mg PO TID', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('DURATION', '5 days (evidence-based for CAP)', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('RATIONALE', 'Weight-based dosing ensures therapeutic concentrations in pediatric patients', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildClinicalExample2() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Geriatric example
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.info, borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 2: Geriatric UTI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('An 80-year-old woman with pyelonephritis has CrCl 30 mL/min (Cockcroft-Gault).', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('EMPIRIC THERAPY', 'Ceftriaxone 1g IV daily (no renal adjustment required)', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('CONVERSION', 'After 3 days → ciprofloxacin 250mg PO BID (reduced dose for CrCl 30)', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('CAUTION', 'Avoid fluoroquinolones if possible in elderly (FDA warning: aortic dissection, tendon rupture)', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildClinicalExample3() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Pregnancy example
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 3: Pregnancy with Pyelonephritis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 28-year-old pregnant woman (2nd trimester) with pyelonephritis.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('SAFE THERAPY', 'Ceftriaxone 1g IV daily (safe in pregnancy)', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('CONVERSION', 'After 3 days → cephalexin 500mg PO QID (safe in pregnancy)', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('AVOID', 'Fluoroquinolones (cartilage damage), tetracyclines (tooth discoloration), aminoglycosides (ototoxicity)', AppColors.error),
        ],
      ),
    );
  }

  Widget _buildClinicalExample4() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),  // Red: Neutropenic fever critical
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('4', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 4: Neutropenic Fever', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 45-year-old man with AML (ANC 100 cells/µL) develops fever (38.5°C).', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('EMPIRIC THERAPY', 'Cefepime 2g IV q8h (antipseudomonal beta-lactam)', AppColors.error),
          const SizedBox(height: 8),
          _buildExampleSection('DAY 5', 'Fever persists despite antibiotics → add voriconazole 6mg/kg IV q12h × 2 doses, then 4mg/kg IV q12h (empiric antifungal)', AppColors.warning),
          const SizedBox(height: 8),
          _buildExampleSection('RATIONALE', 'Neutropenic fever requires broad-spectrum coverage; add antifungal if fever persists >4-7 days', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildExampleSection(String label, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
      ],
    );
  }

  Widget _buildKeyTakeawaysCard() {
    final keyPoints = [
      'Pediatric dosing: weight-based (mg/kg); avoid fluoroquinolones and tetracyclines in children <8 years',
      'Geriatric considerations: age-related renal decline (use Cockcroft-Gault CrCl), polypharmacy, avoid fluoroquinolones (FDA warning)',
      'Pregnancy: safe antibiotics (penicillins, cephalosporins, azithromycin); avoid fluoroquinolones, tetracyclines, aminoglycosides',
      'Neutropenic fever: empiric antipseudomonal beta-lactam (cefepime, piperacillin-tazobactam); add antifungal if fever >4-7 days',
      'Critically ill: altered PK (↑Vd, ARC, AKI); higher loading doses, extended/continuous infusions, TDM essential',
      'Amoxicillin pediatric dosing: 90mg/kg/day divided TID for pneumonia',
      'Ceftriaxone: no renal adjustment (biliary excretion), safe in pregnancy',
      'Consult pharmacist or ID specialist for complex dosing in special populations',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Key takeaways
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Key Takeaways', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                    decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReferencesCard(BuildContext context) {
    final references = {
      'IDSA Guidelines for Neutropenic Fever (2011)': 'https://academic.oup.com/cid/article/52/4/e56/382256',
      'CDC Treatment Guidelines: Pregnancy': 'https://www.cdc.gov/std/treatment-guidelines/pregnancy.htm',
      'Sanford Guide to Antimicrobial Therapy (2024)': 'https://www.sanfordguide.com/',
      'Johns Hopkins ABX Guide: Special Populations': 'https://www.hopkinsguides.com/hopkins/index/Johns_Hopkins_ABX_Guide',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: References
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.info, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.link, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Official References', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...references.entries.toList().asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () async {
                  final uri = Uri.parse(entry.value.value);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                        child: Center(child: Text('${entry.key + 1}', style: const TextStyle(color: AppColors.info, fontSize: 13, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(entry.value.key, style: const TextStyle(color: AppColors.info, fontSize: 14, fontWeight: FontWeight.w500, decoration: TextDecoration.underline))),
                      const Icon(Icons.open_in_new, color: AppColors.info, size: 18),
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
