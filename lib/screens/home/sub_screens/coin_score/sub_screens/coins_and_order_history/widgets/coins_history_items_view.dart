import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/cubits/coins_history/coins_history_cubit.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_icons.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class CoinsHistoryItemsView extends StatefulWidget {
  const CoinsHistoryItemsView({super.key});

  @override
  State<CoinsHistoryItemsView> createState() => _CoinsHistoryItemsViewState();
}

class _CoinsHistoryItemsViewState extends State<CoinsHistoryItemsView> {
  IconData _icon(String type) {
    switch (type) {
      case "grammar":
        return Icons.edit_note;
      case "vocabulary":
        return Icons.book;
      case "listening":
        return Icons.headphones;
      case "writing":
        return Icons.edit;
      case "reading":
        return Icons.menu_book;
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return BlocProvider(
      create: (context) => CoinsHistoryCubit()..getCoinsHistory(),
      child: BlocBuilder<CoinsHistoryCubit, CoinsHistoryState>(
        builder: (context, state) {
          if (state.status == FormStatus.getCoinsHistoryLoading) {
            return Center(
              child: Lottie.asset(AppLotties.loader, width: 320, height: 320),
            );
          } else if (state.status == FormStatus.getCoinsHistorySuccess) {
            if (state.coinsHistory.isNotEmpty) {
              return ListView.separated(
                itemCount: state.coinsHistory.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.mentourNavigationBarBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.mentourBorder1, width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: t.mentourPrimary1.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _icon(state.coinsHistory[index].type),
                            color: t.mentourPrimary2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.coinsHistory[index].title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: t.mentourText3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMM yyyy').format(
                                  DateTime.parse(
                                    state.coinsHistory[index].date,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: t.mentourText4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "+${state.coinsHistory[index].coins}",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: t.mentourPrimary2,
                              ),
                            ),
                            SizedBox(width: 5),
                            SvgPicture.asset(
                              AppIcons.coin,
                              height: 24,
                              width: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
              );
            } else {
              return Center(child: Text("Hozircha hech qanday ma'lumot yo'q"));
            }
          } else if (state.status == FormStatus.getCourseDetailInFailure) {
            return Center(child: Text(state.errorMessage));
          } else {
            return Center(child: Text(state.errorMessage));
          }
        },
      ),
    );
  }
}
