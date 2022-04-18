
import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_renderer.dart';

/// The base class for any BBCode tag.
abstract class AbstractTag {
  final String tag;

  AbstractTag({
    required this.tag
  });

  void onTagStart(FlutterRenderer renderer) {}
  void onTagEnd(FlutterRenderer renderer) {}
}

/// The [StyleTag] changes the way the text is rendered.
/// It pushes a new style on to the stack and pops it after it has been used.
/// If more control is required the [onTagStart] and [onTagEnd] methods can be overwritten. The [UrlTag] does this for example.
/// Most of the style tags should inhirit from this.
abstract class StyleTag extends AbstractTag {

  StyleTag(String tag) : super(tag: tag);

  TextStyle transformStyle(TextStyle oldStyle, Map<String, String>? attributes);

  @override
  void onTagStart(FlutterRenderer renderer) {
    TextStyle newStyle = transformStyle(renderer.getCurrentStyle(), renderer.currentTag?.attributes);
    renderer.pushStyle(newStyle);
    super.onTagStart(renderer);
  }

  @override
  void onTagEnd(FlutterRenderer renderer) {
    renderer.popStyle();
    super.onTagEnd(renderer);
  }
}

/// An abstract tag takes fully control over it's children.
/// This can be useful when it requires different styling.
/// Do note that it should respect the latest [StyleTag] and tap action of the renderer.
/// This is mostly to ensure that the [UrlTag] keeps working.
abstract class AdvancedTag extends AbstractTag {
  AdvancedTag(String tag) : super(tag: tag);

  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element);
}

