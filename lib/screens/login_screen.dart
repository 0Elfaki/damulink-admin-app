import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/colors.dart';
import '../models/staff_profile.dart';
import '../services/auth_repository.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final ValueChanged<StaffProfile> onSignedIn;
  const LoginScreen({super.key, required this.onSignedIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authRepository = AuthRepository();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  // Every role this dashboard serves. 'donor' is deliberately excluded --
  // that account type is rejected by AuthRepository.signIn before it
  // ever gets here.
  static const _roles = ['admin', 'organizer', 'lab', 'health_staff'];
  String _selectedRole = _roles.first;

  String _roleLabel(String role) {
    if (role == 'health_staff') return 'Health Staff';
    return role[0].toUpperCase() + role.substring(1);
  }

  void _forgotPassword() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await _authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (profile == null) return;

      // The role picker is a UX guardrail, not the source of truth --
      // the account's real role always wins. If they don't match, tell
      // the person clearly instead of silently dropping them into a
      // dashboard that doesn't match what they expected to see.
      if (profile.role != _selectedRole) {
        await _authRepository.signOut();
        if (mounted) {
          setState(() {
            _error = "This account is registered as ${_roleLabel(profile.role)}. "
                "Select that role above and sign in again.";
          });
        }
        return;
      }

      widget.onSignedIn(profile);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: AppColors.white, size: 36),
                ),
                const SizedBox(height: 20),
                const Text(
                  'DamuLink Admin',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Organization & staff dashboard',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "I'M SIGNING IN AS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _roles.map((role) {
                    final isSelected = _selectedRole == role;
                    return ChoiceChip(
                      label: Text(_roleLabel(role)),
                      selected: isSelected,
                      onSelected: (_) => setState(() {
                        _selectedRole = role;
                        _error = null;
                      }),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: isSelected ? AppColors.white : AppColors.textPrimary),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightPink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_error!, style: const TextStyle(color: AppColors.critical, fontSize: 13)),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : const Text('SIGN IN', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Access is limited to health staff, organizer, lab, and admin accounts.\nDonors should use the DamuLink app instead.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
