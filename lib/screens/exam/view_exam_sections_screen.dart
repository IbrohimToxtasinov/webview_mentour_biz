import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/home_works/home_work_bloc.dart';
import 'package:mentour_web_view/blocs/unit_detail/unit_detail_bloc.dart';
import 'package:mentour_web_view/cubits/exam_timer/exam_timer_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/cubits/vocabulary_detail/vocabulary_detail_cubit.dart';
import 'package:mentour_web_view/data/models/homeworks/homework_model.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/skeletons/main_skeleton_box.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/utils/app_icons.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/utils/mixins/exam_freeze_observer.dart';

class ViewExamSectionsScreen extends StatefulWidget {
  final HomeworkModel homework;
  final String groupUuid;

  const ViewExamSectionsScreen({
    super.key,
    required this.homework,
    required this.groupUuid,
  });

  @override
  State<ViewExamSectionsScreen> createState() => _ViewExamSectionsScreenState();
}

class _ViewExamSectionsScreenState extends State<ViewExamSectionsScreen>
    with WidgetsBindingObserver, ExamFreezeObserver {
  @override
  bool get freezeEnabled => widget.homework.examPolicy.freezeScreen;

  @override
  bool get inactiveTriggersFreeze => false;

  @override
  bool get noScreenshot => false;

  @override
  String get freezeIdentifier => widget.homework.unitUuid;

  @override
  int get freezeTimerSeconds => widget.homework.examPolicy.freezeTimer > 0
      ? widget.homework.examPolicy.freezeTimer
      : 30;

  @override
  void onFreezeExpired() {}

  @override
  void initState() {
    super.initState();
    initFreezeObserver();
    context.read<UnitDetailBloc>().add(
      GetUnitDetail(unitId: widget.homework.unitUuid),
    );
    final examTimerCubit = context.read<ExamTimerCubit>();
    if (!widget.homework.examPolicy.isFinished) {
      examTimerCubit.startTimer(
        widget.homework.examPolicy.globalRemainingSeconds,
      );
    }
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

    return BlocConsumer<ExamTimerCubit, int>(
      listenWhen: (previous, current) => previous > 0 && current <= 0,
      listener: (context, remainingSeconds) {
        if (!widget.homework.examPolicy.isFinished) {
          context.read<HomeworkBloc>().add(
            GetHomeworksByLesson(groupUuid: widget.groupUuid),
          );
          Navigator.popUntil(
            context,
            (route) =>
                route.settings.name == AppRouterNames.homeRoute ||
                route.isFirst,
          );
        }
      },
      builder: (context, remainingSeconds) {
        return WillPopScope(
          onWillPop: () async {
            context.read<HomeworkBloc>().add(
              GetHomeworksByLesson(groupUuid: widget.groupUuid),
            );
            return true;
          },
          child: Scaffold(
            backgroundColor: t.newMentourBg1,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        NewArrowBackButton(
                          onTap: () {
                            context.read<HomeworkBloc>().add(
                              GetHomeworksByLesson(groupUuid: widget.groupUuid),
                            );
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.homework.unitTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: t.newMentourText7,
                            ),
                          ),
                        ),
                        Container(
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
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<UnitDetailBloc, UnitDetailState>(
                      builder: (context, unitState) {
                        if (unitState.formStatus ==
                                FormStatus.getUnitDetailLoading &&
                            unitState.unit.sections.isEmpty) {
                          return Center(
                            child: Lottie.asset(
                              AppLotties.loader,
                              width: 320,
                              height: 320,
                            ),
                          );
                        }

                        final sections = unitState.unit.sections;

                        if (sections.isEmpty) {
                          return RefreshIndicator(
                            color: t.newMentourPrimary2,
                            backgroundColor: t.mentourNavigationBarBg,
                            onRefresh: () async {
                              context.read<UnitDetailBloc>().add(
                                GetUnitDetail(unitId: widget.homework.unitUuid),
                              );
                            },
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  child: Center(
                                    child: Lottie.asset(
                                      AppLotties.empty,
                                      width: 200,
                                      height: 200,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          color: t.newMentourPrimary2,
                          backgroundColor: t.mentourNavigationBarBg,
                          onRefresh: () async {
                            context.read<UnitDetailBloc>().add(
                              GetUnitDetail(unitId: widget.homework.unitUuid),
                            );
                          },
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: sections.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final section = sections[index];
                              final isLocked =
                                  section.locked ||
                                  remainingSeconds <= 0 ||
                                  widget.homework.examPolicy.isFinished;

                              return _SectionItem(
                                section: section,
                                unitName: widget.homework.unitTitle,
                                onTap: isLocked
                                    ? null
                                    : () {
                                        if (section.type == "VOCABULARY") {
                                          BlocProvider.of<
                                                VocabularyDetailCubit
                                              >(context)
                                              .getVocabularyDetail(
                                                unitId:
                                                    widget.homework.unitUuid,
                                              );
                                          Navigator.pushNamed(
                                            context,
                                            AppRouterNames
                                                .examVocabularyDetailRoute,
                                            arguments: {
                                              "sectionType": section.type,
                                              "unitTitle":
                                                  widget.homework.unitTitle,
                                              "topicName":
                                                  widget.homework.unitTitle,
                                              "unitUuid":
                                                  widget.homework.unitUuid,
                                              "freezeScreen": widget
                                                  .homework
                                                  .examPolicy
                                                  .freezeScreen,
                                              "freezeTimer": widget
                                                  .homework
                                                  .examPolicy
                                                  .freezeTimer,
                                              "noScreenshot": widget
                                                  .homework
                                                  .examPolicy
                                                  .noScreenshot,
                                            },
                                          );
                                        } else {
                                          BlocProvider.of<
                                                UnitSectionDetailCubit
                                              >(context)
                                              .getUnitSectionByIdAndType(
                                                unitId:
                                                    widget.homework.unitUuid,
                                                type: section.type,
                                              );
                                          Navigator.pushNamed(
                                            context,
                                            AppRouterNames.examTasksRoute,
                                            arguments: {
                                              "unitUuid":
                                                  widget.homework.unitUuid,
                                              "sectionType": section.type,
                                              "freezeScreen": widget
                                                  .homework
                                                  .examPolicy
                                                  .freezeScreen,
                                              "freezeTimer": widget
                                                  .homework
                                                  .examPolicy
                                                  .freezeTimer,
                                              "noScreenshot": widget
                                                  .homework
                                                  .examPolicy
                                                  .noScreenshot,
                                            },
                                          );
                                        }
                                      },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

CustomSectionModel getCustomSectionModel({
  required BuildContext context,
  required String type,
}) {
  final t = Theme.of(context);
  switch (type.toUpperCase()) {
    case 'VOCABULARY':
      return CustomSectionModel(
        icon: AppIcons.newVocabulary,
        bgColor: t.newMentourContainer8,
        label: 'Vocabulary',
        progressColors: [const Color(0XFF2D60FF), const Color(0XFFB7C4FF)],
      );
    case 'GRAMMAR':
      return CustomSectionModel(
        icon: AppIcons.newGrammar,
        bgColor: t.newMentourContainer9,
        label: 'Grammar',
        progressColors: [const Color(0XFFDDB8FF), const Color(0XFFB7C4FF)],
      );
    case 'SPEAKING':
      return CustomSectionModel(
        icon: AppIcons.newSpeaking,
        bgColor: t.newMentourContainer10,
        label: 'Speaking',
        progressColors: [const Color(0XFF22C55E), const Color(0XFFB7C4FF)],
      );
    case 'WRITING':
      return CustomSectionModel(
        icon: AppIcons.newWriting,
        bgColor: t.newMentourContainer11,
        label: 'Writing',
        progressColors: [const Color(0XFFF97316), const Color(0XFFB7C4FF)],
      );
    case 'LISTENING':
      return CustomSectionModel(
        icon: AppIcons.newListening,
        bgColor: t.newMentourContainer12,
        label: 'Listening',
        progressColors: [const Color(0XFF3B82F6), const Color(0XFFB7C4FF)],
      );
    case 'READING':
      return CustomSectionModel(
        icon: AppIcons.newReading,
        bgColor: t.newMentourContainer13,
        label: 'Reading',
        progressColors: [const Color(0XFFA855F7), const Color(0XFFB7C4FF)],
      );
    default:
      return CustomSectionModel(
        icon: AppIcons.newVocabulary,
        bgColor: t.newMentourContainer8,
        label: 'Vocabulary',
        progressColors: [const Color(0XFF2D60FF), const Color(0XFFB7C4FF)],
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: t.newMentourContainer20,
            borderRadius: BorderRadius.circular(48),
          ),
          child: Row(
            children: [
              SvgPicture.asset(ui.icon, height: 24, width: 24),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 9.5),
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
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: ui.progressColors,
                                  ),
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
