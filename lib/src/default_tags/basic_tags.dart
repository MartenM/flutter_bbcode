import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bbcode/src/parser/flutter_renderer.dart';
import 'package:flutter_bbcode/src/default_tags/widgets/quote_widget.dart';
import 'package:flutter_bbcode/src/util/color_util.dart';
import 'package:bbob_dart/bbob_dart.dart' as bbob;

import 'abstract_tags.dart';
import 'widgets/spoiler_widget.dart';

/// This file holds all basic tags that come with the project.
/// These range from the bold, italic, underline to img tags.
/// Feel free to add any tags you feel like the project is currently missing.

/// Basic implementation for [b] using the [StyleTag].
/// Defaults ot [FontWeight.bold].
class BoldTag extends StyleTag {
  final FontWeight weight;
  BoldTag({this.weight = FontWeight.bold}) : super('b');

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(fontWeight: weight);
  }
}

class ItalicTag extends StyleTag {
  ItalicTag() : super('i');

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(fontStyle: FontStyle.italic);
  }
}

class UnderlineTag extends StyleTag {
  UnderlineTag() : super('u');

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(decoration: TextDecoration.underline);
  }
}

class StrikeThroughTag extends StyleTag {
  StrikeThroughTag() : super('s');

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(decoration: TextDecoration.lineThrough);
  }
}

/// Implements the [color] tag using the [StyleTag].
/// Only supports HEX colours.
class ColorTag extends StyleTag {
  ColorTag() : super('color');

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    if (attributes?.entries.isEmpty ?? true) {
      return oldStyle;
    }

    String? hexColor = attributes?.entries.first.key;
    if (hexColor == null) return oldStyle;
    return oldStyle.copyWith(color: HexColor.fromHex(hexColor));
  }
}

/// Basic implementation of the [h<number>] tag.
/// [_textSize] is used to define the new textSize.
class HeaderTag extends StyleTag {
  final double _textSize;

  HeaderTag(int headerIndex, this._textSize) : super("h$headerIndex");

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(fontSize: _textSize);
  }
}

/// Default implementation of the [URL] tag.
/// Defaults to a log function when clicked.
class UrlTag extends StyleTag {
  final Function(String)? onTap;

  UrlTag({this.onTap}) : super("url");

  @override
  void onTagStart(FlutterRenderer renderer) {
    late String url;
    if (renderer.currentTag?.attributes.isNotEmpty ?? false) {
      url = renderer.currentTag!.attributes.keys.first;
    } else if (renderer.currentTag?.children.isNotEmpty ?? false) {
      url = renderer.currentTag!.children.first.textContent;
    } else {
      url = "URL is missing!";
    }

    renderer.pushTapAction(() {
      if (onTap == null) {
        log("URL $url has been pressed!");
        return;
      }
      onTap!(url);
    });
    super.onTagStart(renderer);
  }

  @override
  void onTagEnd(FlutterRenderer renderer) {
    renderer.popTapAction();
    super.onTagEnd(renderer);
  }

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(
        decoration: TextDecoration.underline, color: Colors.blue);
  }
}

/// Default [img] tag.
/// Extends AdvancedTag because it's children should not be displayed.
/// Instead we use those to create the image widget.
class ImgTag extends AdvancedTag {
  ImgTag() : super("img");

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    if (element.children.isEmpty) {
      return [TextSpan(text: "[$tag]")];
    }

    // Image URL is the first child / node. If not, that's an issue for the person writing
    // the BBCode.
    String imageUrl = element.children.first.textContent;

    final image = Image.network(imageUrl,
        errorBuilder: (context, error, stack) => Text("[$tag]"));

    if (renderer.peekTapAction() != null) {
      return [
        WidgetSpan(
            child: GestureDetector(
          onTap: renderer.peekTapAction(),
          child: image,
        ))
      ];
    }

    return [
      WidgetSpan(
        child: image,
      )
    ];
  }
}

class QuoteTag extends WrappedStyleTag {
  final TextStyle headerTextStyle;

  QuoteTag({
    this.headerTextStyle = const TextStyle(),
  }) : super("quote");

  @override
  List<InlineSpan> wrap(bbob.Element element, List<InlineSpan> spans) {
    String? author =
        element.attributes.isNotEmpty ? element.attributes.values.first : null;

    return [
      WidgetSpan(
          child: QuoteDisplay(
        author: author,
        headerTextStyle: headerTextStyle,
        content: spans,
      )),
    ];
  }
}

class SpoilerTag extends WrappedStyleTag {
  SpoilerTag() : super("spoiler");

  @override
  List<InlineSpan> wrap(bbob.Element element, List<InlineSpan> spans) {
    late String text;
    if (element.attributes.isNotEmpty) {
      text = "Spoiler: ${element.attributes.values.join(' ')}";
    } else {
      text = "Spoiler";
    }

    return [
      WidgetSpan(
          child: SpoilerDisplay(
        spoilerText: text,
        content: spans,
      ))
    ];
  }
}
