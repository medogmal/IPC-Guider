import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/back_button.dart';
import '../../../core/design/design_tokens.dart';
import '../data/calculator_providers.dart';
import '../domain/models.dart';

// Calculator index for search functionality
class CalculatorItem {
  final String name;
  final String description;
  final String route;
  final String category;

  const CalculatorItem({
    required this.name,
    required this.description,
    required this.route,
    required this.category,
  });
}

// Complete calculator index (30 calculators)
const List<CalculatorItem> _calculatorIndex = [
  // HAI Surveillance (5)
  CalculatorItem(
    name: 'CLABSI Rate',
    description: 'Central Line-Associated Bloodstream Infections',
    route: '/calculator/clabsi',
    category: 'HAI Surveillance',
  ),
  CalculatorItem(
    name: 'CAUTI Rate',
    description: 'Catheter-Associated Urinary Tract Infections',
    route: '/calculator/cauti',
    category: 'HAI Surveillance',
  ),
  CalculatorItem(
    name: 'VAE Rate',
    description: 'Ventilator-Associated Events (VAC, IVAC, VAP)',
    route: '/calculator/vae',
    category: 'HAI Surveillance',
  ),
  CalculatorItem(
    name: 'SSI Rate',
    description: 'Surgical Site Infections by classification',
    route: '/calculator/ssi',
    category: 'HAI Surveillance',
  ),
  CalculatorItem(
    name: 'Device Utilization Ratio',
    description: 'Device exposure monitoring (CL, UC, Ventilator)',
    route: '/calculator/dur',
    category: 'HAI Surveillance',
  ),

  // MDRO Surveillance (5)
  CalculatorItem(
    name: 'MDRO Incidence Rate',
    description: 'MRSA, VRE, ESBL, CRE per 1,000 patient days',
    route: '/calculator/mdro-incidence',
    category: 'MDRO Surveillance',
  ),
  CalculatorItem(
    name: 'Colonization Pressure',
    description: 'Percentage of colonized/infected patients',
    route: '/calculator/colonization-pressure',
    category: 'MDRO Surveillance',
  ),
  CalculatorItem(
    name: 'Screening Yield',
    description: 'Positive screening samples percentage',
    route: '/calculator/screening-yield',
    category: 'MDRO Surveillance',
  ),
  CalculatorItem(
    name: 'Infection Reduction %',
    description: 'Measure intervention effectiveness',
    route: '/calculator/infection-reduction',
    category: 'MDRO Surveillance',
  ),
  CalculatorItem(
    name: 'Isolation Compliance %',
    description: 'Adherence to isolation protocols',
    route: '/calculator/isolation-compliance',
    category: 'MDRO Surveillance',
  ),

  // Antimicrobial Stewardship (5)
  CalculatorItem(
    name: 'DOT (Days of Therapy)',
    description: 'Antibiotic exposure duration metric',
    route: '/calculator/dot',
    category: 'Antimicrobial Stewardship',
  ),
  CalculatorItem(
    name: 'DDD (Defined Daily Dose)',
    description: 'WHO-standardized consumption metric',
    route: '/calculator/ddd',
    category: 'Antimicrobial Stewardship',
  ),
  CalculatorItem(
    name: 'Antibiotic Utilization %',
    description: 'Quick utilization index',
    route: '/calculator/antibiotic-utilization',
    category: 'Antimicrobial Stewardship',
  ),
  CalculatorItem(
    name: 'De-escalation Rate',
    description: 'Stewardship performance metric',
    route: '/calculator/deescalation-rate',
    category: 'Antimicrobial Stewardship',
  ),
  CalculatorItem(
    name: 'Culture-Guided Therapy %',
    description: 'Rational prescribing metric',
    route: '/calculator/culture-guided-therapy',
    category: 'Antimicrobial Stewardship',
  ),

  // Compliance, Audit & Bundle Performance (4)
  CalculatorItem(
    name: 'Bundle Compliance %',
    description: 'Full & partial compliance tracker',
    route: '/calculator/bundle-compliance',
    category: 'Compliance, Audit & Bundle Performance',
  ),
  CalculatorItem(
    name: 'IPC Audit Score %',
    description: 'Overall IPC program performance',
    route: '/calculator/ipc-audit-score',
    category: 'Compliance, Audit & Bundle Performance',
  ),
  CalculatorItem(
    name: 'Observation Compliance %',
    description: 'Real-time behavior adherence',
    route: '/calculator/observation-compliance',
    category: 'Compliance, Audit & Bundle Performance',
  ),
  CalculatorItem(
    name: 'Compliance Trend Tracker',
    description: 'Visualize compliance over time',
    route: '/calculator/compliance-trend',
    category: 'Compliance, Audit & Bundle Performance',
  ),

  // Laboratory Quality Indicators (4)
  CalculatorItem(
    name: 'Blood Culture Contamination %',
    description: 'Critical lab quality metric',
    route: '/calculator/blood-culture-contamination',
    category: 'Laboratory Quality Indicators',
  ),
  CalculatorItem(
    name: 'Appropriate Specimen %',
    description: 'Specimen quality metric',
    route: '/calculator/appropriate-specimen',
    category: 'Laboratory Quality Indicators',
  ),
  CalculatorItem(
    name: 'TAT Compliance %',
    description: 'Turnaround time performance',
    route: '/calculator/tat-compliance',
    category: 'Laboratory Quality Indicators',
  ),
  CalculatorItem(
    name: 'Rejection Rate %',
    description: 'Pre-analytical quality metric',
    route: '/calculator/rejection-rate',
    category: 'Laboratory Quality Indicators',
  ),

  // Occupational Health & Staff Safety (4)
  CalculatorItem(
    name: 'Vaccination Coverage %',
    description: 'HCW immunization compliance',
    route: '/calculator/vaccination-coverage',
    category: 'Occupational Health & Staff Safety',
  ),
  CalculatorItem(
    name: 'NSI Rate',
    description: 'Needlestick injury tracking per 1,000 HCWs',
    route: '/calculator/nsi-rate',
    category: 'Occupational Health & Staff Safety',
  ),
  CalculatorItem(
    name: 'PEP %',
    description: 'Post-exposure prophylaxis compliance',
    route: '/calculator/pep-percentage',
    category: 'Occupational Health & Staff Safety',
  ),
  CalculatorItem(
    name: 'Sick Leave Rate',
    description: 'Infection-related absenteeism tracking',
    route: '/calculator/sick-leave-rate',
    category: 'Occupational Health & Staff Safety',
  ),

  // Environmental & Equipment Surveillance (3)
  CalculatorItem(
    name: 'Environmental Positivity Rate',
    description: 'Microbial contamination in air, surface, water samples',
    route: '/calculator/environmental-positivity-rate',
    category: 'Environmental & Equipment Surveillance',
  ),
  CalculatorItem(
    name: 'Disinfection Compliance %',
    description: 'Environmental cleaning and disinfection audit compliance',
    route: '/calculator/disinfection-compliance',
    category: 'Environmental & Equipment Surveillance',
  ),
  CalculatorItem(
    name: 'Sterilization Failure Rate',
    description: 'CSSD sterilization effectiveness monitoring',
    route: '/calculator/sterilization-failure-rate',
    category: 'Environmental & Equipment Surveillance',
  ),

  // Outbreak & Epidemiologic Investigation (6)
  CalculatorItem(
    name: 'Attack Rate',
    description: 'Primary attack rate with 95% confidence intervals',
    route: '/calculator/attack-rate',
    category: 'Outbreak & Epidemiologic Investigation',
  ),
  CalculatorItem(
    name: 'Secondary Attack Rate',
    description: 'Transmission analysis among exposed contacts',
    route: '/calculator/secondary-attack-rate',
    category: 'Outbreak & Epidemiologic Investigation',
  ),
  CalculatorItem(
    name: 'Relative Risk (RR)',
    description: 'Risk comparison between exposed and unexposed',
    route: '/calculator/relative-risk',
    category: 'Outbreak & Epidemiologic Investigation',
  ),
  CalculatorItem(
    name: 'Odds Ratio (OR)',
    description: 'Case-control analysis from 2×2 tables',
    route: '/calculator/odds-ratio',
    category: 'Outbreak & Epidemiologic Investigation',
  ),
  CalculatorItem(
    name: 'Case Fatality Rate',
    description: 'Outbreak severity and mortality analysis',
    route: '/calculator/case-fatality-rate',
    category: 'Outbreak & Epidemiologic Investigation',
  ),
  CalculatorItem(
    name: 'Epidemic Curve',
    description: 'Visualize outbreak pattern over time',
    route: '/calculator/epidemic-curve',
    category: 'Outbreak & Epidemiologic Investigation',
  ),
];

class CalculatorHomeScreen extends ConsumerStatefulWidget {
  const CalculatorHomeScreen({super.key});

  @override
  ConsumerState<CalculatorHomeScreen> createState() => _CalculatorHomeScreenState();
}

class _CalculatorHomeScreenState extends ConsumerState<CalculatorHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _expandedDomains = {};
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CalculatorItem> _performSearch(String query) {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return _calculatorIndex.where((calc) {
      return calc.name.toLowerCase().contains(lowerQuery) ||
             calc.description.toLowerCase().contains(lowerQuery) ||
             calc.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final calculatorDataAsync = ref.watch(calculatorDataProvider);

    return Scaffold(
      appBar: AppBackAppBar(
        title: 'IPC Calculators',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search calculators...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Quiz Button (matching isolation style)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 32,
                      child: FilledButton.icon(
                        onPressed: () => context.go('/quiz/calculators'),
                        icon: const Icon(Icons.play_arrow, size: 14),
                        label: const Text('Quiz', style: TextStyle(fontSize: 11)),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Content
          Expanded(
            child: calculatorDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error),
              data: (data) => _searchQuery.isEmpty
                  ? _buildMainContent(data)
                  : _buildSearchResults(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load calculator data',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(calculatorDataProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(CalculatorData data) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // HAI Surveillance Section
        _buildHAISurveillanceSection(),
        const SizedBox(height: 12),

        // MDRO Surveillance Section
        _buildMDROSurveillanceSection(),
        const SizedBox(height: 12),

        // Antimicrobial Stewardship Section
        _buildAntimicrobialStewardshipSection(),
        const SizedBox(height: 12),

        // Compliance, Audit & Bundle Performance Section
        _buildComplianceAuditSection(),
        const SizedBox(height: 12),

        // Laboratory Quality Indicators Section
        _buildLabQualitySection(),
        const SizedBox(height: 12),

        // Occupational Health & Staff Safety Section
        _buildOccupationalHealthSection(),
        const SizedBox(height: 12),

        // Environmental & Equipment Surveillance Section
        _buildEnvironmentalEquipmentGroup(),
        const SizedBox(height: 12),

        // Outbreak & Epidemiologic Investigation Section
        _buildOutbreakEpidemiologySection(),
        const SizedBox(height: 24),

        // Other Calculator Domains
        ...data.domains.map((domain) => _buildDomainCard(domain)),
      ],
    );
  }

  Widget _buildHAISurveillanceSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(Icons.monitor_heart_outlined, color: AppColors.interactive),
        title: Text(
          'HAI Surveillance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text('5 calculators'),
        children: [
          _buildHAICalculatorTile(
            'CLABSI Rate',
            'Central Line-Associated Bloodstream Infections',
            Icons.bloodtype_outlined,
            '/calculator/clabsi',
          ),
          _buildHAICalculatorTile(
            'CAUTI Rate',
            'Catheter-Associated Urinary Tract Infections',
            Icons.water_drop_outlined,
            '/calculator/cauti',
          ),
          _buildHAICalculatorTile(
            'VAE Rate',
            'Ventilator-Associated Events (VAC, IVAC, VAP)',
            Icons.air_outlined,
            '/calculator/vae',
          ),
          _buildHAICalculatorTile(
            'SSI Rate',
            'Surgical Site Infections by classification',
            Icons.healing_outlined,
            '/calculator/ssi',
          ),
          _buildHAICalculatorTile(
            'Device Utilization Ratio',
            'Device exposure monitoring (CL, UC, Ventilator)',
            Icons.device_hub_outlined,
            '/calculator/dur',
          ),
        ],
      ),
    );
  }

  Widget _buildHAICalculatorTile(String title, String subtitle, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.go(route),
    );
  }

  Widget _buildMDROSurveillanceSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(Icons.coronavirus_outlined, color: AppColors.primary),
        title: Text(
          'MDRO Surveillance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text('5 calculators'),
        children: [
          _buildMDROCalculatorTile(
            'MDRO Incidence Rate',
            'MRSA, VRE, ESBL, CRE per 1,000 patient days',
            Icons.trending_up,
            '/calculator/mdro-incidence',
          ),
          _buildMDROCalculatorTile(
            'Colonization Pressure',
            'Percentage of colonized/infected patients',
            Icons.people_outline,
            '/calculator/colonization-pressure',
          ),
          _buildMDROCalculatorTile(
            'Screening Yield',
            'Positive screening samples percentage',
            Icons.search,
            '/calculator/screening-yield',
          ),
          _buildMDROCalculatorTile(
            'Infection Reduction %',
            'Measure intervention effectiveness',
            Icons.trending_down,
            '/calculator/infection-reduction',
          ),
          _buildMDROCalculatorTile(
            'Isolation Compliance %',
            'Adherence to isolation protocols',
            Icons.verified_user,
            '/calculator/isolation-compliance',
          ),
        ],
      ),
    );
  }

  Widget _buildAntimicrobialStewardshipSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(Icons.medication_liquid, color: AppColors.primary),
        title: Text(
          'Antimicrobial Stewardship',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text('5 calculators'),
        children: [
          _buildStewardshipCalculatorTile(
            'DOT (Days of Therapy)',
            'Antibiotic exposure duration metric',
            Icons.medication,
            '/calculator/dot',
          ),
          _buildStewardshipCalculatorTile(
            'DDD (Defined Daily Dose)',
            'WHO-standardized consumption metric',
            Icons.science,
            '/calculator/ddd',
          ),
          _buildStewardshipCalculatorTile(
            'Antibiotic Utilization %',
            'Quick utilization index',
            Icons.percent,
            '/calculator/antibiotic-utilization',
          ),
          _buildStewardshipCalculatorTile(
            'De-escalation Rate',
            'Stewardship performance metric',
            Icons.arrow_downward_outlined,
            '/calculator/deescalation-rate',
          ),
          _buildStewardshipCalculatorTile(
            'Culture-Guided Therapy %',
            'Rational prescribing metric',
            Icons.biotech,
            '/calculator/culture-guided-therapy',
          ),
        ],
      ),
    );
  }

  Widget _buildStewardshipCalculatorTile(String title, String subtitle, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.go(route),
    );
  }

  Widget _buildMDROCalculatorTile(String title, String subtitle, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.go(route),
    );
  }

  Widget _buildDomainCard(CalculatorDomain domain) {
    final isExpanded = _expandedDomains[domain.key] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(
              domain.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${domain.formulas.length} formulas'),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () {
              setState(() {
                _expandedDomains[domain.key] = !isExpanded;
              });
            },
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            ...domain.formulas.map((formula) => ListTile(
              title: Text(formula.name),
              subtitle: Text(
                formula.purpose,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Note: This is for future JSON-based formulas
                // Currently the JSON file is empty
              },
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _performSearch(_searchQuery);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final calc = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calculate_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            title: Text(
              calc.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  calc.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  calc.category,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
            onTap: () => context.go(calc.route),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplianceAuditSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(Icons.checklist_rtl, color: AppColors.primary),
        title: Text(
          'Compliance, Audit & Bundle Performance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text('4 calculators'),
        children: [
          _buildComplianceCalculatorTile(
            'Bundle Compliance %',
            'Full & partial compliance tracker',
            Icons.checklist_rtl,
            '/calculator/bundle-compliance',
          ),
          _buildComplianceCalculatorTile(
            'IPC Audit Score %',
            'Overall IPC program performance',
            Icons.assessment,
            '/calculator/ipc-audit-score',
          ),
          _buildComplianceCalculatorTile(
            'Observation Compliance %',
            'Real-time behavior adherence',
            Icons.visibility,
            '/calculator/observation-compliance',
          ),
          _buildComplianceCalculatorTile(
            'Compliance Trend Tracker',
            'Visualize compliance over time',
            Icons.trending_up,
            '/calculator/compliance-trend',
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCalculatorTile(
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.go(route),
    );
  }

  Widget _buildLabQualitySection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(Icons.biotech, color: AppColors.primary),
        title: Text(
          'Laboratory Quality Indicators',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text('4 calculators'),
        children: [
          _buildComplianceCalculatorTile(
            'Blood Culture Contamination %',
            'Critical lab quality metric',
            Icons.biotech,
            '/calculator/blood-culture-contamination',
          ),
          _buildComplianceCalculatorTile(
            'Appropriate Specimen %',
            'Specimen quality metric',
            Icons.check_circle_outline,
            '/calculator/appropriate-specimen',
          ),
          _buildComplianceCalculatorTile(
            'TAT Compliance %',
            'Turnaround time performance',
            Icons.timer,
            '/calculator/tat-compliance',
          ),
          _buildComplianceCalculatorTile(
            'Rejection Rate %',
            'Pre-analytical quality metric',
            Icons.cancel,
            '/calculator/rejection-rate',
          ),
        ],
      ),
    );
  }

  Widget _buildOccupationalHealthSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(Icons.health_and_safety, color: AppColors.primary),
        title: Text(
          'Occupational Health & Staff Safety',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text('4 calculators'),
        children: [
          _buildComplianceCalculatorTile(
            'Vaccination Coverage %',
            'HCW immunization compliance',
            Icons.vaccines,
            '/calculator/vaccination-coverage',
          ),
          _buildComplianceCalculatorTile(
            'NSI Rate',
            'Needlestick injury tracking per 1,000 HCWs',
            Icons.medical_services,
            '/calculator/nsi-rate',
          ),
          _buildComplianceCalculatorTile(
            'PEP %',
            'Post-exposure prophylaxis compliance',
            Icons.emergency,
            '/calculator/pep-percentage',
          ),
          _buildComplianceCalculatorTile(
            'Sick Leave Rate',
            'Infection-related absenteeism tracking',
            Icons.sick,
            '/calculator/sick-leave-rate',
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalEquipmentGroup() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(Icons.science_outlined, color: AppColors.primary),
        title: Text(
          'Environmental & Equipment Surveillance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text('3 calculators'),
        children: [
          _buildComplianceCalculatorTile(
            'Environmental Positivity Rate',
            'Microbial contamination in air, surface, water samples',
            Icons.science_outlined,
            '/calculator/environmental-positivity-rate',
          ),
          _buildComplianceCalculatorTile(
            'Disinfection Compliance %',
            'Environmental cleaning and disinfection audit compliance',
            Icons.cleaning_services,
            '/calculator/disinfection-compliance',
          ),
          _buildComplianceCalculatorTile(
            'Sterilization Failure Rate',
            'CSSD sterilization effectiveness monitoring',
            Icons.medical_services_outlined,
            '/calculator/sterilization-failure-rate',
          ),
        ],
      ),
    );
  }

  Widget _buildOutbreakEpidemiologySection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(Icons.analytics_outlined, color: AppColors.primary),
        title: Text(
          'Outbreak & Epidemiologic Investigation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text('6 calculators'),
        children: [
          _buildOutbreakCalculatorTile(
            'Attack Rate',
            'Primary attack rate with 95% confidence intervals',
            Icons.trending_up_outlined,
            '/calculator/attack-rate',
          ),
          _buildOutbreakCalculatorTile(
            'Secondary Attack Rate',
            'Transmission analysis among exposed contacts',
            Icons.people_outline,
            '/calculator/secondary-attack-rate',
          ),
          _buildOutbreakCalculatorTile(
            'Relative Risk (RR)',
            'Risk comparison between exposed and unexposed',
            Icons.compare_arrows_outlined,
            '/calculator/relative-risk',
          ),
          _buildOutbreakCalculatorTile(
            'Odds Ratio (OR)',
            'Case-control analysis from 2×2 tables',
            Icons.balance_outlined,
            '/calculator/odds-ratio',
          ),
          _buildOutbreakCalculatorTile(
            'Case Fatality Rate',
            'Outbreak severity and mortality analysis',
            Icons.emergency_outlined,
            '/calculator/case-fatality-rate',
          ),
          _buildOutbreakCalculatorTile(
            'Epidemic Curve',
            'Visualize outbreak pattern over time',
            Icons.show_chart_outlined,
            '/calculator/epidemic-curve',
          ),
        ],
      ),
    );
  }

  Widget _buildOutbreakCalculatorTile(
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.warning, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
      onTap: () => context.push(route),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
