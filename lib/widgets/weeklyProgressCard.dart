import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _DayData {
  final String label;
  final int planned;
  final int done;
  const _DayData(this.label, {required this.planned, required this.done});
}

const _weekData = [
  _DayData('Mo', planned: 8, done: 6),
  _DayData('Tu', planned: 10, done: 8),
  _DayData('We', planned: 7, done: 4),
  _DayData('Th', planned: 9, done: 7),
  _DayData('Fr', planned: 6, done: 5),
  _DayData('Sa', planned: 4, done: 2),
];

int get _todayIndex {
  final wd = DateTime.now().weekday;
  return (wd <= 6) ? wd - 1 : -1;
}

class WeeklyProgressCard extends StatefulWidget {
  const WeeklyProgressCard({super.key});

  @override
  State<WeeklyProgressCard> createState() => _WeeklyProgressCardState();
}

class _WeeklyProgressCardState extends State<WeeklyProgressCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final List<Animation<double>> _barAnimations;

  static const _maxBarHeight = 72.0;
  static const _totalDays = 6;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _barAnimations = List.generate(_totalDays, (i) {
      final start = i * 0.10;
      final end = (start + 0.55).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayIdx = _todayIndex;
    final todayData = (todayIdx >= 0) ? _weekData[todayIdx] : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCEEFD)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "This Week",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D1B2A),
                  ),
                ),
                if (todayData != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${todayData.done}/${todayData.planned}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(_totalDays, (i) {
                    final d = _weekData[i];
                    final anim = _barAnimations[i].value;
                    final isToday = i == todayIdx;

                    final plannedH =
                        (d.planned / 10) * _maxBarHeight * anim;
                    final doneH =
                        (d.done / 10) * _maxBarHeight * anim;

                    return _DayColumn(
                      label: d.label,
                      plannedHeight: plannedH,
                      doneHeight: doneH,
                      isToday: isToday,
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _LegendDot(
                    color: const Color(0xFFCDD5DF), label: "Planned"),
                const SizedBox(width: 20),
                _LegendDot(
                    color: const Color(0xFF2196F3), label: "Completed"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  final String label;
  final double plannedHeight;
  final double doneHeight;
  final bool isToday;

  const _DayColumn({
    required this.label,
    required this.plannedHeight,
    required this.doneHeight,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 72,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Bar(
                  height: plannedHeight,
                  color: const Color(0xFFCDD5DF),
                  isToday: false,
                ),
                const SizedBox(width: 3),
                _Bar(
                  height: doneHeight,
                  color: const Color(0xFF2196F3),
                  isToday: isToday,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday
                ? const Color(0xFF2196F3)
                : const Color(0xFF9AA5B4),
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  final bool isToday;

  const _Bar({
    required this.height,
    required this.color,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: height.clamp(4.0, 72.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF5A7184),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
