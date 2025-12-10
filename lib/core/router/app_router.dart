import 'package:go_router/go_router.dart';
import 'package:tekno_mistik/core/widgets/placeholder_screen.dart';
import 'package:tekno_mistik/features/onboarding/presentation/onboarding_screen.dart';
import 'package:tekno_mistik/features/dashboard/presentation/dashboard_screen.dart';

/// Application Router Configuration
/// Routes will be defined here as features are implemented
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const PlaceholderScreen(
        title: 'Kimlik Doğrulama',
        message: 'Auth ekranı yakında...',
      ),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/reflection',
      name: 'reflection',
      builder: (context, state) => const PlaceholderScreen(
        title: 'Yansıma',
        message: 'Reflection ekranı yakında...',
      ),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const PlaceholderScreen(
        title: 'Profil',
        message: 'Profile ekranı yakında...',
      ),
    ),
  ],
);

