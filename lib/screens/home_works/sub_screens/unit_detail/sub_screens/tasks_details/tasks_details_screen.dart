import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/home_works/home_work_bloc.dart';
import 'package:mentour_web_view/blocs/profile/profile_bloc.dart';
import 'package:mentour_web_view/cubits/active_homework/active_homework_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/screens/home_works/sub_screens/unit_detail/sub_screens/tasks_details/widgets/speaking_pronunciation_task_item.dart';
import 'package:mentour_web_view/screens/home_works/sub_screens/unit_detail/sub_screens/tasks_details/widgets/speaking_task_item.dart';
import 'package:mentour_web_view/ui_kit/widgets/audio/custom_audio_player.dart';
import 'package:mentour_web_view/screens/home_works/sub_screens/unit_detail/sub_screens/tasks_details/widgets/writing_task_item.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/containers/task_item.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class TasksDetailsScreen extends StatelessWidget {
  final String unitUuid;
  final String unitTitle;
  final String topicName;
  final String sectionType;
  final bool fromHome;
  final String groupUuid;

  const TasksDetailsScreen({
    super.key,
    required this.unitUuid,
    required this.unitTitle,
    required this.topicName,
    required this.sectionType,
    this.fromHome = false,
    required this.groupUuid,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (fromHome) {
          context.read<ActiveHomeworkCubit>().getActiveHomework();
          context.read<ProfileBloc>().add(GetProfileInfo());
        } else {
          context.read<HomeworkBloc>().add(
            GetHomeworksByLesson(groupUuid: groupUuid),
          );
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: t.newMentourBg1,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                top: 52.5,
                left: 16,
                right: 16,
                child: RefreshIndicator(
                  color: t.newMentourPrimary2,
                  backgroundColor: t.mentourNavigationBarBg,
                  onRefresh: () async {
                    context
                        .read<UnitSectionDetailCubit>()
                        .getUnitSectionByIdAndType(
                          unitId: unitUuid,
                          type: sectionType,
                        );
                  },
                  child: BlocBuilder<UnitSectionDetailCubit, UnitSectionDetailState>(
                    builder: (context, state) {
                      if (state.formStatus ==
                          FormStatus.getUnitSectionLoading) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 200),
                            Center(
                              child: Lottie.asset(
                                AppLotties.loader,
                                width: 320,
                                height: 320,
                              ),
                            ),
                          ],
                        );
                      }

                      if (state.formStatus ==
                          FormStatus.getUnitSectionSuccess) {
                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 12),
                          itemBuilder: (context, index) {
                            return sectionType == "WRITING"
                                ? WritingTaskItem(
                                    task: state.section.tasks[index],
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRouterNames.writingTaskRoute,
                                        arguments: {
                                          "taskId":
                                              state.section.tasks[index].id,
                                          "unitId": unitUuid,
                                        },
                                      );
                                    },
                                  )
                                : sectionType == "SPEAKING"
                                ? state.section.tasks[index].exerciseSubType ==
                                          "PRONUNCIATION"
                                      ? SpeakingPronunciationTaskItem(
                                          onTap: () {
                                            CustomAudioPlayer.pauseAll();
                                            Navigator.pushNamed(
                                              context,
                                              AppRouterNames
                                                  .speakingPronunciationTaskRoute,
                                              arguments: {
                                                "taskId": state
                                                    .section
                                                    .tasks[index]
                                                    .id,
                                                "unitId": unitUuid,
                                                "maxAttempts":
                                                    int.parse(
                                                      state
                                                          .section
                                                          .tasks[index]
                                                          .resSpeaking
                                                          .first
                                                          .resExerciseQuestion
                                                          .content
                                                          .maxTries,
                                                    ) -
                                                    state
                                                        .section
                                                        .tasks[index]
                                                        .resSpeaking
                                                        .first
                                                        .attempts,
                                              },
                                            );
                                          },
                                          task: state.section.tasks[index],
                                        )
                                      : SpeakingTaskItem(
                                          onTap: () {
                                            CustomAudioPlayer.pauseAll();
                                            Navigator.pushNamed(
                                              context,
                                              AppRouterNames.speakingTaskRoute,
                                              arguments: {
                                                "taskId": state
                                                    .section
                                                    .tasks[index]
                                                    .id,
                                                "unitId": unitUuid,
                                              },
                                            );
                                          },
                                          task: state.section.tasks[index],
                                        )
                                : TaskItem(
                                    task: state.section.tasks[index],
                                    onTap: () {
                                      if (state
                                              .section
                                              .tasks[index]
                                              .percentages !=
                                          100) {
                                        Navigator.pushNamed(
                                          context,
                                          AppRouterNames.questionsRoute,
                                          arguments: {
                                            "type": sectionType,
                                            "taskId":
                                                state.section.tasks[index].id,
                                            "unitId": unitUuid,
                                          },
                                        );
                                      }
                                    },
                                  );
                          },
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemCount: state.section.tasks.length,
                        );
                      }

                      if (state.formStatus ==
                          FormStatus.getUnitSectionFailure) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 150),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
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
                                      context
                                          .read<UnitSectionDetailCubit>()
                                          .getUnitSectionByIdAndType(
                                            unitId: unitUuid,
                                            type: sectionType,
                                          );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return Center(child: Text("form_status_pure".tr()));
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
                          if (fromHome) {
                            BlocProvider.of<ActiveHomeworkCubit>(
                              context,
                            ).getActiveHomework();
                            context.read<ProfileBloc>().add(GetProfileInfo());
                          } else {
                            context.read<HomeworkBloc>().add(
                              GetHomeworksByLesson(groupUuid: groupUuid),
                            );
                          }
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 12),
                      Text(
                        sectionType[0] + sectionType.substring(1).toLowerCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: t.newMentourText7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
