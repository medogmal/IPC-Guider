import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design_tokens.dart';

class BreakingChainScreen extends StatelessWidget {
  const BreakingChainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breaking the Chain of Infection'),
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
            // Header Card
          Container(
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.link_off_outlined,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Breaking the Chain of Infection',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Interrupt transmission at any link',
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
                const SizedBox(height: 16),
                Text(
                  'Infection control measures work by breaking one or more links in the chain of infection. Understanding where to intervene is key to preventing transmission.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Link 1: Agent
          _buildBreakingPointCard(
            number: '1',
            title: 'Agent (Pathogen)',
            interventions: [
              'Antimicrobial stewardship to reduce resistance',
              'Vaccination to reduce pathogen circulation',
              'Decolonization protocols (e.g., MRSA, VRE)',
              'Antimicrobial prophylaxis in specific situations',
            ],
            example: 'MRSA decolonization with mupirocin nasal ointment + chlorhexidine baths',
            color: AppColors.error,
            icon: Icons.coronavirus_outlined,
          ),

          const SizedBox(height: 16),

          // Link 2: Reservoir
          _buildBreakingPointCard(
            number: '2',
            title: 'Reservoir',
            interventions: [
              'Identify and treat infected/colonized patients',
              'Environmental cleaning and disinfection',
              'Water system management (Legionella control)',
              'Proper waste disposal and linen handling',
              'Food safety and hygiene',
            ],
            example: 'Enhanced environmental cleaning with bleach for C. difficile spores',
            color: AppColors.warning,
            icon: Icons.water_drop_outlined,
          ),

          const SizedBox(height: 16),

          // Link 3: Portal of Exit
          _buildBreakingPointCard(
            number: '3',
            title: 'Portal of Exit',
            interventions: [
              'Respiratory hygiene/cough etiquette',
              'Proper wound care and dressing',
              'Containment of body fluids',
              'Safe injection practices',
              'Proper handling of secretions/excretions',
            ],
            example: 'Surgical masks for patients with respiratory symptoms to contain droplets',
            color: AppColors.info,
            icon: Icons.logout_outlined,
          ),

          const SizedBox(height: 16),

          // Link 4: Mode of Transmission
          _buildBreakingPointCard(
            number: '4',
            title: 'Mode of Transmission',
            interventions: [
              'Hand hygiene (most important!)',
              'Personal protective equipment (PPE)',
              'Isolation precautions (Contact/Droplet/Airborne)',
              'Environmental controls (ventilation, negative pressure)',
              'Safe injection practices and aseptic technique',
              'Proper equipment reprocessing',
            ],
            example: 'Contact Precautions (gloves + gown) for MRSA to prevent hand transmission',
            color: const Color(0xFF9C27B0), // Purple
            icon: Icons.swap_horiz_outlined,
          ),

          const SizedBox(height: 16),

          // Link 5: Portal of Entry
          _buildBreakingPointCard(
            number: '5',
            title: 'Portal of Entry',
            interventions: [
              'Aseptic technique for invasive procedures',
              'Central line insertion bundles',
              'Catheter care bundles',
              'Surgical site infection prevention',
              'Skin integrity maintenance',
              'Proper wound care',
            ],
            example: 'Central line bundle: hand hygiene, maximal barrier precautions, chlorhexidine skin prep',
            color: AppColors.success,
            icon: Icons.login_outlined,
          ),

          const SizedBox(height: 16),

          // Link 6: Susceptible Host
          _buildBreakingPointCard(
            number: '6',
            title: 'Susceptible Host',
            interventions: [
              'Vaccination (most effective!)',
              'Immunization programs',
              'Nutritional support',
              'Minimize invasive devices',
              'Reduce immunosuppression when possible',
              'Early removal of catheters/devices',
            ],
            example: 'Annual influenza vaccination for healthcare workers and high-risk patients',
            color: AppColors.primary,
            icon: Icons.person_outlined,
          ),

          const SizedBox(height: 24),

          // Key Principles Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
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
                    Icon(Icons.lightbulb_outlined, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Key Principles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPrincipleItem('Breaking ANY link stops transmission'),
                _buildPrincipleItem('Multiple interventions = stronger protection (Swiss cheese model)'),
                _buildPrincipleItem('Hand hygiene breaks transmission at multiple points'),
                _buildPrincipleItem('Focus on the weakest/most accessible link'),
                _buildPrincipleItem('Outbreak control requires breaking multiple links simultaneously'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // References Section
          Container(
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
                Text(
                  'Official References',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildReferenceItem(
                  'CDC – Guideline for Isolation Precautions',
                  'https://www.cdc.gov/infectioncontrol/guidelines/isolation/index.html',
                ),
                _buildReferenceItem(
                  'WHO – Standard Precautions in Health Care',
                  'https://www.who.int/publications/i/item/9789241547857',
                ),
                _buildReferenceItem(
                  'APIC – Breaking the Chain of Infection',
                  'https://apic.org/monthly_alerts/breaking-the-chain-of-infection/',
                ),
                _buildReferenceItem(
                  'GDIPC/Weqaya – National IPC Guidelines (Saudi Arabia)',
                  'https://www.moh.gov.sa/en/Ministry/MediaCenter/Publications/Pages/Publications-2020-10-29-001.aspx',
                ),
                ],
              ),
            ),
            ],
          ),
        ),
    );
  }

  Widget _buildBreakingPointCard({
    required String number,
    required String title,
    required List<String> interventions,
    required String example,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Interventions:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...interventions.map((intervention) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(Icons.check_circle, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    intervention,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outlined, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        example,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrincipleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.arrow_right, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
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

