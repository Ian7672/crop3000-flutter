// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:crop3000/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Petunjuk drag and drop muncul', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      CropApp(
        prefs: prefs,
        initialThemeMode: ThemeMode.system,
        initialLanguage: AppLanguage.indonesian,
      ),
    );

    expect(find.textContaining('Drop gambar'), findsOneWidget);
    expect(find.textContaining('3000 x 3000'), findsOneWidget);
  });
}
