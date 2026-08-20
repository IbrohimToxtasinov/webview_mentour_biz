import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/course/course_bloc.dart';
import 'package:mentour_web_view/blocs/home_works/home_work_bloc.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/screens/courses/widgets/course_card.dart';
import 'package:mentour_web_view/ui_kit/skeletons/main_skeleton_box.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final ScrollController _scrollController = ScrollController();
  CourseBloc? _courseBloc;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || _courseBloc == null) return;
    if (!_isBottom) return;

    final state = _courseBloc!.state;
    if (!state.hasMore || state.isLoadingMore || _isLoading) return;

    _isLoading = true;
    _courseBloc!.add(
      GetStudentAllCourses(page: state.currentPage + 1, isLoadMore: true),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _isLoading = false;
    });
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return false;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: t.newMentourBg1,
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocProvider(
          create: (context) {
            final bloc = CourseBloc()..add(const GetStudentAllCourses(page: 0));
            _courseBloc = bloc;
            return bloc;
          },
          child: Stack(
            children: [
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  return RefreshIndicator(
                    color: t.newMentourPrimary2,
                    backgroundColor: t.newMentourNavigationBg1,
                    onRefresh: () async {
                      context.read<CourseBloc>().add(
                        const GetStudentAllCourses(page: 0),
                      );
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        const SliverToBoxAdapter(child: SizedBox(height: 50)),
                        _buildSliverBody(context, state),
                        const SliverToBoxAdapter(child: SizedBox(height: 120)),
                      ],
                    ),
                  );
                },
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
                        "my_courses".tr(),
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

  Widget _buildSliverBody(BuildContext context, CourseState state) {
    if (state.formStatus == FormStatus.getStudentAllCoursesInLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 120),
              Lottie.asset(AppLotties.loader, width: 320, height: 320),
            ],
          ),
        ),
      );
    }

    if (state.formStatus == FormStatus.getStudentAllCoursesInSuccess) {
      if (state.courses.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _emptyState(context),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: CourseCardWidget(
                courseModel: state.courses[index],
                onTap: () {
                  context.read<HomeworkBloc>().add(
                    GetAllHomeWorks(
                      groupUuid: state.courses[index].resGroup.id,
                    ),
                  );
                  Navigator.pushNamed(
                    context,
                    AppRouterNames.courseDetailRoute,
                    arguments: state.courses[index],
                  );
                },
              ),
            );
          }, childCount: state.courses.length),
        ),
      );
    }

    if (state.formStatus == FormStatus.getStudentAllCoursesInFailure) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _errorState(context, state),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox());
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 150),
          Lottie.asset(
            AppLotties.noData,
            fit: BoxFit.fitWidth,
            width: double.infinity,
          ),
          const SizedBox(height: 20),
          Text(
            "no_data_yet".tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).mentourIconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(BuildContext context, CourseState state) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).mentourError,
                ),
                const SizedBox(height: 24),
                Text(
                  state.errorMessage.isNotEmpty
                      ? state.errorMessage
                      : "An error occurred. Please try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).mentourIconColor,
                  ),
                ),
                const SizedBox(height: 32),
                MainActionButton(
                  label: "try_again".tr(),
                  onTap: () {
                    context.read<CourseBloc>().add(
                      const GetStudentAllCourses(page: 0),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CourseSkeleton extends StatelessWidget {
  const CourseSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.mentourNavigationBarBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.mentourBorder1, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainSkeletonBox(height: 21, width: 150),
              MainSkeletonBox(height: 23, width: 100),
            ],
          ),
          SizedBox(height: 7),
          MainSkeletonBox(height: 18, width: 100),
          SizedBox(height: 7),
          MainSkeletonBox(height: 16, width: 150),
          SizedBox(height: 16),
          MainSkeletonBox(height: 18, width: 300),
          SizedBox(height: 16),

          Row(
            children: [
              MainSkeletonBox(height: 18, width: 150),
              Spacer(),
              MainSkeletonBox(height: 16, width: 25),
            ],
          ),
          SizedBox(height: 8),
          MainSkeletonBox(height: 8, isHaveBorder: false),
        ],
      ),
    );
  }
}
