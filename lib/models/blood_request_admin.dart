class BloodRequestAdmin {
  final String id;
  final String requesterId;
  final String? requesterName;
  final List<String> bloodTypes;
  final String urgency;
  final String hospital;
  final String notes;
  final int unitsNeeded;
  final String status; // open | fulfilled | cancelled
  final DateTime createdAt;
  final int responseCount;

  BloodRequestAdmin({
    required this.id,
    required this.requesterId,
    this.requesterName,
    required this.bloodTypes,
    required this.urgency,
    required this.hospital,
    required this.notes,
    required this.unitsNeeded,
    required this.status,
    required this.createdAt,
    this.responseCount = 0,
  });

  String get bloodTypesLabel => bloodTypes.join(' / ');

  factory BloodRequestAdmin.fromMap(
    Map<String, dynamic> map, {
    String? requesterName,
    int responseCount = 0,
  }) {
    final rawTypes = map['blood_types'];
    final types = rawTypes is List ? rawTypes.map((e) => e.toString()).toList() : <String>[];
    return BloodRequestAdmin(
      id: map['id'] as String,
      requesterId: map['requester_id'] as String,
      requesterName: requesterName,
      bloodTypes: types,
      urgency: map['urgency'] as String? ?? 'Normal',
      hospital: map['hospital'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      unitsNeeded: map['units_needed'] as int? ?? 1,
      status: map['status'] as String? ?? 'open',
      createdAt: DateTime.parse(map['created_at'] as String),
      responseCount: responseCount,
    );
  }
}
