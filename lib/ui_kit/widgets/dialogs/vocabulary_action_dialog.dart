import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_icons.dart';

class VocabularyActionDialog extends StatelessWidget {
  final String vocabularyUuid;
  final String unitId;
  final bool isQuizWordsTap;

  const VocabularyActionDialog({
    super.key,
    required this.vocabularyUuid,
    required this.unitId,
    required this.isQuizWordsTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(horizontal: 40),
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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppIcons.vocabulary,
                    height: 80,
                    width: 80,
                    colorFilter: ColorFilter.mode(
                      t.mentourPrimary2,
                      BlendMode.srcIn,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "vocabulary_action_title".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: t.mentourText3,
                      ),
                    ),
                  ),
                  Text(
                    "vocabulary_action_message".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: t.mentourText3),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(
                              context,
                              AppRouterNames.learnWordsRoute,
                              arguments: {
                                "setUuid": vocabularyUuid,
                                "unitId": unitId,
                                "isQuizWordsTap": isQuizWordsTap,
                              },
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: t.mentourPrimary2,
                            foregroundColor: t.mentourWhite,
                            side: BorderSide(color: t.mentourBorder1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            minimumSize: Size(0, 80),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppIcons.bookOpen,
                                height: 32,
                                width: 32,
                                colorFilter: ColorFilter.mode(
                                  t.mentourWhite,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "learn".tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isQuizWordsTap) ...[
                        SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (isQuizWordsTap) {
                                Navigator.of(context).pop();
                                Navigator.pushNamed(
                                  context,
                                  AppRouterNames.quizWordsRoute,
                                  arguments: {
                                    "setUuid": vocabularyUuid,
                                    "unitId": unitId,
                                  },
                                );
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: t.mentourBg1,
                              foregroundColor: t.mentourText3,
                              side: BorderSide(
                                color: t.mentourBorder1,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              minimumSize: Size(0, 80),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  AppIcons.exercises,
                                  height: 32,
                                  width: 32,
                                  colorFilter: ColorFilter.mode(
                                    t.mentourText3,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "quiz".tr(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: t.mentourBg1,
                        foregroundColor: t.mentourText3,
                        side: BorderSide(color: t.mentourBorder1, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: Size(double.infinity, 44),
                      ),
                      child: Text(
                        "cancel".tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.all(4),
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
}
