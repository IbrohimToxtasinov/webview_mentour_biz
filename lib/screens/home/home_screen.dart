import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/blocs/auth/auth_bloc.dart';
import 'package:mentour_web_view/data/repositories/singletons/secure_storage.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/stadium_gradient_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentour_web_view/blocs/profile/profile_bloc.dart';
import 'package:mentour_web_view/cubits/active_homework/active_homework_cubit.dart';
import 'package:mentour_web_view/screens/home/widgets/active_homework.dart';
import 'package:mentour_web_view/screens/home/widgets/attendance.dart';
import 'package:mentour_web_view/screens/home/widgets/coin_and_score.dart';
import 'package:mentour_web_view/screens/home/widgets/learning_center.dart';
import 'package:mentour_web_view/screens/home/widgets/main_header.dart';
import 'package:mentour_web_view/screens/home/widgets/quick_access.dart';
import 'package:mentour_web_view/ui_kit/skeletons/main_skeleton_box.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/enums/auth_status.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class HomeScreen extends StatefulWidget {
  final bool fromInitialRoute;

  const HomeScreen({super.key, this.fromInitialRoute = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _handleAutoSignIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // prefs.setString("ext_username", "998903530048");
      // prefs.setString("ext_password", "FivePlus5+");

      final extUsername = prefs.getString('ext_username');
      final extPassword = prefs.getString('ext_password');
      if (extUsername != null &&
          extUsername.isNotEmpty &&
          extPassword != null &&
          extPassword.isNotEmpty) {
        if (mounted) {
          context.read<AuthBloc>().add(
            AutoSignIn(userName: extUsername, password: extPassword),
          );
        }
      } else {
        final existingToken = await SecureStorage.get(key: "accessToken");
        if (existingToken != null && existingToken.isNotEmpty) {
          if (mounted) {
            context.read<ProfileBloc>().add(const GetProfileInfo());
            context.read<ActiveHomeworkCubit>().getActiveHomework();
          }
        } else {
          showOverlayMessage(context, text: "credentials_not_found".tr());
          if (mounted) {
            context.read<AuthBloc>().add(const LogOut());
          }
        }
      }
    } catch (_) {
      showOverlayMessage(context, text: "credentials_not_found".tr());
    }
  }

  Future<void> _init() async {
    final token = await SecureStorage.get(key: "accessToken");
    if (token != null && token.isNotEmpty) {
      if (mounted) {
        context.read<ProfileBloc>().add(const GetProfileInfo());
        context.read<ActiveHomeworkCubit>().getActiveHomework();
      }
    } else {
      await _handleAutoSignIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: t.newMentourBg1,
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
        previous.formStatus != current.formStatus ||
            previous.authStatus != current.authStatus,
        listener: (context, state) {
          if (state.formStatus == FormStatus.signInSuccess ||
              state.formStatus == FormStatus.checkUserInSuccess ||
              state.formStatus == FormStatus.getProfileInfoInSuccess ||
              state.authStatus == AuthStatus.authenticated) {
            context.read<ProfileBloc>().add(const GetProfileInfo());
            context.read<ActiveHomeworkCubit>().getActiveHomework();
          }
        },
        builder: (context, authState) {
          final isSigningIn = authState.formStatus == FormStatus.signInLoading;
          final isSignInFailed =
              authState.formStatus == FormStatus.signInFailure &&
                  authState.authStatus == AuthStatus.unauthenticated;
          final isUnauthenticated =
              authState.authStatus == AuthStatus.unauthenticated &&
                  authState.formStatus != FormStatus.signInSuccess;

          if (isSigningIn) {
            return Center(
              child: CircularProgressIndicator(color: t.newMentourPrimary2),
            );
          }

          if (isSignInFailed ||
              (isUnauthenticated &&
                  authState.formStatus == FormStatus.signInFailure)) {
            return _AuthErrorWidget(
              errorMessage: authState.errorMessage.isNotEmpty
                  ? authState.errorMessage
                  : "credentials_not_found".tr(),
              onRetry: _handleAutoSignIn,
            );
          }

          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              return RefreshIndicator(
                color: t.newMentourPrimary2,
                backgroundColor: t.newMentourNavigationBg1,
                onRefresh: () async {
                  context.read<ProfileBloc>().add(const GetProfileInfo());
                  context.read<ActiveHomeworkCubit>().getActiveHomework();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            BlocBuilder<ProfileBloc, ProfileState>(
                              builder: (context, state) {
                                if (state.formStatus ==
                                    FormStatus.getProfileInfoInLoading) {
                                  return const Padding(
                                    padding: EdgeInsets.only(bottom: 12.0),
                                    child: NewHomeSkeleton(),
                                  );
                                } else if (state.formStatus ==
                                    FormStatus.getProfileInfoInSuccess) {
                                  return Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      MainHeaderWidget(
                                        profile: state.profileModel,
                                      ),
                                      const SizedBox(height: 12),
                                      LearningCenterWidget(
                                        school: state.profileModel.schoolInfo,
                                      ),
                                      const SizedBox(height: 12),
                                      CoinAndScoreWidget(
                                        schoolId:
                                        state.profileModel.schoolInfo.uuid,
                                        coins: state.profileModel.coins
                                            .toString(),
                                        score: state.profileModel.score
                                            .toString(),
                                      ),
                                      const SizedBox(height: 12),
                                      QuickAccessWidget(
                                        schoolId:
                                        state.profileModel.schoolInfo.uuid,
                                      ),
                                      const SizedBox(height: 12),
                                      AttendanceWidget(),
                                    ],
                                  );
                                } else if (state.formStatus ==
                                    FormStatus.getProfileInfoInFailure) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24.0,
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            state.errorMessage.isNotEmpty
                                                ? state.errorMessage
                                                : "Failed to load profile data",
                                            style: TextStyle(
                                              color: t.newMentourText2,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            onPressed: () {
                                              context.read<ProfileBloc>().add(
                                                const GetProfileInfo(),
                                              );
                                            },
                                            child: Text("try_again".tr()),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return const Padding(
                                    padding: EdgeInsets.only(bottom: 12.0),
                                    child: NewHomeSkeleton(),
                                  );
                                }
                              },
                            ),
                            ActiveHomeworkWidget(),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AuthErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _AuthErrorWidget({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: t.newMentourText2),
              ),
            ],
            const SizedBox(height: 32),
            StadiumGradientButton(label: "try_again".tr(), onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

class NoActiveHomeworkWidget extends StatelessWidget {
  const NoActiveHomeworkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.mentourNavigationBarBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.mentourBorder1, width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: t.mentourPrimary1),
          const SizedBox(height: 12),
          Text(
            "active_homework_empty".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: t.mentourText2,
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveHomeworkSkeleton extends StatelessWidget {
  const ActiveHomeworkSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: t.newMentourContainer1,
      highlightColor: t.newMentourBorder2,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 24),
        decoration: BoxDecoration(
          color: t.newMentourContainer1,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.newMentourBorder1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MainSkeletonBox(height: 25, width: 120),
            const SizedBox(height: 16),
            ...List.generate(
              3,
                  (index) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: MainSkeletonBox(height: 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewHomeSkeleton extends StatelessWidget {
  const NewHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: t.newMentourContainer1,
      highlightColor: t.newMentourBorder2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MainSkeletonBox(
                height: 40,
                width: 40,
                radius: BorderRadius.circular(20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: MainSkeletonBox(height: 25),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              MainSkeletonBox(
                height: 56,
                width: 56,
                radius: BorderRadius.circular(16),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: MainSkeletonBox(height: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MainSkeletonBox(
                  height: 55,
                  radius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 26),
              Expanded(
                child: MainSkeletonBox(
                  height: 55,
                  radius: BorderRadius.circular(24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MainSkeletonBox(height: 118, radius: BorderRadius.circular(24)),
          const SizedBox(height: 12),
          MainSkeletonBox(height: 106, radius: BorderRadius.circular(24)),
        ],
      ),
    );
  }
}
