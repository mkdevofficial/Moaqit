import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode {
  emeraldNight,
  midnightSapphire,
  velvetBlack,
}

class AppTheme {
  // Brand & Accent Colors
  static const Color gold = Color(0xFFE5A93C);
  static const Color goldLight = Color(0xFFFFD166);
  static const Color goldDark = Color(0xFFB07D1E);
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF065F46);
  static const Color sapphire = Color(0xFF3B82F6);
  static const Color sunset = Color(0xFFF97316);
  static const Color twilight = Color(0xFF8B5CF6);

  // Background Palettes
  static const Color bgEmerald = Color(0xFF071B16);
  static const Color surfaceEmerald = Color(0xFF0F2E26);
  static const Color cardEmerald = Color(0xFF143D33);

  static const Color bgSapphire = Color(0xFF0A1325);
  static const Color surfaceSapphire = Color(0xFF11203B);
  static const Color cardSapphire = Color(0xFF182C4F);

  static const Color bgVelvet = Color(0xFF0A0C10);
  static const Color surfaceVelvet = Color(0xFF14171F);
  static const Color cardVelvet = Color(0xFF1D222E);

  static ThemeData getTheme(AppThemeMode mode) {
    Color bg;
    Color surface;
    Color card;
    Color primary = gold;

    switch (mode) {
      case AppThemeMode.emeraldNight:
        bg = bgEmerald;
        surface = surfaceEmerald;
        card = cardEmerald;
        break;
      case AppThemeMode.midnightSapphire:
        bg = bgSapphire;
        surface = surfaceSapphire;
        card = cardSapphire;
        break;
      case AppThemeMode.velvetBlack:
        bg = bgVelvet;
        surface = surfaceVelvet;
        card = cardVelvet;
        break;
    }

    final textTheme = GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: emerald,
        surface: surface,
        error: const Color(0xFFEF4444),
        onPrimary: Colors.black,
        onSurface: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: card.withValues(alpha: 0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.amiri(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: goldLight,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: Colors.white.withValues(alpha: 0.9),
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: gold,
        unselectedItemColor: Colors.white54,
      ),
    );
  }
}
