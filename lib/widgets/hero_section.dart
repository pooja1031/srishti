import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/booking_page.dart';
import 'elegant_line_animation.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final List<String> _images = [
    'assets/images/hero_bg.jpeg',
    'assets/images/portfolio_1.jpeg',
    'assets/images/hero_3.jpeg',
    'assets/images/hero_4.jpeg',
    'assets/images/hero_5.jpeg',
    
  ];
  int _currentIndex = 0;
  Timer? _timer;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextIndex = (_currentIndex + 1) % _images.length;
        _pageController.animateToPage(
          nextIndex,
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
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Desktop: Split layout (Text Left, Image Right)
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Row(
                  children: [
                    Expanded(child: _buildTextContent(context)),
                    Expanded(child: _buildImageContent(context)),
                  ],
                ),
              );
            } else {
              // Mobile: Stacked layout (Image Top, Text Bottom)
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.infinity,
                    child: _buildImageContent(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: _buildTextContent(context),
                  ),
                ],
              );
            }
          },
        ),
        const ElegantLineAnimation(),
      ],
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 80, right: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Haute Couture Eyebrow
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 32, height: 1.5, color: const Color(0xFFC3A36E)),
              const SizedBox(width: 12),
              Text(
                'SRISHTI  •  SIGNATURE BRIDAL',
                style: GoogleFonts.montserrat(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4.0,
                  color: const Color(0xFF8C7355),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Unveiling Your',
            style: GoogleFonts.playfairDisplay(
              color: Theme.of(context).colorScheme.secondary,
              fontStyle: FontStyle.italic,
              fontSize: 34,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),
          Text(
            'MOST RADIANT\nSELF',
            style: GoogleFonts.playfairDisplay(
              color: Theme.of(context).colorScheme.secondary,
              letterSpacing: 4.0,
              fontSize: 50,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 18),
          Text(
            'Bespoke bridal styling & couture hair & makeup artistry tailored to illuminate your timeless beauty.',
            style: GoogleFonts.montserrat(
              fontSize: 14.5,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF555555),
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 36),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookingPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C2420),
              foregroundColor: const Color(0xFFF9F6F0),
              elevation: 4,
              shadowColor: Colors.black26,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BOOK A CONSULTATION',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_outlined,
                  size: 16,
                  color: Color(0xFFC3A36E),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Container(
          height: 600,
          width: 450,
          margin: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(250),
              topRight: Radius.circular(250),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(250),
              topRight: Radius.circular(250),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      _images[index],
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      filterQuality: FilterQuality.high,
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_images.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
