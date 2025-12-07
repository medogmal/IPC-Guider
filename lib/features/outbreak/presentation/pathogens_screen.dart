import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/shared_widgets.dart';

class PathogensScreen extends StatelessWidget {
  const PathogensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pathogen-Specific Outbreaks'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 64),
          children: [
          // Section Header
          _buildSectionHeader(
            'Pathogen-Specific Outbreaks',
            'MDROs, bacterial, viral, and fungal outbreaks',
            Icons.biotech_outlined,
            AppColors.error,
          ),

          const SizedBox(height: 24),

          // MDROs Section
          _buildCategoryHeader('Multidrug-Resistant Organisms (MDROs)'),
          _buildPathogenCard(context, 'MRSA', 'Methicillin-resistant Staphylococcus aureus', '/outbreak/pathogens/mrsa'),
          _buildPathogenCard(context, 'VRE', 'Vancomycin-resistant Enterococci', '/outbreak/pathogens/vre'),
          _buildPathogenCard(context, 'CRE', 'Carbapenem-resistant Enterobacteriaceae', '/outbreak/pathogens/cre'),
          _buildPathogenCard(context, 'ESBL', 'Extended-spectrum beta-lactamase producers', '/outbreak/pathogens/esbl'),
          _buildPathogenCard(context, 'MDR Acinetobacter', 'Multidrug-resistant Acinetobacter', '/outbreak/pathogens/mdr-acinetobacter'),
          _buildPathogenCard(context, 'MDR Pseudomonas', 'Multidrug-resistant Pseudomonas', '/outbreak/pathogens/mdr-pseudomonas'),

          const SizedBox(height: 20),

          // Bacterial Section
          _buildCategoryHeader('Bacterial Pathogens'),
          _buildPathogenCard(context, 'Tuberculosis (TB)', 'Mycobacterium tuberculosis', '/outbreak/pathogens/tb'),
          _buildPathogenCard(context, 'Legionella', 'Legionella pneumophila', '/outbreak/pathogens/legionella'),
          _buildPathogenCard(context, 'Burkholderia', 'Burkholderia species', '/outbreak/pathogens/burkholderia'),

          const SizedBox(height: 20),

          // Viral Section
          _buildCategoryHeader('Viral Pathogens'),
          _buildPathogenCard(context, 'SARS-CoV-2', 'COVID-19 coronavirus', '/outbreak/pathogens/covid19'),
          _buildPathogenCard(context, 'SARS-CoV', 'Severe Acute Respiratory Syndrome', '/outbreak/pathogens/sars'),
          _buildPathogenCard(context, 'MERS-CoV', 'Middle East Respiratory Syndrome', '/outbreak/pathogens/mers'),
          _buildPathogenCard(context, 'Influenza', 'Seasonal and pandemic influenza', '/outbreak/pathogens/influenza'),
          _buildPathogenCard(context, 'RSV', 'Respiratory Syncytial Virus', '/outbreak/pathogens/rsv'),
          _buildPathogenCard(context, 'Hepatitis', 'Hepatitis A, B, C viruses', '/outbreak/pathogens/hepatitis'),

          const SizedBox(height: 20),

          // Fungal Section
          _buildCategoryHeader('Fungal Pathogens'),
          _buildPathogenCard(context, 'Candida auris', 'Multidrug-resistant Candida auris', '/outbreak/pathogens/candida-auris'),
          _buildPathogenCard(context, 'Aspergillosis', 'Aspergillus species', '/outbreak/pathogens/aspergillosis'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPathogenCard(BuildContext context, String name, String description, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IpcCard(
        title: name,
        subtitle: description,
        icon: Icons.coronavirus_outlined,
        onTap: () => context.go(route),
      ),
    );
  }
}
