import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/questions/questions_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class MatchingWidget extends StatefulWidget {
  final Question question;
  final ValueChanged<bool>? onFilledChange;
  final ValueChanged<Map<String, String>>? onAnswersChange;
  final bool isReadOnly;

  const MatchingWidget({
    super.key,
    required this.question,
    this.onFilledChange,
    this.onAnswersChange,
    this.isReadOnly = false,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  final Map<String, String> _matches = {};

  String? _selectedRightId;

  String? _selectedLeftId;

  List<SelectionOption> get leftOptions => widget.question.content.leftOptions;

  List<SelectionOption> get rightOptions =>
      widget.question.content.rightOptions;

  @override
  void initState() {
    super.initState();
    if (widget.question.preFilledAnswers.isNotEmpty) {
      _matches.addAll(widget.question.preFilledAnswers);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChanges();
    });
  }

  void _notifyChanges() {
    final filled =
        leftOptions.isNotEmpty && _matches.length == leftOptions.length;
    widget.onFilledChange?.call(filled);
    widget.onAnswersChange?.call(_matches);
  }

  void _onWordBoxTap(SelectionOption opt) {
    if (widget.isReadOnly) return;

    if (_selectedLeftId != null) {
      setState(() {
        _matches[_selectedLeftId!] = opt.id;
        _selectedLeftId = null;
        _selectedRightId = null;
      });
      _notifyChanges();
    } else {
      setState(() {
        _selectedRightId = _selectedRightId == opt.id ? null : opt.id;
      });
    }
  }

  void _onSlotTap(String leftId) {
    if (widget.isReadOnly) return;

    if (_selectedRightId != null) {
      setState(() {
        _matches[leftId] = _selectedRightId!;
        _selectedRightId = null;
        _selectedLeftId = null;
      });
      _notifyChanges();
    } else if (_matches.containsKey(leftId)) {
      setState(() {
        _matches.remove(leftId);
        _selectedLeftId = null;
      });
      _notifyChanges();
    } else {
      setState(() {
        _selectedLeftId = _selectedLeftId == leftId ? null : leftId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final unassignedRights = rightOptions
        .where((opt) => !_matches.values.contains(opt.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible:
              unassignedRights.isNotEmpty ||
              _matches.length != leftOptions.length,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: t.newMentourContainer1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: t.newMentourBorder2),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: unassignedRights.map((opt) {
                final isSelected = _selectedRightId == opt.id;
                final bool hasImage =
                    opt.image.isNotEmpty && opt.image != "null";

                return GestureDetector(
                  onTap: () => _onWordBoxTap(opt),
                  child: Container(
                    padding: hasImage
                        ? const EdgeInsets.all(4)
                        : const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                    decoration: BoxDecoration(
                      color: hasImage
                          ? Colors.transparent
                          : (isSelected
                                ? t.newMentourPrimary2
                                : t.newMentourContainer29),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (hasImage && isSelected)
                            ? t.newMentourPrimary2
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              opt.image,
                              width: 80,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
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
                          )
                        : Text(
                            opt.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? t.mentourWhite
                                  : t.newMentourText1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Column(
          children: leftOptions.map((leftOpt) {
            final matchedRightId = _matches[leftOpt.id];
            final isSlotSelected = _selectedLeftId == leftOpt.id;

            SelectionOption? matchedRightOpt;
            if (matchedRightId != null) {
              matchedRightOpt = rightOptions.firstWhere(
                (e) => e.id == matchedRightId,
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Chap element
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => _onSlotTap(leftOpt.id),
                      child: Container(
                        padding: leftOpt.image.isNotEmpty
                            ? const EdgeInsets.all(4)
                            : const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: leftOpt.image.isNotEmpty
                              ? Colors.transparent
                              : (matchedRightId != null
                                    ? t.newMentourPrimary2
                                    : t.newMentourContainer29),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                (leftOpt.image.isNotEmpty &&
                                    matchedRightId != null)
                                ? t.newMentourPrimary2
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: leftOpt.image.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    leftOpt.image,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
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
                                )
                              : Text(
                                  leftOpt.text,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: matchedRightId != null
                                        ? Colors.white
                                        : t.newMentourText3,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 2,
                    color: matchedRightId != null
                        ? t.newMentourPrimary2
                        : t.newMentourBorder2,
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => _onSlotTap(leftOpt.id),
                      child: Container(
                        padding: (matchedRightOpt?.image.isNotEmpty ?? false)
                            ? const EdgeInsets.all(4)
                            : const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (matchedRightOpt?.image.isNotEmpty ?? false)
                              ? Colors.transparent
                              : (matchedRightId != null
                                    ? t.newMentourPrimary2
                                    : isSlotSelected
                                    ? t.newMentourPrimary2.withOpacity(0.12)
                                    : t.newMentourBorder2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                ((matchedRightOpt?.image.isNotEmpty ?? false) &&
                                    matchedRightId != null)
                                ? t.newMentourPrimary2
                                : (isSlotSelected && matchedRightId == null
                                      ? t.newMentourPrimary2
                                      : Colors.transparent),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: (matchedRightOpt?.image.isNotEmpty ?? false)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    matchedRightOpt!.image,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
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
                                )
                              : Text(
                                  matchedRightOpt?.text ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: matchedRightId != null
                                        ? Colors.white
                                        : Colors.transparent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
