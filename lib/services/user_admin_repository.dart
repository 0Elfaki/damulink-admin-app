import 'supabase_service.dart';
import '../models/staff_profile.dart';

class UserAdminRepository {
  final _client = SupabaseService.client;

  Future<List<StaffProfile>> getAllUsers({String? searchQuery}) async {
    var query = _client.from('profiles').select();
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('full_name', '%${searchQuery.trim()}%');
    }
    final rows = await query.order('created_at', ascending: false);
    return (rows as List).map((r) => StaffProfile.fromMap(r as Map<String, dynamic>)).toList();
  }

  /// Only succeeds server-side if the caller is an admin -- enforced by the
  /// admin_update_user_role() Postgres function, not just this client check.
  Future<void> updateUserRole(String userId, String newRole) async {
    await _client.rpc('admin_update_user_role', params: {
      'target_user_id': userId,
      'new_role': newRole,
    });
  }
}
