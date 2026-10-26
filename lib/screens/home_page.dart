import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/services_section.dart';
import '../widgets/portfolio_section.dart';
import '../widgets/footer_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _portfolioKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Decorative Shadow Overlay (Top Left)
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
                  child: Image.asset(
                    'assets/images/shadow1111.jpg',
                    width: MediaQuery.of(context).size.width > 800 ? 540 : 320,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          
          // Main Content
          Column(
            children: [
              NavBar(
                onHomeTap: () => _scrollTo(_homeKey),
                onServicesTap: () => _scrollTo(_servicesKey),
                onPortfolioTap: () => _scrollTo(_portfolioKey),
                onContactTap: () => _scrollTo(_contactKey),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      HeroSection(key: _homeKey),
                      ServicesSection(key: _servicesKey),
                      PortfolioSection(key: _portfolioKey),
                      FooterSection(key: _contactKey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
