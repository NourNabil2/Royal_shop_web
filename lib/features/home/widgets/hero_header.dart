// Professional Hero Header with Parallax Effect
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/model/slide_data.dart';

class HeroHeader extends StatefulWidget {
  @override
  _HeroHeaderState createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<HeroHeader> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late PageController _pageController;

  int _currentSlide = 0;
  late Timer _timer;

  final List<SlideData> slides = [
    SlideData(
      title: 'كل اللي محتاجه براندك في مكان واحد',
      subtitle: 'كروت، بادجات، استيكرات وأكياس بجودة عالية تعكس هوية مصنعك أو مشروعك.',
      image: 'https://scontent.fcai20-6.fna.fbcdn.net/v/t39.30808-6/478412549_122262298922002114_5467925456366657800_n.jpg?_nc_cat=103&ccb=1-7&_nc_sid=cc71e4&_nc_eui2=AeEwGpm80DHgXerFNU_CgjH_2SVvH2_usf_ZJW8fb-6x_yvl09cQKZVKDRSvxCHisZ5njTlWc3GACVacAW7E01QS&_nc_ohc=dsZsz52u9MIQ7kNvwEXkAtU&_nc_oc=AdnVjwKMpjPWDLEsXHYRdsbG2-RUx-TpfiCTIGt51bOkvkv1qd1t1UVRynNBlF8XGns&_nc_zt=23&_nc_ht=scontent.fcai20-6.fna&_nc_gid=_Qim-ZGYKwRMW3ABw5jXdA&oh=00_AfYUS0HjjkE68c6JjJBI3EEZL2MiY-50n1g-vjhMTmVHvA&oe=68C3DA2C',
      buttonText: 'تسوق الآن',
    ),
    SlideData(
      title: 'طباعة احترافية ترفع قيمة منتجك',
      subtitle: 'من الكارت الصغير لحد التغليف الكامل، نوفرلك خامات ممتازة تسيب انطباع يدوم.',
      image: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=1200&h=600&fit=crop',
      buttonText: 'اطلب دلوقتي',
    ),
    SlideData(
      title: 'حلول متكاملة لمصانع الملابس والبراندات',
      subtitle: 'وفر وقتك وخلي كل مستلزماتك من مكان واحد: أكياس، كروت، بادجات، بوكسات واستيكرات.',
      image: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1200&h=600&fit=crop',
      buttonText: 'اكتشف المزيد',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentSlide < slides.length - 1) {
        _currentSlide++;
      } else {
        _currentSlide = 0;
      }
      _pageController.animateToPage(
        _currentSlide,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: Stack(
        children: [
          // Parallax PageView for background images
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double pageOffset = 0;
                  if (_pageController.position.haveDimensions) {
                    pageOffset = _pageController.page! - index;
                  }

                  return _buildParallaxSlide(slides[index], pageOffset);
                },
              );
            },
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Content with parallax text animation
          AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double pageOffset = 0;
              if (_pageController.position.haveDimensions) {
                pageOffset = _pageController.page! - _currentSlide;
              }

              // Parallax effect for text content
              double textParallax = pageOffset * 50;
              double opacityValue = 1.0 - pageOffset.abs().clamp(0.0, 1.0);

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(textParallax, 0),
                    child: Opacity(
                      opacity: opacityValue * _fadeAnimation.value,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.translate(
                                  offset: Offset(-textParallax * 0.3, 0),
                                  child: Text(
                                    slides[_currentSlide].title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Transform.translate(
                                  offset: Offset(-textParallax * 0.5, 0),
                                  child: Text(
                                    slides[_currentSlide].subtitle,
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Transform.translate(
                                  offset: Offset(-textParallax * 0.2, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Theme.of(context).colorScheme.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 8,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            slides[_currentSlide].buttonText,
                                            style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward_rounded),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Enhanced indicators with parallax effect
          AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double pageOffset = 0;
              if (_pageController.position.haveDimensions) {
                pageOffset = _pageController.page! - _currentSlide;
              }

              return Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(pageOffset * 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                          (index) {
                        double distance = (_currentSlide - index).abs().toDouble();
                        double scale = 1.0 - (distance * 0.3).clamp(0.0, 0.7);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentSlide == index ? 30 : 10,
                          height: 10,
                          transform: Matrix4.identity()..scale(scale),
                          decoration: BoxDecoration(
                            color: _currentSlide == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: _currentSlide == index
                                ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // Navigation arrows with enhanced styling
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: _previousSlide,
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: _nextSlide,
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParallaxSlide(SlideData slide, double pageOffset) {
    // Parallax calculations
    double imageParallax = pageOffset * 150; // Background moves slower
    double scaleValue = 1.0 + (pageOffset.abs() * 0.1); // Slight scale effect
    double opacityValue = 1.0 - pageOffset.abs().clamp(0.0, 0.8);

    // Gaussian curve for smooth transitions
    double gauss = math.exp(-(math.pow(pageOffset.abs(), 2) / 0.5));
    double blur = (1 - gauss) * 2;

    return Transform.scale(
      scale: scaleValue,
      child: Opacity(
        opacity: opacityValue,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(slide.image),
              fit: BoxFit.cover,
              alignment: Alignment(
                -pageOffset.clamp(-1.0, 1.0), // Parallax horizontal movement
                0,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1 + blur * 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _previousSlide() {
    if (_currentSlide > 0) {
      _currentSlide--;
    } else {
      _currentSlide = slides.length - 1;
    }
    _pageController.animateToPage(
      _currentSlide,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextSlide() {
    if (_currentSlide < slides.length - 1) {
      _currentSlide++;
    } else {
      _currentSlide = 0;
    }
    _pageController.animateToPage(
      _currentSlide,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }
}