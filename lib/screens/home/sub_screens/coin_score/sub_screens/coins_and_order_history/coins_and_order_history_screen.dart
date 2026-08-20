import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/screens/home/sub_screens/coin_score/sub_screens/coins_and_order_history/widgets/coins_history_items_view.dart';
import 'package:mentour_web_view/screens/home/sub_screens/coin_score/sub_screens/coins_and_order_history/widgets/orders_history_items_view.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/arrow_back_button.dart';

/// ===================== ENUMS =====================
enum HistoryType { coinHistory, orderHistory }

enum CoinSource { grammar, vocabulary, listening, writing, reading }

/// ===================== MODELS =====================
class CoinHistoryItem {
  final CoinSource source;
  final String unitTitle;
  final DateTime date;
  final int coins;

  CoinHistoryItem({
    required this.source,
    required this.unitTitle,
    required this.date,
    required this.coins,
  });
}

class OrderHistoryItem {
  final String productTitle;
  final String productImage;
  final int coins;
  final DateTime date;

  OrderHistoryItem({
    required this.productTitle,
    required this.productImage,
    required this.coins,
    required this.date,
  });
}

/// ===================== SCREEN =====================
class CoinsAndOrderHistoryScreen extends StatefulWidget {
  const CoinsAndOrderHistoryScreen({super.key});

  @override
  State<CoinsAndOrderHistoryScreen> createState() =>
      _CoinsAndOrderHistoryScreenState();
}

class _CoinsAndOrderHistoryScreenState
    extends State<CoinsAndOrderHistoryScreen> {
  HistoryType type = HistoryType.coinHistory;

  /// ===================== MOCK DATA =====================
  final List<CoinHistoryItem> coinHistory = [
    CoinHistoryItem(
      source: CoinSource.grammar,
      unitTitle: "Unit 3 · Past Tense",
      date: DateTime.now().subtract(const Duration(days: 1)),
      coins: 20,
    ),
    CoinHistoryItem(
      source: CoinSource.vocabulary,
      unitTitle: "Food Vocabulary",
      date: DateTime.now().subtract(const Duration(days: 2)),
      coins: 15,
    ),
    CoinHistoryItem(
      source: CoinSource.listening,
      unitTitle: "Daily Conversation",
      date: DateTime.now().subtract(const Duration(days: 3)),
      coins: 10,
    ),
  ];

  final List<OrderHistoryItem> orderHistory = [
    OrderHistoryItem(
      productTitle: "Premium Avatar",
      productImage: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
      coins: 50,
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
    OrderHistoryItem(
      productTitle: "Dark Theme",
      productImage: "https://cdn-icons-png.flaticon.com/512/1829/1829586.png",
      coins: 30,
      date: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: t.mentourBg1,
      body: SafeArea(
        child: Column(
          children: [
            /// ===================== HEADER =====================
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ArrowBackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Coins & Order history".tr(),
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

            /// ===================== FILTER =====================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: t.mentourBorder1, width: 2),
                  color: t.mentourNavigationBarBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _FilterButton(
                      title: "Coins history",
                      selected: type == HistoryType.coinHistory,
                      onTap: () =>
                          setState(() => type = HistoryType.coinHistory),
                    ),
                    const SizedBox(width: 5),
                    _FilterButton(
                      title: "Orders history",
                      selected: type == HistoryType.orderHistory,
                      onTap: () =>
                          setState(() => type = HistoryType.orderHistory),
                    ),
                  ],
                ),
              ),
            ),

            /// ===================== LIST =====================
            Expanded(
              child: type == HistoryType.coinHistory
                  ? CoinsHistoryItemsView()
                  : OrdersHistoryItemsView(),
            ),
          ],
        ),
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
