import 'package:flutter/material.dart';
import '../../engines/comfort_score_engine.dart';
import '../common/weather_card.dart';

class ComfortScoreCard extends StatefulWidget {
  final ComfortScoreResult result;
  final Color accent;

  const ComfortScoreCard({
    super.key,
    required this.result,
    required this.accent,
  });

  @override
  State<ComfortScoreCard> createState() => _ComfortScoreCardState();
}

class _ComfortScoreCardState extends State<ComfortScoreCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final res = widget.result;

    return WeatherCard(
      title: 'WEATHER COMFORT SCORE',
      titleTrailing: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _expanded ? 'Hide Breakdown' : 'Factor Breakdown',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.accent,
                ),
              ),
              Icon(
                _expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: widget.accent,
              ),
            ],
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circular Score Badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: res.color.withOpacity(0.18),
                  border: Border.all(color: res.color, width: 2.5),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${res.overallScore}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: res.color,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: res.color.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          res.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: res.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Driver: ${res.primaryFactor}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: res.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      res.summary,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Expandable Sub-scores Matrix
          if (_expanded) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
            const SizedBox(height: 12),
            _subScoreRow('Temperature', res.temperatureScore, 'Thermal Load', isDark),
            _subScoreRow('Rain Risk', res.rainScore, 'Precipitation', isDark),
            _subScoreRow('Humidity', res.humidityScore, 'Moisture / Dew', isDark),
            _subScoreRow('Wind Factor', res.windScore, 'Air Current', isDark),
            _subScoreRow('Air Quality', res.aqiScore, 'AQI / PM2.5', isDark),
            _subScoreRow('UV Radiation', res.uvScore, 'Solar Intensity', isDark),
          ],
        ],
      ),
    );
  }

  Widget _subScoreRow(String name, int score, String desc, bool isDark) {
    Color barColor;
    if (score >= 80) {
      barColor = const Color(0xFF10B981);
    } else if (score >= 60) {
      barColor = const Color(0xFF0284C7);
    } else if (score >= 40) {
      barColor = const Color(0xFFF59E0B);
    } else {
      barColor = const Color(0xFFEF4444);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 32,
            child: Text(
              '$score',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
