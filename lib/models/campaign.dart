class Campaign {
  final String id;
  final String title;
  final String description;
  final String location;
  final int targetDonations;
  final DateTime startDate;
  final DateTime? endDate;
  final String organizerId;
  final String status; // active | closed
  final int participantCount;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.targetDonations,
    required this.startDate,
    this.endDate,
    required this.organizerId,
    required this.status,
    this.participantCount = 0,
  });

  factory Campaign.fromMap(Map<String, dynamic> map, {int participantCount = 0}) {
    return Campaign(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      targetDonations: map['target_donations'] as int? ?? 0,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      organizerId: map['organizer_id'] as String,
      status: map['status'] as String? ?? 'active',
      participantCount: participantCount,
    );
  }
}
