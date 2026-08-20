import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/questions/questions_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class CircleWidget extends StatefulWidget {
  final Question question;
  final ValueChanged<bool>? onFilledChange;
  final ValueChanged<List<String>>? onAnswersChange;
  final bool isReadOnly;

  const CircleWidget({
    super.key,
    required this.question,
    this.onFilledChange,
    this.onAnswersChange,
    this.isReadOnly = false,
  });

  @override
  State<CircleWidget> createState() => _CircleWidgetState();
}

class _CircleWidgetState extends State<CircleWidget> {
  final Set<String> _selectedCharIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChanges();
    });
  }

  void _onCharTapped(String charId) {
    if (widget.isReadOnly) return;
    setState(() {
      if (_selectedCharIds.contains(charId)) {
        _selectedCharIds.remove(charId);
      } else {
        _selectedCharIds.add(charId);
      }
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final filled = _selectedCharIds.isNotEmpty;
    widget.onFilledChange?.call(filled);
    widget.onAnswersChange?.call(_selectedCharIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: t.newMentourContainer20,
        border: Border.all(color: t.newMentourBorder2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.question.content.parts.map((part) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: part.chars.map((char) => _buildCharItem(char)).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCharItem(CircleChar char) {
    final t = Theme.of(context);
    final isSelected = _selectedCharIds.contains(char.id);

    return GestureDetector(
      onTap: () => _onCharTapped(char.id),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Letter Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(minWidth: 20),
            child: Text(
              char.value.toLowerCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                color: t.mentourText3,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
          // Circle overlay when selected
          IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? t.newMentourPrimary2 : Colors.transparent,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
