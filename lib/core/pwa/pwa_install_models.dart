/// The web platform type used for PWA installation guidance.
enum PwaInstallPlatform {
  iosSafari,
  android,
  other,
}

/// Snapshot of current PWA installation capability.
class PwaInstallInfo {
  const PwaInstallInfo({
    required this.isWeb,
    required this.isMobileWeb,
    required this.isStandalone,
    required this.canPromptInstall,
    required this.platform,
  });

  final bool isWeb;
  final bool isMobileWeb;
  final bool isStandalone;
  final bool canPromptInstall;
  final PwaInstallPlatform platform;
}
