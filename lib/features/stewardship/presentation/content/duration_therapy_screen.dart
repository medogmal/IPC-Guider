import 'package:flutter/material.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/widgets/content_card_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page 5: Duration of Therapy
/// Pattern 2: Practical/Action-Oriented
/// Special UI: Duration recommendations by syndrome, procalcitonin-guided card, clinical scenarios
class DurationTherapyScreen extends StatelessWidget {
  const DurationTherapyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duration of Therapy'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
          // Header Card
          ContentHeaderCard(
            icon: Icons.schedule_outlined,
            iconColor: AppColors.success,  // Green: Duration best practice
            title: 'Duration of Therapy',
            subtitle: 'Evidence-Based Duration Recommendations',
            description: 'Short-course, standard-course, and extended therapy based on infection syndrome and clinical response',
          ),
          const SizedBox(height: 16),

          // Introduction Card
          const IntroductionCard(
            text: 'Evidence-based duration of therapy minimizes unnecessary antibiotic exposure, reduces adverse events (C. difficile, resistance), and improves patient outcomes. Duration should be tailored to infection syndrome, source control, and clinical response.',
            isHighlighted: true,
          ),
          const SizedBox(height: 16),

          // Short-Course Therapy Card
          _buildShortCourseCard(),
          const SizedBox(height: 16),

          // Standard-Course Therapy Card
          _buildStandardCourseCard(),
          const SizedBox(height: 16),

          // Extended Therapy Card
          _buildExtendedTherapyCard(),
          const SizedBox(height: 16),

          // Procalcitonin-Guided Duration Card
          _buildProCalcitoninCard(),
          const SizedBox(height: 16),

          // Avoiding Prolonged Courses Card
          _buildAvoidProlongedCard(),
          const SizedBox(height: 16),

          // Clinical Example 1: CAP
          _buildClinicalExample1(),
          const SizedBox(height: 16),

          // Clinical Example 2: Pyelonephritis
          _buildClinicalExample2(),
          const SizedBox(height: 16),

          // Clinical Example 3: Intra-abdominal
          _buildClinicalExample3(),
          const SizedBox(height: 16),

          // Clinical Example 4: Osteomyelitis
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

  Widget _buildShortCourseCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Short-course therapy
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
                child: const Icon(Icons.timer_outlined, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Short-Course Therapy (3-5 Days)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDurationItem('Uncomplicated Cystitis', '3 days (TMP-SMX, fluoroquinolones)', AppColors.info),
          _buildDurationItem('Community-Acquired Pneumonia', '5 days (if afebrile for 48-72 hours)', AppColors.info),
          _buildDurationItem('Acute Bacterial Sinusitis', '5-7 days', AppColors.info),
          _buildDurationItem('Uncomplicated Cellulitis', '5 days (if improving)', AppColors.info),
          _buildDurationItem('Intra-abdominal Infection (Source Controlled)', '4 days post-op', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildStandardCourseCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Standard-course therapy
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
                child: const Icon(Icons.access_time, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Standard-Course Therapy (7-14 Days)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDurationItem('Pyelonephritis (Uncomplicated)', '7-10 days', AppColors.info),
          _buildDurationItem('Hospital-Acquired Pneumonia', '7 days (if improving)', AppColors.info),
          _buildDurationItem('Complicated Skin/Soft Tissue Infections', '7-14 days', AppColors.info),
          _buildDurationItem('Bacteremia (Uncomplicated)', '7-14 days (depends on source)', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildExtendedTherapyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Extended therapy caution
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
                child: const Icon(Icons.hourglass_full, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Extended Therapy (4-6 Weeks or Longer)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDurationItem('Osteomyelitis', '4-6 weeks (2 weeks IV + 4 weeks PO)', AppColors.warning),
          _buildDurationItem('Endocarditis', '4-6 weeks IV (depends on organism and valve)', AppColors.warning),
          _buildDurationItem('Prosthetic Joint Infection', '4-6 weeks IV + 3-6 months PO', AppColors.warning),
          _buildDurationItem('Brain Abscess', '4-8 weeks (depends on size and response)', AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildDurationItem(String infection, String duration, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                children: [
                  TextSpan(text: '$infection: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: duration),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProCalcitoninCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Biomarker-guided therapy
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
                child: const Icon(Icons.biotech, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Procalcitonin-Guided Duration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Procalcitonin (PCT) is a biomarker of bacterial infection that can guide antibiotic discontinuation. Meta-analyses show that PCT-guided therapy reduces antibiotic exposure by 2-3 days without increasing mortality.',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 14),
          const Text(
            'Discontinuation Criteria:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.info),
          ),
          const SizedBox(height: 8),
          const Text('• PCT decreased by ≥80% from peak', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• PCT <0.5 ng/mL (or <0.25 ng/mL for some protocols)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Clinical improvement (afebrile, stable vitals)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildAvoidProlongedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),  // Red: Risks critical
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
                child: const Icon(Icons.warning_amber, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Avoiding Unnecessarily Prolonged Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('• Daily reassessment of need for continued antibiotics', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Defined stop dates at initiation', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Automatic stop orders (e.g., 48-hour timeout)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const Text('• Stewardship review of prolonged courses (>7 days)', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildClinicalExample1() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Clinical example 1
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
              const Expanded(child: Text('Case 1: Community-Acquired Pneumonia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 50-year-old man with CAP is treated with ceftriaxone 1g IV daily + azithromycin 500mg IV daily. After 3 days, he is afebrile for 48 hours, clinically stable, and tolerating oral intake.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('CONVERSION', 'Ceftriaxone IV → amoxicillin 1g PO TID', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('DURATION', 'Total 5 days (evidence-based for CAP)', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('RATIONALE', 'Short-course therapy reduces C. difficile risk and resistance without compromising outcomes', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildClinicalExample2() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),  // Green: Clinical example 2
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 2: Uncomplicated Pyelonephritis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 30-year-old woman with pyelonephritis is treated with ceftriaxone 1g IV daily. After 3 days, she is afebrile and clinically stable.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('CONVERSION', 'Ceftriaxone IV → ciprofloxacin 500mg PO BID', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('DURATION', 'Total 7 days (evidence-based for uncomplicated pyelonephritis)', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildClinicalExample3() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),  // Amber: Clinical example 3
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
              const Expanded(child: Text('Case 3: Intra-abdominal Infection (Source Controlled)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 45-year-old woman with perforated appendicitis undergoes appendectomy. She is treated with piperacillin-tazobactam 4.5g IV q6h.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('DURATION', '4 days post-op (evidence-based for source-controlled intra-abdominal infections)', AppColors.warning),
          const SizedBox(height: 8),
          _buildExampleSection('RATIONALE', 'STOP-IT trial showed 4 days non-inferior to longer courses when source controlled', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildClinicalExample4() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),  // Blue: Clinical example 4
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
                child: const Center(child: Text('4', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 14),
              const Expanded(child: Text('Case 4: Osteomyelitis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('A 60-year-old man with vertebral osteomyelitis (MSSA) is treated with cefazolin 2g IV q8h.', style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          const SizedBox(height: 12),
          _buildExampleSection('INITIAL THERAPY', 'Cefazolin 2g IV q8h for 2 weeks', AppColors.info),
          const SizedBox(height: 8),
          _buildExampleSection('CONVERSION', 'After 2 weeks IV → cephalexin 500mg PO QID for 4 weeks', AppColors.success),
          const SizedBox(height: 8),
          _buildExampleSection('TOTAL DURATION', '6 weeks (2 weeks IV + 4 weeks PO)', AppColors.info),
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
      'Short-course therapy (3-5 days): cystitis (3d), CAP (5d), sinusitis (5-7d), cellulitis (5d), intra-abdominal with source control (4d)',
      'Standard-course therapy (7-14 days): pyelonephritis (7-10d), HAP (7d), complicated SSTI (7-14d), bacteremia (7-14d)',
      'Extended therapy (4-6 weeks): osteomyelitis (4-6w), endocarditis (4-6w), prosthetic joint (4-6w IV + 3-6mo PO)',
      'Procalcitonin-guided duration: discontinue when PCT ↓80% from peak or <0.5 ng/mL (reduces exposure by 2-3 days)',
      'Avoid unnecessarily prolonged courses: daily reassessment, defined stop dates, automatic stop orders',
      'CAP: 5 days if afebrile for 48-72 hours (evidence-based)',
      'Intra-abdominal with source control: 4 days post-op (STOP-IT trial)',
      'Osteomyelitis: 2 weeks IV + 4 weeks PO (total 6 weeks)',
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
      'IDSA Guidelines (Syndrome-Specific)': 'https://www.idsociety.org/practice-guideline/',
      'Procalcitonin-Guided Antibiotic Therapy Meta-Analysis (2018)': 'https://pubmed.ncbi.nlm.nih.gov/29485636/',
      'STOP-IT Trial: Intra-abdominal Infections (2015)': 'https://pubmed.ncbi.nlm.nih.gov/25599185/',
      'CDC Treatment Guidelines: Duration of Therapy': 'https://www.cdc.gov/antibiotic-use/healthcare/index.html',
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

