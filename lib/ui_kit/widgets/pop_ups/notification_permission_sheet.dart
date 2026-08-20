import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';

/// Shows a custom bottom sheet asking the user to allow notifications.
/// Returns `true` if the user tapped "Allow", `false` if tapped "Not Now".
Future<bool> showNotificationPermissionSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _NotificationPermissionSheet(),
  );
  return result ?? false;
}

class _NotificationPermissionSheet extends StatelessWidget {
  const _NotificationPermissionSheet();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: t.mentourBg2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: t.mentourBorder1,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),

            // Bell icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: MentourColors.primary1.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                size: 36,
                color: t.mentourPrimary2,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              "notif_permission_title".tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: t.mentourText2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              "notif_permission_desc".tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: t.mentourIcon1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Allow button
            MainActionButton(
              onTap: () => Navigator.pop(context, true),
              label: "notif_permission_allow".tr(),
            ),
            const SizedBox(height: 12),

            // Not now button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: t.mentourIcon1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "notif_permission_later".tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
