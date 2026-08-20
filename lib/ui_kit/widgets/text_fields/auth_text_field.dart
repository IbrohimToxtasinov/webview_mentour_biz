import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/helpers/no_emoji_input_formatter.dart';

class MainAuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;

  const MainAuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
  });

  @override
  State<MainAuthTextField> createState() => _MainAuthTextField();
}

class _MainAuthTextField extends State<MainAuthTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    final labelColor = t.newMentourText4;
    final hintColor = t.newMentourText1;
    final fillColor = t.newMentourContainer28;
    final iconColor = t.newMentourText1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: labelColor,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.visiblePassword,
          obscureText: widget.isPassword ? _isObscure : false,
          inputFormatters: [NoEmojiInputFormatter()],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? t.mentourWhite : t.mentourBlack,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: hintColor,
            ),
            filled: true,
            fillColor: fillColor,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscure
                          ? Icons.lock_outline_rounded
                          : Icons.lock_open_rounded,
                      color: iconColor,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: t.newMentourPrimary2, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
