import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class KaaCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const KaaCupertinoLocalizations();

  static const LocalizationsDelegate<CupertinoLocalizations> delegate =
      _KaaCupertinoLocalizationsDelegate();

  @override
  String get alertDialogLabel => 'Eskertiw';

  String get okButtonLabel => 'Tastıqlaw';

  @override
  String get cancelButtonLabel => 'Biykarlaw';

  String get timePickerHourModeAnnouncement => 'Saattı tanlaw rejimi';

  String get timePickerMinuteModeAnnouncement => 'Daqiqanı tanlaw rejimi';

  @override
  String get anteMeridiemAbbreviation => 'Peshin';

  @override
  String get postMeridiemAbbreviation => 'Peshinden keyin';

  @override
  String get todayLabel => 'Búgin';

  String get shortcutTodayLabel => 'Búgin';

  @override
  String get lookUpButtonLabel => 'Izlew';

  @override
  String get searchWebButtonLabel => 'Internetten izlew';

  @override
  String get shareButtonLabel => 'Bólisiw';

  @override
  String get modalBarrierDismissLabel => 'Jabiw';
}

class _KaaCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _KaaCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'kaa';

  @override
  Future<KaaCupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<KaaCupertinoLocalizations>(
      const KaaCupertinoLocalizations(),
    );
  }

  @override
  bool shouldReload(_KaaCupertinoLocalizationsDelegate old) => false;
}
