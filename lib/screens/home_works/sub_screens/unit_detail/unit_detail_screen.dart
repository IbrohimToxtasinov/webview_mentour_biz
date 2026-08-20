import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/home_works/home_work_bloc.dart';
import 'package:mentour_web_view/blocs/unit_detail/unit_detail_bloc.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/cubits/vocabulary_detail/vocabulary_detail_cubit.dart';
import 'package:mentour_web_view/data/models/homeworks/homework_model.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/containers/build_progress_item.dart';
import 'package:mentour_web_view/ui_kit/widgets/dialogs/vocabulary_action_dialog.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class UnitDetailScreen extends StatelessWidget {
  final String unitId;
  final String unitTitle;
  final String groupUuid;

  const UnitDetailScreen({
    super.key,
    required this.unitId,
    required this.unitTitle,
    required this.groupUuid,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        context.read<HomeworkBloc>().add(
          GetHomeworksByLesson(groupUuid: groupUuid),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: t.mentourBg1,
        body: SafeArea(
          child: RefreshIndicator(
            color: t.newMentourPrimary2,
            backgroundColor: t.mentourNavigationBarBg,
            onRefresh: () async {
              context.read<UnitDetailBloc>().add(GetUnitDetail(unitId: unitId));
            },
            child: Stack(
              children: [
                Positioned.fill(
                  top: 65,
                  left: 16,
                  right: 16,
                  child: BlocBuilder<UnitDetailBloc, UnitDetailState>(
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
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              ...state.unit.sections.map(
                                (section) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: buildSectionItem(
                                    section: section,
                                    onTap: () {
                                      if (section.type == "VOCABULARY") {
                                        context
                                            .read<VocabularyDetailCubit>()
                                            .getVocabularyDetail(
                                              unitId: state.unit.unitUuid,
                                            );

                                        Navigator.pushNamed(
                                          context,
                                          AppRouterNames.vocabularyDetailRoute,
                                          arguments: {
                                            "sectionType": section.type,
                                            "unitTitle": state.unit.unitTitle,
                                            "topicName": state.unit.topicName,
                                            "unitUuid": state.unit.unitUuid,
                                            "fromHome": false,
                                            "groupUuid": groupUuid,
                                          },
                                        );
                                      } else {
                                        context
                                            .read<UnitSectionDetailCubit>()
                                            .getUnitSectionByIdAndType(
                                              unitId: state.unit.unitUuid,
                                              type: section.type,
                                            );

                                        Navigator.pushNamed(
                                          context,
                                          AppRouterNames.tasksDetailsRoute,
                                          arguments: {
                                            "sectionType": section.type,
                                            "unitTitle": state.unit.unitTitle,
                                            "topicName": state.unit.topicName,
                                            "unitUuid": state.unit.unitUuid,
                                            "fromHome": false,
                                            "groupUuid": groupUuid,
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state.formStatus == FormStatus.getUnitDetailFailure) {
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
                                    context.read<UnitDetailBloc>().add(
                                      GetUnitDetail(unitId: unitId),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Center(child: Text("form_status_pure".tr()));
                    },
                  ),
                ),

                // TOP BAR
                Positioned(
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 55,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: t.mentourBg1,
                    child: Row(
                      children: [
                        ArrowBackButton(
                          onTap: () {
                            context.read<HomeworkBloc>().add(
                              GetHomeworksByLesson(groupUuid: groupUuid),
                            );
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            unitTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: t.mentourText3,
                            ),
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
      ),
    );
  }
}

void showVocabularyActionDialog({
  required BuildContext context,
  required String vocabularyUuid,
  required String unitId,
  required bool isQuizWordsTap,
}) {
  showDialog(
    context: context,
    builder: (_) => VocabularyActionDialog(
      vocabularyUuid: vocabularyUuid,
      unitId: unitId,
      isQuizWordsTap: isQuizWordsTap,
    ),
  );
}

class SectionUI {
  final IconData icon;
  final Color color;
  final String label;

  SectionUI({required this.icon, required this.color, required this.label});
}

SectionUI getSectionUI(String type) {
  switch (type) {
    case 'VOCABULARY':
      return SectionUI(
        icon: Icons.book,
        color: MentourColors.vocabulary,
        label: 'VOCABULARY',
      );
    case 'GRAMMAR':
      return SectionUI(
        icon: Icons.edit_note,
        color: MentourColors.exercise,
        label: 'GRAMMAR',
      );
    case 'LISTENING':
      return SectionUI(
        icon: Icons.headphones,
        color: MentourColors.listening,
        label: 'LISTENING',
      );
    case 'READING':
      return SectionUI(
        icon: Icons.menu_book,
        color: MentourColors.reading,
        label: 'READING',
      );
    case 'WRITING':
      return SectionUI(
        icon: Icons.edit,
        color: MentourColors.writing,
        label: 'WRITING',
      );
    case 'SPEAKING':
      return SectionUI(
        icon: Icons.mic_rounded,
        color: MentourColors.speaking,
        label: 'SPEAKING',
      );
    default:
      return SectionUI(
        icon: Icons.help_outline,
        color: Colors.grey,
        label: type.toUpperCase(),
      );
  }
}

Widget buildSectionItem({
  required Section section,
  required VoidCallback? onTap,
}) {
  final ui = getSectionUI(section.type);

  return Opacity(
    opacity: section.locked ? 0.5 : 1,
    child: BuildProgressItem(
      onTap: section.locked ? null : onTap,
      icon: ui.icon,
      label: ui.label,
      progress: section.progressPercentage / 100,
      progressText:
          "${section.progressPercentage}% ${tr("complete").toUpperCase()}",
      color: ui.color,
    ),
  );
}
