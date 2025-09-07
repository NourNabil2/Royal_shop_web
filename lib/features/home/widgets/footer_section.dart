
// Footer Section
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/configuration.dart';

class FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;

          if (isDesktop) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCompanyInfo(context)),
                const SizedBox(width: 40),
                Expanded(child: _buildQuickLinks(context)),
                const SizedBox(width: 40),
                Expanded(child: _buildSocialMedia(context)),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompanyInfo(context),
                const SizedBox(height: 32),
                _buildQuickLinks(context),
                const SizedBox(height: 32),
                _buildSocialMedia(context),
                const SizedBox(height: 32),
                _buildCopyright(context),
              ],
            );
          }
        },
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildCompanyInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'ModernShop',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Discover premium products that combine quality with innovation. Your satisfaction is our priority.',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink(context, 'Home', () => router.go('/')),
        _buildFooterLink(context, 'Products', () => router.go('/')),
        _buildFooterLink(context, 'Contact', () => router.go('/contact')),
        _buildFooterLink(context, 'About Us', () {}),
      ],
    );
  }

  Widget _buildSocialMedia(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow Us',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSocialIcon(context, Icons.facebook, () {}),
            const SizedBox(width: 12),
            _buildSocialIcon(context, Icons.camera_alt, () {}),
            const SizedBox(width: 12),
            _buildSocialIcon(context, Icons.alternate_email, () {}),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _launchWhatsApp(),
          icon: const Icon(Icons.chat, color: Colors.white, size: 16),
          label: Text(
            'WhatsApp',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Center(
      child: Text(
        '© 2025 ModernShop. All rights reserved.',
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
    );
  }

  void _launchWhatsApp() {
    final phone = "+1234567890";
    final text = "Hello! I'd like to get in touch.";
    final url = "https://wa.me/$phone?text=${Uri.encodeComponent(text)}";
    print("WhatsApp URL: $url");
  }
}