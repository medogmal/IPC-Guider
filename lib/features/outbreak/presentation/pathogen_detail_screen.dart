import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design/design_tokens.dart';
import '../data/models/pathogen_detail.dart';

class PathogenDetailScreen extends StatelessWidget {
  final PathogenDetail pathogen;
  final String groupName;
  final Color color;

  const PathogenDetailScreen({
    super.key,
    required this.pathogen,
    required this.groupName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(pathogen.name),
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          children: [
          // Quick Reference Button
          _buildQuickReferenceButton(context),
          const SizedBox(height: 16),

          // Scientific Name Badge
          if (pathogen.scientificName.isNotEmpty) ...[
            _buildBadge(pathogen.scientificName, Icons.science),
            const SizedBox(height: 16),
          ],

          // Group Badge
          _buildBadge(groupName, Icons.category),
          const SizedBox(height: 24),

          // All Sections
          _buildSection('Definition', pathogen.definition, Icons.info_outline),
          _buildReservoirSection(),
          _buildTransmissionSection(),
          _buildIncubationSection(),
          _buildRiskFactorsSection(),
          _buildClinicalFeaturesSection(),
          _buildDiagnosisSection(),
          _buildSection('Treatment', pathogen.treatment, Icons.medication),
          _buildInfectionControlSection(),
          _buildOutbreakTriggersSection(),
          _buildReportingSection(),
          _buildPreventionSection(),
          _buildReferencesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReferenceButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _showQuickReferenceModal(context);
      },
      icon: const Icon(Icons.book_outlined),
      label: const Text('Quick Reference'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.textPrimary,
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

  Widget _buildReservoirSection() {
    if (pathogen.reservoir.primary.isEmpty && pathogen.reservoir.secondary.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.home_outlined, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Reservoir / Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pathogen.reservoir.primary.isNotEmpty) ...[
            Text(
              'Primary:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            ...pathogen.reservoir.primary.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(item, style: TextStyle(fontSize: 15, color: AppColors.textPrimary))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
          ],
          if (pathogen.reservoir.secondary.isNotEmpty) ...[
            Text(
              'Secondary:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            ...pathogen.reservoir.secondary.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(item, style: TextStyle(fontSize: 15, color: AppColors.textPrimary))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
          ],
          if (pathogen.reservoir.notes.isNotEmpty)
            Text(
              pathogen.reservoir.notes,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  Widget _buildTransmissionSection() {
    if (pathogen.transmission.mode.isEmpty && pathogen.transmission.routes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.swap_horiz, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Mode of Transmission',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pathogen.transmission.mode.isNotEmpty) ...[
            Text(
              'Mode: ${pathogen.transmission.mode}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
          ],
          if (pathogen.transmission.routes.isNotEmpty) ...[
            Text(
              'Routes:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            ...pathogen.transmission.routes.map((route) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(route, style: TextStyle(fontSize: 15, color: AppColors.textPrimary))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
          ],
          if (pathogen.transmission.notes.isNotEmpty)
            Text(
              pathogen.transmission.notes,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  Widget _buildIncubationSection() {
    if (pathogen.incubationPeriod.range.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.schedule, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Incubation & Infectious Period',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Incubation Period', pathogen.incubationPeriod.range),
          _buildInfoRow('Infectious Period', pathogen.incubationPeriod.infectiousPeriod),
          _buildInfoRow('Seasonality', pathogen.incubationPeriod.seasonality),
          _buildInfoRow('Geographic', pathogen.incubationPeriod.geographic),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskFactorsSection() {
    return _buildListSection('Risk Factors', pathogen.riskFactors, Icons.warning_amber);
  }

  Widget _buildClinicalFeaturesSection() {
    if (pathogen.clinicalFeatures.symptoms.isEmpty && pathogen.clinicalFeatures.complications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.medical_services_outlined, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Clinical Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pathogen.clinicalFeatures.symptoms.isNotEmpty) ...[
            Text(
              'Symptoms:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            ...pathogen.clinicalFeatures.symptoms.map((symptom) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(symptom, style: TextStyle(fontSize: 15, color: AppColors.textPrimary))),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
          ],
          if (pathogen.clinicalFeatures.complications.isNotEmpty) ...[
            Text(
              'Complications:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            ...pathogen.clinicalFeatures.complications.map((complication) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(complication, style: TextStyle(fontSize: 15, color: AppColors.textPrimary))),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
          ],
          if (pathogen.clinicalFeatures.caseDefinition.suspected.isNotEmpty ||
              pathogen.clinicalFeatures.caseDefinition.confirmed.isNotEmpty) ...[
            Text(
              'Case Definition:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            if (pathogen.clinicalFeatures.caseDefinition.suspected.isNotEmpty) ...[
              Text(
                'Suspected: ${pathogen.clinicalFeatures.caseDefinition.suspected}',
                style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
            ],
            if (pathogen.clinicalFeatures.caseDefinition.confirmed.isNotEmpty)
              Text(
                'Confirmed: ${pathogen.clinicalFeatures.caseDefinition.confirmed}',
                style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiagnosisSection() {
    return _buildListSection('Diagnosis', pathogen.diagnosis, Icons.science_outlined);
  }

  Widget _buildInfectionControlSection() {
    if (pathogen.infectionControl.precautions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.shield_outlined, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Infection Control & Containment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Precautions', pathogen.infectionControl.precautions),
          _buildInfoRow('Screening', pathogen.infectionControl.screening),
          _buildInfoRow('Cohorting', pathogen.infectionControl.cohorting),
          _buildInfoRow('Source Control', pathogen.infectionControl.sourceControl),
          _buildInfoRow('Environmental', pathogen.infectionControl.environmental),
          _buildInfoRow('Staff Education', pathogen.infectionControl.staffEducation),
        ],
      ),
    );
  }

  Widget _buildOutbreakTriggersSection() {
    return _buildListSection('Outbreak Triggers', pathogen.outbreakTriggers, Icons.notification_important);
  }

  Widget _buildReportingSection() {
    return _buildListSection('Reporting & Communication', pathogen.reportingCommunication, Icons.campaign);
  }

  Widget _buildPreventionSection() {
    return _buildListSection('Prevention / Education', pathogen.prevention, Icons.health_and_safety);
  }

  Widget _buildReferencesSection() {
    if (pathogen.references.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.library_books, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'References',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pathogen.references.map((ref) {
              return OutlinedButton.icon(
                onPressed: () => _launchURL(ref.url),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(ref.label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showQuickReferenceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Quick Reference: ${pathogen.name}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickRefItem('Definition', pathogen.definition),
              _buildQuickRefItem('Transmission', pathogen.transmission.mode),
              _buildQuickRefItem('Incubation', pathogen.incubationPeriod.range),
              _buildQuickRefItem('Precautions', pathogen.infectionControl.precautions),
              if (pathogen.clinicalFeatures.symptoms.isNotEmpty)
                _buildQuickRefItem('Key Symptoms', pathogen.clinicalFeatures.symptoms.take(3).join(', ')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRefItem(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

