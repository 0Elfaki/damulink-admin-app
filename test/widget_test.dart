import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:damulink_admin/main.dart';
import 'package:damulink_admin/screens/login_screen.dart';

class MockLocalStorage extends LocalStorage {
  const MockLocalStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async => null;

  @override
  Future<void> persistSession(String session) async {}

  @override
  Future<void> removeSession() async {}

  @override
  Future<void> removePersistedSession() async {}

  @override
  Future<bool> hasAccessToken() async => false;
}

class MockGotrueAsyncStorage extends GotrueAsyncStorage {
  const MockGotrueAsyncStorage();

  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> setItem({required String key, required String value}) async {}

  @override
  Future<void> removeItem({required String key}) async {}
}

void main() {
  setUpAll(() async {
    // Initialize Supabase with dummy credentials and mock storage for testing
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co',
      anonKey: 'placeholderAnonKey',
      authOptions: const FlutterAuthClientOptions(
        localStorage: MockLocalStorage(),
        pkceAsyncStorage: MockGotrueAsyncStorage(),
      ),
    );
  });

  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DamuLinkAdminApp());

    // Wait for the asynchronous authentication check to complete.
    await tester.pumpAndSettle();

    // Verify that the LoginScreen is displayed.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('DamuLink Admin'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
  });
}
