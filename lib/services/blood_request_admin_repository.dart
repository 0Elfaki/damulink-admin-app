import 'supabase_service.dart';
import '../models/blood_request_admin.dart';

class BloodRequestAdminRepository {
  final _client = SupabaseService.client;

  Future<List<BloodRequestAdmin>> getAllRequests({String? statusFilter}) async {
    var query = _client.from('blood_requests').select();
    if (statusFilter != null) {
      query = query.eq('status', statusFilter);
    }
    final rows = await query.order('created_at', ascending: false);
    final list = (rows as List).map((r) => r as Map<String, dynamic>).toList();
    if (list.isEmpty) return [];

    final requesterIds = list.map((r) => r['requester_id'] as String).toSet().toList();
    final profileRows =
        await _client.from('profiles').select('id, full_name').inFilter('id', requesterIds);
    final Map<String, String> namesById = {
      for (final row in (profileRows as List)) row['id'] as String: row['full_name'] as String? ?? 'Unknown',
    };

    final responseRows = await _client.from('request_responses').select('request_id');
    final Map<String, int> counts = {};
    for (final row in (responseRows as List)) {
      final id = row['request_id'] as String;
      counts[id] = (counts[id] ?? 0) + 1;
    }

    return list.map((map) {
      final id = map['id'] as String;
      return BloodRequestAdmin.fromMap(
        map,
        requesterName: namesById[map['requester_id']],
        responseCount: counts[id] ?? 0,
      );
    }).toList();
  }

  Future<void> setStatus(String requestId, String status) async {
    await _client.from('blood_requests').update({'status': status}).eq('id', requestId);
  }
}
