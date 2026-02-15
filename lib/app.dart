import 'package:flutter/material.dart';

import 'core/navigation/app_router.dart';
import 'core/pwa/pwa_install_service.dart';
import 'core/state/app_state.dart';
import 'core/state/app_state_scope.dart';
import 'core/theme/app_theme.dart';

class AviumApp extends StatefulWidget {
  const AviumApp({super.key});

  @override
  State<AviumApp> createState() => _AviumAppState();
}

class _AviumAppState extends State<AviumApp> {
  late final AppState _appState;
  late final router = AppRouter.create();

  @override
  void initState() {
    super.initState();
    initializePwaInstallSupport();
    _appState = AppState()..initialize();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: _appState,
      child: MaterialApp.router(
        title: 'Avium',
        themeMode: ThemeMode.system,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
