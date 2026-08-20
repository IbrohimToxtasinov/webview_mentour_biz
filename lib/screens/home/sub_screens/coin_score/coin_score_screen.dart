import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/profile/profile_bloc.dart';
import 'package:mentour_web_view/cubits/coins_market_products/coins_market_products_cubit.dart';
import 'package:mentour_web_view/data/models/product/product_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';
import 'package:mentour_web_view/ui_kit/widgets/rows/build_stats_row.dart';
import 'package:mentour_web_view/utils/app_icons.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class CoinScoreScreen extends StatefulWidget {
  final String schoolId;

  const CoinScoreScreen({super.key, required this.schoolId});

  @override
  State<CoinScoreScreen> createState() => _CoinScoreScreenState();
}

class _CoinScoreScreenState extends State<CoinScoreScreen> {
  @override
  void initState() {
    context.read<CoinsMarketProductsCubit>().getCoinMarketProducts(
      schoolId: widget.schoolId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: t.mentourBg1,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              top: 60,
              left: 16,
              right: 16,
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BuildStatsRow(
                        score: profileState.profileModel.score,
                        coins: profileState.profileModel.coins,
                      ),
                      SizedBox(height: 10),
                      // Stack(
                      //   children: [
                      //     MainActionButton(
                      //       labelFontSize: 16,
                      //       height: 40,
                      //       onTap: () {
                      //         // Navigator.push(
                      //         //   context,
                      //         //   MaterialPageRoute(
                      //         //     builder: (_) =>
                      //         //         const CoinsAndOrderHistoryScreen(),
                      //         //   ),
                      //         // )
                      //       },
                      //       label: "coins_orders_history".tr(),
                      //     ),
                      //     Positioned(
                      //       top: 8,
                      //       right: 12,
                      //       child: SoonBadge(bgColor: t.mentourBlack),
                      //     ),
                      //   ],
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "coins_market".tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: t.mentourText3,
                          ),
                        ),
                      ),
                      Expanded(
                        child:
                            BlocConsumer<
                              CoinsMarketProductsCubit,
                              CoinsMarketProductsState
                            >(
                              listener: (context, state) {
                                if (state.status ==
                                    FormStatus.orderCreateSuccess) {
                                  showOverlayMessage(
                                    context,
                                    status: OverlayStatus.success,
                                    text: "order_create_success".tr(),
                                  );
                                  context.read<ProfileBloc>().add(
                                    GetProfileInfo(),
                                  );
                                  context
                                      .read<CoinsMarketProductsCubit>()
                                      .getCoinMarketProducts(
                                        schoolId: widget.schoolId,
                                      );
                                }
                                if (state.status ==
                                    FormStatus.orderCreateFailure) {
                                  showOverlayMessage(
                                    context,
                                    text: "order_create_fail".tr(),
                                  );
                                  context
                                      .read<CoinsMarketProductsCubit>()
                                      .getCoinMarketProducts(
                                        schoolId: widget.schoolId,
                                      );
                                }
                              },
                              builder: (context, state) {
                                if (state.status ==
                                    FormStatus.getCoinMarketProductsLoading) {
                                  return Center(
                                    child: Lottie.asset(
                                      AppLotties.loader,
                                      width: 320,
                                      height: 320,
                                    ),
                                  );
                                } else if (state.status ==
                                    FormStatus.getCoinMarketProductsSuccess) {
                                  if (state.products.isEmpty) {
                                    return Center(
                                      child: Column(
                                        children: [
                                          Lottie.asset(AppLotties.empty),
                                          Text(
                                            tr("coins_market_empty"),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: t.mentourText3,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return GridView.builder(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      itemCount: state.products.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                            childAspectRatio: 0.75.w,
                                          ),
                                      itemBuilder: (context, index) {
                                        return _ProductCard(
                                          product: state.products[index],
                                          userCoins:
                                              profileState.profileModel.coins,
                                        );
                                      },
                                    );
                                  }
                                } else if (state.status ==
                                    FormStatus.getCoinMarketProductsFailure) {
                                  return Center(
                                    child: Text(state.errorMessage),
                                  );
                                } else {
                                  return Center(
                                    child: Lottie.asset(
                                      AppLotties.loader,
                                      width: 320,
                                      height: 320,
                                    ),
                                  );
                                }
                              },
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),

            /// TOP BAR
            Positioned(
              left: 0,
              right: 0,
              top: 0,
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
                        "coin_score".tr(),
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

/// --------------------
/// PRODUCT CARD
/// --------------------
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final int userCoins;

  const _ProductCard({required this.product, required this.userCoins});

  void _showProductSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailBottomSheetScreen(
        product: product,
        userCanBuyCount: min(product.quantity, userCoins ~/ product.price),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final bool canBuy = userCoins >= product.price;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.mentourNavigationBarBg,
        border: Border.all(color: t.mentourBorder1, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          Center(
            child: Container(
              height: 105,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(product.attachment.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// TITLE
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: t.mentourText3,
            ),
          ),

          const SizedBox(height: 4),

          /// ITEMS LEFT
          Text(
            "${tr("items_left")}: ${product.quantity}",
            style: TextStyle(
              fontSize: 11,
              color: t.mentourText2,
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          /// BUY BUTTON
          MainActionButton(
            disabledColor: Colors.grey,
            height: 34,
            labelFontSize: 13,
            enabled: canBuy,
            onTap: () => _showProductSheet(context),
            label: "${product.price} coins",
          ),
        ],
      ),
    );
  }
}

class ProductDetailBottomSheetScreen extends StatefulWidget {
  final ProductModel product;
  final int userCanBuyCount;

  const ProductDetailBottomSheetScreen({
    required this.product,
    super.key,
    required this.userCanBuyCount,
  });

  @override
  State<ProductDetailBottomSheetScreen> createState() =>
      _ProductDetailBottomSheetScreenState();
}

class _ProductDetailBottomSheetScreenState
    extends State<ProductDetailBottomSheetScreen> {
  int count = 1;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: t.mentourBg1,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(18),
                      topLeft: Radius.circular(18),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(widget.product.attachment.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12, right: 12, top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          color: t.mentourText3,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.coin,
                              height: 24,
                              width: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${NumberFormat.decimalPattern('uz_UZ').format(widget.product.price)} coins',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF22C55E),
                                fontSize: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${tr("items_left")}: ${widget.product.quantity.toInt()}",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: t.mentourPrimary2,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(12, 10, 12, 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: t.mentourBorder1, width: 2),
                      color: t.mentourNavigationBarBg,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: t.mentourBorder1,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: t.mentourBorder1,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  highlightColor: Colors.transparent,
                                  onPressed: () {
                                    setState(() {
                                      if (count != 1) {
                                        count--;
                                        return;
                                      }
                                    });
                                  },
                                  icon: SvgPicture.asset(
                                    width:
                                        MediaQuery.of(context).size.width > 600
                                        ? 5
                                        : null,
                                    height:
                                        MediaQuery.of(context).size.width > 600
                                        ? 5
                                        : null,
                                    AppIcons.minus,
                                    colorFilter: ColorFilter.mode(
                                      count == 1
                                          ? t.mentourText3.withOpacity(0.15)
                                          : t.mentourText3,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                Text(
                                  count.toString(),
                                  style: TextStyle(
                                    color: t.mentourPrimary2,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  highlightColor: Colors.transparent,
                                  onPressed: () {
                                    if (widget.product.quantity != count &&
                                        count < widget.userCanBuyCount) {
                                      setState(() {
                                        if (count != 1000) {
                                          count++;
                                        }
                                      });
                                    }
                                  },
                                  icon: SvgPicture.asset(
                                    width:
                                        MediaQuery.of(context).size.width > 600
                                        ? 18
                                        : null,
                                    height:
                                        MediaQuery.of(context).size.width > 600
                                        ? 18
                                        : null,
                                    AppIcons.plus,
                                    colorFilter: ColorFilter.mode(
                                      widget.product.quantity != count &&
                                              count < widget.userCanBuyCount
                                          ? t.mentourText3
                                          : t.mentourText3.withOpacity(0.15),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MainActionButton(
                            onTap: () {
                              context
                                  .read<CoinsMarketProductsCubit>()
                                  .orderCreate(
                                    itemUuid: widget.product.uuid,
                                    count: count,
                                  );
                              Navigator.pop(context);
                            },
                            label: "order_create".tr(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10.0.h,
              right: 10.0.w,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                  height: 38,
                  width: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: t.mentourBorder1, width: 2),
                    color: t.mentourNavigationBarBg,
                  ),
                  child: Icon(Icons.clear, size: 21, color: t.mentourText3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
