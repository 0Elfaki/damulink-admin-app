import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/colors.dart';
import '../models/staff_kpis.dart';
import '../services/staff_kpi_repository.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

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
            ElevatedButton(onPressed: _load, child: const Text('RETRY')),
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
            const SectionHeader(
              title: 'Staff Overview',
              subtitle: 'Donor registrations and eligibility across the whole donor base.',
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
            const Text('Eligibility Split', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: _buildEligibilityChart(kpis),
              ),
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
}
