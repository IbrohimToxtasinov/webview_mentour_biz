import 'dart:ui' as ui;
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/questions/questions_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/helpers/no_emoji_input_formatter.dart';

class GapFillWidget extends StatefulWidget {
  final Question question;
  final ValueChanged<bool>? onFilledChange;
  final ValueChanged<List<String>>? onAnswersChange;
  final bool isReadOnly;

  const GapFillWidget({
    super.key,
    required this.question,
    this.onFilledChange,
    this.onAnswersChange,
    this.isReadOnly = false,
  });

  @override
  State<GapFillWidget> createState() => _GapFillWidgetState();
}

class _GapFillWidgetState extends State<GapFillWidget> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final RegExp _placeholderRegex = RegExp(r'\{\{(\d+)\}\}');
  bool _lastFilledState = false;
  late final Map<String, String> _prefilled;
  late final Set<String> _lockedKeys;
  final ScrollController _scrollController = ScrollController();
  String? _activeKey;

  void _setActiveKey(String key) {
    if (_activeKey != key) {
      setState(() {
        _activeKey = key;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _prefilled = widget.question.preFilledAnswers;
    _lockedKeys = _prefilled.keys.toSet();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: t.newMentourContainer20,
        border: Border.all(color: t.newMentourBorder2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildRichText(context, t)],
          ),
        ),
      ),
    );
  }

  Widget _buildRichText(BuildContext context, ThemeData t) {
    final text = widget.question.content.text;
    final matches = _placeholderRegex.allMatches(text);
    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    final textKeys =
        widget.question.content.inputs
            .where((m) => m.values.first.mode.toUpperCase() == "TEXT")
            .map((m) => m.keys.first)
            .toList()
          ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    for (final match in matches) {
      if (match.start > lastIndex) {
        final prefix = text.substring(lastIndex, match.start);
        spans.add(TextSpan(text: prefix));
      }

      final placeholderKey = match.group(1)!;
      final inputData = _findInputByKey(placeholderKey);

      if (inputData != null) {
        final mode = inputData.mode.toUpperCase();

        if (mode == "TEXT") {
          final controllerExists = _controllers.containsKey(placeholderKey);
          final controller = _controllers.putIfAbsent(
            placeholderKey,
            () => TextEditingController(),
          );

          if (!controllerExists) {
            controller.addListener(_handleControllersChange);
            if (_prefilled.containsKey(placeholderKey)) {
              controller.text = _prefilled[placeholderKey] ?? "";
            }
          }

          final isEnabled =
              !widget.isReadOnly && !_lockedKeys.contains(placeholderKey);

          final enabledKeys = textKeys
              .where((k) => !_lockedKeys.contains(k))
              .toList();
          final isLastEnabled =
              enabledKeys.isNotEmpty && placeholderKey == enabledKeys.last;

          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(top: 2.5, bottom: 2.5),
                child: _GapFillTextField(
                  controller: controller,
                  hintText: inputData.hint.isNotEmpty
                      ? inputData.hint
                      : "type".tr(),
                  enabled: isEnabled,
                  isActive: _activeKey == placeholderKey,
                  onTap: () => _setActiveKey(placeholderKey),
                  textInputAction: isEnabled
                      ? (isLastEnabled
                            ? TextInputAction.done
                            : TextInputAction.next)
                      : TextInputAction.done,
                ),
              ),
            ),
          );
        } else if (mode == "DROPDOWN") {
          final existing = _dropdownValues.putIfAbsent(
            placeholderKey,
            () => _prefilled[placeholderKey] ?? "",
          );

          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(top: 2.5, bottom: 2.5),
                child: _GapFillDropdown(
                  value: existing.isEmpty ? null : existing,
                  options: inputData.options,
                  enabled:
                      !widget.isReadOnly &&
                      !_lockedKeys.contains(placeholderKey),
                  isActive: _activeKey == placeholderKey,
                  onTap: () => _setActiveKey(placeholderKey),
                  onChanged: (val) {
                    if (widget.isReadOnly ||
                        _lockedKeys.contains(placeholderKey)) {
                      return;
                    }
                    setState(() {
                      _dropdownValues[placeholderKey] = val ?? "";
                    });
                    _handleControllersChange();
                  },
                ),
              ),
            ),
          );
        } else {
          spans.add(TextSpan(text: text.substring(match.start, match.end)));
        }
      } else {
        spans.add(TextSpan(text: text.substring(match.start, match.end)));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: TextStyle(fontSize: 18, color: t.newMentourText4),
    );
  }

  Input? _findInputByKey(String key) {
    for (final inputMap in widget.question.content.inputs) {
      if (inputMap.containsKey(key)) {
        return inputMap[key];
      }
    }
    return null;
  }

  void _handleControllersChange() {
    final filled = _areAllFilled();
    final answers = _collectAnswers();
    if (filled != _lastFilledState) {
      _lastFilledState = filled;
      widget.onFilledChange?.call(filled);
    }
    widget.onAnswersChange?.call(answers);
  }

  bool _areAllFilled() {
    final requiredKeys = _requiredKeys();
    if (requiredKeys.isEmpty) return false;
    for (final key in requiredKeys) {
      final controller = _controllers[key];
      if (controller != null) {
        if (controller.text.trim().isEmpty) return false;
        continue;
      }
      final dropVal = _dropdownValues[key];
      if (dropVal == null || dropVal.isEmpty) return false;
    }
    return true;
  }

  List<String> _collectAnswers() {
    final keys = _requiredKeys()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    return keys.map((k) {
      if (_controllers.containsKey(k)) {
        return _controllers[k]!.text.trim();
      }
      return _dropdownValues[k] ?? "";
    }).toList();
  }

  List<String> _requiredKeys() {
    return widget.question.content.inputs.expand((m) => m.keys).toList();
  }
}

class _GapFillTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final bool isActive;
  final VoidCallback onTap;
  final TextInputAction textInputAction;

  const _GapFillTextField({
    required this.controller,
    required this.hintText,
    required this.enabled,
    required this.isActive,
    required this.onTap,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<_GapFillTextField> createState() => _GapFillTextFieldState();
}

class _GapFillTextFieldState extends State<_GapFillTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateWidth);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateWidth);
    super.dispose();
  }

  void _updateWidth() {
    setState(() {});
  }

  double _calculateWidth() {
    final text = widget.controller.text;
    final displayText = text.isNotEmpty ? text : widget.hintText;

    final textStyle = DefaultTextStyle.of(context).style.copyWith(
      fontSize: 14,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w500,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: displayText, style: textStyle),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();

    final paddingAndBorder = 30.0;
    final calculatedWidth = textPainter.width + paddingAndBorder;

    return calculatedWidth < 50 ? 50 : calculatedWidth;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final adaptiveWidth = _calculateWidth();
    final isSelected = widget.controller.text.isNotEmpty;

    final child = TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      keyboardType: TextInputType.visiblePassword,
      enableSuggestions: false,
      autocorrect: false,
      inputFormatters: [NoEmojiInputFormatter()],
      cursorColor: t.newMentourPrimary1,
      cursorWidth: 1.5,
      onTap: widget.enabled ? widget.onTap : null,
      style: TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        color: isSelected ? t.newMentourText4 : t.newMentourText11,
      ),
      contextMenuBuilder: (context, editableTextState) {
        return const SizedBox.shrink();
      },
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          color: t.newMentourText11,
        ),
        contentPadding: EdgeInsets.zero,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );

    final isDotted = !isSelected && widget.enabled && !widget.isActive;

    final container = AnimatedContainer(
      alignment: Alignment.center,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        left: 10,
        top: isDotted ? 3 : 4,
        bottom: isDotted ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: t.newMentourContainer16,
        borderRadius: BorderRadius.circular(16),
        border: isDotted
            ? null
            : Border.all(
                color: !widget.enabled
                    ? t.newMentourPrimary1
                    : (widget.isActive
                          ? t.newMentourText10
                          : t.newMentourBorder3),
              ),
      ),
      child: child,
    );

    return SizedBox(
      width: adaptiveWidth,
      child: Stack(
        children: [
          container,
          if (isDotted)
            Positioned.fill(
              child: IgnorePointer(
                child: DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    color: t.newMentourBorder3,
                    strokeWidth: 2,
                    dashPattern: const [4, 2],
                    radius: const Radius.circular(16),
                    padding: EdgeInsets.zero,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GapFillDropdown extends StatelessWidget {
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final bool isActive;
  final VoidCallback onTap;

  const _GapFillDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.enabled,
    required this.isActive,
    required this.onTap,
  });

  void _showOptionsTopSheet(BuildContext context, ThemeData t) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 12,
                      right: 16,
                      left: 16,
                      bottom: 4,
                    ),
                    decoration: BoxDecoration(
                      color: t.newMentourContainer21.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...options.map((option) {
                          final isSelected = value == option;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                onChanged(option);
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? t.newMentourPrimary2.withOpacity(0.9)
                                      : t.newMentourContainer22.withOpacity(
                                          0.9,
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? t.newMentourPrimary2
                                        : t.newMentourBorder2,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: t.newMentourText4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isSelected = value != null && value!.isNotEmpty;
    final displayText = isSelected ? value! : "select".tr();

    final child = Text(
      displayText,
      style: TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        color: isSelected ? t.newMentourText4 : t.newMentourText11,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final container = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: t.newMentourContainer16,
        borderRadius: BorderRadius.circular(16),
        border: isSelected || enabled
            ? Border.all(
                color: !enabled
                    ? t.newMentourPrimary1
                    : (isActive ? t.newMentourText10 : t.newMentourBorder3),
              )
            : null,
      ),
      child: child,
    );

    return GestureDetector(
      onTap: enabled
          ? () {
              onTap();
              _showOptionsTopSheet(context, t);
            }
          : null,
      child: !isSelected && enabled
          ? isActive
                ? container
                : DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: t.newMentourBorder3,
                      strokeWidth: 4,
                      dashPattern: const [4, 2],
                      radius: const Radius.circular(16),
                      padding: EdgeInsets.zero,
                    ),
                    child: AnimatedContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 3,
                      ),
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: t.newMentourContainer16,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: child,
                    ),
                  )
          : container,
    );
  }
}
