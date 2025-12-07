import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';

class EnvironmentalMeasuresScreen extends StatefulWidget {
  const EnvironmentalMeasuresScreen({super.key});

  @override
  State<EnvironmentalMeasuresScreen> createState() => _EnvironmentalMeasuresScreenState();
}

class _EnvironmentalMeasuresScreenState extends State<EnvironmentalMeasuresScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Environmental Measures'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Air'),
            Tab(text: 'Water'),
            Tab(text: 'Surfaces'),
            Tab(text: 'Equipment'),
            Tab(text: 'Waste'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAirTab(bottomPadding),
          _buildWaterTab(bottomPadding),
          _buildSurfacesTab(bottomPadding),
          _buildEquipmentTab(bottomPadding),
          _buildWasteTab(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildAirTab(double bottomPadding) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
        _buildHeaderCard(
          title: 'Air Quality & Ventilation',
          icon: Icons.air,
          color: AppColors.info,
          description: 'Proper ventilation and air quality management are critical for preventing airborne transmission of pathogens.',
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Ventilation Requirements',
          color: AppColors.info,
          items: [
            'Maintain minimum 6 air changes per hour (ACH) in patient rooms',
            'Ensure 12+ ACH in airborne infection isolation rooms (AIIR)',
            'Verify negative pressure in AIIR (-2.5 Pa minimum)',
            'Direct airflow from clean to less clean areas',
            'Ensure air exhausts directly outside or through HEPA filter',
            'Monitor and document pressure differentials daily',
            'Avoid recirculation of air from isolation rooms',
          ],
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'HEPA Filtration',
          color: AppColors.info,
          items: [
            'Use HEPA filters (99.97% efficiency for 0.3 micron particles)',
            'Place portable HEPA units in outbreak areas if needed',
            'Change filters per manufacturer recommendations',
            'Position units to maximize air circulation',
            'Calculate room ACH with portable units',
            'Do not use as substitute for proper ventilation',
          ],
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'UV Germicidal Irradiation (UVGI)',
          color: AppColors.info,
          items: [
            'Consider upper-room UVGI for TB/measles outbreaks',
            'Ensure proper installation and maintenance',
            'Protect occupants from direct UV exposure',
            'Use in conjunction with ventilation, not as replacement',
            'Monitor UV lamp output regularly',
          ],
        ),
        const SizedBox(height: 16),
        _buildExampleBox(
          'Common Applications',
          [
            'TB outbreak: AIIR with 12 ACH + negative pressure',
            'Measles outbreak: AIIR + portable HEPA units',
            'COVID-19: Enhanced ventilation + open windows when possible',
            'Aspergillus: HEPA filtration for immunocompromised patients',
          ],
          AppColors.info,
        ),
        ],
      ),
    );
  }

  Widget _buildWaterTab(double bottomPadding) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
        _buildHeaderCard(
          title: 'Water Safety Management',
          icon: Icons.water_drop,
          color: AppColors.primary,
          description: 'Water systems can harbor and transmit waterborne pathogens. Proper management prevents outbreaks.',
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Legionella Prevention',
          color: AppColors.primary,
          items: [
            'Maintain hot water temperature ≥60°C (140°F) at heater',
            'Maintain cold water temperature <20°C (68°F)',
            'Flush low-use outlets weekly (run for 5 minutes)',
            'Remove or flush dead-end pipes',
            'Clean and disinfect cooling towers quarterly',
            'Test water for Legionella per risk assessment',
            'Implement water management program per ASHRAE 188',
          ],
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Point-of-Use Filters',
          color: AppColors.primary,
          items: [
            'Install 0.2 micron filters for high-risk patients',
            'Use for immunocompromised, transplant, burn patients',
            'Change filters per manufacturer recommendations',
            'Validate filter integrity after installation',
            'Document filter changes and validation',
            'Consider for outbreak control in affected areas',
          ],
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Water Testing',
          color: AppColors.primary,
          items: [
            'Test for Legionella at high-risk locations',
            'Test for Pseudomonas in immunocompromised units',
            'Monitor chlorine/chloramine residuals',
            'Test water temperature at outlets',
            'Investigate if cases of waterborne illness occur',
            'Maintain testing records and trend analysis',
          ],
        ),
        const SizedBox(height: 16),
        _buildExampleBox(
          'Common Applications',
          [
            'Legionella outbreak: Superheat/flush + hyperchlorination',
            'Pseudomonas outbreak: Point-of-use filters + pipe replacement',
            'Construction: Protective barriers + enhanced monitoring',
            'Immunocompromised units: Continuous point-of-use filtration',
          ],
          AppColors.primary,
        ),
        ],
      ),
    );
  }

  Widget _buildSurfacesTab(double bottomPadding) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
        _buildHeaderCard(
          title: 'Surface Cleaning & Disinfection',
          icon: Icons.cleaning_services,
          color: AppColors.success,
          description: 'Environmental surfaces can serve as reservoirs for pathogens. Proper cleaning and disinfection breaks transmission chains.',
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'High-Touch Surfaces',
          color: AppColors.success,
          items: [
            'Clean and disinfect at least twice daily during outbreaks',
            'Include: bed rails, call buttons, door handles, light switches',
            'Include: IV poles, monitors, keyboards, phones, tables',
            'Use EPA-registered disinfectant effective against pathogen',
            'Follow manufacturer contact time (typically 1-10 minutes)',
            'Clean before disinfecting (remove organic matter)',
            'Use separate cloths for each room/patient',
          ],
        ),
        const SizedBox(height: 16),
        _buildDisinfectantTable(),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Terminal Cleaning',
          color: AppColors.success,
          items: [
            'Perform after patient discharge or transfer',
            'Clean all surfaces including walls, floors, ceilings',
            'Disinfect all equipment and furniture',
            'Remove and launder curtains if applicable',
            'Consider enhanced methods (UV-C, hydrogen peroxide vapor)',
            'Verify cleaning with ATP or fluorescent markers',
            'Document completion before room reoccupancy',
          ],
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Cleaning Verification',
          color: AppColors.success,
          items: [
            'ATP bioluminescence: <500 RLU for high-touch surfaces',
            'Fluorescent markers: Check removal of invisible gel',
            'Visual inspection: No visible soil or residue',
            'Microbiological cultures: For outbreak investigation',
            'Provide immediate feedback to environmental services',
            'Audit cleaning compliance daily during outbreaks',
          ],
        ),
        ],
      ),
    );
  }

  Widget _buildEquipmentTab(double bottomPadding) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
        _buildHeaderCard(
          title: 'Equipment Management',
          icon: Icons.medical_services,
          color: AppColors.warning,
          description: 'Shared medical equipment can transmit pathogens between patients. Proper reprocessing is essential.',
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Dedicated Equipment',
          color: AppColors.warning,
          items: [
            'Dedicate equipment to isolation rooms when possible',
            'Include: stethoscopes, BP cuffs, thermometers, glucometers',
            'Label equipment clearly as "dedicated"',
            'Clean and disinfect before removing from room',
            'Minimize sharing of equipment during outbreaks',
          ],
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Reprocessing Levels',
          color: AppColors.warning,
          items: [
            'Critical items (enter sterile tissue): Sterilization required',
            'Semi-critical items (contact mucous membranes): High-level disinfection',
            'Non-critical items (intact skin): Low-level disinfection',
            'Follow manufacturer instructions for reprocessing',
            'Ensure staff trained on proper reprocessing',
            'Audit reprocessing compliance regularly',
          ],
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Single-Use Items',
          color: AppColors.warning,
          items: [
            'Never reuse items labeled as single-use',
            'Dispose immediately after use',
            'Do not attempt to clean or sterilize',
            'Ensure adequate stock during outbreaks',
            'Examples: needles, syringes, catheters, some respiratory equipment',
          ],
        ),
        const SizedBox(height: 16),
        _buildExampleBox(
          'Common Applications',
          [
            'MRSA outbreak: Dedicated equipment + enhanced disinfection',
            'C. diff outbreak: Sporicidal disinfectant for equipment',
            'Norovirus outbreak: Bleach disinfection of shared items',
            'Endoscope-related outbreak: Review reprocessing procedures',
          ],
          AppColors.warning,
        ),
        ],
      ),
    );
  }

  Widget _buildWasteTab(double bottomPadding) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
        children: [
        _buildHeaderCard(
          title: 'Waste Management',
          icon: Icons.delete,
          color: AppColors.error,
          description: 'Proper waste segregation and disposal prevents environmental contamination and protects healthcare workers.',
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Waste Categories',
          color: AppColors.error,
          items: [
            'General waste: Non-infectious, non-hazardous (black bag)',
            'Infectious waste: Blood, body fluids, cultures (red/yellow bag)',
            'Sharps: Needles, scalpels, broken glass (puncture-proof container)',
            'Pathological waste: Tissues, organs, body parts (yellow bag)',
            'Chemical waste: Disinfectants, solvents (separate container)',
            'Pharmaceutical waste: Expired medications (separate container)',
          ],
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Outbreak Considerations',
          color: AppColors.error,
          items: [
            'Treat all waste from isolation rooms as infectious',
            'Use leak-proof bags and containers',
            'Fill containers to 3/4 capacity only',
            'Seal bags securely before removing from room',
            'Do not compress or manually handle waste',
            'Increase collection frequency during outbreaks',
            'Ensure adequate PPE for waste handlers',
            'Provide training on outbreak-specific procedures',
          ],
        ),
        const SizedBox(height: 16),
        _buildMeasureCard(
          title: 'Linen & Laundry',
          color: AppColors.error,
          items: [
            'Handle soiled linen with minimal agitation',
            'Place in leak-proof bag at point of use',
            'Do not sort or rinse in patient care areas',
            'Wash with detergent and hot water (≥71°C/160°F)',
            'Or use low-temperature wash with bleach',
            'Dry completely before storage',
            'Store clean linen in clean, dry area',
          ],
        ),
        const SizedBox(height: 16),
        _buildExampleBox(
          'Common Applications',
          [
            'C. diff outbreak: All waste as infectious + enhanced cleaning',
            'Norovirus outbreak: Immediate bag sealing + frequent collection',
            'Ebola/VHF: Double-bagging + autoclave before disposal',
            'TB outbreak: Standard waste procedures (not airborne in waste)',
          ],
          AppColors.error,
        ),
        const SizedBox(height: 16),
        _buildReferencesCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
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
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
    );
  }

  Widget _buildMeasureCard({
    required String title,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle_outline, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
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

  Widget _buildExampleBox(String title, List<String> examples, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outlined, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...examples.map((example) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '• $example',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDisinfectantTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
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
          Text(
            'Disinfectant Selection Guide',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          _buildDisinfectantRow(
            'MRSA/VRE',
            'Quaternary ammonium, Phenolic, Bleach (1:100)',
            '1-10 min',
          ),
          _buildDisinfectantRow(
            'C. difficile',
            'Bleach (1:10 dilution, 5000 ppm)',
            '5-10 min',
          ),
          _buildDisinfectantRow(
            'Norovirus',
            'Bleach (1000-5000 ppm)',
            '5-10 min',
          ),
          _buildDisinfectantRow(
            'Candida auris',
            'Sporicidal disinfectant, Bleach',
            '5-10 min',
          ),
          _buildDisinfectantRow(
            'COVID-19',
            'EPA List N disinfectants',
            '1-10 min',
          ),
          _buildDisinfectantRow(
            'TB/Mycobacteria',
            'Tuberculocidal disinfectant',
            '10 min',
          ),
        ],
      ),
    );
  }

  Widget _buildDisinfectantRow(String pathogen, String disinfectant, String contactTime) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pathogen,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  disinfectant,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  contactTime,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: AppColors.textSecondary.withValues(alpha: 0.2)),
        ],
      ),
    );
  }

  Widget _buildReferencesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
              Icon(Icons.library_books, color: AppColors.primary, size: 24),
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
          _buildReferenceItem(
            'CDC – Environmental Infection Control Guidelines',
            'https://www.cdc.gov/infectioncontrol/guidelines/environmental/',
          ),
          _buildReferenceItem(
            'WHO – Water Safety in Healthcare',
            'https://www.who.int/teams/environment-climate-change-and-health/water-sanitation-and-health/water-safety-and-quality',
          ),
          _buildReferenceItem(
            'APIC – Environmental Services Resources',
            'https://apic.org/professional-practice/practice-resources/',
          ),
          _buildReferenceItem(
            'GDIPC/Weqaya – Environmental Health Standards (Saudi Arabia)',
            'https://www.moh.gov.sa/en/Ministry/MediaCenter/Publications/Pages/Publications-2020-10-29-001.aspx',
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.open_in_new, size: 18, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

