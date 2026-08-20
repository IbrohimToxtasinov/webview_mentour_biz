import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/home_works/home_work_bloc.dart';
import 'package:mentour_web_view/blocs/profile/profile_bloc.dart';
import 'package:mentour_web_view/cubits/active_homework/active_homework_cubit.dart';
import 'package:mentour_web_view/cubits/vocabulary_detail/vocabulary_detail_cubit.dart';
import 'package:mentour_web_view/data/models/section/section_details_model.dart';
import 'package:mentour_web_view/screens/home_works/sub_screens/unit_detail/unit_detail_screen.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/containers/task_item.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class VocabularyDetailScreen extends StatelessWidget {
  final String unitUuid;
  final String unitTitle;
  final String topicName;
  final String sectionType;
  final bool fromHome;
  final String groupUuid;

  const VocabularyDetailScreen({
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
          BlocProvider.of<ActiveHomeworkCubit>(context).getActiveHomework();
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
                              task: Task(
                                answeredAll:
                                    state.vocabularies[index].answeredAll,
                                exerciseSubType: "",
                                id: state.vocabularies[index].uuid,
                                percentages:
                                    state.vocabularies[index].percentage,
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
                                showVocabularyActionDialog(
                                  isQuizWordsTap:
                                      state.vocabularies[index].percentage !=
                                      100,
                                  context: context,
                                  vocabularyUuid:
                                      state.vocabularies[index].uuid,
                                  unitId: unitUuid,
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
