import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/cubits/exam_timer/exam_timer_cubit.dart';
import 'package:mentour_web_view/cubits/vocabulary_detail/vocabulary_detail_cubit.dart';
import 'package:mentour_web_view/data/models/section/section_details_model.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/containers/task_item.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class ExamVocabularyDetailScreen extends StatelessWidget {
  final String unitUuid;
  final String unitTitle;
  final String topicName;
  final String sectionType;
  final bool freezeScreen;
  final int freezeTimer;
  final bool noScreenshot;

  const ExamVocabularyDetailScreen({
    super.key,
    required this.unitUuid,
    required this.unitTitle,
    required this.topicName,
    required this.sectionType,
    this.freezeScreen = false,
    this.freezeTimer = 30,
    this.noScreenshot = false,
  });

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: t.newMentourBg1,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: t.newMentourPrimary2,
              backgroundColor: t.mentourNavigationBarBg,
              onRefresh: () async {
                BlocProvider.of<VocabularyDetailCubit>(
                  context,
                ).getVocabularyDetail(unitId: unitUuid);
              },
              child: Positioned.fill(
                top: 52.5,
                left: 16,
                right: 16,
                child: BlocBuilder<VocabularyDetailCubit, VocabularyDetailState>(
                  builder: (context, state) {
                    if (state.formStatus ==
                        FormStatus.getVocabularyDetailLoading) {
                      return Center(
                        child: Lottie.asset(
                          AppLotties.loader,
                          width: 320,
                          height: 320,
                        ),
                      );
                    } else if (state.formStatus ==
                        FormStatus.getVocabularyDetailSuccess) {
                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemBuilder: (context, index) {
                          return TaskItem(
                            isExam: true,
                            task: Task(
                              answeredAll:
                              state.vocabularies[index].answeredAll,
                              exerciseSubType: "",
                              id: state.vocabularies[index].uuid,
                              percentages: state.vocabularies[index].percentage,
                              lessonSectionType: sectionType,
                              sortOrder: state.vocabularies[index].sortOrder,
                              title: state.vocabularies[index].title,
                              topic: topicName,
                              totalQuestions:
                              state.vocabularies[index].questionCount,
                              resWriting: [],
                              resSpeaking: [],
                              limitInstalled: false,
                              attempts: 0,
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRouterNames.examQuizWordsRoute,
                                arguments: {
                                  "setUuid": state.vocabularies[index].uuid,
                                  "unitId": unitUuid,
                                  "freezeScreen": freezeScreen,
                                  "freezeTimer": freezeTimer,
                                  "noScreenshot": noScreenshot,
                                },
                              );
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 10);
                        },
                        itemCount: state.vocabularies.length,
                      );
                    } else if (state.formStatus ==
                        FormStatus.getVocabularyDetailFailure) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 200,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: t.mentourError,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                state.errorMessage.isNotEmpty
                                    ? state.errorMessage
                                    : "An error occurred. Please try again.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: t.mentourIconColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 32),
                              MainActionButton(
                                label: "try_again".tr(),
                                onTap: () {
                                  BlocProvider.of<VocabularyDetailCubit>(
                                    context,
                                  ).getVocabularyDetail(unitId: unitUuid);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Center(child: Text("form_status_pure".tr()));
                    }
                  },
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                padding: const EdgeInsets.only(left: 8, right: 24),
                decoration: BoxDecoration(color: t.newMentourBg1),
                child: Row(
                  children: [
                    NewArrowBackButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sectionType[0] + sectionType.substring(1).toLowerCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: t.newMentourText7,
                        ),
                      ),
                    ),
                    BlocBuilder<ExamTimerCubit, int>(
                      builder: (context, remainingSeconds) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: remainingSeconds < 60
                                ? t.mentourError.withValues(alpha: 0.1)
                                : t.newMentourContainer26,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 18,
                                color: remainingSeconds < 60
                                    ? t.mentourError
                                    : t.newMentourPrimary2,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(remainingSeconds),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: remainingSeconds < 60
                                      ? t.mentourError
                                      : t.newMentourPrimary2,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
