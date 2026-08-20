import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/group/group_bloc.dart';
import 'package:mentour_web_view/data/models/group/group_model.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/skeletons/main_skeleton_box.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/app_utils.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Fetch initial groups if pure or empty
    final state = context.read<GroupBloc>().state;
    if (state.formStatus == FormStatus.pure || state.groups.isEmpty) {
      context.read<GroupBloc>().add(const GetStudentAllGroup(page: 0));
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final groupBloc = context.read<GroupBloc>();
    if (!_isBottom) return;

    final state = groupBloc.state;
    if (!state.hasMore || state.isLoadingMore || _isLoading) return;

    _isLoading = true;
    groupBloc.add(
      GetStudentAllGroup(page: state.currentPage + 1, isLoadMore: true),
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
        child: Stack(
          children: [
            BlocBuilder<GroupBloc, GroupState>(
              builder: (context, state) {
                return RefreshIndicator(
                  color: t.newMentourPrimary2,
                  backgroundColor: t.newMentourNavigationBg1,
                  onRefresh: () async {
                    context.read<GroupBloc>().add(
                      const GetStudentAllGroup(page: 0),
                    );
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 45)),
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
                      "groups".tr(),
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

  Widget _buildSliverBody(BuildContext context, GroupState state) {
    if (state.formStatus == FormStatus.getStudentAllCoursesInLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: GroupSkeleton(),
            ),
            childCount: 3,
          ),
        ),
      );
    }

    if (state.formStatus == FormStatus.getStudentAllCoursesInSuccess) {
      if (state.groups.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _emptyState(context),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index < state.groups.length) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GroupCardWidget(
                  groupModel: state.groups[index],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouterNames.homeworksRoute,
                      arguments: state.groups[index].id,
                    );
                  },
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              );
            }
          }, childCount: state.groups.length + (state.isLoadingMore ? 1 : 0)),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Lottie.asset(AppLotties.noData, fit: BoxFit.fitWidth, width: 240),
          const SizedBox(height: 20),
          Text(
            "no_data_yet".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).newMentourText4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(BuildContext context, GroupState state) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(Icons.error_outline, size: 64, color: t.mentourError),
          const SizedBox(height: 24),
          Text(
            state.errorMessage.isNotEmpty
                ? state.errorMessage
                : "An error occurred. Please try again.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: t.newMentourText4,
            ),
          ),
          const SizedBox(height: 32),
          MainActionButton(
            label: "try_again".tr(),
            onTap: () {
              context.read<GroupBloc>().add(const GetStudentAllGroup(page: 0));
            },
          ),
        ],
      ),
    );
  }
}

class GroupCardWidget extends StatelessWidget {
  final GroupModel groupModel;
  final VoidCallback onTap;

  const GroupCardWidget({
    super.key,
    required this.groupModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: t.newMentourContainer25,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: t.newMentourBorder1, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppUtils.levelColors(groupModel.level.level),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${groupModel.level.subjectName.toUpperCase()} / ${groupModel.level.level.toUpperCase()}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              groupModel.name,
              style: TextStyle(
                color: t.newMentourText3,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AppUtils.getInitial(groupModel.teacherFullName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupModel.teacherFullName,
                        style: TextStyle(
                          color: t.newMentourText3,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

class GroupSkeleton extends StatelessWidget {
  const GroupSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.newMentourContainer25,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: t.newMentourBorder1, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MainSkeletonBox(height: 20, width: 80),
              const SizedBox(width: 8),
              const MainSkeletonBox(height: 16, width: 100),
            ],
          ),
          const SizedBox(height: 16),
          const MainSkeletonBox(height: 26, width: 160),
          const SizedBox(height: 16),
          Row(
            children: [
              const MainSkeletonBox(height: 32, width: 32, isHaveBorder: false),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MainSkeletonBox(height: 12, width: 50),
                  const SizedBox(height: 4),
                  const MainSkeletonBox(height: 14, width: 120),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
