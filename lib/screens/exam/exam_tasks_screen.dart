import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/cubits/exam_timer/exam_timer_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/screens/home_works/sub_screens/unit_detail/sub_screens/tasks_details/widgets/speaking_pronunciation_task_item.dart';
import 'package:mentour_web_view/screens/home_works/sub_screens/unit_detail/sub_screens/tasks_details/widgets/speaking_task_item.dart';
import 'package:mentour_web_view/screens/home_works/sub_screens/unit_detail/sub_screens/tasks_details/widgets/writing_task_item.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/containers/task_item.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/ui_kit/widgets/audio/custom_audio_player.dart';
import 'package:mentour_web_view/utils/mixins/exam_freeze_observer.dart';

class ExamTasksScreen extends StatefulWidget {
  final String unitUuid;
  final String sectionType;
  final bool freezeScreen;
  final int freezeTimer;
  final bool noScreenshot;

  const ExamTasksScreen({
    super.key,
    required this.unitUuid,
    required this.sectionType,
    this.freezeScreen = false,
    this.freezeTimer = 30,
    this.noScreenshot = false,
  });

  @override
  State<ExamTasksScreen> createState() => _ExamTasksScreenState();
}

class _ExamTasksScreenState extends State<ExamTasksScreen>
    with WidgetsBindingObserver, ExamFreezeObserver {
  @override
  bool get freezeEnabled => widget.freezeScreen;

  @override
  // Screenshot qilganda inactive→resumed tez o'tadi va freeze yo'q.
  // Home button/switch da paused trigger bo'ladi — freeze ishlaydi.
  bool get inactiveTriggersFreeze => false;

  @override
  // Screenshot ruxsat etilgan — OS darajasida bloklanmasin
  bool get noScreenshot => false;

  @override
  String get freezeIdentifier => widget.unitUuid;

  @override
  int get freezeTimerSeconds =>
      widget.freezeTimer > 0 ? widget.freezeTimer : 30;

  @override
  void onFreezeExpired() {
    // Dialog closes itself — nothing else needed here.
  }

  @override
  void initState() {
    super.initState();
    initFreezeObserver();
  }

  @override
  void dispose() {
    disposeFreezeObserver();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  NewArrowBackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.sectionType[0] +
                          widget.sectionType.substring(1).toLowerCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                              ? t.mentourError.withOpacity(0.1)
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: remainingSeconds < 60
                                    ? t.mentourError
                                    : t.newMentourPrimary2,
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
            Expanded(
              child: RefreshIndicator(
                color: t.newMentourPrimary2,
                backgroundColor: t.mentourNavigationBarBg,
                onRefresh: () async {
                  context
                      .read<UnitSectionDetailCubit>()
                      .getUnitSectionByIdAndType(
                        unitId: widget.unitUuid,
                        type: widget.sectionType,
                      );
                },
                child: BlocBuilder<UnitSectionDetailCubit, UnitSectionDetailState>(
                  builder: (context, state) {
                    if (state.formStatus == FormStatus.getUnitSectionLoading) {
                      return Center(
                        child: Lottie.asset(
                          AppLotties.loader,
                          width: 320,
                          height: 320,
                        ),
                      );
                    }

                    if (state.formStatus == FormStatus.getUnitSectionSuccess) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: state.section.tasks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = state.section.tasks[index];
                          return widget.sectionType == "WRITING"
                              ? WritingTaskItem(
                                  isExam: true,
                                  task: task,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRouterNames.examWritingTaskRoute,
                                      arguments: {
                                        "taskId": task.id,
                                        "unitId": widget.unitUuid,
                                        "freezeScreen": widget.freezeScreen,
                                        "freezeTimer": widget.freezeTimer,
                                        "noScreenshot": widget.noScreenshot,
                                      },
                                    );
                                  },
                                )
                              : widget.sectionType == "SPEAKING"
                              ? task.exerciseSubType == "PRONUNCIATION"
                                    ? SpeakingPronunciationTaskItem(
                                        isExam: true,
                                        onTap: () {
                                          CustomAudioPlayer.pauseAll();
                                          Navigator.pushNamed(
                                            context,
                                            AppRouterNames
                                                .examSpeakingPronunciationTaskRoute,
                                            arguments: {
                                              "taskId": task.id,
                                              "unitId": widget.unitUuid,
                                              "maxAttempts":
                                                  task.resSpeaking.isNotEmpty
                                                  ? int.parse(
                                                          task
                                                              .resSpeaking
                                                              .first
                                                              .resExerciseQuestion
                                                              .content
                                                              .maxTries,
                                                        ) -
                                                        task
                                                            .resSpeaking
                                                            .first
                                                            .attempts
                                                  : 3,
                                              "freezeScreen":
                                                  widget.freezeScreen,
                                              "freezeTimer": widget.freezeTimer,
                                              "noScreenshot":
                                                  widget.noScreenshot,
                                            },
                                          );
                                        },
                                        task: task,
                                      )
                                    : SpeakingTaskItem(
                                        isExam: true,
                                        task: task,
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRouterNames
                                                .examSpeakingTaskRoute,
                                            arguments: {
                                              "taskId": task.id,
                                              "unitId": widget.unitUuid,
                                              "freezeScreen":
                                                  widget.freezeScreen,
                                              "freezeTimer": widget.freezeTimer,
                                              "noScreenshot":
                                                  widget.noScreenshot,
                                            },
                                          );
                                        },
                                      )
                              : TaskItem(
                                  isExam: true,
                                  task: task,
                                  onTap: () {
                                    CustomAudioPlayer.pauseAll();
                                    Navigator.pushNamed(
                                      context,
                                      AppRouterNames.sectionQuestionsRoute,
                                      arguments: {
                                        "type": widget.sectionType,
                                        "taskId": task.id,
                                        "unitId": widget.unitUuid,
                                        "freezeScreen": widget.freezeScreen,
                                        "freezeTimer": widget.freezeTimer,
                                        "noScreenshot": widget.noScreenshot,
                                      },
                                    );
                                  },
                                );
                        },
                      );
                    }

                    if (state.formStatus == FormStatus.getUnitSectionFailure) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          top: 150,
                          left: 24,
                          right: 24,
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
                                      unitId: widget.unitUuid,
                                      type: widget.sectionType,
                                    );
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return Center(child: Text("form_status_pure".tr()));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
