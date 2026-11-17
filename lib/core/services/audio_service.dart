import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moaqit/core/constants/app_constants.dart';
import 'package:moaqit/core/services/storage_service.dart';

enum AdhanStyle {
  calm,
  mujawwad,
  clear,
  shortTakbir,
}

extension AdhanStyleExtension on AdhanStyle {
  String get assetPath {
    switch (this) {
      case AdhanStyle.calm:
        return AppConstants.adhanCalmPath;
      case AdhanStyle.mujawwad:
        return AppConstants.adhanMujawwadPath;
      case AdhanStyle.clear:
        return AppConstants.adhanClearPath;
      case AdhanStyle.shortTakbir:
        return AppConstants.adhanTakbirShortPath;
    }
  }

  String get titleAr {
    switch (this) {
      case AdhanStyle.calm:
        return 'هادئ وسكينة';
      case AdhanStyle.mujawwad:
        return 'مجود ومقامي';
      case AdhanStyle.clear:
        return 'واضح ومرتفع';
      case AdhanStyle.shortTakbir:
        return 'تنبيه مختصر';
    }
  }

  String get titleEn {
    switch (this) {
      case AdhanStyle.calm:
        return 'Calm & Serene';
      case AdhanStyle.mujawwad:
        return 'Melodious / Mujawwad';
      case AdhanStyle.clear:
        return 'Clear & High Volume';
      case AdhanStyle.shortTakbir:
        return 'Short Takbir';
    }
  }

  String get subtitleAr {
    switch (this) {
      case AdhanStyle.calm:
        return 'نغمات سكينة هادئة ملائمة للفجر والبيئات الساكنة';
      case AdhanStyle.mujawwad:
        return 'أداء مقامي حجازي عريق بنبرات الحرمين والقدس';
      case AdhanStyle.clear:
        return 'صوت جهوري نقي ذو استجابة قوية للبيئات الصاخبة';
      case AdhanStyle.shortTakbir:
        return 'تكبيرتان فقط مع نغمة هادئة لعدم الإزعاج';
    }
  }

  String get subtitleEn {
    switch (this) {
      case AdhanStyle.calm:
        return 'Tranquil harmonic recitation for Fajr and quiet rooms';
      case AdhanStyle.mujawwad:
        return 'Classic Maqam Hijaz style inspired by Makkah & Al-Aqsa';
      case AdhanStyle.clear:
        return 'Crisp acoustic projection designed for busy environments';
      case AdhanStyle.shortTakbir:
        return 'Short two-beat Takbir alert for discreet notifications';
    }
  }
}

class AudioEngineState {
  final bool isPlaying;
  final AdhanStyle? activePreviewStyle;
  final double volume;
  final bool fadeInEnabled;
  final Map<String, AdhanStyle> prayerStyles; // e.g. 'fajr': AdhanStyle.calm

  const AudioEngineState({
    this.isPlaying = false,
    this.activePreviewStyle,
    this.volume = 0.85,
    this.fadeInEnabled = true,
    this.prayerStyles = const {
      'fajr': AdhanStyle.calm,
      'dhuhr': AdhanStyle.mujawwad,
      'asr': AdhanStyle.clear,
      'maghrib': AdhanStyle.mujawwad,
      'isha': AdhanStyle.clear,
    },
  });

  AudioEngineState copyWith({
    bool? isPlaying,
    AdhanStyle? Function()? activePreviewStyle,
    double? volume,
    bool? fadeInEnabled,
    Map<String, AdhanStyle>? prayerStyles,
  }) {
    return AudioEngineState(
      isPlaying: isPlaying ?? this.isPlaying,
      activePreviewStyle: activePreviewStyle != null
          ? activePreviewStyle()
          : this.activePreviewStyle,
      volume: volume ?? this.volume,
      fadeInEnabled: fadeInEnabled ?? this.fadeInEnabled,
      prayerStyles: prayerStyles ?? this.prayerStyles,
    );
  }
}

final audioEngineProvider =
    NotifierProvider<AudioEngineNotifier, AudioEngineState>(() {
  return AudioEngineNotifier();
});

class AudioEngineNotifier extends Notifier<AudioEngineState> {
  AudioPlayer? _player;
  Timer? _equalizerTimer;
  final _amplitudeController = StreamController<List<double>>.broadcast();

  Stream<List<double>> get amplitudeStream => _amplitudeController.stream;

  @override
  AudioEngineState build() {
    final storage = ref.watch(storageServiceProvider);
    final volume = storage.getDouble('adhan_volume') ?? 0.85;
    final fadeIn = storage.getBool('adhan_fade_in') ?? true;

    _initPlayer();

    ref.onDispose(() {
      _equalizerTimer?.cancel();
      _amplitudeController.close();
      _player?.dispose();
    });

    return AudioEngineState(
      volume: volume,
      fadeInEnabled: fadeIn,
    );
  }

  void _initPlayer() {
    _player = AudioPlayer();
    _player!.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing &&
          playerState.processingState != ProcessingState.completed;
      if (!isPlaying && state.isPlaying) {
        state = state.copyWith(
          isPlaying: false,
          activePreviewStyle: () => null,
        );
        _stopEqualizerSimulation();
      }
    });
  }

  void _startEqualizerSimulation() {
    _equalizerTimer?.cancel();
    final random = Random();
    _equalizerTimer =
        Timer.periodic(const Duration(milliseconds: 90), (_) {
      if (!state.isPlaying) return;
      // 12 dynamic visualizer frequency bars
      final bars = List.generate(12, (index) {
        final base = sin((index / 12) * pi) * 0.5 + 0.3;
        final jitter = (random.nextDouble() - 0.5) * 0.4;
        return (base + jitter).clamp(0.08, 1.0);
      });
      _amplitudeController.add(bars);
    });
  }

  void _stopEqualizerSimulation() {
    _equalizerTimer?.cancel();
    _amplitudeController.add(List.filled(12, 0.08));
  }

  Future<void> previewStyle(AdhanStyle style) async {
    if (_player == null) return;

    if (state.isPlaying && state.activePreviewStyle == style) {
      await stop();
      return;
    }

    try {
      await _player!.stop();
      await _player!.setAsset(style.assetPath);
      await _player!.setVolume(state.volume);

      state = state.copyWith(
        isPlaying: true,
        activePreviewStyle: () => style,
      );
      _startEqualizerSimulation();

      if (state.fadeInEnabled) {
        await _player!.setVolume(0.0);
        await _player!.play();
        _fadeInVolume(state.volume);
      } else {
        await _player!.setVolume(state.volume);
        await _player!.play();
      }
    } catch (_) {
      state = state.copyWith(
        isPlaying: false,
        activePreviewStyle: () => null,
      );
      _stopEqualizerSimulation();
    }
  }

  void _fadeInVolume(double targetVolume) {
    const steps = 10;
    const interval = Duration(milliseconds: 100);
    double stepVal = targetVolume / steps;
    int currentStep = 1;

    Timer.periodic(interval, (timer) {
      if (!state.isPlaying || currentStep > steps) {
        timer.cancel();
        return;
      }
      _player?.setVolume(stepVal * currentStep);
      currentStep++;
    });
  }

  Future<void> stop() async {
    await _player?.stop();
    state = state.copyWith(
      isPlaying: false,
      activePreviewStyle: () => null,
    );
    _stopEqualizerSimulation();
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await _player?.setVolume(volume);
    final storage = ref.read(storageServiceProvider);
    await storage.setDouble('adhan_volume', volume);
  }

  Future<void> toggleFadeIn(bool enabled) async {
    state = state.copyWith(fadeInEnabled: enabled);
    final storage = ref.read(storageServiceProvider);
    await storage.setBool('adhan_fade_in', enabled);
  }

  Future<void> setPrayerStyle(String prayerKey, AdhanStyle style) async {
    final updated = Map<String, AdhanStyle>.from(state.prayerStyles);
    updated[prayerKey] = style;
    state = state.copyWith(prayerStyles: updated);
    final storage = ref.read(storageServiceProvider);
    await storage.setString('adhan_style_$prayerKey', style.name);
  }
}
