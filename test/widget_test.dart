import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pqc_authenticator_app/main.dart';
import 'package:pqc_authenticator_app/services/api_service.dart';
import 'package:pqc_authenticator_app/screens/login_screen.dart';
import 'package:pqc_authenticator_app/screens/home_screen.dart';

void main() {
  group('PQC Authenticator App Tests', () {
    testWidgets('App starts with login screen when no token', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MyApp(hasToken: false),
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('PQC Authenticator'), findsOneWidget);
      expect(find.text('Quantum-safe two-factor authentication'), findsOneWidget);
    });

    testWidgets('App starts with home screen when token exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MyApp(hasToken: true),
        ),
      );

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Authenticator'), findsOneWidget);
    });

    testWidgets('Login screen has required input fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Skip Login (Offline Mode)'), findsOneWidget);
    });

    testWidgets('Login form validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Email validation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('Home screen shows empty state when no accounts', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('No accounts added yet'), findsOneWidget);
      expect(find.text('Tap the + button to add your first account'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('Home screen has navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Home screen has floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Navigation between tabs works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('No accounts added yet'), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(find.text('Data Management'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pump();

      expect(find.text('No accounts added yet'), findsOneWidget);
    });

    testWidgets('App theme is properly configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MyApp(hasToken: false),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
      expect(materialApp.themeMode, equals(ThemeMode.system));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('Security icon is displayed correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MyApp(hasToken: false),
        ),
      );

      expect(find.byIcon(Icons.security), findsAtLeastNWidgets(1));
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('Can navigate to add account screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      
      await tester.tap(fab);
      await tester.pumpAndSettle();
    });

    testWidgets('Settings screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(find.text('Data Management'), findsOneWidget);
      expect(find.text('Backup Accounts'), findsOneWidget);
      expect(find.text('Restore Accounts'), findsOneWidget);
      expect(find.text('Clear All Data'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('Refresh indicator is present on home screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiService()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}