import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/saved/saved_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/my_purchases_screen.dart';
import '../../features/profile/history_screen.dart';
import '../../features/profile/payments_screen.dart';
import '../../features/profile/notifications_screen.dart';
import '../../features/profile/language_screen.dart';
import '../../features/profile/theme_screen.dart';
import '../../features/profile/help_screen.dart';
import '../../features/profile/about_screen.dart';
import '../../features/story_details/story_details_screen.dart';
import '../../features/audio_player/audio_player_screen.dart';
import '../../features/ebook_reader/ebook_reader_screen.dart';
import '../../features/author_dashboard/author_dashboard_screen.dart';
import '../../features/author_onboarding/author_onboarding_screen.dart';
import '../../features/upload_book/upload_book_screen.dart';
import '../../features/child_ui/child_ui_screen.dart';
import '../../features/auth/login_email_screen.dart';
import '../../features/auth/verify_otp_screen.dart';
import '../../models/story.dart';

class AppRouter {
  static const String welcome = '/';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String saved = '/saved';
  static const String profile = '/profile';
  static const String myPurchases = '/my-purchases';
  static const String history = '/history';
  static const String payments = '/payments';
  static const String notifications = '/notifications';
  static const String language = '/language';
  static const String theme = '/theme';
  static const String help = '/help';
  static const String about = '/about';
  static const String storyDetails = '/story/:id';
  static const String audioPlayer = '/audio-player/:id';
  static const String ebookReader = '/ebook-reader/:id';
  static const String authorDashboard = '/author-dashboard';
  static const String authorOnboarding = '/author-onboarding';
  static const String uploadBook = '/upload-book';
  static const String childUI = '/child-ui';
  static const String login = '/login';
  static const String verifyOtp = '/verify-otp';

  static GoRouter buildRouter({String initialLocation = welcome}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
      // Auth routes
      GoRoute(
        path: login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginEmailScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          ),
        ),
      GoRoute(
        path: verifyOtp,
        name: 'verifyOtp',
        pageBuilder: (context, state) {
          final phone = state.extra is String ? state.extra as String : null;
          return CustomTransitionPage(
            key: state.pageKey,
            child: VerifyOtpScreen(phone: phone),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: welcome,
        name: 'welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: explore,
        name: 'explore',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ExploreScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: saved,
        name: 'saved',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SavedScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: storyDetails,
        name: 'storyDetails',
        pageBuilder: (context, state) {
          final story = _storyFromState(state);
          return CustomTransitionPage(
            key: state.pageKey,
            child: StoryDetailsScreen(story: story),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: audioPlayer,
        name: 'audioPlayer',
        pageBuilder: (context, state) {
          final story = _storyFromState(state);
          return CustomTransitionPage(
            key: state.pageKey,
            child: AudioPlayerScreen(story: story),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: ebookReader,
        name: 'ebookReader',
        pageBuilder: (context, state) {
          final story = _storyFromState(state);
          return CustomTransitionPage(
            key: state.pageKey,
            child: EbookReaderScreen(story: story),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: authorDashboard,
        name: 'authorDashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AuthorDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: authorOnboarding,
        name: 'authorOnboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AuthorOnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: uploadBook,
        name: 'uploadBook',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const UploadBookScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: childUI,
        name: 'childUI',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ChildUIScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.1, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: myPurchases,
        name: 'myPurchases',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MyPurchasesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: history,
        name: 'history',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HistoryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: payments,
        name: 'payments',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PaymentsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: notifications,
        name: 'notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: language,
        name: 'language',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LanguageScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: theme,
        name: 'theme',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ThemeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: help,
        name: 'help',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HelpScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: about,
        name: 'about',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AboutScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
    );
  }

  static Story _storyFromState(GoRouterState state) {
    final extra = state.extra;
    if (extra is Story) return extra;

    final id = state.pathParameters['id'] ?? 'unknown';
    return Story(
      id: id,
      title: 'Hadithi',
      description: 'Maelezo ya hadithi hayapatikani kwa sasa.',
      author: 'Story Zoo',
      authorId: 'unknown',
      category: 'General',
      coverImage: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&q=80',
      price: 0,
      rating: 0,
      totalReviews: 0,
      isPurchased: false,
      hasAudio: false,
      publishedDate: DateTime.now(),
    );
  }
}
