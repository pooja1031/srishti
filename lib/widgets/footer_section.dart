import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      debugPrint('Could not launch \$url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      color: Theme.of(context).colorScheme.secondary, // Dark Charcoal
      child: Column(
        children: [
          Text(
            'S R I S H T I',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              letterSpacing: 6.0,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 1, color: const Color(0xFFC3A36E)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'BRIDAL ATELIER',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFFC3A36E),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.5,
                  ),
                ),
              ),
              Container(width: 16, height: 1, color: const Color(0xFFC3A36E)),
            ],
          ),
          const SizedBox(height: 36),
          Text(
            'LET\'S CREATE MAGIC',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 20,
              letterSpacing: 3,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 80,
            runSpacing: 40,
            children: [
              const _ContactInfoColumn(
                icon: Icons.location_on_outlined,
                title: 'STUDIO',
                content: 'Ernakulam',
              ),
              const _ContactInfoColumn(
                icon: Icons.email_outlined,
                title: 'CONTACT',
                content: 'srishti2gmail.com\n+91 12345668',
              ),
            ],
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _launchUrl(
                  'https://www.instagram.com/srishti_signature_by_dhanya/?hl=en',
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.instagram,
                  color: Colors.white70,
                ),
                tooltip: 'Instagram',
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () => _launchUrl('https://facebook.com'),
                icon: const FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Colors.white70,
                ),
                tooltip: 'Facebook',
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            '© ${DateTime.now().year} Srishti Bridal Studio. All rights reserved.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _ContactInfoColumn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _ContactInfoColumn({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
