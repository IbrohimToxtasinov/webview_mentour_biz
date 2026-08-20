import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_images.dart';

class CoinAndScoreWidget extends StatelessWidget {
  final String coins;
  final String score;
  final String schoolId;

  const CoinAndScoreWidget({
    super.key,
    required this.coins,
    required this.score,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouterNames.coinScoreRoute,
                arguments: schoolId,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 7.5,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: t.newMentourContainer1,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: t.newMentourBorder2),
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    decoration: BoxDecoration(
                      color: t.newMentourContainer6,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Lottie.asset(AppLotties.coin, repeat: false),
                    // child: SvgPicture.asset(AppIcons.newCoin),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "COINS",
                        style: TextStyle(
                          color: t.newMentourText4,
                          fontSize: 10,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        coins,
                        style: TextStyle(
                          color: t.newMentourText3,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 26),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouterNames.coinScoreRoute,
                arguments: schoolId,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 7.5,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: t.newMentourContainer1,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: t.newMentourBorder2),
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: t.newMentourContainer6,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Lottie.asset(AppLotties.score, repeat: false),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SCORE",
                        style: TextStyle(
                          color: t.newMentourText4,
                          fontSize: 10,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        score,
                        style: TextStyle(
                          color: t.newMentourText3,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
