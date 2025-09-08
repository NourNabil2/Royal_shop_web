// Advanced Responsive App Bar Component (centered title)
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onThemeToggle;

  const CustomAppBar({Key? key, this.onThemeToggle}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(88);
}

class _CustomAppBarState extends State<CustomAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isSearchExpanded = false;
  bool _isMobileMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getResponsiveConfig(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;
    final isTablet = w >= 768 && w < 1024;
    final isDesktop = w >= 1024;

    return {
      'isMobile': isMobile,
      'isTablet': isTablet,
      'isDesktop': isDesktop,
      'iconSize': isMobile ? 20.0 : (isTablet ? 22.0 : 24.0),
      'titleFontSize': isMobile ? 22.0 : (isTablet ? 26.0 : 30.0),
      'subtitleFontSize': isMobile ? 0.0 : (isTablet ? 11.0 : 12.0),
      'navFontSize': isMobile ? 12.0 : (isTablet ? 13.0 : 14.0),
      'searchWidth': isMobile ? 150.0 : (isTablet ? 210.0 : 260.0),
      'hPad': isMobile ? 8.0 : (isTablet ? 12.0 : 16.0),
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = _getResponsiveConfig(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: widget.preferredSize.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.85),
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Left + Right controls (kept on the edges)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: c['hPad']),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // LEFT SIDE
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (c['isMobile']) _buildMobileMenuButton(c),
                              if (!c['isMobile']) _buildSearchButton(c),
                            ],
                          ),

                          // RIGHT SIDE
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (c['isMobile']) _buildSearchButton(c),
                              if (!c['isMobile']) ...[
                                const SizedBox(width: 12),
                                _buildNavigationButtons(c),
                              ],
                              const SizedBox(width: 12),
                              _buildThemeButton(c),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // TRUE-CENTER TITLE (independent of leading/actions widths)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: _buildCenteredTitle(c),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenteredTitle(Map<String, dynamic> c) {
    final showSubtitle = !c['isMobile'] && c['subtitleFontSize'] > 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Royal',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Symphony',        // 👈 خطك المخصص
            fontSize: 36,                  // نضبطه يدويًا عشان اللمسة الفخمة
            letterSpacing: 1.0,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1.2,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (showSubtitle)
          Text(
            'Premium Collection',
            style: GoogleFonts.cairo(
              fontSize: c['subtitleFontSize'],
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w300,
              letterSpacing: 0.6,
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);
  }

  Widget _buildMobileMenuButton(Map<String, dynamic> c) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: IconButton(
        onPressed: () {
          setState(() => _isMobileMenuOpen = !_isMobileMenuOpen);
          _showMobileMenu();
        },
        icon: Icon(
          _isMobileMenuOpen ? Icons.close : Icons.menu,
          color: Colors.white,
          size: c['iconSize'],
        ),
        tooltip: 'Menu',
      ),
    );
  }

// في custom_app_bar.dart
  Widget _buildSearchButton(Map<String, dynamic> c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () => context.push('/search'),
        icon: Icon(Icons.search, color: Colors.white, size: c['iconSize']),
      ),
    );
  }

  Widget _buildNavigationButtons(Map<String, dynamic> c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavBtn('الرئيسية', () => context.go('/'), c),
          _buildNavBtn('تواصل معنا', () => context.go('/contact'), c),
        ],
      ),
    );
  }

  Widget _buildNavBtn(String title, VoidCallback onPressed, Map<String, dynamic> c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: c['isTablet'] ? 12 : 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: c['navFontSize'],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeButton(Map<String, dynamic> c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: IconButton(
        onPressed: widget.onThemeToggle,
        icon: Icon(
          Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
          color: Colors.white,
          size: c['iconSize'],
        ),
        tooltip: 'Toggle Theme',
      ),
    );
  }

  void _showMobileMenu() {
    if (!_isMobileMenuOpen) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.42,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Navigation Menu',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  _buildMobileMenuItem('Home', Icons.home, () { Navigator.pop(context); context.go('/'); }),
                  _buildMobileMenuItem('Contact', Icons.contact_page, () { Navigator.pop(context); context.go('/contact'); }),
                  _buildMobileMenuItem('Profile', Icons.person, () { Navigator.pop(context); }),
                  _buildMobileMenuItem('Settings', Icons.settings, () { Navigator.pop(context); }),
                ],
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      setState(() => _isMobileMenuOpen = false);
    });
  }

  Widget _buildMobileMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        onTap: onTap,
      ),
    );
  }
}

