import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/src/parsed_element.dart';
import 'package:flutter_bbcode/tags/tag_parser.dart';

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

    parser.onTagStart(this);
    if (parser is AdvancedTag) {
      _output.addAll(parser.parse(this, element));
      return false;
    }
    return true;
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

  void startWrappedStyle(bbob.Element element) {
    _wrapStyleBuffer.add(ParsedElement(element));
  }

  ParsedElement endWrappedStyle() {
    assert(_wrapStyleBuffer.isNotEmpty);
    return _wrapStyleBuffer.removeLast();
  }

  void attachOutput(List<InlineSpan> spans) {
    if(_wrapStyleBuffer.isNotEmpty) {
      _wrapStyleBuffer.last.addAllChild(spans);
      return;
    }
    _output.addAll(spans);
  }

  void _writeBuffer() {
    if (_textBuffer.isEmpty) return;
    if(_wrapStyleBuffer.isNotEmpty) {
      _wrapStyleBuffer.last.addChild(_createSpan());
      _textBuffer.clear();
      return;
    }

    _output.add(_createSpan());

    _textBuffer.clear();
  }

  TextSpan _createSpan() {
    return TextSpan(
        text: _textBuffer.toString(),
        style: getCurrentStyle(),
        recognizer: getCurrentGestureRecognizer()
    );
  }
}
