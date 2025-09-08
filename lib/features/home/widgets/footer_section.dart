// Footer Section (No Quick Links — Facebook & WhatsApp only)
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

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
          final isDesktop = constraints.maxWidth > 800;

          if (isDesktop) {
            // عمودين: معلومات الشركة + السوشيال
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Info
                Expanded(child: _buildCompanyInfo(context)),
                const SizedBox(width: 60),
                // Social Only
                Expanded(child: _buildSocialOnly(context)),
              ],
            );
          } else {
            // موبايل: عمودي
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompanyInfo(context),
                const SizedBox(height: 28),
                _buildSocialOnly(context),
              ],
            );
          }
        },
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildCompanyInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo + Brand
        Row(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Royal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Symphony',
                fontSize: 40,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'نقدّم لعملائنا مجموعة مميزة من الأكياس والكروت المصممة خصيصًا لتلبية احتياجات مصانع الكروبت والبادجات والملابس، '
              'حيث نحرص على الدمج بين الجودة العالية والتصميم الأنيق لنساعدكم في إبراز هوية علامتكم التجارية بصورة احترافية تلفت الأنظار وتترك انطباعًا يدوم.',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialOnly(BuildContext context) {
    final titleStyle = GoogleFonts.cairo(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تابعنا أو تواصل معنا', style: titleStyle),
        const SizedBox(height: 16),

        // Icons Row: Facebook + WhatsApp
        Row(
          children: [
            _buildSocialIcon(
              context,
              icon: Icons.facebook,
              tooltip: 'Facebook',
              onTap: _openFacebook,
            ),
            const SizedBox(width: 12),
            _buildSocialIcon(
              context,
              icon: Icons.chat, // نعرض أيقونة محايدة للواتساب (ممكن تبدلها بأي باكدج أيقونات)
              tooltip: 'واتساب',
              onTap: _launchWhatsApp,
              accentColor: const Color(0xFF25D366),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildCopyright(context),
      ],
    );
  }

  Widget _buildSocialIcon(
      BuildContext context, {
        required IconData icon,
        required VoidCallback onTap,
        String? tooltip,
        Color? accentColor,
      }) {
    final bg = (accentColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1);
    final fg = accentColor ?? Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: (accentColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.18)),
          ),
          child: Icon(icon, color: fg, size: 20),
        ),
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '© 2025 Royal. جميع الحقوق محفوظة.',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.55),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: 'nour60g@gmail.com',
              query: Uri.encodeFull('subject=استفسار من موقع Royal&body=مرحبًا Nour،'),
            );

            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
            } else {
              debugPrint('Could not launch email client');
            }
          },
          child: Text(
            'Developed by Nour Nabil',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        )

      ],
    );
  }


  // ====== Actions ======
  void _openFacebook() async {
    const url = 'https://www.facebook.com/share/1Cj6e45vbe/';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  void _launchWhatsApp() async {
    const internationalPhone = '201505280117'; // +20
    final text = 'مرحبًا! أرغب في الاستفسار عن المنتجات.';
    final url = 'https://wa.me/$internationalPhone?text=${Uri.encodeComponent(text)}';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

}
