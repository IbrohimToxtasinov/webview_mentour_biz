import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentour_web_view/blocs/tab/navigator_bloc.dart';
import 'package:mentour_web_view/data/models/profile/profile_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_utils.dart';

class MainHeaderWidget extends StatelessWidget {
  final ProfileModel profile;

  const MainHeaderWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: profile.profilePhoto.path.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(profile.profilePhoto.path),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: profile.profilePhoto.path.isEmpty
                    ? LinearGradient(
                        colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
                      )
                    : null,
                border: Border.all(color: t.newMentourBorder1),
              ),
              child: profile.profilePhoto.path.isEmpty
                  ? Center(
                      child: Text(
                        AppUtils.getInitial(profile.fullName),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${"hi".tr()}, ${profile.fullName.isNotEmpty ? profile.fullName.split(" ").first : "User"} 👋",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.75,
                      color: t.newMentourText7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
