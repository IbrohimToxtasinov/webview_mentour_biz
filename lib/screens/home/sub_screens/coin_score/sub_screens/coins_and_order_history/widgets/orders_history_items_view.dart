import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/cubits/orders_history/orders_history_cubit.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class OrdersHistoryItemsView extends StatefulWidget {
  const OrdersHistoryItemsView({super.key});

  @override
  State<OrdersHistoryItemsView> createState() => _OrdersHistoryItemsViewState();
}

class _OrdersHistoryItemsViewState extends State<OrdersHistoryItemsView> {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return BlocProvider(
      create: (context) => OrdersHistoryCubit()..getOrdersHistory(),
      child: BlocBuilder<OrdersHistoryCubit, OrdersHistoryState>(
        builder: (context, state) {
          if (state.status == FormStatus.getOrdersHistoryLoading) {
            return Center(
              child: Lottie.asset(AppLotties.loader, width: 320, height: 320),
            );
          } else if (state.status == FormStatus.getOrdersHistorySuccess) {
            if (state.ordersHistory.isNotEmpty) {
              return ListView.separated(
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.mentourNavigationBarBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.mentourBorder1),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            state.ordersHistory[index].productImage,
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.ordersHistory[index].productTitle,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: t.mentourText3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMM yyyy').format(
                                  DateTime.parse(
                                    state.ordersHistory[index].date,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: t.mentourText2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "-${state.ordersHistory[index].coins}",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: t.mentourError,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
                itemCount: state.ordersHistory.length,
              );
            } else {
              return Center(child: Text("Hozircha hech qanday ma'lumot yo'q"));
            }
          } else if (state.status == FormStatus.getOrdersHistoryFailure) {
            return Center(child: Text(state.errorMessage));
          } else {
            return Center(child: Text(state.errorMessage));
          }
        },
      ),
    );
  }
}
