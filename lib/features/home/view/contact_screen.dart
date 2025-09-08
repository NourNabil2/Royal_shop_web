// Contact Screen (Arabic + WhatsApp Direct)
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shoping/core/widgets/custom_app_bar.dart';
import '../../../core/theme/theme.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  static const String _intlWhatsApp = '201505280117'; // +20 150 528 0117

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _openWhatsAppDirect() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final msg = _msgCtrl.text.trim();

    final composed =
        'مرحبًا،\n'
        'الاسم: $name\n'
        'الإيميل: $email\n'
        'الرسالة: $msg\n'
        '\n(مرسلة من موقع Royal)';

    final url =
        'https://wa.me/$_intlWhatsApp?text=${Uri.encodeComponent(composed)}';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر فتح واتساب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onThemeToggle: () =>
            Provider.of<ThemeController>(context, listen: false)
                .toggleTheme(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'تواصل معنا',
                style: GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideX(begin: 0.2),
              const SizedBox(height: 16),
              Text(
                'يسعدنا استقبال استفساراتكم وطلباتكم—راسلنا عبر النموذج أو مباشرة على واتساب.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
              const SizedBox(height: 40),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 800;

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildContactInfo(context)),
                        const SizedBox(width: 40),
                        Expanded(child: _buildContactForm(context)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildContactInfo(context),
                        const SizedBox(height: 40),
                        _buildContactForm(context),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactItem(
          context,
          Icons.phone,
          'الهاتف',
          '01505280117',
        ),
        // const SizedBox(height: 24),
        // _buildContactItem(
        //   context,
        //   Icons.email,
        //   'البريد الإلكتروني',
        //   'contact@royal-eg.com',
        //   // onTap: () async {
        //   //   final uri = Uri(
        //   //     scheme: 'mailto',
        //   //     path: 'contact@royal-eg.com',
        //   //     query: Uri.encodeFull('subject=استفسار من موقع Royal'),
        //   //   );
        //   //   if (await canLaunchUrl(uri)) {
        //   //     await launchUrl(uri);
        //   //   }
        //   // },
        // ),
        const SizedBox(height: 24),
        _buildContactItem(
          context,
          Icons.location_on,
          'العنوان',
          'القاهرة، مصر',
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildContactItem(
      BuildContext context,
      IconData icon,
      String title,
      String content, {
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أرسل لنا رسالة',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'الاسم',
              icon: Icons.person,
              controller: _nameCtrl,
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'من فضلك أدخل الاسم' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'الرسالة',
              icon: Icons.message,
              controller: _msgCtrl,
              maxLines: 4,
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'من فضلك أدخل الرسالة' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openWhatsAppDirect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'إرسال عبر واتساب',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: maxLines == 1 ? keyboardType : TextInputType.multiline,
      maxLines: maxLines,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }

}
