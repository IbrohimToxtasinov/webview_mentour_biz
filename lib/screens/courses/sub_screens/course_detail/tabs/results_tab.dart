import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/home_works/home_work_bloc.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class ResultsTab extends StatelessWidget {
  const ResultsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return BlocBuilder<HomeworkBloc, HomeworkState>(
      builder: (context, state) {
        if (state.formStatus == FormStatus.getAllHomeWorksLoading) {
          return Center(
            child: Lottie.asset(AppLotties.loader, width: 150, height: 150),
          );
        }
        final unlockedHomeworks = state.homeworks
            .where((h) => h.overallStatus != "LOCKED")
            .toList();

        if (unlockedHomeworks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                "There are no available results.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: t.newMentourText4,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "my_results".tr(),
              style: TextStyle(
                color: t.newMentourText3,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: unlockedHomeworks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final hw = unlockedHomeworks[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: t.newMentourContainer1,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t.newMentourBorder2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hw.unitTitle,
                          style: TextStyle(
                            color: t.newMentourText3,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: t.newMentourPrimary2,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${hw.progressPercentage}%",
                          style: TextStyle(
                            color: t.mentourWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
