import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';

class RealtimeThermalChart extends StatefulWidget {
  final double? socTempC;
  final int? batteryTempC;

  const RealtimeThermalChart({
    super.key,
    required this.socTempC,
    required this.batteryTempC,
  });

  @override
  State<RealtimeThermalChart> createState() => _RealtimeThermalChartState();
}

class _RealtimeThermalChartState extends State<RealtimeThermalChart>
    with SingleTickerProviderStateMixin {
  static const int _maxDataPoints = 60;

  final List<double> _socHistory = [];
  final List<double> _battHistory = [];

  double? _scrubIndex;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _addSample(widget.socTempC, widget.batteryTempC);
  }

  @override
  void didUpdateWidget(covariant RealtimeThermalChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.socTempC != oldWidget.socTempC ||
        widget.batteryTempC != oldWidget.batteryTempC) {
      _addSample(widget.socTempC, widget.batteryTempC);
    }
  }

  void _addSample(double? soc, int? batt) {
    final s = soc ?? (batt != null ? (batt + 6).toDouble() : 38.0);
    final b = batt?.toDouble() ?? 33.0;

    setState(() {
      _socHistory.add(s);
      if (_socHistory.length > _maxDataPoints) {
        _socHistory.removeAt(0);
      }

      _battHistory.add(b);
      if (_battHistory.length > _maxDataPoints) {
        _battHistory.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final currentSoc = _socHistory.isNotEmpty ? _socHistory.last : (widget.socTempC ?? 0.0);
    final currentBatt = _battHistory.isNotEmpty ? _battHistory.last : (widget.batteryTempC?.toDouble() ?? 0.0);

    final socMin = _socHistory.isNotEmpty ? _socHistory.reduce(math.min) : currentSoc;
    final socMax = _socHistory.isNotEmpty ? _socHistory.reduce(math.max) : currentSoc;
    final socAvg = _socHistory.isNotEmpty ? _socHistory.reduce((a, b) => a + b) / _socHistory.length : currentSoc;

    final battMin = _battHistory.isNotEmpty ? _battHistory.reduce(math.min) : currentBatt;
    final battMax = _battHistory.isNotEmpty ? _battHistory.reduce(math.max) : currentBatt;
    final battAvg = _battHistory.isNotEmpty ? _battHistory.reduce((a, b) => a + b) / _battHistory.length : currentBatt;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing8),
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Colors.deepOrangeAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.spacing10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.thermalChartTitle.getString(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppLocale.thermalChartSubtitle.getString(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),

          // ── Stat Chips ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: AppLocale.socTempLabel.getString(context),
                  current: currentSoc,
                  min: socMin,
                  max: socMax,
                  avg: socAvg,
                  color: const Color(0xFFFF5722),
                  theme: theme,
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: _buildMetricCard(
                  title: AppLocale.batteryTempLabel.getString(context),
                  current: currentBatt,
                  min: battMin,
                  max: battMax,
                  avg: battAvg,
                  color: const Color(0xFF00B0FF),
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),

          // ── Realtime Canvas Chart ─────────────────────────────────────────
          SizedBox(
            height: 180,
            width: double.infinity,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final local = box.globalToLocal(details.globalPosition);
                setState(() {
                  _scrubIndex = (local.dx / box.size.width).clamp(0.0, 1.0);
                });
              },
              onHorizontalDragEnd: (_) {
                setState(() => _scrubIndex = null);
              },
              onTapDown: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final local = box.globalToLocal(details.globalPosition);
                HapticFeedback.selectionClick();
                setState(() {
                  _scrubIndex = (local.dx / box.size.width).clamp(0.0, 1.0);
                });
              },
              onTapUp: (_) {
                setState(() => _scrubIndex = null);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: CustomPaint(
                  painter: _ThermalChartPainter(
                    socData: _socHistory,
                    battData: _battHistory,
                    scrubProgress: _scrubIndex,
                    theme: theme,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double current,
    required double min,
    required double max,
    required double avg,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppConstants.spacing6),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '${current.toStringAsFixed(1)}°C',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            'Min ${min.toStringAsFixed(1)}° | Max ${max.toStringAsFixed(1)}° | Avg ${avg.toStringAsFixed(1)}°',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThermalChartPainter extends CustomPainter {
  final List<double> socData;
  final List<double> battData;
  final double? scrubProgress;
  final ThemeData theme;

  _ThermalChartPainter({
    required this.socData,
    required this.battData,
    required this.scrubProgress,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double minTemp = 20.0;
    final double maxTemp = 65.0;

    final gridPaint = Paint()
      ..color = theme.colorScheme.outlineVariant.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      fontSize: 10,
    );

    // Draw horizontal grid lines
    const gridSteps = [25.0, 35.0, 45.0, 55.0];
    for (final temp in gridSteps) {
      final y = size.height - ((temp - minTemp) / (maxTemp - minTemp)) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      final textSpan = TextSpan(text: '${temp.toInt()}°C', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(4, y - 12));
    }

    // Draw Safety guard line (48°C)
    final safetyY = size.height - ((48.0 - minTemp) / (maxTemp - minTemp)) * size.height;
    final safetyPaint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, safetyY), Offset(size.width, safetyY), safetyPaint);

    if (socData.length >= 2) {
      _drawCurve(
        canvas: canvas,
        size: size,
        data: socData,
        minTemp: minTemp,
        maxTemp: maxTemp,
        lineColor: const Color(0xFFFF5722),
        fillColor: const Color(0xFFFF5722),
      );
    }

    if (battData.length >= 2) {
      _drawCurve(
        canvas: canvas,
        size: size,
        data: battData,
        minTemp: minTemp,
        maxTemp: maxTemp,
        lineColor: const Color(0xFF00B0FF),
        fillColor: const Color(0xFF00B0FF),
      );
    }

    // Scrubbing indicator
    if (scrubProgress != null && socData.isNotEmpty) {
      final x = scrubProgress! * size.width;
      final scrubPaint = Paint()
        ..color = theme.colorScheme.primary
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), scrubPaint);

      final idx = (scrubProgress! * (socData.length - 1)).round().clamp(0, socData.length - 1);
      final sVal = socData[idx];
      final bVal = battData.length > idx ? battData[idx] : 0.0;

      final badgeText = 'SoC: ${sVal.toStringAsFixed(1)}°C | Batt: ${bVal.toStringAsFixed(1)}°C';
      final badgeSpan = TextSpan(
        text: badgeText,
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      final badgePainter = TextPainter(
        text: badgeSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final badgeW = badgePainter.width + 12;
      final badgeH = badgePainter.height + 6;
      final badgeX = (x - badgeW / 2).clamp(4.0, size.width - badgeW - 4.0);

      final badgeRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(badgeX, 4, badgeW, badgeH),
        const Radius.circular(6),
      );
      final bgPaint = Paint()..color = theme.colorScheme.primary.withValues(alpha: 0.9);
      canvas.drawRRect(badgeRRect, bgPaint);
      badgePainter.paint(canvas, Offset(badgeX + 6, 7));
    }
  }

  void _drawCurve({
    required Canvas canvas,
    required Size size,
    required List<double> data,
    required double minTemp,
    required double maxTemp,
    required Color lineColor,
    required Color fillColor,
  }) {
    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i].clamp(minTemp, maxTemp) - minTemp) / (maxTemp - minTemp)) * size.height;
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );

      fillPath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    // Area gradient
    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        fillColor.withValues(alpha: 0.28),
        fillColor.withValues(alpha: 0.0),
      ],
    );
    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final strokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Glowing end dot
    final endPoint = points.last;
    final glowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, 6.0, glowPaint);

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ThermalChartPainter oldDelegate) {
    return oldDelegate.socData != socData ||
        oldDelegate.battData != battData ||
        oldDelegate.scrubProgress != scrubProgress;
  }
}
