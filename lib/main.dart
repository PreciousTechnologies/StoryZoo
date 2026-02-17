import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart' as firebase_options;
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebase_options.DefaultFirebaseOptions.currentPlatform);
  } else {
    await Firebase.initializeApp();
  }

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

  runApp(ChangeNotifierProvider<AuthProvider>.value(
    value: authProvider,
    child: const StoryZooApp(),
  ));
}

class StoryZooApp extends StatelessWidget {
  const StoryZooApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final initial = auth.isAuthenticated ? '/home' : AppRouter.welcome;

    return MaterialApp.router(
      title: 'Story Zoo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.buildRouter(initialLocation: initial),
    );
  }
}
