import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:flutter_bbcode/src/default_tags/basic_tags.dart';
import 'package:flutter_test/flutter_test.dart';

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
          parseBBCode("Some text without BBCode");
      expect(spans[0].style, defaultStyle,
          reason: "This whole block should be of the same style.");
    });

    test("Default style applied - bbcode gap", () {
      List<InlineSpan> spans = parseBBCode(
          "Some people [b]should[/b] go and work.");
      expect(spans.length, 3, reason: "Span length should be 3");
      expect(spans[2].style, defaultStyle,
          reason: "This whole block [b]should[/b] be of the same style.");
    });

    test("Wrapped style tag (Quote test)", () {
      List<InlineSpan> spans = parseBBCode(
          "Test. [quote]Hey you![/quote] okay?");
      expect(spans.length, 3,
          reason: "Quote is seen as one span. Output: ${spans.toString()}");
      expect(spans[1] is WidgetSpan, true);
    });

    test("Wrapped style tag (Quote test - bold)", () {
      List<InlineSpan> spans = parseBBCode(
          "Test. [quote]Hey [b]you![/b][/quote] okay?");
      expect(spans.length, 3,
          reason: "Quote is seen as one span. Output: ${spans.toString()}");
      expect(spans[1] is WidgetSpan, true);
    });

    test("Wrapped style tag (Quote test - quote in quote)", () {
      List<InlineSpan> spans = parseBBCode(
          "[quote][quote]Hello[/quote][/quote]");
      expect(spans.length, 1,
          reason: "Quote is seen as one span. Output: ${spans.toString()}");
      expect(spans[0] is WidgetSpan, true);
    });
  });

  group("Flutter parseBBCode stylesheet", () {

    var emptySheet = BBStylesheet(tags: []);

    test("No style sheet", () {
      List<InlineSpan> spans = parseBBCode("Some test data without stylesheet", stylesheet: emptySheet);
      expect(spans.length, 1,
          reason: "Text should be parsed into 1 span of the same style.");
      expect(spans[0].toPlainText(), "Some test data without stylesheet",
          reason: "Should not parse any tags");
    });

    test("No style sheet", () {
      List<InlineSpan> spans = parseBBCode("Some [b]test data[/b] without stylesheet", stylesheet: emptySheet);
      expect(spans.length, 1,
          reason: "Text should be parsed into 1 span of the same style.");
      expect(spans[0].toPlainText(), "Some [b]test data[/b] without stylesheet",
          reason: "Should not parse any tags and keep them as is.");
    });

    var boldSheet = BBStylesheet(tags: [
      BoldTag()
    ]);

    test("Single tag sheet", () {
      List<InlineSpan> spans = parseBBCode("Some [b]test data[/b] with boldSheet", stylesheet: boldSheet);
      expect(spans.length, 3,
          reason: "Text should be parsed into 1 span of the same style.");
      expect(spans[0].toPlainText(), "Some ",
          reason: "Content.");
      expect(spans[1].toPlainText(), "test data",
          reason: "Content.");
      expect(spans[2].toPlainText(), " with boldSheet",
          reason: "Content.");
    });
  });

  group("BBStylesheet", () {

    test("Creation", () {
      var sheet = BBStylesheet(tags: []);

      expect(sheet.tags.length, 0, reason: "Should be empty on creation");
      expect(sheet.validTags.length, 0, reason: "Should be empty on creation");
    });

    test("Verify addition", () {
      var sheet = BBStylesheet(tags: []);

      var tag = BoldTag();
      sheet.addTag(BoldTag());

      expect(sheet.tags.length, 1, reason: "Should contain one element");
      expect(sheet.validTags.length, 1, reason: "Should contain one element");
      expect(sheet.validTags.contains(tag.tag), true, reason: "Should return the B tag");

      expect(() => sheet.addTag(tag), throwsA(anything));
    });

    test("Verify replacement", () {
      var sheet = BBStylesheet(tags: []);

      var startTag = BoldTag();
      var replaceTag = BoldTag(weight: FontWeight.w500);

      expect(() => sheet.replaceTag(BoldTag()), throwsA(anything));
      sheet.addTag(startTag);

      expect(sheet.tags.length, 1, reason: "Should contain one element");
      expect(sheet.validTags.length, 1, reason: "Should contain one element");
      expect(sheet.validTags.contains(startTag.tag), true, reason: "Should return the B tag");

      // Check if this is actually the same tag
      var returned = sheet.tags[startTag.tag] as BoldTag;
      expect(returned.weight, startTag.weight, reason: "Should have the same weight.");

      sheet.replaceTag(replaceTag);
      var returnedReplacement = sheet.tags[startTag.tag] as BoldTag;
      expect(returnedReplacement.weight, replaceTag.weight, reason: "Should have the same weight.");
    });

    test("Default text style test", () {
      var textStyle = const TextStyle(fontSize: 48, color: Colors.grey);
      var styleSheet= BBStylesheet(tags: [], defaultText: textStyle);

      List<InlineSpan> spans = parseBBCode("Some test data without bbcode", stylesheet: styleSheet);
      expect(spans[0].style, textStyle,
          reason: "Content should stay the same.");
    });
  });
}
