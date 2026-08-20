import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentour_web_view/cubits/active_homework/active_homework_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/cubits/vocabulary_detail/vocabulary_detail_cubit.dart';
import 'package:mentour_web_view/data/models/homeworks/active_homework_model.dart';
import 'package:mentour_web_view/data/models/homeworks/homework_model.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/screens/home/home_screen.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_icons.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class ActiveHomeworkWidget extends StatelessWidget {
  const ActiveHomeworkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return BlocBuilder<ActiveHomeworkCubit, ActiveHomeworkState>(
      builder: (context, state) {
        if (state.formStatus == FormStatus.getActiveHomeworkLoading) {
          return const ActiveHomeworkSkeleton();
        } else if (state.formStatus == FormStatus.getActiveHomeworkFailure) {
          return Center(child: Text(state.errorMessage));
        } else if (state.formStatus == FormStatus.getActiveHomeworkSuccess) {
          final activeGroups = state.groups
              .where((g) => g.activeHomeworks.any((h) => h.sections.isNotEmpty))
              .toList();

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
            decoration: BoxDecoration(
              color: t.newMentourContainer1,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: t.newMentourBorder2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "u_task".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: t.newMentourText3,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRouterNames.groupsRoute,
                      ),
                      child: Text(
                        "view_all".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: t.mentourPrimary2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (activeGroups.isEmpty)
                  NoActiveHomeworkWidget()
                else
                  ...activeGroups.map((group) => _GroupSection(group: group)),
              ],
            ),
          );
        } else {
          return const ActiveHomeworkSkeleton();
        }
      },
    );
  }
}

class _GroupSection extends StatefulWidget {
  final ActiveHomeworkGroup group;

  const _GroupSection({required this.group});

  @override
  State<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<_GroupSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late final AnimationController _iconCtrl;
  late final Animation<double> _iconTurn;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _iconTurn = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.easeInOut));
    _heightFactor = _iconCtrl.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _iconCtrl.forward();
    } else {
      _iconCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final homeworksWithSections = widget.group.activeHomeworks
        .where((h) => h.sections.isNotEmpty)
        .toList();

    if (homeworksWithSections.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: t.newMentourContainer20,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.newMentourBorder2, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: t.newMentourContainer26,
                  borderRadius: _isExpanded
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        )
                      : BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: t.mentourPrimary2,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.group.groupName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: t.mentourPrimary2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    RotationTransition(
                      turns: _iconTurn,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: t.mentourPrimary2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizeTransition(
              sizeFactor: _heightFactor,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...homeworksWithSections.expand(
                      (homework) => [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            homework.unitTitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: t.newMentourText4,
                            ),
                          ),
                        ),
                        ...homework.sections.map(
                          (section) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SectionItem(
                              unitName: homework.unitTitle,
                              section: section,
                              onTap: () {
                                if (section.type == "VOCABULARY") {
                                  BlocProvider.of<VocabularyDetailCubit>(
                                    context,
                                  ).getVocabularyDetail(
                                    unitId: homework.unitUuid,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    AppRouterNames.vocabularyDetailRoute,
                                    arguments: {
                                      "sectionType": section.type,
                                      "unitTitle": homework.unitTitle,
                                      "topicName": homework.topicName,
                                      "unitUuid": homework.unitUuid,
                                      "fromHome": true,
                                      "groupUuid": widget.group.groupUuid,
                                    },
                                  );
                                } else {
                                  BlocProvider.of<UnitSectionDetailCubit>(
                                    context,
                                  ).getUnitSectionByIdAndType(
                                    unitId: homework.unitUuid,
                                    type: section.type,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    AppRouterNames.tasksDetailsRoute,
                                    arguments: {
                                      "sectionType": section.type,
                                      "unitTitle": homework.unitTitle,
                                      "topicName": homework.topicName,
                                      "unitUuid": homework.unitUuid,
                                      "fromHome": true,
                                      "groupUuid": widget.group.groupUuid,
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
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
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ui.bgColor,
                  ),
                  child: SvgPicture.asset(ui.icon),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ui.label,
                      style: TextStyle(
                        color: t.newMentourText3,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      unitName,
                      style: TextStyle(
                        color: t.newMentourText4,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 9.5),
            Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
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
                ),
                SizedBox(width: 12),
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
          ],
        ),
      ),
    );
  }
}
