import 'dart:developer';

import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'parser/flutter_renderer.dart';
import 'style/stylesheet.dart';

/// Signature used by [BBCodeText.errorBuilder] to create a replacement when BBCode could not be parsed correctly.
typedef BBCodeErrorWidgetBuilder = Widget Function(
    BuildContext context, Object error, StackTrace? stackTrace);

/// A Widget that displays rendered BBCode using the [RichText] widget.
class BBCodeText extends StatelessWidget {
  /// The data to be rendered. Usually a text that contains BBCode tags.
  final String data;

  /// Contains all relevant style information for parsing the BBCode.
  final BBStylesheet? stylesheet;

  /// The error builder that's used when something went wrong during the parsing of the BBCode.
  ///
  /// When the [errorBuilder] is left as NULL parse failures will either result in:
  /// 1. An error widget when in debug mode.
  /// 2. An text widget with the original text when not in debug mode.
  final BBCodeErrorWidgetBuilder? errorBuilder;

  /// Main constructor
  ///
  /// The [data] should be a string of BBCode text. This text can contain line breaks.
  /// The [tagParsers] are the parsers for the tags. When left empty, all available tag parsers will be used. One might
  /// want to get the subset of [_allTags] and additionally overwrite some like [UrlTag] to fit with the style scheme.
  const BBCodeText(
      {Key? key,
      required this.data,
      this.stylesheet,
      this.errorBuilder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Used to catch any errors.
    Object? error;
    StackTrace? stackTrace;

    // Parse the BBCode and catch an errors.
    List<InlineSpan> spans =
        parseBBCode(data, stylesheet: stylesheet, onError: (err, stack) {
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

    if (stylesheet?.selectableText ?? false) {
      return SelectableText.rich(TextSpan(children: spans));
    }

    // Improve accessibility, scale text with textScaleFactor.
    var textScaler = MediaQuery.of(context).textScaler;

    return RichText(
        text: TextSpan(children: spans), textScaler: textScaler);
  }
}

/// Parses BBCode [InlineSpan] elements. These elements can then be used in a [RichText] widget.
///
/// The [stylesheet] is used for parsing. If none is provided [defaultBBStylesheet] will be used instead.
/// Additionally an [onError] method is available for advanced error handling.
List<InlineSpan> parseBBCode(
  String data, {
  BBStylesheet? stylesheet,
  Function(Object error, StackTrace? stackTrace)? onError,
}) {
  // Set default style
  stylesheet ??= defaultBBStylesheet();

  // Use the parser to parse into nodes.
  bbob.ParseErrorMessage? errorObject;
  final nodes =
      bbob.parse(data, validTags: stylesheet.validTags, onError: (parseError) {
    errorObject = parseError;
  });

  if (errorObject != null) {
    onError?.call(errorObject!, StackTrace.current);
    return [];
  }

  // Use the FlutterRenderer to convert the nodes into
  // InlineSpan widgets.
  FlutterRenderer renderer = FlutterRenderer(stylesheet: stylesheet);

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
