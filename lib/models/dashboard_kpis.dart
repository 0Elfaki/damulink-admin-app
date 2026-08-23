class DashboardKpis {
  final int totalDonors;
  final int totalDonations;
  final int completedDonations;
  final int scheduledDonations;
  final int activeCampaigns;
  final int totalCampaigns;
  final int openBloodRequests;
  final int fulfilledBloodRequests;
  final int totalLabReports;
  final int totalRewardsRedeemed;
  final int totalBadgesEarned;
  final int totalPointsInCirculation;

  DashboardKpis({
    required this.totalDonors,
    required this.totalDonations,
    required this.completedDonations,
    required this.scheduledDonations,
    required this.activeCampaigns,
    required this.totalCampaigns,
    required this.openBloodRequests,
    required this.fulfilledBloodRequests,
    required this.totalLabReports,
    required this.totalRewardsRedeemed,
    required this.totalBadgesEarned,
    required this.totalPointsInCirculation,
  });

  factory DashboardKpis.fromMap(Map<String, dynamic> map) {
    int i(String key) => (map[key] as num?)?.toInt() ?? 0;
    return DashboardKpis(
      totalDonors: i('total_donors'),
      totalDonations: i('total_donations'),
      completedDonations: i('completed_donations'),
      scheduledDonations: i('scheduled_donations'),
      activeCampaigns: i('active_campaigns'),
      totalCampaigns: i('total_campaigns'),
      openBloodRequests: i('open_blood_requests'),
      fulfilledBloodRequests: i('fulfilled_blood_requests'),
      totalLabReports: i('total_lab_reports'),
      totalRewardsRedeemed: i('total_rewards_redeemed'),
      totalBadgesEarned: i('total_badges_earned'),
      totalPointsInCirculation: i('total_points_in_circulation'),
    );
  }
}
