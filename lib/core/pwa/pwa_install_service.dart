import 'pwa_install_models.dart';
import 'pwa_install_service_stub.dart'
    if (dart.library.html) 'pwa_install_service_web.dart' as impl;
export 'pwa_install_models.dart';

/// Sets up listeners for PWA install events on web.
void initializePwaInstallSupport() => impl.initializePwaInstallSupport();

/// Returns current install capability and platform information.
PwaInstallInfo getPwaInstallInfo() => impl.getPwaInstallInfo();

/// Triggers browser install prompt when available.
Future<bool> promptPwaInstall() => impl.promptPwaInstall();
