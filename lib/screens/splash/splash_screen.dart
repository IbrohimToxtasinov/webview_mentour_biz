import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentour_web_view/blocs/auth/auth_bloc.dart';
import 'package:mentour_web_view/data/repositories/singletons/secure_storage.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/stadium_gradient_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/auth_status.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _handleAutoSignIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final extUsername = prefs.getString('ext_username');
      final extPassword = prefs.getString('ext_password');
      if (extUsername != null &&
          extUsername.isNotEmpty &&
          extPassword != null &&
          extPassword.isNotEmpty) {
        if (mounted) {
          context.read<AuthBloc>().add(
            AutoSignIn(userName: extUsername, password: extPassword),
          );
        }
      } else {
        final existingToken = await SecureStorage.get(key: "accessToken");
        if (existingToken != null && existingToken.isNotEmpty) {
          _navigateToHome();
        } else {
          if (mounted) {
            showOverlayMessage(context, text: "credentials_not_found".tr());
            context.read<AuthBloc>().add(const LogOut());
          }
        }
      }
    } catch (_) {
      if (mounted) {
        showOverlayMessage(context, text: "credentials_not_found".tr());
      }
    }
  }

  Future<void> _init() async {
    final token = await SecureStorage.get(key: "accessToken");
    if (token != null && token.isNotEmpty) {
      _navigateToHome();
    } else {
      await _handleAutoSignIn();
    }
  }

  void _navigateToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacementNamed(context, AppRouterNames.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: t.newMentourBg1,
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.formStatus != current.formStatus ||
            previous.authStatus != current.authStatus,
        listener: (context, state) {
          if (state.formStatus == FormStatus.signInSuccess ||
              state.formStatus == FormStatus.checkUserInSuccess ||
              state.formStatus == FormStatus.getProfileInfoInSuccess ||
              state.authStatus == AuthStatus.authenticated) {
            _navigateToHome();
          }
        },
        builder: (context, authState) {
          final isSignInFailed =
              authState.formStatus == FormStatus.signInFailure ||
              authState.formStatus == FormStatus.checkUserInFailure ||
              authState.formStatus == FormStatus.getProfileInfoInFailure ||
              (authState.authStatus == AuthStatus.unauthenticated &&
                  authState.formStatus != FormStatus.pure &&
                  authState.formStatus != FormStatus.signInLoading);

          if (isSignInFailed) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.appLogo,
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 24),
                    if (authState.errorMessage.isNotEmpty) ...[
                      Text(
                        authState.errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: t.newMentourText2,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      Text(
                        "credentials_not_found".tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: t.newMentourText2,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    StadiumGradientButton(
                      label: "try_again".tr(),
                      onTap: _handleAutoSignIn,
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.appLogo,
                  width: 140,
                  height: 140,
                ),
                const SizedBox(height: 32),
                CircularProgressIndicator(
                  color: t.newMentourPrimary2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

