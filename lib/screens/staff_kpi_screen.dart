import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/colors.dart';
import '../models/staff_kpis.dart';
import '../services/staff_kpi_repository.dart';

class StaffKpiScreen extends StatefulWidget {
  const StaffKpiScreen({super.key});

  @override
  State<StaffKpiScreen> createState() => _StaffKpiScreenState();
}

class _StaffKpiScreenState extends State<StaffKpiScreen> {
  final _repository = StaffKpiRepository();
  StaffKpis? _kpis;
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
      final kpis = await _repository.getKpis();
      if (mounted) setState(() => _kpis = kpis);
    } catch (e) {
      if (mounted) setState(() => _error = "Couldn't load KPI data.");
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
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final kpis = _kpis!;
    final cards = [
      (label: 'Total Donors', value: '${kpis.totalDonorsCombined}', icon: Icons.people, color: AppColors.primary),
      (label: 'App-Registered', value: '${kpis.totalAppDonors}', icon: Icons.smartphone, color: AppColors.primaryDark),
      (label: 'Registered by Staff', value: '${kpis.totalWalkInDonors}', icon: Icons.badge_outlined, color: AppColors.primaryDark),
      (label: 'Eligible Now', value: '${kpis.eligibleDonorsCombined}', icon: Icons.check_circle, color: AppColors.success),
      (label: 'Not Eligible', value: '${kpis.deferredDonorsCombined}', icon: Icons.block, color: AppColors.critical),
      (label: 'Registered Today', value: '${kpis.registeredToday}', icon: Icons.today, color: AppColors.warning),
      (label: 'Registered This Week', value: '${kpis.registeredThisWeek}', icon: Icons.date_range, color: AppColors.warning),
      (label: 'Registered This Month', value: '${kpis.registeredThisMonth}', icon: Icons.calendar_month, color: AppColors.warning),
      (label: 'Donations Logged', value: '${kpis.donationsLoggedTotal}', icon: Icons.bloodtype, color: AppColors.primary),
      (label: 'Logged This Month', value: '${kpis.donationsLoggedThisMonth}', icon: Icons.bloodtype_outlined, color: AppColors.primary),
    ];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Staff Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text(
              'Donor registrations and eligibility across the whole donor base.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                  children: cards.map((c) => _buildKpiCard(c.label, c.value, c.icon, c.color)).toList(),
                );
              },
            ),
            const SizedBox(height: 28),
            const Text('Eligibility Split', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              height: 220,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: _buildEligibilityChart(kpis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityChart(StaffKpis kpis) {
    final total = kpis.eligibleDonorsCombined + kpis.deferredDonorsCombined;
    if (total == 0) {
      return const Center(child: Text('No donors yet.', style: TextStyle(color: AppColors.textSecondary)));
    }
    return Row(
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: kpis.eligibleDonorsCombined.toDouble(),
                  color: AppColors.success,
                  title: '${kpis.eligibleDonorsCombined}',
                  radius: 40,
                  titleStyle: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                PieChartSectionData(
                  value: kpis.deferredDonorsCombined.toDouble(),
                  color: AppColors.critical,
                  title: '${kpis.deferredDonorsCombined}',
                  radius: 40,
                  titleStyle: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendRow(AppColors.success, 'Eligible to donate', kpis.eligibleDonorsCombined),
              const SizedBox(height: 8),
              _legendRow(AppColors.critical, 'Not eligible yet', kpis.deferredDonorsCombined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendRow(Color color, String label, int value) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
        Text('$value', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
