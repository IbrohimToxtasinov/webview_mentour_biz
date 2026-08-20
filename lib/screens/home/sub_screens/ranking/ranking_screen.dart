import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/cubits/ranking/ranking_cubit.dart';
import 'package:mentour_web_view/data/models/ranking/ranking_user_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/arrow_back_button.dart';
import 'package:mentour_web_view/utils/app_icons.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/app_utils.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

enum RankingType { group, school }

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  RankingType type = RankingType.group;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: t.mentourBg1,
      body: SafeArea(
        child: Stack(
          children: [
            BlocProvider(
              create: (context) => RankingCubit()..getRankingByGroupAndSchool(),
              child: BlocBuilder<RankingCubit, RankingState>(
                builder: (context, state) {
                  if (state.status == FormStatus.getRankingLoading) {
                    return Positioned.fill(
                      top: 55,
                      child: Center(
                        child: Lottie.asset(
                          AppLotties.loader,
                          width: 320,
                          height: 320,
                        ),
                      ),
                    );
                  } else if (state.status == FormStatus.getRankingSuccess) {
                    final List<RankingUserModel> currentList =
                        type == RankingType.group
                        ? state.groupRanking
                        : state.schoolRanking;
                    return Positioned.fill(
                      top: 55,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade600,
                              Colors.orange.shade400,
                              Colors.orange.shade200,
                              Colors.orange.shade100,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (currentList.length >= 2)
                                  _PodiumItem(
                                    place: 2,
                                    user: currentList[1],
                                    height: 110,
                                  )
                                else
                                  _PodiumItemEmpty(place: 2, height: 110),
                                if (currentList.isNotEmpty)
                                  _PodiumItem(
                                    place: 1,
                                    user: currentList[0],
                                    height: 150,
                                  )
                                else
                                  _PodiumItemEmpty(place: 1, height: 150),

                                if (currentList.length >= 3)
                                  _PodiumItem(
                                    place: 3,
                                    user: currentList[2],
                                    height: 90,
                                  )
                                else
                                  _PodiumItemEmpty(place: 3, height: 90),
                              ],
                            ),

                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: t.mentourBg1,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    /// FILTER
                                    Container(
                                      margin: const EdgeInsets.all(16),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: t.mentourBorder1,
                                          width: 2,
                                        ),
                                        color: t.mentourNavigationBarBg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          _FilterButton(
                                            title: "by_group".tr(),
                                            selected: type == RankingType.group,
                                            onTap: () => setState(
                                              () => type = RankingType.group,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          _FilterButton(
                                            title: "by_school".tr(),
                                            selected:
                                                type == RankingType.school,
                                            onTap: () => setState(
                                              () => type = RankingType.school,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// RANKING LIST
                                    Expanded(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.only(
                                          bottom: 20,
                                          right: 16,
                                          left: 16,
                                        ),
                                        itemCount: currentList.length,
                                        separatorBuilder: (_, _) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (_, i) {
                                          final user = currentList[i];
                                          return _RankingItem(
                                            index: i + 1,
                                            user: user,
                                          );
                                        },
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
                  } else if (state.status == FormStatus.getRankingFailure) {
                    return Positioned.fill(
                      top: 55,
                      child: Center(child: Text(state.errorMessage)),
                    );
                  } else {
                    return Positioned.fill(
                      top: 55,
                      child: Center(child: Text("FormStatus is pure")),
                    );
                  }
                },
              ),
            ),

            /// TOP BAR
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: t.mentourBg1,
                child: Row(
                  children: [
                    ArrowBackButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "ranking".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
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
    );
  }
}

/// ===================== PODIUM ITEM =====================
class _PodiumItem extends StatelessWidget {
  final int place;
  final RankingUserModel user;
  final double height;

  const _PodiumItem({
    required this.place,
    required this.user,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final double radius = place == 1 ? 34 : 28;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(1.5), // border width
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.mentourBorder1, // border color
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundImage: user.profilePic.path.isNotEmpty
                  ? NetworkImage(user.profilePic.path)
                  : null,
              child: user.profilePic.path.isEmpty
                  ? Text(
                      AppUtils.getInitial(user.fullName),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.fullName.split(" ").first,
            style: TextStyle(
              color: t.mentourWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 100,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: t.mentourWhite),
                shape: BoxShape.circle,
              ),
              child: Text(
                place.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: t.mentourWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumItemEmpty extends StatelessWidget {
  final int place;
  final double height;

  const _PodiumItemEmpty({required this.place, required this.height});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(1.5), // border width
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.mentourBorder1, // border color
            ),
            child: CircleAvatar(
              radius: place == 1 ? 34 : 28,
              child: Text(
                "---",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "---",
            style: TextStyle(
              color: t.mentourWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 100,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: t.mentourWhite),
                shape: BoxShape.circle,
              ),
              child: Text(
                place.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: t.mentourWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== FILTER BUTTON =====================
class _FilterButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? t.mentourPrimary1 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? t.mentourWhite : t.mentourText3,
            ),
          ),
        ),
      ),
    );
  }
}

/// ===================== RANKING ITEM =====================
class _RankingItem extends StatelessWidget {
  final int index;
  final RankingUserModel user;

  const _RankingItem({required this.index, required this.user});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.mentourNavigationBarBg,
        border: Border.all(width: 2, color: t.mentourBorder1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            index.toString(),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(1.5), // border width
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.mentourBorder1, // border color
            ),
            child: CircleAvatar(
              backgroundImage: user.profilePic.path.isNotEmpty
                  ? NetworkImage(user.profilePic.path)
                  : null,
              child: user.profilePic.path.isEmpty
                  ? Text(
                      AppUtils.getInitial(user.fullName),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Row(
            children: [
              Text(
                user.coinBalance.toString(),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(AppIcons.star, height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
