import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class KaaMaterialLocalizations extends DefaultMaterialLocalizations {
  const KaaMaterialLocalizations();

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _KaaMaterialLocalizationsDelegate();

  @override
  String get alertDialogLabel => 'Eskertiw';

  @override
  String get okButtonLabel => 'Tastıqlaw';

  @override
  String get cancelButtonLabel => 'Biykarlaw';

  @override
  String get cutButtonLabel => 'Kesiw';

  @override
  String get copyButtonLabel => 'Kóshirip alıw';

  @override
  String get pasteButtonLabel => 'Qoyıw';

  @override
  String get selectAllButtonLabel => 'Hammasın tanlaw';

  @override
  String get lookUpButtonLabel => 'Izlew';

  @override
  String get searchWebButtonLabel => 'Internetten izlew';

  @override
  String get shareButtonLabel => 'Bólisiw';

  // Time / Date picker
  @override
  String get anteMeridiemAbbreviation => 'Peshin';

  @override
  String get postMeridiemAbbreviation => 'Peshinden keyin';

  @override
  String get timePickerHourModeAnnouncement => 'Saattı tanlaw rejimi';

  @override
  String get timePickerMinuteModeAnnouncement => 'Daqiqanı tanlaw rejimi';

  @override
  String get timePickerDialHelpText => 'Waqıttı tanlań';

  @override
  String get timePickerInputHelpText => 'Waqıttı kiriń';

  @override
  String get timePickerHourLabel => 'Saat';

  @override
  String get timePickerMinuteLabel => 'Daqiqa';

  @override
  String get unspecifiedDate => 'Sáne kórsetilmegen';

  @override
  String get unspecifiedDateRange => 'Sáne diapazonı kórsetilmegen';

  @override
  String get dateInputLabel => 'Sáne kiriń';

  @override
  String get dateRangeStartLabel => 'Baslanıw sánesi';

  @override
  String get dateRangeEndLabel => 'Tamamlanıw sánesi';

  // Accessibility / Semantics
  @override
  String get modalBarrierDismissLabel => 'Jabiw';

  @override
  String get signedInLabel => 'Kirildi';

  @override
  String get hideAccountsLabel => 'Akkauntlardı jasırıw';

  @override
  String get showAccountsLabel => 'Akkauntlardı kórsetiw';

  // Navigation & Tabs
  @override
  String get previousMonthTooltip => 'Aldıńǵı ay';

  @override
  String get nextMonthTooltip => 'Keyingi ay';

  @override
  String get previousPageTooltip => 'Aldıńǵı bet';

  @override
  String get nextPageTooltip => 'Keyingi bet';

  @override
  String get showMenuTooltip => 'Menyunı kórsetiw';

  String get aboutListTileTitleRaw => r'$applicationName haqqında';

  @override
  String get licensesPageTitle => 'Licenziyalar';

  String get pageRowsInfoTitleRaw => r'$firstRow–$lastRow of $rowCount';

  @override
  String get rowsPerPageTitle => 'Bet tegi qatarlar:';

  // Text field / Input
  @override
  String get keyboardKeyAlt => 'Alt';

  @override
  String get keyboardKeyControl => 'Ctrl';

  @override
  String get keyboardKeyMeta => 'Meta';

  @override
  String get keyboardKeyShift => 'Shift';

  @override
  String get scrimLabel => 'Saya';

  @override
  String get openAppDrawerTooltip => 'Navigatsiya menyusın ashıw';

  @override
  String get backButtonTooltip => 'Artqa';

  @override
  String get closeButtonTooltip => 'Jabiw';

  @override
  String get deleteButtonTooltip => 'Óshiriw';

  @override
  String get moreButtonTooltip => 'Táǵı';

  @override
  String get refreshIndicatorSemanticLabel => 'Jańılaw';

  @override
  String get collapsedHint => 'Jayıw';

  @override
  String get expandedHint => 'Jıynıw';

  @override
  String get expansionTileCollapsedHint => 'eki ret basıń jıynıw úshin';

  @override
  String get expansionTileExpandedHint =>
      'eki ret basıń jayıw úshi'
      'n';

  @override
  String get reorderItemDown => 'Tómenge kóshiriw';

  @override
  String get reorderItemLeft => 'Solǵa kóshiriw';

  @override
  String get reorderItemRight => 'Ońǵa kóshiriw';

  @override
  String get reorderItemToEnd => 'Aqırına kóshiriw';

  @override
  String get reorderItemToStart => 'Basına kóshiriw';

  @override
  String get reorderItemUp => 'Joqarıǵa kóshiriw';

  @override
  String get menuBarMenuLabel => 'Menyu paneli menyusi';

  String get unspecified => 'kórsetilmegen';

  @override
  String get selectYearSemanticsLabel => r'Jıldı tanlaw $selectedYear';
}

class _KaaMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _KaaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'kaa';

  @override
  Future<KaaMaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<KaaMaterialLocalizations>(
      const KaaMaterialLocalizations(),
    );
  }

  @override
  bool shouldReload(_KaaMaterialLocalizationsDelegate old) => false;
}
