import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class TgCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const TgCupertinoLocalizations();

  static const LocalizationsDelegate<CupertinoLocalizations> delegate =
      _TgCupertinoLocalizationsDelegate();

  @override
  String get alertDialogLabel => 'Огоҳлантириш';

  String get okButtonLabel => 'Тасдиқлаш';

  @override
  String get cancelButtonLabel => 'Бекор қилиш';

  String get timePickerHourModeAnnouncement => 'Соат танлаш режими';

  String get timePickerMinuteModeAnnouncement => 'Дақиқа танлаш режими';

  @override
  String get anteMeridiemAbbreviation => 'Пешин';

  @override
  String get postMeridiemAbbreviation => 'Пас аз пешин';

  @override
  String get todayLabel => 'Бугун';

  String get shortcutTodayLabel => 'Бугун';

  @override
  String get lookUpButtonLabel => 'Қидириш';

  @override
  String get searchWebButtonLabel => 'Интернетда қидириш';

  @override
  String get shareButtonLabel => 'Улашиш';

  @override
  String get modalBarrierDismissLabel => 'Ёпиш';
}

class _TgCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _TgCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';

  @override
  Future<TgCupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<TgCupertinoLocalizations>(
      const TgCupertinoLocalizations(),
    );
  }

  @override
  bool shouldReload(_TgCupertinoLocalizationsDelegate old) => false;
}
