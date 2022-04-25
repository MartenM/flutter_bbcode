import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/cupertino.dart';

/// A [ParsedElement] is used to store parsed elements that might need future edits.
/// In the [FlutterRenderer] this is used to keep a stack of tags that need styling around them.
class ParsedElement {
  final bbob.Element element;
  final List<InlineSpan> _parsedChildren = [];

  ParsedElement(this.element);

  void addChild(InlineSpan span) {
    _parsedChildren.add(span);
  }

  void addAllChild(List<InlineSpan> spans) {
    _parsedChildren.addAll(spans);
  }

  List<InlineSpan> get parsedChildren => _parsedChildren;
}
