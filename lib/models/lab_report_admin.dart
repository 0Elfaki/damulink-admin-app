class LabReportAdmin {
  final String id;
  final String donorId;
  final String? donorName;
  final String? bloodTypeConfirmed;
  final double? hemoglobinLevel;
  final String screeningNotes;
  final String status;
  final DateTime createdAt;

  LabReportAdmin({
    required this.id,
    required this.donorId,
    this.donorName,
    this.bloodTypeConfirmed,
    this.hemoglobinLevel,
    required this.screeningNotes,
    required this.status,
    required this.createdAt,
  });

  factory LabReportAdmin.fromMap(Map<String, dynamic> map, {String? donorName}) {
    return LabReportAdmin(
      id: map['id'] as String,
      donorId: map['donor_id'] as String,
      donorName: donorName,
      bloodTypeConfirmed: map['blood_type_confirmed'] as String?,
      hemoglobinLevel: (map['hemoglobin_level'] as num?)?.toDouble(),
      screeningNotes: map['screening_notes'] as String? ?? '',
      status: map['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
