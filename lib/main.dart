import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/supabase_constants.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase initialization error (likely invalid placeholder keys): $e');
  }

  runApp(const BridalStudioApp());
}

class BridalStudioApp extends StatelessWidget {
  const BridalStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Srishti Bridal Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFDBD4C9), // Beige/Taupe
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF2D8D5), // Soft blush pink
          primary: const Color(0xFFC3A36E), // Darker Champagne/Gold
          secondary: const Color(0xFF333333), // Dark Charcoal
          surface: const Color(0xFFFFFFFF),
        ),
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)
            .copyWith(
              displayLarge: GoogleFonts.playfairDisplay(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w600,
              ),
              displayMedium: GoogleFonts.playfairDisplay(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w600,
              ),
              headlineLarge: GoogleFonts.playfairDisplay(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.bold,
              ),
              headlineMedium: GoogleFonts.playfairDisplay(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w500,
              ),
              titleLarge: GoogleFonts.playfairDisplay(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w600,
              ),
              bodyLarge: GoogleFonts.montserrat(
                color: const Color(0xFF555555),
                fontSize: 16,
                height: 1.6,
              ),
              bodyMedium: GoogleFonts.montserrat(
                color: const Color(0xFF555555),
                fontSize: 14,
                height: 1.5,
              ),
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF333333),
            foregroundColor: const Color(0xFFFAF9F6),
            textStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0), // Sharp, classy edges
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF333333),
            textStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
