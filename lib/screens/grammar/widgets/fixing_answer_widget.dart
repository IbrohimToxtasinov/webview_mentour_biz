import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/questions/questions_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class FixingAnswerWidget extends StatefulWidget {
  final Question question;
  final ValueChanged<bool>? onFilledChange;
  final ValueChanged<String>? onAnswerChange;
  final bool isReadOnly;

  const FixingAnswerWidget({
    super.key,
    required this.question,
    this.onFilledChange,
    this.onAnswerChange,
    this.isReadOnly = false,
  });

  @override
  State<FixingAnswerWidget> createState() => _FixingAnswerWidgetState();
}

class _FixingAnswerWidgetState extends State<FixingAnswerWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.question.content.questionText,
    );
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onTextChanged();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final currentText = _controller.text;

    // Button is active as long as text is not empty.
    // The user is allowed to send the original text unchanged.
    final isNotEmpty = currentText.trim().isNotEmpty;

    widget.onFilledChange?.call(isNotEmpty);
    widget.onAnswerChange?.call(currentText.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.newMentourContainer20,
        border: Border.all(color: t.newMentourBorder2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _controller,
        maxLines: null,
        enabled: !widget.isReadOnly,
        style: TextStyle(
          fontSize: 16,
          color: t.mentourText3,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "fix_errors_here".tr(),
          hintStyle: TextStyle(
            fontSize: 16,
            color: t.newMentourText11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
