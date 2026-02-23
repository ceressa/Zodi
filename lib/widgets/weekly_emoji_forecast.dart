import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/emoji_forecast.dart';

class WeeklyEmojiForecast extends StatelessWidget {
  final List<EmojiForecast> forecasts;

  const WeeklyEmojiForecast({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Text('\u{1F4C5}', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                '7 Gunluk Enerji',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecasts.length,
            itemBuilder: (context, index) {
              return _DayCard(
                forecast: forecasts[index],
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final EmojiForecast forecast;
  final int index;

  const _DayCard({required this.forecast, required this.index});

  @override
  Widget build(BuildContext context) {
    final isToday = forecast.isToday;

    return Container(
      width: 68,
      margin: EdgeInsets.only(right: index < 6 ? 8 : 0),
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFF7C3AED).withValues(alpha: 0.10)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToday
              ? const Color(0xFF7C3AED).withValues(alpha: 0.40)
              : const Color(0xFF7C3AED).withValues(alpha: 0.08),
          width: isToday ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED)
                .withValues(alpha: isToday ? 0.12 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isToday ? 'Bugun' : forecast.dayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            forecast.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          // Energy bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xFFE5E7EB),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: forecast.moodScore / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: _barColors(forecast.moodScore),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 300.ms);
  }

  List<Color> _barColors(int score) {
    if (score >= 70) {
      return [const Color(0xFF10B981), const Color(0xFF34D399)];
    }
    if (score >= 40) {
      return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
    }
    return [const Color(0xFFEF4444), const Color(0xFFF87171)];
  }
}
