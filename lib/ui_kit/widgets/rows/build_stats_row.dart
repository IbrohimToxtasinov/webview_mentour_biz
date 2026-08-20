import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/columns/stat_item.dart';
import 'package:mentour_web_view/utils/app_icons.dart';

class BuildStatsRow extends StatelessWidget {
  final int score;
  final int coins;

  const BuildStatsRow({super.key, required this.score, required this.coins});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: t.mentourNavigationBarBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.mentourBorder1, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StatItem(
            icon: AppIcons.coin,
            value: coins.toString(),
            label: "COINS",
          ),
          SizedBox(width: 2, height: 50),
          StatItem(
            icon: AppIcons.star,
            value: score.toString(),
            label: "SCORES",
          ),
        ],
      ),
    );
  }
}
