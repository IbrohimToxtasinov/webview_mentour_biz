import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mentour_web_view/blocs/auth/auth_bloc.dart';
import 'package:mentour_web_view/blocs/course/course_bloc.dart';
import 'package:mentour_web_view/blocs/group/group_bloc.dart';
import 'package:mentour_web_view/blocs/home_works/home_work_bloc.dart';
import 'package:mentour_web_view/blocs/profile/profile_bloc.dart';
import 'package:mentour_web_view/blocs/tab/navigator_bloc.dart';
import 'package:mentour_web_view/blocs/unit_detail/unit_detail_bloc.dart';
import 'package:mentour_web_view/cubits/active_homework/active_homework_cubit.dart';
import 'package:mentour_web_view/cubits/coins_market_products/coins_market_products_cubit.dart';
import 'package:mentour_web_view/cubits/connectivity/connectivity_cubit.dart';
import 'package:mentour_web_view/cubits/file_upload/file_upload_cubit.dart';
import 'package:mentour_web_view/cubits/settings/settings_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/cubits/vocabulary_detail/vocabulary_detail_cubit.dart';
import 'package:mentour_web_view/cubits/exam/exam_cubit.dart';
import 'package:mentour_web_view/cubits/exam_timer/exam_timer_cubit.dart';
import 'package:mentour_web_view/data/repositories/home_works_repository.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/ui_kit/theme/theme.dart';
import 'package:mentour_web_view/utils/helpers/tg_cupertino_delegate.dart';
import 'package:mentour_web_view/utils/helpers/tg_material_delegate.dart';
import 'package:mentour_web_view/utils/helpers/kaa_cupertino_delegate.dart';
import 'package:mentour_web_view/utils/helpers/kaa_material_delegate.dart';
import 'package:mentour_web_view/utils/navigator_key.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ConnectivityCubit()),
        BlocProvider(create: (context) => ActiveHomeworkCubit()),
        BlocProvider(create: (context) => UnitSectionDetailCubit()),
        BlocProvider(create: (context) => VocabularyDetailCubit()),
        BlocProvider(create: (context) => UnitDetailBloc()),
        BlocProvider(create: (context) => HomeworkBloc()),
        BlocProvider(create: (context) => CourseBloc()),
        BlocProvider(create: (context) => GroupBloc()),
        BlocProvider(create: (context) => NavigatorBloc()),
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(create: (context) => AuthBloc()..add(CheckAuthStatus())),
        BlocProvider(create: (context) => ProfileBloc()),
        BlocProvider(create: (context) => CoinsMarketProductsCubit()),
        BlocProvider(create: (context) => FileUploadCubit()),
        BlocProvider(create: (context) => ExamTimerCubit()),
        BlocProvider(
          create: (context) => ExamCubit(sl.get<HomeworksRepository>()),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child!,
                );
              },
              theme: MentourTheme.lightTheme,
              darkTheme: MentourTheme.darkTheme,
              themeMode: state.themeMode,
              title: "mentour",
              localizationsDelegates: [
                ...context.localizationDelegates,
                TgCupertinoLocalizations.delegate,
                TgMaterialLocalizations.delegate,
                KaaCupertinoLocalizations.delegate,
                KaaMaterialLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: AppRouterNames.splashRoute,
            );
          },
        );
      },
    );
  }
}
