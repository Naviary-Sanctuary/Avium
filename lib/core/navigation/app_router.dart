import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/emergency/presentation/emergency_screen.dart';
import '../../features/feeding_guide/presentation/feeding_guide_screen.dart';
import '../../features/food_detail/presentation/food_detail_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final class AppRouter {
  const AppRouter._();

  static final GoRouter config = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const SearchScreen();
        },
      ),
      GoRoute(
        path: '/food/:id',
        name: 'food-detail',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? 'unknown';
          return FoodDetailScreen(foodId: id);
        },
      ),
      GoRoute(
        path: '/emergency',
        name: 'emergency',
        builder: (BuildContext context, GoRouterState state) {
          return EmergencyScreen(foodId: state.uri.queryParameters['foodId']);
        },
      ),
      GoRoute(
        path: '/guide',
        name: 'guide',
        builder: (BuildContext context, GoRouterState state) {
          return const FeedingGuideScreen();
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
    ],
  );
}
