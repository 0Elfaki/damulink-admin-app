class StaffKpis {
  final int totalAppDonors;
  final int totalWalkInDonors;
  final int totalDonorsCombined;
  final int eligibleDonorsCombined;
  final int deferredDonorsCombined;
  final int registeredToday;
  final int registeredThisWeek;
  final int registeredThisMonth;
  final int donationsLoggedTotal;
  final int donationsLoggedThisMonth;

  StaffKpis({
    required this.totalAppDonors,
    required this.totalWalkInDonors,
    required this.totalDonorsCombined,
    required this.eligibleDonorsCombined,
    required this.deferredDonorsCombined,
    required this.registeredToday,
    required this.registeredThisWeek,
    required this.registeredThisMonth,
    required this.donationsLoggedTotal,
    required this.donationsLoggedThisMonth,
  });

  factory StaffKpis.fromMap(Map<String, dynamic> map) {
    int i(String key) => (map[key] as num?)?.toInt() ?? 0;
    return StaffKpis(
      totalAppDonors: i('total_app_donors'),
      totalWalkInDonors: i('total_walk_in_donors'),
      totalDonorsCombined: i('total_donors_combined'),
      eligibleDonorsCombined: i('eligible_donors_combined'),
      deferredDonorsCombined: i('deferred_donors_combined'),
      registeredToday: i('registered_today'),
      registeredThisWeek: i('registered_this_week'),
      registeredThisMonth: i('registered_this_month'),
      donationsLoggedTotal: i('donations_logged_total'),
      donationsLoggedThisMonth: i('donations_logged_this_month'),
    );
  }
}
