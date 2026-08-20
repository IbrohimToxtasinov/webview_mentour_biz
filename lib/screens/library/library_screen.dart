import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentour_web_view/blocs/profile/profile_bloc.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/utils/app_icons.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: t.newMentourBg1,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 24),
              child: Row(
                children: [
                  NewArrowBackButton(onTap: () => Navigator.pop(context)),
                  Text(
                    "library".tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: t.newMentourText7,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      Text(
                        "learning_hub".tr(),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: t.newMentourText6,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "access_videos_audio_books".tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: t.newMentourText5,
                        ),
                      ),
                      SizedBox(height: 12),
                      _LibrarySectionItemWidget(
                        isSoon: false,
                        sectionName: "video".tr(),
                        sectionDescription: "watch_unit_videos".tr(),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouterNames.videosRoute,
                        ),
                      ),
                      SizedBox(height: 12),
                      _LibrarySectionItemWidget(
                        sectionName: "audio".tr(),
                        sectionDescription: "listen_unit_audios".tr(),
                        onTap: () {},
                      ),
                      SizedBox(height: 12),
                      _LibrarySectionItemWidget(
                        sectionName: "books".tr(),
                        sectionDescription: "read_unit_books".tr(),
                        onTap: () {},
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibrarySectionItemWidget extends StatelessWidget {
  final String sectionName;
  final bool isSoon;
  final String sectionDescription;
  final Function() onTap;

  const _LibrarySectionItemWidget({
    required this.sectionName,
    this.isSoon = true,
    required this.sectionDescription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return GestureDetector(
      onTap: isSoon ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: t.newMentourContainer1,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.newMentourBorder2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSoon ? t.newMentourContainer16 : null,
                gradient: isSoon
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [t.newMentourPrimary2, t.newMentourPrimary2],
                      ),
              ),
              child: SvgPicture.asset(
                isSoon ? AppIcons.newLocked : AppIcons.newFolder,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  sectionName,
                  style: TextStyle(
                    color: t.newMentourText3,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isSoon) ...[
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    decoration: BoxDecoration(
                      color: t.newMentourContainer17,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "coming_soon".tr(),
                      style: TextStyle(
                        // color: t.newMentourText3,
                        color: t.newMentourText8,
                        fontSize: 10,
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 12),
            Text(
              sectionDescription,
              style: TextStyle(color: t.newMentourText4),
            ),
          ],
        ),
      ),
    );
  }
}
