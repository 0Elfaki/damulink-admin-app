import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/colors.dart';
import 'services/supabase_service.dart';
import 'models/staff_profile.dart';
import 'services/auth_repository.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const DamuLinkAdminApp());
}

class DamuLinkAdminApp extends StatelessWidget {
  const DamuLinkAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DamuLink Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: GoogleFonts.poppins().fontFamily,
        // Default text color/weight for anything that doesn't set its
        // own TextStyle (dialog titles, chip labels, etc.), so those
        // don't fall back to Material's default black87/purple accents.
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
        ),
        // Shared default for every TextField/TextFormField that doesn't
        // override its own border -- keeps the 12px control radius in
        // one place instead of repeated on every field.
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

/// Decides whether to show the login screen or the dashboard, based on
/// whether there's an active (and staff-authorized) Supabase session.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  final _authRepository = AuthRepository();
  bool _isChecking = true;
  StaffProfile? _profile;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    if (SupabaseService.isLoggedIn) {
      try {
        final profile = await _authRepository.getCurrentStaffProfile();
        if (mounted) {
          setState(() {
            _profile = (profile?.isStaff ?? false) ? profile : null;
            _isChecking = false;
          });
        }
      } catch (_) {
        // A failed session/token refresh (e.g. no network, expired
        // session) should never leave the app stuck on the loading
        // spinner. Fall through to the login screen instead.
        if (mounted) {
          setState(() {
            _profile = null;
            _isChecking = false;
          });
        }
      }
    } else {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _onSignedIn(StaffProfile profile) => setState(() => _profile = profile);
  void _onSignedOut() => setState(() => _profile = null);

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    final profile = _profile;
    if (profile != null) {
      return DashboardShell(profile: profile, onSignedOut: _onSignedOut);
    }
    return LoginScreen(onSignedIn: _onSignedIn);
  }
}
