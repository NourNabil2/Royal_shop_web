// Enhanced Product Details Screen with Modern UI - Responsive Version
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoping/core/model/product_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'dart:async';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _parallaxController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _imageTransitionController;
  late ScrollController _scrollController;
  late Timer _autoImageTimer;

  int _selectedImageIndex = 0;
  double _scrollOffset = 0.0;
  bool _isAddedToFavorites = false;
  int _quantity = 1;
  bool _isImageExpanded = false;
  bool _isAutoSliding = true;
  bool _isHoveringImage = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _imageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scrollController.addListener(_onScroll);
    _parallaxController.forward();

    // Only start auto-slide if there are multiple images
    if (widget.product.imageUrls.length > 1) {
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    _autoImageTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isAutoSliding && !_isHoveringImage && mounted && widget.product.imageUrls.length > 1) {
        _nextImage();
      }
    });
  }

  void _nextImage() {
    if (mounted && widget.product.imageUrls.isNotEmpty) {
      setState(() {
        _selectedImageIndex = (_selectedImageIndex + 1) % widget.product.imageUrls.length;
      });
      _imageTransitionController.forward().then((_) {
        if (mounted) {
          _imageTransitionController.reset();
        }
      });
      HapticFeedback.selectionClick();
    }
  }

  void _selectImage(int index) {
    if (mounted && index != _selectedImageIndex && index < widget.product.imageUrls.length) {
      setState(() {
        _selectedImageIndex = index;
        _isAutoSliding = false; // Pause auto-slide when user interacts
      });
      _imageTransitionController.forward().then((_) {
        if (mounted) {
          _imageTransitionController.reset();
          // Resume auto-slide after 10 seconds
          Timer(const Duration(seconds: 10), () {
            if (mounted) {
              setState(() {
                _isAutoSliding = true;
              });
            }
          });
        }
      });
      HapticFeedback.selectionClick();
    }
  }

  // Helper method to get responsive dimensions
  Map<String, dynamic> _getResponsiveConfig(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define breakpoints
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return {
      'isMobile': isMobile,
      'isTablet': isTablet,
      'isDesktop': isDesktop,
      'expandedHeight': isDesktop ? 600 : (isTablet ? 500 : 400),
      'titleSize': isDesktop ? 56 : (isTablet ? 44 : 32),
      'subtitleSize': isDesktop ? 18 : (isTablet ? 16 : 14),
      'priceSize': isDesktop ? 48 : (isTablet ? 42 : 36),
      'bodySize': isDesktop ? 18 : (isTablet ? 16 : 14),
      'iconSize': isDesktop ? 26 : (isTablet ? 22 : 20),
      'padding': isDesktop ? 40.0 : (isTablet ? 30.0 : 20.0),
      'thumbnailSize': isDesktop ? 90.0 : (isTablet ? 70.0 : 60.0),
      'selectedThumbnailSize': isDesktop ? 110.0 : (isTablet ? 85.0 : 70.0),
    };
  }

  @override
  void dispose() {
    if (widget.product.imageUrls.length > 1) {
      _autoImageTimer.cancel();
    }
    _parallaxController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _imageTransitionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = _scrollController.offset / 300;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getResponsiveConfig(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildResponsiveSliverAppBar(context, config),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).colorScheme.surface.withOpacity(0.3),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(config['padding']),
                child: config['isDesktop']
                    ? _buildDesktopLayout(context, config)
                    : config['isTablet']
                    ? _buildTabletLayout(context, config)
                    : _buildMobileLayout(context, config),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: config['isMobile'] ? _buildResponsiveFAB(context, config) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildResponsiveSliverAppBar(BuildContext context, Map<String, dynamic> config) {
    return SliverAppBar(
      expandedHeight: config['expandedHeight'].toDouble(),
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
      leading: Container(
        margin: EdgeInsets.all(config['isMobile'] ? 6.0 : 8.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: config['isMobile'] ? 18.0 : 20.0,
          ),
          onPressed: () => context.go('/'),
        ),
      ),
      actions: _buildAppBarActions(context, config),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildResponsiveImageGallery(context, config),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, Map<String, dynamic> config) {
    final actionSize = config['isMobile'] ? 6.0 : 8.0;
    final iconSize = config['isMobile'] ? 18.0 : 20.0;

    return [
      Container(
        margin: EdgeInsets.all(actionSize),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _isAddedToFavorites
                    ? 1.0 + (math.sin(_pulseController.value * 2 * math.pi) * 0.1)
                    : 1.0,
                child: Icon(
                  _isAddedToFavorites ? Icons.favorite : Icons.favorite_border,
                  color: _isAddedToFavorites ? Colors.red : Colors.white,
                  size: iconSize,
                ),
              );
            },
          ),
          onPressed: () {
            setState(() {
              _isAddedToFavorites = !_isAddedToFavorites;
            });
            HapticFeedback.lightImpact();
          },
        ),
      ),
      Container(
        margin: EdgeInsets.all(actionSize),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.share, color: Colors.white, size: iconSize),
          onPressed: () => _showAdvancedShareBottomSheet(context, config),
        ),
      ),
      if (!config['isMobile'] && widget.product.imageUrls.length > 1) ...[
        Container(
          margin: EdgeInsets.all(actionSize),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: Icon(
              _isAutoSliding ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: iconSize,
            ),
            onPressed: () {
              setState(() {
                _isAutoSliding = !_isAutoSliding;
              });
            },
          ),
        ),
      ],
    ];
  }

  Widget _buildResponsiveImageGallery(BuildContext context, Map<String, dynamic> config) {
    // Handle case where product has no images
    if (widget.product.imageUrls.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: config['iconSize'] * 3,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No images available',
                style: GoogleFonts.cairo(
                  fontSize: config['bodySize'],
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Hero(
      tag: 'product-${widget.product.id}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHoveringImage = true),
        onExit: (_) => setState(() => _isHoveringImage = false),
        child: Stack(
          children: [
            // Main Image Display with Smooth Transitions
            AnimatedBuilder(
              animation: _imageTransitionController,
              builder: (context, child) {
                return GestureDetector(
                  onTap: () => _showImageModal(context, config),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_isImageExpanded ? 0 : 20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Current Image
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 400),
                            opacity: 1.0 - _imageTransitionController.value,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(widget.product.imageUrls[_selectedImageIndex]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Transition Image
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 400),
                            opacity: _imageTransitionController.value,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(widget.product.imageUrls[_selectedImageIndex]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                          // Hover Effect
                          if (!config['isMobile'] && _isHoveringImage)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Enhanced Floating Thumbnail Gallery (only if multiple images)
            if (widget.product.imageUrls.length > 1)
              Positioned(
                bottom: config['isMobile'] ? 20.0 : 40.0,
                left: config['padding'],
                right: config['padding'],
                child: _buildThumbnailGallery(context, config),
              ),

            // Enhanced Image Counter (only if multiple images)
            if (widget.product.imageUrls.length > 1)
              Positioned(
                top: config['isMobile'] ? 15.0 : 30.0,
                right: config['isMobile'] ? 15.0 : 30.0,
                child: _buildImageCounter(context, config),
              ),

            // Auto-slide Indicator (only if auto-sliding and multiple images)
            if (_isAutoSliding && widget.product.imageUrls.length > 1)
              Positioned(
                top: config['isMobile'] ? 15.0 : 30.0,
                left: config['isMobile'] ? 15.0 : 30.0,
                child: _buildAutoSlideIndicator(context, config),
              ),

            // Zoom Indicator
            Positioned(
              bottom: widget.product.imageUrls.length > 1
                  ? (config['isMobile'] ? 110.0 : 150.0)
                  : (config['isMobile'] ? 20.0 : 40.0),
              right: config['isMobile'] ? 15.0 : 30.0,
              child: _buildZoomIndicator(context, config),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildThumbnailGallery(BuildContext context, Map<String, dynamic> config) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      height: config['isMobile'] ? 70.0 : (config['isTablet'] ? 85.0 : 100.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(_isHoveringImage ? 0.4 : 0.3),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: config['isMobile'] ? 8.0 : 16.0),
        itemCount: widget.product.imageUrls.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedImageIndex == index;
          double thumbnailSize = isSelected ? config['selectedThumbnailSize'] : config['thumbnailSize'];

          return GestureDetector(
            onTap: () => _selectImage(index),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                margin: EdgeInsets.symmetric(
                    horizontal: config['isMobile'] ? 4.0 : 8.0,
                    vertical: config['isMobile'] ? 8.0 : 16.0
                ),
                width: thumbnailSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    children: [
                      Image.network(
                        widget.product.imageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.broken_image,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                      if (!isSelected)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5);
  }

  Widget _buildImageCounter(BuildContext context, Map<String, dynamic> config) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
          horizontal: config['isMobile'] ? 8.0 : 16.0,
          vertical: config['isMobile'] ? 4.0 : 10.0
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(_isHoveringImage ? 0.7 : 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library,
            color: Colors.white,
            size: config['isMobile'] ? 14.0 : 18.0,
          ),
          const SizedBox(width: 8),
          Text(
            '${_selectedImageIndex + 1}/${widget.product.imageUrls.length}',
            style: TextStyle(
              color: Colors.white,
              fontSize: config['isMobile'] ? 10.0 : 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.3);
  }

  Widget _buildAutoSlideIndicator(BuildContext context, Map<String, dynamic> config) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(config['isMobile'] ? 6.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_filled,
            color: Colors.white,
            size: config['isMobile'] ? 14.0 : 18.0,
          ),
          if (!config['isMobile']) ...[
            const SizedBox(width: 6),
            Text(
              'Auto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildZoomIndicator(BuildContext context, Map<String, dynamic> config) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(config['isMobile'] ? 6.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(_isHoveringImage ? 0.7 : 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.zoom_in,
            color: Colors.white,
            size: config['isMobile'] ? 16.0 : 22.0,
          ),
          if (!config['isMobile']) ...[
            SizedBox(width: 6),
            Text(
              'Zoom',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildDesktopLayout(BuildContext context, Map<String, dynamic> config) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: config['padding'] / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildProductInfo(context, config),
          ),
          const SizedBox(width: 80),
          Expanded(
            flex: 2,
            child: _buildProductSpecs(context, config),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, Map<String, dynamic> config) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: config['padding'] / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildProductInfo(context, config),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 2,
            child: _buildProductSpecs(context, config),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Map<String, dynamic> config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductInfo(context, config),
        const SizedBox(height: 30),
        _buildProductSpecs(context, config),
      ],
    );
  }

  Widget _buildProductInfo(BuildContext context, Map<String, dynamic> config) {
    return Transform.translate(
      offset: Offset(0, _scrollOffset * -20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Product Category Badge
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: config['isMobile'] ? 16.0 : 24.0,
                      vertical: config['isMobile'] ? 8.0 : 12.0
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: config['isMobile'] ? 14.0 : 18.0,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.product.category.isNotEmpty ? widget.product.category : 'Premium Collection',
                        style: GoogleFonts.cairo(
                          fontSize: config['isMobile'] ? 11.0 : 15.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3).shimmer(duration: 2000.ms),

          SizedBox(height: config['isMobile'] ? 16.0 : 24.0),

          // Enhanced Product Name with Responsive Text
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      widget.product.name,
                      style: GoogleFonts.cairo(
                        fontSize: config['titleSize'].toDouble(),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                      maxLines: config['isMobile'] ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: config['isMobile'] ? 12.0 : 20.0),

          // Enhanced Rating Section with Responsive Design
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(-50 * (1 - value), 0),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Container(
                    padding: EdgeInsets.all(config['isMobile'] ? 12.0 : 20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: config['isMobile'] ? 6.0 : 8.0,
                          vertical: config['isMobile'] ? 2.0 : 4.0
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.product.inStock ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          color: widget.product.inStock ? Colors.green.shade700 : Colors.red.shade700,
                          fontSize: config['isMobile'] ? 10.0 : 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // SizedBox(height: config['isMobile'] ? 20.0 : 28.0),

          // // Enhanced Price Section with Responsive Animation
          // AnimatedBuilder(
          //   animation: _floatingController,
          //   builder: (context, child) {
          //     return TweenAnimationBuilder<double>(
          //       duration: const Duration(milliseconds: 1000),
          //       tween: Tween(begin: 0.0, end: 1.0),
          //       curve: Curves.elasticOut,
          //       builder: (context, value, child) {
          //         return Transform.translate(
          //           offset: Offset(
          //               0,
          //               (math.sin(_floatingController.value * 2 * math.pi) * 3) +
          //                   (30 * (1 - value))
          //           ),
          //           child: Opacity(
          //             opacity: value.clamp(0.0, 1.0),
          //             child: Container(
          //               padding: EdgeInsets.all(config['isMobile'] ? 16.0 : 28.0),
          //               decoration: BoxDecoration(
          //                 gradient: LinearGradient(
          //                   begin: Alignment.topLeft,
          //                   end: Alignment.bottomRight,
          //                   colors: [
          //                     Theme.of(context).colorScheme.primary.withOpacity(0.12),
          //                     Theme.of(context).colorScheme.secondary.withOpacity(0.12),
          //                     Theme.of(context).colorScheme.tertiary.withOpacity(0.12),
          //                   ],
          //                 ),
          //                 borderRadius: BorderRadius.circular(25),
          //                 border: Border.all(
          //                   color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          //                 ),
          //                 boxShadow: [
          //                   BoxShadow(
          //                     color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          //                     blurRadius: 25,
          //                     offset: const Offset(0, 12),
          //                   ),
          //                 ],
          //               ),
          //               child: Row(
          //                 children: [
          //                   Expanded(
          //                     child: Column(
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: [
          //                         Row(
          //                           children: [
          //                             Text(
          //                               'Price',
          //                               style: TextStyle(
          //                                 fontSize: config['isMobile'] ? 14.0 : 18.0,
          //                                 fontWeight: FontWeight.w500,
          //                                 color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          //                               ),
          //                             ),
          //                             const SizedBox(width: 8),
          //                             Icon(
          //                               Icons.local_offer,
          //                               size: config['isMobile'] ? 14.0 : 18.0,
          //                               color: Theme.of(context).colorScheme.primary,
          //                             ),
          //                           ],
          //                         ),
          //                         const SizedBox(height: 6),
          //                         Row(
          //                           crossAxisAlignment: CrossAxisAlignment.end,
          //                           children: [
          //                             Flexible(
          //                               child: Text(
          //                                 '${widget.product.price.toStringAsFixed(2)} EGP',
          //                                 style: GoogleFonts.cairo(
          //                                   fontSize: config['priceSize'].toDouble(),
          //                                   fontWeight: FontWeight.w900,
          //                                   color: Theme.of(context).colorScheme.primary,
          //                                 ),
          //                                 overflow: TextOverflow.ellipsis,
          //                               ),
          //                             ),
          //                             const SizedBox(width: 12),
          //                             if (!config['isMobile'])
          //                               Text(
          //                                 (widget.product.price * 1.25).toStringAsFixed(2),
          //                                 style: TextStyle(
          //                                   fontSize: config['isMobile'] ? 14.0 : 20.0,
          //                                   decoration: TextDecoration.lineThrough,
          //                                   color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          //                                 ),
          //                               ),
          //                           ],
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                   Container(
          //                     padding: EdgeInsets.symmetric(
          //                         horizontal: config['isMobile'] ? 12.0 : 20.0,
          //                         vertical: config['isMobile'] ? 6.0 : 12.0
          //                     ),
          //                     decoration: BoxDecoration(
          //                       gradient: LinearGradient(
          //                         colors: [Colors.orange, Colors.deepOrange, Colors.red.shade400],
          //                       ),
          //                       borderRadius: BorderRadius.circular(16),
          //                       boxShadow: [
          //                         BoxShadow(
          //                           color: Colors.orange.withOpacity(0.4),
          //                           blurRadius: 15,
          //                           offset: const Offset(0, 6),
          //                         ),
          //                       ],
          //                     ),
          //                     child: Text(
          //                       '20% OFF',
          //                       style: GoogleFonts.cairo(
          //                         color: Colors.white,
          //                         fontWeight: FontWeight.bold,
          //                         fontSize: config['isMobile'] ? 12.0 : 16.0,
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         );
          //       },
          //     );
          //   },
          // ),

          // SizedBox(height: config['isMobile'] ? 24.0 : 36.0),

          // // Enhanced Quantity Selector
          // _buildAdvancedQuantitySelector(context, config).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2, curve: Curves.easeOutBack),

          SizedBox(height: config['isMobile'] ? 24.0 : 40.0),

          // Enhanced Description
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 40 * (1 - value)),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Container(
                    padding: EdgeInsets.all(config['isMobile'] ? 20.0 : 32.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: config['isMobile'] ? 20.0 : 26.0,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'وصف',
                              style: GoogleFonts.cairo(
                                fontSize: config['isMobile'] ? 18.0 : 26.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.product.description.isNotEmpty
                              ? widget.product.description
                              : "Premium quality product with excellent features and modern design. Perfect for everyday use with outstanding durability and performance.",
                          style: TextStyle(
                            fontSize: config['bodySize'].toDouble(),
                            height: 1.7,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: config['isMobile'] ? 24.0 : 40.0),

          // Enhanced Action Buttons
          _buildAdvancedActionButtons(context, config).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildAdvancedQuantitySelector(BuildContext context, Map<String, dynamic> config) {
    return Container(
      padding: EdgeInsets.all(config['isMobile'] ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.production_quantity_limits,
            color: Theme.of(context).colorScheme.primary,
            size: config['isMobile'] ? 18.0 : 22.0,
          ),
          const SizedBox(width: 12),
          Text(
            'Quantity',
            style: GoogleFonts.cairo(
              fontSize: config['isMobile'] ? 16.0 : 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    onTap: _quantity > 1 ? () {
                      setState(() => _quantity--);
                      HapticFeedback.selectionClick();
                    } : null,
                    child: Container(
                      padding: EdgeInsets.all(config['isMobile'] ? 8.0 : 12.0),
                      child: Icon(
                        Icons.remove,
                        color: _quantity > 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        size: config['isMobile'] ? 16.0 : 20.0,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: config['isMobile'] ? 16.0 : 20.0,
                      vertical: config['isMobile'] ? 8.0 : 12.0
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text(
                    '$_quantity',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: config['isMobile'] ? 16.0 : 18.0,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                    onTap: () {
                      setState(() => _quantity++);
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      padding: EdgeInsets.all(config['isMobile'] ? 8.0 : 12.0),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.primary,
                        size: config['isMobile'] ? 16.0 : 20.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSpecs(BuildContext context, Map<String, dynamic> config) {
    return Transform.translate(
      offset: Offset(0, _scrollOffset * -30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(config['isMobile'] ? 20.0 : 28.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.primary,
                      size: config['isMobile'] ? 20.0 : 24.0,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'تفاصيل',
                      style: GoogleFonts.cairo(
                        fontSize: config['isMobile'] ? 18.0 : 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSpecItem('Brand', 'Royal Brand', Icons.business, config),
                _buildSpecItem('خامه', widget.product.matrial, Icons.texture, config),
                _buildSpecItem('مقاس', widget.product.dimensions ?? 'مخصص', Icons.straighten, config),
                _buildSpecItem('الاعتمادية', 'الافضل', Icons.verified_user, config),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.3),

          const SizedBox(height: 24),

          // Enhanced Features
          Container(
            padding: EdgeInsets.all(config['isMobile'] ? 20.0 : 28.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: config['isMobile'] ? 20.0 : 24.0,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'الميزات',
                      style: GoogleFonts.cairo(
                        fontSize: config['isMobile'] ? 18.0 : 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFeatureItem('افضل خامات', Icons.diamond, config),
                _buildFeatureItem('شحن لجميع المحافظات', Icons.local_shipping, config),
                _buildFeatureItem('ثقه بين العملاء', Icons.security, config),
                _buildFeatureItem('24/7 Support', Icons.support_agent, config),
                //_buildFeatureItem('Gift Wrapping', Icons.card_giftcard, config),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value, IconData icon, Map<String, dynamic> config) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(config['isMobile'] ? 6.0 : 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: config['isMobile'] ? 16.0 : 20.0,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: config['isMobile'] ? 12.0 : 14.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: config['isMobile'] ? 14.0 : 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature, IconData icon, Map<String, dynamic> config) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(config['isMobile'] ? 4.0 : 6.0),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: config['isMobile'] ? 14.0 : 16.0,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: TextStyle(
              fontSize: config['isMobile'] ? 14.0 : 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedActionButtons(BuildContext context, Map<String, dynamic> config) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _launchWhatsApp(widget.product),
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: config['isMobile'] ? 16.0 : 20.0,
                  ),
                  label: Text(
                    'واتساب',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w600,
                      fontSize: config['isMobile'] ? 14.0 : 16.0,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: config['isMobile'] ? 14.0 : 18.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: OutlinedButton.icon(
              onPressed: () => context.go('/'),
              icon: Icon(
                Icons.arrow_back_rounded,
                size: config['isMobile'] ? 16.0 : 20.0,
              ),
              label: Text(
                'الرجوع للرئيسية',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w600,
                  fontSize: config['isMobile'] ? 14.0 : 16.0,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: config['isMobile'] ? 14.0 : 18.0),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveFAB(BuildContext context, Map<String, dynamic> config) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_floatingController.value * 2 * math.pi) * 4),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => _showQuickActions(context, config),
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: Icon(
                Icons.more_horiz,
                color: Colors.white,
                size: config['isMobile'] ? 18.0 : 20.0,
              ),
              label: Text(
                'Quick Actions',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: config['isMobile'] ? 12.0 : 14.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImageModal(BuildContext context, Map<String, dynamic> config) {
    if (widget.product.imageUrls.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(config['isMobile'] ? 10.0 : 20.0),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(widget.product.imageUrls[_selectedImageIndex]),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: config['isMobile'] ? 20.0 : 24.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdvancedShareBottomSheet(BuildContext context, Map<String, dynamic> config) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(config['isMobile'] ? 20.0 : 28.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.share,
                  color: Theme.of(context).colorScheme.primary,
                  size: config['isMobile'] ? 20.0 : 24.0,
                ),
                const SizedBox(width: 12),
                Text(
                  'Share Product',
                  style: GoogleFonts.cairo(
                    fontSize: config['isMobile'] ? 20.0 : 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: config['isMobile'] ? 2 : 3,
              shrinkWrap: true,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _buildAdvancedShareButton(
                  Icons.link,
                  'Copy Link',
                  Colors.blue,
                      () => _copyToClipboard(context),
                  config,
                ),
                _buildAdvancedShareButton(
                  Icons.email,
                  'Email',
                  Colors.red,
                      () => _shareViaEmail(),
                  config,
                ),
                _buildAdvancedShareButton(
                  Icons.message,
                  'SMS',
                  Colors.green,
                      () => _shareViaSMS(),
                  config,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedShareButton(IconData icon, String label, Color color, VoidCallback onTap, Map<String, dynamic> config) {
    return GestureDetector(
      onTap: () {
        onTap();
        Navigator.pop(context);
        HapticFeedback.lightImpact();
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(config['isMobile'] ? 16.0 : 20.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              color: color,
              size: config['isMobile'] ? 20.0 : 24.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: config['isMobile'] ? 12.0 : 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final productUrl = 'https://yourstore.com/product/${widget.product.id}';
    Clipboard.setData(ClipboardData(text: productUrl));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Product link copied to clipboard!',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareViaEmail() {
    final subject = Uri.encodeComponent('Check out this amazing product!');
    final body = Uri.encodeComponent(
        'I found this great product: ${widget.product.name}\n'
            'Price: \${widget.product.price}\n'
            'Check it out: https://yourstore.com/product/${widget.product.id}'
    );
    final emailUrl = 'mailto:?subject=$subject&body=$body';
    print('Email URL: $emailUrl');
    // In a real app, use url_launcher: launchUrl(Uri.parse(emailUrl));
  }

  void _shareViaSMS() {
    final message = Uri.encodeComponent(
        'Check out this product: ${widget.product.name} for \${widget.product.price}! '
            'https://yourstore.com/product/${widget.product.id}'
    );
    final smsUrl = 'sms:?body=$message';
    print('SMS URL: $smsUrl');
    // In a real app, use url_launcher: launchUrl(Uri.parse(smsUrl));
  }

  void _showAddToCartDialog(BuildContext context, Map<String, dynamic> config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: config['isMobile'] ? 20.0 : 24.0,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Added to Cart',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: config['isMobile'] ? 16.0 : 18.0,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '${widget.product.name} (Qty: $_quantity) has been added to your cart.',
          style: GoogleFonts.cairo(
            fontSize: config['isMobile'] ? 14.0 : 16.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue Shopping',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                fontSize: config['isMobile'] ? 12.0 : 14.0,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to cart
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'View Cart',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                fontSize: config['isMobile'] ? 12.0 : 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context, Map<String, dynamic> config) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(config['isMobile'] ? 20.0 : 28.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: config['isMobile'] ? 20.0 : 24.0,
                ),
                const SizedBox(width: 12),
                Text(
                  'Quick Actions',
                  style: GoogleFonts.cairo(
                    fontSize: config['isMobile'] ? 20.0 : 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(config['isMobile'] ? 6.0 : 8.0),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.compare_arrows,
                  color: Colors.orange,
                  size: config['isMobile'] ? 18.0 : 20.0,
                ),
              ),
              title: Text(
                'Compare Products',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w600,
                  fontSize: config['isMobile'] ? 14.0 : 16.0,
                ),
              ),
              subtitle: Text(
                'Compare with similar products',
                style: TextStyle(fontSize: config['isMobile'] ? 12.0 : 14.0),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _launchWhatsApp(Product product) {
    const phone = "+201505280117";
    final text = "مرحبًا، أنا مهتم بمنتج ${product.name}. هل يمكنني معرفة المزيد من التفاصيل؟";
    final url = "https://wa.me/$phone?text=${Uri.encodeComponent(text)}";
    print("WhatsApp URL: $url");
    // In a real app, you would use url_launcher package:
    launchUrl(Uri.parse(url));
  }
}