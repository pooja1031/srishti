import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'elegant_line_animation.dart';

class ServicesSection extends StatefulWidget {
  const ServicesSection({super.key});

  @override
  State<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<ServicesSection> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 1000; // Start at a high number for infinite scroll
  bool _isHovering = false;

  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Bridal Makeup',
      'description':
          'Exquisite and long-lasting makeup tailored for your special day. We ensure you look flawless from every angle.',
      'icon': Icons.face_retouching_natural,
    },
    {
      'title': 'Pre-Wedding Shoots',
      'description':
          'Camera-ready looks perfect for your engagement and pre-wedding photography sessions.',
      'icon': Icons.camera_alt_outlined,
    },
    {
      'title': 'Party & Event Makeup',
      'description':
          'Glamorous looks for bridesmaids, family members, or any special occasion.',
      'icon': Icons.star_border,
    },
    {
      'title': 'Saree Draping',
      'description':
          'Professional saree draping in any traditional or modern style for a flawless silhouette.',
      'icon': Icons.checkroom,
    },
    {
      'title': 'Hair Styling',
      'description':
          'Elegant updos, beautiful curls, or sleek straight styles tailored to perfectly complement your look.',
      'icon': Icons.face_2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.3,
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isHovering && _pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate viewport fraction to keep cards a fixed, closer distance apart
    final screenWidth = MediaQuery.of(context).size.width;
    // 340px per page gives a 60px gap since cards are 280px wide
    final viewportFraction = (340.0 / screenWidth).clamp(0.2, 0.85);

    // Recreate controller if fraction changes significantly
    if (_pageController.hasClients &&
        (_pageController.viewportFraction - viewportFraction).abs() > 0.1) {
      final oldPage = _pageController.page?.round() ?? _currentPage;
      _pageController.dispose();
      _pageController = PageController(
        initialPage: oldPage,
        viewportFraction: viewportFraction,
      );
    }

    final isDesktop = screenWidth > 800;

    return Stack(
      children: [
        // Leaf shadow background (Top-Left)
        Positioned(
          top: 0,
          left: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.85,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).scaffoldBackgroundColor,
                  BlendMode.multiply,
                ),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: Image.asset(
                    'assets/images/shadow1111.jpg',
                    width: isDesktop ? 580 : 350,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Leaf shadow background (Bottom-Right)
        Positioned(
          bottom: 0,
          right: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.75,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).scaffoldBackgroundColor,
                  BlendMode.multiply,
                ),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: Transform.flip(
                    flipX: true,
                    flipY: true,
                    child: Image.asset(
                      'assets/images/shadow1111.jpg',
                      width: isDesktop ? 540 : 320,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 80),
          color: Colors.transparent,
          child: Column(
            children: [
          Text(
            'W H A T   W E   O F F E R',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 4,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'OUR SERVICES',
            style: TextStyle(
              fontSize: 42,
              fontFamily: 'Georgia',
              letterSpacing: 2,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.diamond,
                  size: 8,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                width: 40,
                height: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 60),
          MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: SizedBox(
              height: 420,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final serviceIndex = index % _services.length;
                  final service = _services[serviceIndex];

                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double currentScale = 0.85;
                      double currentOpacity = 0.5;

                      if (_pageController.position.haveDimensions) {
                        double page = _pageController.page!;
                        double difference = (page - index).abs();
                        currentScale = (1 - (difference * 0.15)).clamp(
                          0.85,
                          1.0,
                        );
                        currentOpacity = (1 - (difference * 0.5)).clamp(
                          0.5,
                          1.0,
                        );
                      } else {
                        double difference = (_currentPage - index)
                            .abs()
                            .toDouble();
                        currentScale = (1 - (difference * 0.15)).clamp(
                          0.85,
                          1.0,
                        );
                        currentOpacity = (1 - (difference * 0.5)).clamp(
                          0.5,
                          1.0,
                        );
                      }

                      return Center(
                        child: Opacity(
                          opacity: currentOpacity,
                          child: Transform.scale(
                            scale: currentScale,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: _ServiceCard(
                      title: service['title'],
                      description: service['description'],
                      icon: service['icon'],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),

          const ElegantLineAnimation(),
        ],
      ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 380,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF8), // Warm off-white
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 22,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 13,
                height: 1.8,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
