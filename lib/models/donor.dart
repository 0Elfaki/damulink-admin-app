/// A walk-in donor registered by health staff (no login account).
/// Maps to the `donors_with_eligibility` view, which adds `is_eligible`
/// and `next_eligible_date` on top of the `donors` table columns.
class Donor {
  final String id;
  final String donorId;
  final String fullName;
  final String? phone;
  final String? bloodType;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? nationalId;
  final String idType;
  final String? district;
  final String healthStatus; // eligible | deferred
  final String? healthNotes;
  final DateTime? lastDonationDate;
  final String? registeredBy;
  final String? campaignId;
  final String? campaignName;
  final String? registrationLocation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEligible;
  final DateTime? nextEligibleDate;

  Donor({
    required this.id,
    required this.donorId,
    required this.fullName,
    this.phone,
    this.bloodType,
    this.dateOfBirth,
    this.gender,
    this.nationalId,
    this.idType = 'National ID',
    this.district,
    this.healthStatus = 'eligible',
    this.healthNotes,
    this.lastDonationDate,
    this.registeredBy,
    this.campaignId,
    this.campaignName,
    this.registrationLocation,
    required this.createdAt,
    required this.updatedAt,
    required this.isEligible,
    this.nextEligibleDate,
  });

  factory Donor.fromMap(Map<String, dynamic> map) {
    DateTime? date(String key) => map[key] != null ? DateTime.parse(map[key] as String) : null;
    return Donor(
      id: map['id'] as String,
      donorId: map['donor_id'] as String,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String?,
      bloodType: map['blood_type'] as String?,
      dateOfBirth: date('date_of_birth'),
      gender: map['gender'] as String?,
      nationalId: map['national_id'] as String?,
      idType: map['id_type'] as String? ?? 'National ID',
      district: map['district'] as String?,
      healthStatus: map['health_status'] as String? ?? 'eligible',
      healthNotes: map['health_notes'] as String?,
      lastDonationDate: date('last_donation_date'),
      registeredBy: map['registered_by'] as String?,
      campaignId: map['campaign_id'] as String?,
      campaignName: map['campaign_name'] as String?,
      registrationLocation: map['registration_location'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isEligible: map['is_eligible'] as bool? ?? true,
      nextEligibleDate: date('next_eligible_date'),
    );
  }
}
