import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/colors.dart';
import '../models/dashboard_kpis.dart';
import '../services/kpi_repository.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _kpiRepository = KpiRepository();
  DashboardKpis? _kpis;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final kpis = await _kpiRepository.getKpis();
      if (mounted) setState(() => _kpis = kpis);
    } catch (e) {
      if (mounted) setState(() => _error = "Couldn't load dashboard data.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('RETRY')),
          ],
        ),
      );
    }

    final kpis = _kpis!;
    final cards = [
      (label: 'Total Donors', value: '${kpis.totalDonors}', icon: Icons.people, color: AppColors.primary),
      (label: 'Total Donations', value: '${kpis.totalDonations}', icon: Icons.bloodtype, color: AppColors.primaryDark),
      (label: 'Completed Donations', value: '${kpis.completedDonations}', icon: Icons.check_circle, color: AppColors.success),
      (label: 'Scheduled Donations', value: '${kpis.scheduledDonations}', icon: Icons.event, color: AppColors.warning),
      (label: 'Active Campaigns', value: '${kpis.activeCampaigns} / ${kpis.totalCampaigns}', icon: Icons.campaign, color: AppColors.primary),
      (label: 'Open Blood Requests', value: '${kpis.openBloodRequests}', icon: Icons.warning_amber_rounded, color: AppColors.critical),
      (label: 'Fulfilled Requests', value: '${kpis.fulfilledBloodRequests}', icon: Icons.volunteer_activism, color: AppColors.success),
      (label: 'Lab Reports Issued', value: '${kpis.totalLabReports}', icon: Icons.biotech, color: AppColors.primaryDark),
      (label: 'Rewards Redeemed', value: '${kpis.totalRewardsRedeemed}', icon: Icons.card_giftcard, color: AppColors.warning),
      (label: 'Badges Earned', value: '${kpis.totalBadgesEarned}', icon: Icons.emoji_events, color: AppColors.primary),
      (label: 'Points in Circulation', value: '${kpis.totalPointsInCirculation}', icon: Icons.stars, color: AppColors.primaryDark),
    ];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Overview',
              subtitle: 'Live numbers across the whole DamuLink platform.',
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 600 ? 3 : 2);
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.5,
                  children: cards
                      .map((c) => StatCard(label: c.label, value: c.value, icon: c.icon, color: c.color))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 28),
            const Text('Status Breakdown', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
                child: _buildBarChart(kpis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(DashboardKpis kpis) {
    final bars = [
      (label: 'Donations\nCompleted', value: kpis.completedDonations, color: AppColors.success),
      (label: 'Donations\nScheduled', value: kpis.scheduledDonations, color: AppColors.warning),
      (label: 'Requests\nOpen', value: kpis.openBloodRequests, color: AppColors.critical),
      (label: 'Requests\nFulfilled', value: kpis.fulfilledBloodRequests, color: AppColors.primary),
    ];
    final maxVal = bars.map((b) => b.value).fold<int>(0, (a, b) => a > b ? a : b);
    final chartMax = (maxVal == 0 ? 5 : (maxVal * 1.3)).toDouble();

    return BarChart(
      BarChartData(
        maxY: chartMax,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= bars.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    bars[index].label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        barGroups: List.generate(bars.length, (i) {
          final bar = bars[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: bar.value.toDouble(),
                color: bar.color,
                width: 28,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }
}
