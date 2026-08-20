import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/questions/questions_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class TracingWidget extends StatefulWidget {
  final Question question;
  final ValueChanged<bool>? onFilledChange;
  final ValueChanged<Map<String, dynamic>>? onAnswersChange;

  final ValueChanged<bool>? onTracingGestureChanged;

  const TracingWidget({
    super.key,
    required this.question,
    this.onFilledChange,
    this.onAnswersChange,
    this.onTracingGestureChanged,
  });

  @override
  State<TracingWidget> createState() => _TracingWidgetState();
}

class _TracingWidgetState extends State<TracingWidget>
    with SingleTickerProviderStateMixin {
  int _currentLetterIndex = 0;
  List<TracingLetter> _letters = [];
  final Set<int> _completedLetterIndices = {};

  int _currentStrokeIndex = 0;
  double _currentStrokeProgress = 0.0;
  List<Path> _currentLetterPaths = [];
  List<PathMetric> _currentLetterMetrics = [];

  List<Path> _lastCompletedPaths = [];

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _letters = widget.question.content.tracingLetters;

    for (int i = 0; i < _letters.length; i++) {
      if (!_letters[i].placeholder) {
        _completedLetterIndices.add(i);
      }
    }

    while (_completedLetterIndices.contains(_currentLetterIndex) &&
        _currentLetterIndex < _letters.length) {
      _currentLetterIndex++;
    }

    if (_currentLetterIndex >= _letters.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Map<String, dynamic> results = {};
        for (var letter in _letters) {
          if (letter.placeholder == true && letter.placeholderId != null) {
            results[letter.placeholderId!] = true;
          }
        }
        widget.onAnswersChange?.call(results);
        widget.onFilledChange?.call(true);
      });
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _preparePaths();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _preparePaths() {
    if (_currentLetterIndex >= _letters.length) return;
    _currentLetterPaths = [];
    _currentLetterMetrics = [];
    _currentStrokeIndex = 0;
    _currentStrokeProgress = 0.0;

    for (var svgPath in _letters[_currentLetterIndex].svgPaths) {
      final path = _parsePath(svgPath);
      _currentLetterPaths.add(path);
      _currentLetterMetrics.addAll(path.computeMetrics());
    }
  }

  Path _parsePath(String svgPath) {
    final path = Path();
    final parts = svgPath.split(' ');
    // We normalize coordinates to 0..100 in the UI
    for (int i = 0; i < parts.length; i++) {
      final cmd = parts[i];
      try {
        if (cmd == 'M') {
          path.moveTo(double.parse(parts[i + 1]), double.parse(parts[i + 2]));
          i += 2;
        } else if (cmd == 'L') {
          path.lineTo(double.parse(parts[i + 1]), double.parse(parts[i + 2]));
          i += 2;
        } else if (cmd == 'Q') {
          path.quadraticBezierTo(
            double.parse(parts[i + 1]),
            double.parse(parts[i + 2]),
            double.parse(parts[i + 3]),
            double.parse(parts[i + 4]),
          );
          i += 4;
        } else if (cmd == 'C') {
          path.cubicTo(
            double.parse(parts[i + 1]),
            double.parse(parts[i + 2]),
            double.parse(parts[i + 3]),
            double.parse(parts[i + 4]),
            double.parse(parts[i + 5]),
            double.parse(parts[i + 6]),
          );
          i += 6;
        }
      } catch (e) {
        debugPrint("Error parsing SVG part: $e");
      }
    }
    return path;
  }

  void _onLetterCompleted() {
    setState(() {
      _lastCompletedPaths = List.from(_currentLetterPaths);

      _completedLetterIndices.add(_currentLetterIndex);

      _currentLetterIndex++;
      while (_completedLetterIndices.contains(_currentLetterIndex) &&
          _currentLetterIndex < _letters.length) {
        _currentLetterIndex++;
      }

      if (_currentLetterIndex < _letters.length) {
        _preparePaths();
      } else {
        Map<String, dynamic> results = {};
        for (var letter in _letters) {
          if (letter.placeholder == true && letter.placeholderId != null) {
            results[letter.placeholderId!] = true;
          }
        }
        widget.onAnswersChange?.call(results);
        widget.onFilledChange?.call(true);
      }
    });
  }

  void _onPointerMove(Offset localPosition, Size size) {
    if (_currentStrokeIndex >= _currentLetterMetrics.length) return;

    final normalizedX = localPosition.dx * 100 / size.width;
    final normalizedY = localPosition.dy * 100 / size.height;
    final point = Offset(normalizedX, normalizedY);

    final metric = _currentLetterMetrics[_currentStrokeIndex];
    final totalLength = metric.length;

    double closestDistance = double.infinity;
    double closestProgress = 0.0;

    const samples = 100;
    for (int i = 0; i < samples; i++) {
      final prg = i / (samples - 1);
      final tangent = metric.getTangentForOffset(prg * totalLength);
      if (tangent != null) {
        final dist = (tangent.position - point).distance;
        if (dist < closestDistance) {
          closestDistance = dist;
          closestProgress = prg;
        }
      }
    }

    const threshold = 18.0;

    if (closestDistance < threshold) {
      if (closestProgress > _currentStrokeProgress &&
          (closestProgress - _currentStrokeProgress) < 0.3) {
        setState(() {
          _currentStrokeProgress = closestProgress;
        });

        if (_currentStrokeProgress > 0.94) {
          _completeStroke();
        }
      }
    }
  }

  void _completeStroke() {
    if (_currentStrokeIndex >= _currentLetterMetrics.length) return;

    setState(() {
      _currentStrokeProgress = 1.0;
      _currentStrokeIndex++;
      _currentStrokeProgress = 0.0;

      if (_currentStrokeIndex >= _currentLetterMetrics.length) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _onLetterCompleted();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
          decoration: BoxDecoration(
            color: t.newMentourContainer20,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.newMentourBorder2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _letters.asMap().entries.map((entry) {
              final index = entry.key;
              final letter = entry.value;
              final isCompleted = _completedLetterIndices.contains(index);
              final isCurrent = _currentLetterIndex == index;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  letter.char,
                  style: TextStyle(
                    fontSize: 32,
                    // fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? t.newMentourPrimary1
                        : (isCurrent
                              ? t.newMentourPrimary2
                              : t.newMentourText4.withOpacity(0.3)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final size = Size(width, width);
            return Center(
              child: Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  color: t.newMentourContainer20,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: t.newMentourBorder2),
                ),
                child: Stack(
                  children: [
                    // Grid lines
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GridPainter(color: t.newMentourBorder2),
                      ),
                    ),

                    Positioned.fill(
                      child: CustomPaint(
                        painter: TracingBasePainter(
                          paths: _currentLetterIndex < _letters.length
                              ? _currentLetterPaths
                              : _lastCompletedPaths,
                          color: t.newMentourText4.withOpacity(0.08),
                          strokeWidth: 50,
                        ),
                      ),
                    ),

                    if (_currentLetterIndex >= _letters.length &&
                        _lastCompletedPaths.isNotEmpty)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: TracingBasePainter(
                            paths: _lastCompletedPaths,
                            color: t.newMentourPrimary2,
                            strokeWidth: 20,
                          ),
                        ),
                      ),

                    if (_currentLetterIndex < _letters.length)
                      Positioned.fill(
                        child: Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: (_) =>
                              widget.onTracingGestureChanged?.call(true),
                          onPointerMove: (event) =>
                              _onPointerMove(event.localPosition, size),
                          onPointerUp: (_) =>
                              widget.onTracingGestureChanged?.call(false),
                          onPointerCancel: (_) =>
                              widget.onTracingGestureChanged?.call(false),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: TracingGuidancePainter(
                                  allPaths: _currentLetterPaths,
                                  allMetrics: _currentLetterMetrics,
                                  currentStrokeIndex: _currentStrokeIndex,
                                  currentStrokeProgress: _currentStrokeProgress,
                                  activeColor: t.newMentourPrimary2,
                                  inactiveColor: t.newMentourPrimary2
                                      .withOpacity(0.2),
                                  pulseValue: _pulseController.value,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class TracingBasePainter extends CustomPainter {
  final List<Path> paths;
  final Color color;
  final double strokeWidth;

  TracingBasePainter({
    required this.paths,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 100;
    final scaleY = size.height / 100;
    final matrix = Matrix4.identity()..scale(scaleX, scaleY);

    for (final path in paths) {
      canvas.drawPath(path.transform(matrix.storage), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TracingGuidancePainter extends CustomPainter {
  final List<Path> allPaths;
  final List<PathMetric> allMetrics;
  final int currentStrokeIndex;
  final double currentStrokeProgress;
  final Color activeColor;
  final Color inactiveColor;
  final double pulseValue;

  TracingGuidancePainter({
    required this.allPaths,
    required this.allMetrics,
    required this.currentStrokeIndex,
    required this.currentStrokeProgress,
    required this.activeColor,
    required this.inactiveColor,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100;
    final scaleY = size.height / 100;
    final matrix = Matrix4.identity()..scale(scaleX, scaleY);
    final scaleMatrix = matrix.storage;

    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < currentStrokeIndex; i++) {
      canvas.drawPath(allPaths[i].transform(scaleMatrix), activePaint);
    }

    if (currentStrokeIndex < allMetrics.length) {
      final metric = allMetrics[currentStrokeIndex];
      final length = metric.length;

      if (currentStrokeProgress > 0) {
        final tracedPath = metric.extractPath(
          0,
          length * currentStrokeProgress,
        );
        canvas.drawPath(tracedPath.transform(scaleMatrix), activePaint);
      }

      final dashPaint = Paint()
        ..color = activeColor.withOpacity(0.4)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final start = length * currentStrokeProgress;
      _drawDashedPath(
        canvas,
        metric.extractPath(start, length).transform(scaleMatrix),
        dashPaint,
      );

      _drawIndicator(canvas, metric, currentStrokeProgress, size);
    }
  }

  void _drawIndicator(
    Canvas canvas,
    PathMetric metric,
    double progress,
    Size size,
  ) {
    final length = metric.length;
    final tangent = metric.getTangentForOffset(length * progress);
    if (tangent == null) return;

    final scaleX = size.width / 100;
    final scaleY = size.height / 100;
    final pos = Offset(
      tangent.position.dx * scaleX,
      tangent.position.dy * scaleY,
    );

    final pulseRadius = 20 + (5 * pulseValue);
    canvas.drawCircle(
      pos,
      pulseRadius,
      Paint()..color = activeColor.withOpacity(0.25 * (1 - pulseValue)),
    );

    canvas.drawCircle(pos, 18, Paint()..color = Colors.white);

    canvas.drawCircle(pos, 15, Paint()..color = activeColor);

    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);
    canvas.rotate(angle);

    final arrowPath = Path();
    arrowPath.moveTo(-6, -5);
    arrowPath.lineTo(6, 0);
    arrowPath.lineTo(-6, 5);
    canvas.drawPath(arrowPath, arrowPaint);

    canvas.restore();
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 10.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final pathPart = metric.extractPath(
          distance,
          (distance + dashWidth).clamp(0, metric.length),
        );
        canvas.drawPath(pathPart, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    _drawDashedLine(
      canvas,
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );
    _drawDashedLine(
      canvas,
      Offset(centerX, 0),
      Offset(centerX, size.height),
      paint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 10.0;
    final totalVector = end - start;
    final totalDistance = totalVector.distance;
    final direction = totalVector / totalDistance;

    double currentDist = 0;
    while (currentDist < totalDistance) {
      canvas.drawLine(
        start + direction * currentDist,
        start + direction * (currentDist + dashWidth).clamp(0, totalDistance),
        paint,
      );
      currentDist += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
