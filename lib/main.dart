import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sound_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/timer_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'services/ad_service.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage Service
  final storageService = await StorageService.init();

  // Initialize Audio & Notification Services
  final audioService = AudioService();
  final notificationService = NotificationService();
  await notificationService.init();

  // Initialize Google Mobile Ads SDK asynchronously
  AdService.instance.init();

  runApp(
    FocusFlowApp(
      storageService: storageService,
      audioService: audioService,
      notificationService: notificationService,
    ),
  );
}

class FocusFlowApp extends StatelessWidget {
  final StorageService storageService;
  final AudioService audioService;
  final NotificationService notificationService;

  const FocusFlowApp({
    super.key,
    required this.storageService,
    required this.audioService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => StatsProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SoundProvider(audioService, storageService),
        ),
        ChangeNotifierProxyProvider2<SettingsProvider, StatsProvider, TimerProvider>(
          create: (context) => TimerProvider(
            notificationService,
            audioService,
            context.read<SettingsProvider>(),
            context.read<StatsProvider>(),
          ),
          update: (context, settings, stats, timer) {
            timer!.updateDependencies(settings, stats);
            return timer;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'FocusFlow: Minimal Pomodoro & White Noise',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
