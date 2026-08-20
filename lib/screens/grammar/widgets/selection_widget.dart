import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/questions/questions_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class SelectionWidget extends StatefulWidget {
  final Question question;
  final ValueChanged<bool>? onFilledChange;
  final ValueChanged<String?>? onAnswerChange;
  final bool isReadOnly;

  const SelectionWidget({
    super.key,
    required this.question,
    this.onFilledChange,
    this.onAnswerChange,
    this.isReadOnly = false,
  });

  @override
  State<SelectionWidget> createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {
  String? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    if (widget.question.preFilledAnswers.isNotEmpty) {
      final preFilledValue = widget.question.preFilledAnswers.values.first;
      if (preFilledValue.isNotEmpty) {
        _selectedOptionId = preFilledValue;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChanges();
    });
  }

  void _onOptionSelected(String optionId) {
    if (widget.isReadOnly) return;
    setState(() {
      _selectedOptionId = optionId;
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final filled = _selectedOptionId != null && _selectedOptionId!.isNotEmpty;
    widget.onFilledChange?.call(filled);
    widget.onAnswerChange?.call(_selectedOptionId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).mentourSidebarItem0,
            Theme.of(context).mentourSidebarItem1,
            Theme.of(context).mentourSidebarItem2,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.question.content.text.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).mentourBg2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.question.content.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).mentourIconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            // Display question if available
            if (widget.question.content.question.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).mentourBg2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.question.content.question,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).mentourIconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (widget.question.content.options.isNotEmpty) ...[
              SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: widget.question.content.options
                    .map((option) => _buildOptionButton(option))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(SelectionOption option) {
    final isSelected = _selectedOptionId == option.id;
    return GestureDetector(
      onTap: () => _onOptionSelected(option.id),
      child: Container(
        height: 35,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          gradient: !isSelected
              ? LinearGradient(
                  colors: [
                    Theme.of(context).mentourSidebarItem0,
                    Theme.of(context).mentourSidebarItem1,
                    Theme.of(context).mentourSidebarItem2,
                  ],
                )
              : null,
          color: isSelected ? Theme.of(context).mentourPrimary1 : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1.5,
            color: isSelected
                ? Theme.of(context).mentourPrimary1
                : Theme.of(context).mentourIconColor.withOpacity(0.2),
          ),
        ),
        child: Text(
          option.text,
          style: TextStyle(
            fontSize: 15,
            color: isSelected
                ? Theme.of(context).mentourBlack
                : Theme.of(context).mentourIconColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
