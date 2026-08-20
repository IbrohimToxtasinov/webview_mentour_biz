/// Central configuration for exam freeze behavior.
///
/// [screenshotSafeRoutes] — routes where screenshots are allowed without
/// triggering the freeze dialog.  The freeze dialog WILL still appear if the
/// user backgrounds the app or pulls down the notification shade on these routes.
///
/// Add a route constant here to exclude it from screenshot-triggered freeze.
class ExamFreezeConfig {
  ExamFreezeConfig._();

  /// Routes on which taking a screenshot must NOT trigger the freeze dialog.
  /// Background / notification-shade still triggers freeze on these routes.
  static const Set<String> screenshotSafeRoutes = {
    '/view_exam_sections', // ViewExamSectionsScreen
    '/exam_tasks', // ExamTasksScreen
  };

  /// Delay used for routes in [screenshotSafeRoutes].
  ///
  /// Screenshots cause `inactive` → `resumed` in ≈ 200–500 ms.
  /// By waiting 1 500 ms we let the OS return to `resumed` (cancelling the
  /// timer) before we decide to freeze.  The notification shade stays
  /// `inactive` indefinitely, so it still triggers freeze.
  static const Duration screenshotSafeDelay = Duration(milliseconds: 1500);

  /// Delay used for all other routes.
  ///
  /// A short delay avoids false positives from transient system overlays
  /// (e.g. volume HUD) while still catching real screenshot events quickly.
  static const Duration screenshotUnsafeDelay = Duration(milliseconds: 300);
}
