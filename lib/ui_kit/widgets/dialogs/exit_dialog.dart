import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/stadium_gradient_button.dart';
import 'package:mentour_web_view/utils/app_images.dart';

void showExitDialog({
  required BuildContext context,
  required String message,
  required String title,
  required VoidCallback yesTap,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final t = Theme.of(context);
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.symmetric(horizontal: 40),
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Container(
          decoration: BoxDecoration(
            color: t.newMentourContainer1,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(AppLotties.logOut, height: 150, width: 150, repeat: false),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: t.newMentourText3),
                  ),
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: t.newMentourText4),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: StadiumGradientButton(
                        label: 'no'.tr(),
                        onTap: () => Navigator.of(context).pop(),
                        height: 40,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: StadiumGradientButton(
                        label: 'yes'.tr(),
                        onTap: yesTap,
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
