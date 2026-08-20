import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/cubits/connectivity/connectivity_cubit.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/utils/app_images.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key, required this.voidCallback});

  final VoidCallback voidCallback;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return PopScope(
      canPop: false,
      child: BlocListener<ConnectivityCubit, ConnectivityState>(
        listener: (context, state) {
          if (state.connectivityResult != ConnectivityResult.none) {
            voidCallback.call();
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          backgroundColor: t.mentourBg2,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 100),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    textAlign: TextAlign.center,
                    "internet_error".tr(),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: LottieBuilder.asset(
                      AppLotties.noInternet,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 50),
                  child: MainActionButton(
                    label: "try_again".tr(),
                    onTap: () {
                      BlocProvider.of<ConnectivityCubit>(
                        context,
                      ).checkInternet();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
