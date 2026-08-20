import 'package:flutter/services.dart';

class NoEmojiInputFormatter extends TextInputFormatter {
  static final RegExp _emojiRegex = RegExp(
    // ignore: valid_regexps
    r'(\p{Emoji_Presentation}|\p{Emoji_Modifier}|\p{Emoji_Modifier_Base})',
    unicode: true,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(_emojiRegex, '');

    if (cleaned == newValue.text) {
      return newValue;
    }

    final newOffset = cleaned.length < newValue.selection.extentOffset
        ? cleaned.length
        : newValue.selection.extentOffset;

    return newValue.copyWith(
      text: cleaned,
      selection: TextSelection.collapsed(offset: newOffset),
      composing: TextRange.empty,
    );
  }
}
