library flutter_bbcode;

import 'dart:developer';

import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_renderer.dart';
import 'package:flutter_bbcode/tags/basic_tags.dart';
import 'package:flutter_bbcode/tags/tag_parser.dart';

Set<AbstractTag> allTags = {
  BoldTag(),
  ItalicTag(),
  UnderlineTag(),
  StrikeThroughTag(),
  ColorTag(),
  HeaderTag(1, 28),
  HeaderTag(2, 26),
  HeaderTag(2, 24),
  HeaderTag(3, 22),
  HeaderTag(4, 20),
  HeaderTag(5, 18),
  HeaderTag(6, 16),
  UrlTag(),
  ImgTag(),
  QuoteTag(),
  SpoilerTag(),
};

/// A paragraph of BBCode text.
class BBCodeText extends StatelessWidget {
  final String data;
  final bool selectable;
  final Set<AbstractTag>? tagsParsers;
  final TextStyle? defaultStyle;

  /// Creates a paragraph of BBCode text.
  /// The [data] should be a string of BBCode text. This text can contain line breaks.
  /// Use [selectable] to make the text selectable by the user.
  /// A [defaultStyle] can be supplied to the builder.
  /// The [tagParsers] are the parsers for the tags. When left empty, all available tag parsers will be used. One might
  /// want to get the subset of [_allTags] and additionally overwrite some like [UrlTag] to fit with the style scheme.
  const BBCodeText({
    Key? key,
    required this.data,
    this.selectable = false,
    this.tagsParsers,
    this.defaultStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Used to catch any errors.
    Object? error;
    StackTrace? stackTrace;

    // Parse the BBCode and catch an errors.
    List<InlineSpan> spans = parseBBCode(data,
        parsers: tagsParsers,
        defaultStyle: defaultStyle, onError: (err, stack) {
      error = err;
      stackTrace = stack;
    });

    if (error != null || stackTrace != null) {
      if (kDebugMode) {
        log(error.toString());
        log(stackTrace.toString());
        return ErrorWidget.withDetails(
            message:
                "An error occurred while attempting to parse the BBCode.\n${error.toString()}");
      }

      return RichText(
          text: const TextSpan(
              text: "An error occurred attempting to parse the BBCode."));
    }

    if (selectable) {
      return SelectableText.rich(TextSpan(children: spans));
    }
    return RichText(text: TextSpan(children: spans));
  }
}

/// Parses BBCode [InlineSpan] elements. These elements can then be used in a [RichText] widget.
/// The [parers] are used for parsing. If none are specified all will be used.
/// Additionally an [onError] method is available for advanced error handling.
/// The default style from the [context] is used as default text.
List<InlineSpan> parseBBCode(
  String data, {
  Set<AbstractTag>? parsers,
  Function(Object error, StackTrace? stackTrace)? onError,
  TextStyle? defaultStyle,
}) {
  // Use the parser to parse into nodes.
  bbob.ParseErrorMessage? errorObject;
  final nodes = bbob.parse(data,
      validTags: parsers == null
          ? allTags.map((e) => e.tag).toSet()
          : parsers.map((e) => e.tag).toSet(), onError: (parseError) {
    errorObject = parseError;
  });

  if (errorObject != null) {
    onError?.call(errorObject!, StackTrace.current);
    return [];
  }

  // Use the FlutterRenderer to convert the nodes into
  // InlineSpan widgets.
  FlutterRenderer renderer = FlutterRenderer(
      defaultStyle:
          defaultStyle ?? const TextStyle(color: Colors.black, fontSize: 14),
      parsers: parsers ?? allTags);

  late List<InlineSpan> spans;
  try {
    spans = renderer.render(nodes);
  } catch (error, stack) {
    onError?.call(error, stack);
    return [];
  }

  // Return the inline spans.
  return spans;
}
