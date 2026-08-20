import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/repositories/singletons/storage.dart';
import 'package:mentour_web_view/services/js_communication/js_security_service.dart';
import 'package:mentour_web_view/ui_kit/widgets/dialogs/freeze_dialog.dart';
import 'package:no_screenshot/no_screenshot.dart';

/// Mixin that handles exam freeze behavior when the app goes to background.
///
/// ## How freeze is triggered
///
/// | AppLifecycleState | [inactiveTriggersFreeze]=true | [inactiveTriggersFreeze]=false |
/// |-------------------|-------------------------------|--------------------------------|
/// | inactive          | Freeze after 300 ms           | **No freeze** (screenshots safe) |
/// | paused            | Freeze immediately            | Freeze immediately             |
///
/// Setting [inactiveTriggersFreeze] to `false` on a screen means:
/// - Screenshot → app briefly goes `inactive` then back to `resumed` → **no freeze**
/// - Home button / app switch → app goes `inactive` then `paused` → **freeze**
/// - Notification shade (stays inactive, never `paused`) → **no freeze**
///   (acceptable for navigation/overview screens)
///
/// ## Usage
/// 1. Add `with WidgetsBindingObserver, ExamFreezeObserver` to your State.
/// 2. Override [freezeEnabled], [freezeTimerSeconds], [freezeIdentifier].
/// 3. Override [inactiveTriggersFreeze] to `false` if screenshots must not freeze.
/// 4. Optionally override [noScreenshot] to block OS-level screenshots.
/// 5. Call [initFreezeObserver] in `initState`.
/// 6. Call [disposeFreezeObserver] in `dispose`.
/// 7. Implement [onFreezeExpired].
mixin ExamFreezeObserver<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  bool _freezeDialogShown = false;
  bool _freezeSuppressed = false;
  final NoScreenshot _noScreenshot = NoScreenshot.instance;
  Timer? _inactiveTimer;
  Timer? _resumeTimer;

  // ── Overridable getters ────────────────────────────────────────────────────

  /// Enable freeze when app goes to background (from exam policy).
  bool get freezeEnabled => false;

  /// Countdown shown in the freeze dialog.
  int get freezeTimerSeconds => 30;

  /// Block screenshots at OS level via [NoScreenshot].
  bool get noScreenshot => false;

  /// Unique storage key suffix (e.g. unitId).
  String get freezeIdentifier => '';

  /// Whether the `inactive` lifecycle state should trigger the freeze dialog.
  ///
  /// Set to `false` on screens where screenshots must NOT cause a freeze
  /// (e.g. navigation/overview screens).  The freeze will still fire when the
  /// app moves to `paused` (home button, task switcher, etc.).
  bool get inactiveTriggersFreeze => true;

  // ── Internal ───────────────────────────────────────────────────────────────

  String get _storageKey => 'exam_freeze_remaining_secs_$freezeIdentifier';

  /// Called when the freeze countdown expires.
  void onFreezeExpired();

  /// Temporarily suppress freeze (e.g. while a system permission dialog is open).
  /// Call [resumeFreezeObserver] when the dialog is dismissed.
  void pauseFreezeObserver() {
    _resumeTimer?.cancel();
    _resumeTimer = null;
    _freezeSuppressed = true;
    _inactiveTimer?.cancel();
    _inactiveTimer = null;
  }

  /// Re-enable freeze after [pauseFreezeObserver] was called.
  void resumeFreezeObserver() {
    _resumeTimer?.cancel();
    final state = WidgetsBinding.instance.lifecycleState;
    if (state != null && state != AppLifecycleState.resumed) {
      // If the app is currently not resumed (e.g. still in inactive/paused from permission dialog),
      // we delay resuming the observer to allow the app to transition back fully.
      _resumeTimer = Timer(const Duration(milliseconds: 1000), () {
        _freezeSuppressed = false;
      });
    } else {
      _freezeSuppressed = false;
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  void initFreezeObserver() {
    WidgetsBinding.instance.addObserver(this);
    if (freezeEnabled) {
      _checkAndShowPersistentFreeze();
      if (kIsWeb) {
        JsSecurityServiceBridge.instance.initialize(
          onFreezeTriggered: () {
            _onAppBackground();
          },
          onViolationTriggered: () {
            _onExamViolation();
          },
        );
      }
    }
    if (noScreenshot) {
      _noScreenshot.screenshotOff();
    }
  }

  void disposeFreezeObserver() {
    WidgetsBinding.instance.removeObserver(this);
    _inactiveTimer?.cancel();
    _inactiveTimer = null;
    _resumeTimer?.cancel();
    _resumeTimer = null;
    if (kIsWeb && freezeEnabled) {
      JsSecurityServiceBridge.instance.dispose();
    }
    if (noScreenshot) {
      _noScreenshot.screenshotOn();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!freezeEnabled) return;
    if (_freezeSuppressed) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // App is back — cancel any pending inactive timer.
        // This is what happens after a screenshot: inactive → resumed quickly.
        _inactiveTimer?.cancel();
        _inactiveTimer = null;

      case AppLifecycleState.paused:
        // App truly backgrounded (home button, recent apps, screen off).
        // Always trigger freeze regardless of [inactiveTriggersFreeze].
        _inactiveTimer?.cancel();
        _inactiveTimer = null;
        _onAppBackground();

      case AppLifecycleState.inactive:
        if (!inactiveTriggersFreeze) {
          // On screenshot-safe screens we intentionally ignore `inactive`.
          // Screenshots cause inactive→resumed very quickly; we do nothing here
          // and let `paused` (if it comes) handle real backgrounding.
          return;
        }
        // On other screens a short delay filters transient system overlays
        // (volume HUD, etc.) while still catching real background events.
        _inactiveTimer?.cancel();
        _inactiveTimer = Timer(const Duration(milliseconds: 1000), () {
          if (mounted &&
              WidgetsBinding.instance.lifecycleState ==
                  AppLifecycleState.inactive) {
            _onAppBackground();
          }
        });

      default:
        break;
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _checkAndShowPersistentFreeze() {
    final remainingSeconds = StorageRepository.getInt(_storageKey, defValue: 0);
    if (remainingSeconds > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showFreezeDialogWithSeconds(remainingSeconds);
      });
    }
  }

  void _onAppBackground() {
    if (_freezeSuppressed) return;
    if (_freezeDialogShown) return;
    if (!mounted) return;

    _freezeDialogShown = true;

    int remainingSeconds = StorageRepository.getInt(_storageKey, defValue: 0);
    if (remainingSeconds <= 0) {
      remainingSeconds = freezeTimerSeconds;
      StorageRepository.putInt(_storageKey, remainingSeconds);
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) {
        _freezeDialogShown = false;
        return;
      }
      _showFreezeDialogWithSeconds(remainingSeconds);
    });
  }

  void _showFreezeDialogWithSeconds(int seconds) {
    if (!_freezeDialogShown) _freezeDialogShown = true;
    showFreezeDialog(
      context: context,
      freezeSeconds: seconds,
      onExpired: () {
        StorageRepository.deleteInt(_storageKey);
        _freezeDialogShown = false;
        if (mounted) onFreezeExpired();
      },
      onTick: (int sec) {
        if (sec > 0) {
          StorageRepository.putInt(_storageKey, sec);
        } else {
          StorageRepository.deleteInt(_storageKey);
        }
      },
    );
  }

  void _onExamViolation() {
    if (_freezeSuppressed) return;
    if (mounted) {
      _onAppBackground();
    }
  }
}
