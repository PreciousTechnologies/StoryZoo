import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';
import 'core/services/mini_audio_player_controller.dart';
import 'shared/widgets/floating_mini_player.dart';

// Temporary local development flag to bypass login flow.
const bool kBypassLoginForDebug = false;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auth provider (restores token if present)
  final authProvider = await AuthProvider.create();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.backgroundLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<MiniAudioPlayerController>(
          create: (_) => MiniAudioPlayerController(),
        ),
      ],
      child: const StoryZooApp(),
    ),
  );
}

class StoryZooApp extends StatelessWidget {
  const StoryZooApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final initial = kBypassLoginForDebug
        ? AppRouter.home
        : (auth.isAuthenticated ? AppRouter.home : AppRouter.welcome);

    final preferredLanguage = auth.preferredLanguage;
    final appLocale = preferredLanguage == 'en' ? const Locale('en') : const Locale('sw');
    final preferredThemeMode = auth.preferredThemeMode;
    final appThemeMode = preferredThemeMode == 'dark'
      ? ThemeMode.dark
      : preferredThemeMode == 'light'
        ? ThemeMode.light
        : ThemeMode.system;

    return MaterialApp.router(
      title: 'Story Zoo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appThemeMode,
      locale: appLocale,
      supportedLocales: const [
        Locale('sw'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const FloatingMiniPlayer(),
          ],
        );
      },
      routerConfig: AppRouter.buildRouter(initialLocation: initial),
    );
  }
}
