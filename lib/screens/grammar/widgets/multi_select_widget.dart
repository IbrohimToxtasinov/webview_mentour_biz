import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/questions/questions_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class MultiSelectWidget extends StatefulWidget {
  final Question question;
  final ValueChanged<bool>? onFilledChange;
  final ValueChanged<List<String>>? onAnswersChange;
  final bool isReadOnly;

  const MultiSelectWidget({
    super.key,
    required this.question,
    this.onFilledChange,
    this.onAnswersChange,
    this.isReadOnly = false,
  });

  @override
  State<MultiSelectWidget> createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  final Set<String> _selectedOptionIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.question.preFilledAnswers.isNotEmpty) {
      final preFilledValue = widget.question.preFilledAnswers.values.first;
      if (preFilledValue.isNotEmpty) {
        _selectedOptionIds.addAll(preFilledValue.split(','));
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChanges();
    });
  }

  void _onOptionTapped(String optionId) {
    if (widget.isReadOnly) return;
    setState(() {
      if (_selectedOptionIds.contains(optionId)) {
        _selectedOptionIds.remove(optionId);
      } else {
        _selectedOptionIds.add(optionId);
      }
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final filled = _selectedOptionIds.isNotEmpty;
    final selectedIds = widget.question.content.options
        .where((opt) => _selectedOptionIds.contains(opt.id))
        .map((opt) => opt.id)
        .toList();

    widget.onFilledChange?.call(filled);
    widget.onAnswersChange?.call(selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.question.content.text.isNotEmpty ||
            widget.question.content.question.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: t.newMentourContainer20,
              border: Border.all(color: t.newMentourBorder2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.question.content.text.isNotEmpty) ...[
                  Text(
                    widget.question.content.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: t.mentourText3,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  if (widget.question.content.question.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Divider(
                      color: t.newMentourBorder2,
                      thickness: 1,
                      height: 0.8,
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
                if (widget.question.content.question.isNotEmpty)
                  Text(
                    widget.question.content.question,
                    style: TextStyle(
                      fontSize: 17,
                      color: t.mentourText3,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.question.content.options.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final option = widget.question.content.options[index];
            return _buildOptionItem(option);
          },
        ),
      ],
    );
  }

  Widget _buildOptionItem(SelectionOption option) {
    final t = Theme.of(context);
    final isSelected = _selectedOptionIds.contains(option.id);
    final bool hasImage = option.image.isNotEmpty && option.image != "null";

    return GestureDetector(
      onTap: () => _onOptionTapped(option.id),
      child: Container(
        padding: hasImage
            ? const EdgeInsets.all(8)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected && !hasImage
              ? t.newMentourPrimary2.withOpacity(0.08)
              : t.newMentourContainer20,
          border: Border.all(
            color: isSelected ? t.newMentourPrimary2 : t.newMentourBorder2,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? t.newMentourPrimary2 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? t.newMentourPrimary2
                      : t.newMentourBorder3,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: hasImage
                  ? Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          option.image,
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return SizedBox(
                              width: 80,
                              height: 80,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: t.newMentourPrimary2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              width: 80,
                              height: 80,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.redAccent,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Text(
                      option.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: t.mentourText3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
