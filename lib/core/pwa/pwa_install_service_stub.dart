import 'pwa_install_models.dart';

void initializePwaInstallSupport() {}

PwaInstallInfo getPwaInstallInfo() {
  return const PwaInstallInfo(
    isWeb: false,
    isMobileWeb: false,
    isStandalone: false,
    canPromptInstall: false,
    platform: PwaInstallPlatform.other,
  );
}

Future<bool> promptPwaInstall() async => false;
