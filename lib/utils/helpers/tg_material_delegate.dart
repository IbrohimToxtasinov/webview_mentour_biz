import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TgMaterialLocalizations extends DefaultMaterialLocalizations {
  const TgMaterialLocalizations();

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _TgMaterialLocalizationsDelegate();

  @override
  String get alertDialogLabel => 'Огоҳлантириш';

  @override
  String get okButtonLabel => 'Тасдиқлаш';

  @override
  String get cancelButtonLabel => 'Бекор қилиш';

  @override
  String get cutButtonLabel => 'Кесиш';

  @override
  String get copyButtonLabel => 'Нусха олиш';

  @override
  String get pasteButtonLabel => 'Қўйиш';

  @override
  String get selectAllButtonLabel => 'Ҳаммасини танлаш';

  @override
  String get lookUpButtonLabel => 'Қидириш';

  @override
  String get searchWebButtonLabel => 'Интернетда қидириш';

  @override
  String get shareButtonLabel => 'Улашиш';

  @override
  String get anteMeridiemAbbreviation => 'Пешин';

  @override
  String get postMeridiemAbbreviation => 'Пас аз пешин';

  @override
  String get timePickerHourModeAnnouncement => 'Соат танлаш режими';

  @override
  String get timePickerMinuteModeAnnouncement => 'Дақиқа танлаш режими';

  @override
  String get timePickerDialHelpText => 'Вақтни танланг';

  @override
  String get timePickerInputHelpText => 'Вақтни киритинг';

  @override
  String get timePickerHourLabel => 'Соат';

  @override
  String get timePickerMinuteLabel => 'Дақиқа';

  @override
  String get unspecifiedDate => 'Сана кўрсатилмаган';

  @override
  String get unspecifiedDateRange => 'Сана диапазони кўрсатилмаган';

  @override
  String get dateInputLabel => 'Сана киритинг';

  @override
  String get dateRangeStartLabel => 'Бошланиш санаси';

  @override
  String get dateRangeEndLabel => 'Тугаш санаси';

  @override
  String get modalBarrierDismissLabel => 'Ёпиш';

  @override
  String get signedInLabel => 'Кириб бўлинди';

  @override
  String get hideAccountsLabel => 'Ҳисобларни яшириш';

  @override
  String get showAccountsLabel => 'Ҳисобларни кўрсатиш';

  @override
  String get previousMonthTooltip => 'Олдинги ой';

  @override
  String get nextMonthTooltip => 'Кейинги ой';

  @override
  String get previousPageTooltip => 'Олдинги саҳифа';

  @override
  String get nextPageTooltip => 'Кейинги саҳифа';

  @override
  String get showMenuTooltip => 'Менюни кўрсатиш';

  String get aboutListTileTitleRaw => r'$applicationName ҳақида';

  @override
  String get licensesPageTitle => 'Лицензиялар';

  String get pageRowsInfoTitleRaw => r'$firstRow–$lastRow of $rowCount';

  @override
  String get rowsPerPageTitle => 'Саҳифадаги қаторлар:';

  @override
  String get keyboardKeyAlt => 'Alt';

  @override
  String get keyboardKeyControl => 'Ctrl';

  @override
  String get keyboardKeyMeta => 'Meta';

  @override
  String get keyboardKeyShift => 'Shift';

  @override
  String get scrimLabel => 'Соя';

  @override
  String get openAppDrawerTooltip => 'Навигация менюсини очиш';

  @override
  String get backButtonTooltip => 'Орқага';

  @override
  String get closeButtonTooltip => 'Ёпиш';

  @override
  String get deleteButtonTooltip => 'Ўчириш';

  @override
  String get moreButtonTooltip => 'Яна';

  @override
  String get refreshIndicatorSemanticLabel => 'Янгилаш';

  @override
  String get collapsedHint => 'Кенгайтириш';

  @override
  String get expandedHint => 'Йиғиш';

  @override
  String get expansionTileCollapsedHint => 'икки марта босинг йиғиш учун';

  @override
  String get expansionTileExpandedHint => 'икки марта босинг кенгайтириш учун';

  @override
  String get reorderItemDown => 'Пастга кўчириш';

  @override
  String get reorderItemLeft => 'Чапга кўчириш';

  @override
  String get reorderItemRight => 'Ўнгга кўчириш';

  @override
  String get reorderItemToEnd => 'Охирига кўчириш';

  @override
  String get reorderItemToStart => 'Бошига кўчириш';

  @override
  String get reorderItemUp => 'Юқорига кўчириш';

  @override
  String get menuBarMenuLabel => 'Меню панели менюси';

  String get unspecified => 'кўрсатилмаган';

  @override
  String get selectYearSemanticsLabel => r'Йил танлаш $selectedYear';
}

class _TgMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _TgMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tg';

  @override
  Future<TgMaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<TgMaterialLocalizations>(
      const TgMaterialLocalizations(),
    );
  }

  @override
  bool shouldReload(_TgMaterialLocalizationsDelegate old) => false;
}
