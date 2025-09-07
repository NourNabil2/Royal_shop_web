// Advanced Responsive App Bar Component
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
  Size get preferredSize => const Size.fromHeight(80);
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
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper method to get responsive dimensions and breakpoints
  Map<String, dynamic> _getResponsiveConfig(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return {
      'isMobile': isMobile,
      'isTablet': isTablet,
      'isDesktop': isDesktop,
      'logoSize': isMobile ? 20.0 : (isTablet ? 22.0 : 24.0),
      'iconSize': isMobile ? 20.0 : (isTablet ? 22.0 : 24.0),
      'titleFontSize': isMobile ? 18.0 : (isTablet ? 20.0 : 24.0),
      'subtitleFontSize': isMobile ? 10.0 : (isTablet ? 11.0 : 12.0),
      'navFontSize': isMobile ? 12.0 : (isTablet ? 13.0 : 14.0),
      'searchWidth': isMobile ? 150.0 : (isTablet ? 180.0 : 200.0),
      'horizontalPadding': isMobile ? 8.0 : (isTablet ? 12.0 : 16.0),
      'showNavButtons': !isMobile, // Hide navigation buttons on mobile
      'showSubtitle': !isMobile || screenWidth > 400, // Hide subtitle on very small screens
    };
  }

  @override
  Widget build(BuildContext context) {
    final config = _getResponsiveConfig(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 80,
              leading: config['isMobile'] ? _buildMobileMenuButton() : null,
              title: _buildResponsiveTitle(config),
              centerTitle: false,
              actions: config['isMobile']
                  ? _buildMobileActions(config)
                  : _buildDesktopActions(config),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileMenuButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            _isMobileMenuOpen = !_isMobileMenuOpen;
          });
          _showMobileMenu();
        },
        icon: Icon(
          _isMobileMenuOpen ? Icons.close : Icons.menu,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildResponsiveTitle(Map<String, dynamic> config) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            size: config['logoSize'],
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Royal design',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: config['titleFontSize'],
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (config['showSubtitle'])
                Text(
                  'Premium Collection',
                  style: GoogleFonts.poppins(
                    fontSize: config['subtitleFontSize'],
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w300,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.3);
  }

  List<Widget> _buildMobileActions(Map<String, dynamic> config) {
    return [
      _buildSearchButton(config),
      const SizedBox(width: 8),
      _buildCartButton(config),
      const SizedBox(width: 8),
      _buildThemeButton(config),
      SizedBox(width: config['horizontalPadding']),
    ];
  }

  List<Widget> _buildDesktopActions(Map<String, dynamic> config) {
    return [
      _buildSearchButton(config),
      const SizedBox(width: 12),
      if (config['showNavButtons']) _buildNavigationButtons(config),
      if (config['showNavButtons']) const SizedBox(width: 12),
      _buildCartButton(config),
      const SizedBox(width: 12),
      _buildThemeButton(config),
      SizedBox(width: config['horizontalPadding']),
    ];
  }

  Widget _buildSearchButton(Map<String, dynamic> config) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isSearchExpanded ? config['searchWidth'] : 50,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
              });
            },
            icon: Icon(
              _isSearchExpanded ? Icons.close : Icons.search,
              color: Colors.white,
              size: config['iconSize'],
            ),
          ),
          if (_isSearchExpanded)
            Expanded(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: config['isMobile'] ? 12 : 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: config['isMobile'] ? 12 : 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(Map<String, dynamic> config) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavButton(context, 'Home', () => context.go('/'), config),
          _buildNavButton(context, 'Contact', () => context.go('/contact'), config),
        ],
      ),
    );
  }

  Widget _buildCartButton(Map<String, dynamic> config) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: config['iconSize'],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                '3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: config['isMobile'] ? 9 : 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(Map<String, dynamic> config) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: widget.onThemeToggle,
        icon: Icon(
          Theme.of(context).brightness == Brightness.dark
              ? Icons.light_mode
              : Icons.dark_mode,
          color: Colors.white,
          size: config['iconSize'],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, VoidCallback onPressed, Map<String, dynamic> config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: config['isTablet'] ? 12 : 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: config['navFontSize'],
          ),
        ),
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
        height: MediaQuery.of(context).size.height * 0.4,
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
            const SizedBox(height: 20),
            Text(
              'Navigation Menu',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildMobileMenuItem('Home', Icons.home, () {
                    Navigator.pop(context);
                    context.go('/');
                  }),
                  _buildMobileMenuItem('Contact', Icons.contact_page, () {
                    Navigator.pop(context);
                    context.go('/contact');
                  }),
                  _buildMobileMenuItem('Profile', Icons.person, () {
                    Navigator.pop(context);
                    // Handle profile navigation
                  }),
                  _buildMobileMenuItem('Settings', Icons.settings, () {
                    Navigator.pop(context);
                    // Handle settings navigation
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _isMobileMenuOpen = false;
      });
    });
  }

  Widget _buildMobileMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}