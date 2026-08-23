import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/staff_profile.dart';

class AuthRepository {
  final _auth = SupabaseService.auth;

  bool get isLoggedIn => SupabaseService.isLoggedIn;

  Future<StaffProfile?> signIn({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email, password: password);
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;

    final row = await SupabaseService.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;

    final profile = StaffProfile.fromMap(row);
    if (!profile.isStaff) {
      // Not an organizer/lab/admin account -- this dashboard isn't for them.
      await _auth.signOut();
      throw const AuthException('This account does not have dashboard access. Contact an admin.');
    }
    return profile;
  }

  Future<StaffProfile?> getCurrentStaffProfile() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;
    final row = await SupabaseService.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return StaffProfile.fromMap(row);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
