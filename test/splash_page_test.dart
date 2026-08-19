import 'package:completai_app/features/splash/views/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash presents the brand then replaces itself with login', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashPage(
            duration: Duration(milliseconds: 20),
            loginRoute: '/login',
          ),
          '/login': (_) => const Scaffold(body: Text('Login atual')),
        },
      ),
    );

    expect(find.text('Completai!'), findsOneWidget);
    expect(find.text('Seu caminho para abastecer melhor.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 25));
    await tester.pumpAndSettle();

    expect(find.text('Login atual'), findsOneWidget);
    expect(find.text('Completai!'), findsNothing);
  });
}
