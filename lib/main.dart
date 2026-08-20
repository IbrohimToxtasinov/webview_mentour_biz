import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mentour_web_view/app/app.dart';
import 'package:mentour_web_view/data/repositories/singletons/storage.dart';
import 'package:mentour_web_view/services/di/locator.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await slInit();
    } catch (e, stack) {
      print('slInit error: $e\n$stack');
    }

    try {
      await StorageRepository.getInstance();
    } catch (e, stack) {
      print('StorageRepository error: $e\n$stack');
    }

    try {
      await EasyLocalization.ensureInitialized();
    } catch (e, stack) {
      print('EasyLocalization error: $e\n$stack');
    }

    try {
      await initializeDateFormatting();
    } catch (e, stack) {
      print('initializeDateFormatting error: $e\n$stack');
    }

    if (!kIsWeb) {
      try {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } catch (e) {
        print('SystemChrome error: $e');
      }
    }

    runApp(
      EasyLocalization(
        startLocale: const Locale('en'),
        supportedLocales: const [
          Locale('uz'),
          Locale('ru'),
          Locale('en'),
          Locale('ky'),
          Locale('tg'),
          Locale('kaa'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        saveLocale: true,
        child: const App(),
      ),
    );
  }, (error, stackTrace) {
    print('Flutter Global Error: $error\n$stackTrace');
  });
}

