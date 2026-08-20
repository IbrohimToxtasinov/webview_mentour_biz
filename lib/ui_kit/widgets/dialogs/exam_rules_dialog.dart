import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_icons.dart';

class ExamRulesDialog extends StatelessWidget {
  final VoidCallback onAgree;

  const ExamRulesDialog({super.key, required this.onAgree});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: t.mentourNavigationBarBg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: t.mentourPrimary2.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppIcons.newTasks, // Or a more suitable icon for exam
                        height: 48,
                        width: 48,
                        colorFilter: ColorFilter.mode(
                          t.mentourPrimary2,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      "exam_rules_title".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: t.mentourText3,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRuleItem(t, "exam_rule_1".tr()),
                      _buildRuleItem(t, "exam_rule_2".tr()),
                      _buildRuleItem(t, "exam_rule_3".tr()),
                      _buildRuleItem(t, "exam_rule_4".tr()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "exam_rules_confirm_msg".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: t.mentourText3.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: t.mentourBg1,
                            foregroundColor: t.mentourText3,
                            side: BorderSide(color: t.mentourBorder1, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            minimumSize: const Size(0, 52),
                            maximumSize: const Size(double.infinity, 52),
                          ),
                          child: Text(
                            "no".tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onAgree();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: t.mentourPrimary2,
                            foregroundColor: t.mentourWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            minimumSize: const Size(0, 52),
                            maximumSize: const Size(double.infinity, 52),
                          ),
                          child: Text(
                            "yes".tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: t.mentourText3.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 20, color: t.mentourText3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(ThemeData t, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: t.mentourPrimary2,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: t.mentourText3),
            ),
          ),
        ],
      ),
    );
  }
}
