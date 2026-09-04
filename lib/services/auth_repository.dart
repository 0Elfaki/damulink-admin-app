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

  /// Sends a password-reset email containing a 6-digit code. Make sure
  /// the "Reset Password" email template in Supabase includes
  /// {{ .Token }} so the code actually shows up in the email. The code
  /// is verified in-app with verifyPasswordResetOtp -- no deep link or
  /// redirect URL needed, so this works even if the email is opened on a
  /// different device than the one running the app.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  /// Verifies the 6-digit code from the reset email and establishes a
  /// temporary recovery session, which updatePassword() then uses to set
  /// the new password.
  Future<void> verifyPasswordResetOtp({required String email, required String code}) async {
    await _auth.verifyOTP(type: OtpType.recovery, token: code, email: email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  }
}
