import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/course/course_bloc.dart';
import 'package:mentour_web_view/cubits/group_details/group_details_cubit.dart';
import 'package:mentour_web_view/data/models/course/course_detail_model.dart';
import 'package:mentour_web_view/data/models/course/course_model.dart';
import 'package:mentour_web_view/screens/courses/sub_screens/course_detail/tabs/attendance_tab.dart';
import 'package:mentour_web_view/screens/courses/sub_screens/course_detail/tabs/my_group_tab.dart';
import 'package:mentour_web_view/screens/courses/sub_screens/course_detail/tabs/results_tab.dart';
import 'package:mentour_web_view/screens/courses/sub_screens/course_detail/widgets/course_tab_bar.dart';
import 'package:mentour_web_view/screens/courses/widgets/course_card.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel courseModel;

  const CourseDetailScreen({super.key, required this.courseModel});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  int _currentTabIndex = 0;
  final List<String> _tabs = ["attendance", "results", "group"];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: t.newMentourBg1,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              top: 50,
              left: 10,
              right: 10,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) =>
                        CourseBloc()
                          ..add(GetCourseById(courseId: widget.courseModel.id)),
                  ),
                  BlocProvider(
                    create: (context) =>
                        GroupDetailsCubit()
                          ..getGroupDetails(courseId: widget.courseModel.id),
                  ),
                ],
                child: BlocBuilder<CourseBloc, CourseState>(
                  builder: (context, state) {
                    if (state.formStatus ==
                        FormStatus.getCourseDetailInLoading) {
                      return Center(
                        child: Lottie.asset(
                          AppLotties.loader,
                          width: 320,
                          height: 320,
                        ),
                      );
                    } else if (state.formStatus ==
                        FormStatus.getCourseDetailInSuccess) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            CourseCardWidget(courseModel: widget.courseModel),
                            SizedBox(height: 12),
                            // TABS
                            CourseTabBar(
                              currentIndex: _currentTabIndex,
                              onTap: (index) {
                                setState(() {
                                  _currentTabIndex = index;
                                });
                              },
                              tabKeys: _tabs,
                            ),
                            SizedBox(height: 8),
                            // TAB CONTENT
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: _buildTabContent(
                                state.courseDetail.lessons,
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      );
                    } else if (state.formStatus ==
                        FormStatus.getCourseDetailInFailure) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 200,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: t.mentourError,
                              ),
                              SizedBox(height: 24),
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
                              SizedBox(height: 32),
                              MainActionButton(
                                label: "try_again".tr(),
                                onTap: () {
                                  context.read<CourseBloc>().add(
                                    GetCourseById(
                                      courseId: widget.courseModel.id,
                                    ),
                                  );
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
            // TOP BAR
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(color: t.newMentourBg1),
                child: Row(
                  children: [
                    NewArrowBackButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 12),
                    Text(
                      "course_details".tr(),
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

  Widget _buildTabContent(List<Lesson> lessons) {
    if (_currentTabIndex == 0) {
      return AttendanceTab(lessons: lessons);
    } else if (_currentTabIndex == 1) {
      return ResultsTab();
    } else {
      return BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
        builder: (context, groupState) {
          if (groupState.formStatus ==
              FormStatus.getCourseGroupDetailsInLoading) {
            return Center(
              child: Lottie.asset(AppLotties.loader, width: 280, height: 280),
            );
          }
          return MyGroupsTabContent(groupDetails: groupState.groupDetails);
        },
      );
    }
  }
}
