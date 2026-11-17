import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moaqit/core/theme/app_theme.dart';
import 'package:moaqit/core/services/audio_service.dart';
import 'package:moaqit/core/services/notification_service.dart';
import 'package:moaqit/core/localization/app_localizations.dart';
import 'package:moaqit/core/widgets/audio_visualizer.dart';

class AdhanScreen extends ConsumerWidget {
  const AdhanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final audioEngine = ref.watch(audioEngineProvider);
    final audioNotifier = ref.read(audioEngineProvider.notifier);

    final categories = [
      AdhanStyle.calm,
      AdhanStyle.mujawwad,
      AdhanStyle.clear,
      AdhanStyle.shortTakbir,
    ];

    final prayers = [
      {'key': 'fajr', 'name': loc.translate('fajr')},
      {'key': 'dhuhr', 'name': loc.translate('dhuhr')},
      {'key': 'asr', 'name': loc.translate('asr')},
      {'key': 'maghrib', 'name': loc.translate('maghrib')},
      {'key': 'isha', 'name': loc.translate('isha')},
    ];

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Screen Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: AppTheme.gold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('adhanStudio'),
                        style: GoogleFonts.amiri(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldLight,
                        ),
                      ),
                      Text(
                        isArabic
                            ? 'تخصيص نغمات الأذان والتنبيهات لكل صلاة'
                            : 'Customize Adhan styles and audio levels per prayer',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Live Equalizer Visualizer & Active Preview Box
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF13202E),
                    Color(0xFF0F1822),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: audioEngine.isPlaying
                      ? AppTheme.gold.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    audioEngine.isPlaying
                        ? '${loc.isArabic ? "جارٍ معاينة:" : "Now Previewing:"} ${isArabic ? audioEngine.activePreviewStyle?.titleAr : audioEngine.activePreviewStyle?.titleEn}'
                        : (loc.isArabic
                            ? 'اضغط على أي فئة للاستماع للمعاينة'
                            : 'Tap any category below to preview sound'),
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: audioEngine.isPlaying
                          ? AppTheme.goldLight
                          : Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // StreamBuilder for real-time equalizer bars
                  StreamBuilder<List<double>>(
                    stream: audioNotifier.amplitudeStream,
                    initialData: List.filled(12, 0.1),
                    builder: (context, snapshot) {
                      return AudioVisualizerWidget(
                        amplitudes: snapshot.data ?? List.filled(12, 0.1),
                        isPlaying: audioEngine.isPlaying,
                        height: 52,
                        primaryColor: AppTheme.gold,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Stop Button if playing
                  if (audioEngine.isPlaying)
                    ElevatedButton.icon(
                      onPressed: () => audioNotifier.stop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.2),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                              color: Colors.redAccent, width: 0.8),
                        ),
                      ),
                      icon: const Icon(Icons.stop_rounded, size: 20),
                      label: Text(
                        isArabic ? 'إيقاف المعاينة' : 'Stop Preview',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 4 Distinct Adhan Categories Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                isArabic ? 'أنماط وفئات الأذان' : 'Adhan Sound Categories',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 4 Category Cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final style = categories[index];
                final isCurrentPlaying = audioEngine.isPlaying &&
                    audioEngine.activePreviewStyle == style;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCurrentPlaying
                        ? AppTheme.gold.withValues(alpha: 0.12)
                        : const Color(0xFF111C24).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCurrentPlaying
                          ? AppTheme.gold.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Play / Pause Circle Button
                      GestureDetector(
                        onTap: () => audioNotifier.previewStyle(style),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrentPlaying
                                ? AppTheme.gold
                                : Colors.white.withValues(alpha: 0.08),
                            border: Border.all(
                              color: isCurrentPlaying
                                  ? AppTheme.goldLight
                                  : Colors.white24,
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            isCurrentPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: isCurrentPlaying
                                ? Colors.black
                                : Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title & Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? style.titleAr : style.titleEn,
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isCurrentPlaying
                                    ? AppTheme.goldLight
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isArabic ? style.subtitleAr : style.subtitleEn,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.white60,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: categories.length,
            ),
          ),

          // Per-Prayer Style Assignment Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                isArabic
                    ? 'تخصيص الأذان لكل صلاة على حدة'
                    : 'Assign Adhan Per Prayer',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Prayer Dropdown Selector Items
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final p = prayers[index];
                final pKey = p['key'] as String;
                final pName = p['name'] as String;
                final currentStyle =
                    audioEngine.prayerStyles[pKey] ?? AdhanStyle.mujawwad;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101920).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pName,
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      DropdownButton<AdhanStyle>(
                        value: currentStyle,
                        dropdownColor: const Color(0xFF14202B),
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: AppTheme.gold),
                        items: categories.map((style) {
                          return DropdownMenuItem<AdhanStyle>(
                            value: style,
                            child: Text(
                              isArabic ? style.titleAr : style.titleEn,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: AppTheme.goldLight,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newStyle) {
                          if (newStyle != null) {
                            audioNotifier.setPrayerStyle(pKey, newStyle);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
              childCount: prayers.length,
            ),
          ),

          // Audio Engine Controls (Volume & Fade-in)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF101920).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic
                        ? 'إعدادات تشغيل الأذان'
                        : 'Audio Engine Properties',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Volume Slider
                  Row(
                    children: [
                      const Icon(Icons.volume_down_rounded,
                          color: Colors.white54, size: 20),
                      Expanded(
                        child: Slider(
                          value: audioEngine.volume,
                          min: 0.1,
                          max: 1.0,
                          activeColor: AppTheme.gold,
                          inactiveColor: Colors.white24,
                          onChanged: (val) => audioNotifier.setVolume(val),
                        ),
                      ),
                      const Icon(Icons.volume_up_rounded,
                          color: AppTheme.gold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${(audioEngine.volume * 100).toInt()}%',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Fade-in Toggle Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppTheme.gold,
                    activeTrackColor: AppTheme.gold.withValues(alpha: 0.3),
                    title: Text(
                      loc.translate('fadeIn'),
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      isArabic
                          ? 'يبدأ الأذان بنبرة هادئة ثم يرتفع تدريجياً لعدم الإفزاع'
                          : 'Ramps up volume smoothly during the first 3 seconds',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    value: audioEngine.fadeInEnabled,
                    onChanged: (val) => audioNotifier.toggleFadeIn(val),
                  ),

                  const Divider(color: Colors.white12, height: 24),

                  // Test Instant Background Notification Button
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(notificationServiceProvider)
                          .showInstantTestNotification(
                            title: isArabic
                                ? 'تجربة إشعار الأذان الفوري'
                                : 'Test Instant Adhan Alert',
                            body: isArabic
                                ? 'الله أكبر .. الله أكبر (حي على الصلاة)'
                                : 'Allahu Akbar (Come to prayer)',
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic
                                ? 'تم إرسال إشعار تجريبي في شريط التنبيهات'
                                : 'Test notification sent successfully',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: AppTheme.emeraldDark,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.notifications_active_outlined,
                        size: 20),
                    label: Text(
                      isArabic
                          ? 'إرسال إشعار تجريبي لاختبار التنبيه'
                          : 'Send Test Notification to System Bar',
                      style: GoogleFonts.cairo(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }
}
