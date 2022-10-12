library flutter_bbcode;

import 'dart:developer';

import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_renderer.dart';
import 'package:flutter_bbcode/tags/basic_tags.dart';
import 'package:flutter_bbcode/tags/list_tag.dart';
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
  ListTag(ListItemStyle("%index%. ", const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), ListItemStyle("● ", const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
  ListItem()
};

/// Signature used by [BBCodeText.errorBuilder] to create a replacement when BBCode could not be parsed
/// correctly.
typedef BBCodeErrorWidgetBuilder = Widget Function(
    BuildContext context, Object error, StackTrace? stackTrace);

/// A paragraph of BBCode text.
class BBCodeText extends StatelessWidget {
  /// The data to be rendered. Usually a text that contains BBCode tags.
  final String data;

  /// If the text should be selectable or not.
  final bool selectable;

  /// An set of [AbstractTag] parsers. These handle the tags that are parsed into widgets.
  final Set<AbstractTag>? tagsParsers;

  /// The default text style used by the widget.
  final TextStyle? defaultStyle;

  /// The error builder that's used when something went wrong during the parsing of the BBCode.
  /// When the [errorBuilder] is left as NULL parse failures will either result in:
  /// 1. An error widget when in debug mode.
  /// 2. An text widget with the original text when not in debug mode.
  final BBCodeErrorWidgetBuilder? errorBuilder;

  /// Creates a paragraph of BBCode text.
  /// The [data] should be a string of BBCode text. This text can contain line breaks.
  /// Use [selectable] to make the text selectable by the user.
  /// A [defaultStyle] can be supplied to the builder.
  /// The [tagParsers] are the parsers for the tags. When left empty, all available tag parsers will be used. One might
  /// want to get the subset of [_allTags] and additionally overwrite some like [UrlTag] to fit with the style scheme.
  const BBCodeText(
      {Key? key,
      required this.data,
      this.selectable = false,
      this.tagsParsers,
      this.defaultStyle,
      this.errorBuilder})
      : super(key: key);

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

    // Handle any potential errors.
    if (error != null) {
      // Log the error if the app is running in debug mode or if verbose logging has been enabled.
      if (kDebugMode) {
        log(error.toString());
        log(stackTrace.toString());

        if (errorBuilder == null) {
          return ErrorWidget.withDetails(
              message:
                  "An error occurred while attempting to parse the BBCode.\n${error.toString()}"
                  "\n\n"
                  "No error builder was provided.");
        }
      }

      if (errorBuilder == null) {
        return Text(data);
      }

      return errorBuilder!(context, error!, stackTrace);
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
