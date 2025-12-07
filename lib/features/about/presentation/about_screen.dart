import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/back_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackAppBar(
        title: 'About',
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/icons/ipc_icon.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'IPC Guider',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Infection Prevention & Control',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0+1',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About This App
          _AboutSection(
            title: 'About This App',
            child: Text(
              'IPC Guider is a comprehensive offline-first mobile application designed for healthcare professionals working in infection prevention and control. '
              'The app provides evidence-based calculators, isolation precautions, clinical protocols, and educational resources to support safe patient care.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Evidence-Based Content
          _AboutSection(
            title: 'Evidence-Based Content',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReferenceItem(
                  title: 'World Health Organization (WHO)',
                  description: 'Global infection prevention guidelines',
                  url: 'https://www.who.int/teams/integrated-health-services/infection-prevention-control',
                ),
                _ReferenceItem(
                  title: 'Centers for Disease Control and Prevention (CDC)',
                  description: 'Infection control practices & HAI prevention',
                  url: 'https://www.cdc.gov/infectioncontrol/',
                ),
                _ReferenceItem(
                  title: 'National Healthcare Safety Network (NHSN)',
                  description: 'CDC\'s healthcare-associated infection tracking system',
                  url: 'https://www.cdc.gov/nhsn/index.html',
                ),
                _ReferenceItem(
                  title: 'Association for Professionals in Infection Control (APIC)',
                  description: 'IPC standards & best practices',
                  url: 'https://apic.org/',
                ),
                _ReferenceItem(
                  title: 'Infectious Diseases Society of America (IDSA)',
                  description: 'Clinical practice guidelines & antimicrobial stewardship',
                  url: 'https://www.idsociety.org/practice-guideline/',
                ),
                _ReferenceItem(
                  title: 'Society for Healthcare Epidemiology of America (SHEA)',
                  description: 'Healthcare epidemiology & antimicrobial stewardship',
                  url: 'https://shea-online.org/',
                ),
                _ReferenceItem(
                  title: 'Clinical and Laboratory Standards Institute (CLSI)',
                  description: 'Antimicrobial susceptibility testing standards',
                  url: 'https://clsi.org/',
                ),
                _ReferenceItem(
                  title: 'American Society for Microbiology (ASM)',
                  description: 'Clinical microbiology & laboratory guidelines',
                  url: 'https://asm.org/',
                ),
                _ReferenceItem(
                  title: 'European Committee on Antimicrobial Susceptibility Testing (EUCAST)',
                  description: 'Antimicrobial susceptibility testing & breakpoints',
                  url: 'https://www.eucast.org/',
                ),
                _ReferenceItem(
                  title: 'General Directorate of Infection Prevention and Control (GDIPC)',
                  description: 'Saudi Ministry of Health IPC guidelines',
                  url: 'https://www.moh.gov.sa/',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Technical Information
          _AboutSection(
            title: 'Technical Information',
            child: Column(
              children: [
                _InfoRow('Platform', 'Flutter (Cross-platform)'),
                _InfoRow('Data Storage', 'Local (Hive + SharedPreferences)'),
                _InfoRow('Network', 'Offline-only (No internet required)'),
                _InfoRow('Supported Platforms', 'Android, iOS  and (Desktop coming soon)'),
                _InfoRow('Build Date', 'December 6, 2025'),
                _InfoRow('Version', '1.0.0+1'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Developed By
          _AboutSection(
            title: 'Developed By',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Yazeed A. Qasem',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Consultant Medical Microbiology and Director of Infection Prevention and Control',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jazan Armed Forces Hospital',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Legal & Privacy
          _AboutSection(
            title: 'Legal & Privacy',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medical Disclaimer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Medical Disclaimer: This app is for educational and professional reference purposes only. It does not replace institutional policies, or local guidelines.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Privacy & Data Policy
                Text(
                  '• This application operates entirely offline with no internet connectivity required.\n\n'
                  '• No user, patient, or institutional data is collected, stored, transmitted, or shared.\n\n'
                  '• All calculations, configurations, and results remain locally on your device at all times.\n\n'
                  '• The app does not connect to external servers, cloud services, or APIs.\n\n'
                  '• No analytics, advertisements, or third-party integrations are included.\n\n'
                  '• Always follow your institution\'s policies and procedures as the primary authority.\n\n'
                  '• Use of this app is at the user\'s discretion and responsibility.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Terms Agreement
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'By using this app, you agree to the Terms of Use and Privacy Policy.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // View Full Privacy Policy Button
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse('https://superyazeed.github.io/ipcguider-privacy/');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'View Full Privacy Policy',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.open_in_new, color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Website Reference
                Text(
                  'Full Terms & Privacy Policy:\nhttps://superyazeed.github.io/ipcguider-privacy/',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Scientific & Academic Use
          _AboutSection(
            title: 'Scientific & Academic Use',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'If you use this app in research, quality-improvement projects, competency assessments, or educational activities, please acknowledge it using the following citation:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote, color: AppColors.info, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'IPC Guider – A Mobile Application for Evidence-Based Infection Prevention and Control Practice, developed by Dr. Yazeed A. Qasem.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Contact Information
          _AboutSection(
            title: 'Contact',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'For questions, feedback, or support:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse('mailto:yzd.qsm@gmail.com?subject=IPC%20Guider%20Inquiry');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'yzd.qsm@gmail.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Copyright
          _AboutSection(
            title: 'Copyright',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '© 2025 Dr. Yazeed A. Qasem. All rights reserved.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'These terms are governed by the laws of the Kingdom of Saudi Arabia.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Footer
          Center(
            child: Text(
              'Built with ❤️ for healthcare professionals',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Bottom padding for mobile responsiveness
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _AboutSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Container(
          width: double.infinity,
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
          child: child,
        ),
      ],
    );
  }
}



class _ReferenceItem extends StatelessWidget {
  final String title;
  final String description;
  final String url;

  const _ReferenceItem({
    required this.title,
    required this.description,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.link, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, color: AppColors.textTertiary, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
