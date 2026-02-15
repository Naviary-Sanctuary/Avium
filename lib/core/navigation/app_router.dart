import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/emergency/presentation/emergency_screen.dart';
import '../../features/feeding_guide/presentation/feeding_guide_screen.dart';
import '../../features/food_detail/presentation/food_detail_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final class AppRouter {
  const AppRouter._();

  static GoRouter create() {
    return GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _buildPage(state: state, child: const SearchScreen());
          },
        ),
        GoRoute(
          path: '/food/:id',
          name: 'food-detail',
          pageBuilder: (BuildContext context, GoRouterState state) {
            final id = state.pathParameters['id'] ?? 'unknown';
            return _buildPage(
              state: state,
              child: FoodDetailScreen(foodId: id),
            );
          },
        ),
        GoRoute(
          path: '/emergency',
          name: 'emergency',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _buildPage(
              state: state,
              child:
                  EmergencyScreen(foodId: state.uri.queryParameters['foodId']),
            );
          },
        ),
        GoRoute(
          path: '/guide',
          name: 'guide',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _buildPage(state: state, child: const FeedingGuideScreen());
          },
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _buildPage(state: state, child: const SettingsScreen());
          },
        ),
      ],
    );
  }

  static Page<void> _buildPage({
    required GoRouterState state,
    required Widget child,
  }) {
    if (kIsWeb) {
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: child,
      );
    }

    return MaterialPage<void>(
      key: state.pageKey,
      child: child,
    );
  }
}
