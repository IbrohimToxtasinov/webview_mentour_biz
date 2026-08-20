import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/section/section_details_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class PronunciationResultCard extends StatelessWidget {
  final List<ProcessedWord> processedWords;
  final double? overallScore;
  final bool isTaskItemView;

  const PronunciationResultCard({
    super.key,
    required this.processedWords,
    this.overallScore,
    this.isTaskItemView = true,
  });

  static Color _scoreColor(double score) {
    if (score >= 80) return const Color(0xFF22C55E); // green
    if (score >= 50) return const Color(0xFFF59E0B); // yellow
    return const Color(0xFFEF4444); // red
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    if (processedWords.isEmpty) return const SizedBox.shrink();

    // Use provided overallScore or calculate average from processedWords
    final effectiveScore =
        overallScore ??
        (processedWords.isEmpty
            ? 0.0
            : processedWords
                      .map((w) => w.pronunciationAssessment.accuracyScore)
                      .reduce((a, b) => a + b) /
                  processedWords.length);

    final accentColor = _scoreColor(effectiveScore);
    final isPerfect = effectiveScore >= 100.0;

    // Emoji and Label logic
    String emoji;
    String label;
    if (isPerfect) {
      emoji = '🎉';
      label = 'perfect_score'.tr();
    } else if (effectiveScore >= 80) {
      emoji = '😊';
      label = 'excellent'.tr();
    } else if (effectiveScore >= 50) {
      emoji = '🙂';
      label = 'good_job'.tr();
    } else {
      emoji = '😢';
      label = 'keep_practicing'.tr();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: isTaskItemView ? t.mentourNavigationBarBg : t.mentourBg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTaskItemView) ...[
            // Header: Emoji & Score
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _CircularScoreWidget(score: effectiveScore, color: accentColor),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
          ],

          // Words list
          ...processedWords.map((wordData) {
            final wordScore = wordData.pronunciationAssessment.accuracyScore;
            final wordColor = _scoreColor(wordScore);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        wordData.word,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: t.mentourText3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${wordScore.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: wordColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (wordData.syllables.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: wordData.syllables.map((syl) {
                        final sylScore =
                            syl.pronunciationAssessment.accuracyScore;
                        final sylColor = _scoreColor(sylScore);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: sylColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: sylColor.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                syl.syllable,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: sylColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${sylScore.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: sylColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CircularScoreWidget extends StatelessWidget {
  final double score;
  final Color color;

  const _CircularScoreWidget({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SizedBox(
      width: 58,
      height: 58,
      child: CustomPaint(
        painter: _CircleScorePainter(
          score: score,
          color: color,
          bgColor: t.mentourBorder1,
        ),
        child: Center(
          child: Text(
            '${score.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleScorePainter extends CustomPainter {
  final double score;
  final Color color;
  final Color bgColor;

  const _CircleScorePainter({
    required this.score,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double pi = 3.1415926535897932;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final scorePaint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * pi,
      false,
      bgPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * (score / 100),
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(_CircleScorePainter old) =>
      old.score != score || old.color != color;
}
