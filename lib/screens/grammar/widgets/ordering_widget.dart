import 'dart:math' as math;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/questions/questions_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

bool _isFillBlankMode(Question question) {
  final texts = question.content.texts;
  if (texts.isEmpty) return false;
  final placeholderRegex = RegExp(r'\{\{(\d+)\}\}');
  return texts.any((t) => placeholderRegex.hasMatch(t));
}

class OrderingWidget extends StatefulWidget {
  final Question question;
  final ValueChanged<bool>? onFilledChange;
  final ValueChanged<List<String>>? onAnswersChange;
  final bool isReadOnly;

  const OrderingWidget({
    super.key,
    required this.question,
    this.onFilledChange,
    this.onAnswersChange,
    this.isReadOnly = false,
  });

  @override
  State<OrderingWidget> createState() => _OrderingWidgetState();
}

class _OrderingWidgetState extends State<OrderingWidget>
    with SingleTickerProviderStateMixin {
  final List<String?> _selectedOrder = [];
  final List<OrderingWord> _availableWords = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  int? _previousNextSlotIndex;
  final Map<String, String?> _slotValues = {};
  final List<OrderingWord> _bankWords = [];
  late bool _fillBlankMode;
  final RegExp _placeholderRegex = RegExp(r'\{\{(\d+)\}\}');
  String? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    _fillBlankMode = _isFillBlankMode(widget.question);
    _initializeAnimation();
    if (_fillBlankMode) {
      _initFillBlank();
    } else {
      _initializeWords();
    }
  }

  void _initializeAnimation() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
  }

  void _triggerShakeAnimation() {
    _shakeController.reset();
    _shakeController.forward();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // ─── Classic ordering ────────────────────────────────────────────────────────

  void _initializeWords() {
    _availableWords.clear();
    _availableWords.addAll(widget.question.content.words);
    _selectedOrder.clear();
    final texts = widget.question.content.texts;
    final slotsCount = texts.isNotEmpty
        ? texts.length
        : widget.question.content.words.length;
    _selectedOrder.addAll(List.filled(slotsCount, null));
    _previousNextSlotIndex = _selectedOrder.indexWhere((item) => item == null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChanges();
      _triggerShakeAnimation();
    });
  }

  void _onWordTap(OrderingWord word) {
    if (widget.isReadOnly) return;
    setState(() {
      final emptyIndex = _selectedOrder.indexWhere((item) => item == null);
      if (emptyIndex != -1) {
        _selectedOrder[emptyIndex] = word.id;
        _availableWords.removeWhere((w) => w.id == word.id);
      }
    });
    _notifyChanges();
  }

  void _onSlotTap(int index) {
    if (widget.isReadOnly) return;
    if (_selectedOrder[index] != null) {
      setState(() {
        final wordId = _selectedOrder[index]!;
        final word = widget.question.content.words.firstWhere(
          (w) => w.id == wordId,
        );
        _availableWords.add(word);
        _selectedOrder[index] = null;
      });
      _notifyChanges();
    }
  }

  void _notifyChanges() {
    if (_fillBlankMode) {
      _notifyFillBlankChanges();
      return;
    }
    final filled = _selectedOrder.every((item) => item != null);
    final answers = _selectedOrder.where((item) => item != null).map((wordId) {
      final word = widget.question.content.words.firstWhere(
        (w) => w.id == wordId,
        orElse: () => OrderingWord(id: wordId!, text: ''),
      );
      return word.text;
    }).toList();
    widget.onFilledChange?.call(filled);
    widget.onAnswersChange?.call(answers);
  }

  void _initFillBlank() {
    final Set<String> placeholderIds = {};
    for (final text in widget.question.content.texts) {
      for (final m in _placeholderRegex.allMatches(text)) {
        placeholderIds.add(m.group(1)!);
      }
    }

    _slotValues.clear();
    for (final id in placeholderIds) {
      _slotValues[id] = null;
    }

    _bankWords
      ..clear()
      ..addAll(widget.question.content.words);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyFillBlankChanges();
      _triggerShakeAnimation();
    });
  }

  void _onBankWordTap(OrderingWord word) {
    if (widget.isReadOnly) return;
    String targetSlot = '';
    if (_selectedSlotId != null && _slotValues[_selectedSlotId] == null) {
      targetSlot = _selectedSlotId!;
    } else {
      targetSlot = _sortedSlotIds().firstWhere(
        (id) => _slotValues[id] == null,
        orElse: () => '',
      );
    }
    if (targetSlot.isEmpty) return;
    setState(() {
      _slotValues[targetSlot] = word.id;
      _bankWords.removeWhere((w) => w.id == word.id);
      _selectedSlotId = null;
    });
    _notifyFillBlankChanges();
  }

  void _onFilledSlotTap(String slotId) {
    if (widget.isReadOnly) return;
    final wordId = _slotValues[slotId];
    if (wordId == null) return;
    setState(() {
      final word = widget.question.content.words.firstWhere(
        (w) => w.id == wordId,
        orElse: () => OrderingWord(id: wordId, text: ''),
      );
      _bankWords.add(word);
      _slotValues[slotId] = null;
    });
    _notifyFillBlankChanges();
  }

  void _onEmptySlotTap(String slotId) {
    if (widget.isReadOnly) return;
    setState(() {
      _selectedSlotId = (_selectedSlotId == slotId) ? null : slotId;
    });
  }

  void _notifyFillBlankChanges() {
    final filled = _slotValues.values.every((v) => v != null);
    final answers = _sortedSlotIds().map((id) {
      final wordId = _slotValues[id];
      if (wordId == null) return '';
      return widget.question.content.words
          .firstWhere(
            (w) => w.id == wordId,
            orElse: () => OrderingWord(id: wordId, text: ''),
          )
          .text;
    }).toList();
    widget.onFilledChange?.call(filled);
    widget.onAnswersChange?.call(answers);
  }

  List<String> _sortedSlotIds() {
    final ids = _slotValues.keys.toList();
    ids.sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
    return ids;
  }

  @override
  Widget build(BuildContext context) {
    if (_fillBlankMode) return _buildFillBlank(context);
    return _buildClassicOrdering(context);
  }

  Widget _buildFillBlank(BuildContext context) {
    final t = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.question.content.text.isNotEmpty) ...[
            _buildPlainText(widget.question.content.text, t),
            const SizedBox(height: 16),
          ],
          if (_bankWords.isNotEmpty) ...[
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _bankWords
                    .map((word) => _buildBankWord(word))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.newMentourContainer20,
              border: Border.all(color: t.newMentourBorder2),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: widget.question.content.texts.map((text) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTextWithSlots(context, text, t),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextWithSlots(BuildContext context, String text, ThemeData t) {
    final matches = _placeholderRegex.allMatches(text).toList();
    if (matches.isEmpty) {
      return _buildRichLine(context, [TextSpan(text: text)], t);
    }

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      final slotId = match.group(1)!;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildFillSlot(slotId),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return _buildRichLine(context, spans, t);
  }

  Widget _buildRichLine(
    BuildContext context,
    List<InlineSpan> spans,
    ThemeData t,
  ) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 15,
          color: t.mentourText3,
          fontWeight: FontWeight.w600,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildFillSlot(String slotId) {
    final t = Theme.of(context);
    final wordId = _slotValues[slotId];
    final isEmpty = wordId == null;

    final firstEmptySlotId = _sortedSlotIds().firstWhere(
      (id) => _slotValues[id] == null,
      orElse: () => '',
    );
    final isNextToFill = isEmpty && slotId == firstEmptySlotId;
    final isSelected = _selectedSlotId == slotId;

    if (isEmpty) {
      Widget slotWidget;

      final solidSlot = Container(
        width: 70,
        height: 32,
        decoration: BoxDecoration(
          color: t.newMentourContainer23,
          borderRadius: BorderRadius.circular(48),
          border: Border.all(color: t.newMentourText10, width: 1.5),
        ),
      );

      if (isSelected) {
        slotWidget = solidSlot;
      } else if (isNextToFill && _selectedSlotId == null) {
        // Shake animation to indicate where the next word goes
        // (only when no slot is manually targeted)
        slotWidget = AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final shakeOffset =
                math.sin(_shakeAnimation.value * 2 * math.pi) * 4;
            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: child!,
            );
          },
          child: solidSlot,
        );
      } else {
        slotWidget = DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: const Radius.circular(48),
            color: t.newMentourBorder3,
            strokeWidth: 1.5,
            dashPattern: const [6, 4],
            padding: EdgeInsets.zero,
          ),
          child: Container(
            width: 70,
            height: 32,
            decoration: BoxDecoration(
              color: t.newMentourContainer23,
              borderRadius: BorderRadius.circular(48),
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: () => _onEmptySlotTap(slotId),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              slotWidget,
              const SizedBox(height: 3), // Match filled slot height pattern
            ],
          ),
        ),
      );
    }

    final word = widget.question.content.words.firstWhere(
      (w) => w.id == wordId,
      orElse: () => OrderingWord(id: wordId, text: ''),
    );

    return GestureDetector(
      onTap: () => _onFilledSlotTap(slotId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              color: t.newMentourText10,
              borderRadius: BorderRadius.circular(48),
            ),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: t.newMentourContainer22,
                borderRadius: BorderRadius.circular(48),
              ),
              child: Center(
                child: Text(
                  word.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: t.mentourText3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankWord(OrderingWord word) {
    final t = Theme.of(context);
    return GestureDetector(
      onTap: () => _onBankWordTap(word),
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: t.newMentourText10,
            borderRadius: BorderRadius.circular(48),
          ),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: t.newMentourContainer22,
              borderRadius: BorderRadius.circular(48),
            ),
            child: Center(
              child: Text(
                word.text,
                style: TextStyle(
                  fontSize: 15,
                  color: t.mentourText3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassicOrdering(BuildContext context) {
    final t = Theme.of(context);
    final currentNextSlotIndex = _selectedOrder.indexWhere(
      (item) => item == null,
    );
    if (currentNextSlotIndex != -1 &&
        currentNextSlotIndex != _previousNextSlotIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerShakeAnimation();
      });
      _previousNextSlotIndex = currentNextSlotIndex;
    }

    final texts = widget.question.content.texts;
    final hasTexts = texts.isNotEmpty && _selectedOrder.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.newMentourContainer20,
              border: Border.all(color: t.newMentourBorder2),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasTexts) ...[
                  ...texts.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final text = entry.value;
                    final hasSlot = idx < _selectedOrder.length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildPlainText(text, t),
                          if (hasSlot) _buildClassicSlot(idx),
                        ],
                      ),
                    );
                  }),
                ] else ...[
                  Center(
                    child: Wrap(
                      spacing: 13,
                      runSpacing: 13,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: List.generate(
                        _selectedOrder.length,
                        (index) => _buildClassicSlot(index),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 48),
          if (_availableWords.isNotEmpty)
            Center(
              child: Wrap(
                spacing: 13,
                runSpacing: 13,
                alignment: WrapAlignment.center,
                children: _availableWords
                    .map((word) => _buildWordButton(word))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlainText(String text, ThemeData t) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: t.mentourText3,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildClassicSlot(int index) {
    final t = Theme.of(context);
    final wordId = _selectedOrder[index];
    final isEmpty = wordId == null;
    final firstEmptyIndex = _selectedOrder.indexWhere((item) => item == null);
    final isNextToFill = isEmpty && index == firstEmptyIndex;

    final bool hasTexts = widget.question.content.texts.isNotEmpty;
    final double slotWidth = hasTexts ? 70 : 80;
    final double slotHeight = hasTexts ? 32 : 40;

    if (isEmpty) {
      Widget slotWidget = isNextToFill
          ? Container(
              width: slotWidth,
              height: slotHeight,
              decoration: BoxDecoration(
                color: t.newMentourContainer23,
                borderRadius: BorderRadius.circular(48),
                border: Border.all(color: t.newMentourText10, width: 1.5),
              ),
              child: Center(
                child: SizedBox(width: hasTexts ? 35 : 50, height: 16),
              ),
            )
          : DottedBorder(
              options: RoundedRectDottedBorderOptions(
                radius: const Radius.circular(48),
                color: t.newMentourBorder3,
                strokeWidth: 1.5,
                dashPattern: const [6, 4],
                padding: EdgeInsets.zero,
              ),
              child: Container(
                width: slotWidth,
                height: slotHeight,
                decoration: BoxDecoration(
                  color: t.newMentourContainer23,
                  borderRadius: BorderRadius.circular(48),
                ),
                child: Center(
                  child: SizedBox(width: hasTexts ? 40 : 60, height: 16),
                ),
              ),
            );

      if (isNextToFill) {
        slotWidget = AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final shakeOffset =
                (math.sin(_shakeAnimation.value * 2 * math.pi) * 4);
            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: child!,
            );
          },
          child: slotWidget,
        );
      }

      return GestureDetector(
        onTap: () => _onSlotTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            slotWidget,
            SizedBox(height: hasTexts ? 3 : 4),
          ],
        ),
      );
    }

    final word = widget.question.content.words.firstWhere(
      (w) => w.id == wordId,
      orElse: () => OrderingWord(id: wordId, text: ''),
    );

    return GestureDetector(
      onTap: () => _onSlotTap(index),
      child: Container(
        padding: EdgeInsets.only(bottom: hasTexts ? 3 : 4),
        decoration: BoxDecoration(
          color: t.newMentourText10,
          borderRadius: BorderRadius.circular(48),
        ),
        child: Container(
          height: slotHeight,
          padding: EdgeInsets.symmetric(horizontal: hasTexts ? 12 : 18),
          decoration: BoxDecoration(
            color: t.newMentourContainer22,
            borderRadius: BorderRadius.circular(48),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.text,
                style: TextStyle(
                  fontSize: hasTexts ? 15 : 18,
                  color: t.mentourText3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordButton(OrderingWord word) {
    final t = Theme.of(context);
    return GestureDetector(
      onTap: () => _onWordTap(word),
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: t.newMentourText10,
          borderRadius: BorderRadius.circular(48),
        ),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: t.newMentourContainer22,
            borderRadius: BorderRadius.circular(48),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.text,
                style: TextStyle(
                  fontSize: 15,
                  color: t.mentourText3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
