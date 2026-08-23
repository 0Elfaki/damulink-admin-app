class StaffProfile {
  final String id;
  final String fullName;
  final String role; // donor | organizer | lab | admin
  final int points;
  final DateTime createdAt;

  StaffProfile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.points,
    required this.createdAt,
  });

  bool get isStaff => role == 'organizer' || role == 'lab' || role == 'admin';
  bool get isAdmin => role == 'admin';

  factory StaffProfile.fromMap(Map<String, dynamic> map) {
    return StaffProfile(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      role: map['role'] as String? ?? 'donor',
      points: map['points'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
