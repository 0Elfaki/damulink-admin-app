class DonorDonation {
  final String id;
  final String donorId;
  final DateTime donationDate;
  final String? location;
  final String donationType;
  final String? campaignId;
  final String? loggedBy;
  final DateTime createdAt;

  DonorDonation({
    required this.id,
    required this.donorId,
    required this.donationDate,
    this.location,
    this.donationType = 'Whole Blood',
    this.campaignId,
    this.loggedBy,
    required this.createdAt,
  });

  factory DonorDonation.fromMap(Map<String, dynamic> map) {
    return DonorDonation(
      id: map['id'] as String,
      donorId: map['donor_id'] as String,
      donationDate: DateTime.parse(map['donation_date'] as String),
      location: map['location'] as String?,
      donationType: map['donation_type'] as String? ?? 'Whole Blood',
      campaignId: map['campaign_id'] as String?,
      loggedBy: map['logged_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
