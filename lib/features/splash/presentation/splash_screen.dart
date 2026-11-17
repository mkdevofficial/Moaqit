import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moaqit/core/theme/app_theme.dart';
import 'package:moaqit/core/widgets/islamic_star_painter.dart';
import 'package:moaqit/features/home/presentation/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _strokeController;
  late AnimationController _glowController;
  late AnimationController _textController;

  late Animation<double> _strokeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    _strokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _strokeAnimation = CurvedAnimation(
      parent: _strokeController,
      curve: Curves.easeInOutCubic,
    );

    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOutBack,
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // 1. Draw geometric star paths
    await _strokeController.forward();

    // 2. Bloom golden radial aura
    _glowController.forward();

    // 3. Staggered calligraphy reveal
    await _textController.forward();

    // Small atmospheric pause
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Seamless custom page route into Home dashboard
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          final scale = Tween<double>(begin: 0.94, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _strokeController.dispose();
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071419),
      body: Stack(
        children: [
          // Background celestial gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.15),
                  radius: 1.1,
                  colors: [
                    Color(0xFF0F3229),
                    Color(0xFF091C17),
                    Color(0xFF050E0C),
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Islamic Rub el Hizb & Golden Light Bloom
                Hero(
                  tag: 'app_emblem',
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_strokeAnimation, _glowAnimation]),
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(180, 180),
                        painter: IslamicRubElHizbPainter(
                          strokeProgress: _strokeAnimation.value,
                          glowProgress: _glowAnimation.value,
                          primaryColor: AppTheme.gold,
                          glowColor: AppTheme.goldLight,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 36),

                // Calligraphy title with staggered slide & fade
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'مَواقِيت',
                          style: GoogleFonts.amiri(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldLight,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: AppTheme.gold.withValues(alpha: 0.6),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'MAWAQIT PRAYER TIMES',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4.0,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'دقة الميقات وحسن الاتباع',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: AppTheme.gold.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom brand label
          Positioned(
            bottom: 34,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: Text(
                  '100% Offline Astronomical Precision',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Colors.white30,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
