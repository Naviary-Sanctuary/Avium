// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'pwa_install_models.dart';

Object? _deferredPromptEvent;
bool _initialized = false;

void initializePwaInstallSupport() {
  if (_initialized) {
    return;
  }
  _initialized = true;

  html.window.addEventListener(
    'beforeinstallprompt',
    (html.Event event) {
      event.preventDefault();
      _deferredPromptEvent = event;
    },
  );

  html.window.addEventListener(
    'appinstalled',
    (html.Event _) {
      _deferredPromptEvent = null;
    },
  );
}

PwaInstallInfo getPwaInstallInfo() {
  initializePwaInstallSupport();

  final userAgent = html.window.navigator.userAgent.toLowerCase();
  final isIos = userAgent.contains('iphone') ||
      userAgent.contains('ipad') ||
      userAgent.contains('ipod');
  final isSafari = userAgent.contains('safari') &&
      !userAgent.contains('crios') &&
      !userAgent.contains('fxios') &&
      !userAgent.contains('edgios');
  final isAndroid = userAgent.contains('android');
  final isStandalone =
      html.window.matchMedia('(display-mode: standalone)').matches;

  final platform = isIos && isSafari
      ? PwaInstallPlatform.iosSafari
      : isAndroid
          ? PwaInstallPlatform.android
          : PwaInstallPlatform.other;

  return PwaInstallInfo(
    isWeb: true,
    isMobileWeb: isIos || isAndroid,
    isStandalone: isStandalone,
    canPromptInstall: _deferredPromptEvent != null,
    platform: platform,
  );
}

Future<bool> promptPwaInstall() async {
  initializePwaInstallSupport();
  final event = _deferredPromptEvent;
  if (event == null) {
    return false;
  }

  final dynamic deferredPrompt = event;
  await deferredPrompt.prompt();

  final dynamic userChoice = deferredPrompt.userChoice;
  _deferredPromptEvent = null;
  if (userChoice == null) {
    return false;
  }

  final dynamic choice = await userChoice;
  final outcome = choice?.outcome as String?;
  return outcome == 'accepted';
}
