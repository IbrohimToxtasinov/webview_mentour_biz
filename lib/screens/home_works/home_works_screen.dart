import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/home_works/home_work_bloc.dart';
import 'package:mentour_web_view/blocs/unit_detail/unit_detail_bloc.dart';
import 'package:mentour_web_view/cubits/exam/exam_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/cubits/vocabulary_detail/vocabulary_detail_cubit.dart';
import 'package:mentour_web_view/data/models/homeworks/homework_by_lesson_model.dart';
import 'package:mentour_web_view/data/models/homeworks/homework_model.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/skeletons/main_skeleton_box.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/dialogs/exam_rules_dialog.dart';
import 'package:mentour_web_view/ui_kit/widgets/dialogs/loading_dialog.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';
import 'package:mentour_web_view/utils/app_icons.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/app_utils.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class HomeWorksScreen extends StatefulWidget {
  final String groupUuid;

  const HomeWorksScreen({super.key, required this.groupUuid});

  @override
  State<HomeWorksScreen> createState() => _HomeWorksScreenState();
}

class _HomeWorksScreenState extends State<HomeWorksScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeworkBloc>().add(
      GetHomeworksByLesson(groupUuid: widget.groupUuid),
    );
  }

  void _showExamRulesDialog(BuildContext context, HomeworkModel homework) {
    showDialog(
      context: context,
      builder: (dialogContext) => ExamRulesDialog(
        onAgree: () async {
          context.read<ExamCubit>().startExam(homework.unitUuid);
        },
      ),
    );
  }

  Widget _buildLessonGroupedList({
    required BuildContext context,
    required List<HomeworkByLessonModel> lessonGroups,
  }) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 55, 16, 20),
      itemCount: lessonGroups.length,
      itemBuilder: (context, index) {
        final lesson = lessonGroups[index];
        return _LessonSection(
          lesson: lesson,
          groupUuid: widget.groupUuid,
          onExamStartRequested: (homework) =>
              _showExamRulesDialog(context, homework),
        );
      },
    );
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
                context.read<HomeworkBloc>().add(
                  GetHomeworksByLesson(groupUuid: widget.groupUuid),
                );
              },
              child: MultiBlocListener(
                listeners: [
                  BlocListener<ExamCubit, ExamState>(
                    listener: (context, state) {
                      if (state.formStatus == FormStatus.resumeExamLoading) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const LoadingDialog(),
                        );
                      } else if (state.formStatus ==
                              FormStatus.startExamSuccess ||
                          state.formStatus == FormStatus.resumeExamSuccess) {
                        if (state.formStatus == FormStatus.resumeExamSuccess) {
                          Navigator.pop(context);
                        }
                        final homeworks = context
                            .read<HomeworkBloc>()
                            .state
                            .homeworks;
                        try {
                          var startedHomework = homeworks.firstWhere(
                            (h) => h.unitUuid == state.unitUuid,
                          );
                          if (state.examPolicy != null) {
                            startedHomework = startedHomework.copyWith(
                              examPolicy: state.examPolicy,
                            );
                          }
                          Navigator.pushNamed(
                            context,
                            AppRouterNames.viewExamSectionsRoute,
                            arguments: {
                              "homework": startedHomework,
                              "groupUuid": widget.groupUuid,
                            },
                          );
                        } catch (e) {
                          debugPrint("Error finding started homework: $e");
                        }
                      } else if (state.formStatus ==
                              FormStatus.startExamFailure ||
                          state.formStatus == FormStatus.resumeExamFailure) {
                        context.read<HomeworkBloc>().add(
                          GetHomeworksByLesson(groupUuid: widget.groupUuid),
                        );
                        if (state.formStatus == FormStatus.resumeExamFailure) {
                          Navigator.pop(context);
                        }
                        showOverlayMessage(context, text: state.errorMessage);
                      }
                    },
                  ),
                ],
                child: BlocBuilder<HomeworkBloc, HomeworkState>(
                  builder: (context, state) {
                    final examStatus = context
                        .watch<ExamCubit>()
                        .state
                        .formStatus;
                    if (state.formStatus == FormStatus.getAllHomeWorksLoading ||
                        state.formStatus ==
                            FormStatus.getHomeworksByLessonLoading ||
                        examStatus == FormStatus.startExamLoading) {
                      return Center(
                        child: Lottie.asset(
                          AppLotties.loader,
                          width: 320,
                          height: 320,
                        ),
                      );
                    }

                    if (state.formStatus ==
                        FormStatus.getHomeworksByLessonSuccess) {
                      if (state.homeworksByLesson.isEmpty) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      AppLotties.noData,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      "no_homework".tr(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return _buildLessonGroupedList(
                        context: context,
                        lessonGroups: state.homeworksByLesson,
                      );
                    }

                    if (state.formStatus == FormStatus.getAllHomeWorksSuccess) {
                      if (state.homeworks.isEmpty) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      AppLotties.noData,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      "no_homework".tr(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.homeworks.length,
                        padding: EdgeInsets.fromLTRB(16, 55, 16, 20),
                        itemBuilder: (context, index) {
                          return UnitItem(
                            groupUuid: widget.groupUuid,
                            homework: state.homeworks[index],
                            onExamStartRequested: (homework) =>
                                _showExamRulesDialog(context, homework),
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                      );
                    }

                    if (state.formStatus == FormStatus.getAllHomeWorksFailure ||
                        state.formStatus ==
                            FormStatus.getHomeworksByLessonFailure) {
                      if (state.formStatus ==
                              FormStatus.getHomeworksByLessonFailure &&
                          state.homeworks.isNotEmpty) {
                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.homeworks.length,
                          padding: EdgeInsets.fromLTRB(16, 55, 16, 20),
                          itemBuilder: (context, index) {
                            return UnitItem(
                              groupUuid: widget.groupUuid,
                              homework: state.homeworks[index],
                              onExamStartRequested: (homework) =>
                                  _showExamRulesDialog(context, homework),
                            );
                          },
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                        );
                      }
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
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
                                        context.read<HomeworkBloc>().add(
                                          GetHomeworksByLesson(
                                            groupUuid: widget.groupUuid,
                                          ),
                                        );
                                        context.read<HomeworkBloc>().add(
                                          GetHomeworksByLesson(
                                            groupUuid: widget.groupUuid,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
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
                    Text(
                      "homeworks".tr(),
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
    );
  }
}

class _LessonSection extends StatelessWidget {
  final HomeworkByLessonModel lesson;
  final String groupUuid;
  final Function(HomeworkModel) onExamStartRequested;

  const _LessonSection({
    required this.lesson,
    required this.groupUuid,
    required this.onExamStartRequested,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lesson.lessonName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: t.newMentourText7,
                  ),
                ),

                Text(
                  "${AppUtils.formatDate(lesson.lessonDate)} / ${AppUtils.getFormattedTime(context, DateTime.parse(lesson.startTime))} - ${AppUtils.getFormattedTime(context, DateTime.parse(lesson.endTime))}",
                  style: TextStyle(fontSize: 16, color: t.newMentourText13),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: t.newMentourContainer25,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                for (int i = 0; i < lesson.units.length; i++) ...[
                  UnitItem(
                    groupUuid: groupUuid,
                    homework: lesson.units[i],
                    onExamStartRequested: onExamStartRequested,
                  ),
                  if (i < lesson.units.length - 1)
                    Divider(
                      height: 0,
                      thickness: 3,
                      color: t.newMentourContainer27,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UnitItem extends StatefulWidget {
  final HomeworkModel homework;
  final String groupUuid;
  final Function(HomeworkModel) onExamStartRequested;

  const UnitItem({
    super.key,
    required this.homework,
    required this.onExamStartRequested,
    required this.groupUuid,
  });

  @override
  State<UnitItem> createState() => _UnitItemState();
}

class _UnitItemState extends State<UnitItem> {
  bool _isExpanded = false;
  late UnitDetailBloc _unitDetailBloc;

  @override
  void initState() {
    super.initState();
    _unitDetailBloc = UnitDetailBloc();
  }

  @override
  void dispose() {
    _unitDetailBloc.close();
    super.dispose();
  }

  void _onTap() {
    final isLocked = widget.homework.overallStatus == "LOCKED";
    if (widget.homework.progressPercentage > 0 || !isLocked) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
      if (_isExpanded &&
          _unitDetailBloc.state.formStatus != FormStatus.getUnitDetailSuccess) {
        _unitDetailBloc.add(GetUnitDetail(unitId: widget.homework.unitUuid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isLocked = widget.homework.overallStatus == "LOCKED";
    final isExam = widget.homework.unitType == "EXAM";

    Color iconBgColor;
    Color iconColor;
    if (isLocked) {
      iconColor = t.mentourIcon1;
      iconBgColor = t.newMentourContainer27;
    } else if (isExam) {
      iconColor = const Color(0xFFF97316);
      iconBgColor = const Color(0xFFF97316).withOpacity(0.15);
    } else {
      iconColor = t.mentourPrimary2;
      iconBgColor = t.newMentourContainer26;
    }

    return BlocProvider.value(
      value: _unitDetailBloc,
      child: GestureDetector(
        onTap: isExam ? null : _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.fromLTRB(20, 16.5, 20, 16.5),
          decoration: BoxDecoration(
            color: t.newMentourContainer25,
            borderRadius: BorderRadius.circular(32),
            border: isExam && !isLocked
                ? Border.all(
                    color: const Color(0xFFF97316).withOpacity(0.2),
                    width: 1.5,
                  )
                : Border.all(color: Colors.transparent, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!isLocked && widget.homework.progressPercentage > 0)
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: _RisingCircularProgress(
                        value: widget.homework.progressPercentage.toDouble(),
                        color: _progressColor(
                          widget.homework.progressPercentage.toDouble(),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isLocked
                            ? SvgPicture.asset(
                                AppIcons.newLocked,
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                              )
                            : SvgPicture.asset(
                                isExam
                                    ? AppIcons.newTasks
                                    : (widget.homework.isAdditional
                                          ? AppIcons.school
                                          : AppIcons.newBook),
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.homework.unitTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isLocked
                                ? t.newMentourText13
                                : t.newMentourText7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLocked)
                    widget.homework.unitType == "EXAM"
                        ? MainActionButton(
                            width: null,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            height: 32,
                            isGradientButton:
                                !widget.homework.examPolicy.isFinished,
                            buttonColor: iconColor,
                            enabled: !widget.homework.examPolicy.isFinished,
                            onTap: widget.homework.examPolicy.isFinished
                                ? () {}
                                : () {
                                    if (widget.homework.examPolicy.isStarted) {
                                      context.read<ExamCubit>().resumeExam(
                                        widget.homework.unitUuid,
                                      );
                                    } else {
                                      widget.onExamStartRequested(
                                        widget.homework,
                                      );
                                    }
                                  },
                            label: widget.homework.examPolicy.isFinished
                                ? "finished".tr()
                                : (widget.homework.examPolicy.isStarted
                                      ? "resume".tr()
                                      : "start".tr()),
                            labelColor: widget.homework.examPolicy.isFinished
                                ? t.mentourIcon1
                                : t.newMentourText9,
                            labelFontSize: 13,
                          )
                        : Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: t.mentourText3,
                          ),
                ],
              ),
              if (_isExpanded)
                BlocBuilder<UnitDetailBloc, UnitDetailState>(
                  builder: (context, state) {
                    if (state.formStatus == FormStatus.getUnitDetailLoading) {
                      return Center(
                        child: Lottie.asset(
                          AppLotties.loader,
                          width: 320,
                          height: 320,
                        ),
                      );
                    }

                    if (state.formStatus == FormStatus.getUnitDetailSuccess) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _SectionItem(
                              unitName: state.unit.unitTitle,
                              section: state.unit.sections[index],
                              onTap: () {
                                if (state.unit.sections[index].type ==
                                    "VOCABULARY") {
                                  BlocProvider.of<VocabularyDetailCubit>(
                                    context,
                                  ).getVocabularyDetail(
                                    unitId: state.unit.unitUuid,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    AppRouterNames.vocabularyDetailRoute,
                                    arguments: {
                                      "sectionType":
                                          state.unit.sections[index].type,
                                      "unitTitle": state.unit.unitTitle,
                                      "topicName": state.unit.topicName,
                                      "unitUuid": state.unit.unitUuid,
                                      "fromHome": false,
                                      "groupUuid": widget.groupUuid,
                                    },
                                  );
                                } else {
                                  BlocProvider.of<UnitSectionDetailCubit>(
                                    context,
                                  ).getUnitSectionByIdAndType(
                                    unitId: state.unit.unitUuid,
                                    type: state.unit.sections[index].type,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    AppRouterNames.tasksDetailsRoute,
                                    arguments: {
                                      "sectionType":
                                          state.unit.sections[index].type,
                                      "unitTitle": state.unit.unitTitle,
                                      "topicName": state.unit.topicName,
                                      "unitUuid": state.unit.unitUuid,
                                      "fromHome": false,
                                      "groupUuid": widget.groupUuid,
                                    },
                                  );
                                }
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 10);
                          },
                          itemCount: state.unit.sections.length,
                          shrinkWrap: true,
                        ),
                      );
                    }

                    if (state.formStatus == FormStatus.getUnitDetailFailure) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                state.errorMessage,
                                style: TextStyle(color: t.mentourError),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _unitDetailBloc.add(
                                    GetUnitDetail(
                                      unitId: widget.homework.unitUuid,
                                    ),
                                  );
                                },
                                child: Text(
                                  "try_again".tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: t.newMentourPrimary2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSectionModel {
  final String icon;
  final Color bgColor;
  final List<Color> progressColors;
  final String label;

  CustomSectionModel({
    required this.icon,
    required this.bgColor,
    required this.label,
    required this.progressColors,
  });
}

Color _progressColor(double percentage) {
  if (percentage < 50) return const Color(0xFFEF4444); // red
  if (percentage < 80) return const Color(0xFFEAB308); // yellow
  return const Color(0xFF22C55E); // green
}

CustomSectionModel getCustomSectionModel({
  required BuildContext context,
  required String type,
}) {
  final t = Theme.of(context);
  switch (type) {
    case 'VOCABULARY':
      return CustomSectionModel(
        icon: AppIcons.newVocabulary,
        bgColor: t.newMentourContainer8,
        label: 'Vocabulary',
        progressColors: [Color(0XFF2D60FF), Color(0XFFB7C4FF)],
      );
    case 'GRAMMAR':
      return CustomSectionModel(
        icon: AppIcons.newGrammar,
        bgColor: t.newMentourContainer9,
        label: 'Grammar',
        progressColors: [Color(0XFFDDB8FF), Color(0XFFB7C4FF)],
      );
    case 'SPEAKING':
      return CustomSectionModel(
        icon: AppIcons.newSpeaking,
        bgColor: t.newMentourContainer10,
        label: 'Speaking',
        progressColors: [Color(0XFF22C55E), Color(0XFFB7C4FF)],
      );
    case 'WRITING':
      return CustomSectionModel(
        icon: AppIcons.newWriting,
        bgColor: t.newMentourContainer11,
        label: 'Writing',
        progressColors: [Color(0XFFF97316), Color(0XFFB7C4FF)],
      );
    case 'LISTENING':
      return CustomSectionModel(
        icon: AppIcons.newListening,
        bgColor: t.newMentourContainer12,
        label: 'Listening',
        progressColors: [Color(0XFF3B82F6), Color(0XFFB7C4FF)],
      );
    case 'READING':
      return CustomSectionModel(
        icon: AppIcons.newReading,
        bgColor: t.newMentourContainer13,
        label: 'Reading',
        progressColors: [Color(0XFFA855F7), Color(0XFFB7C4FF)],
      );
    default:
      return CustomSectionModel(
        icon: AppIcons.newVocabulary,
        bgColor: t.newMentourContainer8,
        label: 'Vocabulary',
        progressColors: [Color(0XFF2D60FF), Color(0XFFB7C4FF)],
      );
  }
}

class _SectionItem extends StatelessWidget {
  final Section section;
  final String unitName;
  final VoidCallback? onTap;

  const _SectionItem({
    required this.unitName,
    required this.section,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final ui = getCustomSectionModel(context: context, type: section.type);
    return Opacity(
      opacity: section.locked ? 0.5 : 1,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: t.newMentourContainer20,
            borderRadius: BorderRadius.circular(48),
          ),
          child: Row(
            children: [
              SvgPicture.asset(ui.icon, height: 24, width: 24),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ui.label,
                          style: TextStyle(
                            color: t.newMentourText3,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: ui.progressColors,
                          ).createShader(bounds),
                          child: Text(
                            "${(section.progressPercentage).toInt()}%",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: t.mentourWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 9.5),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final totalWidth = constraints.maxWidth;
                        final progressWidth =
                            totalWidth * (section.progressPercentage / 100);
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 6,
                            width: double.infinity,
                            color: t.newMentourContainer14,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: progressWidth,
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: ui.progressColors,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RisingCircularProgress extends StatefulWidget {
  final double value; // 0–100
  final Color color;

  const _RisingCircularProgress({required this.value, required this.color});

  @override
  State<_RisingCircularProgress> createState() =>
      _RisingCircularProgressState();
}

class _RisingCircularProgressState extends State<_RisingCircularProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        return CustomPaint(
          size: const Size(54, 54),
          painter: _RisingArcPainter(value: _anim.value, color: widget.color),
          child: Center(
            child: Text(
              '${widget.value.toInt()}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: t.newMentourText7,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RisingArcPainter extends CustomPainter {
  final double value; // 0–100 (animated)
  final Color color;

  _RisingArcPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (value <= 0) return;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final sweep = math.pi * (value / 100);

    canvas.drawArc(rect, math.pi / 2, sweep, false, progressPaint);
    canvas.drawArc(rect, math.pi / 2, -sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RisingArcPainter old) => old.value != value;
}

class UnitItemSkeleton extends StatelessWidget {
  const UnitItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: t.mentourBorder1, width: 2),
        color: t.mentourNavigationBarBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  MainSkeletonBox(
                    height: 32,
                    width: 32,
                    radius: BorderRadius.circular(6),
                    isHaveBorder: true,
                  ),
                  const SizedBox(width: 12),
                  MainSkeletonBox(height: 16, width: 70),
                ],
              ),
              MainSkeletonBox(height: 16, width: 40),
            ],
          ),
          const SizedBox(height: 10),
          MainSkeletonBox(
            height: 6,
            radius: BorderRadius.circular(3),
            isHaveBorder: false,
          ),
        ],
      ),
    );
  }
}
