import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_chart_widget.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Analytics'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stat Cards Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        StatCard(
                          title: "TODAY'S FOCUS",
                          value: '${statsProvider.totalFocusMinutesToday}m',
                          subtitle: 'Minutes focused today',
                          icon: Icons.today,
                          iconColor: theme.colorScheme.primary,
                        ),
                        StatCard(
                          title: 'THIS WEEK',
                          value: '${statsProvider.totalFocusMinutesThisWeek}m',
                          subtitle: 'Total weekly focus',
                          icon: Icons.date_range,
                          iconColor: theme.colorScheme.secondary,
                        ),
                        StatCard(
                          title: 'SESSIONS',
                          value: '${statsProvider.totalCompletedSessions}',
                          subtitle: 'Completed sessions',
                          icon: Icons.task_alt_rounded,
                          iconColor: const Color(0xFF8B5CF6), // Purple
                        ),
                        StatCard(
                          title: 'STREAK',
                          value: '${statsProvider.currentDailyStreak} Days',
                          subtitle: 'Current daily streak',
                          icon: Icons.local_fire_department,
                          iconColor: const Color(0xFFF59E0B), // Orange
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 7-day chart
                    WeeklyChartWidget(
                      last7DaysData: statsProvider.last7DaysData,
                    ),
                  ],
                ),
              ),
            ),

            // Adaptive Banner Ad at Bottom of Stats screen
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
