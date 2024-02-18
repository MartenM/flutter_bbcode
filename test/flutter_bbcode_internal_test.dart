import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group("BBStylesheet tests", () {
    test("Copy test (no new variables)", () {
      var initial = defaultBBStylesheet();
      var copy = initial.copyWith();

      expect(initial.tags, copy.tags);
      expect(initial.defaultTextStyle, copy.defaultTextStyle);
      expect(initial.selectableText, copy.selectableText);
    });

    test("Copy test (all new variables)", () {
      var newStyle = TextStyle(fontSize: 999);

      var initial = defaultBBStylesheet();
      var copy =
          initial.copyWith(defaultTextStyle: newStyle, selectableText: true);

      expect(initial.tags, copy.tags);
      expect(copy.defaultTextStyle, newStyle);
      expect(copy.selectableText, true);
    });
  });
}
