import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/storage_service.dart';
import 'providers/persona_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/persona_picker_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/forecast/forecast_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/locations/locations_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/assistant/assistant_screen.dart';
import 'screens/travel/travel_screen.dart';
import 'screens/analytics/analytics_screen.dart';

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------
final _storageService = StorageService();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final done = await _storageService.isOnboardingComplete();
      if (!done && state.matchedLocation == '/') return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/persona-picker',
        builder: (_, __) => const PersonaPickerScreen(),
      ),
      GoRoute(
        path: '/forecast',
        builder: (_, __) => const ForecastScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/locations',
        builder: (_, __) => const LocationsScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (_, __) => const WeatherMapScreen(),
      ),
      GoRoute(
        path: '/assistant',
        builder: (_, __) => const AssistantScreen(),
      ),
      GoRoute(
        path: '/travel',
        builder: (_, __) => const TravelScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (_, __) => const AnalyticsScreen(),
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Root App
// ---------------------------------------------------------------------------
class MausamApp extends ConsumerWidget {
  const MausamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Mausam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
