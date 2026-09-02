enum DonorSource { walkIn, app }

/// One row in the staff "Donors" list. Unifies walk-in donors (the new
/// `donors` table, registered by staff) and app-registered donors (the
/// existing `profiles` table, role = 'donor') into a single shape so the
/// list/search/eligibility-color UI doesn't need to care which one it's
/// looking at. `id` is the underlying row's id in its source table --
/// use it plus `source` to know where to fetch full detail from.
class DonorListItem {
  final DonorSource source;
  final String id;
  final String? donorId;
  final String fullName;
  final String? bloodType;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? district;
  final DateTime createdAt;
  final DateTime? lastDonationDate;
  final bool isEligible;
  final DateTime? nextEligibleDate;
  final String? campaignName;
  final String? registrationLocation;
  final String healthStatus; // 'eligible' | 'deferred' for walk-in; app donors have no manual health flag

  DonorListItem({
    required this.source,
    required this.id,
    this.donorId,
    required this.fullName,
    this.bloodType,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.district,
    required this.createdAt,
    this.lastDonationDate,
    required this.isEligible,
    this.nextEligibleDate,
    this.campaignName,
    this.registrationLocation,
    this.healthStatus = 'eligible',
  });

  factory DonorListItem.fromDonorMap(Map<String, dynamic> map) {
    DateTime? date(String key) => map[key] != null ? DateTime.parse(map[key] as String) : null;
    return DonorListItem(
      source: DonorSource.walkIn,
      id: map['id'] as String,
      donorId: map['donor_id'] as String?,
      fullName: map['full_name'] as String,
      bloodType: map['blood_type'] as String?,
      phone: map['phone'] as String?,
      dateOfBirth: date('date_of_birth'),
      gender: map['gender'] as String?,
      district: map['district'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastDonationDate: date('last_donation_date'),
      isEligible: map['is_eligible'] as bool? ?? true,
      nextEligibleDate: date('next_eligible_date'),
      campaignName: map['campaign_name'] as String?,
      registrationLocation: map['registration_location'] as String?,
      healthStatus: map['health_status'] as String? ?? 'eligible',
    );
  }

  factory DonorListItem.fromAppDonorMap(Map<String, dynamic> map) {
    DateTime? date(String key) => map[key] != null ? DateTime.parse(map[key] as String) : null;
    return DonorListItem(
      source: DonorSource.app,
      id: map['id'] as String,
      donorId: map['donor_id'] as String?,
      fullName: map['full_name'] as String,
      bloodType: map['blood_type'] as String?,
      phone: map['phone'] as String?,
      dateOfBirth: date('date_of_birth'),
      gender: map['gender'] as String?,
      district: map['district'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastDonationDate: date('last_donation_date'),
      isEligible: map['is_eligible'] as bool? ?? true,
      nextEligibleDate: date('next_eligible_date'),
      campaignName: null,
      registrationLocation: null,
      healthStatus: 'eligible',
    );
  }
}
