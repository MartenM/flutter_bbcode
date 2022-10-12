import 'dart:developer';

import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/src/parsed_element.dart';
import 'package:flutter_bbcode/tags/tag_parser.dart';

/// An exception when rendering a tag results in an error.
/// This is usually due to faulty implementations.
class TagRenderException implements Exception {
  bbob.Element element;
  Object parent;
  StackTrace? stackTrace;

  TagRenderException(this.element, this.parent, this.stackTrace);

  @override
  String toString() {
    return "Failed to parse the tag: [${element.tag}]. Reason: ${parent.toString()}";
  }
}

/// Empty class from which other nodes can extend.
/// Render data is used to give information about the rendering process to child nodes.
abstract class RenderData {}

/// The flutter rendered walks through list of [bbob.Node]s.
/// The output is a InlineSpan which can be used by the [RichText] widget.
class FlutterRenderer extends bbob.NodeVisitor {
  /// The map that has the tags to -> parser
  /// The parsers modify the renderer.
  final Map<String, AbstractTag> _parsers = {};

  /// The default style. This will be the first style on the [_styleStack].
  final TextStyle defaultStyle;

  /// The list of output spans that will be in the rich text widget.
  late List<InlineSpan> _output;

  /// The [_styleStack] contains the stack of styles. After each element that
  /// modified the style it should remove it's style from the stack.
  final List<TextStyle> _styleStack = [];

  /// The [_gestureRecognizerStack] is used to keep track of actions on the text.
  /// By default this list is empty.
  final List<Function()> _tapActions = [];

  /// The [_wrapStyleBuffer] is used for elements that need styling around them.
  /// When a list entry is present it is being written to instead of the [_output].
  /// After the style tag ends that created the buffer it should write all output to [_output].
  final List<ParsedElement> _wrapStyleBuffer = [];

  /// A stack that is used to store render data.
  /// Render data is used by underlying tags to define their style.
  final List<RenderData> _renderDataStack = [];

  /// The current tag that is currently being parsed.
  bbob.Element? _currentTag;
  bbob.Element? get currentTag => _currentTag;

  /// String buffer to prevent creating lots of [InlineSpan] elements by grouping text together.
  final StringBuffer _textBuffer = StringBuffer();

  FlutterRenderer(
      {required this.defaultStyle, Set<AbstractTag> parsers = const {}}) {
    for (var parser in parsers) {
      _parsers[parser.tag] = parser;
    }
  }

  List<InlineSpan> render(List<bbob.Node> nodes) {
    _output = [];
    _styleStack.clear();
    _styleStack.add(defaultStyle);

    for (var node in nodes) {
      node.accept(this);
    }
    _writeBuffer();

    // Cleanup checks
    assert(_styleStack.length == 1);
    assert(_tapActions.isEmpty);
    assert(_wrapStyleBuffer.isEmpty);
    assert(_renderDataStack.isEmpty);
    return _output;
  }

  @override
  void visitElementAfter(bbob.Element element) {
    // Write the current buffer
    _writeBuffer();

    _currentTag = element;

    // Gets the corresponding BBCode tag parser.
    AbstractTag? parser = _parsers[element.tag.toLowerCase()];
    if (parser == null) return;

    parser.onTagEnd(this);
  }

  /// Called at the start of an element.
  /// Return false if the children should be skipped. True if they should be visited.
  @override
  bool visitElementBefore(bbob.Element element) {
    // Write previous elements
    _writeBuffer();

    _currentTag = element;

    AbstractTag? parser = _parsers[element.tag];
    if (parser == null) return true;

    try {
      parser.onTagStart(this);
      if (parser is AdvancedTag) {
        _output.addAll(parser.parse(this, element));
        return false;
      }
      return true;
    } catch (error, stack) {
      // When in debug mode print the original stack too. This can help debugging the actual tag parser.
      if (kDebugMode) {
        log("The original stacktrace for this error:");
        log(stack.toString());
      }
      throw TagRenderException(element, error, stack);
    }
  }

  @override
  void visitText(bbob.Text text) {
    _textBuffer.write(text.text);
  }

  TextStyle getCurrentStyle() {
    assert(_styleStack.isNotEmpty);
    return _styleStack.last;
  }

  TapGestureRecognizer? getCurrentGestureRecognizer() {
    return _tapActions.isEmpty
        ? null
        : (TapGestureRecognizer()..onTap = _tapActions.last);
  }

  /// Pushes a [TextStyle] to the [_styleStack].
  void pushStyle(TextStyle style) {
    _styleStack.add(style);
  }

  /// Pops the most recent addition from the [_styleStack].
  void popStyle() {
    _styleStack.removeLast();
  }

  void pushTapAction(Function() onTap) {
    _tapActions.add(onTap);
  }

  void popTapAction() {
    assert(_tapActions.isNotEmpty);
    _tapActions.removeLast();
  }

  Function()? peekTapAction() {
    return _tapActions.isEmpty ? null : _tapActions.last;
  }

  /// Creates a new buffer for a wrapped style.
  void startWrappedStyle(bbob.Element element) {
    _wrapStyleBuffer.add(ParsedElement(element));
  }

  /// Ends a wrapped style and returns the [ParsedElement]
  ParsedElement endWrappedStyle() {
    assert(_wrapStyleBuffer.isNotEmpty);
    return _wrapStyleBuffer.removeLast();
  }

  /// Adds a new [RenderData] object to the [_renderDataStack].
  void startRenderData(RenderData data) {
    _renderDataStack.add(data);
  }

  /// Pops the last render data from the stack.
  void endRenderData() {
    assert(_renderDataStack.isNotEmpty);
    _renderDataStack.removeLast();
  }

  /// Gets the currently used [RenderData] such that it can be used
  /// by a child node.
  RenderData getRenderData() {
    assert(_renderDataStack.isNotEmpty);
    return _renderDataStack.last;
  }

  /// Appends [TextSpan]s and writes it to the current [_wrappedStyleBuffer] or
  /// writes it to the output directly.
  void appendTextSpans(List<InlineSpan> spans) {
    if (_wrapStyleBuffer.isNotEmpty) {
      _wrapStyleBuffer.last.addAllChild(spans);
      return;
    }

    _output.addAll(spans);
  }

  /// Appends a [TextSpan] and writes it to the current [_wrappedStyleBuffer] or
  /// writes it to the output directly.
  void appendTextSpan(TextSpan span) {
    if (_wrapStyleBuffer.isNotEmpty) {
      _wrapStyleBuffer.last.addChild(span);
      _textBuffer.clear();
      return;
    }

    _output.add(span);
  }

  /// Writes the current text buffer to the correct output.
  /// This can either be a wrappedStyle or the output.
  void _writeBuffer() {
    if (_textBuffer.isEmpty) return;
    if (_wrapStyleBuffer.isNotEmpty) {
      _wrapStyleBuffer.last.addChild(_createSpan());
      _textBuffer.clear();
      return;
    }

    _output.add(_createSpan());

    _textBuffer.clear();
  }

  /// Creates a [TextSpan] from the [_textBuffer].
  TextSpan _createSpan() {
    return TextSpan(
        text: _textBuffer.toString(),
        style: getCurrentStyle(),
        recognizer: getCurrentGestureRecognizer());
  }
}
