import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bbcode/flutter_bbcode.dart';

void main() {
  const TextStyle defaultStyle = TextStyle(color: Colors.black, fontSize: 14);

  group("Flutter parseBBCode", () {
    test("No BBCode tag (span compression)", () {
      List<InlineSpan> spans = parseBBCode("Some test data without bbcode");
      expect(spans.length, 1,
          reason: "Text should be parsed into 1 span of the same style.");
      expect(spans[0].toPlainText(), "Some test data without bbcode",
          reason: "Content should stay the same.");
    });

    test("Single BBCode tag (span compression)", () {
      List<InlineSpan> spans = parseBBCode("Some test [b]data[/b] with bbcode");
      expect(spans.length, 3,
          reason: "Text should be parsed into 3 span of the same style.");
      expect(spans[0].toPlainText(), "Some test ",
          reason: "Content should stay the same.");
      expect(spans[1].toPlainText(), "data",
          reason: "Content should stay the same.");
      expect(spans[2].toPlainText(), " with bbcode",
          reason: "Content should stay the same.");
    });

    test("Nested BBCode tag (span compression)", () {
      List<InlineSpan> spans =
          parseBBCode("Some test [b][i]data[/i][/b] with bbcode");
      expect(spans.length, 3,
          reason: "Text should be parsed into 3 spans of the same style.");
      expect(spans[0].toPlainText(), "Some test ",
          reason: "Content should stay the same.");
      expect(spans[1].toPlainText(), "data",
          reason: "Content should stay the same.");
      expect(spans[2].toPlainText(), " with bbcode",
          reason: "Content should stay the same.");
    });

    test("Single BBCode tag surrouned (span compression)", () {
      List<InlineSpan> spans = parseBBCode("[i]Some test data with bbcode[/i]");
      expect(spans.length, 1,
          reason: "Text should be parsed into 1 span of the same style.");
      expect(spans[0].toPlainText(), "Some test data with bbcode",
          reason: "Content should stay the same.");
    });

    test("Multiple BBCode tags (span compression)", () {
      List<InlineSpan> spans =
          parseBBCode("[i]Some test [b]data[/b] with [u]bbcode[/u][/i]");
      expect(spans.length, 4,
          reason: "Text should be parsed into 4 spans of the same style.");
      expect(spans[0].toPlainText(), "Some test ",
          reason: "Content should stay the same.");
      expect(spans[1].toPlainText(), "data",
          reason: "Content should stay the same.");
      expect(spans[2].toPlainText(), " with ",
          reason: "Content should stay the same.");
      expect(spans[3].toPlainText(), "bbcode",
          reason: "Content should stay the same.");
    });

    test("Default style applied - no bbcode", () {
      List<InlineSpan> spans =
          parseBBCode("Some text without BBCode", defaultStyle: defaultStyle);
      expect(spans[0].style, defaultStyle,
          reason: "This whole block should be of the same style.");
    });

    test("Default style applied - bbcode gap", () {
      List<InlineSpan> spans = parseBBCode(
          "Some people [b]should[/b] go and work.",
          defaultStyle: defaultStyle);
      expect(spans.length, 3, reason: "Span length should be 3");
      expect(spans[2].style, defaultStyle,
          reason: "This whole block [b]should[/b] be of the same style.");
    });

    test("Wrapped style tag (Quote test)", () {
      List<InlineSpan> spans = parseBBCode(
        "Test. [quote]Hey you![/quote] okay?",
        defaultStyle: defaultStyle
      );
      expect(spans.length, 3, reason: "Quote is seen as one span. Output: ${spans.toString()}");
      expect(spans[1] is WidgetSpan, true);
    });

    test("Wrapped style tag (Quote test - bold)", () {
      List<InlineSpan> spans = parseBBCode(
          "Test. [quote]Hey [b]you![/b][/quote] okay?",
          defaultStyle: defaultStyle
      );
      expect(spans.length, 3, reason: "Quote is seen as one span. Output: ${spans.toString()}");
      expect(spans[1] is WidgetSpan, true);
    });

    test("Wrapped style tag (Quote test - quote in quote)", () {
      List<InlineSpan> spans = parseBBCode(
          "[quote][quote]Hello[/quote][/quote]",
          defaultStyle: defaultStyle
      );
      expect(spans.length, 1, reason: "Quote is seen as one span. Output: ${spans.toString()}");
      expect(spans[0] is WidgetSpan, true);
    });
  });
}
