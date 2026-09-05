import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/auth_repository.dart';

/// Self-contained "Forgot Password" flow: email -> 6-digit code from that
/// email -> new password -> a congratulations message -> back to login.
/// Everything happens inside the app itself, so it works even if the
/// reset email is opened on a different device than the one running the
/// admin app (no deep link, no redirect URL configuration needed).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

enum _Step { email, code, password, done }

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _authRepository = AuthRepository();

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _Step _step = _Step.email;
  bool _isBusy = false;
  bool _obscure = true;
  String? _error;

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } catch (_) {
      // Fall through either way -- don't reveal whether an account
      // exists for this email.
    }
    if (mounted) {
      setState(() {
        _isBusy = false;
        _step = _Step.code;
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      setState(() => _error = 'Enter the 6-digit code from your email.');
      return;
    }
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      await _authRepository.verifyPasswordResetOtp(
        email: _emailController.text.trim(),
        code: code,
      );
      if (mounted) {
        setState(() {
          _isBusy = false;
          _step = _Step.password;
        });
      }
    } catch (e) {
      setState(() {
        _isBusy = false;
        _error = "That code didn't work. Check the email and try again.";
      });
    }
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      await _authRepository.updatePassword(_newPasswordController.text);
      await _authRepository.signOut();
      if (mounted) {
        setState(() {
          _isBusy = false;
          _step = _Step.done;
        });
      }
    } catch (e) {
      setState(() {
        _isBusy = false;
        _error = "Couldn't update your password. Please try again.";
      });
    }
  }

  void _goToLogin() {
    // No named routes in this app -- popping back to the first route
    // returns to _AuthGate, which shows the login screen since there's
    // no active session at this point.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _step == _Step.done
          ? null
          : AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _buildStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.email:
        return _buildShell(
          icon: Icons.lock_reset,
          title: 'Reset Your Password',
          subtitle: "Enter your staff account email and we'll send you a 6-digit code.",
          fields: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
          buttonLabel: 'SEND CODE',
          onPressed: _sendCode,
        );
      case _Step.code:
        return _buildShell(
          icon: Icons.mark_email_read_outlined,
          title: 'Enter the Code',
          subtitle: 'We sent a 6-digit code to ${_emailController.text.trim()}. It can take a minute to arrive.',
          fields: [
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                counterText: '',
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isBusy ? null : _sendCode,
                child: const Text('Resend Code'),
              ),
            ),
          ],
          buttonLabel: 'VERIFY CODE',
          onPressed: _verifyCode,
        );
      case _Step.password:
        return _buildShell(
          icon: Icons.password,
          title: 'Set a New Password',
          subtitle: 'Choose a new password for your staff account.',
          fields: [
            TextField(
              controller: _newPasswordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscure,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
          buttonLabel: 'UPDATE PASSWORD',
          onPressed: _updatePassword,
        );
      case _Step.done:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.lightGreen, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 44),
            ),
            const SizedBox(height: 24),
            const Text(
              'Congratulations!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your password has been updated. You can now sign in with your new password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('GO TO LOGIN', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildShell({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> fields,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: Icon(icon, color: AppColors.white, size: 30)),
        ),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 28),
        ...fields,
        if (_error != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.lightPink, borderRadius: BorderRadius.circular(8)),
            child: Text(_error!, style: const TextStyle(color: AppColors.critical, fontSize: 13)),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isBusy ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isBusy
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                : Text(buttonLabel, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
