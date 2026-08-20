import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/helpers/no_emoji_input_formatter.dart';

class CustomTextField extends StatefulWidget {
  final String textFieldLabel;
  final String hinText;
  final TextEditingController controller;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.textFieldLabel,
    required this.hinText,
    required this.controller,
    this.isPassword = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: TextStyle(fontWeight: FontWeight.w800),
          obscureText: widget.isPassword ? _isObscure : false,
          keyboardType: TextInputType.visiblePassword,
          controller: widget.controller,
          inputFormatters: [NoEmojiInputFormatter()],
          decoration: InputDecoration(
            hintText: widget.hinText,
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            filled: true,
            fillColor: Theme.of(context).mentourNavigationBarBg,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).mentourBorder1,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).mentourBorder1,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).mentourBorder1,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).mentourBorder1,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).mentourBorder1,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}
