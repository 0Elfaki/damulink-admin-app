import 'supabase_service.dart';
import '../models/lab_report_admin.dart';
import '../models/staff_profile.dart';

class LabReportAdminRepository {
  final _client = SupabaseService.client;

  Future<List<LabReportAdmin>> getAllReports() async {
    final rows = await _client.from('lab_reports').select().order('created_at', ascending: false);
    final list = (rows as List).map((r) => r as Map<String, dynamic>).toList();
    if (list.isEmpty) return [];

    final donorIds = list.map((r) => r['donor_id'] as String).toSet().toList();
    final profileRows =
        await _client.from('profiles').select('id, full_name').inFilter('id', donorIds);
    final Map<String, String> namesById = {
      for (final row in (profileRows as List)) row['id'] as String: row['full_name'] as String? ?? 'Unknown',
    };

    return list
        .map((map) => LabReportAdmin.fromMap(map, donorName: namesById[map['donor_id']]))
        .toList();
  }

  /// Donors to show in the "create report for" picker.
  Future<List<StaffProfile>> searchDonors(String query) async {
    final rows = await _client
        .from('profiles')
        .select()
        .eq('role', 'donor')
        .ilike('full_name', '%$query%')
        .limit(20);
    return (rows as List).map((r) => StaffProfile.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<void> createReport({
    required String donorId,
    String? bloodTypeConfirmed,
    double? hemoglobinLevel,
    required String screeningNotes,
    String status = 'completed',
  }) async {
    final staffId = SupabaseService.currentUser?.id;
    await _client.from('lab_reports').insert({
      'donor_id': donorId,
      'blood_type_confirmed': bloodTypeConfirmed,
      'hemoglobin_level': hemoglobinLevel,
      'screening_notes': screeningNotes,
      'status': status,
      'created_by': staffId,
    });
  }
}
